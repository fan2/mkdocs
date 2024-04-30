---
title: GDB Examining the Stack
authors:
  - xman
date:
    created: 2022-04-25T10:00:00
categories:
    - toolchain
tags:
    - gdb
    - examine
    - stack
    - frame
comments: true
---

[8 Examining the Stack](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Stack.html#Stack)

*   Frames: Stack frames
*   Backtrace: Backtraces
*   Selection: Selecting a frame
*   Frame Info: Information on a frame

<!-- more -->

## Frames

[8.1 Stack Frames](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Frames.html#Frames)

The call stack is divided up into contiguous pieces called *stack frames*, or frames for short; each frame is the data associated with one call to one function. The frame contains the arguments given to the function, the function’s local variables, and the address at which the function is executing.

When your program is started, the stack has only one frame, that of the function *main*. This is called the *initial* frame or the *outermost* frame. Each time a function is called, a new frame is made. Each time a function returns, the frame for that function invocation is eliminated.

Usually this address is kept in a register called the *frame pointer register* (see [\$fp](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Registers.html#Registers)) while execution is going on in that frame.

GDB labels each existing stack frame with a *level*, a number that is zero for the innermost frame, one for the frame that called it, and so on upward. These level numbers give you a way of designating stack frames in GDB commands. The terms *frame number* and *frame level* can be used interchangeably to describe this number.

Some compilers provide a way to compile functions so that they operate without stack frames. (For example, the GCC option `-fomit-frame-pointer` generates functions without a frame.) This is occasionally done with heavily used library functions to save the frame setup time. 

《C/C++深层探索》(姚新颜,2002) 03 调用函数、栈：

!!! info ""

    ［FN0308］：可能会有读者问：为什么一开始不直接用 esp 寻址𣏾里面的数据，用得着这么费功夫，先保存 ebp，然后用 ebp 存放 esp 的值，再通过 ebp 来寻址吗？

    其实直接用 esp 寻址是可以的，但 gcc 默认输出的汇编代码是用 ebp 来寻址吗？用 esp 勾画出整个函数的栈空间。这样做的好处是代码非常清晰，便于分析研究，所以本书也就按照这样的代码进行讲解。

    如果要追求更高的运行效率，例如在编译 linux 内核时，你会发现函数内部的确是直接用 esp 寻址的。可以用编译选项指示 gcc 直接用 esp 寻址，例如：`gcc -fomit-frame-pointer example.c`。

《C语言标准与实现》(姚新颜,2004) 02 P6处理器的栈：

!!! info ""

    如果我们明确表示不需要 EBP 提供栈框信息，编译器可以省去进入过程后保存 EBP 以及退出过程前恢复 EBP 的动作并且直接使用 ESP 来寻址过程的参数和内部变量。

    对于 gcc 和 g++，可以使用 `-fomit-frame-poiter` 编译选项。

## Backtrace

[8.2 Backtraces](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Backtrace.html#Backtrace)

A backtrace is a summary of how your program got where it is. It shows one line per frame, for many frames, starting with the currently executing frame (frame zero), followed by its caller (frame one), and on up the stack.

To print a backtrace of the entire stack, use the `backtrace` command, or its alias `bt`. This command will print one line per frame for frames in the stack. By default, all stack frames are printed. You can stop the backtrace at any time by typing the system interrupt character, normally Ctrl-c.

`backtrace [option]… [qualifier]… [count]`

Print the backtrace of the entire stack, show you `where` the execution is halted.

当程序被停住了，你需要做的第一件事就是查看程序是在哪里停住的。当你的程序调用了一个函数，函数的地址、参数以及函数内的局部变量都会被压入“栈”（Stack）中。你可以用 GDB 命令 `backtrace` 来查看当前栈中的信息。

当调用栈较深时，可以限定显示层级：

- `bt <n>`: n是一个正整数，表示只打印栈顶上n层的栈信息。
- `bt <-n>`: -n表一个负整数，表示只打印栈底下n层的栈信息。

backtrace 显示的是 Call Stack，每一层函数都有自己的栈帧（Stack Frame）。

## Frame Info

[8.4 Information About a Frame](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Frame-Info.html#Frame-Info)

`frame`: When used without any argument, this command does not change which frame is selected, but prints a brief description of the *currently* selected stack frame. It can be abbreviated `f`. With an argument, this command is used to select a stack frame. See [Selecting a Frame](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Selection.html#Selection).

`info frame`: This command prints a verbose description of the selected stack frame, including:

*   the address of the frame
*   the address of the next frame down (called by this frame)
*   the address of the next frame up (caller of this frame)
*   the language in which the source code corresponding to this frame is written
*   the address of the frame’s arguments
*   the address of the frame’s local variables
*   the program counter saved in it (the address of execution in the caller frame)
*   which registers were saved in the frame

执行 `frame` / `info frame` 可以查看当前栈帧的简要/详情信息。

如果你要查看某一层的信息，则需要切换当前的栈。一般来说，程序停止时，最顶层的栈就是当前栈，如果你要查看栈下面层的详细信息，首先要做的是切换当前栈。

## Frame Switch

[8.3 Selecting a Frame](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Selection.html#Selection)

Most commands for examining the stack and other data in your program work on whichever stack frame is selected at the moment. Here are the commands for selecting a stack frame; all of them finish by printing a brief description of the stack frame just selected.

`frame [ frame-selection-spec ]` : The frame command allows different stack frames to be selected. The `frame-selection-spec` can be any of the following:

num / level num: num 是栈中的层编号

> Select frame level *num*. Recall that frame zero is the innermost (currently executing) frame, frame one is the frame that called the innermost one, and so on. The highest level frame is usually the one for main.

function function-name

> Select the stack frame for function *function-name*. If there are multiple stack frames for function *function-name* then the inner most stack frame is selected.

up n: 表示向栈的上面移动n层（默认 n=1）。

> Move *n* frames up the stack; n defaults to 1. For positive numbers n, this advances toward the outermost frame, to higher frame numbers, to frames that have existed longer.

down n: 表示向栈的下面移动n层（默认 n=1）。

> Move *n* frames down the stack; n defaults to 1. For positive numbers n, this advances toward the innermost frame, to lower frame numbers, to frames that were created more recently. You may abbreviate down as do.
