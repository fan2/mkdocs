---
title: python中的枚举类型——enum
authors:
  - xman
date:
    created: 2019-12-06T08:40:00
categories:
    - python
tags:
    - enum
comments: true
---

本文简单介绍了 python 中枚举类 enum 的基本用法。

<!-- more -->

[Python中枚举的使用](https://blog.csdn.net/m0_38061927/article/details/76058133)

## help

```Shell
>>> import enum
>>> help(enum)

Help on module enum:

NAME
    enum

CLASSES
    builtins.int(builtins.object)
        IntEnum(builtins.int, Enum)
        IntFlag(builtins.int, Flag)
    builtins.object
        Enum
            Flag
                IntFlag(builtins.int, Flag)
            IntEnum(builtins.int, Enum)
        auto
    builtins.type(builtins.object)
        EnumMeta
```

## usage

```
from enum import Enum

class Color (Enum):
      red=1
      orange=2
      yellow=3
      green=4
      blue=5
      indigo=6
      purple=7
```

如果要限制定义枚举时，不能定义相同值的成员。可以使用装饰器 `@unique`:

```
from enum import Enum, unique

@unique
class Color(Enum):

```

## access

通过成员的名称来获取成员：

```
>>> Color['red']
<Color.red: 1>
```

通过成员的值来获取成员：

```
>>> Color(1)
<Color.red: 1>
```

通过成员，来获取它的名称和值：

```
>>> Color.red
<Color.red: 1>

>>> Color.red.name
'red'
>>> Color.red.value
1
```