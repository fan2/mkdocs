---
title: python中生成随机数——random
authors:
  - xman
date:
    created: 2019-12-06T08:50:00
categories:
    - python
tags:
    - random
comments: true
---

本文简单梳理了 python 中生成随机数的 random 类的惯用法。

<!-- more -->

[random — Generate pseudo-random numbers](https://docs.python.org/3/library/random.html) @[zh-cn](https://docs.python.org/zh-cn/3/library/random.html)

- [python 随机数 random 库的使用总结](https://blog.csdn.net/Flag_ing/article/details/124043788)
- [Python随机函数random使用详解](https://zhuanlan.zhihu.com/p/98298060)
- [Python random 随机函数示例](https://juejin.cn/post/7165800040689221645)

模块random包含生成伪随机数的函数，有助于编写模拟程序或生成随机输出的程序。请注意，虽然这些函数生成的数字好像是完全随机的，但它们背后的系统是可预测的。
如果你要求真正的随机（如用于加密或实现与安全相关的功能），应考虑使用模块os中的函数 `urandom`。模块random 中的 `SystemRandom` 类基于的功能与urandom类似，可提供接近于真正随机的数据。

参考 Alternative Generator 中的 `class random.SystemRandom([seed])` 说明。

## random.seed

Initialize the random number generator.

```Python
random.seed(a=None, version=2)
```

If `a` is omitted or None, the current system time is used.

> Since version 3.11: The seed must be one of the following types: `NoneType`, int, float, str, bytes, or bytearray.

If randomness sources are provided by the operating system, they are used instead of the system time (see the [os.urandom()](https://docs.python.org/3/library/os.html#os.urandom) function for details on availability).

```Shell
>>> import os
>>> help(os.urandom)
urandom(size, /)
    Return a bytes object containing random bytes suitable for cryptographic use.
```

如果不调用 `seed` 或调用 `seed(None)`，默认在运行时使用系统时间作为随机数种子，因此每次运行程序得到的结果都是不一样的。

### reproducibility

Notes on Reproducibility

Sometimes it is useful to be able to **reproduce** the sequences given by a pseudo-random number generator.  
By re-using a seed value, the same sequence should be reproducible from run to run as long as multiple threads are not running.  

When the random seed is set to be a constant, the random number is *fixed* every time.  

- If `a` is an int, it is used directly.  

如果在程序运行时指定随机数种子，那么随机函数每次重新运行后产生的结果是一样的。

这对于一些需要保证测试数据的一致性，以便多次重复测试的场景，非常有用。

## random.random

random.random 函数用于生成一个落入区间 [0, 1) 的随机符点数。

```Shell
random() method of random.Random instance
    random() -> x in the interval [0, 1).
```

两次调用 random，生成不同的浮点纯小数：

```Shell
>>> random.random()
0.5297818805989034
>>> random.random()
0.49944915534347745
```

指定 seed，生成相同的随机数：

```Shell
>>> random.seed(10)
>>> random.random()
0.5714025946899135

>>> random.random()
0.4288890546751146

>>> random.seed(10)
>>> random.random()
0.5714025946899135
```

## random.uniform

random.uniform 用于生成一个指定范围内的随机符点数，两个参数依次指定上限和下限。

```Shell
uniform(a, b) method of random.Random instance
    Get a random number in the range [a, b) or [a, b] depending on rounding.
```

- 如果 a<b，则生成的随机数范围是 [a, b]。
- 如果 a>b，则生成的随机数范围是 [b, a]。

```Shell
>>> random.uniform(3,5)
3.857778109350229
>>> random.uniform(3,5)
4.156182602268941

>>> random.seed(10)
>>> random.uniform(3,5)
4.142805189379827

>>> random.uniform(3,5)
3.857778109350229

>>> random.seed(10)
>>> random.uniform(3,5)
4.142805189379827
```

## random.randint

random.randint 用于生成一个指定范围内的整数。

```Shell
randint(a, b) method of random.Random instance
    Return random integer in range [a, b], including both end points.
```

其中参数a是下限，参数b是上限，生成的随机数范围是 [a, b]。

```Shell
>>> random.randint(30,50)
45
>>> random.randint(30,50)
48
```

## random.randrange

random.randrange 的函数原型为 `random.randrange([start], stop[, step])`，修复了 randint 包含上界的问题。

```Shell
randrange(start, stop=None, step=1) method of random.Random instance
    Choose a random item from range(start, stop[, step]).

    This fixes the problem with randint() which includes the
    endpoint; in Python this is usually not what you want.
```

- random.randrange(stop): 用于生成一个随机整数，取值范围为 [0, stop)。
- random.randrange(start, stop[, step]): 用于生成一个随机整数，取值范围为 [start, stop)。

生成一个取值 0-999 的随机数：

```Shell
>>> random.randrange(1000)
15
>>> random.randrange(1000)
211
```

## random.choice

random.choice 从指定序列 `seq` 中随机获取一个元素。

参数 `seq` 表示一个有序类型，在python中泛指一系列的类型，例如 list,range,tuple,str等。

```Shell
choice(seq) method of random.Random instance
    Choose a random element from a non-empty sequence.
```

```Shell
# list
>>> random.choice([1,3,5,7,9])
7
>>> random.choice([1,3,5,7,9])
5
# range
>>> random.choice(range(1000))
473
# tuple
>>> random.choice((2,4,6,8,10))
4
>>> random.choice((2,4,6,8,10))
2
# str
>>> random.choice('Python')
'o'
>>> random.choice('Zen of Python')
'P'
```

## random.choices

基于不重复序列，扩容生成返回带重复数字的新序列，验证包含重复数字的测试用例。

- 源输入序列 population 保持不变。

```Shell
choices(population, weights=None, *, cum_weights=None, k=1) method of random.Random instance
    Return a k sized list of population elements chosen with replacement.

    If the relative weights or cumulative weights are not specified,
    the selections are made with equal probability.
```

- sequence：必填参数，跟 random.choice() 一样。
- weights：可选参数，用于衡量每个值的可能性的可选参数，值越大随机出现的几率也就越大，不填跟 random.choice() 没区别。
- cum_weights：可选参数，用于权衡每个值的可能性，但是在这种情况下，可能性被累加。
- k：可选参数，用于定义返回列表的长度，默认 1 个。

注意：weights 数组的元素个数必须与 population 一致，否则报错 `ValueError: The number of weights does not match the population`。

```Shell
>>> mylist = ["geeks", "for", "python"]
>>> print(random.choices(mylist, weights = [10, 1, 1], k = 5))
['geeks', 'geeks', 'geeks', 'geeks', 'geeks']
```

长度为5的列表 mylist 不包含重复元素，可调用 choices 生成包含重复元素的扩容序列，`weights` 设置（重复）出现的概率。

> 从结果看，choices 无法保证每个元素都至少出现一次。

```Shell
>>> mylist=[1,3,5,7,9]
>>> random.choices(mylist, weights=[1,4,6,3,5], k=10)
[7, 7, 3, 9, 9, 9, 7, 1, 1, 3]
```

对于 `k<len(population)` 的情形，截取的片段中可能存在重复的元素，即通过choices进行多挑少是放回取样。
如果要不放回取样抽取不重复的子序列，建议采用 `random.sample` 函数。

```Shell
# 从[0,9]九个数中放回取样5个，可能存在重复。
>>> random.choices(range(0,10), k=5)
[9, 1, 9, 7, 4]
```

## random.shuffle

random.shuffle 用于模拟洗牌，将一个列表中的元素打乱顺序。

```Shell
shuffle(x, random=None) method of random.Random instance
    Shuffle list x in place, and return None.

    Optional argument random is a 0-argument function returning a
    random float in [0.0, 1.0); if it is the default None, the
    standard random.random will be used.
```

shuffle 本身无返回值，被操作对象 mylist 被洗牌后就地打乱。

```Shell
>>> mylist=[1,3,5,7,9]
>>> random.shuffle(mylist)
>>> mylist
[7, 3, 1, 9, 5]

>>> random.shuffle(mylist)
>>> mylist
[7, 1, 3, 9, 5]
```

## random.sample

random.sample 用于模拟抽牌，从指定序列中随机抽取指定长度的片断。

```Shell
sample(population, k, *, counts=None) method of random.Random instance
    Chooses k unique random elements from a population sequence or set.

    Returns a new list containing elements from the population while
    leaving the original population unchanged.  The resulting list is
    in selection order so that all sub-slices will also be valid random
    samples.  This allows raffle winners (the sample) to be partitioned
    into grand prize and second place winners (the subslices).

    Repeated elements can be specified one at a time or with the optional keyword-only counts parameter. 
```

从 population 中随机抽取5个元素，作为一个片断（子序列）返回。
基于副本操作，源输入序列将保持不变。

```Shell
>>> random.sample(range(0,10), 5)
[4, 2, 8, 6, 0]

>>> list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
>>> slice = random.sample(list, 5)
>>> slice
[2, 6, 3, 7, 10]
```

如果 k>len(population)，则会报错：`ValueError: Sample larger than population or is negative`。

```Shell
>>> l = list(range(1,10,2))
>>> l
[1, 3, 5, 7, 9]
>>> import random
>>> random.sample(l, k=10)
    raise ValueError("Sample larger than population or is negative")
ValueError: Sample larger than population or is negative
```

此时，可通过 `counts` 参数指定每个元素出现的次数。
l=[1,3,5,7,9]，指定 counts=[1,2,2,2,3]，则1出现1次，3、5、7各出现2次，9出现三次。

```Shell
l = list(range(1,10,2))
>>> random.sample(l, k=10, counts=[1,2,2,2,3])
[7, 9, 5, 9, 9, 1, 5, 3, 3, 7]
```

## 实战示例

实际需求中，随机生成一个、两个整数或一系列整数的场景比较多。

- 生成一个整数，可以基于 `random.randrange` 或 `random.choice` 从已知序列中随机选一个。
- 生成两个整数，可以两次调用 `random.randrange` 或 `random.choice`，也可以调用 `random.sample` 从已知序列中随机挑选两个。
- 生成N个整数序列，可以for循环N次调用 `random.randrange`，或调用 `random.sample` 从已知序列（例如range）中随机挑选N个。
- 已知不重复的序列list，可调用 `random.choices` 对其进行扩容。

以下综合示例，主要

1. randomList 函数用于生成一个长度为n的随机整数列表，数值范围为 [0,1000]。
2. 调用 `random.shuffle` 对 iList1 的副本 iList2 进行洗牌。
3. 调用 `random.choices` 扩容生成包含重复元素的新序列 iList3。

```Python
import random

def randomList(n: int = 5, min: int = 1, max: int = 10) -> list:
    '''返回一个长度为n的整数列表'''
    if min > max or n>=max-min+1:
        return []

    # 方法一：基于 for 循环和 randrange，数值范围较小时很容易重复
    # iList = []
    # for i in range(n):
    #     iList.append(random.randint(min, max))
    # 方法二：基于 sample，抽样不重复
    iList = random.sample(range(min,max+1), n)
    return iList

if __name__ == "__main__":
    # 从[1,100]中随机挑选10个数
    iList = randomList(10, 1, 100)
    print(iList)
    # 从[1,10]中随机挑选6个数
    iList1 = randomList(6)
    # manipulate with iList: countingSort(iList1)
    print(iList1)
    iList2 = iList1.copy()
    random.shuffle(iList2)
    print(iList2)
    # manipulate with iList2: countingSort(iList2)
    # 扩容生成长度为10的新序列，以便包含重复元素（有些元素可能不包含）
    iList3 = random.choices(iList2, weights=[1,2,3,4,5,6], k=10)
    print(iList3)
    # manipulate with iList3: countingSort(iList3)
    # 扩容生成长度为10的新序列，counts 指定每个元素出现次数
    iList4 = random.sample(iList2, k=10, counts=[1,2,1,2,3,1])
    print(iList4)
    # manipulate with iList3: countingSort(iList4)
```
