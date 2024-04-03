---
title: python内置模块之集合(set)
authors:
  - xman
date:
    created: 2019-12-04T09:20:00
categories:
    - python
tags:
    - set
comments: true
---

Python内置模块中的集合（builtins.set）的基本用法。

<!-- more -->

[Set Types — set, frozenset](https://docs.python.org/3/library/stdtypes.html#set-types-set-frozenset)

## help

```Shell
>>> help(set)

Help on class set in module builtins:

class set(object)
 |  set() -> new empty set object
 |  set(iterable) -> new set object
 |
 |  Build an unordered collection of unique elements.
```

## empty set

`st=set()`: 构造一个空集合对象。  

> 注意： `st={}` 定义的是空字典。  

`st={1,2}` 相当于 `st=set();st.add(1);st.add(2)`。

集合不支持基于脚标索引访问元素（access through subscripted index）。

## expressions

- `len(st)`: Return the number of elements in set st.  
- `e in st`: Test e for membership in st.  
- `e not in st`: Test e for non-membership in st.  
- `for e in st`: enumerate elements in st.  

## api overview

```Shell
>>> set.
set.add(                          set.intersection(                 set.pop(
set.clear(                        set.intersection_update(          set.remove(
set.copy(                         set.isdisjoint(                   set.symmetric_difference(
set.difference(                   set.issubset(                     set.symmetric_difference_update(
set.difference_update(            set.issuperset(                   set.union(
set.discard(                      set.mro()                         set.update(
```

基于 set 提供的丰富接口，可执行常见的集合运算。

## set vs. list

集合 set 相对 list 的最大区别是，集合 set 中的元素必须是独一无二的，add重复元素无效。

```Shell
 |  add(...)
 |      Add an element to a set.
 |
 |      This has no effect if the element is already present.
```

```Shell
>>> lt=[1,2]
>>> lt.add(2)
>>> lt.append(2)
>>> lt
[1, 2, 2]

>>> st={1,2}
>>> st
{1, 2}
>>> st.add(2)
>>> st
{1, 2}
```

可以基于list构造set，移除相同的元素实现去重：

```Shell
>>> lt=[1,2,2]
>>> set(lt)
{1, 2}
```

此外，set 支持常规集合运算：

- 集合包含关系：issuperset、issubset
- 计算并集：union
- 计算交集：intersection
- 计算差集：difference
