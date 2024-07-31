---
title: ARM64 Load/Store exclusive & Atomic operations
authors:
    - xman
date:
    created: 2023-10-07T12:00:00
categories:
    - arm
tags:
    - LL/SC
    - LSE
    - CAS
comments: true
---

ARMv7-A and ARMv8-A architectures both provide support for exclusive memory accesses. In A64, this is the *Load/Store exclusive* (`LDXR`/`STXR`) pair.

In an SMP (Symmetric multiprocessing) system, data accesses must frequently be restricted to *one* modifier at any particular time.

<!-- more -->

## Load/Store exclusive

### Memory access

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) | 6: The A64 instruction set - 6.3 Memory access instructions - 6.3.11 Synchronization primitives

ARMv7-A and ARMv8-A architectures both provide support for exclusive memory accesses. In A64, this is the *Load/Store exclusive* (`LDXR`/`STXR`) pair.

The `LDXR` instruction loads a value from a memory address and attempts to silently claim an exclusive *lock* on the address. The Store-Exclusive instruction `STXR` then writes a new value to that location only if the *lock* was successfully obtained and held. The `LDXR`/`STXR` pairing is used to construct standard synchronization primitives such as ***spinlocks***.

Software must avoid having any explicit memory accesses, system control register updates, or cache maintenance instructions between paired `LDXR` and `STXR` instructions.

There is also an exclusive pair of Load Acquire/Store Release instructions called `LDAXR` and `STLXR`.

### Multi-processing

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) | 14: Multi-core processors - 14.1 Multi-processing systems - 14.1.4 Synchronization

In an SMP ([Symmetric multiprocessing](https://en.wikipedia.org/wiki/Symmetric_multiprocessing)) system, data accesses must frequently be restricted to *one* modifier at any particular time. This can be true for peripheral devices, but also for global variables and data structures accessed by more than one thread or process. Protection of such shared resources is often through a method known as **`mutual exclusion`**. In a multi-core system, you can use a *`spinlock`*, which is effectively a *shared flag* with an atomic *indivisible* mechanism, to test and set its value.

The ARM architecture provides three instructions relating to exclusive access, and variants of these instructions, that operate on byte, halfword, word, or doubleword sized data.

The instructions rely on the ability of the core or memory system to **tag** particular addresses for exclusive access monitoring by that core, using an *exclusive access monitor*. The use of these instructions is common in multi-core systems, but is also found in single core systems, to implement synchronization operations between threads running on the same core.

The A64 instruction set has instructions for implementing such synchronization functions:

- Load Exclusive (`LDXR`): `LDXR W|Xt, [Xn]`
- Store Exclusive (`STXR`): `STXR Ws, W|Xt, [Xn]` where `Ws` indicates whether the store completed successfully. 0 = success.
- Clear Exclusive access monitor (`CLREX`): This is used to clear the state of the Local Exclusive Monitor.

`LDXR` performs a load of memory, but also **tags** the Physical Address to be *monitored* for exclusive access by that core. `STXR` performs a conditional store to memory, succeeding only if the target location is **tagged** as being monitored for exclusive access by *that* core. This instruction returns non-zero in the general-purpose register `Ws` if the store does not succeed, and a value of `0` if the store is successful. In the assembler syntax, it is always specified as a `W` register, that is, not an `X` register. In addition, the `STXR` **clears** the exclusive tag.

### Exclusive monitor

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

## 原子操作(Atomic)

[Concurrency support library (since C++11) - cppreference.com](https://en.cppreference.com/w/cpp/thread#Semaphores)

> These components are provided for fine-grained atomic operations allowing for *lockless concurrent* programming. Each atomic operation is ***indivisible*** with regards to any other atomic operation that involves the same object. Atomic objects are [free of data races](https://en.cppreference.com/w/cpp/language/memory_model#Threads_and_data_races).

本文节选自 [《ARM64体系结构编程与实践》](https://item.jd.com/13119117.html) | 第 20 章 原子操作，仅作学习参考之用途。

原子操作是指保证指令以原子的方式执行，执行过程不会被打断。

【例 20-1】在如下代码片段中，假设 thread_A_func 和 thread_B_func 都尝试进行 i++ 操作，thread-A-func 和 thread-B-func 执行完后，i 的值是多少？

```c
static int i = 0;
void thread_A_func()
{
    i++;
}

void thread_B_func ()
{
    i++;
}
```

有的读者可能认为i等于2，但也可能不等于2，代码的执行过程如下。

=== "CPU0: thread_A_func"

    ```asm
    load i=0

    i++

    store i (i=1)
    ```

=== "CPU1: thread_B_func"

    ```asm
    // assumptive scheduling gap

    load i=0

    i++

    store i (i=1)
    ```

从上面的代码执行过程来看，最终 i 也可能等于1。因为变量 i 位于临界区，CPU0 和 CPU1 可能同时访问，发生并发访问。从CPU角度来看，变量 i 是一个静态全局变量，存储在数据段中，首先读取变量的值并存储到通用寄存器中，然后在通用寄存器里做加法运算，最后把寄存器的数值写回变量 i 所在的内存中。在多处理器体系结构中，上述动作可能同时进行。即使在单处理器体系结构上依然可能存储并发访问，例如 thread_B_func 在某个中断处理函数中执行。

原子操作需要保证不会被打断，如上述的 `i++` 语句就可能被打断。要保证操作的完整性和原子性，通常需要“原子地”（不间断地）完成“**读一修改-回写**”机制，中间不能被打断。在下述操作中，如果其他 CPU 同时对该原子变量进行写操作，则会造成数据破坏。

1. 读取原子变量的值，从内存中读取原子变量的值到寄存器。
2. 修改原子变量的值，在寄存器中修改原子变量的值。
3. 把新值写回内存中，把寄存器中的新值写回内存中。

处理器必须提供原子操作的汇编指令来完成上述操作，如 ARM64 处理器提供 `LDXR` 和 `STXR` 独占访问内存的指令以及原子内存访问操作指令。

### 独占内存访问指令

原子操作需要处理器提供硬件支持，不同的处理器体系结构在原子操作上会有不同的实现。

ARMv8 使用两种方式来实现原子操作：一种是经典的独占加载（Load-Exclusive）和独占存储（Store-Exclusive）指令，这种实现方式叫作连接加载/条件存储（Load-Link/Store-Conditional, `LL/SC`）；另一种是在ARMv8.1体系结构上实现的 `LSE` 指令。

LL/SC 最早用于并发与同步访问内存的 CPU 指令，它分成两部分。

- 第一部分（`LL`）表示从指定内存地址**读取**一个值，并且处理器会监控这个内存地址，看其他处理器是否修改该内存地址。
- 第二部分（`SC`）表示如果这段时间内其他处理器没有修改该内存地址，则把新值**写入**该地址。

因此，一个原子的 LL/SC 操作就是通过 LL 读取值，进行一些计算，最后通过 SC 来写回。如果SC失败，那么重新开始整个操作。

LL/SC 常常用于实现 ***无锁*** 算法与“读-修改-回写”原子操作。很多 RISC 体系结构实现了这种 LL/SC 机制，比如 ARMv8 指令集里实现了 `LDXR` 和 `STXR` 指令。

LDXR 指令是内存独占加载指令，它从内存中以独占方式加教内存地址的信到通用寄存器里。

以下是 `LDXR` 指令的原型，它把 `Xn` 或者 `SP` 地址的值原子地加载到 `Xt` 寄存器里。

```asm
ldxr <xt>, [xn | sp]
```

`STXR` 指令是内存独占存储指令，它以独占的方式把新的数据存储到内存中。这是 `STXR` 指令的原型。

```asm
stxr <ws>, <xt>, [xn | sp]
```

它把 `Xt` 寄存器的值原子地存储到 `Xn` 或者 `SP` 地址里，执行的结果反映到 `Ws` 寄存器中。

- 若 `Ws` 寄存器的值为 0，说明 `LDXR` 和 `STXR` 指令都执行完了。
- 如果结果不是 0，说明 `LDXR` 和 `STXR` 指令都已经发生错误，此时需要跳转到 `LDXR` 指令处，重新做原子加载以及原子存储操作。

LDXP和STXP指令是多字节独占内存访问指令，一条指令可以独占地加载和存储16字节。

```asm
ldxp <xt1>, <xt2>, [xn | sp]
stxp <ws>, <xt1>, <xt2＞, [xn | sp]
```

LDXR 和STXR 指令还可以和加载-获取以及存储-释放内存屏障原语结合使用，构成一个类似于临界区的内存屏障，在一些场景（比如自旋锁的实现）中非常有用。

【例 20-2】下面的代码使用了原子的加法函数。`atomic_add(i,v)` 函数非常简单，它是原子地给 v 加上 i。

```c linenums="1"
    void atomic_add (int i, atomic_t *v)
    {
        unsigned long tmp;
        int result;

        asm volatile("// atomic_add\n"
            "1: ldxr %w0, [%2] \n"
            "   add %w0, %w0, %w3\n"
            "   stxr %w1, %w0, [%2] \n"
            "   cbnz %w1, 1b"
            : "=&r" (result), "=&r" (tmp)
            : "r" (&v->counter), "Ir" (i)
            : "cc") ;
    }
```

其中 `atomic_t` 变量的定义如下。

```c
typede struct {
    int counter;
} atomic_t;
```

在第6~13行中，通过内嵌汇编的方式实现 `atomic_add` 功能。
在第7行中，通过 `LDXR` 独占加载指令来加载 `v->counter` 的值到 `result` 变量中，该指令会标记 `v->counter` 的地址为独占。
在第8行中，通过 **`ADD`** 指令让 `v->counter` 的值加上变量 `i` 的值。
在第9行中，通过 `STXR` 独占存储指令来把最新的 `v->counter` 的值写入 `v->counter` 地址处。
在第10行中，判断 `tmp` 的值。如果 `tmp` 的值为 0，说明 `STXR` 指令存储成功；否则，存储失败。如果存储失败，那只能跳转到第7行重新调用 `LDXR` 指令。
在第11行中，输出部分有两个参数，其中 `result` 和 `tmp` 具有可写属性。
在第12行中，输入部分有两个参数，`v->counter` 的地址只有只读属性，`i` 也只有只读属性。

### 独占内存访问工作原理

我们在前文已经介绍了 `LDXR` 和 `STXR` 指令。`LDXR` 是内存加载指令的一种，不过它会通过独占监视器（exclusive monitor）来监控对内存的访问。

独占监视器会把对应内存地址标记为独占访问模式，保证以独占的方式来访问这个内存地址，不受其他因素的影响。而 `STXR` 是*有条件*的存储指令，它会把新数据写入 `LDXR` 指令标记独占访问的内存地址里。

【例 20-3】下面是一段使用 `LDXR` 和 `STXR` 指令的简单代码。

```asm linenums="1"
my_atomic_set:
1:
    ldxr x2, [x1]
    orr x2, x2, x0
    stxr w3, x2, [x1]
    cbnz w3, 1b
```

在第3行中，读取 X1 寄存器的值，然后以 X1 寄存器的值为地址，以独占的方式加载该地址的内容到 X2 寄存器中。
在第4行中，通过 `ORR` 指令来设置 X2 寄存器的值。
在第5行中，以独占的方式把 X2 寄存器的值写入 X1 寄存器里。若 W3 寄存器的值为0，表示写入成功：若 W3 寄存器的值为1，表示不成功。
在第6行中，判断 W3 寄存器的值，如果 W3 寄存器的值不为0，说明 `LDXR` 和 `STXR` 指令执行失败，需要跳转到第2行的标签1处，重新使用 `LDXR` 指令进行独占加载。

注意，`LDXR` 和 `STXR` 指令是需要**配对使用**的，而且它们之间是原子的，即使我们使用仿真器硬件也没有办法单步调试和执行 `LDXR` 和 `STXR` 指令，即我们无法使用仿真器来单步调试第3~5行的代码，它们是原子的，是一个不可分割的整体。

`LDXR` 指令本质上也是 `LDR` 指令，只不过在 ARM64 处理器内部使用一个独占监视器来监视它的状态。独占监视器一共有两个状态——***开放访问状态*** 和 ***独占访问状态***。

当 CPU 通过 `LDXR` 指令从内存加载数据时，CPU 会把这个内存地址标记为独占访问，然后 CPU 内部的独占监视器的状态变成独占访问状态。当 CPU 执行 `STXR` 指令的时候，需要根据独占监视器的状态来做决定。

1. 如果独占监视器的状态为独占访问状态，并且 `STXR` 指令要存储的地址正好是刚才使用 `LDXR` 指令标记过的，那么 `STXR` 指令存储成功，`STXR` 指令返回0，独占监视器的状态变成开放访问状态。
2. 如果独占监视器的状态为开放访问状态，那么 `STXR` 指令存储失败，`STXR` 指令返回1，独占监视器的状态不变，依然保持开放访问状态。

---

**独占监视器与缓存一致性**：

`LDXR` 指令和 `STXR` 指令在多核之间利用高速缓存一致性协议以及独占监视器来保证执行的 **串行化** 和 **数据一致性**。以 Cortex-A72 为例，L1 数据高速缓存之间的缓存一致性是通过 `MESI` 协议来实现的。

### 原子内存访问操作指令

在 ARMv8.1 体系结构中新增了原子内存访问操作指令（atomic memory access instruction），这个也称为 `LSE`（Large System Extension）。原子内存访问操作指令需要 AMBA 5 总线中的 `CHI`（Coherent Hub Interface）的支持。AMBA 5 总线引入了原子事务（atomic transaction），允许将原子操作发送到数据，并且允许原子操作在靠近数据的地方执行，例如在互连总线上执行原子算术和逻辑操作，而不需要加载到高速缓存中处理。原子事务非常适合要操作的数据离处理器核心比较*远*的情况，例如数据在内存中。

使用独占内存访间指令会导致所有的 CPU 核都把锁加载到 L1 高速缓存中，然后不停地尝试获取锁（使用 `LDXR` 指令来读取锁）和检查独占监视器的状态，导致高速缓存颠簸。这个场最在 NUMA 体系结构下会变得更糟糕，远端节点（remote node）的 CPU 需要不断地跨节点访问数据。另外一个问题是不公平，当锁持有者释放锁时，所有的 CPU 都需要抢这把锁（使用 `STXR` 指令写这个 lock 变量），有可能最先申请锁的 CPU 反而没有抢到锁。

如果使用原子内存访问操作指令，那么最先申请这个锁的 CPU 内核会通过 CHI 互连总线的 HN-F 节点完成算术和逻辑运算，不需要把数据加载到 L1 高速缓存，而且整个过程都是原子的。

在使用这些指令之前需要确认一下你使用的 CPU 是否支持这个特性。我们可以通过 `ID_AA64ISAR0_EL1` 寄存器中的 `atomic` 域来判断 CPU 是否支持 LSE 特性。

LSE 指令中主要新增了如下三类指令。

- 比较并交换（Compare And Swap, `CAS`）指令。
- 原子内存访问指令，比如 `LDADD` 指令，用于原子地加载内存地址的值，然后进行加法运算；`STADD` 指令原子地对内存地址的值进行加法运算，然后把结果存储到这个内存地址里。
- 交换指令（Swap）。

原子内存访问指令分成两类。

- 原子加载（atomic load）指令，先原子地加载，然后做运算。
- 原子存储（atomic store）指令，先运算，然后原子地存储。

上述两类指令的执行过程都是原子性的。

【例 20-5】下面以 `STADD` 指令来实现 `atomic_add()` 函数。

```c linenums="1"
static inline void atomic_add(int i, atomic_t *v)
{
    asm volatile(
        "stadd %w[i], %[v]\n"
        : [i] "+r" (i), [v] "+Q" (v-›counter)
        :
        : "cc");
}
```

在第4行中，使用 `STADD` 指令来把变量i的值添加到 `v->counter` 中
在第5行中，输出操作数列表，描述在指令部分中可以修改的C语言变量以及约束条件，其中变量 `i` 和 `v->counter` 都具有可读、可写属性。
在第7行中，改变资源列表。即告诉编译器哪些资源已修改，需要更新。

使用原子内存访问操作指令来实现 `atomic_add()` 函数非常高效。

【例 20-6】下面使用 `LDUMAX`（无符号的最大值加载） 指令来实现经典的自旋锁。

> 获取自旋锁的函数原型为 `get_lock()`。

```asm linenums="1"
#define LOCK 1
#define UNLOCK 0

//函数原型：get_lock(lock)
get_lock:
    mov x1, #LOCK

retry:
    ldumaxa x1, x2, [x0]
    cbnz x2, retry
    ret
```

首先比较 X1 寄存器的值与 [X0]（[X0] 表示以 X0 寄存器的值为地址）的值，然后把 *最大值* 写入以 X0 寄存器的值为地址的内存中。最后，返回 [X0] 的旧值，存放在 X2 寄存器中。
X2 寄存器存储了锁的旧值，如果 X2 寄存器的值为1，那么说明锁已经被其他进程持有了，当前 CPU 获取锁失败。如果 X2 寄存器的值为0，说明当前 CPU 成功获取了锁。

释放锁比较简单，使用 `STLR` 指令来往锁的地址写0即可。

```asm
//释放锁：release_lock(lock)
release_lock:
    mov x1, #UNLOCK
    stlr x1, [x0]
```

#### 比较并交换指令(CAS)

比较并交换（CAS）指令在 ***无锁*** 实现中起到非常重要的作用。比较并交换指令的伪代码如下。

```c linenums="1"
int compare_swap(int *ptr, int expected, int new)
{
    int actual = *ptr;
    if (actual == expected) {
        *ptr = new;
    }
    return actual;
}
```

CAS 指令的基本思路是检查 `ptr` 指向的值与 `expected` 是否相等。若相等，则把 `new` 的值赋值给 `ptr`；否则，什么也不做。
不管是否相等，最终都会返回 `ptr` 的旧值，让调用者来判断该比较并交换指令执行是否成功。

ARM64 处理器提供了 CAS 指令。CAS 指令根据内存屏障属性分成4类，如表20.2所示。

- 隐含了加载-获取内存屏障原语。
- 隐含了存储-释放内存屏障原语。
- 同时隐含了加载-获取和存储-释放内存屏障原语。
- 不隐含内存屏障原语。

Linux 内核中常见的比较并交换函数是 `cmpxchg()`。由于 Linux 内核最早是基于 x86 体系结构来实现的，x86指令集中对应的指令是 `CMPXCHG` 指令，因此 Linux 内核使用该名字作为函
数名。

【例 20-7】对于 ARM64 体系结构，`cmpxchg_mb_64()` 函数的实现如下。

```c linenums="1"
u64 cmpxchg_mb_64 (volatile void *ptr, u64 old, u64 new)
{
    u64 tmp;

    asm volatile(
    "   mov x30, %x[old]\n"
    "   casal x30, %x[new], %[v]\n"
    "   mov %x[ret], x30"
    : [ret] "+r" (tmp), [v] "+Q" (*(unsigned long *)ptr)
    : [old] "r" (old), [new] "r" (new)
    : "memory");

    return tmp;
}
```

在第6行中，把 `old` 参数（expected）加载到 `X30` 寄存器中。
在第7行中，使用 `CASAL` 指令来执行比较并交换操作。比较 `ptr` 的值是否与 `X30` 的值相等，若相等，则把 `new` 的值设置到 `ptr` 中。

> 注意，这里 `CASAL` 指令隐含了加载-获取和存储-释放内存屏障原语。

在第8行中，通过 `ret` 参数返回 `X30` 寄存器的值。

除 `cmpxchg()` 函数之外，Linux 内核还实现了多个变体，如表20.3所示。这些函数在 ***无锁*** 机制的实现中起到了非常重要的作用。

cmpxchg() 函数的变体 | 描述
---------------------|-----------------------------
cmpxchg_acquire()    | 比较并交换操作，隐含了加载-获取内存屏障原语
cmpxchg_release()    | 比较并交换操作，隐含了存储-释放内存屏障原语
cmpchg_relaxed()     | 比较并交换操作，不隐含任何内存屏障原语
cmpxchg()            | 比较并交换操作，隐含了加载-获取和存储-释放内存屏障原语
