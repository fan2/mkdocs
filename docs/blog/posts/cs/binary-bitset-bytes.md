---
title: Binary —— Bitset & Bytes
authors:
  - xman
date:
    created: 2021-10-05T10:00:00
    updated: 2024-04-28T12:00:00
categories:
    - CS
tags:
    - binary
    - bitset
    - bytes
comments: true
---

所谓数制是指计数的方法。对于有10根手指的人来来说，使用十进制表示法是很自然的事情，现代计算机则采用的是二进制系统，存储和处理的信息以二值信号表示。

一串二进制数码按照固定长度（8）组合出有意义的基本存储单位——字节，多个字节（1,2,4,8）可以组合出基本算术单元 char,short,int/float,long/double，或复合类型和用户自定义类型。

在计算机内存或磁盘上，指令和数据没有任何区别，都是二进制信息。CPU 在工作的时候把有的信息解析为指令，有的信息解读为数据，为同样的信息赋予了不同的意义。

这涉及到 [Abstract State Machine](../c/c-abstract-state-machine.md)：

- a `value` : what state are we in
- the `type` : what this state represents
- the `representation` : how state is distinguished

<!-- more -->

## decimal

人两手加起来共10根手指，故日常计数和做算术都使用十进制。大家熟悉并使用了一千多年的十进制起源于印度，在12世纪被阿拉伯数学家改进，并在13世纪被意大利数学家Leonardo Pisano（Fibonacci）带到西方。1、2、3的罗马计数法是Ⅰ、Ⅱ、Ⅲ，Ⅰ+Ⅱ=Ⅲ 直观展示了加法运算的含义。

数据无论使用哪种进位制，都涉及两个基本要素：**基数**（radix）与各数位的 **位权**（weight）。
十进制数有两个特点：

1. 用0、1、2、3、...、9这10个基本符号表示；基本数字符号（数码）的个数叫**基数**。
2. 遵循“逢十进一”原则，每位计满十时向高位进一。

一般地，任意一个十进制数 N 都可以表示为 $\sum_{i=-m}^{n-1}K_i\ast10^i$：

$$
N = K_{n-1}\ast10^{n-1} + K_{n-2}\ast10^{n-2} + \cdots + K_1\ast10^1 + K_0\ast10^0 + K_{-1}\ast10^{-1} + K_{-2}\ast10^{-2} + \cdots + K_{-m}\ast10^{-m}
$$

抛开小数部分，整数按权的展开式为：

$$
N = \sum_{i=0}^{n-1}K_i\ast10^i = K_{n-1}\ast10^{n-1} + K_{n-2}\ast10^{n-2} + \cdots + K_1\ast10^1 + K_0\ast10^0
$$

一个数字符号在不同位时，代表的数值不同。在上述表达式中，数位 $K_i$ 的权为 $10^i$（以基数$10$为底，序号$i$为指数），数字符号乘以其位权为这个数字符号所表示的真实数值（$K_i\ast10^i$）。

## binary

现代计算机存储和处理的信息以二值信号表示。二值信号可以表示为导线上的高电压或低电压、晶体管的导通或截止、电子自旋的两个方向，或者顺时针或逆时针的磁场。

当今的计算机系统使用的基本上都是由18世纪德国数理哲学大师莱布尼兹发现的**二进制系统**。二进制数字系统中只有两种二进制数码——0和1。这些微不足道的二进制数字，或者称为位（bit - binary digit），形成了数字革命的基础。

对于有10根手指的人来来说，使用十进制表示法是很自然的事情，但是当构造存储和处理信息的机器时，二进制工作得更好。在计算机内部，二进制总是存放在由具有两种相反状态的存储元件构成的寄存器或存储单元中，即二进制数码0和1是由存储元件的两种相反状态来表示的。这使得二值信号很容易地被表示、存储和传输。

在 [指令集及流水线](https://blog.csdn.net/phunxm/article/details/8980808) 中提到，在上个世纪的打孔编程时代，纸带上的每个孔代表一位(bit)，穿孔（presence）表示1，未穿孔（absence）表示0，这些孔序列被扫描识别为机器指令的二进制位串。

十进制数按权的展开式可以推广到任意进位计数制。二进制中只有0和1两个字符，基数为2，满足“逢二进一”。权用 $2^i$ 表示，二进制的按权展开式为 $N =  \sum_{i=0}^{n-1}b_i\ast2^i$。

二进制与其他数制相比，有以下显著特点：

1. 数制简单，容易基于元器件的电子特性实现数字逻辑电路。
2. 由于二进制只有两种状态，因此抗干扰性强，可靠性、稳定性高。
3. 可以基于布尔逻辑代数进行分析和综合，运算规则相对简单易实现。

> 基数为2的好处在于基本算术运算表很短，对比一下十进制和二进制的加法和乘法表，长短相形一目了然。

## bit pattern

2个比特可以组合出4（$2^2$）种状态，可表示无符号数值范围[0,3]；32个比特可以组合出4294967296（$2^{32}$）种状态，可表示无符号数值范围[0,4294967295]；……。

由于一个位只能表示二元数值，所以单独一位的用处不大。当把位**组合**在一起，再加上某种解释（interpretation），即赋予不同的可能**位模式**以含意。通常将固定位数的位串作为一个基本存储单位，这样就可以存储范围较大的值。在有限范围内的可计量数值几乎都可以用二进制数码位串组合表示，计算机的内存由数以亿万计的比特位存储单元（晶体管）组成。

大多数计算机使用8位的块，或者字节（byte），作为最小的可寻址的内存单位，而不是访问内存中单独的位（bit）。机器级程序将内存视作一个非常大的字节数组，内存的每个字节都由一个唯一的数字来标识，称为它的地址。

> The number of bits in a char(byte) is reported by the macro `CHAR_BIT` in the C header [<limits.h\>](https://en.cppreference.com/w/c/types/limits) / [<climits\>](https://en.cppreference.com/w/cpp/header/climits).

A C program, whatever its size, consists of functions and variables.
在 C 程序里，变量（variable）就是数据，函数（function）就是指令。

在内存或磁盘上，指令和数据没有任何区别，都是二进制信息。
每个程序对象可以简单地视为一个字节块，程序本身就是一个字节序列。
CPU 在工作的时候把有的信息看作指令，有的信息看作数据，为同样的信息赋予了不同的意义。

## dump bitset

1byte=8bit，底层都是二进制位串进行移位实现相关操作。

以下为打印单字节和双字节（short）、四字节（int）二进制位串的程序，包括三个子函数，功能如下：

1. `hexdump`：输出指定内存起始地址 start 开始的 size 个字节，C 程序是按照 BYTE_ORDER dump memory bytearry。
2. `print_bytes`：输出指定内存地址 start 开始的 size 个字节的二进制位串，foreach 每个字节调用 print_byte 子函数。
3. `count_bits`：统计整数 x 的二进制位串中 1 的个数。

```c title="print-bitset.c" linenums="1"
#include <stdio.h>
#include <limits.h>

typedef unsigned char byte;
typedef unsigned char *byte_pointer;

// Dump memory bytearray as BYTE_ORDER
void hexdump(const byte_pointer start, const size_t size)
{
    size_t i = 0;
    putchar('{');
    for (i = 0; i < size; i++)
        printf("%#.2x%s", start[i], i < size - 1 ? ", " : "");
    puts("}");
}

// Count bits set
int count_bits(int x)
{
    int countx = 0;
    while (x)
    {
        countx++;
        x = x & (x - 1);
    }

    return countx;
}

// Dump bitset from MSB to LSB
void print_byte(const byte uc)
{
    for (int i = 0; i < CHAR_BIT; ++i)
    {
        if ((uc << i) & 0x80)
            putchar('1');
        else
            putchar('0');
    }
}

void print_bytes(const byte_pointer start, const size_t size)
{
    int i = 0;

#ifdef _BIG_ENDIAN
    for (i = 0; i < size; i++)
    {
        print_byte(start[i]);
        if (i < size - 1)
            putchar('_');
    }
#else
    for (i = size - 1; i > -1; i--)
    {
        print_byte(start[i]);
        if (i > 0)
            putchar('_');
    }
#endif
    printf("\n");
}

int main(int argc, char *argv[])
{
    byte_pointer bp = NULL;
    int bc = 0;
    size_t size = 0;

    short year = 2010;
    bp = (byte_pointer)&year;
    size = sizeof year;
    printf("hex(%hd) = %#x\n", year, year);
    printf("hexdump(%hd) = ", year);
    hexdump(bp, size);
    printf("bitset = ");
    print_bytes(bp, size);
    bc = count_bits((int)(year));
    printf("bits set count = %d\n", bc);

    puts("");

    int hours = 86400;
    bp = (byte_pointer)&hours;
    size = sizeof hours;
    printf("hex(%d) = %#x\n", hours, hours);
    printf("hexdump(%d) = ", hours);
    hexdump(bp, size);
    printf("bitset = ");
    print_bytes(bp, size);
    bc = count_bits(hours);
    printf("bits set count = %d\n", bc);

    return 0;
}
```

以下是在 rpi4b-ubuntu/aarch64 下测试的结果：

```Shell
$ cc print-bitset.c -o print-bitset -g && ./print-bitset
hex(2010) = 0x7da
hexdump(2010) = {0xda, 0x07}
bitset = 00000111_11011010
bits set count = 8

hex(86400) = 0x15180
hexdump(86400) = {0x80, 0x51, 0x01, 00}
bitset = 00000000_00000001_01010001_10000000
bits set count = 5
```

标准C++中的 <bitset\> 提供了二进制位串操作接口，参考 [TC++PL](https://www.stroustrup.com/4th.html) 34.2.2 bitset 中的相关说明。

- [std::bitset](https://en.cppreference.com/w/cpp/utility/bitset): The class template bitset represents a fixed-size sequence of N bits.
- [Numerics library - Bit manipulation](https://en.cppreference.com/w/cpp/numeric#Bit_manipulation): [<bit\>](https://en.cppreference.com/w/cpp/header/bit)(C++20) provides several function templates to access, manipulate, and process individual bits and bit sequences.

在 C++ 中，可基于双字节（short）、四字节（int）构造 bitset，调用 `std::cout << ` 打印位串，调用成员函数 `count()` 输出值为 1 的位数。

!!! note "cout unsigned char as byte?"

    [c++ - cout not printing unsigned char](https://stackoverflow.com/questions/15585267/cout-not-printing-unsigned-char)

    执行 `std::cout << start[i]` 打印 unsigned char，默认会输出 ASCII 码。如果碰上不可打印字符（non-printable character），则可能显示乱码。
    如果想输出十六进制 byte，则需要先将其提升为整形（unsigned [int] 或 signed [int]），再调用 `std::cout << hex`。

```cpp title="print-bitset.cpp" linenums="1"
#include <climits>
#include <iostream>
#include <iomanip>
#include <bitset>

using namespace std;
using byte_pointer = unsigned char*;

// Dump memory bytearray as BYTE_ORDER
void hexdump(const byte_pointer start, const size_t size)
{
    cout << '{';
    cout << hex << setw(2) << setfill('0');
    for (size_t i = 0; i < size; i++)
        // unary plus triggers implicit (arithmetic) conversions
        // integral promotion: promote smaller integer to int
        cout << +start[i] << (i<size-1 ? ", " : "");
        // or explicit integral promotion
        // cout << static_cast<unsigned>(start[i]) << (i<size-1 ? ", " : "");
    cout << '}' << endl;
}

int main(int argc, char *argv[])
{
    byte_pointer bp = nullptr;

    short year = 2010;
    cout << "hex(" << year << ") = " << showbase << hex << year << dec << endl;
    bp = reinterpret_cast<byte_pointer>(&year);
    cout << "hexdump(" << year << ") = " ;
    hexdump(bp, sizeof year);
    bitset<sizeof(year) * CHAR_BIT> bs1 (year);
    cout << "bitset(" << year << ") = " << bs1 << endl;
    cout << "bits set count = " << dec << bs1.count() << endl;

    cout << endl;

    int hours = 86400;
    cout << "hex(" << hours << ") = " << showbase << hex << hours << dec << endl;
    bp = reinterpret_cast<byte_pointer>(&hours);
    cout << "hexdump(" << hours << ") = " ;
    hexdump(bp, sizeof hours);
    bitset<sizeof(hours) * CHAR_BIT> bs2 (hours);
    cout << "bitset(" << hours << ") = " << bs2 << endl;
    cout << "bits set count = " << dec << bs2.count() << endl;

    return 0;
}
```

以下是在 rpi4b-ubuntu/aarch64 下测试的结果：

```Shell
$ c++ print-bitset.cpp -o print-bitset -g && ./print-bitset
hex(2010) = 0x7da
hexdump(2010) = {0xda, 0x7}
bitset(0x7da) = 0000011111011010
bits set count = 8

hex(86400) = 0x15180
hexdump(86400) = {0x80, 0x51, 0x1, 00}
bitset(0x15180) = 00000000000000010101000110000000
bits set count = 5
```

!!! question "hex vs. hexdump byte order mismatch"

    hex(2010) 输出十六进制是 0x7da，hexdump(2010) 输出内存中的字节数组是 {0xda, 0x7}，字节顺序为什么不同？

## reinterpretation

关于 Width in bits by data model，参考 [C Data Types](../c/c-data-types.md) 和 [C++ Data Types](../cpp/cpp-data-types.md)。

- C99 增加了一种64位整数类型 —— long long，<limits.h\> 中规定了其 minimal precision 为 64。
- 在 C++ [Fundamental types](https://en.cppreference.com/w/cpp/language/types) 中规定：long long — target type will have width of at least 64 bits. (since C++11)

下图为 Microsoft *LLP64* Data Model 中 [C++ Type System](https://msdn.microsoft.com/en-us/library/hh279663.aspx) 的 Fundamental (built-in) types 按字节宽度的层砌图（Layout of Source Language Data Types）：

![built-intypesizes](https://learn.microsoft.com/en-us/cpp/cpp/media/built-intypesizes.png)

在 MS LLP64 数据模型中，维持 ILP32 模式下的 `__SIZEOF_LONG__`=`__SIZEOF_INT__`=4， 满足：

- `__SIZEOF_LONG_LONG__` == `__SIZEOF_POINTER__` = 8。

典型 Unix-like systems（如 Linux，macOS）的 Data Model 一般为 *LP64*：

- `LONG_BIT` = `__WORDSIZE` = 64
- `__SIZEOF_LONG__` = `__SIZEOF_POINTER__` = 8

无论是在 LLP64 还是在 LP64 模式下，一个8byte宽的存储单元，可以存储1个 long long/double、2个连续的 int/float、4个连续的 wchart\_t（short）、8个连续的byte（char）。

对于给定的 memory byte array，可按需对字节串进行组合析取或类型转换。通用指针 void\* 的妙处就在于可以按照需要操作一块内存，以取所需值类型。

上面测试程序 print-bitset 中的 hexdump 函数的作用是 Dump memory bytearray as BYTE_ORDER。

以下测试 C 程序则演示了将 byte array 按照 1、2、4 三种字节组合析值情况。

```c title="bytes-reinterpret.c"
#include <stdio.h>
#include <stdint.h>

int main(int argc, const char *argv[])
{
    int i;
    const int size = 9;
    int8_t byte[] = {48, 49, 50, 51, 52, 53, 54, 55, 0};
    printf("byte array = {");
    for (i = 0; i < size; i++)
        printf("0x%x%s", byte[i], i<size-1 ? ", " : "");
    puts("}");

    int8_t *pByte = byte;
    puts("----------------------------------");
    printf("c string = \"%s\"\n", pByte);

    puts("----------------------------------");
    puts("每2个byte组合而成的16进制值:");
    int16_t *pi16 = (int16_t *)pByte;
    for (i = 0; i < size/2; i++)
    {
        int16_t i16 = *(pi16 + i);
        printf("short array [%d] = 0x%4x\n", i, *(pi16 + i));
    }

    puts("----------------------------------");

    puts("每4个byte组合而成的16进制值:");
    int32_t *pi32 = (int32_t *)pByte;
    for (i = 0; i < size/4; i++)
    {
        int32_t i32 = *(pi32 + i);
        printf("int array [%d] = %#x\n", i, *(pi32 + i));
    }

    puts("----------------------------------");

    return 0;
}
```

在 rpi4b-ubuntu/aarch64 下的测试结果如下：

```Shell
$ cc bytes-reinterpret.c -o bytes-reinterpret && ./bytes-reinterpret
byte array = {0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x0}
----------------------------------
c string = "01234567"
----------------------------------
每2个byte组合而成的短整型:
short array [0] = 0x3130
short array [1] = 0x3332
short array [2] = 0x3534
short array [3] = 0x3736
----------------------------------
每4个byte组合而成的整形:
int array [0] = 0x33323130
int array [1] = 0x37363534
----------------------------------
```

!!! question "why 0x3130 , not 0x3031?"

    每2个byte组合而成的短整型 short array [0] 为什么是 `0x3130`，而非 `0x3031`？

## type conversion

对于字符型 char 变量，短整型 short 变量，可以提升（promote）为更宽的 int 类型。
int accommodate short 属于“大肠包小肠”、“大箱装小包”，不会有精度损失。

在 binary representation 层面，一般会 expanding sign bit 实现等值 integral promotion，参考 [计算机中有符号数的表示](./signedness-representation.md)。

```c title="test-conversion-promotion.c"
    unsigned char uc = 128;
    int i = (int)uc;
    printf("uc = %hhu, i = %d\n", uc, i);
    printf("uc = %#x, i = %#.8x\n", uc, i);

    short s = 0x5678;
    i = (int)s;
    printf("s = %hd, i = %d\n", s, i);
    printf("s = %#hx, i = %#.8x\n", s, i);
```

反过来，对于给定的整形 int 变量，也可以强制转换（force conversion）析取部分 byte 值。
这种 narrow down 会引起 precision truncate，此之谓“断章取义”，只能获得“以偏概全”的“一孔之见”。

```c title="test-conversion-narrow-down.c"
    int i = 0x12345678;
    short s = (short)i;
    char c = (char)i;
    printf("i = %#x, s = %#x, c = %#x\n", i, s, c);
```

!!! question "元芳，你怎么看？"

    分析一下程序 test-conversion-narrow-down.c 的输出结果。
