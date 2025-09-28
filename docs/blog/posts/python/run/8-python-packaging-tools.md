---
title: Python Packaging Tools - setuptools & wheel
authors:
  - xman
date:
    created: 2019-12-02T11:00:00
categories:
    - python
tags:
    - setuptools
    - wheel
comments: true
---

Introduce Python Packaging Tools - setuptools & wheel.

<!-- more -->

[PyPA](https://pypa.io/) » [Python Packaging User Guide](https://packaging.python.org/) » [Guides](https://packaging.python.org/guides/) » [Tool recommendations](https://packaging.python.org/guides/tool-recommendations/)

- Installation Tool Recommendations  
	- Use **pip** to install Python [packages](https://packaging.python.org/glossary/#term-distribution-package) from [PyPI](https://packaging.python.org/glossary/#term-python-package-index-pypi).  
	- Use [**virtualenv**](https://packaging.python.org/key_projects/#virtualenv), or [venv](https://docs.python.org/3/library/venv.html) to isolate application specific dependencies from a shared Python installation.  
- Packaging Tool Recommendations  
	- Use [**setuptools**](https://packaging.python.org/key_projects/#setuptools) to define projects and create [Source Distributions](https://packaging.python.org/glossary/#term-source-distribution-or-sdist).  
	- Use the `bdist_wheel` [setuptools](https://packaging.python.org/key_projects/#setuptools) extension available from the [wheel project](https://packaging.python.org/key_projects/#wheel) to create [wheels](https://packaging.python.org/glossary/#term-wheel). This is especially beneficial, if your project contains binary extensions.  

## setuptools

[Package Index](https://pypi.python.org/pypi) > [setuptools](https://pypi.python.org/pypi/setuptools)

Easily download, build, install, upgrade, and uninstall Python packages

Github Page: [pypa](https://github.com/pypa) / [setuptools](https://github.com/pypa/setuptools)

[setuptools](https://packaging.python.org/key_projects/#setuptools) (which includes `easy_install`) is a collection of enhancements to the Python distutils that allow you to more easily build and distribute Python distributions, especially ones that have dependencies on other packages.

macOS 下使用 brew 安装 python3 时，默认已安装 pip3 和 setuptools。

```bash
faner@FAN-MB0:~|⇒  pip3 list
DEPRECATION: The default format will switch to columns in the future. You can use --format=(legacy|columns) (or define a format=(legacy|columns) in your pip.conf under the [list] section) to disable this warning.
pip (9.0.1)
setuptools (36.5.0)
wheel (0.30.0)
```

> [How can I get a list of locally installed Python modules?](https://stackoverflow.com/questions/739993/how-can-i-get-a-list-of-locally-installed-python-modules)  

可通过 `pip3 show setuptools` 命令查看已安装的 setuptools 包信息。

```bash
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

```bash
$ pip3 show ipykernel
WARNING: Package(s) not found: ipykernel
```

## wheel

[Docs](https://wheel.readthedocs.io/en/latest/#)  » [wheel](https://wheel.readthedocs.io/en/latest/)

A built-package format for Python.  
A **wheel** is a ZIP-format archive with a specially formatted filename and the `.whl` extension.  

macOS 下使用 brew 安装 python3 时，默认已安装 pip3 和 wheel3。

```bash
faner@FAN-MB0:~|⇒  wheel3 -V
usage: wheel3 [-h]
              {keygen,sign,unsign,verify,unpack,install,install-scripts,convert,version,help}
              ...
wheel3: error: unrecognized arguments: -V
```

可通过 `pip3 show wheel` 命令查看 wheel 包信息。

```bash
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
