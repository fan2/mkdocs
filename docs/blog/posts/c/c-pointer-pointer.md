---
title: C Double Pointer(Pointer-to-Pointer)
authors:
  - xman
date:
    created: 2023-10-12T10:00:00
categories:
    - c
comments: true
---

Since pointers are variables themselves, they can be stored in *arrays* just as other variables can.

The pointer to a pointer in C is used when we want to store the address of another pointer.

<!-- more -->

## Pointer Arrays

[TCPL](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/) | Chapter 5 - Pointers and Arrays - 5.6 Pointer Arrays; Pointers to Pointers

Let us illustrate by writing a program that will sort a set of text lines into alphabetic order, a stripped-down version of the UNIX program `sort`.

The same algorithms will work, except that now we have to deal with *lines* of text, which are of different lengths, and which, unlike integers, can't be compared or moved in a *single* operation. We need a data representation that will cope efficiently and conveniently with *variable-length* text lines.

This is where the array of pointers enters. If the lines to be sorted are stored end-to-end in one long character array, then each line can be accessed by a pointer to its first character. The pointers themselves can be stored in an array. Two lines can be compared by passing their pointers to strcmp. When two out-of-order lines have to be exchanged, the pointers in the pointer array are exchanged, not the text lines themselves.

```text
    +-----+      +--------+           +-----+               +--------+
    |  ⌾  | -->  |defghi\0|           |  ①  | ----   --②->  |defghi\0|
    +-----+      +-------------+      +-----+     \ /       +-------------+
    |  ⌾  | -->  |jklmnopqrst\0|      |  ②  | ---/ \ --③->  |jklmnopqrst\0|
    +-----+      +-------------+      +-----+      /\       +-------------+
    |  ⌾  | -->  |abc\0|              |  ③  | ----/  --①->  |abc\0|
    +-----+      +-----+              +-----+               +-----+
```

This eliminates the twin problems of complicated storage management and high overhead that would go with moving the lines themselves.

The main new thing is the declaration for lineptr:

```c
char *lineptr[MAXLINES]
```

says that `lineptr` is an array of *MAXLINES* elements, each element of which is a pointer to a char. That is, `lineptr[i]` is a character pointer, and `*lineptr[i]` is the character it points to, the first character of the $i^{th}$ saved text line.

Since lineptr is itself the name of an array, it can be treated as a pointer in the same manner as in our earlier examples.

```c
/* writelines: write output lines */
void writelines(char *lineptr[], int nlines)
{
    while (nlines-- > 0)
        printf("%s\n", *lineptr++);
}
```

Initially, `*lineptr` points to the first line; each element advances it to the next line pointer while `nlines` is counted down.

### Argument Vector

[TCPL](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/) | Chapter 5 - Pointers and Arrays - 5.10 Command-line Arguments

In environments that support C, there is a way to pass command-line arguments or parameters to a program when it begins executing. When `main` is called, it is called with two arguments. The first (conventionally called `argc`, for argument count) is the number of command-line arguments the program was invoked with; the second (`argv`, for *argument vector*) is a *`pointer to an array`* of character strings that contain the arguments, one per string. We customarily use multiple levels of pointers to manipulate these character strings.

The simplest illustration is the program `echo`, which echoes its command-line arguments on a single line, separated by blanks. That is, the command

```bash
$ echo hello, world
```

prints the output

```bash
hello, world
```

By convention, `argv[0]` is the name by which the program was invoked, so `argc` is at least 1. If `argc` is 1, there are no command-line arguments after the program name. In the example above, `argc` is 3, and `argv[0]`, `argv[1]`, and `argv[2]` are "echo", "hello,", and "world" respectively. The first optional argument is `argv[1]` and the last is `argv[argc-1]`; additionally, the standard requires that `argv[argc]` be a null pointer.

```text
                  argv[n]
                    (*)
       +-----+    +-----+      +------+
argv:  |  ⌾  | -> |  ⌾  | -->  |echo\0|
(**)   +-----+    +-----+      +--------+
                  |  ⌾  | -->  |hello,\0|
                  +-----+      +--------+
                  |  ⌾  | -->  |world\0|
                  +-----+      +-------+
```

The first version of `echo` treats `argv` as an array of character pointers. Since `argv` is a pointer to an array of pointers, we can manipulate the pointer rather than index the array. This next variant is based on incrementing `argv`, which is a pointer to pointer to char, while `argc` is counted down:

```c
#include <stdio.h>

/* echo command-line arguments; 2nd version */
int main(int argc, char *argv[])
{
    while (--argc > 0)
        printf("%s%s", *++argv, (argc > 1) ? " " : "");
    printf("\n");

    return 0;
}
```

Since `argv` is a pointer to the beginning of the array of argument strings, incrementing it by 1 (`++argv`) makes it point at the original `argv[1]` instead of `argv[0]`. Each successive increment moves it along to the next argument; `*argv` is then the pointer to that argument. At the same time, `argc` is decremented; when it becomes zero, there are no arguments left to print.

Alternatively, we could write the `printf` statement as

```c
printf((argc > 1) ? "%s " : "%s", *++argv);
```

This shows that the format argument of `printf` can be an expression too.

---

[TCPL](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/) | Chapter 8 - The UNIX System Interface - 8.6 Example - Listing Directories

The main routine deals with command-line arguments; it hands each argument to the function `fsize`.

```c
int main(int argc, char **argv) {}
```

Here the `argv` is declared as equiv double pointer(pointer-to-pointer).

## Double Pointer

C - Pointer to Pointer (Double Pointer): [tutorialspoint](https://www.tutorialspoint.com/cprogramming/c_pointer_to_pointer.htm), [geeksforgeeks](https://www.geeksforgeeks.org/c-pointer-to-pointer-double-pointer/)

A pointer to pointer which is also known as a double pointer in C is used to store the address of another pointer.

A variable in C that stores the address of another variable is known as a pointer. A pointer variable can store the address of any type including the primary data types, arrays, struct types, etc. Likewise, a pointer can store the address of another pointer too, in which case it is called "`pointer to pointer`" (also called "`double pointer`").

A "pointer to a pointer" is a form of *multiple indirection* or a *chain* of pointers. Normally, a pointer contains the address of a variable. When we define a "pointer to a pointer", the first pointer contains the address of the second pointer, which points to the location that contains the actual value as shown below.

<!-- ![pointer_to_pointer](https://www.tutorialspoint.com/cprogramming/images/pointer_to_pointer.jpg) -->
<!-- ![double-pointers](https://media.geeksforgeeks.org/wp-content/uploads/20230412184414/double-pointers-in-c.webp) -->

```text
      Pointer            Pointer            Variable
    +---------+        +---------+        +---------+
    | address |   ->   | address |   ->   |  value  |
    +---------+        +---------+        +---------+
```

[C – Pointer to Pointer (Double Pointer)](https://www.scaler.com/topics/c/pointer-to-pointer-in-c/): Imagine you have a box (`num`) that contains a value. Now, there's another box (`ptr1`) that doesn't hold a direct value but rather a paper that tells you where the first box is located. This second box is a pointer. Now, imagine a third box (`ptr2`), which instead of having a paper pointing to a direct value, has a paper pointing to the second box (`ptr1`). This is the concept of a *`double pointer`*.

<!-- ![double-pointer](https://i.sstatic.net/aSoZ0.jpg) -->

```text
                            pointer      pointer to pointer
                              ↓                 ↓
var:       num               ptr1              ptr2
        +--------+        +--------+        +--------+
val:    |   10   |   <-   | 0x1000 |   <-   | 0x2000 |
        +--------+        +--------+        +--------+
addr:     0x1000            0x2000            0x3000
         (&num)            (&ptr1)           (&ptr2)
```

As per the figure, `ptr1` is a single pointer which is having address of variable `num`.

```c
int num = 10;
int *ptr1 = &num;
```

Similarly `ptr2` is a pointer to pointer(double pointer) which is having the address of pointer `ptr1`.

```c
int **ptr2 = &ptr1;
```

A pointer which points to another pointer is known as double pointer. In this example `ptr2` is a double pointer.

As a double pointer is still a pointer (variable), it occupies the same amount of space in the memory stack as a normal pointer.

### Examples

In [C Pointer as Function Argument](./c-pointer-parameters.md), we use a pointer to a pointer to change the values of normal pointers, thus returning a newly allocated block of memory.

```c
char *GetMemory(char **p, int num)
{
    *p = (char *)malloc(num * sizeof(char));
}
```

See [How do pointer-to-pointers work in C?](https://stackoverflow.com/questions/897366/how-do-pointer-to-pointers-work-in-c-and-when-might-you-use-them): there is a "real world" code example of pointer to pointer usage, in Git 2.0, [commit 7b1004b](https://github.com/git/git/commit/7b1004b0ba6637e8c299ee8f927de5426139495c):

```c
    list_entry **pp = &head; /* pointer to a pointer */
    list_entry *entry = head;

    while (entry) {
        if (entry->val == to_remove)
            *pp = entry->next;
        else
             pp = &entry->next;
        entry = entry->next;
    }
```

In [reloc puts@plt via GOT - r2 debug](../elf/plt-puts-r2debug.md), `X16` is an indirect double pointer, *LDR* dereferences `X16` to `X17` as a pointer pointing to function `puts()` defined in libc.so.

```bash
[0xaaaadc76063c]> dr?x16
0xaaaadc770fc8

[0xaaaadc76063c]> pv @ x16
0x0000ffff9cbbae70

[0xaaaadc76063c]> xQ $w @ x16
0xaaaadc770fc8  0x0000ffff9832ae70 x17

[0xaaaadc76063c]> dr x17
0xffff9832ae70
```

Here is the ASCII graph for illustration.

```text
           x16                        x17
    +----------------+        +----------------+
    | 0xaaaadc770fc8 |   ->   | 0xffff9832ae70 |   ->   puts() {}
    +----------------+        +----------------+
      (reloc.puts)               (puts@GLIBC)
```

In [C Pointer and Array Cross Reference with Mismatched Type](./c-pointer-array-crossref.md), after disassembling `ref_pointer_as_array`, we discovered the auxiliary intermediate variable `char **_p = &p` behind the scenes (BTS). Apparently `_p` turns out to be a double pointer.

```text
                                                         a
                +-------------------+  +-----------------^-----------------+
                ↑                   ↓ /                                      \
        +--------------+      -----------------------------------------------------
        |0xaaaacf3009d8|         ⚡️  | 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | ⚡️
        +--------------+      -----------------------------------------------------
        p       ↑                  / a[0]  a[1]  a[2]  a[3]  a[4]  a[5]  a[6]
0xaaaacf311078  |             0xaaaacf3009d8
                |
        +--------------+
        |0xaaaacf311078|
        +--------------+
        _p
```

---

[When to use Pointer-to-Pointer in C++?](https://stackoverflow.com/questions/29848863/when-to-use-pointer-to-pointer-in-c)

[dtech](https://stackoverflow.com/a/29849202): I'd say it is better to never use it in C++. Ideally, you will only have to use it when dealing with C APIs or some legacy stuff, still related to or designed with C APIs in mind.

Pointer to pointer has been pretty much made obsolete by the features of the C++ language and its standard library. You have references for when you want to pass a pointer and manipulate the original pointer in a function, and for stuff like a pointer to an array of strings you are better off using a `std::vector<std::string>`. The same goes for multidimensional arrays, matrices and whatnot, C++ has a better way of dealing with these things than cryptic pointers to pointers.
