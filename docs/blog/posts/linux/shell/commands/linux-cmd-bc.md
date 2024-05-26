---
title: Linux Command - bc
authors:
  - xman
date:
    created: 2019-10-30T10:30:00
    updated: 2024-05-19T16:30:00
categories:
    - wiki
    - linux
comments: true
---

[bc](https://www.gnu.org/software/bc/manual/html_mono/bc.html)(basic calculator) - An arbitrary precision calculator language.

`bc` is a language that supports arbitrary precision numbers with interactive execution of statements.

<!-- more -->

bc is typically used as either a `mathematical scripting language` or as an `interactive mathematical shell`.  

> 关于 bc 表达式语言，参考 wiki - [bc](https://en.wikipedia.org/wiki/Bc_(programming_language))。

There are four special variables, `scale`, `ibase`, `obase`, and `last`.  

支持输入数学表达式的解释型计算语言  

在终端输入 `bc` 即可进入 bc 命令行解释器；输入 `quit` 或者 `<C-d>` 发送 EOF 结束退出 bc。

> [COMMAND LINE CALCULATOR, BC](http://linux.byexamples.com/archives/42/command-line-calculator-bc/)  
> [How to Use the "bc" Calculator in Scripts](https://www.lifewire.com/use-the-bc-calculator-in-scripts-2200588)  
> [Linux下的计算器(bc、expr、dc、echo、awk)知多少？](http://blog.csdn.net/linco_gp/article/details/4517945)  
> [Linux中的super pi(bc 命令总结)](http://www.linuxidc.com/Linux/2012-06/63684.htm)  
> [我使用过的Linux命令之bc - 浮点计算器、进制转换](http://codingstandards.iteye.com/blog/793734)  

## basic

1. 在 bash shell 终端输入 `bc` 即可启动 bc 计算器。

输入表达式 `56.8 + 77.7`，再按回车键即可在新行得到计算结果：

```bash
pi@raspberrypi:~ $ bc
bc 1.06.95
Copyright 1991-1994, 1997, 1998, 2000, 2004, 2006 Free Software Foundation, Inc.
This is free software with ABSOLUTELY NO WARRANTY.
For details type `warranty'. 

56.8 + 77.7
134.5
```

也可书写代数表达式，用变量承载计算结果，作为进一步计算的操作数：

```bash
$ bc -q # -q 不显示冗长的欢迎信息
a=2+3;
a
5
b=a*4;
b
20
```

2. 可通过 bc 内置的 **`scale`** 变量可指定浮点数计算输出精度：

```bash
$ bc -q
5 * 7 /3
11
scale=2; 5 * 7 /3
11.66
```

3. 在终端可基于[数据流重定向或管道](https://www.cnblogs.com/mingcaoyouxin/p/4077264.html)作为 `bc` 的输入表达式：

```bash
$ echo "56.8 + 77.7" | bc
134.5
```

## inline

对于简单的单行运算，可用 echo 重定向或内联重定向实现：

```bash
$ bc <<< "56.8 + 77.7"
134.5
```

如果需要进行大量运算，在一个命令行中列出多个表达式就会有点麻烦。  
bc命令能识别输入重定向，允许你将一个文件重定向到bc命令来处理。  
但这同样会叫人头疼，因为你还得将表达式存放到文件中。  

最好的办法是使用内联输入重定向，它允许你直接在命令行中重定向数据。  
在shell脚本中，你可以将输出赋给一个变量。

```bash
variable=$(bc << EOF
           options
           statements
           expressions
           EOF)
```

`EOF` 文本字符串标识了内联重定向数据的起止。

以下在终端测试这种用法：

```bash
$ bc << EOF
heredoc> 56.8 + 77.7
heredoc> EOF
134.5
```

## script

在shell脚本中，可调用bash计算器帮助处理浮点运算。可以用命令替换运行bc命令，并将输出赋给一个变量。基本格式如下：

```bash
variable=$(echo "options; expression" | bc)
```

第一部分 options 允许你设置变量。 如果你需要不止一个变量， 可以用分号将其分开。 expression参数定义了通过bc执行的数学表达式。

以下为在 shell scripts 调用 bc 对常量表达式做计算的示例:

```bash
$ result=$(echo "scale=2; 5 * 7 /3;" | bc)
$ echo $result
11.66
```

以下为在 shell scripts 调用 bc 对变量表达式做计算的示例:

```bash
$ var1=100
$ var2=45
$ result=`echo "scale=2; $var1 / $var2" | bc`
$ echo $result
2.22
```

如果在脚本中使用，可使用内联重定向写法，将所有bash计算器涉及的部分都放到同一个脚本文件的不同行。  
将选项和表达式放在脚本的不同行中可以让处理过程变得更清晰，提高易读性。  
当然，一般需要用命令替换符号将 bc 命令的输出赋给变量，以作后用。  

`EOF` 字符串标识了重定向给bc命令的数据的起止，bc 内部可创建临时变量辅助计算（定义辅助变量或承接中间计算结果），但总是返回最后一条表达式的计算结果。

下面是在脚本中使用这种写法的例子。

```bash
$ cat test12.sh
#!/bin/bash

var1=10.46
var2=43.67
var3=33.2
var4=71
var5=$(bc << EOF
scale = 4
a1 = ( $var1 * $var2)
b1 = ($var3 * $var4)
a1 + b1
EOF)

echo The final answer for this mess is $var5
```

```bash
$ chmod u+x test12.sh
$ ./test12.sh
The final answer for this mess is 2813.9882
```

**注意**：在bash计算器中创建的局部变量只在内部有效，不能在shell脚本中引用！

## last

**`last`**  (an  extension)  is a variable that has the value of the *last* printed number.

bc 内置的 **`last`** 变量代表上个表达式的计算结果，可将 last 变量作为后续表达式的操作数，进行二次计算：

```bash
$ bc -q
2+3
5
last*4
20
```

## ibase/obase

默认输入和输出都是基于十进制：

```bash
$ bc -q
ibase
10
obase
10
```

在 bc 命令解释器中输入 `ibase=10;obase=16;2017`，转换输出2017（十进制）的十六进制：

```bash
ibase=10;obase=16;2017
7E1
```

或者 echo 分号相隔的表达式重定向作为 bc 的输入进行解释运行：

```bash
$ echo "ibase=10;obase=16;2017" | bc
7E1
```

以下示例用 `bc` 计算器实现进制转换。

先将十进制转换成二进制：

```bash
$ no=100
$ echo "obase=2;$no" | bc 
1100100
```

再将二进制转换回十进制

```bash
$ no=1100100
$ echo "obase=10;ibase=2;$no" | bc
100
```

需要注意先写obase再写ibase，否则出错：

```bash
$ no=1100100
$ echo "ibase=2;obase=10;$no" | bc
1100100
```
