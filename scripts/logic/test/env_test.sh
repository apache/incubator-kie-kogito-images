#!/bin/bash

export image_id=$1
export image_sha=$2

export image_registry=brew.registry.redhat.io/rh-osbs
export image_serverless_namespace=openshift-serverless-1-tech-preview
export image_name=${image_serverless_namespace}-${image_id}@sha256
export image_full_tag=${image_registry}/${image_name}:${image_sha}
export image_descriptor_filename=${image_id}-image.yaml
