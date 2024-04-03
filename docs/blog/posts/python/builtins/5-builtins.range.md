---
title: python内置模块之区间范围(range)
authors:
  - xman
date:
    created: 2019-12-04T08:40:00
categories:
    - python
tags:
    - range
comments: true
---

Python内置模块中的区间范围（builtins.range）的基本用法。

<!-- more -->

[range](https://docs.python.org/3/library/stdtypes.html#range)（区间范围）

## help

```Shell
>>> help(range)

Help on class range in module builtins:

class range(object)
 |  range(stop) -> range object
 |  range(start, stop[, step]) -> range object
 |
 |  Return an object that produces a sequence of integers from start (inclusive)
 |  to stop (exclusive) by step.  range(i, j) produces i, i+1, i+2, ..., j-1.
 |  start defaults to 0, and stop is omitted!  range(4) produces 0, 1, 2, 3.
 |  These are exactly the valid indices for a list of 4 elements.
 |  When step is given, it specifies the increment (or decrement).
```

## usage

```shell
>>> r=range(1,10,2)

>>> r.start
1
>>> r.stop
10
>>> r.step
2
```

可以将其转换为 tuple 或 list 打印出其值：

```
>>> tuple(r)
(1, 3, 5, 7, 9)

>>> list(r) # or [*r]
[1, 3, 5, 7, 9]
```

## access through subscripted index

range 支持下标索引访问：

```shell
>>> r[3]
7
>>> r[:3]
range(1, 7, 2)
>>> r[-1]
9
```

## expressions

- `len(r)`: Return the number of elements in range r.  
- `e in r`: Test e for membership in r.  
- `e not in r`: Test e for non-membership in r.  
- `for e in r`: enumerate elements in r.  

```shell
# 返回区间包含的元素个数
>>> len(r)
5

# 判断5是否在区间内
>>> 5 in r
True

# 判断6是否不在区间内
>>> 6 not in r
True

# for 循环遍历
>>> for i in r:
...     print(i)
... 
1
3
5
7
9
```

## Methods

```shell

 |  count(...)
 |      rangeobject.count(value) -> integer -- return number of occurrences of value
 |  
 |  index(...)
 |      rangeobject.index(value, [start, [stop]]) -> integer -- return index of value.
 |      Raise ValueError if the value is not present.
 
```

`r.count(e)`：返回区间范围内元素e的个数：

```shell
>>> r.count(4)
0
>>> r.count(5)
1
```

`r.index(e)`：返回区间范围内元素e的索引，不存在抛异常：

```shell
>>> r.index(4)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ValueError: 4 is not in range
>>> r.index(5)
2
```

## usage

区间的典型应用是界定列表索引：

```
>>> a = [1, 2, 3, 4, 5, 6, 7]
>>> a
[1, 2, 3, 4, 5, 6, 7]

>>> for i,e in enumerate(a):
...     print('l[%d] = %d' % (i, e))
...
l[0] = 1
l[1] = 2
l[2] = 3
l[3] = 4
l[4] = 5
l[5] = 6
l[6] = 7

>>> for i in range(0, len(a)): # i=[0, len(a)-1]
...     print("a[{0}] = {1}".format(i, a[i]))
...
a[0] = 1
a[1] = 2
a[2] = 3
a[3] = 4
a[4] = 5
a[5] = 6
a[6] = 7
```

### negative step

如果 `step>0`，则 `start+n*step` 终止条件为 `<stop`。

> 当顺序遍历数组时，索引范围是 [0, len-1]，终止条件为 `<len`。

如果 `step<0`，则 `start+n*step` 终止条件为 `>stop`。

> 当逆向遍历数组时，索引范围是 [len-1, 0]，终止条件为 `>-1`。

---

C语言中 `for (i=len-1; i>=1; i--)` 的等效实现：

> 冒泡升序排序中每轮的冒泡位置

```Python
A=[1,3,5,7,9]
for i in range(len(A)-1, 0, -1): # >0
    print(i, end=' ') # 4,3,2,1
```

C语言中 `for (i=len-1; i>=0; i--)` 的等效实现：

```Python
A=[1,3,5,7,9]
for i in range(len(A)-1, -1, -1): # >-1
    print(i, end=' ') # 4,3,2,1,0
```

C语言中 `for (int k=i; k>=offset; k-=offset)` 的等效实现：

> 希尔升序排序中

```Python
i=6; offset=2
# i=7; offset=2
for k in range(i, offset-1, -offset): # >offset-1
    print(k, end=' ')
```
