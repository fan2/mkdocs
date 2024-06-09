---
title: Anaconda IDE 介绍
authors:
  - xman
date:
    created: 2019-12-01T10:40:00
categories:
    - python
tags:
    - Anaconda
comments: true
---

Anaconda IDE 开发环境简介。

<!-- more -->

!!! abstract "Anaconda"

    Unleash Al Innovation and Value

    The World's Most Popular Python/R Data Science Platform

    The open-source Anaconda Distribution is the easiest way to perform Python/R data science and machine learning on Linux, Windows, and Mac OS X.

[Anaconda](https://www.anaconda.com/) - [Anaconda Documentation](https://docs.anaconda.com/) - [Anaconda Distribution](https://docs.anaconda.com/free/anaconda/)

Anaconda 是一个包含诸多常用科学包及其依赖项的 Python 发行版本，其开源跨平台，解决了 Python 原生包管理器 Pip 的依赖冲突问题，极大地方便了 Python 环境的管理。

如果你使用 Python 的场景属于数据科学领域，则 Anaconda 可以被看作是标配。

## install

在 Windows 下，可通过包管理器 Chocolatey 或 Scoop 进行安装：

```
# scoop bucket add scoopet https://github.com/integzz/scoopet
scoop install miniconda-cn
choco install miniconda3
```

对 macOS 用户，可用 Homebrew 安装：

```
brew cask install anaconda
```

brew 安装日志提示其安装位置：

```
PREFIX=/usr/local/anaconda3
```

---

macOS 通过 brew 安装的 python3 目前的版本为 3.9.0：

```
$ python3 -V
Python 3.9.0

$ pip3 -V
pip 20.2.4 from /usr/local/lib/python3.9/site-packages/pip (python 3.9)
```

cd 进入 anaconda3 命令行工具包目录（`/usr/local/anaconda3/bin`），执行 `./python3 -V` 可知，anaconda3 内置的 python3 版本为 3.7.6：

```
$ cd /usr/local/anaconda3/bin
$ ./python3 -V
Python 3.7.6

$ ./pip -V
pip 20.0.2 from /usr/local/anaconda3/lib/python3.7/site-packages/pip (python 3.7)
```

执行 `./pip list` 可以查看安装的第三方包：

```
$ ./pip list | more
Package                            Version
---------------------------------- -------------------
alabaster                          0.7.12
anaconda-client                    1.7.2
anaconda-navigator                 1.9.12
anaconda-project                   0.8.3

$ ./pip list | grep 'pandas'
pandas                             1.0.1
```

## conda

`conda` is a tool for managing and deploying applications, environments and packages.

conda 是 Anaconda 内置的命令行工具包，[macOS 安装 Anaconda 后无法在终端使用 conda 命令怎么办？](https://zhuanlan.zhihu.com/p/144550389)

cd 进入 anaconda3 命令行工具包目录（`/usr/local/anaconda3/bin`），即可执行 `./conda` 相关命令。

查看 conda 版本：

```
$ cd /usr/local/anaconda3/bin
$ ./conda -V
conda 4.8.2
```

### help

查看 conda 帮助：

```
$ ./conda -h
usage: conda [-h] [-V] command ...

conda is a tool for managing and deploying applications, environments and packages.

Options:

positional arguments:
  command
    clean        Remove unused packages and caches.
    config       Modify configuration values in .condarc. This is modeled
                 after the git config command. Writes to the user .condarc
                 file (/Users/faner/.condarc) by default.
    create       Create a new conda environment from a list of specified
                 packages.
    help         Displays a list of available conda commands and their help
                 strings.
    info         Display information about current conda install.
    init         Initialize conda for shell interaction. [Experimental]
    install      Installs a list of packages into a specified conda
                 environment.
    list         List linked packages in a conda environment.
    package      Low-level conda package utility. (EXPERIMENTAL)
    remove       Remove a list of packages from a specified conda environment.
    uninstall    Alias for conda remove.
    run          Run an executable in a conda environment. [Experimental]
    search       Search for packages and display associated information. The
                 input is a MatchSpec, a query language for conda packages.
                 See examples below.
    update       Updates conda packages to the latest compatible version.
    upgrade      Alias for conda update.

```

执行 `conda activate -h` 查看 activate 子命令的帮助：

```bash
$ ./conda activate -h
usage: conda activate [-h] [--[no-]stack] [env_name_or_prefix]

Activate a conda environment.

Options:

positional arguments:
  env_name_or_prefix    The environment name or prefix to activate. If the
                        prefix is a relative path, it must start with './'
                        (or '.\' on Windows).
```

### info

执行 `./conda info` 命令可查看当前安装的 conda 相关配置信息。  
conda 有个子环境的概念，默认为 `active environment : base`。  

```
$ ./conda info

     active environment : base
    active env location : /usr/local/anaconda3
            shell level : 1
       user config file : /Users/faner/.condarc
 populated config files : /Users/faner/.condarc
          conda version : 4.8.2
    conda-build version : 3.18.11
         python version : 3.7.6.final.0
       virtual packages : __osx=10.16
       base environment : /usr/local/anaconda3  (writable)
           channel URLs : https://repo.anaconda.com/pkgs/main/osx-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/osx-64
                          https://repo.anaconda.com/pkgs/r/noarch
          package cache : /usr/local/anaconda3/pkgs
                          /Users/faner/.conda/pkgs
       envs directories : /usr/local/anaconda3/envs
                          /Users/faner/.conda/envs
               platform : osx-64
             user-agent : conda/4.8.2 requests/2.22.0 CPython/3.7.6 Darwin/20.1.0 OSX/10.16
                UID:GID : 501:20
             netrc file : None
           offline mode : False
```

### list

列举 conda 默认的 base 环境（/usr/local/anaconda3）集成的工具包：

```
$ ./conda list | wc -l
     305

$ ./conda list | more
# packages in environment at /usr/local/anaconda3:
#
# Name                    Version                   Build  Channel
_ipyw_jlab_nb_ext_conf    0.1.0                    py37_0
alabaster                 0.7.12                   py37_0
anaconda                  2020.02                  py37_0
anaconda-client           1.7.2                    py37_0
anaconda-navigator        1.9.12                   py37_0
anaconda-project          0.8.4                      py_0

$ ./conda list | grep 'pandas'
pandas                    1.0.1            py37h6c726b0_0
```

!!! note "Anaconda Toolset Suite"

    Our repository features over 8,000 open-source data science and machine learning packages, Anaconda-built and compiled for all major operating systems and architectures.

![Anaconda-Suite](https://www.anaconda.com/wp-content/uploads/2023/03/Distro01.webp)

- [Jupyter](https://jupyter.org/): *Jupyter* is a non-profit, open-source project, born out of the [IPython Project](https://ipython.org/) in 2014 as it evolved to support interactive data science and scientific computing across all programming languages.  

Analyze data with scalability and performance:

- [NumPy](https://numpy.org/): *NumPy* is the fundamental package for scientific computing with Python.  
- [SciPy](https://www.scipy.org/): *SciPy* is a Python-based ecosystem of open-source software for mathematics, science, and engineering.  
- [Numba](https://numba.pydata.org/): *Numba* is an open source JIT compiler that translates a subset of Python and NumPy code into fast machine code.  
- [pandas](http://pandas.pydata.org/): *pandas* is an open source, BSD-licensed library providing high-performance, easy-to-use data structures and data analysis tools for the Python programming language.  
- [Dask](https://dask.org/): *Dask* provides advanced parallelism for analytics, enabling performance at scale for the tools you love. It is developed in coordination with other community projects like Numpy, Pandas, and Scikit-Learn.  

Visualize Toolset:

- [Matplotlib](https://matplotlib.org/): *Matplotlib* is a Python 2D plotting library which produces publication quality figures in a variety of hardcopy formats and interactive environments across platforms.  
- [Bokeh](https://bokeh.pydata.org/en/latest/): *Bokeh* is an interactive visualization library that targets modern web browsers for presentation.  
- [Datashader](http://datashader.org/): *Datashader* is a graphics pipeline system for creating meaningful representations of large datasets quickly and flexibly.  
- [Holoviews](http://holoviews.org/): *HoloViews* is an open-source Python library designed to make data analysis and visualization seamless and simple.  

## conda envs

[Anaconda介绍、安装及使用教程](https://zhuanlan.zhihu.com/p/32925500)  

### base

执行 `./conda activate` 尝试激活 base 环境，报错 *CommandNotFoundError*：

```
$ ./conda activate

CommandNotFoundError: Your shell has not been properly configured to use 'conda activate'.
To initialize your shell, run

    $ conda init <SHELL_NAME>

Currently supported shells are:
  - bash
  - fish
  - tcsh
  - xonsh
  - zsh
  - powershell

See 'conda init --help' for more information and options.

IMPORTANT: You may need to close and restart your shell after running 'conda init'.
```

#### init shell

根据提示执行 `./conda init zsh`，`vim ~/.zshrc` 可看到 ZSH 配置文件末尾添加了 conda initialize，主要是将 conda bin 添加到环境变量：

```
export PATH="/usr/local/anaconda3/bin:$PATH"
```

执行 `. ~/.zshrc` 或 `source ~/.zshrc` 或重开一个新的 zsh 终端窗口，即可进入 conda base 环境，可直接运行 conda 系列命令。

```
$ conda -V
conda 4.8.2
(base)

$ python3 -V
Python 3.7.6
(base)
```

#### activate

将 conda 集成进当前 shell（zsh） 之后，再次执行 `conda activate` 可进入 conda base 环境。

默认的 base 环境携带了所有集成的组件库（Toolset Suite），可以直接导入引用，新建的子环境则需要自行按需安装。  
如无特殊的环境隔离需求，普通简单的需求直接在 base 环境运行调试即可。  

activate 后进入 conda base prompt 环境，查看内置的 python 版本和路径：

```Shell
$ conda activate
$ (base) python -V
Python 3.9.7
$ (base) which python
/usr/local/anaconda3/bin/python
```

#### deactivate

在 conda base 环境下，执行 `conda deactivate` 可退出 base 环境，回到系统默认的 zsh-python 环境。

```
$ conda deactivate

$ python3 -V
Python 3.9.0
```

#### auto_activate_base

由于执行 `./conda init zsh` 时改动了 ZSH 配置文件（`~/.zshrc`），导致每次启动 zsh 终端窗口，都会自动进入 conda base 环境。

[怎样取消每次自动进入 conda base 环境呢](https://blog.csdn.net/u014734886/article/details/90718719)？

可通过以下三种方式：

**方法一**：注释掉 ZSH 配置文件（`~/.zshrc`）中的 conda initialize 相关脚本；  

**方法二**：每次在命令行通过 `conda deactivate` 退出 base 环境；  

**方法三**：推荐方式

1. 通过将 `auto_activate_base` 参数设置为 false 实现：

```
conda config --set auto_activate_base false
```

> 如果要进入的话可执行通过 `conda activate` 默认进入 base 环境

2. 如果反悔了，可以再次恢复 `auto_activate_base` 参数值：

```
conda config --set auto_activate_base true
```

conda config 实际上是修改 user config file : `~/.condarc`。

### create env

执行 `conda create -h` 查看 create 子命令帮助。

```
# 创建
conda create -n [env_name] [package_spec [package_spec ...]]
# 删除
conda env remove -n [env_name]
```

输入 `conda create -n Py376 python=3.7.6`，创建一个名为 Py376 的 python 3.7.6 子环境。

```
Preparing transaction: done
Verifying transaction: \ WARNING conda.core.path_actions:verify(963): Unable to create environments file. Path not writable.
  environment location: /Users/faner/.conda/environments.txt

done
Executing transaction: / WARNING conda.core.envs_manager:register_env(52): Unable to register environment. Path not writable or missing.
  environment location: /usr/local/anaconda3/envs/Py376
  registry file: /Users/faner/.conda/environments.txt
done
#
# To activate this environment, use
#
#     $ conda activate Py376
#
# To deactivate an active environment, use
#
#     $ conda deactivate

# 中间省略

Preparing transaction: done
Verifying transaction: \ WARNING conda.core.path_actions:verify(963): Unable to create environments file. Path not writable.
  environment location: /Users/faner/.conda/environments.txt

done
Executing transaction: / WARNING conda.core.envs_manager:register_env(52): Unable to register environment. Path not writable or missing.
  environment location: /usr/local/anaconda3/envs/Py376
  registry file: /Users/faner/.conda/environments.txt
done
#
# To activate this environment, use
#
#     $ conda activate Py376
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```

#### Path not writable

执行 conda 相关命令时，提示 WARNING：

- Unable to create environments file. Path not writable.
- Unable to register environment. Path not writable or missing.

当然可以已 sudo 身份重新执行一遍，但是最好按照以下方式为 conda 工作目录添加必要的写权限。

[How does one fix the issue of not writable paths with conda?](https://stackoverflow.com/questions/59619442/how-does-one-fix-the-issue-of-not-writable-paths-with-conda)

ls 查看 `~/.conda` 权限为755，属组成员不可写：

```
$ ls -lhFA | grep '\.conda/'
drwxr-xr-x    3 faner  staff    96B Nov 15 18:53 .conda/
```

为属组成员添加权限，chmod -R g+w 变更权限为 775：

```
$ # sudo chmod -R 775 .conda
$ sudo chmod -R g+w .conda
Password:

$ ls -lhFA | grep '\.conda/'
drwxrwxr-x    3 faner  staff    96B Nov 15 18:53 .conda/
```

#### env list

创建了新的子环境后，再执行 `conda env list` 可以看到环境列表多了一项：

```
$ conda env list
# conda environments:
#
base                  *  /usr/local/anaconda3
Py376                    /usr/local/anaconda3/envs/Py376

(base)
```

environment location: `/Users/faner/.conda/environments.txt`

```
$ cat ~/.conda/environments.txt
/usr/local/anaconda3
/usr/local/anaconda3/envs/Py376
```

新建的 Anaconda 子环境被安装在 `/usr/local/anaconda3/envs` 目录下。

#### activate

创建好子环境之后，按照提示执行 `conda activate Py376`，激活名为 Py376 的子环境。

> 必须执行过 `conda init`，否则执行 activate 时提示报错 `CommandNotFoundError`！

此时执行 `conda activate Py376` 切换到 Py376 子环境，可再次执行 `conda info` 确认相关配置信息：

```
$ conda activate Py376
(Py376)

$ conda info

     active environment : Py376
    active env location : /usr/local/anaconda3/envs/Py376

```

用完之后执行 `conda deactivate` 退回 base 环境。

```
$ conda deactivate
(base)
```

#### install

执行 `conda install -h` 查看 install 子命令帮助。

```
usage: conda install [-h] [--revision REVISION] [-n ENVIRONMENT | -p PATH]
                     [--freeze-installed | --update-deps | -S | --update-all | --update-specs]
                     [package_spec [package_spec ...]]
```

在 Py376 下执行 conda list | grep 'pandas' 可知，新建的子环境并没有自带 base 下的 pandas 等 Toolset Suite，需要自行按需安装。

```
conda install -n Py376 pandas
```

**常用包管理相关的命令如下**：

```
# 搜索某个包，会列举所有可安装版本
conda search [package_name]
# 为指定环境安装指定版本的包
conda install [-n ENVIRONMENT] [package_spec] [--revision REVISION]
# 查看已安装列表
conda list
# 更新某个包
conda update [package_name]
# 更新所有包
conda update --all
# 删除已安装的包
conda remove [package_name] # remove alias as uninstall
```

## conda update

执行 `conda update -h` 查看 update 子命令帮助。

在 base 环境下执行 `conda update` 提示没有提供要升级的包名，并给出了升级 anaconda 自身的命令。

```
$ conda update

CondaValueError: no package names supplied
# If you want to update to a newer version of Anaconda, type:
#
# $ conda update --prefix /usr/local/anaconda3 anaconda
```

- 执行 `conda update -n Py376 scipy` 更新 Py376 下的 scipy 包。  
- 执行 `conda update python` 更新当前子环境（base）下的 python 包。  
- 执行 `conda update --all` 更新当前子环境（base）下的所有包。  

```
$ conda update --all
Collecting package metadata (current_repodata.json): done
Solving environment: done

# All requested packages already installed.
```
