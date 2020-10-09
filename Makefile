IMAGE_VERSION := $(shell cat image.yaml | egrep ^version  | cut -d"\"" -f2)
SHORTENED_LATEST_VERSION := $(shell echo $(IMAGE_VERSION) | awk -F. '{print $$1"."$$2}')
BUILD_ENGINE := docker
.DEFAULT_GOAL := build
CEKIT_CMD := cekit -v ${cekit_option}

clone-repos:
# if the NO_TEST env defined, proceed with the tests, as first step prepare the repo to be used
ifneq ($(ignore_test),true)
	cd tests/test-apps && sh clone-repo.sh
endif

.PHONY: list
list:
	@python3 scripts/list-images.py

# Build all images
.PHONY: build
# start to build the images
build: clone-repos _build

_build:
	@for f in $(shell make list); do make build-image image_name=$${f}; done

.PHONY: build-image
image_name=
build-image:
ifneq ($(ignore_build),true)
	${CEKIT_CMD} build --overrides-file ${image_name}-overrides.yaml ${BUILD_ENGINE}
endif
# if ignore_test is set to true, ignore the tests
ifneq ($(ignore_test),true)
	${CEKIT_CMD} test --overrides-file ${image_name}-overrides.yaml behave
endif
ifneq ($(findstring rc,$(IMAGE_VERSION)),rc)
	${BUILD_ENGINE} tag quay.io/kiegroup/${image_name}:${IMAGE_VERSION} quay.io/kiegroup/${image_name}:${SHORTENED_LATEST_VERSION}
endif

# push images to quay.io, this requires permissions under kiegroup organization
.PHONY: push
push: build _push

_push:
	@for f in $(shell make list); do make push-image image_name=$${f}; done

.PHONY: push-image
image_name=
push-image:
	docker push quay.io/kiegroup/${image_name}:${IMAGE_VERSION}
	docker push quay.io/kiegroup/${image_name}:latest
ifneq ($(findstring rc,$(IMAGE_VERSION)), rc)
	@echo "${SHORTENED_LATEST_VERSION} will be pushed"
	docker push quay.io/kiegroup/${image_name}:${SHORTENED_LATEST_VERSION}
endif


# push staging images to quay.io, done before release, this requires permissions under kiegroup organization
# to force updating an existing tag instead create a new one, use `$ make push-staging override=-o`
.PHONY: push-staging
push-staging: build _push-staging
_push-staging:
	python3 scripts/push-staging.py ${override}


# push to local registry, useful to push the built images to local registry
# requires parameter: REGISTRY: my-custom-registry:[port]
# requires pre built images, if no images, run make build first
# the shortened version will be used so operator can fetch it from the local namespace.
# use the NS env to set the current namespace, if no set openshift will be used
# example:  make push-local-registry REGISTRY=docker-registry-default.apps.spolti.cloud NS=spolti-1
.PHONY: push-local-registry
push-local-registry:
	/bin/sh scripts/push-local-registry.sh ${REGISTRY} ${SHORTENED_LATEST_VERSION} ${NS}

# run bat tests locally
.PHONY: bats
bats:
	./scripts/run-bats.sh