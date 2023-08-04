# 离线包准备

## 一、离线包获取

### 1. base.sh 脚本下载
```shell
curl -fL -u ptzqb68a4hxw:54b3c1629e82bd0c324e91e7c659492338a2370f "https://pixiuoffline-generic.pkg.coding.net/pixiuoffline/k8soffline/base.sh?version=latest" -o base.sh
```

### 2. 下载所有离线包
```shell
sh base.sh download all
```

- 单独下载包 ，可以用下面命令

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

部署机IP为  192.168.17.38

### 1. 安装前置服务nexus

```shell
sh base.sh install
```
安装完成结果

> 当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09   nexus服务正在启动.............
当前时间: 16:53:09 服务启动成功！

访问

```shell
# 访问nexus
http://ip:58000   用户名: admin  密码: admin123

# nexus搭建镜像仓库地址
http://ip:58001   用户名: admin  密码: admin123
```

### 2. 上传镜像和软件包

```shell
# 1. 修改下面LOCALIP的值
LOCALIP="xxx.xxx.xxx.xxx"
sed -i "s/LOCALIP=\"localhost\"/LOCALIP=\"${LOCALIP}\"/g" base.sh

# 2. 上传镜像和软件包
sh base.sh push all

单独上传镜像可以用  sh base.sh push image
单独上传rpm可以用  sh base.sh push rpm
```

### 3. 设置nexus repo和安装kubez-ansible

```shell
sh base.sh kubezansible all

单独设置nexus repo 可以用  sh base.sh kubezansible repo
单独安装kubez-ansible可以用 sh base.sh kubezansible install
```

效果:

> copying ansible/roles/nfs/templates/exports.j2 -> /usr/share/kubez-ansible/ansible/roles/nfs/templates
running install_egg_info
Copying kubez_ansible.egg-info to /usr/lib/python2.7/site-packages/kubez_ansible-0.0.0-py2.7.egg-info
running install_scripts
copying build/scripts-2.7/kubez-ansible -> /usr/bin
changing mode of /usr/bin/kubez-ansible to 755

