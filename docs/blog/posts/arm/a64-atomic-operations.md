---
title: ARM64 Atomic operations
authors:
    - xman
date:
    created: 2023-10-12T10:00:00
categories:
    - arm
tags:
    - LL/SC
    - LSE
    - CAS
comments: true
---

原子操作是指保证指令以原子的方式执行，执行过程不会被打断。

<!-- more -->

[Concurrency support library (since C++11) - cppreference.com](https://en.cppreference.com/w/cpp/thread#Semaphores)

> These components are provided for fine-grained atomic operations allowing for *lockless concurrent* programming. Each atomic operation is ***indivisible*** with regards to any other atomic operation that involves the same object. Atomic objects are [free of data races](https://en.cppreference.com/w/cpp/language/memory_model#Threads_and_data_races).

本文节选自 [《ARM64体系结构编程与实践》](https://item.jd.com/13119117.html) | 第 20 章 原子操作，仅作学习参考之用途。

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

```asm
CPU0: thread_A_func   |     CPU1: thread_B_func
load i=0              |     
                      |     load i=0
i++                   |     
                      |     i++
store i (i=1)         |     
                      |     store i (i=1)
```

从上面的代码执行过程来看，最终 i 也可能等于1。因为变量 i 位于临界区，CPU0 和 CPU1 可能同时访问，发生并发访问。从CPU角度来看，变量 i 是一个静态全局变量，存储在数据段中，首先读取变量的值并存储到通用寄存器中，然后在通用寄存器里做加法运算，最后把寄存器的数值写回变量 i 所在的内存中。在多处理器体系结构中，上述动作可能同时进行。即使在单处理器体系结构上依然可能存储并发访问，例如 thread_B_func 在某个中断处理函数中执行。

原子操作需要保证不会被打断，如上述的 `i++` 语句就可能被打断。要保证操作的完整性和原子性，通常需要“原子地”（不间断地）完成“**读一修改-回写**”机制，中间不能被打断。在下述操作中，如果其他 CPU 同时对该原子变量进行写操作，则会造成数据破坏。

1. 读取原子变量的值，从内存中读取原子变量的值到寄存器。
2. 修改原子变量的值，在寄存器中修改原子变量的值。
3. 把新值写回内存中，把寄存器中的新值写回内存中。

处理器必须提供原子操作的汇编指令来完成上述操作，如 ARM64 处理器提供 `LDXR` 和 `STXR` 独占访问内存的指令以及原子内存访问操作指令。

## 独占内存访问指令

原子操作需要处理器提供硬件支持，不同的处理器体系结构在原子操作上会有不同的实现。

ARMv8 使用两种方式来实现原子操作：一种是经典的独占加载（Load-Exclusive）和独占存储（Store-Exclusive）指令，这种实现方式叫作连接加载/条件存储（Load-Link/Store-Conditional, `LL/SC`）；另一种是在ARMv8.1体系结构上实现的 `LSE` 指令。

LL/SC 最早用于并发与同步访问内存的 CPU 指令，它分成两部分。

- 第一部分（`LL`）表示从指定内存地址**读取**一个值，并且处理器会监控这个内存地址，看其他处理器是否修改该内存地址。
- 第二部分（`SC`）表示如果这段时间内其他处理器没有修改该内存地址，则把新值**写入**该地址。

因此，一个原子的 LL/SC 操作就是通过 LL 读取值，进行一些计算，最后通过 SC 来写回。如果SC失败，那么重新开始整个操作。

LL/SC 常常用于实现 ***无锁*** 算法与“读-修改-回写”原子操作。很多 RISC 体系结构实现了这种 LL/SC 机制，比如 ARMv8 指令集里实现了 `LDXR` 和 `STXR` 指令。

[LDXR](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/LDXR--Load-exclusive-register-) 是内存独占加载指令，它从内存中以独占方式加载内存地址的信到通用寄存器里。

以下是 `LDXR` 指令的原型，它把 `Xn` 或者 `SP` 地址的值原子地加载到 `Xt` 寄存器里。

```asm
ldxr <xt>, [xn | sp]
```

[STXR](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/STXR--Store-exclusive-register-) 是内存独占存储指令，它以独占的方式把新的数据存储到内存中。

以下是 `STXR` 指令的原型，它把 `Xt` 寄存器的值原子地存储到 `Xn` 或者 `SP` 地址里，执行的结果反馈到 `Ws` 寄存器中。

```asm
stxr <ws>, <xt>, [xn | sp]
```

- 若 `Ws` 寄存器的值为 0，说明 `LDXR` 和 `STXR` 指令都执行完了。
- 如果结果不是 0，说明 `LDXR` 和 `STXR` 指令都已经发生错误，此时需要跳转到 `LDXR` 指令处，重新做原子加载以及原子存储操作。

[LDXP](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/LDXP--Load-exclusive-pair-of-registers-) 和 [STXP](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/STXP--Store-exclusive-pair-of-registers-) 指令是多字节独占内存访问指令，一条指令可以独占地加载和存储16字节。

```asm
ldxp <xt1>, <xt2>, [xn | sp]
stxp <ws>, <xt1>, <xt2＞, [xn | sp]
```

`LDXR` 和 `STXR` 指令还可以和加载-获取以及存储-释放内存屏障原语结合使用，构成一个类似于临界区的内存屏障，在一些场景（比如自旋锁的实现）中非常有用。

【例 20-2】下面的代码使用了原子的加法函数。`atomic_add(i,v)` 函数非常简单，它是原子地给 v 加上 i。

> 关于 C 代码内嵌 ASM 汇编，参考 [GCC Extended Asm - C/C++ inline assembly](../toolchain/gcc-ext-asm.md)，其中有本文相关案例的详细说明。

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

【例 20-3】下面是一段使用 `LDXR` 和 `STXR` 指令进行独占访问的代码片段。

```asm linenums="1"
my_atomic_set:
1:
    ldxr x2, [x1]
    orr x2, x2, x0
    stxr w3, x2, [x1]
    cbnz w3, 1b
```

在第3行中，读取 X1 寄存器的值，然后以 X1 寄存器的值为地址，以独占的方式加载该地址的内容到 X2 寄存器中。
在第4行中，通过 [ORR](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/ORR--shifted-register---Bitwise-OR--shifted-register--)(Bitwise OR) 指令来设置 X2 寄存器的值：x2 = x2|x0。
在第5行中，以独占的方式把 X2 寄存器的值写回 X1 寄存器里。若 W3 寄存器的值为0，表示回写成功；否则，表示回写失败。
在第6行中，判断 W3 的值如果非0，表明上面的 `LDXR`/`STXR` 指令对执行失败，跳转到第2行的标签1处，重新尝试 `LDXR` 指令进行独占加载。

注意，`LDXR` 和 `STXR` 指令是需要**配对使用**的，而且它们之间是原子的，即使我们使用仿真器硬件也没有办法单步调试和执行 `LDXR` 和 `STXR` 指令，即我们无法使用仿真器来单步调试第3~5行的代码，它们是原子的，是一个不可分割的整体。

`LDXR` 指令本质上也是 `LDR` 指令，只不过在 ARM64 处理器内部使用一个独占监视器来监视它的状态。独占监视器一共有两个状态——***开放访问状态*** 和 ***独占访问状态***。

当 CPU 通过 `LDXR` 指令从内存加载数据时，CPU 会把这个内存地址标记为独占访问，然后 CPU 内部的独占监视器的状态变成独占访问状态。当 CPU 执行 `STXR` 指令的时候，需要根据独占监视器的状态来做决定。

1. 如果独占监视器的状态为独占访问状态，并且 `STXR` 指令要存储的地址正好是刚才使用 `LDXR` 指令标记过的，那么 `STXR` 指令存储成功，反馈结果0，独占监视器的状态变成开放访问状态。
2. 如果独占监视器的状态为开放访问状态，那么 `STXR` 指令存储失败，反馈结果1，独占监视器的状态不变，依然保持开放访问状态。

---

**独占监视器与缓存一致性**：

`LDXR` 指令和 `STXR` 指令在多核之间利用高速缓存一致性协议以及独占监视器来保证执行的 **串行化** 和 **数据一致性**。以 Cortex-A72 为例，L1 数据高速缓存之间的缓存一致性是通过 `MESI` 协议来实现的。

## 原子内存访问操作指令

在 ARMv8.1 体系结构中新增了原子内存访问操作指令（atomic memory access instruction），这个也称为 `LSE`（Large System Extension）。原子内存访问操作指令需要 AMBA 5 总线中的 `CHI`（Coherent Hub Interface）的支持。AMBA 5 总线引入了原子事务（atomic transaction），允许将原子操作发送到数据，并且允许原子操作在靠近数据的地方执行，例如在互连总线上执行原子算术和逻辑操作，而不需要加载到高速缓存中处理。原子事务非常适合要操作的数据离处理器核心比较*远*的情况，例如数据在内存中。

使用独占内存访间指令会导致所有的 CPU 核都把锁加载到 L1 高速缓存中，然后不停地尝试获取锁（使用 `LDXR` 指令来读取锁）和检查独占监视器的状态，导致高速缓存颠簸。这个场最在 NUMA 体系结构下会变得更糟糕，远端节点（remote node）的 CPU 需要不断地跨节点访问数据。另外一个问题是不公平，当锁持有者释放锁时，所有的 CPU 都需要抢这把锁（使用 `STXR` 指令写这个 lock 变量），有可能最先申请锁的 CPU 反而没有抢到锁。

如果使用原子内存访问操作指令，那么最先申请这个锁的 CPU 内核会通过 CHI 互连总线的 HN-F 节点完成算术和逻辑运算，不需要把数据加载到 L1 高速缓存，而且整个过程都是原子的。

在使用这些指令之前需要确认一下你使用的 CPU 是否支持这个特性。我们可以通过 `ID_AA64ISAR0_EL1` 寄存器中的 `atomic` 域来判断 CPU 是否支持 LSE 特性。

LSE 指令中主要新增了如下三类指令。

- 比较并交换（Compare And Swap）指令：[CAS](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/CAS--CASA--CASAL--CASL--Compare-and-swap-word-or-doubleword-in-memory-)。

    - `CASA` and `CASAL` load from memory with *acquire* semantics.
    - `CASL` and `CASAL` store to memory with *release* semantics.
    - `CAS` has no memory ordering requirements.

- 原子内存访问指令，比如 [LDADD](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/LDADD--LDADDA--LDADDAL--LDADDL--Atomic-add-on-word-or-doubleword-in-memory-) 指令，用于原子地加载内存地址的值，然后进行加法运算；[STADD](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/STADD--STADDL--Atomic-add-on-word-or-doubleword-in-memory--without-return--an-alias-of-LDADD--LDADDA--LDADDAL--LDADDL-) 指令原子地对内存地址的值进行加法运算，然后把结果存储到这个内存地址里。
- 交换（Swap）指令：[SWP](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/SWP--SWPA--SWPAL--SWPL--Swap-word-or-doubleword-in-memory-)。

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
        : [i] "+r" (i), [v] "+Q" (v->counter)
        :
        : "cc");
}
```

在第4行中，使用 `STADD` 指令来把变量 `i` 的值添加到 `v->counter` 中。
在第5~7行，详情参考 [GCC Extended Asm - C/C++ inline assembly](../toolchain/gcc-ext-asm.md)。

使用原子内存访问操作指令来实现 `atomic_add()` 函数非常高效。

??? note "linux/arch/arm64 - arch_atomic_add(int i, atomic_t *v)"

    1. [atomic.h](https://github.com/torvalds/linux/blob/master/arch/arm64/include/asm/atomic.h) 中定义了函数 `arch_atomic_add`，其调用 `__lse_ll_sc_body`：

    ```c
    // arch/arm64/include/asm/atomic.h

    #define ATOMIC_OP(op)							\
    static __always_inline void arch_##op(int i, atomic_t *v)		\
    {									\
        __lse_ll_sc_body(op, i, v);					\
    }

    ATOMIC_OP(atomic_add)
    ```

    2. lse.h 中定义了函数宏 `__lse_ll_sc_body` 调用 `__lse_atomic_add`：

    ```c
    // arch/arm64/include/asm/lse.h

    #ifdef CONFIG_ARM64_LSE_ATOMICS

    #define __lse_ll_sc_body(op, ...)					\
    ({									\
        alternative_has_cap_likely(ARM64_HAS_LSE_ATOMICS) ?		\
            __lse_##op(__VA_ARGS__) :				\
            __ll_sc_##op(__VA_ARGS__);				\
    })

    #else
    ```

    3. atomic_lse.h 中实现了函数 `__lse_atomic_add`，asm_op=`stadd`：

    ```c
    // arch/arm64/include/asm/atomic_lse.h

    #define ATOMIC_OP(op, asm_op)						\
    static __always_inline void						\
    __lse_atomic_##op(int i, atomic_t *v)					\
    {									\
        asm volatile(							\
        __LSE_PREAMBLE							\
        "	" #asm_op "	%w[i], %[v]\n"				\
        : [v] "+Q" (v->counter)						\
        : [i] "r" (i));							\
    }

    ATOMIC_OP(add, stadd)
    ```

【例 20-6】下面使用 [LDUMAX](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/LDUMAX--LDUMAXA--LDUMAXAL--LDUMAXL--Atomic-unsigned-maximum-on-word-or-doubleword-in-memory-)（无符号的最大值加载） 指令来实现经典的自旋锁。

Linux arch/arm 下的头文件 spinlock_types.h 定义了 `arch_spinlock_t` 类型：

```c
// arch/arm/include/asm/spinlock_types.h
typedef struct {
	union {
		u32 slock;
		struct __raw_tickets {
#ifdef __ARMEB__
			u16 next;
			u16 owner;
#else
			u16 owner;
			u16 next;
#endif
		} tickets;
	};
} arch_spinlock_t;
```

ARM 上锁操作，参考 spinlock.h 中定义的函数 `arch_spin_lock(arch_spinlock_t *lock)`；ARM64 参考 arch/arm64/kvm/hyp/include/nvhe/spinlock.h 中的函数 `hyp_spin_lock(hyp_spinlock_t *lock)`。

以 ARM 下的 `arch_spinlock_t` 为例，基于 `LDUMAXA` 指令实现获取自旋锁的函数原型 `get_lock(&lock->slock)`。

```asm linenums="1"
#define LOCK 1
#define UNLOCK 0

get_lock:
    mov x1, #LOCK

retry:
    ldumaxa x1, x2, [x0]
    cbnz x2, retry
    ret
```

1. `X0` 寄存器存放入参，即锁变量 `lock->slock` 的地址。
2. `LDUMAXA` 的后缀 `A` 代表 “Acquire”，隐含加载-获取屏障原语。

!!! note "LDUMAX inst"

    `LDUMAX <Xs>, <Xt>, [<Xn|SP>]` => Xt = \*Xn; \*Xn = MAX(Xt, Xs);

    This instruction atomically loads a 32-bit word or 64-bit doubleword from memory addressed by `Xn` to `Xt`, compares it (`Xt`) against the value held in register `Xs`, and stores the larger value back to memory addressed by `Xn`, treating the values as unsigned numbers. The value initially loaded from memory is returned in the destination register (`Xt`).

1. `LDUMAX` 加载指针 `X0` 指向的值（当前锁变量 slock）到 `X2`，然后比较 `X2` 和 `X1`（LOCK=1），将其中的大值写入 `X0` 指向的内存中。
2. 如果 `X2` 保存的锁的旧值为1，说明锁已经被其他 CPU 持有，slock 被写入 1，维持被占用状态。否则，说明锁处于空闲状态，slock 被写入 1，当前 CPU 成功上锁。

释放锁比较简单，使用 `STLR` 指令来往锁的地址写 0 即可。

```asm
//释放锁：release_lock(lock)
release_lock:
    mov x1, #UNLOCK
    stlr x1, [x0]
```

### 比较并交换指令(CAS)

比较并交换（CAS）指令在 ***无锁*** 实现中起到非常重要的作用。

!!! note "CAS inst"

    `CAS <Xs>, <Xt>, [<Xn|SP>{, #0}]` => if (\*Xn == Xs) \*Xn = Xt

    This instruction reads a 32-bit word or 64-bit doubleword from memory addressed by `Xn`, and compares it against the value held in a first register `Xs`. If the comparison is equal, the value in a second register `Xt` is written to memory addressed by `Xn`. If the write is performed, the read and write occur atomically such that no other modification of the memory location can take place between the read and write.

ARM64 处理器提供的 `CAS` 指令根据内存屏障属性分成4类：

- 隐含了加载-获取内存屏障原语：`CASA`。
- 隐含了存储-释放内存屏障原语：`CASL`。
- 同时隐含了加载-获取和存储-释放内存屏障原语：`CASAL`。
- 不隐含内存屏障原语：`CAS`。

比较并交换指令的伪代码如下：

```c linenums="1"
// ptr->Xn; expected->Xs; new->Xt
int compare_swap(int *ptr, int expected, int new)
{
    int actual = *ptr;
    if (actual == expected) {
        *ptr = new;
    }
    return actual;
}
```

检查 `ptr` 指向的值与 `expected` 是否相等：若相等，则把 `new` 的值赋值给 `ptr`；否则，什么也不做。
不管是否相等，最终都会返回 `ptr` 的旧值，让调用者来判断该比较并交换指令执行是否成功。

Linux 内核中常见的比较并交换函数是 `cmpxchg()`。由于 Linux 内核最早是基于 x86 体系结构来实现的，x86指令集中对应的指令是 `CMPXCHG` 指令，因此 Linux 内核沿用该函数名。

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

在第6行中，把 `old` 参数（expected）加载到 `X30` 寄存器中：`X30 = old`。
在第7行中，`CASAL` 指令比较 `*ptr` 的值是否与 `X30` 的值相等，若相等则设置 `*ptr = new`。
在第8行中，将 `X30` 寄存器的值移动到 `ret` 参数（符号变量 `tmp`），最为最终 return 返回值。

Linux 内核实现了 `cmpxchg()` 函数的多个变体，如下表所示。这些函数在 ***无锁*** 机制的实现中起到了非常重要的作用。

cmpxchg() 函数的变体 | 描述
---------------------|-----------------------------
cmpxchg_acquire()    | 比较并交换操作，隐含了加载-获取内存屏障原语（`CASA`）
cmpxchg_release()    | 比较并交换操作，隐含了存储-释放内存屏障原语（`CASL`）
cmpchg_relaxed()     | 比较并交换操作，不隐含任何内存屏障原语（`CAS`）
cmpxchg()            | 比较并交换操作，隐含了加载-获取和存储-释放内存屏障原语（`CASAL`）

??? note "linux/arch/arm64 - __cmpxchg_case_mb_64(volatile void *ptr, u##sz old, u##sz new)"

    1. [cmpxchg.h](https://github.com/torvalds/linux/blob/master/arch/arm64/include/asm/cmpxchg.h) 中定义了函数 `__cmpxchg_case_mb_64`，其调用 `__lse_ll_sc_body`：

    ```c
    // arch/arm64/include/asm/cmpxchg.h

    #define __CMPXCHG_CASE(name, sz)			\
    static inline u##sz __cmpxchg_case_##name##sz(volatile void *ptr,	\
                            u##sz old,		\
                            u##sz new)		\
    {									\
        return __lse_ll_sc_body(_cmpxchg_case_##name##sz,		\
                    ptr, old, new);				\
    }

    __CMPXCHG_CASE(mb_, 64)
    ```

    2. lse.h 中定义了函数宏 `__lse_ll_sc_body` 调用 `__lse__cmpxchg_case_mb_64`：

    ```c
    // arch/arm64/include/asm/lse.h

    #ifdef CONFIG_ARM64_LSE_ATOMICS

    #define __lse_ll_sc_body(op, ...)					\
    ({									\
        alternative_has_cap_likely(ARM64_HAS_LSE_ATOMICS) ?		\
            __lse_##op(__VA_ARGS__) :				\
            __ll_sc_##op(__VA_ARGS__);				\
    })

    #else
    ```

    3. atomic_lse.h 中实现了函数 `__lse__cmpxchg_case_mb_64`，mb=`al`, asm_op=`casal`：

    ```c
    // arch/arm64/include/asm/atomic_lse.h

    #define __CMPXCHG_CASE(w, sfx, name, sz, mb, cl...)			\
    static __always_inline u##sz						\
    __lse__cmpxchg_case_##name##sz(volatile void *ptr,			\
                            u##sz old,		\
                            u##sz new)		\
    {									\
        asm volatile(							\
        __LSE_PREAMBLE							\
        "	cas" #mb #sfx "	%" #w "[old], %" #w "[new], %[v]\n"	\
        : [v] "+Q" (*(u##sz *)ptr),					\
        [old] "+r" (old)						\
        : [new] "rZ" (new)						\
        : cl);								\
                                        \
        return old;							\
    }

    __CMPXCHG_CASE(x,  ,  mb_, 64, al, "memory")
    ```

## linux/include

LSE/LL_SC:

- arch/arm64/include/asm/atomic_ll_sc.h
- arch/arm64/include/asm/atomic_lse.h
- [arch/arm64/include/asm/lse.h](https://github.com/torvalds/linux/blob/master/arch/arm64/include/asm/lse.h#L4)

atomic.h: 

> [linux/Documentation/atomic_t.txt](https://github.com/torvalds/linux/blob/master/Documentation/atomic_t.txt)

- [include/linux/atomic.h](https://github.com/torvalds/linux/blob/master/include/linux/atomic.h)
- include/asm-generic/atomic.h
- arch/x86/include/asm/atomic.h
- arch/arm/include/asm/atomic.h
- [arch/arm64/include/asm/atomic.h](https://github.com/torvalds/linux/blob/master/arch/arm64/include/asm/atomic.h)

cmpxchg.h:

- include/asm-generic/cmpxchg.h
- arch/x86/include/asm/cmpxchg.h
- arch/arm/include/asm/cmpxchg.h
- [arch/arm64/include/asm/cmpxchg.h](https://github.com/torvalds/linux/blob/master/arch/arm64/include/asm/cmpxchg.h)

## references

[Atomic operation in aarch64](http://www.wowotech.net/armv8a_arch/492.html)
[ARMv8.1平台下新添加原子操作指令](https://blog.csdn.net/Roland_Sun/article/details/107552574)

[眉目传情之匠心独运的kfifo](https://blog.csdn.net/chen19870707/article/details/39899743)
[眉目传情之并发无锁环形队列的实现](https://blog.csdn.net/chen19870707/article/details/39994303)

[Linux 内核：匠心独运之无锁环形队列kfifo](https://blog.csdn.net/s2603898260/article/details/109559233) - [代码走读](https://blog.csdn.net/yusiguyuan/article/details/41985907)，[难点理解](https://blog.csdn.net/readnap/article/details/118938656)
[DPDK 无锁环形队列(rte_ring)详解](https://blog.csdn.net/s2603898260/article/details/109565922) - [DPDK: lib/ring/rte_ring.h](https://doc.dpdk.org/api/rte__ring_8h.html)，[深入理解](https://blog.csdn.net/qq_15437629/article/details/78147874)
