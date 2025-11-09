---
title: python内置模块之字符串格式化(str.format)
authors:
  - xman
date:
    created: 2019-12-04T08:30:00
categories:
    - python
tags:
    - str
    - format
    - template
comments: true
---

Python内置模块中的字符串（builtins.str）格式化惯用法。

<!-- more -->

[Format String Syntax](https://docs.python.org/3/library/string.html#format-string-syntax)  

- [Format Specification Mini-Language](https://docs.python.org/3/library/string.html#formatspec)  
- [Format examples](https://docs.python.org/3/library/string.html#format-examples)

控制台输入 `help('FORMATTING')` 可查看字符串格式化相关议题（Format String Syntax）。

[7. Input and Output — Python 3.12.2 documentation](https://docs.python.org/3/tutorial/inputoutput.html)

---

[Python String Formatting Best Practices](https://realpython.com/python-string-formatting/)

1. “Old Style” String Formatting (% Operator)
2. “New Style” String Formatting (str.format)
3. String Interpolation / f-Strings (Python 3.6+)
4. Template Strings (Standard Library)

[比較 Python 的格式化字串 — %-formatting、str.format()、 f-string](https://zoejoyuliao.medium.com/%E6%AF%94%E8%BC%83-python-%E7%9A%84%E6%A0%BC%E5%BC%8F%E5%8C%96%E5%AD%97%E4%B8%B2-formatting-str-format-f-string-6d28487ba1d2)

## format()

builtins.format # help('FORMATTING')  

参考 [builtins.format](https://docs.python.org/3/library/functions.html#format)，format 函数将值类型按照指定格式转换为字符串表示。

```
format(value[, format_spec])

Convert a value to a “formatted” representation, as controlled by *format_spec*. 
```

The default `format_spec` is an empty string which usually gives the same effect as calling `str(value)`.

str(255) 将值字符串化为 '255'，hex(255) 将值字符串化为带 0x 前缀的十六进制表示 '0xff'。
除此之外，可以通过 format 函数指定更详细的表示格式，例如不带 0x 前缀、十六进制大小写等。

```Shell
>>> format(255, '#x'), format(255, 'x'), format(255, 'X')
('0xff', 'ff', 'FF')
```

## %-formatting

Old string formatting

The % operator (modulo) can also be used for string formatting.
This operation is commonly known as string interpolation.

[printf-style String Formatting](https://docs.python.org/3/library/stdtypes.html#printf-style-string-formatting)

String objects have one unique built-in operation: the `%` operator (modulo). This is also known as the string *formatting* or *interpolation* operator. Given `format % values` (where format is a string), `%` conversion specifications in format are **replaced** with zero or more elements of *values*. The effect is similar to using the `sprintf`() in the C language.

If format requires a single argument, *values* may be a single non-tuple object. Otherwise, values must be a **tuple** with exactly the number of items specified by the format string, or a single mapping object (for example, a dictionary).

[How to print a C format in python](https://stackoverflow.com/questions/45622463/how-to-print-a-c-format-in-python)

C printf 风格，使用 `%` 格式符标识占位。

直接字符串字面值表达式：

```Shell
>>> '%#x' % 255, '%x' % 255, '%X' % 255
('0xff', 'ff', 'FF')
```

使用 print 函数打印输出：

```Shell
# start 可加括号
>>> print('start is %d' % start)
start is 0

>>> print('start,stop is %d, %d' % (start, stop))
start,stop is 0, 30

name = "John"
age = 23
score = 85
print("Total score for", name, "is", score)
print("%s is %d years old." % (name, age))
```

也支持命名占位参数，后面以大括号字典形式给出（参数key对应）：

```Shell
>>> print('%(language)s has %(number)03d quote types.' % {'language': "Python", "number": 2})
Python has 002 quote types.
```

---

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

## str.format

[PEP 3101 – Advanced String Formatting](https://www.python.org/dev/peps/pep-3101)

> The ‘%’ operator is primarily limited by the fact that it is a binary operator, and therefore can take at most two arguments. One of those arguments is already dedicated to the format string, leaving all other variables to be **squeezed** into the remaining argument. The current practice is to use either a dictionary or a tuple as the second argument, but as many people have commented, this lacks flexibility. The “all or nothing” approach (meaning that one must choose between only positional arguments, or only named arguments) is felt to be overly constraining.

The built-in string class (and also the unicode class in 2.6) will gain a new method, ‘format’, which takes an arbitrary number of positional and keyword arguments:

函数原型：str.**format**(\**args*, \*\**kwargs*)

```
Perform a string formatting operation. The string on which this method is called can contain literal text or replacement fields delimited by braces {}. Each replacement field contains either the numeric index of a positional argument, or the name of a keyword argument.
```

- reference - [2.4.3. Formatted string literals](https://docs.python.org/3.6/reference/lexical_analysis.html#f-strings) - New in version 3.6.  
- tutorial - [7.1. Fancier Output Formatting](https://docs.python.org/3.6/tutorial/inputoutput.html#fancier-output-formatting)  
- library - [str.format](https://docs.python.org/3/library/stdtypes.html#str.format)  
- library - [**6.1.3. Format String Syntax**](https://docs.python.org/3/library/string.html#formatstrings)  

`str.format()` 函数把字符串当成一个模板，通过传入的参数进行格式化，并使用大括号 `{}` 作为特殊字符代替 % 占位格式符。

### positional argument

大括号中可指定参数索引（the numeric index of a positional argument）。  
从 Python 3.1 开始，占位序号也可以省略，`{} {}` 自动编号为 `{0} {1}`。  

Accessing arguments by position:

```Shell
>>> print('{0} {1}'.format('hello','world'))
hello world
>>> print('{} {}'.format('hello','world'))
hello world
# 重复使用某一位置序号
>>> print('{0} {1} {0}'.format('hello','world'))
hello world hello
```

甚至，可以像下面这样，把编号当对象使用进行深度引用：

```Shell
>>> table = {'Sjoerd': 4127, 'Jack': 4098, 'Dcab': 8637678}
>>> print('Jack: {0[Jack]:d}; Sjoerd: {0[Sjoerd]:d}; '
...       'Dcab: {0[Dcab]:d}'.format(table))
Jack: 4098; Sjoerd: 4127; Dcab: 8637678
```

### keyword argument

大括号中也可指定占位替换变量（the name of a keyword argument）。  

Accessing arguments by name:

```Shell
>>> print('i love {you}'.format(you='python'))
i love python
>>>
>>> 'Coordinates: {latitude}, {longitude}'.format(latitude='37.24N', longitude='-115.81W')
'Coordinates: 37.24N, -115.81W'
>>> 
>>> coord = {'latitude': '37.24N', 'longitude': '-115.81W'}
>>> 'Coordinates: {latitude}, {longitude}'.format(**coord)
'Coordinates: 37.24N, -115.81W'
```

以下示例利用三引号跨行定义一个 HTML 模板：

```Shell
>>> template='''<html>
... <head><title>{title}</title></head>
... <body>
... <h1>{title}</h1>
... <p>{text}</p>
... </body>'''

>>> template
'<html>\n<head><title>{title}</title></head>\n<body>\n<h1>{title}</h1>\n<p>{text}</p>\n</body>'

>>> print(template)
<html>
<head><title>{title}</title></head>
<body>
<h1>{title}</h1>
<p>{text}</p>
</body>
```

然后，通过 format 传参替换占位变量对模板进行实例化：

```Shell
>>> print(template.format(title='My Home Page', text='Welcome to my home page!'))
<html>
... <head><title>My Home Page</title></head>
... <body>
... <h1>My Home Page</h1>
... <p>Welcome to my home page!</p>
... </body>
```

### format_map

Python 3.2 开始还提供了 str.**format_map()** 方法，支持传入字典作为参数键值对对模板进行实例化：

```Shell
>>> data = {'title': 'My Home Page', 'text': 'Welcome to my home page!'}
>>> print(template.format_map(data))
<html>
<head><title>My Home Page</title></head>
<body>
<h1>My Home Page</h1>
<p>Welcome to my home page!</p>
</body>
```

### mixins

位置占位和关键字占位可混合使用：

```Shell
>>> a='python'
>>> b='you'
>>> d='me'
>>> "The story of {0}, {1}, and {c}".format(a, b, c=d)
'The story of python, you, and me'

>>> print('The story of {0}, {1}, and {other}.'.format('Bill', 'Manfred', other='Georg'))
The story of Bill, Manfred, and Georg.
```

## f-string

2016 发布的 Python 3.6 中新增的 `f-string`，可以解决 `%-formatting` 变量不易阅读以及 `str.format()` 接变量后变超长的问题。

[Formatted string literals](https://docs.python.org/3/reference/lexical_analysis.html#f-strings)

A *formatted string literal* or *f-string* is a string literal that is prefixed with `'f'` or `'F'`. These strings may contain replacement fields, which are expressions delimited by curly braces `{}`. While other string literals always have a constant value, formatted strings are really expressions evaluated at run time.

A string literal with `'f'` or `'F'` in its prefix is a *formatted string literal*. The `'f'` may be combined with `'r'`, but not with `'b'` or `'u'`, therefore raw formatted strings are possible, but formatted bytes literals are not.

语法和效果，有点类似 JavaScript 中 ES2015 引入的 [Template literals (Template strings)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals)。

If a conversion is specified, the result of evaluating the expression is converted before formatting. Conversion '`!s`' calls `str`() on the result, '`!r`' calls `repr`(), and '`!a`' calls `ascii`().

!s 对整数变量调用str字符串化输出：

> 此处不带这个，默认也会转换。

```Shell
>>> year = 2019
>>> f'year is {year!s}' # 等效于 f'year is {str(year)}'
'year is 2019'
```

!r 对字符串变量调用repr，保持原始字符串输出（包括引号）：

```Shell
>>> name = "Fred"
>>> f"He said his name is {name}."
'He said his name is Fred.'
>>> f"He said his name is {name!r}." # f"He said his name is {repr(name)}."
"He said his name is 'Fred'."
```

或者用 `=` 来实现类似的效果：

```Shell
>>> f"He said his {name = }."
"He said his name = 'Fred'."
```

对于 iterable 类型，实际上是 iter next 调用多次：

```Shell
>>> a=["a", "b", "c"]
>>> print(f"List a contains:\n{"\n".join(a)}")
List a contains:
a
b
c
```

**参考资料**：

- [Python 3's f-Strings: An Improved String Formatting Syntax](https://realpython.com/python-f-strings/)
- [String formatting for dictionary with f-string in Python](https://bobbyhadz.com/blog/python-string-formatting-dictionary-f-string)
- [How can I do a dictionary format with f-string in Python 3 .6?](https://stackoverflow.com/questions/43488137/how-can-i-do-a-dictionary-format-with-f-string-in-python-3-6)

### 指定格式

对于日期按照年月日字段格式组合输出：

```Shell
>>> today = datetime.datetime(year=2017, month=1, day=27)
>>> f"{today:%B %d, %Y}"  # using date format specifier
'January 27, 2017'
>>> f"{today=:%B %d, %Y}" # using date format specifier and debugging
'today=January 27, 2017'
```

对数字进行快捷转换，按指定进制/格式输出：

```Shell
>>> number = 1024
>>> f"{number:#0x}"
'0x400'

>>> f'{255:#x}', f'{255:x}', f'{255:X}'
('0xff', 'ff', 'FF')
```

### 支持运算

Because f-strings are evaluated at *runtime*, you can put any and all valid Python expressions in them.

```Shell
>>> a = 5
>>> b = 10
>>> f'Five plus ten is {a + b} and not {2 * (a + b)}.'
'Five plus ten is 15 and not 30.'

>>> x=10
>>> y=3
>>> f'{x/y = :.2f}'
'x/y = 3.33'
>>> f'{x}/{y} = {x/y:.2f}'
'10/3 = 3.33'
```

### 跨行拼接

Formatted string literals may be concatenated, but replacement fields cannot be split across literals.

Multiline f-Strings:

```Python
name = "Eric"
profession = "comedian"
affiliation = "Monty Python"

# 续行符
message = f"Hi {name}. " \
          f"You are a {profession}. " \
          f"You were in {affiliation}."
print(message)

# 括号省略续行符
message = (f"Hi {name}. "
           f"You are a {profession}. "
           f"You were in {affiliation}.")
print(message)

# f加三引号，则按照排版输出，包括换行缩进
message = f"""Hi {name}. 
You are a {profession}. 
You were in {affiliation}."""
print(message)
```

以下示例多个 f-strings 进行跨行拼接：

```Python
    payload = {
        'msgtype': 'markdown',
        'markdown': {
            'content':
            f'**App昨日Crash统计**\n'
            f'**Android前一版本crash率:** {(android_old_crash_rate * 100):.4f}%\n'
            f'**Android前一版本flutter错误率:** {(android_old_error_rate * 100):.4f}%\n'
            f'**Android当前版本crash率:** {(android_new_crash_rate * 100):.4f}%\n'
            f'**Android当前版本flutter错误率:** {(android_new_error_rate * 100):.4f}%\n'
            f'**IOS前一版本crash率:** {(ios_old_crash_rate * 100):.4f}%\n'
            f'**IOS前一版本flutter错误率:** {(ios_old_error_rate * 100):.4f}%\n'
            f'**IOS当前版本crash率:** {(ios_new_crash_rate * 100):.4f}%\n'
            f'**IOS当前版本flutter错误率:** {(ios_new_error_rate * 100):.4f}%\n'
        }
    }
```

## string Template

The [string](https://docs.python.org/3.6/library/string.html#module-string) module contains a [Template](https://docs.python.org/3.6/library/string.html#string.Template) class which offers yet another way to **substitute** values into strings.

参考：[builtins.str](./3-builtins.str.md)。

## rule of thumb

Python String Formatting Rule of Thumb: If your format strings are user-supplied, use Template Strings to avoid security issues.  
Otherwise, use Literal String Interpolation/f-Strings if you're on Python 3.6+, and “New Style” str.format if you're not.  