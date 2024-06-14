---
title: GDB manual & help
authors:
  - xman
date:
    created: 2020-02-04T09:00:00
categories:
    - toolchain
tags:
    - gdb
comments: true
---

The best known command-line debugger is the official GNU Debugger(aka `GDB`).

Vanilla GDB is an amazing tool in process debugging, just like a swiss army knife.

This initial piece introduces how to use the gdb help system.

1. GDB onlinedocs, concept index.
2. Help within GDB, search command class and detailed command name.
3. Take the breakpoints search as an example to exemplify help usage.

<!-- more -->

## gdb online

[GDB: The GNU Project Debugger](https://sourceware.org/gdb/current/onlinedocs/)

- [GDB’s Obsolete Annotations](https://sourceware.org/gdb/current/onlinedocs/annotate.html)
- Debugging with GDB: [integrated](https://sourceware.org/gdb/current/onlinedocs/gdb), [index/toc](https://sourceware.org/gdb/current/onlinedocs/gdb.html/index.html)

VisualGDB - [GDB Command Reference](https://visualgdb.com/gdbreference/commands/): an incomplete reference of most frequently used GDB commands.

查看 Debugging with GDB - [index/toc](https://sourceware.org/gdb/current/onlinedocs/gdb.html/index.html)，可以搜索相关话题章节。

可以在 [Concept Index](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Concept-Index.html) 索引页面搜索查找某个感兴趣的关键词。

搜索 `info ` 相关的话题：

- [process info via /proc](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Process-Information.html#index-process-info-via-_002fproc)
- [info line, repeated calls](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Machine-Code.html#index-info-line_002c-repeated-calls)
- [info proc files](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Process-Information.html#index-info-proc-files)

搜索 `examin` 相关的话题：

- [examine process image](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Process-Information.html#index-examine-process-image)
- [examining data](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Data.html#index-examining-data)
- [examining memory](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Memory.html#index-examining-memory)

在 [index/toc](https://sourceware.org/gdb/current/onlinedocs/gdb.html/index.html) 和 [Concept Index](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Concept-Index.html) 中都搜索不到某个感兴趣的关键词时，可以借助本机 GDB 实时 help 命令查找相关话题。

## man gdb

本机执行 `gdb --help` / `gdbserver --help` 可以查看 gdb/gdbserver 的 usage 帮助概要：

```Shell
$ gdb --help
This is the GNU debugger.  Usage:

    gdb [options] [executable-file [core-file or process-id]]
    gdb [options] --args executable-file [inferior-arguments ...]

For more information, type "help" from within GDB, or consult the
GDB manual (available as on-line info or a printed manual).

$ gdbserver --help
Usage:	gdbserver [OPTIONS] COMM PROG [ARGS ...]
	gdbserver [OPTIONS] --attach COMM PID
	gdbserver [OPTIONS] --multi COMM

COMM may either be a tty device (for serial debugging),
HOST:PORT to listen for a TCP connection, or '-' or 'stdio' to use
stdin/stdout of gdbserver.
PROG is the executable program.  ARGS are arguments passed to inferior.
PID is the process ID to attach to, when --attach is specified.
```

本机执行 `man gdb` 或 `info gdb` 可查看 gdb 调试器的详细参考手册。

## help within GDB

执行 `gdb` 启动 gdb 执行环境（REPL），或 `gdb <program>` 启动 gdb 调试 program。

> type "help" from within GDB, or consult the GDB manual

在 gdb REPL 中输入 `help` 查看 gdb 帮助，列出命令分类（List of classes of commands）。

```Shell
(gdb) help
List of classes of commands:

aliases -- User-defined aliases of other commands.
breakpoints -- Making program stop at certain points.
data -- Examining data.
files -- Specifying and examining files.
internals -- Maintenance commands.
obscure -- Obscure features.
running -- Running the program.
stack -- Examining the stack.
status -- Status inquiries.
support -- Support facilities.
text-user-interface -- TUI is the GDB text based interface.
tracepoints -- Tracing of program execution without stopping the program.
user-defined -- User-defined commands.

Type "help" followed by a class name for a list of commands in that class.
Type "help all" for the list of all commands.
Type "help" followed by command name for full documentation.
Type "apropos word" to search for commands related to "word".
Type "apropos -v word" for full documentation of commands related to "word".
Command name abbreviations are allowed if unambiguous.
```

### help <command-class\>

> Type "help" followed by a class name for a list of commands in that class.

在 gdb REPL 中输入 `help <comman-class>` 查看具体分类命令的帮助。

例如，输入 `help breakpoints` 查看设置断点相关命令。以下摘录断点相关常用命令。

```Shell
(gdb) help breakpoints
Making program stop at certain points.

List of commands:

break, brea, bre, br, b -- Set breakpoint at specified location.
break-range -- Set a breakpoint for an address range.

clear, cl -- Clear breakpoint at specified location.
commands -- Set commands to be executed when the given breakpoints are hit.
condition -- Specify breakpoint number N to break only if COND is true.
delete, del, d -- Delete all or some breakpoints.

delete breakpoints -- Delete all or some breakpoints or auto-display expressions.

delete display -- Cancel some expressions to be displayed when program stops.

disable, disa, dis -- Disable all or some breakpoints.
disable breakpoints -- Disable all or some breakpoints.
disable display -- Disable some expressions to be displayed when program stops.

enable, en -- Enable all or some breakpoints.
enable breakpoints -- Enable all or some breakpoints.
enable breakpoints count -- Enable some breakpoints for COUNT hits.
enable breakpoints delete -- Enable some breakpoints and delete when hit.
enable breakpoints once -- Enable some breakpoints for one hit.
enable count -- Enable some breakpoints for COUNT hits.
enable delete -- Enable some breakpoints and delete when hit.
enable display -- Enable some expressions to be displayed when program stops.

rbreak -- Set a breakpoint for all functions matching REGEXP.
rwatch -- Set a read watchpoint for EXPRESSION.

skip -- Ignore a function while stepping.
skip delete -- Delete skip entries.
skip disable -- Disable skip entries.
skip enable -- Enable skip entries.
skip file -- Ignore a file while stepping.
skip function -- Ignore a function while stepping.
strace -- Set a static tracepoint at location or marker.
tbreak -- Set a temporary breakpoint.

trace, trac, tra, tr, tp -- Set a tracepoint at specified location.
watch -- Set a watchpoint for EXPRESSION.

--Type <RET> for more, q to quit, c to continue without paging--
```

按回车键（`RET`）翻页查看 more，按 `q` 退出，按 `c` 不分页展开剩下的部分。

### help <command-name\>

> Type "help" followed by command name for full documentation.

#### help break

输入 `help break`，查看如何在特定位置设置断点（Set breakpoint at specified location.）。

```Shell
(gdb) help break
break, brea, bre, br, b
Set breakpoint at specified location.
break [PROBE_MODIFIER] [LOCATION] [thread THREADNUM]
	[-force-condition] [if CONDITION]
PROBE_MODIFIER shall be present if the command is to be placed in a
probe point.  Accepted values are `-probe' (for a generic, automatically
guessed probe type), `-probe-stap' (for a SystemTap probe) or
`-probe-dtrace' (for a DTrace probe).
LOCATION may be a linespec, address, or explicit location as described
below.

With no LOCATION, uses current execution address of the selected
stack frame.  This is useful for breaking on return to a stack frame.

...
```

由帮助说明可知，设置断点有以下几种常见方法：

| command                            | description                         | comment                                                  |
| ---------------------------------- | ----------------------------------- | -------------------------------------------------------- |
| break                              | 不带任何参数，表示在下一条指令处停住。                 | 缩略写法 `b`                                                 |
| break <function\>                  | 在进入指定函数后停住                          | C++中可以使用 class::function 或 function(type,type) 格式来指定函数名。 |
| break <linenum\>                   | 在指定行号停住。                            |                                                          |
| break +offset <br /> break -offset | 在当前行号的前/后偏移offset行处停住               | offiset为自然数                                              |
| break filename\:linenum            | 在源文件filename的linenum行处停住。           |                                                          |
| break filename\:function           | 在源文件filename的function函数的入口处停住。      |                                                          |
| break \*address                    | 在程序运行的内存地址处停住。                      | \*main + 4: fourth byte past main()                      |
| break ... if <condition\>          | ...可以是上述的参数。condition表示条件，在条件成立时停住。 | 比如在循环境体中，可以设置 break if i=100，表示当i为100时停住程序。              |

可使用info命令，查看已经配置的断点信息：

*   info breakpoints \[n]
*   info break \[n]
*   i b \[n]

注：n 表示断点号，可选。没有指定断点号，列出所有断点；否则只显示指定序号的断点信息。

#### help disable breakpoints

输入 `help disable` 列出了所有 disable 相关的子命令（List of disable subcommands）：

```Shell
(gdb) help disable
disable, disa, dis
Disable all or some breakpoints.
Usage: disable [BREAKPOINTNUM]...
Arguments are breakpoint numbers with spaces in between.
To disable all breakpoints, give no argument.
A disabled breakpoint is not forgotten, but has no effect until re-enabled.

List of disable subcommands:

disable breakpoints -- Disable all or some breakpoints.
disable display -- Disable some expressions to be displayed when program stops.
disable frame-filter -- GDB command to disable the specified frame-filter.
disable mem -- Disable memory region.
disable pretty-printer -- GDB command to disable the specified pretty-printer.
disable probes -- Disable probes.
disable type-printer -- GDB command to disable the specified type-printer.
disable unwinder -- GDB command to disable the specified unwinder.
disable xmethod -- GDB command to disable a specified (group of) xmethod(s).

Type "help disable" followed by disable subcommand name for full documentation.
Type "apropos word" to search for commands related to "word".
Type "apropos -v word" for full documentation of commands related to "word".
Command name abbreviations are allowed if unambiguous.
```

> Type "help disable" followed by disable subcommand name for full documentation.

进一步输入 `help disable breakpoints` 查看怎么禁用断点：

```Shell
(gdb) help disable breakpoints
Disable all or some breakpoints.
Usage: disable breakpoints [BREAKPOINTNUM]...
Arguments are breakpoint numbers with spaces in between.
To disable all breakpoints, give no argument.
A disabled breakpoint is not forgotten, but has no effect until re-enabled.
This command may be abbreviated "disable".
```

由帮助说明可知，`disable breakpoints` 后接断点号（BREAKPOINTNUM）即可禁用指定断点。

执行 `i b` 列出所有断点信息，可查看断点号（Num）和断点启用状态（Enb）。

#### help enable breakpoints

输入 `help enable` 列出了所有 enable 相关的子命令（List of enable subcommands）。

> Type "help enable" followed by enable subcommand name for full documentation.

进一步输入 `help enable breakpoints` 查看怎么使能断点：

```Shell
(gdb) help enable breakpoints
Enable all or some breakpoints.
Usage: enable breakpoints [BREAKPOINTNUM]...
Give breakpoint numbers (separated by spaces) as arguments.
This is used to cancel the effect of the "disable" command.
May be abbreviated to simply "enable".

List of enable breakpoints subcommands:

enable breakpoints count -- Enable some breakpoints for COUNT hits.
enable breakpoints delete -- Enable some breakpoints and delete when hit.
enable breakpoints once -- Enable some breakpoints for one hit.

Type "help enable breakpoints" followed by enable breakpoints subcommand name for full
documentation.
Type "apropos word" to search for commands related to "word".
Type "apropos -v word" for full documentation of commands related to "word".
Command name abbreviations are allowed if unambiguous.
```

### apropos word

如果想模糊搜索某个感兴趣的话题，可以借助 `apropos` 命令查找关键字。

> Type "apropos word" to search for commands related to "word".

`apropos compile`: 查看 compile 相关的话题。
`apropos file`: 查看 file 相关的话题。

## gdb-multiarch

[What is multi-arch?](https://sourceware.org/gdb/papers/multi-arch/whatis.html)

```bash
$ apt search -n gdb-multiarch
Sorting... Done
Full Text Search... Done
gdb-multiarch/jammy-updates,now 12.1-0ubuntu1~22.04 arm64 [installed]
  GNU Debugger (with support for multiple architectures)
```

```bash
$ apt show gdb-multiarch
Package: gdb-multiarch
Version: 12.1-0ubuntu1~22.04

Description: GNU Debugger (with support for multiple architectures)
    This package contains a version of GDB which supports multiple target architectures.
```

执行 `sudo apt-get install gdb-multiarch`  即可安装 gdb-multiarch。

[c - Specifying an architecture in gdb-multiarch](https://stackoverflow.com/questions/55684272/specifying-an-architecture-in-gdb-multiarch)
[gdb调试arm：gdb-multiarch gdbserver coredump](https://blog.csdn.net/weixin_49867936/article/details/109719019)
[ARM pwn 环境搭建和使用](https://blog.csdn.net/qq_60209620/article/details/137163917?depth_1-utm_source=distribute.pc_relevant.none-task-blog-2~default~YuanLiJiHua~Position-2-137163917-blog-109719019.235%5Ev43%5Epc_blog_bottom_relevance_base4): qemu+gdb-multiarch

## references

用GDB调试程序：[（一）](https://haoel.blog.csdn.net/article/details/2879) ～ [（七）](https://haoel.blog.csdn.net/article/details/2885)
[GDB之(8)GDB-Server远程调试](https://onceday.blog.csdn.net/article/details/136335177)

[Arm Assembly Internals and Reverse Engineering](https://www.amazon.com/Blue-Fox-Assembly-Internals-Analysis/dp/1119745306) | Chapter 11 Dynamic Analysis - Command-Line Debugging

[Advanced GDB Usage | Interrupt](https://interrupt.memfault.com/blog/advanced-gdb#conditional-breakpoints-and-watchpoints)
[Tools we use: installing GDB for ARM | Interrupt](https://interrupt.memfault.com/blog/installing-gdb)
