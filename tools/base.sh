#!/usr/bin/env bash
#
# Bootstrap script to install kubernetes env.
#
# This script is intended to be used for install kubernetes env.

# author: shujiangle

# 本机ip
LOCALIP="localhost"

# 镜像版本
IMAGETAG="1.23.17"

# 拉取的用户名和密码
USER="ptx9sk7vk7ow:003a1d6132741b195f332b815e8f98c39ecbcc1a"

# 拉取的URL
URL="https://pixiupkg-generic.pkg.coding.net"

# 当前路径, $pwd 可以更改路径
PKGPWD=$pwd

# 判断LOCALIP是否修改
printChangeIp() {
	if [ "$LOCALIP" = "localhost" ]; then
		echo "你的ip未修改,请修改成你部署机ip"
		exit 1
	fi
}

printHelp() {
	printf "[WARN] 请输入你要选择的操作.\n\n"
	echo "Available Commands:"
	printf "  %-25s\t %s\t \n" "download" "下载离线包"
	printf "  %-25s\t %s\t \n" "install" "安装前置服务"
	printf "  %-25s\t %s\t \n" "push" "推送k8s镜像和rpm包"
	printf "  %-25s\t %s\t \n" "kubezansible" "安装kubez-ansible"
}

printDownloadHelp() {
	printf "[WARN] 请输入你要下载的离线包.\n\n"
	echo "Available Commands:"
	printf "  %-25s\t %s\t \n" "all" "下载所有离线包"
	printf "  %-25s\t %s\t \n" "nexus" "下载nexus"
	printf "  %-25s\t %s\t \n" "rpm" "下载rpm离线包"
	printf "  %-25s\t %s\t \n" "image" "下载镜像包"
	printf "  %-25s\t %s\t \n" "kubez" "下载kubez-ansible 离线包"
}

Download() {
	case $1 in
	"all")
		downloadNexus
		downloadRpm
		downloadImage
		downloadKubez
		;;
	"nexus")
		downloadNexus
		;;
	"rpm")
		downloadRpm
		;;
	"image")
		downloadImage
		;;
	"kubez")
		downloadKubez
		;;
	*)
		printDownloadHelp
		;;
	esac
}

downloadNexus() {
	# 准备 nexus 离线包
	if [ ! -f "nexus.tar.gz" ]; then
		echo "正在下载nexus"
		curl -fL -u $USER $URL/pixiu/k8soffline/nexus.tar.gz?version=latest -o nexus.tar.gz
	else
		# nexus 的md5值
		nexus_old_md5="f7224a5b7e4cc049fe59cb9c3898da76"
		nexus_new_md5=$(md5sum nexus.tar.gz | awk '{print $1}')
		if [ "$nexus_new_md5" == "$nexus_old_md5" ]; then
			echo "nexus文件已经存在无需下载"
		else
			echo "nexus md5值不正确，开始重新下载"
			curl -fL -u $USER $URL/pixiu/k8soffline/nexus.tar.gz?version=latest -o nexus.tar.gz
		fi
	fi
}

downloadRpm() {
	# 准备 rpm 离线包
	if [ ! -f "k8s-v${IMAGETAG}-rpm.tar.gz" ]; then
		echo "正在下载k8s-v${IMAGETAG}-rpm.tar.gz"
		curl -fL -u $USER $URL/pixiu/k8soffline/k8s-v$IMAGETAG-rpm.tar.gz?version=latest -o k8s-v${IMAGETAG}-rpm.tar.gz
	else
		# nexus 的md5值
		rpm_old_md5="f95fdacb5d5d7261a3a25be69763122f"
		rpm_new_md5=$(md5sum k8s-v${IMAGETAG}-rpm.tar.gz | awk '{print $1}')
		if [ "$rpm_new_md5" == "$rpm_old_md5" ]; then
			echo "k8s-v${IMAGETAG}-rpm.tar.gz文件已经存在无需下载"
		else
			echo "k8s-v${IMAGETAG}-rpm.tar.gz md5值不正确，开始重新下载"
			curl -fL -u $USER $URL/pixiu/k8soffline/k8s-v$IMAGETAG-rpm.tar.gz?version=latest -o k8s-v${IMAGETAG}-rpm.tar.gz
		fi
	fi
}

downloadImage() {
	# 准备镜像离线包
	if [ ! -f "k8s-centos7-v${IMAGETAG}_images.tar.gz" ]; then
		echo "正在下载k8s-centos7-v${IMAGETAG}_images.tar.gz"
		curl -fL -u $USER $URL/pixiu/allimagedownload/allimagedownload.tar.gz?version=latest -o k8s-centos7-v${IMAGETAG}_images.tar.gz
	else
		# nexus 的md5值
		image_old_md5="f07343496ee591ca78ad25fb27af68d9"
		image_new_md5=$(md5sum k8s-centos7-v${IMAGETAG}_images.tar.gz | awk '{print $1}')
		if [ "$image_new_md5" == "$image_old_md5" ]; then
			echo "k8s-centos7-v${IMAGETAG}_images.tar.gz文件已经存在无需下载"
		else
			echo "k8s-centos7-v${IMAGETAG}_images.tar.gz md5值不正确，开始重新下载"
			curl -fL -u $USER $URL/pixiu/allimagedownload/allimagedownload.tar.gz?version=latest -o k8s-centos7-v${IMAGETAG}_images.tar.gz
		fi
	fi

}

downloadKubez() {
	# 准备镜像离线包
	if [ ! -f "kubez-ansible-offline-master.zip" ]; then
		echo "正在下载kubez-ansible-offline-master.zip"
		curl https://codeload.github.com/gopixiu-io/kubez-ansible-offline/zip/refs/heads/master -o kubez-ansible-offline-master.zip
	else
		# nexus 的md5值
		kubez_old_md5="f8f17f550211fdcf65f8c73e4add170a"
		kubez_new_md5=$(md5sum kubez-ansible-offline-master.zip | awk '{print $1}')
		if [ "$kubez_new_md5" == "$kubez_old_md5" ]; then
			echo "kubez-ansible-offline-master.zip文件已经存在无需下载"
		else
			echo "kubez-ansible-offline-master.zip md5值不正确，开始重新下载"
			curl https://codeload.github.com/gopixiu-io/kubez-ansible-offline/zip/refs/heads/master -o kubez-ansible-offline-master.zip
		fi
	fi
	# 准备 kubez-ansible 离线包

}

check_nexus_status() {
	curl localhost:58000 >/dev/null 2>&1
	if [ $? == 0 ]; then
		echo -e "服务已经启动成功"
		sleep 1
		exit 0
	fi
}
# 安装nexus
installNexus() {
	check_nexus_status
	if [ ! -f "nexus.tar.gz" ]; then
		echo "nexus安装包不存在，请下载"
		exit 1
	fi
	cd $PKGPWD
	tar zxvf nexus.tar.gz
	cd nexus_local/

	# 启动服务
	sh nexus.sh start
}

printPushHelp() {
	printf "[WARN] 请输入你要上传的物料.\n\n"
	echo "Available Commands:"
	printf "  %-25s\t %s\t \n" "all" "上传所有k8s镜像和所有rpm包"
	printf "  %-25s\t %s\t \n" "image" "上传所有k8s镜像"
	printf "  %-25s\t %s\t \n" "rpm" "上传所有rpm包"
}

pushImage() {
	printChangeIp
	cd $PKGPWD
	tar zxvf k8s-centos7-v${IMAGETAG}_images.tar.gz
	cd allimagedownload
	sh load_image.sh $LOCALIP
}

pushRpm() {
	printChangeIp
	cd $PKGPWD
	tar zxvf k8s-v${IMAGETAG}-rpm.tar.gz
	cd localrepo
	sh push_rpm.sh $LOCALIP
}

Push() {
	case $1 in
	"all")
		pushImage
		sleep 10
		pushRpm
		;;
	"image")
		pushImage
		;;
	"rpm")
		pushRpm
		;;
	*)
		printPushHelp
		;;
	esac
}

printKubezHelp() {
	printf "[WARN] 设置nexus repo和安装kubez-ansible.\n\n"
	echo "Available Commands:"
	printf "  %-25s\t %s\t \n" "all" "设置nexus repo和安装kubez-ansible"
	printf "  %-25s\t %s\t \n" "repo" "设置nexus repo"
	printf "  %-25s\t %s\t \n" "install" "安装kubez-ansible"
}

kubezansible() {
	case $1 in
	"all")
		kubezansibleRepo
		kubezansibleInstall
		;;
	"repo")
		kubezansibleRepo
		;;
	"install")
		kubezansibleInstall
		;;
	*)
		printKubezHelp
		;;
	esac
}

kubezansibleRepo() {
	printChangeIp

  [ -d "/etc/yum.repos.d.bak" ] && echo "/etc/yum.repos.d.bak  备份目录存在，无需备份" && exit 0
  mv /etc/yum.repos.d /etc/yum.repos.d.bak
	mkdir -p /etc/yum.repos.d

	[ -f "/etc/yum.repos.d/offline.repo" ] && echo "/etc/yum.repos.d/offline.repo 文件存在，无需再创建" && exit 0
	cat >/etc/yum.repos.d/offline.repo <<EOF
[basenexus]
name=Pixiuio Repository
baseurl=http://${LOCALIP}:58000/repository/pixiuio-centos/
enabled=1
gpgcheck=0
EOF

	yum clean all && yum makecache
}

kubezansibleInstall() {
  # 判断ip是否修改
	printChangeIp

  if command -v "kubez-ansible" >/dev/null; then
    echo "kubez-ansible 命令已经安装"
    exit 0
  else
    cd $PKGPWD
    # 安装依赖包
		yum makecache
    yum -y install ansible unzip python2-pip
    # 解压 kubez-ansible 包
		if [ ! -d "kubez-ansible-offline-master" ]; then
    unzip kubez-ansible-offline-master.zip
    cd kubez-ansible-offline-master
    # 安装依赖
    pip install pip/pbr-5.11.1-py2.py3-none-any.whl

    cp tools/git /usr/local/bin && git init
    # 执行安装
    python setup.py install

    cp -r etc/kubez/ /etc/
    cp ansible/inventory/multinode ~
    cd ~
	fi
fi
}

case $1 in
"download")
	Download $2
	;;
"install")
	installNexus
	;;
"push")
	Push $2
	;;
"kubezansible")
	kubezansible $2
	;;
*)
	printHelp
	;;
esac
