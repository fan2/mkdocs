---
title: python functions
authors:
  - xman
date:
    created: 2019-12-02T08:10:00
categories:
    - python
comments: true
---

python 中的函数类型介绍。

<!-- more -->

[4.7. Defining Functions](https://docs.python.org/3/tutorial/controlflow.html#defining-functions)
[4.8. More on Defining Functions](https://docs.python.org/3/tutorial/controlflow.html#more-on-defining-functions)

[4.8.6. Lambda Expressions](https://docs.python.org/3/tutorial/controlflow.html#lambda-expressions)
[细说Python的lambda函数用法](https://zhuanlan.zhihu.com/p/80960485)

## 如何定义函数

函数是结构化编程的核心。
函数是若干代码语句的组合，执行语句序列操作，并返回一个值。也可是无返回值（返回None）的纯过程处理。
函数往往是将一些特定任务的功能操作打包封装起来，方便后续复用，减少重复工作量。
函数可由系统或第三方工具包提供，对调用者而言，可视作黑盒，不关注内部具体实现，仅关注功能和接口（输入参数，输出返回值）。

那么，在 Python 中，如何定义函数呢？使用 `def` 语句定义函数。

如下定义了函数 function 框架，但是还没实现，先用 pass 占位符或return（什么也不返回），使其有内容编译通过。
后面再慢慢补充函数的具体实现。

```Python
def function(args):
    pass # a function that does nothing (yet)
```

可以添加多个参数，并且给参数指定数据类型：

```Python
def function(args: list):
    pass

# only procedure, no return value
def enroll(name: str, gender: int, age: int):
    return
```

可以指定返回值数据类型，例如输入姓名、性别和年龄，输出登记入伍是否成功。
由于征兵条件苛刻，这里默认先返回 False，待pass部分实现了判断流程，符合条件的才准许参军。

```Python
def enroll(name: str, gender: int, age: int) -> bool:
    pass # to be done
    return False
```

### 定义函数字符串

把在 def 语句后面（以及模块和类的开头），放在函数开头的字符串称为文档字符串（docstring），它将作为函数的一部分存储起来。

```Python
def enroll(name: str, gender: int, age: int) -> bool:
    'Determine whether a person is eligible for enlistment by profile.'
    pass # to be done
    return False
```

函数的docstring保存在 `__doc__` 属性中，可执行 `enroll.__doc__` 查看函数的 docstring。

尽管函数还没实现，但是可以通过执行 `help(enroll)` 查看帮助，知晓其预设初心。

### 函数两种传参模式

```Python
def enroll(name: str, gender: int, age: int) -> bool:
    if gender == 0 and age >= 18 and age <= 28:
        return True
    return False
```

调用函数时，一般按照参数位置传递参数（positional argument），位置至关重要，必须与定义的参数顺序对应。

```Python
b=enroll('Cliff', 0, 18)
print(b)
```

有时候，参数的排列顺序可能难以记住，尤其是参数很多时。为了简化调用工作，可指定参数的名称。

```Python
b=enroll(name='Harry', gender=0, age=48)
print(b)
```

实际上，指定了参数的名称时，参数的顺序无关紧要。

```Python
b=enroll(gender=0, age=25, name='Jeff')
print(b)
```

像这样使用名称指定的参数称为关键字参数（keyword argument），主要优点是有助于澄清各个参数的作用。

也可混合使用位置参数和关键字参数，前面几个按位置给定不具名参数，后面的参数可使用关键字参数（顺序可乱）。

```Python
b=enroll('James', gender=1, age=19)
print(b)
b=enroll('John', age=24, gender=0)
print(b)
```

### 指定参数默认值

关键字参数最大的优点在于，可以指定默认值。像这样给参数指定默认值后，调用函数时可不提供它！

```Python
def enroll(name: str = '', gender: int = 0, age: int = 0) -> bool:
```

如果只想指定部分参数的默认值，则这些参数要放在最后面。这样可以兼顾位置按需传参。

```Python
def enroll(gender: int, age: int, name : str = '') -> bool:
def enroll(gender: int, age: int = 0, name : str = '') -> bool:
```

### 函数形参作用域

字符串（以及数和元组）是不可变的（immutable），这意味着你不能修改它们（即只能替换为新值）。
函数参数存储在局部作用域内，在函数内部给形参赋值对外部的实参没有任何影响。
以下示例中，形参重新关联，另有所指，不影响外部传入的实参。

```Python
def try_to_change_str(s):
    s = 'Mr. Gumby'

name = 'Mrs. Entity'
try_to_change_str(name)
print(name)

def try_to_change_tuple(t):
    t = tuple(range(6))

t = tuple(range(5))
try_to_change_tuple(t)
print(t)
```

要想获取 try_to_change 系列函数处理后的结果，可考虑 return 返回，外面接收返回值。

对于 immutable 的字符串，实际是赋值（副本）传参，在其内部执行操作，不影响外部的实参原件。

```Python
def try_to_change_str(s):
    s.replace('Mrs', 'Mr')

name = 'Mrs. Entity'
try_to_change_str(name)
print(name)
```

但列表 list 是 mutable sequence，当传递列表作为参数时，形参和实参将指向同一个原始列表。
相当于C语言中的引用或指针传参，函数内部对该变量的操作将直接影响原始变量。

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

## 传递任意数量的实参

《Python编程从入门到实践》中的 第8章 函数 - 8.5 传递任意数量的实参，有点类似C语言中的可变参数（stdarg.h 中的 va_list）。

### 传递任意数量的不记名实参

下面的函数只有一个形参 `*toppings`，不管调用语句提供多少实参，这个形参都将它们统统打包到其中：

```Python
def make_pizza(*toppings):
    """打印顾客点的所有配料""" 
    print(toppings)
```

形参名 `*toppings` 中的星号让 Python 创建一个名为 toppings 的空元组（tuple()），并将收到的所有值都封装到这个元组中。

具体参考 Python 星号表达式（starred expression）: 

> An asterisk `*` denotes *iterable unpacking*. Its operand must be an [iterable](https://docs.python.org/3/glossary.html#term-iterable).
> The iterable is expanded into a sequence of items, which are included in the new **tuple**, list, or set, at the site of the unpacking.

```Python
def make_pizza(*toppings):
    """打印顾客点的所有配料"""
    # print(type(toppings), len(toppings))
    print(toppings)

make_pizza('pepperoni')
make_pizza('mushrooms', 'green peppers', 'extra cheese')
```

例如，传入任意个整数进行求和：

> 有点类似 builtins.sum，支持对不定长数值序列进行迭代求和。

```Python
def add(*numbers):
    r = 0
    for e in numbers:
        r += e
    return r

add(1,3,5,7,9)
```

还可以结合使用位置实参和任意数量实参。

如果要让函数接受不同类型的实参，必须在函数定义中将接纳任意数量实参的形参放在最后。
Python先匹配位置实参和关键字实参，再将余下的实参都收集到最后一个形参中。
make_pizza 添加一个参数，先传入尺寸，再传入配料表。

```Python
def make_pizza(size, *toppings):
    """概述要制作的比萨"""
    print("\nMaking a " + str(size) + "-inch pizza with the following toppings:")
    for topping in toppings:
        print("- " + topping)

make_pizza(16, 'pepperoni')
make_pizza(12, 'mushrooms', 'green peppers', 'extra cheese')
```

### 使用任意数量的关键字实参

有时候，需要接受任意数量的实参，但预先不知道传递给函数的会是什么样的信息（包括参数名和参数值）。
在这种情况下，可将函数编写成能够接受任意数量的参数（参数名和参数值）——调用语句提供了多少就接受多少。

```Python
def build_profile(first, last, **user_info):
    """创建一个字典，其中包含我们知道的有关用户的一切"""
    # print(type(user_info), len(user_info))
    profile = {}
    profile['first_name'] = first
    profile['last_name'] = last
    for key, value in user_info.items():
        profile[key] = value
    return profile

user_profile = build_profile('albert',
                              'einstein',
                              location='princeton',
                              field='physics')
print(user_profile)
```

函数 build_profile 的前两个参数要求提供名和姓，同时允许用户根据需要提供其他额外补充信息（user_info）。
形参 `**user_info` 中的两个星号让 Python 创建一个空字典（dict()），并将收到的所有参数对都封装到这个字典中。
在这个函数中，可以像访问其他字典那样访问 user_info 中的参数对。

具体参考 help(dict) 中的双星构造法：

```Shell
dict(**kwargs) -> new dictionary initialized with the name=value pairs
```

### 综合使用星号和双星号收集变参

以下综合示例，前三个是位置参数，pospar收集中间的不定量变参，keypar收集具名关键字参数。

```Python
def print_params_4(x, y, z=3, *pospar, **keypar):
    print(x, y, z) # first three
    print(pospar)  # middle tuple
    print(keypar)  # last dict

print_params_4(1, 2, 3, 5, 6, 7, foo=1, bar=2)
```

### 综合使用星号和双星号分配参数

前面介绍了如何将参数收集到元组和字典中，但用同样的两个运算符（\*和\*\*）也可执行相反的操作。

假设有如下函数：

```Python
def add(x, y):
    return x + y
```

假设还有一个元组（或列表、集合），其中包含两个你要相加的数。

- pt = (1, 2)
- pl = [3, 4]
- ps = {5, 6}

在调用函数（而不是定义函数）时，可使用运算符 \* 可对序列进行解引用（枚举遍历），按位置序号进行迭代分配。
这与前面执行的操作差不多是相反的：不是收集参数，而是分配参数。

```Python
pt = (1, 2)
add(*pt)

pl = [3, 4]
add(*pl)

ps = {5, 6}
add(*ps)
```

**注意**：序列中元素的个数必须和函数能接受的参数个数匹配，否则报错！
