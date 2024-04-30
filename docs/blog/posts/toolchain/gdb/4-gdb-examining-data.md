---
title: GDB Examining Data
authors:
  - xman
date:
    created: 2020-02-07T10:00:00
categories:
    - toolchain
tags:
    - gdb
    - examine
comments: true
---

[10 Examining Data](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Data.html#Data)

- [10.3 Program Variables](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Variables.html#Variables)
- [10.4 Artificial Arrays](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Arrays.html#Arrays)
- [10.6 Examining Memory](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Memory.html#Memory)
- [10.8 Automatic Display](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Auto-Display.html#Auto-Display)
- [10.14 Registers](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Registers.html#Registers)

<!-- more -->

The usual way to examine data in your program is with the `print` command (abbreviated `p`), or its synonym `inspect`. It evaluates and prints the value of an expression.

print [[options] --] expr
print [[options] --] /f expr

> *expr* is an expression. By default the value of expr is printed in a format appropriate to its data type; you can choose a different format by specifying `/f`, where f is a letter specifying the *format*; see [Output Formats](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Output-Formats.html#Output-Formats).

GDB的数据显示格式：

- `x`: 按十六进制格式显示变量。
- `d`: 按十进制格式显示变量。
- `u`: 按十六进制格式显示无符号整型。
- `o`: 按八进制格式显示变量。
- `t`: 按二进制格式显示变量。
- `a`: 按十六进制格式显示变量。
- `c`: 按字符格式显示变量。
- `f`: 按浮点数格式显示变量。

```Shell
(gdb) p i
$1 = 101
(gdb) p/a i
$2 = 0x65
(gdb) p/c i
$3 = 101 'e'
(gdb) p/t i
$4 = 1100101
```

## array

有时候，你需要查看一段连续的内存空间的值。比如数组的一段，或是动态分配的数据的大小。

此时，可以使用GDB的 `@` 操作符。`@` 的左边是第一个内存的地址，`@`的右边是欲查看的内存的长度（字节数）。

例如，你的程序中有这样的语句：

```c
int *array = (int *) malloc (len * sizeof (int));
```

于是，在GDB调试过程中，可以以如下命令显示出这个动态数组的取值：

```Shell
p *array@len
```

@的左边是数组的首地址的值，也就是变量array所指向的内容，右边则是数据的长度 len。 

其输出结果，大约是下面这个样子的：

```Shell
(gdb) p *array@len
$1 = {2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40}
```

如果是静态数组的话，可以直接用 print 数组名，就可以显示数组中所有数据的内容了。

## memory

可以使用 `examine` 命令（简写是 `x`）来查看内存地址中的值，语法如下：

```Shell
x/<n/f/u> <addr>
```

n、f、u 是可选的参数。

- n 是一个正整数，表示显示内存的长度，也就是说从当前地址向后显示几个地址的内容。

- f 表示显示的格式，参见上面。如果地址所指的是字符串，那么格式可以是s，如果地址是指令地址，那么格式可以是i。

- u 表示从当前地址往后请求的字节数，如果不指定的话，GDB默认是4个bytes。

    - u 参数可以用以下字符来代替：b表示单字节，h表示双字节，w表示四字节，g表示八字节。

    - 当我们指定了字节长度后，GDB会从指内存定的内存地址开始，读写指定字节，并把其当作一个值取出来。

- `<addr>`: 表示一个内存地址。

n/f/u三个参数可以一起使用。例如，命令 `x/3uh 0x54320` 表示从内存地址0x54320读取内容，h表示以双字节为一个单位，3表示三个单位，u表示按十六进制显示。

## display

可以设置一些自动显示的变量，当程序停住时，或是在你单步跟踪时，这些变量会自动显示。相关的GDB命令是 `display`。

- `display <expr>`
- `display/<fmt> <expr>`
- `display/<fmt> <addr>`

expr 是一个表达式，fmt 表示显示的格式，addr 表示内存地址。

当你用display设定好了一个或多个表达式后，只要你的程序被停下来，GDB会自动显示你所设置的这些表达式的值。

可执行 `info display` 列举查看已经设置的 display points。此外，GDB 还提供了删除命令：

- `undisplay <dnums...>`
- `delete display <dnums...>`

dnums 为自动显示的编号，多个编号之间用空格分隔。

## registers

要查看寄存器的值，可以使用如下命令：

`info registers`：查看寄存器的情况。（除了浮点寄存器）
`info all-registers`：查看所有寄存器的情况。（包括浮点寄存器）
`info registers <regname ...>`：查看指定的寄存器的情况。

寄存器中放置了程序运行时的数据，比如程序当前运行的指令地址（ip），程序的当前堆栈地址（sp）等等。你同样可以使用print命令来访问寄存器的情况，只需要在寄存器名字前加一个 \$ 符号即可，如 `p $pc`。
