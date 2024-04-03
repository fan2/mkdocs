---
title: python中的容器类——collections
authors:
  - xman
date:
    created: 2019-12-06T09:00:00
categories:
    - python
tags:
    - collections
comments: true
---

本文简单梳理了 python 中的容器类 collections 提供的便利工具集（wrapper toolset）。

<!-- more -->

[collections](https://docs.python.org/3/library/collections.html) — Container datatypes

- `namedtuple()`（命名元组）: factory function for creating tuple subclasses with named fields  
- `deque`（双端队列）: list-like container with fast appends and pops on either end  
- `ChainMap`（链接字典）: dict-like class for creating a single view of multiple mappings  
- `Counter`（计数器）: dict subclass for counting hashable objects  
- `OrderedDict`（有序字典）: dict subclass that remembers the order entries were added  
- `defaultdict`: dict subclass that calls a factory function to supply missing values  
- `UserDict`: wrapper around dictionary objects for easier dict subclassing  
- `UserList`: wrapper around list objects for easier list subclassing  
- `UserString`: wrapper around string objects for easier string subclassing  

## help

```Shell
>>> import collections
>>> help(collections)

Help on package collections:

NAME
    collections

DESCRIPTION
    This module implements specialized container datatypes providing
    alternatives to Python's general purpose built-in containers, dict,
    list, set, and tuple.

    * namedtuple   factory function for creating tuple subclasses with named fields
    * deque        list-like container with fast appends and pops on either end
    * ChainMap     dict-like class for creating a single view of multiple mappings
    * Counter      dict subclass for counting hashable objects
    * OrderedDict  dict subclass that remembers the order entries were added
    * defaultdict  dict subclass that calls a factory function to supply missing values
    * UserDict     wrapper around dictionary objects for easier dict subclassing
    * UserList     wrapper around list objects for easier list subclassing
    * UserString   wrapper around string objects for easier string subclassing
```

## OrderedDict

[Converting dict to OrderedDict](https://stackoverflow.com/questions/15711755/converting-dict-to-ordereddict)

```Python
import collections

Joe = {"Age": 28, "Race": "Latino", "Job": "Nurse"}
Bob = {"Age": 25, "Race": "White", "Job": "Mechanic", "Random": "stuff"}

#Just for clarity:
Joe = collections.OrderedDict(Joe)
Bob = collections.OrderedDict(Bob)

print(Joe)
# OrderedDict([('Age', 28), ('Race', 'Latino'), ('Job', 'Nurse')])
print(Bob)
# OrderedDict([('Age', 25), ('Race', 'White'), ('Job', 'Mechanic'), ('Random', 'stuff')])
```

## OrderedSet

[Does Python have an ordered set?](https://stackoverflow.com/questions/1653970/does-python-have-an-ordered-set)

[orderedset](https://pypi.org/project/orderedset/)
