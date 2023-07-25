# 单节点集群

### 系统要求
- `1C2G+`

### 依赖条件
- [离线包准备](offline.md)

### 部署步骤
1. 检查虚拟机默认网卡配置
   - 默认网卡为 `eth0`, 如果环境实际网卡不是 `eth0`，则需要手动指定网卡名称:
     ```bash
     编辑 /etc/kubez/globals.yml 文件, 取消 network_interface: "eth0" 的注解, 并修改为实际网卡名称
     ```

2. 确认集群环境连接地址

   a. 内网连接: 无需更改

   b. 公网连接:
   ```bash
   编辑 /etc/kubez/globals.yml 文件, 取消 #kube_vip_address: "" 的注解，并修改为实际公网地址 云平台环境需要放通公网ip到后面节点的6443端口
   ```

3. (可选) 修改默认的 `cri`
- 离线安装时，默认的 `cri` 为 `docker`, 如果期望修改为 `containerd`, 则
  - `Centos` 修改 `/usr/share/kubez-ansible/ansible/inventory/all-in-one`
  - `Ubuntu` 修改 `/usr/local/share/kubez-ansible/ansible/inventory/all-in-one`

- 移除 `docker-master` 和 `docker-node` 的主机信息, 并添加在 `containerd` 分组中, 调整后效果如下:
  ```shell
  [docker-master]

  [docker-node]

  [containerd-master]
  localhost       ansible_connection=local

  [containerd-node]
  localhost       ansible_connection=local
  ```

4. 修改 /etc/kubez/globals.yml 配置文件
    ``` bash
    修改 kube_release: 为指定 Kubernetes 版本
    kube_release: 1.23.17

    修改 image_repository: "" 为本地镜像仓库
    image_repository: "192.168.16.210:58001/pixiuio"

    修改 yum_baseurl: “” 为本地 yum 仓库地址
    yum_baseurl: "http://192.168.16.210:58000/repository/pixiuio-centos"

    ```

5. 执行如下命令，进行 `kubernetes` 的依赖安装
    ```bash
    kubez-ansible bootstrap-servers
    ```

6. 执行如下命令，进行 `kubernetes` 的集群安装
    ``` bash
    kubez-ansible deploy
    ```

7. 验证环境
   ```bash
   # kubectl get node
   NAME    STATUS   ROLES    AGE    VERSION
   pixiu   Ready    master   134d   v1.23.6
   ```

8. (可选)启用 kubectl 命令行补全
    ``` bash
    kubez-ansible post-deploy
    ```

