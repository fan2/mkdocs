---
title: C Pointers and Arrays
authors:
  - xman
date:
    created: 2023-10-05T10:00:00
categories:
    - c
comments: true
---

Many beginners don't know about the relationship between pointers and arrays. I'll tell you now: there is no relationship between them, they just often wear similar clothes to tease you. A pointer is a pointer. A pointer variable occupies 4 bytes in a 32-bit system and 8 bytes in a 64-bit system. Its value is the address of a particular memory location. A pointer can point to anything, but can you access anything using this pointer variable?

An array is an array, and its size is related to the type and number of its elements; when defining an array, the type and number of its elements must be specified; an array can hold any kind of data, but not functions. Since there is no relationship between them, why do many people often confuse arrays with pointers, and even think that pointers and arrays are the same?

This is related to the mixed C language reference books on the market. Few books explain this topic thoroughly and clearly. Let's go back to the classics, back to the basics, and get the truth from the classic explanations and interpretations of the masters.

<!-- more -->

Previously, at the end of [Register file of ARM64](../arm/a64-regs.md), we specially mentioned dedicated pointers in armasm, such as `SP`(Stack Pointer) and `FP`(Frame Pointer). See [ARM Push/Pop Stack Modes](../arm/arm-stack-modes.md), if we take the stack frame as an array occupying the memory area bounded by the half-open internal $[T.limit, T.base)$. The stack pointer(`SP`) point to the top of the current stack frame, walking between the ad-hoc memory area with offset. Check the previous post [C Pointer Explanation in armasm](./c-pointer-armasm.md) against the stack layout of the demo program.

## Pointers and Arrays

[TCPL](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/) | Chapter 5 - Pointers and Arrays - 5.3 Pointers and Arrays; 5.4 Address Arithmetic

In C, there is a strong relationship between pointers and arrays, strong enough that pointers and arrays should be discussed simultaneously. Any operation that can be achieved by array subscripting can also be done with pointers. The pointer version will in general be faster but, at least to the uninitiated, somewhat harder to understand.

The declaration **`int a[10];`** defines an array of size 10, that is, a block of 10 consecutive objects named `a[0]`, `a[1]`, ..., `a[9]`.

```text
    ---------------------------------------------------
    |    |    |    |    |    |    |    |    |    |    |
    ---------------------------------------------------
     a[0] a[1] a[2] a[3] a[4] a[5] a[6] a[7] a[8] a[9]
```

The notation `a[i]` refers to the $i^{th}$ element of the array. If `pa` is a pointer to an integer, declared as **`int *pa;`** then the assignment **`pa = &a[0];`** sets `pa` to point to element zero of `a`; that is, `pa` contains the address of `a[0]`.

```text
     +-----------+
     ↑           ↓
  ------------------------------------------------------------------------
  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
  ------------------------------------------------------------------------
    pa            a[0] a[1] a[2] a[3] a[4] a[5] a[6] a[7] a[8] a[9]
```

Now the assignment **`x = *pa;`** will copy the contents of `a[0]` into `x`.

If `pa` points to a particular element of an array, then by definition `pa+1` points to the *next* element, `pa+i` points *i* elements after `pa`, and `pa-i` points *i* elements before. Thus, if `pa` points to `a[0]`, **`*(pa+1)`** refers to the contents of `a[1]`, `pa+i` is the address of `a[i]`, and `*(pa+i)` is the contents of `a[i]`.

```text
                     pa+1 pa+2
     +-----------+    |    |
     ↑           ↓    ↓    ↓
  ------------------------------------------------------------------------
  |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
  ------------------------------------------------------------------------
    pa            a[0] a[1] a[2] a[3] a[4] a[5] a[6] a[7] a[8] a[9]
```

These remarks are true regardless of the type or size of the variables in the array `a`. The meaning of "adding 1 to a pointer," and by extension, all pointer arithmetic, is that `pa+1` points to the *next* object, and `pa+i` points to the $i^{th}$ object beyond `pa`.

!!! note "step size of pointer movement"

    The number *`i`* in `pa+i` represents the number of the element. For example, `pa+1` moves the cursor *one* step forward, pointing to the next element. This means `i` is scaled according to the size of the object `pa` points to, which is determined by the declaration of `pa`. The step size here is `sizeof(int)=4` bytes, not a single byte.

    **Question time**: Think about `a+1`, what does `1` mean? Where would `a+1` go? Take the question with you, read on to find out.

The correspondence between indexing and pointer arithmetic is very close. By definition, the value of a variable or expression of type array is the address of element zero of the array. Thus after the assignment **`pa = &a[0];`** `pa` and `a` have *identical* values. Since the *name* of an array is a synonym for the *location* of the initial element, the assignment `pa=&a[0]` can also be written as **`pa = a;`**.

Rather more surprising, at first sight, is the fact that a reference to `a[i]` can also be written as `*(a+i)`. In evaluating `a[i]`, C converts it to `*(a+i)` immediately; the two forms are equivalent. Applying the operator `&` to both parts of this equivalence, it follows that `&a[i]` and `a+i` are also identical: `a+i` is the address of the $i^{th}$ element beyond `a`. As the other side of this coin, if `pa` is a pointer, expressions might use it with a subscript; `pa[i]` is identical to `*(pa+i)`. In short, an *array-and-index* expression is equivalent to one written as a *pointer and offset*.

There is one difference between an *array name* and a pointer that must be kept in mind. A pointer is a variable, so `pa=a` and `pa++` are legal. But an array name is *not* a variable (but a const pointer); constructions like `a=pa` and `a++` are illegal.

When an array name is passed to a function, what is passed is the *location* of the initial element. Within the called function, this argument is a local variable, and so an *array name* parameter is a *pointer*, that is, a variable containing an address. We can use this fact to write another version of `strlen`, which computes the length of a string.

```c
/* strlen: return length of string s */
int strlen(char *s) {
    int n;
    for (n = 0; *s != '\0', s++)
        n++;
    return n;
}
```

Since `s` is a pointer, incrementing it is perfectly legal; `s++` has no effect on the character string in the function that called `strlen`, but merely increments `strlen`'s private copy of the pointer. That means that calls like the following all work.

```c
strlen("hello, world"); /* string constant */
strlen(array);          /* char array[100]; */
strlen(ptr);            /* char *ptr; */
```

As formal parameters in a function definition, **`char s[];`** and **`char *s;`** are equivalent; we prefer the latter because it says more explicitly that the variable is a pointer. When an array name is passed to a function, the function can at its convenience believe that it has been handed either an array or a pointer, and manipulate it accordingly. It can even use both notations if it seems appropriate and clear.

Consider the following two versions of the function definition, if the array could be passed into the function, `i` should return 10 in the first version. In fact, the formal array size makes no sense and could be ignored and simplified as `a[]`, and further decays to a pointer. This means that the actual array size passed has nothing to do with the array size specified by the formal parameter. `i` would return pointer width in both cases. Therefore, the latter is more in line with the actual situation and is preferable.

=== "formal parameter with array"

    ```c
    void fun(char a[10])
    {
        int i = sizeof(a);
        printf("i = %zu\n", i);
        // ...
    }
    ```

=== "formal parameter with pointer"

    ```c
    void fun(char *a, size_t l)
    {
        int i = sizeof(a);
        printf("i = %zu\n", i);
        // ...
    }
    ```

It is possible to pass *part* of an array to a function, by passing a pointer to the beginning of the subarray. For example, if a is an array, **`f(&a[2])`** and **`f(a+2)`** both pass to the function `f` the address of the subarray that starts at `a[2]`. Within `f`, the parameter declaration can read **`f(int arr[]) { ... }`** or **`f(int *arr) { ... }`**. So as far as `f` is concerned, the fact that the parameter refers to part of a larger array is of no consequence.

If one is sure that the elements exist, it is also possible to index backwards in an array; `p[-1]`, `p[-2]`, and so on are syntactically legal, and refer to the elements that immediately precede `p[0]`. Of course, it is illegal to refer to objects that are not within the array bounds.

```text

          Lbound                  pa   pa+1 pa+2           pa+5
         /                        |    |    |              |
         |                        ↓    ↓    ↓              ↓
   ---------------------------------------------------------------
   |  ⚡️  |    |    |    |    |    |    |    |    |    |    |  ⚡️  |
   ---------------------------------------------------------------
          a[0] a[1] a[2] a[3] a[4] a[5] a[6] a[7] a[8] a[9] \
    ↑                    ↑    ↑                              |
    pa-6                 pa-2 pa-1                           Rbound
```

## array-to-pointer decay

[Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/) | 11 Pointers - 11.3 Pointers and arrays

**11.3.1 Array and pointer access are the same**

> TAKEAWAY 11.16: `A[i]` and `*(A+i)` are equivalent regardless of whether `A` is an array or a pointer.

If `A` is a pointer, we understand the second expression. Here, it just says that we may write the same expression as `A[i]`. Applying this notion of array access to pointers should improve the readability of your code. The equivalence does not mean that all of the sudden an array object appears where there was none. If `A` is null, `A[i]` should crash nicely, as should `*(A+i)`.

If `A` is an array, `*(A+i)` shows our first application of one of the most important rules in C, called ***array-to-pointer decay***:

> TAKEAWAY 11.17 (array decay): Evaluation of an array `A` returns `&A[0]`.

In fact, this is the reason there are no "array values" and all the difficulties they entail. Whenever an array occurs that requires a value, it **decays** to a pointer, and we lose all additional information.

> TAKEAWAY 6.3: There are array objects but no array values.
> TAKEAWAY 6.5: Arrays can't be assigned to.

**11.3.2 Array and pointer parameters are the same**

Because of the decay, arrays *cannot* be function arguments. There would be no way to call such a function with an array parameter; before any call to the function, an array that we feed into it would **decay** into a pointer, and thus the argument type wouldn't match.

But we have seen declarations of functions with array parameters, so how did they work?

The trick C gets away with is to **rewrite** array parameters to pointers.

> TAKEAWAY 11.18: In a function declaration, any array parameter rewrites to a pointer.

Think of this and what it means for a while. Understanding this "chief feature" (or character flaw) is central for coding easily in C.

To come back to our examples from section 6.1.5, the functions that were written with array parameters could be declared as follows:

```c
size_t strlen(char const* s);
char * strcpy(char* target, char const* source);
signed strcmp(char const* s0, char const* s1);
```

These are completely equivalent, and any C compiler should be able to use both forms interchangeably.

Which one to use is a question of habit, culture, or other social contexts. The rule that we follow in this book to use array notation if we suppose it *can't* be null, and pointer notation if it corresponds to a single item of the base type that *also* can be null to indicate a special condition.

## distinguish &a[0] and &a

[dissection_c](https://blog.csdn.net/dissection_c) - [《C语言深度解剖（第3版）》](https://item.jd.com/12720594.html) | 第 4 章 指针和数组

When we define an array `a`, the compiler allocates a block of memory of a certain size (element type size * number of elements) according to the specified number of elements and element type, and names this block of memory `a`.

Once the name `a` occupies this block of memory, it cannot be changed. `a[0]`, `a[1]`, etc. are elements of `a`, but they are not the names of the elements. Each element of the array has no name.

What is the difference between `&a[0]` and `&a`?

`a[0]` is an element, `a` is the whole array. Although `&a[0]` and `&a` have the same value, they have different meanings. The former is the first address of the first element of the array, while the latter is the first address of the array.

Think of `a` as Kwangtung Province, `a[0]` could stand for Canton, which is the capital of Kwangtung. The provincial government of Kwangtung resides in Canton, and the city government of Canton is also located in Canton. Both governments are in Canton, but their meanings are completely different. They have different administrative levels and different jurisdictions.

Usually we can assign a pointer to point to the first element of an array like this `int *pa = &a[0];`, but `int *pa = &a;` will receive a `-Wincompatible-pointer-types` warning: initialization of `int *` from incompatible pointer type `int (*)[10]`. Anyhow, city government is not the counterpart of province government.

!!! note ""

    Going back to the leftover question in Part One, `pa+1`(i.e. `a[1]`) could refer to Canton's sister city, e.g. Shenzhen or Zhuhai, while `a+1` could refer to Kwangtung's neighbouring province, e.g. Guangxi or Fujian.

## array name as lvalue or rvalue

What does `a` mean when used as an rvalue?

Many books assume that it means the first address of the array, but this is actually very wrong. When `a` is used as an rvalue, its meaning is the same as `&a[0]`, which represents the first address of the first element of the array, not the first address of the array (when used in the expression `sizof(a)`, `a` represents the array name, not used as an rvalue). They are two different things. But note that this is just a representation, and there is *no* place (this is just a simple assumption, and its specific implementation details will not be discussed too much) to store this address, i.e. the compiler does not allocate a piece of memory for the array `a` to store its address, which is very different from a pointer.

Now that we know the meaning of `a` as an rvalue, what about as an lvalue?

`a` cannot be an lvalue! Almost every student has made this mistake. The compiler will think that the array name as lvalue means the first address of the first element of `a`, but the memory starting from that address is a whole. We can only access a particular element of the array, not the array as a whole. So we can treat `a[i]` as an lvalue, but we cannot treat `a` as an lvalue. In fact, we can treat `a` as an ordinary variable, but this variable is divided into many small blocks, and we can *only* access the whole variable a by accessing these small blocks separately.

## test programs about pointers

### sizeof pointer

On the A32/*ILP32* data model, all pointers are 4 bytes long, that's what `P32` means, whereas on the A64/*LP64* data model, all pointers are 8 bytes long, that's what `P64` means. See [Machine Word](../cs/machine-word.md) for more details about `__SIZEOF_POINTER__` and `__WORDSIZE` and print `sizeof(void*)` to check.

`sizeof` is a keyword, not a function. Functions are evaluated at run time, while the keyword `sizeof` is evaluated at compile time.

```c title="sizeof-pointer.c"
#include <stdio.h>

int main(int argc, char* argv[]) {
    char c = 'c';
    short s = 2048;
    int i = 19890604;
    long l = 0xFEEDBABEDEADBEEF;
    int a[10] = {0,1,2,3,4,5,6,7,8,9};

    char *pc = &c;
    short *ps = &s;
    int *pi = &i;
    long *pl = &l;
    // int *pa = &a; // -Wincompatible-pointer-types
    int *pa = &a[0];

    printf("sizeof(void*) = %zu\n", sizeof(void*));
    printf("sizeof(pc) = %zu, sizeof(*pc) = %zu\n", sizeof(pc), sizeof(*pc));
    printf("sizeof(ps) = %zu, sizeof(*ps) = %zu\n", sizeof(ps), sizeof(*ps));
    printf("sizeof(pi) = %zu, sizeof(*pi) = %zu\n", sizeof(pi), sizeof(*pi));
    printf("sizeof(pl) = %zu, sizeof(*pl) = %zu\n", sizeof(pl), sizeof(*pl));
    printf("sizeof(a) = %zu, sizeof(pa) = %zu\n", sizeof(a), sizeof(pa));
    printf("sizeof(*pa) = %zu, sizeof(a[10]) = %zu\n", sizeof(*pa), sizeof(a[10]));

    return 0;
}
```

On rpi4b-ubuntu/aarch64 and the LP64 data model, the result is as follows.

```bash
$ cc sizeof-pointer.c -o sizeof-pointer && ./sizeof-pointer
sizeof(void*) = 8
sizeof(pc) = 8, sizeof(*pc) = 1
sizeof(ps) = 8, sizeof(*ps) = 2
sizeof(pi) = 8, sizeof(*pi) = 4
sizeof(pl) = 8, sizeof(*pl) = 8
sizeof(a) = 40, sizeof(pa) = 8
sizeof(*pa) = 4, sizeof(a[10]) = 4
```

Although the element `a[10]` does not exist(out of boundary), `a[10]` is not actually accessed here. Instead, its size is determined based on the type of the array element.

### pointer arithmetic

Finally, I designed a comprehensive test case as a quiz to measure learning outcomes based on the topics of this article.

```c title="array-pointer.c" linenums="1" 
#include <stdio.h>
#include <stdint.h> // uintptr_t

int main(int argc, char *argv[]) {
    int a[5] = { 1, 2, 3, 4, 5 };
    printf("%p, %p, %p\n", a, &a, &a[0]); // same
    printf("%p, %p, %p\n", a+1, &a+1, &a[0]+1);

    int *p1 = (int *)(&a+1);
    int *p2 = (int *)(a+1); // (int *)(&a[0]+1);
    printf("%#x, 0x%02x\n", p1[-1], *p2);

    // little endian
    int *p3 = (int *)((uintptr_t)a+1);
    printf("%p = 0x%0*x: ", p3, 8, *p3);

    // dump *p3 byte by byte
    for (int i=0; i<sizeof(int); i++) {
        printf("%02x ", *((unsigned char*)p3+i));
    }
    printf("\n");

    return 0;
}
```

- line 6: `&a` is type of array pointer `int (*)[5]`, so p1=`&a+1` points to the next array.
- line 7: `(int *)(a+1)` equiv to `(int *)(&a[0]+1)`, so p2 points to the second element `a[1]`. Check against output of line 9.
- line 13: The address of the array `&a` is forced to be cast to an integer, then add 1, so that p3 points to the second byte of `a[0]`.

On rpi4b-ubuntu/aarch64 and the LP64 data model, the result is as follows.

```bash
$ cc array-pointer.c -o array-pointer -g && ./array-pointer
0xfffff0b59c00, 0xfffff0b59c00, 0xfffff0b59c00
0xfffff0b59c04, 0xfffff0b59c14, 0xfffff0b59c04
0x5, 0x02
0xfffff0b59c01 = 0x02000000: 00 00 00 02
```

The following ascii graph illustrates the position and layout of array and pointers.

```text
             p3             p2                                                                       p1
             |              |                                                                        |
             ↓              ↓                                                                        ↓
------------------------------------------------------------------------------------------------------------
|  ⚡️  | \x01\x00\x00\x00 | \x02\x00\x00\x00 | \x03\x00\x00\x00 | \x04\x00\x00\x00 | \x05\x00\x00\x00 |  ⚡️  |
------------------------------------------------------------------------------------------------------------
      a[0]               a[1]               a[2]               a[3]               a[4]
```

Note that `p3` is a misaligned address, dereferencing `*p3` as an integer will combine the last three bytes of `a[0]` and the first byte of `a[1]`. It is only an artificially constructed test case and is not practical.

---

Follow the [C Pointer Explanation in armasm](./c-pointer-armasm.md), disassemble the binary ELF `array-pointer` and draw the stack layout to understand it from the ground up.

First dump contents of section `.rodata` to see the format literals of `printf`.

```bash
$ objdump -j .rodata -s array-pointer # or
$ rabin2 -z array-pointer
```

Then execute `objdump --disassemble=main --source-comment -l array-pointer` to disassemble the binary ELF statically. To debug dynamically, use [GDB-pwndbg](../toolchain/gdb/7-gdb-enhanced.md) `gdb-pwndbg array-pointer` or [radare2](../toolchain/radare2-basics.md) `r2 -Ad array-pointer`.

The stack layout(ascii graph) and illustration are as follows.

1. StackGuard in prolog/epilog, see [ARM StackGuard - Stack Canary](../arm/arm-stack-guard.md)
2. stack size = 0x60/96, it can accommodate 12 double(giant)-word
3. sizeof(a[n])=4, sizeof(p1|p2|p3)=8, corresponds to word/double-word
4. int array `a[5]` ranges from 0x40\~0x50, with right boundary 0x54
5. `int *p1` points to `a[5]`; `int *p2` points to `a[1]`
6. the loop variable `int i` resides in 0x20, occupy a 4-byte word
7. use instruction `LDRB` to load register byte per loop

```text
                  stack
high addr       +-----------+
    ↓           |  canary   | 🐦‍⬛
            /   |-----------|+0x58
            |   |a[4] |     | ←-----------+
            |   |-----------|+0x50        |
      a[5] <    |a[2] | a[3]|             |
            |   |-----------|+0x48        |
            |   |a[0] | a[1]| ←-------+   |
            \   |-----------|+0x40    |   |
                |  sp+0x41  |         |   |
          p3 -→ |-----------|+0x38    |   |
                |  sp+0x44  | --------+   |
          p2 -→ |-----------|+0x30        |
                |  sp+0x54  | ------------+
          p1 -→ |-----------|+0x28
                |  i  |     |
                |-----------|+0x20
                |     | w0  |
                |-----------|+0x18
                |    x1     |
                |-----------|+0x10
                |    LR     |
                |-----------|+0x8
                |    P_FP   |
        SP/FP → +-----------+
```
