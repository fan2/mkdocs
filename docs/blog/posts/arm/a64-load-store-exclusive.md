---
title: ARM64 exclusive Load/Store
authors:
    - xman
date:
    created: 2023-10-07T12:00:00
categories:
    - arm
tags:
    - LDAXR
    - STLXR
comments: true
---

ARMv7-A and ARMv8-A architectures both provide support for exclusive memory accesses. In A64, this is the *Load/Store exclusive* (`LDXR`/`STXR`) pair.

In an SMP (Symmetric multiprocessing) system, data accesses must frequently be restricted to *one* modifier at any particular time.

<!-- more -->

## Memory access

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) | 6: The A64 instruction set - 6.3 Memory access instructions - 6.3.11 Synchronization primitives

ARMv7-A and ARMv8-A architectures both provide support for exclusive memory accesses. In A64, this is the *Load/Store exclusive* (`LDXR`/`STXR`) pair.

The `LDXR` instruction loads a value from a memory address and attempts to silently claim an exclusive *lock* on the address. The Store-Exclusive instruction `STXR` then writes a new value to that location only if the *lock* was successfully obtained and held. The `LDXR`/`STXR` pairing is used to construct standard synchronization primitives such as ***spinlocks***.

Software must avoid having any explicit memory accesses, system control register updates, or cache maintenance instructions between paired `LDXR` and `STXR` instructions.

There is also an exclusive pair of Load Acquire/Store Release instructions called `LDAXR` and `STLXR`.

## Multi-processing

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) | 14: Multi-core processors - 14.1 Multi-processing systems - 14.1.4 Synchronization

In an SMP ([Symmetric multiprocessing](https://en.wikipedia.org/wiki/Symmetric_multiprocessing)) system, data accesses must frequently be restricted to *one* modifier at any particular time. This can be true for peripheral devices, but also for global variables and data structures accessed by more than one thread or process. Protection of such shared resources is often through a method known as **`mutual exclusion`**. In a multi-core system, you can use a *`spinlock`*, which is effectively a *shared flag* with an atomic *indivisible* mechanism, to test and set its value.

The ARM architecture provides three instructions relating to exclusive access, and variants of these instructions, that operate on byte, halfword, word, or doubleword sized data.

The instructions rely on the ability of the core or memory system to **tag** particular addresses for exclusive access monitoring by that core, using an *exclusive access monitor*. The use of these instructions is common in multi-core systems, but is also found in single core systems, to implement synchronization operations between threads running on the same core.

The A64 instruction set has instructions for implementing such synchronization functions:

- Load Exclusive (`LDXR`): `LDXR W|Xt, [Xn]`
- Store Exclusive (`STXR`): `STXR Ws, W|Xt, [Xn]` where `Ws` indicates whether the store completed successfully. 0 = success.
- Clear Exclusive access monitor (`CLREX`): This is used to clear the state of the Local Exclusive Monitor.

`LDXR` performs a load of memory, but also **tags** the Physical Address to be *monitored* for exclusive access by that core. `STXR` performs a conditional store to memory, succeeding only if the target location is **tagged** as being monitored for exclusive access by *that* core. This instruction returns non-zero in the general-purpose register `Ws` if the store does not succeed, and a value of `0` if the store is successful. In the assembler syntax, it is always specified as a `W` register, that is, not an `X` register. In addition, the `STXR` **clears** the exclusive tag.

## Exclusive monitor

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) | 14: Multi-core processors - 14.1 Multi-processing systems - 14.1.7 Exclusive monitor system location

A typical multi-core system might include multiple exclusive monitors. Each core has its own *local* monitor and there are one or more *global* monitors. The shareable and cacheable attributes of the translation table entry relating to the location used for the exclusive load or store instruction determines which exclusive monitor is used.

In hardware, the core includes a device named the *local monitor*. This monitor **observes** the core. When the core performs an exclusive load access, it ***records*** that fact in the local monitor. When it performs an exclusive store, it ***checks*** that a previous exclusive load was performed and fails the exclusive store if this was not the case. The architecture enables individual implementations to determine the level of checking performed by the monitor. The core can only **tag** one Physical Address at a time.

The local exclusive monitor gets cleared on every exception return, that is, on execution of the `ERET` instruction. In the Linux kernel multiple tasks run in kernel context at `EL1`, and can be context-switched without an exception return. Only when we return to a userspace thread within the context of its associated kernel task do we perform the exception return. This is different to the ARMv7 architecture, where the kernel task scheduler must explicitly **clear** the exclusive access monitor on each task switch. It is *`IMPLEMENTATION DEFINED`* whether the resetting of the local exclusive monitor also resets the global exclusive monitor.

The local monitor is used when the location used for the exclusive access is *marked* as non-shareable, that is, threads running on the same core only. Local monitors can also handle the case where accesses are *marked* as inner shareable, for example, a mutex protecting a resource shared between `SMP` threads running on any core within the shareable domain. For threads running on different, non-coherent cores, the mutex location is marked as normal, non-cacheable and requires a global access monitor in the system.

A system might not include a global monitor, or a global monitor might only be available for certain address regions. It is *`IMPLEMENTATION DEFINED`* what happens if an exclusive access is performed to a location for which no suitable monitor exists in the system. The following are some of the permitted options:

- The instruction generates an External Abort.
- The instruction generates an MMU fault.
- The instruction is treated as a `NOP`.
- The exclusive instruction is treated as a standard `LDR`/`STR` instruction, the value held in the result register of the store exclusive instruction becomes *`UNKNOWN`*.

The *Exclusives Reservation Granule* (`ERG`) is the granularity of the exclusive monitor. Its size is *`IMPLEMENTAION DEFINED`*, but is typically *one* cache line. It gives the minimum spacing between addresses for the monitor to distinguish between them. Placing two mutexes within a single `ERG` can lead to false negatives, where executing a `STXR` instruction to either mutex **clears** the exclusive tag of both. This does not prevent architecturally-correct software from functioning correctly but it might be less efficient. The size of the `ERG` of the exclusive monitor on a specific core might be read from the Cache Type Register, `CTR_EL0`.
