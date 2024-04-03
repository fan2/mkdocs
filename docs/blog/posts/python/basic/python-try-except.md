---
title: python之异常捕获(try...except)
authors:
  - xman
date:
    created: 2019-12-05T08:00:00
categories:
    - python
tags:
    - try
    - except
comments: true
---

本文简单介绍了 python 中的异常捕获。

<!-- more -->

[Python try…except 异常处理模块](http://www.cnblogs.com/Alanpy/articles/5056566.html)  
[Python 异常处理 try...except、raise](http://www.cnblogs.com/Lival/p/6203111.html)  
[python中的try/except/else/finally语句](http://www.cnblogs.com/windlazio/archive/2013/01/24/2874417.html)  

## PEP

[doc 网站](https://www.python.org/doc/) 搜索 `except`：

[PEP 341 -- Unifying try-except and try-finally](https://www.python.org/dev/peps/pep-0341/)

### Abstract

```
try:
    <do something>
except Exception:
    <handle the error>
finally:
    <cleanup>
```

### Rationale/Proposal

```
try:
    <suite 1>
except Ex1:
    <suite 2>
<more except: clauses>
else:
    <suite 3>
finally:
    <suite 4>
```

## Reference

控制台执行 `help('except')`：

```
Before an except clause’s suite is executed, details about the
exception are stored in the "sys" module and can be accessed via
"sys.exc_info()". "sys.exc_info()" returns a 3-tuple consisting of the
exception class, the exception instance and a traceback object (see
section The standard type hierarchy) identifying the point in the
program where the exception occurred.  "sys.exc_info()" values are
restored to their previous values (before the call) when returning
from a function that handled an exception.

Related help topics: EXCEPTIONS
```

控制台执行 `help('EXCEPTIONS')`：

```
Exceptions are a means of breaking out of the normal flow of control
of a code block in order to handle errors or other exceptional
conditions.  An exception is *raised* at the point where the error is
detected; it may be *handled* by the surrounding code block or by any
code block that directly or indirectly invoked the code block where
the error occurred.

Related help topics: try, except, finally, raise
```

或在 [The Python Language Reference](https://docs.python.org/3/reference/index.html) 搜索 `Exceptions`。

## Library

[The Python Standard Library](https://docs.python.org/3/library/index.html) 搜索 `Exceptions`

相关库介绍：[Built-in Exceptions](https://docs.python.org/3/library/exceptions.html)

其中列举了常见异常继承体系：Exception hierarchy。

执行 `help(BaseException)` 查看基本元素：

```
 |  ----------------------------------------------------------------------
 |  Data descriptors defined here:
 |
 |  __cause__
 |      exception cause
 |
 |  __context__
 |      exception context
 |
 |  __dict__
 |
 |  __suppress_context__
 |
 |  __traceback__
 |
 |  args
```

## Tutorial

在 [The Python Tutorial](https://docs.python.org/3.6/tutorial/) 搜索 `Exceptions`

相关教程：[Errors and Exceptions](https://docs.python.org/3/tutorial/errors.html)

## demos

```
try:
    mbr_log_file = open('nosuchfile.md')
except Exception as exc:
    print(exc)
except:
    print('A exception flew by!')
    raise
finally:
    # sys.exit()
    print('finally')
```

当前工作目录下不存在指定文件时，执行结果如下：

```
[Errno 2] No such file or directory: 'nosuchfile.md'
finally
```

第一个 except 语句捕获通用的 `Exception` 并打印出来。
第二个 except 语句没有指定具体的异常对象类型，按默认异常处理。

从 BaseException 的继承体系可知，可以用扩号指定其他三类异常 tuple，并统称别名为 exc：

```
except (SystemExit, KeyboardInterrupt, GeneratorExit) as exc:
```

第3个 except 也可以换成 else 声明，打印一句 `A exception flew by!` 后，调用 `raise` 抛回给系统执行默认处理。

### exc_info

如果 except 后面不指定具体的异常类型，可以打印 `sys.exc_info()` 三元组（3-tuple）获取相关异常信息：

```
import sys

try:
    mbr_log_file = open('nosuchfile.md')
except:
    print(sys.exc_info()[0]) # exception class
    print(sys.exc_info()[1]) # exception instance
    # print(sys.exc_info()[2]) # traceback object
finally:
    # sys.exit()
    print('finally')
```

执行结果：

```
<class 'FileNotFoundError'>
[Errno 2] No such file or directory: 'nosuchfile.md'
finally
```

### [UnicodeDecodeError](https://stackoverflow.com/questions/8898294/convert-utf-8-with-bom-to-utf-8-with-no-bom-in-python)

As for guessing the encoding, then you can just loop through the encoding from most to least specific:

```
def decode(s):
    for encoding in "utf-8-sig", "utf-16":
        try:
            return s.decode(encoding)
        except UnicodeDecodeError:
            continue
    return s.decode("ISO-8859-1") # fallback, will always work
```

An `UTF-16` encoded file wont decode as `UTF-8`, so we try with `UTF-8` first. If that fails, then we try with `UTF-16`. 
Finally, we use `ISO-8859-1` — this will always work since all 256 bytes are legal values in `ISO-8859-1`.
