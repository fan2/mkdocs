---
title: python单元测试示例——unittest for bsearch
authors:
  - xman
date:
    created: 2019-12-05T08:30:00
categories:
    - python
tags:
    - unittest
    - bsearch
comments: true
---

本文梳理了 python 中的单元测试框架——unittest。

<!-- more -->

模块 bisect 提供了标准的二分查找实现：`bisect_left(a, x, lo=0, hi=None, *, key=None)`。

## 二分查找的实现

下面我们用 while 循环和递归两种算法实现 binary_search。

```Python
def binary_search_loop(A: list, e, l=0, r=None, debug=False):
    assert(len(A) > 1) # 列表至少两个元素
    if r is None:
        r = len(A) - 1 # [l:r+1]
    assert(r-l > 0) # 切片至少两个元素
    assert(e in A[l:r+1]) # 元素在切片中

    # 中间命中或l(=r)命中
    while l <= r:
        m = (l+r)//2
        if debug:
            print(f'binary_search_w: {e = }, A[{l}:{r}] = {A[l:r+1]}, A[{m=}] = {A[m]}')
        if A[m] < e:
            l = m+1
        elif A[m] > e:
            r = m-1
        else:
            return m

    return -1

def binary_search_recursion(A: list, e, l=0, r=None, debug=False):
    if e not in A:
        return -1

    if r is None:
        r = len(A)-1

    m = (l+r)//2
    if debug:
        print(f'binary_search_r: {e = }, A[{l}:{r}] = {A[l:r+1]}, A[{m=}] = {A[m]}')
    if A[m] == e: # l=r
        return m
    else:
        if A[m] < e:
            return binary_search_recursion(A, e, m+1, r, debug)
        elif A[m] > e:
            return binary_search_recursion(A, e, l, m-1, debug)

```

## 测试用例的设计(case by case)

每个单元测试用于核实函数的某个方面没有问题。
测试用例（一组单元测试），用于核实一系列输入都将得到预期的输出。

本案测试用例的整体设计要点如下：

1. 基于 `random` 模块生成随机序列 rList，并调用 sorted 排好序；

    - random.sample 从序列 range(1,21) 这20个数中不放回随机取样10个数。
    - 可放大随机数范围，适当增大数据跨度；可调整列表长度为奇偶数进行测试。

2. 选取特定索引，包括边界、中心和随机位置，调用 `binary_search` 查找该元素，索引应一致。

    - 设计6组case：左边界, 右边界, 中心点, 中心左移2位, 中心右移2位, 随机位置
    - 调用 random.randrange(n) 随机抽取索引，但要与前5组case去重。

3. 测试case都是取特定索引的元素，二分查找验证位置，需要写6组assertEqual例程。

根据实际情况，可选择 unittest.main 或 unittest.TextTestRunner 作为测试入口点。

对于测试用例，6组单元测试将第一步中准备的数据作为输入，测试二分查找函数的输出是否符合预期。
第一步准备的测试数据，可以放在 `__init__` 或 `setUp` 中初始化，每个单元测试执行前都会调用。
如果想测试数据只全局初始化一次，则可考虑在类方法 `setUpClass` 中进行初始化，在 `tearDownClass` 中执行必要的清理。

可考虑加强验证测试：

1. binary_search_loop 算法试错：将 while l <= r 中的 = 去掉，看看边界case不通过的输出。
2. 可基于random.choices替代random.sample，进行放回取样，验证有重复数值序列的二分查找验证。

以下实现了循环二分查找 binary_search_loop 的测试用例 TestBSearchLoop。
如果要实现递归二分查找 binary_search_recursion 的测试用例 TestBSearchRecursion，只需切换每个case中的函数名即可。

```Python
import unittest
import random

class TestBSearchLoop(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # 在 [l,r] 之间随机挑选n个数
        l = 1; r = 40; n = 13
        random.seed(r+1)
        cls.count = n
        cls.rList = sorted(random.sample(range(l,r+1), n))
        print(40*'-')
        print(f'test_bsearch: {n}, {cls.rList = }')

    # 6个case: 左边界, 右边界, 中心点, 中心左移2位, 中心右移2位, 随机位置

    # case1: 左边界
    def test_bsearch_left(self):
        # 待搜元素
        i = 0
        e = self.rList[i]
        # 查找到的索引
        ei = binary_search_loop(self.rList, e, debug=True)
        # 应与预期索引匹配
        self.assertEqual(ei, i, msg=f'{e = }')

    # case2: 右边界
    def test_bsearch_right(self):
        # 待搜元素
        i = self.count-1
        e = self.rList[i]
        # 查找到的索引
        ei = binary_search_loop(self.rList, e, debug=True)
        # 应与预期索引匹配
        self.assertEqual(ei, i, msg=f'{e = }')

    # case3: 中心点
    def test_bsearch_middle(self):
        # 待搜元素
        i = self.count//2
        e = self.rList[i]
        # 查找到的索引
        ei = binary_search_loop(self.rList, e, debug=True)
        # 应与预期索引匹配
        self.assertEqual(ei, i, msg=f'{e = }')

    # case4: 中心左移2位
    def test_bsearch_middle_left(self):
        # 待搜元素
        i = self.count//2-2
        e = self.rList[i]
        # 查找到的索引
        ei = binary_search_loop(self.rList, e, debug=True)
        # 应与预期索引匹配
        self.assertEqual(ei, i, msg=f'{e = }')

    # case5: 中心右移2位
    def test_bsearch_middle_right(self):
        # 待搜元素
        i = self.count//2+2
        e = self.rList[i]
        # 查找到的索引
        ei = binary_search_loop(self.rList, e, debug=True)
        # 应与预期索引匹配
        self.assertEqual(ei, i, msg=f'{e = }')

    # case6: 随机位置
    def test_bsearch_random(self):
        # case 1~5
        m = self.count//2
        il = [0, self.count-1, m, m-2, m+2]
        # 待搜元素
        i = random.randrange(self.count)
        while i in il: # 去重
            i = random.randrange(self.count)
        e = self.rList[i]
        # 查找到的索引
        ei = binary_search_loop(self.rList, e, debug=True)
        # 应与预期索引匹配
        self.assertEqual(ei, i, msg=f'{e = }')

# 会启动执行当前模块中的所有TestCase测试用例
# if __name__ == '__main__':
#     unittest.main(argv=[''], verbosity=2, exit=False)

# TestSuite按需添加要执行的TestCase测试用例
def suite():
    suite = unittest.TestSuite()
    suite.addTest(TestBSearchLoop('test_bsearch_left'))
    suite.addTest(TestBSearchLoop('test_bsearch_right'))
    suite.addTest(TestBSearchLoop('test_bsearch_middle'))
    suite.addTest(TestBSearchLoop('test_bsearch_middle_left'))
    suite.addTest(TestBSearchLoop('test_bsearch_middle_right'))
    suite.addTest(TestBSearchLoop('test_bsearch_random'))
    return suite

if __name__ == '__main__':
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite())
```

## 测试用例的设计(foreach subTest)

以上测试用例的设计中，每个单元测试的工作流程如下：

1. 挑选索引及待搜元素
2. 调用待测函数，返回查找到的索引
3. 核实查找到的索引与预设索引是否匹配

除了第1步筛选出不同的索引外，后续步骤基本一样。
因此，为了可考虑将测试用例收缩到一个单元测试中，原单元测试变为子测试。
具体做法是，将6组索引提前组装成列表，再用for循环执行subTest，不通过的case会dump指定的msg。

```Python
import unittest
import random

class TestBSearchLoop(unittest.TestCase):
    def test_bsearch(self):
        """
        test: binary_search
        """
        # 在 [l,r] 之间随机挑选n个数
        l = 1; r = 20; n = 13
        random.seed(r+1)
        rList = sorted(random.sample(range(l,r+1), n))
        print(40*'-')
        print(f'test_bsearch: {n}, {rList = }')

        # 6个case: 左边界, 右边界, 中心点, 中心左移2位, 中心右移2位, 随机位置
        mi = n//2
        il = [0, n-1, mi, mi-2, mi+2]
        dl = ['left', 'right', 'middle', 'middle-left-2', 'middle-right+2']
        ri = random.randrange(n)
        while ri in il:
            ri = random.randrange(n)
        il.append(ri)
        dl.append('random')
        zl = list(zip(il, dl))

        for t in zl:
            with self.subTest(t=t):
                # 待搜元素
                e = rList[t[0]]
                # 查找到的索引
                ei = binary_search_loop(rList, e, debug=True)
                # 应与预期索引匹配
                self.assertEqual(ei, t[0], msg=f'{rList[t[0]]}, {t[1]}')


if __name__ == '__main__':
    unittest.main(argv=[''], verbosity=2, exit=False)

```

## 测试用例的设计(base case)

无论是 case by case，还是 foreach subTest，测试用例中，测试用例 TestBSearchRecursion 相比测试用例 TestBSearchLoop 只需切换每个case中的二分查找函数名即可，其他测试参数和流程一致。因此，可以考虑提取出一个基类 TestBSearch，再派生两个子类，适当时机设定待测函数即可。

### 提取测试用例基类

抽取基类：`TestBSearch`

```Python
class TestBSearch(unittest.TestCase):

```

### 提取设置测试函数入口

提取设置测试函数入口：`set_binary_search`

```Python
    # 设置二分查找搜索函数
    def set_binary_search(self, binary_search):
        if not hasattr(self, 'bsearch'):
            self.bsearch = binary_search
```

将6个case（test_bsearch_\*）中的 binary_search_loop 替换为 `self.bsearch`。

### 设计两个派生类，初始传入测试函数

设计两个 TestBSearch 的派生类 TestBSearchLoop 和 TestBSearchRecursion。
在派生类的 `__init__` 或 `setUp` 中调用 set_binary_search 设置要测试的二分查找函数。

> 每个case（test_bsearch_*）调用之前，都会调用 `__init__` 或 `setUp`。

```Python
class TestBSearchLoop(TestBSearch):
    def __init__(self, methodName: str = "runTest") -> None:
        self.set_binary_search(binary_search_loop)
        super().__init__(methodName)

    # def setUp(self) -> None:
    #     self.set_binary_search(binary_search_loop)
    #     return super().setUp()

class TestBSearchRecursion(TestBSearch):
    def __init__(self, methodName: str = "runTest") -> None:
        print('TestBSearchRecursion.init')
        self.set_binary_search(binary_search_recursion)
        super().__init__(methodName)

    # def setUp(self) -> None:
    #     self.set_binary_search(binary_search_recursion)
    #     return super().setUp()
```

### 创建TestSuite，TextTestRunner启动测试

创建两个 TestSuite，分别添加 TestBSearchLoop 和 TestBSearchRecursion 的测试用例。
再用 `unittest.TextTestRunner` 加载 TestSuite，再调用 run 启动测试用例。

```Python
# 会启动执行当前模块中的所有TestCase测试用例
# if __name__ == '__main__':
#     unittest.main(argv=[''], verbosity=2, exit=False)

# TestSuite按需添加要执行的TestCase测试用例
def suiteBSearchLoop():
    suite = unittest.TestSuite()
    suite.addTest(TestBSearchLoop('test_bsearch_left'))
    suite.addTest(TestBSearchLoop('test_bsearch_right'))
    suite.addTest(TestBSearchLoop('test_bsearch_middle'))
    suite.addTest(TestBSearchLoop('test_bsearch_middle_left'))
    suite.addTest(TestBSearchLoop('test_bsearch_middle_right'))
    suite.addTest(TestBSearchLoop('test_bsearch_random'))
    return suite

def suiteBSearchRecursion():
    suite = unittest.TestSuite()
    suite.addTest(TestBSearchRecursion('test_bsearch_left'))
    suite.addTest(TestBSearchRecursion('test_bsearch_right'))
    suite.addTest(TestBSearchRecursion('test_bsearch_middle'))
    suite.addTest(TestBSearchRecursion('test_bsearch_middle_left'))
    suite.addTest(TestBSearchRecursion('test_bsearch_middle_right'))
    suite.addTest(TestBSearchRecursion('test_bsearch_random'))
    return suite

def suiteBSearch():
    suite = unittest.TestSuite()
    suiteLoop = suiteBSearchLoop()
    suiteRecursion = suiteBSearchRecursion()
    suite.addTests(suiteLoop)
    suite.addTests(suiteRecursion)
    return suite

if __name__ == '__main__':
    runner = unittest.TextTestRunner(verbosity=2)
    # runner.run(suiteBSearchLoop())
    # runner.run(suiteBSearchRecursion())
    runner.run(suiteBSearch())
```

## 测试用例的设计(base case for subTest)

基于以上测试用例的设计思路，将subTest的测试用例稍加改造即可同时支持测试两种目标函数。

```Python
import unittest
import random

class TestBSearch(unittest.TestCase):

    # 设置二分查找搜索函数
    def set_binary_search(self, binary_search):
        if not hasattr(self, 'bsearch'):
            self.bsearch = binary_search

    def test_bsearch(self):
        # 在 [l,r] 之间随机挑选n个数
        l = 1; r = 40; n = 13
        random.seed(r+1)
        rList = sorted(random.sample(range(l,r+1), n))
        print(40*'-')
        print(f'test_bsearch: {n}, {rList = }')

        # 6个case: 左边界, 右边界, 中心点, 中心左移2位, 中心右移2位, 随机位置
        mi = n//2
        il = [0, n-1, mi, mi-2, mi+2]
        dl = ['left', 'right', 'middle', 'middle-left-2', 'middle-right+2']
        ri = random.randrange(n)
        while ri in il:
            ri = random.randrange(n)
        il.append(ri)
        dl.append('random')
        zl = list(zip(il, dl))

        for t in zl:
            with self.subTest(t=t):
                # 待搜元素
                e = rList[t[0]]
                # 查找到的索引
                ei = self.bsearch(rList, e, debug=True)
                # 应与预期索引匹配
                self.assertEqual(ei, t[0], msg=f'{rList[t[0]]}, {t[1]}')

class TestBSearchLoop(TestBSearch):
    def __init__(self, methodName: str = "runTest") -> None:
        self.set_binary_search(binary_search_loop)
        super().__init__(methodName)

    # def setUp(self) -> None:
    #     self.set_binary_search(binary_search_loop)
    #     return super().setUp()

class TestBSearchRecursion(TestBSearch):
    def __init__(self, methodName: str = "runTest") -> None:
        self.set_binary_search(binary_search_recursion)
        super().__init__(methodName)

    # def setUp(self) -> None:
    #     self.set_binary_search(binary_search_recursion)
    #     return super().setUp()

# 会启动执行当前模块中的所有TestCase测试用例
# if __name__ == '__main__':
#     unittest.main(argv=[''], verbosity=2, exit=False)

# TestSuite按需添加要执行的TestCase测试用例
def suiteBSearch():
    suite = unittest.TestSuite()
    suite.addTest(TestBSearchLoop('test_bsearch'))
    suite.addTest(TestBSearchRecursion('test_bsearch'))
    return suite

if __name__ == '__main__':
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suiteBSearch())
```
