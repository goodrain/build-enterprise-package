#!/bin/bash

DOMESTIC_BASE_NAME=${DOMESTIC_BASE_NAME:-'registry.cn-hangzhou.aliyuncs.com'}
DOMESTIC_NAMESPACE=${DOMESTIC_NAMESPACE:-'goodrain'}
BUILDER_VERSION=${BUILDER_VERSION:-'v5.8.1-release'}
RUNNER_VERSION=${RUNNER_VERSION:-'v5.8.1-release'}
KANIKO_VERSION=${KANIKO_VERSION:-'latest'}
RESOURCE_PROXY_VERSION=${RESOURCE_PROXY_VERSION:-'v5.8.1-release'}
VERSION=${VERSION:-'v5.8.1-arm'}

offline_tar_list="${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/builder:${BUILDER_VERSION}
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/runner:${RUNNER_VERSION}
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/kaniko-executor:${KANIKO_VERSION}
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/resource-proxy:${RESOURCE_PROXY_VERSION}
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-init-probe:${VERSION}-release
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-mesh-data-panel:${VERSION}-release"

for image in ${offline_tar_list}; do
    docker pull "${image}"
done

docker save -o rainbond-offline-"${VERSION}"-arm64.tar ${offline_tar_list}
