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

Python Package Installation Tool - pip.

<!-- more -->

[pip](https://pypi.python.org/pypi/pip)

Github Page: [pypa](https://github.com/pypa) / [pip](https://github.com/pypa/pip)  

The [PyPA recommended](https://packaging.python.org/en/latest/current/) tool for installing Python packages.  
pip works on Unix/Linux, macOS, and Windows.  

[Pip](https://wiki.python.org/moin/CheeseShopTutorial) is a modern, general purpose installation tool for python packages. Most often it is useful to install it in your system python.

[pip](https://zh.wikipedia.org/wiki/Pip_(%E8%BB%9F%E4%BB%B6%E5%8C%85%E7%AE%A1%E7%90%86%E7%B3%BB%E7%B5%B1)) 是一个以 Python 计算机程序语言写成的软件包管理系统，他可以安装和管理软件包。  
另外，不少的软件包也可以在 PyPI 中找到。  

## usage help

官方文档：[Docs](https://pip.pypa.io/en/stable/#) » [pip](https://pip.pypa.io/en/stable/)  

pip 和 pip3 带 `-h`(`--help`) 选项可查看帮助（Show help）。  

pip 的主要命令（Commands）如下：

```bash
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
> [Python 包管理工具 pip 详解](https://muzing.top/posts/594ac4a6/)

## python -m pip

另外，也可以通过 `python3 -m pip` 执行指定 Python 配套的 pip。

> `-m mod` : run library module as a script

```bash
# macOS
python3 -m pip install matplotlib

# Windows (may require elevation)
python -m pip install matplotlib

# Linux (Debian)
apt-get install python3-tk
python3 -m pip install matplotlib
```

假设我们用 brew 安装了多个 python，或者之前用过的 python 一直残留着没有移除。

```bash
$ ls -1 /usr/local/Cellar/ | grep 'python@'
python@3.10
python@3.11
python@3.12
python@3.8
python@3.9

$ find /usr/local/Cellar/ -type d -iname "python@*"
/usr/local/Cellar/python@3.12
/usr/local/Cellar/python@3.10
/usr/local/Cellar/python@3.11
/usr/local/Cellar/python@3.8
/usr/local/Cellar/python@3.9
```

我们在之前的某个版本安装了一些工具包，后来忘了。那么怎么查找到当时用的那个版本呢？

在命令行执行 `python3 -m pip -V` 可以看到指定 python 版本的配套 pip 版本和 site-packages 位置。

- 也可打印 `sys.path` 看看 modules 的搜索路径。

```bash
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

```bash
$ /usr/local/Cellar/python@3.8/3.8.18_2/bin/python3.8 -m pip list
$ /usr/local/Cellar/python@3.9/3.9.18_2/bin/python3.9 -m pip list
$ /usr/local/Cellar/python@3.10/3.10.13_2/bin/python3.10 -m pip list
$ /usr/local/Cellar/python@3.11/3.11.7_2/bin/python3.11 -m pip list
```

## upgrade pip

[upgrade pip](https://pip.pypa.io/en/stable/installing/#upgrading-pip)

On Linux or macOS:

```bash
pip install -U pip
```

```bash
pi@raspberrypi:~ $ pip install -U pip
Collecting pip
  Downloading pip-9.0.1-py2.py3-none-any.whl (1.3MB)
    100% |████████████████████████████████| 1.3MB 13kB/s 
Installing collected packages: pip
Successfully installed pip-9.0.1
```

On Windows:

```bash
python -m pip install -U pip
```

---

运行 pip3 命令，提示新版本可供升级：

```bash
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

```bash
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

## upgrade packages

```bash
pip3 install -U $(pip3 list --outdated | awk 'NR>2 {print $1}')
pip3 list --outdated | awk 'NR>2 {print $1}' | xargs -n1 pip3 install -U

# exclude xlrd or click
pip3 list --outdated | awk 'NR>2 && $1 !~/xlrd/ {print $1}'
pip3 list --outdated | awk 'NR>2 && $1 !~/xlrd|click/ {print $1}'
```

1. `pip3 list --outdated` lists all Python packages that have newer versions available, output format looks like:

```bash
Package    Version Latest Type
---------- ------- ------ -----
requests   2.25.1  2.28.1 wheel
numpy      1.21.0  1.23.2 wheel
```

2. `awk 'NR>2 {print $1}'` extracts the package names from the output of `pip3 list --outdated`:

  - `NR>2` skips the first 2 lines (header and separator line)
  - `{print $1}` prints only the first column (package names)
  - This extracts just the package names: `requests`, `numpy`, etc.

3. `xargs -n1 pip3 install -U` installs each package one by one:

  - `xargs` takes the package names from the previous command
  - `-n1` processes one package name at a time
  - `pip3 install -U` upgrades each package to its latest version

The complete pipeline takes all your outdated Python packages and upgrades them one by one to their latest versions.

Example execution:

If you had outdated packages `requests` and `numpy`, this would effectively run:

```bash
pip3 install -U requests
pip3 install -U numpy
```

### incompatible conflicting dependencies

执行 `pip3 install -U backrefs` 命令将 backrefs 5.9 升级到了最新的 6.0.1：

```bash
$ pip3 install -U backrefs
Requirement already satisfied: backrefs in /Users/faner/.venv/lib/python3.13/site-packages (5.9)
Collecting backrefs
  Using cached backrefs-6.0.1-py313-none-any.whl.metadata (3.2 kB)
Downloading backrefs-6.0.1-py313-none-any.whl (400 kB)
Installing collected packages: backrefs
  Attempting uninstall: backrefs
    Found existing installation: backrefs 5.9
    Uninstalling backrefs-5.9:
      Successfully uninstalled backrefs-5.9
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
mkdocs-material 9.6.21 requires backrefs~=5.7.post1, but you have backrefs 6.0.1 which is incompatible.
Successfully installed backrefs-6.0.1
```

报出 mkdocs-material 依赖的 [backrefs 版本](https://pypi.org/project/backrefs/#history) 兼容错误（incompatible ERROR）。

我们可以借助 [pipdeptree](https://pypi.org/project/pipdeptree/) 工具来查看包依赖关系。

执行 `pipdeptree -p mkdocs-material` 查看 mkdocs-material 的依赖信息，或执行 `pipdeptree -rp backrefs` 查看 backrefs 被依赖的信息，都提示 `Warning!!! Possibly conflicting dependencies found`：

```bash
$ pipdeptree -p mkdocs-material
Warning!!! Possibly conflicting dependencies found:
* mkdocs-material==9.6.21
 - backrefs [required: ~=5.7.post1, installed: 6.0.1]
------------------------------------------------------------------------
mkdocs-material==9.6.21
├── babel [required: ~=2.10, installed: 2.17.0]
├── backrefs [required: ~=5.7.post1, installed: 6.0.1]
...

$ pipdeptree -rp backrefs
Warning!!! Possibly conflicting dependencies found:
* mkdocs-material==9.6.21
 - backrefs [required: ~=5.7.post1, installed: 6.0.1]
------------------------------------------------------------------------
backrefs==6.0.1
└── mkdocs-material==9.6.21 [requires: backrefs~=5.7.post1]
```

mkdocs-material 9.6.21 依赖 backrefs~=5.7.post1，即与 5.7.post1 兼容的版本，一般大版本 5.\* 至少要保持一致。这里激进升级到最新的 6.0.1，主版本已经是 6，提示出现兼容问题。

> mkdocs-material 9.6.21 requires backrefs~=5.7.post1, but you have backrefs 6.0.1 which is incompatible.

参考 [python requirements == 和 ~= 区别](https://blog.csdn.net/u010339879/article/details/131884373)，解决方案是卸载最新的 backrefs 6.0.1，指定安装版本 ==5.\* 进行降级：

1. pip uninstall backrefs
2. pip install backrefs==5.*

回退后，重新执行 `pipdeptree -rp backrefs`，不再提示 Warning：

```bash
$ pipdeptree -rp backrefs
backrefs==5.9
└── mkdocs-material==9.6.21 [requires: backrefs~=5.7.post1]
```

可考虑使用 [pip lock](https://pip.pypa.io/en/stable/cli/pip_lock/) 命令来生成 lock file，Lock packages and their dependencies.

## dependency requirements

`pip freeze` Output installed packages in requirements format.

```bash
pip freeze > requirements.txt
```

[pipreqs · PyPI](https://pypi.org/project/pipreqs/) is a tool for generating the requirements.txt file containing project dependencies. It analyzes Python code within a project, automatically detects *third-party* libraries used, and generates the corresponding requirements.txt file.

Run `pip install pipreqs` to install pipreqs, then run `pipreqs` to generate project-specific package dependencies.

```bash
pipreqs . --force --encoding=utf8
pipreqs . --force --encoding=utf8 --savepath ./dev-reqs.txt
```

1. `--force`: Overwrite existing requirements.txt
2. `--encoding=utf8`: Specify the encoding of the requirements.txt file.
3. `--savepath`: Specify the path to save the requirements.txt file.

### pip install from requirements.txt

`pip3 help install`: pip also supports installing from "requirements files", which provide an easy way to specify a whole environment to be installed.

```bash
  -r, --requirement <file>    Install from the given requirements file. This option can be used multiple times.
```

Specify `-r` or `--requirement` option to install required/dependent packages from a requirements file.

```bash
pip install -r requirements.txt
```

### pip download and install offline

For various reasons, operations personnel often need to deploy Python in production environments, and this inevitably involves installing its various packages. When connected to the internet, executing the `pip install` command completes the installation process. However, it's important to note that production servers are often disconnected from the internet. In such scenarios, installing third-party packages can be difficult. One solution is to download the required packages within the internal network environment first, and then transfer them to the production environment via SCP for offline installation.

1. OA/UAT: Run `pip freeze > requirements.txt` to collect all installed packages in requirements format.
2. OA/UAT: Run `pip download -r requirements.txt -d ./offline_packages` to download all packages in the requirements file.
3. PROD: Run `pip install -r requirements.txt --no-index --find-links=./offline_packages` to install required dependency packages from local index/cache.

```bash
$ pip3 help install

Package Index Options:

  --no-index                  Ignore package index (only looking at --find-links URLs instead).
  -f, --find-links <url>      If a URL or path to an html file, then parse for links to archives such as
                              sdist (.tar.gz) or wheel (.whl) files. If a local path or file:// URL that's a
                              directory, then look for archives in the directory listing. Links to VCS
                              project URLs are not supported.
```

## pip dep and autoremove

### Method 1: Manually approach with pipdeptree

1. Check dependencies before uninstalling:

```bash
# pipdeptree -p
pipdeptree --packages package_name
```

2. List reverse dependencies to see what depends on each package:

```bash
# pipdeptree -rp
pipdeptree --reverse --packages dependency_name
```

3. Manually uninstall packages that are only used by your target package:

```bash
pip3 uninstall package_name dependency1 dependency2 ...
```

### Method 2: Using pip-autoremove (Recommended)

First install the tool:

```bash
pip3 install pip-autoremove
```

Using pip-autoremove with dry-run to see what would be removed without actually doing it:

```bash
pip-autoremove package_name --dry-run
```

Then use it to remove a package and its unused dependencies:

```bash
pip-autoremove package_name -y
```
