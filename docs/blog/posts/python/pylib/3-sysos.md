---
title: python常用模块之sys,os,platform
authors:
  - xman
date:
    created: 2019-12-06T08:20:00
categories:
    - python
tags:
    - sys
    - os
    - platform
comments: true
---

本文简单梳理了 python 中常用模块：sys,os, platform 和 sysconfig。

<!-- more -->

## sys

### doc

```shell
>>> import sys
>>> print(sys.__doc__)
This module provides access to some objects used or maintained by the
interpreter and to functions that interact strongly with the interpreter.

Dynamic objects:

argv -- command line arguments; argv[0] is the script pathname if known
path -- module search path; path[0] is the script directory, else ''
modules -- dictionary of loaded modules

```

- Dynamic objects  
- Static objects  
- Functions  

**argv** 为脚本运行参数列表(str list)。  
`argv[0]` 为脚本名称，从 `argv[1]` 开始为用户参数。  

### test

```shell
>>> import sys

# 平台类型标识
>>> sys.platform
'darwin'

# 版本信息（string格式）
>>> sys.version
'3.6.5 (default, Apr 14 2018, 06:59:43) \n[GCC 4.2.1 Compatible Apple LLVM 9.1.0 (clang-902.0.39.1)]'

>>> print(sys.version)
3.6.5 (default, Apr 14 2018, 06:59:43) 
[GCC 4.2.1 Compatible Apple LLVM 9.1.0 (clang-902.0.39.1)]

# 版本信息（Version information as a named tuple.）
>>> sys.version_info
sys.version_info(major=3, minor=6, micro=5, releaselevel='final', serial=0)
# 获取字符串格式描述
>>> repr(sys.version_info)
"sys.version_info(major=3, minor=6, micro=5, releaselevel='final', serial=0)"
# 获取数据成员属性(Data descriptors)
>>> sys.version_info.major
3
>>> sys.version_info.minor
6
>>> sys.version_info.micro
5
>>> sys.version_info.releaselevel
'final'
>>> sys.version_info.serial
0

# Python 实现信息(python3)
## 返回 types.SimpleNamespace 对象实例
>>> sys.implementation
namespace(_multiarch='darwin', cache_tag='cpython-36', hexversion=50726384, name='cpython', version=sys.version_info(major=3, minor=6, micro=5, releaselevel='final', serial=0))
## 取字典格式
>>> sys.implementation.__dict__
{'name': 'cpython', 'cache_tag': 'cpython-36', 'version': sys.version_info(major=3, minor=6, micro=5, releaselevel='final', serial=0), 'hexversion': 50726384, '_multiarch': 'darwin'}

# 字节序
>>> sys.byteorder
'little'

# python2: sys.long_info
>>> sys.int_info
sys.int_info(bits_per_digit=30, sizeof_digit=4)
>>> sys.int_info.bits_per_digit
30
>>> sys.int_info.sizeof_digit
4

# 线程模型(python3)
>>> sys.thread_info
sys.thread_info(name='pthread', lock='mutex+cond', version=None)

```

## os

### doc

```shell
>>> import os
>>> print(os.__doc__)
OS routines for NT or Posix depending on what system we're on.

This exports:
  - all functions from posix or nt, e.g. unlink, stat, etc.
  - os.path is either posixpath or ntpath
  - os.name is either 'posix' or 'nt'
  - os.curdir is a string representing the current directory (always '.')
  - os.pardir is a string representing the parent directory (always '..')
  - os.sep is the (or a most common) pathname separator ('/' or '\\')
  - os.extsep is the extension separator (always '.')
  - os.altsep is the alternate pathname separator (None or '/')
  - os.pathsep is the component separator used in $PATH etc
  - os.linesep is the line separator in text files ('\r' or '\n' or '\r\n')
  - os.defpath is the default search path for executables
  - os.devnull is the file path of the null device ('/dev/null', etc.)

Programs that import and use 'os' stand a better chance of being
portable between different platforms.  Of course, they must then
only use functions that are defined by all platforms (e.g., unlink
and opendir), and leave all pathname manipulation to os.path
(e.g., split and join).
```

### [os.path](https://docs.python.org/3.7/library/os.path.html)

Source code: `Lib/posixpath.py` (for POSIX), `Lib/ntpath.py` (for Windows NT), and `Lib/macpath.py` (for Macintosh)

macOS Python REPL 中输入 `help(os.path)` 显示  posixpath：

```
Help on module posixpath:

NAME
    posixpath - Common operations on Posix pathnames.
```

[os.path Examples](https://www.dotnetperls.com/path-python)  

[python文件和目录操作方法大全（含实例）](https://www.cnblogs.com/kaid/p/9252084.html)  

#### property

判断给定字符串是否为目录或文件：

```
os.path.isdir(path)
    Return True if path is an existing directory. 
    This follows symbolic links, so both islink() and isdir() can be true for the same path.
os.path.isfile(path)
    Return True if path is an existing regular file. 
    This follows symbolic links, so both islink() and isfile() can be true for the same path.
```

判断给定字符串（目录或文件）是否存在：

```
os.path.exists(path)
    Return True if path refers to an existing path or an open file descriptor. Returns False for broken symbolic links. On some platforms, this function may return False if permission is not granted to execute os.stat() on the requested file, even if the path physically exists.
```

获取指定路径下文件（目录？）的文件大小：

```
os.path.getsize(path)
    Return the size, in bytes, of path. Raise OSError if the file does not exist or is inaccessible.
```

#### split

```
os.path.split(path)
    Split the pathname path into a pair, (head, tail) where tail is the last pathname component and head is everything leading up to that. 
    The tail part will never contain a slash; if path ends in a slash, tail will be empty.
os.path.splitdrive(path)
    Split the pathname path into a pair (drive, tail) where drive is either a mount point or the empty string. 
    On systems which do not use drive specifications, drive will always be the empty string. In all cases, drive + tail will be the same as path.
os.path.splitext(path)
    Split the pathname path into a pair (root, ext) such that root + ext == path, and ext is empty or begins with a period and contains at most one period. Leading periods on the basename are ignored; splitext('.cshrc') returns ('.cshrc', '').
```

[How to split a dos path into its components in Python](https://stackoverflow.com/questions/3167154/how-to-split-a-dos-path-into-its-components-in-python)  
[Splitting a Path into All of Its Parts](https://www.oreilly.com/library/view/python-cookbook/0596001673/ch04s16.html)  
[Python | os.path.splitext() method](https://www.geeksforgeeks.org/python-os-path-splitext-method/)  

#### join

将多个部分以 `os.sep` 拼接相连。

```
os.path.join(path, *paths)
    Join one or more path components intelligently. The return value is the concatenation of path and any members of *paths with exactly one directory separator (os.sep) following each non-empty part except the last, meaning that the result will only end in a separator if the last part is empty. If a component is an absolute path, all previous components are thrown away and joining continues from the absolute path component.
```

[Build the full path filename in Python](https://stackoverflow.com/questions/7132861/build-the-full-path-filename-in-python)  
[Python os.path.join() on a list](https://stackoverflow.com/questions/14826888/python-os-path-join-on-a-list)  
[Python os.path.join on Windows](https://stackoverflow.com/questions/2422798/python-os-path-join-on-windows)  

### test

```shell
>>> import os

>>> os.path
<module 'posixpath' from '/usr/local/Cellar/python/3.6.5/Frameworks/Python.framework/Versions/3.6/lib/python3.6/posixpath.py'>

>>> os.name
'posix'

>>> os.uname()
posix.uname_result(sysname='Darwin', nodename='MBP-FAN', release='17.6.0', version='Darwin Kernel Version 17.6.0: Fri Apr 13 19:57:44 PDT 2018; root:xnu-4570.60.17.0.1~3/RELEASE_X86_64', machine='x86_64')

# 路径分隔符（pathname separator）
>>> os.sep
'/'

# 文件后缀分隔符（extension separator）
>>> os.extsep
'.'

# 环境变量 PATH 分隔符（component separator used in $PATH）
>>> os.pathsep
':'

# 换行符（line separator），nt 下为 '\r\n'
>>> os.linesep
'\n'

```

## platform

### doc

```shell
>>> import platform
>>> print(platform.__doc__)
 This module tries to retrieve as much platform-identifying data as
    possible. It makes this information available via function APIs.

    If called from the command line, it prints the platform
    information concatenated as single string to stdout. The output
    format is useable as part of a filename.
```

### test

```shell
>>> import platform

>>> platform.platform()
'Darwin-17.6.0-x86_64-i386-64bit'

>>> platform.version()
'Darwin Kernel Version 17.6.0: Fri Apr 13 19:57:44 PDT 2018; root:xnu-4570.60.17.0.1~3/RELEASE_X86_64'

>>> platform.uname()
uname_result(system='Darwin', node='MBP-FAN', release='17.6.0', version='Darwin Kernel Version 17.6.0: Fri Apr 13 19:57:44 PDT 2018; root:xnu-4570.60.17.0.1~3/RELEASE_X86_64', machine='x86_64', processor='i386')

# 体系架构
>>> platform.machine()
'x86_64'

# 处理器
>>> platform.processor()
'i386'

# 系统
>>> platform.system()
'Darwin'

>>> platform.python_implementation()
'CPython'

>>> platform.python_version()
'3.6.5'

>>> platform.python_version_tuple()
('3', '6', '5')
```

## sysconfig

### doc

```shell
>>> import sysconfig
>>> print(sysconfig.__doc__)
Access to Python's configuration information.
```

### test

```shell
>>> import sysconfig

>>> sysconfig.get_platform()
'macosx-10.13-x86_64'

>>> sysconfig.get_python_version()
'3.6'
```
