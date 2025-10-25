---
title: Linux Command - sed NDP
authors:
  - xman
date:
    created: 2019-11-04T11:30:00
categories:
    - wiki
    - linux
tags:
    - sed
comments: true
---

Linux 下的 sed 命令进阶操作 —— NDP。

<!-- more -->

## next

### n

`n` 命令让 sed 编辑器移动到指定行或模式匹配行的下一行（相当于略过一行），再执行操作。

> 对照 awk 中的 `getline` 函数。

```bash
$ cat data2.txt
This is the header line.
This is the first data line.
This is the second data line.
This is the last line.

# sed '/header/{n ; d}' data2.txt
$ sed '/header/{n;d
quote> }' data2.txt
This is the header line.
This is the second data line.
This is the last line.
```

### N

单行 next 命令会将数据流中的下一文本行移动到 sed 编辑器的工作空间（称为 `模式空间`）。

多行版的 next 命令（N）会将下一文本行添加到模式空间中已有的文本后。

以下示例中，sed 编辑器脚本查找包含单词 `first` 的行，然后将下一行合并到同一模式空间中，执行替换操作。
将换行符替换为空格，实现合并行的效果。

```bash
$ sed '/first/{ N ; s/\n/ / }' data2.txt
sed: 1: "/first/{ N ; s/\n/ / }": bad flag in substitute command: '}'

$ sed '/first/{N ; s/\n/ /
quote> }' data2.txt
This is the header line.
This is the first data line. This is the second data line.
This is the last line.
```

以下命令，查找特定双词短语 `System Administrator` 并执行替换。

```bash
$ cat data3.txt
On Tuesday, the Linux System
Administrator's group meeting will be held.
All System Administrators should attend.
Thank you for your attendance.

$ sed 's/System Administrator/Desktop User/' data3.txt
On Tuesday, the Linux System
Administrator's group meeting will be held.
All Desktop Users should attend.
Thank you for your attendance.
```

但对于双词短语分散在两行的情形，替换命令就无法识别匹配的模式了。
这时，`N` 命令就派上用场了。

sed 编辑器发现第一个单词的那行和下一行合并后，即使短语内出现了换行，仍然可以找到它。  
以下示例中，替换命令在 System 和 Administrator 之间用了通配符（`.`），可匹配空格和换行符这两种情况，从而实现跨行匹配替换。

```bash
$ sed 'N ; s/System.Administrator/Desktop User/' data3.txt
On Tuesday, the Linux Desktop User's group meeting will be held.
All Desktop Users should attend.
Thank you for your attendance.
```

但是，有个非预期效果：匹配到换行符时，从字符串中删掉了换行符，导致两行合并为一行。  
要解决以上问题，可以在 sed 编辑器脚本中用2条替换命令，分别匹配短语出现在多行/单行中的情况。

```bash
# macOS
$ sed 'N
quote> s/System\nAdministrator/Desktop\nUser/
quote> s/System Administrator/Desktop User/
quote> ' data3.txt
On Tuesday, the Linux DesktopnUser's group meeting will be held.
All Desktop Users should attend.
Thank you for your attendance.

# raspberrypi
$ sed 'N
quote> s/System\nAdministrator/Desktop\nUser/
quote> s/System Administrator/Desktop User/
quote> ' data3.txt
On Tuesday, the Linux Desktop
User's group meeting will be held.
All Desktop Users should attend.
Thank you for your attendance.
```

> macOS 下依然不行！？

以上仍有一个小问题，总是在执行 sed 编辑器命令前将下一行文本读入到模式空间。
当它到了最后一行文本时，就没有下一行可读了，从而停止执行。  
如果要匹配的文本刚好在最后一行，则N命令会错过。

```bash
$ cat data4.txt
On Tuesday, the Linux System
Administrator's group meeting will be held.
All System Administrators should attend.
```

```bash
# raspberrypi
$ sed 'N
quote> s/System\nAdministrator/Desktop\nUser/
quote> s/System Administrator/Desktop User/
quote> ' data4.txt
On Tuesday, the Linux Desktop
User's group meeting will be held.
All System Administrators should attend.
```

这个问题可以将单行命令放到N命令前面来解决。

```bash
# raspberrypi
$ sed '
quote> s/System Administrator/Desktop User/
quote> N
quote> s/System\nAdministrator/Desktop\nUser/
quote> ' data4.txt
On Tuesday, the Linux Desktop
User's group meeting will be held.
All Desktop Users should attend.
```

现在，查找单行中短语的替换命令在数据流的最后一行也能正常工作了。

## D

sed 编辑器用 `d` 命令来执行单行删除。  
但当 d 命令和 N 命令一起使用时，可能非预期地删除模式空间的跨两行。  

```bash
# raspberrypi
$ sed 'N ; /System\nAdministrator/d' data4.txt
All System Administrators should attend.
```

如果只想删除模式空间中的第一行，可使用多行删除命令 `D`。  

```bash
$ sed 'N ; /System\nAdministrator/D' data4.txt
Administrator's group meeting will be held.
All System Administrators should attend.
```

以下示例，对于空行及其下一行组成的模式空间中匹配到 header，删除空行。

```bash
# raspberrypi

$ cat data5.txt

This is the header line.
This is a data line.

This is the last line.

$ sed '/^$/{N ; /header/D}' data5.txt
This is the header line.
This is a data line.

This is the last line.

```

## P

sed 编辑器用 `p` 命令来执行单行打印。  
但当 p 命令和 N 命令一起使用时，可能非预期地打印模式空间的跨两行。  

```bash
$ sed -n 'N ; /System\nAdministrator/p' data3.txt
On Tuesday, the Linux System
Administrator's group meeting will be held.
```

如果只想打印多行模式空间中的第一行，可以选用 `P` 命令。

```bash
$ sed -n 'N ; /System\nAdministrator/P' data3.txt
On Tuesday, the Linux System
```

## hg

**模式空间**（pattern space）是一块活跃的缓冲区，在sed编辑器执行命令时，它会保存待检查的文本。

sed编辑器还提供另一块称做 **保持空间**（hold space）的缓存区，在处理模式空间中的某些行时，可以用保持空间来临时保存一些行。

有以下5条命令，由于在模式空间和保持空间之间交换：

命令   | 描述
------|----------
 `h`  | 将模式空间复制到保持空间
 `H`  | 将模式空间附加到保持空间
 `g`  | 将保持空间复制到模式空间
 `G`  | 将保持空间附加到模式空间
 `x`  | 交换模式空间和保持空间的内容

```bash
$ sed -n '/first/{h;p;n;p;g;p}' data2.txt
sed: 1: "/first/{h;p;n;p;g;p}": extra characters at the end of p command

$ sed -n '/first/{h;p;n;p;g;p
quote> }' data2.txt
This is the first data line.
This is the second data line.
This is the first data line.
```

- `h;p` : copy first to hold  
- `n;p` : next line(second)  
- `g;p` : restore from hold  

通过使用保持空间移动行来辗转腾挪，可以满足一些特殊的编辑需求。
可以强制输出中的第一个数据行出现在第二个数据行后面。
去掉第一个p命令，可以实现相反的顺序输出这两行。

```bash
$ sed -n '/first/{h;n;p;g;p}' data2.txt
sed: 1: "/first/{h;n;p;g;p}": extra characters at the end of p command

sed -n '/first/{h;n;p;g;p
quote> }' data2.txt
This is the second data line.
This is the first data line.
```

- `h`   : copy first to hold  
- `n;p` : next line(second)  
- `g;p` : restore from hold  

你甚至可以结合这些方法实现将整个文件的文本行反转（Permute Lines: Reverse）。

## !

感叹号命令（`!`）用来排除（negate）命令，也就是让原本会起作用的命令不起作用。

加了感叹号之后，匹配的部分不执行p命令，不匹配的部分执行p命令打印。

```bash
$ sed -n '/header/!p' data2.txt
This is the first data line.
This is the second data line.
This is the last line.
```

在N命令捆绑下一行到模式空间的例子中，如果要匹配的文本刚好在最后一行，则N命令会错过。
除了上面给出的先匹配单行的方案外，也可以用感叹号排除最后一行捆绑来解决这个问题。

```bash
# raspberrypi
$ sed '$!N
quote> s/System\nAdministrator/Desktop\nUser/
quote> s/System Administrator/Desktop User/
quote> ' data4.txt
On Tuesday, the Linux Desktop
User's group meeting will be held.
All Desktop Users should attend.
```

对最后一行，不执行N命令，针对单行操作。

### tac

下面，我们来对文本实现行逆转（linux 中的 tac) 功能。

```bash
$ cat data2.txt
This is the header line.
This is the first data line.
This is the second data line.
This is the last line.

$ tac data2.txt
This is the last line.
This is the second data line.
This is the first data line.
This is the header line.
```

以下为基于 sed 的 tac 等效实现：

```bash
$ sed -n '{1!G; h; $p}' data2.txt
This is the last line.
This is the second data line.
This is the first data line.
This is the header line.
```

1. 第1行不执行 `G` 命令，执行 `h` 将模式空间复制到保持空间；  
2. 第2行至最后一行执行 `G` 指令，将保持空间附加到模式空间（当前行），形成逆序；再执行 `h` 指令；  
3. 执行到最后一行，将模式空间中的整个数据流都按行反转了之后，当达到数据流中的最后一行时，打印模式空间整个数据流。  

line 1: `h` - copy pattern space to hold space

- hold space = 1st line

line 2: `G` - append hold space to pattern space; `h` - copy pattern space to hold space

- pattern space = 2nd line; 1st line
- hold space = 2nd line; 1st line

line 3: `G` - append hold space to pattern space; `h` - copy pattern space to hold space

- pattern space = 3nd line; 2nd line; 1st line
- hold space = 3nd line; 2nd line; 1st line

## refs

[How to use the Linux sed command](https://opensource.com/article/21/3/sed-cheat-sheet) - [使用 sed 命令进行复制、剪切和粘贴](https://linux.cn/article-13417-1.html)