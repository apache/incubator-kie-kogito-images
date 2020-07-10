### Kogito helper scripts

On this directory you can find some python scripts used to help with some repetitive tasks.

Today we have these scripts:

- [manage-kogito-version.py](manage-kogito-version.py)
- [push-local-registry.sh](push-local-registry.sh)
- [push-staging.py](push-staging.py)
- [update-maven-information.py](update-maven-information.py)
- [common.py](common.py)

### Managing Kogito images version

The manage-kogito-version script will help when we need to update the current version due a new release or prepare the
master branch for the next release.

#### Script dependencies

The `manage-kogito-version.py` has one dependency that needs to be manually installed:

```bash
$ pip install -U ruamel.yaml
```
This script has a dependency on `common.py`.

#### Usage
Its usage is pretty simple, only one parameter is accepted:

```bash
$ python manage-kogito-version.py --bump-to 1.0.0  
```

The script also allows you to set a custom branch for the kogito-examples repository on the behave tests. Useful for minor
releases, e.g. 0.9.x branch.

```bash
$ python manage-kogito-version.py --bump-to 0.10.1-rc1 --apps-branch 0.10.x
```

The command above will update all the needed files to the version 1.0.0. These changes includes updates on

 - all cekit modules
 - image.yaml file descriptor
 - kogito-imagestream.yaml
 

### Pushing Images to a local registry

This script will help you while building images and test in a local OpenShift Cluster. It requires you to already have
images built in your local registry with the tag following the patter: X.Z, e.g. 0.10:

```text
quay.io/kiegroup/kogito-jobs-service:0.10
```

The [Makefile](../Makefile) has an option to do it, it can be invoked as the following sample:

```bash
$ make push-local-registry REGISTRY=docker-registry-default.apps.test.cloud NS=test-1
```

Where **NS** stands for the namespace where the images will be available.

To execute the script directly:

```bash
$ /bin/sh scripts/push-local-registry.sh my_registry_address 0.10 my_namespace
```

### Pushing staging images.

Staging images are the release candidates which are pushed mainly after big changes that has direct impact on how
the images will behave and also when new functionality is added.

The script updates the version on:

 - all cekit modules
 - image.yaml file descriptor
 - kogito-imagestream.yaml
 

#### Script dependencies

The `push-staging.py` has a few dependencies that probably needs to be manually installed:

```bash
$ pip install -U docker yaml
$ pip install -U ruamel.yaml
```

#### Usage

This script is called as the last step of the `make push-staging` command defined on the [Makefile](../Makefile).

It will look for the current RC images available on [quay.io](https://quay.io/organization/kiegroup) to increase the rc tag 
accordingly then push the new tag so it can be tested by others. 

### Updating Kogito Images service artifacts.

The update-maven-information script will help in fetching the artifacts from the Maven repository
and update them in the `module.yaml` files of the kogito services

#### Script dependencies

The `update-maven-information.py` has some dependencies that needs to be manually installed:

```bash
$ pip install -U ruamel.yaml
$ pip install -U elementpath
```
It's usage is pretty simple as well:

```bash
$ python update-maven-information.py
```

#### Usage

##### Update Maven artifact version

This script also accepts `--version` as argument in specifying the current version of artifacts which need to be fetched

```bash
$ python update-maven-information.py --version='8.0.0-SNAPSHOT'
$ python update-maven-information.py --version='0.12.0'
```
if no argument is given, it takes the default value of `8.0.0-SNAPSHOT`

The command will update the needed files with latest  URL:

 - kogito-data-index/module.yaml
 - kogito-jobs-service/module.yaml
 - kogito-management-console/module.yaml

as well as the `KOGITO_VERSION` environment variable present in the Kogito modules.

##### Update Maven artifact repository url

This script also accepts `--repo-url` as argument in specifying the Maven repository from where to fetch the artifacts

```bash
$ python update-maven-information.py --repo-url='https://maven-repository.mirror.com/public'
```
if no argument is given, it takes the JBoss repository as the default value.

The command will update the needed files with the new URL:

 - kogito-data-index/module.yaml
 - kogito-jobs-service/module.yaml
 - kogito-management-console/module.yaml

as well as the `JBOSS_MAVEN_REPO_URL` where present in the repository.

### Common script

The `common.py` script defines some common functions for the scripts.
