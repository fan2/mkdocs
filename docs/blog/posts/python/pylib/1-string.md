---
title: python常用模块之string
authors:
  - xman
date:
    created: 2019-12-06T08:00:00
categories:
    - python
tags:
    - version
comments: true
---

本文简单介绍了 python 中字符串类 string，包括 constants、Formatter 和 Template。

<!-- more -->

`str` 是 built-in string class，`string` 是 A collection of string constants。

## help

模块 [string](https://docs.python.org/3/library/string.html) 定义了一些字符类型集常量：

```Shell
# 或直接输入 help('string')
>>> import string
>>> print(string.__doc__)
A collection of string constants.

Public module variables:

whitespace -- a string containing all ASCII whitespace
ascii_lowercase -- a string containing all ASCII lowercase letters
ascii_uppercase -- a string containing all ASCII uppercase letters
ascii_letters -- a string containing all ASCII letters
digits -- a string containing all ASCII decimal digits
hexdigits -- a string containing all ASCII hexadecimal digits
octdigits -- a string containing all ASCII octal digits
punctuation -- a string containing all ASCII punctuation characters
printable -- a string containing all ASCII characters considered printable

```

```Shell
>>> string.digits
'0123456789'
>>> '5' in string.digits
True

>>> string.hexdigits
'0123456789abcdefABCDEF'
>>> 'f' in string.hexdigits
True
```

## Formatter

Custom String Formatting

The built-in string class provides the ability to do complex variable substitutions and value formatting via the [format()](https://docs.python.org/3/library/stdtypes.html#str.format) method described in [PEP 3101](https://www.python.org/dev/peps/pep-3101).  
The Formatter class in the string module allows you to create and **customize** your own string formatting behaviors using the same implementation as the built-in `format()` method.

```
class string.Formatter
The Formatter class has the following public methods:

format(format_string, *args, **kwargs)
    The primary API method. It takes a format string and an arbitrary set of positional and keyword arguments. It is just a wrapper that calls vformat().

vformat(format_string, args, kwargs)
    This function does the actual work of formatting. It is exposed as a separate function for cases where you want to pass in a predefined dictionary of arguments, rather than unpacking and repacking the dictionary as individual arguments using the *args and **kwargs syntax.
```

## Template

```
CLASSES
    builtins.object
        Formatter
        Template
```

The [string](https://docs.python.org/3/library/string.html#module-string) module provides a [Template](https://docs.python.org/3/library/string.html#string.Template) class that implements these rules. The methods of [Template](https://docs.python.org/3/library/string.html#string.Template) are:

*class* string.**Template**(*template*)

> The constructor takes a single argument which is the template string.

```Shell
>>> from string import Template
>>> s = Template('$who likes $what')
>>> s.substitute(who='tim', what='kung pao')
'tim likes kung pao'
```

[TDW](http://code.tencent.com/tdw.html)（[腾讯的分布式数据仓库](https://blog.csdn.net/johnny_lee/article/details/26673829/)）  [HIVE SQL](http://data.qq.com/article?id=819) 使用了 python 作为流程控制语言，以下摘自某段格式化查询脚本：

```Python
# 模板（大括号可省略）
sql_query_t = 'SELECT * FROM ${db}::${tbl} WHERE time=${date}'
# 格式化替换参数
sql_query = string.Template(sql_query_t).substitute(db='myDB', tbl='myTable', date='20180108')
# 执行 sql
tdwqe.execute(sql_query)
```
