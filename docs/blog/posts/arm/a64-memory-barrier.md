---
title: ARM64 Memory Ordering - barriers
authors:
    - xman
date:
    created: 2023-10-07T10:00:00
categories:
    - arm
tags:
    - ISB
    - DMB
    - DSB
comments: true
---

On most modern uniprocessors memory operations are not executed in the order specified by the program code. In single threaded programs all operations *appear to* have been executed in the order specified, with all out-of-order execution hidden to the programmer – however in multi-threaded environments (or when interfacing with other hardware via memory buses) this can lead to problems. To avoid problems, [memory barriers](https://en.wikipedia.org/wiki/Memory_barrier) can be used in these cases.

<!-- more -->

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) | Chapter 13 Memory Ordering

The ARM architecture includes barrier instructions to **force** access *ordering* and access *completion* at a specific point. In some architectures, similar instructions are known as a fence(membar, memory fence).

If you are writing code where ordering is important, see *Appendix J7 Barrier Litmus Tests in the ARM Architecture Reference Manual - ARMv8, for ARMv8-A architecture profile* and *Appendix G Barrier Litmus Tests in the ARM Architecture Reference Manual ARMv7-A/R Edition*, which includes many worked examples.

## barrier instructions

The *ARM Architecture Reference Manual* defines certain key words, in particular, the terms *`observe`* and must be *`observed`*. In typical systems, this defines how the bus interface of a master, for example, a core or GPU and the interconnect, must handle bus transactions. Only masters are able to **observe** transfers. All bus transactions are initiated by a master. The order that a master performs transactions in is not necessarily the same order that such transactions complete at the slave device, because transactions might be **re-ordered** by the interconnect unless some ordering is explicitly **enforced**.

A simple way to describe observability is to say that 

> I have observed your write when I can read what you wrote and 
> I have observed your read when I can no longer change the value you read.

where both I and you refer to cores or other masters in the system.

There are three types of barrier instruction provided by the architecture:

**Instruction Synchronization Barrier** (`ISB`)

This is used to guarantee that any *subsequent* instructions are fetched, again, so that privilege and access are checked with the current MMU configuration. It is used to **ensure** any previously executed context-changing operations, such as writes to system control registers, have **completed** by the time the `ISB` completes. In hardware terms, this might mean that the instruction pipeline is ***flushed***, for example. Typical uses of this would be in memory management, cache control, and context switching code, or where code is being moved about in memory.

**Data Memory Barrier** (`DMB`)

This prevents re-ordering of data accesses instructions across the barrier instruction. All data accesses, that is, loads or stores, but not instruction fetches, performed by this processor before the `DMB`, are **visible** to all other masters within the specified shareability domain before any of the data accesses after the `DMB`.

For example:

> Pay attention: `ADD` is not data accessing instructions.

```asm
LDR x0, [x1]    // Must be seen by the memory system before the STR below.
DMB ISHLD
ADD x2, #1      // May be executed before or after the memory system sees LDR.
STR x3, [x4]    // Must be seen by the memory system after the LDR above.
```

It also **ensures** that any explicit preceding data or unified cache maintenance operations have *completed before* any subsequent data accesses are executed.

```asm
DC CSW, x5      // Data clean by Set/way
LDR x0, [x1]    // Effect of data cache clean might not be seen by this instruction

DMB ISH
LDR x2, [x3]    // Effect of data cache clean will be seen by this instruction
```

**Data Synchronization Barrier** (`DSB`)

This **enforces** the same ordering as the Data Memory Barrier (DMB), but has the additional effect of blocking execution of *any* further instructions, not just loads or stores, or both, until synchronization is complete. This can be used to **prevent** execution of a `SEV` instruction, for instance, that would *signal* to other cores that an event occurred. It **waits** until all cache, TLB and branch predictor maintenance operations issued by this processor have completed for the specified shareability domain.

For example:

```asm
DC ISW, x5      // operation must have completed before DSB can complete
STR x0, [x1]    // Access must have completed before DSB can complete
DSB ISH
ADD x2, x2, #3  // Cannot be executed until DSB completes
```

## params for DMB/DSB

As you can see from the above examples, the `DMB` and `DSB` instructions take a parameter which specifies the types of access to which the barrier operates, before or after, and a shareability domain to which it applies.

<option\> | Ordered Accesses (before - after) | Shareability Domain
---------|-----------------------------------|--------------------
OSHLD    | Load - Load, Load - Store         | Outer shareable
OSHST    | Store - Store                     | *ditto*
OSH      | Any - Any                         | *ditto*
NSHLD    | Load - Load, Load - Store         | Non-shareable
NSHST    | Store - Store                     | *ditto*
NSH      | Any - Any                         | *ditto*
ISHLD    | Load -Load, Load - Store          | Inner shareable
ISHST    | Store - Store                     | *ditto*
ISH      | Any - Any                         | *ditto*
LD       | Load -Load, Load - Store          | Full system
ST       | Store - Store                     | *ditto*
SY       | Any - Any                         | *ditto*

The ordered access field specifies which classes of accesses the barrier operates on. There are three options.

**Load - Load/Store**

> This means that the barrier requires all `loads` to complete *before* the barrier but does not require stores to complete.
> Both `loads` and `stores` that appear *after* the barrier in program order must wait for the barrier to complete.

**Store - Store**

> This means that the barrier *only* affects store accesses and that loads can still be freely re-ordered around the barrier.

**Any - Any**

> This means that ***both*** loads and stores must **complete** *before* the barrier.
> ***Both*** loads and stores that appear *after* the barrier in program order must **wait** for the barrier to complete.

Barriers are used to **prevent** unsafe optimizations from occurring and to **enforce** a specific memory ordering. Use of unnecessary barrier instructions can therefore **reduce** software performance. Consider carefully whether a barrier is necessary in a specific situation, and if so, which is the correct barrier to use.

A more subtle effect of the ordering rules is that the instruction interface, data interface, and MMU table walker of a core are considered as separate observers. This means that you might need, for example, to use `DSB` instructions to **ensure** that an access one interface is **guaranteed** to be *observable* on a different interface.

If you execute a data cache clean and invalidate instruction, for example `DCCVAU, X0`, you must insert a `DSB` instruction after this to be sure that subsequent page table walks, modifications to translation table entries, instruction fetches, or updates to instructions in memory, can all see the new values.

For example, consider an update of the translation tables:

```asm
STR X0, [X1]    // update a translation table entry
DSB ISHST       // ensure write has completed
TLBI VAE1IS, X2 // invalidate the TLB entry for the entry that changes
DSB ISH         // ensure TLB invalidation is complete
ISB             // synchronize context on this processor
```

A `DSB` is required to ensure that the maintenance operations complete and an `ISB` is required to ensure that the effects of those operations are seen by the instructions that *follow*.

The processor might speculatively access an address marked as Normal at *any* time. So when considering whether barriers are required, don’t just consider explicit accesses generated by load or store instructions.

## One-way barriers

AArch64 adds new load and store instructions with implicit barrier semantics. These require that all loads and stores before or after the implicit barrier are **observed** in program order.

**Load-Acquire (LDAR)**

> All loads and stores that are after an `LDAR` in program order, and that match the shareability domain of the target address, must be observed *after* the `LDAR`.

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

**Store-Release (STLR)**

> All loads and stores preceding an `STLR` that match the shareability domain of the target address, must be observed *before* the `STLR`.

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

There are also exclusive versions of the above, `LDAXR` and `STLXR`, available. Here *`X`* stands for eXclusive.

Unlike the data barrier instructions, which take a qualifier to control which shareability domains see the effect of the barrier, the `LDAR` and `STLR` instructions use the attribute of the address accessed.

An `LDAR` instruction guarantees that any memory access instructions after the `LDAR`, are only visible *after* the load-acquire. A store-release guarantees that all earlier memory accesses are visible *before* the store-release becomes visible and that the store is visible to all parts of the system capable of storing cached data at the same time.

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

## ISB in more detail

The ARMv8 architecture defines *context* as the state of the system registers and *context-changing operations* as things like cache, TLB, and branch predictor maintenance operations, or changes to system control registers, for example, `SCTLR_EL1`, `TCR_EL1`, and `TTBRn_EL1`. The effect of such a context-changing operation is only guaranteed to be seen after a *context synchronization event*.

There are three kinds of context synchronization event:

- Taking an exception.
- Returning from an exception.
- Instruction Synchronization Barrier (`ISB`).

An `ISB` flushes the pipeline, and re-fetches the instructions from the cache or memory and ensures that the effects of any completed context-changing operation before the `ISB` are visible to any instruction after the `ISB`. It also ensures that any context-changing operations after the `ISB` instruction only take effect after the `ISB` has been executed and are not seen by instructions before the `ISB`. This does not mean that an `ISB` is required after each instruction that modifies a processor register. For example, reads or writes to `PSTATE` fields, `ELRs`, `SPs` and `SPSRs` occur in program order relative to other instructions.

This example shows how to enable the floating-point unit and `NEON`, which you can do in AArch64 by writing to bit[20] of the `CPACR_EL1` register. The `ISB` is a context synchronization event that guarantees that the enable is complete before any subsequent or `NEON` instructions are executed.

```asm
MRS X1, CPACR_EL1
ORR X1, X1, #(0x3 << 20)
MSR CPACR_EL1, X1
ISB
```

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

All versions of C and C++ have *`sequence points`*, but C11 and C++11 also provide memory models. Sequence points *only* prevent the compiler from re-ordering C++ source code. There is *nothing* to stop the processor re-ordering instructions in the generated object code, or for read and write buffers to re-order the sequence in which data transfers are sent to the cache. In other words, they are only relevant for single-threaded code. For multi-threaded code, then either use the memory model features of C11 / C++11, or other ***synchronization*** mechanisms such as `mutexes` which are provided by the operating system. Typically, a compiler cannot re-arrange statements across a sequence point and restrict what optimizations the compiler can make. Examples of sequence points in code include function calls and accesses to [volatile](../c/c-volatile.md) variables.

The C language specification defines sequence points as follows:

> At certain specified points in the execution sequence called sequence points, all side effects of previous evaluations shall be complete and no side effects of subsequent evaluations shall have taken place.

!!! note "Barriers in Linux"

    The Linux kernel includes a number of platform independent barrier functions. See the Linux kernel documentation in the [memory-barriers.txt](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/memory-barriers.txt) file.
