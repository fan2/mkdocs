---
title: C++ Data Types
authors:
  - xman
date:
    created: 2009-10-03T16:00:00
    updated: 2024-04-20T10:00:00
categories:
    - cpp
tags:
    - data_type
comments: true
---

Every name and every expression has a type that determines the operations that may be performed on it.

Types built out of the built-in types using C++’s abstraction mechanisms are called *user-deﬁned types*. They are referred to as structures, classes and enumerations.

<!-- more -->

## C++ Type

[C++ Type](http://en.cppreference.com/w/cpp/language/type)

> The signedness of char depends on the compiler and the target platform: the defaults for ARM and PowerPC are typically **unsigned**, the defaults for x86 and x64 are typically **signed**.

![cpp_types](https://upload.cppreference.com/mwiki/images/9/96/cpp_types.svg)

[C++ Fundamental types](https://en.cppreference.com/w/cpp/language/types?cf_lbyyhhwhyjj5l3rs65cb3w=6d3uam2jwchpcfhhfnoiwc)

![stdint-properties](./images/stdint-properties.png)

GCC libstdc++ [Types](https://gcc.gnu.org/onlinedocs/libstdc++/manual/support.html)

[C++98](http://www.cplusplus.com/doc/oldtutorial/) : [Variables. Data Types.](http://www.cplusplus.com/doc/oldtutorial/variables/)

MSDN - [C++ Type System](https://learn.microsoft.com/en-us/cpp/cpp/cpp-type-system-modern-cpp)

The following illustration shows the relative sizes of the built-in types in the Microsoft C++ implementation:

![built-intypesizes](https://learn.microsoft.com/en-us/cpp/cpp/media/built-intypesizes.png)

MSDN - [Built-in types (C++)](https://learn.microsoft.com/en-us/cpp/cpp/fundamental-types-cpp)

- Void type
- std::nullptr_t
- Boolean type
- Character types
- Floating-point types
- Integer types
- Sizes of built-in types

## TC++PL4

[A Tour of C++(3e)-2022](https://www.stroustrup.com/tour3.html)
[The\_C++\_Programming\_Language(4e)-2013](https://www.stroustrup.com/4th.html)

- 2.2 The Basics | 2.2.2 Types, Variables, and Arithmetic
- 2.3 User-Deﬁned Types : Structures; Classes; Enumerations

### 2.2 The Basics

Every name and every expression has a type that determines the operations that may be performed on it. For example, the declaration

```cpp
int inch;
```
speciﬁes that inch is of type int; that is, inch is an integer variable.

A declaration is a statement that introduces a name into the program. It speciﬁes a type for the named entity:

- A type deﬁnes a set of possible values and a set of operations (for an object).
- An object is some memory that holds a value of some type.
- A value is a set of bits interpreted according to a type.
- A variable is a named object.

Each fundamental type corresponds directly to hardware facilities and has a ﬁxed size that determines the range of values that can be stored in it.

- bool: 1
- char: 1
- int: 4
- double: 8

A char variable is of the natural size to hold a character on a given machine (typically an 8-bit byte), and the sizes of other types are quoted in multiples of the size of a char. The size of a type is implementation-deﬁned (i.e., it can vary among different machines) and can be obtained by the sizeof operator; for example, sizeof(char) equals 1 and sizeof(int) is often 4.

### 2.3 User-Deﬁned Types

We call the types that can be built from the fundamental types, the const modiﬁer, and the declarator operators ***built-in types***. C++’s set of built-in types and operations is rich, but deliberately low-level. They directly and efﬁciently reﬂect the capabilities of conventional computer hardware. However, they don’t provide the programmer with high-level facilities to conveniently write advanced applications. Instead, C++ augments the built-in types and operations with a sophisticated set of *abstraction mechanisms* out of which programmers can build such high-level facilities.

The C++ abstraction mechanisms are primarily designed to let programmers design and implement their own types, with suitable representations and operations, and for programmers to simply and elegantly use such types. Types built out of the built-in types using C++’s abstraction mechanisms are called ***user-deﬁned types***. They are referred to as structures, classes and enumerations.

User-defined types can be built out of both built-in types and other user-defined types. User-defined types are often preferred over built-in types because they are easier to use, less error-prone, and typically as efficient for what they do as direct use of built-in types, or even more efficient.
