---
title: python检测安装的版本
authors:
  - xman
date:
    created: 2019-12-06T08:30:00
categories:
    - python
tags:
    - version
comments: true
---

本文简单介绍了如何检测本机安装的 python 版本。

<!-- more -->

假设我们的python项目基于某一版本发行，若客户python运行时低于此版本，则某些功能特性可能不支持。
此时，我们可能需要检测客户是否安装了python，并且版本是否满足最低要求，否则提示用户安装或升级python。

## sh检测是否安装了python

未安装python时，执行 `python -V` 提示命令找不到：

```Shell
$ python -V
zsh: command not found: python
$ echo $?
127
```

已安装python时，执行 `python -V` 正常返回版本：

```Shell
$ python -V
Python 3.9.6
$ echo $?
0
```

以下定义了 shell 函数 check_python_version 用于检测本地是否安装了 python 运行时：

```Shell
check_python_version()
{
    if python -V &>/dev/null; # 不输出执行结果
    then
        python_version=$(python -V) 1>/dev/null # 不输出版本信息
        echo "python installed: $python_version"
        return 0
    else
        echo "python uninstalled!"
        return 1
    fi
}
```

## python检测当前安装版本

通过上文，我们知道，可以通过 platform, sys 和 sysconfig 相关接口检测当前 python 版本。

1. sysconfig.get_python_version() 返回字符串，例如 '3.9'；

```Shell
>>> sysconfig.get_python_version()
'3.9'
```

2. platform.python_version() 返回字符串，或调用 platform.python_version_tuple() 返回字符串元组。

```Shell
>>> platform.python_version()
'3.9.6'
>>> platform.python_version_tuple()
('3', '9', '6')
```

3. sys.version_info 返回 version_info 对象。

```Shell
>>> sys.version_info
sys.version_info(major=3, minor=9, micro=6, releaselevel='final', serial=0)
>>> tuple(sys.version_info)
(3, 9, 6, 'final', 0)
```

## python对比安装版本

[How do I compare version numbers in Python? - Stack Overflow](https://stackoverflow.com/questions/11887762/how-do-i-compare-version-numbers-in-python)

以下用四种方式判断 python 版本是否大于 3.8/3.9.6。

```Python
import platform, sys, sysconfig

def version_str2tuple(vs:str):
    return tuple(map(int, vs.split(".")))

def version_tuple_str2int(vst:tuple):
    return tuple(map(int, vst))

# '3.12'
version_str2tuple(sysconfig.get_python_version()) > (3, 8)

# '3.12.2'
version_str2tuple(platform.python_version()) > (3, 9, 6)

# ('3', '12', '2')
version_tuple_str2int(platform.python_version_tuple()) > (3, 9, 6)

# (3, 12, 2, 'final', 0)
tuple(sys.version_info) > (3, 9, 6) # sys.version_info > (3, 9, 6)
```
