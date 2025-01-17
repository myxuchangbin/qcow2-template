#!/bin/bash

# 该数组未使用，仅记录官方下载地址，请修改下面一个数组
declare -A os_images_bak=(
    ["ubuntu1804.qcow2"]="https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img"
    ["ubuntu2004.img"]="https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
    ["ubuntu2204.img"]="https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
    ["ubuntu2404.img"]="https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
    ["debian11.qcow2"]="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
    ["debian12.qcow2"]="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
    ["centos7.qcow2"]="https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
    ["centos8-stream.qcow2"]="https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
    ["centos9-stream.qcow2"]="https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
    ["centos10-stream.qcow2"]="https://cloud.centos.org/centos/10-stream/x86_64/images/CentOS-Stream-GenericCloud-10-latest.x86_64.qcow2"
    ["almalinux8.qcow2"]="https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
    ["almalinux9.qcow2"]="https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
    ["rockylinux8.qcow2"]="http://download.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"
    ["rockylinux9.qcow2"]="http://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
    ["alpinelinux_edge.qcow2"]="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/cloud/nocloud_alpine-3.18.6-x86_64-bios-cloudinit-r0.qcow2"
    ["alpinelinux_stable.qcow2"]="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/cloud/nocloud_alpine-3.19.1-x86_64-bios-cloudinit-r0.qcow2"
)

# 可以根据格式按需修改，目前镜像文件链接来自主机商idc.wiki
declare -A os_images=(
    ["ubuntu1804.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/ubuntu18.qcow2"
    ["ubuntu2004.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/ubuntu20.qcow2"
    ["ubuntu2204.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/ubuntu22.qcow2"
    ["ubuntu2404.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/ubuntu24.qcow2"
    ["debian11.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/debian11.qcow2"
    ["debian12.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/debian12.qcow2"
    ["centos7.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/centos7.qcow2"
    ["centos8-stream.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/centos8-stream.qcow2"
    ["centos9-stream.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/centos9-stream.qcow2"
    ["centos10-stream.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/centos10-stream.qcow2"
    ["almalinux8.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/almalinux8.qcow2"
    ["almalinux9.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/almalinux9.qcow2"
    ["rockylinux8.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/rockylinux8.qcow2"
    ["rockylinux9.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/rockylinux9.qcow2"
    ["alpinelinux_edge.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/alpinelinux_edge.qcow2"
    ["alpinelinux_stable.qcow2"]="https://down.idc.wiki/Image/realServer-Template/current/qcow2/alpinelinux_stable.qcow2"
)

download_image() {
    local file_name=$1
    local image_url=$2
    local image_file="${download_dir}/${file_name}"
    echo "下载镜像: $os_name"
    wget --no-check-certificate -nv "$image_url" -O "$image_file"
}

custom_image() {
    if ! command -v virt-customize &> /dev/null
    then
        echo "virt-customize not found, installing libguestfs-tools"
        apt-get update
        apt-get install -y libguestfs-tools rng-tools
    fi
    qcow2_file=$1
    local download_image_file="${download_dir}/${qcow2_file}"
    local work_image_file="${work_dir}/${qcow2_file}"
    echo "复制文件..."
    cp -a ${download_image_file} ${work_image_file}
    echo "修改镜像：$qcow2_file..."
    # 启用root登录
    virt-edit -a $work_image_file /etc/cloud/cloud.cfg -e 's/disable_root:.*[Tt]rue/disable_root: False/'
    virt-edit -a $work_image_file /etc/cloud/cloud.cfg -e 's/disable_root:.*1/disable_root: 0/'
    virt-edit -a $work_image_file /etc/ssh/sshd_config -e 's/PermitRootLogin.*[Nn]o/PermitRootLogin yes/'
    virt-edit -a $work_image_file /etc/ssh/sshd_config -e 's/#PermitRootLogin.*[Yy]es/PermitRootLogin yes/'
    virt-edit -a $work_image_file /etc/ssh/sshd_config -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/'
    # 启用密码登录
    virt-edit -a $work_image_file /etc/cloud/cloud.cfg -e 's/lock_passwd:.*[Tt]rue/lock_passwd: False/'
    virt-edit -a $work_image_file /etc/cloud/cloud.cfg -e 's/lock_passwd:.*1/lock_passwd: 0/'
    virt-edit -a $work_image_file /etc/cloud/cloud.cfg -e 's/ssh_pwauth:.*[Ff]alse/ssh_pwauth: True/'
    virt-edit -a $work_image_file /etc/cloud/cloud.cfg -e 's/ssh_pwauth:.*0/ssh_pwauth: 1/'
    virt-edit -a $work_image_file /etc/ssh/sshd_config -e 's/PasswordAuthentication no/PasswordAuthentication yes/'
    virt-edit -a $work_image_file /etc/ssh/sshd_config -e 's/#UseDNS yes/UseDNS no/'
    virt-edit -a $work_image_file /etc/motd -e '$_ = "" if /^========/'
    virt-edit -a $work_image_file /etc/motd -e '$_ = "" if /^This image built by/'
    virt-edit -a $work_image_file /etc/motd -e '$_ = "" if /^Build time/'
    # 安装常用工具
    virt-customize -a $work_image_file --install cloud-init,qemu-guest-agent,bash-completion,curl,wget,ca-certificates,sudo,net-tools
    if [[ $os_name =~ ^alpinelinux ]]; then
        virt-customize -a $work_image_file --run-command "rc-update add qemu-guest-agent"
    else
        virt-customize -a $work_image_file --run-command "systemctl enable qemu-guest-agent"
    fi
    if [[ $os_name =~ ^centos7 ]]; then
        # 修复centos7下cloud-init19.4版本不支持static6，导致ipv6在PVE中下发失败
        # https://forum.proxmox.com/threads/cloud-init-suddenly-stopped-working-for-centos-fedora-templates.87439/#post-563138
        virt-customize -a $work_image_file --run-command "sed -i \"s/elif subnet_is_ipv6(subnet) and subnet\['type'\] == 'static':/elif subnet_is_ipv6(subnet):\\n                    iface['mode'] = 'static'/\" /usr/lib/python2.7/site-packages/cloudinit/net/eni.py;
            sed -i \"s/elif sn_type in \['static'\]:/elif sn_type in \['static', 'static6'\]:/\" /usr/lib/python2.7/site-packages/cloudinit/net/netplan.py;
            sed -i \"s/elif subnet_type == 'static':/elif subnet_type in \['static', 'static6'\]:/g\" /usr/lib/python2.7/site-packages/cloudinit/net/sysconfig.py"
    fi
    virt-customize -a $work_image_file --root-password password:password
    virt-customize -a $work_image_file --selinux-relabel
    # 使用virt-sparsify将空闲空间归零和稀疏化
    virt-sparsify $work_image_file --compress --convert qcow2 ${compress_dir}/${qcow2_file}
    echo "镜像修改完成: ${qcow2_file}"
}

image=$1

# 检查目录是否存在，不存在则创建
pwd=$(pwd)
download_dir="${pwd}/images_cache"
[ -e "${download_dir}" ] || mkdir -p "${download_dir}"
work_dir="${pwd}/images_work"
[ -e "${work_dir}" ] || mkdir -p "${work_dir}"
compress_dir="${work_dir}/compress"
[ -e "${compress_dir}" ] || mkdir -p "${compress_dir}"

# 下载全部镜像或指定镜像
if [ -z "$image" ]; then
    # 制作全部镜像
    for os in "${!os_images[@]}"; do
        IFS='.' read -r os_name format <<< "$os"
        echo "下载镜像: $os_name"
        download_image "$os" "${os_images[$os]}"
    done
else
    # 制作特定类型的镜像
    if [ -z "${os_images[$image]}" ]; then
        echo "没有找到镜像: $image"
        exit 1
    fi

    IFS='.' read -r os_name format <<< "$image"
    download_image "$os" "${os_images[$image]}"
fi

# 修改全部镜像或指定镜像
if [ -z "$image" ]; then
    # 制作全部镜像
    for os in "${!os_images[@]}"; do
        IFS='.' read -r os_name format <<< "$os"
        echo "修改镜像: $os_name"
        custom_image "$os"
    done
else
    # 制作特定类型的镜像
    if [ -z "${os_images[$image]}" ]; then
        echo "没有找到镜像: $image"
        exit 1
    fi

    IFS='.' read -r os_name format <<< "$image"
    custom_image "$os"
fi
