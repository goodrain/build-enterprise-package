# build-offlice-package
构建Rainbond离线安装包

### 打包方式

- 通过修改脚本中 `RBD_VER=enterprise-2106` 环境变量值变更版本
- 使用 [GitHub Actions](https://github.com/goodrain/build-offlice-package/actions/workflows/release-offline-package.yml) 进行打包,打包完成会自动推送至OSS。


开源版oss包地址：oss://rainbond-pkg/offline/5.3/
企业版oss包地址：oss://rainbond-pkg/offline/5.3-enterprise/
