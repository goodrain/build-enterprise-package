# build-offlice-package

[![ci-allinone-enterprise-build](https://github.com/goodrain/build-offlice-package/actions/workflows/ci-allinone-enterprise.yml/badge.svg)](https://github.com/goodrain/build-offlice-package/actions/workflows/ci-allinone-enterprise.yml)
[![ci-region-enterprise-build](https://github.com/goodrain/build-offlice-package/actions/workflows/ci-region-enterprise.yml/badge.svg)](https://github.com/goodrain/build-offlice-package/actions/workflows/ci-region-enterprise.yml)

[![build-release-offlice-package](https://github.com/goodrain/build-offlice-package/actions/workflows/release-offline-package.yml/badge.svg)](https://github.com/goodrain/build-offlice-package/actions/workflows/release-offline-package.yml)
[![build-enterprise-offlice-package](https://github.com/goodrain/build-offlice-package/actions/workflows/enterprise-offline-package.yml/badge.svg)](https://github.com/goodrain/build-offlice-package/actions/workflows/enterprise-offline-package.yml)

## 功能列表

1. Rainbond企业版编译
2. 构建Rainbond离线安装包

## 目录

* [Rainbond企业版编译](#Rainbond企业版编译)
* [构建Rainbond离线安装包](#构建Rainbond离线安装包)
* [Rainbond企业版安装](#Rainbond企业版安装)

### 一、Rainbond企业版编译


- 分别编译 `allinone` 及数据中心镜像。
- 通过修改 `workflows` 文件中 `env.VERSION` 环境变量值变更版本。
- 使用 GitHub Actions 进行编译,编译完成会自动推送镜像。
    

### 二、构建Rainbond离线安装包

- 包括开源版及企业版离线安装包打包。
- 通过修改 `workflows` 文件中 `env.RBD_VER` 环境变量值变更版本。
- 使用 [GitHub Actions](https://github.com/goodrain/build-offlice-package/actions/workflows/release-offline-package.yml) 进行打包,打包完成会自动推送至OSS。

    开源版oss包地址：oss://rainbond-pkg/offline/5.3/         
    企业版oss包地址：oss://rainbond-pkg/offline/5.3-enterprise/

### 三、Rainbond企业版安装

> Rainbond v5.3企业版离线部署文档

**前提条件**

- 如果开启了防⽕墙，确保开通了 80, 443, 6060,6443, 7070, 8443 端⼝；
- 设置服务器时区为 `Asia/Shanghai` ，并同步时间；
- 硬件环境满⾜环境需求单中的配置；
- CentOS 7 操作系统请 [升级内核到最新稳定版](https://t.goodrain.com/t/topic/1305)。
```bash
wget https://goodrain-delivery.oss-cn-hangzhou.aliyuncs.com/zhangz/kernel_upgrade.tgz && tar xvf kernel_upgrade.tgz  && cd kernel_upgrade && sh kernel_upgrade.sh
```
- 将生成的控制台license文件放到~/license目录（license签发参考文档https://rainbond.coding.net/p/delivery/wiki/377）

**安装步骤**

#### 下载并解压离线安装包

```bash
wget https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/offline/5.3-enterprise/rainbond-offline-enterprise-2107.tgz && tar xvf rainbond-offline-enterprise-2107.tgz
```

#### 离线安装docker

```bash
cd offline/ && ./install_docker_offline.sh
```

#### 启动控制台

```bash
docker run --name=rainbond-allinone --restart=always \
-d -p 7070:7070   \
-v ~/.ssh:/root/.ssh \
-v ~/rainbonddata:/app/data   \
 -v ~/license:/opt/license \
 -e DISABLE_DEFAULT_APP_MARKET=true \
 -e IS_ENTERPRISE_EDITION=true \
 -e INSTALL_IMAGE_REPO=goodrain.me \
-e RAINBOND_VERSION=enterprise-2107 \
-e LICENSE_PATH=/opt/license/**.yb \
-e LICENSE_KEY=**  \
goodrain.me/rainbond:enterprise-2107-allinone
```


#### 初始化

访问主机`IP:7070`端口，注册企业后选择从主机开始安装，执行初始化操作时选择离线脚本

```bash
export SSH_RSA="****"&& ./init_node_offline.sh
```

#### 集群端 license 挂载

- 使用sqlite数据库时需根据如下操作，将 console 库的 tenant_enterprise 和 region_info 表复制到 cloudadaptor 数据库中

```
$ sqlite3 ~/rainbonddata/db.sqlite3

.output tenant_enterprise.sql
.dump  tenant_enterprise

.output region_info.sql
.dump region_info

.exit

$ sqlite3 ~/rainbonddata/cloudadaptor/db.sqlite3

.read ./tenant_enterprise.sql
.read ./region_info.sql

.exit
```

- rbd-api 挂载license

```
kubectl create secret generic rbd-api-license -n rbd-system --from-file=license-file=./XXXXX.yb

kubectl edit -n rbd-system rbdcomponent rbd-api

  env:
  - name: LICENSE_PATH
    value: /opt/license/license-file
  - name: LICENSE_KEY
    value: "XXXX"

  volumeMounts:
  - mountPath: /opt/license
    name: rbd-api-license
    readOnly: true
  volumes:
  - name: rbd-api-license
    secret:
      defaultMode: 420
      secretName: rbd-api-license
```

#### 命令行工具安装

- kubectl

```bash
cd offline/ 
mv kubectl /usr/local/bin/
mkdir ~/.kube/
vi ~/.kube/config
```


- grctl

```bash
docker run -it --rm -v /:/rootfs  goodrain.me/rbd-grctl:enterprise-2107 copy
mv /usr/local/bin/rainbond-grctl /usr/local/bin/grctl 
grctl install 
```


