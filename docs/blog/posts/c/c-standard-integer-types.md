---
title: C语言标准与实现之整数类型
authors:
  - xman
date:
    created: 2009-10-05T12:00:00
    updated: 2024-04-26T16:00:00
categories:
    - c
tags:
    - data_type
    - standard
    - integer
comments: true
---

在 C 语言刚刚被设计出来的时候，一共只有两种整数类型 —— `char` 和 `int`。C89 引入了两种新的整数类型 —— `short` 和 `long`，C99 再增加一种整数类型 —— long long。

后来，随着 C 语言的进一步发展，K&R C 引入了无符号整数的概念以及 `unsigned` 关键字。`char` 既不属于标准带符号整数类型也不属于标准无符号整数类型，它属于历史遗物。

C89 引入 `signed` 关键字后，可显式声明 `signed char`，明确表达最小的标准带符号整数类型。

为什么 `getchar()` 返回的类型是 int，而不是 char？

<!-- more -->

## storage representation

粗略地概括，整数类型分为两大类：无符号整数（`unsigned` integer）和带符号整数（`signed` integer）。

对于无符号整数，一般来说，所有的数位都被用来表示数值。
对于带符号整数，数位被划分为符号位（只能占一位）与数值位（剩余的其它位）。

符号位的权值有不同的解释：

1. 权值是零（符号位是“1”则表示数值为负），称为“符号-绝对值”模式。
2. 权值是 –2^N-1^，“2的补码”方式。
3. 权值是 –(2^N-1^-1)，“1的补码”方式。

至于具体根据哪一种情况对带符号整数作出解释则由每一 种实现自行定义。不过，几乎所有的现代计算机架构均采用“2的补码”解释带符号整数，因此，如果一个实现没有特别说明，我们就可以认为它就是基于“2的补码”方式。

不难得出结论，一个 N 位的带符号整数能够表示的数值范围在三种情形下分别是：

1. [-(2^N-1^-1), (2^N-1^-1)]
2. [-2^N-1^, (2^N-1^-1)]
3. [–(2^N-1^-1), (2^N-1^-1)]

值得注意的是，情形1和情形3都会产生一个重复的零值：对于情形1，符号位是“1”其它位全是零的值按照上面的解释也是零；对于情形3，所有位都是“1”的值按照上面的解释也是零。

很多时候人们容易忘记无符号整数的一个最基本的特性：**永不为负**，于是在某些场合一不小心就出现愚蠢的错误，其中比较常见的是计数器变量（下面的代码试图从大到小打印 [0，99] 区间内的所有整数）：

```c
unsigned i;
for (i = 99; i >= 0; --i) /* 看出问题吗？ */
    printf("%u\n", i);
```

上面代码的意图很明显，计数器 i 从 99 开始，每次减1，递减到0。在这个过程中以 i 为参数调用函数 printf()，总共打印 100 次，然后退出 for 语句。

但是，计数器 i 是无符号整数，编译器会用相应的指令去判断 i 是否大于或等于零，结果很清楚，作为无符号整数的 i 一定是永远大于或等于零的，就是说，上面的 for 语句是一个死循环。对于无符号整数，尽量避免使用 <，>，<=，>= 等运算符而优先选用 != ：

```c
unsigned i = 100;
while (i != 0) /* OK */
{
    --i;
    printf(“%u\n”, i);
}
```

## short, long, long long

C89 引入了两种新的整数类型 —— `short` 和 `long`，很自然 short 和 long 也是新增加的关键字。C99 再增加一种整数类型 —— `long long`，至此，C 语言一共有5种标准带符号整数类型以及5种标准无符号整数类型，标准带符号整数类型和标准无符号整数类型合称为**标准整数类型**。

标准带符号整数类型  | 标准无符号整数类型
-----------------|---------------
signed char      | unsigned char
signed short     | unsigned short
signed int       | unsigned int
sigend long      | unsigned long
signed long long | unsigend long long

C99 标准并没有硬性规定具体到某种平台上的某种整数类型究竟占用多少字节、能够表示多大范围的数值等，只是给出一条原则和一个参考数值集合，只要同时满足这两方面条件就算是符合 C 标准。原则是：

- long long 能够表示的数值范围必须大于或等于 long 能够表示的数值范围，
- long 能够表示的数值范围必须大于或等于 int 能够表示的数值范围，
- int 能够表示的数值范围必须大于或等于 short 能够表示的数值范围，
- short 能够表示的数值范围必须大于或等于 signed char 能够表示的数值范围。

每一种标准整数类型的最大、最小值在该平台对应的 C 标准头文件 [<limits.h\>](https://en.cppreference.com/w/c/types/limits) 中给出，具体实现的数值应该在绝对值上大于或等于 C99 列出的参考值而且符号相同，参考 [cplusplus.com/reference/climits/](https://cplusplus.com/reference/climits/) 中的 Macro constants 表格。

32 位计算机架构上的 C 语言实现通常选用 `ILP32` 模式。

整数类型 | 长度
-------|--------
char | 1 byte ( 8 bit)
short | 2 byte (16 bit)
int | 4 byte (32 bit)
long | 4 byte (32 bit)
long long | 8 byte (64 bit)

而 64 位计算机架构上的 C 语言实现通常选用 `LP64` 模式：

整数类型 | 长度
-------|------
char | 1 byte ( 8 bit)
short | 2 byte (16 bit)
int | 4 byte (32 bit)
long | 8 byte (64 bit)
long long | 8 byte (64 bit)

即使是同一种整数类型，在不同的平台上也可能有不同的长度（例如 long 在 ILP32 和 LP64 中分别是32位和64位），为了方便大家跨平台使用整数类型能够“心中有数”，C99 增加了标准头文件 [<stdint.h\>](https://en.cppreference.com/w/c/types/integer)，里面定义了一系列的类型，这些类型在所有符合 C99 的实现上都具有一致的语义，下面介绍其中最重要的几类。

!!! info "具有准确长度的整数类型"

    - int8_t uint8_t int16_t uint16_t
    - int32_t uint32_t int64_t uint64_t

上面的 intN_t 表示长度为 N 位（不含填充位）、使用“2的补码”的带符号整数类 型，而 uintN_t 则表示长度为 N 位（不含填充位）的无符号整数类型，这些整数类型对 应的最大、最小值分别为（N = 8，16，32，64）：

宏 | 参考值（精确）
---|----------------
INT{==N==}_MIN | -(2^N-1^)
INT{==N==}_MAX | 2^N-1^-1
UINT{==N==}_MAX | 2^N-1

适合存放 void 指针的整数类型：intptr_t / uintptr_t。这两种类型都是可选的，它们分别表示足够用来存放 void 指针的最小带符号、无符号整数类型。

[Fixed width integer types (since C99)](https://en.cppreference.com/w/c/types/integer)

- `intptr_t`: integer type capable of holding a pointer
- `uintptr_t`: unsigned integer type capable of holding a pointer

了解 C 语言的所有这些最重要的整数类型之后，下一个问题就是搞清楚编译器在怎样的情况下会把一个变量或者常数看作什么样的整数类型。

## single char constant

在 C 语言刚刚被设计出来的时候，一共只有两种整数类型—— `char` 和 `int`，在实际的运算当中，char 总是先被提升为 int。

另外，在 C 语言中，单字节字符常数的类型从一开始到现在都是 int（单字节字符常数指 'A'、'\n'、'\045'、'\x33' 等常量）。本来大家很自然地以为 'A' 应该是 char 类型的，不是吗？例如：

```c
char c = 'A';
```

上面这个表达式的确引起了我们的错觉。'A' 明显代表一个单字节字符值，把这个代表字符的值赋给 char 变量，可谓“门当户对”的事啊……然而，'A'虽然代表一个单字节字符值，但同时它的值必须要用与 int 等长的空间来存储，因此它的身份是不折不扣的 int。这也是 char 变量必须提升为 int 再参与运算的规则的另一个反映——反正到头来还是得提升为 int，索性一开始就给它 int 的身份！至于上面那个表达式，它的作用相当于把一个曾经提升为 int 类型的 char 数值还原回 char 而已，完全没有问题。虽然 C89 开始确立了一系列的新规则，但 `单字节字符常量的类型是 int` 这个惯例仍然被保留下来，即使到了 C99也同样如此：

```c
#include <stdio.h>

int main(int argc, char* argv[]) {
    printf("sizeof('A') = %zu\n",sizeof('A'));

    return 0;
}
```

由于 sizeof 是编译期就确定的数值，我们完全可以从汇编代码中看出它的具体 值，不过这里还是编译成可执行文件再运行：

```Shell
$ cc single-char.c -o single-char && ./single-char
sizeof('A') = 4
```

显然，'A' 要占用4个字节，在32位平台上这恰好就是一个 int 的长度。综合上面所说，在 C 语言的早期，要确定一个表达式里的整型变量或者常数的具体类型并不复杂，原本就只有两种整数类型，在运算和传递参数时 char 又总是先被提升为 int，加上整型常数属于 int 类型、单字节字符常量也属于 int 类型——一切都非常清楚。

## char: signed or unsigned?

后来，随着 C 语言的进一步发展，K&R C 引入了无符号整数的概念以及 `unsigned` 关键字，并增加了 short、long 两种整数类型。这时，C 语言已经拥有以下整数类型：

- char / unsigned char
- short / unsigned short
- int / unsigned int
- long / unsigned long

至此，情况开始变得复杂。在进一步分析 unsigned 引入的问题之前，我们先清算一下 [关于 char 的旧账](https://stackoverflow.com/questions/2054939/is-char-signed-or-unsigned-by-default/2054941)。在 D.M.Ritchie 设计 C 语言的早期，char 变量只是用来存放 ASCII 字符，由于 ASCII 是7位编码体系10，用最小的存储单位——字节来存放 char 变量完全足够。虽然 ASCII 字符值只占用一个字节的低7位从而使到一个 char 变量不应该出现负值，D.M.Ritchie 本人还是把 char 实现为带符号整数类型，允许 char 变量出现负值，也就是说，[char 只不过是比 int 短一些的整数类型罢了](https://www.reddit.com/r/learnprogramming/comments/p9pgxl/c_why_is_the_data_type_char_considered_an_integer/)。

不过，其它一些 C 实现平台的做法有所不同。例如，某些平台使用8位的扩展编码体系，为了能够表达字符集里所有的字符，这些平台上的 char 变量连最高位也派上用场了。 在这种情形下，很难说服人们把最高位是“1”的 char 值看作负数，于是，在这部分的 C 实现中，char 的存在方式恰好和当初的设计目的不谋而合 —— char 值永不为负。0xFF 不是“-1”而是255。

到了 K&R C 引入 unsigned 关键字以后，基于 char 的分歧已经根深蒂固，unsigned char、unsigned short、unsigned int、unsigned long 都属于无符号整数类型，而 short、int、long 属于带符号整数类型，这些都毫无疑问，偏偏 char 例外。char 属于什么类型？在那些一直把 char 实现为带符号整数的平台上，char 属于带符号类型；而在另外那些使用8位字符编码的实现里，char 名副其实地拒绝负数的概念，很明显这些平台上的 char 相当于 unsigned char。

大家可能会问，在那些坚持 char 永不为负的实现里岂不是少了一种8位带符号整数类型？因为在 char 被实现为带符号整数的平台上可以通过加上 unsigned 关键字来构造非负的 char 变量，但却没有办法让另外那些平台使用永远非负的 char 来存放负数啊。

对，正因为如此，C89 才会引入 `signed` 关键字。如果不了解这段历史，大家肯定会认为 signed 关键字简直就是废物——已经专门有一个 unsigned 被发明出来表示无符号整数的概念，那只要不使用 unsigned 来修饰不就意味着带符号整数吗，何必再来一个 signed 呢？对于 short、int、long 这些类型来说，signed 真的是多余，但对于 char，关键字 signed 是必要的。否则大家就不知道自己的 char 变量在不同的平台会有什么表现，在一个平台上是负数，在另一个平台上又被解释为永远非负，这与 C 的标准化完全相抵。有了 signed，我们就能避开这个陷阱，明确表达自己究竟想怎样。

```c
signed char x;      /* 无论在哪里，x 都是带符号整型变量 */
unsigned char y;    /* 无论在哪里，y 都是无符号整型变量 */
```

所以，前面在讲述标准整数类型时，笔者已经在注释里着重强调：属于标准带符号整数类型的是 signed char（而不是 char）！char 既不属于标准带符号整数类型也不属于标准无符号整数类型，它属于历史遗物。

GCC [C Dialect Options](https://gcc.gnu.org/onlinedocs/gcc/C-Dialect-Options.html) 中提供了 `-fsigned-char` 和 `-funsigned-char` 选项，支持明确指定 `char` 的符号类型。

!!! note "-fsigned-char & -funsigned-char"

    `-fsigned-char`

    Let the type char be signed, like signed char.

    Note that this is equivalent to -fno-unsigned-char, which is the negative form of -funsigned-char. Likewise, the option -fno-signed-char is equivalent to -funsigned-char.

    `-funsigned-char`

    Let the type char be unsigned, like unsigned char.

    Each kind of machine has a default for what char should be. It is either like unsigned char by default or like signed char by default.

    Ideally, a portable program should always use signed char or unsigned char when it depends on the signedness of an object. But many programs have been written to use plain char and expect it to be signed, or expect it to be unsigned, depending on the machines they were written for. This option, and its inverse, let you make such a program work with the opposite default.

    The type char is always a distinct type from each of signed char or unsigned char, even though its behavior is always just like one of those two.

## why getchar() return int?

最后，来看一下 [File input/output](https://en.cppreference.com/w/c/io) - [<stdio.h\>](https://pubs.opengroup.org/onlinepubs/009695299/basedefs/stdio.h.html) 中读写字符相关接口的参数类型：

```c
int fgetc( FILE *stream );
int getc( FILE *stream );
int getchar( void );
int putchar( int ch );
int ungetc( int ch, FILE *stream );
```

遥想当年初学 C 语言，相信不少人对于 `getchar()` 函数家族的返回类型都会有所困惑。

[Why is getchar() function in C an Integer?](https://stackoverflow.com/questions/39341213/why-is-getchar-function-in-c-an-integer)

> `getchar()` and family return an integer so that the `EOF` -1 is distinguishable from `(char)-1` or `(unsigned char)255`.

[Difference between int and char in getchar/fgetc and putchar/fputc?](https://stackoverflow.com/questions/35356322/difference-between-int-and-char-in-getchar-fgetc-and-putchar-fputc)

!!! quote "JohnLM"

    [JohnLM](https://stackoverflow.com/a/35356510/3721132):

    Always use `int` to save character from `getchar()` as `EOF` constant is of int type. If you use `char` then the comparison against `EOF` is not correct.

    You can safely pass `char` to `putchar()` though as it will be promoted to `int` automatically.

!!! quote "Antti Haapala"

    [Antti Haapala -- Слава Україні](https://stackoverflow.com/a/35356684/3721132):

    The reason why you must use `int` to store the return value of both `getchar` and `putchar` is that when the end-of-file condition is reached (or an I/O error occurs), both of them return the value of the macro `EOF` which is a negative integer constant, (usually -1).

    For `getchar`, if the return value is not `EOF`, it is the read *unsigned char* zero-extended to an `int`. That is, assuming 8-bit characters, the values returned can be `0...255` or the value of the macro `EOF`; again assuming 8-bit char, there is no way to squeeze these 257 distinct values into 256 so that each of them could be identified uniquely.

[4.1.3 Character I/O Using getchar() and putchar()](https://ee.hawaii.edu/~tep/EE160/Book/chap4/subsection2.1.1.3.html)

!!! note "to accommodate EOF"

    The function `getchar()` reads a single character from the standard input and returns the character value as the value of the function, but to **accommodate** a possible negative value for `EOF`, the type of the value returned is `int`. (Recall, EOF may be either 0 or -1 depending on implementation). So we could use `getchar()` to read a character and assign the returned value to an integer variable:

    ```c
        int c;
        c = getchar();
    ```

    If, after executing this statement, c equals EOF, we have reached the end of the input file; otherwise, c is the ASCII value of the next character in the input stream.

    While int type can be used to store the ASCII value of a character, programs can become *confusing* to read - we expect that the int data type is used for numeric integer data and that char data type is used for character data. The problem is that char type, depending on implementation, may or may not allow negative values. To resolve this, C allows us to explicitly declare a signed char data type for a variable, which can store negative values as well as positive ASCII values:

    ```c
        signed char c;
        c = getchar();
    ```

    An explicit signed char variable ensures that a character is stored in a character type object while allowing a possible negative value for EOF. The keyword signed is called a **type qualifier**.

    A similar routine for character output is `putchar()`, which outputs its argument as a character to the standard output. Thus,

    ```c
    putchar(c);
    ```

    outputs the ASCII character whose value is in c to the standard output. The argument of putchar() is expected to be an integer; however, the variable c may be either char type or int type (ASCII value) since the value of a char type is really an integer ASCII value.

---

本文节选自 《[C语言标准与实现(姚新颜)-2004](https://att.newsmth.net/nForum/att/CProgramming/3213/245)》 #2 数值运算 | 12 整数类型。
