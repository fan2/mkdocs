---
title: Python Package Installer - easy_install & pip
authors:
  - xman
date:
    created: 2019-12-02T12:00:00
categories:
    - python
tags:
    - easy_install
    - pip
comments: true
---

Introduce Python Package Installation Tools.

<!-- more -->

[PyPA](https://pypa.io/) » [Python Packaging User Guide](https://packaging.python.org/) » [Guides](https://packaging.python.org/guides/) » [Tool recommendations](https://packaging.python.org/guides/tool-recommendations/)

- Installation Tool Recommendations  
	- Use **pip** to install Python [packages](https://packaging.python.org/glossary/#term-distribution-package) from [PyPI](https://packaging.python.org/glossary/#term-python-package-index-pypi).  
	- Use [**virtualenv**](https://packaging.python.org/key_projects/#virtualenv), or [venv](https://docs.python.org/3/library/venv.html) to isolate application specific dependencies from a shared Python installation.  
- Packaging Tool Recommendations  
	- Use [**setuptools**](https://packaging.python.org/key_projects/#setuptools) to define projects and create [Source Distributions](https://packaging.python.org/glossary/#term-source-distribution-or-sdist).  
	- Use the `bdist_wheel` [setuptools](https://packaging.python.org/key_projects/#setuptools) extension available from the [wheel project](https://packaging.python.org/key_projects/#wheel) to create [wheels](https://packaging.python.org/glossary/#term-wheel). This is especially beneficial, if your project contains binary extensions.  

Python有两个著名的包管理工具 `easy_install.py` 和 `pip`。

在 Python2.7 的安装包中，`easy_install.py` 是默认安装的，而 `pip` 需要我们手动安装。  
在 python 2.7.9+ 及 python 3.4+ 的安装包中，默认已经自带 `pip` 包管理器。  

## easy_install

[EasyInstall](https://wiki.python.org/moin/EasyInstall) ([easy_install](https://pypi.python.org/pypi/easy_install)) gives you a quick and painless way to install packages remotely by connecting to the cheeseshop or even other websites via HTTP. It is somewhat analogous to the CPAN and PEAR tools for Perl and PHP, respectively.

[setuptools 36.6.0 documentation](http://setuptools.readthedocs.io/en/latest/index.html) » [Easy Install](http://setuptools.readthedocs.io/en/latest/easy_install.html#id8)  

Easy Install is a python module (`easy_install`) bundled with `setuptools` that lets you automatically download, build, install, and manage Python packages.

在 macOS/raspbian 终端输入 `easy_install` 再按下 tab 可查看所有版本的 `easy_install`；

- 输入 `easy_install --version` 命令可查看 Python 2.7 对应的 easy_install 的版本号；  
- 输入 `easy_install-3.6 --version`（`easy_install3 --version`）可查看 Python 3.* 对应的 easy_install 的版本号。  

```bash
faner@FAN-MB0:~|⇒  easy_install
easy_install      easy_install-2.6  easy_install-2.7  easy_install-3.6

faner@FAN-MB0:~|⇒  easy_install --version
setuptools 18.5 from /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python (Python 2.7)

faner@FAN-MB0:~|⇒  easy_install-3.6 --version
setuptools 36.5.0 from /usr/local/lib/python3.6/site-packages (Python 3.6)
```

```bash
pi@raspberrypi:~ $ easy_install
easy_install   easy_install3

pi@raspberrypi:~ $ easy_install --version
setuptools 33.1.1 from /usr/lib/python2.7/dist-packages (Python 2.7)
pi@raspberrypi:~ $ easy_install3 --version
setuptools 33.1.1 from /usr/lib/python3/dist-packages (Python 3.5)
```

## pip

[pip](https://pypi.python.org/pypi/pip)

Github Page: [pypa](https://github.com/pypa) / [pip](https://github.com/pypa/pip)  

The [PyPA recommended](https://packaging.python.org/en/latest/current/) tool for installing Python packages.  
pip works on Unix/Linux, macOS, and Windows.  

[Pip](https://wiki.python.org/moin/CheeseShopTutorial) is a modern, general purpose installation tool for python packages. Most often it is useful to install it in your system python.

[pip](https://zh.wikipedia.org/wiki/Pip_(%E8%BB%9F%E4%BB%B6%E5%8C%85%E7%AE%A1%E7%90%86%E7%B3%BB%E7%B5%B1)) 是一个以 Python 计算机程序语言写成的软件包管理系统，他可以安装和管理软件包。  
另外，不少的软件包也可以在 PyPI 中找到。  

### Installation

[Installation](https://pip.pypa.io/en/stable/installing.html): To install pip, securely download [get-pip.py](https://bootstrap.pypa.io/get-pip.py)

Then run the following:

```bash
python get-pip.py
```

> [Installing pip/setuptools/wheel with Linux Package Managers](https://packaging.python.org/guides/installing-using-linux-tools/#installing-pip-setuptools-wheel-with-linux-package-managers)  
> [怎么在windows下安装pip?](https://taizilongxu.gitbooks.io/stackoverflow-about-python/content/8/README.html)  
> [windows下面安装Python和pip终极教程](http://www.cnblogs.com/yuanzm/p/4089856.html)  

### pip2 & pip3

[pip2 & pip3](https://www.zhihu.com/question/21653286)

 `pip` comes with the official Python 2.7 and 3.4+ packages from python.org, and a `pip` bootstrap is included by **default** if you build from source.  
`pip` is already installed if you're using Python 2 >=2.7.9 or Python 3 >=3.4 binaries downloaded from [python.org](https://www.python.org/), but you'll need to [upgrade pip](https://pip.pypa.io/en/stable/installing/#upgrading-pip).  

输入 pip 默认运行 pip 2，输入 pip3 则指定运行版本3的 pip。  

```bash
# macOS

faner@FAN-MB0:~|⇒  pip3 -V
pip 9.0.1 from /usr/local/lib/python3.6/site-packages (python 3.6)
faner@FAN-MB0:~|⇒  which pip3
/usr/local/bin/pip3
```

```bash
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

## pip over easy_install

[Installing Python Modules](https://docs.python.org/3/installing/index.html): pip is the **preferred** installer program. Starting with `Python 3.4`, it is included by ***default*** with the Python binary installers.

### reason

> [pip vs easy_install](https://packaging.python.org/discussions/pip-vs-easy-install/)  
> [Why use pip over easy_install? ](https://stackoverflow.com/questions/3220404/why-use-pip-over-easy-install)  
> [Pip Compared To easy_install](https://pip.readthedocs.io/en/1.1/other-tools.html#pip-compared-to-easy-install)  

1. pip provides an `uninstall` command  
2. if an installation fails in the middle, pip will leave you in a <u>clean</u> state.  
3. **Requirements files** allow you to create a snapshot of all packages that have been installed through `pip`.  

@img ![current-state-of-packaging](https://i.stack.imgur.com/2icn1.jpg)

[Setuptools](http://pythonhosted.org/setuptools/) and easy_install will be replaced by the new hotness—distribute and pip. While pip is still the new hotness, Distribute merged with Setuptools in 2013 with the release of Setuptools v0.7.

@img ![friendly_python_packaging_hotness](https://i.stack.imgur.com/RdBpi.png)

### UPDATE

`setuptools` has absorbed `distribute` as opposed to the other way around, as some thought. `setuptools` is up-to-date with the latest `distutils` changes and the wheel format.  
Hence, `easy_install` and `pip` are more or less on equal footing now.  
