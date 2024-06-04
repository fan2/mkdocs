---
title: Struct Alignment Specify
authors:
  - xman
date:
    created: 2021-10-13T11:00:00
    updated: 2024-05-04T12:00:00
categories:
    - CS
    - c
    - cpp
tags:
    - struct
    - alignment
comments: true
---

在上一篇《[Struct Alignment Rule](./struct-alignment.md)》中，我们梳理了结构体存储布局的“地址边界对齐限制”规则。
本篇介绍通过编译器 gcc/msvc 提供的扩展特性及 C/C++ 提供的一些语言特性来修改默认的对齐参数，并测试分析其作用效果。

1. The `packed` attribute specifies that a structure member should have the *smallest* possible alignment.
2. The `aligned` attribute specifies a *minimum* alignment for the variable or structure field, measured in bytes.
3. `-fpack-struct[=n]`/`#pragma pack(n)` specifies the *maximum* alignment, structure members can potentially be *unaligned*.

<!-- more -->

## gcc/msvc align spec

GCC specific [Common Variable Attributes](https://gcc.gnu.org/onlinedocs/gcc/Common-Variable-Attributes.html) 提供了属性修饰声明 `__attribute__`，支持定义变量的存储布局为 `packed`，或通过 `aligned [(n)]` 改变默认对齐字节数。

1. The `packed` attribute specifies that a structure member should have the ***smallest*** possible alignment—one bit for a bit-field and one byte otherwise, unless a larger value is specified with the `aligned` attribute. The attribute *does not* apply to non-member objects.

    - `struct __attribute__((__packed__))` 相当于 `-fpack-struct`，开启 Packed alignment mode，按 1 字节对齐（*without* holes），satisfies weakest alignment requirement。

2. The `aligned` attribute specifies a ***minimum*** alignment for the variable or structure field, measured in bytes. When specified, alignment must be an integer constant power of 2. Specifying *no* alignment argument implies the ***maximum*** alignment for the target, which is often, but by no means always, 8 or 16 bytes.

    - 当 `__attribute__((aligned))` 不指定参数时，相当于 Natural alignment mode，采用默认的 default maximum alignment 对齐策略。

[align (C++)](https://learn.microsoft.com/en-us/cpp/cpp/align-cpp?view=msvc-170) - Microsoft Specific

> Use `__declspec(align(n))` to precisely control the alignment of user-defined data (for example, static allocations or automatic data in a function).

- 参考 [x64 structure alignment examples](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions#x64-structure-alignment-examples)。

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

## gcc -fpack-struct

GCC specific [Options for Code Generation Conventions](https://gcc.gnu.org/onlinedocs/gcc/Code-Gen-Options.html) 支持编译选项 `-fpack-struct[=n]` 指定结构体中成员变量的对齐字节数。

> Without a value specified, pack all structure members together *without* holes. When a value is specified (which must be a small power of two), pack structure members according to this value, representing the ***maximum*** alignment (that is, objects with default alignment requirements larger than this are output potentially **unaligned** at the next fitting location).

当不指定参数时，`-fpack-struct` 相当于 `struct __attribute__((__packed__))`，满足 weakest alignment requirement，按 1 字节对齐。

> [Data structure alignment](https://en.wikipedia.org/wiki/Data_structure_alignment): Alternatively, one can ***pack*** the structure, omitting the padding, which may lead to slower access, but uses three quarters as much memory.

## #pragma pack

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

Win10/x86_64 下 msvc 2022 32/64 编译输出警告：

```Shell
# vcvars32.bat
>cl /c pack-show.c
用于 x86 的 Microsoft (R) C/C++ 优化编译器 19.39.33523 版
版权所有(C) Microsoft Corporation。保留所有权利。

pack-show.c
pack-show.c(1): warning C4810: pragma pack(show) 的值 == 8

# vcvars64.bat
>cl /c pack-show.c
用于 x64 的 Microsoft (R) C/C++ 优化编译器 19.39.33523 版
版权所有(C) Microsoft Corporation。保留所有权利。

pack-show.c
pack-show.c(1): warning C4810: pragma pack(show) 的值 == 16
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

以下测试代码 struct-packed-aligned.c，综合测试通过指定 `__attribute__` 和 `#pragma pack` 改变结构体默认对齐方式的作用效果。

关于跨平台设置 packed 和 aligned 属性，参考：

- [c - The advantage of using \_\_attribute\_\_((aligned( )))](https://softwareengineering.stackexchange.com/questions/256179/the-advantage-of-using-attribute-aligned)
- [Visual C++ equivalent of GCC's \_\_attribute\_\_ ((\_\_packed\_\_))](https://stackoverflow.com/questions/1537964/visual-c-equivalent-of-gccs-attribute-packed)
- [visual c++ - Cross-platform ALIGN(x) macro?](https://stackoverflow.com/questions/7895869/cross-platform-alignx-macro)

### Program

1. 可执行 `cpp struct-packed-aligned.c`（或 `gcc -E`）查看宏 `PACK` 包裹 / `ALIGN` 修饰定义的结构体。

2. `PACK` 宏包裹定义的结构体不考虑成员变量的“地址边界对齐限制”，各成员变量依序自然紧凑排列，其大小是各个成员 sizeof 之和。

3. `ALIGN` 宏修饰的结构体，指定对齐参数 n，必须满足整体大小为 n 的倍数。

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
    #if defined(__GNUC__) || defined(__clang__)
    #  define PACK( __Declaration__ ) __Declaration__ __attribute__((__packed__))
    #elif defined(_MSC_VER)
    #  define PACK( __Declaration__ ) __pragma( pack(push, 1) ) __Declaration__ __pragma( pack(pop))
    #else
    #  error "Unknown compiler; can't define PACK"
    #endif

    // aligned (alignment): specifies a minimum alignment
    #if defined(__GNUC__) || defined(__clang__)
    #  define ALIGN(n) __attribute__ ((aligned(n)))
    #elif defined(_MSC_VER)
    #  define ALIGN(n) __declspec(align(n))
    #else
    #  error "Unknown compiler; can't define ALIGN"
    #endif

    // use alignof instead for maximum portability
    // #if defined(__GNUC__) || defined(__clang__)
    // #  define ALIGNOF(X) __alignof__(X)
    // #elif defined(_MSC_VER)
    // #  define ALIGNOF(X) __alignof(X)
    // #else
    // #  error "Unknown compiler; can't define ALIGNOF"
    // #endif

    #define GET_SIZE(StructName) sizeof(struct StructName)
    #define GET_PACKED_SIZE(StructName, n) sizeof(struct StructName##_pack_##n)
    #define GET_ALIGNED_SIZE(StructName, n) sizeof(struct StructName##_align_##n)

    #define DCI { double d; char c; int i; }
    #define CDI { char c; double d; int i; }

    struct st_dci DCI;
    PACK(struct st_dci_pack_1 DCI);

    struct st_cdi CDI;
    PACK(struct st_cdi_pack_1 CDI);

    #pragma pack(push, 4)
    struct st_cdi_pack_4 CDI;
    #pragma pack(pop)
    struct ALIGN(4) st_cdi_align_4 CDI;

    #pragma pack(push, 16)
    struct st_cdi_pack_16 CDI;
    #pragma pack(pop)
    struct ALIGN(16) st_cdi_align_16 CDI;

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

        printf("sizeof(st_dci)=%zu,%zu, alignof(st_dci)=%zu\n",
            GET_PACKED_SIZE(st_dci, 1), GET_SIZE(st_dci),
            alignof(struct st_dci));
        printf("sizeof(st_cdi)=%zu,%zu, alignof(st_cdi)=%zu\n",
            GET_PACKED_SIZE(st_cdi, 1), GET_SIZE(st_cdi),
            alignof(struct st_cdi));

        struct st_cdi st;
        printf("st_cdi offsets: c=%zu, d=%zu, i=%zu\n",
            offsetof(struct st_cdi, c),
            offsetof(struct st_cdi, d),
            (uintptr_t)&st.i - (uintptr_t)&st);

        printf("sizeof(st_cdi): pack(4)=%zu, align(4)=%zu\n",
            GET_PACKED_SIZE(st_cdi, 4),
            GET_ALIGNED_SIZE(st_cdi, 4));
        printf("alignof(st_cdi): pack(4)=%zu, align(4)=%zu\n",
            alignof(struct st_cdi_pack_4),
            alignof(struct st_cdi_align_4));

        printf("sizeof(st_cdi): pack(16)=%zu, align(16)=%zu\n",
            GET_PACKED_SIZE(st_cdi, 16),
            GET_ALIGNED_SIZE(st_cdi, 16));
        printf("alignof(st_cdi): pack(16)=%zu, align(16)=%zu\n",
            alignof(struct st_cdi_pack_16),
            alignof(struct st_cdi_align_16));

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
sizeof(st_dci)=13,16, alignof(st_dci)=8
sizeof(st_cdi)=13,24, alignof(st_cdi)=8
st_cdi offsets: c=0, d=8, i=16
sizeof(st_cdi): pack(4)=16, align(4)=24
alignof(st_cdi): pack(4)=4, align(4)=8
sizeof(st_cdi): pack(16)=24, align(16)=32
alignof(st_cdi): pack(16)=8, align(16)=16
```

MSVC 2022 设置 vcvars64.bat，编译 `cl /std:c11 struct-packed-aligned.c && struct-packed-aligned.exe`，测试结果区别：

1. LLP64 数据模型下，alignof(long)=4
2. E0020: 未定义标识符 "max\_align\_t"
3. C4359: “st\_cdi\_align\_4”: 对齐说明符小于实际对齐方式(8)，将被忽略。
4. 其他测试结果相同。

### Interpretation

**运行调试**：

1. 编译添加 `-g` 选项生成调试信息，添加 `-fno-eliminate-unused-debug-types`；
2. `gdb struct-packed-aligned` 进入 GDB Console，执行 `start` 启动运行。

**结果分析**：

1. struct Readout、st_dci、st_cdi，采用 default natural alignment 对齐策略，遵循“地址边界对齐限制”。

    !!! info "gdb ptype /o "

        ```Shell
        # pwndbg> dt struct\ Readout
        (gdb) ptype /o struct Readout
        /* offset      |    size */  type = struct Readout {
        /*      0      |       1 */    char hour;
        /* XXX  3-byte hole      */
        /*      4      |       4 */    int value;
        /*      8      |       1 */    char seq;
        /* XXX  3-byte padding   */

                                    /* total size (bytes):   12 */
                                    }
        # pwndbg> dt struct\ st_dci
        (gdb) ptype /o struct st_dci
        /* offset      |    size */  type = struct st_dci {
        /*      0      |       8 */    double d;
        /*      8      |       1 */    char c;
        /* XXX  3-byte hole      */
        /*     12      |       4 */    int i;

                                    /* total size (bytes):   16 */
                                    }
        # pwndbg> dt struct\ st_cdi
        (gdb) ptype /o struct st_cdi
        /* offset      |    size */  type = struct st_cdi {
        /*      0      |       1 */    char c;
        /* XXX  7-byte hole      */
        /*      8      |       8 */    double d;
        /*     16      |       4 */    int i;
        /* XXX  4-byte padding   */

                                    /* total size (bytes):   24 */
                                    }
        ```

2. 对于 st_cdi_pack_4：指定 maximum alignment=4 < default，alignof=min{n, default}=n=4，d 不遵从自然对齐，sizeof=16。

    !!! info "gdb ptype /o st_cdi_pack_4"

        ```Shell
        (gdb) ptype /o struct st_cdi_pack_4
        /* offset      |    size */  type = struct st_cdi_pack_4 {
        /*      0      |       1 */    char c;
        /* XXX  3-byte hole      */
        /*      4      |       8 */    double d;
        /*     12      |       4 */    int i;

                                    /* total size (bytes):   16 */
                                    }
        ```

3. 对于 st_cdi_align_4：指定 minimum alignment=4 < default，alignof=max{n, default}=default=8，结构体按自然对齐，sizeof=24。

    !!! info "gdb ptype /o st_cdi_align_4"

        ```Shell
        (gdb) ptype /o struct st_cdi_align_4
        /* offset      |    size */  type = struct st_cdi_align_4 {
        /*      0      |       1 */    char c;
        /* XXX  7-byte hole      */
        /*      8      |       8 */    double d;
        /*     16      |       4 */    int i;
        /* XXX  4-byte padding   */

                                    /* total size (bytes):   24 */
                                    }
        ```

4. 对于 st_cdi_pack_16：指定 maximum alignment=16 > default，alignof=min{n, default}=default=8，结构体按自然对齐，sizeof=24。

    !!! info "gdb ptype /o st_cdi_pack_16"

        ```Shell
        (gdb) ptype /o struct st_cdi_pack_16
        /* offset      |    size */  type = struct st_cdi_pack_16 {
        /*      0      |       1 */    char c;
        /* XXX  7-byte hole      */
        /*      8      |       8 */    double d;
        /*     16      |       4 */    int i;
        /* XXX  4-byte padding   */

                                    /* total size (bytes):   24 */
                                    }
        ```

5. 对于 st_cdi_align_16：指定 minimum alignment=16 > default，alignof=max{n, default}=n=16，结构体按自然对齐，并且总大小必须为 16 的倍数，故 sizeof=32。

    !!! info "gdb ptype /o st_cdi_align_16"

        ```Shell
        (gdb) ptype /o struct st_cdi_align_16
        /* offset      |    size */  type = struct st_cdi_align_16 {
        /*      0      |       1 */    char c;
        /* XXX  7-byte hole      */
        /*      8      |       8 */    double d;
        /*     16      |       4 */    int i;
        /* XXX 12-byte padding   */

                                    /* total size (bytes):   32 */
                                    }
        ```
