---
title: python包管理器--pip
authors:
  - xman
date:
    created: 2019-12-03T08:00:00
categories:
    - python
tags:
    - pip
comments: true
---

Python Packaging User Guide: Packaging Tool & Installation Tool.

<!-- more -->

[PyPA](https://pypa.io/) » [Python Packaging User Guide](https://packaging.python.org/) » [Guides](https://packaging.python.org/guides/) » [Tool recommendations](https://packaging.python.org/guides/tool-recommendations/)

- Installation Tool Recommendations  
	- Use **pip** to install Python [packages](https://packaging.python.org/glossary/#term-distribution-package) from [PyPI](https://packaging.python.org/glossary/#term-python-package-index-pypi).  
	- Use [**virtualenv**](https://packaging.python.org/key_projects/#virtualenv), or [venv](https://docs.python.org/3/library/venv.html) to isolate application specific dependencies from a shared Python installation.  
- Packaging Tool Recommendations  
	- Use [**setuptools**](https://packaging.python.org/key_projects/#setuptools) to define projects and create [Source Distributions](https://packaging.python.org/glossary/#term-source-distribution-or-sdist).  
	- Use the `bdist_wheel` [setuptools](https://packaging.python.org/key_projects/#setuptools) extension available from the [wheel project](https://packaging.python.org/key_projects/#wheel) to create [wheels](https://packaging.python.org/glossary/#term-wheel). This is especially beneficial, if your project contains binary extensions.  

## Packaging Tool

### setuptools

[Package Index](https://pypi.python.org/pypi) > [setuptools](https://pypi.python.org/pypi/setuptools)

Easily download, build, install, upgrade, and uninstall Python packages

Github Page: [pypa](https://github.com/pypa) / [setuptools](https://github.com/pypa/setuptools)

[setuptools](https://packaging.python.org/key_projects/#setuptools) (which includes `easy_install`) is a collection of enhancements to the Python distutils that allow you to more easily build and distribute Python distributions, especially ones that have dependencies on other packages.

macOS 下使用 brew 安装 python3 时，默认已安装 pip3 和 setuptools。

```shell
faner@FAN-MB0:~|⇒  pip3 list
DEPRECATION: The default format will switch to columns in the future. You can use --format=(legacy|columns) (or define a format=(legacy|columns) in your pip.conf under the [list] section) to disable this warning.
pip (9.0.1)
setuptools (36.5.0)
wheel (0.30.0)
```

> [How can I get a list of locally installed Python modules?](https://stackoverflow.com/questions/739993/how-can-i-get-a-list-of-locally-installed-python-modules)  

可通过 `pip3 show setuptools` 命令查看已安装的 setuptools 包信息。

```shell
faner@FAN-MB0:~|⇒  pip3 show setuptools
Name: setuptools
Version: 36.5.0
Summary: Easily download, build, install, upgrade, and uninstall Python packages
Home-page: https://github.com/pypa/setuptools
Author: Python Packaging Authority
Author-email: distutils-sig@python.org
License: UNKNOWN
Location: /usr/local/lib/python3.6/site-packages
Requires:
```

如果想查看的包未安装，会提示 not found：

```Shell
$ pip3 show ipykernel
WARNING: Package(s) not found: ipykernel
```

### Wheel

[Docs](https://wheel.readthedocs.io/en/latest/#)  » [Wheel](https://wheel.readthedocs.io/en/latest/)

A built-package format for Python.  
A **wheel** is a ZIP-format archive with a specially formatted filename and the `.whl` extension.  

macOS 下使用 brew 安装 python3 时，默认已安装 pip3 和 wheel3。

```shell
faner@FAN-MB0:~|⇒  wheel3 -V
usage: wheel3 [-h]
              {keygen,sign,unsign,verify,unpack,install,install-scripts,convert,version,help}
              ...
wheel3: error: unrecognized arguments: -V
```

可通过 `pip3 show wheel` 命令查看 wheel 包信息。

```shell
faner@FAN-MB0:~|⇒  pip3 show wheel     
Name: wheel
Version: 0.30.0
Summary: A built-package format for Python.
Home-page: https://github.com/pypa/wheel
Author: Alex Grönholm
Author-email: alex.gronholm@nextday.fi
License: MIT
Location: /usr/local/lib/python3.6/site-packages
Requires: 
```

## Installation Tool

Python有两个著名的包管理工具 `easy_install.py` 和 `pip`。

在 Python2.7 的安装包中，`easy_install.py` 是默认安装的，而 `pip` 需要我们手动安装。  
在 python 2.7.9+ 及 python 3.4+ 的安装包中，默认已经自带 `pip` 包管理器。  

### [easy_install](https://pypi.python.org/pypi/easy_install)

[EasyInstall](https://wiki.python.org/moin/EasyInstall) (easy_install) gives you a quick and painless way to install packages remotely by connecting to the cheeseshop or even other websites via HTTP. It is somewhat analogous to the CPAN and PEAR tools for Perl and PHP, respectively.

[setuptools 36.6.0 documentation](http://setuptools.readthedocs.io/en/latest/index.html) » [Easy Install](http://setuptools.readthedocs.io/en/latest/easy_install.html#id8)  

Easy Install is a python module (`easy_install`) bundled with `setuptools` that lets you automatically download, build, install, and manage Python packages.

在 macOS/raspbian 终端输入 `easy_install` 再按下 tab 可查看所有版本的 `easy_install`；

- 输入 `easy_install --version` 命令可查看 Python 2.7 对应的 easy_install 的版本号；  
- 输入 `easy_install-3.6 --version`（`easy_install3 --version`）可查看 Python 3.* 对应的 easy_install 的版本号。  

```shell
faner@FAN-MB0:~|⇒  easy_install
easy_install      easy_install-2.6  easy_install-2.7  easy_install-3.6

faner@FAN-MB0:~|⇒  easy_install --version
setuptools 18.5 from /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python (Python 2.7)

faner@FAN-MB0:~|⇒  easy_install-3.6 --version
setuptools 36.5.0 from /usr/local/lib/python3.6/site-packages (Python 3.6)
```

```shell
pi@raspberrypi:~ $ easy_install
easy_install   easy_install3

pi@raspberrypi:~ $ easy_install --version
setuptools 33.1.1 from /usr/lib/python2.7/dist-packages (Python 2.7)
pi@raspberrypi:~ $ easy_install3 --version
setuptools 33.1.1 from /usr/lib/python3/dist-packages (Python 3.5)
```

### [pip](https://pypi.python.org/pypi/pip)

Github Page: [pypa](https://github.com/pypa) / [pip](https://github.com/pypa/pip)  

The [PyPA recommended](https://packaging.python.org/en/latest/current/) tool for installing Python packages.  
pip works on Unix/Linux, macOS, and Windows.  

[Pip](https://wiki.python.org/moin/CheeseShopTutorial) is a modern, general purpose installation tool for python packages. Most often it is useful to install it in your system python.

[pip](https://zh.wikipedia.org/wiki/Pip_(%E8%BB%9F%E4%BB%B6%E5%8C%85%E7%AE%A1%E7%90%86%E7%B3%BB%E7%B5%B1)) 是一个以 Python 计算机程序语言写成的软件包管理系统，他可以安装和管理软件包。  
另外，不少的软件包也可以在 PyPI 中找到。  

#### [Installation](https://pip.pypa.io/en/stable/installing.html)

To install pip, securely download [get-pip.py](https://bootstrap.pypa.io/get-pip.py)

Then run the following:

```shell
python get-pip.py
```

> [Installing pip/setuptools/wheel with Linux Package Managers](https://packaging.python.org/guides/installing-using-linux-tools/#installing-pip-setuptools-wheel-with-linux-package-managers)  
> [怎么在windows下安装pip?](https://taizilongxu.gitbooks.io/stackoverflow-about-python/content/8/README.html)  
> [windows下面安装Python和pip终极教程](http://www.cnblogs.com/yuanzm/p/4089856.html)  

#### [pip2 & pip3](https://www.zhihu.com/question/21653286)

 `pip` comes with the official Python 2.7 and 3.4+ packages from python.org, and a `pip` bootstrap is included by **default** if you build from source.  
`pip` is already installed if you're using Python 2 >=2.7.9 or Python 3 >=3.4 binaries downloaded from [python.org](https://www.python.org/), but you'll need to [upgrade pip](https://pip.pypa.io/en/stable/installing/#upgrading-pip).  

输入 pip 默认运行 pip 2，输入 pip3 则指定运行版本3的 pip。  

```shell
# macOS

faner@FAN-MB0:~|⇒  pip3 -V
pip 9.0.1 from /usr/local/lib/python3.6/site-packages (python 3.6)
faner@FAN-MB0:~|⇒  which pip3
/usr/local/bin/pip3
```

```shell
# raspbian

pi@raspberrypi:~ $ pip -V
pip 9.0.1 from /usr/lib/python2.7/dist-packages (python 2.7)
pi@raspberrypi:~ $ which pip
/usr/bin/pip
pi@raspberrypi:~ $ whereis pip
pip: /usr/bin/pip /etc/pip.conf /usr/share/man/man1/pip.1.gz

pi@raspberrypi:~ $ pip3 -V
pip 9.0.1 from /usr/lib/python3/dist-packages (python 3.5)
pi@raspberrypi:~ $ which pip3
/usr/bin/pip3
pi@raspberrypi:~ $ whereis pip3
pip3: /usr/bin/pip3 /usr/share/man/man1/pip3.1.gz
```

#### help

官方文档：[Docs](https://pip.pypa.io/en/stable/#) » [pip](https://pip.pypa.io/en/stable/)  

pip 和 pip3 带 `-h`(`--help`) 选项可查看帮助（Show help）。  

pip 的主要命令（Commands）如下：

```shell
pi@raspberrypi:~ $ pip -h

Usage:   
  pip <command> [options]

Commands:
  install                     Install packages.
  download                    Download packages.
  uninstall                   Uninstall packages.
  freeze                      Output installed packages in requirements format.
  list                        List installed packages.
  show                        Show information about installed packages.
  check                       Verify installed packages have compatible dependencies.
  search                      Search PyPI for packages.
  wheel                       Build wheels from your requirements.
  hash                        Compute hashes of package archives.
  completion                  A helper command used for command completion.
  help                        Show help for commands.

```

在终端输入 `pip3 help install` 可查看 pip install 命令的帮助说明。  

在 raspbian 下还可以输入 `man pip` / `man pip3` 查看 pip(3) 的 Manual Page：

- man pip：`/usr/share/man/man1/pip.1.gz`  
- man pip3：`/usr/share/man/man1/pip3.1.gz`  

> [Python的包管理工具pip的安装与使用](http://blog.csdn.net/liuchunming033/article/details/39578019)  
> [pip安装使用详解](http://www.ttlsa.com/python/how-to-install-and-use-pip-ttlsa/) / [python pip常用命令](http://www.cnblogs.com/xueweihan/p/4981704.html)  
> [常用的python模块及安装方法](http://blog.chinaunix.net/uid-24567872-id-3926986.html)  
> [不得不知的几个 python 开源项目](http://lukejin.iteye.com/blog/608230)  

#### python -m pip

另外也可以 `python3 -m pip` 执行指定 Python 配套的 pip。

> `-m mod` : run library module as a script

```Shell
# macOS
python3 -m pip install matplotlib

# Windows (may require elevation)
python -m pip install matplotlib

# Linux (Debian)
apt-get install python3-tk
python3 -m pip install matplotlib
```

假设我们用 brew 安装了多个 python，或者之前用过的 python 一直残留着没有移除。

```Shell
$ ls -1 /usr/local/Cellar/ | grep 'python@'
python@3.10
python@3.11
python@3.12
python@3.8
python@3.9

$ find /usr/local/Cellar/ -type d -iname "python@*"
/usr/local/Cellar//python@3.12
/usr/local/Cellar//python@3.10
/usr/local/Cellar//python@3.11
/usr/local/Cellar//python@3.8
/usr/local/Cellar//python@3.9
```

我们在之前的某个版本安装了一些工具包，后来忘了。那么怎么查找到当时用的那个版本呢？

在命令行执行 `python3 -m pip -V` 可以看到指定 python 版本的配套 pip 版本和 site-packages 位置。

- 也可打印 `sys.path` 看看 modules 的搜索路径。

```Shell
# macOS Xcode command line tool 安装的 python3 的 site-packages 位置
$ python -m pip -V
pip 21.2.4 from /Applications/Xcode.app/Contents/Developer/Library/Frameworks/Python3.framework/Versions/3.9/lib/python3.9/site-packages/pip (python 3.9)

# macOS brew 安装的 python3 的 site-packages 位置
$ python3 -m pip -V
pip 24.0 from /usr/local/lib/python3.12/site-packages/pip (python 3.12)

# conda base 中 site-packages 的位置
$ pip -V
pip 23.3.1 from /usr/local/anaconda3/lib/python3.9/site-packages/pip (python 3.9)
```

可以指定python可执行文件的绝对路径，执行 `python -m pip list` 命令列出已安装的 site-packages。

```Shell
$ /usr/local/Cellar/python@3.8/3.8.18_2/bin/python3.8 -m pip list
$ /usr/local/Cellar/python@3.9/3.9.18_2/bin/python3.9 -m pip list
$ /usr/local/Cellar/python@3.10/3.10.13_2/bin/python3.10 -m pip list
$ /usr/local/Cellar/python@3.11/3.11.7_2/bin/python3.11 -m pip list
```

#### [upgrade pip](https://pip.pypa.io/en/stable/installing/#upgrading-pip)

On Linux or macOS:

```shell
pip install -U pip
```

```shell
pi@raspberrypi:~ $ pip install -U pip
Collecting pip
  Downloading pip-9.0.1-py2.py3-none-any.whl (1.3MB)
    100% |████████████████████████████████| 1.3MB 13kB/s 
Installing collected packages: pip
Successfully installed pip-9.0.1
```

On Windows:

```shell
python -m pip install -U pip
```

---

运行 pip3 命令，提示新版本可供升级：

```shell
faner@MBP-FAN:~|⇒  pip3 list
DEPRECATION: The default format will switch to columns in the future. You can use --format=(legacy|columns) (or define a format=(legacy|columns) in your pip.conf under the [list] section) to disable this warning.
beautifulsoup4 (4.6.0)
cppman (0.4.8)
html5lib (1.0.1)
pip (9.0.1)
setuptools (36.5.0)
six (1.11.0)
webencodings (0.5.1)
wheel (0.30.0)
You are using pip version 9.0.1, however version 9.0.3 is available.
You should consider upgrading via the 'pip install --upgrade pip' command.
```

按照提示运行 `pip install --upgrade pip`（`-U` = `--upgrade`）可升级 pip：

```shell
faner@MBP-FAN:~|⇒  pip3 install -U pip
Collecting pip
  Downloading pip-9.0.3-py2.py3-none-any.whl (1.4MB)
    100% |████████████████████████████████| 1.4MB 989kB/s 
Installing collected packages: pip
  Found existing installation: pip 9.0.1
    Uninstalling pip-9.0.1:
      Successfully uninstalled pip-9.0.1
Successfully installed pip-9.0.3

faner@MBP-FAN:~|⇒  pip3 --version
pip 9.0.3 from /usr/local/lib/python3.6/site-packages (python 3.6)
```

> 一般来说，更新 python(3) 时，自动会更新内置的 pip。

### pip over easy_install

[Installing Python Modules](https://docs.python.org/3/installing/index.html): pip is the **preferred** installer program. Starting with `Python 3.4`, it is included by ***default*** with the Python binary installers.

#### reason

> [pip vs easy_install](https://packaging.python.org/discussions/pip-vs-easy-install/)  
> [Why use pip over easy_install? ](https://stackoverflow.com/questions/3220404/why-use-pip-over-easy-install)  
> [Pip Compared To easy_install](https://pip.readthedocs.io/en/1.1/other-tools.html#pip-compared-to-easy-install)  

1. pip provides an `uninstall` command  
2. if an installation fails in the middle, pip will leave you in a <u>clean</u> state.  
3. **Requirements files** allow you to create a snapshot of all packages that have been installed through `pip`.  

@img ![current-state-of-packaging](https://i.stack.imgur.com/2icn1.jpg)

[Setuptools](http://pythonhosted.org/setuptools/) and easy_install will be replaced by the new hotness—distribute and pip. While pip is still the new hotness, Distribute merged with Setuptools in 2013 with the release of Setuptools v0.7.

@img ![friendly_python_packaging_hotness](https://i.stack.imgur.com/RdBpi.png)

#### UPDATE

`setuptools` has absorbed `distribute` as opposed to the other way around, as some thought. `setuptools` is up-to-date with the latest `distutils` changes and the wheel format.  
Hence, `easy_install` and `pip` are more or less on equal footing now.  

## install/upgrade issues

[pip/python: normal site-packages is not writeable - Stack Overflow](https://stackoverflow.com/questions/59997065/pip-python-normal-site-packages-is-not-writeable)

> Defaulting to user installation because normal site-packages is not writeable

Python 2/3:

```bash
# python -m pip install [package_name]
python3 -m pip install [package_name]
```

Specify the version that you use:

```bash
python3.7 -m pip install [package_name]
```

[How to upgrade all Python packages with pip - Stack Overflow](https://stackoverflow.com/questions/2720014/how-to-upgrade-all-python-packages-with-pip)

macOS issues the following warnings when install or upgrade through pip3:

- error: externally-managed-environment
- hint: See PEP 668 for the detailed specification.

As the caveat suggests, we have two solutions to the problem.

1. use a virtual environment to install and upgrade pip packages, such as [pipx](https://pipx.pypa.io/stable/)
2. passing `--break-system-packages` to install and upgrade commands

### 33667992

https://stackoverflow.com/a/33667992

Do

```bash
$ pip freeze > requirements.txt
```

Open the text file, replace the == with >=, or have sed do it for you:

```bash
$ sed -i 's/==/>=/g' requirements.txt
```

and execute:

```bash
$ pip install -r requirements.txt --upgrade
```

### 3452888

https://stackoverflow.com/a/3452888

There isn't a built-in flag yet. Starting with pip version 22.3, the --outdated and --format=freeze have become mutually exclusive. Use Python, to parse the JSON output:

```bash
pip3 --disable-pip-version-check list --outdated --format=json | python3 -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))" | xargs -n1 pip3 install -U
```

If you are using pip<22.3 you can use:

```bash
pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U
```

### 54209210

https://stackoverflow.com/a/54209210

[achillesrasquinha/pipupgrade](https://github.com/achillesrasquinha/pipupgrade)

Like yarn outdated/upgrade, but for pip. Upgrade all your pip packages and automate your Python Dependency Management.

To upgrade all local packages, you can install [pip-review](https://github.com/jgonggrijp/pip-review).

### 22260015

https://stackoverflow.com/a/22260015

```bash
# https://stackoverflow.com/a/27071962
pip3 install -U `pip3 list --outdated | awk 'NR>2 {print $1}'`

# https://stackoverflow.com/a/3452888
pip3 --disable-pip-version-check list --outdated --format=json | python3 -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))" | xargs -n1 pip3 install -U

# synthetical answer
pip3 list --outdated | awk 'NR>2 {print $1}' | xargs -n1 pip3 install -U
```

> The `-n1` flag for `xargs` prevents stopping everything if updating one package fails.
> xargs -n1 keeps going if an error occurs.

Although not recommended, you can use the brutal solution if you have to.

```bash
pip3 list --outdated | awk 'NR>2 {print $1}' | xargs -n1 pip3 install -U --break-system-packages
```
