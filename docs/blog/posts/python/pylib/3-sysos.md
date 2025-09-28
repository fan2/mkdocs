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

[os — Miscellaneous operating system interfaces](https://docs.python.org/3/library/os.html)

This module provides a portable way of using operating system dependent functionality. If you just want to read or write a file see [open()](https://docs.python.org/3/library/functions.html#open), if you want to manipulate paths, see the [os.path](https://docs.python.org/3/library/os.path.html) module, and if you want to read all the lines in all the files on the command line see the [fileinput](https://docs.python.org/3/library/fileinput.html) module. For creating temporary files and directories see the [tempfile](https://docs.python.org/3/library/tempfile.html) module, and for high-level file and directory handling see the [shutil](https://docs.python.org/3/library/shutil.html) module.

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

# 获取当前目录
>>> os.curdir
'.'
>>> os.getcwd()
'/Users/faner'
```

### os.path

[os.path — Common pathname manipulations](https://docs.python.org/3/library/os.path.html): This module implements some useful functions on pathnames. To read or write files see [open()](https://docs.python.org/3/library/functions.html#open), and for accessing the filesystem see the [os](https://docs.python.org/3/library/os.html) module.

Source code: `Lib/posixpath.py` (for POSIX), `Lib/ntpath.py` (for Windows NT), and `Lib/macpath.py` (for Macintosh)

> The [pathlib](https://docs.python.org/3/library/pathlib.html) module offers *high-level* path objects.

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

- os.path.dirname(path): Return the directory name of pathname path. This is the *first* element of the pair returned by passing path to the function `split()`.
- os.path.basename(path): Return the base name of pathname path. This is the *second* element of the pair returned by passing path to the function `split()`.

以下代码片段测试 `split` 系列函数（split/splitext）分解文件路径：

```Python
# filepath="/home/user/dir/subdir/"
# filepath="~/dir/subdir/"
# filepath="/home/user/dir/filename"
# filepath="~/dir/filename"
# filepath="/home/user/dir/subdir/filename.ext"
filepath="~/dir/subdir/filename.ext"

print(f'os.path.split = {os.path.split(filepath)}')
print(f'os.path.dirname = {os.path.dirname(filepath)}')
print(f'os.path.basename = {os.path.basename(filepath)}')
print(f'os.path.splitdrive = {os.path.splitdrive(filepath)}')
print(f'os.path.splitext = {os.path.splitext(filepath)}')
```

可以通过文件路径字符串是否包含后缀来简单判断文件类型，也可使用 `os.path` 或 `pathlib.Path` 提取文件后缀再判断文件类型：

- [pathlib — Object-oriented filesystem paths](https://docs.python.org/3/library/pathlib.html#module-pathlib)

```Python
import os
# import pathlib

filepath='/opt/homebrew/CHANGELOG.md'

# 通过文件路径字符串判断文件类型
if '.md' in filepath:
    print('doctype = Markdown By John Gruber')
elif filepath.endswith('.xlsx'):
    print('doctype = OOXML: Excel Workbook')

# 通过文件后缀(ext/suffix)判断文件类型
ext=os.path.splitext(filepath)[1] # pathlib.Path(filepath).suffix
if ext == '.md':
    print("MIME=text/markdown")
elif ext == '.xlsx':
    print("MIME=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
```

#### join

将多个部分以 `os.sep` 拼接相连。

```
os.path.join(path, *paths)
    Join one or more path components intelligently. The return value is the concatenation of path and any members of *paths with exactly one directory separator (os.sep) following each non-empty part except the last, meaning that the result will only end in a separator if the last part is empty. If a component is an absolute path, all previous components are thrown away and joining continues from the absolute path component.
```

[Build the full path filename in Python](https://stackoverflow.com/questions/7132861/build-the-full-path-filename-in-python)  
[Python os.path.join() on a list](https://stackoverflow.com/questions/14826888/python-os-path-join-on-a-list)  
[Python os.path.join on Windows](https://stackoverflow.com/questions/2422798/python-os-path-join-on-windows)  

### os.walk

假设我们想遍历当前目录（`.`）下所有的 Excel Workbook 文件（后缀为 .xlsx），该如何实现呢？

[How to iterate over files in directory using Python?](https://www.geeksforgeeks.org/how-to-iterate-over-files-in-directory-using-python/)
[Python Loop through Folders and Files in Directory](https://www.geeksforgeeks.org/python-loop-through-folders-and-files-in-directory/)

[Using os.walk() to recursively traverse directories in Python](https://stackoverflow.com/questions/16953842/using-os-walk-to-recursively-traverse-directories-in-python)
[How to Recursively Traverse Files and Directories in Python](https://medium.com/@sabahat-khan/how-to-recursively-traverse-files-and-directories-in-python-6020155713fa)

`os.listdir` 和 `os.scandir` 以及 `pathlib.Path.iterdir` 均只支持扫描当前目录，不支持递归扫描子目录，相当于 `ls -1` 和 `tree -L 1`。

1. `os.listdir(path='.')` 返回 list(str)。
2. `os.scandir(path='.')` 返回 iterator of [os.DirEntry](https://docs.python.org/3/library/os.html#os.DirEntry) objects。

如果想实现 `ls -1R` 和 `tree` (`-a` 选项将显示 .DS_Store 这样的隐藏文件) 那样的递归遍历目录效果，则可使用 `os.walk` 方法。

> os.walk(top, topdown=True, onerror=None, followlinks=False)

>> Generate the file names in a directory tree by walking the tree either top-down or bottom-up. For each directory in the tree rooted at directory top (including top itself), it yields a 3-tuple (`dirpath`, `dirnames`, `filenames`).

```Python
import os
import pathlib

def test_listdir(dir: str = '.'):
    for item in os.listdir(dir):
        print(item)

def test_scandir(dir: str = '.'):
    for entry in os.scandir(dir):
        print(entry.path)

def test_iterdir(dir: str = os.curdir):
    for item in pathlib.Path(dir).iterdir():
        print(item)

# 递归遍历各级目录下的文件夹和文件
def test_walkdir(dir: str = '.'):
    for dirpath, folders, files in os.walk(dir):
        print(f"{dirpath}: ")
        print(f"\t{folders}")
        print(f"\t{files}")

# 递归遍历各级目录下的Excel Workbook文件
def test_traverse(dir: str = '.'):
    for dirpath, _, files in os.walk(dir):
        print(f"{dirpath}: {files}")
        for file in files:
            if file.endswith('.xlsx'):
                print(f"\t{os.path.join(dirpath, file)}")

test_scandir()
test_walkdir()
```

`pathlib.Path(dir).walk` 效果等效于 `os.walk(dir)`。

> Path.walk(top_down=True, on_error=None, follow_symlinks=False)

>> Generate the file names in a directory tree by walking the tree either top-down or bottom-up.

>> For each directory in the directory tree rooted at self (including self but excluding `'.'` and `'..'`), the method yields a 3-tuple of `(dirpath, dirnames, filenames)`.

>> `dirpath` is a Path to the directory currently being walked, `dirnames` is a list of strings for the names of subdirectories in *dirpath* (excluding '.' and '..'), and `filenames` is a list of strings for the names of the non-directory files in *dirpath*. To get a full path (which begins with self) to a file or directory in dirpath, do `dirpath / name`. Whether or not the lists are sorted is file system-dependent.

## glob

可以使用 [glob](https://docs.python.org/3/library/glob.html) 模块来实现通配过滤（wildcards）：

> The glob module finds all the pathnames matching a specified pattern according to the rules used by the Unix shell, although results are returned in arbitrary order.

```Python
import glob
import pathlib
import pprint

# 默认recursive=False，遍历当前目录下的 items
def test_glob_ls(dir: str = '.'):
    for level1_item in glob.glob(f'{dir}/*'): # same as **
        print(level1_item)

# return list, Memory-consuming
def test_glob_list(dir: str = '.'):
    for tree_item in glob.glob(f'{dir}/**', recursive=True):
        print(tree_item)

# return iterator, Memory-efficient
def test_glob_iter(dir: str = '.'):
    for tree_item in glob.iglob(f'{dir}/**', recursive=True):
        print(tree_item)

# glob match *.xlsx to filter Excel Workbook
def test_glob_excel_1(dir: str = '.'):
    for excel in glob.iglob(f'{dir}/**/*.xlsx', recursive=True):
        print(excel)

test_glob_iter()
test_glob_excel_1()
```

也可使用 `pathlib.Path.glob` 方法等效实现。

> Path.glob(pattern, *, case_sensitive=None, recurse_symlinks=False)

>> Glob the given relative pattern in the directory represented by this path, yielding all matching files (of any kind):

以下 test_glob_excel_2() 为 test_glob_excel_1() 的等效实现，使用 `Path.glob` 或 `Path.rglob`。

```Python
import pprint
import pathlib

# equiv impl with pathlib.Path(dir).glob
def test_glob_excel_2(dir: str = '.'):
    p = pathlib.Path(dir)
    # 等效于 p.rglob('*.xlsx')，返回 PosixPath
    pprint.pp(list(p.glob('**/*.xlsx')))
    # 将 PosixPath 强转为 str 对象类型
    # pprint.pp([str(p) for p in list(p.glob('**/*.xlsx'))])

test_glob_excel_2()
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
