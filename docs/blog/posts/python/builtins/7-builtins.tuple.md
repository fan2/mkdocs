---
title: python内置模块之元组(tuple)
authors:
  - xman
date:
    created: 2019-12-04T09:00:00
categories:
    - python
tags:
    - tuple
comments: true
---

Python内置模块中的元组（builtins.tuple）的基本用法。

<!-- more -->

[tuple](https://docs.python.org/3/library/stdtypes.html#tuple)（元组）

列表是可以修改的，非常适合用于存储在程序运行期间可能变化的数据集。  
然而，有时候你需要创建一系列不可修改的元素， 元组可以满足这种需求。  
Python将不能修改的值称为`不可变的`，而不可变的列表被称为**元组**。  

## help

```Shell
>>> help(tuple)

Help on class tuple in module builtins:

class tuple(object)
 |  tuple(iterable=(), /)
 |
 |  Built-in immutable sequence.
 |
 |  If no argument is given, the constructor returns an empty tuple.
 |  If iterable is specified the tuple is initialized from iterable's items.
 |
 |  If the argument is a tuple, the return value is the same object.
 |
 |  Built-in subclasses:
 |      asyncgen_hooks
 |      UnraisableHookArgs
```

## demo

```shell
>>> range1=range(1,8)
>>> tuple1=tuple(range1)
>>> tuple1
(1, 2, 3, 4, 5, 6, 7)
>>> tuple1[-1]
7
>>> tuple1[-1]=8
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: 'tuple' object does not support item assignment
>>>
```

## init

元组看起来犹如列表，但使用圆括号而不是方括号来标识。

1. `t=tuple()`: 构造一个空元组对象。  
2. `t=()`：小括号定义空元组。  

多个元素之间以逗号分隔，例如 `t1=(1,2,3,4)`。  

定义 tuple 时，也可不加小括号：

```Python
labels = 'first', 'middle', 'last'
type(labels) # <class 'tuple'>
labels # ('first', 'middle', 'last')
```

以下基于内置函数format、str的C printf格式化和f-string打印255的三种十六进制，在一行中用逗号分隔，输出 tuple:

```Shell
>>> format(255, '#x'), format(255, 'x'), format(255, 'X')
('0xff', 'ff', 'FF')

>>> '%#x' % 255, '%x' % 255, '%X' % 255
('0xff', 'ff', 'FF')

>>> f'{255:#x}', f'{255:x}', f'{255:X}'
('0xff', 'ff', 'FF')
```

元组支持基于脚标索引访问元素（access through subscripted index）。

## zip

```Shell
Help on class zip in module builtins:

class zip(object)
 |  zip(*iterables, strict=False) --> Yield tuples until an input is exhausted.
 |
 |     >>> list(zip('abcdefg', range(3), range(4)))
 |     [('a', 0, 0), ('b', 1, 1), ('c', 2, 2)]
 |
 |  The zip object yields n-length tuples, where n is the number of iterables
 |  passed as positional arguments to zip().  The i-th element in every tuple
 |  comes from the i-th iterable argument to zip().  This continues until the
 |  shortest argument is exhausted.
```

内置函数 zip 将传入的可迭代序列，每个序列选取一个元素生成tuple。

```Shell
>>> list(zip('abc', '123', [4,5,6]))
[('a', '1', 4), ('b', '2', 5), ('c', '3', 6)]

# 第一个参数多出一个元素
>>> list(zip('abcd', '123', [4,5,6]))
[('a', '1', 4), ('b', '2', 5), ('c', '3', 6)]

# 第二个参数多出一个元素
>>> list(zip('abc', '1234', [4,5,6]))
[('a', '1', 4), ('b', '2', 5), ('c', '3', 6)]

# 第二、三个参数各多出一个元素
>>> list(zip('abc', '1234', [4,5,6,7]))
[('a', '1', 4), ('b', '2', 5), ('c', '3', 6)]
```

以下是应用 zip 函数的另外一个案例：

```Shell
>>> labels = 'first', 'middle', 'last'
>>> full_name = 'Magnus Lie Hetland'
>>> names = full_name.split()
>>> for label, name in zip(labels, names):
...     print('{}: {}'.format(label, name))
...
first: Magnus
middle: Lie
last: Hetland
```

## expressions

- `len(t)`: Return the number of elements in tuple t.  
- `e in t`: Test e for membership in t.  
- `e not in t`: Test e for non-membership in t.  
- `for e in t`: enumerate elements in t.  

## comparison

Python 中支持直接对数值tuple序列比较大小：

```Shell
>>> t1=(1,3,5)
>>> t2=(2,4,6)
>>> t1<t2
True
>>> t3=(1,2,6)
>>> t1<t3
False
```

通过 sys 获取 python 版本号：tuple(sys.version_info) = (3, 9, 6, 'final', 0)，可直接与预期版本tuple进行比较匹配。

```Python
tuple(sys.version_info) > (3, 9, 6)
```

实际上，Python 中也支持直接对数值list序列比较大小：

```Shell
>>> l1=[1,3,5]
>>> l2=[2,4,6]
>>> l1<l2
True
>>> l3=[1,2,6]
>>> l1<l3
False
```
