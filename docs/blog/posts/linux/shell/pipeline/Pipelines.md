---
title: Linux Pipeline（管道）
authors:
  - xman
date:
    created: 2019-11-01T10:00:00
    updated: 2026-01-23T19:00:00
categories:
    - wiki
    - linux
tags:
    - pipeline
    - tee
    - wc
    - cut
    - tr
    - xargs
comments: true
---

参考 BASH(1) manual page 的 `SHELL GRAMMAR > Pipelines` 部分。

<!-- more -->

## |

A `pipeline` is a sequence of one or more commands separated by one of the control operators `|` or `|&`. The format for a pipeline is:

```bash
[time [-p]] [ ! ] command [ [|⎪|&] command2 ... ]
```

The standard output of *`command`* is connected via a pipe to the standard input of *`command2`*.  
If **`|&`** is used, *`command`*'s standard error, in addition to its standard output, is connected to *`command2`*'s standard input through the pipe; it is shorthand for `2>&1 |`.  

管道被放在命令之间，将一个命令的输出重定向到另一个命令中：

```bash
command1 | command2
```

不要以为由管道串起的两个命令会依次执行。Linux系统实际上会同时运行这两个命令，在系统内部将它们连接起来。在第一个命令产生输出的同时，输出会被立即送给第二个命令，数据传输不会用到任何中间文件或缓冲区。

管道分隔界定符是 `|`，默认只将上一个命令的stdout输出作为下一个命令的stdin输入，不包括stderr。采用 `|&` 管传，则同时传入上一个命令的stdout和stderr输出，相当于 `2>&1 |`。

当命令输出较多时，为了避免滚动超出，可以导向给 more 或 less 翻页查看，例如 `ls -al /etc | less`。

cat命令不仅可以读取文件、拼接数据，还支持从标准输入中进行读取。以下脚本将ls的输出传给 `cat -n`，后者接收stdin输入并将内容加上行号，输出重定向到文件out.txt。

```bash
ls | cat -n > out.txt
```

终端通过 curl 从 github 下载安装流行的 Zsh 配置 [Oh My ZSH](https://ohmyz.sh/#install)：

```bash
# curl
$ sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
## 或者
$ curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh -c
```

以下脚本下载 [Homebrew](https://docs.brew.sh/) 安装包tarball，基于 `&&` 递进执行创建目录和下载文件。
下载完成后，将下载的压缩包（本地存储的文件路径）重定向给 tar 进行解压。

```bash
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
```

以下是来自 stackoverflow 上 [Amir Mehler](https://stackoverflow.com/a/22671136) 对问题 [How to read from a file or standard input in Bash](https://stackoverflow.com/questions/6980090/how-to-read-from-a-file-or-standard-input-in-bash) 的回答。

```bash
$ cat reader.sh
#!/bin/bash
while read line; do
  echo "reading: ${line}"
done < /dev/stdin

$ cat writer.sh
#!/bin/bash
for i in {0..5}; do
  echo "line ${i}"
done
```

该案例直观阐述了管道的运行机制：

```bash
$ ./writer.sh | ./reader.sh
reading: line 0
reading: line 1
reading: line 2
reading: line 3
reading: line 4
reading: line 5
```

## tee

如果对stderr或stdout进行重定向，被重定向的文本会传入文件。
因为文本已经被重定向到文件中，也就没剩下什么东西可以通过管道传给后续命令。
有一种方法既可以将数据重定向到文件，还可以提供一份重定向数据的副本作为后续命令的stdin。

双向重定向命令 `tee` 通过管道连接前后，可实现这个目标：`command1 | tee FILE | command2`。

1. command1的stdout输出管传作为tee命令的stdin输入；
2. tee将接收的数据(stdin输入)重定向到文件FILE，同时复制一份到stdout输出；
3. tee将产生的stdout输出再通过管道传递给后续命令，command2以此作为stdin输入继续处理。

tee 默认重定向是 `>` 会清空覆写已有文件，如果不想覆写而是追加，可以指定 `-a` 等效 `>>`。

> `-a`: Append the output to the files rather than overwriting(default).

```bash
# 将 ls -l 结果追加到文件，同时输出到控制台用more分页显示。
faner@MBP-FAN:~|⇒  ls -l / | tee -a ~/homefile | more
```

执行 `shadowsocks.sh` 脚本安装 shadowsocks 时，将执行的 stdout 和 stderr 输出既在控制台显示，同时写入日志文件 shadowsocks.log，方便后续回看。

```bash
./shadowsocks.sh |& tee shadowsocks.log # or
./shadowsocks.sh 2>&1 | tee shadowsocks.log
```

## wc,sort,uniq

### wc

**wc** - print newline, word, and byte counts for each file

```bash
-c, --bytes
      print the byte counts

-m, --chars
      print the character counts

-w, --words
      print the word counts

-l, --lines
      print the newline counts
```

统计 Podfile 文件的行数：

```
$ wc -l Podfile
     879 Podfile
```

统计 Podfile 文件的行数和字节数：

```
$ wc -lc Podfile
     879   38508 Podfile
```

how count all lines in all files in current dir and omit empty lines with wc, grep, cut and bc commands

```bash
echo `wc -l * | grep total | cut -f2 -d’ ‘` – `grep -in “^$” * | wc -l ` | bc
```

### sort

**sort** - sort lines of text files

### uniq

**uniq** - report or omit repeated lines

统计 `mars/mars/stn/src` 目录下类数（同名的 h/cc）

```bash
faner@MBP-FAN:~/Projects/git/framework/mars/mars/stn/src|master⚡ 
⇒  ls | cut -d '.' -f 1 | uniq -c
   2 anti_avalanche
   2 dynamic_timeout
   2 flow_limit
   2 frequency_limit
   2 longlink
   2 longlink_connect_monitor
   2 longlink_identify_checker
   2 longlink_speed_test
   2 longlink_task_manager
   2 net_channel_factory
   2 net_check_logic
   2 net_core
   2 net_source
   2 netsource_timercheck
   2 proxy_test
   2 shortlink
   1 shortlink_interface
   2 shortlink_task_manager
   2 signalling_keeper
   2 simple_ipport_sort
   2 smart_heartbeat
   1 special_ini
   1 task_profile
   2 timing_sync
   2 zombie_task_manager
```

## cut

`cut` 命令可基于索引或分隔符（separator/delimiter）将文件或stdin文本行内数据进行切割提取，获取所需的信息域。

在 macOS 终端执行 cut 将显示 usage 简要说明，执行 `man cut` 可查看详细帮助手册（Manual Page）：

```bash
faner@MBP-FAN $ man cut
CUT(1)                    BSD General Commands Manual                   CUT(1)

NAME
     cut -- cut out selected portions of each line of a file

SYNOPSIS
     cut -b list [-n] [file ...]
     cut -c list [file ...]
     cut -f list [-d delim] [-s] [file ...]

DESCRIPTION
     The cut utility cuts out selected portions of each line (as specified by list) from each file and
     writes them to the standard output.  If no file arguments are specified, or a file argument is a single
     dash (`-'), cut reads from the standard input.  The items specified by list can be in terms of column
     position or in terms of fields delimited by a special character.  Column numbering starts from 1.

     The list option argument is a comma or whitespace separated set of numbers and/or number ranges.  Num-
     ber ranges consist of a number, a dash (`-'), and a second number and select the fields or columns from
     the first number to the second, inclusive.  Numbers or number ranges may be preceded by a dash, which
     selects all fields or columns from 1 to the last number.  Numbers or number ranges may be followed by a
     dash, which selects all fields or columns from the last number to the end of the line.  Numbers and
     number ranges may be repeated, overlapping, and in any order.  If a field or column is specified multi-
     ple times, it will appear only once in the output.  It is not an error to select fields or columns not
     present in the input line.

     The options are as follows:

     -b list
             The list specifies byte positions.

     -c list
             The list specifies character positions.

     -d delim
             Use delim as the field delimiter character instead of the tab character.

     -f list
             The list specifies fields, separated in the input by the field delimiter character (see the -d
             option.)  Output fields are separated by a single occurrence of the field delimiter character.

     -n      Do not split multi-byte characters.  Characters will only be output if at least one byte is
             selected, and, after a prefix of zero or more unselected bytes, the rest of the bytes that form
             the character are selected.

     -s      Suppress lines with no field delimiter characters.  Unless specified, lines with no delimiters
             are passed through unmodified.
```

### bytes

`-b`, --bytes=LIST：select only these bytes，按二进制解析处理，提取指定索引的字节。

```bash
# 提取第4个字节
faner@MBP-FAN $ echo "/usr/local/bin" | cut -b 4
r
# 提取开头（第1个）至第4个字节
faner@MBP-FAN $ echo "/usr/local/bin" | cut -b -4
/usr
# 提取第2个、第6个这两个字节
faner@MBP-FAN $ echo "/usr/local/bin" | cut -b 2,6
ul
# 提取第6个至末尾的字节
faner@MBP-FAN $ echo "/usr/local/bin" | cut -b 6-
local/bin
```

### characters

对于英语 ASCII 码，一个字符占一个字节，对于 CJK 等多字符集，一个字符的Unicode编码占用2~4个字节。
如果以可视字符作为索引定位，则需要改用 `-c` 选项。

`-c`, --characters=LIST：select only these characters

对于混合了字母和汉字的字符串 `w我m们d的a爱`，当其按照 `-b` 索引时，第二个`我`字占据第2~4个字节位置。

```bash
faner@MBP-FAN $ echo "w我m们d的a爱" | cut -b 1
w
faner@MBP-FAN $ echo "w我m们d的a爱" | cut -b 2
�
faner@MBP-FAN $ echo "w我m们d的a爱" | cut -b 2,3
�
faner@MBP-FAN $ echo "w我m们d的a爱" | cut -b 2,3,4
我
faner@MBP-FAN $ echo "w我m们d的a爱" | cut -b 2,3,4,5
我m
```

可以通过 `hexdump` 或 `od` 查看其二进制编码，可见这几个汉字每个占据3个字节。

```bash
faner@MBP-FAN $ echo "w我m们d的a爱" | hexdump -C
00000000  77 e6 88 91 6d e4 bb ac  64 e7 9a 84 61 e7 88 b1  |w...m...d...a...|
00000010  0a                                                |.|
00000011
faner@MBP-FAN $ echo "w我m们d的a爱" | od -N 18 -A x -t xCa
0000000    77  e6  88  91  6d  e4  bb  ac  64  e7  9a  84  61  e7  88  b1
           w   �  88  91   m   �   �   �   d   �  9a  84   a   �  88   �
0000010    0a
          nl
0000011
```

通常，使用 `-c` 选项，按照可视字符定位提取的场景更多一点。

```bash
# 提取第2个字符
faner@MBP-FAN $ echo "w我m们d的a爱" | cut -c 2
我
# 提取第2个和第3个字符
faner@MBP-FAN $ echo "w我m们d的a爱" | cut -c 2,3
我m
```

export 声明变量排列整齐，可据此以字符为单位提取固定字符位置区间：

```bash
# 获取 export 前4条
pi@raspberrypi:~ $ export | head -n 4
declare -x DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
declare -x HOME="/home/pi"
declare -x INFINALITY_FT_AUTOHINT_HORIZONTAL_STEM_DARKEN_STRENGTH="10"
declare -x INFINALITY_FT_AUTOHINT_INCREASE_GLYPH_HEIGHTS="true"

# 提取12个字符及其后的部分（移除行首的11个字符(declare -x )）
## 12为起始位置，-后面未指定结束位置，表示至行尾
pi@raspberrypi:~ $ export | head -n 4 | cut -c 12-
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
HOME="/home/pi"
INFINALITY_FT_AUTOHINT_HORIZONTAL_STEM_DARKEN_STRENGTH="10"
INFINALITY_FT_AUTOHINT_INCREASE_GLYPH_HEIGHTS="true"
```

其他像 ps、last 等命令输出都由空白（空格或tab 制表符）控制排版格式，连续空白较难合适分割。

以下来自 manpage 的示例，相当于提取两个range的子串：

```bash
# Show the names and login times of the currently logged in users:
faner@MBP-FAN $ who | cut -c 1-16,26-38
```

### delimiter

除了 `-b`、`-c` 按照字节、字符索引提取文本行，还有一个更常用的 `-d` 支持按分割符提取域。

`-d`, --delimiter=DELIM：use DELIM instead of TAB for field delimiter

一般使用 `-d` 指定 DELIM 对文本行进行分割后，往往搭配使用 `-f` 选项提取指定索引域。

`-f`, --fields=LIST：select only these fields; also print any line that contains no delimiter character, unless the -s option is specified

> `cut -d` 可替代 awk 适用一些简单的切割提取场景，`-d` 选项相当于 awk 的 `-F`（`FS`），`-f` 则相当于 `$NF` 引用取域。

---

提取 /etc/passwd 文件中文本行第1个域和第7个域：

```bash
faner@MBP-FAN $ echo "nobody:*:-2:-2:Unprivileged User:/var/empty:/usr/bin/false" | cut -d : -f 1,7
nobody:/usr/bin/false

# 对整个文件文本行进行提取域1和域7
# Extract users' login names and shells from the system passwd(5) file as ``name:shell'' pairs:
faner@MBP-FAN $ cut -d : -f 1,7 /etc/passwd | head -20
```

PATH 环境变量是以 `:` 分隔多个路径，可以使用 cut 命令提取其中部分路径。

```bash
faner@MBP-FAN $ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin
faner@MBP-FAN $ echo $PATH | cut -d ':' -f 3
/bin
faner@MBP-FAN $ echo $PATH | cut -d ':' -f 5
/sbin
faner@MBP-FAN $ echo $PATH | cut -d ':' -f 3,5
/bin:/sbin
```

不小心向 PATH 重复追加了 `/usr/local/sbin`：

```bash
pi@raspberrypi:~ $ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
pi@raspberrypi:~ $ PATH=$PATH:/usr/local/sbin
pi@raspberrypi:~ $ echo $PATH 
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/usr/local/sbin
```

如何删除刚才追加重复的 `/usr/local/sbin`？

直接 `PATH=` 赋值修改前的值 `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games`。

执行 `PATH=$(echo $PATH | cut -d : -f 1,3-)` 可移除第2项。

## tr

`tr`（translate）命令支持对标准输入进行替换或删除，一般用于删除文件中的控制字符或进行字符转换。

tr只能通过stdin，而无法通过命令行参数来接受输入，它的调用格式如下：

```bash
tr [options] set1 set2
```

将来自stdin的输入字符从set1映射到set2，然后将输出写入stdout。
其中set1和set2是字符类或字符集，set1用于查询，set2用于转换。

- 如果两个字符集的长度不相等，那么set2会不断重复其最后一个字符，直到长度与set1相同。
- 如果set2的长度大于set1，那么在set2中超出set1长度的那部分字符则全部被忽略。

在 macOS 终端执行 `man tr` 可查看详细帮助手册（Manual Page）：

```bash
faner@MBP-FAN $ man tr
TR(1)                     BSD General Commands Manual                    TR(1)

NAME
     tr -- translate characters

SYNOPSIS
     tr [-Ccsu] string1 string2
     tr [-Ccu] -d string1
     tr [-Ccu] -s string1
     tr [-Ccu] -ds string1 string2

DESCRIPTION
     The tr utility copies the standard input to the standard output with substitution or deletion of
     selected characters.

     The following options are available:

     -C      Complement the set of characters in string1, that is ``-C ab'' includes every character except
             for `a' and `b'.

     -c      Same as -C but complement the set of values in string1.

     -d      Delete characters in string1 from the input.

     -s      Squeeze multiple occurrences of the characters listed in the last operand (either string1 or
             string2) in the input into a single instance of the character.  This occurs after all deletion
             and translation is completed.

     -u      Guarantee that any output is unbuffered.
```

- `-c`, -C, --complement: use the complement of SET1. 反选设定字符，也就是符合 SET1 的部份不做处理，不符合的剩余部份才进行转换。
- `-d`, --delete: delete characters in SET1, do not translate. 删除指令字符。  
- `-s`, --squeeze-repeats: replace  each  sequence of a repeated character that is listed in the last specified SET, with a single
occurrence of that character. 缩减连续重复的字符成指定的单个字符。  

### substite

没有指定任何选项时，一般表示替换string1中的字符序列为string2中的字符（序列）。

最典型地应用是大小写转换：

- [convert to Uppercase in shell](https://stackoverflow.com/questions/13700632/convert-to-uppercase-in-shell)  
- [Changing to Uppercase or Lowercase](https://www.shellscript.sh/tips/case/)  
- [Shell Scripting: Convert Uppercase to Lowercase](https://www.cyberciti.biz/faq/linux-unix-shell-programming-converting-lowercase-uppercase/)  

```bash
# 将文件 testfile 中的大写字母全部转换为小写
faner@MBP-FAN $ cat testfile | tr A-Z a-z

# 将小写字母全部转换为大写字母
# 等效实现：awk 'BEGIN { getline; print toupper($0) }'
faner@MBP-FAN $ echo "dos2unix" | tr '[:lower:]' '[:upper:]'
DOS2UNIX
```

以下为 manpage 中的示例，将含附加标号的英文字母（参考 [Diacritic](https://en.wikipedia.org/wiki/Diacritic)）替换为普通字母。

- 拉丁文中的字母：ùúûü  
- 汉语拼音字母：ūúǔùǖǘǚǜü  

```bash
# 将拉丁字母中的变种u替换为普通u
faner@MBP-FAN $ tr "[=u=]" "u" <<< ùúûü
uuuu
# 移除字母e的变种标号，替换为普通e
faner@MBP-FAN $ tr "[=e=]" "e" <<< "hëhë, hēcha, héliu, êxin, hèka, ęě"
hehe, hēcha, heliu, exin, heka, ęě
# 将文件file1中的变种e普通化后保存到file2
faner@MBP-FAN $ tr "[=e=]" "[e*]" <file1 >file2
```

以下示例将文件1中的大括号替换为小括号，然后保存输出到 file2。

> 注意这里左右括号的对应替换顺序。

```bash
faner@MBP-FAN $ tr '{}' '()' < file1 > file2
```

通过在tr中使用集合的概念，可以轻松地将字符从一个集合映射到另一个集合中。
以下示例使用tr完成简单地加解密：set1 中的 12345 基于索引位置将映射为 set2 中的 87654，反之解密。

```bash
# 加密
$ echo 12345 | tr '0-9' '9876543210'
87654
# 解密
$ echo 87654 | tr '9876543210' '0-9'
12345
```

ROT13是一个著名的加密算法，它按照字母表排列顺序执行13个字母转换。
在ROT13算法中，文本加密和解密都使用同一个函数。
下面用tr进行ROT13加密：

```bash
$ echo "tr came, tr saw, tr conquered." | tr 'a-zA-Z' 'n-za-mN-ZA-M'
ge pnzr, ge fnj, ge pbadhrerq.
```

对加密后的密文再次使用同样的ROT13函数即可进行解密：

```bash
$ echo ge pnzr, ge fnj, ge pbadhrerq. | tr 'a-zA-Z' 'n-za-mN-ZA-M'
tr came, tr saw, tr conquered.
```

#### Squeeze

以下示例将字符串中的空格转换为制表符，默认每个空格都会转换。

```bash
faner@MBP-FAN $ echo "This is a  test" | tr '[:space:]' '\t'
This    is      a               test    %
```

指定 `-s` 选项，可压缩这些重复的空格：

```bash
faner@MBP-FAN $ echo "This is a  test" | tr -s '[:space:]' '\t'
This    is      a       test    %
```

以下使用 `-s` 选项去除重复字母，或将相同字母进行压缩。

```bash
faner@MBP-FAN $  cat oops.txt
And the cowwwwws went homeeeeeeee
Or did theyyyy

faner@MBP-FAN $  tr -s '[a-z]' < oops.txt
And the cows went home
Or did they
```

以下使用 `-s` 选项移除文件中的空行。

> `-d` 会移除所有文本行结尾的换行符。

```bash
# tr -s "[\012]" < oops.txt
faner@MBP-FAN $ tr -s "[\n]" < oops.txt
```

利用 `tr -s` 替换回车换行符（`\r\n`）为换行符（`\n`），实现dos2unix（crlf->lf）：

```bash
faner@MBP-FAN $ tr -s "[\r\n]" "[\n*]" < include/litestd.h
faner@MBP-FAN $ tr -s "[\015\012]" "[\012*]" < include/litestd.h
```

#### Complement

来自 unix/POSIX - [tr](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/tr.html) manpage 的一个样例：

```bash
# creates a list of all words in file1 one per line in file2, where a word is taken to be a maximal string of letters.
tr -cs "[:alpha:]" "[\n*]" <file1 >file2
```

下面的文件包含一个星期的日程表，需要从其中删除所有数字，只保留日期。

```bash
faner@MBP-FAN $ $ cat diary.txt
Monday     08:00
Tuesday    08:10
wednesday  08:20
Thursday   08:30
friday     08:40
Saturday   08:50
sunday     09:00
```

基于 `-c` 的补集思路：把星期之外的非字母替换为换行符，相当于移除星期之后的部分。

```bash
# cat diary.txt | tr -cs "[a-z][A-Z]" "[\n*]"
faner@MBP-FAN $ cat diary.txt | tr -cs "[:alpha:]" "[\n*]"
Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
Sunday
```

文件每行所有不包含在大小写字母集合 `[a-z]` 或 `[A-Z]` 中的字符串放在字符串1中并转换为新行。

> `-c` 表明保留所有字母不动，取其补集；`-s` 选项表明压缩所有新行。

### delete

使用 `-d` 选项可以删除指定的字符（集），例如 `tr -d '[:space:]'`（`tr -d ' '`） 删除空格。

```bash
# 删除所有的小写字母
faner@MBP-FAN $ echo 'Hua Wei' | tr -d a-z
H W
```

使用 `-cd` 组合选项，则删除指定的字符（集）之外的其他字符，以下为 manpage 示例。

```bash
# 删除可打印字符的补集，即删除不可打印字符。
faner@MBP-FAN $ tr -cd "[:print:]" < file1
```

dos2unix（crlf->lf）的另外一种实现是利用 `tr -d`，删除回车控制字符（`\r`），并输出到新文件：

```bash
faner@MBP-FAN $ cat include/litestd.h | tr -d '[\r]' > include/litestd2.h
faner@MBP-FAN $ tr -d '[\r]' < include/litestd.h > include/litestd2.h
faner@MBP-FAN $ tr -d "[\015]" < include/litestd.h | tee include/litestd2.h
```

上面示例基于补集替换提取 diary.txt 中的日期列，另一种思路是基于 `-d` 删除除星期之外的所有字符，包括空格、数字和冒号。

```bash
faner@MBP-FAN $ cat diary.txt | tr -d "[0-9][: ]"
```

**注意**：`tr -cd "[:alpha:]"` 会将末尾的换行符也删除，`tr -cd "[:alpha:][\n]"` 符合预期。

## xargs

以下是各大平台的 xargs 在线手册：

- unix/POSIX - [xargs](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/xargs.html)  
- FreeBSD/Darwin - [xargs](https://www.freebsd.org/cgi/man.cgi?query=xargs)  
- linux - [xargs(1)](http://man7.org/linux/man-pages/man1/xargs.1.html)  
- debian - [xargs(1)](https://manpages.debian.org/buster/findutils/xargs.1.en.html)  
- ubuntu - [xargs(1)](https://manpages.ubuntu.com/manpages/jammy/en/man1/xargs.1.html)  

以下是各大平台对 xargs 的定义：

- unix/POSIX：xargs - construct argument lists and invoke utility  
- FreeBSD/Darwin：xargs -- construct argument list(s) and execute utility  
- linux/debian/ubuntu：xargs - build and execute command lines from standard input  

macOS 下关于 xargs 的 DESCRIPTION：

> The `xargs` utility reads space, tab, newline and end-of-file delimited strings from the standard input and executes *`utility`* with the strings as arguments.
> If `utility` is omitted, *echo*(1) is used.

执行 `xargs --help` 可查看简要帮助（Usage）。  
执行 `man xargs` 可查看详细帮助手册（Manual Page）。

### usage

大多数时候，xargs 命令都是跟管道一起使用的，但是它也可以单独使用。`xargs` 后面的缺省命令（utility）是 `echo`。

`xargs` 是构建单行命令的重要组件之一，它擅长将标准输入数据转换成命令行参数。 它一般紧跟在管道操作符之后，以标准输入作为主要的源数据流。

关于 xargs 的用法，可以参考 《Linux Shell 脚本攻略》中的 `2.5 玩转 xargs` 相关章节。

- [xargs 命令教程](http://www.ruanyifeng.com/blog/2019/08/xargs-tutorial.html)  
- [xargs 命令详解](https://www.cnblogs.com/wangqiguo/p/6464234.html)  
- [Xargs 用法详解](https://blog.csdn.net/zhangfn2011/article/details/6776925)  
- [xargs 原理剖析及用法详解](https://www.cnblogs.com/f-ck-need-u/p/5925923.html)  

默认情况下 xargs 将其标准输入中的内容以空白(包括空格、tab、回车换行等)分割成多个 arguments 之后当作命令行参数传递给其后面的命令，也可以使用 `-d` 命令指定特定分隔符（macOS 貌似不支持该选项）。

基于这一原理，最简单的应用是通过 ` | xargs` 移除字符串首尾以及中间多余的空格。

```bash
# 移除首尾空格
$ echo "   lol  " | xargs
lol

# 移除首尾及中间多余的空格
$ echo "  Bash  Scripting  Language   " | xargs
Bash Scripting Language

$ echo "  Bash  Scripting  Language   " | xargs -n 1
Bash
Scripting
Language
```

`xargs` 使用 stdin 并通过提供 *命令行参数* 给后续要执行的命令（utility）。

md5 命令支持计算指定文件或字符串的MD5值，但不支持从stdin输入，因此无法将字符串管传给md5执行计算。此时，可考虑基于 `echo $string | xargs md -s` 变通实现：

```bash
$ echo 'How many roads must a man walk down' | xargs md5 -s
```

以下通过 `brew list --cask` 列举所有brew安装的cask应用，然后通过管道 xargs 传参给 `brew upgrade --cask` 执行升级：

```bash
brew list --cask | xargs -t brew upgrade --cask
```

xargs 和 find 算是一对死党，两者结合使用可以让任务变得更轻松，详情参考 [find](../commands/linux-cmd-find.md)，特别是 `find ... -print0 | xargs -0 ...` 的搭配使用。

### options

以下列举了5个常用的命令选项：

```
     -0	     Change xargs to expect NUL	(``\0'') characters as separators, in-
	     stead of spaces and newlines.  This is expected to	be used	in
	     concert with the -print0 function in find(1).

     -I	replstr
	     Execute utility for each input line, replacing one	or more	occur-
	     rences of replstr in up to	replacements (or 5 if no -R flag is
	     specified)	arguments to utility with the entire line of input.

     -n	number
	     Set the maximum number of arguments taken from standard input for
	     each invocation of	utility.

     -p	     Echo each command to be executed and ask the user whether it
	     should be executed.  An affirmative response, `y' in the POSIX
	     locale, causes the	command	to be executed,	any other response
	     causes it to be skipped.  No commands are executed	if the process
	     is	not attached to	a terminal.

     -t	     Echo the command to be executed to	standard error immediately be-
	     fore it is	executed.
```

#### -t

xargs 的 `-t` 选项允许每次执行 xargs 后面的命令之前，先在 stderr 上打印出扩展开的真实命令。

```bash
echo "  Bash  Scripting  Language   " | xargs -t
/bin/echo Bash Scripting Language
Bash Scripting Language
```

#### -n

> `-n, --max-args`: Set the maximum number of arguments taken from standard input for each invocation of *utility*.

在上面的例子中，指定 `-n 1` 每次只取一个参数，实现空格分割：

```bash
$ echo "  Bash  Scripting  Language   " | xargs -n 1
Bash
Scripting
Language
```

工作目录下有3个文件，其中文件名 `hello world.txt` 包含空格：

```bash
$ ls -1
hello world.txt
HELLO.txt
WORLD.txt

$ tree -L 1
.
├── hello world.txt
├── HELLO.txt
└── WORLD.txt

1 directory, 3 files
```

将 ls 结果重定向给 xargs 进行 echo 回显，指定 `-n 1` 每次取1个参数：

```bash
# ls : 输出一行，以空格分割
# ls -1 : 每行一个文件，以 \n 分割
$ ls | xargs -n 1
hello
world.txt
HELLO.txt
WORLD.txt
```

文件名 `hello world.txt` 被 xargs 以空格作为分割符视作两个参数：`hello` 和 `world.txt`。

若指定 `-n 2` 则一次取2个参数，第1行输出=`hello` 和 `world.txt`，第2行输出=`HELLO.txt` 和 `WORLD.txt`。

```bash
$ ls | xargs -n 2
hello world.txt
HELLO.txt WORLD.txt
```

默认情况下，xargs 每次导入一条分割的数据到命令行中作为参数。

从 pip 过期包列表中提取出第一列包名，并使用 xargs 命令批量安装：

```bash
$ pip3 install -U $(pip3 list --outdated | awk 'NR>2 {print $1}')
$ pip3 list --outdated | awk 'NR>2 {print $1}' | xargs -n1 pip3 install -U
```

假设有一个文件保存了 wget 想要下载的大量链接和对应要保存的目标文件名，一行链接紧跟一行文件名，格式如下：

```bash
https://www.xxx.yyy/a1
filename1
https://www.xxx.yyy/a2
filename2
https://www.xxx.yyy/a3
filename3
```

如何实现每次从文件读取两行作为一对参数，传递给 wget 进行下载呢？

```bash
$ wget '{URL}' -O '{FILENAME}'
```

xargs 自身的功能无法一次性传递多个参数（parallel命令可以，而且方式多种），只能寻求一些技巧来实现。

```bash
cat url.txt | xargs -n 2 bash -c 'wget "$1" -O "$2"'
```


#### -0

xargs 默认是以空白字元作为导入参数列表的分割符，如果有一些档名或者是其他意义的名词内含有空白字元的时候，xargs 可能会误判分割导致参数错误。

接下来我们结合一些实例来分析一下 `find -print0` 和 `xargs -0` 选项的配对使用场景。

`find` 默认对匹配到的文件（路径）执行打印操作（`-print`），以换行符 `\n` 作为分隔符将结果行（条目）进行分隔输出到控制台。

```bash
$ find . -type f
./WORLD.txt
./hello world.txt
./HELLO.txt
```

使用 `-ls` 替代默认的 `-print` 选项，列举找到的文件的属性信息：

```bash
$ find . -type f -ls
128555241        8 -rw-r--r--    1 faner            staff                 146 Apr  9  2024 ./WORLD.txt
128555232        8 -rw-r--r--    1 faner            staff                 146 Apr  9  2024 ./hello world.txt
27135950        8 -rw-r--r--    1 faner            staff                 146 Apr  9  2024 ./HELLO.txt
```

`find -ls` 可以基于 `find`+`ls -l` 等效实现：将 `find` 输出结果重定向给 `xargs` 作为参数传递给 `ls -l` 命令进行处理：

```bash
$ find . -type f | xargs -t ls -l
ls -l ./WORLD.txt ./hello world.txt ./HELLO.txt
ls: ./hello: No such file or directory
-rw-r--r--@ 1 faner  staff   146 Apr  9  2024 ./HELLO.txt
-rw-r--r--@ 1 faner  staff   146 Apr  9  2024 ./WORLD.txt
-rw-r--r--@ 1 faner  staff   146 Apr  9  2024 world.txt
```

不出意外，遇到和 `ls | xargs -n 1` 同样的问题，`hello world.txt` 被 xargs 以空格作为分割符解析成了两个参数：`hello` 和 `world.txt`。尝试执行 `ls -l ./hello` 时，报错文件（夹）不存在。

对于 find 出的文件（名/路径）包含空格，可以指定 `-print0` 替代隐含默认的 `-print`，使用 `\0` 代替 `\n` 作为结果分隔符，每个文件（名/路径）后都隐含有一个字符 NUL（`\0`）。然后，相应通过 `xargs -0` 选项指定以 `\0` 而非空白字元来作为参数分隔符，从而正确解析出参数列表，再逐个文件调用 `ls -l`，则结果符合预期。

```bash
$ find . -type f -print0 | xargs -0 -t ls -l
ls -l ./WORLD.txt ./hello world.txt ./HELLO.txt
-rw-r--r--@ 1 cliff  staff   146 Apr  9  2024 ./hello world.txt
-rw-r--r--@ 1 cliff  staff   146 Apr  9  2024 ./HELLO.txt
-rw-r--r--@ 1 cliff  staff   146 Apr  9  2024 ./WORLD.txt
```

---

在 vim 下执行 `:%s/\r//g` 可将DOS文件中的回车符 `^M` 替换为空（即删除）。

dos2unix 批量替换方案：`find ./ -type f print0 | xargs -0 sed -i 's/^M$//'`。  

#### -I

xargs 的 `-I` 选项是一个功能强大的工具，它的核心作用是定义一个**占位符**，让你能够精确控制从标准输入读取的参数被放置在后续命令的哪个位置。

默认情况下，`xargs` 会将接收到的参数添加到命令的末尾。但很多场景下，我们需要将参数插入到命令中间或指定位置，这时 `-I` 选项就派上用场了。

例如，`cat url_list.txt | xargs -n 1 wget` 中，`-n 1` 表示每行一个参数（URL）传递给 `wget` 进行下载，相当于 `wget URL`。

上面的 `find . -type f -print0 | xargs -0 -t ls -l` 以 `\0` 分割的参数（文件名）将作为 `ls -l FILEs` 的参数 FILEs，实际展开效果如下：

```bash
# 参数位置在 ls 命令尾部
ls -l ./WORLD.txt ./hello world.txt ./HELLO.txt
```

**基本语法格式**：`xargs -I <占位符> <命令> <占位符>`，占位符可以是任意字符串，如 `{}`、`file`、`@` 等，`{}` 是最常见的选择。

> `xargs -I` 和 `xargs -i` 是一样的，只是 `-i` 默认使用大括号（`{}`）作为替换字符串（replstr），`-I` 则可以自定义其他字符串作为 replstr，但是必须用引号包起来（？）。
> man 推荐使用 `-I` 代替 `-i`（macOS 下不支持 `-i` 选项），但是一般都使用 `-i` 图个简单，除非在命令中不能使用大括号。

典型应用场景包括：

1. 批量重命名文件

```bash
ls *.txt | xargs -t -I {} mv {} {}.bak
```

- 这条命令会将所有 `.txt` 文件追加 `.bak` 后缀进行重命名。例如，输入是 `a.txt`，那么构造出的命令就是 `mv a.txt a.txt.bak`。

2. 将文件复制到特定目录

```bash
find . \( -iname "*.jpg" -o -iname "*.png" \) | xargs -I {} cp {} /data/images
```

- 将所有找到的图片文件（后缀为 .jpg 或 .png，不区分大小写）复制到 /data/images 目录下。

无法通过 xargs 传递数值做正确的算术扩展：

```bash
$ echo 1 | xargs -I "x" echo $((2*x))
```

这时只能改变方法或寻找一些小技巧，例如：

```bash
$ echo 1 | xargs -I {} expr 2 \* {}
```

`cat url_list.txt | xargs -I % sh -c '...'` 是一个经典的组合，用于对文件中的每一行内容（例如每个URL）执行一系列复杂的操作。

这个结构的强大之处在于，你可以在 `sh -c '...'` 的单引号内编写任何复杂的命令序列。

- `sh -c` 后面的命令字符串必须用单引号引起来，这样可以确保占位符 `%` 由 xargs 进行替换，而不是被当前Shell提前解释。

例如，可以依次执行下载URL并记录日志：

```bash
cat url_list.txt | xargs -I % sh -c 'echo "正在下载：%"; wget %; echo "已完成：%" >> wget_download.log'
```

对于 url_list.txt 里的每个URL，Shell 都会依次执行三条命令：先打印正在下载提示信息，然后使用 wget下载，最后将完成信息追加到日志文件中。
