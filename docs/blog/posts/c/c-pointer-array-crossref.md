---
title: C Pointer and Array Cross Reference with Mismatched Type
authors:
  - xman
date:
    created: 2023-10-07T10:00:00
categories:
    - c
comments: true
---

So far, we've discussed [C Pointers and Arrays](./c-pointer-array.md), [C Character Pointer and String Manipulation](./c-pointer-string.md). There are very confusingly named concepts and it's very easy to get them mixed up.

In this article, we'll see what happens when an external reference is declared with the wrong but compatible type. There are two cases involved, refer array as pointer and opposite.

<!-- more -->

## Ref array as pointer

Suppose the character array is defined in file 1 as follows:

```c
char a[100];
```

The external variable declaration referenced in file 2 is as follows:

```c
extern char *a;
```

Here, array `a` is defined in file 1, and it is declared as a pointer in file 2. Is there anything wrong with this? Isn't it often said that pointers and arrays are similar, and can even be used interchangeably? But, unfortunately, this is wrong. You may still remember what I said [previously](./c-pointer-array.md): arrays are arrays, and pointers are pointers. They are two completely different things! There is no relationship between them, but they are often dressed in similar clothes to confuse you. Let's try to analyze this problem.

At the beginning of Chapter 1, I emphasized the difference between definitions and declarations. Definitions allocate memory, while declarations do not. Definitions can only appear once, while declarations can appear multiple times. Here, `extern` promises the compiler that the name `a` has been defined in another file. The name `a` used in the following code is defined in another file. Looking back at the discussion of lvalues ​​and rvalues ​​in the previous article, we know that if the compiler needs an address (and possibly an offset) to perform an operation, it can directly read or write the memory at this address by unlocking it (using the key `*`), without having to first find the place where the address is stored. On the contrary, for a pointer, you must first find the place where the address is stored, take out the address value, and then unlock the address (still using the key `*`).

This is why `extern char a[]` is equivalent to `extern char a[100]`. Because it is just a declaration and no space is allocated, the compiler does not need to know how many elements the array has. Both declarations tell the compiler that `a` is an array defined in another file, and `a` also represents the address of the first element of the array, that is, the starting address of this memory block. The addresses of other elements in the array can be expressed in the form of base address + offset.

However, when you declare it as `extern char *a`, the compiler naturally thinks that `a` is a pointer variable, which occupies 4/8 bytes in 32/64-bit systems respectively. These 4/8 bytes store an address, and the character type data is stored at this address. Although in file 1, the compiler knows that a is an array, but in file 2, the compiler does not know this. Most compilers use files as translation units, and the compiler only processes according to the types declared in this file. Therefore, although the actual size of a is 100 bytes, in file 2, the compiler thinks that a only occupies 4/8 bytes.

We know that the compiler will treat any data stored in a pointer variable as an address. Therefore, if we need to access these character type data, we must first get the address stored in the pointer variable `a`.

Assume that the original array `a` stores 100 characters, e.g. {'B', 'A', 'A', 'D', 'D', 'A', 'A', 'D', 'F', 'E', 'E', 'D', 'B', 'A', 'B', 'E', ...}. Under x86_64/AArch64 platforms, the compiler will only see the first 8 bytes (the binary encoding of the ASCII characters).

```bash
$ echo "BAADDAAD" | xxd
00000000: 4241 4144 4441 4144 0a                   BAADDAAD.
```

The compiler takes out the first 8 bytes (the ASCII code of the character) at once according to the `uintptr_t` type and obtains `0x4441414444414142` in little-endian order, which may not be a valid address and is not expected even if it is valid.

## Ref pointer as array

Obviously, according to the above analysis, if we declare the array defined in file 1 as a pointer in file 2, an error will occur. Similarly, if it is defined as a pointer in file 1 and declared as an array in file 2, an error will also occur.

Suppose the character pointer is defined in file 1 as follows:

```c
char *p = "abcdefg";
```

The external char array declaration referenced in file 2 is as follows:

```c
extern char p[];
```

In file 1, the compiler allocates 4/8 bytes of space and names it `p`; at the same time, `p` stores the address of the first character of the string constant `"abcdefg"`; this constant string literal itself is stored in the static area of ​​memory(probably .rodata section), and its content cannot be changed. In file 2, the compiler considers `p` to be an array with a size of 4/8 bytes, and the array stores data of type char.

In file 2, the *pointer-to-array* promotion (as opposed to the *array-to-pointer decay* rule) is applied to the variable-length array. The block of memory (with pointer width) to which `p` is bound is treated as an array. For a convenient mnemonic, we note it as `_p`, which satisfies the following facts: `_p = &p` and `*_p = p`.

Suppose on AArch64, its address is 0xaaaab4461078, corresponding to atomic bytearray {0x78, 0x10, 0x46, 0xb4, 0xaa, 0xaa, 0x00, 0x00}. In file 2, the compiler treats the value (address) of the pointer variable `p` as an array of 8 char types, and dereferences the bytes in sequence according to the char/byte type. These are not all valid characters, nor are they the addresses of the memory blocks we want. If `p[i]`(actually `_p[i]`) is assigned a value (i ∈ [0,7]), the legal address originally saved in `p` will be destroyed, making it impossible to find the memory it originally pointed to, and even causing an illegal memory access exception.

## test programs

Based on the analysis above, we can design a comprehensive test program.

In file 1(crossdef.c), we define char array and pointer to string literal. function `disclose_a()` outputs pointer `a` and dereference the first character/byte, function `disclose_p()` does the same thing.

```c title="array-pointer-crossdef.c"
#include <stdio.h>

char a[100] = {'B', 'A', 'A', 'D', 'D', 'A', 'A', 'D', 'F', 'E', 'E', 'D', 'B', 'A', 'B', 'E'};
char *p = "abcdefg";

void disclose_a() {
    printf("a = %p, *a = (%c, %#x)\n", a, *a, *a);
}

void disclose_p() {
    printf("p = %p, *p = (%c, %#x)\n", p, *p, *p);
}
```

File 2(crossref.c) contains the main routine, it declares external references to `a` and `p` defined in file 1, but with a deliberately mismatched prototype.

```c title="array-pointer-crossref.c"
#include <stdio.h>
#include <stdint.h> // uintptr_t

extern char *a;
extern char p[];

extern void disclose_a();
extern void disclose_p();

void ref_array_as_pointer() {
    disclose_a();
    printf("a = %p\n", a);
    printf("*a = %#x", *a);

    // for (int i=0; i<8; i++) {
    //     printf("a[%d] = %#x\n", i, a[i]);
    // }
}

void ref_pointer_as_array() {
    disclose_p();
    printf("p = %p\n", p);
    printf("*p = %#x\n", *p);

    // for (int i=0; i<8; i++) {
    //     printf("p[%d] = %#x\n", i, p[i]);
    // }
}

int main(int argc, char* argv[]) {
    int c;
    printf("input 'a' or 'p' to choose test case: ");

    while ((c=getchar()) != EOF) {
        if (c == 'a') {
            ref_array_as_pointer();
            break;
        } else if (c == 'p') {
            ref_pointer_as_array();
            break;
        }
    }

    return 0;
}
```

Run the following command to compile the C program.

```bash
$ cc array-pointer-crossdef.c array-pointer-crossref.c -o array-pointer-crossref
```

Run the binary ELF and input `a` according to the tips.

```bash
$ ./array-pointer-crossref
input 'a' or 'p' to choose test case: a
a = 0xaaaad26f1010, *a = (B, 0x42)
a = 0x4441414444414142
[1]    21745 segmentation fault (core dumped)  ./array-pointer-crossref
```

The following ascii graph illustrates the address and layout of array `a`.

```text
0xaaaad26f1010                        a
      |   +---------------------------^----------------------------+
       \ /                                                          \
  --------------------------------------------------------------------------
     ⚡️  | 'B' | 'A' | 'A' | 'D' | 'D' | 'A' | 'A' | 'D' | ... | xxx | ⚡️
  --------------------------------------------------------------------------
         a[0]  a[1]  a[2]  a[3]  a[4]  a[5]  a[6]  a[7]   ...  a[99]
```

!!! note "Cross reference array as pointer"

    In fact, the actual type of `a` is `char[100]`. There is a forced typecast in file 2(crossref.c). When `a` is treated as a normal pointer, it takes whatever it contains as an address. Since the pointer width(`__SIZEOF_POINTER__`)=8 in AArch64, it will group the first 8 characters/bytes as a unit, forming the address 0x4441414444414142.

    However, accessing the illegal address will throw a *`segmentation fault`* exception.

Run the binary ELF again and input `p`:

```bash
$ ./array-pointer-crossref
input 'a' or 'p' to choose test case: p
p = 0xaaaacee309b0, *p = (a, 0x61)
p = 0xaaaacee41078
*p = 0xb0
```

Type `rax2 -x 0xaaaacee309b0` to output in hexpairs or `rax2 -c 0xaaaacee309b0` to output in C string.

The following ascii graph illustrates the address and layout of literal string (character array `a`) and pointer `p`.

```text
                                                     a
            +-------------------+  +-----------------^-----------------+
            ↑                   ↓ /                                      \
    +--------------+      -----------------------------------------------------
    |0xaaaacee309b0|         ⚡️  | 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | ⚡️
    +--------------+      -----------------------------------------------------
    p                          / a[0]  a[1]  a[2]  a[3]  a[4]  a[5]  a[6]
   _p=0xaaaacee41078     0xaaaacee309b0
```

!!! note "Cross reference pointer as array"

    The pointer variable `p` is at `0xaaaacee41078`, when treated as an array, its content `0xaaaacee309b0` (the address of the string literal) is split as a character array. According to the latent implication of the array name, when used as rvalue, it returns the address of the first element, which is `0xaaaacee41078`. So `*p` will dereference the first character/byte and return `0xb0` under LSB(Least Significant Byte comes first).

    Here it's all about `p`, nothing to do with `a`.

The content of this article may be a bit confusing and brain-bending, but if you understand it thoroughly, you will really get to grips with the concepts and essence of arrays and pointers. At least, that's how it feels to me. I hope it helps you a little.

---

The subject content of this article is referenced from the classic [《C语言深度解剖（第3版）》](https://item.jd.com/12720594.html) | 第 4 章 指针和数组 - 4.3 指针和数组之间的恩恩怨怨 - 4.3.3 指针和数组的定义与声明.

Sincere thanks to the original author!
