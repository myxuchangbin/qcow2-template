# qcow2-template

一套可直接下载使用的 Linux 虚拟机镜像。镜像基于各 Linux 发行版官方云镜像制作，适用于支持 **QCOW2** 格式的平台，例如 Proxmox VE、KVM 等。

[![Build Images Template](https://github.com/myxuchangbin/qcow2-template/actions/workflows/build.yml/badge.svg)](https://github.com/myxuchangbin/qcow2-template/actions/workflows/build.yml)

## 这个项目能做什么？

如果你需要在家用服务器、云主机或虚拟化平台上安装 Linux，但不想从头安装系统，可以下载本项目提供的镜像，导入平台后创建虚拟机。

- **上手更快：** 下载镜像即可开始创建虚拟机，不必自己安装操作系统。
- **系统干净精简：** 基于发行版官方云镜像，不带桌面环境、捆绑软件或项目专属服务。
- **常用虚拟机功能已准备好：** 预装云初始化和虚拟机管理组件，方便配置网络、SSH 和虚拟机状态。
- **系统选择多：** 提供 Ubuntu、Debian、CentOS、AlmaLinux、Rocky Linux 和 Alpine Linux 等镜像。

## 下载与使用

1. 前往 [Releases 下载页面](https://github.com/myxuchangbin/qcow2-template/releases)。
2. 选择所需的 Linux 版本，下载对应的 `.qcow2` 镜像文件。
3. 在虚拟化平台中导入镜像并创建虚拟机。
4. 首次启动时，按平台提示配置网络、主机名和 SSH 密钥等信息。

> 请下载 Release 中的 `.qcow2` 镜像，不要下载 `Source code (zip)` 或 `Source code (tar.gz)`；源码压缩包不能直接用作虚拟机磁盘。

## 可用镜像

| 镜像文件 | 系统 | 版本 | 虚拟盘容量（上游默认值） |
| --- | --- | --- | ---: |
| `ubuntu2004.qcow2` | Ubuntu | 20.04 LTS (Focal Fossa) | 2.2 GiB |
| `ubuntu2204.qcow2` | Ubuntu | 22.04 LTS (Jammy Jellyfish) | 2.2 GiB |
| `ubuntu2404.qcow2` | Ubuntu | 24.04 LTS (Noble Numbat) | 2.2 GiB |
| `ubuntu2604.qcow2` | Ubuntu | 26.04 LTS (Resolute Raccoon) | 2.2 GiB |
| `debian11.qcow2` | Debian | 11 (Bullseye) | 2 GiB |
| `debian12.qcow2` | Debian | 12 (Bookworm) | 2 GiB |
| `debian13.qcow2` | Debian | 13 (Trixie) | 2 GiB |
| `centos7.qcow2` | CentOS | 7 | 8 GiB |
| `centos8-stream.qcow2` | CentOS Stream | 8 | 10 GiB* |
| `centos9-stream.qcow2` | CentOS Stream | 9 | 10 GiB |
| `centos10-stream.qcow2` | CentOS Stream | 10 | 10 GiB* |
| `almalinux8.qcow2` | AlmaLinux | 8 | 10 GiB |
| `almalinux9.qcow2` | AlmaLinux | 9 | 10 GiB |
| `almalinux10.qcow2` | AlmaLinux | 10 | 10 GiB |
| `rockylinux8.qcow2` | Rocky Linux | 8 | 10 GiB |
| `rockylinux9.qcow2` | Rocky Linux | 9 | 10 GiB |
| `rockylinux10.qcow2` | Rocky Linux | 10 | 10 GiB |
| `alpinelinux_324.qcow2` | Alpine Linux | 3.24.2 | 200 MiB* |
| `alpinelinux_323.qcow2` | Alpine Linux | 3.23.3 | 200 MiB* |
| `alpinelinux_322.qcow2` | Alpine Linux | 3.22.1 | 200 MiB* |

容量是上游镜像设置的虚拟磁盘大小，不代表下载文件大小。带 `*` 的容量为估算值，可能随上游版本变化。

## 镜像内容与登录

镜像基于发行版官方云镜像制作，保留精简的系统环境，并做了以下调整，方便创建和管理虚拟机：

- **预装工具：** 安装云初始化工具 `cloud-init`、虚拟机管理组件 `qemu-guest-agent`、SSH 服务，以及 `curl`、`wget`、`sudo`、`net-tools`、`unzip`、`bzip2`、`lsof`、`bash-completion` 和 `ca-certificates` 等常用工具。
- **登录与服务：** 允许使用 root 用户和密码通过 SSH 登录，关闭 SSH 登录时的 DNS 查询，并启用 SSH 和 QEMU Guest Agent 服务。
- **系统时区：** 设置为香港时间（`Asia/Hong_Kong`）。
- **兼容旧版系统：** 将 Debian 11 的软件源调整为 Debian Archive，并关闭软件源过期时间检查；将 CentOS 7 和 CentOS 8 Stream 的软件源调整为 CentOS Vault。CentOS 7 还会修复 cloud-init 的静态 IPv6 配置兼容性。

默认用户名为 `root`，初始密码为 `password`；如果创建虚拟机时通过 cloud-init 设置了其他密码，则使用所设置的密码。推荐在首次启动时配置 SSH 公钥。

**安全提醒：** 初始密码是公开的。虚拟机连接公网前，请务必设置自己的强密码，或改用 SSH 密钥并关闭不需要的密码登录。不要在公网环境中继续使用初始密码。

## 反馈与贡献

遇到问题或有改进建议？欢迎到 [GitHub Issues](https://github.com/myxuchangbin/qcow2-template/issues) 反馈；如果愿意，也欢迎提交 Pull Request。反馈时请注明镜像版本和使用的虚拟化平台。

## 许可证

项目采用 [MIT License](./LICENSE)。镜像内操作系统及预装软件仍遵循各自上游项目的许可证。
