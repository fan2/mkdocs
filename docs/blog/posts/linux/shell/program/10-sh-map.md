---
title: Linux Shell Program - map
authors:
  - xman
date:
    created: 2019-11-06T10:10:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之字典常用操作。

<!-- more -->

## linux

raspi Ubuntu Desktop 21.10 上自带的 bash shell 版本是 5.1.8：

```Shell
rpi4b-ubuntu% bash --version
GNU bash, version 5.1.8(1)-release (aarch64-unknown-linux-gnu)
Copyright (C) 2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

[The usage of Linux shell map](https://developpaper.com/the-usage-of-linux-shell-map/)  
[Linux Shell：Map的用法](https://www.cnblogs.com/yy3b2007com/p/11267237.html)  


## macOS

[Mac下shell命令支持map](https://www.zengxi.net/2020/01/mac-shell-support-map/)

macOS 自带的bash是3.x版本的：

```Shell
$ bash --version
GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin20)
Copyright (C) 2007 Free Software Foundation, Inc.
```

shell中的 declare 命令不支持 `-A` 这个参数，会报下面的错误：

```Shell
declare: -A: invalid option
declare: usage: declare [-afFirtx] [-p] [name[=value] ...]
```

可考虑通过 brew 安装最新版本的bash

```Shell
brew install bash
```

然后，sh脚本文件开头的 Shebang 注意从 `#!/bin/bash` 替换成 `#!/usr/local/bin/bash`，否则还是用旧版本的bash来执行。

[Mac环境下shell脚本中的map](https://www.jianshu.com/p/a55480b793b0)

macOS 下执行 sh 脚本，declare -A 报错不支持该选项：

```Shell
bash-3.2$ sh cmd.sh
d.sh: line 2: declare: -A: invalid option
declare: usage: declare [-afFirtx] [-p] [name[=value] ...]
```

macOS 的默认 Bash 还是3.x版本，不支持map这种数据结构。

所以有两种解决方案：

1. 升级bash到 4.x 以上版本；  
2. 用其他方式：比如 if elif 去到达相同的结果；  
