---
title: python内置模块之字符串(str)
authors:
  - xman
date:
    created: 2019-12-04T08:20:00
categories:
    - python
tags:
    - str
comments: true
---

Python内置模块中的字符串（builtins.str）基本用法。

<!-- more -->

# [Text Sequence Type — str](https://docs.python.org/3/library/stdtypes.html#text-sequence-type-str)

[str](https://docs.python.org/3/library/stdtypes.html#str)  
[str tutorial](https://docs.python.org/3.6/tutorial/introduction.html#strings)  

字符串类 str 是 python 最常用的类，用来处理字符序列和文本数据。

## help

```
>>> help(str)

Help on class str in module builtins:

class str(object)
 |  str(object='') -> str
 |  str(bytes_or_buffer[, encoding[, errors]]) -> str
 |
 |  Create a new string object from the given object. If encoding or
 |  errors is specified, then the object must expose a data buffer
 |  that will be decoded using the given encoding and error handler.
 |  Otherwise, returns the result of object.__str__() (if defined)
 |  or repr(object).
 |  encoding defaults to sys.getdefaultencoding().
 |  errors defaults to 'strict'.
```

## empty string

1. `s=str()`: 构造一个空字符串对象。  
2. `s=''`：定义空字符串字面量。  

## Literals

参考 reference - [2.4. Literals](https://docs.python.org/3/reference/lexical_analysis.html#literals) - String and Bytes literals。

One syntactic restriction not indicated by these productions is that whitespace is not allowed between the `stringprefix` or `bytesprefix` and the rest of the literal.

String literals are described by the following lexical definitions:

```
stringliteral   ::=  [stringprefix](shortstring | longstring)
stringprefix    ::=  "r" | "u" | "R" | "U" | "f" | "F"
                     | "fr" | "Fr" | "fR" | "FR" | "rf" | "rF" | "Rf" | "RF"
```

Bytes literals are described by the following lexical definitions:

```
bytesliteral   ::=  bytesprefix(shortbytes | longbytes)
bytesprefix    ::=  "b" | "B" | "br" | "Br" | "bR" | "BR" | "rb" | "rB" | "Rb" | "RB"
```

### 原始字符串

Both string and bytes literals may optionally be prefixed with a letter `'r'` or `'R'`; such strings are called *raw* strings and treat backslashes as literal characters. As a result, in string literals, `'\U'` and `'\u'` escapes in raw strings are not treated specially.

用前缀r表示原始字符串。原始字符串不会对反斜杠做特殊处理，而是让字符串包含的每个字符都保持原样。

```Shell
>>> print(r'C:\nowhere')
C:\nowhere
```

一个例外是，引号需要像通常那样进行转义，但这意味着用于执行转义的反斜杠也将包含在最终的字符串中。

```Shell
>>> print(r'Let\'s go!')
Let\'s go!
```

### 三种引号定义

字符串有三种定义方式：

- Single quotes: `'allows embedded "double" quotes'`  
- Double quotes: `"allows embedded 'single' quotes"`  
- Triple quoted: `'''Three single quotes''', """Three double quotes"""`  

> **Triple quoted** strings may span multiple lines - all associated whitespace will be included in the string literal.

其中单引号定义的字符串中可携带双引号；双引号定义的字符串中可携带单引号。  
若想以跨行模式定义长字符串，则可考虑使用三引号，支持换行书写。  

#### 单引号

单引号定义的字符串中可包含双引号：

```Shell
>>> 'allows embedded "double" quotes'
'allows embedded "double" quotes'

>>> '"Hello, world!" she said'
'"Hello, world!" she said'
```

单引号定义的字符串中不能包含撇号，否则解释器报错：

```Shell
>>> 'Let's go!'
  File "<stdin>", line 1
    'Let's go!'
         ^
SyntaxError: invalid syntax
```

> 在这里，字符串为 'Let'，因此 Python 不知道如何处理 s 后面的内容。

可使用反斜杠（\\）对引号进行转义，示意中间的引号是字符串的一部分，而非字符串结束标志。

```
>>> 'Let\'s go!'
"Let's go!"
```

#### 双引号

双引号定义的字符串中可包含单引号：

```Shell
>>> "allows embedded 'single' quotes"
"allows embedded 'single' quotes"

>>> "Let's go!"
"Let's go!"
```

双引号定义的字符串中不能包含双引号，否则解释器报错：

```Shell
>>> ""Hello, world!" she said"
  File "<stdin>", line 1
    ""Hello, world!" she said"
          ^
SyntaxError: invalid syntax
```

此时，使用反斜杠（\\）对字符串中的双引号进行转义，示意中间的双引号为原义。

```Shell
>>> "\"Hello, world!\" she said"
'"Hello, world!" she said'
```

#### 三引号

可使用三引号（三个单引号或三个双引号）来表示很长的字符串：

```Shell
>>> '''Three single quotes''', """Three double quotes"""
('Three single quotes', 'Three double quotes')
```

三引号中可包含单引号和双引号：

```Shell
>>> str1 = ''''single' quotes and "double" quotes in Three single quotes'''
# 相当于 print(repr(str1))
>>> str1
'\'single\' quotes and "double" quotes in Three single quotes'
# 相当于 print(str(str1))
>>> print(str1)
'single' quotes and "double" quotes in Three single quotes

# 注意中间包含撇号还是要转义！
>>> str2='''Let\'s say "Hello, world!"'''
# 相当于 print(repr(str2))
>>> str2
'Let\'s say "Hello, world!"'
# 相当于 print(str(str2))
>>> print(str2)
Let's say "Hello, world!"
```

### bytes

[bytes](https://docs.python.org/3/library/stdtypes.html#bytes)

Only ASCII characters are permitted in bytes literals (regardless of the declared source code encoding).  
Any binary values over 127 must be entered into bytes literals using the appropriate escape sequence.

Bytes literals are always prefixed with `'b'` or `'B'`; they produce an instance of the `bytes` type instead of the `str` type.  
They may only contain ASCII characters; bytes with a numeric value of 128 or greater must be expressed with escapes.

```
>>> bs = b'ABC'
>>> type(bs)
<class 'bytes'>

>>> bs
b'ABC'
>>> bs[0]
65
>>> bs[1]
66
>>> bs[2]
67
```

Since 2 hexadecimal digits correspond precisely to a single byte, hexadecimal numbers are a commonly used format for describing binary data. Accordingly, the bytes type has an additional class method to read data in that format:

```
classmethod fromhex(string)
    This bytes class method returns a bytes object, decoding the given string object.  
    The string must contain two hexadecimal digits per byte, with ASCII whitespace being ignored.
```

```Python
>>> dot = b'\x2E'
>>> dot
b'.'

>>> bytes.fromhex('2Ef0 F1f2  ')
b'.\xf0\xf1\xf2'
```

其中 ASCII 字符 `.` 的编码为 0x2E(46)：

```
>>> chr(0x2E)
'.'
>>> int('2E', 16)
46
>>> ord('.')
46
>>> hex(46)
'0x2e'
```

A **reverse** conversion function exists to transform a bytes object into its hexadecimal representation.

```
hex()
    Return a string object containing two hexadecimal digits for each byte in the instance.
```

```
>>> b'\xf0\xf1\xf2'.hex()
'f0f1f2'

>>> bs.hex()
'414243'
```

## assign copy

[Python Strings | Python Education - Google for Developers](https://developers.google.com/edu/python/strings)

> Python strings are "immutable" which means they cannot be changed after they are created.  
> Since strings can't be changed, we construct *new* strings as we go to represent computed values.  

由于 str 是 immutable 的，赋值是拷贝（duplicate）副本（copy）。

```Python
mr = 'Mr. Entity'
mrs = mr # duplicate
mrs = 'Mrs. Entity'
print(mr) # remain unchanged
print(mr is mrs) # False
```

## sequential access

access through subscripted index

```Shell
>>> word = 'Python'
```

顺序索引访问（从0开始）：

```
>>> #第一个字符
... word[0]
'P'

>>> #最后一个字符
... word[len(word)-1]
'n'
>>> word[5]
'n'
```

负数倒序索引访问（从-1开始）：

```
>>> #倒数第一个字符
... word[-1]
'n'

>>> #倒数第二个字符
... word[-2]
'o'

>>> #倒数第六个字符
... word[-6]
'P'
```

区间索引访问：

```
>>> word[0:2]
'Py'
>>> word[2:5]
'tho'
```

不指定起始索引，默认的起始索引为句首（0）:

```
>>> word[:2]
'Py'
```

不指定起始索引，默认的起始索引至末尾（len(s)-1,-1）:

```>>> word[2:]
'thon'
>>> word[4:]
'on'
>>> word[-2:]
'on'
```

## Core Methods

[String Methods](https://docs.python.org/3.6/library/stdtypes.html#string-methods)

```Shell

# 基于占位符格式化创建字符串
str.format(*args, **kwargs)

# 判断是否以某个子串开头/结尾
str.startswith(prefix[, start[, end]])
str.endswith(suffix[, start[, end]])

# 计算子串的个数
str.count(sub[, start[, end]])

# 查找子串的位置索引，不存在则返回-1
str.find(sub[, start[, end]])
str.rfind(sub[, start[, end]])

# 查找子串的位置索引，找不到则抛 ValueError 异常
str.index(sub[, start[, end]]) 
str.rindex(sub[, start[, end]])

# 替换子串
str.replace(old, new[, count])

# 移除开头或结尾的空白
str.strip([chars])
str.lstrip([chars])
str.rstrip([chars])

# 分割三部分(head, sep, tail)
str.partition(sep)
str.rpartition(sep)

# 按照分隔符分割成子串
str.split(sep=None, maxsplit=-1)
str.rsplit(sep=None, maxsplit=-1)

str.splitlines([keepends])

```

capitalize 将首字母大写；title 将每个单词首字母大写；upper/lower将全部字母大写/小写。

> 由于 str 是 immutable 的，这些大小写操作函数都是基于副本操作，返回处理后的副本，不影响原件(str1)。

```Shell
#%%
str1='hello, world!'
str2=str1.capitalize()
print(str2) # Hello, world!
str3=str1.title()
print(str3) # Hello, World!
str4=str1.upper()
print(str4) # HELLO, WORLD!
str5=str4.lower()
print(str5) # hello, world!
```

### startswith tuple

startswith 的位置参数 prefix 除了支持单个字符串，也支持传入字符串 tuple(str1,str2,...)，逐个尝试匹配。

```Shell
>>> help(str)

 |  startswith(...)
 |      S.startswith(prefix[, start[, end]]) -> bool
 |
 |      Return True if S starts with the specified prefix, False otherwise.
 |      With optional start, test S beginning at that position.
 |      With optional end, stop comparing S at that position.
 |      prefix can also be a tuple of strings to try.
```

例如，以下代码片段逐行读取文本文件，判断开头是否以空白字符集开头：

```Python
import string

with open('test.py') as f:
    for index, line in enumerate(f):
        if (not line.startswith(tuple(string.whitespace))):
            print(f'{index+1}:', line, end='')
        else:
            print(f'{index+1}: ')
```

### join iterable

```Shell
>>> help(str)

 |  join(self, iterable, /)
 |      Concatenate any number of strings.
 |
 |      The string whose method is called is inserted in between each given string.
 |      The result is returned as a new string.
 |
 |      Example: '.'.join(['ab', 'pq', 'rs']) -> 'ab.pq.rs'
```

string.py 中的 string.capwords 方法即使用 map 迭代器搭配 join 实现：

```Python
# Capitalize the words in a string, e.g. " aBc  dEf " -> "Abc Def".
def capwords(s, sep=None):
    return (sep or ' ').join(map(str.capitalize, s.split(sep)))
```

Pretty-Printed Python Path:

> python3 -c "import sys, pprint; pprint.pp(sys.path)"
> python3 -c "import sys; print('\n'.join(sys.path))"

### expressions

- `len(s)`: Return the length of str(number of single character).  
- `c in s`: Test x for membership in s.  
- `c not in s`: Test x for non-membership in s.  
- `for c in s`: enumerate substring(character)  in s.  

### demos

```Shell

>>> str1='py'
>>> str2='python'

>>> str1 in str2
True

>>> str2.find(str1)
0

>>> str2.count(str1)
1

>>> str2.startswith(str1) or str2.endswith(str1)
True
```
