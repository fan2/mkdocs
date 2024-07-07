---
title: const qualifier in C
authors:
  - xman
date:
    created: 2023-10-09T10:00:00
categories:
    - c
comments: true
---

`const` is the abbreviation for "constant". Unfortunately, because of this, many people think that the value qualified by `const` is a constant. This is not correct. More accurately, it should be a *read-only* variable whose value cannot be used at compile time because the compiler does not know its stored content at compile time. Perhaps this keyword should have been replaced by *readonly*. So what is the use and meaning of this keyword?

The original purpose of `const` was to replace precompiled instructions, eliminating their shortcomings and inheriting their advantages. Let's see the difference between it and the `#define` macro.

In C, the `const` keyword should probably be replaced with *readonly*.

<!-- more -->

## qualify read-only var for immutability

General variables are read-only variables of simple types. When defining such read-only variables, the `const` qualifier can be used before or after the type specifier. For example:

`int const i = 2;` or `const int i = 2;`

To define or declare a read-only array, you can use the following format:

`int const a[5] = {1, 2, 3, 4, 5};` or `const int a[5] = {1, 2, 3, 4, 5}`

Look at the following example and think about it: is this way of writing correct?

```c
const int Max = 100;
int Array[Max];
```

Please create a `const.c` file and a `const.cpp` file and test them.

You will notice that `gcc` will give an error when compiling the `const.c` file, while `g++` will compile the `const.cpp` file just fine. Why is this?

> `gcc pointer-demo.c` reports error: variable-sized object may not be initialized.

We know that when defining an array, the number of elements must be specified. This also indirectly proves that in the C language, Max qualified by `const` is still a *variable*, but it is only a read-only attribute; in C++, the meaning of const is extended, which will not be discussed here due to space limitations.

Note: const-qualified read-only variables must be initialized at the same time as they are defined. Think about why?

One question remains: Can a `case` statement be followed by a const-qualified read-only variable? Please test it yourself.

## avoid unnecessary allocation

The compiler usually does not allocate memory for ordinary `const` read-only variables, but stores them in the symbol table, which makes them a compile-time value without storage and memory read operations, making them very efficient. For example:

```c
#define M 3         // macro
const int N = 5;    // At this time, N is not put into memory
//...
int i = N;          // Allocate memory for N at this time, and no more again
int I = M;          // Macro replacement and memory allocation during precompilation
int j = N;          // No more memory allocation
int J = M;          // Perform macro replacement and allocate memory again
```

From an assembler point of view, the read-only variable defined by `const` only returns the corresponding memory address, rather than an immediate value like `#define`. Therefore, the read-only variable defined by `const` has only *one* backup during program execution (because it is a global read-only variable stored in the *static* area), while the macro constant defined by `#define` has *several* backups in memory. The `#define` macro is replaced in the pre-compile stage, while the read-only variable qualified by `const` has its value determined at compile time. The `#define` macro has no type, while the read-only variable qualified by `const` has a specific type.

## qualify pointer and target

```c
const int *p;           // p is mutable, the object pointed to by p is immutable
int const *p;           // p is mutable, the object pointed to by p is immutable
int* const p;          // p is immutable, the object pointed to by p is mutable
const int * const p;    // both p and the object it points to are immutable
```

Here is a method to remember and understand: ignore the type name first (the compiler also ignores the type name when parsing), and see which one `const` is closest to. "Whoever is close to the water gets the moon first", so it qualifies whatever it is close to.

- const ~~int~~ \*p; : const qualifies `*p`, the object `p` points to is immutable
- ~~int~~ const \*p; : const qualifies `*p` ditto
- ~~int~~\* const p; : const qualifies `p`，`p` is immutable
- const ~~int~~ \* const p; : the first qualifies `*p`, the latter `p`, both immutable

***Summary***: The `const` to the right of the asterisk qualifies the pointer *variable*, and the const to the left of the asterisk qualifies the *location* to which the pointer is pointing.

## qualify function

The const qualifier can also be used to qualify function parameters when you do not want the parameter value to be accidentally changed within the function body. For example:

```c
void Fun (const int *p);
```

It explicitly tells the compiler that `*p` cannot be changed in the function body, thus preventing some unintentional or erroneous changes by the user.

Here are some typical function parameters qualified by `const` in the standard library.

[<stdio.h\> - File input/output](https://en.cppreference.com/w/c/io)

```c
int puts( const char* str );
int printf( const char* format, ... );
```

[<string.h\> - Null-terminated byte strings](https://en.cppreference.com/w/c/string/byte)

```c
size_t strlen( const char* str );
char *strcpy( char *dest, const char *src );
char *strstr( const char *str, const char *substr );
```

---

In addition, the `const` qualifier can also be used to qualify the return value of a function, indicating that the return value cannot be changed. For example:

```c
const int Fun (void);
```

To reference a `const` read-only variable in another linked file:

```c
extern const int i;     // right
extern const int j=10;  // wrong, the read-only variable cannot be changed
```

Are we done with what we have covered so far? Far from it. In C++, `const` has been extended, and there is still a lot of knowledge that has not been covered. If you are interested, you should look up the relevant information and study it.

---

The subject content of this article is referenced from the classic [《C语言深度解剖（第3版）》](https://item.jd.com/12720594.html) | 第1章 关键字 - 1.13 const关键字也许该被替换为readonly

Sincere thanks to the original author!
