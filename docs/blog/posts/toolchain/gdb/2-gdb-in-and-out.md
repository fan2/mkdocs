---
title: GDB Invocation & Quitting
authors:
  - xman
date:
    created: 2020-02-05T10:00:00
categories:
    - toolchain
tags:
    - gdb
comments: true
---

[Invocation (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Invocation.html#Invocation)

This article discusses how to start GDB, and how to get out of it.

- type `gdb` to start GDB.
- Use `file` to change and load debugging FILE.
- Use `info`/`list` to show info/src about the program.
- Use the `run` command to start your program under GDB.
- Use the `start` command to start debugging and to stop at main.
- type `quit`, `exit` or <kbd>ctrl</kbd>+<kbd>d</kbd> to exit GDB console.

<!-- more -->

## Invoking

[Invoking GDB (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Invoking-GDB.html#Invoking-GDB)

=== "helloc.c"

    ```c linenums="1"
    #include <stdio.h>

    int main(int argc, char *argv[]) {
        printf("Hello world from c!\n");

        return 0;
    }
    ```

=== "hellocpp.cpp"

    ```cpp linenums="1"
    #include <iostream>

    class Hello {
    public:
        Hello() {
            std::cout << "Hello()" << std::endl;
        }

        ~Hello() {
            std::cout << "~Hello()" << std::endl;
        }
    } h;

    int main(int argc, char *argv[]) {
        printf("Hello world from cpp!\n");

        return 0;
    }
    ```

gcc 编译链接 C/C++ 代码，添加 `-g` 选项生成调试信息。
执行 `objdump -f` 查看 file header，执行 `file` 查看 file type info。

=== "cc -g helloc.c"

    ```Shell
    $ cc helloc.c -o helloc -g

    $ objdump -f helloc

    helloc:     file format elf64-littleaarch64
    architecture: aarch64, flags 0x00000150:
    HAS_SYMS, DYNAMIC, D_PAGED
    start address 0x0000000000000640

    $ file helloc
    helloc: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=62f7c3d231acd23080c08c38a3734b466c3e4f28, for GNU/Linux 3.7.0, with debug_info, not stripped
    ```

=== "c++ -g helloc.c"

    ```Shell
    $ c++ hellocpp.cpp -o hellocpp -g

    $ objdump -f hellocpp

    hellocpp:     file format elf64-littleaarch64
    architecture: aarch64, flags 0x00000150:
    HAS_SYMS, DYNAMIC, D_PAGED
    start address 0x00000000000009c0

    $ file hellocpp
    hellocpp: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=9bf3258ef5383b9fb42b6f6c017205d12c38b3cb, for GNU/Linux 3.7.0, with debug_info, not stripped
    ```

执行 `gdb helloc` / `gdb hellocpp` 启动 gdb 调试 helloc/hellocpp。

### show

show 显示调试器本身的一些设置/配置信息，和 set 命令对应，相当于 get。
以下摘取了一些看起来比较有用的子命令，具体有待后续实践按需取用。

```Shell
(gdb) help show
show, info set
Generic command for showing things about the debugger.

List of show subcommands:

show args -- Show argument list to give program being debugged when it is started.
show breakpoint -- Breakpoint specific settings.
show commands -- Show the history of commands you typed.
show convenience, show conv -- Debugger convenience ("$foo") variables and functions.
show cwd -- Show the current working directory that is used when the inferior is started.
show data-directory -- Show GDB's data directory.
show debug-file-directory -- Show the directories where separate debug symbols are searched for.
show directories -- Show the search path for finding source files.
show disassembler-options -- Show the disassembler options.
show endian -- Show endianness of target.
show environment -- The environment to give the program, or one variable's value.
show language -- Show the current source language.
show listsize -- Show number of source lines gdb will list by default.
show paths -- Current search path for finding object files.
show print, show pr, show p -- Generic command for showing print settings.
show source -- Generic command for showing source settings.
show step-mode -- Show mode of the step operation.
show substitute-path -- Show one or all substitution rules rewriting the source directories.
show tui -- TUI configuration variables.

```

以下调用部分 show subcommand 确认调试器的一些配置信息：

```Shell
(gdb) show language
The current source language is "auto; currently c".
(gdb) show endian
The target endianness is set automatically (currently little endian).
(gdb) show listsize
Number of source lines gdb will list by default is 10.
(gdb) show step-mode
Mode of the step operation is off.
```

### file

[18 GDB Files | 18.1 Commands to Specify Files](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Files.html)

```Shell
(gdb) help file
Use FILE as program to be debugged.
```

如果不带参数执行 `gdb` 启动 REPL，未指定 executable file 和 symbol file。

```Shell
(gdb) r
Starting program:
No executable file specified.
Use the "file" or "exec-file" command.

(gdb) file
No executable file now.
No symbol file now.
```

可执行 `file` 指定要调试的文件：

```Shell
(gdb) file helloc
Reading symbols from helloc...
```

中途可以使用该命令加载切换新的调试目标文件（Load new symbol table）。

其他参考：[17.7 Compiling and injecting code in GDB](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Compiling-and-Injecting-Code.html#Compiling-and-Injecting-Code)

### attach process

You can, instead, specify a process ID as a second argument or use option `-p`, if you want to debug a running process:

```Shell
gdb program 1234
```

`gdb -p 1234` would attach GDB to process 1234. With option `-p` you can omit the program filename.

[Attach (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Attach.html#Attach)

### Shell Commands

[Shell Commands](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Shell-Commands.html#Shell-Commands)

If you need to execute occasional shell commands during your debugging session, there is no need to leave or suspend GDB; you can just use the shell command.

```
shell command-string
!command-string
```

Invoke a shell to execute *command-string*. Note that no space is needed between `!` and `command-string`. On GNU and Unix systems, the environment variable `SHELL`, if it exists, determines which shell to run. Otherwise GDB uses the default shell (/bin/sh on GNU and Unix systems, cmd.exe on MS-Windows, COMMAND.COM on MS-DOS, etc.).

You may also invoke shell commands from expressions, using the `$_shell` convenience function. See [$_shell convenience function](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Convenience-Funs.html#g_t_0024_005fshell-convenience-function).

!!! note "invoke make in GDB"

    The utility `make` is often needed in development environments. You do not have to use the shell command for this purpose in GDB:

    `make make-args`: Execute the make program with the specified arguments. This is equivalent to `shell make make-args`.

```bash
pipe [command] | shell_command
| [command] | shell_command
pipe -d delim command delim shell_command
| -d delim command delim shell_command
```

Executes *command* and sends its output to *shell_command*. Note that no space is needed around `|`. If no *command* is provided, the *last* command executed is repeated.

In case the *command* contains a `|`, the option `-d` delim can be used to specify an alternate delimiter string delim that separates the *command* from the *shell_command*.

The convenience variables `$_shell_exitcode` and `$_shell_exitsignal` can be used to examine the exit status of the last shell command launched by *shell*, *make*, *pipe* and *|*. See [Convenience Variables](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Convenience-Vars.html).

## info && list

### info

[16 Examining the Symbol Table](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Symbols.html#Symbols)
[18 GDB Files | 18.1 Commands to Specify Files](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Files.html)

`show` 命令用于显示调试器本身的信息，而 `info` 命令则可用于显示被调试任务的信息。

```Shell
(gdb) help info
info, inf, i
Generic command for showing things about the program being debugged.

List of info subcommands:

info files -- Names of targets and files being debugged.

info line -- Core addresses of the code for a source line.

info proc -- Show additional information about a process.
info program -- Execution status of the program.

info source -- Information about the current source file.
info sources -- All source files in the program or those matching REGEXP.
```

Execute `info program` to show the execution status.

```Shell
(gdb) info program
The program being debugged is not being run.
```

#### info file

执行 `info files` 列举当前已加载符号的调试文件：

```Shell
(gdb) help info files
Names of targets and files being debugged.
Shows the entire stack of targets currently in use (including the exec-file,
core-file, and process, if any), as well as the symbol file name.

(gdb) info files
Symbols from "/home/pifan/Projects/cpp/helloc".
Local exec file:
	`/home/pifan/Projects/cpp/helloc', file type elf64-littleaarch64.
	Entry point: 0x640

...
```

> run/start 运行起来后，Entry point 会变成虚拟地址（VMA）。

#### info source

执行 `info source` 查看正在调试的源代码文件信息：

```Shell
(gdb) info source
Current source file is helloc.c
Compilation directory is /home/pifan/Projects/cpp
Located in /home/pifan/Projects/cpp/helloc.c
Contains 7 lines.
Source language is c.
Producer is GNU C17 11.4.0 -mlittle-endian -mabi=lp64 -g -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection.
Compiled with DWARF 5 debugging format.
Does not include preprocessor macro info.

(gdb) info sources
/home/pifan/Projects/cpp/helloc:

/home/pifan/Projects/cpp/helloc.c

```

> run/start 运行起来后，info sources 列表会多出很多运行时依赖文件和 libc.so.6。

#### info proc

使用 `info proc` 子命令可以显示进程相关的附加信息。

```bash
(gdb) help info proc
Show additional information about a process.
Specify any process id, or use the program being debugged by default.

List of info proc subcommands:

info proc all -- List all available info about the specified process.
info proc cmdline -- List command line arguments of the specified process.
info proc cwd -- List current working directory of the specified process.
info proc exe -- List absolute filename for executable of the specified process.
info proc files -- List files opened by the specified process.
info proc mappings -- List memory regions mapped by the specified process.
info proc stat -- List process info from /proc/PID/stat.
info proc status -- List process info from /proc/PID/status.

Type "help info proc" followed by info proc subcommand name for full documentation.
Type "apropos word" to search for commands related to "word".
Type "apropos -v word" for full documentation of commands related to "word".
Command name abbreviations are allowed if unambiguous.
```

### list

[Source (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Source.html#Source)

执行 `list` / `l` 命令打印程序的源代码（List specified function or line），可指定函数名或行号。

```Shell
(gdb) help list
list, l
List specified function or line.
With no argument, lists ten more lines after or around previous listing.
"list -" lists the ten lines before a previous ten-line listing.
One argument specifies a line, and ten lines are listed around that line.
Two arguments with comma between specify starting and ending lines to list.
Lines can be specified in these ways:
  LINENUM, to list around that line in current file,
  FILE:LINENUM, to list around that line in that file,
  FUNCTION, to list around beginning of that function,
  FILE:FUNCTION, to distinguish among like-named static functions.
  *ADDRESS, to list around the line containing that address.
With two args, if one is empty, it stands for ten lines away from
the other arg.

By default, when a single location is given, display ten lines.
This can be changed using "set listsize", and the current value
can be shown using "show listsize".
```

`list 0` 从第 1 行开始显示源程序。
`list +` 显示当前断点行后面的源程序。
`list -` 显示当前断点行前面的源程序。

*   每次显示 10 行（由 listsize 控制）。

```Shell
# 缺省为 list +
(gdb) list
1	#include <stdio.h>
2	
3	int main(int argc, char *argv[]) {
4	    printf("Hello world from c!\n");
5	
6	    return 0;
7	}
```

按回车键重复上一次的命令，即继续 list 显示下一个 10 行。

当显示到文件最后一行（EOF），会提示 out of range：

```Shell
(gdb)
Line number 8 out of range; helloc.c has 7 lines.
```

此时可执行 `l 0` 从头开始显示。

`list <linenum>`：显示程序第linenum行上下各 5 行源程序。
`list <function>`：显示指定名称函数的源程序。

## run / start

[4 Running Programs Under GDB](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Running.html#Running) | [4.2 Starting your Program](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Starting.html#Starting)

### run

`run` / `r`: Use the `run` command to start your program under GDB. You must first specify the program name with an argument to GDB (see [Getting In and Out of GDB](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Invocation.html#Invocation)), or by using the file or exec-file command (see [Commands to Specify Files](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Files.html#Files)).

```Shell
(gdb) help run
run, r
Start debugged program.
You may specify arguments to give it.
Args may include "*", or "[...]"; they are expanded using the
shell that will start the program (specified by the "$SHELL" environment
variable).  Input and output redirection with ">", "<", or ">>"
are also allowed.

With no arguments, uses arguments last specified (with "run" or
"set args").  To cancel previous arguments and run with no arguments,
use "set args" without arguments.

To start the inferior without using a shell, use "set startup-with-shell off".
```

执行 `gdb helloc` 启动 gdb 调试 gcc 编译好的 helloc。 或中途执行 `file` 命令加载切换新的调试目标后，即可执行 `run` 命令启动运行。 如果没有设置断点，则默认执行完整个程序。

```Shell
(gdb) r
Starting program: /home/pifan/Projects/cpp/helloc
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".
Hello world from c!
[Inferior 1 (process 145910) exited normally]
```

> When you issue the `run` command, your program begins to execute immediately. See [Stopping and Continuing](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Stopping.html#Stopping), for discussion of how to arrange for your program to stop. Once your program has stopped, you may call functions in your program, using the `print` or `call` commands. See [Examining Data](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Data.html#Data).

### start

`start`: The debugger provides a convenient way to start the execution of the program and to stop at the beginning of the `main` procedure, depending on the language used.

The ‘start’ command does the equivalent of setting a *temporary* breakpoint at the beginning of the main procedure and then invoking the ‘run’ command.

`starti`: The ‘starti’ command does the equivalent of setting a temporary breakpoint at the first instruction of a program's execution and then invoking the ‘run’ command. For programs containing an *elaboration* phase, the starti command will stop execution at the start of the elaboration phase.

```Shell
(gdb) help start
Start the debugged program stopping at the beginning of the main procedure.
You may specify arguments to give it.
Args may include "*", or "[...]"; they are expanded using the
shell that will start the program (specified by the "$SHELL" environment
variable).  Input and output redirection with ">", "<", or ">>"
are also allowed.

With no arguments, uses arguments last specified (with "run" or
"set args").  To cancel previous arguments and run with no arguments,
use "set args" without arguments.

To start the inferior without using a shell, use "set startup-with-shell off".
```

执行 `gdb helloc` 启动 gdb 进入调试 REPL 后，输入 `start` 将启动运行，在入口函数 main 处的临时断点（tbreak）停下，相当于 tb main + run。

```Shell
(gdb) start
Temporary breakpoint 1 at 0x764: file helloc.c, line 4.
Starting program: /home/pifan/Projects/cpp/helloc
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".

Temporary breakpoint 1, main (argc=1, argv=0xfffffffff248) at helloc.c:4
4	    printf("Hello world from c!\n");
```

若输入 `starti` 将在 ld.so 的 `_start` 函数处停住，相当于 tb _start + run。

```Shell
(gdb) starti
Starting program: /home/pifan/Projects/cpp/helloc

Program stopped.
0x0000fffff7fd9c40 in _start () from /lib/ld-linux-aarch64.so.1
```

全局符号 `_start` 代表整个程序第一条指令的地址，每个用户进程都是从 `_start` 开始执行指令。

!!! info "Behind the scenes of main()"

    [Mini FAQ about the misc libc/gcc crt files.](https://dev.gentoo.org/~vapier/crt.txt)
    [_start, _init and frame_dummy functions](https://www.linuxquestions.org/questions/programming-9/_start-_init-and-frame_dummy-functions-810257/)
    [ELF Format Cheatsheet](https://gist.github.com/x0nu11byt3/bcb35c3de461e5fb66173071a2379779) | Common objects and functions.
    [A General Overview of What Happens Before main()](https://embeddedartistry.com/blog/2019/04/08/a-general-overview-of-what-happens-before-main/)
    [C语言标准与实现(姚新颜)-2004](https://att.newsmth.net/nForum/att/CProgramming/3213/245) - 07 C 源文件的编译和链接

Execute `info program` to check the execution status.

```Shell
(gdb) info program
	Using the running image of child Thread 0xfffff7ff7e60 (LWP 203218).
Program stopped at 0xaaaaaaaa0764.
It stopped at a breakpoint that has since been deleted.
Type "info stack" or "info registers" for more information.
```

### restart

调试过程中，随时可以输入 `run` 或 `start` 从头开始执行。

```Shell
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n)

(gdb) start
The program being debugged has been started already.
Start it from the beginning? (y or n)
```

### info proc

[Process Information (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Process-Information.html#index-info-proc-files)

执行 `info proc` 命令可查看进程信息：

```Shell
(gdb) help info proc
Show additional information about a process.

(gdb) i proc
process 147173
cmdline = '/home/pifan/Projects/cpp/helloc'
cwd = '/home/pifan/Projects/cpp'
exe = '/home/pifan/Projects/cpp/helloc'
```

> 此时，在另外一个终端窗口键入 `cat /proc/147173/maps` 可以查看系统给进程（PID 为147173）分配的虚拟地址空间。

执行 `info share` 命令可查看加载的动态库信息：

```Shell
(gdb) help info sharedlibrary
info sharedlibrary, info dll
Status of loaded shared object libraries.

(gdb) i share
From                To                  Syms Read   Shared Object Library
0x0000fffff7fc3c40  0x0000fffff7fe20a4  Yes         /lib/ld-linux-aarch64.so.1
0x0000fffff7e37040  0x0000fffff7f43090  Yes         /lib/aarch64-linux-gnu/libc.so.6
```

## Quitting

[Quitting GDB (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Quitting-GDB.html#Quitting-GDB)

*   quit \[expression]
*   exit \[expression]
*   q

To exit GDB, use the quit command (abbreviated `q`), the `exit` command, or type an end-of-file character (usually `Ctrl-d`). If you do not supply expression, GDB will terminate normally; otherwise it will terminate using the result of expression as the error code.

An interrupt (often `Ctrl-c`) does not exit from GDB, but rather terminates the action of any GDB command that is in progress and returns to GDB command level.

## online

[GDB online Debugger](https://www.onlinegdb.com/)

[CoderPad](https://coderpad.io/) - [Documentation](https://coderpad.io/resources/docs/)

- [Interview documentation](https://coderpad.io/resources/docs/interview/)
- [Candidate preparation guides](https://coderpad.io/resources/docs/for-candidates/)

[I think coderpad.io is the modern day equivalent of a whiteboard.](https://news.ycombinator.com/item?id=13874277)

[Is it possible to set breakpoints in CoderPad for C#? ](https://stackoverflow.com/questions/67595787/is-it-possible-to-set-breakpoints-in-coderpad-for-c)

> No, you cannot set breakpoints in Coderpad. The only means of debugging I know is to print to console.

[Is it possible to manually launch GDB without a core dump for C/C++?](https://x.com/5omik/status/1313590329845575680?lang=en)

> No, this isn't currently possible on CoderPad - but if it's helpful, we'll consider adding it. What's your use case?

!!! tip "Tricks to launch GDB in CoderPad"

    Add some code at the end of main to cause an ***SEGV*** exception:

    1. Attempt to modify a const(readonly) string literal.
    2. Attempt to access an illegal random absolute address.

```c
#include <stdio.h>

// To execute C, please define "int main()"

int main() {

    // Your solution code

    //----------------trick 1------------------
    // modify a const(readonly) string literal
    char* str = "CoderPad"; // in section .rodata
    *str = 'D'; // raise SEGV
    //-----------------------------------------

    //----------------trick 2------------------
    // access illegal random absolute address
    unsigned int *pui = (unsigned int *)0x2048;
    *pui = 2048; // raise SEGV
    //-----------------------------------------

    return 0;
}
```

Either way, a core dump will be generated so that you can launch the GDB.

Type `Y` launch GDB:

```bash
==15==ERROR: AddressSanitizer: SEGV on unknown address 0x000000002048 (pc 0x563a22671f6c bp 0x7ffd83dfb9e0 sp 0x7ffd83dfb960 T0)
==15==The signal is caused by a WRITE memory access.

...

Core dump detected, launch GDB? [Y/n] Y
```

Then type `start` to restart debugging with GDB. Now you can set breakpoints between your code and debug online the same way as the localized experience.

In the GDB REPL console, you can run shell commands to probe the configuration of the host machine.

```bash
shell arch
shell lscpu
shell uname -a

!cat /proc/version
!cat /etc/issue

!getconf WORD_BIT
!getconf LONG_BIT
```

Of course, you can also use GNU binutils like *readelf*, *objdump*, *nm*, to explore the ELF binary.

```bash
!readelf -S ./solution
```
