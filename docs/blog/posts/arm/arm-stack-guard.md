---
title: ARM StackGuard - Stack Canary
authors:
  - xman
date:
    created: 2023-10-03T10:00:00
categories:
    - arm
comments: true
---

Nearly every introduction to exploitation covers Aleph One's classic article "Smashing the Stack for Fun and Profit"([pdf1](https://www.s3.eurecom.fr/docs/ifip18_bierbaumer.pdf), [pdf2](https://www.eecs.umich.edu/courses/eecs588/static/stack_smashing.pdf)), which explains the basics of exploiting stack-based buffer overflows.

In this article, I'll explore the basic [Buffer overflow protection](https://en.wikipedia.org/wiki/Buffer_overflow_protection) mechanism based on stack canary.

<!-- more -->

## gcc -fstack-protector

[linux - Stack Guard and Stack Smashing Protection - canaries, memory](https://stackoverflow.com/questions/28020213/stack-guard-and-stack-smashing-protection-canaries-memory)
[Use compiler flags for stack protection in GCC and Clang | Red Hat Developer](https://developers.redhat.com/articles/2022/06/02/use-compiler-flags-stack-protection-gcc-and-clang#stack_usage_and_statistics)

There are several methods to protect against this scourge, regardless of the C/C++ programmers' negligence. MSVC has options like

- [/GZ (Enable Stack Frame Run-Time Error Checking)](https://learn.microsoft.com/en-us/cpp/build/reference/gz-enable-stack-frame-run-time-error-checking) - Deprecated, use `/RTC (Run-Time Error Checks)` instead.
- [/RTC (Run-time error checks)](https://learn.microsoft.com/en-us/cpp/build/reference/rtc-run-time-error-checks) - `/RTCs` Enables stack frame run-time error checking

GCC - [Instrumentation Options](https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html)

`-fstack-protector`: Emit extra code to check for *buffer overflows*, such as *stack smashing attacks*. This is done by adding a *guard variable* to functions with vulnerable objects. This includes functions that call alloca, and functions with buffers larger than or equal to 8 bytes. The guards are initialized when a function is entered and then checked when the function exits. If a guard check fails, an error message is printed and the program exits. Only variables that are actually allocated on the stack are considered, optimized away variables or variables allocated in registers don't count.

Aggressive options:

- `-fstack-protector-all`
- `-fstack-protector-strong`
- `-fstack-protector-explicit`

Related options:

- `-fstack-check`
- `-fstack-clash-protection`
- `-fsplit-stack`

[sysvabi64](https://github.com/ARM-software/abi-aa/blob/844a79fd4c77252a11342709e3b27b2c9f590cf1/sysvabi64/sysvabi64.rst) - 9 Program Loading and Dynamic Linking - 9.4 GNU Indirect Functions - 9.4.2 IFUNC requirements for static linkers

> `IFUNC` resolvers must not be compiled with security features like *stack-protection*, which requires a guard variable to be initialized.

[A journey into Radare 2 – Part 2: Exploitation – Megabeets](https://www.megabeets.net/a-journey-into-radare-2-part-2/)

GCC compiling with `-no-pie` and `-fno-stack-protector` options to disable protection mechanisms on the stack.

```bash
$ gcc megabeets_0x2.c -no-pie -fno-stack-protector -o megabeets_0x2
```

## Stack Canaries

[How to look at the stack with gdb](https://news.ycombinator.com/item?id=27204883)

The canary is pretty clever: it starts with a null byte so that it won't be leaked by normal string functions, and the true canary is stored somewhere else in memory (not the stack) so it can't be easily leaked or corrupted.

[Stack Canaries | Binary Exploitation](https://ir0nstone.gitbook.io/notes/types/stack/canaries)

Stack Canaries are very simple - at the beginning of the function, a random value is placed on the stack. Before the program executes ret, the current value of that variable is compared to the initial: if they are the same, no buffer overflow has occurred.

If they are not, the attacker attempted to overflow to control the return pointer and the program crashes, often with a *`stack smashing detected`* error message.

[Programming with 64-Bit ARM Assembly Language](https://www.amazon.com/Programming-64-Bit-ARM-Assembly-Language/dp/1484258800/) | Chapter 16: Hacking Code - Mitigating Buffer Overrun Vulnerabilities - Poor Stack Canaries Are the First to Go

The GNU C compiler has a feature to detect buffer overruns. The idea is, in any routine that contains a string buffer located on the stack, to add extra code to place a secret random value next to the stored function return address. Then this value is tested before the function returns, and if corrupted, then a buffer overrun has occurred, and the program is terminated. These stack canaries are like the proverbial canaries in a coal mine, because when something goes wrong, they're the first to go and warn us that something bad is happening.

[Reverse Engineering for Beginners(Understanding Assembly Language)](https://beginners.re/) @[PDF](https://repository.root-me.org/Reverse%20Engineering/EN%20-%20Reverse%20Engineering%20for%20Beginners%20-%20Dennis%20Yurichev.pdf)

- Code Patterns - Arrays - Buffer overflow protection methods

One of the methods is to write a random value between the local variables in stack at function prologue and to check it in function epilogue before the function exits. If value is not the same, do not execute the last instruction RET, but stop (or hang). The process will halt, but that is much better than a remote attack to your host.

This random value is called a "canary" sometimes, it is related to the [miners' canary](https://en.wikipedia.org/wiki/Domestic_canary#Miner's_canary), they were used by miners in the past days in order to detect poisonous gases quickly.

Canaries are very sensitive to mine gases, they become very agitated in case of danger, or even die.

<!-- ![Canary_coal_mine](https://upload.wikimedia.org/wikipedia/commons/0/06/Canary_coal_mine.jpg) -->

![Canary_coal_mine](./images/Canary_coal_mine.jpg)

## Canary detection

pwndbg - [canary](https://pwndbg.re/pwndbg/commands/canary/canary/): Print out the current stack canary.

GEF - [checksec](https://hugsy.github.io/gef/commands/checksec/): The `checksec` command is inspired from [checksec.sh](https://www.trapkit.de/tools/checksec.html). It provides a convenient way to determine which security protections are enabled in a binary.

GEF - [canary](https://hugsy.github.io/gef/commands/canary/): If the currently debugged process was compiled with the *Smash Stack Protector* (`SSP`) - i.e. the `-fstack-protector` flag was passed to the compiler, this command will display the value of the canary. This makes it convenient to avoid manually searching for this value in memory.

radare2's `i` command(`rabin2 -I`) can retrieve binary [information](https://r2wiki.readthedocs.io/en/latest/home/misc/cheatsheet/#information) from opened file, including mitigation properties.

- `i ~ canary` : check if the binary has canaries
- `i ~ nx` : check if the binary has non-executable stack
- `i ~ pic` : check if the binary has position-independent-code

```bash
$ r2 -Ad xr-struct

[0xaaaac5ab0934]> i~canary,crypto,nx,pic,relocs,relro,static,stripped
canary   true
crypto   false
nx       true
pic      true
relocs   true
relro    full
static   false
stripped false
```

## Demonstration

In [ARM64 PCS - calling convention and stack layout](./a64-pcs-demo.md), pay attention to the disassembly prolog and epilog of `foo`.

The first prolog instruction creates a space of 0x30/48 bytes for the function, and a *guard variable* is pushed to the stack base(`sp+0x28`). The original value is located at offset *0xfe8* of the data segment(*LOAD1*). The `ADRP`+`LDR` instructions form the address of the initial canary.

```bash
    [0xaaaac5ab0934]> pdf @ sym.foo
    # prolog
    │  sym.foo + 0              0xaaaac5ab08ac      fd7bbda9       stp x29, x30, [sp, -0x30]!
    │  sym.foo + 4              0xaaaac5ab08b0      fd030091       mov x29, sp
    │  sym.foo + 8              0xaaaac5ab08b4      80000090       adrp x0, map._home_pifan_Projects_cpp_xr_struct.rw_
    │  sym.foo + 12             0xaaaac5ab08b8      00f447f9       ldr x0, [x0, 0xfe8]
    │  sym.foo + 16             0xaaaac5ab08bc      010040f9       ldr x1, [x0]
    │  sym.foo + 20             0xaaaac5ab08c0      e11700f9       str x1, [sp, 0x28]
    │  sym.foo + 24             0xaaaac5ab08c4      010080d2       mov x1, 0
    │  sym.foo + 28             0xaaaac5ab08c8      e0430091       add x0, var_10h
    │  sym.foo + 32             0xaaaac5ab08cc      e80300aa       mov x8, x0
```

After `sym.foo + 12`, we can use `?w x0` or `drr ~ x0` to inspect/telescope the guard variable.

When debugging in `gdb-pwndbg`, type `i symbol $x0` to inspect the canary after <foo+12\>. The guard variable is labelled as `__stack_chk_guard` by pwndbg.

```bash
pwndbg> i symbol $x0
__stack_chk_guard in section .data.rel.ro of /lib/ld-linux-aarch64.so.1
pwndbg> i addr __stack_chk_guard
Symbol "__stack_chk_guard" is static storage at address 0xfffff7ffdb58.
pwndbg> telescope $x0
00:0000│ x0 0xfffff7ffdb58 (__stack_chk_guard) ◂— 0x9a7d2c706ded4700
01:0008│    0xfffff7ffdb60 (_rtld_global_ro) ◂— 0x50f9500000000
02:0010│    0xfffff7ffdb68 (_rtld_global_ro+8) —▸ 0xfffffffff4e8 ◂— 0x34366863726161 /* 'aarch64' */

```

The `LDR`+`STR` instructions load canary from memory and store it to the correct place on the stack.

At the beginning of the epilog, it reloads the initial value from `segment.LOAD1+0xfe8` to `X1` and loads its copy from stack `sp+0x28` to `X2`. Then the `SUBS` instruction performs a subtraction and updates the ALU flags, which is equivalent to a comparison to check the correctness of the "canary".

If `X2-X1` equals to zero, which means the original "canary" is still there, i.e. the stack hasn't been overwritten/overflowed, `b.eq` jumps to the success branch. Otherwise the guard check fails, it jumps to `__stack_chk_fail`.

```bash
    [0xaaaac5ab0934]> pdf @ sym.foo
    # epilog
    │  sym.foo + 96             0xaaaac5ab090c      80000090       adrp x0, map._home_pifan_Projects_cpp_xr_struct.rw_
    │  sym.foo + 100            0xaaaac5ab0910      00f447f9       ldr x0, [x0, 0xfe8]
    │  sym.foo + 104            0xaaaac5ab0914      e21740f9       ldr x2, [var_28h]
    │  sym.foo + 108            0xaaaac5ab0918      010040f9       ldr x1, [x0]
    │  sym.foo + 112            0xaaaac5ab091c      420001eb       subs x2, x2, x1
    │  sym.foo + 116            0xaaaac5ab0920      010080d2       mov x1, 0
    │  sym.foo + 120        ┌─< 0xaaaac5ab0924      40000054       b.eq 0xaaaac5ab092c
    │  sym.foo + 124        │   0xaaaac5ab0928      6affff97       bl sym.imp.__stack_chk_fail
    │  sym.foo + 128        └─> 0xaaaac5ab092c      fd7bc3a8       ldp x29, x30, [sp], 0x30
    └  sym.foo + 132            0xaaaac5ab0930      c0035fd6       ret
```

Stack canaries are quite effective, but if a hacker discovers the value used in a running process, they can construct a buffer overrun exploit. Plus, the fact that having your process terminate like this is never a good thing.

## references

[Stack Canaries | HackTricks](https://book.hacktricks.xyz/binary-exploitation/common-binary-protections-and-bypasses/stack-canaries)
[Stack Canaries - The Buffer Overflow defence](https://ir0nstone.gitbook.io/notes/types/stack/canaries)

[Security Technologies: Stack Smashing Protection (StackGuard)](https://www.redhat.com/en/blog/security-technologies-stack-smashing-protection-stackguard)
[Stack Canaries – Gingerly Sidestepping the Cage | SANS Institute](https://www.sans.org/blog/stack-canaries-gingerly-sidestepping-the-cage/)
[Reverse engineering x64 binaries with Radare2 - Defeating stack canaries](https://artik.blue/reversing-radare-23)
[StackGuard: Automatic Adaptive Detection and Prevention of Buffer-Overflow Attacks](https://www.usenix.org/legacy/publications/library/proceedings/sec98/full_papers/cowan/cowan.pdf)
