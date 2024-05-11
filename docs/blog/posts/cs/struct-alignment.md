---
title: Struct Alignment
authors:
  - xman
date:
    created: 2021-10-13T10:00:00
    updated: 2024-05-02T12:00:00
categories:
    - CS
tags:
    - struct
    - alignment
comments: true
---

An object doesn't just need enough storage to hold its representation. In addition, on some machine architectures, the bytes used to hold it must have proper alignment for the hardware to access it efﬁciently.

Where alignment most often becomes visible is in object layouts: sometimes structs contain "`holes`" to improve alignment.

<!-- more -->

## struct padding holes

### TCPL

Excerpt from [C Programming Language, 2nd Edition - 1988](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/).

---

**6.4 Pointers to Structures**

Don't assume, however, that the size of a structure is the sum of the sizes of its members. Because of alignment requirements for different objects, there may be unnamed "`holes`" in a structure. Thus, for instance, if a char is one byte and an int four bytes, the structure.

```c
struct {
    char c;
    int i;
};
```

might well require eight bytes, not five. The `sizeof` operator returns the proper value.

---

**6.5 Self-referential Structures**

objects of certain types must satisfy alignment restrictions

Alignment requirements can generally be satisfied easily, at the cost of some wasted space, by ensuring that the allocator always returns a pointer that meets *all* alignment restrictions.

### TC++PL

Excerpt from [The C++ Programming Language(4e)-2013](https://www.stroustrup.com/4th.html).

---

6. Types and Declarations | 6.2 Types | **6.2.9 Alignment**

An object doesn't just need enough storage to hold its representation. In addition, on some machine architectures, the bytes used to hold it must have proper alignment for the hardware to access it efﬁciently (or in extreme cases to access it at all). For example, a 4-byte `int` often has to be aligned on a word (4-byte) boundary, and sometimes an 8-byte `double` has to be aligned on a word (8-byte) boundary. Of course, this is all very implementation speciﬁc, and for most programmers completely implicit. You can write good C++ code for decades without needing to be explicit about alignment. Where alignment most often becomes visible is in object layouts: sometimes structs contain "`holes`" to improve alignment.

The `alignof` operator returns the alignment of its argument expression.

---

8. Structures, Unions, and Enumerations | 8.2 Structures | **8.2.1 struct Layout**

An object of a **struct** holds its members in the order they are declared. For example, we might store primitive equipment readout in a structure like this:

```c
struct Readout {
    char hour;  // [0:23]
    int value;
    char seq;   // sequence mark ['a':'z']
};
```

You could imagine the members of a `Readout` object laid out in memory like this:

![struct-Readout-1](./images/alignment/struct-Readout-1.png)

Members are allocated in memory in declaration order, so the address of `hour` must be less than the address of `value`. See also §8.2.6.

However, the size of an object of a **struct** is not necessarily the sum of the sizes of its members. This is because many machines require objects of certain types to be allocated on architecture dependent *boundaries* or handle such objects much more *efﬁciently* if they are. For example, integers are often allocated on word boundaries. On such machines, objects are said to have to be properly ***aligned*** (§6.2.9). This leads to "`holes`" in the structures. A more realistic layout of a `Readout` on a machine with 4-byte int would be:

![struct-Readout-2](./images/alignment/struct-Readout-2.png)

In this case, as on many machines, `sizeof(Readout)` is 12, and not 6 as one would naively expect from simply adding the sizes of the individual members.

You can minimize wasted space by simply ordering members by size (*largest member ﬁrst*). For example:

```c
struct Readout {
    int value;
    char hour;  // [0:23]
    char seq;   // sequence mark ['a':'z']
};
```

![struct-Readout-3](./images/alignment/struct-Readout-3.png)

Note that this still leaves a 2-byte "`hole`" (unused space) in a `Readout` and `sizeof(Readout)==8`. The reason is that we need to maintain alignment when we put two objects next to each other, say, in an array of `Readout`s. The size of an array of 10 `Readout` objects is `10∗sizeof(Readout)`.

It is usually best to order members for readability and sort them by size only if there is a demonstrated need to optimize.

Use of multiple access speciﬁers (i.e., `public`, `private`, or `protected`) can affect layout (§20.5).

## struct alignment rule

在上一节 [Memory Address Alignment](./address-alignment.md) 中，提到了基础类型（basic/fundamental types）的自然对齐规则（natural alignment rule）：任何 $K$ 字节的基本对象的存储地址必须是 $K$ 的倍数。

结构体成员变量的存放地址也有“地址边界对齐限制”：在默认编译配置下，成员变量存放的地址相对结构体起始地址的**偏移量**也必须满足自然对齐，即偏移量为该成员变量自身类型大小的倍数。

各成员变量在存放的时候根据在结构体中声明的顺序依次申请空间，同时按照“地址边界对齐限制”原则调整存放位置（地址），空缺的字节会自动填充。

### largest member ﬁrst

下面以 `struct st_dci` 为例来说明结构体的存储布局。

```c
struct st_dci
{
    double d;
    char c;
    int i;
};
```

1. 先为 `d` 分配存储空间，其起始地址和结构体起始地址相同，偏移量0为sizeof(double)=8的倍数，占用8字节。
2. 再为 `c` 分配存储空间，地址偏移量为8，是sizeof(char)=1的倍数，占用1个字节。
3. 继续为 `i` 分配存储空间，地址偏移量为9，不是sizeof(int)=4的倍数。为满足“地址边界对齐限制”，将自动填充3个字节，在偏移量为12的地址处存放 i，占用4个字节。

至此，各成员变量都已分配了相对地址，sizeof(struct st_dci) = 8+1+(3)+4=16。其中，括号里的 *3* 为 padding bits 位数。

> 20230510 - [ISO/IEC-N4950](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf) - 6.8.2 Fundamental types: Padding bits have *unspecified* value, but cannot cause traps.

可以调用 <stddef.h\> 中定义的宏 [offsetof](https://en.wikibooks.org/wiki/C_Programming/stddef.h/Function_reference#offsetof) 来读取各个成员的实际偏移量。

### largest member middle

上面的 `struct st_dci` 是一种类似 TC++PL 中调整后的 struct Readout - largest member ﬁrst 的内存布局。

交换一下成员变量d和c的位置，将占位最长的 d 放在中间，新的结构体 `struct st_cdi` 的内存布局和占用空间又是怎样的呢？

```c
struct st_cdi
{
    char c;
    double d;
    int i;
};
```

按照结构体成员变量的“地址边界对齐限制”原则，分析一下 `struct st_cdi` 的地址分配。

1. 先为 `c` 分配存储空间，其起始地址和结构体起始地址相同，是sizeof(char)=1的倍数，占用1个字节。
2. 再为 `d` 分配存储空间，地址偏移量为1，不是sizeof(double)=8的倍数，为满足“地址边界对齐限制”，先填充7个字节，再从地址偏移量为8的地址处存放d，占用8字节。
3. 继续为 `i` 分配存储空间，地址偏移量为16，是sizeof(int)=4的倍数。

经以上推演相对存储分配布局后，sizeof(struct st_cdi) = 1+(7)+8+4=20。其中，括号里的 *7* 为 padding bits 位数。

按照成员变量的“地址边界对齐限制”原则，似乎已经讨论完毕，但问题不止如此。

结构体 `struct st_cdi` 最终的实际大小，请见下节分析。

### struct array

考虑定义一个结构体 `struct st_cdi` 的数组：

```c
struct st_cdi st[4];
```

按照上面的讨论，sizeof(struct st_cdi)=20，假设数组（第一个结构体）的起始地址为 Sa，则第二、三、四个结构体的地址分别为 Sa+20, Sa+40, Sa+60。

第一个结构体 st[0] 内部的成员 c、d、i 固然能满足“地址边界对齐限制”，但是紧随其后的第二、三、四个结构体中的每个成员变量是否能满足“地址边界对齐限制”呢？

以第二个结构体 st[1] 为例，其起始地址为 Sa+20，成员 c 满足对齐限制，占用1字节+填充7字节后，成员 d 的起始地址为 Sa+28。取 Sa 为典型的 8 或 16，均不能满足 d 的“地址边界对齐限制”。

实际上，编译器在为 `struct st_cdi` 分配空间时，除了使每个成员变量满足“地址边界对齐限制”外，还必须保证结构体所占的总字节数是结构中最长类型所占字节数（这里是sizeof(double)=8）的倍数（satisfy the strictest alignment requirement）。

具体来说，在为最后一个成员变量 i 分配地址后，已占 20 个字节，还必须在尾部填充4个字节。这样，结构体整体大小 sizeof(struct st_cdi) = 1+(7)+8+4+(4)=24，为 8 的倍数。

只要确保结构数组起始地址 Sa（&st[0]）是 8 的倍数，就能够保证其后的每个元素（st[1]，st[2]，...）中的成员变量都满足自身的地址对齐限制。

## compiler support

GCC - [Determining the Alignment of Functions, Types or Variables](https://gcc.gnu.org/onlinedocs/gcc/Alignment.html): The keyword `__alignof__` determines the alignment requirement of a function, object, or a type, or the minimum alignment usually required by a type. Its syntax is just like sizeof and [C11 _Alignof](https://en.cppreference.com/w/c/keyword/_Alignof)([until C23](https://en.cppreference.com/w/c/language/_Alignof)).

[Microsoft-specific](https://learn.microsoft.com/en-us/cpp/cpp/alignof-operator?view=msvc-170): `alignof` and `__alignof` are synonyms in the Microsoft compiler. Before it became part of the standard in C++11, the Microsoft-specific `__alignof` operator provided this functionality.

> For maximum portability, you should use the [alignof](https://en.cppreference.com/w/c/types) operator instead of the 
GCC-specific `__alignof__` operator or Microsoft-specific `__alignof` operator.

此外，编译器提供的编译配置选项，使得我们有机会修改默认的对齐方式，自行设定变量的对齐方式。

### default alignment

参考上一篇 《[Memory Address Alignment](./address-alignment.md)》 中的 natural alignment 部分。

**MSVC** - [/Zp (Struct Member Alignment)](https://learn.microsoft.com/en-us/cpp/build/reference/zp-struct-member-alignment)：Controls how the members of a structure are packed into memory and specifies the same packing for all structures in a module.

- [x64 ABI conventions](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions#x64-type-and-storage-layout) - [x64 type and storage layout](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions#x64-type-and-storage-layout) - Scalar types alignment

/Zp argument | Effect
------- | -------
1 | Packs structures on 1-byte boundaries. Same as `/Zp`.
2 | Packs structures on 2-byte boundaries.
4 | Packs structures on 4-byte boundaries.
8 | Packs structures on 8-byte boundaries (default for x86, ARM, and ARM64).
16 | Packs structures on 16-byte boundaries (default for x64 and ARM64EC).

> Don't use this option unless you have specific alignment requirements.

在 MSVC Project Settings->C/C++->Struct member alignment 中默认值为 8，可在程序中使用 `#pragma pack` 预处理来指定。

32、64 位下的基本数据类型占用最大空间是 8 字节（sizeof(long long)、sizeof(double)），这个也是自然对齐的最大参数。

!!! warning "Don't change the default alignment"

    The C/C++ headers in the Windows SDK assume the platform's *default* alignment is used. Don't change the setting from the default when you include the Windows SDK headers, either by using `/Zp` on the command line or by using `#pragma pack`. Otherwise, your application may cause memory corruption at runtime.

**GCC** - [Common Variable Attributes](https://gcc.gnu.org/onlinedocs/gcc/Common-Variable-Attributes.html):

As in the preceding examples, you can explicitly specify the alignment (in bytes) that you wish the compiler to use for a given variable or structure field. Alternatively, you can leave out the alignment factor and just ask the compiler to align a variable or field to the default alignment for the target architecture you are compiling for. The default alignment is **fixed** for a particular target ABI.

- pipermail/gcc-help - [default alignment](https://gcc.gnu.org/pipermail/gcc-help/2015-June/124424.html)

[Arm Compiler for Embedded Reference Guide](https://developer.arm.com/documentation/101754/0622/armclang-Reference/Compiler-specific-Function--Variable--and-Type-Attributes/--attribute----aligned---type-attribute):

- For `AArch32`, the default alignment is 8 bytes.
- For `AArch64`, the default alignment is 16 bytes.

### BIGGEST_ALIGNMENT

The default alignment is *sufficient* for all scalar types, but may not be enough for all vector types on a target that supports vector operations.

!!! note "x86 strictest 16-bytes alignment"

    [x86 Assembly/SSE](https://en.wikibooks.org/wiki/X86_Assembly/SSE#SSE2:_Added_with_Pentium_4) - `movapd`: move two 64-bit(double precision) floats, vector is 16 byte aligned. Refer to [Demystifying SSE Move Instructions](https://www.gamedev.net/blog/615/entry-2250281-demystifying-sse-move-instructions/).

    [x64 calling convention](https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention) - [Alignment](https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention#alignment): Most structures are aligned to their natural alignment. The primary exceptions are the stack pointer and `malloc` or `alloca` memory, which are 16-byte aligned to aid performance. Alignment above 16 bytes must be done manually. Since 16 bytes is a common alignment size for **XMM** operations, this value should work for most code. For more information about structure layout and alignment, see [x64 type and storage layout](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions#x64-type-and-storage-layout). For information about the stack layout, see [x64 stack usage](https://learn.microsoft.com/en-us/cpp/build/stack-usage).

[GCC](https://gcc.gnu.org/onlinedocs/gcc/Common-Variable-Attributes.html) also provides a target specific macro `__BIGGEST_ALIGNMENT__`, which is the *largest* alignment ever used for *any* data type on the target machine you are compiling for.

!!! warning "linker limitations for maximal alignment size"

    Note that the effectiveness of aligned attributes for static variables may be limited by inherent limitations in the system linker and/or object file format. On some systems, the linker is only able to arrange for variables to be aligned up to a certain maximum alignment. (For some linkers, the maximum supported alignment may be very very small.) If your linker is only able to align variables up to a maximum of 8-byte alignment, then specifying aligned(16) in an `__attribute__` still only provides you with 8-byte alignment. See your linker documentation for further information.

    Stack variables are not affected by linker restrictions; GCC can properly align them on any target.

可以借助 cpp / gcc -E -dM 预编译，过滤打印出 `__BIGGEST_ALIGNMENT__` 宏定义：

```Shell
$ gcc -dM -E -arch armv7 -x c /dev/null | grep '__BIGGEST_ALIGNMENT__'
$ gcc -dM -E -arch arm -x c /dev/null | grep '__BIGGEST_ALIGNMENT__'
$ gcc -dM -E -arch arm64 -x c /dev/null | grep '__BIGGEST_ALIGNMENT__'
$ gcc -dM -E -arch x86_64 -x c /dev/null | grep '__BIGGEST_ALIGNMENT__'
$ gcc -dM -E -x c /dev/null | grep '__BIGGEST_ALIGNMENT__'
$ echo | cpp -dM | grep '__BIGGEST_ALIGNMENT__'
```

测试结果：

- macOS clang/llvm-gcc ： armv7、arm 下定义为 4；arm64 下定义为 8；x86_64 下定义为 16。
- 在 rpi3b-raspbian/armv7l(armhf? aarch32?) 下定义为 8；在 rpi3b-ubuntu/aarch64 下定义为 16。
- 在 rpi4b-ubuntu/aarch64 下定义为 16。

!!! abstract "std::max_align_t"

    [max_align_t](https://en.cppreference.com/w/c/types/max_align_t)(since C11) is a type whose alignment requirement is at least as strict (as large) as that of every scalar type.

    Pointers returned by allocation functions such as malloc are suitably aligned for *any* object, which means they are aligned at *least* as strictly as `max_align_t`.

    文末测试程序 struct-packed-aligned.c 测得的 `alignof(max_align_t)` 数值同对应平台上的 `__BIGGEST_ALIGNMENT__`。

### gcc/msvc specific

GCC specific [Common Variable Attributes](https://gcc.gnu.org/onlinedocs/gcc/Common-Variable-Attributes.html) 提供了属性修饰声明 `__attribute__`，支持定义变量的存储布局为 `packed`，或通过 `aligned [(n)]` 改变默认对齐字节数。

1. The `packed` attribute specifies that a structure member should have the ***smallest*** possible alignment—one bit for a bit-field and one byte otherwise, unless a larger value is specified with the `aligned` attribute. The attribute *does not* apply to non-member objects.

    - `struct __attribute__((__packed__))` 相当于 `-fpack-struct`，满足 weakest alignment requirement，按 1 字节对齐（*without* holes）。

2. The `aligned` attribute specifies a ***minimum*** alignment for the variable or structure field, measured in bytes. When specified, alignment must be an integer constant power of 2. Specifying *no* alignment argument implies the ***maximum*** alignment for the target, which is often, but by no means always, 8 or 16 bytes.

    - 当 `__attribute__((aligned))` 不指定参数时，相当于采用默认的 default maximum alignment 对齐策略。

[align (C++)](https://learn.microsoft.com/en-us/cpp/cpp/align-cpp?view=msvc-170) - Microsoft Specific

> Use `__declspec(align(n))` to precisely control the alignment of user-defined data (for example, static allocations or automatic data in a function).

```cpp
#define CACHE_LINE  32
#define CACHE_ALIGN __declspec(align(CACHE_LINE))

struct CACHE_ALIGN S1 { // cache align all instances of S1
   int a, b, c, d;
};
struct S1 s1;   // s1 is 32-byte cache aligned

// sizeof(struct S2) = 16
__declspec(align(8)) struct S2 {
   int a, b, c, d;
};

// sizeof(struct S3) = 64.
struct S3 {
   struct S1 s1;   // S3 inherits cache alignment requirement
                  // from S1 declaration
   int a;         // a is now cache aligned because of s1
                  // 28 bytes of trailing padding
};

// sizeof(struct S4) = 64.
struct S4 {
   int a;
   // 28 bytes padding
   struct S1 s1;      // S4 inherits cache alignment requirement of S1
};
```

related topics:

- [c - The advantage of using \_\_attribute\_\_((aligned( )))](https://softwareengineering.stackexchange.com/questions/256179/the-advantage-of-using-attribute-aligned)
- [visual c++ - Cross-platform ALIGN(x) macro?](https://stackoverflow.com/questions/7895869/cross-platform-alignx-macro)

### gcc -fpack-struct

GCC specific [Options for Code Generation Conventions](https://gcc.gnu.org/onlinedocs/gcc/Code-Gen-Options.html) 支持编译选项 `-fpack-struct[=n]` 指定结构体中成员变量的对齐字节数。

> Without a value specified, pack all structure members together *without* holes. When a value is specified (which must be a small power of two), pack structure members according to this value, representing the ***maximum*** alignment (that is, objects with default alignment requirements larger than this are output potentially unaligned at the next fitting location.

当不指定参数时，`-fpack-struct` 相当于 `struct __attribute__((__packed__))`，满足 weakest alignment requirement，按 1 字节对齐。

[Data structure alignment](https://en.wikipedia.org/wiki/Data_structure_alignment): Alternatively, one can ***pack*** the structure, omitting the padding, which may lead to slower access, but uses three quarters as much memory.

### #pragma pack

GCC - [Structure-Layout Pragmas](https://gcc.gnu.org/onlinedocs/gcc/Structure-Layout-Pragmas.html)
[pack pragma | Microsoft Learn](https://learn.microsoft.com/en-us/cpp/preprocessor/pack)

- `#pragma pack(show)`: Displays the current byte value for packing alignment. The value is displayed by a warning message.

`#pragma pack(show)` 测试代码：

```c
#pragma pack(show)

int main(int argc, char *argv[])
{
    return 0;
}
```

macOS（Intel x86_64、Apple Silicon arm64）下 clang/llvm-gcc 编译输出警告：

```Shell
$ cc -S pack-show.c
pack-show.c:1:9: warning: value of #pragma pack(show) == 8
#pragma pack(show)
        ^
1 warning generated.
```

rpi4b-ubuntu/arm64 下 GCC 不支持预编译指令选项 `show`。

---

MSVC 和 GCC 等编译器中都支持通过预编译处理指令 `#pragma pack(n)` 来改变编译器的默认对齐方式。

[pack pragma | Microsoft Learn](https://learn.microsoft.com/en-us/cpp/preprocessor/pack)

> To *pack* a class is to place its members directly after each other in memory. It can mean that some or all members can be aligned on a boundary ***smaller*** than the default alignment of the target architecture. `pack` gives control at the data-declaration level.
> 在 GCC 中，对于 `#pragma pack(n)` 中的结构体而言，相当于 `-fpack-struct[=n]`，指定 ***maximum*** alignment 对齐策略，可能小于默认的对齐参数。

```c
#pragma pack(n)

// to be packed

#pragma pack()
```

在 `#pragma pack(n)` 和 `#pragma pack()` 之间的代码将按 `n` 字节对齐。

成员对齐有一个重要的条件，即每个成员按自己的方式对齐，也就是说虽然指定了按 n 字节对齐，但并不是所有的成员都是以 n 字节对齐。其对齐的规则是：每个成员按其类型的对齐参数（通常是这个类型的大小）和指定对齐参数（这里是n字节）中较小的一个对齐，即 `min(n, sizeof(item))`，并且结构的长度必须为所用过的所有对齐参数的整数倍，不够就填充字节。

1. 如果 n >= sizeof(item)，成员变量按默认的对齐方式，即按照其 size 对齐，结构对齐后的总大小必须是成员中最大的对齐参数的整数倍，这样在处理数组时可以保证每一项都边界对齐。
2. 如果 n < sizeof(item)，成员变量的偏移量取 n 的倍数，不用满足默认的对齐方式，结构的总大小必须为 n 的倍数。

默认 n=8，满足第一种情况的自然对齐；当 n>8，不再有实际影响。

下面举例说明通过 `#pragma pack(n)` 指定 n<8 时，对结构存储布局的影响。

```cpp
#pragma pack(push)
#pragma pack(4)

struct st_cdi
{
    char c;
    double d;
    int i;
};

#pragma pack(pop)
```

1. 首先，为c分配空间，其偏移量为0，满足n=4字节对齐方式，c占1个字节。
2. 其次，为d分配空间，这时其偏移量为1，需填补3个字节，对齐n=4（不必按sizeof(double)=8 对齐），d占8个字节。
3. 最后，为i分配空间，这时其偏移量为12，满足为n=4的倍数，i占4个字节。
4. 三个成员共分配了16个字节，满足为n=4的倍数，故 sizeof(st_cdi) = 16。

如果把 `#pragma pack(4)` 改为 `#pragma pack(16)`，那么结构的大小就是 n>8 自然对齐下的24，相当于不受影响。

## test alignment

以下测试代码 struct-packed-aligned.c，综合测试通过指定 `__attribute__` 和 `#pragma pack` 改变结构体默认的对齐方式。

1. 可执行 `cpp struct-packed-aligned.c`（或 `gcc -E`）查看宏 `DEFINE_STRUCT_PAIR` / `DEFINE_STRUCT_ALIGNED` 的展开结果。

2. DEFINE_STRUCT_PAIR 给结构体定义加上属性限定 `__attribute__((__packed__))` 定义 `StructName##_packed`（MyStruct1_packed，MyStruct2_packed），不考虑成员变量的“地址边界对齐限制”，各成员变量依序自然紧凑排列，其大小是各个成员 sizeof 之和。

3. DEFINE_STRUCT_ALIGNED 指定 `__attribute__((aligned(16)))` 定义 `struct MyStruct4_aligned`，后者必须满足整体大小为 n=16 的倍数，sizeof 测算结果为 32。

    - 参考 [x64 structure alignment examples](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions#x64-structure-alignment-examples)。

??? info "struct-packed-aligned.c"

    ```c linenums="1"
    #include <stddef.h>     // size_t, max_align_t, offsetof
    #include <stdalign.h>   // alignof, alignas
    #include <stdint.h>
    #include <stdio.h>

    struct Readout
    {
        char hour;  // [0:23]
        int value;
        char seq;   // sequence mark ['a':'z']
    };

    // __attribute__ ((__packed__))
    // struct's members are packed closely together,
    // but the internal layout of its s member is not packed
    #define DEFINE_STRUCT_PAIR(StructName, StructBody) \
        struct StructName StructBody \
        struct __attribute__((__packed__)) StructName##_packed StructBody
    #define GET_PACKED_SIZE(StructName) sizeof(struct StructName##_packed)
    #define GET_SIZE(StructName) sizeof(struct StructName)

    // aligned (alignment): specifies a minimum alignment
    #define DEFINE_STRUCT_ALIGNED(n, StructName, StructBody) \
        struct __attribute__((aligned(n))) StructName##_aligned StructBody
    #define GET_ALIGNED_SIZE(StructName) sizeof(struct StructName##_aligned)

    DEFINE_STRUCT_PAIR(MyStruct1, {
        double d;
        char c;
        int i;
    };)

    DEFINE_STRUCT_PAIR(MyStruct2, {
        char c;
        double d;
        int i;
    };)

    #pragma pack(push, 4)
    struct MyStruct3
    {
        char c;
        double d;
        int i;
    };
    #pragma pack(pop)

    DEFINE_STRUCT_ALIGNED(4, MyStruct3, {
        char c;
        double d;
        int i;
    };)

    #pragma pack(push, 16)
    struct MyStruct4
    {
        char c;
        double d;
        int i;
    };
    #pragma pack(pop)

    // on a 16-byte boundary.
    DEFINE_STRUCT_ALIGNED(16, MyStruct4, {
        char c;
        double d;
        int i;
    };)

    int main(int argc, char *argv[])
    {
        printf("sizeof pointer=%zu\n", sizeof(void *));

        printf("alignof(char)=%zu\n", alignof(char));
        printf("alignof(short)=%zu\n", alignof(short));
        printf("alignof(int)=%zu\n", alignof(int));
        printf("alignof(long)=%zu\n", alignof(long));
        printf("alignof(long long)=%zu\n", alignof(long long));
        printf("alignof(double)=%zu\n", alignof(double));

        size_t ma = alignof(max_align_t);
        printf("alignof(max_align_t)=%zu\n", ma);

        puts("----------------------------------------");

        printf("sizeof(Readout)=%zu, alignof(Readout)=%zu\n",
                sizeof(struct Readout), alignof(struct Readout));

        printf("sizeof(MyStruct1)=%zu,%zu, alignof(MyStruct1)=%zu\n",
            GET_PACKED_SIZE(MyStruct1), GET_SIZE(MyStruct1),
            alignof(struct MyStruct1));
        printf("sizeof(MyStruct2)=%zu,%zu, alignof(MyStruct2)=%zu\n",
            GET_PACKED_SIZE(MyStruct2), GET_SIZE(MyStruct2),
            alignof(struct MyStruct2));

        struct MyStruct2 ms2;
        printf("MyStruct2 offsets: c=%zu, d=%zu, i=%zu\n",
            offsetof(struct MyStruct2, c),
            offsetof(struct MyStruct2, d),
            (uintptr_t)&ms2.i - (uintptr_t)&ms2);

        printf("sizeof(MyStruct3): pack(4)=%zu, aligned(4)=%zu\n",
            sizeof(struct MyStruct3),
            GET_ALIGNED_SIZE(MyStruct3));
        printf("alignof(MyStruct3): pack(4)=%zu, aligned(4)=%zu\n",
            alignof(struct MyStruct3),
            alignof(struct MyStruct3_aligned));

        printf("sizeof(MyStruct4): pack(16)=%zu, aligned(16)=%zu\n",
            sizeof(struct MyStruct4),
            GET_ALIGNED_SIZE(MyStruct4));
        printf("alignof(MyStruct4): pack(16)=%zu, aligned(16)=%zu\n",
            alignof(struct MyStruct4),
            alignof(struct MyStruct4_aligned));

        return 0;
    }
    ```

mbpa1398-macOS/x86_64、mbpa2991-macOS/arm64 和 rpi4b-ubuntu/aarch64 LP64 数据模式下输出结果如下：

```Shell
# cc struct-packed-aligned.c -o struct-packed-aligned && ./struct-packed-aligned
$ cc struct-packed-aligned.c -o struct-packed-aligned -g -fno-eliminate-unused-debug-types && ./struct-packed-aligned
sizeof pointer=8
alignof(char)=1
alignof(short)=2
alignof(int)=4
alignof(long)=8
alignof(long long)=8
alignof(double)=8
alignof(max_align_t)=8 (comment: 16 for x86_64 and aarch64)
----------------------------------------
sizeof(Readout)=12, alignof(Readout)=4
sizeof(MyStruct1)=13,16, alignof(MyStruct1)=8
sizeof(MyStruct2)=13,24, alignof(MyStruct2)=8
MyStruct2 offsets: c=0, d=8, i=16
sizeof(MyStruct3): pack(4)=16, aligned(4)=24
alignof(MyStruct3): pack(4)=4, aligned(4)=8
sizeof(MyStruct4): pack(16)=24, aligned(16)=32
alignof(MyStruct4): pack(16)=8, aligned(16)=16
```

### interpretation

**运行调试**：

1. 编译添加 `-g` 选项生成调试信息，添加 `-fno-eliminate-unused-debug-types`；
2. `gdb struct-packed-aligned` 进入 GDB Console，执行 `start` 启动运行。

**结果分析**：

1. struct Readout、MyStruct1、MyStruct2，采用 default natural alignment 对齐策略，遵循“地址边界对齐限制”。

    !!! info "gdb ptype /o MyStruct3"

        ```Shell
        (gdb) ptype /o struct Readout
        /* offset      |    size */  type = struct Readout {
        /*      0      |       1 */    char hour;
        /* XXX  3-byte hole      */
        /*      4      |       4 */    int value;
        /*      8      |       1 */    char seq;
        /* XXX  3-byte padding   */

                                    /* total size (bytes):   12 */
                                    }
        (gdb) ptype /o struct MyStruct1
        /* offset      |    size */  type = struct MyStruct1 {
        /*      0      |       8 */    double d;
        /*      8      |       1 */    char c;
        /* XXX  3-byte hole      */
        /*     12      |       4 */    int i;

                                    /* total size (bytes):   16 */
                                    }
        (gdb) ptype /o struct MyStruct2
        /* offset      |    size */  type = struct MyStruct2 {
        /*      0      |       1 */    char c;
        /* XXX  7-byte hole      */
        /*      8      |       8 */    double d;
        /*     16      |       4 */    int i;
        /* XXX  4-byte padding   */

                                    /* total size (bytes):   24 */
                                    }
        ```

2. 对于 MyStruct3：`#pragma pack(4)`，指定 maximum alignment=4 < default，alignof=min{n, default}=n=4，d 不遵从自然对齐，sizeof=16。

    !!! info "gdb ptype /o MyStruct3"

        ```Shell
        (gdb) ptype /o struct MyStruct3
        /* offset      |    size */  type = struct MyStruct3 {
        /*      0      |       1 */    char c;
        /* XXX  3-byte hole      */
        /*      4      |       8 */    double d;
        /*     12      |       4 */    int i;

                                    /* total size (bytes):   16 */
                                    }
        ```

3. 对于 MyStruct3_aligned (4)：指定 minimum alignment=4 < default，alignof=max{n, default}=default=8，结构体按自然对齐，sizeof=24。

    !!! info "gdb ptype /o MyStruct3_aligned"

        ```Shell
        (gdb) ptype /o struct MyStruct3_aligned
        /* offset      |    size */  type = struct MyStruct3_aligned {
        /*      0      |       1 */    char c;
        /* XXX  7-byte hole      */
        /*      8      |       8 */    double d;
        /*     16      |       4 */    int i;
        /* XXX  4-byte padding   */

                                    /* total size (bytes):   24 */
                                    }
        ```

4. 对于 MyStruct4：`#pragma pack(16)`，指定 maximum alignment=16 > default，alignof=min{n, default}=default=8，结构体按自然对齐，sizeof=24。

    !!! info "gdb ptype /o MyStruct4"

        ```Shell
        (gdb) ptype /o struct MyStruct4
        /* offset      |    size */  type = struct MyStruct4 {
        /*      0      |       1 */    char c;
        /* XXX  7-byte hole      */
        /*      8      |       8 */    double d;
        /*     16      |       4 */    int i;
        /* XXX  4-byte padding   */

                                    /* total size (bytes):   24 */
                                    }
        ```

5. 对于 MyStruct4_aligned (16)：指定 minimum alignment=16 > default，alignof=max{n, default}=n=16，结构体按自然对齐，并且总大小必须为 16 的倍数，故 sizeof=32。

    !!! info "gdb ptype /o MyStruct4_aligned"

        ```Shell
        (gdb) ptype /o struct MyStruct4_aligned
        /* offset      |    size */  type = struct MyStruct4_aligned {
        /*      0      |       1 */    char c;
        /* XXX  7-byte hole      */
        /*      8      |       8 */    double d;
        /*     16      |       4 */    int i;
        /* XXX 12-byte padding   */

                                    /* total size (bytes):   32 */
                                    }
        ```

## refs

[C Structure Padding Initialization](https://interrupt.memfault.com/blog/c-struct-padding-initialization)
[How Struct Memory Alignment Works in C](https://levelup.gitconnected.com/how-struct-memory-alignment-works-in-c-3ee897697236)  

[Computer Systems - A Programmer’s Perspective](https://www.amazon.com/Computer-Systems-OHallaron-Randal-Bryant/dp/1292101768/) - 3.9.3: Data Alignment

[老码识途-从机器码到框架的系统观逆向修炼之路-2012](https://book.douban.com/subject/19930393/) - 1.5 无法沟通——对齐的错误
