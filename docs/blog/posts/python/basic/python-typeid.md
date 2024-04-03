---
title: python type & id
authors:
  - xman
date:
    created: 2019-12-02T08:20:00
categories:
    - python
comments: true
---

python 中的类型判断，包括 type, id, is, isinstance, hasattr 等内容。

<!-- more -->

[The Python Standard Library](https://docs.python.org/3/library/index.html)

## type

type 为内建模块（builtins）中定义的基本类型。

```shell
>>> help(type)

Help on class type in module builtins:

class type(object)
 |  type(object_or_name, bases, dict)
 |  type(object) -> the object's type
 |  type(name, bases, dict) -> a new type
```

执行 `type(object)`  可查看变量的类型：

```shell
>>> i=2018
>>> print(type(i))
<class 'int'>

>>> str_1 = str()
>>> print(type(str_1))
<class 'str'>
```

## id

执行 `help(builtins)` 可以查看到内置函数 `id()`：

```shell
>>> help(builtins)

Help on built-in module builtins:

    id(obj, /)
        Return the identity of an object.
```

`id(obj)` 用于获取类或对象的类型 ID。

```shell
# 也可执行 print(id.__doc__)

>>> help(id)

Help on built-in function id in module builtins:

id(obj, /)
    Return the identity of an object.
    
    This is guaranteed to be unique among simultaneously existing objects.
    (CPython uses the object's memory address.)
```

以下测试打印类 str 和实例 str1 和 str2 的类型 ID：

```shell
>>> str1=str()
>>> str2='str2'
>>> id(str)
4363629888
>>> id(str1)
4364618416
>>> id(str2)
4391268056
```

## isinstance

```shell
    isinstance(obj, class_or_tuple, /)
        Return whether an object is an instance of a class or of a subclass thereof.

```

## hasattr/getattr/setattr/delattr

1. `hasattr`: 判断对象 obj 是否有名称为 name 的属性，返回 bool 类型。
2. `getattr`: 获取对象 obj 名称为 name 的属性，支持指定默认值 default。
3. `setattr`: 将对象 obj 名称为 name 的属性设置为指定的值 value。
4. `delattr`: 删除对象 obj 名称为 name 的属性。

```Shell
hasattr(obj, name, /)
    Return whether the object has an attribute with the given name.

    This is done by calling getattr(obj, name) and catching AttributeError.

getattr(...)
    getattr(object, name[, default]) -> value

    Get a named attribute from an object; getattr(x, 'y') is equivalent to x.y.
    When a default argument is given, it is returned when the attribute doesn't
    exist; without it, an exception is raised in that case.

setattr(obj, name, value, /)
    Sets the named attribute on the given object to the specified value.

    setattr(x, 'y', v) is equivalent to ``x.y = v``

delattr(obj, name, /)
    Deletes the named attribute from the given object.

    delattr(x, 'y') is equivalent to ``del x.y``
```

[python - How to check if an object has an attribute? - Stack Overflow](https://stackoverflow.com/questions/610883/how-to-check-if-an-object-has-an-attribute)

```Python
if not hasattr(someObject, 'someProp'):
    # Set someProp
    setattr(someObject, 'someProp', var_or_method)
    pass

if hasattr(someObject, 'someProp'):
    # Access someProp
    # prop = someObject.someProp
    # prop = getattr(someObject, 'someProp')
    pass

try:
    getattr(someObject, 'someProp')
except AttributeError:
    print "someObject not hasattr someProp"
else
    print "someObject hasattr someProp"
```

假如要设计一个二分查找的测试用例，精心挑选序列的一些指定索引元素进行查找，判断查找出的索引是否符合预期。
为了测试循环和递归两种算法，我们设计了一个基础类 TestBSearch，提供接口 set_binary_search 供子类设定要测试的目标算法（函数）。

> 子类的 `__init__` 或 `setUp` 中调用该接口设定目标算法函数。

这里把传入的 binary_search 挂接到属性 bsearch 上，以供后续 test 测试用例调用。
由于每个测试用例执行时都会调用一遍 `__init__` 或 `setUp`，这里进行去重判断。
如果没有这个属性才挂接，否则不重复挂接。

```Python
class TestBSearch(unittest.TestCase):

    # 设置二分查找搜索函数
    def set_binary_search(self, binary_search):
        if not hasattr(self, 'bsearch'):
            self.bsearch = binary_search

```

## class method

### __base__

执行 `obj.__base__()` 或 `obj.__bases__()` 可以查看 obj 的基类。

```shell
# str 的基类是 object
>>> print(str.__base__)
<class 'object'>

# bool 的基类是 int
>>> print(bool.__base__)
<class 'int'>
>>> print(bool.__bases__)
(<class 'int'>,)

# int 的基类是 object
>>> print(int.__base__)
<class 'object'>
```

### __subclasses__

某些类别提供了 `__subclasscheck__()` 方法，用于检测是否是其他类的子类。

```shell
 |  __subclasscheck__(...)
 |      __subclasscheck__() -> bool
 |      check if a class is a subclass
```

`__subclasses__()` 方法则用于列举子类。

```shell
 |  __subclasses__(...)
 |      __subclasses__() -> list of immediate subclasses
```

执行 `int.__subclasses__()` 可列举查看 int 的子类：

```shell
>>> print(int.__subclasses__())
[<class 'bool'>, <enum 'IntEnum'>, <enum 'IntFlag'>, <class 'sre_constants._NamedIntConstant'>]

```

**特例**：查看 object 所有的子类，相当于列举所有可用的类：

```shell
>>> print(object.__subclasses__())
```

```shell
    issubclass(cls, class_or_tuple, /)
        Return whether 'cls' is a derived from another class or is the same class.
```

## is, is not

reference - [6.10.3. Identity comparisons](https://docs.python.org/3/reference/expressions.html#is)

The operators `is` and `is not` test for **object identity**: `x is y` is true if and only if x and y are the same object. Object identity is determined using the `id()` function. x is not y yields the inverse truth value. 

```shell
>>> str1='str1'
>>> str2=str1
>>> str1 is str2
True
>>>
>>> str2='str1'
>>> str1 is str2
True
>>>
>>> str2='str2'
>>> str1 is str2
False
```

## inspect

```shell
>>> import inspect
>>> help(inspect)

Help on module inspect:

NAME
    inspect - Get useful information from live Python objects.



# 判断 object 是否为模块
inspect.ismodule(object)
Return true if the object is a module.

# 判断 object 是否为类
inspect.isclass(object)
Return true if the object is a class, whether built-in or created in Python code.

# 判断 object 是否为绑定方法
inspect.ismethod(object)
Return true if the object is a bound method written in Python.

# 判断 object 是否为函数
inspect.isfunction(object)
Return true if the object is a Python function, which includes functions created by a lambda expression.
```

## demos

[How to find out if a Python object is a string?](https://stackoverflow.com/questions/1303243/how-to-find-out-if-a-python-object-is-a-string)

```shell
>>> str1=str()
>>> str2='str2'

>>> type(str1)
<class 'str'>
>>> type(str2)
<class 'str'>

>>> type(str1) is str
True
>>> type(str2) is str
True

>>> isinstance(str1,str)
True

>>> str(str2)==str2
True
```

以下为 `inspect.is*` 系列函数示例：

```shell

>>> inspect.ismodule(str)
False
>>> inspect.isclass(str)
True
>>> inspect.ismodule(string)
True
>>> inspect.isclass(string)
False
>>> inspect.ismethod(string.capwords)
False
>>> inspect.isfunction(string.capwords)
True
>>> inspect.isclass(string.Template)
True
>>> inspect.ismethod(string.Template.substitute)
False
>>> inspect.isfunction(string.Template.substitute)
True

```
