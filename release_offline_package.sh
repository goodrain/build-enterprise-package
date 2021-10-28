#!/bin/bash

export NFSCLI_URL="https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/offline/nfs-client/nfs_all.tar.gz"
export DOCKER_VER=19.03.5
RBD_VER=${RBD_VER:-'v5.4.0-release'}

function get_nfscli() {

    if [[ -f "./offline/nfs_all.tar.gz" ]]; then
        echo "[INFO] nfs binaries already existed"
    else
        wget -c "$NFSCLI_URL" || {
            echo "[ERROR] Downloading nfs binaries failed"
            exit 1
        }
        mv nfs_all.tar.gz ./offline/nfs_all.tar.gz
    fi

}

function get_kernel() {

    KERNEL_URL="https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/offline/os-kernel/kernel-lt-5.4.130-1.el7.elrepo.x86_64.rpm"
    if [[ -f "./offline/kernel-lt-5.4.130-1.el7.elrepo.x86_64.rpm" ]]; then
        echo "[INFO] Kernel upgrade package already existed"
    else
        wget -c "$KERNEL_URL" || {
            echo "[ERROR] Downloading kernel upgrade package failed"
            exit 1
        }
        mv kernel-lt-5.4.130-1.el7.elrepo.x86_64.rpm ./offline/kernel-lt-5.4.130-1.el7.elrepo.x86_64.rpm
    fi

}

function get_docker() {

    DOCKER_URL="https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/offline/docker/docker-${DOCKER_VER}.tgz"
    if [[ -f "/opt/docker/down/docker-${DOCKER_VER}.tgz" ]]; then
        echo "[INFO] docker binaries already existed"
    else
        echo -e "[INFO] \033[33mdownloading docker binaries\033[0m $DOCKER_VER"
        wget -c "$DOCKER_URL" || {
            echo "[ERROR] downloading docker failed"
            exit 1
        }
        mv ./docker-${DOCKER_VER}.tgz ./offline/docker-${DOCKER_VER}.tgz
    fi

}

function get_offline_script() {


    wget sh.rainbond.com/install_docker_offline.sh -O ./offline/install_docker_offline.sh || "echo "[ERROR] Failed to download offline script" && exit 1" && chmod +x ./offline/install_docker_offline.sh

    wget https://rainbond-script.oss-cn-hangzhou.aliyuncs.com/init_node_offline.sh -O ./offline/init_node_offline.sh || "echo "[ERROR] Failed to download offline script" && exit 1" && chmod +x ./offline/init_node_offline.sh

}

function get_command_line_tools() {

    TOOLS_URL="https://grstatic.oss-cn-shanghai.aliyuncs.com/binary/kubectl"
    if [[ -f "./offline/kubectl" ]]; then
        echo "[INFO] command line tools already existed"
    else
        wget $TOOLS_URL -O ./offline/kubectl || {
            echo "[ERROR] downloading command line tools failed"
            exit 1
        }
        chmod +x ./offline/kubectl
    fi 

}

function get_k8s_images() {

    cat >./offline/k8s_image/list.txt <<EOF
registry.cn-hangzhou.aliyuncs.com/goodrain/coreos-etcd:v3.4.13-rke
registry.cn-hangzhou.aliyuncs.com/goodrain/rke-tools:v0.1.68
registry.cn-hangzhou.aliyuncs.com/goodrain/cluster-proportional-autoscaler:1.8.1
registry.cn-hangzhou.aliyuncs.com/goodrain/coredns-coredns:1.7.0
registry.cn-hangzhou.aliyuncs.com/goodrain/k8s-dns-node-cache:1.15.13
registry.cn-hangzhou.aliyuncs.com/goodrain/hyperkube:v1.19.6-rke
registry.cn-hangzhou.aliyuncs.com/goodrain/coreos-flannel:v0.13.0-rke
registry.cn-hangzhou.aliyuncs.com/goodrain/flannel-cni:v0.3.0-rke
registry.cn-hangzhou.aliyuncs.com/goodrain/pause:3.2
registry.cn-hangzhou.aliyuncs.com/goodrain/metrics-server:v0.3.6
rancher/k8s-dns-kube-dns:1.15.10
rancher/k8s-dns-dnsmasq-nanny:1.15.10
rancher/k8s-dns-sidecar:1.15.10
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
registry.cn-hangzhou.aliyuncs.com/goodrain/rainbond:$RBD_VER-allinone
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-node:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-resource-proxy:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-eventlog:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-worker:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-gateway:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-chaos:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-api:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-webcli:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-mq:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-monitor:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-mesh-data-panel:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-init-probe:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/rbd-grctl:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/builder:v5.4.0
registry.cn-hangzhou.aliyuncs.com/goodrain/runner:v5.4.0
registry.cn-hangzhou.aliyuncs.com/goodrain/rainbond-operator:v2.1.0
registry.cn-hangzhou.aliyuncs.com/goodrain/plugins-tcm:5.1.7
registry.cn-hangzhou.aliyuncs.com/goodrain/kubernetes-dashboard:v2.0.1-3
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
    # get nfs client package
    get_nfscli
    # get os kernel
    get_kernel
    # get docker package
    get_docker
    # get offline install rainbond script
    get_offline_script
    # Get command line tools
    get_command_line_tools
    # get kubernetes image
    get_k8s_images
    # get rainbond image
    get_rbd_images

    tar zcvf rainbond-offline-$RBD_VER.tgz offline/*

}

main
