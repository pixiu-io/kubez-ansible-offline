#!/usr/bin/env bash
#
# Bootstrap script to install kubernetes env.
#
# This script is intended to be used for install kubernetes env.
# version: 1.0




# 安装nexus定义的ip
LOCALIP="localhost"

# 镜像版本
IMAGETAG="1.26.15"

# 当前路径, $(pwd) 可以更改路径
PKGPWD=$(pwd)


# 判断LOCALIP是否修改
function print_change_ip() {
    if [ "$LOCALIP" = "localhost" ]; then
		log error "base.sh 24行:     你的ip未修改,请修改12行， LOCALIP的值"
		exit 1
	fi
}


# 打印日志 31m 红色，32m 绿色，34蓝色
function log() {
    case $1 in
        "info")
            echo -e `date '+%Y-%m-%d %H:%M:%S'`"\t\t\t\e[32m [ INFO ]  $2\e[0m"
            ;;
        "error")
            echo -e `date '+%Y-%m-%d %H:%M:%S'`"\t\t\t\e[31m [ error ]  $2\e[0m"
            ;;
        *)
            echo -e `date '+%Y-%m-%d %H:%M:%S'`"\t\t\t\e[34m [ INFO ]   $2\e[0m"
            ;;
    esac
}


# 检查nexus状态
#function check_nexus_status() {
#    curl localhost:58000>/dev/null  2>&1
#    if [ $? -eq 0 ]; then
#        log info "nexus服务已经安装"
#        exit
#    fi
#
#}


function check_memory() {
    mem_total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_total_gb=$(echo "scale=2; $mem_total_kb / 1024 / 1024" | bc)
    required_mem_gb=4.0

    if (( $(echo "$mem_total_gb < $required_mem_gb" | bc -l) )); then
        echo -e "\e[31m 内存不足: 当前系统内存为 ${mem_total_gb}GB，需要至少 ${required_mem_gb}GB 内存。\e[0m"
        exit 1
    else
        echo -e "\e[32m 内存检查通过: 当前系统内存为 ${mem_total_gb}GB。\e[0m"
    fi
}



# 安装nexus
function install_nexus() {
	check_memory
	curl localhost:58000>/dev/null  2>&1
    if [ $? -eq 0 ]; then
        log info "nexus服务已经安装"
        return 0
    fi
    if [ ! -d "/data/nexus_local" ]; then
        log info "准备开始安装nexus---------"
        [ ! -f "./nexus.tar.gz" ] &&  log error  "base.sh 78行:     nexus.tar.gz文件不存在,请下载" && exit 1
        mkdir /data
        tar -zxvf nexus.tar.gz -C /data
    fi

	# 启动服务
	cd  /data/nexus_local && bash nexus.sh start

    # 判断/etc/rc.d/rc.local是否存在nexus
    line=`cat /etc/rc.d/rc.local|grep "bash nexus.sh start"|wc -l`
    if [ "$line" -eq 0 ]; then
        # 写入开机自启动
       echo 'cd /data/nexus_local &&  bash nexus.sh start' >> /etc/rc.d/rc.local
    fi

}

function push_nexus() {
	case $1 in
	"all")
	    push_nexus_image
		sleep 10
		push_nexus_rpm
		;;
	"image")
		push_nexus_image
		;;
	"rpm")
		push_nexus_rpm
		;;
	*)
		push_nexus_help
		;;
	esac
}

function push_nexus_help() {
	printf "[WARN] 请输入你要上传的物料.\n\n"
	echo "Available Commands:"
	printf "  %-25s\t %s\t \n" "all" "上传所有k8s镜像和所有rpm包"
	printf "  %-25s\t %s\t \n" "image" "上传所有k8s镜像"
	printf "  %-25s\t %s\t \n" "rpm" "上传所有rpm包"
}

function push_nexus_image() {
    cd $PKGPWD
    print_change_ip
    install_nexus
    cd $PKGPWD
    if [ ! -d "allimagedownload" ]; then
        [ ! -f "./k8s-centos7-v${IMAGETAG}_images.tar.gz" ] && log error  "base.sh 128行： k8s-centos7-v${IMAGETAG}_images.tar.gz文件不存在,请检查相关文件是否存在" && exit 1
        log info "开始解压k8s-centos7-v${IMAGETAG}_images.tar.gz"
        tar -zxvf k8s-centos7-v${IMAGETAG}_images.tar.gz
    fi


	cd allimagedownload
	sh load_image.sh $LOCALIP
}

function push_nexus_rpm() {
    cd $PKGPWD
	print_change_ip
	install_nexus
	cd $PKGPWD
	if [ ! -d "localrepo" ]; then
    [ ! -f "./k8s-centos7-v${IMAGETAG}-rpm.tar.gz" ] &&  log error  "base.sh 144行:     k8s-centos7-v${IMAGETAG}-rpm.tar.gz文件不存在,请检查相关文件是否存在" && exit 1
    log info "开始解压k8s-centos7-v${IMAGETAG}-rpm.tar.gz"
    tar -zxvf k8s-centos7-v${IMAGETAG}-rpm.tar.gz
    fi
	cd $PKGPWD
	cd localrepo
	log info
	sh push_rpm.sh $LOCALIP
}


function print_kubez_ansible() {
	printf "[WARN] 设置nexus repo和安装kubez-ansible.\n\n"
	echo "Available Commands:"
	printf "     %-25s\t %s\t \n" "all" "设置nexus repo和安装kubez-ansible"
	printf "     %-25s\t %s\t \n" "repo" "设置nexus repo"
	printf "     %-25s\t %s\t \n" "install" "安装kubez-ansible"
}

function kubez_ansible() {
	case $1 in
	"all")
		kubez_ansible_repo
		kubez_ansible_install

		;;
	"repo")
		kubez_ansible_repo
		;;
	"install")
		kubez_ansible_install
		;;
	*)
		print_kubez_ansible
		;;
	esac
}

function kubez_ansible_repo() {
    # 判断ip是否修改
	print_change_ip



    # 判断nexus repo是否存在
	[ -f "/etc/yum.repos.d/offline.repo" ] && log info "/etc/yum.repos.d/offline.repo 文件存在，无需再创建" && return 0

    # 判断nexus服务是否启动
    install_nexus

    # 判断 /etc/yum.repos.d.bak 是否存在
	[ -d "/etc/yum.repos.d.bak" ] && log info "/etc/yum.repos.d.bak  备份目录存在，无需备份" && return 0
	log info
	mv /etc/yum.repos.d /etc/yum.repos.d.bak
	mkdir -p /etc/yum.repos.d


	cat >/etc/yum.repos.d/offline.repo <<EOF
[basenexus]
name=Pixiuio Repository
baseurl=http://${LOCALIP}:58000/repository/pixiuio-centos/
enabled=1
gpgcheck=0
EOF

	log info "\n" && yum clean all && rm -rf /var/cache/yum/* && yum makecache && echo -e "\n" && log info "repo 仓库修改完成"
}

function kubez_ansible_install() {
	# 判断ip是否修改
	print_change_ip

    # 判断nexus服务是否启动
    install_nexus


    if command -v "kubez-ansible" >/dev/null; then
		log true "kubez-ansible 命令安装完成"
		exit 1
	else
		cd $PKGPWD
		# 安装依赖包
		log info
		if [ ! -d "kubez-ansible-offline-master" ]; then
		    [ ! -f "./kubez-ansible-offline-master.zip" ] &&  log error  "base.sh 228:     kubez-ansible-offline-master.zip文件不存在,请下载" && exit 1

		fi
        unzip kubez-ansible-offline-master.zip
		yum makecache
		yum -y install ansible unzip python2-pip
		# 解压 kubez-ansible 包

        log info
        cd kubez-ansible-offline-master
        # 安装依赖
        pip install pip/pbr-5.11.1-py2.py3-none-any.whl

        cp tools/git /usr/local/bin && chmod 755 /usr/local/bin/git && git init
        # 执行安装
        log info
        python setup.py install

        cp -r etc/kubez/ /etc/
        cp ansible/inventory/multinode ~
        cd ~

        log info
        if command -v "kubez-ansible" >/dev/null; then

        log true "kubez-ansible 命令安装完成"
        kubez-ansible -h
	    fi
	fi


}






# 初始化的帮助服务
function printhelp() {
    printf "[WARN] 请输入你要选择的操作.\n\n"
    echo "Available Commands:"

    # 定义命令和描述的数组
    commands=("install" "push" "kubezansible")
    descriptions=("安装所有" "安装前置服务" "推送k8s镜像和rpm包" "安装kubez-ansible")

    # 遍历数组并打印每个命令和描述
    for i in "${!commands[@]}"; {
        printf "     %-25s\t %s\t \n" "${commands[$i]}" "${descriptions[$i]}"
    }
}


function all_install() {
    install_nexus
    push_nexus all
    kubez_ansible all
}


function input() {
   case $1 in
    "all")
        all_install
        ;;
    "install")
        install_nexus
        ;;
    "push")
        push_nexus $2
        ;;
    "kubezansible")
        kubez_ansible $2
        ;;
    *)
        printhelp
        ;;
    esac

}

input  $1  $2
