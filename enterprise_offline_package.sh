#!/bin/bash

DOCKER_OFFLINE_VERSION=20.10.9

function download_offline_package () {
    if [ $(arch) == "x86_64" ] || [ $(arch) == "amd64" ]; then
        wget https://pkg.rainbond.com/offline/nfs-client/nfs_all.tar.gz -O ./offline/nfs_all.tar.gz
        wget https://pkg.rainbond.com/offline/docker/docker-${DOCKER_OFFLINE_VERSION}.tgz -O ./offline/docker-${DOCKER_OFFLINE_VERSION}.tgz
        wget https://pkg.goodrain.com/pkg/kubectl/v1.23.10/kubectl -O ./offline/kubectl
        wget https://pkg.goodrain.com/pkg/helm/v3.10.1/helm -O ./offline/helm
        wget https://pkg.goodrain.com/pkg/rke/v1.3.15/rke -O ./offline/rke
    elif [ $(arch) == "aarch64" ] || [ $(arch) == "arm64" ]; then
        wget https://pkg.rainbond.com/offline/nfs-client/nfs_all_arm.tar.gz -O ./offline/nfs_all.tar.gz
        wget https://pkg.rainbond.com/offline/docker/docker-arm-${DOCKER_OFFLINE_VERSION}.tgz -O ./offline/docker-arm-${DOCKER_OFFLINE_VERSION}.tgz
        wget https://pkg.goodrain.com/pkg/kubectl/v1.23.10/kubectl-arm -O ./offline/kubectl
        wget https://pkg.goodrain.com/pkg/helm/v3.10.1/helm-arm64 -O ./offline/helm
        wget https://pkg.goodrain.com/pkg/rke/v1.3.15/rke-arm -O ./offline/rke
    fi
    
    wget https://get.rainbond.com/install_docker_offline.sh -O ./offline/install_docker_offline.sh
    wget https://get.rainbond.com/init_node_offline.sh -O ./offline/init_node_offline.sh
    wget https://get.rainbond.com/linux-optimize.sh -O ./offline/linux-optimize.sh
    
    chmod +x ./offline/init_node_offline.sh
    chmod +x ./offline/install_docker_offline.sh
    chmod +x ./offline/linux-optimize.sh
    chmod +x ./offline/kubectl
    chmod +x ./offline/helm
    chmod +x ./offline/rke
    
    wget https://pkg.rainbond.com/offline/os-kernel/kernel_upgrade.tgz -O ./offline/kernel_upgrade.tgz
}

function get_k8s_images() {

image_list="rainbond/mirrored-coreos-etcd:v3.5.3
rainbond/rke-tools:v0.1.87
rainbond/cluster-proportional-autoscaler:1.8.1
rainbond/mirrored-coredns-coredns:1.10.1
rainbond/mirrored-k8s-dns-node-cache:1.21.1
rainbond/hyperkube:v1.23.10-rancher1
rainbond/mirrored-coreos-flannel:v0.15.1
rainbond/flannel-cni:v0.3.0-rancher6
rainbond/mirrored-pause:3.6
rainbond/mirrored-metrics-server:v0.4.1
rainbond/mirrored-k8s-dns-kube-dns:1.21.1
rainbond/mirrored-k8s-dns-dnsmasq-nanny:1.21.1
rainbond/mirrored-k8s-dns-sidecar:1.21.1"

    for images in ${image_list}; do
        k8s_image_tar=$(echo "${images}" | awk -F"/" '{print $NF}' | tr : -)
        k8s_offline_image=$(echo "${images}" | awk -F"/" '{print $NF}')
        
        docker pull "${images}" ||  exit 1
        docker tag "${images}" goodrain.me/"${k8s_offline_image}"
        docker save goodrain.me/"${k8s_offline_image}" -o ./offline/k8s_image/"${k8s_image_tar}".tgz
    done
}

function get_rbd_images() {

DOMESTIC_BASE_NAME=${DOMESTIC_BASE_NAME:-"registry.ap-southeast-1.aliyuncs.com"}
DOMESTIC_NAMESPACE=${DOMESTIC_NAMESPACE:-"goodrain-ee"}

image_list="$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rainbond:$VERSION-allinone
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-node:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-resource-proxy:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-eventlog:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-worker:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-gateway:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-chaos:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-api:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-webcli:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-mq:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-monitor:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-mesh-data-panel:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-init-probe:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rbd-grctl:$VERSION
$DOMESTIC_BASE_NAME/$DOMESTIC_NAMESPACE/rainbond-operator:$VERSION
registry.cn-hangzhou.aliyuncs.com/goodrain/builder:latest
registry.cn-hangzhou.aliyuncs.com/goodrain/runner:latest
registry.cn-hangzhou.aliyuncs.com/goodrain/nfs-provisioner:latest
rainbond/rbd-db:8.0.19
rainbond/mysqld-exporter:latest
rainbond/kubernetes-dashboard:v2.6.1
rainbond/metrics-scraper:v1.0.4
rainbond/etcd:v3.3.18
rainbond/registry:2.6.2
rainbond/metrics-server:v0.4.1"
    
    docker login -u "$DOMESTIC_DOCKER_USERNAME" -p "$DOMESTIC_DOCKER_PASSWORD" "${DOMESTIC_BASE_NAME}"
    
    for images in ${image_list}; do
        rbd_image_tar=$(echo "${images}" | awk -F"/" '{print $NF}' | tr : -)
        rbd_offline_image=$(echo "${images}" | awk -F"/" '{print $NF}')

        docker pull "${images}" || exit 1
        docker tag "${images}" goodrain.me/"${rbd_offline_image}"
        docker save goodrain.me/"${rbd_offline_image}" -o ./offline/rbd_image/"${rbd_image_tar}".tgz
    done
}

function main() {

    mkdir -p ./offline ./offline/k8s_image ./offline/rbd_image
    
    download_offline_package
    
    get_k8s_images
    
    get_rbd_images

    tar zcvf rainbond-offline-"$VERSION".tgz offline/*

}

main
