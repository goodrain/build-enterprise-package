#!/bin/bash

export NFSCLI_URL="https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/offline/nfs-client/nfs_all.tar.gz"
export DOCKER_VER=19.03.5
export RBD_VER=v5.3.1-release


function get_nfscli() {

    if [[ -f "./offline/nfs_all.tar.gz" ]]; then
        echo "[INFO] nfs binaries already existed"
    else
        wget -c "$NFSCLI_URL" || {
            echo "[ERROR] downloading docker failed"
            exit 1
        }
        mv nfs_all.tar.gz ./offline/nfs_all.tar.gz
    fi

}

function get_kernel(){

    wget  https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/offline/yum/kernel-ml-5.12.12-1.el7.elrepo.x86_64.rpm  && mv kernel-ml-5.12.12-1.el7.elrepo.x86_64.rpm  ./offline/kernel-ml-5.12.12-1.el7.elrepo.x86_64.rpm

}

function get_k8s_images() {

    cat > ./offline/k8s_image/list.txt <<EOF
registry.cn-hangzhou.aliyuncs.com/goodrain/coreos-etcd:v3.4.13-rke
registry.cn-hangzhou.aliyuncs.com/goodrain/rke-tools:v0.1.68
registry.cn-hangzhou.aliyuncs.com/goodrain/cluster-proportional-autoscaler:1.8.1
registry.cn-hangzhou.aliyuncs.com/goodrain/coredns-coredns:1.7.0
registry.cn-hangzhou.aliyuncs.com/goodrain/k8s-dns-node-cache:1.15.13
registry.cn-hangzhou.aliyuncs.com/goodrain/hyperkube:v1.19.6-rke
registry.cn-hangzhou.aliyuncs.com/goodrain/coreos-flannel:v0.13.0-rke
registry.cn-hangzhou.aliyuncs.com/goodrain/flannel-cni:v0.3.0-rke
registry.cn-hangzhou.aliyuncs.com/goodrain/pause:3.2
rancher/k8s-dns-kube-dns:1.15.10
rancher/k8s-dns-dnsmasq-nanny:1.15.10
rancher/k8s-dns-sidecar:1.15.10
EOF

    while read k8s_image_name;do
        k8s_image_tar=`echo ${k8s_image_name} | awk -F"/" '{print $NF}'|tr : -`
        k8s_offline_image=`echo ${k8s_image_name} | awk -F"/" '{print $NF}'`

        if  [[ -f "./offline/k8s_image/${k8s_image_tar}.tgz" ]];then
            echo "[INFO] ${k8s_image_tar} image already existed"
        else
            docker pull ${k8s_image_name} &&
            docker tag  ${k8s_image_name} goodrain.me/${k8s_offline_image}  &&
            docker save goodrain.me/${k8s_offline_image} -o ./offline/k8s_image/${k8s_offline_image}.tgz
        fi
    done < ./offline/k8s_image/list.txt

}

function get_rbd_images() {

    cat > ./offline/rbd_image/list.txt <<EOF
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
registry.cn-hangzhou.aliyuncs.com/goodrain/builder:v5.3.0
registry.cn-hangzhou.aliyuncs.com/goodrain/runner:v5.3.0
registry.cn-hangzhou.aliyuncs.com/goodrain/rainbond-operator:v2.0.1
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
    while read rbd_image_name;do
        rbd_image_tar=`echo ${rbd_image_name} | awk -F"/" '{print $NF}'|tr : -`
        rbd_offline_image=`echo ${rbd_image_name} | awk -F"/" '{print $NF}'`

        if  [[ -f "./offline/rbd_image/${rbd_image_tar}.tgz" ]];then
            echo "[INFO] ${rbd_image_tar} image already existed"
        else
            docker pull ${rbd_image_name}  &&
            docker tag  ${rbd_image_name} goodrain.me/${rbd_offline_image}  &&
            docker save goodrain.me/${rbd_offline_image}  -o ./offline/rbd_image/${rbd_offline_image}.tgz
        fi
    done < ./offline/rbd_image/list.txt

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

function get_offline_script(){

    wget sh.rainbond.com/install_docker_offline.sh && mv install_docker_offline.sh ./offline/install_docker_offline.sh && chmod +x ./offline/install_docker_offline.sh

    wget https://rainbond-script.oss-cn-hangzhou.aliyuncs.com/init_node_offline.sh && mv init_node_offline.sh ./offline/init_node_offline.sh && chmod +x ./offline/init_node_offline.sh

    wget https://grstatic.oss-cn-shanghai.aliyuncs.com/binary/kubectl -O ./offline/kubectl && chmod +x ./offline/kubectl

}


function main(){

    mkdir -p ./offline ./offline/k8s_image ./offline/rbd_image
    # get nfs client package
    get_nfscli
    # get centos kernel
    get_kernel
    # get kubernetes image
    get_k8s_images
    # get rainbond image
    get_rbd_images
    # get docker package
    get_docker
    # get offline install rainbond script
    get_offline_script

    tar zcvf rainbond-offline-$RBD_VER.tgz  offline/*

}

main
