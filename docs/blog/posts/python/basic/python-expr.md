---
title: python expressions
authors:
  - xman
date:
    created: 2019-12-02T08:00:00
    updated: 2025-09-28T12:00:00
categories:
    - python
comments: true
---

python 中的基础表达式介绍。

<!-- more -->

reference - [6. Expressions](https://docs.python.org/3/reference/expressions.html)  
运算符相关：[6.16. Operator precedence](https://docs.python.org/3.6/reference/expressions.html?highlight=operator%20precedence#operator-precedence)  

```shell
>>> str1='1234567'
>>>
>>> range1=range(1,8)
>>> list(range1)
[1, 2, 3, 4, 5, 6, 7]
>>>
>>> tuple1=tuple(range1)
>>> tuple1
(1, 2, 3, 4, 5, 6, 7)
>>>
>>> list1=list(range1)
>>> list1
[1, 2, 3, 4, 5, 6, 7]
>>>
>>> dict1=dict() # dict1={}
>>> for i in range1:
...     k = 'k{}'.format(i) # 'k'+str(i)
...     dict1[k]=i
... 
>>> dict1
{'k1': 1, 'k2': 2, 'k3': 3, 'k4': 4, 'k5': 5, 'k6': 6, 'k7': 7}
>>>
>>> set1=set(range1)
>>> set1
{1, 2, 3, 4, 5, 6, 7}
>>>
```

## ternary conditional operator

[Does Python have a ternary conditional operator?](https://stackoverflow.com/questions/394809/does-python-have-a-ternary-conditional-operator)

```shell
>>> print('yes') if True else print('no')
yes
>>> print('yes') if False else print('no')
no
```

datetime.py

```python
def _cmp(x, y):
    return 0 if x == y else 1 if x > y else -1
```

## None, not

### None

内置的 None 常量经常用作哨符值，来作为默认值，或判断某些实例变量是否为尚未初始化的空对象。

```shell
>>> help('None')

Help on NoneType object:

class NoneType(object)
 |  Methods defined here:
 |  
 |  __bool__(self, /)
 |      self != 0
```

```python
def repeater(value):
    while True:
        new = (yield value)
        if new is not None: value = new
```

[深入理解Python中的None](https://zhuanlan.zhihu.com/p/65193194)  
[python 中None，is和==的深入探讨](https://www.jianshu.com/p/627232777efd)  
[python - What is the difference between "is None" and "== None"](https://stackoverflow.com/questions/3257919/what-is-the-difference-between-is-none-and-none)  

### not

```shell
>>> help('not')

Boolean operations
******************

   or_test  ::= and_test | or_test "or" and_test
   and_test ::= not_test | and_test "and" not_test
   not_test ::= comparison | "not" not_test

In the context of Boolean operations, and also when expressions are
used by control flow statements, the following values are interpreted
as false: "False", "None", numeric zero of all types, and empty
strings and containers (including strings, tuples, lists,
dictionaries, sets and frozensets).  All other values are interpreted
as true.  User-defined objects can customize their truth value by
providing a "__bool__()" method.
```

以下代码片段节选自 string.py 中 string.Template.substitute 方法的定义，若传入的元组 args 为空则抛出 TypeError 异常：

```python
    def substitute(*args, **kws):
        if not args:
            raise TypeError("descriptor 'substitute' of 'Template' object "
                            "needs an argument")

```

```python
if not (filename and text and password):
    print('Invalid parameters.')
    sys.exit()
```

## len(obj)

- `len(s)`: Return the length of str(number of single character).  

```shell
>>> help(len)

Help on built-in function len in module builtins:

len(obj, /)
    Return the number of items in a container.
```

本质上是调用对象的 `__len__()` 方法，返回序列（包括字符串）、集合或字典等容器所包含元素的个数。

```shell
# 等效于 list1.__len__()
>>> len(list1)
7
```

## in, not in

- `x in s`: Test x for membership in s.  
- `x not in s`: Test x for non-membership in s.  

```shell
>>> help('in')

Related help topics: SEQUENCEMETHODS

Membership test operations
**************************

The operators "in" and "not in" test for membership.  "x in s"
evaluates to "True" if *x* is a member of *s*, and "False" otherwise.
"x not in s" returns the negation of "x in s".  All built-in sequences
and set types support this as well as dictionary, for which "in" tests
whether the dictionary has a given key. For container types such as
list, tuple, set, frozenset, dict, or collections.deque, the
expression "x in y" is equivalent to "any(x is e or x == e for e in
y)".

For the string and bytes types, "x in y" is "True" if and only if *x*
is a substring of *y*.  An equivalent test is "y.find(x) != -1".
Empty strings are always considered to be a substring of any other
string, so """ in "abc"" will return "True".

For user-defined classes which define the "__contains__()" method, "x
in y" returns "True" if "y.__contains__(x)" returns a true value, and
"False" otherwise.
```

- `x in s` 测试 x 是否为 s 的成员，或者说 s 是否包含 x。  
- `x not in s` 等效于 `not x in s`，对 `x in s` 结果取反。  

内置序列及容器类型，如列表（list）、元组（tuple）、区间（range）、集合（set）、双端队列（collections.deque）等类型均支持包含关系测试符 in。 

字典（dict）也支持 in 测试符，但是是基于键值（keys）判断。

```shell
>>> # 等效于 'k3' in dict1.keys()
>>> 'k3' in dict1
True
>>> 3 in dict1
False
```

字符串（str）亦支持 in 测试符，不过是判断子串包含关系。`x in y` 等效于 `y.find(x) != -1`。

```shell
>>> '4' in str1
True
>>> '567' in str1
True
```

对于用户自定义的类型，`x in y` 等效于 `y.__contains__(x)`。

---

综上，`x in y` 等效于 **`any(x is e or x == e for e in y)`**.

## for

reference - [8.3. The for statement](https://docs.python.org/3/reference/compound_stmts.html#the-for-statement)  

- `for e in s`: enumerate elements in s.

The for statement is used to iterate over the elements of a sequence (such as a string, tuple or list) or other `iterable` object.

```
for_stmt ::=  "for" target_list "in" expression_list ":" suite
              ["else" ":" suite]
```

The expression list is evaluated once; it should yield an iterable object. An **iterator** is created for the result of the `expression_list`. The suite is then executed once for each item provided by the iterator, in the order returned by the iterator.

`for e in s` 遍历 s 中的元素 e，它针对任何可迭代（iterable）的对象 s 提供了一种更简约的迭代语法表达式。

```shell
>>> for e in list1:
...     print(e)
... 
1
2
3
4
5
6
7
```

`for ... in` 表达式背后还是基于迭代器（iterator）实现。

基于索引遍历访问的等效实现如下：

```shell
>>> i = 0;
>>> while i < len(list1):
...     print(list1[i])
...     i += 1
... 
```

**注意**：

- `for k in dict1` 遍历字典的键值，等效于 `for k in dict1.keys()`；  
- `for c in str1` 遍历字符串中的字符（单字符子串）。  

### Using \_ as a Loop Variable

> ChatGPT/DeepSeek topic: `Using an underscore _ as a loop variable in Python`

Using an underscore `_` as a loop variable in Python is a convention to indicate that the loop variable is *not* used within the loop's body. It signals that the loop is primarily for repeating an action a specific number of times, rather than processing the elements of an iterable.

In Python, using a single underscore `_` as a loop variable is a ​​convention to indicate that the loop variable is intentionally unused or irrelevant​​ within the loop body. This practice improves code readability by signaling to other developers that the value is being ignored.

For example:

```Python
for _ in range(5):
    print("Hello")
```

`_` signifies that the loop index is irrelevant; only the repetition matters. The loop executes five times (prints "Hello" 5 times), but the `_` variable (loop counter) is not used.

**Keywords**: Unused, Placeholder, Throwaway Indicator

**Key Takeaways**: Using `_` as a loop variable is a convention to indicate that the variable's value is not needed.

以下代码片段求前20项的斐波那契数：

```Python
a = 0
b = 1
for _ in range(20):
    (a, b) = (b, a + b)
    print(a, end=' ')
```

**Unpacking Extension​**​:

`_` is also used to ignore values during unpacking (e.g., `x, _, y = (1, 2, 3)`), reinforcing its role as a discard placeholder.

[Trying to understand Python loop using underscore and input](https://stackoverflow.com/questions/39188827/trying-to-understand-python-loop-using-underscore-and-input)

As a general purpose "throwaway" variable name to indicate that part of a function result is being deliberately ignored, as in code like:

```Python
label, has_label, _ = text.partition(':')
```

另外一个典型的例子是目录循环迭代生成器 os.walk（Directory tree generator），生成 (dirpath, dirnames, filenames) 三元组。

```Python
for dirpath, folders, files in os.walk(directory):
```

如果不关注子目录名，只关注每一层中的文件，可以以 `_` 标识忽略 folders：

```Python
for dirpath, _, files in os.walk(dir):
    print(f"{dirpath}: {files}")
    for file in files:
        print(f"\t{os.path.join(dirpath, file)}") # filepath
```

### comprehension

[**list comprehension**](https://docs.python.org/3/glossary.html?highlight=list%20comprehension) : A compact way to process all or part of the elements in a sequence and return a list with the results.

**列表解析式** 是遍历一个列表中的元素，过滤筛选出符合一定条件的元素，执行必要地转换后追加到另一个列表并返回这个新的列表的表达式。  

列表解析式形如 `expression comp_for [comp_if]`，或更清晰一点 `expr for iter_var in iterable [if cond_expr]`，其中的条件过滤器 if 语句是可选的。如果没有 if 过滤，则默认遍历所有元素执行转换。

> The if clause is optional. If omitted, all elements in comp_for are processed.

以下示例for循环遍历可枚举对象，遍历元素为value，表达式 value**2 计算平方，整个列表解析用于创建1到10的平方。

```Shell
>>> squares = [value**2 for value in range(1,11)]
>>> print(squares)
[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```

还可以针对 for 循环添加过滤条件，筛选出符合条件的元素，再执行复合计算。

```Shell
# 过滤出 list1 中大于4的元素，返回新列表 list2
>>> [e for e in range(1,8) if e>4]
[5, 6, 7]
```

更多参考 [builtins.list](../builtins/6-builtins.list.md) 中的相关说明和例程。

## if

reference - [8.1. The if statement](https://docs.python.org/3/reference/compound_stmts.html#the-if-statement)

if 表达式用来执行条件分支，可使用 if-elif-else 结构执行多条件分支。

```Python
if_stmt ::=  "if" assignment_expression ":" suite
             ("elif" assignment_expression ":" suite)*
             ["else" ":" suite]
```

### 三元表达式

以下代码片段，用于判断整数x的奇偶性，并将其保存到even变量。

```Python
even = 0
if x%2 == 0:
    even = 1
else:
    even = 0
```

在C语言中，对这种if-else非此即彼的条件赋值，可改用三目运算符来简化书写：

> even = x%2==0 ? 1 : 0;

Python没有像C语言中那样的三目运算符，但提供了基于if的三元表达式支持。

```
#如果条件为真，返回 exp1，否则返回 exp2
exp1 if contion else exp2
```

> even = 1 if x%2==0 else 0

可以使用嵌套的三元表达式，构造更加复杂的复合表达式。

在嵌套时需要注意 if 和 else 的配对，例如：

```Python
a if a>b else c if c>d else d
```

应该理解为：

```Python
a if a>b else ( c if c>d else d )
```

以下代码判断年份是否置闰：

```Python
year=2024
leap=True if (year%400==0 or (year%4==0 and year%100!=0)) else False
print('{} is leap: {}'.format(year, leap))
```

### switch(match)

Python 中未提供其他语言中的 switch 关键字，可使用多 elif 等效实现。

```Python
def switch(lang):
    if lang == "JavaScript":
        return "You can become a web developer."
    elif lang == "PHP":
        return "You can become a backend developer."
    elif lang == "Python":
        return "You can become a Data Scientist."
    elif lang == "Solidity":
        return "You can become a Blockchain developer."
    elif lang == "Java":
        return "You can become a mobile app developer."
```

在最新的 Python 3.10 中，可使用 match 和 case 关键字实现 Switch 效果。

```Python
lang = 'JavaScript'
match lang:
    case "JavaScript":
        print("You can become a web developer.")
    case "PHP":
        print("You can become a backend developer.")
    case "Python":
        print("You can become a Data Scientist.")
    case "Solidity":
        print("You can become a Blockchain developer.")
    case "Java":
        print("You can become a mobile app developer.")
    case _:
        print("unknown language")
```

## while

reference - [8.2. The while statement](https://docs.python.org/3/reference/compound_stmts.html#the-while-statement)

```Python
while_stmt ::=  "while" assignment_expression ":" suite
                ["else" ":" suite]
```

for 循环用于针对集合中的每个元素都执行一个代码块，而 while 循环不断地运行，直到指定的条件不满足为止。

在要求很多条件都满足才继续运行的程序中，可定义一个变量，用于判断整个程序是否处于活动状态。这个变量被称为`标志`，充当了程序的交通信号灯。  
你可让程序在标志为 `True` 时继续运行，并在任何事件导致标志的值为 `False` 时让程序停止运行。  
这样，在 while 语句中就只需检查一个条件——标志的当前值是否为True，并将所有测试(是否发生了应将标志设置为False的事件)都放在其他地方，从而让程序变得更为整洁。  

```Python
    prompt = "\nTell me something, and I will repeat it back to you:"
    prompt += "\nEnter 'quit' to end the program."

    active = True
    while active:
        message = input(prompt)

        if message == 'quit':
            active = False # break
        else:
            print(message)
```

### break

A `break` statement executed in the first suite terminates the loop without executing the else clause’s suite.  

要立即退出while循环，不再运行循环中余下的代码，也不管条件测试的结果如何，可使用 `break` 语句。  
break语句用于控制程序流程，可使用它来控制哪些代码行将执行，哪些代码行不执行，从而让程序按你的要求执行你要执行的代码。  

### continue

A `continue` statement executed in the first suite skips the rest of the suite and goes back to testing the expression.  

要返回到循环开头，并根据条件测试结果决定是否继续执行循环，可使用 `continue` 语句。  
它不像break语句那样不再执行余下的代码并退出整个循环，而是略过当前条件继续执行下一趟循环。  

### vs. for

以下C语言代码片段中，for循环最后一趟i=9满足条件，然后i++自增为10时不再满足条件，结束退出时i=10。

```C
    int i=0;
    for (; i<10; i++)
        printf("%d ", i);
    // 自然结束时，i=10
```

而在 Python 中，for-in 循环中没有先自增后比较的操作，而是遍历已知枚举中的元素，最后一个元素即是循环变量最终的值。

```Python
for i in range(0,10):
    print(i)
# 自然结束时，i=9
```

可改用while实现C语言类似效果，while支持条件判断，满足条件判断执行逻辑，并自增i继续下一轮循环。
因此，i最终的值是自增到不满足条件的边界值10。

```Python
i=0
while i<10:
    print(i)
    i += 1
# 自然结束时，i=10
```

简单地说，Python 中 for 循环常用于不带条件的枚举，因此结束时的循环变量仍然是合法值。
而 while 是带条件的循环，循环结束时变量为第一个不满足条件的边界值。
明确了然这个微小区别，对于某些特定场景至关重要。

## multiple assignment

在 python 语言中，支持 `expr3, expr4 = expr1, expr2` 形式的多重赋值。

以下为 tutorial - [4.6. Defining Functions](https://docs.python.org/3.6/tutorial/controlflow.html#defining-functions) 中计算斐波那契数列的示例代码： 

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

**注意**：多重赋值是逐个计算右值表达式，再依次赋给左侧变量。

前5轮循环推演如下：

```shell
## loop 1
result.append(0)
a, b = 1, 1
## loop 2
result.append(1)
a, b = 1, 2
## loop 3
result.append(1)
a, b = 2, 3
## loop 4
result.append(2)
a, b = 3, 5
## loop 5
result.append(3)
a, b = 5, 8
```

`expr3, expr4 = expr1, expr2`  并非简单等价于 `expr3 = expr1;expr4 = expr2`。  
假如把 fib2 中的 `a, b = b, a+b` 拆分成 `a = b; b = a+b`，会因逻辑错位关联而达不到预期结果。

```shell
## loop 1
result.append(0)
a = b = 1
b = a+b = 1+1 = 2

## loop 2
result.append(1)
a = b = 2
b = a+b = 2+2 = 4

## loop 3
result.append(2)
a = b = 4
b = a+b = 4+4 = 8

## loop 4
result.append(4)
a = b = 8
b = a+b = 8+8 = 16

## loop 5
result.append(8)
a = b = 16
b = a+b = 16+16 = 32
```

以下代码片段示例了分段截取应用场景：

```shell
# 等效于 first, *rest = list1
>>> first, rest = list1[0], list1[1:]
>>> first, rest
(1, [2, 3, 4, 5, 6, 7])
>>>
# 针对 list 的 iter, __next__
>>> it = iter(list1)
>>> first=it.__next__()
>>> rest=list(it)
>>> first, rest
(1, [2, 3, 4, 5, 6, 7])
>>>
# 针对 dict 的 iter, __next__
>>> it=iter(dict1)
>>> first=next(it)  # it.__next__()
>>> rest=list(it)
>>> first, rest
('k1', ['k2', 'k3', 'k4', 'k5', 'k6', 'k7'])
>>>
# 等效于 head, *body, tail = list1
>>> head, body, tail = list1[0], list1[1:-1], list1[-1]
>>> head, body, tail
(1, [2, 3, 4, 5, 6], 7)
>>>
>>> for first, *rest in [(1, 2, 3), (4, 5, 6, 7)]:
...     print(first, rest)
... 
1 [2, 3]
4 [5, 6, 7]
>>> # 收集尾部值
>>> a, b, *rest = [1, 2, 3, 4]
>>> rest
[3, 4]
>>> # 收集中部值
>>> name = "Albus Percival Wulfric Brian Dumbledore"
>>> first, *middle, last = name.split()
>>> middle
['Percival', 'Wulfric', 'Brian']
```

可参阅《Python基础教程》5.2 赋值魔法 章节相关内容。

## starred expression

[PEP 448 -- Additional Unpacking Generalizations](https://www.python.org/dev/peps/pep-0448/)  
[PEP 3132 -- Extended Iterable Unpacking](https://www.python.org/dev/peps/pep-3132/)  

reference - [starred_expression](https://docs.python.org/3/reference/expressions.html#grammar-token-starred_expression)  
reference - [starred_list](https://docs.python.org/3/reference/expressions.html#grammar-token-starred_list)  

[Python 3: starred expression to unpack a list](https://stackoverflow.com/questions/12555627/python-3-starred-expression-to-unpack-a-list)  
[Star * operator on left vs right side of an assignment statement](https://stackoverflow.com/questions/35636785/star-operator-on-left-vs-right-side-of-an-assignment-statement)  

An asterisk `*` denotes *iterable unpacking*. Its operand must be an [iterable](https://docs.python.org/3/glossary.html#term-iterable). The iterable is expanded into a **sequence** of items, which are included in the new tuple, list, or set, at the site of the unpacking.

```shell
>>> '{0}, {1}, {2}'.format(*str1)
'1, 2, 3'
>>> '{0}, {1}, {2}'.format(*range1)
'1, 2, 3'
>>> '{0}, {1}, {2}'.format(*tuple1)
'1, 2, 3'
>>> '{0}, {1}, {2}'.format(*list1)
'1, 2, 3'
>>> '{0}, {1}, {2}'.format(*set1)
'1, 2, 3'
```

对于字典（dict）一个星号解析

```shell
# position
>>> '{0}, {1}, {2}'.format(*dict1)
'k1, k2, k3'

# name
>>> '{k1}, {k2}, {k3}'.format(**dict1)
'1, 2, 3'
```

`*elements, = iterable`: elements is always going to be a list containing all the items in the iterable.  
`elements = *iterable,`: expands the contents of the iterable it is attached to.  

```shell
# *elements, = iterable 生成列表
# 等效于 parenth_form : list2 = [*set1]
>>> *list2, = set1
>>> list2
[1, 2, 3, 4, 5, 6, 7]

# elements = *iterable, 生成 tuple
>>> tuple2 = *set1,
>>> tuple2
(1, 2, 3, 4, 5, 6, 7)
```

### Destructuring

在 ES6 中，允许按照一定模式从数组和对象中提取值，然后对变量进行赋值，这被称为**解构**（Destructuring）。
在 Python 中，通过星号也支持类似的按照“模式匹配”读取匹配位置模式的值。

例如对于二元tuple，可按位置解构出二元值对。

```Shell
>>> tp = (1,6)
>>> t1,t2 = tp
>>> t1
1
>>> t2
6
```

for 循环枚举出的 tuple 也可用解构赋值接收值对。

```Shell
>>> for index,value in enumerate(l):
        print('e[{0}] = {1}'.format(index, value))

e[0] = 1
e[1] = 2
e[2] = 3
e[3] = 4
e[4] = 5
e[5] = 6
e[6] = 7
```

以下字典返回的 items，也可基于位置解构 tuple 二元值对。

```Shell
>>> for e in favorite_languages.items():
        print(e)

('jen', 'python')
('sarah', 'c')
('edward', 'ruby')
('phil', 'python')

>>> for k,v in favorite_languages.items():
        print('{}: {}'.format(k,v))

jen: python
sarah: c
edward: ruby
phil: python
```

对于多元tuple或多于两个元素的list，当我们只想析取指定位置部分时，可以使用星号实现。

对于列表l，`a,*b,c = l` 指定a、c接收首尾元素，中间部分用星号解构接收到变量b。

```Shell
>>> l=[*range(1,8)]
>>> a,*b,c = l
>>> a
1
>>> b
[2, 3, 4, 5, 6]
>>> c
7
```

## with

[PEP 343 -- The "with" Statement](https://www.python.org/dev/peps/pep-0343)  
reference - [8.5. The with statement](https://docs.python.org/3/reference/compound_stmts.html#the-with-statement)  
library - [29.6. contextlib — Utilities for with-statement contexts](https://docs.python.org/3/library/contextlib.html#)  

with 语句实际上是一个非常通用的结构，它通过 *上下文管理器* 执行一些设置和清理操作。

with 语句的目的是**简化 try/finally 模式**。这种模式用于保证一段代码运行完毕后执行某项操作，即便那段代码由于异常、return 语句或 sys.exit() 调用而中止，也会执行指定的操作。finally 子句中的代码通常用于释放重要的资源，或者还原临时变更的状态。

以下例子摘自《流畅的 python》的 第 8 章 对象引用、可变性和垃圾回收 - 8.9 延伸阅读 - 杂谈 - 对象析构和垃圾回收。

```python
open('test.txt', 'wt', encoding='utf-8').write('1, 2, 3')
```

这行代码是安全的，因为文件对象的引用数量会在 write 方法返回后归零，Python 在销毁内存中表示文件的对象之前，会立即关闭 文件。然而，这行代码在 Jython 或 IronPython 中却不安全，因为它们使用的是宿主运行时（Java VM 和 .NET CLR）中的垃圾回收程序，那些回收程序更复杂，但是不依靠引用计数，而且销毁对象和关闭文件的时间可能更长。

在任何情况下，包括 CPython，最好显式关闭文件；而关闭文件的最可靠方式是使用 with 语句，它能**保证文件一定会被关闭**，即使打开文件时抛出了异常也无妨。

使用 with，上述代码片段变成了：

```python
with open('test.txt', 'wt', encoding='utf-8') as fp:
    fp.write('1, 2, 3')
```

---

关于 with 背后的上下文管理机制，参考《流畅的 python》的第 15 章 上下文管理器和 else 块。

with 语句会设置一个临时的上下文，交给上下文管理器对象控制，并且负责清理上下文。这么做能避免错误并减少样板代码，因此 API 更安全，而且更易于使用。除了自动关闭文件之外，with 块还有很多用途。

上下文管理器是支持两个方法的对象：`__enter__` 和 `__exit__`。  
上下文管理器对象存在的目的是管理 with 语句，就像迭代器的存在是为了管理 for 语句一样。
