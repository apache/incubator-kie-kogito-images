#!/usr/bin/env bash
# Simple usage: /bin/sh scripts/push-local-registry.sh ${REGISTRY} ${SHORTENED_LATEST_VERSION} ${NS}

BUILD_ENGINE="docker"
CEKIT_CMD="cekit --verbose --redhat"

ver=$(cekit --version )
ver=$((${ver//./} + 0))
if [ ${ver//./} -lt 379 ]; then
    echo "Using CEKit version $ver, Please use CEKit version 3.8.0 or greater."
    exit 10
fi

image="${2}"
if [ "x${image}" == "x" ]; then
    echo "image_name can't be empty.."
    exit 8
fi

function get_parent_image_overrides() {
    echo $()
}

ACTION=${1}
case ${ACTION} in
    "build")
        ${CEKIT_CMD} build --overrides-file $(python3 scripts/list-images.py --parent-image=${image})-overrides.yaml --overrides-file ${image_name}-overrides.yaml ${BUILD_ENGINE}
    ;;

    "test")
        ${CEKIT_CMD} test --overrides-file $(python3 scripts/list-images.py --parent-image=${image})-overrides.yaml --overrides-file ${image_name}-overrides.yaml behave
    ;;
    *)
        echo "Please use build or test actions."
    ;;
esac

