---
title: python中的迭代器——iterator
authors:
  - xman
date:
    created: 2019-12-06T09:50:00
categories:
    - python
tags:
    - iterator
comments: true
---

本文梳理了 python 中的迭代器类——iterator，介绍了其基本概念和基础惯用法。

<!-- more -->

[Glossary — iterator](https://docs.python.org/3/glossary.html#term-iterator)
[Built-in Types — Iterator Types](https://docs.python.org/3/library/stdtypes.html#typeiter)
[9.8. Iterators](https://docs.python.org/3/tutorial/classes.html#iterators)

可借鉴参考《ES6 标准入门》第 15 章《iteraor 和 for...of 循环》。

## iterable

Python supports a concept of iteration over containers. This is implemented using two distinct methods; these are used to allow user-defined classes to support iteration. Sequences, described below in more detail, always support the iteration methods.

One method needs to be defined for container objects to provide iterable support:

> container.`__iter__`()
>> Return an iterator object. The object is required to support the iterator protocol described below. If a container supports different types of iteration, additional methods can be provided to specifically request iterators for those iteration types. (An example of an object supporting multiple forms of iteration would be a tree structure which supports both breadth-first and depth-first traversal.) This method corresponds to the tp_iter slot of the type structure for Python objects in the Python/C API.

An object capable of returning its members one at a time. Examples of iterables include all sequence types (such as [`list`](https://docs.python.org/3/library/stdtypes.html#list "list"), [`str`](https://docs.python.org/3/library/stdtypes.html#str "str"), and [`tuple`](https://docs.python.org/3/library/stdtypes.html#tuple "tuple")) and some non-sequence types like [`dict`](https://docs.python.org/3/library/stdtypes.html#dict "dict"), [file objects](https://docs.python.org/3/glossary.html#term-file-object), and objects of any classes you define with an [`__iter__()`](https://docs.python.org/3/library/stdtypes.html#iterator.__iter__ "iterator.__iter__") method or with a [`__getitem__()`](https://docs.python.org/3/reference/datamodel.html#object.__getitem__ "object.__getitem__") method that implements [sequence](https://docs.python.org/3/glossary.html#term-sequence) semantics.

Iterables can be used in a [`for`](https://docs.python.org/3/reference/compound_stmts.html#for) loop and in many other places where a sequence is needed ([`zip()`](https://docs.python.org/3/library/functions.html#zip "zip"), [`map()`](https://docs.python.org/3/library/functions.html#map "map"), …). When an iterable object is passed as an argument to the built-in function [`iter()`](https://docs.python.org/3/library/functions.html#iter "iter"), it returns an iterator for the object. This iterator is good for one pass over the set of values. When using iterables, it is usually not necessary to call [`iter()`](https://docs.python.org/3/library/functions.html#iter "iter") or deal with iterator objects yourself. The [`for`](https://docs.python.org/3/reference/compound_stmts.html#for) statement does that automatically for you, creating a temporary unnamed variable to hold the iterator for the duration of the loop. See also [iterator](https://docs.python.org/3/glossary.html#term-iterator), [sequence](https://docs.python.org/3/glossary.html#term-sequence), and [generator](https://docs.python.org/3/glossary.html#term-generator).

### sequence

- Sequence Types — list（mutable）, tuple（immutable）, range（immutable）
- Text Sequence Type — str（immutable）

序列类 list、tuple、range、str 均实现了可迭代协议，具备 iterable 特性。

```Shell
>>> help(list)

 |  __iter__(self, /)
 |      Implement iter(self).

 |  ----------------------------------------------------------------------
 |  Class methods defined here:
 |
 |  __class_getitem__(...) from builtins.type
 |      See PEP 585
```

list、tuple、set 均支持传入 iterable object 构造，因此它们之间可以互相构造转换。

```Shell
class list(object)
 |  list(iterable=(), /)
 |
 |  Built-in mutable sequence.
 |
 |  If no argument is given, the constructor creates a new empty list.
 |  The argument must be an iterable if specified.

class tuple(object)
 |  tuple(iterable=(), /)
 |
 |  Built-in immutable sequence.
 |
 |  If no argument is given, the constructor returns an empty tuple.
 |  If iterable is specified the tuple is initialized from iterable's items.
 |
 |  If the argument is a tuple, the return value is the same object.

class set(object)
 |  set() -> new empty set object
 |  set(iterable) -> new set object
 |
 |  Build an unordered collection of unique elements.
```

list 的 extend 接口传入 iterable object，逐个追加可迭代对象中的元素。

> list.extend(self, iterable, /): Extend list by appending elements from the iterable.

由于 range 也是 iterable，因此也可以传入 list、tuple、set，range 常用于快捷初始化序列。

```Shell
>>> list(range(1,11))
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
>>> list(range(1,11,2))
[1, 3, 5, 7, 9]
```

由于 str 也是 iterable，因此也可以传入 list、tuple、set，生成字符（串）序列。

```Shell
>>> list('string')
['s', 't', 'r', 'i', 'n', 'g']
```

str 的 join(self, iterable, /) 方法需要传入可迭代对象，将它们连接起来。

```Shell
>>> ','.join(('Hello', 'World'))
'Hello,World'
```

## iterator

An object representing a stream of data. Repeated calls to the iterator’s [`__next__()`](https://docs.python.org/3/library/stdtypes.html#iterator.__next__ "iterator.__next__") method (or passing it to the built-in function [`next()`](https://docs.python.org/3/library/functions.html#next "next")) return successive items in the stream. When no more data are available a [`StopIteration`](https://docs.python.org/3/library/exceptions.html#StopIteration "StopIteration") exception is raised instead. At this point, the iterator object is exhausted and any further calls to its `__next__()` method just raise [`StopIteration`](https://docs.python.org/3/library/exceptions.html#StopIteration "StopIteration") again. Iterators are required to have an [`__iter__()`](https://docs.python.org/3/library/stdtypes.html#iterator.__iter__ "iterator.__iter__") method that returns the iterator object itself so every iterator is also iterable and may be used in most places where other iterables are accepted. One notable exception is code which attempts multiple iteration passes. A container object (such as a [`list`](https://docs.python.org/3/library/stdtypes.html#list "list")) produces a fresh new iterator each time you pass it to the [`iter()`](https://docs.python.org/3/library/functions.html#iter "iter") function or use it in a [`for`](https://docs.python.org/3/reference/compound_stmts.html#for) loop. Attempting this with an iterator will just return the same exhausted iterator object used in the previous iteration pass, making it appear like an empty container.

The **iterator** objects themselves are required to support the following two methods, which together form the *iterator protocol*:

> iterator.`__iter__`()
>> Return the iterator object itself. This is required to allow both containers and iterators to be used with the for and in statements. This method corresponds to the tp_iter slot of the type structure for Python objects in the Python/C API.

> iterator.`__next__`()
>> Return the next item from the iterator. If there are no further items, raise the StopIteration exception. This method corresponds to the tp_iternext slot of the type structure for Python objects in the Python/C API.

Python defines several iterator objects to support iteration over general and specific sequence types, dictionaries, and other more specialized forms. The specific types are not important beyond their implementation of the iterator protocol.

Once an iterator’s `__next__`() method raises `StopIteration`, it must continue to do so on subsequent calls. Implementations that do not obey this property are deemed broken.

### concept

iterator 迭代器（遍历器）就是这一种接口，为各种不同的数据结构提供统一的访问机制。
任何数据结构只要部署了 iterator 接口，就可以支持 for...in 循环遍历操作。

任何可迭代（iterable）的对象都会定义 `__iter__` 和 `__next__` 方法，即实现迭代器协议。  
更正规的定义是：实现了方法 `__iter__` 的对象是可迭代的，而实现了方法 `__next__` 的对象是迭代器。  

方法 `__iter__` 返回一个迭代器，它是包含`__next__` 方法的对象。

> `list` provide iterable support；`list_iterator` conform to iterator protocl.

```Shell
>>> hasattr(list, '__iter__')
True
>>> hasattr(list, '__next__')
False
```

iterator 的遍历过程如下：

1. 创建一个指针对象，指向当前数据结构的起始位置。也就是说，遍历器对象本质上就是一个指针对象。
2. 第一次调用指针对象的 next 方法，可以将指针指向数据结构的第一个成员。
3. 第二次调用指针对象的 next 方法，指针就指向数据结构的第二个成员。
4. 不断调用指针对象的 next 方法，直到它指向数据结构的结束位置。

每次调用 next 方法都会返回数据结构的当前成员的信息。

### Fibonacci

我们来看看经典的斐波那契数列，它具备典型的前向推导和迭代特性。

先来看看原始定义：f(n)=f(n-1)+f(n-2)。

$$
% abs
f(n)=
\begin{cases}
		n, & x<2 \\
		f(n-1)+f(n-2), & x \ge 2
\end{cases}
$$

之前基于 list.append 方法实现的斐波那契列表：

```Python
def fibs(n: int) -> list:
    if n < 2:
        print('To make sense, n should be bigger than 2.')
        return None
    else:
        r = [0, 1]
        for i in range(n-2):
            r.append(r[-2]+r[-1])
        return r
```

基于多重赋值（逐个计算右值表达式，再依次赋给左侧变量），稍作改进：

```shell
>>> def fib2(n):  # return Fibonacci series up to n
...     """Return a list containing the Fibonacci series up to n."""
...     result = []
...     a, b = 0, 1
...     while a < n:
...         result.append(a)    # see below
...         a, b = b, a+b
...     return result
... 
>>> f100 = fib2(100)
>>> f100
[0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
```

以上将生成的斐波那契数列一一存储在列表中。但假如我们只想逐个地获取值，而不是使用列表一次性获取。
例如，只想找出第一个大于1000的斐波那契数，而不关注前向序列，如果用列表实现，非常耗费内存。
此时，使用迭代器实现更通用、更简单、更优雅。

```Python
class Fibs:
    def __init__(self):
        self.a = 0
        self.b = 1

    def __next__(self):
        self.a, self.b = self.b, self.a + self.b
        return self.a

    def __iter__ (self):
        return self

fibs = Fibs()
for fib in fibs:
    if fib > 1000:
        print(fib)
        break
```

这个循环之所以会停止，是因为其中包含 break 语句；否则，这个 for 循环将没完没了地执行。

## iterate

[8.3. The for statement](https://docs.python.org/3/reference/compound_stmts.html#the-for-statement): The for statement is used to iterate over the elements of a sequence (such as a string, tuple or list) or other iterable object.

### iter-next

内置的 `iter()` 函数返回迭代器（iterator），`next()` 函数则遍历迭代器，解引用返回遍历到的位置对应的元素。

不同的对象类型传递给 iter 返回各自类型的 iterator：

1. iter(str) 返回 str_ascii_iterator
2. iter(list) 返回 list_iterator
3. iter(tuple) 返回 tuple_iterator
4. iter(range) 返回 range_iterator

对 iterator 调用 next，实际上等效于调用其 `__next__` 方法。

```Shell
Help on built-in function iter in module builtins:

iter(...)
    Get an iterator from an object.

    In the first form, the argument must supply its own iterator, or be a sequence.
    In the second form, the callable is called until it returns the sentinel.

next(...)
    Return the next item from the iterator.

    If default is given and the iterator is exhausted,
    it is returned instead of raising StopIteration.
```

以下示例使用 iter+next 迭代遍历访问列表：

```Shell
>>> l=['abc', 2024, (3,8)]
>>> i=iter(l)
>>> next(i)
'abc'
>>> next(i)
2024
>>> next(i)
(3, 8)
>>> next(i)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```

调用 next 访问返回最后一个元素后，迭代完毕（exhausted），再次调用 next 将抛出 `StopIteration` 异常。
调用 iter 获取 iterator 后，逐次调用 next 比较繁琐，不切实际，建议使用循环迭代遍历。
可使用 while 循环调用 next 迭代，并捕获迭代溢出异常退出循环。

```Shell
>>> l=['abc', 2024, (3,8)]
>>> it=iter(l)
>>> while True:
...     try:
...             e=next(it)
...             print(e)
...     except StopIteration:
...             break
... 
abc
2024
(3, 8)
```

**注意**：字典（dict）的迭代器是针对 键值对 进行的一维迭代。

当然，由于 iterator 本身也实现了 `__iter__` 接口，也可直接对其执行 for 循环迭代：

```Shell
>>> l=['abc', 2024, (3,8)]
>>> i=iter(l)
>>> for x in i:
...     print(x)
... 
abc
2024
(3, 8)
```

当然，调用 iter 就多此一举，直接使用 for 循环对 iterable object 遍历迭代更简洁：

```Shell
>>> for i in l:
...     print(i)
...
abc
2024
(3, 8)
```

### enumerate

enumerate 类实现了 iterator protocol，可对返回的 enumerate 对象执行 for 循环遍历或调用 list() 构造转换。

```Shell
Help on class enumerate in module builtins:

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
 |
 |  Methods defined here:
 |
 |  __getattribute__(self, name, /)
 |      Return getattr(self, name).
 |
 |  __iter__(self, /)
 |      Implement iter(self).
 |
 |  __next__(self, /)
 |      Implement next(self).
 |
 |  __reduce__(...)
 |      Return state information for pickling.
 |
 |  ----------------------------------------------------------------------
 |  Class methods defined here:
 |
 |  __class_getitem__(...) from builtins.type
 |      See PEP 585
 |
 |  ----------------------------------------------------------------------
 |  Static methods defined here:
 |
 |  __new__(*args, **kwargs) from builtins.type
 |      Create and return a new object.  See help(type) for accurate signature.
lines 5-41 bytes 120-1225 98% of file -
```

enumerate(object) 函数返回 enumerate 对象实例，可传递给 list() 构造 indexed list。

```Shell
>>> l=['abc', 2024, (3,8)]
>>> en=enumerate(l)
>>> [*en]
[(0, 'abc'), (1, 2024), (2, (3, 8))]
>>> [*en] # exhausted
[]
```

迭代遍历 enumerate 对象，每个元素为一个 tuple 二元组 (index, value)。

```Shell
>>> en=enumerate(l)
>>> for e in en:
...     print(e)
... 
(0, 'abc')
(1, 2024)
(2, (3, 8))
```

对列表调用 `enumerate()` 可以获取每个元素的索引及其值，也可基于返回的枚举对象构造元组或列表。

```Shell
>>> l=[*range(1,13, 2)]
>>> tuple(enumerate(l))
((0, 1), (1, 3), (2, 5), (3, 7), (4, 9), (5, 11))
>>> list(enumerate(l))
[(0, 1), (1, 3), (2, 5), (3, 7), (4, 9), (5, 11)]
```

## itertools

### sorted

Python 内建模块 builtins 中的函数 `sorted` 支持对可迭代序列进行（升序）排序，返回排序后的 list。

- 可指定参数 reverse=True 进行降序排列。

```Shell
    sorted(iterable, /, *, key=None, reverse=False)
        Return a new list containing all items from the iterable in ascending order.
```

以下代码片段在 [1,40] 之间随机挑选13个数，然后调用 sorted 函数进行排序：

```Python
    l = 1; r = 40; n = 13
    random.seed(r+1)
    rl = random.sample(range(l,r+1), n)
    srl = sorted(rl) # 默认升序
    # srl = sorted(rl, reverse=True) # 降序
```

对于 list(tuple) 和 dict 等符合可结合 lambda 指定排序的 key：

```Python
a=[('b',3), ('a',2), ('d',4), ('c',1)]
# 按照第一个元素排序
sorted(a,key=lambda x:x[0])
# 按照第二个元素排序
sorted(a,key=lambda x:x[1])
```

[Python | Sort Python Dictionaries by Key or Value - GeeksforGeeks](https://www.geeksforgeeks.org/python-sort-python-dictionaries-by-key-or-value/)

```Python
d={'b':3, 'a':2, 'd':4, 'c':1}
# sort by keys
sorted(d.items())

# sort by keys（列表推导）
ks = list(d.keys())
ks.sort()
sorted_dict = {k: d[k] for k in ks}

# sort by values
sorted(d.items(), key=lambda kv:(kv[1], kv[0]))
```

### reversed

Python 内建模块 builtins 中的工具类 `reversed` 支持对可迭代序列进行逆序，根据输入的序列返回不同类型的迭代器。

- 对返回的迭代器对象，可直接 for 循环遍历或调用 list() 构造转换。

```Shell
class reversed(object)
 |  reversed(sequence, /)
 |
 |  Return a reverse iterator over the values of the given sequence.
```

以下代码片段将 str、range、tuple、list 传入 reversed() 返回对应的逆序列迭代器。

```Python
s='Hello, World!'
rs=reversed(s)
type(rs) # 返回 reversed

r = range(1,11)
rr = reversed(r)
type(rr) # 返回 range_iterator

t = tuple(r)
rt = reversed(t)
type(rt) # 返回 reversed

l = [*r]
rl = reversed(l)
type(rl) # 返回 list_reverseiterator
```

### map

Python 内建模块 builtins 中的工具类 `map` 支持将序列中的元素做映射转换，func 为转换函数（converter）。
map 迭代遍历传入的 iterable object，对每个元素调用转换函数（func），映射生成新的的元素序列。
如果转换函数很简短且不必考虑复用，可改用 in-place 形式的 lambda 表达式。

- 可对返回的 map 对象执行 for 循环遍历或调用 list() 构造转换。

```Shell
Help on class map in module builtins:

class map(object)
 |  map(func, *iterables) --> map object
 |
 |  Make an iterator that computes the function using arguments from
 |  each of the iterables.  Stops when the shortest iterable is exhausted.
 |
 |  Methods defined here:
 |
 |  __getattribute__(self, name, /)
 |      Return getattr(self, name).
 |
 |  __iter__(self, /)
 |      Implement iter(self).
 |
 |  __next__(self, /)
 |      Implement next(self).
 |
 |  __reduce__(...)
 |      Return state information for pickling.
 |
 |  ----------------------------------------------------------------------
 |  Static methods defined here:
 |
 |  __new__(*args, **kwargs) from builtins.type
 |      Create and return a new object.  See help(type) for accurate signature.
```

#### demo1: string.capwords

string.py 中的 string.capwords 方法即使用 map 实现：

```Python
# Capitalize the words in a string, e.g. " aBc  dEf " -> "Abc Def".
def capwords(s, sep=None):
    return (sep or ' ').join(map(str.capitalize, s.split(sep)))
```

#### demo2: version tuple str2int

1. sysconfig.get_python_version() 输出 '3.9'，platform.python_version() 输出 '3.9.6'。

`version_str2tuple` 函数将版本号字符串按点号（`.`）分割成字符数组，再对字符数组调用 int 逐一映射为整数。

```Python
def version_str2tuple(vs:str):
    return tuple(map(int, vs.split(".")))
    # list comprehension
    # return tuple([int(s) for s in vs.split('.')])
```

- version_str2tuple(sysconfig.get_python_version()) 输出 (3, 9)；
- version_str2tuple(platform.python_version()) 输出 (3, 9, 6)；

2. platform.python_version_tuple() 输出 ('3', '9', '6')，调用 `version_tuple_str2int` 函数将元组序列中的字符转成整数。

```Python
def version_tuple_str2int(vst:tuple):
    return tuple(map(int, vst))
    # list comprehension
    # return tuple([int(s) for s in vst])
```

- version_tuple_str2int(platform.python_version_tuple()) 输出 (3, 9, 6)。

将版本字符串转换成整数tuple后，即可直接与预期版本tuple进行比较匹配。

```Python
# '3.9'
version_str2tuple(sysconfig.get_python_version()) > (3, 8)

# '3.9.6'
version_str2tuple(platform.python_version()) > (3, 9, 6)

# ('3', '9', '6')
version_tuple_str2int(platform.python_version_tuple()) > (3, 9, 6)

# (3, 9, 6, 'final', 0)
tuple(sys.version_info) > (3, 9, 6) # sys.version_info > (3, 9, 6)
```

以上示例中，字符串转整数，转换器为 int 类，传入字符串构造转换。
否则，需要自己编写转换器。如果转换器函数只使用一次（不考虑复用），可使用 lambda 表达式（匿名函数）。

#### demo3: sequence calculation

例如，要生成 1-10 的平方，可使用 map 对 range(1,11) 序列执行映射转换：

- 等效列表推导：[value**2 for value in range(1,11)]

```Shell
# [1, 4,9, 16, 25, 36, 49, 64, 81, 100]
>>> square=map(lambda x:x**2, range(1,11))
>>> next(square)
1
>>> next(square)
4
>>> [*square] # list(square)
[9, 16, 25, 36, 49, 64, 81, 100]
>>> next(square)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
>>> [*square]
[]
```

需要说明的是，对于 map 实例对象 square，传递给 list() 构造后，已经遍历完毕。
尝试再次调用 next 迭代，将抛出异常 StopIteration。

来看一个日常生活中的实际应用案例。

**需求**：PDF文档，实际页数和文档标记页数存在误差，如何快速计算每一章节的准确跳转页码？
**方案**：先看看标记第一页和实际第一页之间的偏移offset。然后，通过TOC查看每章的标记页码，遍历加上偏移量即可得到每章的实际跳转页码。

[Adding K to each element in a list of integers](https://www.geeksforgeeks.org/python-adding-k-to-each-element-in-a-list-of-integers/)

使用列表推导对页数进行矫正：

```Python
page_no = [3,11,45,65,69,85,109,127,141,163,191,195,203,227]
offset = 25
correct_page_no = [p + offset for p in page_no]
```

也可使用 map 结合 lambda 的函数式编程方式实现同样的目的。

```Python
correct_page_no=list(map(lambda x:x+offset, page_no))
```

---

现代 Python 更多地采用面向对象编程范式，建议尽量不采用这种函数式编程方式，当然 map、filter 本身也是类。
如果 map 和 filter 中转换/过滤逻辑简单到一行代码就能实现的，建议采用 lambda 表达式。
或直接采用列表推导等效实现，更加简洁且可读性更高（concise and readable）。

### filter

Python 内建模块 builtins 中的工具类 `filter` 支持对 iterable 对象实现过滤，筛选出符合条件的元素。
filter 迭代遍历传入的 object，对每个元素调用谓词函数（function）执行过滤，留下符合谓词条件的元素。
如果谓词函数很简短且不必考虑复用，可改用 in-place 形式的 lambda 表达式。

- 可对返回的 filter 对象执行 for 循环遍历或调用 list() 构造转换。

```Shell
# filter 的定义和 map 几乎一样。

Help on class filter in module builtins:

class filter(object)
 |  filter(function or None, iterable) --> filter object
 |
 |  Return an iterator yielding those items of iterable for which function(item)
 |  is true. If function is None, return the items that are true.
 |
 |  Methods defined here:
 |
 |  __getattribute__(self, name, /)
 |      Return getattr(self, name).
 |
 |  __iter__(self, /)
 |      Implement iter(self).
 |
 |  __next__(self, /)
 |      Implement next(self).
 |
 |  __reduce__(...)
 |      Return state information for pickling.
 |
 |  ----------------------------------------------------------------------
 |  Static methods defined here:
 |
 |  __new__(*args, **kwargs) from builtins.type
 |      Create and return a new object.  See help(type) for accurate signature.
```

假如我们想过滤 1-10 中的偶数，可以使用 filter 过滤出序列中整除 2 的元素：

- 基于列表推导的等效实现：[n for n in range(1,11) if n%2==0]

```Shell
>>> even=filter(lambda n:n%2==0, range(1,11))
>>> [*even]
[2, 4, 6, 8, 10]
>>> [*even]
[]
```

同样，对于 filter 实例对象 even，传递给 list() 构造后，已经遍历完毕。
尝试再次调用 next 迭代，将抛出异常 StopIteration。

下面通过 filter 过滤出了内置模块（builtins）中的公开符号：

```Shell
>>> import builtins, pprint
>>> builtin_sym=filter(lambda s:not s.startswith('_'), dir(builtins))
>>> pprint.pp([*builtin_sym])
```

再使用 filter 过滤出以“is”开头的判断接口:

```Shell
>>> is_sym=filter(lambda s:s.startswith('is'), builtin_sym)
>>> [*is_sym]
['isinstance', 'issubclass']
```

基于列表推导的等效实现：

> [n for n in dir(builtins) if not n.startswith('_') and n.startswith('is')]

---

**谓词函数相关参考**：

> C++ STL 中带有 `_if` 后缀的算法（std::find, std::find_if, std::find_if_not）需要带有谓词函数（UnaryPredicate）作为形参。

> 在 IBM DB2 文档中，[谓词](https://www.ibm.com/docs/zh/db2/9.7?topic=concepts-predicate) 是一个搜索条件的元素，它表示或隐含一个比较操作。谓词包括在以 WHERE 或 HAVING 开头的子句中。

> 在 IBM i7.5 文档中，[谓词](https://www.ibm.com/docs/zh/i/7.5?topic=steps-predicates) 由一个称为谓词表达式的表达式组成，该表达式括在方括号 ([]) 中。 谓词通过保留某些项并废弃其他项来过滤序列。针对序列中的每个项对谓词表达式求值一次。 谓词表达式的结果是一个称为谓词真值的 xs:boolean 值。 将保留谓词真值为 true 的那些项，并且将废弃谓词真值为 false 的那些项。

### itertools

如果想要过滤出 iterable object 符合条件的元素，除了可以调用内置的 filter 工具类外，也可调用 itertools 中的相关工具集。

- itertools.takewhile(predicate, iterable)
- itertools.filterfalse(predicate, iterable)
- itertools.dropwhile(predicate, iterable)

以上接口返回可迭代对象 takewhile、filterfalse、dropwhile，需要对其调用 next 完成迭代。

[itertools — Functions creating iterators for efficient looping — Python 3.12.2 documentation](https://docs.python.org/3.12/library/itertools.html)

takewhile 过滤出符合谓词逻辑 predicate 的元素，一旦遇到第一个不符合条件的即终止。

```Shell
>>> x=itertools.takewhile(lambda x:x<5, [1,4,6,4,1])
>>> x
<itertools.takewhile object at 0x108f204c0>
>>> next(x)
1
>>> next(x)
4
>>> next(x)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```

filterfalse 过滤出所有不符合谓词逻辑 predicate 的元素。

```Shell
>>> x=itertools.filterfalse(lambda x: x%2, range(10))
>>> next(x)
0
>>> next(x)
2
>>> next(x)
4
>>> next(x)
6
>>> next(x)
8
>>> next(x)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```

takewhile 过滤掉符合谓词逻辑 predicate 的元素，一旦遇到第一个不符合条件的予以保留（至末尾）。

```Shell
>>> x=itertools.dropwhile(lambda x: x<5, [1,4,6,4,1])
>>> next(x)
6
>>> next(x)
4
>>> next(x)
1
>>> next(x)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```
