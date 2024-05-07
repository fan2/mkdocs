---
title: C++ Standard - Data Types
authors:
  - xman
date:
    created: 2023-06-01T10:00:00
categories:
    - cpp
tags:
    - standard
    - data_type
comments: true
---

ISO/IEC C++ standard basic types specification: Fundamental types, Compound types and CV-qualifiers.

<!-- more -->

[ISO/IEC-N4950](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf) - 20230510

## 6.8.2 Fundamental types

[basic.fundamental]

1. There are five standard signed integer types: `signed char`, `short int`, `int`, `long int`, and `long long int`. In this list, each type provides at least as much storage as those preceding it in the list. There may also be implementation-defined *extended signed integer types*. The standard and extended signed integer types are collectively called ***signed integer types***. The range of representable values for a signed integer type is −2^N−1^ to 2^N−1^ − 1 (inclusive), where *N* is called the *width* of the type.

    !!! note "Plain ints"

        Plain ints are intended to have the natural width suggested by the architecture of the execution environment; the other signed integer types are provided to meet special needs.

2. For each of the standard signed integer types, there exists a corresponding (but different) *standard unsigned integer type*: `unsigned char`, `unsigned short int`, `unsigned int`, `unsigned long int`, and `unsigned long long int`. Likewise, for each of the extended signed integer types, there exists a corresponding *extended unsigned integer type*. The standard and extended unsigned integer types are collectively called ***unsigned integer types***. An unsigned integer type has the same width *N* as the corresponding signed integer type. The range of representable values for the unsigned type is 0 to 2^N^ − 1 (inclusive); arithmetic for the unsigned type is performed modulo 2^N^.

    !!! note "signed arithmetic overflow"

        Unsigned arithmetic does not overflow. Overflow for signed arithmetic yields undefined behavior (7.1).

3. An unsigned integer type has the same object representation, value representation, and alignment requirements (6.7.6) as the corresponding signed integer type. For each value x of a signed integer type, the value of the corresponding unsigned integer type congruent to x modulo 2^N^ has the same value of corresponding bits in its value representation.

    Table 14: Minimum width - [tab:basic.fundamental.width]

    Type | Minimum width *N*
    -----|------------------
    signed char | 8
    short int | 16
    int | 16
    long int | 32
    long long int | 64

    !!! example "signed -1, unsigned max"

        The value `−1` of a signed integer type has the same representation as the largest value of the corresponding unsigned type.

4. The width of each signed integer type shall not be less than the values specified in Table 14. The value representation of a signed or unsigned integer type comprises *N* bits, where N is the respective width. Each set of values for any padding bits (6.8.1) in the object representation are alternative representations of the value specified by the value representation.

    !!! note "padding bits"

        Padding bits have *unspecified* value, but cannot cause traps. In contrast, see ISO C 6.2.6.2.

    !!! note "signed and unsigned constraints"

        The signed and unsigned integer types satisfy the *constraints* given in ISO C 5.2.4.2.1.

- Except as specified above, the width of a signed or unsigned integer type is implementation-defined.

5. Each value x of an unsigned integer type with width `N` has a unique representation $x = x_{0}2^0 + x_{1}2^1 + \dotsc + x_{N-1}2^{N-1}$ , where each coefficient x i is either 0 or 1; this is called the base-2 representation of x. The base-2 representation of a value of signed integer type is the base-2 representation of the congruent value of the corresponding unsigned integer type. The standard signed integer types and standard unsigned integer types are collectively called the ***standard integer types***, and the extended signed integer types and extended unsigned integer types are collectively called the ***extended integer types***.

$$
B2U_n(\vec{x}) \dot=\sum_{i=0}^{N-1}x_i\ast2^i
$$

6. A fundamental type specified to have a signed or unsigned integer type as its *underlying type* has the same object representation, value representation, alignment requirements (6.7.6), and range of representable values as the underlying type. Further, each value has the same representation in both types.

7. Type `char` is a distinct type that has an implementation-defined choice of `signed char` or `unsigned char` as its underlying type. The three types `char`, `signed char`, and `unsigned char` are collectively called *ordinary character types*. The ordinary character types and `char8_t` are collectively called *narrow character types*. For narrow character types, each possible bit pattern of the object representation represents a distinct value.

    !!! note "Note 5"

        This requirement does not hold for other types.

    !!! note "Note 6"

        A bit-field of narrow character type whose width is larger than the width of that type has padding bits; see 6.8.1.

8. Type `wchar_t` is a distinct type that has an implementation-defined `signed` or `unsigned` integer type as its underlying type.

9. Type `char8_t` denotes a distinct type whose underlying type is `unsigned char`. Types `char16_t` and `char32_t` denote distinct types whose underlying types are `uint_least16_t` and `uint_least32_t`, respectively, in <cstdint\> (17.4.1).

10. Type `bool` is a distinct type that has the same object representation, value representation, and alignment requirements as an implementation-defined unsigned integer type. The values of type bool are *true* and *false*.

    !!! note "distinction/uniqeness of bool"

        There are no signed, unsigned, short, or long bool types or values.

11. The types `char`, `wchar_t`, `char8_t`, `char16_t`, and `char32_t` are collectively called *character types*. The character types, bool, the signed and unsigned integer types, and cv-qualified versions (6.8.5) thereof, are collectively termed *integral types*. A synonym for integral type is ***integer type***.

    !!! note "Enumerations"

        Enumerations (9.7.1) are not integral; however, unscoped enumerations can be *promoted* to integral types as specified in 7.3.7.

12. The three distinct types `float`, `double`, and `long double` can represent floating-point numbers. The type double provides at least as much precision as float, and the type long double provides at least as much precision as double. The set of values of the type float is a subset of the set of values of the type double; the set of values of the type double is a subset of the set of values of the type long double. The types float, double, and long double, and cv-qualified versions (6.8.5) thereof, are collectively termed *standard floating-point types*. An implementation may also provide additional types that represent floating-point values and define them (and cv-qualified versions thereof) to be *extended floating-point types*. The standard and extended floating-point types are collectively termed ***floating-point types***.

    !!! note "additional implementation-specific"

        Any additional implementation-specific types representing floating-point values that are not defined by the implementation to be extended floating-point types are not considered to be floating-point types, and this document imposes no requirements on them or their interactions with floating-point types.

- Except as specified in 6.8.3, the object and value representations and accuracy of operations of floating-point types are implementation-defined.

13. Integral and floating-point types are collectively termed ***arithmetic types***.

    !!! note "Properties of the arithmetic types"

        Properties of the arithmetic types, such as their minimum and maximum representable value, can be queried using the facilities in the standard library headers <limits\> (17.3.3), <climits\> (17.3.6), and <cfloat\> (17.3.7).

14. A type *cv* void is an ==incomplete== type that cannot be completed; such a type has an empty set of values. It is used as the return type for functions that do not return a value. Any expression can be explicitly converted to type *cv* void (7.6.1.4, 7.6.1.9, 7.6.3). An expression of type cv void shall be used only as an expression statement (8.3), as an operand of a comma expression (7.6.20), as a second or third operand of `?:` (7.6.16), as the operand of `typeid`, `noexcept`, or `decltype`, as the expression in a `return` statement (8.7.4) for a function with the return type *cv* void, or as the operand of an explicit conversion to type *cv* void.

15. A value of type `std::nullptr_t` is a null pointer constant (7.3.12). Such values participate in the pointer and the pointer-to-member conversions (7.3.12, 7.3.13). `sizeof(std::nullptr_t)` shall be equal to `sizeof(void*)`.

16. The types described in this subclause are called ***fundamental types***.

    !!! note "same value, different types"

        Even if the implementation defines two or more fundamental types to have the same value representation, they are nevertheless different types.

## 6.8.4 Compound types

[basic.compound]

1. Compound types can be constructed in the following ways:

- `arrays` of objects of a given type, 9.3.4.5;
- `functions`, which have parameters of given types and return void or references or objects of a given type, 9.3.4.6;
- `pointers` to *cv* void or objects or functions (including static members of classes) of a given type, 9.3.4.2;
- `references` to objects or functions of a given type, 9.3.4.3. There are two types of references:

    - lvalue reference
    - rvalue reference

- `classes` containing a sequence of objects of various types (Clause 11), a set of types, enumerations and functions for manipulating these objects (11.4.2), and a set of restrictions on the access to these entities (11.8);
- `unions`, which are classes capable of containing objects of different types at different times, 11.5;
- `enumerations`, which comprise a set of *named* constant values, 9.7.1;
- `pointers` to *non-static class members*, which identify members of a given type within objects of a given class, 9.3.4.4. Pointers to data members and pointers to member functions are collectively called *pointer-to-member* types.

2. These methods of constructing types can be applied recursively; restrictions are mentioned in 9.3.4. Constructing a type such that the number of bytes in its object representation exceeds the maximum value representable in the type `std::size_t` (17.2) is ill-formed.

3. The type of a pointer to *cv* void or a pointer to an object type is called an *object pointer type*.

    !!! note "void*"

        A pointer to void does not have a pointer-to-object type, however, because void is not an object type.

- The type of a pointer that can designate a function is called a *function pointer type*. A pointer to an object of type T is referred to as a ***pointer to T***.

    !!! example "pointer naming"

        A pointer to an object of type int is referred to as “pointer to int” and a pointer to an object of class X is called a “pointer to X”.

- Except for pointers to static members, text referring to “pointers” does not apply to pointers to members. Pointers to ==incomplete== types are allowed although there are restrictions on what can be done with them (6.7.6). Every value of pointer type is one of the following:

    - a pointer *to* an object or function (the pointer is said to point to the object or function), or
    - a pointer *past* the end of an object (7.6.6), or
    - the *null* pointer value for that type, or
    - an *invalid* pointer value.

- A value of a pointer type that is a pointer to or past the end of an object *represents the address* of the first byte in memory (6.7.1) occupied by the object or the first byte in memory after the end of the storage occupied by the object, respectively.

    !!! note "Pointer beyond the end - sentinel"

        A pointer past the end of an object (7.6.6) is not considered to point to an unrelated object of the object’s type, even if the unrelated object is located at that address. A pointer value becomes invalid when the storage it denotes reaches the end of its storage duration; see 6.7.5.

- For purposes of pointer arithmetic (7.6.6) and comparison (7.6.9, 7.6.10), a pointer past the end of the last element of an array x of n elements is considered to be equivalent to a pointer to a hypothetical array element n of x and an object of type T that is not an array element is considered to belong to an array with one element of type T. The value representation of pointer types is implementation-defined. Pointers to layout-compatible types shall have the same value representation and alignment requirements (6.7.6).

    !!! note "Pointers to over-aligned types"

        Pointers to over-aligned types (6.7.6) have no special representation, but their range of valid values is restricted by the extended alignment requirement.

4. Two objects a and b are *pointer-interconvertible* if:

    - they are the same object, or
    - one is a union object and the other is a non-static data member of that object (11.5), or
    - one is a standard-layout class object and the other is the *first* non-static data member of that object or any base class subobject of that object (11.4), or
    - there exists an object c such that a and c are pointer-interconvertible, and c and b are pointer-interconvertible.

- If two objects are pointer-interconvertible, then they have the same address, and it is possible to obtain a pointer to one from a pointer to the other via a `reinterpret_cast` (7.6.1.10).

    !!! note "array != &array[0]"

        An array object and its first element are not pointer-interconvertible, even though they have the same address.

5. A byte of storage b is *reachable through* a pointer value that points to an object x if there is an object y, pointer-interconvertible with x, such that b is within the storage occupied by y, or the immediately-enclosing array object if y is an array element.

6. A pointer to cv void can be used to point to objects of unknown type. Such a pointer shall be able to **hold** any object pointer. An object of type “pointer to cv void” shall have the same representation and alignment requirements as an object of type “pointer to cv char”.

## 6.8.5 CV-qualifiers

[basic.type.qualifier]

1. Each type other than a function or reference type is part of a group of four distinct, but related, types: a `cv-unqualified` version, a `const-qualified` version, a `volatile-qualified` version, and a `const-volatile-qualified` version. The types in each such group shall have the same representation and alignment requirements (6.7.6). A function or reference type is always [cv-unqualified](https://stackoverflow.com/questions/15413037/what-does-cv-unqualified-mean-in-c).

- A `const` object is an object of type const T or a non-mutable subobject of a const object.
- A `volatile` object is an object of type volatile T or a subobject of a volatile object.
- A `const volatile` object is an object of type const volatile T, a non-mutable subobject of a const volatile object, a const subobject of a volatile object, or a non-mutable volatile subobject of a const object.

    !!! note "type invovles cv-qualifiers"

        The type of an object (6.7.2) includes the *cv-qualifiers* specified in the *decl-specifier-seq* (9.2), *declarator* (9.3), *type-id* (9.3.2), or *new-type-id* (7.6.2.8) when the object is created.

2. Except for array types, a compound type (6.8.4) is not cv-qualified by the cv-qualifiers (if any) of the types from which it is compounded.

3. An array type whose elements are cv-qualified is also considered to have the same cv-qualifications as its elements.

    !!! note "Cv-qualifiers"

        Cv-qualifiers applied to an array type attach to the underlying element type, so the notation “cv T”, where T is an array type, refers to an array whose elements are so-qualified (9.3.4.5).

    !!! example "Cv-qualifiers"

        typedef char CA[5];
        typedef const char CC;
        CC arr1[5] = { 0 };
        const CA arr2 = { 0 };

        The type of both arr1 and arr2 is “array of 5 const char”, and the array type is considered to be const-qualified.

4. See 9.3.4.6 and 12.2.2 regarding function types that have cv-qualifiers.

5. There is a partial ordering on cv-qualifiers, so that a type can be said to be *more cv-qualified* than another. Table 16 shows the relations that constitute this ordering.

    Table 16: Relations on const and volatile - [tab:basic.type.qualifier.rel]

    - no cv-qualifier < const
    - no cv-qualifier < volatile
    - no cv-qualifier < const volatile
    - const < const volatile
    - volatile < const volatile

6. In this document, the notation *cv* (or *cv1*, *cv2*, etc.), used in the description of types, represents an arbitrary set of cv-qualifiers, i.e., one of {`const`}, {`volatile`}, {`const`, `volatile`}, or the empty set. For a type cv T, the *top-level cv-qualifiers* of that type are those denoted by cv.

    !!! example "top-level cv-qualifiers"

        The type corresponding to the type-id `const int&` has no top-level cv-qualifiers. The type corresponding to the type-id `volatile int * const` has the top-level cv-qualifier const. For a class type C, the type corresponding to the type-id `void (C::* volatile)(int) const` has the top-level cv-qualifier volatile.
