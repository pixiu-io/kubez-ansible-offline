# 下载 kubernetes 离线部署组件
## 一、部署私有仓库

### 部署步骤
1. 下载物料包

   - 下载 `nexus`
     ```bash
     curl -fL -u ptx9sk7vk7ow:003a1d6132741b195f332b815e8f98c39ecbcc1a "https://pixiupkg-generic.pkg.coding.net/pixiu/k8soffline/nexus.tar.gz?version=latest" -o nexus.tar.gz
     ```

   - 下载 `rpm` 包
     ```bash
     curl -fL -u ptx9sk7vk7ow:003a1d6132741b195f332b815e8f98c39ecbcc1a "https://pixiupkg-generic.pkg.coding.net/pixiu/k8soffline/k8s-v1.23.17-rpm.tar.gz?version=latest" -o k8s-v1.23.17-rpm.tar.gz
     ```

   - 下载镜像包
     ```bash
     curl -fL  https://pixiupkg-generic.pkg.coding.net/pixiu/allimagedownload/allimagedownload.tar.gz?version=latest -o k8s-centos7-v1.23.17_images.tar.gz
     ```
2. 安装 `nexus`

   - 解压安装 `nexus`
     ```bash
     解压 "nexus"
     tar -zxvf nexus.tar.gz
     启动 "nexus"
     cd  nexus_local/
     sh nexus.sh start

     # 访问nexus
     http://ip:58000   用户名： admin  密码： admin123

     # nexus搭建镜像仓库地址
     http://ip:58001   用户名： admin  密码： admin123
     ```
3. 上传镜像和软件包

   - 上传镜像包
     ```bash
     tar zxvf k8s-centos7-v1.23.17_images.tar.gz
     cd allimagedownload

     # 导入的时候，传入你部署机的 IP
     sh load_image.sh  192.168.17.47
     ```
   - 上传 `rpm` 包
     ```bash
     tar zxvf k8s-v1.23.17-rpm.tar.gz
     cd localrepo

     # 导入的时候，传入你部署机的 IP
     sh push_rpm.sh 192.168.17.47
     ```
4. 制作 `yum` 仓库
   - 添加yum仓库
     ```bash
     vi /etc/yum.repos.d/pixiu.rep
     # 仓库内容 IP 更换为系统当前使用 IP
     [basenexus]
     name=Nexus Yum Repository
     baseurl=http://192.168.17.47:58000/repository/pixiuio-centos/
     enabled=1
     gpgcheck=0

     # 清除之前 yum 仓库缓存
     yum clean all

     # 重新构建 yum 仓库缓存
     yum makecache
     ```
## 二、安装 kubez-ansible

### 部署步骤
1. 下载代码

   - 下载 `kubez-ansible`
     ```bash
     # 下载地址，建议本地下载后上传
     https://github.com/gopixiu-io/kubez-ansible-offline/archive/refs/heads/master.zip
     ```
     ```bash
     解压 "kubez-ansible"
     yum -y install unzip
     unzip  kubez-ansible-offline-master.zip
     ```
   - 安装 `kubez-ansible`
     ```bash
     # 安装 "pip"
     yum -y install python2-pip

     # 安装依赖包（后续此包也会内置进去）
     pip install pbr-5.11.1-py2.py3-none-any.whl

     # 将 git 拷贝到 bin 目录下, init 初始化
     cd kubez-ansible-offline-master
     cp tools/git /usr/bin/
     git init

     # 执行脚本安装kubez-ansible
     python setup.py  install

     # 测试命令回显
     kubez-ansible

     Usage: /usr/bin/kubez-ansible COMMAND [options]

     Options:
     --inventory, -i <inventory_path>   Specify path to ansible inventory file
     --playbook, -p <playbook_path>     Specify path to ansible playbook file
     ```

