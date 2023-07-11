#!/bin/bash

DOCKER_VERSION=${DOCKER_VERSION:-"20.10.9"}

function download_offline_package () {
    if [ $(arch) == "x86_64" ] || [ $(arch) == "amd64" ]; then
        wget https://pkg.rainbond.com/offline/nfs-client/nfs_all.tar.gz -O ./offline/nfs_all.tar.gz
        wget https://pkg.rainbond.com/offline/docker/docker-${DOCKER_VERSION}.tgz -O ./offline/docker-${DOCKER_VER}.tgz
        wget https://pkg.goodrain.com/pkg/kubectl/v1.23.10/kubectl -O ./offline/kubectl
        wget https://pkg.goodrain.com/pkg/helm/v3.10.1/helm -O ./offline/helm
        wget https://pkg.goodrain.com/pkg/rke/v1.3.15/rke -O ./offline/rke
    elif [ $(arch) == "aarch64" ] || [ $(arch) == "arm64" ]; then
        wget https://pkg.rainbond.com/offline/nfs-client/nfs_all_arm.tar.gz -O ./offline/nfs_all.tar.gz
        wget https://pkg.rainbond.com/offline/docker/docker-arm-${DOCKER_VERSION}.tgz -O ./offline/docker-arm-${DOCKER_VER}.tgz
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

image_list="rancher/mirrored-coreos-etcd:v3.5.3
rancher/rke-tools:v0.1.87
rancher/cluster-proportional-autoscaler:1.8.1
rancher/mirrored-coredns-coredns:1.10.1
rancher/mirrored-k8s-dns-node-cache:1.21.1
rancher/hyperkube:v1.23.10-rancher1
rancher/mirrored-coreos-flannel:v0.15.1
rancher/flannel-cni:v0.3.0-rancher6
rancher/mirrored-pause:3.6
rancher/mirrored-metrics-server:v0.4.1
rancher/mirrored-k8s-dns-kube-dns:1.21.1
rancher/mirrored-k8s-dns-dnsmasq-nanny:1.21.1
rancher/mirrored-k8s-dns-sidecar:1.21.1"

    for images in ${image_list}; do
        k8s_image_tar=$(echo ${images} | awk -F"/" '{print $NF}' | tr : -)
        k8s_offline_image=$(echo ${images} | awk -F"/" '{print $NF}')
        
        docker pull ${images} ||  exit 1
        docker tag ${images} goodrain.me/${k8s_offline_image}
        docker save goodrain.me/${k8s_offline_image} -o ./offline/k8s_image/${k8s_image_tar}.tgz
    done
}

function get_rbd_images() {

image_list="image.goodrain.com/goodrain/rainbond:$VERSION-allinone
image.goodrain.com/goodrain/rbd-node:$VERSION
image.goodrain.com/goodrain/rbd-resource-proxy:$VERSION
image.goodrain.com/goodrain/rbd-eventlog:$VERSION
image.goodrain.com/goodrain/rbd-worker:$VERSION
image.goodrain.com/goodrain/rbd-gateway:$VERSION
image.goodrain.com/goodrain/rbd-chaos:$VERSION
image.goodrain.com/goodrain/rbd-api:$VERSION
image.goodrain.com/goodrain/rbd-webcli:$VERSION
image.goodrain.com/goodrain/rbd-mq:$VERSION
image.goodrain.com/goodrain/rbd-monitor:$VERSION
image.goodrain.com/goodrain/rbd-mesh-data-panel:$VERSION
image.goodrain.com/goodrain/rbd-init-probe:$VERSION
image.goodrain.com/goodrain/rbd-grctl:$VERSION
image.goodrain.com/goodrain/rainbond-operator:$VERSION
registry.cn-hangzhou.aliyuncs.com/goodrain/builder:latest
registry.cn-hangzhou.aliyuncs.com/goodrain/runner:latest
registry.cn-hangzhou.aliyuncs.com/goodrain/nfs-provisioner:latest
rainbond/rbd-db:8.0.19
rainbond/mysqld-exporter:latest
rainbond/kubernetes-dashboard:v2.6.1
rainbond/metrics-scraper:v1.0.4
rainbond/etcd:v3.3.18
rainbond/registry:2.6.2"
    
    for images in ${image_list}; do
        rbd_image_tar=$(echo ${images} | awk -F"/" '{print $NF}' | tr : -)
        rbd_offline_image=$(echo ${images} | awk -F"/" '{print $NF}')

        docker pull ${images} || exit 1
        docker tag ${images} goodrain.me/${rbd_offline_image}
        docker save goodrain.me/${rbd_offline_image} -o ./offline/rbd_image/${rbd_image_tar}.tgz
    done
}

function main() {

    mkdir -p ./offline ./offline/k8s_image ./offline/rbd_image
    
    download_offline_package
    
    get_k8s_images
    
    get_rbd_images

    tar zcvf rainbond-offline-$VERSION.tgz offline/*

}

main
