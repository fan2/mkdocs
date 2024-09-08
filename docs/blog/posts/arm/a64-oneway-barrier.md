---
title: ARM64 One-Way Barriers
authors:
    - xman
date:
    created: 2023-10-07T11:00:00
categories:
    - arm
tags:
    - LDAR
    - STLR
comments: true
---

In the previous article [ARM64 Memory Barriers](./a64-memory-barrier.md), we systematically sorted out and summarized common memory barrier instructions.

AArch64 adds new *load* and *store* instructions with implicit barrier semantics. These require that all loads and stores before or after the implicit barrier are **observed** in program order.

<!-- more -->

The ARMv8 instruction set also supports load and store instructions with implicit memory barrier primitives. These memory barrier primitives affect the execution order of load and store instructions. Their impact on the execution order is *unidirectional*.

- `acquire` barrier primitive: read and write operations after this barrier primitive cannot be reordered *before* this barrier primitive. Usually, this barrier primitive is combined with `load` instructions.
- `release` barrier primitive: read and write operations before this barrier primitive cannot be reordered *after* this barrier primitive. Usually, this barrier primitive is combined with `store` instructions.

## Load-Acquire (LDAR)

The ordering requirements that are imposed by the Load-Acquire `LDAR` instruction are as follows:

- All explicit memory accesses after the `LDAR` are observed ***after*** the `LDAR`.
- All explicit memory accesses before the `LDAR` are not affected, and are reordered regarding the `LDAR`.

![LDAR ordering requirements](https://documentation-service.arm.com/static/62a304f231ea212bb662321f)

All loads and stores that are *after* an `LDAR` in program order, and that match the shareability domain of the target address, must be observed *after* the `LDAR`.

```text
// read after write

                  +------+
                  | STR1 |------------+
                  | LDR1 |            |
                  +------+            |
                                      |
                                      |
--------------------------------------|-----
           ⚡️ Load-Acquire (LDAR) ⚡️    |
--------------------------------------|-----
        ↑                             |
        |                             |
        |         +------+            |
        |         | STR2 |            |
        +---------| LDR2 |            |
                  +------+            |
                                      ↓
```

STR1/LDR1 *can* be reordered across the `LDAR` barrier forwards, but STR2/LDR2 after `LDAR` *can't* be reordered across the `LDAR` barrier backwards.

## Store-Release (STLR)

The ordering requirements that are imposed by Store-Release `STLR` instruction are as follows:

- All explicit memory accesses before the `STLR` are observed ***before*** the `STLR`.
- All explicit memory accesses after the `STLR` are not affected, and are reordered regarding the `STLR`.

![STLR ordering requirements](https://documentation-service.arm.com/static/62a304f231ea212bb6623216)

All loads and stores *preceding* an `STLR` that match the shareability domain of the target address, must be observed *before* the `STLR`.

```text
// wirte before read

                                      ↑
                  +------+            |
        +---------| STR1 |            |
        |         | LDR1 |            |
        |         +------+            |
        |                             |
        ↓                             |
--------------------------------------|-----
           ⚡️ Store-Release (STLR) ⚡️   |
--------------------------------------|-----
                                      |
                                      |
                  +------+            |
                  | STR2 |            |
                  | LDR2 |------------+
                  +------+
```

STR2/LDR2 *can* be reordered across the `STLR` barrier backwards, but STR1/LDR1 before `STLR` *can't* be reordered across the `STLR` barrier forwards.

The following example shows how to use an `STLR` to enforce ordering observation. The memory locations at `X1` and `X3` are initialized to 0x0:

```asm
STR  #1, [X1] 
STLR #1, [X3]  ; Cannot observe this STLR without observing the previous STR.
```

In this example, if the memory location at `X3` is observed updated, then `X1` must *also* be observed updated. If another observer reads the same two memory locations, in the same order, the following truth table shows the combination of values that the memory system might return:

X1  | X3
----|----
0x0 | 0x0
0x1 | 0x0
0x1 | 0x1

## LDAR + STLR

There are also exclusive versions of the above, `LDAXR` and `STLXR`, available. Here *`X`* stands for eXclusive, see [ARM64 exclusive Load/Store](./a64-load-store-exclusive.md).

Load-Acquire and Store-Release instructions can be **combined** in a pair to protect a critical section of code. Combining these instructions ensures that accesses that are made *within* the critical code section are not reordered *outside* of the critical section. Accesses *inside* the critical code section are not affected, and can be reordered, as you can see in the following diagram:

![Protecting a critical code section with an LDAR-STLR pair](https://documentation-service.arm.com/static/62a304f231ea212bb662321e)

Unlike the data barrier instructions, which take a qualifier to control which shareability domains see the effect of the barrier, the `LDAR` and `STLR` instructions use the attribute of the address accessed.

An `LDAR` instruction guarantees that any memory access instructions after the `LDAR`, are only visible *after* the load-acquire. A store-release(`STLR`) guarantees that all earlier memory accesses are visible *before* the store-release becomes visible and that the store is visible to all parts of the system capable of storing cached data at the same time.

```text
                  +------+
                  | STR1 |------------+
                  | LDR1 |            |
                  +------+            |
                                      |
                                      |
--------------------------------------|-------
           ⚡️ Load-Acquire (LDAR) ⚡️    |
--------------------------------------|-------  \
        ↑                             |   ↑     |
        |         +------+            |   |     |
        +---------| STR2 |            |   |     |   critical
        +---------| LDR2 |            |   |     | code section
        |         +------+            |   |     |
        ↓                             ↓   |     |
------------------------------------------|---  /
           ⚡️ Store-Release (STLR) ⚡️       |
------------------------------------------|---
                                          |
                                          |
                  +------+                |
                  | STR3 |                |
                  | LDR3 |----------------+
                  +------+
```

The diagram shows how accesses can cross a one-way barrier in one direction but not in the other.

The load-acquire barrier instruction `LDAR` and the store-release barrier instruction `STLR` are equivalent to the unidirectional `DMB` instruction, while the `DMB` instruction is equivalent to an omnidirectional barrier, and no read or write operation can cross the barrier.
The combination of `LDAR` and `STLR` can enhance code flexibility and improve execution efficiency.

As shown in the figure above, the `LDAR` and the `STLR` form a critical section, which is equivalent to a barrier.

1. STR1/LDR1 can be moved in front of `LDAR`, but cannot continue to move forward (the direction of instruction execution in the figure) to cross `STLR`.
2. STR3/LDR3 can be moved behind `STLR`, but cannot continue to move backward (the reverse direction of instruction execution in the figure) to cross `LDAR`.
3. The memory access instruction STR2/LDR2 in the critical section cannot cross the critical section constructed by (`LDAR`, `STLR`).

## Sequentially consistent

When there is a `STLR` followed by a `LDAR` to a different address, then these 2 can't be reordered and hence it is called *`RCsc`* (release consistent sequential consistent).

Acquire/release operations use a sequentially consistent model. This means that, when a Load-Acquire appears in program order *after* a Store-Release, the memory access that is generated by the Store-Release instruction is observed *before* the memory access that is generated by the Load-Acquire instruction. You can see these ordering requirements in the following diagram:

![Sequentially consistent ordering requirements](https://documentation-service.arm.com/static/62a304f231ea212bb6623217)

The freedom to move `LDAPR` instructions past preceding `STLR` instructions to unrelated addresses has the potential to improve performance in these sequences.

## Load-AcquirePC

When there is a `STLR` followed by a `LDAPR` to a different address, then these 2 can be reordered. This is called *`RCpc`* (release consistent processor consistent).

Armv8.3-A also provides Load-AcquirePC instructions. The combination of Load-AcquirePC and Store-Release is used to support the weaker Release Consistency processor consistent (RCpc) model, as you can see in the following diagram:

![Load-AcquirePC instructions](https://documentation-service.arm.com/static/62a304f231ea212bb662321c)

References of `LDAPR`:

- [arm - ARMv8.3 meaning of rcpc - Stack Overflow](https://stackoverflow.com/questions/68676666/armv8-3-meaning-of-rcpc)
- [Enabling the LDAPR instructions for C/C++ compilers](https://community.arm.com/arm-community-blogs/b/tools-software-ides-blog/posts/enabling-rcpc-in-gcc-and-llvm)
- [[16/18] arm64: cpufeatures: Add capability for LDAPR instruction - Patchwork](https://patchwork.kernel.org/project/linux-arm-kernel/patch/20200630173734.14057-17-will@kernel.org/)
- [95751 – [aarch64] Consider using ldapr for __atomic_load_n(acquire) on ARMv8.3-RCPC](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=95751)

## barriers in C code

The C11 and C++11 languages have a good platform-independent memory model that is preferable to intrinsics if possible.

=== "C memory_order"

    [memory_order - cppreference.com](https://en.cppreference.com/w/c/atomic/memory_order)

    ```c
    // Defined in header <stdatomic.h>
    enum memory_order {
        memory_order_relaxed,
        memory_order_consume,
        memory_order_acquire,
        memory_order_release,       // (since C11)
        memory_order_acq_rel,
        memory_order_seq_cst
    };
    ```

=== "C++ memory_order"

    [std::memory_order - cppreference.com](https://en.cppreference.com/w/cpp/atomic/memory_order)

    ```c
    // Defined in header <atomic>
    typedef enum memory_order {
        memory_order_relaxed,
        memory_order_consume,
        memory_order_acquire, // (since C++11)
        memory_order_release, // (until C++20)
        memory_order_acq_rel,
        memory_order_seq_cst
    } memory_order;

    enum class memory_order : /* unspecified */ {
        relaxed, consume, acquire, release, acq_rel, seq_cst
    };
    inline constexpr memory_order memory_order_relaxed = memory_order::relaxed;
    inline constexpr memory_order memory_order_consume = memory_order::consume; // (since C++20)
    inline constexpr memory_order memory_order_acquire = memory_order::acquire;
    inline constexpr memory_order memory_order_release = memory_order::release;
    inline constexpr memory_order memory_order_acq_rel = memory_order::acq_rel;
    inline constexpr memory_order memory_order_seq_cst = memory_order::seq_cst;
    ```

All versions of C and C++ have *`sequence points`*, but C11 and C++11 also provide memory models. Sequence points *only* prevent the compiler from re-ordering C++ source code. There is *nothing* to stop the processor re-ordering instructions in the generated object code, or for read and write buffers to re-order the sequence in which data transfers are sent to the cache. In other words, they are *only* relevant for single-threaded code. For multi-threaded code, then either use the memory model features of C11 / C++11, or other ***synchronization*** mechanisms such as `mutexes` which are provided by the operating system. Typically, a compiler cannot re-arrange statements across a sequence point and restrict what optimizations the compiler can make. Examples of sequence points in code include function calls and accesses to [volatile](../c/c-volatile.md) variables.

The C language specification defines sequence points as follows:

> At certain specified points in the execution sequence called `sequence points`, all side effects of previous evaluations shall be ***complete*** and ***no*** side effects of subsequent evaluations shall have taken place.

See [C Memory Order(Sequential Consistency)](../c/c-memory-order.md).

## linux/barrier.h

The Linux kernel includes a number of platform independent barrier functions. See the Linux kernel documentations:

- Documentation/memory-barriers.txt: @[kernel.org](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/memory-barriers.txt), @[github.com](https://github.com/torvalds/linux/blob/master/Documentation/memory-barriers.txt)
- tools/memory-model/Documentation/: @[kernel.org](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/memory-model/Documentation/), @[github.com](https://github.com/torvalds/linux/blob/master/tools/memory-model/Documentation/)

The relevant header files are as follows:

- [include/asm-generic/barrier.h](https://github.com/torvalds/linux/blob/master/include/asm-generic/barrier.h)
- [arch/x86/include/asm/barrier.h](https://github.com/torvalds/linux/blob/master/arch/x86/include/asm/barrier.h)
- [tools/arch/x86/include/asm/barrier.h](https://github.com/torvalds/linux/blob/master/tools/arch/x86/include/asm/barrier.h)
- [arch/arm/include/asm/barrier.h](https://github.com/torvalds/linux/blob/master/arch/arm/include/asm/barrier.h)
- [tools/include/asm/barrier.h](https://github.com/torvalds/linux/blob/master/tools/include/asm/barrier.h)
- [arch/arm64/include/asm/barrier.h](https://github.com/torvalds/linux/blob/master/arch/arm64/include/asm/barrier.h)
- [tools/arch/arm64/include/asm/barrier.h](https://github.com/torvalds/linux/blob/master/tools/arch/arm64/include/asm/barrier.h)
