---
title: Linux Command - awk basic
authors:
  - xman
date:
    created: 2019-11-05T09:00:00
categories:
    - wiki
    - linux
tags:
    - awk
comments: true
---

Linux 下的 awk 命令基本知识。

<!-- more -->

虽然sed编辑器是非常方便自动修改文本文件的工具，但其也有自身的限制。  
如果要格式化报文或从一个大的文本文件中抽取数据包，那么 awk 可以完成这些任务。

awk 提供了一个类编程环境来修改和重新组织文件中的数据，是一种来处理文件中的数据的更高级工具。  
awk 是一种自解释的编程语言，以发展这种语言的人 `A`ho.`W`eninberger 和 `K`ernigham 命名。  
awk 结合诸如 grep 和 sed 等其他工具，将会使shell编程更加强大。除此之外，还有 gawk、nawk 和 mawk 等扩展变种。  

为获得所需信息，文本或字符串必须格式化，意即用 `域分割符`（Filed Separator）划分抽取域。
awk 在文本文件或字符串中基于指定规则浏览和抽取信息，然后再执行其他命令。

可以利用 awk 编程语言做下面的事情：

- 定义变量来保存数据  
- 使用算术和字符串操作符来处理数据  
- 使用结构化编程概念（比如if-then语句和循环）来为数据处理增加处理逻辑  
- 通过提取数据文件中的数据元素，将其重新排列或格式化，生成格式化报告  

awk 程序的报告生成能力通常用来从大文本文件中提取数据元素，并将它们格式化成可读的报告。其中最完美的例子是格式化日志文件。

## awk 范式

默认情况下，awk 会从输入中读取一行文本，然后针对该行的数据执行程序脚本。

一个完整的 awk 脚本由3部分组成，形如如下：

```
awk 'BEGIN {begin} {body} END {end}' file
```

### BEGIN/END

awk 脚本包含两个特殊字段 `BEGIN` 和 `END`。

- `BEGIN` : 在处理数据前运行脚本，用于为报告创建标题等；  
- `END` : 在处理数据后运行脚本，awk 会在读完数据后执行它；  

`BEGIN` 语句用于设定 PreProcessing，用于设置计数和打印头，使用在任何文本浏览动作之前。  

> 通常 awk 控制格式相关的一些内置变量和用户自定义变量放在 BEGIN 部分，以便在读取第一行之前即初始化。

`END` 语句用来设定 PostProcessing，用于在完成文本浏览动作后打印输出文本总数和结尾状态标志。  

> BEGIN/END 部分通常不是必须的。

### 模式和动作

awk 脚本的 body 部分可能包含多条语句，任何一条 awk 语句则都由 `模式` 和 `动作` 组成。

模式部分决定动作语句何时触发及触发事件，处理即对数据进行的操作。  
模式可以是任何条件语句或复合语句或正则表达式。

```Shell
pattern { action }
```

> 如果不特别指明模式，awk 总是匹配或打印行数。如果省略模式部分，动作将时刻保持执行状态。

**动作** 大多数用来打印，但是可以在大括号（`{}`）内书写更长的代码诸如 if 和循环（looping）语句及循环退出结构。  
大括号（`{}`）内多行语句以分号（`;`）相隔，这一点和 sed、C等其他编程语言一致。  

> 如果不指明采取动作，awk 将打印出所有浏览出来的记录。

awk 默认的动作是**逐条遍历打印记录**(*foreach print*)，有以下几种最简范式：

- 逐行打印文档：`awk 1{print $0} data.txt`，其中模式1恒成立；  
- 进一步省略默认参数 $0：`awk 1{print} data.txt`；  
- 进一步省略默认动作：`awk 1 data.txt`。  

除了输出字段分割符（`OFS`），awk 中的 print 语句在数据显示上并未提供多少控制。

### 入门示例

可以只书写 BEGIN 部分测试 awk 语法，省略 body 和 END 部分，以及 file 参数。

```Shell
$ awk 'BEGIN {print "Hello, AWK!"}'
Hello, AWK!
```

文本文件 data1 内容如下：

```Shell
$ cat data1
P.Bunny # 02/99 # 48   # Yellow
J.Troll # 07/99 # 4842 # Brown-3
```

在 awk 结尾部分，通过 END 打印处理的记录数：

```Shell
$ awk 'END {print "end-of-record, NR="NR}' data1
end-of-record, NR=2
```

---

文本文件 data2.txt 内容如下：

```Shell
$ cat data2.txt
One line of test text.
Two lines of test text.
Three lines of test text.
```

下面是一段完整的范式示例：

```Shell
$ awk 'BEGIN {print "The data2 File Contents:"; print "=========="}
    {print $0}
    END {print "=========="; print "End of File"}' data2.txt
The data2 File Contents:
==========
One line of test text.
Two lines of test text.
Three lines of test text.
==========
End of File
```

## 记录和域

### 记录（Record）

跟 sed 一样，awk 默认逐行扫描文本，并执行程序对每一行进行分析处理。
这里的“一行”即为一条记录（Record），是 awk 将进行数据分析处理的基本单位。

awk 扫描文本时，实际上是根据记录分割符 `RS`（Record Seperator）来界定一条记录的。
当发现 RS 时，awk 获悉读取到了一条记录，进行模式匹配（分析）并执行动作（处理）。
分析完一条记录后，继续移动指针向后扫描，直到发现下一个 RS，处理新的记录。
读取进程如此往复，持续到文件结尾（EOF）或文件不再存在结束。

以下在 BEGIN 中打印当前 RS，默认为换行符 `\n`：

```Shell
$ awk 'BEGIN { printf "RS=\"%s\"\n", RS }'
RS="
"
```

> 关于 RS 变量的设置和实践，参考 [awk-vars](./awk-vars.md) 一节。

---

`awk '1 {print $0}' data2.txt` 中的模式永真，实际效果为逐条打印。

> 由于 print 为缺省动作，因此可进一步简写为 `awk 1 data2.txt`。

```Shell
$ awk '1 {print}' data2.txt
One line of test text.
Two lines of test text.
Three lines of test text.
```

### 域（Field）

awk 在处理一条记录时，会用预定义的分割符，将这条记录划分为多个域（字段，Field）。

> 可类比excel表格数据：将记录类比表格的行（row），域类比为表格的列（column）。

awk 扫描记录时，当发现域分割符 `FS`（Field Seperator），则将其当做一个字段。

awk 中默认的字段分割符是任意的空白字符（例如空格或制表符）。

以下在 BEGIN 中打印当前 FS：

```Shell
$ awk 'BEGIN { printf "FS=\"%s\"\n", FS }'
FS=" "
```

#### -F 指定域分割符

默认 `FS` 非顶格空格或制表符，也可以自行指定其他字符（串）作为域分割符。
除此之外，也可在执行 awk 命令时通过 `-F` 选项来指定域分割符。

> `-F` 之后的 fs 之间可以没有空格；`fs` 如果是单个字符可以不加（双）引号；如果是多个字符或包含空格，建议添加引号。

携带 `-F` 选项的典型调用范式如下：

```Shell
awk -F: 'commands' input-file
```

执行 awk 命令，`-F` 指定按 `#` 分割域，输出如下：

```Shell
$ awk -F '#' '{print $1,$2,$3,$4}' data1
P.Bunny   02/99   48     Yellow
J.Troll   07/99   4842   Brown-3
```

参照下表，awk 每次读取一条记录，在分析记录时，遇到域分割符（`#`），标识其为域 $n，直至遇到记录分割符 `RS` 结束。
然后，继续扫描下一条记录，分析其中的域（字段），如此往复。

| 域1     | 分割符  | 域2   | 分割符   | 域3   | 分割符  | 域4     | RS |
| --------| ------ | ------| ------ | ---- | ------ | --------|----|
| P.Bunny | #      | 02/99 | #      | 48   | #      | Yellow  | \n |
| J.Troll | #      | 07/99 | #      | 4842 | #      | Brown-3 | \n |

---

awk 的 `-F` 选项可指定任何合法的字符串作为域分割符，以便对数据记录进行切割提取分析。  
典型使用场景是利用 grep 或 sed 从文本中筛选出匹配指定模式的行，再通过管道重定向给 awk 进行切割提取指定域。  

[sed-awk-demo](../sed-awk-demo.md) 中有大量 sed 与 awk 结合使用的场景示例。 

[awk - 10 examples to insert / remove / update fields of a CSV file](https://www.theunixschool.com/2012/11/awk-examples-insert-remove-update-fields.html)  

[关于使用shell在文件中查找一段字符串的问题](https://bbs.csdn.net/topics/380208443)

指定 FS=AAA，基于 AAA 分割前半部分：

```Shell
$ echo "12312312343242AAAdfasdfasdfasdfasdfadAAAfsdgfsdfgfgfgdfgasdfg" | awk -F "AAA" '{print $1}'
12312312343242
```

指定 FS=AAA，基于 AAA 分割后半部分：

```Shell
$ echo "12312312343242AAAdfasdfasdfasdfasdfadAAAfsdgfsdfgfgfgdfgasdfg" | awk -F "AAA" '{print $2}'
dfasdfasdfasdfasdfad
```

#### 域标识及引用

awk 将分割出来的域依次标记为 `$1`,`$2`,...,`$n`，它们称为 **域标识**。

- `$0` : 代表整个文本行（整条记录）  
- `$1` : 代表文本行中的第1个数据字段  
- `$2` : 代表文本行中的第2个数据字段  
- `$n` : 代表文本行中的第n个数据字段  

脚本中可引用域标识对域进行进一步处理。  
使用 `$1,$3` 表示引用第1和第3域，注意这里用逗号做域分割。  
如果希望打印有5个域的记录的所有域，不必指明 `$1,$2,$3,$4,$5`，可使用 `$0`，意即整条记录的所有域。  
awk 浏览数据到达一新行时，即假定到达包含域的记录末尾，然后开始下一行新记录的读动作，并重新设置域分割符。  

---

以下示例中，awk 读取文本文件，每行只显示第1个字段。

```Shell
$ awk '{print $1}' data2.txt
One
Two
Three
```

以下命令摘取打印每条记录的第1、3、6三个字段：

```Shell
$ awk '{print $1,$3,$6}' grade.txt
M.Tansley 48311 40
J.Lulu 48317 24
P.Bunny 48 35
J.Troll 4842 26
L.Tansley 4712 30
```

以下示例中，awk 引用域四并对其进行赋值修改：

```Shell
$ awk '{$4="awk";print$0}' data2.txt
One line of awk text.
Two lines of awk text.
Three lines of awk text.
```

## 典型范式

Manual Pages 中的 SYNOPSIS 如下：

```Shell
       awk [ -F fs ] [ -v var=value ] [ 'prog' | -f progfile ] [ file ...  ]

       awk [−F sepstring] [−v assignment]... program [argument...]

       awk [−F sepstring] −f progfile [−f progfile]... [−v assignment]...
            [argument...]
```

省略模式部分的典型 awk 调用范式如下：

```Shell
awk options 'commands' input-file
```

也可将所有的 awk 命令保存到一个脚本文件中，然后调用 awk 时用 `-f` 选项指定命令脚本：

```Shell
awk -f awk-script-file input-file(s)
```

- `-f` 选项指明在文件 awk_script_file 中的 awk 脚本；  
- `input-file(s)` 是使用 awk 进行浏览的文件名。  

### options

awk 常用命令选项如下表：

| 选项           | 描述                          |
| -------------- | -----------------------------|
| `-F fs`        | 指定行中划分数据字段的字段分割符   |
| `-f file`      | 从指定的文件中读取脚本程序        |
| `-v var=value` | 定义一个变量及其默认值           |
| `-mf N`        | 指定要处理的数据文件中的最大字段数 |
| `-mr N`        | 指定数据文件中的最大数据行数      |

### input from STDIN

若没有在命令行上指定文件（input-file），则 awk 将会等待从 STDIN 接受输入参数作为待处理数据。

输入一行文本并按下回车键，awk 会对这行文本运行一遍程序脚本。

以下示例 `awk '{print "Hello, AWK!"}'` 总是打印一行固定的文本字符串，因此不管你在数据流中输入什么文本，都会得到同样的文本输出。

```Shell
$ awk '{print "Hello, AWK!"}'
stdin line 1 for awk!
Hello, AWK!
stdin line 2 for awk!
Hello, AWK!
```

稍作修改为 `awk '{print $2}'`，则打印输入文本空格分割的第2个字段：

```Shell
$ awk '{print $2}'
Hello World
World
Hey Jude
Jude
```

按下 `<C-C>` 或 `<C-D>`（EOF）退出。
