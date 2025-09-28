---
title: python中的生成器——generator
authors:
  - xman
date:
    created: 2019-12-06T10:00:00
    updated: 2024-04-17T09:00:00
categories:
    - python
tags:
    - generator
comments: true
---

本文梳理了 python 中的生成器类——generator，介绍了其基本概念和基础惯用法。

<!-- more -->

[Glossary — generator](https://docs.python.org/3/glossary.html#term-generator)
[Built-in Types — Generator Types](https://docs.python.org/3/library/stdtypes.html#generator-types)
[9.9. Generators](https://docs.python.org/3/tutorial/classes.html#generators)

可借鉴参考《ES6 标准入门》第 16 章《Generator 函数的语法》。

## 术语概念（term）

Glossary - **generator**：

A function which returns a [generator iterator](https://docs.python.org/3/glossary.html#term-generator-iterator). It looks like a normal function except that it contains [`yield`](https://docs.python.org/3/reference/simple_stmts.html#yield) expressions for producing a series of values usable in a for-loop or that can be retrieved one at a time with the [`next()`](https://docs.python.org/3/library/functions.html#next "next") function.

Usually refers to a generator function, but may refer to a *generator iterator* in some contexts. In cases where the intended meaning isn't clear, using the full terms avoids ambiguity.

**Generator Types**:

Python's [generator](https://docs.python.org/3/glossary.html#term-generator)s provide a convenient way to implement the iterator protocol. If a container object's [`__iter__()`](https://docs.python.org/3/library/stdtypes.html#iterator.__iter__ "iterator.__iter__") method is implemented as a generator, it will automatically return an iterator object (technically, a generator object) supplying the `__iter__()` and [`__next__()`](https://docs.python.org/3/reference/expressions.html#generator.__next__ "generator.__next__") methods. More information about generators can be found in the documentation for [the yield expression](https://docs.python.org/3/reference/expressions.html#yieldexpr).

**Generators**:

[Generators](https://docs.python.org/3/glossary.html#term-generator) are a simple and powerful tool for creating iterators. They are written like regular functions but use the [`yield`](https://docs.python.org/3/reference/simple_stmts.html#yield) statement whenever they want to **return** data. Each time [`next()`](https://docs.python.org/3/library/functions.html#next "next") is called on it, the generator **resumes** where it left off (it **remembers** all the data values and which statement was last executed).

## 术语理解（interpretation）

生成器由两个单独的部分组成：生成器的函数和生成器的迭代器，两位一体通称为**生成器**（generator）。

从外表看，生成器的函数和普通函数一样，只是其中包含一条或多条 yield 语句。
从语法上，可以把生成器函数理解成一个状态机，yield 语句定义了不同的内部状态。

其次，它还是一个迭代器对象生成函数，调用该函数并不立即执行函数体，而是返回生成器迭代器。
针对返回的迭代器对象，可以逐次调用 next 或执行 for 循环遍历其内部 yield 定义的状态。

每次调用 next 方法，从函数头部或上一次停下来的地方开始执行，直到遇到下一条 yield 语句为止。
换言之，生成器函数是分段执行的，yield 语句是暂停执行的标记，而 next 方法可以恢复执行。

---

`yield` 这个单词既有“生产”、“产出”的意思，又有“让路”、“让出”的意思，真是一语双关！

为了阐述 yield 语句的具体作用机制，首先明确一下“语句”和“表达式”的概念：

- yield 语句：yield (state)
- yield 表达式：y = yield (state)

下面以 yield 语句表达式 `y = yield (state)` 为例，初步解读一下其运作机制：

1. 调用 next，运行至 yield 语句，返回状态值（yield state），并暂停执行（yield CPU control）。
2. 再次调用 next，从上次的 yield 冻结点唤醒，yield 表达式返回 None，即 y=None。
3. 如果想改变 yield 表达式的返回值，可改调 g.send(v)，注入 y=v。

如果一个生成器函数包含多条 yield 语句，对其迭代器进行遍历即可获取多个状态值。

- 普通函数只能通过 return 语句返回一个值。

## 生成器演示（demonstration）

先来看一个最简单的生成器，只有一条空 yield，仅实现让出运行权的效果。

```Python
def generator1():
    print('before yield')
    yield
    print('after yield')

g1 = generator1()
# NOP
print(next(g1))
# before yield, yield nothing
print(next(g1))
# after yield, no yield else
```

1. g1 = generator1()：返回生成器迭代器，尚未触发执行
2. next(g1): 触发执行生成器函数，打印 'before yield' 后，运行至 yield，无返回值，冻结暂停
3. next(g1): yield 唤醒，继续运行打印 'after yield' 后结束，没有下一条 yield，抛出 StopIteration 异常

稍作改进，yield 后面加一个值，看看运行效果。

```Shell
def generator2():
    print('before yield')
    yield 2024
    print('after yield')

g2 = generator2()
print(next(g2))
print(next(g2))
```

1. g2 = generator2()：返回生成器迭代器，尚未触发执行
2. next(g2): 触发执行生成器函数，打印 'before yield' 后，运行至 yield，返回 2024 打印，冻结暂停
3. next(g2): yield 唤醒，继续运行打印 'after yield' 后结束，没有下一条 yield，抛出 StopIteration 异常

继续改进，给生成器函数增加一条 return 语句，执行结果同上。

- 这里和 ES6 不一样，return 语句不同于 yield 语句，不接受 next 访问语义。

```Python
def generator3():
    print('before yield')
    yield 2024
    print('after yield')
    return 2025

g3 = generator3()
print(next(g3))
print(next(g3))
```

继续改进，再增加两条 yield 语句：

```Python
def generator4():
    print('yield 1')
    yield 2024
    print('yield 2')
    yield 2025
    print('yield 3')
    yield 2026

g4 = generator4()
print(next(g4))
print(next(g4))
print(next(g4))
print(next(g4))
```

1. next(g4): 输出两行：yield 1; 2024
2. next(g4): 输出两行：yield 2; 2025
3. next(g4): 输出两行：yield 3; 2026
4. next(g4): 抛出 StopIteration 异常

由于生成器函数返回生成器迭代器，故可以直接对其执行 for 循环：

```Python
for i in g4:
    print(i)
```

正常情况下，有 n 条 yield 语句，就可以调用 n 次 next 迭代取值，再调一次抛出 StopIteration 异常。

## 通用生成器--递归

考虑有一个二层嵌套列表：nested = [[1, 2], [3, 4], [5]]，其每个元素还是列表。换而言之，这是一个列表的列表。

如果要将其展开，下面是一种解决方案：

```Python
def flatten(nested):
    for sublist in nested:
        for element in sublist:
            yield element
```

外层 for 循环迭代提供嵌套列表中的所有子列表，内存 for 循环按顺序迭代每个子列表的元素。
之前的实现最后一行为 print(element)，这里改为了 yield element 将其变成了生成器。

传入要展开的嵌套列表，然后对 flatten 返回的生成器迭代器，使用 for 循环迭代即可。

```Python
nested = [[1, 2], [3, 4], [5]]
for e in flatten(nested):
    print(e)
```

但是，上面设计的生成器只能处理两层的嵌套列表，这是使用两个for循环来实现的。如果要处理任意层嵌套的列表，该如何办呢？
对于每层嵌套，都需要一个for循环，但由于不知道有多少层嵌套，你必须修改解决方案，使其更灵活。该求助于递归了。

```Python
def flatten(nested):
    try:
        for sublist in nested:
            for element in flatten(sublist):
                yield element
    except TypeError:
        yield nested

nested = [[[1], 2], 3, 4, [5, [6, 7]], 8]
for e in flatten(nested):
    print(e)
```

调用flatten时，有两种可能性（处理递归时都如此）：基线条件和递归条件。在基线条件下， 要求这个函数展开单个元素（如一个数）。在这种情况下，for循环将引发TypeError异常（因为你试图迭代一个数），而这个生成器只生成一个元素。

然而，如果要展开的是一个列表（或其他任何可迭代对象），你就需要做些工作：遍历所有的子列表（其中有些可能并不是列表）并对它们调用flatten，然后使用另一个for循环生成展开后的子列表中的所有元素。

但是，这个解决方案存在一个问题：如果nested是字符串或类似于字符串的对象，它就属于序列，因此不会引发TypeError异常，可你并不想对其进行迭代。

> 在函数 flatten 中，不应该对类似于字符串的对象进行迭代，主要原因有两个。首先，你想将类似于字符串的对象视为原子值，而不是应该展开的序列。其次，对这样的对象进行迭代会导致无穷递归，因为字符串的第一个元素是一个长度为1的字符串，而长度为1的字符串的第一个元素是字符串本身！

要处理这种问题，必须在生成器开头进行检查。要检查对象是否类似于字符串，最简单、最 快捷的方式是，尝试将对象与一个字符串拼接起来，并检查这是否会引发TypeError异常。添加 这种检查后的生成器如下：

```Python
def flatten(nested):
    try:
        try: nested + ''
        except TypeError: pass # 非字符串拼接异常，继续迭代
        else: raise TypeError  # 类字符串对象，不迭代

        for sublist in nested:
            for element in flatten(sublist):
                yield element
    except TypeError:
        yield nested

nested = ['foo', ['bar', ['baz']]]
for e in flatten(nested):
    print(e)
```

### yield from subgenerator

flatten 本身是个函数生成器，内部递归调用相当于 subgenerator，可以改用 `yield from` 语句，更加简洁。
如果不加 isinstance 判断排除 str，会报错 RecursionError: maximum recursion depth exceeded。

```Python
def flatten(sequence):
    """flatten a multi level list or something
    >>> list(flatten([1, [2], 3]))
    [1, 2, 3]
    >>> list(flatten([1, [2], [3, [4]]]))
    [1, 2, 3, 4]
    """
    for element in sequence:
        if hasattr(element, '__iter__') and not isinstance(element, str):
            yield from flatten(element)
        else:
            yield element

print(list(flatten([1, [2], [3, [4]]])))
print(list(flatten([[[1], 2], 3, 4, [5, [6, 7]], 8])))
print(list(flatten(['foo', ['bar', ['baz']]])))
```

**参考**：

- [Python yield from 用法详解 - 简书](https://www.jianshu.com/p/87da832730f5)
- [In practice, what are the main uses for the "yield from" syntax in Python 3.3? - Stack Overflow](https://stackoverflow.com/questions/9708902/in-practice-what-are-the-main-uses-for-the-yield-from-syntax-in-python-3-3)

## 通用生成器--带循环

以下 repeater 是个无限循环，初始传入 value=3，每次调用 next 返回 value=3。

```Python
def repeater(value):
    while True:
        yield value

r=repeater(3)
print(next(r))
print(next(r))
print(next(r))
```

1. r=repeater(3)：value=3，返回生成器迭代器，尚未触发执行
2. next(r): 触发执行生成器函数，运行至 yield，返回 3 后冻结
3. next(r): yield 返回 None，继续循环至 yield，返回 3 后冻结
4. next(r): 同上

可参考 [itertools — Functions creating iterators for efficient looping](https://docs.python.org/3.12/library/itertools.html#itertools.takewhile) 中 takewhile、filterfalse 和 dropwhile 的等效生成器实现。

```Python
# 过滤出符合谓词逻辑 predicate 的元素，一旦遇到第一个不符合条件的即终止。
def takewhile(predicate, iterable):
    # takewhile(lambda x: x<5, [1,4,6,4,1]) --> 1 4
    for x in iterable:
        if predicate(x):
            yield x
        else:
            break

# 过滤出所有不符合谓词逻辑 predicate 的元素。
def filterfalse(predicate, iterable):
    # filterfalse(lambda x: x%2, range(10)) --> 0 2 4 6 8
    if predicate is None:
        predicate = bool
    for x in iterable:
        if not predicate(x):
            yield x

# 过滤掉符合谓词逻辑 predicate 的元素，一旦遇到第一个不符合条件的予以保留（至末尾）。
def dropwhile(predicate, iterable):
    # dropwhile(lambda x: x<5, [1,4,6,4,1]) --> 6 4 1
    iterable = iter(iterable)
    for x in iterable:
        if not predicate(x):
            yield x
            break
    for x in iterable:
        yield x
```

## 通用生成器--外部通信

在生成器开始运行后，可使用生成器和外部之间的通信渠道向它提供值。这个通信渠道包含如下两个端点：

- 外部世界：外部世界可访问生成器的方法 send，这个方法类似于 next，但接受一个参数（要发送的“消息”，可以是任何对象）。
- 生成器：在挂起的生成器内部，yield 可能用作表达式而不是语句。换而言之，当生成器重新运行时，yield 返回一个值——通过 send 从外部世界发送的值。

请注意，仅当生成器被挂起（即遇到第一个 yield）后，使用 send（而不是 next）才有意义。 要在此之前向生成器提供信息，可使用生成器的函数的参数。

> 注意：如果一定要在生成器刚启动时对其调用方法 send，可向它传递参数 None。

上面的 repeater 就是个简单的复读机，无限循环输出初始给定的值。
对其稍加修改，在中途调用 send 向其内部注入新值，更新内部状态（即复读的内容）。

```Python
def repeater(value):
    while True:
        print('before yield')
        yret = yield value
        print('after yield', yret)
        if yret:
            value = yret # update with send param

r=repeater(3)
print(next(r))
print(next(r))
print(r.send('24'))
print(next(r))
print(next(r))
```

1. r=repeater(3)：返回生成器迭代器，尚未触发执行
2. next(r): 触发执行生成器函数，运行至 yield，返回 value=3 后冻结
3. next(r): yield 返回 None，继续循环至 yield，返回 value=3 后冻结
4. r.send('24'): yield 返回 24 并更新 value=24，继续循环至 yield，返回 value=24 后冻结
5. next(r): yield 返回 None，继续循环至 yield，返回 value=24 后冻结
6. next(r): 同上

下面综合演示 yield 语句和表达式混合使用：

```Python
def generator5(x):
    y = 2 * (yield (x+1))
    z = yield (y//3)
    yield (x+y+z)

g5 = generator5(5)
print(next(g5))
print(next(g5))
```

1. g5=generator5(5)：x=5，返回生成器迭代器，尚未触发执行
2. next(g5): 触发执行生成器函数，运行至 yield，返回 x+1=6 后冻结
3. next(g5): yield 表达式返回 None，与整数 2 相乘，报异常 TypeError：

    - TypeError: unsupported operand type(s) for *: 'int' and 'NoneType'

修改测试代码，第一次调用 next(g5) 后，可以调用 send 向内注入 yield 表达式值：

```Python
g5 = generator5(5)
print(next(g5))
print(g5.send(12))
print(next(g5))
```

1. g5=generator5(5)：x=5，返回生成器迭代器，尚未触发执行
2. next(g5): 触发执行生成器函数，运行至 yield，返回 x+1=6 后冻结
3. g5.send(12)：第1个 yield 表达式返回 12，y=2*12=24，返回 y//3=8
4. next(g5): 第2个 yield 表达式返回 None，z=None，第三个 yield 语句报异常 TypeError:

- TypeError: unsupported operand type(s) for +: 'int' and 'NoneType'

再次修改测试部分，把 send 后的 next 改为再次 send 传值：

```Python
g5 = generator5(5)
print(next(g5))
print(g5.send(12))
print(g5.send(13))
```

1. g5=generator5(5)：x=5，返回生成器迭代器，尚未触发执行
2. next(g5): 触发执行生成器函数，运行至 yield，返回 x+1=6 后冻结
3. g5.send(12)：第1个 yield 表达式返回 12，y=2*12=24，返回 y//3=8
4. g5.send(13)：第2个 yield 表达式返回 13，z=13，yield 语句 x+y+z=5+24+13=42，返回 42

### throw & close

生成器还包含另外两个方法。

- `throw`：用于在生成器中（yield表达式处）引发异常，并返回下一个状态。调用时可提供一个异常类型、一个可选值和一个traceback对象。
- `close`：用于停止生成器，调用时无需提供任何参数。

方法 close（由Python垃圾收集器在需要时调用）也是基于异常的：在 yield 处引发 `GeneratorExit` 异常。
因此如果要在生成器中提供一些清理代码，可将yield放在一条 try/finally 语句中。

```Python
def echo(value=None):
    print("Execution starts when 'next()' is called for the first time.")
    try:
        while True:
            try:
                value = (yield value)
            except Exception as e:
                value = e
    finally:
        print("Don't forget to clean up when 'close()' is called.")
```

调用生成器函数，初始化生成生成器迭代器，并首次调用 next：

```Shell
>>> generator = echo(1)
>>> print(next(generator))
Execution starts when 'next()' is called for the first time.
1
```

再次调用 next，激活上次 yield 表达式返回 None 赋值给 value，再次运行至 yield 返回 value=None。

```Shell
>>> print(next(generator))
None
```

对生成器调用 send 注入新状态（value=2），重新 yield 返回 value=2：

```Shell
>>> print(generator.send(2))
2
```

为上次 yield 冻结点注入异常，捕获更新状态 value=TypeError('spam')，并运行至下一条 yield 返回 value：

```Shell
>>> generator.throw(TypeError("spam"))
TypeError('spam')
```

为上次 yield 冻结点注入 GeneratorExit 异常，执行 finally 代码块：

```Shell
>>> generator.close()
Don't forget to clean up when 'close()' is called.
```

调用 close 关闭状态机后，再次调用 next 将报 StopIteration 异常。

```Shell
>>> next(generator)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```

## 圆括号构造生成器表达式

在 Python 2.4 中，引入了一个类似于列表推导（List Comprehension）的概念：生成器推导，也叫生成器表达式（Generator Expressions）。
其工作原理与列表推导相同，但不是创建一个列表（即不立即执行循环），而是返回一个生成器，让你能够逐步执行计算。

```Shell
>>> g = ((i + 2) ** 2 for i in range(2, 27))
>>> next(g)
16
>>> golf = 'golf'
>>> list(golf[i] for i in range(len(golf)-1, -1, -1))
['f', 'l', 'o', 'g']
```

如你所见，不同于列表推导，这里使用的是圆括号。在像这样的简单情形下，还不如使用列表推导；但如果要包装可迭代对象（可能生成大量的值），使用列表推导将立即实例化一个列表，从而丧失迭代的优势。

> Generator expressions are more compact but less versatile than full generator definitions and tend to be more memory friendly than equivalent list comprehensions.

另一个好处是，直接在一对既有的圆括号内（如在函数调用中）使用生成器推导时，无需再添加一对圆括号。换而言之，可编写下面这样非常漂亮的代码：

> sum(i ** 2 for i in range(10))

以下使用 sum 结合生成器表达式，便捷地实现向量的点积（dot product）：

```Python
>>> xvec = [10, 20, 30]
>>> yvec = [7, 5, 3]
>>> sum(x*y for x,y in zip(xvec, yvec))
260
```

string.py 中 string.capwords 函数的早期实现即基于生成器迭代器（现已改为 map 实现）：

```Python
# Capitalize the words in a string, e.g. " aBc  dEf " -> "Abc Def".
def capwords(s, sep=None):
    return (sep or ' ').join(x.capitalize() for x in s.split(sep))
```

以下构建生成器，过滤生成 1-10 内的偶数，even 承接返回迭代器：

```Shell
>>> even=(n for n in range(1,11) if n%2==0)
>>> type(even)
<class 'generator'>
```

[syntax - Python equivalent of c++ find_if - Stack Overflow](https://stackoverflow.com/questions/51410881/python-equivalent-of-c-find-if)

找出序列中第一个被 5 整除的数：

```Shell
>>> lst=[1,2,10,3,5,3,4]
>>> next(n for n in lst if n%5==0)
10
```

A slight modification will give you the index rather than the value:

```Shell
>>> next(idx for idx,n in enumerate(lst) if n%5==0)
2
```

## 生成器与状态机应用实例

Generator 是实现状态机的最佳结构。比如，下面的 clock 函数就是一个状态机。

```Python
ticking = True
def clock():
    global ticking
    if ticking:
        print('Tick!')
    else:
        print('Tock!')
    ticking = not ticking

clock()
clock()
clock()
clock()
```

上面的 clock 函数一共有两种状态（Tick 和 Tock），每运行一次就改变一次状态，模拟钟摆的嘀嗒。

- 当把这两种状态用二进制 0,1 表示时，相当于布尔开关状态机。

这个函数如果用 Generator 实现，代码如下：

```Python
def clock():
    while True:
        print('Tick!')
        yield
        print('Tock!')
        yield

c = clock()
next(c)
next(c)
next(c)
next(c)
```

对比上面的 Generator 实现与普通函数实现，可以看到少了用来保存状态的外部变量 ticking，这样就更简洁，更安全（状态不会被非法篡改），更符合函数式编程的思想，在写法上也更优雅。

Generator 之所以可以不用外部变量保存状态，是因为它本身就包含了一个状态信息，即目前是否处于暂停态。

类似，以下是引入三种状态的“剪刀石头布”游戏（Rock-Paper-Scissors，Stone-Scissors-Cloth），循环出石头、布、剪刀。

```Python
def draw_rps():
    while True:
        print('Rock')
        yield
        print('Paper')
        yield
        print('Scissors')
        yield

dr = draw_rps()
next(dr)
next(dr)
next(dr)
next(dr)
next(dr)
next(dr)
```

### 周期序列生成器

在 repeater 的基础上，我们稍作修改，让其产生增长序列，其中 i 为初始值，step 为步长。

```Python
def generator6(i=0， step=1):
    while True:
        reset = yield i
        if reset is not None: # isinstance(reset, int)
            i = reset
        i += step
```

初始化状态机后，当外部不干涉状态机时，其生成无限等步长增长序列。

例如 odds 生成奇数序列 1,3,5,7,9,...；把起始值改为 2，则生成偶数序列。

```Python
def odds():
    g6 = generator6(i=1, step=2)
    print(next(g6))
    print(next(g6))
    print(next(g6))
    print(next(g6))
    print(next(g6))

odds()
```

count 引入了外部干扰，遇到 10 即复位为 0，从而生成十进制数序列（0-9）：

```Python
def count():
    g6 = generator6()
    print(next(g6))
    print(next(g6))
    print(next(g6))
    print(next(g6))
    print(next(g6))
    print(next(g6))
    print(next(g6))
    print(next(g6))
    print(next(g6))
    print(next(g6)) # 9
    print(g6.send(-1)) # 逢十进一复位为 0

count()
```

binary 引入了外部干扰，每生成两个数 0,1 即复位，从而生成二进制数序列：

- 类似上面的 Tick-Tock 和日常生活中的布尔开关状态。

```Python
def binary():
    g6 = generator6()
    print(next(g6))
    print(next(g6))
    print(g6.send(-1))
    print(next(g6))
    print(g6.send(-1))
    print(next(g6))

binary()
```

1. g6=generator6()：返回生成器迭代器，尚未触发执行
2. next(g6): 触发执行生成器函数，运行至 yield，返回 0 后冻结
3. next(g6): yield 返回 None，i 自增为1，继续循环至 yield，返回 1 后冻结
4. g6.send(-1): yield 返回 -1，i 复位为 -1 并自增为 0，继续循环至 yield，返回 0 后冻结
5. next(g6): yield 返回 None，i 自增为1，继续循环至 yield，返回 1 后冻结
6. 重复 4-5，不断生成二进制序列。

初始化和注入点稍作修改，即可改为生成军训口令“一二一”序列。

- 这个非典型示例中 send 修改都超过了 next 读取内部状态，一般状态机也不这么设计。

```Python
def command():
    g6 = generator6(1)
    print(next(g6))
    print(next(g6))
    print(g6.send(0))

    print(g6.send(0))
    print(next(g6))
    print(g6.send(0))

    print(g6.send(0))
    print(next(g6))
    print(g6.send(0))

command()
```

count 示例十进制组成数，实际上是个周期循环。
日常生活中，最典型的“周期”是 week，七天循环一周。
weekdays 则演示了一周从周一到周日，过完一周后复位为周一，周而复始。

```Python
def weekdays():
    g5 = generator6(1)
    print(next(g5)) # Monday
    print(next(g5)) # Tuesday
    print(next(g5)) # Wednesday
    print(next(g5)) # Thursday
    print(next(g5)) # Friday
    print(next(g5)) # Saturday
    print(next(g5)) # Sunday
    print(g5.send(0)) # reset to Monday
    print(next(g5))
    print(next(g5))
    print(next(g5))
    print(next(g5))
    print(next(g5))
    print(next(g5))
    print(g5.send(0)) # reset to Monday

weekdays()
```

### 斐波那契数列

假如只想找出第一个大于1000的斐波那契数，而不关注前向序列，如果用列表实现，非常耗费内存。
在迭代器专题中，我们演示了基于迭代器实现了斐波那契数列。

```Python
class Fibs:
    def __init__(self):
        self.a = 0
        self.b = 1

    def __next__(self):
        self.a, self.b = self.b, self.a + self.b
        return self.a

    def __iter__ (self):
        return self

fibs = Fibs()
for fib in fibs:
    if fib > 1000:
        print(fib)
        break
```

这一节，我们基于生成器（迭代器）来更简洁地等效实现。

```Python
def fibonacci():
    a,b = 0,1
    while True:
        a,b = b,a+b
        yield b

for fib in fibonacci():
    if fib > 1000:
        print(fib)
        break
```

### 目录遍历生成器

`os.scandir` 和 `pathlib.Path.iterdir` 均只支持当前目录的扫描（`tree -L 1` 级别）：

```Python
# os.scandir
(function) def scandir(path: GenericPath[AnyStr@scandir]) -> _ScandirIterator[AnyStr@scandir]

# pathlib.Path.iterdir
(method) def iterdir() -> Generator[Path, None, None]
```

`os.walk`: Directory tree generator.

```Python
(function) def walk(
    top: GenericPath[AnyStr@walk],
    topdown: bool = True,
    onerror: _OnError | None = None,
    followlinks: bool = False
) -> Iterator[tuple[AnyStr@walk, list[AnyStr@walk], list[AnyStr@walk]]]
```

`glob.iglob`: Return an iterator which yields the paths matching a pathname pattern.

```Python
(function) def iglob(
    pathname: AnyStr@iglob,
    *,
    root_dir: StrOrBytesPath | None = None,
    dir_fd: int | None = None,
    recursive: bool = False,
    include_hidden: bool = False
) -> Iterator[AnyStr@iglob]
```

`pathlib.Path.glob`: Iterate over this subtree and yield all existing files (of any kind, including directories) matching the given relative pattern.

```Python
(method) def glob(
    pattern: str,
    *,
    case_sensitive: bool | None = None
) -> Generator[Path, None, None]
```
