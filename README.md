# build-offlice-package


## 功能列表

1.Rainbond企业版编译

[![ci-allinone-enterprise-build](https://github.com/goodrain/build-offlice-package/actions/workflows/ci-allinone-enterprise.yml/badge.svg)](https://github.com/goodrain/build-offlice-package/actions/workflows/ci-allinone-enterprise.yml)
[![ci-region-enterprise-build](https://github.com/goodrain/build-offlice-package/actions/workflows/ci-region-enterprise.yml/badge.svg)](https://github.com/goodrain/build-offlice-package/actions/workflows/ci-region-enterprise.yml)

2.构建Rainbond离线安装包

[![build-release-offlice-package](https://github.com/goodrain/build-offlice-package/actions/workflows/release-offline-package.yml/badge.svg)](https://github.com/goodrain/build-offlice-package/actions/workflows/release-offline-package.yml)
[![build-enterprise-offlice-package](https://github.com/goodrain/build-offlice-package/actions/workflows/enterprise-offline-package.yml/badge.svg)](https://github.com/goodrain/build-offlice-package/actions/workflows/enterprise-offline-package.yml)

## 目录

* [Rainbond企业版编译](#Rainbond企业版编译)
* [构建Rainbond离线安装包](#构建Rainbond离线安装包)
* [Rainbond企业版安装](#Rainbond企业版安装)

### Rainbond企业版编译


- 分别编译 `allinone` 及数据中心镜像。
- 通过修改 `workflows` 文件中 `env.VERSION` 环境变量值变更版本。
- 使用 GitHub Actions 进行编译,编译完成会自动推送镜像。
    

### 构建Rainbond离线安装包

- 包括开源版及企业版离线安装包打包。
- 通过修改 `workflows` 文件中 `env.RBD_VER` 环境变量值变更版本。
- 使用 [GitHub Actions](https://github.com/goodrain/build-offlice-package/actions/workflows/release-offline-package.yml) 进行打包,打包完成会自动推送至OSS。

    开源版oss包地址：oss://rainbond-pkg/offline/5.3/         
    企业版oss包地址：oss://rainbond-pkg/offline/5.3-enterprise/

### Rainbond企业版安装

[Rainbond 企业版离线部署文档](https://rainbond.coding.net/p/delivery/wiki/349)
