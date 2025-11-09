---
title: python常用模块之print加强版——pprint
authors:
  - xman
date:
    created: 2019-12-06T08:10:00
categories:
    - python
tags:
    - version
comments: true
---

本文简单介绍了 python 中 print 加强版 pprint 的用法。

<!-- more -->

[pprint — Data pretty printer](https://docs.python.org/3/library/pprint.html)  
[pprint --- 数据美化输出](https://docs.python.org/zh-cn/3/library/pprint.html)  

从 help(pprint) 中的函数原型来看：

1. `pprint` 当信息超过80个字符时将分行显示，还可通过 ident 设置分行缩进。
2. 如果不需要指定 stream、indent、width、depth、compact 等控制信息，可采用简易接口 `pp` 即可。

```Shell
>>> help(pprint)

FUNCTIONS

    pp(object, *args, sort_dicts=False, **kwargs)
        Pretty-print a Python object

    pprint(object, stream=None, indent=1, width=80, depth=None, *, compact=False, sort_dicts=True)
        Pretty-print a Python object to a stream [default is sys.stdout].
```

- [Python - Pretty Print Numbers](https://www.tutorialspoint.com/python_text_processing/python_pretty_prints.htm)
- [打印 Python 的一切 —— pprint & beeprint](https://zhuanlan.zhihu.com/p/42504137)

## list

以下示例，通过简单列表推导，调用 pprint.pp 打印内建模块 builtins 中的符号列表。

```Shell
>>> import builtins, pprint
>>> builtin_sym=[n for n in dir(builtins) if not n.startswith('_')]
>>> pprint.pp(builtin_sym)
```

以下示例，通过简单列表推导，过滤列表list公用接口，并分别用 print、pprint 打印符号列表。

```Python
import pprint


list_all = [n for n in dir(list) if not n.startswith('_')]
print(list_all)
pprint.pp(list_all)
```

print 在一行打印整个列表，而 pprint 则在每一行输出一个列表项：

```
['append', 'clear', 'copy', 'count', 'extend', 'index', 'insert', 'pop', 'remove', 'reverse', 'sort']

['append',
 'clear',
 'copy',
 'count',
 'extend',
 'index',
 'insert',
 'pop',
 'remove',
 'reverse',
 'sort']
```

以下示例，分别用 print、pprint 打印 string 模块向外导出的符号列表：

```Python
import pprint
import string


print(string.__all__)
pprint.pprint(string.__all__, indent=4)
```

```
['ascii_letters', 'ascii_lowercase', 'ascii_uppercase', 'capwords', 'digits', 'hexdigits', 'octdigits', 'printable', 'punctuation', 'whitespace', 'Formatter', 'Template']

[   'ascii_letters',
    'ascii_lowercase',
    'ascii_uppercase',
    'capwords',
    'digits',
    'hexdigits',
    'octdigits',
    'printable',
    'punctuation',
    'whitespace',
    'Formatter',
    'Template']
```

以下示例，分别用 print、pprint 打印 sys.path：

```Python
import pprint
import sys


print(sys.path)
pprint.pp(sys.path)
```

对于长列表，pprint 更方便地逐行查看每个元素：

```
['', '/usr/local/Cellar/python@3.10/3.10.8/Frameworks/Python.framework/Versions/3.10/lib/python310.zip', '/usr/local/Cellar/python@3.10/3.10.8/Frameworks/Python.framework/Versions/3.10/lib/python3.10', '/usr/local/Cellar/python@3.10/3.10.8/Frameworks/Python.framework/Versions/3.10/lib/python3.10/lib-dynload', '/usr/local/lib/python3.10/site-packages', '/usr/local/Cellar/pygments/2.13.0/libexec/lib/python3.10/site-packages']

['',
 '/usr/local/Cellar/python@3.10/3.10.8/Frameworks/Python.framework/Versions/3.10/lib/python310.zip',
 '/usr/local/Cellar/python@3.10/3.10.8/Frameworks/Python.framework/Versions/3.10/lib/python3.10',
 '/usr/local/Cellar/python@3.10/3.10.8/Frameworks/Python.framework/Versions/3.10/lib/python3.10/lib-dynload',
 '/usr/local/lib/python3.10/site-packages',
 '/usr/local/Cellar/pygments/2.13.0/libexec/lib/python3.10/site-packages']
```

## dict

以下示例，分别用 print、pprint 打印字典 dict 对象：

```Python
import pprint


d = {'foo': 1, 'bar': 2, 'foobar': 3}
print(d)
pprint.pprint(d)
```

pprint 打印字典时，会在计算其显示形式前会先根据键来排序。

```
{'foo': 1, 'bar': 2, 'foobar': 3}

{'bar': 2, 'foo': 1, 'foobar': 3}
```

以下示例，分别用 print、pprint 打印Python 实现信息字典对象：

```Python
import pprint
import sys


print(sys.implementation.__dict__)
pprint.pprint(sys.implementation.__dict__)
```

对于长字典，pprint 更方便地逐行查看每个item：

```
{'name': 'cpython', 'cache_tag': 'cpython-310', 'version': sys.version_info(major=3, minor=10, micro=8, releaselevel='final', serial=0), 'hexversion': 50989296, '_multiarch': 'darwin'}

{'_multiarch': 'darwin',
 'cache_tag': 'cpython-310',
 'hexversion': 50989296,
 'name': 'cpython',
 'version': sys.version_info(major=3, minor=10, micro=8, releaselevel='final', serial=0)}
```

## rich.pretty

[Textualize/rich](https://github.com/Textualize/rich) / [README.md](https://github.com/Textualize/rich/blob/master/README.md)

```bash
>>> import requests, rich
>>> r = requests.get('http://ipinfo.io')
>>> print(r.json())
{'ip': '119.237.98.88', 'hostname': 'n1192379888.netvigator.com', 'city': 'Hong Kong', 'region': 'Hong Kong', 'country': 'HK', 'loc': '22.3735, 114.1791', 'org': 'AS4760 HKT Limited', 'postal': '999077', 'timezone': 'Asia/Hong_Kong', 'readme': 'https://ipinfo.io/missingauth'}
```

Use `rich.print` or `rich.console.Console().print` to dump json dict:

```bash
>>> rich.print(r.json())
{
    'ip': '119.237.98.88',
    'hostname': 'n1192379888.netvigator.com',
    'city': 'Hong Kong',
    'region': 'Hong Kong',
    'country': 'HK',
    'loc': '22.3735, 114.1791',
    'org': 'AS4760 HKT Limited',
    'postal': '999077',
    'timezone': 'Asia/Hong_Kong',
    'readme': 'https://ipinfo.io/missingauth'
}
```

[documentation](https://rich.readthedocs.io/) / [rich.console](https://rich.readthedocs.io/en/latest/reference/console.html#rich.console.Console)

- `Console.print_json`: Pretty prints JSON *str*. Output will be valid JSON.

```bash
>>> rich.console.Console().print_json(r.text)
{
  "ip": "119.237.98.88",
  "hostname": "n1192379888.netvigator.com",
  "city": "Hong Kong",
  "region": "Hong Kong",
  "country": "HK",
  "loc": "22.3735, 114.1791",
  "org": "AS4760 HKT Limited",
  "postal": "999077",
  "timezone": "Asia/Hong_Kong",
  "readme": "https://ipinfo.io/missingauth"
}
```

- [documentation](https://rich.readthedocs.io/) / [rich.pretty](https://rich.readthedocs.io/en/stable/pretty.html)

The `pprint()` method offers a few more arguments you can use to tweak how objects are pretty printed.

```bash
>>> rich.pretty.pprint(r.json())
{
│   'ip': '119.237.98.88',
│   'hostname': 'n1192379888.netvigator.com',
│   'city': 'Hong Kong',
│   'region': 'Hong Kong',
│   'country': 'HK',
│   'loc': '22.3735, 114.1791',
│   'org': 'AS4760 HKT Limited',
│   'postal': '999077',
│   'timezone': 'Asia/Hong_Kong',
│   'readme': 'https://ipinfo.io/missingauth'
}
```
