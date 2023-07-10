#!/bin/bash

DOCKER_VERSION=${VERSION:-"20.10.9"}
RBD_VER=${RBD_VER:-'enterprise-2211-gitee'}

function download_offline_package () {
    if [ $(arch) == "x86_64" ] || [ $(arch) == "amd64" ]; then
        wget https://pkg.rainbond.com/offline/nfs-client/nfs_all.tar.gz -O ./offline/nfs_all.tar.gz
        wget https://pkg.rainbond.com/offline/docker/docker-${DOCKER_VER}.tgz -O ./offline/docker-${DOCKER_VER}.tgz
        wget https://pkg.goodrain.com/pkg/kubectl/v1.23.10/kubectl -O ./offline/kubectl
        wget https://pkg.goodrain.com/pkg/helm/v3.10.1/helm -O ./offline/helm
    elif [ $(arch) == "aarch64" ] || [ $(arch) == "arm64" ]; then
        wget https://pkg.rainbond.com/offline/nfs-client/nfs_all_arm.tar.gz -O ./offline/nfs_all.tar.gz
        wget https://pkg.rainbond.com/offline/docker/docker-${DOCKER_VER}.tgz -O ./offline/docker-arm-${DOCKER_VER}.tgz
        wget https://pkg.goodrain.com/pkg/kubectl/v1.23.10/kubectl-arm -O ./offline/kubectl
        wget https://pkg.goodrain.com/pkg/helm/v3.10.1/helm-arm64 -O ./offline/helm
    fi
    
    wget https://get.rainbond.com/install_docker_offline.sh -O ./offline/install_docker_offline.sh
    wget https://get.rainbond.com/init_node_offline.sh -O ./offline/init_node_offline.sh
    wget https://get.rainbond.com/linux-optimize.sh -O ./offline/linux-optimize.sh
    
    chmod +x ./offline/init_node_offline.sh
    chmod +x ./offline/install_docker_offline.sh
    chmod +x ./offline/linux-optimize.sh
    chmod +x ./offline/kubectl
    chmod +x ./offline/helm
    
    wget https://pkg.rainbond.com/offline/os-kernel/kernel_upgrade.tgz -O ./offline/kernel_upgrade.tgz
}

function get_k8s_images() {

    cat >./offline/k8s_image/list.txt <<EOF
registry.cn-hangzhou.aliyuncs.com/goodrain/mirrored-coreos-etcd:v3.5.3
registry.cn-hangzhou.aliyuncs.com/goodrain/rke-tools:v0.1.87
registry.cn-hangzhou.aliyuncs.com/goodrain/mirrored-cluster-proportional-autoscaler:1.8.5
registry.cn-hangzhou.aliyuncs.com/goodrain/mirrored-coredns-coredns:1.9.0
registry.cn-hangzhou.aliyuncs.com/goodrain/mirrored-k8s-dns-node-cache:1.21.1
registry.cn-hangzhou.aliyuncs.com/goodrain/hyperkube:v1.23.10-rancher1
registry.cn-hangzhou.aliyuncs.com/goodrain/mirrored-coreos-flannel:v0.15.1
registry.cn-hangzhou.aliyuncs.com/goodrain/flannel-cni:v0.3.0-rancher6
registry.cn-hangzhou.aliyuncs.com/goodrain/mirrored-pause:3.6
registry.cn-hangzhou.aliyuncs.com/goodrain/mirrored-metrics-server:v0.6.1
rancher/mirrored-k8s-dns-kube-dns:1.21.1
rancher/mirrored-k8s-dns-dnsmasq-nanny:1.21.1
rancher/mirrored-k8s-dns-sidecar:1.21.1
EOF

    while read k8s_image_name; do
        k8s_image_tar=$(echo ${k8s_image_name} | awk -F"/" '{print $NF}' | tr : -)
        k8s_offline_image=$(echo ${k8s_image_name} | awk -F"/" '{print $NF}')

        if [[ -f "./offline/k8s_image/${k8s_image_tar}.tgz" ]]; then
            echo "[INFO] ${k8s_image_tar} image already existed"
        else
            docker pull ${k8s_image_name} ||  exit 1
            docker tag ${k8s_image_name} goodrain.me/${k8s_offline_image}
            docker save goodrain.me/${k8s_offline_image} -o ./offline/k8s_image/${k8s_offline_image}.tgz
        fi
    done <./offline/k8s_image/list.txt

}

function get_rbd_images() {

    cat >./offline/rbd_image/list.txt <<EOF
image.goodrain.com/goodrain/rainbond:$RBD_VER-allinone
image.goodrain.com/goodrain/rbd-node:$RBD_VER
image.goodrain.com/goodrain/rbd-resource-proxy:$RBD_VER
image.goodrain.com/goodrain/rbd-eventlog:$RBD_VER
image.goodrain.com/goodrain/rbd-worker:$RBD_VER
image.goodrain.com/goodrain/rbd-gateway:$RBD_VER
image.goodrain.com/goodrain/rbd-chaos:$RBD_VER
image.goodrain.com/goodrain/rbd-api:$RBD_VER
image.goodrain.com/goodrain/rbd-webcli:$RBD_VER
image.goodrain.com/goodrain/rbd-mq:$RBD_VER
image.goodrain.com/goodrain/rbd-monitor:$RBD_VER
image.goodrain.com/goodrain/rbd-mesh-data-panel:$RBD_VER
image.goodrain.com/goodrain/rbd-init-probe:$RBD_VER
image.goodrain.com/goodrain/rbd-grctl:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/builder:latest
registry.cn-hangzhou.aliyuncs.com/goodrain/runner:latest
registry.cn-hangzhou.aliyuncs.com/goodrain/rainbond-operator:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/plugins-tcm:5.1.7
registry.cn-hangzhou.aliyuncs.com/goodrain/kubernetes-dashboard:v2.6.1
registry.cn-hangzhou.aliyuncs.com/goodrain/nfs-provisioner:latest
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-db:8.0.19
registry.cn-hangzhou.aliyuncs.com/goodrain/metrics-scraper:v1.0.4
registry.cn-hangzhou.aliyuncs.com/goodrain/etcd:v3.3.18
registry.cn-hangzhou.aliyuncs.com/goodrain/mysqld-exporter:latest
registry.cn-hangzhou.aliyuncs.com/goodrain/registry:2.6.2
registry.cn-hangzhou.aliyuncs.com/goodrain/smallimage:latest
EOF
    while read rbd_image_name; do
        rbd_image_tar=$(echo ${rbd_image_name} | awk -F"/" '{print $NF}' | tr : -)
        rbd_offline_image=$(echo ${rbd_image_name} | awk -F"/" '{print $NF}')

        if [[ -f "./offline/rbd_image/${rbd_image_tar}.tgz" ]]; then
            echo "[INFO] ${rbd_image_tar} image already existed"
        else
            docker pull ${rbd_image_name} || exit 1
            docker tag ${rbd_image_name} goodrain.me/${rbd_offline_image}
            docker save goodrain.me/${rbd_offline_image} -o ./offline/rbd_image/${rbd_offline_image}.tgz
        fi
    done <./offline/rbd_image/list.txt

}

function main() {

    mkdir -p ./offline ./offline/k8s_image ./offline/rbd_image
    
    download_offline_package
    
    get_k8s_images
    
    get_rbd_images

    tar zcvf rainbond-offline-$RBD_VER.tgz offline/*

}

main
