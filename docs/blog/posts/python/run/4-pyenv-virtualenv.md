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

## pyenv

[pyenv](https://github.com/pyenv/pyenv): Simple Python Version Management

pyenv lets you easily switch between multiple versions of Python. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.

> pyenv is to Python as nvm is to NodeJs.

### What

What pyenv _does..._:

-   Lets you **change the global Python version** on a per-user basis.
-   Provides support for **per-project Python versions**.
-   Allows you to **override the Python version** with an environment variable.
-   Searches for commands from **multiple versions of Python at a time**. This may be helpful to test across Python versions with [tox](https://pypi.python.org/pypi/tox).

In contrast with pythonbrew and pythonz, pyenv _does not..._:

-   **Depend on Python itself.** pyenv was made from pure shell scripts. There is no bootstrap problem of Python.
-   **Need to be loaded into your shell.** Instead, pyenv's shim approach works by adding a directory to your `PATH`.
-   **Manage virtualenv.** Of course, you can create [virtualenv](https://pypi.python.org/pypi/virtualenv) yourself, or [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) to automate the process.

### How

At a high level, pyenv intercepts Python commands using shim executables injected into your `PATH`, determines which Python version has been specified by your application, and passes your commands along to the correct Python installation.

pyenv works by inserting a directory of _shims_ at the front of your `PATH`:

    $(pyenv root)/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, pyenv maintains shims in that directory to match every Python command across every installed version of Python—`python`, `pip`, and so on.

Shims are lightweight executables that simply pass your command along to pyenv. So with pyenv installed, when you run, say, `pip`, your operating system will do the following:

-   Search your `PATH` for an executable file named `pip`
-   Find the pyenv shim named `pip` at the beginning of your `PATH`
-   Run the shim named `pip`, which in turn passes the command along to pyenv

### Installation

```bash
$ brew info pyenv
==> pyenv: stable 2.6.8 (bottled), HEAD
Python version management
https://github.com/pyenv/pyenv
Not installed
From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/p/pyenv.rb

$ brew install pyenv
```

**Set up your shell environment for Pyenv**:

Add Pyenv startup commands to `~/.zshrc` by running the following in your terminal:

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc
```

If you wish to get Pyenv in noninteractive login shells as well, also add the commands to `~/.zprofile` or `~/.zlogin`.

### Commands

[pyenv Command Reference](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md)

`pyenv commands`: Lists all available pyenv commands.

To list the all available versions of Python, including Anaconda, Jython, pypy, and stackless use: 

```bash
$ pyenv install --list
Available versions:
  2.1.3
  2.2.3

```

Then install the desired versions:

```bash
$ pyenv install 2.7.6
$ pyenv install 2.6.8
$ pyenv install 3:latest
```

Lists all Python versions known to pyenv, and shows an asterisk next to the currently active version.

```bash
$ pyenv versions
* system (set by /Users/faner/.pyenv/version)
```

1. **`pyenv global`**: Sets the *global* version of Python to be used in *all* shells by writing the version name to the `~/.pyenv/version` file. This version can be overridden by an application-specific `.python-version` file, or by setting the `PYENV_VERSION` environment variable.
2. **`pyenv local`**: Sets a local *application-specific* Python version by writing the version name to a `.python-version` file in the *current* directory. This version overrides the global version, and can be overridden itself by setting the `PYENV_VERSION` environment variable or with the `pyenv shell` command.
3. **`pyenv shell`**: Sets a *shell-specific* Python version by setting the `PYENV_VERSION` environment variable in your shell. This version overrides application-specific versions and the global version.

Displays the currently active Python version, along with information on how it was set.

```bash
$ pyenv version
system (set by /Users/faner/.pyenv/version)
```

Uninstall a specific Python version.

```bash
Usage: pyenv uninstall [-f|--force] <version>

   -f  Attempt to remove the specified version without prompting
       for confirmation. If the version does not exist, do not
       display an error message.
```

Displays the full path to the executable that pyenv will invoke when you run the given command.

```bash
$ pyenv which python3.3
/Users/faner/.pyenv/versions/3.3.3/bin/python3.3
```

## venv

[venv — Creation of virtual environments](https://docs.python.org/3/library/venv.html) - Added in version 3.3.

The `venv` module supports creating lightweight “virtual environments”, each with their own independent set of Python packages installed in their [site](https://docs.python.org/3/library/site.html#module-site) directories. A virtual environment is created on top of an existing Python installation, known as the virtual environment’s “base” Python, and by default is isolated from the packages in the base environment, so that only those explicitly installed in the virtual environment are available.

When used from within a virtual environment, common installation tools such as [pip](https://pypi.org/project/pip/) will install Python packages into a virtual environment without needing to be told to do so explicitly.

> Used to contain a specific Python interpreter and software libraries and binaries which are needed to support a project (library or application). These are by default isolated from software in other virtual environments and Python interpreters and libraries installed in the operating system.

### help

Run `python3 -m venv --help` to show usage information.

```bash
$ python3 -m venv --help
usage: venv [-h] [--system-site-packages] [--symlinks | --copies] [--clear] [--upgrade]
            [--without-pip] [--prompt PROMPT] [--upgrade-deps] [--without-scm-ignore-files]
            ENV_DIR [ENV_DIR ...]

Creates virtual Python environments in one or more target directories.

positional arguments:
  ENV_DIR               A directory to create the environment in.

options:
  -h, --help            show this help message and exit
  --system-site-packages
                        Give the virtual environment access to the system site-packages
                        dir.
  --symlinks            Try to use symlinks rather than copies, when symlinks are not the
                        default for the platform.
  --copies              Try to use copies rather than symlinks, even when symlinks are the
                        default for the platform.
  --clear               Delete the contents of the environment directory if it already
                        exists, before environment creation.
  --upgrade             Upgrade the environment directory to use this version of Python,
                        assuming Python has been upgraded in-place.
  --without-pip         Skips installing or upgrading pip in the virtual environment (pip
                        is bootstrapped by default)
  --prompt PROMPT       Provides an alternative prompt prefix for this environment.
  --upgrade-deps        Upgrade core dependencies (pip) to the latest version in PyPI
  --without-scm-ignore-files
                        Skips adding SCM ignore files to the environment directory (Git is
                        supported by default).

Once an environment has been created, you may wish to activate it, e.g. by sourcing an
activate script in its bin directory.
```

### usage

1. Creating virtual environments

```
cmd> python -m venv C:\path\to\new\virtual\environment
bash> python -m venv /path/to/new/virtual/environment
```

2. Activate a virtual environment

```
# sourcing an activate script in its bin/Scripts directory
cmd> %VIRTUAL_ENV%\Scripts\activate
bash> source VIRTUAL_ENV/bin/activate
```

When a virtual environment has been activated, the `VIRTUAL_ENV` environment variable is set to the path of the environment.

```bash
$ echo $VIRTUAL_ENV
/Users/faner/.venv
```

3. Deactivate current venv when done

```
deactivate
```

### mechanism

When a Python interpreter is running from a virtual environment, [`sys.prefix`](https://docs.python.org/3/library/sys.html#sys.prefix) and [`sys.exec_prefix`](https://docs.python.org/3/library/sys.html#sys.exec_prefix) point to the directories of the virtual environment, whereas [`sys.base_prefix`](https://docs.python.org/3/library/sys.html#sys.base_prefix) and [`sys.base_exec_prefix`](https://docs.python.org/3/library/sys.html#sys.base_exec_prefix) point to those of the *base* Python used to create the environment. It is sufficient to check `sys.prefix != sys.base_prefix` to determine if the current interpreter is running from a virtual environment.

A virtual environment may be “activated” using a script in its binary directory (`bin` on POSIX; `Scripts` on Windows). This will **prepend** that directory to your `PATH`, so that running **python** will invoke the environment’s Python interpreter and you can run installed scripts without having to use their full path. The invocation of the activation script is platform-specific.

### prefix path

The `sys.prefix` and `sys.exec_prefix` have changed and are distinct from the corresponding base prefix.

```bash
$ python3 -c "import sys; print(sys.prefix)"
/Users/faner/.venv
$ python3 -c "import sys; print(sys.exec_prefix)"
/Users/faner/.venv
```

`site.PREFIXES` now only points to `VIRTUAL_ENV`, and `site.ENABLE_USER_SITE` turns to be `False`.

```bash
$ python3 -c "import pprint, site; pprint.pp(site.PREFIXES)"
['/Users/faner/.venv']

$ python3 -c "import pprint, site; print(site.ENABLE_USER_SITE)"
False
```

Let's check the current python3 bin path `sys.executable`:

```bash
$ which python3
/Users/faner/.venv/bin/python3
$ python3 -c "import sys; print(sys.executable)"
/Users/faner/.venv/bin/python3
```

`site.getsitepackages()` now only returns the `VIRTUAL_ENV`'s `site-packages` and replace the last default site-package path in `sys.path`.

```bash
$ python3 -c "import pprint, site; pprint.pp(site.getsitepackages())"
['/Users/faner/.venv/lib/python3.13/site-packages']

$ python3 -c "import sys, pprint; pprint.pp(sys.path)"
['',
 '/opt/homebrew/Cellar/python@3.13/3.13.7/Frameworks/Python.framework/Versions/3.13/lib/python313.zip',
 '/opt/homebrew/Cellar/python@3.13/3.13.7/Frameworks/Python.framework/Versions/3.13/lib/python3.13',
 '/opt/homebrew/Cellar/python@3.13/3.13.7/Frameworks/Python.framework/Versions/3.13/lib/python3.13/lib-dynload',
 '/Users/faner/.venv/lib/python3.13/site-packages']
```

## pyenv-virtualenv

[pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) is a [pyenv](https://github.com/pyenv/pyenv) *plugin* that provides features to manage virtualenvs and conda environments for Python on UNIX-like systems.

**virtualenv vs. venv**:

There is a [venv](http://docs.python.org/3/library/venv.html) module available for CPython 3.3 and newer. It provides an executable module `venv` which is the successor of `virtualenv` and distributed by default.

`pyenv-virtualenv` uses `python -m venv` if it is available and the `virtualenv` command is not available.

## virtualenv

[virtualenv](https://pypi.python.org/pypi/virtualenv) is a tool to create isolated Python environments.

[virtualenv documentation](https://virtualenv.pypa.io/en/latest/)

Since Python `3.3`, a subset of it has been integrated into the standard library under the [venv module](https://docs.python.org/3/library/venv.html). The `venv` module does not offer all features of this library, to name just a few more prominent:

- is slower (by not having the `app-data` seed method),
- is not as extendable,
- cannot create virtual environments for arbitrarily installed python versions (and automatically discover these),
- is not upgrade-able via [pip](https://pip.pypa.io/en/stable/installing/),
- does not have as rich programmatic API (describe virtual environments without creating them).
