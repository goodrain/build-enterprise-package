#!/bin/bash

export NFSCLI_URL="https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/offline/nfs-client/nfs_all_arm.tar.gz"
export DOCKER_VER=19.03.9
RBD_VER=${RBD_VER:-'enterprise-2108'}
DOMESTIC_BASE_NAME=${DOMESTIC_BASE_NAME:-'rainbond'}
DOMESTIC_NAMESPACE=${DOMESTIC_NAMESPACE:-'goodrain'}

function get_nfscli() {

    if [[ -f "./offline/nfs_all_arm.tar.gz" ]]; then
        echo "[INFO] nfs binaries already existed"
    else
        wget -c "$NFSCLI_URL" || {
            echo "[ERROR] Downloading nfs binaries failed"
            exit 1
        }
        mv nfs_all_arm.tar.gz ./offline/nfs_all.tar.gz
    fi

}

function get_kernel() {

    KERNEL_URL="https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/offline/os-kernel/kernel_upgrade.tgz"
    if [[ -f "./offline/kernel_upgrade.tgz" ]]; then
        echo "[INFO] Kernel upgrade package already existed"
    else
        wget -c "$KERNEL_URL" || {
            echo "[ERROR] Downloading kernel upgrade package failed"
            exit 1
        }
        mv kernel_upgrade.tgz ./offline/kernel_upgrade.tgz
    fi

}

function get_docker() {

    DOCKER_URL="https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/offline/docker/docker-arm-${DOCKER_VER}.tgz"
    if [[ -f "/opt/docker/down/docker-${DOCKER_VER}.tgz" ]]; then
        echo "[INFO] docker binaries already existed"
    else
        echo -e "[INFO] \033[33mdownloading docker binaries\033[0m $DOCKER_VER"
        wget -c "$DOCKER_URL" || {
            echo "[ERROR] downloading docker failed"
            exit 1
        }
        mv ./docker-arm-${DOCKER_VER}.tgz ./offline/docker-${DOCKER_VER}.tgz
    fi

}

function get_offline_script() {


    wget sh.rainbond.com/install_docker_offline.sh -O ./offline/install_docker_offline.sh || "echo "[ERROR] Failed to download offline script" && exit 1" && chmod +x ./offline/install_docker_offline.sh

    wget https://rainbond-script.oss-cn-hangzhou.aliyuncs.com/init_node_offline.sh -O ./offline/init_node_offline.sh || "echo "[ERROR] Failed to download offline script" && exit 1" && chmod +x ./offline/init_node_offline.sh

}

function get_command_line_tools() {

    TOOLS_URL="https://grstatic.oss-cn-shanghai.aliyuncs.com/binary/kubectl-arm"
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
rancher/coreos-etcd:v3.4.13-arm64
rancher/rke-tools:v0.1.68
rancher/cluster-proportional-autoscaler:1.8.1
rancher/coredns-coredns:1.7.0
rancher/k8s-dns-node-cache:1.15.13
rancher/hyperkube:v1.19.6-rancher1
rancher/coreos-flannel:v0.13.0-rancher1
rancher/flannel-cni:v0.3.0-rancher6
rancher/pause:3.2
rancher/metrics-server:v0.3.6
rancher/k8s-dns-kube-dns:1.15.10
rancher/k8s-dns-dnsmasq-nanny:1.15.10
rancher/k8s-dns-sidecar:1.15.10
EOF

    while read k8s_image_name; do
        k8s_offline_image=$(echo "${k8s_image_name}" | awk -F"/" '{print $NF}')
        docker pull "${k8s_image_name}" ||  exit 1

        if [ "${k8s_offline_image}" = "coreos-etcd:v3.4.13-arm64" ]; then
            docker tag "${k8s_image_name}" goodrain.me/coreos-etcd:v3.4.13-rke
            docker save goodrain.me/coreos-etcd:v3.4.13-rke -o ./offline/k8s_image/coreos-etcd:v3.4.13-rke.tgz
        elif [ "${k8s_offline_image}" = "k8s-dns-kube-dns:1.15.10" ] || [ "${k8s_offline_image}" = "k8s-dns-dnsmasq-nanny:1.15.10" ] || [ "${k8s_offline_image}" = "rancher/k8s-dns-sidecar:1.15.10" ]; then
            docker save rancher/"${k8s_offline_image}" -o ./offline/k8s_image/"${k8s_offline_image}".tgz
        elif [ "${k8s_offline_image}" = "hyperkube:v1.19.6-rancher1" ]; then
            docker tag "${k8s_image_name}" goodrain.me/hyperkube:v1.19.6-rke
            docker save goodrain.me/hyperkube:v1.19.6-rke -o ./offline/k8s_image/hyperkube:v1.19.6-rke.tgz
        elif [ "${k8s_offline_image}" = "coreos-flannel:v0.13.0-rancher1" ]; then
            docker tag "${k8s_image_name}" goodrain.me/coreos-flannel:v0.13.0-rke
            docker save goodrain.me/coreos-flannel:v0.13.0-rke -o ./offline/k8s_image/coreos-flannel:v0.13.0-rke.tgz
        elif [ "${k8s_offline_image}" = "flannel-cni:v0.3.0-rancher6" ]; then
            docker tag "${k8s_image_name}" goodrain.me/flannel-cni:v0.3.0-rke
            docker save goodrain.me/flannel-cni:v0.3.0-rke -o ./offline/k8s_image/flannel-cni:v0.3.0-rke.tgz
        else
            docker tag "${k8s_image_name}" goodrain.me/"${k8s_offline_image}"
            docker save goodrain.me/"${k8s_offline_image}" -o ./offline/k8s_image/"${k8s_offline_image}".tgz
        fi
        
    done <./offline/k8s_image/list.txt

}

function get_rbd_images() {

    cat >./offline/rbd_image/list.txt <<EOF
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rainbond:$RBD_VER-allinone
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-node:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-resource-proxy:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-eventlog:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-worker:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-gateway:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-chaos:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-api:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-webcli:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-mq:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-monitor:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-mesh-data-panel:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-init-probe:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rbd-grctl:$RBD_VER
${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/rainbond-operator:$RBD_VER
registry.cn-hangzhou.aliyuncs.com/goodrain/plugins-tcm:5.1.7
kubernetesui/dashboard:v2.0.1
rifelpet/nfs-provisioner:v2.2.2
mysql/mysql-server:8.0.19
kubernetesui/metrics-scraper:v1.0.4
quay.io/coreos/etcd:v3.3.18-arm64
prom/mysqld-exporter:latest
registry:2.6.2
EOF
    while read rbd_image_name; do
        rbd_offline_image=$(echo "${rbd_image_name}" | awk -F"/" '{print $NF}')

        docker pull "${rbd_image_name}" || exit 1
        docker tag "${rbd_image_name}" goodrain.me/"${rbd_offline_image}"
        docker save goodrain.me/"${rbd_offline_image}" -o ./offline/rbd_image/"${rbd_offline_image}".tgz
        
    done <./offline/rbd_image/list.txt

}

function main() {
    
    docker login -u "$DOMESTIC_DOCKER_USERNAME" -p "$DOMESTIC_DOCKER_PASSWORD" "${DOMESTIC_BASE_NAME}"

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
