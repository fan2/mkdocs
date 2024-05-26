---
title: ABI & Calling conventions
authors:
  - xman
date:
    created: 2023-03-14T10:00:00
categories:
    - CS
tags:
    - x86
    - arm
comments: true
---

[ABI](https://en.wikipedia.org/wiki/Application_binary_interface) - [Calling convention](https://en.wikipedia.org/wiki/Calling_convention)

In computer science, a ***calling convention*** is an implementation-level (low-level) scheme for how subroutines or functions **receive** parameters from their caller and how they **return** a result.

<!-- more -->

When some code calls a function, design choices have been taken for where and how parameters are *passed* to that function, and where and how results are *returned* from that function, with these transfers typically done via certain *registers* or within a [stack frame](https://en.wikipedia.org/wiki/Stack_frame) on the [call stack](https://en.wikipedia.org/wiki/Call_stack).

There are design choices for how the tasks of preparing for a function call and restoring the environment after the function has completed are divided between the `caller` and the `callee`. Some calling convention specifies the way every function should get called. The correct calling convention should be used for every function call, to allow the correct and reliable execution of the whole program using these functions.

## x86

[x86 calling conventions](https://en.wikipedia.org/wiki/X86_calling_conventions)
[x86 Disassembly/Calling Conventions](https://en.wikibooks.org/wiki/X86_Disassembly/Calling_Conventions)

### docs

[Application binary interfaces](https://developer.apple.com/documentation/xcode/application-binary-interfaces):

- [Writing 64-bit Intel code for Apple Platforms](https://developer.apple.com/documentation/xcode/writing-64-bit-intel-code-for-apple-platforms)

[OS X ABI Function Call Guide](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/LowLevelABI/000-Introduction/introduction.html):

- [IA-32 Function Calling Conventions](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/LowLevelABI/130-IA-32_Function_Calling_Conventions/IA32.html)
- [x86-64 Function Calling Conventions](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/LowLevelABI/140-x86-64_Function_Calling_Conventions/x86_64.html)

Microsoft Learn:

- [Calling Conventions](https://learn.microsoft.com/en-us/cpp/cpp/calling-conventions)
- [Argument passing and naming conventions](https://learn.microsoft.com/en-us/cpp/cpp/argument-passing-and-naming-conventions)

[Configure C++ projects for 64-bit, x64 targets](https://learn.microsoft.com/en-us/cpp/build/configuring-programs-for-64-bit-visual-cpp)

- [x64 ABI conventions](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions)
- [x64 calling convention](https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention)

System V ABI:

- [System V Application Binary Interface Intel386 Architecture Processor Supplement - 4th Edition](https://www.sco.com/developers/devspecs/abi386-4.pdf)
- [System V Application Binary Interface AMD64 Architecture Processor Supplement(With LP64 and ILP32 Programming Models)](https://cs61.seas.harvard.edu/site/pdf/x86-64-abi-20210928.pdf)
- [System V psABI for AMD64](https://gitlab.com/x86-psABIs/x86-64-ABI) - official repository

### refs

The history of calling conventions:

- [part 1](https://devblogs.microsoft.com/oldnewthing/20040102-00/?p=41213), [part 2](https://devblogs.microsoft.com/oldnewthing/20040107-00/?p=41183), [part 3](https://devblogs.microsoft.com/oldnewthing/20040108-00/?p=41163)
- [part 4: ia64](https://devblogs.microsoft.com/oldnewthing/20040113-00/?p=41073)
- [part 5: amd64](https://devblogs.microsoft.com/oldnewthing/20040114-00/?p=41053)

[CS 61](https://cs61.seas.harvard.edu/site/2023/) - [Assembly 2: Calling convention – 2018](https://cs61.seas.harvard.edu/site/2018/Asm2/)
[Guide to x86 Assembly](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html) - [Calling Convention](https://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html#calling)

[What are the calling conventions for UNIX & Linux system calls on x86-64?](https://stackoverflow.com/questions/2535989/what-are-the-calling-conventions-for-unix-linux-system-calls-on-x86-64)

[Function calling conventions](https://stackoverflow.com/questions/24974291/function-calling-conventions)
[Guide: Function Calling Conventions](http://www.delorie.com/djgpp/doc/ug/asm/calling.html)
[C Function Call Conventions](https://redirect.cs.umbc.edu/~chang/cs313.s02/stack.shtml), UMBC CMSC 313, Spring 2002

[CS 4120/ENGRD 4120 Spring 2022](https://www.cs.cornell.edu/courses/cs4120/2022sp/notes/) - [Calling Conventions](https://www.cs.cornell.edu/courses/cs4120/2022sp/notes.html?id=callconv)
[SYSC 3006 - Computer Organization](https://www.sce.carleton.ca/courses/sysc-3006) - [Subroutines](https://www.sce.carleton.ca/courses/sysc-3006/s13/Lecture%20Notes/Part11-Subroutines.pdf)

## arm

`ATPCS`: ARM-Thumb Procedure Call Standard
`AAPCS`: Arm Architecture Procedure Call Standard

### docs

[ABI](https://developer.arm.com/Architectures/Application%20Binary%20Interface) - [Application Binary Interface](https://developer.arm.com/Architectures/ABI)

1. [Software Standards](https://developer.arm.com/Architectures/Software%20Standards)

2. Specifications @[github](https://github.com/ARM-software/abi-aa/releases)

    - ABI for the Arm 32-bit Architecture
    - ABI for the Arm 64-bit Architecture

3. [About the ARM-Thumb Procedure Call Standard](https://developer.arm.com/documentation/dui0056/d/using-the-procedure-call-standard/about-the-arm-thumb-procedure-call-standard)

    - Register roles and names
    - The stack
    - Parameter passing

[Application binary interfaces | Apple Developer Documentation](https://developer.apple.com/documentation/xcode/application-binary-interfaces):

- [Writing ARMv7 code for iOS](https://developer.apple.com/documentation/xcode/writing-armv7-code-for-ios)
- [Writing ARM64 code for Apple platforms](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms)

[Configure C++ projects for ARM processors | Microsoft Learn](https://learn.microsoft.com/en-us/cpp/build/configuring-programs-for-arm-processors-visual-cpp):

- [Overview of ARM ABI Conventions](https://learn.microsoft.com/en-us/cpp/build/overview-of-arm-abi-conventions)
- [Overview of ARM64 ABI conventions](https://learn.microsoft.com/en-us/cpp/build/arm64-windows-abi-conventions)
- [Overview of ARM64EC ABI conventions](https://learn.microsoft.com/en-us/cpp/build/arm64ec-windows-abi-conventions)

### terms

[aapcs64](https://github.com/ARM-software/abi-aa/blob/2a70c42d62e9c3eb5887fa50b71257f20daca6f9/aapcs64/aapcs64.rst) - 2.2 Terms and abbreviations:

`Program state`: The state of the program’s memory, including values in machine registers.

`Routine`, `subroutine`: A fragment of program to which control can be transferred that, on completing its task, returns control to its caller at an instruction following the call. Routine is used for clarity where there are nested calls: a routine is the *`caller`* and a subroutine is the *`callee`*.

- `Procedure`: A routine that returns no result value.
- `Function`: A routine that returns a result value.

`Argument` / `parameter`: The terms argument and parameter are used interchangeably. They may denote a formal parameter of a routine given the value of the actual parameter when the routine is called, or an actual parameter, according to context.

`Activation stack` / `call-frame stack`: The stack of routine activation records (call frames).

`Activation record` / `call frame`: The memory used by a routine for saving registers and holding local variables (usually allocated on a stack, once per activation of the routine).

### PCS

[A64 Instruction Set Architecture Guide](https://developer.arm.com/documentation/102374/0102/Procedure-Call-Standard) - 27. Procedure Call Standard

The Arm architecture places few restrictions on how general purpose registers are used. To recap, integer registers and ﬂoating-point registers are general purpose registers. However, if you want your code to **interact** with code that is written by someone else, or with code that is produced by a compiler, then you need to **agree** rules for register usage. For the Arm architecture, these rules are called the Procedure Call Standard, or ***PCS***.

The PCS speciﬁes:

- Which registers are used to **pass** arguments into the function.
- Which registers are used to **return** a value to the function doing the calling, known as the caller.
- Which registers the function being called, which is known as the callee, *can* corrupt.
- Which registers the callee *cannot* corrupt.

Consider a function `foo()`, being called from `main()`:

<figure markdown="span">
    ![aapcs64-example](./images/aapcs64-example.jpeg)
</figure>

The PCS says that the first argument is passed in `X0`, the second argument in `X1`, and so on up to `X7`. Any further arguments are passed on the stack. Our function, `foo()`, takes two arguments: `b` and `c`. Therefore, `b` will be in `W0` and `c` will be in `W1`.

Why `W` and not `X`? Because the arguments are a 32-bit type, and therefore we only need a `W` register.

!!! note "X0 reserved for this pointer in C++"

    In C++, `X0` is used to pass the implicit *this* pointer that points to the called function.

Next, the PCS deﬁnes which registers can be corrupted, and which registers cannot be corrupted. If a register can be corrupted, then the called function can **overwrite** without needing to restore, as this table of PCS register rules shows:

X0-X7 | X8-X15 | X16-X23 | X24-X30
------|--------|---------|--------
Parameter and Result Registers (X0-X7) | XR (X8) | IP0 (X16) | Callee-saved Registers (X24-X28)
- | Corruptible Registers (X9-X15) | IP1 (X17) | FP (X29)
- | - | PR (X18) | LR (X30)
- | - | Callee-saved Registers (X19-X23) | -

For example, the function `foo()` can use registers `X0` to `X15` without needing to preserve their values. However, if `foo()` wants to use `X19` to `X28` it must **save** them to stack ﬁrst, and then **restore** from the stack before returning.

Some registers have special signiﬁcance in the PCS:

- `XR` - This is an *indirect* result register. If `foo()` returned a *struct*, then the memory for struct would be **allocated** by the caller, `main()` in the earlier example. `XR` is a pointer to the memory allocated by the caller for returning the struct.

- `IP0` and `IP1` - These registers are intra-procedure-call corruptible registers. These registers can be corrupted between the time that the function is called and the time that it arrives at the ﬁrst instruction in the function. These registers are used by *linkers* to **insert** veneers between the caller and callee. Veneers are small pieces of code. The most common example is for branch range extension. The branch instruction in A64 has a limited range. If the target is beyond that range, then the linker needs to generate a veneer to **extend** the range of the branch.

- `FP` - Frame pointer.

- `LR` - `X30` is the link register (`LR`) for function calls.

### refs

[Stacks on ARM processors.doc](http://www.cems.uwe.ac.uk/~cduffy/es/ARMstacks.doc)
[Armv8-M Exception Model User Guide - Stack frames](https://developer.arm.com/documentation/107706/0100/Exceptions-and-interrupts-overview/Stack-frames)

[System V ABI for the Arm® 64-bit Architecture (AArch64)](https://github.com/ARM-software/abi-aa/blob/844a79fd4c77252a11342709e3b27b2c9f590cf1/sysvabi64/sysvabi64.rst)

[Subroutines and Parameter passing.ppt](http://users.ece.utexas.edu/~valvano/Volume1/Lec5.ppt)
[iOS Assembly Tutorial: Understanding ARM](https://www.kodeco.com/2705-ios-assembly-tutorial-understanding-arm)

[ARM 过程调用标准 AAPCS 以及堆栈使用](https://blog.csdn.net/FJDJFKDJFKDJFKD/article/details/102967031)
[arm64程序调用规则](https://wukaikai.tech/2019/05/19/arm64%E7%A8%8B%E5%BA%8F%E8%B0%83%E7%94%A8%E8%A7%84%E5%88%99/)

[Understanding Procedure Call Standard for Arm Architecture — Part 1](https://medium.com/@csrohit/understanding-procedure-call-standard-for-arm-architecture-part-1-ff78031842c8)
[堆和栈调用惯例 - 以ARMv8为例](https://github.com/carloscn/blog/issues/50)

[ARM二进制程序的函数调用过程栈的变化详解](https://www.cnblogs.com/from-zero/p/16133051.html)
[安卓逆向: 这是一篇逆向基础函数在ARM32中的刨根问底](https://cloud.tencent.com/developer/article/1774732)

## refs

[Linux Foundation Referenced Specifications](https://refspecs.linuxfoundation.org/)

[常见函数调用约定(x86、x64、arm、arm64)](https://zhuanlan.zhihu.com/p/34282144)
