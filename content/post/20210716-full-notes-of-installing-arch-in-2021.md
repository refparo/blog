---
title: 2021 年的 Arch 安装完全笔记：从选择镜像到个性化
date: 2021-07-18
lastmod: 2021-07-20
toc: true
---

时隔多年终于回到技术栏目，第一篇博客竟然又是环境配置（笑）。

这次我们要在实机上安装 Arch Linux 了。实际上这也不是我第一次在实机上装 Arch，但标题中强调的“2021 年”，意味着这次肯定要有与之前不一样的东西。这次安装的目标是：在 [Wayland](https://wiki.archlinux.org/title/Wayland) 下基于平铺式窗口管理器 [Sway](https://github.com/swaywm/sway/) 构建一个基本可用的桌面环境。

<!-- more -->

那么话不多说，直入正题。制作安装 U 盘、分区等步骤各人各机需求不同，所以我们跳过这两步，从 Arch Wiki 的 [Installation](https://wiki.archlinux.org/title/Installation_guide#Installation) 一节开始。

## 安装系统

假设现在你已经在 live 系统内，连上了网，对好了时，分好了区，把根文件系统装载到 `/mnt`，把 EFI 文件系统装载到 `/mnt/boot`。

2021 年的 live 系统已经自带了 [reflector](https://wiki.archlinux.org/title/Reflector)，用来自动选择“最好的”镜像源。然而，reflector 在国内的效果往往并不好。个人建议手动选择。

```text
# systemctl disable --now reflector.service reflector.timer
# tar -xf /var/cache/pacman/pkg/pacman-mirrorlist-* etc/pacman.d/mirrorlist
# cp -f etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
# vim /etc/pacman.d/mirrorlist # 选择你需要的镜像源
```

安装基础软件包（包括 `base-devel`）、内核、固件、[文本编辑器](https://wiki.archlinux.org/title/Text_editor)（我选择 Vim）、[无线网络管理器](https://wiki.archlinux.org/title/Networking)（我选择 iwd，不是笔记本就不需要了）、文档查看器等。

```text
# pacstrap /mnt base linux linux-firmware \
    base-devel vim iwd man-db man-pages texinfo
```

下面从 chroot 开始到设置 root 密码为止都和 Arch Wiki 的安装指南没有区别，所以直接看安装指南吧：[Configure the system](https://wiki.archlinux.org/title/Installation_guide#Configure_the_system)。

安装 [boot loader](https://wiki.archlinux.org/title/Boot_loader) 和 microcode。为了简单起见，我们使用 [GRUB](https://wiki.archlinux.org/title/GRUB)，并且不启用 Secure Boot。如果你想让 Arch 与 Windows 11 组成双系统，请自行学习 [Secure Boot 的配置方法](https://wiki.archlinux.org/title/Secure_Boot)。

```text
# pacman -S grub efibootmgr os-prober
# echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
# pacman -S intel-ucode # 或者 amd-ucode，取决于你的 CPU 品牌。
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
# grub-mkconfig -o /boot/grub/grub.cfg 
```

最后一行指令会自动检测到已安装的 Windows。如果想要之后再安装 Windows，可以在安装后重新执行这行指令。下面退出 chroot 环境，重启。

```text
# exit
# reboot
```

## 基础配置

现在你已经启动到刚刚安装的新系统。第一步是连上网。如果你使用 Wi-Fi，那么首先用 `iwctl` 连接 Wi-Fi，记住网络接口名。如果你使用有线网络，那么插上网线，用 `ip link` 查看网络接口名。编辑 `/etc/systemd/network/<网络接口名>.network`：

```ini
[Match]
Name=<网络接口名>

[Network]
DHCP=yes
IPv6PrivacyExtensions=true
```

然后让 `systemd-networkd` 重新加载配置文件：

```text
# networkctl reload
```

现在你应该已经连上网了。下面设置用户：

```text
# useradd -m -G wheel video -s /bin/bash <用户名>
# passwd <用户名>
```

给予新用户 `sudo` 权限（把 `vim` 换成你安装的文本编辑器，下同）：

```text
# EDITOR=vim visudo # 取消注释 %wheel ALL=(ALL) ALL 一行
```

安装 `polkit` 来让新用户有权开关机。

```text
# pacman -S polkit
```

添加 [`archlinuxcn` 源](https://github.com/archlinuxcn/mirrorlist-repo#readme)。向 `/etc/pacman.conf` 末尾加入以下内容（可自行选择和调整镜像顺序）：

```ini
[archlinuxcn]
Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux-cn/$arch
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
```

刷新缓存，安装 `archlinuxcn-keyring`，然后退出 root 用户，重新登录到新用户。

```text
# pacman -Syy archlinuxcn-keyring
# exit
```

安装 [AUR helper](https://wiki.archlinux.org/title/AUR_helpers)，这里选择 `paru`。

```bash
$ sudo pacman -S paru
$ mkdir -p ~/.config/paru
$ cp /etc/paru.conf ~/.config/paru/paru.conf
```

按自己的需要编辑 `~/.config/paru/paru.conf`，尤其是要配置 AUR 镜像。我的配置：[`paru.conf`](https://github.com/refparo/dotfiles/blob/760ea8e2ef783359477d64df9092dd330041d7c5/.config/paru/paru.conf)。

配置 Bash 自动补全和历史记录：

```bash
$ paru -S bash-completion # 把 paru 换成你安装的 AUR helper 或 sudo pacman，下同
$ paru --aur -S bash-complete-alias # 可选，需要 AUR helper 或手动安装
```

接下来编辑 `~/.bashrc`。下面的是我的配置，`$PS1` 和命令别名均可根据自己的需要调整。

```bash
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o noclobber
shopt -s checkwinsize
shopt -s expand_aliases

PS1="\[$(tput setaf 6)\]\w\[$(tput setaf 2)\] \\$ \[$(tput sgr0)\]"
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE='\: *:\:'
HISTFILESIZE=
HISTSIZE=
HISTTIMEFORMAT="[%F %T] "
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

alias ls='ls --color=auto'
alias la='ls -A --color=auto'
alias ll='ls --color=auto -Al'
alias userctl='systemctl --user'
alias :q=exit

# 这部分是用来自动补全命令别名的，需要对每个别名分别设置
# 如果没有安装 bash-complete-alias，则不需要下面这部分
. /usr/share/bash-complete-alias/complete_alias
complete -F _conplete_alias la
complete -F _complete_alias ll
complete -F _complete_alias userctl
```

其它常用命令行工具均可按需安装，这里就不再展开。

电源管理所需要的配置在不同硬件之间差别很大，我现在的笔记本用的是 Intel 处理器，下面是我使用的电源管理服务：

```bash
$ paru -S thermald cpupower tlp
$ sudo systemctl enable --now thermald cpupower tlp
```

同时建议[修改 `/etc/systemd/logind.conf` 里的 ACPI 事件设置](https://wiki.archlinux.org/title/Power_management#Power_management_with_systemd)，我修改了下面两条：

```ini
HandlePowerKey=ignore
HandleLidSwitch=lock
```

基础配置差不多就是这些。接下来就是这篇博客真正的重头戏了。

## 图形界面

首先安装显卡驱动。这一步同样与硬件高度相关，这里仅以 Intel 集显为例，其它显卡的用户可以参考 [Arch Wiki 的这一节](https://wiki.archlinux.org/title/Xorg#Driver_installation)自行调整。

```bash
$ paru -S mesa libva-intel-driver
```

安装 Sway、Xwayland、Qt5 的 Wayland 后端、终端模拟器和基础字体。

```bash
$ paru -S sway xorg-xwayland qt5-wayland qterminal \ # 换成你喜欢的终端模拟器
    noto-fonts noto-fonts-cjk noto-fonts-emoji # 可以换成你喜欢的字体，但要有中英文
```

接下来是重点！就本文写作时而言，官方库内还没有原生支持 Wayland 的[显示管理器](https://wiki.archlinux.org/title/Display_manager)（唯一一款原生支持 Wayland 的需要自行编译和很复杂的配置，其它的虽然能启动 Wayland 桌面环境但本身必须运行在 X server 下），因此我们将不使用显示管理器，直接在登陆 TTY 后从 TTY 启动 Sway。下面需要手动编写一些 Systemd 单元文件。

`~/.config/systemd/user/sway-session.target`：

```ini
[Unit]
Description=Sway session
Documentation=man:systemd.special(7)
BindsTo=graphical-session.target
```

`~/.config/systemd/user/graphical-session.target.d/override.conf`：

```ini
[Unit]
BindsTo=sway-session.target
```

`~/.config/systemd/user/sway-autostart.target`：

```ini
[Unit]
Description=Sway session autostart
Documentation=man:systemd.special(7)
BindsTo=xdg-desktop-autostart.target graphical-session.target
```

`~/.config/systemd/user/xdg-desktop-autostart.target.d`：

```ini
[Unit]
BindsTo=sway-autostart.target
```

`~/.config/systemd/user/sway.service`：

```ini
[Unit]
Description=Sway
Documentation=man:sway(5)

[Service]
Type=simple
ExecStart=sway
ExecStopPost=systemctl --user stop sway-session.target
ExecStopPost=systemctl --user unset-environment DBUS_SESSION_BUS_ADDRESS DISPLAY SWAYSOCK WAYLAND_DISPLAY

[Install]
WantedBy=graphical-session.target
```

配置 Sway：

```bash
$ userctl enable sway # 如果没有设置别名 userctl，就换成 systemctl --user，下同
$ mkdir -p ~/.config/sway
$ cp /etc/sway/config ~/.config/sway/config
```

编辑 `~/.config/sway/config`。`set $term` 处：

```bash
# Your preferred terminal emulator
set $term qterminal
```

`# Exit sway` 处：

```bash
# Exit sway (logs you out of your Wayland session)
bindsym $mod+Shift+e exec swaynag -t warning \
  -m 'Do you really want to exit sway? This will end your Wayland session.' \
  -b 'Yes, exit sway' \
  'systemctl --user stop sway-session.target; swaymsg exit'
```

文件末尾：

```bash
# Begin autostart
exec sleep 5 && systemctl --user start sway-autostart.target
```

除了上述几处之外，你也可以在这里根据自己的需求修改键位、壁纸、Hi-DPI 缩放、触摸板、键盘 Numlock 等配置，详见 [Arch Wiki 页面](https://wiki.archlinux.org/title/Sway)和 [Sway 文档](https://man.archlinux.org/man/sway.5)。

编辑 `~/.config/environment.d/env.conf` 设置环境变量（这里有一些变量要后面才会用到，这里提前加入以免重复累赘）：

```ini
LANG=zh_CN.UTF-8
XDG_CURRENT_DESKTOP=sway
QT_QPA_PLATFORM=wayland-egl
SDL_VIDEODRIVER=wayland
MOZ_ENABLE_WAYLAND=1
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
```

编辑 `~/.bashrc`：

```diff
 # If not running interactively, don't do anything
 [[ $- != *i* ]] && return

+if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
+  export EDITOR=vim
+  export PATH=$HOME/.local/bin:$PATH
+  systemctl --user import-environment \
+    XDG_SESSION_ID XDG_RUNTIME_DIR XDG_SESSION_TYPE XDG_SEAT \
+    PATH EDITOR
+  systemctl --user start sway-session.target
+fi
```

最后，`reboot` 重启电脑。重新登陆，你应该能看到 Sway 自动启动了。

下面解释一下上述配置的原理。Sway 启动需要一些环境变量，这些环境变量在每次登陆时可能有变化，并且 Systemd 的服务运行环境默认并没有设置这些环境变量，因此我们需要在登陆到 Bash 时将这些变量导入到 Systemd 的环境中，然后启动 Sway session。一些 TTY 下与图形环境共享的环境变量也应在这里设置并导入。而仅限图形环境的变量则可在 Systemd 的环境配置文件夹 `~/.config/environment.d/` 下设置。`sway-session.target` 启动会带动 `graphic-session.target` 这个特殊目标启动，进而启动我们已经启用的 `sway.service`，也就是启动 Sway。Sway 在读取到配置文件的末尾时启动 `sway-autostart.target`，从而启动之后需要安装的各种自启应用。

为什么要搞得那么复杂？为了符合 Systemd 的标准，从而更方便与之后安装的各种应用协调。

现在你已经进入 Sway，使用 <kbd>Meta</kbd>+<kbd>Enter</kbd>（即 <kbd>Win</kbd>+<kbd>Enter</kbd>）启动终端模拟器。首先安装音频服务并启动。

```bash
$ paru -S pipewire pipewire-alsa pipewire-pulse
$ userctl start pipewire pipewire-pulse pipewire-media-session
```

还有一些不需要怎么配置的系统服务，如状态栏（这里选择 `waybar`）、消息通知 daemon（这里选择 `mako`）、`xdg-desktop-portal`。

```bash
$ paru -S --asdeps xdg-desktop-portal-wlr
$ paru -S otf-font-awesome waybar mako xdg-desktop-portal
```

编辑 `~/.config/sway/config` 的 `# Status Bar` 部分来应用 `waybar`：

```bash
#
# Status Bar:
#
bar {
  swaybar_command waybar
}
```

<kbd>Meta</kbd>+<kbd>Shift</kbd>+<kbd>C</kbd> 重载配置文件，就能看到新的状态栏了。可以分别编辑 [`~/.config/waybar/{config,style.css}`](https://github.com/Alexays/Waybar/wiki/Configuration) 和 [`~/.config/mako/config`](https://man.archlinux.org/man/mako.5.en) 来自定义它们的外观。

下面安装应用启动器，这里选择 `bemenu`。

```bash
$ paru -S bemenu j4-dmenu-desktop-git
```

编辑 `~/.config/sway/config` 的 `set $menu` 处：

```bash
# Your preferred application launcher
# Note: pass the final command to swaymsg so that the resulting window can be opened
# on the original workspace that the command was run on.
set $menu j4-dmenu-desktop \
  --dmenu='bemenu -i -l10 --scrollbar autohide' \
  --wrapper 'swaymsg exec'
```

再次重载配置文件，现在你可以用 <kbd>Meta</kbd>+<kbd>D</kbd> 打开应用启动器了。

现在你可以安装 `firefox`（以及 `firefox-i18n-zh-cn`）并用应用启动器启动来继续阅读本文的下一部分了。

## 应用软件

这一节将会介绍一些比较难配置，或者需要注意的应用的安装配置。这一节的各部分基本是相互独立的。

### 亮度与音量调节

我的笔记本上有亮度和音量调节的按键，这些按键的功能在 Sway 上需要手动实现。

首先我们要给予用户修改亮度的权限。编辑 `/etc/udev/rules.d/backlight.rules`：

```text
SUBSYSTEM=="backlight", ACTION=="add", \
  RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", \
  RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
```

重载 udev 规则：

```bash
$ sudo udevadm control --reload
$ sudo udevadm trigger
```

接下来，我们还希望使用这些按键时能有屏幕反馈。可以用 Wob 实现简单的亮度/音量提示框。

```bash
$ paru -S wob
```

编写一些 Systemd 单元文件。`~/.config/systemd/user/wob@.socket`：

```ini
[Socket]
ListenFIFO=%t/wob@%i.sock
SocketMode=0600

[Install]
WantedBy=sockets.target
```

`~/.config/systemd/user/wob@.service`：

```ini
[Unit]
Description=Wob
BindsTo=graphical-session.target

[Service]
Type=simple
StandardInput=socket
ExecStart=wob --anchor top --border-color "#A0000000" --background-color "#A0000000" --bar-color "#A0FFFFFF"
```

然后分别对亮度和音量启用 `wob@.socket`：

```bash
$ userctl enable --now wob@brightness.socket wob@volume.socket
```

现在这两个服务会监听 `$XDG_RUNTIME_DIR/wob@{brightness,volume}.sock`，在读取到数字时显示亮度和音量。

为了修改亮度，我们还需要安装一个命令行工具 `acpilight`：

```bash
$ paru -S acpilight
```

最后向 Sway 配置文件中加入以下几行来监听快捷键：

```bash
# Light adjustment
bindsym --locked XF86MonBrightnessUp exec xbacklight -inc 2 && xbacklight -get > $XDG_RUNTIME_DIR/wob@brightness.sock
bindsym --locked XF86MonBrightnessDown exec xbacklight -dec 2 && xbacklight -get > $XDG_RUNTIME_DIR/wob@brightness.sock

# Audio adjustment
bindsym --locked XF86AudioMute exec pactl set-sink-mute 0 toggle
bindsym --locked XF86AudioLowerVolume exec pactl set-sink-volume 0 -5% \
  && pactl list sinks | grep -Pom1 "\d+(?=%)" > $XDG_RUNTIME_DIR/wob@volume.sock
bindsym --locked XF86AudioRaiseVolume exec pactl set-sink-volume 0 +5% \
  && pactl list sinks | grep -Pom1 "\d+(?=%)" > $XDG_RUNTIME_DIR/wob@volume.sock
```

### 锁屏

在 Sway 中，锁屏也需要手动配置。这里使用 Sway 官方开发的 `swaylock` 和 `swayidle`。

```bash
$ paru -S swaylock swayidle
```

这两个工具结合使用可以实现非常复杂的锁定逻辑。这里我们要实现的功能是这样的：

- 当按下电源按钮，关闭屏幕且不锁定；
- 当按下 <kbd>Meta</kbd>+<kbd>L</kbd>，锁定但不关闭屏幕；
- 当合上屏幕时，锁定；
- 当持续 5 分钟无活动时，锁定并关闭屏幕。

下面编写一些 Systemd 单元文件。`~/.config/systemd/user/sway-close-display.service`，用来实现第一点需求：

```ini
[Unit]
Description=Swayidle close display
BindsTo=graphical-session.target

[Service]
Type=simple
ExecStart=swayidle -w timeout 0 'close-display' resume 'swaymsg "output * dpms on"'

[Install]
WantedBy=xdg-desktop-autostart.target
```


`~/.config/systemd/user/sway-idle-lock.service`，用来实现其余三点：

```ini
[Unit]
Description=Swayidle idle lock
BindsTo=graphical-session.target

[Service]
Type=simple
ExecStart=swayidle -w timeout 300 'close-display' timeout 301 'swaylock' resume 'swaymsg "output * dpms on"' before-sleep 'swaylock' lock 'swaylock'

[Install]
WantedBy=xdg-desktop-autostart.target
```

启用这两个服务：

```bash
$ userctl enable --now sway-close-display sway-idle-lock
```

还要编写两个辅助脚本。`~/.local/bin/close-display`，用来实现流畅美观地关闭屏幕：

```bash
#!/bin/bash
orig_value=$(xbacklight -get)
xbacklight -set 0 -fps 60
swaymsg 'output * dpms off'
xbacklight -set $orig_value
```

`~/.local/bin/lock`，用来手动触发关闭屏幕和锁定：

```bash
#!/bin/bash
kill -s SIGUSR1 \
  $(systemctl --user show $1 --property=MainPID | cut -d'=' -f2)
```

最后向 Sway 配置文件加入以下几行监听快捷键：

```bash
# Lock
bindsym --locked $mod+l exec swaylock
bindsym --locked XF86PowerOff exec lock sway-close-display
```

完成。你可以编辑 [`~/.config/swaylock/config`](https://man.archlinux.org/man/swaylock.1) 修改锁屏的外观。

### 截图

就本文写作时而言，在 Sway 下暂时还没有很完善的截图解决方案。下面给出一种做法。

```bash
$ paru -S grim slurp grimshot swappy
```

编辑 Sway 配置文件绑定快捷键：

```bash
# Screenshot
bindsym Print exec grimshot copy screen
bindsym $mod+Print exec grimshot save window - | swappy -f -
bindsym $mod+Shift+Print exec sleep 3 && grimshot save window - | swappy -f -
```

这么做可以实现：

- 当按下键盘上的 <kbd>Print</kbd> 键时，全屏截图并复制；
- <kbd>Meta</kbd>+<kbd>Print</kbd>，选框截图并使用 Swappy 编辑；
- <kbd>Meta</kbd>+<kbd>Shift</kbd>+<kbd>Print</kbd>，倒计时三秒后选框截图并用 Swappy 编辑。

然而由于 `grimshot` 是基于 `grim` 和 `slurp` 两个工具来实现选框截图的，是在选择好区域后再截图，而非先固定截图再选择区域裁剪，这就导致第三个快捷键的目的——给右键菜单等鼠标操作后会消失的控件截图——并不能实现。

### 剪贴板管理器

Wayland 服务器不提供剪贴板管理功能，需要安装剪贴板管理程序才能在剪贴来源程序关闭后保存剪贴板内容。

```bash
$ paru -S copyq
```

用应用启动器启动 CopyQ，在文件 > 首选项 菜单内启用自动启动。

已知问题是 [CopyQ 的菜单栏菜单总是出现在上方](https://github.com/hluk/CopyQ/issues/1712)。

### 输入法

```bash
$ paru -S fcitx5-im fcitx5-chinese-addons
```

用应用启动器启动 Fcitx 5。所需的环境变量已经在前面配置好。下次启动 Sway 时 Fcitx 5 会自动启动。

已知问题是[在 Firefox 的拓展的弹框内（例如 Saladict）输入法选项框无法显示](https://bugzilla.mozilla.org/show_bug.cgi?id=1720814)。

### 基于 Chromium 的应用

目前大部分基于 Chromium 的应用应该都还需要手动添加命令行参数才能原生运行在 Wayland 下，下面以 Visual Studio Code 为例。

```bash
$ paru -S visual-studio-code-bin
$ mkdir -p ~/.local/share/applications
$ cp /usr/share/applications/visual-studio-code* ~/.local/share/applications/
```

编辑 `~/.local/bin/code`：

```bash
#!/bin/bash
/usr/bin/code --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"
```

`~/.local/share/applications/visual-studio-code.desktop`：

```diff
@@ -5 +5 @@
-Exec=/opt/visual-studio-code/code --no-sandbox --unity-launch %F
+Exec=code --no-sandbox --unity-launch %F
@@ -17 +17 @@
-Exec=/opt/visual-studio-code/code --no-sandbox --new-window %F
+Exec=code --no-sandbox --new-window %F
```

`~/.local/share/applications/visual-studio-code-url-handler.desktop`：

```diff
@@ -5 +5 @@
-Exec=/opt/visual-studio-code/code --no-sandbox --open-url %U
+Exec=code --no-sandbox --open-url %U
```

现在 VSCode 就能原生在 Wayland 下运行了。

已知问题是 [VSCode 内无法使用输入法](https://github.com/microsoft/vscode/issues/120084)。

### 代理

这里使用 Qv2ray 来图形化管理 V2ray。

```bash
$ paru -S qv2ray-dev-git xray # 或者 v2ray
```

从应用管理器启动 Qv2ray，在首选项中启用登陆时启动。如果使用 xray 则还要在 首选项 > 内核设置 中更换内核。

### 其它常用应用

我的选择：

```bash
$ paru -S gthumb # 图片查看器
$ paru -S thunar gvfs trash-cli # 文件管理器和回收站
$ paru -S mpv # 音乐和视频播放器，等到 VLC 原生支持 Wayland 之后会换成 VLC
```

至于更多的……自己探索吧。

## 个性化

这里的个性化指的是 GTK 和 Qt 两大 GUI 框架的主题。我安装的主题：

```bash
$ paru -S arc-gtk-theme arc-icon-theme
```

GTK 在 Wayland 下的主题设置比较麻烦，因为 GTK3 在 Wayland 下有[特别的读取主题方式](https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland)。我选择自己写一个脚本设置主题。

```bash
#!/bin/bash

gtk2_config="$HOME/.gtkrc-2.0"
gtk3_config="$HOME/.config/gtk-3/settings.ini"
gnome_schema="org.gnome.desktop.interface"
map=(
# gtkrc-key:gsettings-key:value
  gtk-theme-name:gtk-theme:Arc-Dark
  gtk-icon-theme-name:icon-theme:Arc
  "gtk-font-name:font-name:Sans 11"
  gtk-cursor-theme-name:cursor-theme:Adwaita
)

rm -f $gtk2_config
rm -f $gtk3_config
#mkdir -p $(dirname $gtk3_config)
#echo "[Settings]" >> $gtk3_config
for i in "${map[@]}"; do
  #echo $(echo $i | cut -d':' -f1) = \"$(echo $i | cut -d':' -f3)\" >> $gtk2_config
  #echo $(echo $i | cut -d':' -f1) = $(echo $i | cut -d':' -f3) >> $gtk3_config
  gsettings set $gnome_schema $(echo $i | cut -d':' -f2) "$(echo $i | cut -d':' -f3)"
done
```

有 GTK2 和在 XWayland 下使用 GTK3 需求的可以取消注释对应的行。这个脚本只需要在修改配置时运行一次，不需要每次启动都运行。

Qt 的主题设置基本和 X11 下相同，我的选择：

```bash
$ paru -S qt5ct kvantum-qt5
```

在 `~/.config/environment.d/env.conf` 内加入 `QT_QPA_PLATFORMTHEME=qt5ct`，用 Kvantum Manager 选择仿 Arc Dark 主题，用 Qt5ct 选择 Kvantum 主题引擎。

Fontconfig 设置之类的，都与 X11 下没有区别，可以直接参考 Arch Wiki。

## 已知问题

- 前面已经提到的问题；
- [当 Sway 设置了 Hi-DPI 缩放时，运行在 XWayland 下的程序会模糊](https://github.com/swaywm/wlroots/pull/2064)。

