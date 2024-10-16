# 离线环境初始化

## 离线包获取
### 获取 `base.sh` 初始化脚本
```shell
###（可选）自动获取，网络通时，通过 curl 命令直接获取脚本到本地
curl https://raw.githubusercontent.com/pixiu-io/kubez-ansible-offline/master/tools/base.sh -o base.sh

### 手动获取
### 自动获取失败时使用，一般因为网络不通或者未安装 curl 命令
### 拷贝项目的 tools/base.sh, 并保存为 base.sh
```

### 下载离线包
- 查看首页的支持版本列表
- 以 1.26.15 版本为例

| 支持版本 | 操作系统 | 资源链接 |
| :---        |    :----:     |          ---: |
| 1.26.15     | Centos | [1.26.15](resource.md)   |
| 1.23.17     | Centos  | [1.23.17](resource.md)   |

### 拷贝所有包至内网部署机
```shell
# 以 1.26.15 版本为例，正常物料包列表如下
[root@pixiu ~]# ls
base.sh  k8s-centos7-v1.26.15_images.tar.gz  k8s-centos7-v1.26.15-rpm.tar.gz  kubez-ansible-offline-master.zip  nexus.tar.gz
```

## 部署机操作

### 部署私有仓库
- 修改 `base.sh` 脚本内容
  ```shell
  vim base.sh
  # 修改为本机 IP 地址
  LOCALIP="localhost"

  # 镜像版本，即k8s的版本号
  IMAGETAG="1.26.15"
  ```

## 一键安装基本依赖
  ```shell
  sh base.sh all
  ```

- 安装完成结果显示
```shell
2024-06-07 16:56:36                      [ INFO ]  nexus服务已经安装
2024-06-07 16:56:36                      [ INFO ]   kubez-ansible 命令安装完成
```
