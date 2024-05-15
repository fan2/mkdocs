---
title: Linux Command - utilities
authors:
  - xman
date:
    created: 2019-10-29T14:30:00
categories:
    - wiki
    - linux
comments: true
---

linux 下一些实用的小命令集锦。

<!-- more -->

## cd

cd（change directory）：切换文件目录。

- `cd` / `cd ~`：进入当前用户的家目录（$HOME）；  
- `cd ..`：返回上级目录；  
- `cd -`：返回上次访问目录（相当于 `cd $OLDPWD`），再次执行在近两次目录之间切换。  

切换到带有空格的路径，需要加转义字符（反斜杠<kbd>\\</kbd>）来标识空格。

以下示例从 `~/` 目录切换到 `/Library/Application Support/Sublime Text 3/Packages/User`：

```Shell
faner@FAN-MB0:~|⇒  cd /Users/faner/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
faner@FAN-MB0:~/Library/Application Support/Sublime Text 3/Packages/User|
⇒  
```

另外一种做法是定义 shell 字符串变量，然后使用 <kbd>$</kbd> 符号解引用变量作为 cd 的参数：

```Shell
faner@FAN-MB0:~|⇒  dir="/Users/faner/Library/Application Support/Sublime Text 3/Packages/User/"                    
faner@FAN-MB0:~|⇒  cd $dir
faner@FAN-MB0:~/Library/Application Support/Sublime Text 3/Packages/User|
```

### pushd & popd

`cd -` 可在近两次目录之间切换，当涉及3个以上的工作目录需要切换时，可以使用 pushd 和 popd 命令。

macOS 的 zsh 命令行输入 push 然后 tab 可以查看所有 push 相关命令：

```Shell
faner@MBP-FAN:~|⇒  push
pushd   pushdf  pushln
```

- 其中 **pushdf** 表示切换到当前 Finder 目录（`pushd` to the current Finder directory）。  
- 关于 **pushln** 可参考 zsh-manual [Shell Builtin Commands](http://bolyai.cs.elte.hu/zsh-manual/zsh_toc.html#TOC65) 中的说明。  

> 在 macOS 终端中执行 `man pushd` 或 `man popd` 可知，他们为 BASH 内置命令（Shell builtin commands）。

**`pushd`** 和 **`popd`** 可以用于在多个目录（directory）之间进行切换（push/pop）而无需复制并粘贴目录路径。 

`pushd` 和 `popd` 以栈的方式来运作，后进先出（Last In First Out, LIFO）。目录路径被存储在栈中，然后用 push 和 pop 操作在目录之间进行切换。

```Shell

# 执行 dirs -c 清理栈之后，只剩当前目录
faner@MBP-FAN:~|⇒  dirs
~

# 将 ~/Downloads 目录压栈
faner@MBP-FAN:~|⇒  pushd Downloads 
~/Downloads ~

# 将 ~/Documents 目录压栈
faner@MBP-FAN:~/Downloads|⇒  pushd ../Documents 
~/Documents ~/Downloads ~

# 依次执行 pushd ../Movies、pushd ../Pictures、pushd ../AppData、pushd ../Applications、pushd ../Desktop

# 将 ~/Music 目录压栈
faner@MBP-FAN:~/Desktop|⇒  pushd ../Music 
~/Music ~/Desktop ~/Applications ~/AppData ~/Pictures ~/Movies ~/Documents ~/Downloads ~
```

**`dirs`**：查看当前 Shell 窗口操作过的目录栈记录，索引0表示栈顶。

> `dirs [−clpv] [+n] [−n]` : Without options, displays the list of currently remembered directories.

 选项 | 含义
-----|------
-p  | 每行显示一条记录
-v  | 每行显示一条记录，同时展示该记录在栈中的index
-c  | 清空目录栈

```Shell
# 查看当前栈，0为栈顶，8为栈底
faner@MBP-FAN:~/Music|⇒  dirs -v
0   ~/Music
1   ~/Desktop
2   ~/Applications
3   ~/AppData
4   ~/Pictures
5   ~/Movies
6   ~/Documents
7   ~/Downloads
8   ~
```

- 不带参数输入 **pushd** 会将栈顶目录和下一目录对调，相当于 `cd -` 的效果。  

	> pushd 还可以带索引选项 +n，**切换**到当前栈中从栈底开始计数的某个目录。

- 不带参数输入 **popd** 会移除栈顶（当前）目录，切换到上一次访问的目录。  

	> popd 还可以带索引选项 +n，移除当前栈中从栈底开始计数的某个目录。

对于 `pushd +n` 和 `popd +n`，索引顺序与 `dirs -v` 相反，从栈底开始计数；  
反过来 `pushd -n` 和 `popd -n` 索引顺序与 `dirs -v` 相同，从栈顶开始计数。

```Shell
# 从栈底（索引为0）右往左数第3个目录 ~/Movies 重新压入栈顶，相当于切换到该目录
faner@MBP-FAN:~/Music|⇒  pushd +3
~/Movies ~/Documents ~/Downloads ~ ~/Music ~/Desktop ~/Applications ~/AppData ~/Pictures

# 从栈顶（索引为-0）左往右数第3个目录 ~ 移除出栈
faner@MBP-FAN:~/Movies|⇒  popd -3
~/Movies ~/Documents ~/Downloads ~/Music ~/Desktop ~/Applications ~/AppData ~/Pictures

# 从栈顶（索引为-0）左往右数第3个目录 ~/Music 重新压入栈顶，相当于切换到该目录
faner@MBP-FAN:~/Movies|⇒  pushd -3
~/Music ~/Desktop ~/Applications ~/AppData ~/Pictures ~/Movies ~/Documents ~/Downloads

# 从栈底（索引为0）右往左数第3个目录 ~/Pictures 移除出栈
faner@MBP-FAN:~/Music|⇒  popd +3
~/Music ~/Desktop ~/Applications ~/AppData ~/Movies ~/Documents ~/Downloads
```

[Linux中的pushd和popd](https://www.jianshu.com/p/53cccae3c443)  
[在命令行中使用pushd和popd进行快速定位](http://blog.sina.com.cn/s/blog_b6b704ef0102wjdk.html)  

### dirname & basename

dirname、basename 用于获取路径字符串的目录和文件部分。

```Shell
$ man basename
BASENAME(1)               BSD General Commands Manual              BASENAME(1)

NAME
     basename, dirname -- return filename or directory portion of pathname

SYNOPSIS
     basename string [suffix]
     basename [-a] [-s suffix] string [...]
     dirname string
```

[Linux中basename和dirname命令的妙用](https://blog.csdn.net/Jerry_1126/article/details/79872110)

典型应用场景：在sh脚本中，基于 dirname/basename 获取当前脚本的路径和名称。

```Shell
echo "dirname = $(dirname $0)"
echo "basename = $(basename $0)"
```

例如 [transfer.sh](https://transfer.sh/) 中，从第一个参数中基于 basename 提取纯文件名：

```Shell
        file="$1"
        file_name=$(basename "$file")
```

## printf

```Shell
$man bash

SHELL BUILTIN COMMANDS

printf [−v var] format [arguments]

Write the formatted arguments to the standard output under the control of the format. The format is a character string which contains three types of objects: plain characters, which are simply copied to standard output, character escape sequences, which are converted and copied to the standard output, and format speciﬁcations, each of which causes printing of the next successive argument. In addition to the standard printf(1) formats, %b causes printf to expand backslash escape sequences in the corresponding argument (except that \c terminates output, backslashes in \', \", and \? are not removed, and octal escapes beginning with \0 may contain up to four digits), and %q causes printf to output the corresponding argument in a format that can be reused as shell input.

The −v option causes the output to be assigned to the variable var rather than being printed to the standard output.

The format is reused as necessary to consume all of the arguments. If the format requires more arguments than are supplied, the extra format speciﬁcations behave as if a zero value or null string, as appropriate, had been supplied. The return value is zero on success, non-zero on failure.
```

- [Shell printf命令：格式化输出语句](https://wiki.jikexueyuan.com/project/shell-tutorial/shell-printf-command.html)  
- [Shell printf命令详解](https://www.cnblogs.com/machangwei-8/p/10354698.html)  
- [Bash Printf 命令](https://www.itcoder.tech/posts/bash-printf-command/)  

- [Bash's Built-in printf Function](https://www.linuxjournal.com/content/bashs-built-printf-function)  
- [Linux printf command](https://www.computerhope.com/unix/uprintf.htm)  
- [Bash Printf command](https://linuxhint.com/bash-printf-command/)  
- [Bash printf Command](https://linuxize.com/post/bash-printf-command/)  
- [Bash printf Function: 7 Examples for Linux](https://www.makeuseof.com/bash-printf-examples/)  

## head/tail

head/tail 命令支持查看文件(file)前/后指定字节(-c)或行数(-n)的内容。

```Shell
# macOS
$ man head
HEAD(1)                   BSD General Commands Manual                  HEAD(1)

NAME
     head -- display first lines of a file

SYNOPSIS
     head [-n count | -c bytes] [file ...]

$ man tail
TAIL(1)                   BSD General Commands Manual                  TAIL(1)

NAME
     tail -- display the last part of a file

SYNOPSIS
     tail [-F | -f | -r] [-q] [-b number | -c number | -n number] [file ...]
```

在 [bash_history](../manual/bash_history.md) 中，当过往输入历史接近 HISTSIZE 时，`history` 命令列表较长，不便翻阅。
此时，可通过管道命令导向 `head` / `tail` 筛选查看开头/结尾部分。

```Shell
# history日志条目按插入时间升序（从远到近）
# 查看最远10条输入命令记录：
$ history | head # 默认显示10条
$ history | head -n 10
# 查看最近10条输入命令记录：
$ history | tail # 默认显示10条
$ history | tail -n 10
```

下面通过 du 命令按占用磁盘空间大小降序列举某一目录下各个子目录。
当子目录太多时，可重定向给 `more` 滚动查看，或重定向给 `head` 查看前10条。

```Shell
$ du -csh ~/Library/Developer/* | sort -rh | head
```

在 Linux 下，head 的 -n 接负号数（-NUM）表示打印除末尾几行的开头部分。

```Shell
$ man head
       -n, --lines=[-]NUM
              print the first NUM lines instead of the first 10; with the leading
              '-', print all but the last NUM lines of each file
```

在 Linux 下，tail 的 -n 接正号数（+NUM）表示打印从第NUM行开头到尾部部分（即忽略前NUM-1行）。

```Shell
$ man tail
       -n, --lines=[+]NUM
              output  the  last NUM lines, instead of the last 10; or use -n +NUM
              to output starting with line NUM
```

在 Linux 下，如想打印除开头和结尾10行的中间部分可以执行：`head -n -10 file.txt | tail +11`。

在 macOS 下由于不支持以上特性，需要按照下面的步骤实现同等效果：

```Shell
# 先统计总行数
lines=$(wc -l file.txt | awk '{print $1}')
# 减去末尾10行，head显示开头部分
hl=$(expr $lines - 10)
# 再减去开头10行，tail显示末尾部分
tl=$(expr $hl - 10)
head -n $hl file.txt | tail -n $tl
```

`-f` 参数是 tail 命令的一个突出特性，它使该命令保持活动状态，支持监视文件追加变更，并实时显示追加到到文末的内容。
这是实时监测日志的绝妙方式，可以用来实时滚动显示日志文件最新的内容。

```Shell
# macOS/FreeBSD/Darwin
     -f      The -f option causes tail to not stop when end of file is reached, but rather to wait for addi-
             tional data to be appended to the input.  The -f option is ignored if the standard input is a
             pipe, but not if it is a FIFO.

# linux
       -f, --follow[={name|descriptor}]
              output appended data as the file grows;
              an absent option argument means 'descriptor'
```

以下用于实时滚动显示 nginx 最新访问日志：

```Shell
$ tail -f nginx-access.log
```

---

**sed**（`s`tream `ed`itor）意即流式编辑器，可轻松实现类似head/more的过滤文本显示。
当然也可借助sed指定正则匹配规则，过滤出某些行或某些有特殊起始格式的段落。

具体参考 [sed-basic.md](../../shell/sed-awk/sed/sed-basic.md) 中的示例。

以上想打印除开头和结尾10行的中间部分，也可先计算好中间部分的起始行号，再用sed过滤打印：

```Shell
# 先统计总行数
lines=$(wc -l file.txt | awk '{print $1}')
# 开始行号11
hl=11
# 减去末尾10行，得出结束行号
tl=$(expr $lines - 10)
# 注意不能用单引号(inhibit parameter expansion)！
sed -n "$hl, $tl p" file.txt
```

## du

关于磁盘统计涉及到两个命令：

- `df` (Disk FileSystem)  
- `du` (Disk Usage)  

```Shell
$ df -lh
Filesystem       Size   Used  Avail Capacity iused      ifree %iused  Mounted on
/dev/disk1s1s1  466Gi   15Gi   16Gi    48%  567381 4882909539    0%   /
/dev/disk1s4    466Gi   12Gi   16Gi    42%       9 4883476911    0%   /System/Volumes/VM
/dev/disk1s2    466Gi  507Mi   16Gi     3%    2991 4883473929    0%   /System/Volumes/Preboot
/dev/disk1s6    466Gi  2.3Mi   16Gi     1%      17 4883476903    0%   /System/Volumes/Update
/dev/disk1s5    466Gi  422Gi   16Gi    97% 4976082 4878500838    0%   /System/Volumes/Data
```

[How to Get the Size of a Directory in Linux](https://linuxize.com/post/how-get-size-of-file-directory-linux/)  
[How To Find The Size Of A Directory In Linux](https://www.ostechnix.com/find-size-directory-linux/)  
[How to Get the Size of a Directory from Command Line](http://osxdaily.com/2017/03/09/get-size-directory-command-line/)  
[How do I get the size of a directory on the command line?](https://unix.stackexchange.com/questions/185764/how-do-i-get-the-size-of-a-directory-on-the-command-line)  
[3 Simple Ways to Get the Size of Directories in Linux](https://www.2daygeek.com/how-to-get-find-size-of-directory-folder-linux/)  

进入指定文件夹执行 `du`，列举指定目录下的文件及所有递归文件夹占用磁盘的大小。

```Shell
du ~/Documents
du ~/Library/Developer
du Pods
```

- 添加 `-l` 选项，仅显示本地文件系统，不包括 mount points；  
- 添加 `-T` 选项（`-Y` for macOS），打印出文件系统类型；  
- 添加 `-h` 选项，使输出的 fileSize 更易阅读；  
- 添加 `-s` 选项，相当于 `-d 0` 指定一级目录，不递归子目录；  
- 添加 `-c` 选项，最后会输出一条总占用大小；  

```Shell
$ du -sh ~/Documents
or
$ du -h -d 0 ~/Documents
$ du -h --max-depth=0 ~/Documents
```

统计目录 `~/Library/Developer` 占用磁盘空间大小：

```Shell
$ du -sh ~/Library/Developer
 66G	/Users/faner/Library/Developer
```

统计目录 `~/Library/Developer` 子目录占用磁盘空间大小：

```Shell
$ du -csh ~/Library/Developer/*
 23G	/Users/faner/Library/Developer/CoreSimulator
1.4G	/Users/faner/Library/Developer/XCTestDevices
 39G	/Users/faner/Library/Developer/Xcode
425M	/Users/faner/Library/Developer/chromium
2.2G	/Users/faner/Library/Developer/flutter
 66G	total
```

按占用磁盘空间降序（由大到小）排序：

```Shell
$ du -sh ~/Library/Developer/* | sort -rh
 39G	/Users/faner/Library/Developer/Xcode
 23G	/Users/faner/Library/Developer/CoreSimulator
2.2G	/Users/faner/Library/Developer/flutter
1.4G	/Users/faner/Library/Developer/XCTestDevices
425M	/Users/faner/Library/Developer/chromium
```

当子目录太多时，可重定向给 `more` 滚动查看，或重定向给 `head -n 10` 查看前10条。

列举 Pods 目录下所有的一级子目录（不递归）：

```Shell
ls -1 -d Pods/* | tee ~/Downloads/Pods-tree-L1.log
```

查看 Pods 目录下所有的一级子目录占用磁盘空间大小：

```Shell
du -csh Pods/* | more
du -csh Pods/* | tee ~/Downloads/Pods-tree-L1-du.log
ls -1 -d Pods/* | xargs du -chs | tee ~/Downloads/Pods-tree-L1-du.log
```

---

The `tree` command is a recursive directory listing program that produces a depth indented listing of files and directories in a tree-like format.

```Shell
tree --du -h /opt/ktube-media-downloader
```

## bc

[bc](https://www.gnu.org/software/bc/manual/html_mono/bc.html)(basic calculator) - An arbitrary precision calculator language  

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

### basic

1. 在 bash shell 终端输入 `bc` 即可启动 bc 计算器。

输入表达式 `56.8 + 77.7`，再按回车键即可在新行得到计算结果：

```Shell
pi@raspberrypi:~ $ bc
bc 1.06.95
Copyright 1991-1994, 1997, 1998, 2000, 2004, 2006 Free Software Foundation, Inc.
This is free software with ABSOLUTELY NO WARRANTY.
For details type `warranty'. 

56.8 + 77.7
134.5
```

也可书写代数表达式，用变量承载计算结果，作为进一步计算的操作数：

```Shell
$ bc -q # -q 不显示冗长的欢迎信息
a=2+3;
a
5
b=a*4;
b
20
```

2. 可通过 bc 内置的 **`scale`** 变量可指定浮点数计算输出精度：

```Shell
$ bc -q
5 * 7 /3
11
scale=2; 5 * 7 /3
11.66
```

3. 在终端可基于[数据流重定向或管道](https://www.cnblogs.com/mingcaoyouxin/p/4077264.html)作为 `bc` 的输入表达式：

```Shell
$ echo "56.8 + 77.7" | bc
134.5
```

### inline

对于简单的单行运算，可用 echo 重定向或内联重定向实现：

```Shell
$ bc <<< "56.8 + 77.7"
134.5
```

如果需要进行大量运算，在一个命令行中列出多个表达式就会有点麻烦。  
bc命令能识别输入重定向，允许你将一个文件重定向到bc命令来处理。  
但这同样会叫人头疼，因为你还得将表达式存放到文件中。  

最好的办法是使用内联输入重定向，它允许你直接在命令行中重定向数据。  
在shell脚本中，你可以将输出赋给一个变量。

```Shell
variable=$(bc << EOF
           options
           statements
           expressions
           EOF)
```

`EOF` 文本字符串标识了内联重定向数据的起止。

以下在终端测试这种用法：

```Shell
$ bc << EOF
heredoc> 56.8 + 77.7
heredoc> EOF
134.5
```

### script

在shell脚本中，可调用bash计算器帮助处理浮点运算。可以用命令替换运行bc命令，并将输出赋给一个变量。基本格式如下：

```Shell
variable=$(echo "options; expression" | bc)
```

第一部分 options 允许你设置变量。 如果你需要不止一个变量， 可以用分号将其分开。 expression参数定义了通过bc执行的数学表达式。

以下为在 shell scripts 调用 bc 对常量表达式做计算的示例:

```Shell
$ result=$(echo "scale=2; 5 * 7 /3;" | bc)
$ echo $result
11.66
```

以下为在 shell scripts 调用 bc 对变量表达式做计算的示例:

```Shell
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

```Shell
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

```Shell
$ chmod u+x test12.sh
$ ./test12.sh
The final answer for this mess is 2813.9882
```

**注意**：在bash计算器中创建的局部变量只在内部有效，不能在shell脚本中引用！

### last

**`last`**  (an  extension)  is a variable that has the value of the *last* printed number.

bc 内置的 **`last`** 变量代表上个表达式的计算结果，可将 last 变量作为后续表达式的操作数，进行二次计算：

```Shell
$ bc -q
2+3
5
last*4
20
```

### ibase/obase

默认输入和输出都是基于十进制：

```Shell
$ bc -q
ibase
10
obase
10
```

在 bc 命令解释器中输入 `ibase=10;obase=16;2017`，转换输出2017（十进制）的十六进制：

```Shell
ibase=10;obase=16;2017
7E1
```

或者 echo 分号相隔的表达式重定向作为 bc 的输入进行解释运行：

```Shell
$ echo "ibase=10;obase=16;2017" | bc
7E1
```

以下示例用 `bc` 计算器实现进制转换。

先将十进制转换成二进制：

```Shell
$ no=100
$ echo "obase=2;$no" | bc 
1100100
```

再将二进制转换回十进制

```Shell
$ no=1100100
$ echo "obase=10;ibase=2;$no" | bc
100
```

需要注意先写obase再写ibase，否则出错：

```Shell
$ no=1100100
$ echo "ibase=2;obase=10;$no" | bc
1100100
```

## Checksum

### cksum

cksum, sum -- display file checksums and block counts

### CRC32

crc32 - Perform a 32bit Cyclic Redundancy Check

计算从 [crx4chrome](https://www.crx4chrome.com/) 离线下载的 [Vimium CRX 1.60.3 for Chrome](https://www.crx4chrome.com/crx/731/)  插件的 crc32 校验和：

```Shell
faner@FAN-MB0:~/Downloads/crx|
⇒  crc32 dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx 
db950177
```

与官网给出的 CRC32 Checksum 值一致，则说明未被篡改，可放心安装。

### MD5

md5 -- calculate a message-digest fingerprint (checksum) for a file

md5 命令后的默认输入参数为文件名，也可通过 `-s` 选项指定计算字符串参数的MD5。

```Shell
     -s string
             Print a checksum of the given string.
```

计算从 [crx4chrome](https://www.crx4chrome.com/) 离线下载的 [Vimium CRX 1.60.3 for Chrome](https://www.crx4chrome.com/crx/731/)  插件的 MD5：

```Shell
faner@FAN-MB0:~/Downloads/crx|
⇒  md5 dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx 
MD5 (dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx) = c98057821ee3cede87d911ead832dcc1
```

与官网给出的 MD5 Checksum 值一致，则说明未被篡改，可放心安装。

---

计算下载到本地的 Vimium CRX 1.60.3 for Chrome 插件所在路径字符串的 MD5 值：

```Shell
faner@FAN-MB0:~/Downloads/crx|
⇒  md5 -s "/Users/faner/Downloads/crx/dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx" 
MD5 ("/Users/faner/Downloads/crx/dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx") = 2f6f9a98b561f995564793765c205a66
```

### SHA

shasum - Print or Check SHA Checksums

```Shell
SYNOPSIS
        Usage: shasum [OPTION]... [FILE]...
        Print or check SHA checksums.
        With no FILE, or when FILE is -, read standard input.

          -a, --algorithm   1 (default), 224, 256, 384, 512, 512224, 512256
          -b, --binary      read in binary mode
          -c, --check       read SHA sums from the FILEs and check them
          -t, --text        read in text mode (default)
```

When verifying SHA-512/224 or SHA-512/256 checksums, indicate the **algorithm** explicitly using the `-a` option, e.g.

`shasum -a 512224 -c checksumfile`

---

计算从 [crx4chrome](https://www.crx4chrome.com/) 离线下载的 [Vimium CRX 1.60.3 for Chrome](https://www.crx4chrome.com/crx/731/) 插件的 SHA-1：

```Shell
faner@FAN-MB0:~/Downloads/crx|
⇒  shasum dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx 
476c61437d3c34e38ed1ee15950d202ded0902c8  dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx
```

与官网给出的 SHA1 Checksum 值一致，则说明未被篡改，可放心安装。

---

[SHA1 vs SHA256](https://www.keycdn.com/support/sha1-vs-sha256)  
[Why use SHA256 instead of SHA1?](https://www.ibm.com/support/pages/why-use-sha256-instead-sha1)  
[Re-Hashed: The Difference Between SHA-1, SHA-2 and SHA-256 Hash Algorithms](https://www.thesslstore.com/blog/difference-sha-1-sha-2-sha-256-hash-algorithms/)  

## binhex

[Convert binary data to hexadecimal in a shell script](https://stackoverflow.com/questions/6292645/convert-binary-data-to-hexadecimal-in-a-shell-script)  
[Binary to hexadecimal and decimal in a shell script](https://unix.stackexchange.com/questions/65280/binary-to-hexadecimal-and-decimal-in-a-shell-script)  

[shell 编程进制转换](https://www.cnblogs.com/rykang/p/11880609.html)
[Linux Bash：进制间转换](https://juejin.cn/post/6844903952547315726)

第一种方式是基于 printf 函数格式化输出：

```Shell
# hexadecimal to decimal
$ printf '%d\n' 0x24
36
# decimal to hexadecimal
$ printf '%x\n' 36
24
```

第二种方式是基于 `$((...))` 表达式，将其他进制转换为十进制：

```Shell
# binary to decimal
$ echo "$((2#101010101))"
341
# binary to hexadecimal
$ printf '%x\n' "$((2#101010101))"
155
# hexadecimal to decimal
$ echo "$((16#FF))"
255
```

第三种方式是基于上文提到的bc计算器，实现任意进制间互转：

```Shell
# binary to decimal
$ echo 'obase=10;ibase=2;101010101' | bc
341
# decimal to hexadecimal
$ bc <<< 'obase=16;ibase=10;254'
FE
# hexadecimal to decimal
$ bc <<< 'obase=10;ibase=16;FE'
254
```

## hexdump

### od

Linux/Unix（macOS）下的命令行工具 `od` 可按指定进制格式查看文档：

```Shell
pi@raspberrypi:~ $ od --version
od (GNU coreutils) 8.26
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Jim Meyering.
```

```Shell
pi@raspberrypi:~ $ man od

NAME
       od - dump files in octal and other formats

SYNOPSIS
       od [OPTION]... [FILE]...
       od [-abcdfilosx]... [FILE] [[+]OFFSET[.][b]]
       od --traditional [OPTION]... [FILE] [[+]OFFSET[.][b] [+][LABEL][.][b]]
```

**`-A`**, --address-radix=RADIX

> output format for file offsets; RADIX is one of [doxn], for Decimal, Octal, Hex or None  
>> 输出左侧的地址格式，默认为 o（八进制），可指定为 x（十六进制）。   

**`-j`**, --skip-bytes=BYTES

> skip BYTES input bytes first（跳过开头指定长度的字节）

**`-N`**, --read-bytes=BYTES

> limit dump to BYTES input bytes（只 dump 转译指定长度的内容）

**`-t`**, --format=TYPE

> select output format or formats（dump 输出的级联复合格式：`[d|o|u|x][C|S|I|L|n]`）

- `[doux]` 可指定有符号十、八、无符号十、十六进制；  
- `[CSIL]` 可指定 sizeof(char)=1, sizeof(short)=2, sizeof(int)=4, sizeof(long)=8 作为 group_bytes_by_bits；或直接输入数字[1,2,4,8]。

- `a`：Named characters (ASCII)，打印可见 ASCII 字符。

***`-x`***: same as `-t x2`, select hexadecimal 2-byte units

>  默认 group_bytes_by_bits = 16，两个字节（shorts）为一组。  

---

以下示例 hex dump `tuple.h` 文件开头的64字节：

```Shell
# 等效 od -N 64 -A x -t xCa tuple.h
faner@MBP-FAN:~/Downloads|⇒  od -N 64 -A x -t x1a tuple.h
0000000    ef  bb  bf  0d  0a  23  70  72  61  67  6d  61  20  6f  6e  63
           ?   ?   ?  cr  nl   #   p   r   a   g   m   a  sp   o   n   c
0000010    65  0d  0a  0d  0a  6e  61  6d  65  73  70  61  63  65  20  41
           e  cr  nl  cr  nl   n   a   m   e   s   p   a   c   e  sp   A
0000020    73  79  6e  63  54  61  73  6b  0d  0a  7b  0d  0a  0d  0a  2f
           s   y   n   c   T   a   s   k  cr  nl   {  cr  nl  cr  nl   /
0000030    2f  20  e5  85  83  e7  bb  84  28  54  75  70  6c  65  29  e6
           /  sp   ?  85  83   ?   ?  84   (   T   u   p   l   e   )   ?
0000040
```

### xxd

还有一个od类似的命令行工具是xxd。

```Shell
XXD(1)                                                                                                XXD(1)



NAME
       xxd - make a hexdump or do the reverse.

SYNOPSIS
       xxd -h[elp]
       xxd [options] [infile [outfile]]
       xxd -r[evert] [options] [infile [outfile]]

DESCRIPTION
       xxd creates a hex dump of a given file or standard input.  It can also convert a hex dump back to its
       original binary form.  Like uuencode(1) and uudecode(1) it allows the transmission of binary data  in
       a  `mail-safe' ASCII representation, but has the advantage of decoding to standard output.  Moreover,
       it can be used to perform binary file patching.
```

[dstebila/bin2hex.sh](https://gist.github.com/dstebila/1731faaad1da66475db1)

```Shell
#!/bin/bash

# Read either the first argument or from stdin
cat "${1:-/dev/stdin}" | \
# Convert binary to hex using xxd in plain hexdump style
xxd -ps | \
# Put spaces between each pair of hex characters
sed -E 's/(..)/\1 /g' | \
# Merge lines
tr -d '\n'
```

### hexdump

Linux/Unix（macOS）下的命令行工具 `hexdump` 可按指定进制格式查看文档：

```Shell
pi@raspberrypi:~ $ man hexdump

NAME
     hexdump, hd — ASCII, decimal, hexadecimal, octal dump

SYNOPSIS
     hexdump [-bcCdovx] [-e format_string] [-f format_file] [-n length] [-s skip] file ...
     hd [-bcdovx] [-e format_string] [-f format_file] [-n length] [-s skip] file ...
```

**`-b`**      One-byte octal display.  
**`-c`**      One-byte character display.  
**`-C`**      Canonical hex+ASCII display.  
**`-d`**      Two-byte decimal display.  
**`-o`**      Two-byte octal display.  
**`-x`**      Two-byte hexadecimal display.  

**`-s`** offset: Skip offset bytes from the beginning of the input（跳过开头指定长度的字节）  
**`-n`** length: Interpret only length bytes of input（ 只 dump 转译指定长度的内容）  

---

可以 hexdump 出 UTF-8 编码的文本文件，通过开头3个字节来判断是否带BOM：

> 如果开头3个字节为 `ef bb bf`，则为带 BOM 编码；否则为不带 BOM 编码。

```Shell
# 等效 hexdump -C litetransfer.cpp | head -n 4
faner@MBP-FAN:~/Downloads|⇒  hexdump -n 64 -C tuple.h
00000000  ef bb bf 0d 0a 23 70 72  61 67 6d 61 20 6f 6e 63  |.....#pragma onc|
00000010  65 0d 0a 0d 0a 6e 61 6d  65 73 70 61 63 65 20 41  |e....namespace A|
00000020  73 79 6e 63 54 61 73 6b  0d 0a 7b 0d 0a 0d 0a 2f  |syncTask..{..../|
00000030  2f 20 e5 85 83 e7 bb 84  28 54 75 70 6c 65 29 e6  |/ ......(Tuple).|
00000040
```

### strings

```Shell
pi@raspberrypi:~ $ man strings

STRINGS(1)                          GNU Development Tools                          STRINGS(1)

NAME
       strings - print the strings of printable characters in files.

SYNOPSIS
       strings [-afovV] [-min-len]
               [-n min-len] [--bytes=min-len]
               [-t radix] [--radix=radix]
               [-e encoding] [--encoding=encoding]
               [-] [--all] [--print-file-name]
               [-T bfdname] [--target=bfdname]
               [-w] [--include-all-whitespace]
               [-s] [--output-separatorsep_string]
               [--help] [--version] file...

```

## 其他

### rev

```Shell
NAME
     rev -- reverse lines of a file

SYNOPSIS
     rev [file ...]

DESCRIPTION
     The rev utility copies the specified files to the standard output, reversing the order of characters in
     every line.  If no files are specified, the standard input is read.
```

```Shell
echo "Bash Shell" | rev
llehS hsaB
```

### fuser

```Shell
$ man fuser
NAME
       fuser - list process IDs of all processes that have one or more files open

SYNOPSIS
       fuser [ -cfu ] file ...
```

### lsof

```Shell
NAME
       lsof - list open files

SYNOPSIS
       lsof  [  -?abChlnNOPRtUvVX ] [ -A A ] [ -c c ] [ +c c ] [ +|-d d ] [ +|-D D ] [ +|-e s ] [ +|-E ] [ +|-f [cfgGn] ] [ -F [f] ] [ -g [s] ] [
       -i [i] ] [ -k k ] [ -K k ] [ +|-L [l] ] [ +|-m m ] [ +|-M ] [ -o [o] ] [ -p s ] [ +|-r [t[m<fmt>]] ] [ -s [p:s] ] [ -S [t] ] [ -T [t] ]  [
       -u s ] [ +|-w ] [ -x [fl] ] [ +|-X ] [ -z [z] ] [ -Z [Z] ] [ -- ] [names]
```

查找监听指定端口的进程PID：

```Shell
lsof -i :8010 | awk 'NR>1 {print $2}' | xargs kill -KILL
```

- [查看 Linux TCP Port 被哪隻程式(Process)佔用](https://blog.longwin.com.tw/2013/12/linux-port-process-check-2013/)  
- [Finding the PID of the Process Using a Specific Port](https://www.baeldung.com/linux/find-process-using-port)  
- [Linux Find Out Which Process Is Listening Upon a Port](https://www.cyberciti.biz/faq/what-process-has-open-linux-port/)  
- [3 Ways to Find Out Which Process Listening on a Particular Port](https://www.tecmint.com/find-out-which-process-listening-on-a-particular-port/)  

### jq

对于压缩/转义的 JSON 字符串，可以在以下网站进行格式化或解析转换。

- [JSON在线解析及格式化验证](https://www.json.cn/)：支持在线解析和压缩转义。
- [JSON解析格式化工具](https://www.sojson.com/)：支持校验/格式化、压缩/转义。
- [JSON格式化查看工具](https://www.baidufe.com/fehelper/json-format/index.html)：支持对 JSON 进行压缩，以及对压缩（转义）的JSON字符串进行还原。

macOS/Linux 下还可以安装 `jq` 命令行工具，将压缩/转义的json字符串转换为格式化的 JSON 对象。

[jq](https://stedolan.github.io/jq/) is a lightweight and flexible command-line JSON processor.

- [linux下jq的使用](https://www.cnblogs.com/haima/p/15135587.html)
- [给力的linux命令--jq简易教程](https://www.jianshu.com/p/6de3cfdbdb0e)
- [jq - 一个灵活的轻量级命令行JSON处理器](https://wangchujiang.com/linux-command/c/jq.html)

以下将压缩转义的json字符串格式化为JSON对象输出控制台并存储到 banner-exposure.json 文件。

```Shell
$ echo "{\"bizName\":\"yidian\",\"plat\":\"h5\",\"actionName\":\"banner\",\"actionType\":\"exposure\",\"extra\":{\"value\":{\"banner_id\":\"3303\",\"title\":\"体检季来了：你最关心的各种检查，这里都有\",\"index\":0}}}" | jq | tee banner-exposure.json
{
  "bizName": "yidian",
  "plat": "h5",
  "actionName": "banner",
  "actionType": "exposure",
  "extra": {
    "value": {
      "banner_id": "3303",
      "title": "体检季来了：你最关心的各种检查，这里都有",
      "index": 0
    }
  }
}
```

以下对 banner-exposure.json 文件中的内容压缩为一行输出。

```Shell
$ cat banner-exposure.json | jq -c .
{"bizName":"yidian","plat":"h5","actionName":"banner","actionType":"exposure","extra":{"value":{"banner_id":"3303","title":"体检季来了：你最关心的各种检查，这里都有","index":0}}}
```