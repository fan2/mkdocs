---
title: rpi4b-ubuntu外挂硬盘配置samba共享服务
authors:
  - xman
date:
    created: 2024-03-18T17:00:00
categories:
    - ubuntu
    - samba
tags:
    - ubuntu
    - samba
comments: true
---

本文梳理了为树莓派 RPI4B/Ubuntu 外挂硬盘配置 samba 局域网共享服务，并将其中一个分区作为 macOS TM 备份分区，实现局域网无线备份。

<!-- more -->

## disk info

2T 的 WD 硬盘之前格式化为 macExt 格式，其中 1.5T 的 sda2 为 macOS 备份分区，0.5T 的 sda3 为普通分区。

### lsblk

lsblk - list block devices

```Shell
$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0         7:0    0  59.7M  1 loop /snap/core20/2186
loop1         7:1    0    59M  1 loop /snap/core20/1638
loop2         7:2    0  69.2M  1 loop /snap/core22/1125
loop3         7:3    0 131.9M  1 loop /snap/lxd/23893
loop4         7:4    0 134.1M  1 loop /snap/lxd/27054
loop5         7:5    0    34M  1 loop /snap/snapd/21185
loop6         7:6    0  35.2M  1 loop /snap/snapd/20674
sda           8:0    0   1.8T  0 disk
├─sda1        8:1    0   200M  0 part
├─sda2        8:2    0   1.4T  0 part
└─sda3        8:3    0 465.6G  0 part
mmcblk0     179:0    0  59.5G  0 disk
├─mmcblk0p1 179:1    0   256M  0 part /boot/firmware
└─mmcblk0p2 179:2    0  59.2G  0 part /
```

!!! note "blkid"

    blkid - locate/print block device attributes

    执行 `sudo blkid` 可以查看硬盘块设备 id 信息，包括 LABEL、UUID 和 TYPE（文件系统类型）。

### fdisk

fdisk - manipulate disk partition table

- `-l` / `--list`: List the partition tables for the specified devices and then exit.

```Shell
$ sudo fdisk -l

...

Device          Start        End    Sectors   Size Type
/dev/sda1          40     409639     409600   200M EFI System
/dev/sda2      409640 2930008111 2929598472   1.4T Apple HFS/HFS+
/dev/sda3  2930270256 3906701271  976431016 465.6G Apple HFS/HFS+
```

## mount disk

创建挂载点目录：

```Shell
$ sudo mkdir /media/WDHD

$ ls -l /media/
total 4
drwxr-xr-x 2 root root 4096 Apr  7 03:22 WDHD
```

修改挂载点目录的所有人为当前用户（组）：

```Shell
$ sudo chown pifan:ubuntu /media/WDHD

$ ls -l /media/
total 4
drwxr-xr-x 2 pifan ubuntu 4096 Apr  7 03:22 WDHD
```

挂载外接硬盘的 sda3 分区：

```Shell
# sudo mount /dev/sda3 /media/WDHD
$ sudo mount -o uid=pifan,gid=ubuntu /dev/sda3 /media/WDHD
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           781M  3.1M  778M   1% /run
/dev/mmcblk0p2   59G   14G   42G  25% /
tmpfs           3.9G     0  3.9G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/mmcblk0p1  253M  138M  115M  55% /boot/firmware
tmpfs           781M  4.0K  781M   1% /run/user/1000
/dev/sda3       466G  204G  262G  44% /media/WDHD
```

### test mkdir

尝试在外挂硬盘上创建一个文件夹，提示“Read-only file system”：

```Shell
$ mkdir /media/WDHD/test
$ mkdir: cannot create directory ‘/media/WDHD/test’: Read-only file system
```

### install hfsprogs

参考 [mount - How to read and write HFS+ journaled external HDD in Ubuntu without access to OS X? - Ask Ubuntu](https://askubuntu.com/questions/332315/how-to-read-and-write-hfs-journaled-external-hdd-in-ubuntu-without-access-to-os)。

执行以下命令安装 hfsprogs（mkfs and fsck for HFS and HFS+ file systems）

```Shell
$ sudo apt-get install hfsprogs -y
```

执行 fsck.hfsplus 检查磁盘状态：

```Shell
$ sudo fsck.hfsplus /dev/sda3
** /dev/sda3
   Executing fsck_hfs (version 540.1-Linux).
** Checking Journaled HFS Plus volume.
   The volume name is WDHD
** Checking extents overflow file.
** Checking catalog file.
** Checking multi-linked files.
** Checking catalog hierarchy.
** Checking extended attributes file.
** Checking volume bitmap.
** Checking volume information.
** The volume WDHD appears to be OK.
```

执行以下命令重新加载硬盘：

```Shell
$ sudo mount -t hfsplus -o remount,force,rw /media/WDHD
```

或者卸载后执行以下命令加载硬盘：

```Shell
$ sudo umount /media/WDHD/
$ sudo mount -t hfsplus -o force,rw,uid=pifan,gid=ubuntu /dev/sda3 /media/WDHD
```

重新执行 `mkdir /media/WDHD/test` 创建文件夹成功。

### auto mount

编辑文件 `sudo vim /etc/fstab`，其格式条目如下：

```Shell
# <file system> <mount point> <file system type> <options> <dump> <pass>
```

在其中加入启动加载项 `UUID 指定目录 硬盘文件系统格式 defaults,nofail 0 0`：

```Shell
# 执行 id 命令可查看当前用户的 uid/gid
UUID=8be03e5b-ebbe-4695-a698-f0c0b5cc9f39 /media/WDHD hfsplus force,rw,uid=1000,gid=1000 0 0
```

重启加载后，挂载点还是提示 Read-only！参考上一步，remount 或者 umount 后重新 mount 挂载。

=== "参考配置 1"

    [ubuntu - How to Mount HFS+ drive as read-write on startup](https://unix.stackexchange.com/questions/639476/how-to-mount-hfs-drive-as-read-write-on-startup)

    ```Shell
    /dev/disk/by-id/usb-Seagate_Expansion+_Desk_NA8B0LGL-0:0-part2 /media/media/4tb auto nosuid,nodev,nofail,x-gvfs-show,force,rw 0 0
    ```

=== "参考配置 2"

    [raspbian - Adding hfsplus file system to fstab](https://raspberrypi.stackexchange.com/questions/29087/adding-hfsplus-file-system-to-fstab)

    ```Shell
    UUID=12345 /media/USBDrive/ hfsplus force,rw
    ```

=== "参考配置 3"

    [SOLVED - Mounting hfs partition at boot](https://ubuntuforums.org/showthread.php?t=1485096)

    ```Shell
    /dev/sda3 /media/sda3 hfsplus defaults 0 0
    ```

## config samba for WDHD

### install samba

samba - Server to provide AD and SMB/CIFS services to clients

执行以下命令安装 samba：

```Shell
$ sudo apt install samba -y
$ sudo apt install samba-vfs-modules -y
```

1. `samba -V`: 查看软件版本；
2. `samba --help`：查看帮助（usage）；
3. `man samba`：查看帮助手册（manual）；

```Shell
$ samba -V
Version 4.15.13-Ubuntu
```

### config samba

Samba配置文件通常在 /etc/samba/ 路径下：

```Shell
$ ls -l /etc/samba/
total 20
-rw-r--r-- 1 root root    8 Jan  5 21:23 gdbcommands
-rw-r--r-- 1 root root 8950 Apr  7 05:00 smb.conf
drwxr-xr-x 2 root root 4096 Jan  5 21:23 tls
```

编辑 Samba 配置文件：

```Shell
$ sudo vim /etc/samba/smb.conf
```

在配置文件底部添加如下配置（注意请移除行尾注释）：

```Shell
[WDHD]
    # 共享描述
    comment = WD - Hard Disk
    # 共享目录（mount point）
    path = /media/WDHD
    # sudo smbpasswd -a pifan 创建共享用户密码
    valid users = pifan
    # 可读写
    browseable = yes
    read only = no
    writeable = yes
    # 不允许 guest 账户访问
    public = no
    guest ok = no
    # 客户端上传文件的默认权限
    create mask = 0777
    # 客户端创建目录的默认权限
    directory mask = 0777
```

### smbpasswd

配置完毕后执行 `sudo smbpasswd -a pifan` 来设置用户名密码。

!!! note "关于 Samba 账户"

    Samba 需要 Linux 账户才能使用，可以使用 已有账户 或 创建新用户。虽然用户名可以和 Linux 系统共享，但 Samba 使用的是单独的密码管理。

设置完毕后重启 Samba 服务：`sudo samba restart` 或 `sudo systemctl restart smbd`。

执行 `systemctl status smbd`（或 smbd.service）可查看 samba 服务状态。

### test samba

局域网 macOS 中打开 Finder，选择 菜单栏–前往–连接服务器（或者直接 Command + K），在弹出的窗口中输入 `smb://树莓派的IP地址` 后选择 「连接–输入设置」 的账户和密码后就能访问了。

```Shell
smb://192.168.0.202/
smb://rpi4b-ubuntu.local/
smb://rpi4b-ubuntu.local/WDHD
```

## config samba for WDTM

WD 硬盘的 sda3 分区是普通分区，挂载后局域网通过 smb 协议访问可直接读写。

sda2 分区之前为 macOS 备份分区，将该分区挂载为 `/media/WDTM`：

```Shell
# 1. 创建挂载点目录
$ sudo mkdir /media/WDTM

$ ls -l /media/
total 0
drwxrwxr-x 1 pifan ubuntu 24 Apr  7 04:23 WDHD
drwxrwxr-x 1 root root 21 Apr  7 10:46 WDTM

# 2. 修改挂载点目录的所有人为当前用户（组）：
$ sudo chown pifan:ubuntu /media/WDTM

$ ls -l /media/
total 0
drwxrwxr-x 1 pifan ubuntu 24 Apr  7 04:23 WDHD
drwxrwxr-x 1 pifan ubuntu 21 Apr  7 10:46 WDTM

# 3. 挂载外接硬盘的 sda2 分区
$ sudo mount -t hfsplus -o force,rw,uid=pifan,gid=ubuntu /dev/sda2 /media/WDTM
```

挂载成功后，查看挂载点及其目录内容：

```Shell
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           781M  5.2M  776M   1% /run
/dev/mmcblk0p2   59G   14G   42G  26% /
tmpfs           3.9G     0  3.9G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/mmcblk0p1  253M  138M  115M  55% /boot/firmware
tmpfs           781M  4.0K  781M   1% /run/user/1000
/dev/sda3       466G  204G  263G  44% /media/WDHD
/dev/sda2       1.4T  1.3T  135G  91% /media/WDTM

$ ls -l /media/WDTM
total 288
drwxr-xr-x  1 faner  staff   16384 Mar 16 10:38 Backups.backupdb
dr-xr-xr-x  1 faner  staff   16384 Sep  9  2017 _HF2VN~W
-rwxr-xr-x  1 faner  staff  111620 Feb 21  2017 tmbootpicker.efi
```

再为 sda2 分区挂载点 /media/WDTM 配置 samba 共享服务，供局域网内的 macOS 无线备份。

在配置文件 /etc/samba/smb.conf 的全局配置段（[global]）下增加如下设置，以禁用 SMB1 协议和支持 macOS 系统的拓展属性：

> Apple extensions ("AAPL") run under SMB2/3 protocol, make that the minimum (probably shouldn't be running SMB1 anyway...)

```Shell
[global]
    # 最小支持为 SMB2
    min protocol = SMB2
    # Apple 扩展需要支持扩展属性(xattr)
    ea support = yes
    # smb encrypt = required
```

在配置文件末尾添加 WDTM 配置：

```Shell
[WDTM]
    # 共享描述
    comment = WD - Time Machine
    # 共享目录（mount point）
    path = /media/WDTM
    # 可读写
    browseable = yes
    read only = no
    writeable = yes
    # 不允许 guest 账户访问
    public = no
    guest ok = no
    # valid users = pifan
    # create mask = 0700
    # vfs objects = fruit streams_xattr
    vfs objects = catia fruit streams_xattr
    fruit:aapl = yes
    fruit:time machine = yes
    fruit:metadata = stream
    fruit:model = MacSamba
    # 文件清理的一些配置
    fruit:veto_appledouble = no
    fruit:nfs_aces = no
    fruit:posix_rename = yes
    fruit:zero_file_id = yes
    fruit:wipe_intentionally_left_blank_rfork = yes
    fruit:delete_empty_adfiles = yes
```

设置完毕后重启 Samba 服务：`sudo systemctl restart smbd`。
执行 `systemctl status smbd` 可查看 samba 服务状态。

局域网 macOS 中打开 Finder，Command + K 输入 `smb://rpi4b-ubuntu.local/WDTM`，按照提示输入账户和密码就能访问了。

### set as macOS Backup Disk

系统设置中打开时间机器（Settings - General - Time Machine），点击 `Add Backup Disk...` 按钮：

![Add_Backup_Disk](../images/1-tm-Add_Backup_Disk.png)

点击弹出的 `WDTM on RPI4B-UBUNTU.local`：

![select-WDTM](../images/2-tm-select-WDTM.png)

点击加密（Encrypt Backup）开关关闭加密，Disk Usage Limit 默认最大：

![config-WDTM](../images/3-tm-config-WDTM.png)

确认点击 Done 后，Time Machine 面板出现新添加的备份网盘 WDTM - RPI4B-UBUNTU.local：

![TimeMachine-Panel](../images/4-tm-TimeMachine-Panel.png)

这样，随时随地进行局域网无线备份，再也不用专门为了备份而插拔硬盘。

## refs

[Configure Samba to Work Better with Mac OS X](https://wiki.samba.org/index.php/Configure_Samba_to_Work_Better_with_Mac_OS_X)
[How to Mount Windows Share on Linux using CIFS](https://linuxize.com/post/how-to-mount-cifs-windows-share-on-linux/)

[树莓派挂载移动硬盘 | Notes](https://monsoir.github.io/Notes/RaspberryPie/raspberry-extend-storage.html)
[树莓派搭建低配版文件存储及家庭影音库 - 少数派](https://sspai.com/post/69050)
[教女朋友一样教你用树莓派和移动硬盘搭NAS - 知乎](https://zhuanlan.zhihu.com/p/456124824)

[Types of disks you can use with Time Machine on Mac](https://support.apple.com/en-hk/guide/mac-help/mh15139/mac)
[Samba and macOS Time Machine](https://www.jpatrickfulton.dev/blog/2023-06-23-samba-and-timemachine/)
[利用树莓派打造时间机器 - 少数派](https://sspai.com/post/69197)

[局域网内使用 Samba 搭建 macOS 时间机器的远程备份 - huoyanCC](https://www.cnblogs.com/huoyanCC/p/17281882.html)
[局域网内部署 SMB 服务器实现 macOS Time Machine 自动备份](https://huangxt.cn/manual/lan-macos-tmachine/)
[Linux使用SMB给macOS做无线Time Machine备份 - 知乎](https://zhuanlan.zhihu.com/p/628939584)
