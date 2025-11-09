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

[Built-in Exceptions](https://docs.python.org/3/library/exceptions.html)

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
Before an except clause's suite is executed, details about the
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

### FileNotFoundError

```python
def catch_FileNotFoundError():
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

### KeyboardInterrupt

程序运行过程中，按键 Ctrl+C 触发的 SIGINT 中断信号可以通过 except `KeyboardInterrupt` 捕获。

- [How To Catch A Keyboardinterrupt in Python - GeeksforGeeks](https://www.geeksforgeeks.org/python/how-to-catch-a-keyboardinterrupt-in-python/)
- [error handling - Capture Control-C in Python - Stack Overflow](https://stackoverflow.com/questions/15318208/capture-control-c-in-python)
- [Catching KeyboardInterrupt in Python during program shutdown - Stack Overflow](https://stackoverflow.com/questions/21120947/catching-keyboardinterrupt-in-python-during-program-shutdown)

```python
import sys

try:
    # Your main program code or a long-running loop goes here
    while True:
        print("Program running... Press Ctrl+C to exit.")
        # Simulate some work
        import time
        time.sleep(1)
except KeyboardInterrupt:
    print("\nCtrl+C detected! Performing cleanup before exiting...")
    # Add any cleanup code here, such as closing files,
    # saving data, stopping threads, etc.
    print("Cleanup complete. Exiting gracefully.")
finally:
    # Exit due to a SIGINT
    sys.exit(130)
```

### UnicodeDecodeError

[utf 8 - Convert UTF-8 with BOM to UTF-8 with no BOM in Python - Stack Overflow](https://stackoverflow.com/questions/8898294/convert-utf-8-with-bom-to-utf-8-with-no-bom-in-python)

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

## exc_info

### sys.exc_info

如果 except 后面不指定具体的异常类型，可以打印 `sys.exc_info()` 三元组（3-tuple）获取相关异常信息：

1. inspect 查看 sys.exc_info 说明：

```bash
>>> rich.inspect(sys.exc_info, help=True)
╭───────────────────── <built-in function exc_info> ─────────────────────╮
│ def exc_info():                                                        │
│                                                                        │
│ Return current exception information: (type, value, traceback).        │
│                                                                        │
│ Return information about the most recent exception caught by an except │
│ clause in the current stack frame or in an older stack frame.          │
│                                                                        │
│ 30 attribute(s) not shown. Run inspect(inspect) for options.           │
╰────────────────────────────────────────────────────────────────────────╯
```

2. 捕获打印 sys.exc_info 示例：

```python
import sys

def catch_FileNotFoundError():
    try:
        mbr_log_file = open('nosuchfile.md')
    except Exception:
        print(sys.exc_info()[0]) # exception class
        print(sys.exc_info()[1]) # exception instance
        # print(sys.exc_info()[2]) # traceback object
    finally:
        # sys.exit()
```

执行结果：

```bash
<class 'FileNotFoundError'>
[Errno 2] No such file or directory: 'nosuchfile.md'
finally
```

### rich print_exception

[Textualize/rich](https://github.com/Textualize/rich) / [README.md](https://github.com/Textualize/rich/blob/master/README.md)

- [documentation](https://rich.readthedocs.io/) / [rich.console](https://rich.readthedocs.io/en/latest/reference/console.html#rich.console.Console)

- `Console.print_exception`: Prints a rich render of the last exception and traceback.

You can use Rich to print a traceback for an exception that you have caught within a `try...except` block, using the `Console.print_exception()` method.

```python
from rich import console

def divide(a, b):
    try:
        r = a / b
        print(f'{a} / {b} = {r}')
    except Exception:
        console.Console().print_exception(show_locals=True)

if __name__ == '__main__':
    divide(10, 0)
```

执行结果：

```bash
╭─────────────────────────────── Traceback (most recent call last) ────────────────────────────────╮
│ /Users/cliff/Projects/python/test/test.py:20 in divide                                           │
│                                                                                                  │
│   17                                                                                             │
│   18 def divide(a, b):                                                                           │
│   19 │   try:                                                                                    │
│ ❱ 20 │   │   r = a / b                                                                           │
│   21 │   │   print(f'{a} / {b} = {r}')                                                           │
│   22 │   except Exception:                                                                       │
│   23 │   │   console.Console().print_exception(show_locals=True)                                 │
│                                                                                                  │
│ ╭─ locals ─╮                                                                                     │
│ │ a = 10   │                                                                                     │
│ │ b = 0    │                                                                                     │
│ ╰──────────╯                                                                                     │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
ZeroDivisionError: division by zero
```

## rich.traceback

[Textualize/rich](https://github.com/Textualize/rich) / [README.md](https://github.com/Textualize/rich/blob/master/README.md)

- [documentation](https://rich.readthedocs.io/) / [Traceback](https://rich.readthedocs.io/en/latest/traceback.html)

Rich can render beautiful tracebacks which are easier to read and show more code than standard Python tracebacks. You can set Rich as the default traceback handler so all uncaught exceptions will be rendered by Rich.

Rich can be installed as the default traceback handler so that all uncaught exceptions will be rendered with highlighting. Here's how:

```python
from rich.traceback import install
install(show_locals=True)
```

There are a few options to configure the traceback handler, see [install()](https://rich.readthedocs.io/en/latest/reference/traceback.html#rich.traceback.install) for details.

As well as using the `print_exception()` method to print a traceback for the current exception being handled manually, you can also call `install()` to set Rich as the *default* handler for *all* subsequent uncaught exceptions in your program, providing enhanced tracebacks automatically.

```python
from rich.traceback import install

# Example of an uncaught exception
def risky_function(a, b):
    result = a / b
    return result

if __name__ == '__main__':
    # Install the Rich traceback handler
    # The 'show_locals=True' option displays local variables for each frame (optional)
    install(show_locals=True)

    # This will now trigger the Rich-formatted traceback
    risky_function(10, 0)
```
