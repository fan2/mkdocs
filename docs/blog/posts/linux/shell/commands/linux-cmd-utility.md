---
title: Linux Command - utilities
authors:
  - xman
date:
    created: 2019-10-29T14:30:00
    updated: 2024-05-18T18:30:00
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

```bash
faner@FAN-MB0:~|⇒  cd /Users/faner/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
faner@FAN-MB0:~/Library/Application Support/Sublime Text 3/Packages/User|
⇒  
```

另外一种做法是定义 shell 字符串变量，然后使用 <kbd>$</kbd> 符号解引用变量作为 cd 的参数：

```bash
faner@FAN-MB0:~|⇒  dir="/Users/faner/Library/Application Support/Sublime Text 3/Packages/User/"                    
faner@FAN-MB0:~|⇒  cd $dir
faner@FAN-MB0:~/Library/Application Support/Sublime Text 3/Packages/User|
```

### pushd & popd

`cd -` 可在近两次目录之间切换，当涉及3个以上的工作目录需要切换时，可以使用 pushd 和 popd 命令。

macOS 的 zsh 命令行输入 push 然后 tab 可以查看所有 push 相关命令：

```bash
faner@MBP-FAN:~|⇒  push
pushd   pushdf  pushln
```

- 其中 **pushdf** 表示切换到当前 Finder 目录（`pushd` to the current Finder directory）。  
- 关于 **pushln** 可参考 zsh-manual [Shell Builtin Commands](http://bolyai.cs.elte.hu/zsh-manual/zsh_toc.html#TOC65) 中的说明。  

> 在 macOS 终端中执行 `man pushd` 或 `man popd` 可知，他们为 BASH 内置命令（Shell builtin commands）。

**`pushd`** 和 **`popd`** 可以用于在多个目录（directory）之间进行切换（push/pop）而无需复制并粘贴目录路径。 

`pushd` 和 `popd` 以栈的方式来运作，后进先出（Last In First Out, LIFO）。目录路径被存储在栈中，然后用 push 和 pop 操作在目录之间进行切换。

```bash

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

```bash
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

```bash
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

```bash
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

```bash
echo "dirname = $(dirname $0)"
echo "basename = $(basename $0)"
```

例如 [transfer.sh](https://transfer.sh/) 中，从第一个参数中基于 basename 提取纯文件名：

```bash
        file="$1"
        file_name=$(basename "$file")
```

## printf

```bash
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

### rev

```bash
NAME
     rev -- reverse lines of a file

SYNOPSIS
     rev [file ...]

DESCRIPTION
     The rev utility copies the specified files to the standard output, reversing the order of characters in
     every line.  If no files are specified, the standard input is read.
```

```bash
echo "Bash Shell" | rev
llehS hsaB
```

## head/tail

head/tail 命令支持查看文件(file)前/后指定字节(-c)或行数(-n)的内容。

```bash
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

```bash
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

```bash
$ du -csh ~/Library/Developer/* | sort -rh | head
```

在 Linux 下，head 的 -n 接负号数（-NUM）表示打印除末尾几行的开头部分。

```bash
$ man head
       -n, --lines=[-]NUM
              print the first NUM lines instead of the first 10; with the leading
              '-', print all but the last NUM lines of each file
```

在 Linux 下，tail 的 -n 接正号数（+NUM）表示打印从第NUM行开头到尾部部分（即忽略前NUM-1行）。

```bash
$ man tail
       -n, --lines=[+]NUM
              output  the  last NUM lines, instead of the last 10; or use -n +NUM
              to output starting with line NUM
```

在 Linux 下，如想打印除开头和结尾10行的中间部分可以执行：`head -n -10 file.txt | tail +11`。

在 macOS 下由于不支持以上特性，需要按照下面的步骤实现同等效果：

```bash
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

```bash
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

```bash
$ tail -f nginx-access.log
```

---

**sed**（`s`tream `ed`itor）意即流式编辑器，可轻松实现类似head/more的过滤文本显示。
当然也可借助sed指定正则匹配规则，过滤出某些行或某些有特殊起始格式的段落。

具体参考 [sed-basic.md](../../shell/sed-awk/sed/sed-basic.md) 中的示例。

以上想打印除开头和结尾10行的中间部分，也可先计算好中间部分的起始行号，再用sed过滤打印：

```bash
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

```bash
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

```bash
du ~/Documents
du ~/Library/Developer
du Pods
```

- 添加 `-l` 选项，仅显示本地文件系统，不包括 mount points；  
- 添加 `-T` 选项（`-Y` for macOS），打印出文件系统类型；  
- 添加 `-h` 选项，使输出的 fileSize 更易阅读；  
- 添加 `-s` 选项，相当于 `-d 0` 指定一级目录，不递归子目录；  
- 添加 `-c` 选项，最后会输出一条总占用大小；  

```bash
$ du -sh ~/Documents
or
$ du -h -d 0 ~/Documents
$ du -h --max-depth=0 ~/Documents
```

统计目录 `~/Library/Developer` 占用磁盘空间大小：

```bash
$ du -sh ~/Library/Developer
 66G	/Users/faner/Library/Developer
```

统计目录 `~/Library/Developer` 子目录占用磁盘空间大小：

```bash
$ du -csh ~/Library/Developer/*
 23G	/Users/faner/Library/Developer/CoreSimulator
1.4G	/Users/faner/Library/Developer/XCTestDevices
 39G	/Users/faner/Library/Developer/Xcode
425M	/Users/faner/Library/Developer/chromium
2.2G	/Users/faner/Library/Developer/flutter
 66G	total
```

按占用磁盘空间降序（由大到小）排序：

```bash
$ du -sh ~/Library/Developer/* | sort -rh
 39G	/Users/faner/Library/Developer/Xcode
 23G	/Users/faner/Library/Developer/CoreSimulator
2.2G	/Users/faner/Library/Developer/flutter
1.4G	/Users/faner/Library/Developer/XCTestDevices
425M	/Users/faner/Library/Developer/chromium
```

从 [The Linux Kernel Archives](https://www.kernel.org/) 下载最新 Linux 内核源码 [2024-05-17 stable:6.9.1](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/?h=v6.9.1)，解压后统计一级子目录的大小并进行排序：

```bash
du -csh ./* | sort -rh
1.5G	total
1.0G	./drivers
146M	./arch
 74M	./tools
 68M	./Documentation
 53M	./include
 50M	./sound
 49M	./fs
 36M	./net
 14M	./kernel
8.2M	./lib
5.4M	./mm
4.1M	./scripts
3.8M	./crypto
3.5M	./security
2.1M	./block
1.6M	./samples
880K	./rust
732K	./MAINTAINERS
652K	./io_uring
320K	./virt
276K	./ipc
276K	./LICENSES
196K	./init
104K	./CREDITS
 76K	./usr
 72K	./certs
 68K	./Makefile
4.0K	./README
4.0K	./Kconfig
4.0K	./Kbuild
4.0K	./COPYING
```

当子目录太多时，可重定向给 `more` 滚动查看，或重定向给 `head -n 10` 查看前10条。

列举 Pods 目录下所有的一级子目录（不递归）：

```bash
ls -1 -d Pods/* | tee ~/Downloads/Pods-tree-L1.log
```

查看 Pods 目录下所有的一级子目录占用磁盘空间大小：

```bash
du -csh Pods/* | more
du -csh Pods/* | tee ~/Downloads/Pods-tree-L1-du.log
ls -1 -d Pods/* | xargs du -chs | tee ~/Downloads/Pods-tree-L1-du.log
```

---

The `tree` command is a recursive directory listing program that produces a depth indented listing of files and directories in a tree-like format.

```bash
tree --du -h /opt/ktube-media-downloader
```

## Checksum

### cksum

cksum, sum -- display file checksums and block counts

### CRC32

crc32 - Perform a 32bit Cyclic Redundancy Check

计算从 [crx4chrome](https://www.crx4chrome.com/) 离线下载的 [Vimium CRX 1.60.3 for Chrome](https://www.crx4chrome.com/crx/731/)  插件的 crc32 校验和：

```bash
faner@FAN-MB0:~/Downloads/crx|
⇒  crc32 dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx 
db950177
```

与官网给出的 CRC32 Checksum 值一致，则说明未被篡改，可放心安装。

### MD5

md5 -- calculate a message-digest fingerprint (checksum) for a file

md5 命令后的默认输入参数为文件名，也可通过 `-s` 选项指定计算字符串参数的MD5。

```bash
     -s string
             Print a checksum of the given string.
```

计算从 [crx4chrome](https://www.crx4chrome.com/) 离线下载的 [Vimium CRX 1.60.3 for Chrome](https://www.crx4chrome.com/crx/731/)  插件的 MD5：

```bash
faner@FAN-MB0:~/Downloads/crx|
⇒  md5 dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx 
MD5 (dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx) = c98057821ee3cede87d911ead832dcc1
```

与官网给出的 MD5 Checksum 值一致，则说明未被篡改，可放心安装。

---

计算下载到本地的 Vimium CRX 1.60.3 for Chrome 插件所在路径字符串的 MD5 值：

```bash
faner@FAN-MB0:~/Downloads/crx|
⇒  md5 -s "/Users/faner/Downloads/crx/dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx" 
MD5 ("/Users/faner/Downloads/crx/dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx") = 2f6f9a98b561f995564793765c205a66
```

### SHA

shasum - Print or Check SHA Checksums

```bash
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

```bash
faner@FAN-MB0:~/Downloads/crx|
⇒  shasum dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx 
476c61437d3c34e38ed1ee15950d202ded0902c8  dbepggeogbaibhgnhhndojpepiihcmeb-1.60.3-Crx4Chrome.com.crx
```

与官网给出的 SHA1 Checksum 值一致，则说明未被篡改，可放心安装。

---

[SHA1 vs SHA256](https://www.keycdn.com/support/sha1-vs-sha256)  
[Why use SHA256 instead of SHA1?](https://www.ibm.com/support/pages/why-use-sha256-instead-sha1)  
[Re-Hashed: The Difference Between SHA-1, SHA-2 and SHA-256 Hash Algorithms](https://www.thesslstore.com/blog/difference-sha-1-sha-2-sha-256-hash-algorithms/)  

## misc

### fuser

```bash
$ man fuser
NAME
       fuser - list process IDs of all processes that have one or more files open

SYNOPSIS
       fuser [ -cfu ] file ...
```

### lsof

```bash
NAME
       lsof - list open files

SYNOPSIS
       lsof  [  -?abChlnNOPRtUvVX ] [ -A A ] [ -c c ] [ +c c ] [ +|-d d ] [ +|-D D ] [ +|-e s ] [ +|-E ] [ +|-f [cfgGn] ] [ -F [f] ] [ -g [s] ] [
       -i [i] ] [ -k k ] [ -K k ] [ +|-L [l] ] [ +|-m m ] [ +|-M ] [ -o [o] ] [ -p s ] [ +|-r [t[m<fmt>]] ] [ -s [p:s] ] [ -S [t] ] [ -T [t] ]  [
       -u s ] [ +|-w ] [ -x [fl] ] [ +|-X ] [ -z [z] ] [ -Z [Z] ] [ -- ] [names]
```

查找监听指定端口的进程PID：

```bash
lsof -i :8010 | awk 'NR>1 {print $2}' | xargs kill -KILL
```

- [查看 Linux TCP Port 被哪隻程式(Process)佔用](https://blog.longwin.com.tw/2013/12/linux-port-process-check-2013/)  
- [Finding the PID of the Process Using a Specific Port](https://www.baeldung.com/linux/find-process-using-port)  
- [Linux Find Out Which Process Is Listening Upon a Port](https://www.cyberciti.biz/faq/what-process-has-open-linux-port/)  
- [3 Ways to Find Out Which Process Listening on a Particular Port](https://www.tecmint.com/find-out-which-process-listening-on-a-particular-port/)  

You can use `lsof` (list of open files) in most cases to find open log files without knowing the configuration.

```Shell
# macOS
~$ ps aux | grep nginx
faner            33741   0.0  0.0 35126068   3596   ??  S     7:34AM   0:00.30 nginx: worker process
root             33691   0.0  0.0 34425616   6392   ??  Ss    7:34AM   0:00.03 nginx: master process /usr/local/opt/nginx-full/bin/nginx -g daemon off;

~$ lsof -p 33741 | grep log
nginx   33741 faner    1u     REG              1,13        0            25121281 /usr/local/var/log/nginx.log
nginx   33741 faner    2w     REG              1,13    51695             3821144 /usr/local/var/log/nginx/error.log
nginx   33741 faner    4w     REG              1,13  2103983             3821142 /usr/local/var/log/nginx/access.log
nginx   33741 faner    5w     REG              1,13    51695             3821144 /usr/local/var/log/nginx/error.log
```

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

```bash
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

```bash
$ cat banner-exposure.json | jq -c .
{"bizName":"yidian","plat":"h5","actionName":"banner","actionType":"exposure","extra":{"value":{"banner_id":"3303","title":"体检季来了：你最关心的各种检查，这里都有","index":0}}}
```