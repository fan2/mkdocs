---
title: Linux Command - awk vars
authors:
  - xman
date:
    created: 2019-11-05T09:30:00
categories:
    - wiki
    - linux
tags:
    - awk
comments: true
---

Linux 下的 awk 命令中的变量。

<!-- more -->

## FS/OFS/RS

以下是控制格式相关的一些内置变量：

 变量        | 描述
------------|-----------------
FIELDWIDTHS | 由空格分隔的一列数字，<br>定义了每个数据字段确切宽度
RS          | 输入记录分隔符，默认为换行符
FS          | 输入字段分隔符，默认为空白字符
ORS         | 输出记录分隔符，默认为换行符
OFS         | 输出字段分隔符，默认为空格

以下打印 awk 默认的输入记录/字段分割符、输出记录/字段分割符：

```bash
$ awk 'BEGIN { printf "RS=\"%s\"\nFS=\"%s\"\nORS=\"%s\"\nOFS=\"%s\"\n", RS, FS, ORS, OFS }'
RS="
"
FS=" "
ORS="
"
OFS=" "
```

[Linux 中 awk 后面的 RS, ORS, FS, OFS 用法](https://www.cnblogs.com/xuaijun/p/7902757.html)  
[Explanation about awk command using ORS, NR, FS, RS](https://stackoverflow.com/questions/55997954/explanation-about-awk-command-using-ors-nr-fs-rs)  
[8 Powerful Awk Built-in Variables – FS, OFS, RS, ORS, NR, NF, FILENAME, FNR](https://www.thegeekstuff.com/2010/01/8-powerful-awk-built-in-variables-fs-ofs-rs-ors-nr-nf-filename-fnr/)  


### FS

在 [awk-basic](./awk-basic.md) 中讲过，可在执行 awk 命令时通过 `-F` 选项来指定域分割符。

默认 `FS` 非顶格空格或制表符，也可以自行指定其他字符（串）作为域分割符。

一般在 BEGIN 中指定 FS，实际上 `-F` 和 `FS` 支持[指定多个字符作为分割点](https://blog.csdn.net/hongchangfirst/article/details/25071937)。

> 例如 `-F '[()]'` 或 `FS='[()]'` 表示以左括号和右括号作为分割符。

macOS 下通过 `networksetup -listnetworkserviceorder` 命令可查看网络服务接口：

```bash
$ networksetup -listnetworkserviceorder
An asterisk (*) denotes that a network service is disabled.
(1) Wi-Fi
(Hardware Port: Wi-Fi, Device: en0)

(2) Bluetooth PAN
(Hardware Port: Bluetooth PAN, Device: en3)

(3) Thunderbolt Bridge
(Hardware Port: Thunderbolt Bridge, Device: bridge0)
```

如果提取无线网卡（Wi-Fi）的接口名称（en0）呢？

1. 定位起始边界标题行 `(1) Wi-Fi`，读取下一行；  
2. 括号内按逗号分割，读取第二部分 `Device: en0`；  
3. 对 `Device: en0` 提取后面的名称部分。  

执行过程分析如下：

- 管传第1个awk：界定结构化内容的起始边界行（标题包含序号和接口名）；  
- 管传第2个awk：指定三个分割符 `(`、`,`、`)`，进行多点切割；  
- 管传第3个awk：默认按空格分割，提取第二部分的设备名。  

```bash
# networksetup -listnetworkserviceorder | awk '/\([[:digit:]]+\) Wi-Fi/{getline; print}' | awk -F '[(,)]' '{print $3}' | awk '{print $2}'
$ networksetup -listnetworkserviceorder | awk '/\([[:digit:]]+\) Wi-Fi/{getline; print}' | awk 'BEGIN {FS="[(,)]"} {print $3}' | awk '{print $NF}'
```

### OFS

变量 FS 和 OFS 定义了 awk 如何处理数据流中的数据字段。

- 变量 `FS` 用来定义记录处理时的字段分割符；  
- 变量 `OFS` 用于定义 `print` 打印字段的分隔符。  

默认情况下，awk 将 `OFS` 设成一个空格，打印各字段以空格分隔。
执行命令 `print $1,$2,$3`，会看到输出 `field1 field2 field3`。

```bash
$ awk '{print $1, $2}' data2.txt
One line
Two lines
Three lines
```

可以通过 BEGIN 模块在 body 处理前预设 OFS：

```bash
$ awk 'BEGIN {OFS=", "} {print $1, $2}' awk-data2.txt
One, line
Two, lines
Three, lines
```

### FIELDWIDTH

在一些应用程序中，数据并没有使用字段分隔符，而是被放置在了记录中的特定列。
这种情况下，必须设定 `FIELDWIDTHS` 变量来匹配数据在记录中的 *位置*，按照列宽来分割各个域。

> 一旦设置了 FIELDWIDTH 变量，awk 就会忽略 FS 变量。

### RS

变量 RS 和 ORS 定义了 awk 程序如何分割/分隔数据流中的记录。
默认情况下，awk 将 RS 和 ORS 设为换行符（`\n`），即以行作为记录裁决单位。

更多的时候，你会在数据流中碰到占据多行的结构化信息。  
典型的例子是包含地址和电话号码的数据，其中地址和电话号码各占一行。

```bash
Riley Mullen
123 Main Street
Chicago, IL 60601
(312)555-1234
```

如果用默认的 FS 和 RS 变量值来读取这组数据，awk 就会把每行作为一条单独的记录来读取，并将记录中的空格当作字段分隔符。
但符合实际预期的解读是，每四行组成的结构化区块为一条完整的记录，每条记录中的每一行对应一个字段域。

结构化的记录之间留一个空白行相间，可以将 `RS` 变量设置成空字符串，将 `FS` 设置为换行符（`\n`）。
然后 awk 会把每个空白行当作一个记录分隔符，把文件中的每行当成一个字段。

data2 中有三条记录：

```bash
$ cat data2
Riley Mullen
123 Main Street
Chicago, IL 60601
(312)555-1234

Frank Williams
456 Oak Street
Indianapolis, IN 46201
(317)555-9876

Haley Snell
4231 Elm Street
Detroit, MI 48201
(313)555-4938
```

awk 提取姓名和电话号码打印输出：

```bash
$ awk 'BEGIN {RS=""; FS="\n"; OFS=": " } {print $1,$4}' data2
Riley Mullen: (312)555-1234
Frank Williams: (317)555-9876
Haley Snell: (313)555-4938
```

### demo

有时会遇到较长的单行文本，但包含固定的分隔符。

**例1**：按行打印输出 `ifconfig -l` 中的接口。

1. 输入字段分割符FS默认为空白字符，然后在BEGIN中指定输出字段分隔符OFS为换行，BODY部分for循环打印各个字段，即实现了按行打印记录。

```bash
ifconfig -l | awk 'BEGIN{OFS="\n"} { for (i=1; i<=NF; i++) print $i}'
```

2. 更简单的方案：指定记录分割符RS为空格，将接口列表按空格分割成多条记录，再按行打印记录（ORS默认即为换行）：

```bash
# 默认动作print可省
ifconfig -l | awk 'BEGIN{RS=" "} {print}'
```

**例2**：按行打印输出 `PATH` 中的环境变量（`print -l $PATH`）。

1. `-F` 指定以 `:` 作为字段分割符（FS），然后在BEGIN中指定输出字段分隔符OFS为换行，BODY部分for循环打印各个字段，即实现了按行打印记录。

```bash
echo $PATH | awk -F ':' 'BEGIN{OFS="\n"} { for (i=1; i<=NF; i++) print $i}'
```

2. 更简单的方案：指定输入记录分隔符RS为 `:`，将 PATH 环境变量按冒号分割成多条记录，再按行打印记录（ORS默认即为换行）：

```bash
# 默认动作print可省
echo $PATH | awk 'BEGIN{RS=":"} {print}'
```

**例3**：按行打印输出用户身份 id 和所属用户组 groups。

```bash
# 默认动作print可省
groups | awk 'BEGIN {RS=" ";} {print}'
groups `whoami` | awk 'BEGIN {RS=" ";} {print}'
id | awk 'BEGIN {RS=" ";} {print}'
id `whoami` | awk 'BEGIN {RS=" ";} {print}'
```

**例4**：局域网内的某台服务器（raspi-ubuntu）由于采用了DHCP，如何查找它的IP地址，以便进行SSH连接呢？

假设我们知道设备wifi接口（wlan0）的MAC地址是以 `dc:a6:32` 开头，那么在 SSH 客户端，可以通过 arp 查询该 MAC 地址对应的 IP。

```bash
$ arp -a | grep "dc:a6:32"
? (192.168.0.114) at dc:a6:32:**:**:** on en0 ifscope [ethernet]
```

实际上，arp 命令输出的 ARP 报文格式是固定的，括号中即为对应设备分配占用的 IP 地址。
那么，如何提取这个IP地址呢？

可以基于awk先基于左括号进行切割，然后再移除右括号及其后的内容：

```bash
# awk先分割左括号，再替换右括号后面为空
$ arp -na | grep "dc:a6:32" | awk -F '(' '{sub(/\).*/, "", $2);print$2}'
```

更简洁的思路是，基于左右括号两点切割，然后域 $2 即是中间的IP地址部分：

```bash
# awk -F 指定两个分割符
$ arp -na | grep "dc:a6:32" | awk -F '[()]' '{print$2}'
```

## NF/NR/FNR

当要在 awk 程序中跟踪数据字段和记录时，变量 FNR、NF 和 NR 用起来就非常方便。

 变量  | 描述
------|-----------------
`NF`  | number of fields in the current record
`NR`  | ordinal number of the current record
`FNR` | ordinal number of the current record in the current file

### NF

有时并不知道记录中到底有多少个数据字段，NF 变量存储了记录中域（字段）的个数。
可以 `$NF` 形式引用记录中最后一个字段，RS 例程中的电话号码字段（`$4`）也可以 `$NF` 形式引用。

[How to select only the first 10 rows in my AWK script](https://stackoverflow.com/questions/37097272/how-to-select-only-the-first-10-rows-in-my-awk-script)

上节示例中，BODY中的for循环，采用NF作为索引上限，打印各个字段：

```bash
ifconfig -l | awk 'BEGIN{OFS="\n"} { for (i=1; i<=NF; i++) print $i}'
```

### FNR

FNR 和 NR 变量虽然类似，但又略有不同。

- FNR 变量记录了当前文件中已处理过的记录条数；  
- NR 变量则记录着所有文件累计已处理过的记录条数。  

由于默认 `RS`="\n"，每条记录为自然行，记录数 `FNR` 也即当前文件游标所在的行数（从1开始计数）。

在以下示例中，awk 指定输入了两个相同的文件，脚本打印第一个字段，并输出 FNR 变量值，追踪 FNR 的动态变化。

```bash
$ cat data1
data11,data12,data13,data14,data15
data21,data22,data23,data24,data25
data31,data32,data33,data34,data35

$ awk 'BEGIN{FS=","} {print $1,"FNR="FNR}' data1 data1
data11 FNR=1
data21 FNR=2
data31 FNR=3
data11 FNR=1
data21 FNR=2
data31 FNR=3
```

**注意**：

1. 直接引用 FNR 变量，不需要加 `$` 引用。  
2. 当 awk 程序处理第二个文件时，`FNR` 值被设回了1。  

### NR

现在，让我们加上 `NR` 变量看看会输出什么。

```bash
$ awk 'BEGIN{FS=","} {print $1,"FNR="FNR,"NR="NR}' data1 data1
data11 FNR=1 NR=1
data21 FNR=2 NR=2
data31 FNR=3 NR=3
data11 FNR=1 NR=4
data21 FNR=2 NR=5
data31 FNR=3 NR=6
```

FNR 变量在 awk 处理第二个文件时被重置了，而 NR 变量则在处理第二个数据文件时继续计数。

1. 如果只输入一个文件时，FNR 和 NR 的值是相同的；  
2. 如果输入多个文件进行处理，FNR 会在处理完当前文件时重置复位；而 NR 则会继续累计，直到处理完所有的文件。  

在处理单文件或不需要多文件累计记录数时，建议使用 FNR。

ifconfig 过滤出的 inet（IP 地址）一般有两行，分别是 ipv6 和 ipv4。

```bash
wlan_dev='en0'
wlan_inet=$(ifconfig "$wlan_dev" | awk '/inet/{print $2}')
```

以下通过 awk 命令逐行遍历 `wlan_inet`，并将每一行 `$0` 保存到数组 `ip[]`。
最后，在 END 中逆序打印 inet 地址，即先打印 ipv4 再打印 ipv6。
print 在每个 `ip[i]` 前添加一个制表符 (`\t`) 控制输出格式。

```bash
echo "$wlan_inet" | awk '{ ip[NR] = $0 } END { for (i = NR; i >= 1; i--) { print "\t"ip[i] } }'
```

### line-range

以下示例，只打印 curl 返回的第一行信息，即 HTTP STATUS LINE：

```bash
# 方法一：NR==1 只显示第一行，默认动作print可省
curl -sI www.google.com | awk 'NR==1 {print $0}'
# 方法二：使用 head -n 1 等效实现
curl -sI www.google.com | head -n 1
```

以下示例，打印除第一行之外的所有行（记录）：

```bash
# 方法一：前置不符合条件略过
$ awk 'NR==1 { next; }' data2.txt
# 方法二：前置条件约束（省略默认动作）
$ awk 'NR>1' data2.txt
Two lines of test text.
Three lines of test text.
```

以下示例，只打印前两条记录：

```bash
# 方法一：前置条件约束
$ id `whoami` | awk 'BEGIN {RS=" ";} FNR<=2 {print}'

# 方法二：后置边界退出
$ id `whoami` | awk 'BEGIN {RS=" ";} {print} FNR==2{exit}'
```

以下示例，打印 pip3 列表中所有过期包的信息，略过前两行表头：

```bash
# 方法一：NR>2 从第3行开始
$ pip3 list --outdated | awk 'NR>2'
# 方法二：使用 tail -n +3 等效实现
$ pip3 list --outdated | tail -n +3
```

从过期包列表中提取出第一列包名，并使用 xargs 命令批量安装：

```bash
$ pip3 install -U $(pip3 list --outdated | awk 'NR>2 {print $1}')
$ pip3 list --outdated | awk 'NR>2 {print $1}' | xargs -n1 pip3 install -U
```

要打印出从 M 行到 N 行这个范围内的文本内容，可使用下面的语法：

```bash
$ awk 'FNR==M, FNR==N' filename
```

也可以用stdin作为输入：

```bash
$ cat filename | awk 'FNR==M, FNR==N'
```

只打印前两行，也可以指定 FNR 行号区间实现：

```bash
# 方法三：前置约束，限定NR区间，默认动作print可省
$ id `whoami` | awk 'BEGIN {RS=" ";} FNR==1, FNR==2 {print}'
```

以下筛选打印文件 grade.txt 的第2~4行：

```bash
$ awk 'FNR==2, FNR==4' grade.txt
J.Lulu      06/99   48317   green       9   24  26
P.Bunny     02/99   48      Yellow      12  35  28
J.Troll     07/99   4842    Brown-3     12  26  26
```

打印 CSV 文件第2到4行的第2个字段：

```bash
awk -F ',' 'FNR==2, FNR==4 {print $2}' issue_data-LineTooLong.csv
```

以下脚本使用模式过滤 `readelf -SW` 输出的 section entry，结尾 END 统计总行数（FNR）。
然后，基于 FNR 过滤输出限定范围行。

```bash
# count output lines between [Section Headers:, Key to Flags:]
secnum=$(readelf -SW a.out | awk '/Section Headers:/,/Key to Flags:/' | wc -l)
secnum=$(readelf -SW a.out | awk '/Section Headers:/,/Key to Flags:/' | awk 'END{print FNR}')
# discard first three prefix lines and the last suffix line
readelf -SW a.out | awk '/Section Headers:/,/Key to Flags:/' | awk "FNR==4, FNR==$((secnum-1))"
```

### csv-analyze

CSV（Comma-Separated Values）即逗号分割值，有时也称为字符分割值。
因为分割字符也可以不是逗号，其文件以纯文本形式存储表格数据（数字和文本）。

在 CSV 文本文件中，每条记录占一行，每一行以逗号作为为分割符，逗号前后的空格会被忽略。

[linux awk解析csv文件](https://www.cnblogs.com/htlee/p/4701961.html)  

读取CSV第1行即表头：

```bash
$ awk 'FNR==1' dependence.csv
SubModule,Header,Class,Method,Macro
```

读取所有记录的第1列：

```bash
awk -F ',' 'FNR>1{print $1}' dependence.csv
```

对第1列进行去重输出：

```bash
awk -F ',' 'FNR>1{print $1}' dependence.csv | uniq
```

对第1列进行合并统计和去重统计：

```bash
awk -F ',' 'FNR>1{print $1}' dependence.csv | uniq -c
awk -F ',' 'FNR>1{print $1}' dependence.csv | uniq | wc -l
```

## user-defined

跟其他典型的编程语言一样，awk 允许自定义变量在程序代码中使用。  
awk 自定义变量名可以是任意数目的字母、数字和下划线，但不能以数字开头，且区分大小写。  

### assign var

在 awk 中直接引用 shell 上下文的变量报错：

```bash
$ test="cat"
$ sentence="The cat sat on the mat"
$ awk 'BEGIN {print index($sentence, $test)}'
awk: illegal field $(), name "sentence"
 source line number 1
```

可通过 `-v` 选项将 shell 变量赋值给 awk 内部变量，再引用。

```bash
$ index=`awk -v a="$sentence" -v b="$test" 'BEGIN{print index(a,b)}'`
$ echo $index
5
```

假设 pattern 为 shell 变量：`ifip='inet'`，则需要将通过 `-v` 注入 pattern 参数，然后使用原始的 `$0 ~ /pattern/` 匹配表达式。

```bash
wlan_dev='en0'
ifip='inet'
wlan_inet=$(ifconfig "$wlan_dev" | awk -v pattern="$ifip" '$0 ~ pattern {print $2}')
```

除了使用 `-v` 选项在 body 之前前置传递变量，也可以在 body 之后后置传递变量：

```bash
wlan_dev='en0'
ifip='inet'
wlan_inet=$(ifconfig "$wlan_dev" | awk '$0 ~ pattern {print $2}' pattern="$ifip")
```

### local var

在 awk 程序脚本中给变量赋值和在 shell 脚本中赋值类似，都用赋值语句。

```bash
$ awk 'BEGIN{testing="This is a test"; print testing}'
This is a test

$ awk 'BEGIN{x=4; x= x * 2 + 3; print x}'
11
```

> awk 引用内部变量和 C 语言相似，不用 `$` 符号。

也可以用 awk 命令行来给程序中的变量赋值，这允许你在正常的代码之外赋值，即时改变变量的值。

### cmd var

以下示例使用命令行变量传参，来显示文件中特定数据字段。

```bash
$ cat script1.awk
BEGIN{FS=","}
{print $n}

$ awk -f script1.awk n=2 data1
data12
data22
data32

$ awk -f script1.awk n=3 data1
data13
data23
data33
```

但是，使用命令行参数来定义变量值会有一个问题，命令行传参其值在 BEGIN 部分不可用。

```bash
$ cat script2.awk
BEGIN{print "The starting value is",n; FS=","}
{print $n}

$ awk -f script2.awk n=3 data1
The starting value is
data13
data23
data33
```

可以用 `-v` 命令行参数来解决这个问题。它允许在 BEGIN 代码之前设定变量。  
在命令行上，`-v` 命令行参数必须放在脚本代码之前。

```bash
$ awk -v n=3 -f script2.awk data1
The starting value is 3
data13
data23
data33
```

### array

for 语句会在每次循环时将关联数组array的下一个索引值赋给变量var，然后执行一遍statements。

**注意**：

1. 这个变量中存储的是 *索引值* 而不是数组元素值；  
2. 索引值不会按任何特定顺序返回，只能保证索引值和数据值的对应关系；  

```bash
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
Index: g  - Value: 2
Index: m  - Value: 3
Index: u  - Value: 4
Index: a  - Value: 1
```

这里的“数组”，更像是“字典”的概念。索引为字符串，并非整数。

```bash
$ awk 'BEGIN{
    STR="mydoc.txt"
    print split(STR,components,".")
    print "prefix="components["1"]
    print "suffix="components["2"]
}'
2
prefix=mydoc
suffix=txt
```

#### delete

从关联数组中删除数组索引要用一个特殊的命令。

```bash
delete array[index]
```

删除命令会从数组中删除关联索引值和相关的数据元素值。

```bash
$ awk 'BEGIN{
    var["a"] = 1
    var["g"] = 2
    var["m"] = 3
    var["u"] = 4
    for (test in var)
    {
        print "Index:",test," - Value:",var[test]
    }

    delete var["g"]

    print "---"
    for (test in var)
    {
        print "Index:",test," - Value:",var[test]
    }
}'
Index: g  - Value: 2
Index: m  - Value: 3
Index: u  - Value: 4
Index: a  - Value: 1
---
Index: m  - Value: 3
Index: u  - Value: 4
Index: a  - Value: 1
```
