---
title: python包和模块
authors:
  - xman
date:
    created: 2019-12-03T08:10:00
categories:
    - python
tags:
    - module
comments: true
---

Python中的包和模块概述，包括 import、`__main__` 等内容.

<!-- more -->

[The Python Language Reference](https://docs.python.org/3/reference/index.html) - [The import system](https://docs.python.org/3/reference/import.html#importsystem)  
[The Python Tutorial](https://docs.python.org/3.6/tutorial/) - [Modules](https://docs.python.org/3.6/tutorial/modules.html)  

[General Index](https://docs.python.org/3/genindex.html)  
[Global Module Index](https://docs.python.org/3/py-modindex.html)  

Python的程序由包（[package](https://docs.python.org/3/glossary.html#term-package)）、模块（[module](https://docs.python.org/3/glossary.html#term-module)）和函数组成。包是由一系列模块组成的集合。模块是处理某一类问题的函数和类的集合。

- ***package***: A Python [module](https://docs.python.org/3/glossary.html#term-module) which can contain submodules or recursively, subpackages. Technically, a package is a Python module with an `__path__` attribute.

- ***module***: An object that serves as an organizational unit of Python code. Modules have a namespace containing arbitrary Python objects. Modules are loaded into Python by the process of [importing](https://docs.python.org/3/glossary.html#term-importing).

- ***function***: A series of statements which returns some value to a caller. It can also be passed zero or more [arguments](https://docs.python.org/3/glossary.html#term-argument) which may be used in the execution of the body. See also [parameter](https://docs.python.org/3/glossary.html#term-parameter), [method](https://docs.python.org/3/glossary.html#term-method), and the [Function definitions](https://docs.python.org/3/reference/compound_stmts.html#function) section.

## sys

```shell
>>> import sys

>>> help(sys)

Help on built-in module sys:

NAME
    sys

DESCRIPTION
    This module provides access to some objects used or maintained by the
    interpreter and to functions that interact strongly with the interpreter.
    
    Dynamic objects:
    
    argv -- command line arguments; argv[0] is the script pathname if known
    path -- module search path; path[0] is the script directory, else ''
    modules -- dictionary of loaded modules

    Static objects:
    
    builtin_module_names -- tuple of module names built into this interpreter

```

## import module

Python code in one [module](https://docs.python.org/3/glossary.html#term-module) **gains access** to the code in another module by the process of [importing](https://docs.python.org/3/glossary.html#term-importing) it. The [import](https://docs.python.org/3/reference/simple_stmts.html#import) statement is the most common way of invoking the import machinery, but it is not the only way. Functions such as [importlib.import_module()](https://docs.python.org/3/library/importlib.html#importlib.import_module) and built-in [`__import__()`](https://docs.python.org/3/library/functions.html#__import__) can also be used to invoke the import machinery.

The [import](https://docs.python.org/3/reference/simple_stmts.html#import) statement combines two operations; it **searches** for the named module, then it **binds** the results of that search to a name in the local scope.

### Search Path

The first place checked during import search is [sys.modules](https://docs.python.org/3/library/sys.html#sys.modules). 

- ***sys.path***: A list of strings that specifies the search path for modules. Initialized from the environment variable [PYTHONPATH](https://docs.python.org/3/using/cmdline.html#envvar-PYTHONPATH), plus an installation-dependent default.  
- ***sys.modules***: This is a dictionary that maps module names to modules which have already been loaded. This can be manipulated to force reloading of modules and other tricks. However, replacing the dictionary will not necessarily work as expected and deleting essential items from the dictionary may cause Python to fail.  

When the named module is not found in [sys.modules](https://docs.python.org/3/library/sys.html#sys.modules), Python next searches [sys.meta_path](https://docs.python.org/3/library/sys.html#sys.meta_path), which contains a list of meta path finder objects. These finders are queried in order to see if they know how to handle the named module.

- ***sys.meta_path***: A list of [meta path finder](https://docs.python.org/3/glossary.html#term-meta-path-finder) objects that have their [find_spec()](https://docs.python.org/3/library/importlib.html#importlib.abc.MetaPathFinder.find_spec) methods called to see if one of the objects can find the module to be imported. 

### import

[The import statement](https://docs.python.org/3/reference/simple_stmts.html#import)  

> If the requested module is retrieved successfully, it will be made **available** in the local namespace.

Examples:

```shell
import foo                 # foo imported and bound locally
import foo.bar.baz         # foo.bar.baz imported, foo bound locally
import foo.bar.baz as fbb  # foo.bar.baz imported and bound as fbb
from foo.bar import baz    # foo.bar.baz imported and bound as baz
from foo import attr       # foo imported and foo.attr bound as attr
```

> import 类似 C(++) 中的 include，Objective-C 中的 import；  
> `from module import class(.method)` 类似 C++ 中命名空间的导入引用（using）。  

If the list of identifiers is replaced by a star ('`*`'), all public names defined in the module are bound in the local namespace for the scope where the import statement occurs.

The wild card form of import — `from module import *` — is only allowed at the **module** level. Attempting to use it in class or function definitions will raise a SyntaxError.

### isort

[isort](https://marketplace.visualstudio.com/items?itemName=ms-python.isort): Import Organization support for python files.

如果 import 库顺序混乱，则可能警告提示：Imports are incorrectly sorted and/or formatted.isort(E)

Quick Fix 将调用 isort Sort Python import definitions alphabetically within logical sections.

## __main__

[`__main__`](https://docs.python.org/3/library/__main__.html#module-__main__) is the name of the scope in which top-level code executes. A module’s `__name__` is set equal to '`__main__`' when read from standard input, a script, or from an interactive prompt.

A module can discover whether or not it is running in the main scope by checking its own `__name__`, which allows a common idiom for conditionally executing code in a module when it is run as a script or with `python -m` but not when it is imported:

```python
if __name__ == "__main__":
    # execute only if run as a script
    main()
```

For a package, the same effect can be achieved by including a `__main__.py` module, the contents of which will be executed when the module is run with `-m`.

```shell
⇒  python -h
usage: python [option] ... [-c cmd | -m mod | file | -] [arg] ...
Options and arguments (and corresponding environment variables):

-m mod : run library module as a script (terminates option list)

```

[Special considerations for __main__](https://docs.python.org/3/reference/import.html#special-considerations-for-main)  

### main entry

```python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import sys


def function(args):
    pass


def main(args):
    function(args)  # do something


# main entry
if __name__ == '__main__':
    print('This program is being run by itself')
    if len(sys.argv) < 2:
        print('please input parameters:')
    else:
        main(sys.argv[1:])
else:
    print('I am being imported from another module')

```

### shebang

!!! abstract "shebang"

    [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)): In computing, a shebang is the character sequence consisting of the characters number sign and exclamation mark (#!) at the beginning of a script. It is also called sharp-exclamation, sha-bang, hashbang, pound-bang, or hash-pling.

[Purpose of #!/usr/bin/python3](https://stackoverflow.com/questions/7670303/purpose-of-usr-bin-python3)  
[Should I put #! (shebang) in Python scripts, and what form should it take?](https://stackoverflow.com/questions/6908143/should-i-put-shebang-in-python-scripts-and-what-form-should-it-take)  

- [Shebang line for Python 2.7](https://stackoverflow.com/questions/21189346/shebang-line-for-python-2-7)：`#!/usr/bin/env python2.7`  
- Shebang line for Python 3：`#!/usr/bin/env python3`  
- compatible with both Python 2.x and 3.x：`#!/usr/bin/env python`  

To be better portable users can use `#!/usr/bin/env python3` which will use the first python3 from the `PATH`.

当执行`chmod a+x code.py` 赋予 python 脚本执行权，则可在终端敲下 `code.py` 或 `./code.py` 像执行 bash shell 脚本那样运行。  
此时，将读取首行的 shebang，找到其指定的 python 版本进行解释执行。

当以 `python code.py` 或 `python3 code.py` 显式指定调用 python(2.7) 或 python3 进行解释执行时，将忽略首行的 shebang。

如果py脚本开头没有指定 Shebang - `#!/usr/bin/env python3`，则 vscode Run Code 执行 `python -u test.py`，可能提示找不到 python 命令。

> macOS 自 Monterey（April 2022）后移除了 Python 2.7。

## test

1. test_module.py  
2. test_modulefinder.py  

## demo

新建一个 resnet1.py 文件：

```python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-


from __future__ import absolute_import
from __future__ import division
from __future__ import print_function


def inference(a, b):
    return a+b

```

再新建一个 train.py 文件，导入 resnet1 模块，调用其中的 inference 函数：

```python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import sys
import importlib
import argparse


def main(args):
    network = importlib.import_module(args.model_def, 'inference')
    c = network.inference(1,2)
    print(c)


def parse_arguments(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('--model_def', 
        type=str, 
        help='Model definition.', 
        default='resnet1')
    return parser.parse_args(argv)


if __name__ == '__main__':
    main(parse_arguments(sys.argv[1:]))

```

## references

[Python导入模块的几种姿势](https://blog.csdn.net/bitcarmanlee/article/details/52825260)  
[python学习之动态导入模块](http://www.cnblogs.com/zy6103/p/6943557.html)：__import__ 和 importlib  
Python中标准模块 importlib [介绍](http://www.cnblogs.com/meishandehaizi/p/5863233.html) 及 [详解](http://www.jb51.net/article/111282.htm)  
[scrapy 中引入源码的 load_object 实现](https://blog.csdn.net/hhczy1003/article/details/76662184)  
[python中from module import * 的一个陷阱](http://www.cnblogs.com/baiyanhuang/p/3855841.html)  
[python中实现动态导入模块 importlib.import_module](http://www.360doc.com/content/17/0608/16/10408243_661106033.shtml)  
[Python 动态导入对象之 importlib.import_module 案例](https://www.aliyun.com/jiaocheng/517064.html)  

[Python Class vs. Module Attributes](https://stackoverflow.com/questions/1250779/python-class-vs-module-attributes)
