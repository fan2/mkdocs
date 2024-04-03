---
title: python单元测试框架——unittest
authors:
  - xman
date:
    created: 2019-12-05T08:20:00
categories:
    - python
tags:
    - unittest
comments: true
---

本文梳理了 python 中的单元测试框架——unittest。

<!-- more -->

参考：

- 《Python基础教程》第16章《测试基础》
- 《Python编程从入门到实践》第11章《测试代码》

极限编程先锋引入了“测试一点点，再编写一点点代码”的理念。这种理念与直觉不太相符，却很管用，胜过与直觉一致的“编写一点点代码，再测试一点点”的做法。
换而言之，测试在先，编码在后。这也称为**测试驱动的编程**。

开发软件时，必须先知道软件要解决什么问题——要实现什么样的目标。要阐明程序的目标，可编写需求说明，也就是描述程序必须满足何种需求的文档。这样以后就很容易核实 需求是否确实得到了满足。

这里的理念是先编写测试，再编写让测试通过的程序。测试程序就是需求说明，可帮助确保程序开发过程紧扣这些需求。

在测试领域，有两个重要的基础概念：单元测试和测试用例。**单元测试**用于核实函数的某个方面没有问题；**测试用例**是一组单元测试，这些单元测试一起核实函数在各种情形下的行为都符合要求。

**全覆盖式测试**用例包含一整套单元测试，涵盖了各种可能的函数使用方式。
良好的测试用例考虑到了函数可能收到的各种输入，包含针对所有这些情形的测试。
对于大型项目，要实现全覆盖可能很难。通常，最初只要针对代码的重要行为编写测试即可，等项目被广泛使用时再考虑全覆盖。

**覆盖率**（coverage）是一个重要的测试概念。
运行测试时，很可能达不到运行所有代码（分支）的理想状态。
实际上，最理想的情况是，使用各种可能的输入检查每种可能的程序状态，但这根本不可能做到。
优秀测试套件的目标之一是确保较高的覆盖率，为此可使用覆盖率工具，它们测量测试期间实际运行的代码所占的比例。

Python标准库中的模块unittest提供了自动化测试框架工具集，让你能够以结构化方式编写庞大而详尽的测试集（测试用例）。

# unittest

[unittest — Unit testing framework — Python 3.12.2 documentation](https://docs.python.org/3/library/unittest.html)
[unittest --- 单元测试框架 — Python 3.12.2 文档](https://docs.python.org/zh-cn/3/library/unittest.html#)

The unittest unit testing framework was originally inspired by JUnit and has a similar flavor as major unit testing frameworks in other languages.

The unittest module provides a rich set of tools for constructing and running tests.

## TestCase

In unittest, test cases are represented by `unittest.TestCase` instances. To make your own test cases you must write subclasses of `TestCase` or use FunctionTestCase.

**test case**:

A test case is the individual unit of testing. It checks for a specific response to a particular set of inputs. 
unittest provides a base class,` TestCase`, which may be used to create new test cases.
A testcase is created by subclassing `unittest.TestCase`. 

### test/helper

以上代码 class NameTestCase 继承 `unittest.TestCase` 创建了一个测试样例。

测试方法都以 `test` 开头命名，该前缀告诉测试框架哪些方法是需要运行的单元测试。
unittest 运行起来后，会执行该模块的测试用例，即所有以 `test` 开头的单元测试。

> The three individual tests are defined with methods whose names start with the letters `test`.
> This naming convention informs the test runner about which methods **represent** tests.

如果多个单元测试，测试流程基本相同，仅仅是部分测试参数差异。此时，可考虑将公共部分提取为辅助函数。然后，测试用例都调用这个辅助函数。

> 如果想要定义辅助函数，只要命名不以 test 开头的 [Non-test methods](https://stackoverflow.com/questions/6961099/non-test-methods-in-a-python-testcase) 即可。

### setUp/tearDown

通过 setUp() 和 tearDown() 方法，可以设置测试开始前与完成后需要执行的指令。

运行每个以 `test` 开头命名的单元测试，都会先执行 setUp()；用例执行完，会执行 tearDown()。

1. Tests can be numerous, and their set-up can be repetitive. Luckily, we can factor out set-up code by implementing a method called `setUp`(), which the testing framework will automatically call for every single test we run.
2. Similarly, we can provide a `tearDown`() method that tidies up after the test method has been run.

Tests share setup and shutdown code: The `setUp`() and `tearDown`() methods allow you to define instructions that will be executed before and after **each** test method.

可在 `__init__` 中初始化成员变量，挂靠到self上，后续测试用例通过 self.var 形式引用这些成员变量。
但 `__init__` 不止初始化一次，调用次数同 setUp/tearDown，即运行每个单元测试前都会运行。

A new TestCase instance is created as a unique test fixture used to execute each individual test method. Thus `setUp`(), `tearDown`(), and `__init__`() will be called once per test.

例如所有单元测试中都会用到的相同的测试数据，可以抽取到 `__init__` 或 `setUp` 中初始化，然后定义为属性(prop)，在后续测试用例中引用(self.prop)。
这样做，可以避免测试用例中对一套测试数据的重复书写（初始化），但是运行期每次执行单元测试之前都会调用 `__init__` 或 `setUp` 还是会重复初始化。
对于网络连接这类重型操作，如果每个单元测试都创建/销毁一条临时网络连接，动作幅度和资源消耗非常大，最好是能全局初始化只创建一次。
在这种场景下，可考虑调用类方法 `setUpClass` 创建一条公用的网络连接，然后在 `tearDownClass` 中关闭连接（销毁相关资源）。

```Python
import unittest

class Test(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls._connection = createExpensiveConnectionObject()

    @classmethod
    def tearDownClass(cls):
        cls._connection.destroy()
```

在测试用例中，可通过 `self._connection` 引用这个成员变量。

### assert methods

每个测试的关键是使用断言来管理预期：

- 调用 assertEqual 或 assertNotEqual 来检查预期的输出（check for an expected result）；
- 调用 assertTrue 或 assertFalse 来验证一个条件（verify a condition）；
- 调用 assertIs 或 assertIsNot 来验证是否同一对象；
- 调用 assertIsNone 或 assertIsNotNone 来验证对象是否有效；
- 调用 assertIn 或 assertNotIn 来验证包含情况；
- 调用 assertIsInstance 或 assertNotIsInstance 来验证对象和是否是类的实例；

这些断言方法都支持 msg 参数，如果指定了该参数，它将被用作测试失败时的错误消息。

使用这些方法而不是 `assert` 语句是为了让测试运行者能聚合所有的测试结果并产生结果报告。

> These methods are used instead of the assert statement so the test runner can accumulate all test results and produce a report.

the list of assert methods:

方法 | 检查对象 | 引入版本
----|---------|-----------
assertEqual(a, b) | a == b
assertNotEqual(a, b) | a != b
assertTrue(x) | bool(x) is True
assertFalse(x) | bool(x) is False
assertIs(a, b) | a is b | 3.1
assertIsNot(a, b) | a is not b | 3.1
assertIsNone(x) | x is None | 3.1
assertIsNotNone(x) | x is not None | 3.1
assertIn(a, b) | a in b | 3.1
assertNotIn(a, b) | a not in b | 3.1
assertIsInstance(a, b) | isinstance(a, b) | 3.2
assertNotIsInstance(a, b) | not isinstance(a, b) | 3.2

还有 assertGreater/assertGreaterEqual、assertLess/assertLessEqual、assertRegex/assertNotRegex、assertCountEqual 等断言方法。

还可以使用下列方法来检查异常、警告和日志消息的产生:

方法 | 检查对象 | 引入版本
----|---------|-----------
assertRaises(exc, fun, *args, **kwds) | `fun(*args, **kwds)` 引发了 exc
assertRaisesRegex(exc, r, fun, *args, **kwds) | `fun(*args, **kwds)` 引发了 exc 并且消息可与正则表达式 r 相匹配 | 3.1
assertWarns(warn, fun, *args, **kwds) | `fun(*args, **kwds)` 引发了 warn | 3.2
assertWarnsRegex(warn, r, fun, *args, **kwds) | `fun(*args, **kwds)` 引发了 warn 并且消息可与正则表达式 r 相匹配 | 3.2
assertLogs(logger, level) | `with` 代码块在 logger 上使用了最小的 level 级别写入日志 | 3.4
assertNoLogs(logger, level) | `with` 代码块没有在 logger 上使用最小的 level 级别写入日志 | 3.10

## entrypoint

测试模块一般是直接运行的，其中的入口点触发测试用例的运行。
启动运行后，将实例化所有（或挑选的）的TestCase子类，并运行所有（或挑选的）以test打头的方法（单元测试）。

### main run TestCase

```Python
unittest.main(module='__main__', defaultTest=None, argv=None, testRunner=None, testLoader=unittest.defaultTestLoader, exit=True, verbosity=1, failfast=None, catchbreak=None, buffer=None, warnings=None)

A command-line program that loads a set of tests from module and runs them; this is primarily for making test modules conveniently executable.
```

The simplest use for this function is to include the following line at the end of a test script:

```Python
if __name__ == '__main__':
    unittest.main()
```

You can run tests with more detailed information by passing in the verbosity argument:

```Python
if __name__ == '__main__':
    unittest.main(verbosity=2)
```

考虑在 vscode 中使用 Jupyter Notebook 情景。

假设Cell 1中定义了一个函数：

```Python
def add(a, b):
    return a + b
```

可在Cell 2中编写测试Cell 1中add函数的单测用例：

- 运行Cell2之前，必须先运行Cell1使之加载。

```Python
import unittest

class TestNotebook(unittest.TestCase):

    def test_add(self):
        self.assertEqual(add(2, 3), 5)

if __name__ == '__main__':
    unittest.main(argv=[''], verbosity=2, exit=False)
```

**注意**：测试框架入口函数 unittest.main() 在 ipykernel 下需要指定 `argv` 和 `exit` 参数，否则运行报错！

[用单元测试让你的python代码更靠谱测试函数单元测试和测试用例测试类-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1347180)

假设 name_function.py 文件中定义了 get_formatted_name 函数：

```Python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

def get_formatted_name(first, last, middle=''):
    if middle:
        full_name = first + ' ' + middle + ' ' + last
    else:
        full_name = first + ' ' + last
    return full_name.title()
```

test_name_function.py 单测 name_function 中的 get_formatted_name 函数：

```Python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import unittest
from name_function import get_formatted_name


class NameTestCase(unittest.TestCase):
    def test_first_last_name(self):
        formatted_name = get_formatted_name('janis', 'joplin')
        self.assertEqual(formatted_name, 'Janis Joplin')

    def test_first_last_middle_name(self):
        formatted_name = get_formatted_name('wolfgang', 'mozart', 'amadeus')
        self.assertEqual(formatted_name, 'Wolfgang Amadeus Mozart')


unittest.main()
```

在控制台中运行测试用例脚本：

```Shell
$ python3 test_name_function.py
..
----------------------------------------------------------------------
Ran 2 tests in 0.000s

OK
```

测试框架入口函数 unittest.main() 默认 verbosity=1，可修改为2，以便打印更详细的单测过程：

```Shell
# unittest.main(verbosity=2)
$ python3 test_name_function.py #or
$ python -m unittest test_name_function.py #or
$ python -m unittest -v test_name_function.py

test_first_last_middle_name (__main__.NameTestCase.test_first_last_middle_name) ... ok
test_first_last_name (__main__.NameTestCase.test_first_last_name) ... ok

----------------------------------------------------------------------
Ran 2 tests in 0.000s

OK
```

### TextTestRunner run TestSuite

**test suite**

A test suite is a collection of test cases, test suites, or both. It is used to aggregate tests that should be executed together.

```Python
class unittest.TextTestRunner(stream=None, descriptions=True, verbosity=1, failfast=False, buffer=False, resultclass=None, warnings=None, *, tb_locals=False, durations=None)

A basic test runner implementation that outputs results to a stream. If stream is None, the default, sys.stderr is used as the output stream. This class has a few configurable parameters, but is essentially very simple. Graphical applications which run test suites should provide alternate implementations. Such implementations should accept **kwargs as the interface to construct runners changes when features are added to unittest.

run(test)
    This method is the main public interface to the TextTestRunner. This method takes a TestSuite or TestCase instance.
```

以下示例中，TestStringMethods 定义了三个 test 用例，TestSuite addTest 添加两个用例，然后调用 unittest.TextTestRunner run TestSuite。

```Python
import unittest

class TestStringMethods(unittest.TestCase):

    def test_upper(self):
        self.assertEqual('foo'.upper(), 'FOO')

    def test_isupper(self):
        self.assertTrue('FOO'.isupper())
        self.assertFalse('Foo'.isupper())

    def test_split(self):
        s = 'hello world'
        self.assertEqual(s.split(), ['hello', 'world'])
        # check that s.split fails when the separator is not a string
        with self.assertRaises(TypeError):
            s.split(2)

# if __name__ == '__main__':
    # unittest.main(argv=[''], verbosity=2, exit=False)

def suite():
    suite = unittest.TestSuite()
    suite.addTest(TestStringMethods('test_upper'))
    suite.addTest(TestStringMethods('test_isupper'))
    return suite

if __name__ == '__main__':
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite())
```

### main or TextTestRunner?

采用 `unittest.main` 作为测试入口点时，会启动执行当前模块（Python File或Jupyter Notebook）中的所有TestCase测试用例。

1. Python File 包含多个 TestCase
2. Jupyter Code Cell 中包含多个 TestCase
3. Jupyter 包含多个包含 TestCase 的 Code Cell

如果不想执行所有的测试用例，最好将不同的测试用例分散到独立的模块中，保证每个Python File或者Jupyter Notebook中只有一个TestCase测试用例。
也可创建 TestSuite 按需添加指定 TestCase 的测试用例，改用 `unittest.TextTestRunner` 加载 TestSuite，再调用 run 启动测试用例。

## Organization

### subTest

Distinguishing test iterations using subtests

When there are very small differences among your tests, for instance some parameters, unittest allows you to distinguish them inside the body of a test method using the `subTest`() context manager.

> `self.subTest(msg=None, **params)` Return a context manager which executes the enclosed code block as a subtest.

一般用在for循环下，结合 with 和 subTest 将循环体代码块作为子测试，而非简单的代码语句，从而拥有类似单元测试的报错机制。
对于大量逻辑重复的单元测试，仅仅是测试数据索引级别的差异，可考虑使用for循环搭配subTest改写为一个单元测试，使代码更简洁。

```Python
class NumbersTest(unittest.TestCase):

    def test_even(self):
        """
        Test that numbers between 0 and 5 are all even.
        """
        for i in range(0, 6):
            with self.subTest(i=i):
                self.assertEqual(i % 2, 0)

if __name__ == '__main__':
    unittest.main(argv=[''], verbosity=2, exit=False)
```

Without using a subtest, execution would **stop** after the *first* failure, and the error would be less easy to diagnose because the value of `i` wouldn’t be displayed.

对于以上 test_even 用例中的 for 循环，如果不添加 subTest，那么i=1时，用例即立即宣告失败并退出。
实际上，我们希望跑完for循环，并将失败的循环变量i打印出来，添加 subTest 可满足这种需求。

### skip

Unittest supports skipping individual test methods and even whole classes of tests.

Skipping a test is simply a matter of using the skip() decorator or one of its conditional variants:

- 以下在 python 3.10 以下运行时，单元测试 skipIf 会报 SyntaxError: invalid syntax 错误，因为无法识别 match/case 关键字。

```Python
import sys, unittest

class MyTestCase(unittest.TestCase):

    @unittest.skip("demonstrating skipping")
    def test_nothing(self):
        self.fail("shouldn't happen")

    @unittest.skipUnless(sys.platform.startswith("win"), "requires Windows")
    def test_windows_support(self):
        # windows specific testing code
        pass

    @unittest.skipIf(sys.version_info < (3, 10),
                     "Python Version too low, upgrade to 3.10 or higher.")
    def test_match_case(self):
        # Tests that work for Python >= 3.10.
        def http_error(status):
            match status:
                case 400:
                    return "Bad request"
                case 404:
                    return "Not found"
                case 418:
                    return "I'm a teapot"
                case _:
                    return "Something's wrong with the internet"
        self.assertEqual(http_error(404), "Not found")
```

Classes can be skipped just like methods:

```Python
@unittest.skip("MyTestCase")
class MyTestCase(unittest.TestCase):
    def test_not_run(self):
        pass

    def test_nothing(self):
        self.fail("shouldn't happen")
```
