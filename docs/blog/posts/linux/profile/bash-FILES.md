---
title: bash配置文件
authors:
  - xman
date:
    created: 2019-10-24T08:20:00
categories:
    - wiki
    - linux
tags:
    - bash
comments: true
---

macOS、CentOS、raspbian/ubuntu 下的 bash 配置文件（bash FILES）一览。

<!-- more -->

## macOS

```Shell
# man bash on macOS

FILES
       /bin/bash
              The bash executable
       /etc/profile
              The systemwide initialization file, executed for login shells
       ~/.bash_profile
              The personal initialization file, executed for login shells
       ~/.bashrc
              The individual per-interactive-shell startup file
       ~/.bash_logout
              The  individual  login  shell  cleanup file, executed when a login shell
              exits
       ~/.inputrc
              Individual readline initialization file

```

相比 CentOS 少了 `/etc/bash.bash_logout`。

## CentOS

```Shell
# man bash on CentOS

FILES
       /bin/bash
              The bash executable
       /etc/profile
              The systemwide initialization file, executed for login shells
       /etc/bash.bash_logout
              The systemwide login shell cleanup file, executed when a login shell exits
       ~/.bash_profile
              The personal initialization file, executed for login shells
       ~/.bashrc
              The individual per-interactive-shell startup file
       ~/.bash_logout
              The individual login shell cleanup file, executed when a login shell exits
       ~/.inputrc
              Individual readline initialization file

```

相比 raspbian 少了 `/etc/bash.bashrc`。

## raspbian/ubuntu

```Shell
#man bash on ubuntu and raspbian

FILES
       /bin/bash
              The bash executable
       /etc/profile
              The systemwide initialization file, executed for login shells
       /etc/bash.bashrc
              The systemwide per-interactive-shell startup file
       /etc/bash.bash.logout
              The systemwide login shell cleanup file, executed when a login shell exits
       ~/.bash_profile
              The personal initialization file, executed for login shells
       ~/.bashrc
              The individual per-interactive-shell startup file
       ~/.bash_logout
              The individual login shell cleanup file, executed when a login shell exits
       ~/.inputrc
              Individual readline initialization file

```

比较完备，profile、bashrc、logout 均有 systemwide 和 individual 两级配置。

- `~/.bash_profile`: The personal initialization file, executed for **login** shells  
- `~/.bashrc`: The individual per-interactive-shell startup file  

`~/.bash_profile` file (Mac OS X) or `~/.bashrc` file (Linux). 
