---
title: 用 LxRunOffline 安装 Arch Linux
date: 2018-02-14
tags:
  - 编程
toc: true
---

前段时间重装系统之后我就一直在 WSL 内开发。Ubuntu 因为我不喜欢所以直接放弃（？？？），所以就一直在用 openSUSE。然而现在越用越感觉 zypper 的下载源坑爹……于是在 Github 上一阵搜索之后，我终于找到了这个神器：[LxRunOffline](https://github.com/DDoSolitary/LxRunOffline)。于是我毅然卸载了 openSUSE，开始尝试安装 Arch Linux……

<!-- more -->

## 准备工作

0. 你需要一个 64 位的 Windows 10 专业版或企业版的最新 Insder 预览版（为了正常使用 WSL）；
1. 启用*适用于 Linux 的 Windows 子系统*（不开这个还想用 WSL？）；
2. 下载 [LxRunOffline](https://github.com/DDoSolitary/LxRunOffline)，解压到任意位置（推荐开发版本）；
3. 在 [清华大学镜像站](https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/latest/) 下载 `archlinux-bootstrap-<日期>-x86_64.tar.gz`。

## 安装 rootfs

在 LxRunOffline 目录下打开 CMD 或 PowerShell（我用 CMD），输入

```shell
> .\LxRunOffline.exe install -n <用于向 Windows 注册的系统名> -f <到 rootfs 文件的路径> -d <安装到的目录> -r root.x86_64
```

LxRunOffline 可能会要求重启，那么重启之后再次输入上述命令。LxRunOffline 会把系统安装到指定的目录。正常安装完成后 LxRunOffline 不会有任何输出（真是遵循 UNIX 哲学）。然后输入：

```shell
> .\LxRunOffline.exe default -n <之前输入的系统名>
```

把刚刚安装的 Arch 设为默认，就可以输入 `wsl` 启动 Arch 了。

## 安装系统

首先要用 Windows 资源管理器找到 Arch 的安装目录，编辑 `安装目录\rootfs\etc\pacman.d\mirrorlist`，选择需要的服务器，取消注释。（因为这时候 Arch 内没有安装任何编辑器。）此时建议打开任务管理器检查是否有未关闭的 WSL 进程。把 WSL 进程全部停止，然后输入 `wsl` 打开 Bash（此时应该是以 root 用户登陆的），开始安装 Arch：

```shell
# pacman-key --init
# pacman-key --populate archlinux
# pacman -Syyu base base-devel
```

设置用户：

```shell
# useradd -m -G wheel -s /bin/bash <用户名>
# passwd root
# passwd <用户名>
```

输入 `visudo`，按自己的喜好设置 sudo 权限。按 [这里](https://www.archlinuxcn.org/archlinux-cn-repo-and-mirror/) 的说明添加 `archlinuxcn` 软件源，安装 `fakeroot-tcp` 包。此时 Pacman 会提示 `fakeroot-tcp` 与 `fakeroot` 冲突，选择卸载 `fakeroot`。需要这个软件包的原因见 [此](https://github.com/Microsoft/BashOnWindows/issues/2465)。

接下来输入 `id -u <用户名>` 查看 UID，然后退出 Bash，输入

```shell
> .\LxRunOffline.exe config-uid -n <之前输入的系统名> -v <UID>
```

设置默认用户。此时建议打开任务管理器检查是否有未关闭的 WSL 进程。把 WSL 进程全部停止，然后打开 Bash，系统就会默认以你的用户登录了。

![Enjoy~](finish.png)

到这里为止，Arch Linux 就安装完成了。（撒花🎉~）此时系统内还有一些无用的软件包，强迫症可以输入以下命令卸载这些无用的包：

```shell
$ sudo pacman -R arch-install-scripts linux-firmware mkinitcpio mkinitcpio-busybox linux
```

虽然除了 `arch-install-scripts` 以外其他的看起来都是重要的包，但是在 WSL 上这些都没有用，因为 Linux 内核由 Windows 提供。当然，你也可以在刚才安装时就不安装以上这些包（忘记讲了，这里补一下）。
