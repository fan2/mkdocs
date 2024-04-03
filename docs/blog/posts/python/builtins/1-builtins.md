---
title: python内置模块一览
authors:
  - xman
date:
    created: 2019-12-04T08:00:00
categories:
    - python
tags:
    - builtins
comments: true
---

Python内置模块 builtins 概览，dir(builtins) 分类梳理一览。

<!-- more -->

[Built-in Functions](https://docs.python.org/3/library/functions.html)

## id

builtins.dir  

builtins.id  
builtins.hash  
builtins.type  

builtins.isinstance  
builtins.issubclass  

builtins.hasattr  
builtins.getattr  

## vars

builtins.vars  
builtins.locals  
builtins.globals  

argparse 解析参数 `args = argparser.parse_args()`，调用 print(args) 打印出来的是 Namespace：

```
Namespace(debug=False, logpath='logs/19.09.30.14-MBR.log', platform=1)
```

调用 print(vars(args)) 以字典形式打印 `object.__dict__`：

```
{'platform': 1, 'logpath': 'logs/19.09.30.14-MBR.log', 'debug': False}
```

## types

### None

builtins.None  
builtins.Ellipsis # 省略号  

### bool

builtins.bool  
builtins.False  
builtins.True  

builtins.any # 一组值中只要有一个为 True。

- bool(x) 传入数值 0 为 False，传入非 0 值为 True。  
- bool(x) 传入空对象 None 为 False，传入非空对象为 True。  

### Sequence Types

builtins.str - Text Sequence  

builtins.list # array  
builtins.tuple  
builtins.range  

builtins.slice  

### Mapping Types

builtins.dict  
builtins.map  

### Set Types

builtins.set  
builtins.frozenset  

### Binary Sequence Types

builtins.bytes  
builtins.bytearray  
builtins.memoryview  

## len & filter

builtins.len # 对字符串、列表等序列化数据集合求取长度（size）。

builtins.reversed  
builtins.filter  
builtins.sorted  

builtins.zip  

## iterate

### enumerate

builtins.enumerate  

help(enumerate) 查看相关帮助：

```
class enumerate(object)
 |  enumerate(iterable, start=0)
 |
 |  Return an enumerate object.
 |
 |    iterable
 |      an object supporting iteration
 |
 |  The enumerate object yields pairs containing a count (from start, which
 |  defaults to zero) and a value yielded by the iterable argument.
 |
 |  enumerate is useful for obtaining an indexed list:
 |      (0, seq[0]), (1, seq[1]), (2, seq[2]), ...
```

枚举列表的索引与值。

对 enumerate 返回的对象转换为list，可知其内为 (index, value) 的 tuple 数组。

```
>>> l = [1,2,3,4]
>>> el = enumerate(l)
>>> list(el)
[(0, 1), (1, 2), (2, 3), (3, 4)]
```

for 循环遍历取 tuple 二维元素值：

```
>>> for i,e in enumerate(l):
...     print('l[%d] = %d' % (i, e))
...
l[0] = 1
l[1] = 2
l[2] = 3
l[3] = 4
```

### iter & next

builtins.iter  
builtins.next  

```
mytuple = ("apple", "banana", "cherry")
myit = iter(mytuple)

print(next(myit))
print(next(myit))
print(next(myit))
print(next(myit)) #StopIteration Exception!!!
```

## open

builtins.open  

builtins.eval  
builtins.exec  

## warning/error

builtins.Warning  
builtins.UserWarning  

builtins.IndexError  
builtins.FileExistsError  
builtins.FileNotFoundError  

builtins.TypeError  
builtins.ValueError  

[Built-in Exceptions](https://docs.python.org/3/library/exceptions.html)  
[warnings — Warning control](https://docs.python.org/3/library/warnings.html?highlight=warning#module-warnings)  

## refs

[30段极简Python代码](http://www.raincent.com/content-85-14066-1.html)
