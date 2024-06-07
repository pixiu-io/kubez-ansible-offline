# 离线环境初始化

## 离线包获取

### 获取 `base.sh` 脚本
```shell
curl https://raw.githubusercontent.com/pixiu-io/kubez-ansible-offline/master/tools/base.sh -o base.sh
```

### 下载离线包
查看首页下载需要的版本

### 拷贝所有包至内网部署机
  ```shell
  [root@pixiu ~]# ls
  base.sh  k8s-centos7-v1.26.15_images.tar.gz  k8s-centos7-v1.26.15-rpm.tar.gz  kubez-ansible-offline-master.zip  nexus.tar.gz
  ```


## 部署机操作

### 部署私有仓库
- 修改 `base.sh` 脚本内容
  ```shell
  vim base.sh
  # 本机ip
  LOCALIP="localhost"     #修改为本机 IP 地址
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




