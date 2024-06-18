---
title: pyenv & virtualenv
authors:
  - xman
date:
    created: 2019-12-01T10:30:00
categories:
    - python
tags:
    - pyenv
    - virtualenv
comments: true
---

pyenv，virtualenv，pyenv-virtualenv 简介。

<!-- more -->

[What is the difference between venv, pyvenv, pyenv, virtualenv, virtualenvwrapper, pipenv, etc?](https://stackoverflow.com/questions/41573587/what-is-the-difference-between-venv-pyvenv-pyenv-virtualenv-virtualenvwrappe)  

[ohmyzsh / plugins / python](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/python)

## PEP 668 - externally-managed-environment

[pip - Upgraded Python; Do I have to reinstall all site-packages manually? - Stack Overflow](https://stackoverflow.com/questions/45563909/upgraded-python-do-i-have-to-reinstall-all-site-packages-manually)

```bash
pip freeze > ~/Downloads/output/reqs.txt
pip3 freeze --path /usr/local/lib/python3.10/site-packages > ~/Downloads/pip-list.txt

pip3 install -r ~/Downloads/output/reqs.txt
pip3 install --user -r pip-list.txt

error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try brew install
    xyz, where xyz is the package you are trying to
    install.

    If you wish to install a Python library that isn't in Homebrew,
    use a virtual environment:

    python3 -m venv path/to/venv
    source path/to/venv/bin/activate
    python3 -m pip install xyz

    If you wish to install a Python application that isn't in Homebrew,
    it may be easiest to use 'pipx install xyz', which will manage a
    virtual environment for you. You can install pipx with

    brew install pipx

    You may restore the old behavior of pip by passing
    the '--break-system-packages' flag to pip, or by adding
    'break-system-packages = true' to your pip.conf file. The latter
    will permanently disable this error.

    If you disable this error, we STRONGLY recommend that you additionally
    pass the '--user' flag to pip, or set 'user = true' in your pip.conf
    file. Failure to do this can result in a broken Homebrew installation.

    Read more about this behavior here: <https://peps.python.org/pep-0668/>

note: If you believe this is a mistake, please contact your Python installation or OS distribution provider. You can override this, at the risk of breaking your Python installation or OS, by passing --break-system-packages.
hint: See PEP 668 for the detailed specification.
```

As the caveat suggests, we have two solutions to the problem.

1. use a virtual environment to install and upgrade pip packages, such as [pipx](https://pipx.pypa.io/stable/)
2. passing `--break-system-packages` to install and upgrade commands

## venv

[venv — Creation of virtual environments](https://docs.python.org/3/library/venv.html)

> Source code: Lib/venv/, since Python 3.3

The `venv` module supports creating lightweight “virtual environments”, each with their own independent set of Python packages installed in their [`site`](https://docs.python.org/3/library/site.html#module-site) directories. A virtual environment is created on top of an existing Python installation, known as the virtual environment's “*base*” Python, and may optionally be isolated from the packages in the base environment, so *only* those explicitly installed in the virtual environment are available.

When used from within a virtual environment, common installation tools such as [pip](https://pypi.org/project/pip/) will install Python packages into a virtual environment without needing to be told to do so explicitly.

A virtual environment is (amongst other things):

- Used to contain a specific Python interpreter and software libraries and binaries which are needed to support a project (library or application). These are by default isolated from software in other virtual environments and Python interpreters and libraries installed in the operating system.

- Contained in a directory, conventionally either named `venv` or `.venv` in the project directory, or under a container directory for lots of virtual environments, such as `~/.virtualenvs`.

- Not checked into source control systems such as Git.

- Considered as disposable – it should be simple to delete and recreate it from scratch. You don’t place any project code in the environment

- Not considered as movable or copyable – you just recreate the same environment in the target location.

See [**PEP 405**](https://peps.python.org/pep-0405/) for more background on Python virtual environments.

[Availability](https://docs.python.org/3/library/intro.html#availability): not Emscripten, not WASI.

## pyenv

github: [pyenv](https://github.com/pyenv) / [pyenv](https://github.com/pyenv/pyenv)

Simple Python Version Management: pyenv

pyenv lets you easily switch between multiple versions of Python.  
It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.  

> [intallation by Homebrew on macOS](https://github.com/pyenv/pyenv#homebrew-on-mac-os-x)  
> [Multiple Python installations on OS X](https://gist.github.com/Bouke/11261620)  
> [python 环境管理器pyenv 命令](http://blog.csdn.net/sentimental_dog/article/details/52718398)  
> [在 Mac OS X 10.10 安装 pyenv 的一个小坑](http://blog.csdn.net/gzlaiyonghao/article/details/46343913)  
> [CentOS 使用 pyenv](http://www.jianshu.com/p/a23448208d9a), [CentOS 6.4 下安装配置 pip 和 pyenv](http://blog.csdn.net/magedu_linux/article/details/48528257)  

---

pyenv 的美好之处在于它并没有使用将不同的 $PATH 植入不同的 shell 这种高耦合的工作方式，而是简单地在 $PATH 最前面插入了一个垫片路径（shims）：

> `~/.pyenv/shims:/usr/local/bin:/usr/bin:/bin`

所有对 Python 可执行文件的查找都会首先被这个 shims 路径截获，从而架空了后面的系统路径。

### Command Reference

[pyenv Command Reference](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md)

To list the all available versions of Python, including Anaconda, Jython, pypy, and stackless use: 

列出所有可安装的 python 版本：

```shell
faner@MBP-FAN:~|⇒  pyenv install --list
Available versions:
  2.1.3
  2.2.3

```

Then install the desired versions:

安装特定的 python 版本：

```shell

$ pyenv install 2.7.6
$ pyenv install 2.6.8

```

Lists all Python versions known to pyenv, and shows an asterisk next to the currently active version.

列出已经安装的 python 版本：

```shell
faner@MBP-FAN:~|⇒  pyenv versions
* system (set by /Users/faner/.pyenv/version)
```

查看当前正在使用的 python 版本：

```shell
faner@MBP-FAN:~|⇒  pyenv version
system (set by /Users/faner/.pyenv/version)
```

Uninstall a specific Python version.

卸载指定版本的 python：

```shell
Usage: pyenv uninstall [-f|--force] <version>

   -f  Attempt to remove the specified version without prompting
       for confirmation. If the version does not exist, do not
       display an error message.
```

Displays the full path to the executable that pyenv will invoke when you run the given command.

列出指定版本 python 的实际路径：

```shell
$ pyenv which python3.3
/home/yyuu/.pyenv/versions/3.3.3/bin/python3.3
```

## virtualenv

[virtualenv](https://pypi.python.org/pypi/virtualenv) is a tool to create isolated Python environments.

[Docs](https://virtualenv.pypa.io/en/stable/#) » [Virtualenv](https://virtualenv.pypa.io/en/stable/)  

> [ubuntu 使用 pyenv 和 virtualenv 搭建多版本虚拟开发环境](http://www.cnblogs.com/npumenglei/p/3719412.html)  
> [CentOS 6.8 使用 pyenv + virtualenv 打造多版本 Python 开发环境](http://python.jobbole.com/85587/)  

## pyenv-virtualenv

github: [pyenv](https://github.com/pyenv) / [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)

pyenv 是一个 Python 多版本环境管理工具，这个是和我们常用的 virtualenv 有所不同。  

1. 前者是对 Python 的版本进行管理，实现不同版本的切换和使用；  
2. 后者测试创建一个虚拟环境，与系统环境以及其他 Python 环境隔离，避免干扰。  

**pyenv-virtualenv** is a [pyenv](https://github.com/pyenv/pyenv) *plugin* that provides features to manage virtualenvs and conda environments for Python on UNIX-like systems.

## references

[pyenv简介——Debian/Ubuntu中管理多版本Python](http://www.malike.net.cn/blog/2016/05/21/pyenv-tutorial/) - git clone  

[mac下使用pyenv,pyenv-virtualenv管理python的多个版本](http://blog.csdn.net/angel22xu/article/details/45443019) - homebrew - 图文详细  
[Mac OS 上用pyenv和pyenv-virtualenv管理多个Python多版本及虚拟环境](http://blog.csdn.net/liuchunming033/article/details/78345286) - homebrew  
[Python版本管理：pyenv和pyenv-virtualenv(MAC、Linux)、virtualenv和virtualenvwrapper(windows)](http://www.jianshu.com/p/60f361822a7e) - git clone  
