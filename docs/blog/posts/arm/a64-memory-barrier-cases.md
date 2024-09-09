---
title: ARM64内存屏障指令案例分析
authors:
    - xman
date:
    created: 2023-10-08T12:00:00
categories:
    - arm
tags:
    - messaging
    - spin_lock
comments: true
---

本篇以消息传递和自旋锁为案例，演示了 ARM64 中 [Multiprocessing](https://en.wikipedia.org/wiki/Multiprocessing) (`MP`) 场景下的内存屏障典型运用。

<!-- more -->

本文节选自 [《ARM64体系结构编程与实践》](https://item.jd.com/13119117.html) | 第 18 章 内存屏障指令 - 18.3 案例分析，仅作学习参考之用途。

首先，对本节的案例做一些前置约定，主要是定义了两条伪指令宏块 `WAIT` 和 `WAIT_ACQ`。

**`WAIT([xn]==1)`**：表示一直在等待 Xn 寄存器的值等于1，伪代码如下。

```asm
loop:
    ldr w12, [xn]
    cmp w12, #1
    b.ne loop
```

**`WAIT_ACQ([xn]==1)`**：在 `WAIT` 后面加了 ACQ，表示加了加载-获取内存屏障原语。从原来的 `LDR` 指令改成了内置加载-获取内存屏障原语的 `LDAR` 指令，因此 `WAIT_ACQ` 后面的加载存储指令**不会**提前执行，这对等待标志位的操作是非常有用的，伪代码如下。

```asm
loop:
    ldar w12, [xn]
    cmp w12, #1
    b.ne loop
```

## 消息传递问题

【例 18-12】在弱一致性内存模型下，CPU1 和 CPU2 通过传递以下代码片段来传递消息。

```asm
//CPU1
    str x5, [x1] ;  // 写入新数据
    str x0, [x2] ;  // 设置标志位

//CPU2
    WAIT([x2]==1) ; // 等待标志位
    ldr x5, [x1] ;  // 读取新数据
```

CPU1 先执行 `STR` 指令，往 [X1] 处写入新数据，然后设置 X2 寄存器来通知 CPU2，数据已经准备好了。在 CPU2 侧，使用 `WAIT` 语句轮询等待 X2 寄存器置位，然后读取 [X1] 的内容。

CPU1 和 CPU2 都是乱序执行的 CPU，所以 CPU 不一定会按照次序来执行程序。例如，CPU1 可能会先设置 X2 寄存器，然后再写入新数据；CPU2 也有可能先读 X1 寄存器，然后再等 X2 寄存器的标志位，于是 CPU2 读取了错误的数据。

我们可以使用加载-获取以及存储-释放内存屏障原语来解决这个问题，代码如下。

```asm linenums="1" hl_lines="3 6"
//CPU1
    str x5, [x1] ;      // 写入新数据
    stlr x0, [x2] ;     // 设置标志位

//CPU2
    WAIT_ACQ([x2]==1) ; // 等待标志位
    ldr x5, [x1];       // 读取新数据
```

在 CPU1 侧，使用 `STLR` 指令来存储 [X2] 的值。第2行的 `STR` 指令不能向前越过 `STLR` 指令，例如提前重排到第4行，因为 `STLR` 指令本身就内置了存储-释放内存屏障原语。
在 CPU2 侧，使用 `WAIT_ACQ` 来等待 [X2] 置位。前面提到，`WAIT_ACQ` 会内置加载-获取内存屏障原语。第7行的 `LDR` 指令不能向后越过 `WAIT_ACQ`，例如往后重排到第5行，因为 WAIT_ACQ 使用了 `LDAR` 指令，隐含了加载-获取内存屏障。

使用加载-获取和存储-释放内存屏障原语的组合，比直接使用 DMB 指令，在性能上要好一些。

在 CPU2 侧，我们也可以通过构造一个地址依赖解决乱序执行问题。

```asm linenums="1" hl_lines="7 8"
//CPU1
    str x5, [x1] ;      // 写入新数据
    stlr x0, [x2] ;     // 设置标志位

//CPU2
    WAIT([x2]==1) ;     // 等待标志位
    and w12, w12, wzr ; // w12 寄存器在 WAIT 宏中
    ldr x5, [x1, w12] ; // 读取新数据
```

上述代码巧妙地利用 `W12` 寄存器构造了一个地址依赖关系。

在第6行中，`WAIT` 宏使用了 `W12` 寄存器。在第7行中，使用 `W12` 寄存器的值作为地址偏移量，它们之间存在地址依赖，因此这里不需要使用加载-获取内存屏障原语。

## 单方向内存屏障与自旋锁

ARMv8 指令集里把加载-获取和存储-释放内存屏障原语集成到了**独占**内存访问指令中。根据结合的情况，分成下面 4 种情况。

1. 没有集成屏障原语的 [LDXR](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/LDXR--Load-exclusive-register-) 和 [STXR](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/STXR--Store-exclusive-register-) 指令。注意：ARM32 对应指令的写法是 `LDREX` 和 `STREX`。
2. 仅仅集成了加载-获取内存屏障原语的 *`LDAXR`* 和 `STXR` 指令。
3. 仅仅集成了存储-释放内存屏障原语的 `LDXR` 和* `STLXR`* 指令。
4. 同时集成了加载-获取和存储-释放内存屏障原语的 [LDAXR](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/LDAXR--Load-acquire-exclusive-register-) 和 [STLXR](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/STLXR--Store-release-exclusive-register-) 指令。

> 关于配对使用的独占内存访问指令 `LDXR`/`STXR`（Load-Link/Store-Conditional, LL/SC 实现机制），参考 *第 20 章 原子操作* - *20.2 独占内存访问指令* 和 *20.3 独占内存访问工作原理*。

在使用原子加载存储指令时，可以通过清除全局监视器来触发一个事件，从而唤醒因为 `WFE` 指令而睡眠的 CPU，这样不需要 `DSB` 和 `SEV` 指令，这通常会在自旋锁（spin lock）的实现中用到。

> ARM 架构下，有一个全局的事件寄存器（Event Register），系统中的每一个 CPU 核在这个寄存器上都有对应的位。

### 实现经典自旋锁

自旋锁的实现原理非常简单。当锁变量 `lock` 的值为 0 时，表示锁是空闲的；当锁变量 `lock` 的值为 1 时，表示锁已经被 CPU 持有。

【例 18-13】下面是一段获取自旋锁的伪代码，其中 X1 寄存器存放了自旋锁，W0 寄存器的值为 1。

```asm linenums="1" hl_lines="3 5"
prfm pstl1keep, [x1]
loop:
    ldaxr w5, [x1]
    cbnz w5, loop
    stxr w5, w0, [x1]
    cbnz w5, loop
    ; //成功获取了锁
```

在第1行中，[PRFM](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/PRFM--register---Prefetch-memory--register--) 是预取指令，把 *lock* 先预取到高速缓存里，起到加速的作用。
在第3行中，使用内置了加载-获取内存屏障原语的独占访问指令 `LDAXR` 来读取 *lock* 的值。
在第4行中，判断 *lock* 的值是否为0，如果不等于0，说明其他 CPU 持有了锁，那只能继续跳转到 loop 标签处并***自旋***。当 lock 的值为 0 的时候，说明这个锁已经释放了，是空闲的。
在第5行中，`STXR` 指令与第三行的 `LDXR` 指令配对使用，把 W0 的值（1）写入 lock 地址，这样就获取了锁。W5 寄存器用来接收 `STXR` 指令操作的返回值（the status result）。
在第6行中，判断 `STXR` 指令的返回值 W5，如果等于 0，说明原子性的写入成功；如果不等于 0，则说明写入失败，只能继续跳转到 loop 标签处继续***自旋***。
在第7行中，成功获取了锁。

这里只使用内置加载-获取内存屏障原语的独占访间指令就足够了，主要用于防止在临界区里的加载/存储指令被乱序重排到临界区外面。

### 释放自旋锁

释放自旋锁不需要使用独占存储指令，因为通常只有锁持有者会修改和更新这个锁。不过，为了让其他观察者（其他 CPU 内核）能看到这个锁的变化，还需要使用存储-释放内存屏障原语。

【例 18-14】释放锁的伪代码如下。

```asm
... //锁的临界区里的读写操作
stlr wzr, [x1] ; 清除锁
```

释放锁时只需要使用 `STLR` 指令往 *lock* 里写 0 即可。`STLR` 指令内置了存储-释放内存屏障原语，阻止锁的临界区里的加载/存储指令越出临界区。

### WFE+SEV 优化自旋锁

如果实现了 [WFE](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/WFE--Wait-for-event-)（Wait For Event）指令将当前 CPU 核切换到低功耗模式，那就一定要实现 `SEV` 指令，否则该 CPU 核有可能会一直不被唤醒。

[SEV](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/SEV--Send-event-)（Send Event）指令将向系统中的所有 CPU 核发送事件。对应系统中的每个 CPU 核，**设置**事件寄存器（Event Register）相应的位。如果某个 CPU 核正在等待事件（`WFE`），那么该 CPU 核会被立即唤醒，并**清除**掉表示该 CPU 的事件寄存器相应的位。

[SEVL](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/SEVL--Send-event-local-)（Send Event Locally）为发送本地事件指令。不同于 `SEV` 指令，这条指令只会向*当前* CPU 核心发送。如果是多核 CPU 那也只向当前核心，不会向 CPU 内的其它核心发送。值得注意的是，这条指令只有在支持 ARMv8 指令集之后的处理器中才有效。

从前面的分析可以看出来，可以通过 `SEVL` 指令来设置事件寄存器对应当前 CPU 核的位，可以通过 `SEV` 指令来设置事件寄存器对应所有 CPU 核的位，可以通过 `WFE` 指令来清空事件寄存器对应当前 CPU 核的位。

在 ARMv8 指令集中，还添加了一种情况，用来发送事件。当全局监视器标记的对某段内存的独占访问被清空后，将向所有标记了对该段内存独占访问的 CPU 核都发送事件。也就是说，当系统在多个 CPU 核上，通过 `LDREX` 或 `LDXR` 指令读取某段内存后，系统全局监视器会将该段内存标记为独占（Exclusive），这之后又调用了 `WFE` 指令进入低功耗模式了。当系统中又有一个 CPU，通过 `STREX` 或 `STXR` 指令对该段内存进行了写入，这将清空全局监视器对该段内存的独占标记，那么系统会自动给前面那些 CPU 核发送事件，将它们唤醒。

---

例18-13 中实现的经典自旋锁有一个特点，当自旋锁已经被其他 CPU 持有时，想获取锁的 CPU 只能在锁外面不停地尝试，这样很浪费 CPU 资源，而且会造成高速缓存行颠簸，导致性能下降。如何解决这个问题呢？Linux 内核采用 [MCS](https://en.wikipedia.org/wiki/MCS_algorithm) 算法解决这个问题。

ARMv8 体系结构支持的 `WFE` 机制可对自旋锁进行特殊优化——让 CPU 在自旋等待锁时进入低功耗睡眠模式，这既可以解决性能问题，还能降低功耗。直到有一个异常或者特定事件才会被换醒，通常这个事件可以通过清除全局独占监视器的方式来触发、唤醒。

【例 18-15】使用 `WFE` 和 `SEV` 指令优化自旋锁的代码如下。

```asm linenums="1" hl_lines="1 4"
sevl
prfm pstl1keep, [x1]
loop:
    wfe
    ldaxr w5, [x1]
    cbnz w5, loop
    stxr w5, w0, [x1]
    cbnz w5, loop
    //成功获取了锁
    ...
```

在第1行中，`SEVL` 指令是 `SEV` 指令的本地版本，它会向本地 CPU 发送个唤醒事件。

- 它通常在以一个 `WFE` 指令开始的循环里使用。这里，`SEVL` 指令的作用是让**第一次**调用 `WFE` 指令时 CPU 不会睡眠。

在第2行中，把 *lock* 地址的内容预取到高速缓存里。
在第4行中，第一次调用 `WFE` 指令时，CPU 不会睡眠，因为前面有一个 `SEVL` 指令。
在第5行中，通过 `LDAXR` 指令来读取 *lock* 的值到 W5 寄存器中。
在第6行中，判断 *lock* 的值是否为 0：如果不等于0，说明其他 CPU 持有了锁，那只能继续跳转到 loop 标签处并***自旋***；如果等于 0，说明这个锁已经释放了，是空闲的，继续执行第 7 行。

- 第二次执行 loop 时会调用 `WFE` 指令让 CPU 进入睡眠状态。那么 CPU 什么时候会被唤醒呢？其他持有锁的 CPU 释放锁时，就会让睡眠等待的 CPU 唤醒。

在第7行中，如果 *lock* 空闲，往 lock （X1）里写入 1 来获取这个锁。W5 寄存器用来接收 `STXR` 指令操作的返回值（the status result）。
在第8行中，判断第 7 行 `STXR` 指令的返回值 W5，如果等于 0，说明写入成功；如果不等于 0，则说明写入失败，只能继续跳转到 loop 标签处继续***自旋***。
在第9行中，成功获取了锁。

【例 18-16】下面的代码释放锁。

```asm
//锁的临界区里的读写操作
stlr wzr, [x1] ; 清除锁
```

释放锁的操作很简单，使用 `STLR` 指令把 lock 的值设置 0。

使用 `STLR` 指令来释放锁并且让处理器的独占监视器（exclusive monitor）监测到锁临界区被*清除*，即处理器的全局监视器监测到有内存区域从独占问状态（exclusive access state）变成开放访问状态（open access state），从而触发一个 `WFE` 事件，来*唤醒*等待这个自旋锁的 CPU。

### smp_mb__after_spinlock

内存屏障模型在 Linux 内核编程中广泛运用，本章通过 Linux 内核中 `try_to_wake_up()` 函数里内置的4个内存屏障的使用场景，介绍内存屏障在实际编程中的使用。

【例 19-6】 `try_to_wake_up()` 函数里内置了4条内存屏障指令，我们需要分析这4条内存屏障指令的使用场景和逻辑。

```c
// <linux5.0/kernel/sched/core.c>

static int
try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
{
    raw_spin_lock_irgsave(&p->pi_lock, flags);
    smp_mb__after_spinlock(); //第一次使用内存屏障指令

    if (!(p->state & state))
        goto out;

    smp_rmb(); //第二次使用内存屏障指令
    if (p->on_rq && ttwu_remote(p, wake_flags))
        goto stat;

    smp_rmb(); //第三次使用内存屏障指令

    smp_cond_load_acquire(&p->on_cpu, !VAL); //第四次使用内存屏障指令

    p->state = TASK_WAKING;

    ttwu_queue(p, cpu, wake_flags);
    ...
}
```

第一次使用内存屏障指令：这里使用了一个比较新的函数 `smp_mb__after_spinlock()`，从函数名可以知道它在 `spin_lock()` 函数后面添加 `smp_mb()` 内存屏障指令。锁机制隐含了内存屏障，那为什么在自旋锁后面要显式地添加 `smp_mb()` 内存屏障指令呢？

这需要从自旋锁的实现开始讲起。其实自旋锁的实现隐含了内存屏障指令，但是不同的体系结构隐含的内存屏障是不一样的。例如，x86 体系结构实现的是 `TSO`（Total Store Order）*强一致性内存模型*（Strongly Ordered），而 ARM64 实现的是*弱一致性内存模型*（Weakly Ordered）。对于 TSO 内存模型，原子操作指令隐含了 `smp_mb()` 内存屏障指令；但是，对于弱一致性内存模型的处理器来说，`spin_lock()` 的实现其实并没有隐含 `smp_mb()` 内存屏障指令。

在ARM64体系结构里，实现自旋锁最简单的方式是使用 `LDAXR` 和 `STXR` 指令，参见上面的【例 18-13】和【例 18-15】。我们以 Linux 3.7 内核的源代码中自旋锁的实现为例进行说明。

> 关于 C 代码内嵌 ASM 汇编，参考 [GCC Extended Asm - C/C++ inline assembly](../toolchain/gcc-ext-asm.md)，其中有本案例的详细说明。

```c
// <linux-3.7/arch/arm64/include/asm/spinlock.h>
static inline void arch_spin_lock(arch_spinlock_t *lock)
{
    unsigned int tmp;

    asm volatile (
    "   sevl\n"
    "1: wfe\n"
    "2: ldaxr %w0, [%1]\n"
    "   cbnz  %w0, 1b\n"
    "   stxr  %w0, %w2, [%1] \n"
    "   cbnz  %w0, 2b\n"
    : "=&r" (tmp)
    : "r" (&lock->lock), "r" (1)
    : "memory");
}

// linux-6.9:
// arch/arm/include/asm/spinlock.h: ARMv6 ticket-based spin-locking.
static inline void arch_spin_lock(arch_spinlock_t *lock);
static inline void arch_spin_unlock(arch_spinlock_t *lock);

// arch/arm64/kvm/hyp/include/nvhe/spinlock.h:
static inline void hyp_spin_lock(hyp_spinlock_t *lock);
static inline void hyp_spin_unlock(hyp_spinlock_t *lock);
```

从上面的代码可以看到，自旋锁采用 `LDAXR` 和 `STXR` 的指令组合来实现，`LDAXR` 指令隐含了加载-获取内存屏障原语。加载-获取屏障原语之后的读写操作不能重排到该屏障原语前面，但是不能保证屏障原语前面的读写指令重排到屏障原语后面。如图19.14所示，读指令1和写指令1有可能重排到屏障原语后面，而读指令2和写指令2不能重排到屏障原语指令的前面。

```text
// read after write

                  +------+
                  | LDR1 |------------+
                  | STR1 |            |
                  +------+            |
                                      |
                                      |
--------------------------------------|-----
           ⚡️ Load-Acquire (LDAR) ⚡️    |
--------------------------------------|-----
        ↑                             |
        |                             |
        |         +------+            |
        |         | LDR2 |            |
        +---------| STR2 |            |
                  +------+            |
                                      ↓
        
        // critical section

```

所以，在 ARM64 体系结构里，自旋锁隐含了一条单方向（one-way barrier）的内存屏障指令，在自旋锁临界区里的读写指令不能向前（后？）越过临界区，但是自旋锁临界区前面的读写指令可以穿越到临界区里，这会引发问题。

```c
// include/linux/spinlock.h
#ifndef smp_mb__after_spinlock
#define smp_mb__after_spinlock()	kcsan_mb()
#endif
```

在 ARM64 体系结构里定义 `smp_mb__after_spinlock` 函数宏为 `smp_mb()` 内存屏障指令。

```c
// arch/arm64/include/asm/spinlock.h
/* See include/linux/spinlock.h */
#define smp_mb__after_spinlock()	smp_mb()
```

在 x86 体系结构下，kcsan-checks.h 中定义了 `kcsan_mb` 为一个空函数。

```c
// include/linux/kcsan-checks.h
#define kcsan_mb()	do { } while (0)
```

## 邮箱传递消息

多核之间可以通过邮箱机制来共享数据。下面举个例子，两个 CPU 通过邮箱机制来共享数据，其中全局变量 `SHARE_DATA` 表示共享的数据，`FLAGS` 表示标志位。

【例 18-17】下面是 CPU0 侧（Sender）的伪代码。

```asm linenums="1"
ldr x1, =SHARE_DATA
ldr x2, =FLAGS

str x6,［x1］    //写新数据
dmb ishst
str xzr, [x2]   //更新 flags 为 0 通知 CPU1 数据已经准备好
```

CPU0 用来发消息。首先，它把数据写入 X1 寄存器，也就是写入 `SHARE_DATA` 里，然后执行一个 `DMB` 指令，最后把 `FLAGS` 标志位设置成 0，通知 CPU1 数据已经更新完成。

下面是 CPU1 侧（Receiver）的伪代码。

```asm linenums="1"
ldr x1, =SHARE_DATA
ldr x2, =FLAGS

//等待 CPU0 更新 flags
loop:
    ldr x7, [x2]
    cbnz x7, loop

dmb ishld

//读取共享数据
ldr x8, [x1]
```

CPU1 用来接收数据。第5\~7行的 loop 循环等待 CPU0 更新 FLAGS 标志位。接下来，执行一条 `DMB` 指令，读取共享数据。

在本例中，CPU0 和 CPU1 均使用了 `DMB` 指令。

- 在 CPU0 侧，`DMB` 指令是为保证这两次存储操作的执行次序的。如果先执行更新 FLAGS 操作，那么 CPU1 就可能读到错误的数据。
- 在 CPU1 侧，在等待 FLAGS 和读共享数据之间插入 `DMB` 指令，是为了保证读到 FLAGS 之后*才*读共享数据，要不然就读到错误的数据了。

**注意**：这两条 `DMB` 指令带的参数，其中 `ish` 表示内部共享域。

- 在 CPU0 侧使用 `ishst` 参数，`st` 表示内存屏障指令的访问次序为存储-存储操作，即在内部共享域里实现写内存屏障。
- 在 CPU1 侧使用 `ishld` 参数，`ld` 表示内存屏障访问次序方向为加载-加载操作，即在内部共享域里的读内存屏障。

## 参考资料

[宋宝华：关于ARM Linux原子操作的实现](https://cloud.tencent.com/developer/article/1518247)
[罗玉平：关于ARM Linux原子操作的底层支持](https://cloud.tencent.com/developer/article/1517857)

[ARM64平台下WFE和SEV相关指令解析](https://blog.csdn.net/Roland_Sun/article/details/107456179)
[ARM系列之ARM多核指令WFE、WFI、SEV原理](https://blog.csdn.net/xy010902100449/article/details/126812552)

[ARM架构中导致独占式内存访问Exclusive access 指令（LDXR/STXR）失败的原因分析](https://blog.csdn.net/luolaihua2018/article/details/136768258)
