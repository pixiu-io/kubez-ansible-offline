# 离线包准备

## 一、离线包获取

### 1. `base.sh` 脚本下载
```shell
curl https://raw.githubusercontent.com/gopixiu-io/kubez-ansible/master/tools/base.sh | bash
```

### 2. 下载所有离线包
```shell
sh base.sh download all
```

- 单独下载包 ，可以用下面命令(网络不佳可单独下载)

```shell
# 下载nexus
sh base.sh download nexus

# 下载rpm离线包
sh base.sh download rpm

# 下载镜像包
sh base.sh download image

# 下载kubez-ansible 离线包
sh base.sh download kubez
```

### 3. 拷贝下面所有包至内网部署机
```shell
base.sh
k8s-centos7-v1.23.17_images.tar.gz
k8s-v1.23.17-rpm.tar.gz
kubez-ansible-offline-master.zip
nexus.tar.gz
```

## 二、 部署机操作

### 1. 部署私有仓库

- 修改 base.sh 脚本内容

```shell
vim bash.sh
# 本机ip
LOCALIP="localhost"     #修改为本机 IP 地址
```
- 安装 nexus 
```shell
sh base.sh install
```
- 安装完成结果显示
```shell
当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09 服务启动成功！
```

- 访问测试

```shell
# 访问nexus
http://ip:58000   用户名: admin  密码: admin123

# nexus搭建镜像仓库地址
http://ip:58001   用户名: admin  密码: admin123
```

### 2. 上传镜像和软件包

```shell
sh base.sh push all     # 上传全部 rpm 包和所需镜像到 nexus 仓库
sh bash.sh push rpm     # 上传 rpm 包
sh bash.sh push image   # 上传 images 
```

### 3. 设置 `nexus repo` 和安装 `kubez-ansible`

```shell
sh base.sh kubezansible all     # 设置 nexus repo 以及安装 kubez-ansible
sh base.sh kubezansible repo    # 设置 nexus repo
sh base.sh kubezansible install # 安装 kubez-ansible
```

- 命令执行成功回显
```shell
copying ansible/roles/nfs/templates/exports.j2 -> /usr/share/kubez-ansible/ansible/roles/nfs/templates
running install_egg_info
Copying kubez_ansible.egg-info to /usr/lib/python2.7/site-packages/kubez_ansible-0.0.0-py2.7.egg-info
running install_scripts
copying build/scripts-2.7/kubez-ansible -> /usr/bin
changing mode of /usr/bin/kubez-ansible to 755
```
