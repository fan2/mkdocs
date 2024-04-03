---
title: python内置模块之有序列表(list)
authors:
  - xman
date:
    created: 2019-12-04T08:50:00
categories:
    - python
tags:
    - list
comments: true
---

Python内置模块中的有序列表（builtins.list）的基本用法。

<!-- more -->

[list](https://docs.python.org/3/library/stdtypes.html#list)（有序列表）

```shell
>>> type(sys.argv)
<class 'list'>
```

```shell
# 判断模块名称中是否包含 '__doc__' 和 '__file__'
>>> import builtins
>>> '__doc__' in dir(builtins)
True
>>> '__file__' in dir(builtins)
False

>>> import os
>>> '__doc__' in dir(os)
True
>>> '__file__' in dir(os)
True
```

## help

```Shell
>>> help(list)

Help on class list in module builtins:

class list(object)
 |  list(iterable=(), /)
 |
 |  Built-in mutable sequence.
 |
 |  If no argument is given, the constructor creates a new empty list.
 |  The argument must be an iterable if specified.
```

## why not [array](https://docs.python.org/3/library/array.html) ?

`array` — Efficient arrays of numeric values

This module defines an object type which can compactly represent an array of basic values: characters, integers, floating point numbers.  Arrays are sequence types and behave very much like lists, except that the type of objects stored in them is **constrained**.  
The type is specified at object creation time by using a *type code*, which is a single character.  

```
a=array.array('i', [1, 2, 3, 4, 5])
```

当我们要存储操作大规模的标量数值类型时，数组（array）的效率要比列表（list）要高得多。
因为数组在背后存的并不是对象，而是数字的机器翻译，也就是字节表述。

> [python之数组模块array](https://www.cnblogs.com/jlf0103/p/9168093.html)  
> [python3之数组(array)](https://blog.csdn.net/xc_zhou/article/details/88538793)  

array 相比 list 的局限在于：list 可以混合存储任意类型，而 array 在构造时必须指定确定的数值类型。
一般 list 用的场合比较多。

## common

### initialization

1. `l=list()`: 构造一个空列表对象。  

   - `l=list(range(1,5))`：基于range构造list。

2. `l=[]`：中括号定义空列表。  
3. `l=[10]`：定义只有一个元素列表。

   - 注意C语言中表示生命size=10的数组。  

4. `l1=[1,2,3,4]`：定义包含多个元素的列表，多个元素之间以逗号分隔。

5. `l=[*range(1,5)]` 或 `l=[*tuple(range(1,5))]`：使用星号对可枚举对象range、tuple进行解包，生成列表。

列表支持基于脚标索引访问元素（access through subscripted index）。

此外，有些场合可能需要预分配指定尺寸的数组（列表），以便按索引设值而不用担心越界访问。

- `[None]*10`: 初始化长度为10的列表，所有元素初始化为空对象None。
- `[0]*10`: 初始化包含10个0的列表。

```Shell
>>> l1=[None]*10
>>> l1
[None, None, None, None, None, None, None, None, None, None]
>>> l2=[0]*10
>>> l2
[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```

例如计数排序（[Counting Sort](https://www.geeksforgeeks.org/counting-sort/)）中，预先声明一个和源列表相同尺寸的数组，用于接收排序结果。

> B = [None]*len(A)

### expressions

- `len(l)`: Return the number of elements in list l.  
- `e in l`: Test e for membership in l.  
- `e not in l`: Test e for non-membership in l.  
- `for e in l`: enumerate elements in l.  

### api overview

在 python shell 中，构造一个空列表 l，然后输入 `l.` 再输入 tab 键自动提示可用的成员函数：

```
>>> l=list()
>>> l.
l.append(   l.copy(     l.extend(   l.insert(   l.remove(   l.sort(
l.clear(    l.count(    l.index(    l.pop(      l.reverse(
```

## add

### append, insert

向列表中添加元素，有两种方式：

1. 调用 `l.append(e)`，将新元素 e 添加到列表 l 的末尾；  
2. 调用 `l.insert(i, e)`，将新元素 e 插入到列表 l 原来索引为 i 的元素之前：

    > 原来索引 i 及其后的元素顺势后移一位，新元素 e 占据索引 i 的位置。

- 尾追法：`l.append(e)`;  
- 头插法：`l.insert(0,e)`;  

以下为基于 list.append 方法实现斐波那契列表。

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

### extend

`append` 一般是将单个元素追加到列表末尾，如何在已有列表后面追加（衔接）另外一个列表呢？

这涉及到 extend 接口：`extend` list by appending elements from the iterable.

我们创建列表 l1 及其副本 l2，接下来看看它们分别通过 append 和 extend 追加的效果。

```
>>> l1=list(range(1,5))
>>> l1
[1, 2, 3, 4]
>>> l2 = l1.copy()
>>> l2
[1, 2, 3, 4]
>>> l3=list(range(5,9))
>>> l3
[5, 6, 7, 8]
```

`l1.append(l3)` 将 l3 追加到 l1，是将列表 l3 作为一个元素追加到 l1：

```
>>> l1.append(l3)
>>> l1
[1, 2, 3, 4, [5, 6, 7, 8]]
>>> len(l1)
5
>>> l1[4]
[5, 6, 7, 8]
>>> type(l1[4])
<class 'list'>
```

`l2.extend(l3)` 则将 l3 中的列表元素逐个 append 追加到 l2 后面，实现了预期的列表衔接。

```
>>> l2.extend(l3)
>>> l2
[1, 2, 3, 4, 5, 6, 7, 8]
>>> len(l2)
8
```

## delete

### del

调用内置的 `del` 函数，可以删除列表中的元素，被删位置自动排空。

1. `del(l[i])` 或 `del l[i]`：从列表l中移除索引 i 处的元素；
2. 当然也可以 `del l[i:j:k]` 移除切片子集。

### pop

list 本身自带的 pop 函数，支持弹出指定位置元素。

`e=l.pop(i)`：从列表l中弹出索引i处的元素到变量e，等效于 `e=l[i]; del(l[i])`；  

- `l.pop()`：不指定索引，默认弹出上一次 append 到队尾（栈顶）的元素。  
- `e=l.pop(0)`：弹出队头（*栈底*）元素到变量e。  

### remove

有时候，你不知道要从列表中删除的值所处的位置。
如果你只知道要删除的元素（的值），可调用 `list.remove(e)` 方法。

> Remove first occurrence of value. Raises *ValueError* if the value is not present.

```
>>> if e in l1:
...     l1.remove(e)
...     print(l1)
... else:
...     print("{} not in list".format(e))
```

当 e=4 在列表中时，被移除；当 e=9 不在列表中时，打印提示不在列表中。

## slice

切片的完整格式是 `[start:stop:step]`，对应 slice 函数的定义。  

一般省略默认step=1，简写为一个冒号区间形式 `[start:stop]`。  
甚至连start和stop都可不指定，简写一个冒号形式 `[:]`（等价于 `[::]`）。  

---

a = `[1,2,3,4,5,6,7]`，取切片 `a[1:3]` 索引范围 = [1,3)，取出的子集为 `[2, 3]`。

```
>>> a=[1,2,3,4,5,6,7]
>>> a[1:3]
[2, 3]
```

`a[:4]`：省略切片开始索引，默认为0，相当于 `a[0:4]`，取值 a[0]~a[3]。

```
>>> a[:4]
[1, 2, 3, 4]
```

`a[4:]`：省略切片结束索引，默认为len，相当于 `a[4:len(a)]`，取值 a[4]~a[len(a)-1]。

```
>>> a[4:]
[5, 6, 7]
```

`a[:]`：省略切片开始和结束索引，相当于 `a[0:len(a)]`，取值 a[0]~a[len(a)-1]。

```
>>> a[:] # 默认步长为1，等效于 a[::]、a[::1]
[1, 2, 3, 4, 5, 6, 7]

>>> a[::2] # 指定步长为2，取所有偶数索引位置的值
[1, 3, 5, 7]

>>> a[1::2] # 指定步长为2，指定起始索引为1，取所有奇数索引位置的值
[2, 4, 6]
```

还有一种特殊的用法：使用 `a[::-1]` 指定步长为-1，从后到前读取生成列表a的反转副本：

```
>>> a[::-1]
[7, 6, 5, 4, 3, 2, 1]
>>> a # 读取切片不影响原列表
[1, 2, 3, 4, 5, 6, 7]
```

如果调用 `reverse` 则将原列表永久翻转了：

```
>>> a.reverse()
>>> a
[7, 6, 5, 4, 3, 2, 1]
```

---

也可以用内置的 **slice** 函数指定 start、stop 和 step，构造切片索引，对序列进行切片取值。

```
slice(start, stop[, step])
```

这样使得切片范围可编程定制化，更灵活的截取子集。

```
>>> s = slice(1,3)
>>> a[s] # 等效于 a[1:3] 和 a[1:3:1]
[2, 3]
```

特殊地有 `slice(None)`，连起始索引 start 都省略，等价于冒号 `:`，表示从头到尾。

```
>>> s=slice(None)
>>> a[s]
[1, 2, 3, 4, 5, 6, 7]
```

### copy slice

图解LeetCode初级算法插入排序中，用到了Python的切片赋值。

1. 从前子向量切片 [0:right]（结束索引为 right-1） 中查找比右子向量当前首元素 target 大的索引 left；  
2. 将从 left 开始比 right 大的切片 [left:right]（不包括 right 对应的 target 元素）整体向右移动一位；  

    > right 的值提前暂存到 target 中了，right 位置将被右移占用，左边 left 位置腾出插入 target 值。

```Python
def insertionSort(iList: list) -> list:
    if len(iList) <= 1:
        return iList
    for right in range(1, len(iList)):
        target = iList[right]
        for left in range(0, right):
            if target <= iList[left]:
                iList[left+1:right+1] = iList[left:right] #使用Python的切片赋值
                iList[left] = target
                break
        # print("第 %d 轮排序结果:" %(right), end="")
        # print(iList)
    return iList
```

### copy list

list 是 mutable sequence，将列表赋给新的变量时，新的变量并不会执行深拷贝，而将指向同一个原始列表。

以下示例演示了在不使用切片（副本）的情况下复制列表操作的非预期灾难性后果：

```Python
# 朋友和我相同的美食爱好
my_foods = ['pizza', 'falafel', 'carrot cake']

friend_foods = my_foods

# 定制我和朋友各自喜欢的美食
my_foods.append('cannoli')
friend_foods.append('ice cream')

print("My favorite foods are:")
print(my_foods)
print("\nMy friend's favorite foods are:")
print(friend_foods)
```

如果后续过程处理不想影响原件，可考虑拷贝原始列表的副本，然后针对副本操作。
如果需要根据既有列表创建全新的列表，除了可以调用源列表的 `copy` 函数创建副本外，也可创建一个包含整个列表的切片（`[:]`），然后赋值给新列表变量，即达目的。

```Shell
>>> b=a[:] # 深度复制 a 的副本
>>> b
[1, 2, 3, 4, 5, 6, 7]
>>> b.pop(0)
1
>>> b # b 弹出队首元素
[2, 3, 4, 5, 6, 7]
>>> a # b 的改动不影响 a，a 不变
[1, 2, 3, 4, 5, 6, 7]
```

具体到上述定制美食清单案例中，拷贝一份我的美食清单，副本作为朋友自己的美食清单，再进行定制即符合预期：

```Python
# 拷贝一份我的美食清单，副本作为朋友自己的美食清单
friend_foods = my_foods[:] # my_foods.copy()

# 基于我和朋友各自的美食清单，开始定制
```

修改前，指向复用 friend_foods is my_foods = True；修改后，拷贝解耦 friend_foods is my_foods = False。

对于列表，形参和实参这两个变量将指向同一个列表，相当于C语言中的引用或指针传参，函数内部对该变量的操作将直接影响原始变量。

```Python
def try_to_change_list1(l):
    l = list(range(6)) # 形参另有所指，与实参分离，不影响原件

def try_to_change_list2(l):
    l.append(6) # 修改形参所指，直接影响原件

l = list(range(5))
try_to_change_list1(l)
print(l)

try_to_change_list2(l)
print(l)
```

如果传入列表，只是想看看函数处理的结果，而不希望影响外面的原始列表，可以考虑通过全切片拷贝（[:] 或 copy）传入副本。

```Python
def try_to_change_list(l):
    l.append(6)

l = list(range(5))
m = l[:] # l.copy()
try_to_change_list(m)
print(l)
```

### refs

[Python切片Slice](http://liao.cpython.org/07slice/)  
[python中切片（Slice）操作符](https://blog.csdn.net/xiaofeiyu321/article/details/82941765)  
[切片（Slice）在python中的运用](https://blog.csdn.net/dfshi198/article/details/80843175)  
[Python高级特性——切片（Slice）](https://www.cnblogs.com/hiwuchong/p/8052502.html)  

## stack

list 模拟队列 FIFO 的惯用法：

- 尾部入列：list.append(e)
- 头部出列：e=l.pop(0)

list 模拟栈的 LIFO 惯用法：

- 尾部压栈：list.append(e)
- 访问尾部：e=list[len-1]
- 尾部出栈：e=list.pop()
- 替换：先读取按需修改，再 pop 后 append

另外也可单向访问双端队列（collections.`deque`）遵循栈的 LIFO 用法。

如果需要频繁对序列做先出先进（FIFO）的操作，双端队列（collections.deque）的速度应该会更快。  
除了标准的 append/pop 接口，deque 还专门提供了 `appendleft`/`popleft` 接口。

- 双端队列标准惯用法：入队 **enqueue** - `dq.append(e)`, 出队 **dequeue** - `e=dq.popleft()`。

## listcomp

[**list comprehension**](https://docs.python.org/3/glossary.html?highlight=list%20comprehension) : A compact way to process all or part of the elements in a sequence and return a list with the results.

[5.1.3. List Comprehensions](https://docs.python.org/3/tutorial/datastructures.html#list-comprehensions): List comprehensions provide a concise way to create lists. Common applications are to make new lists where each element is the result of some operations applied to each member of another sequence or iterable, or to create a subsequence of those elements that satisfy a certain condition.

listcomp (**列表解析式**) 是遍历一个列表中的元素，过滤筛选出符合一定条件的元素，执行必要地转换后追加到另一个列表并返回这个新的列表的表达式。  

列表解析式形如 `expression comp_for [comp_if]`，或更清晰一点 `expr for iter_var in iterable [if cond_expr]`，其中的条件过滤器 if 语句是可选的。如果没有 if 过滤，则默认遍历所有元素执行转换。

> The if clause is optional. If omitted, all elements in comp_for are processed.

### without if

`x in y` 的列表解析等效表达式：`any(x is e or x == e for e in y)`。

以下示例for循环遍历原始可枚举对象，对遍历元素value执行 value**2 计算平方，整体效果是生成1到10的平方值列表。

```Shell
>>> squares = [value**2 for value in range(1,11)]
>>> print(squares)
[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```

以下创建一个列表，列表元素是元组，包括平方根和平方：

```Shell
# create a list of 2-tuples like (number, square)
>>> [(x, x**2) for x in range(1,11)]
[(1, 1), (2, 4), (3, 9), (4, 16), (5, 25), (6, 36), (7, 49), (8, 64), (9, 81), (10, 100)]
```

来看一个日常生活中基于列表解析的实际应用案例。

**需求**：PDF文档，实际页数和文档标记页数存在误差，如何快速计算每一章节的准确跳转页码？
**方案**：先看看标记第一页和实际第一页之间的偏移offset。然后，通过TOC查看每章的标记页码，遍历加上偏移量即可得到每章的实际跳转页码。

[Adding K to each element in a list of integers](https://www.geeksforgeeks.org/python-adding-k-to-each-element-in-a-list-of-integers/)

```Python
page_no = [3,11,45,65,69,85,109,127,141,163,191,195,203,227]
offset = 25
correct_page_no = [p + offset for p in page_no]
```

以上使用列表推导对页数进行矫正，也可使用 map 结合 lambda 的函数式编程方式实现同样的目的。

```Python
correct_page_no=list(map(lambda x:x+offset, page_no))
```

现代 Python 更多地推荐采用面向对象编程范式，建议尽量不采用这种函数式编程方式。
相比而言，列表推导（list comprehension）实现方式书写简洁且可读性更高（concise and readable）。

### with if

还可以针对 for 循环添加过滤条件，筛选出符合条件的元素，再执行复合计算。

以下示例将列表解析返回的元素传入三目运算，判断偶数为1，奇数为0，返回奇偶性标识列表。

```Shell
>>> [1 if e%2==0 else 0 for e in range(1,11)]
[0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
```

以下还是列表解析结合三目运算，遍历range(1,8)，对于≤4的数替换为1，生成新列表。

```Shell
>>> [e if e>4 else 1 for e in range(1,8)]
[1, 1, 1, 1, 5, 6, 7]
```

以下示例通过列表推导将指定模块中以下划线开头的非供外部使用的名称过滤掉：

```shell
>>> import copy
>>> [n for n in dir(copy) if not n.startswith('_')]
['Error', 'copy', 'deepcopy', 'dispatch_table', 'error']
>>> 
>>> import string
>>> [n for n in dir(string) if not n.startswith('_')]
['Formatter', 'Template', 'ascii_letters', 'ascii_lowercase', 'ascii_uppercase', 'capwords', 'digits', 'hexdigits', 'octdigits', 'printable', 'punctuation', 'whitespace']
```

### multilayer

listcomp 还支持 multi-layers loop。

以下用两重 for 循环展开列表的列表：

```Shell
>>> vec = [[1,2,3], [4,5,6], [7,8,9]]
>>> [num for elem in vec for num in elem] # from left to right
[1, 2, 3, 4, 5, 6, 7, 8, 9]
```

以下用两重 for 循环将两个列表的元素排列组合成 tuple 序列：

```Shell
>>> [(x, y) for x in [1,2,3] for y in [4,5,6]]
[(1, 4), (1, 5), (1, 6), (2, 4), (2, 5), (2, 6), (3, 4), (3, 5), (3, 6)]

# 注意：与 zip 的区别！
>>> [*zip([1,2,3],[4,5,6])]
[(1, 4), (2, 5), (3, 6)]
```

也可在循环后面增加过滤条件：

```Shell
>>> [(x, y) for x in [1,2,3] for y in [3,1,4] if x != y]
[(1, 3), (1, 4), (2, 3), (2, 1), (2, 4), (3, 1), (3, 4)]
```

### Nested

The initial expression in a list comprehension can be any arbitrary expression, including another list comprehension.

以下 matrix 定义了一个 3x4 的矩阵，然后通过嵌套 listcomp 实现矩阵的转置（transpose）。

```Shell
>>> matrix = [
...     [1, 2, 3, 4],
...     [5, 6, 7, 8],
...     [9, 10, 11, 12],
... ]
>>> [[row[i] for row in matrix] for i in range(4)]
[[1, 5, 9], [2, 6, 10], [3, 7, 11], [4, 8, 12]]
```

等效于 for 循环加一层 listcomp:

```Shell
>>> transposed = []
>>> for i in range(4):
...     transposed.append([row[i] for row in matrix])
...
>>> transposed
[[1, 5, 9], [2, 6, 10], [3, 7, 11], [4, 8, 12]]
```

当然，以上最简洁的等效实现方式是使用星号解引用搭配zip：`list(zip(*matrix))`。

### refs

关于 dict comprehension/set comprehension 等话题，参考 [6.2.4. Displays for lists, sets and dictionaries](https://docs.python.org/3/reference/expressions.html#displays-for-lists-sets-and-dictionaries)。

- [python知识点: 列表解析](https://blog.csdn.net/reallocing1/article/details/63409400)  
- [python-列表解析之if](https://blog.csdn.net/qq_25730711/article/details/53996124)  
- [Python列表解析（列表推导式）](https://blog.csdn.net/shingle_/article/details/55050701)  
- [形象地解释 Python 中的列表解析](http://python.jobbole.com/83884/)  
- [推导式 Comprehension](https://eastlakeside.gitbook.io/interpy-zh/comprehensions)
