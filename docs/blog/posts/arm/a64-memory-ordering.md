---
title: ARM64 Memory Ordering - re-ordering
authors:
    - xman
date:
    created: 2023-10-06T09:00:00
categories:
    - arm
comments: true
---

[Memory ordering](https://en.wikipedia.org/wiki/Memory_ordering) describes the order of accesses to computer *memory* by a CPU. The term can refer either to the memory ordering generated by the *compiler* during compile time, or to the memory ordering generated by a *CPU* during runtime.

In modern microprocessors, memory ordering characterizes the CPU's ability to reorder memory operations – it is a type of [out-of-order execution](https://en.wikipedia.org/wiki/Out-of-order_execution). Memory reordering can be used to fully **utilize** the bus-bandwidth of different types of memory such as caches and memory banks.

<!-- more -->

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) | Chapter 13 Memory Ordering

If your code interacts directly either with the hardware or with code executing on other cores, or if it directly loads or writes instructions to be executed, or modifies page tables, you need to be aware of *memory ordering* issues.

If you are an application developer, hardware interaction is probably through a device driver, the interaction with other cores is through [Pthreads](https://en.wikipedia.org/wiki/Pthreads) or another multithreading API, and the interaction with a paged memory system is through the operating system. In all of these cases, the memory ordering issues are taken care of for you by the relevant code. However, if you are writing the operating system kernel or device drivers, or implementing a hypervisor, JIT compiler, or multithreading library, you must have a good understanding of the memory ordering rules of the ARM Architecture. You must **ensure** that where your code requires explicit ordering of memory accesses, you are able to achieve this through the correct use of barriers.

The ARMv8 architecture employs a *`weakly-ordered`* model of memory. In general terms, this means that the order of memory accesses is not required to be the same as the program order for load and store operations. The processor is able to ***re-order*** memory read operations with respect to each other. Writes may also be ***re-ordered*** (for example, write combining) . As a result, hardware optimizations, such as the use of cache and write buffer, function in a way that improves the performance of the processor, which means that the required *bandwidth* between the processor and external memory can be reduced and the long latencies associated with such external memory accesses are hidden.

Reads and writes to Normal memory can be **re-ordered** by hardware, being subject only to data dependencies and explicit memory barrier instructions. Certain situations require stronger ordering rules. You can provide information to the core about this through the memory type attribute of the translation table entry that describes that memory.

## re-ordering

Very high performance systems might support techniques such as speculative memory reads, multiple issuing of instructions, or out-of-order execution and these, along with other techniques, offer further possibilities for hardware re-ordering of memory access:

**Multiple issue of instructions**

> A processor might issue and execute multiple instructions per cycle, so that instructions that are after each other in program order can be executed at the same time.

**Out-of-order execution**

> Many processors support out-of-order execution of *non-dependent* instructions. Whenever an instruction is stalled while it waits for the result of a preceding instruction, the processor can execute subsequent instructions that do not have a dependency.

**Speculation**

> When the processor encounters a *conditional* instruction, such as a branch, it can speculatively begin to execute instructions before it knows for sure whether that particular instruction must be executed or not. The result is, therefore, available sooner if conditions resolve to show the speculation was correct.

**Speculative loads**

> If a load instruction that reads from a cacheable location is speculatively executed, this can result in a cache linefill and the potential eviction of an existing cache line.

**Load and store optimizations**

> As reads and writes to external memory can have a long latency, processors can reduce the number of transfers by, for example, **merging** together a number of stores(`STP`, `SIMD`(*Neon*), etc.) into one larger transaction.

**External memory systems**

> In many complex System on Chip (`SoC`) devices, there are a number of agents capable of initiating transfers and multiple routes to the slave devices that are read or written. Some of these devices, such as a DRAM controller, might be capable of accepting simultaneous requests from different masters. Transactions can be *buffered*, or *re-ordered* by the interconnect. This means that accesses from different masters might therefore take varying numbers of cycles to complete and might overtake each other.

**Cache coherent multi-core processing**

> In a multi-core processor, hardware cache coherency can migrate cache lines between cores. Different cores might therefore see updates to cached memory locations in a different order to each other.

**Optimizing compilers**

> An optimizing compiler can re-order instructions to hide latencies or make best use of hardware features. It can often move a memory access *forwards*, to make it *earlier*, and give it more time to complete before the value is required.

In a single core system, the effects of such re-ordering are generally transparent to the programmer, as the individual processor can check for hazards and ensure that data dependencies are respected. However, in cases where you have multiple cores that communicate through shared memory, or share data in other ways, memory ordering considerations become more important. This chapter discusses several topics that relate to [Multiprocessing](https://en.wikipedia.org/wiki/Multiprocessing) (`MP`) operation and synchronization of multiple execution threads. It also discusses memory types and rules defined by the architecture and how these are controlled.

## memory types

The ARMv8 architecture defines two mutually-exclusive memory types. All regions of memory are configured as one or the other of these two types, which are `Normal` and `Device`. A third memory type, *Strongly Ordered*, is part of the ARMv7 architecture. The differences between this type and Device memory are few and it is therefore now **omitted** in ARMv8. (See Device memory on page 13-4.)

In addition to the memory type, *attributes* also provide control over cacheability, shareability, access, and execution permissions. Shareable and cache properties pertain *only* to Normal memory. Device regions are always *deemed* to be `non-cacheable` and `outer-shareable`. For cacheable locations, you can use attributes to indicate cache allocation policy to the processor.

### Normal memory

You can use `Normal memory` for all code and for most data regions in memory. Examples of Normal memory include areas of *RAM*, *Flash*, or *ROM* in physical memory. This kind of memory provides the highest processor performance as it is *weakly ordered* and has fewer restrictions placed on the processor. The processor can **re-order**, **repeat**, and **merge** accesses to Normal memory.

Furthermore, address locations that are marked as Normal can be accessed *speculatively* by the processor, so that data or instructions can be read from memory without being explicitly referenced in the program, or *in advance* of the actual execution of an explicit reference. Such speculative accesses can occur as a result of branch prediction, speculative cache linefills, out-of-order data loads, or other hardware optimizations.

For best performance, always mark application code and data as `Normal` and in circumstances where an enforced memory ordering is required, you can achieve it through the use of explicit `barrier` operations. Normal memory implements a weakly-ordered memory mode. There is no requirement for Normal accesses to complete in order with respect to either other Normal accesses or to Device accesses.

However, the processor must always handle hazards caused by *address dependencies*.

For example, consider the following simple code sequence:

```asm
STR X0, [X2]
LDR X1, [X2]
```

The processor always **ensures** that the value placed in `X1` is the value that was written to the address stored in `X2`.

This of course applies to more complex dependencies.

Consider the following code:

```asm
ADD X4, X3, #3
ADD X5, X3, #2

STR X0, [X3]
STRB W1, [X4]
LDRH W2, [X5]
```

In this case, the accesses take place to addresses that overlap each other. The processor must **ensure** that the memory is updated as if the `STR` and `STRB` occurred in order, so that the `LDRH` returns the most up-to-date value. It would still be valid for the processor to merge the STR and STRB into a single access that contained the latest, correct data to be written.

### Device memory

You can use `Device memory` for all memory regions where an access might have a side-effect. For example, a read to a FIFO location or timer is not repeatable, as it returns different values for each read. A write to a control register might trigger an interrupt. It is typically only used for peripherals in the system. The Device memory type **imposes** more restrictions on the core. Speculative data accesses **cannot** be performed to regions of memory marked as Device. There is a single, uncommon exception to this. If `NEON` operations are used to read bytes from Device memory, the processor might read bytes not explicitly referenced if they are within an aligned 16-byte block that contains one or more bytes that are explicitly referenced.

Trying to execute code from a region marked as Device, is generally *`UNPREDICTABLE`*. The implementation might either handle the instruction fetch as if it were to a memory location with the Normal non-cacheable attribute, or it might take a permission fault.

There are four different types of device memory, to which different rules apply.

- Device-nGnRnE most restrictive (equivalent to Strongly Ordered memory in the ARMv7 architecture).
- Device-nGnRE
- Device-nGRE
- Device-GRE least restrictive

The letter suffixes refer to the following three properties:

1. Gathering or non Gathering (`G` or `nG`)
2. Re-ordering (`R` or `nR`)
3. Early Write Acknowledgement (`E` or `nE`)