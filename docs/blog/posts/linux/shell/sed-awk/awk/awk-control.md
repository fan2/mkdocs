---
title: Linux Command - awk control
authors:
  - xman
date:
    created: 2019-11-05T10:00:00
categories:
    - wiki
    - linux
tags:
    - awk
comments: true
---

Linux 下的 awk 命令中的流程控制。

<!-- more -->

## 结构化流程控制

awk 编程语言支持常见的结构化流程控制。

### if

假如想看看哪些学生可以获得升段机会，需要判断目前级别分 field-6 是否小于（`<`）最高分 field-7。

```
#不指定动作时，默认打印匹配行。
$ awk '$6<$7' grade.txt
M.Tansley   05/99   48311   Green       8   40  44
J.Lulu      06/99   48317   green       9   24  26
```

以上命令等效的 `pattern { action }` 简约格式为 `awk '$6<$7 {print $0}' grade.txt`。

在 body 部分，用 if 条件判断的完整格式为：

```
awk '{if($6<$7) print $0}' grade.txt
```

- 筛选 field-6 小于 27 的条目: `awk '$6<27' grade.txt`；  
- 判断小于等于（`<=`）：`awk '$6<=$7 {print $1}' grade.txt`；  
- 判断大于（`>`）：`awk '$6>$7 {print $1}' grade.txt`；  

---

以下筛选出低于平均成绩的记录，并输出一句鼓励的话：

```
# pattern { action } 格式
$ awk '$6<$7 {print $1, "Try better at the next comp"}' grade.txt
M.Tansley Try better at the next comp
J.Lulu Try better at the next comp
```

在 body 部分，用 if 条件判断的完整格式为：

```
awk '{if($6<$7) print $1, "Try better at the next comp"}' grade.txt
```

#### 修改域值

以上 awk 语句针对 M.Tansley 修改其成绩并 print，其他人直接 print 第1、6、7列。
修改域值动作受条件限制，print 动作不受条件限制。

```
$ #awk '{if($1=="M.Tansley") $6=$6-1; print $1,$6,$7}' grade.txt
$ awk '$1=="M.Tansley" {$6=$6-1} {print $1,$6,$7}' grade.txt
M.Tansley 39 44
J.Lulu 24 26
P.Bunny 35 28
J.Troll 26 26
L.Tansley 30 28
```

如果只想打印修改的条目，可将 print 约束到条件判断才执行：

```
# #awk '{if($1=="M.Tansley") {$6=$6-1; print $1,$6,$7}}' grade.txt
$ awk '$1=="M.Tansley"{$6=$6-1; print $1,$6,$7}' grade.txt
M.Tansley 39 44
```

修改文本域即对其重新赋值，需要做的就是赋给一个新的字符串。  
在 J.Troll 中加入字母，使其成为 J.L.Troll，表达式为 `$1="J.L.Troll"`，记住字符串要使用双引号（`""`），并用圆括号（`()`）括起整个赋值语句。

```
$ #awk '{if($1=="J.Troll") ($1="J.L.Troll"); print $1}' grade.txt
$ awk '$1=="J.Troll" { ($1="J.L.Troll") } { print $1}' grade.txt
M.Tansley
J.Lulu
P.Bunny
J.L.Troll
L.Tansley
```

修改一下，只打印修改部分：

```
$ #awk '{if($1=="J.Troll") { ($1="J.L.Troll"); print $1 } }' grade.txt
$ awk '$1=="J.Troll" { ($1="J.L.Troll"); print $1 }' grade.txt
J.L.Troll
```

#### 创建新域

在 awk 中处理数据时，基于各域进行计算时创建新域是一种好习惯。  
创建新域要通过其他域赋予新域标识符，如创建一个基于其他域的加法新域 `{$4=$2+$3}`，这里假定记录包含3个域，则域4为新建域，保存域2和域3相加结果。  
以下示例，在文件 grade.txt 中创建新域8保存域目前级别分与域最高级别分的减法值，表达式为 `{$8=$7-$6}`。

```
$ #awk 'BEGIN{print "Name\t Difference"} {if($6<$7){$8=$7-$6; print $1,$8}}' grade.txt
$ awk 'BEGIN{print "Name\t   Difference"} $6<$7 {$8=$7-$6; printf "%-10s %s\n",$1,$8}' grade.txt
Name	   Difference
M.Tansley  4
J.Lulu     2
```

### for

for 语句是许多编程语言执行循环的常见方法。
awk编程语言支持C风格的for循环。

```
for( variable assignment; condition; iteration process)
```

将多个功能合并到一个语句有助于简化循环。

示例1：for 循环数组元素

```
$ awk 'BEGIN{
    var["a"] = 1
    var["g"] = 2
    var["m"] = 3
    var["u"] = 4
    for (test in var)
    {
        print "Index:",test," - Value:",var[test]
    }
}'
```

示例2: for 循环统计每条记录域5和域6平均值。

```
awk '{
    total = 0
    for (i=5; i<7; i++)
    {
        total += $i
    }
    avg = total / 2
    print "Average:",avg
}' grade.txt
Average: 24
Average: 16.5
Average: 23.5
Average: 19
Average: 21
```

### while

while 语句为 awk 程序提供了一个基本的循环功能。下面是while语句的格式。

```
while (condition) { statements }
```

while 循环允许遍历一组数据，并检查迭代的结束条件。

以下示例统计每一条记录中各个域加和平均值：

```
$ cat data5
130 120 135
160 113 140
145 170 215

$ awk '{
    total = 0
    i = 1
    while (i <= NF)
    {
        total += $i
        i++
    }
    avg = total / 3
    print "Average:",avg
}' data5
Average: 128.333
Average: 137.667
Average: 176.667
```

> awk 编程语言支持在 while 循环中使用 `break` 语句和 `continue` 语句，允许从循环中跳出。

#### do-while

do-while 语句类似于 while 语句，但会在检查条件语句之前执行命令。

下面是 do-while 语句的格式。

```
do {
    statements
} while (condition)
```

这种格式保证了语句会在条件被求值之前至少执行一次。  
当需要在求值条件前执行语句时，这个特性非常方便。

## 格式化输出控制

gawk [Examples Using printf](https://www.gnu.org/software/gawk/manual/html_node/Printf-Examples.html)  
[How can I format the output of a bash command in neat columns](https://stackoverflow.com/questions/6462894/how-can-i-format-the-output-of-a-bash-command-in-neat-columns)  

print 打印语句的多个部分（常量和变量）之间要用逗号分隔，逗号前后会自动添加空行：

```
$ awk '{if($6<$7) print $1, "Try better at the next comp"}' grade.txt
M.Tansley Try better at the next comp
J.Lulu Try better at the next comp
```

> 以上如果不加逗号，Try 和前面的名称会连在一起。

以下 `"NR="NR`，常量串和变量（不用$符号引用）可以连在一起不用插入逗号。

```
$ awk 'BEGIN{FS=","} {print $1,"FNR="FNR,"NR="NR}' data1 data1
```

for 循环示例中的 `print "Index:",test," - Value:",var[test]` 中间那个空行可以省掉。

调用 print 打印多行时，每条 print 语句以分号指示结束：

```
$ awk 'BEGIN {print "The data2 File Contents:"; print "=========="}
$ awk 'END {print "end-of-record, NR="NR}' data1
```

### 格式化输出（printf）

如果要创建详尽的报表，可以使用格式化打印命令 `printf`，为数据选择特定的格式和位置进行输出。  
如果你熟悉C语言编程的话，awk 中的 printf 命令用法也是一样，允许指定具体如何显示数据的指令。  

```
    print [ expression-list ] [ > expression ]
    printf format [ , expression-list ] [ > expression ]
```

`printf` 命令格式：

```
    printf "format string", var1, var2, ...
```

`format string` 是格式化输出的关键，它会用文本元素和格式化指定符来具体指定如何呈现格式化输出。  

格式化指定符是一种特殊的代码，会指明显示什么类型的变量以及如何显示。
awk 程序会将每个格式化指定符作为占位符，供命令中的变量使用。第一个格式化指定符对应列出的第一个变量，第二个对应第二个变量，依此类推。

`格式化指定符` 采用如下格式：

```
%[modifier]control-letter
```

以下用科学计数法输出 `10*100` 的计算结果：

```
$ awk 'BEGIN{
  x = 10 * 100;
  printf "The answer is: %e\n", x
}'
The answer is: 1.000000e+03
```

以下示例强制第一个字符串的输出宽度为16个字符，并且左对齐。

```
$ awk 'BEGIN{FS="\n"; RS=""} {printf "%-16s %s\n", $1, $4}' data2
Riley Mullen     (312)555-1234
Frank Williams   (317)555-9876
Haley Snell      (313)555-4938
```

关于 awk 中使用算术表达式，参考 [Arithmetic Ops](https://www.gnu.org/software/gawk/manual/html_node/Arithmetic-Ops.html), [awk high precision arithmetic](https://unix.stackexchange.com/questions/57006/awk-high-precision-arithmetic)。

> **注意**：awk 中的 print(f) 中算术运算操作数只支持十进制。

参考 [puts@plt - static analysis](../../../../elf/plt-puts-analysis.md) 中的 printf 和算术运算的综合示范样例。

`objdump -hw` 输出的 section 的 Offset/Size 均为无 `0x` 前缀的十六进制。可使用 awk 提取列值进行十进制算术运算统计或插入新列。
为方便参加后续计算，使用 awk 提取列值进行输出时，可冠上十六进制前缀字符串 `"0x"`，它将与`$NF`引用自动进行字符串拼接。

```bash
$ objdump -hw a.out | awk '/.bss/{print $3}'
00000008
$ objdump -hw a.out | awk '/.bss/{print "0x"$3}'
0x00000008
$ objdump -hw a.out | awk '/.bss/{print (("0x"$3))+0}'
8

$ got_offset=$(objdump -hw a.out | awk '/.got/{print "0x"$6}')
$ got_size=$(objdump -hw a.out | awk '/.got/{print "0x"$3}')
```

使用 awk 对 hexdump 第一列 offset 值添加地址偏移量（baddr）以便得到 address。

1. 对于无前缀的十六进制格式化字符串 `"%08_ax\t"`，需先添加 `0x` 前缀，并使用`(("0x"$1))`对字符串进行数值化。
2. 或将格式化字符串改写为十进制 `"%_ad\t"` 或加前缀的的十六进制 `"0x%08_ax\t"`，这样可直接引用参加十进制运算。

```bash
# hexdump -v -s $got_offset -n $got_size -e '"%08_ax\t" /8 "%016x\t" "\n"' a.out \
# | awk 'BEGIN{print "Offset\t\tAddress\t\t\t\tValue"} \
# {printf("%s\t", $1); printf("%016x\t", (("0x"$1))+65536); print $2}'

# hexdump -v -s $got_offset -n $got_size -e '"%_ad\t" /8 "%016x\t" "\n"' a.out \
# | awk 'BEGIN{print "Offset\t\tAddress\t\t\t\tValue"} \
# {printf("%08x\t", $1); printf("%016x\t", $1+65536); print $2}'

$ hexdump -v -s $got_offset -n $got_size -e '"0x%08_ax\t" /8 "%016x\t" "\n"' a.out \
| awk 'BEGIN{print "Offset\t\tAddress\t\t\t\tValue"} \
{printf("%s\t", $1); printf("%016x\t", $1+65536); print $2}'
Offset    Address           Value
00000f90  0000000000010f90  0000000000000000
00000f98  0000000000010f98  0000000000000000
00000fa0  0000000000010fa0  0000000000000000
00000fa8  0000000000010fa8  00000000000005d0
00000fb0  0000000000010fb0  00000000000005d0
00000fb8  0000000000010fb8  00000000000005d0
00000fc0  0000000000010fc0  00000000000005d0
00000fc8  0000000000010fc8  00000000000005d0
00000fd0  0000000000010fd0  0000000000010da0
00000fd8  0000000000010fd8  0000000000000000
00000fe0  0000000000010fe0  0000000000000000
00000fe8  0000000000010fe8  0000000000000000
00000ff0  0000000000010ff0  0000000000000754
00000ff8  0000000000010ff8  0000000000000000
```

**注意**：第一列 Offset 的十六进制串的 printf 格式化控制符为 `%s`，不要错误写成 `%08x`！

### 格式化字符串（sprintf）

`sprintf` 函数用提供的 format 和 variables 返回一个类似于 printf 格式输出的字符串。

```
    sprintf(fmt, expr, ... )
        the string resulting from formatting expr ...  according to the printf(3) format fmt
```
