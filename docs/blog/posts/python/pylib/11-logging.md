---
title: python中的日志类——logging
authors:
  - xman
date:
    created: 2019-12-06T09:40:00
categories:
    - python
tags:
    - logging
comments: true
---

本文梳理了 python 中的日志打点模块——logging，介绍了其基本框架和基础惯用法。

<!-- more -->

## print to specified file instead of std.out

[Built-in Functions — print](https://docs.python.org/3/library/functions.html#print)

还记得初识 python 时，向控制台输出 `Hello, World!` 时的激动心情吗？毕竟它为我们开启了一段全新的旅程。
print 也许是大多数人学习 Python 时认识和使用的第一个函数，它让我们得以像屏幕输出信息，打点跟踪程序执行过程。

让我们回过头来再仔细看看 print 函数，其携带了一个关键字参数 file，默认不填时，输出打印到控制台（sys.stdout）。

如果我们不想打印到控制台，可以指定将日志写入到指定文件 file。

```Python
print(*args, sep=' ', end='\n', file=None, flush=False)
    Prints the values to a stream, or to sys.stdout by default.

    sep
      string inserted between values, default a space.
    end
      string appended after the last value, default a newline.
    file
      a file-like object (stream); defaults to the current sys.stdout.
    flush
      whether to forcibly flush the stream.
```

以下代码基于时间整点拼接一个日志文件名，如果文件已存在则追加，否则新建文件。

with open 打开文件区块中的 print 指定 file，写入文件不输出到控制台。
区块前后的 print 没有指定 file，依旧打印到控制台。

```Python
import os, datetime

cur_time = datetime.datetime.now()
str_cur_time = cur_time.strftime('%Y%m%d%H')
log_path = str_cur_time + '.log'
print(f'{log_path = }')
mode = 'ta' if os.path.exists(log_path) else 'tx'
with open(log_path, mode) as log_file:
    for i in range(5):
        print(f'log line {i}', file=log_file)
print('finish')
```

## How to print to both std.out and file?

怎样像 Shell 中的 `command | tee run.log` 将 command 运行结果同时输出到控制台(stdout)和文件(run.log)呢？

[python - How to redirect stdout to both file and console with scripting? - Stack Overflow](https://stackoverflow.com/questions/14906764/how-to-redirect-stdout-to-both-file-and-console-with-scripting)

方案是自定义一个类 Logger，在 write 方法中同时调用写控制台（sys.stdout.write）和写文件。

然后用重载 sys.stdout，将其赋值为 Logger，这样后续调用 print 实际上就调用 Logger.write。

```Python
# Author: Amith Koujalgi, Sanon

class Logger(object):
    def __init__(self):
        self.terminal = sys.stdout

    def write(self, message):
        with open ("logfile.log", "a", encoding = 'utf-8') as self.log:
            self.log.write(message)
        self.terminal.write(message)

    def flush(self):
        #this flush method is needed for python 3 compatibility.
        #this handles the flush command by doing nothing.
        #you might want to specify some extra behavior here.
        pass

sys.stdout = Logger()
```

以下改进版，在 start 中劫持 sys.stdout，在 stop 中恢复原始 sys.stdout。

```Python
"""
Transcript - direct print output to a file, in addition to terminal.
Author: Brian Burns

Usage:
    import transcript
    transcript.start('logfile.log')
    print("inside file")
    transcript.stop()
    print("outside file")
"""

import sys

class Transcript(object):

    def __init__(self, filename):
        self.terminal = sys.stdout
        self.logfile = open(filename, "a")

    def write(self, message):
        self.terminal.write(message)
        self.logfile.write(message)

    def flush(self):
        # this flush method is needed for python 3 compatibility.
        # this handles the flush command by doing nothing.
        # you might want to specify some extra behavior here.
        pass

def start(filename):
    """Start transcript, appending print output to given filename"""
    sys.stdout = Transcript(filename)

def stop():
    """Stop transcript and return print functionality to normal"""
    sys.stdout.logfile.close()
    sys.stdout = sys.stdout.terminal
```

有人提供了支持 with 的 Tee 类：

```Python
# Author: supersolver

import traceback
import sys

# Context manager that copies stdout and any exceptions to a log file
class Tee(object):
    def __init__(self, filename):
        self.file = open(filename, 'w')
        self.stdout = sys.stdout

    def __enter__(self):
        sys.stdout = self

    def __exit__(self, exc_type, exc_value, tb):
        sys.stdout = self.stdout
        if exc_type is not None:
            self.file.write(traceback.format_exc())
        self.file.close()

    def write(self, data):
        self.file.write(data)
        self.stdout.write(data)

    def flush(self):
        self.file.flush()
        self.stdout.flush()

if __name__ == '__main__':
    print("Print")
    with Tee('test.txt'):
        print("Print+Write")
        raise Exception("Test")
    print("Print")
```

## logging - python log system

日志大致上就是收集与程序运行相关的数据，供事后进行追溯、研究和分析。
查看日志是开发人员日常获取信息、排查异常、诊断分析问题的最好途径。

两类日志及其目的（作用）：

- **诊断日志**: 记录应用程序运行过程中的相关操作和状态日志。例如，用户遇到的异常报错信息，可通过检索日志获得上下文信息，从而诊断分析问题。
- **审计日志**: 为商业分析而记录的用户行为日志。从中可提取用户的操作路径和交易信息，结合用户资料可构建用户报告（画像），用来优化商业目标。

现代公司运营的大项目日志系统中，客户端除了支持将本地日志实时输出到控制台和存储落盘外，往往还支持将日志流水旁路一份异步上报到日志服务器。
具体来说，本地日志上报模块定时将日志主动上传到网络日志服务器，服务端日志存储系统搭配在线日志检索平台，可供开发人员远程在线检索诊断分析。

更高级的日志系统中，本地日志上报模块还支持被动上报。具体过程如下：

1. 本地日志上报模块监听预设消息 PUSH 通道（长连接）上服务器下发的日志远程捞取信令。
2. 在线日志平台提出检索需求，指定客户（设备ID或账号ID）信息和时间段，通过消息通道下发日志捞取命令。
3. 客户端在收到日志捞取指令后，收集打包指定时间段的日志，并通过预铺信道（或临时连接）上传日志到服务端。
4. 开发运维人员收到检索平台的捞取成功通知后，在日志平台检索指定客户被动上报的日志，协助远程分析定位问题。

### replace print with logging

调用 print 向屏幕输出信息是一种简单易用的日志形式，可用于打点跟踪程序运行状态。

在下面的代码片段中，使用 print 跟踪 urllib 下载前后的状态，print 指定写日志文件。

```Python
print('Downloading file from URL', url, file=urllib.log)
text = urllib.urlopen(url).read()
print('File successfully downloaded', file=urllib.log)
```

如果程序在下载期间崩溃，这种方法的效果就不会很好。
更安全的做法是，在每条日志语句前后都打开和关闭文件（至少应该在写入后刷新文件）。
专业的做法是使用 Python 标准库中提供的日志模块——logging 替代原始的 print。

> This module defines functions and classes which implement a flexible event logging system for applications and libraries.

> The key benefit of having the logging API provided by a standard library module is that all Python modules can participate in logging, so your application log can include your own messages integrated with messages from third-party modules.

- 日志事件产生的日志记录包含清晰可用的诊断信息，如异常时间、操作路径、文件路径名称、函数名及行号等。
- 可通过 Logger.setLevel() 设定日志级别，有选择地记录日志；或通过设置 Logger.disabled 禁用。
- 包含日志模块的应用，默认可通过根记录器对应用的日志流进行访问，除非你将日志过滤了。

我们可以按照输出终端（Handler）进行分类，也可以按照日志级别（Level）进行分类：

1. 按输出终端进行分类，通常指的是将日志在控制台输出显示，还是将日志存入文件。
2. 日志级别是按 DEBUG、INFO、WARNING、ERROR、CRITICAL 等严重等级划分。

python 的 logging 模块与 Android/Java 中的 log4j 日志系统的机制基本一样，只是具体的实现细节不同。

[Log4j](https://en.wikipedia.org/wiki/Log4j) - [Apache Logging Services](https://logging.apache.org/log4j/)

> Apache Log4j is a Java-based logging utility originally written by Ceki Gülcü. It is part of the Apache Logging Services, a project of the Apache Software Foundation. Log4j is one of several Java logging frameworks.

### logging module

[logging — Logging facility for Python](https://docs.python.org/3/library/logging.html)

- Module [logging.config](https://docs.python.org/3/library/logging.config.html#module-logging.config): Configuration API for the logging module.
- Module [logging.handlers](https://docs.python.org/3/library/logging.handlers.html#sockethandler): Useful handlers included with the logging module.

[Logging HOWTO](https://docs.python.org/3/howto/logging.html#logging-basic-tutorial) - Logging Flow

按照惯例，我们先借助 help 系统一览 logging 提供的 class hierarchy。

主要包括继承自 Filterer 的 `Logger` 类和 `Handler` 类，以及内置的 `Filter` 类和 `Formatter` 类。

```Shell
>>> help(logging)

CLASSES
    builtins.object
        BufferingFormatter
        Filter
        Formatter
        LogRecord
        LoggerAdapter
    Filterer(builtins.object)
        Handler
            NullHandler
            StreamHandler
                FileHandler
        Logger

```

The basic classes defined by the module, together with their functions, are listed below.

- `Loggers` expose the `interface` that application code directly uses.
- `Handlers` send the log records (created by loggers) to the appropriate `destination`.
- `Filters` provide a finer grained facility for determining *which* log records to output.
- `Formatters` specify the `layout` of log records in the final output.

下面对这四个类进行简单梳理：

1. `Logger`：提供日志接口，供应用代码使用。logger 最常用的操作有两类：配置和发送日志消息。

    - 可通过 logging.**getLogger**(name) 获取 logger 对象，如不指定 name 则返回 root 对象。
    - 传入相同的 name 调用 getLogger 方法返回同一个 logger 对象。
    - name 可取模块名称（`__name__`），即按模块 getLogger。

2. `Handler`：将日志记录（LogRecord）发送到合适的目的地（destination），比如控制台、文件、socket 等。

    - 一个 Logger 对象可以通过 **addHandler** 方法添加多个 Handler。
    - 每个 Handler 又可以定义不同的日志级别，以实现日志分级过滤显示、存储落盘或远程上报。

3. `Filter`：为 Logger、Handler 提供的过滤器（钩子），提供一种优雅的方式决定一个日志记录是否发送到 Handler。

    - Logger 和 Handler 两个层级均提供了 **addFilter**/**removeFilter** 接口。
    - Logger 层级的 Filter 将作用于所有 Handler；Handler 也可定制 Filter（覆盖 Logger 的 Filter）。

4. `Formatter`：指定日志记录输出的具体格式。

    - Formatter 的构造方法需要两个参数：消息的格式字符串（fmt）和日期字符串（datefmt），这两个参数都是可选的。
    - 可对 Handler 调用 **setFormatter** 为其设定 Formatter。

The flow of log event information in loggers and handlers is illustrated in the following diagram.

- LogRecord instances are created automatically by the Logger every time something is logged.
- Logger pass LogRecords to Handler for further processing/dispatch.

通过简单梳理 logging 模块涉及的核心类后，我们来看看日志模块的惯用法。

### logging levels

The numeric values of logging levels are given in the following table. These are primarily of interest if you want to define your own levels, and need them to have specific values relative to the predefined levels. If you define a level with the same numeric value, it overwrites the predefined value; the predefined name is lost.

每个日志级别数值间隔 10，我们可以插入自定义的日志级别。

Level | Numeric value | What it means / When to use it
------|---------------|-----------------------------------
`logging.NOTSET` | 0 | When set on a logger, indicates that ancestor loggers are to be consulted to determine the effective level. If that still resolves to NOTSET, then **all** events are logged. When set on a handler, **all** events are handled.
`logging.DEBUG` | 10 | **Detailed** information, typically only of interest to a developer trying to *diagnose* a problem.
`logging.INFO` | 20 | *Confirmation* that things are working as **expected**.
`logging.WARNING` | 30 | An *indication* that something **unexpected** happened, or that a problem might occur in the near future (e.g. ‘disk space low’). The software is still working as expected.
`logging.ERROR` | 40 | Due to a more serious **problem**, the software has not been able to perform some function.
`logging.CRITICAL` | 50 | A serious **error**, indicating that the program itself may be unable to continue running.

### logging.log

logging 模块提供了 log 接口打点指定级别的日志，也可直接调用对应级别的log接口（debug、info、warning、error 和 critical）。

```Shell
logging.disable(level=CRITICAL)
Provides an overriding level level for all loggers which takes precedence over the logger’s own level.

logging.log(level, msg, *args, **kwargs)
Logs a message with level level on the root logger. The other arguments are interpreted as for debug().

logging.debug(msg, *args, **kwargs)
Logs a message with level DEBUG on the root logger. The msg is the message format string, and the args are the arguments which are merged into msg using the string formatting operator. (Note that this means that you can use keywords in the format string, together with a single dictionary argument.)

logging.info(msg, *args, **kwargs)
Logs a message with level INFO on the root logger. The arguments are interpreted as for debug().

logging.warning(msg, *args, **kwargs)
Logs a message with level WARNING on the root logger. The arguments are interpreted as for debug().

logging.error(msg, *args, **kwargs)
Logs a message with level ERROR on the root logger. The arguments are interpreted as for debug().

logging.critical(msg, *args, **kwargs)
Logs a message with level CRITICAL on the root logger. The arguments are interpreted as for debug().
```

### RootLogger

最简单的使用就是导入 logging 后，什么都不用配置，直接调用模块级别的日志打点函数（Module-Level Functions），将日志输出到控制台（相当于 print）。

可以发现 debug、info 日志并未输出，只有 warning 及以上级别的日志才会输出。
默认的日志格式是 `logging.BASIC_FORMAT` = '%(levelname)s:%(name)s:%(message)s'，级别:模块:消息。

```Shell
>>> import logging
>>> logging.debug('debug')
>>> logging.info('info')
>>> logging.warning('warning')
WARNING:root:warning
>>> logging.error('error')
ERROR:root:error
>>> logging.critical('critical')
CRITICAL:root:critical
```

实际上，尽管我们什么都没配置，logging 内部第一次调用日志打点函数时，内部会调用 `basicConfig` 初始化，创建一个 `StreamHandler`/`Formatter` 挂接到默认的 `RootLogger` 上。

```Shell
logging.basicConfig(**kwargs)
Does basic configuration for the logging system by creating a StreamHandler with a default Formatter and adding it to the root logger. The functions debug(), info(), warning(), error() and critical() will call basicConfig() automatically if no handlers are defined for the root logger.
```

- logging.debug() (as well as info(), warning(), error() and critical()) will call `basicConfig`() if the root logger doesn’t have any handler attached.

我们可以调用 `logging.getLogger()` 查看默认的 RootLogger。

> Note that the root logger is created with level WARNING.

```Shell
logging.getLogger(name=None)
Return a logger with the specified name or, if name is None, return a logger which is the root logger of the hierarchy.
```

logging.getLogger() 返回 `RootLogger`，日志级别是 WARNING：

```Shell
>>> logging.getLogger()
<RootLogger root (WARNING)>
```

查看 RootLogger 的 level：

```Shell
>>> rootLogger=logging.getLogger()
>>> rootLogger.level
30
>>> rootLogger.getEffectiveLevel()
30
```

从 logging.log 的帮助文档中，这些接口都是打到 root logger，实际上是调用 RootLogger 的相应接口。因此，上述最简示例等效于：

```Shell
>>> rootLogger.debug('debug')
>>> rootLogger.info('info')
>>> rootLogger.warning('warning')
WARNING:root:warning
>>> rootLogger.error('error')
ERROR:root:error
>>> rootLogger.critical('critical')
CRITICAL:root:critical
```

#### handlers & filters

查看 RootLogger 的 Handlers，即 basicConfig 创建的 `StreamHandler`：

> 从 stream 来看，其本质是一个 TextIOWrapper，但不是写入文件，而是写入 stderr，即输出到控制台（print 默认输出到 stdout）。

```Shell
>>> rootLogger.hasHandlers()
True
>>> rootLogger.handlers
[<StreamHandler <stderr> (NOTSET)>]
>>> defaultStreamHandler.stream
<_io.TextIOWrapper name='<stderr>' mode='w' encoding='utf-8'>
>>> defaultStreamHandler.terminator
'\n'
```

查看 RootLogger 的 Filters（默认没有配置）：

```Shell
>>> rootLogger.filters
[]
```

#### test level & formatter

尝试降低 RootLogger 的日志级别，使其能输出 INFO 及以上级别的信息：

```Shell
>>> rootLogger.setLevel(logging.INFO)
>>> rootLogger.debug('debug')
>>> rootLogger.info('info')
INFO:root:info
>>> rootLogger.warning('warning')
WARNING:root:warning
>>> rootLogger.error('error')
ERROR:root:error
>>> rootLogger.critical('critical')
CRITICAL:root:critical
```

尝试修改 RootLogger 默认 StreamHandler 的日志格式：

```Shell
>>> formatter = logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
>>> defaultStreamHandler.setFormatter(formatter)
>>> rootLogger.info('info')
2024-03-07 16:45:19,645 root         INFO     info
```

当然，以上两步的修改，可以直接调用 logging.basicConfig 配置，然后调用日志接口。

```Shell
>>> import logging
# 一定要在第一次调用 log 日志接口之前调用 basicConfig
>>> logging.basicConfig(level=logging.INFO, format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
>>> logging.debug('debug')
>>> logging.info('info')
2024-03-07 17:26:31,908 root         INFO     info
>>> logging.warning('warning')
2024-03-07 17:26:39,515 root         WARNING  warning
>>> logging.error('error')
2024-03-07 17:26:45,479 root         ERROR    error
>>> logging.critical('critical')
2024-03-07 17:26:51,360 root         CRITICAL critical
```

## practices

[日志（Logging）— 三种配置方式](https://pythonguidecn.readthedocs.io/zh/latest/writing/logging.html)

- 通过INI文件进行配置的例子 - fileConfig
- 通过字典进行配置的例子 - dictConfig
- 通过源码直接配置的例子 - logger, handler, formatter

### several loggers with per handler

CSDN-东华果汁哥 : [Python 日志模块详解及具体应用](https://blog.csdn.net/u013421629/article/details/123715151)

- 按日志级别 getLogger 并指定 FileHandler，落盘到不同的日志文件。
- 没有指定 Formatter，每次自行组装 log_msg 和 error_msg。

以下是 东华果汁哥 封装的 loggers.py，其他模块导入该模块即可使用。

- 由于不同级别的日志落盘到不同的文件，诊断分析某一时间段的日志时，可能要串查多个 log 文件。

```Python
# -*- coding: utf-8 -*-
# author: 东华果汁哥

import os
import time
import logging
import inspect

dt = time.strftime("%Y%m%d")

handlers = {logging.DEBUG: "./log/debug_%s.log" % (dt),
            logging.INFO: "./log/info_%s.log" % (dt),
            logging.WARNING: "./log/warn_%s.log" % (dt),
            logging.ERROR: "./log/error_%s.log" % (dt)}
loggers = {}


def init_loggers():
    for level in handlers.keys():
        path = os.path.abspath(handlers[level])
        handlers[level] = logging.FileHandler(path)
    for level in handlers.keys():
        logger = logging.getLogger(str(level))
        # 如果不指定level，获得的handler似乎是同一个handler
        logger.addHandler(handlers[level])
        logger.setLevel(level)
        loggers.update({level: logger})


# 加载模块时创建全局变量
init_loggers()


def print_now():
    return time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())


def get_log_msg(message):
    return "[%s]  %s" % (print_now(), message)


def get_error_msg(message):
    frame, filename, lineNo, functionName, code, unknowField = inspect.stack()[2]
    return "[%s] [%s - %s - %s] %s" % (print_now(), filename, lineNo, functionName, message)


def info(message):
    message = get_log_msg(message)
    loggers[logging.INFO].info(message)


def error(message):
    message = get_error_msg(message)
    loggers[logging.ERROR].error(message)


def debug(message):
    message = get_log_msg(message)
    loggers[logging.DEBUG].debug(message)


def warn(message):
    message = get_log_msg(message)
    loggers[logging.WARNING].warning(message)
```

### logger with multiple handlers

[Python 日志模块 logging 用法详解](https://cloud.tencent.com/developer/article/1587902)
[Python 日志模块](https://rgb-24bit.github.io/blog/2018/python-logging.html)

下面示例，演示同时将日志输出到控制台和文件中，这也是日常开发过程最常用的日志打点模式。

在控制台（stderr）上只打出 warning 及以上级别的日志，在日志文件中打出 debug 及以上级别的日志。

```Python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import logging

# 建立一个 Streamhandler 来把日志打在控制台上，级别为 WARNING 以上
ch = logging.StreamHandler()
ch.setLevel(logging.WARNING)

# 建立一个 Filehandler 来把日志记录在文件里，级别为 DEBUG 以上
fh = logging.FileHandler("spam.log")
fh.setLevel(logging.DEBUG)

# 设置日志格式，StreamHandler 和 FileHandler 共用
formatter = logging.Formatter(
    "%(asctime)s - %(name)s - %(levelname)s - %(message)s")
ch.setFormatter(formatter)
fh.setFormatter(formatter)

# 将两个 handler 添加到 logger 对象中
logger = logging.getLogger("log_demo")
logger.setLevel(logging.DEBUG)
logger.addHandler(ch)
logger.addHandler(fh)

# 开始打日志
logger.debug("debug message")
logger.info("info message")
logger.warning("warn message")
logger.error("error message")
logger.critical("critical message")
```

以下是运行脚本后，控制台输出和日志文件内容：

```Shell
$ python3 test_logging.py
2024-03-07 17:13:31,969 - log_demo - WARNING - warn message
2024-03-07 17:13:31,969 - log_demo - ERROR - error message
2024-03-07 17:13:31,969 - log_demo - CRITICAL - critical message

$ cat spam.log
2024-03-07 17:13:31,968 - log_demo - DEBUG - debug message
2024-03-07 17:13:31,969 - log_demo - INFO - info message
2024-03-07 17:13:31,969 - log_demo - WARNING - warn message
2024-03-07 17:13:31,969 - log_demo - ERROR - error message
2024-03-07 17:13:31,969 - log_demo - CRITICAL - critical message
```

如果是系统级服务，可考虑将日志记录到操作系统事务日志，参考 `SysLogHandler` 和 `NTEventLogHandler`。

### rich.logging.RichHandler

[Textualize/rich](https://github.com/Textualize/rich) / [README.md](https://github.com/Textualize/rich/blob/master/README.md)

- [documentation](https://rich.readthedocs.io/) - [Logging Handler](https://rich.readthedocs.io/en/stable/logging.html)

You can also use the builtin Handler class to format and colorize output from Python's logging module. Here's an example of the output:

- The RichHandler class may be configured to use Rich's `Traceback` class to format exceptions, which provides more context than a built-in exception. To get beautiful exceptions in your logs set `rich_tracebacks=True` on the handler constructor:

Rich 可以替代标准日志模块，为日志添加颜色和格式，不同级别的日志一目了然。上面创建的 StreamHandler 用于将日志打在控制台上，可以构造一个 rich.logging.RichHandler 替代之。

> RichHandler 构造函数支持传入 `rich_tracebacks=True` 以便使用 rich.traceback 输出异常堆栈。

```python
import logging
from rich.logging import RichHandler

# 使用 RichHandler 替换 StreamHandler，指定时间戳精确到毫秒
ch = RichHandler(rich_tracebacks=True, log_time_format="%Y-%m-%d, %H:%M:%S,%f")
ch.setLevel(logging.WARNING)

# ...

# 将 RichHandler 添加到 logger 对象中
logger.addHandler(ch)
```

### Bypass to the log server

现代日志系统中，可能还要旁路一份上传到日志服务器。

- 如果知道日志服务器的监听端口，可以采用 `SocketHandler` 和 `DatagramHandler` 连接服务器，再调用 send 接口上传。

    - 如果服务端提供的是 HTTP CGI 日志上报接口，则可以采用 `HTTPHandler`。

- 如果将日志上报的同时，对于 WARNING 及以上级别的日志组织发送告警邮件，那么可以考虑 SMTPHandler 连接邮箱服务器发送邮件。

## refs

[Does python logging replace print? - Stack Overflow](https://stackoverflow.com/questions/26658280/does-python-logging-replace-print)

[Make it easy to replace print() calls with logging calls · Issue #66391 · python/cpython](https://github.com/python/cpython/issues/66391)

[Stop Using “Print” and Start Using “Logging” | by Naser Tamimi | Towards Data Science](https://towardsdatascience.com/stop-using-print-and-start-using-logging-a3f50bc8ab0)

[1万字详解 python logging日志模块 - FooFish](https://foofish.net/logging.html)
[Python中Logging 日志模块（最详细完整版） - 知乎](https://zhuanlan.zhihu.com/p/476549020)
