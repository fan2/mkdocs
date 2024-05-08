---
title: Memory Address Alignment
authors:
  - xman
date:
    created: 2021-10-12T10:00:00
    updated: 2024-05-02T12:00:00
categories:
    - CS
tags:
    - alignment
    - word_boundary
    - misalignment
comments: true
---

One of the low-level features of C/C++ is the ability to specify the precise alignment of objects in memory to take maximum advantage of a specific hardware architecture. By default, the compiler **aligns** class and struct members on their size value.

<!-- more -->

[Alignment and memory addresses](https://learn.microsoft.com/en-us/cpp/cpp/alignment-cpp-declarations#alignment-and-memory-addresses)

Alignment is a property of a memory address, expressed as the numeric address modulo a power of 2. For example, the address `0x0001103F` modulo 4 is 3. That address is said to be aligned to $4n+3$, where 4 indicates the chosen power of 2. The alignment of an address depends on the chosen power of 2. The same address modulo 8 is 7. An address is said to be aligned to X if its alignment is $Xn+0$.

CPUs execute instructions that operate on data stored in memory. The data are identified by their addresses in memory. A single datum also has a size. We call a datum ***naturally aligned*** if its address is aligned to its size. It's called ***misaligned*** otherwise. For example, an 8-byte floating-point datum is naturally aligned if the address used to identify it has an 8-byte alignment.

---

[Data structure alignment](https://en.wikipedia.org/wiki/Data_structure_alignment) is the way data is arranged and accessed in computer memory. It consists of three separate but related issues: `data alignment`, `data structure padding`, and `packing`.

The CPU in modern computer hardware performs reads and writes to memory most efficiently when the data is *naturally aligned*, which generally means that the data's memory address is a *multiple* of the data size. For instance, in a 32-bit architecture, the data may be aligned if the data is stored in four consecutive bytes and the first byte lies on a 4-byte boundary.

*Data alignment* is the aligning of elements according to their natural alignment. To ensure natural alignment, it may be necessary to insert some *padding* between structure elements or after the last element of a structure. For example, on a 32-bit machine, a data structure containing a 16-bit value followed by a 32-bit value could have 16 bits of padding between the 16-bit value and the 32-bit value to align the 32-bit value on a 32-bit boundary. Alternatively, one can *pack* the structure, omitting the padding, which may lead to slower access, but uses three quarters as much memory.

## reasons

[Data structure alignment - Problems](https://en.wikipedia.org/wiki/Data_structure_alignment#Problems):

The CPU accesses memory by a single memory word at a time. As long as the memory word size is at least as large as the largest primitive data type supported by the computer, **aligned** accesses will always access a *single* memory word. This may not be true for **misaligned** data accesses.

If the highest and lowest bytes in a datum are not within the same memory word the computer must split the datum access into multiple memory accesses. This requires a lot of complex circuitry to generate the memory accesses and coordinate them. To handle the case where the memory words are in different memory pages the processor must either verify that both pages are present before executing the instruction or be able to handle a *TLB miss* or a *page fault* on any memory access during the instruction execution.

《[C语言标准与实现(姚新颜)-2004](https://att.newsmth.net/nForum/att/CProgramming/3213/245)》 #1基础知识 | 11 内存地址对齐：

以P6处理器为例，使数据的地址按一定的边界对齐主要有三方面的考虑：

1. **提高效率**：P6处理器读/写内存中的数据需要一个或数个内存总线周期，对于8位数据，处理器一个周期就可以访问完毕；对于16位数据，如果数据的地址是2字节对齐（被2整除），P6 处理器耗费一个总线周期就可以访问完毕；如果不是双字节对齐，但只要它的地址没有横跨在相邻两个对齐的32位数据地址上，则处理器仍然只需一个内存总线周期就可完成操作，否则处理器需要两个周期才能完成操作；对于32位数据，如果数据的地址是4字节对齐（被4整除）的话，P6处理器耗费一个总线周期就可以访问完毕，否则需要两个周期进行操作；对于64位数据，如果数据的地址是8字节对齐（被8整除）的话，P6处理器耗费一个总线周期就可以访问完毕，否则需要两个周期进行操作。可见，对于最常用的32/64位数据，访问地址对齐的数据比访问地址没有对齐的数据在理论上节省50%的时间，因此，我们可以看到 gcc 在默认情况下生成的汇编代码总是把数据按照对应的对齐规则指示链接程序安排适当的地址。

2. **指令要求**：某些 SSE、SSE2 指令要求内存操作数的地址必须是16字节对齐的，否则就引发异常。Pentium III 处理器开始支持 SSE 指令，Pentium 4处理器开始支持 SSE2 指令， 而这些指令的其中一部分需要地址是16字节对齐的内存操作数，例如：`movdqa`（SSE 指令）、`movapd`（SSE2指令）。当使用这些指令并且其中一个操作数是内存操作数时，内存操作数的地址必须满足16字节对齐，否则处理器引发13号异常。

3. 保证对内存的访问是**原子操作**（atomic operation）。在多处理器环境下，为了保证各个处理器对内存操作的正确性，系统必须确保某些读/写操作在一个内存总线周期内完成。从前面我们已经知道，对于地址满足适当对齐条件的16/32/64位数据，P6处理器均可以在一个内存总线周期内完成访问，这很自然地满足原子操作的要求。如果数据地址不满足对应的对齐条件，那么处理器必须用2个内存总线周期才能完成读/写操作，万一在这两个周期之间其它处理器刚好获得总线的使用权并且在随后的连续两个周期内访问到该数据，则该访问的结果将是不正确的。虽然P6处理器可以使用 LOCK 命令前缀在一条指令执行完毕之前锁住总线的使用权，但 LOCK 前缀的使用范围有限，并不是所有指令都可以加上 LOCK 前缀，例如最常见的 `MOV` 指令就不能使用 LOCK 前缀。因此，要保证数据的完整性，最好让数据的地址按照适当的规则对齐从而保证处理器访问内存是原子操作。

《[现代C++语言核心特性解析-2021](https://item.jd.com/12942311.html)》 - 第30章 alignas 和 alignof：

一个类型的属性除了其数据长度，还有一个重要的属性——数据对齐的字节长度。

为什么我们需要数据对齐呢？原因说起来很简单，就是硬件需要。

首当其冲的就是**CPU**了，CPU对数据对齐有着迫切的需求，一个好的对齐字节长度可以让CPU运行起来更加轻松快速。反过来说，不好的对齐字节长度则会让CPU运行速度减慢，甚至抛出错误。通常来说所谓好的对齐长度和CPU访问数据总线的宽度有关系，比如CPU访问32位宽度的数据总线，就会期待数据是按照32位对齐，也就是4字节。这样CPU读取4字节的数据只需要对总线访问一次，但是如果要访问的数据并没有按照4字节对齐，那么CPU需要访问数据总线两次，运算速度自然也就减慢了。另外，对于数据对齐问题引发错误的情况（Alignment Fault），通常会发生在ARM架构的计算机上。当然除了CPU之外，还有**其他硬件**也需要数据对齐，比如通过DMA访问硬盘，就会要求内存必须是4K对齐的。

总的来说，配合现代编译器和CPU架构，可以让程序获得令人难以置信的性能，但这种良好的性能取决于某些编程实践，其中一种编程实践是正确的数据对齐。

[Computer Systems - A Programmer’s Perspective](https://www.amazon.com/Computer-Systems-OHallaron-Randal-Bryant/dp/1292101768/) - 3.9.3: Data Alignment:

Many computer systems place restrictions on the allowable addresses for the primitive data types, requiring that the address for some objects must be a multiple of some value $K$ (typically 2, 4, or 8). Such ***alignment restrictions*** simplify the design of the hardware forming the interface between the processor and the memory system.

For example, suppose a processor always fetches 8 bytes from memory with an address that must be a multiple of 8. If we can guarantee that any `double` will be aligned to have its address be a multiple of 8, then the value can be read or written with a *single* memory operation. Otherwise, we may need to perform *two* memory accesses, since the object might be split across two 8-byte memory blocks.

## natural alignment

[Computer Systems - A Programmer’s Perspective](https://www.amazon.com/Computer-Systems-OHallaron-Randal-Bryant/dp/1292101768/) - 3.9.3: Data Alignment:

The x86-64 hardware will work correctly regardless of the alignment of data. However, Intel recommends that data be aligned to improve memory system performance. Their alignment rule is based on the principle that any primitive object of $K$ bytes must have an *address* that is a multiple of $K$. We can see that this rule leads to the following alignments:

K | Types
--|------
1 | char
2 | short
4 | int, float
8 | long, double, char *

Alignment is **enforced** by making sure that every data type is organized and allocated in such a way that every object within the type **satisﬁes** its alignment restrictions.

[ARM Compiler v5.06 for uVision armcc User Guide](https://developer.arm.com/documentation/dui0375/g/C-and-C---Implementation-Details/Basic-data-types-in-ARM-C-and-C--) ｜ Basic data types in ARM C and C++
 - Size and alignment of basic data types

- The following table gives the size and natural alignment of the basic data types under ILP32 data model.

[ILP32 and LP64 data models.PDF](https://scc.ustc.edu.cn/zlsc/czxt/200910/W020100308601263456982.pdf) - HP-UX 64-bit data model list ILP32 and LP64 data alignment:

![ILP32-LP64-data-alignment](./images/alignment/ILP32-LP64-data-alignment.png)

## x86 misalignment

The x86-64 hardware will work correctly regardless of the alignment of data.

[Are machine code instructions fetched in little endian 4-byte words on an Intel x86-64 architecture?](
https://stackoverflow.com/a/68229991/3721132)

x86 machine code is a [byte-stream](https://stackoverflow.com/questions/60905135/how-to-interpret-objdump-disassembly-output-columns); there's nothing word-oriented about it, except for 32-bit displacements and immediates which are little-endian. e.g. in `add qword [rdi + 0x1234], 0xaabbccdd`. It's physically fetched in 16-byte or 32-byte chunks on modern CPUs, and split on instruction boundaries in parallel to feed to decoders in parallel.

x86-64 is not a word-oriented architecture; there is no single natural word-size, and things **don't** have to be aligned. That concept is not very useful when thinking about x86-64. The integer register width happens to be 8 bytes, but that's not even the default operand-size in machine code, and you can use any operand-size from byte to qword with most instructions, and for SIMD from 8 or 16 byte up to 32 or 64 byte. And most importantly, alignment of wider integers isn't required in machine code, or even for data.

[assembly - What's the size of a QWORD on a 64-bit machine? - Stack Overflow](https://stackoverflow.com/a/55430777/3721132)

The whole concept of "machine word" [doesn't really apply to x86](https://stackoverflow.com/questions/68229585/are-machine-code-instructions-fetched-in-little-endian-4-byte-words-on-an-intel/68229991#68229991), with its machine-code format being a byte stream, and equal support for multiple operand-sizes, and unaligned loads/stores that mostly **don't** care about naturally aligned stuff, only cache line boundaries for normal cacheable memory.

[Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/) - 12 The C memory model | 12.7 Alignment:

Some architectures are more tolerant of **misalignment** than others, and we might have to force the system to error out on such a condition. We use the following function at the beginning to force crashing:

!!! note "enable alignment check for i386 processors"

    Intel’s i386 processor family is quite tolerant in accepting misalignment of data. This can lead to irritating bugs when ported to other architectures that are not as tolerant.

    This function enables a check for this problem also for this family or processors, such that you can be sure to detect this problem early.

    I found that code on [Ygdrasil’s blog](http://orchistro.tistory.com/206): `void enable_alignment_check(void);`.

## C alignment

Excerpt from [Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/).

**12 The C memory model | 12.7 Alignment**

The inverse direction of pointer conversions (from “pointer to character type” to “pointer to object”) is not harmless at all, and not only because of possible aliasing. This has to do with another property of C’s memory model: ***alignment***. Objects of most non-character types can’t start at any *arbitrary* byte position; they usually start at a ***word boundary***. The alignment of a type then describes the possible byte positions at which an object of that type can start.

If we force some data to a false alignment, really bad things can happen.

The program crashes with an error indicated as a ***bus error***, which is a shortcut for something like “data bus alignment error.”

As you can see in the output, above, it seems that `complex double` still works well for alignments of half of its size, but then with an alignment of one fourth, the program crashes.

---

In the previous code example, we also see a new operator, `alignof` (or `_Alignof`, if you don’t include [<stdalign.h\>](https://en.cppreference.com/w/c/types)), that provides us with the alignment of a speciﬁc type. You will rarely ﬁnd the occasion to use it in real live code.

Another keyword can be used to force allocation at a speciﬁed alignment: `alignas` (respectively, `_Alignas`). Its argument can be either a type or expression. It can be useful where you know that your platform can perform certain operations more efﬁciently if the data is aligned in a certain way.

## C++ alignment

### ISO/IEC-N4950

20230510 - [ISO/IEC-N4950](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf)

6 Basics | 6.7 Memory and objects | **6.7.6 Alignment**

1. Object types have *alignment requirements* (6.8.2, 6.8.4) which place restrictions on the addresses at which an object of that type may be allocated. An ***alignment*** is an implementation-defined integer value representing the number of bytes between successive addresses at which a given object can be allocated. An object type imposes an alignment requirement on every object of that type; stricter alignment can be requested using the alignment specifier (9.12.2).

2. A *fundamental alignment* is represented by an alignment less than or equal to the greatest alignment supported by the implementation in all contexts, which is equal to `alignof(std::max_align_t)` (17.2). The alignment required for a type may be different when it is used as the type of a complete object and when it is used as the type of a subobject.

    - The result of the `alignof` operator reflects the alignment requirement of the type in the complete-object case.

6. The alignment requirement of a complete type can be queried using an `alignof` expression (7.6.2.6). Furthermore, the narrow character types (6.8.2) shall have the *weakest* alignment requirement.

    - This enables the ordinary character types to be used as the underlying type for an aligned memory area (9.12.2).

---

**related sections**:

- 7 Expressions | 7.6 Compound expressions | 7.6.2 Unary expressions | 7.6.2.6 Alignof
- 9 Declarations | 9.12 Attributes | 9.12.2 Alignment specifier
- 17 Language support library | 17.2 Common definitions | 17.2.4 Sizes, alignments, and offsets

### language support

《[现代C++语言核心特性解析-2021](https://item.jd.com/12942311.html)》 - 第30章 alignas 和 alignof

C++11中新增了 `alignof` 和 `alignas` 两个关键字，其中 `alignof` 运算符可以用于获取类型的对齐字节长度，`alignas` 说明符可以用来改变类型的默认对齐字节长度。这两个关键字的出现解决了长期以来C++标准中无法对数据对齐进行处理的问题。

`alignof` 运算符和前面提到的编译器扩展关键字 `__alignof`、`__alignof__` 用法相同，都是获得类型的对齐字节长度。

C++标准规定 `alignof` 必须是针对类型的。不过 GCC 扩展了这条规则，`alignof` 除了能接受一个类型外还能接受一个变量。使用MSVC的读者如果想获得变量的对齐，不妨使用编译器的扩展关键字 `__alignof`。

另外，还可以通过 `alignof` 获得类型 `std::max_align_t` 的对齐字节长度，这是一个非常重要的值。

C++11 [<stddef.h\>](https://en.cppreference.com/w/c/types) 定义了 `std::max_align_t`，它是一个平凡的标准布局类型，其对齐字节长度要求至少与每个标量类型一样严格。也就是说，所有的标量类型都适应 `std::max_align_t` 的对齐字节长度。

C++ 标准还规定，诸如 `new` 和 `malloc` 之类的分配函数返回的指针需要适合于任何对象，也就是说内存地址至少与 `std::max_align_t` 严格对齐。

由于 C++ 标准并没有定义 `std::max_ align_t` 对齐字节长度具体是什么样的，因此不同的平台会有不同的值，通常情况下是8字节和16字节。
