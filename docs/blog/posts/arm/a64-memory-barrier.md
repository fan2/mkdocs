---
title: ARM64 Memory Barriers
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

[ARM Cortex-R Series Programmer's Guide](https://developer.arm.com/documentation/den0042/latest/Memory-Ordering) | Chapter 10 Memory Ordering:

A memory barrier is an instruction that requires the processor to apply an ordering *constraint* between memory operations that occur before and after the memory barrier instruction in the program.

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) | Chapter 13 Memory Ordering:

If you are an application developer, hardware interaction is probably through a device driver, the interaction with other cores is through [Pthreads](https://en.wikipedia.org/wiki/Pthreads) or another multithreading API, and the interaction with a paged memory system is through the operating system. In all of these cases, the memory ordering issues are taken care of for you by the relevant code. However, if you are writing the operating system kernel or device drivers, or implementing a hypervisor, JIT compiler, or multithreading library, you must have a good understanding of the memory ordering rules of the ARM Architecture. You must **ensure** that where your code requires *explicit* ordering of memory accesses, you are able to achieve this through the correct use of *`barriers`*.

The ARM architecture includes barrier instructions to **force** access *ordering* and access *completion* at a specific point. In some architectures, similar instructions are known as a *fence*(membar, memory fence).

If you are writing code where ordering is important, see *Appendix J7 Barrier Litmus Tests in the ARM Architecture Reference Manual - ARMv8, for ARMv8-A architecture profile* and *Appendix G Barrier Litmus Tests in the ARM Architecture Reference Manual ARMv7-A/R Edition*, which includes many worked examples.

The *ARM Architecture Reference Manual* defines certain key words, in particular, the terms *`observe`* and must be *`observed`*. In typical systems, this defines how the bus interface of a master, for example, a core or GPU and the interconnect, must handle bus transactions. Only masters are able to **observe** transfers. All bus transactions are initiated by a master. The order that a master performs transactions in is not necessarily the same order that such transactions complete at the slave device, because transactions might be **re-ordered** by the interconnect unless some ordering is explicitly **enforced**.

A simple way to describe observability is to say that 

> I have observed your write when I can read what you wrote and 
> I have observed your read when I can no longer change the value you read.

where both I and you refer to cores or other masters in the system.

There are three types of barrier instruction provided by the architecture:

## ISB(Instruction Synchronization Barrier)

[Instruction barriers](https://developer.arm.com/documentation/102336/latest/Instruction-barriers)

[ISB: Instruction synchronization barrier](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/ISB--Instruction-synchronization-barrier-): This instruction flushes the pipeline in the PE([Processing Element](https://developer.arm.com/documentation/102404/latest/Common-architecture-terms)) and is a context synchronization event.

This is used to guarantee that any *subsequent* instructions are fetched, again, so that privilege and access are checked with the current MMU configuration. It is used to **ensure** any previously executed context-changing operations, such as writes to system control registers, have ***completed*** by the time the `ISB` completes. In hardware terms, this might mean that the instruction pipeline is ***flushed***, for example. Typical uses of this would be in memory management, cache control, and context switching code, or where code is being moved about in memory.

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

## DMB(Data Memory Barrier)

[Data Memory Barrier](https://developer.arm.com/documentation/102336/latest/Data-Memory-Barrier)

[DMB: Data memory barrier.](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/DMB--Data-memory-barrier-): This instruction is a memory barrier that ensures the ordering of observations of memory accesses.

This prevents re-ordering of data accesses instructions across the barrier instruction. All data accesses, that is, loads or stores, but not instruction fetches, performed by this processor before the `DMB`, are **visible** to all other masters within the specified shareability domain before any of the data accesses after the `DMB`.

For example:

> Pay attention: `ADD` is not data accessing instructions.

```asm
LDR x0, [x1]    // Must be seen by the memory system before the STR below.
DMB ISHLD       // Inner shareable: Load - Load, Load - Store
ADD x2, #1      // May be executed before or after the memory system sees LDR.
STR x3, [x4]    // Must be seen by the memory system after the LDR above.
```

It also **ensures** that any explicit preceding data or unified cache maintenance operations have *completed before* any subsequent data accesses are executed.

```asm
DC CSW, x5      // Data clean by Set/way
LDR x0, [x1]    // Effect of data cache clean might not be seen by this instruction

DMB ISH         // Inner shareable: Any - Any
LDR x2, [x3]    // Effect of data cache clean will be seen by this instruction
```

Maintenance instructions related to data cache and unified cache(such as `DC`) are actually also considered data access instructions. Therefore, the data cache maintenance instructions before the `DMB` instruction must be executed before the memory access instructions after the DMB instruction.

From the analysis of the above examples, it can be seen that the `DMB` instruction focuses on the sequence of memory access and does not need to care when the memory access instructions are executed. The data access instructions before the `DMB` must be ***observed*** by the data access instructions after the `DMB`.

## DSB(Data Synchronization Barrier)

[Data Synchronization Barrier](https://developer.arm.com/documentation/102336/latest/Data-Synchronization-Barrier)

[DSB: Data synchronization barrier.](https://developer.arm.com/documentation/ddi0602/2024-06/Base-Instructions/DSB--Data-synchronization-barrier-): This instruction is a memory barrier that ensures the completion of memory accesses.

This **enforces** the same ordering as the Data Memory Barrier (`DMB`), but has the additional effect of blocking execution of *any* further instructions, *not* just loads or stores, or both, until synchronization is complete. This can be used to **prevent** execution of a `SEV` instruction, for instance, that would *signal* to other cores that an event occurred. It **waits** until all cache, TLB and branch predictor maintenance operations issued by this processor have completed for the specified shareability domain.

The `DSB` instruction is much stricter than the `DMB` instruction. *Any* instruction after the `DSB` must meet the following two conditions before it can start executing.

- All data access instructions (memory access instructions) before the `DSB` instruction must be executed.
- The cache, branch prediction, TLB and other maintenance instructions before the `DSB` instruction must also be executed.

The instructions after the `DSB` instruction can only be executed after these two conditions are met. Note that the instructions after the `DSB` refer to *any* instructions.

Compared with the `DMB` instruction, the `DSB` instruction specifies under what conditions it can be executed, while the `DMB` instruction only constrains the execution order of the data access instructions before and after the barrier.

Example 1: The CPU executes the following 3 instructions.

```asm
LDR x0, [x1]    // Access must have completed before DSB can complete
DSB ISH         // Inner shareable: Any - Any
ADD x2, x3, x4  // Cannot be executed until DSB completes
```

The `ADD` instruction must wait for the `DSB` instruction to be executed before it can start executing. It cannot be reordered before the `LDR` instruction.

If the `DSB` instruction is replaced with the `DMB` instruction, the `ADD` instruction can be reordered before the `LDR` instruction.

Example 2: The CPU executes the following 4 instructions.

```asm
// DC ISW, x5
DC CIVA x5      // operation must have completed before DSB can complete
STR x0, [x1]    // Access must have completed before DSB can complete
DSB ISH         // Inner shareable: Any - Any
ADD x2, x2, #3  // Cannot be executed until DSB completes
```

The first instruction is the `DC` instruction, which clears and invalidates the data cache corresponding to the virtual address (X5 register).
The second instruction stores the value of the X0 register to the address hold by register x1. The third instruction is the `DSB` instruction. The fourth instruction is the `ADD` instruction, which adds 3 to the value of the X2 register.

The `DC` instruction and the `STR` instruction must be executed before the `DSB` instruction. The `ADD` instruction must wait until the `DSB` instruction is executed before it can start executing. Although the `ADD` instruction is not a data access instruction, it must wait until the `DSB` instruction is executed before it can start executing.

In a multi-core system, cache and TLB maintenance instructions are broadcast to other CPU cores to perform local related maintenance operations. The `DSB` instruction is considered to be completed only when it waits for these broadcasts and receives the acknowledgement signal sent by other CPU cores. Therefore, when the `DSB` instruction is executed, the other CPU cores have seen that the first `DC` instruction has been executed.

## parameters for DMB/DSB

[Limiting the scope of memory barriers](https://developer.arm.com/documentation/102336/latest/Limiting-the-scope-of-memory-barriers)

As you can see from the above examples, the `DMB` and `DSB` instructions take a parameter which specifies the types of access to which the barrier operates, *before* or *after*, and a [shareability domain](./a64-memory-ordering.md) to which it applies.

The argument that defines which type of memory accesses are ordered by the memory barrier and the Shareability domain over which the instruction must operate. This *scope* effectively defines which Observers the ordering imposed by the barriers extend to.

According to the scope of sharing, the cache can be divided into 4 share domains - non-shareable domain, inner shareable domain, outer shareable domain and system shareable domain. The purpose of the shared domain is to specify the scope of cache consistency for all hardware units that can access memory, which is mainly used for cache maintenance instructions and memory barrier instructions.

1. If an area is marked as `Non-shareable`, it means that it can only be accessed by one processor and cannot be accessed by other processors.
2. If an area is marked as `Inner Shareable`, it means that the processors in this area can access these shared caches, but the hardware units in other areas of the system (such as DMA devices, GPUs, etc.) cannot access them.
3. If an area is marked as `Outer Shareable`, it means that the processors in this area and the hardware units with memory access capabilities (such as GPUs, etc.) can access and share caches with each other.
4. If a memory area is marked as `System Shareable`(*Full system*), it means that all units in the system that access memory can access and share this area.

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

## barrier usage scenarios

In most scenarios, we don't need to pay special attention to memory barriers. Especially in single-processor systems, although the CPU supports out-of-order execution and predictive execution, in general, the CPU will ensure that the final execution result meets the programmer's requirements. In the scenario of multi-core concurrent programming, programmers need to consider whether to use memory barrier instructions. The following are some typical scenarios where you need to consider using memory barrier instructions.

- Share data between multiple CPU cores. Under the weak consistency memory model, a CPU's disordered memory access order may cause contention access.
- Perform operations related to peripherals, such as DMA operations. The process of starting DMA operations is usually as follows: the first step is to write data to the DMA buffer; the second step is to set DMA-related registers to start DMA. If there is no memory barrier instruction in the middle, the related operations of the second step may be executed before the first step, so that DMA transmits wrong data.
- Modify the memory management strategy, such as context switching, requesting page faults, and modifying page tables.
- Modify the memory area where instructions are stored, such as the scenario of self-modifying code.

In short, the purpose of using memory barrier instructions is to make the CPU execute according to the logic of the program code, rather than having the execution order of the code disrupted by the CPU's out-of-order execution and speculative execution.

## references

[为什么需要内存屏障？](https://blog.csdn.net/chen19870707/article/details/39896655)
内存避障：[一个内存乱序实例](https://blog.csdn.net/jackgo73/article/details/129580683) & [前世今生](https://mingjie.blog.csdn.net/article/details/129588953)
浅墨: 聊聊原子变量、锁、内存屏障那点事：[（1）](https://cloud.tencent.com/developer/article/1518180)，[（2）](https://cloud.tencent.com/developer/article/1517889)

[从CPU缓存架构、内存一致性到内存屏障](https://blog.chongsheng.art/post/golang/cpu-cache-memory-barrier/)
[从缓存一致性、指令重排、内存屏障到volatile](https://www.cnblogs.com/yungyu16/p/13200453.html)

[什么是内存屏障？](https://blog.csdn.net/s2603898260/article/details/109234770) - MESI, [Store Buffer, Invalid Queue](https://blog.csdn.net/wll1228/article/details/107775976)
理解内存屏障及应用实例无锁环形队列kfifo：[bw_0927](https://www.cnblogs.com/my_life/articles/5220172.html)，[绿色冰点](https://www.cnblogs.com/moodlxs/p/10718706.html)
