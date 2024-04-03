---
title: python内置模块--builtins
authors:
  - xman
date:
    created: 2019-12-03T08:30:00
categories:
    - python
tags:
    - builtins
comments: true
---

Python内置模块 builtins 概览，包括常见 FUNCTIONS 和基础 CLASSES。

<!-- more -->

打印 `sys.builtin_module_names` 可查看 python 解释器自带的基础模块：

```Shell
>>> import sys
>>> sys.builtin_module_names
('_ast', '_codecs', '_collections', '_functools', '_imp', '_io', '_locale', '_operator', '_signal', '_sre', '_stat', '_string', '_symtable', '_thread', '_tracemalloc', '_warnings', '_weakref', 'atexit', 'builtins', 'errno', 'faulthandler', 'gc', 'itertools', 'marshal', 'posix', 'pwd', 'sys', 'time', 'xxsubtype', 'zipimport')
```

> A tuple of strings giving the names of all modules that are compiled into this Python interpreter.

## builtins

在 python help utility 交互控制台中，直接输入 builtins 可查看模块帮助。  
在 python 交互控制台中，则先执行 `import builtins` 导入 builtins 模块，再调用 `help(builtins)` 查看模块帮助。

```Shell
>>> import builtins
>>> help(builtins)

Help on built-in module builtins:

NAME
    builtins - Built-in functions, exceptions, and other objects.

DESCRIPTION
    Noteworthy: None is the `nil' object; Ellipsis represents `...' in slices.

```

- 执行 `print(builtins.__doc__)` 查看模块概要：

```Shell
>>> import builtins
>>> print(builtins.__doc__)
Built-in functions, exceptions, and other objects.

Noteworthy: None is the `nil' object; Ellipsis represents `...' in slices.
```

- 执行 `dir(builtins)` 查看模块：

```Shell
>>> import builtins
>>> dir(builtins)
```

	> 也可执行 `print(builtins.__dict__)` 打印 builtins 模块的符号表。

[Understanding Data Types in Python](https://jakevdp.github.io/PythonDataScienceHandbook/02.01-understanding-data-types.html)

以下先过滤内置模块中的公开符号，然后再进一步过滤出以“is”开头的判断接口：

```Shell
>>> [n for n in dir(builtins) if not n.startswith('_') and n.startswith('is')]
['isinstance', 'issubclass']
```

## FUNCTIONS

builtins 模块提供了一些常用的内置函数（[FUNCTIONS](https://docs.python.org/3/library/functions.html)），大概分为 vars、math、utility 三类：

### vars

```Shell
    globals()
        Return the dictionary containing the current scope's global variables.

    locals()
        Return a dictionary containing the current scope's local variables.

    vars(...)
        vars([object]) -> dictionary
        
        Without arguments, equivalent to locals().
        With an argument, equivalent to object.__dict__.
```

### math

```
    abs(x, /)
        Return the absolute value of the argument.

    divmod(x, y, /)
        Return the tuple (x//y, x%y).  Invariant: div*y + mod == x.

    max(...)

    min(...)

    pow(x, y, z=None, /)
        Equivalent to x**y (with two arguments) or x**y % z (with three arguments)

    round(...)
        round(number[, ndigits]) -> number

    sorted(iterable, /, *, key=None, reverse=False)
        Return a new list containing all items from the iterable in ascending order.

    sum(iterable, start=0, /)
        Return the sum of a 'start' value (default: 0) plus an iterable of numbers

```

更多可参考 [math](https://docs.python.org/3/library/math.html)、[cmath](https://docs.python.org/3/library/cmath.html#module-cmath) 等 C 标准的数学库模块，或安装更专业的第三方科学计算库 [SciPy](https://www.scipy.org/) 组织提供的 SciPy 和 NumPy。  

### inspect.isbuiltin

由于 python3 控制台 REPL 默认导入了 builtins 模块，因此可以直接输入函数符号名，如下显示则为内置函数：

```Shell
>>> len
<built-in function len>
>>> open
<built-in function open>
>>> print
<built-in function print>
```

另外，也可通过 `inspect.isbuiltin(object)` 判断 object 是否为内置函数：

```Shell
inspect.isbuiltin(object)
Return true if the object is a built-in function or a bound built-in method.
```

示例如下：

```Shell
>>> inspect.isbuiltin(print)
True
>>> inspect.isbuiltin(len)
True
>>> inspect.isbuiltin(hex)
True
>>> inspect.isbuiltin(str)
False
>>> inspect.isbuiltin(string)
False
```

### inspect in builtins

由于 python3 控制台 REPL 默认导入了 builtins 模块，因此可以直接输入类名，根据输出的提示信息判断是否为内建模块：

str 为内建类型（在 builtins 模块中），string 不是内建类型（但是标准库）：

```
>>> str
<class 'str'>

>>> string
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'string' is not defined
```

enumerate 为内建类型，enum 不是内建类型：

```
>>> enum
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'enum' is not defined

>>> enumerate
<class 'enumerate'>
```

date 和 datetime 非内建类型：

```
>>> date
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'date' is not defined

>>> datetime
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'datetime' is not defined
```

除此之外，还可以通过 in dir(builtins) 判断是否在dir列表中，来判断符号是否在内置命名空间 builtins 中。

```Shell
>>> import builtins
>>> 'list' in [n for n in dir(builtins) if not n.startswith('_')]
True
```

或者尝试执行 `help(list)` 或 `dir(list)`，看是否正常输出从而判断是否包含在内置命名空间 builtins 中。

## CLASSES

builtins 模块还提供了一些常用的基础类（[CLASSES](https://docs.python.org/3/library/stdtypes.html#)）：

```Shell

CLASSES
    object
        BaseException

        bytearray
        bytes
        classmethod
        complex
        dict
        enumerate
        filter
        float
        frozenset
        int
            bool
        list
        map
        memoryview
        property
        range
        reversed
        set
        slice
        staticmethod
        str
        super
        tuple
        type
        zip
```

> [How do I check whether a module is installed or not in Python?](https://askubuntu.com/questions/588390/how-do-i-check-whether-a-module-is-installed-or-not-in-python)  

> [How to Check if a List, Tuple or Dictionary is Empty in Python](https://www.pythoncentral.io/how-to-check-if-a-list-tuple-or-dictionary-is-empty-in-python/)  

```
>>> str.__module__
'builtins'

>>> import inspect
>>> inspect.getmodule(str)
<module 'builtins' (built-in)>
```

### str

[Text Sequence Type — str](https://docs.python.org/3/library/stdtypes.html#text-sequence-type-str)

> Textual data in Python is handled with **str** objects.

字符串类 str 是 python 最常用的类，用来处理文本数据。

字符串有三种定义方式：

- Single quotes: `'allows embedded "double" quotes'`  
- Double quotes: `"allows embedded 'single' quotes"`  
- Triple quoted: `'''Three single quotes''', """Three double quotes"""`  

> **Triple quoted** strings may span multiple lines - all associated whitespace will be included in the string literal.

其中单引号定义的字符串中可携带双引号；双引号定义的字符串中可携带单引号。  
若想以跨行模式定义长字符串，则可考虑使用三引号，支持换行书写。  

---

两个相邻的字符串字面量会自动连接：

```Shell
>>> str1='Py' 'thon'
>>> str1
'Python'

>>> prefix='Py'
>>> prefix+'thon'
'Python'
```

---

当书写长字符串时，使用 `()` 定义多个字面量部分，换行时自动跨行续接，直到反括号结束：

```Shell
# 小括号定义多个字面量拼接
>>> text=('Put several strings within parentheses '
... 'to have them joined together.')
>>> text
'Put several strings within parentheses to have them joined together.'

# 三引号跨行书写长字符串
>>> text='''Put several strings within parentheses 
... to have them joined together.'''
>>> text
'Put several strings within parentheses \nto have them joined together.'
```

`str[subscripted_index]`：基于脚标索引访问指定位置的字符（位置对应长度为1的子串）。

> Strings can be indexed (subscripted), with the first character having index 0. There is no separate character type; a character is simply a string of size one:

`str[start:stop]`：访问索引区间为 `[start, stop)` 对应的子字符串。

> subscripted_index、start、stop 均可为负数，其中 -1 索引最后一个元素，依次类推。

### Numeric Types

[Numeric Types](https://docs.python.org/3/library/stdtypes.html#numeric-types-int-float-complex)

- [int](https://docs.python.org/3/library/functions.html#int)：整形  
- [float](https://docs.python.org/3/library/functions.html#float)：浮点型  
- [complex](https://docs.python.org/3/library/functions.html#complex)：复数  

### Binary Sequence Types

- [bytes](https://docs.python.org/3/library/stdtypes.html#bytes) objects are immutable sequences of single bytes.  
- [bytearray](https://docs.python.org/3/library/stdtypes.html#bytearray) objects are a mutable counterpart to bytes objects.  

[String and Bytes literals](https://docs.python.org/3/reference/lexical_analysis.html#strings)  
[Bytes and Bytearray Operations](https://docs.python.org/3/library/stdtypes.html#bytes-methods)  

### Sequence Types

[Sequence Types](https://docs.python.org/3/library/stdtypes.html#sequence-types-list-tuple-range)

#### list

列表 [list](https://docs.python.org/3/library/stdtypes.html#list) 定义格式为：[e1, e2, e3, ...]  

> 其中 e 可以为基本类型或 tuple、list、set、dict 等复合类型

```Shell
# [整形,字符串,元组,列表,集合,字典]
>>> list1=[1,'2',(3,4),[5,6],{7,8},{'a':9,'b':10}]
>>> len(list1)
6
```

针对标量数值类型，可使用比 list 更高效的 [array](https://docs.python.org/3/library/array.html) 类型（Efficient arrays of numeric values）。

> Arrays are sequence types and behave very much like lists, except that the type of objects stored in them is constrained.

#### tuple

> Tuples are immutable sequences, typically used to store collections of heterogeneous data.

元组 [tuple](https://docs.python.org/3/library/stdtypes.html#tuple) 定义格式为：(e1, e2, e3, ...)  

> 其中 e 可以为基本类型或 tuple、list、set、dict 等复合类型

```Shell
# (整形,字符串,元组,列表,集合,字典)
>>> tuple1=(1,'2',(3,4),[5,6],{7,8},{'a':9,'b':10})
>>> len(tuple1)
6
```

内置函数 [enumerate()](https://docs.python.org/3/library/functions.html#enumerate) 产生的结果为 `list<tuple>`，每个列表元素为 `(index, value)` 二元组（2-tuples）。

```Shell
>>> help(enumerate)

Help on class enumerate in module builtins:

class enumerate(object)
 |  enumerate(iterable[, start]) -> iterator for index, value of iterable
 |  
 |  Return an enumerate object.  iterable must be another object that supports iteration.  The enumerate object yields pairs containing a count (from start, which defaults to zero) and a value yielded by the iterable argument.
 |  enumerate is useful for obtaining an indexed list:
 |      (0, seq[0]), (1, seq[1]), (2, seq[2]), ...
```

以下为具体示例：

```Shell
>>> seasons = ['Spring', 'Summer', 'Fall', 'Winter']
>>> list(enumerate(seasons))
[(0, 'Spring'), (1, 'Summer'), (2, 'Fall'), (3, 'Winter')]
```

#### range

[range](https://docs.python.org/3/library/stdtypes.html#range) 定义了区间范围。

> The arguments to the range constructor must be **integers** (either built-in `int` or any object that implements the `__index__` special method).

- class range(stop)  
- class range(start, stop[, step])  

定义前开后闭区间 start ≤ e ＜ stop，步进为 step。

> start 默认为0；step 默认为1。

```Shell
>>> list(range(10))
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

>>> list(range(1, 11))
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

>>> list(range(0, 30, 5))
[0, 5, 10, 15, 20, 25]
```

`range(start,stop,step)` 可用 while 循环等效实现：

```Shell
>>> start=0
>>> stop=30
>>> step=5

>>> r=range(start,stop,step)
>>> list(r)
[0, 5, 10, 15, 20, 25]

# range 的等效定义
>>> i=0
>>> v=0
>>> while True:
...     v = start+i*step
...     if v >= stop:
...         break
...     else:
...         print('v[%d] = %d' % (i, v))
...         i += 1
... 
v[0] = 0
v[1] = 5
v[2] = 10
v[3] = 15
v[4] = 20
v[5] = 25
```

典型应用是 stop 取 len(list)，基于索引循环遍历列表：

```Shell
>>> for i in range(len(list1)):\
...     print(list1[i])
... 
1
2
(3, 4)
[5, 6]
{8, 7}
{'a': 9, 'b': 10}
```

### Set Types

[Set Types — set, frozenset](https://docs.python.org/3/library/stdtypes.html#set-types-set-frozenset)

- set：无序集合  

> A **set** object is an *unordered* collection of distinct [hashable](https://docs.python.org/3/glossary.html#term-hashable) objects.

集合定义格式为：{e1, e2, e3, ...}  

> 其中 e 可以为基本类型或 tuple 类型

```Shell
>>> set1={1,'2',(3,4)}
>>> len(set1)
3
```

set 中的元素必须提供 `__hash__()` 方法，为 hashable（has a hash value），否则报错 `TypeError: unhashable type:`

```Shell
>>> set2={1,'2',(3,4),[5,6]}
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: unhashable type: 'list'
>>> set3={1,'2',(3,4),{7,8}}
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: unhashable type: 'set'
>>> set4={1,'2',(3,4),{'a':9,'b':10}}
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: unhashable type: 'dict'
```

更多容器相关的类型，可参考 [collections](https://docs.python.org/3/library/collections.html#module-collections)。

### Mapping Types

[Mapping Types — dict](https://docs.python.org/3/library/stdtypes.html#mapping-types-dict)

- dict：无序字典(键值对映射)  

> A mapping object maps **hashable** values to arbitrary objects. Mappings are mutable objects. There is currently only one standard mapping type, the dictionary.  
> A dictionary’s keys are almost arbitrary values. Values that are **not hashable**, that is, values containing lists, dictionaries or other mutable types may not be used as keys.  

- key 必须为 arbitrary（hashable），list、set、dict 等 unhashable 类型不能作为键；  
- value 可为 not hashable 或 hashable。  

```Shell
>>> dict1[squares]=3
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: unhashable type: 'list'
>>> dict1[3]=squares
>>> dict1
{3: [1, 4, 9, 16, 25]}
```