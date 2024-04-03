---
title: python内置函数之print
authors:
  - xman
date:
    created: 2019-12-04T08:10:00
categories:
    - python
tags:
    - print
comments: true
---

Python内置函数 builtins.print 基本用法。

<!-- more -->

- builtins.repr  
- builtins.print  

在 Python 2 中，print 为关键字；在 Python 3 中，print 为内置函数（builtins.print）。

builtins 的 print() 函数：

```Shell
    print(...)
        print(value, ..., sep=' ', end='\n', file=sys.stdout, flush=False)
```

在 Python 3 中可执行 `help(print)` 查看 print 函数说明：

```Shell
>>> help(print)

Help on built-in function print in module builtins:

print(...)
    print(value, ..., sep=' ', end='\n', file=sys.stdout, flush=False)

    Prints the values to a stream, or to sys.stdout by default.
    Optional keyword arguments:
    file:  a file-like object (stream); defaults to the current sys.stdout.
    sep:   string inserted between values, default a space.
    end:   string appended after the last value, default a newline.
    flush: whether to forcibly flush the stream.
```

Python3 已经不支持 print 的非函数格式了，必须使用 `print()` 函数调用格式。

```Shell
>>> print 'hello,world!'
  File "<stdin>", line 1
    print 'hello,world!'
                       ^
SyntaxError: Missing parentheses in call to 'print'. Did you mean print('hello,world!')?
```

> [Python print函数用法](http://blog.csdn.net/zanfeng/article/details/52164124)  
> [python格式化输出](http://blog.csdn.net/wchoclate/article/details/42297173)  
> [python2与python3的print](https://blog.csdn.net/freestyle4568world/article/details/48369057)  

---

对很多应用程序来说，使用模块 logging 来写入日志比使用 print 更合适。

> 相关模块参考：syslog, logging。

## sep & end

### sep

print 一行打印多个变量（逗号分隔），默认会以空格（`sep=' '`）分隔：

```
>>> year=2019
>>> month=10
>>> day=1
>>> print(year,month,day)
2019 10 1
```

可以指定 sep 参数，定制行内分隔（连接）符：

```
>>> print(year,month,day,sep='')
2019101
>>> print(year,month,day,sep='-')
2019-10-1
```

另外一个例子：print 打印日志起始行 tuple，两行之间插了一个空格：

```
mbr_start_line = '2019-09-22 21:41:59.416 Debug|1031|137920|:96|IMPDT_MBR_Engine||start: role = 1\n'
mbr_stop_line = '2019-09-22 21:43:59.947 Debug|1031|672495|:125|IMPDT_MBR_Engine||stop: reset role from 1\n'
print(mbr_start_line, mbr_stop_line)
```

```
2019-09-22 21:41:59.416 Debug|1031|137920|:96|IMPDT_MBR_Engine||start: role = 1
 2019-09-22 21:43:59.947 Debug|1031|672495|:125|IMPDT_MBR_Engine||stop: reset role from 1
```

也可以指定 sep 去掉空格：`print(mbr_start_line, mbr_stop_line,sep='')`

### end

```
mbr_start_line = '2019-09-22 21:41:59.416 Debug|1031|137920|:96|IMPDT_MBR_Engine||start: role = 1\n'
mbr_stop_line = '2019-09-22 21:43:59.947 Debug|1031|672495|:125|IMPDT_MBR_Engine||stop: reset role from 1\n'
#print(mbr_start_line),print(mbr_stop_line)
mbr_border_lines = (mbr_start_line, mbr_stop_line) # make tuple
for line in mbr_border_lines:
    print(line,end='') #print(line)
```

打印结果为：

```
2019-09-22 21:41:59.416 Debug|1031|137920|:96|IMPDT_MBR_Engine||start: role = 1

2019-09-22 21:43:59.947 Debug|1031|672495|:125|IMPDT_MBR_Engine||stop: reset role from 1

```

由于按文本读出的行末尾本身就有换行符，因此在连续打印多行日志时，可考虑将 print 在尾部追加的换行符置空，或定制其他行间分隔符。

> 将 `print(line)` 修改为 `print(line, end='')` 即可。

## expr

`print(var)` 或 `print(expr)` 打印变量或表达式的值。

```Shell
>>> start=1
>>> stop=10
>>> step=2

>>> print(start)
1

>>> print(start+step)
3

>>> r=range(1,10,2)
# python2
>>> print(r)
[1, 3, 5, 7, 9]
# python3
>>> print(r)
range(1, 10, 2)

>>> l1=[1,2,3,4]
>>> print(l1)
[1, 2, 3, 4]

```

## repr

`print(object)` 输出类型或描述信息。

```Shell
#######################################
# 打印模块信息
#######################################
# python3
>>> print(builtins)
<module 'builtins' (built-in)>

>>> print(array)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'array' is not defined
>>> import array

# python2
>>> print(array)
<module 'array' from '/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/lib-dynload/array.so'>

# python3
>>> print(array)
<module 'array' from '/usr/local/Cellar/python/3.6.5/Frameworks/Python.framework/Versions/3.6/lib/python3.6/lib-dynload/array.cpython-36m-darwin.so'>
```

除此之外，调用 `repr(obj)` 可以获取该 obj 对象实例的描述信息。

repr 实际上调用的是 obj 的 `__repr__` 方法：`repr(obj) = obj.__repr__()`

```
>>> help(repr)

Help on built-in function repr in module builtins:

repr(obj, /)
    Return the canonical string representation of the object.
    
    For many object types, including most builtins, eval(repr(obj)) == obj.
```

部分示例如下：


```
#######################################
# 打印模块类型信息
#######################################

>>> print(list)
<class 'list'>

>>> repr(list)
"<class 'list'>"

>>> print(len)
<built-in function len>

>>> repr(len)
'<built-in function len>'

>>> print(hex)
<built-in function hex>

>>> repr(hex)
'<built-in function hex>'

#######################################
# 打印对象实例描述（__repr__）
#######################################

>>> print(sys.version_info)
sys.version_info(major=3, minor=6, micro=5, releaselevel='final', serial=0)

>>> repr(sys.version_info)
"sys.version_info(major=3, minor=9, micro=13, releaselevel='final', serial=0)"

>>> print(sys.thread_info)
sys.thread_info(name='pthread', lock='mutex+cond', version=None)

>>> repr(sys.thread_info)
"sys.thread_info(name='pthread', lock='mutex+cond', version=None)"
```

## list vars

逗号后直接接变量，Python 2 下输出 tuple；Python 3 将自动拼接前半句字面量和后面的变量，以空格（space-separated with `sep=' '`）隔开。

```Shell
>>> start=0
>>> stop=30
>>> step=5

# python2 下的输出 tuple
>>> print('start is', start)
('start is', 0)
>>> print('start, stop is', start, stop)
('start, stop is', 0, 30)

# python3 下的输出
>>> print('start is', start)
start is 0
>>> print('start, stop is', start, stop)
start, stop is 0 30
```

变量也可穿插在中间：

```Shell
>>> name = "John"
>>> score = 85
>>> print("Total score for", name, "is", score)
Total score for John is 85
```

## format

可参考 builtins.format 和 str.format 函数，输入 `help('FORMATTING')` 可查看字符串格式化相关议题。

- 参考 [builtins.str.format](./4-builtins.str.format.md)、[builtins.str]( ./3-builtins.str.md)。

### printf-style

[printf-style String Formatting](https://docs.python.org/3/library/stdtypes.html#printf-style-string-formatting)

C printf 风格，使用 `%` 格式符标识占位，

```Shell
# start 可加括号
>>> print('start is %d' % start)
start is 0

>>> print('start,stop is %d, %d' % (start, stop))
start,stop is 0, 30

```

以下采用 C-printf-style，控制字符串截断输出：

```Shell
>>> 'i love %s' % 'python'
'i love python'
>>> 'i love %.2s' % 'python'
'i love py'

# 截取两位，总共三位，默认右对齐
>>> 'i love %3.2s' % 'python'
'i love  py'

# 截取两位，总共十位，默认右对齐
>>> 'i love %10.2s' % 'python'
'i love         py'

# 截取两位，总共十位，设置左对齐
>>> 'i love %-10.2s' % 'python'
'i love py        '

# 截取两位，总共十位，设置左对齐
>>> 'i love %-10.2s !' % 'python'
'i love py         !'
```

### format specifier

在占位序号或关键字之后可以 `:` 来设置填充（fill）、对齐（align）、位宽（width）、进制（base）等格式控制。

> An optional '`:`' and format specifier can follow the field name. This allows greater control over how the value is formatted.

1. 设置打印进制格式(str.format)

```Shell
>>> # format also supports binary numbers
>>> "int: {0:d};  hex: {0:x};  oct: {0:o};  bin: {0:b}".format(42)
'int: 42;  hex: 2a;  oct: 52;  bin: 101010'

>>> # with 0x, 0o, or 0b as prefix:
>>> "int: {0:d};  hex: {0:#x};  oct: {0:#o};  bin: {0:#b}".format(42)
'int: 42;  hex: 0x2a;  oct: 0o52;  bin: 0b101010'

```

2. 设置浮点数位数(str.format)

```Shell
>>> import math
>>> print('The value of PI is approximately {0:.3f}.'.format(math.pi))
The value of PI is approximately 3.142.

>>> '{0:6.2f}'.format(math.pi)
'  3.14'
>>> '{0:>6.2f}'.format(math.pi)
'  3.14'
>>> '{0:<6.2f}'.format(math.pi)
'3.14  '
```

3. 设置输出宽度及填充格式(str.format)

	> Aligning the text and specifying a width

```Shell
# default align left, fill right with spaces
>>> '{:30}'.format('left aligned')
'left aligned                  '
>>> '{:<30}'.format('left aligned')
'left aligned                  '
>>> '{:>30}'.format('right aligned')
'                 right aligned'
>>> '{:^30}'.format('centered')
'           centered           '
>>> '{:*^30}'.format('centered')  # use '*' as a fill char
'***********centered***********'
>>> '{:-^30}'.format('centered')  # use '-' as a fill char
'-----------centered-----------'
```

> Passing an integer after the '`:`' will cause that field to be a minimum number of characters wide. This is useful for making tables pretty.

```Shell
# position:{width}{base}
>>> table = {'Sjoerd': 4127, 'Jack': 4098, 'Dcab': 7678}
>>> for name, phone in table.items():
...     print('{0:10} ==> {1:10d}'.format(name, phone))
... 
Sjoerd     ==>       4127
Jack       ==>       4098
Dcab       ==>       7678
```

4. 逗号千位分隔（Using the comma as a thousands separator）

```Shell
# 对整数进行千位分隔
>>> str1 = '{:,}'.format(1234567890)
>>> str1
'1,234,567,890'

# 去掉千位分隔符
>>> int(str1.replace(',', ''))
1234567890
```

5. 输出百分数(str.format)

```Shell
>>> points = 19
>>> total = 22
>>> 'Correct rate of answers: {:.2%}'.format(points/total)
'Correct rate of answers: 86.36%'
```
