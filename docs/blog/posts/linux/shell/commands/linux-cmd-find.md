---
title: Linux Command - find & xargs
authors:
  - xman
date:
    created: 2019-10-29T12:00:00
    updated: 2026-01-23T19:30:00
categories:
    - wiki
    - linux
tags:
    - find
    - xargs
comments: true
---

linux 下的命令 find 用法总结。

<!-- more -->

## man

以下是各大平台的 find 在线手册：

- unix/POSIX - [find](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/find.html)  
- FreeBSD/Darwin - [find](https://www.freebsd.org/cgi/man.cgi?query=find)  

- linux - [find(1)](http://man7.org/linux/man-pages/man1/find.1.html) & [find(1p)](http://man7.org/linux/man-pages/man1/find.1p.html)  
- debian - [find(1)](https://manpages.debian.org/buster/findutils/find.1.en.html)  

- ubuntu - [find(1)](https://manpages.ubuntu.com/manpages/jammy/en/man1/find.1.html)  

以下是各大平台对 find 的定义：

- unix/POSIX：find - find files  
- FreeBSD/Darwin：find -- walk a file hierarchy  
- linux/debian/ubuntu：find - search for files in a directory hierarchy  

## help/usage

执行 `man find` 可查看 find 命令帮助手册。

```bash
# macOS
FIND(1)			FreeBSD	General	Commands Manual		       FIND(1)

NAME
     find -- walk a file hierarchy

SYNOPSIS
     find [-H |	-L | -P] [-EXdsx] [-f path] path ... [expression]
     find [-H |	-L | -P] [-EXdsx] -f path [path	...] [expression]

DESCRIPTION
     The find utility recursively descends the directory tree for each path
     listed, evaluating	an expression (composed	of the "primaries" and
     "operands"	listed below) in terms of each file in the tree.
```

find 命令的工作方式如下：沿着文件层次结构向下遍历，匹配查找符合条件的文件（夹），执行相应的操作。

```
find path [options] [expression]
```

> 其中 path 可以指定多个目录。

1. If no paths are given, the *current* directory is used.  
2. If no expression, such as `-ls`, `-delete`, `-exec`, `-ok` is given/specified, the expression `-print` is used. It prints the pathname of the found file(s) to standard output.  
3. `-print0`: Similar to Null-Terminated Strings in C, it prints the pathname of the current file to standard output, followed by an ASCII NUL character (character code 0). This allows file names that contain newlines or other types of white space to be correctly interpreted by programs that process the find output.  

## options

### OPERATORS

表达式及操作符。

> The operator `-or` was implemented as `-o`, and the operator `-and` was implemented as `-a`.

```bash
     The primaries may be combined using the following operators.  The operators are listed in order of
     decreasing precedence.

     ( expression )
             This evaluates to true if the parenthesized expression evaluates to true.

     ! expression
     -not expression
             This is the unary NOT operator.  It evaluates to true if the expression is false.

     -false  Always false.
     -true   Always true.

     expression -and expression
     expression expression
             The -and operator is the logical AND operator.  As it is implied by the juxtaposition of two
             expressions it does not have to be specified.  The expression evaluates to true if both
             expressions are true.  The second expression is not evaluated if the first expression is
             false.

     expression -or expression
             The -or operator is the logical OR operator.  The expression evaluates to true if either the
             first or the second expression is true.  The second expression is not evaluated if the first
             expression is true.

     All operands and primaries must be separate arguments to find.  Primaries which themselves take argu-
     ments expect each argument to be a separate argument to find.
```

### -name

按照文件名查找文件。

**注意**：-name 模糊匹配目录或文件，是基于通配符（globbing/wildcard patterns），而非正则表达式！

以下示例通配查找当前目录下的所有txt文件：

```bash
$ find . -name *.txt
find: data.txt: unknown primary or operator
```

根据提示通配符需要转义，或者将 `-name` 参数用引号包起来：

```bash
find . -name \*.txt
find . -name '*.txt'
find . -name "*.log"
```

以下示例通配查找当前目录下所有名称包含OfflineFile的文件夹及文件。

```bash
$ find . -iname '*OfflineFile*'
```

以下示例通配查找当前目录下所有后缀为proto的文件（即protobuf协议文件）。

```bash
$ find . -type f -name "*.proto"
```

#### case-insensitive

`-iname`：匹配名字时会忽略大小写。

大部分操作系统中，文件名中不区分大小写，`file.txt` 和 `FILE.txt` 表示同一个文件；`file.txt` 和 `file.TXT` 也表示同一个文件。

因此在执行相关 find 查找时，比如统计C语言程序代码文件，其后缀可能为 `*.c` 或 `*.C`。此时，`-iname` 比 `-name` 更实用。

#### inverse

`!`（`-not`）运算符支持反向匹配。

以下示例查找所有非指定后缀的文件：

```bash
$ find . ! -name '*.txt'
$ find . -not -name '*.txt'
# 转义反斜杠貌似可有可无
$ find . \! -iname "*.c"
```

以下为 find 的 man page 中的两个相关示例：

```bash
     find / \! -name "*.c" -print
             Print out a list of all the files whose names do not end in .c.

     find / \! \( -newer ttt -user wnj \) -print
             Print out a list of all the files which are not both newer than ttt and owned by ``wnj''.
```

以下示例，同时指定符合和不符合的条件：

```bash
# 查找 *.txt 文件，但是忽略 .txt、.vimrc、.data 等隐藏文件（hidden dot files）。
$ find . -type f \( -iname "*.txt" ! -iname ".*" \)

# 查找所有的点隐藏文件（hidden dot files），但是忽略 .htaccess 文件。
$ find . -type f \( -iname ".*" ! -iname ".htaccess" \)

# 查找所有非C/C++代码文件（包括头文件和源码文件），以便删除中间产物
$ find . -type f \( ! -iname '*.h' ! -iname '*.hh' ! -iname '*.hpp' ! -iname '*.c' ! -iname '*.cc' ! -iname '*.cpp' \)
```

#### or

`-name ` 每次只能指定一种文件名通配规则，如果要复合匹配多个规则，可使用逻辑运算符。

如果想同时匹配多个条件，可以采用 AND 条件运算符（`-and` 或 `-a`）。

> 多个匹配条件没有指定逻辑运算符时，默认就是同时满足（AND）。
> 一般 -type 和 -name 选项同时出现，就是同时通配满足类型和名称。

如果想匹配多个条件中的一个，可以采用 OR 条件运算符（`-or` 或 `-o`）：

```bash
$ ls
new.txt some.jpg text.pdf 
$ find . -iname "*.txt" -o -iname "*.pdf"
./text.pdf
./new.txt
./hello world.txt
```

上面的代码会打印出所有后缀为 .txt 和 .pdf 文件。

当带有多个同类条件时，也可通过括号将同类条件（-iname）括起来，方便归拢逻辑和提高阅读体验。

> `\(` 以及 `\)` 用于将 `-name "*.txt" -o -name "*.pdf` 视为一个逻辑整体。

```bash
$ find . \( -iname "*.txt" -o -iname "*.pdf" \)
```

---

当把 find 结果传给 -exec 执行或管传给 xargs 执行时，**如果不加括号**，则实际效果看起来只传参了匹配 -o 后面的那一部分！？

以下脚本本意是删除 testDir1 目录下的所有文件夹 __MACOSX 和隐藏文件 .DS_Store，实际只删除了 .DS_Store：

```bash
$ find testDir1 -name "__MACOSX" -o -name ".DS_Store" -exec rm -rf {} \;
```

按照逻辑结合优先级，以上表达式等效于：

```bash
$ find testDir1 \( -name "__MACOSX" \) -o \( -name ".DS_Store" -exec rm -rf {} \; \)
```

### -type

`-type ` 选项支持按照文件类型查找文件。

```bash
     -type t
             True if the file is of the specified type.  Possible file types are as follows:

             b       block special
             c       character special
             d       directory
             f       regular file
             l       symbolic link
             p       FIFO
             s       socket
```

当未指定 `-type ` 选项时，默认查找所有文件类型，包括文件夹、文件和软链等。

上面的非名称匹配（-not -name）示例中，第一行默认输出当前目录（.），因为未指定 -type 。

```bash
$ find . ! -name '*.txt'
# 明确查找类型为文件
$ find . -type f ! -name '*.txt'
```

以下示例通配查找当前目录下所有名称以 data 开头的文件。

```bash
$ find . -type f -iname 'data*'
```

以下示例列举当前文件夹下的子目录：

```bash
$ find . -type d
# 过滤掉当前目录dot('.')
$ find . -type d ! -name '.'
# 或者
$ find ./* -type d
```

以下示例精确查找名为 `OfflineFile` 的文件夹：

```bash
$ find . -type d -name 'OfflineFile'
```

以下示例精确查找名为 `libOfflineFile.a` 的文件：

```bash
$ find . -type f -name 'libOfflineFile.a'
```

以下示例统计 `OfflineFile` 文件夹下所有可参与编译的源代码文件（Compile Sources）数量：

```bash
$ find OfflineFile -type f \( -iname "*.c" -o -iname "*.cpp" -o -iname "*.m" -o -iname "*.mm" \) | wc -l
     273
```

#### or

`-type ` 每次只能指定一种类型，如果要复合匹配多种类型，可使用逻辑运算符。

> 关于 AND 条件运算符（`-and` 或 `-a`）和 OR 条件运算符（`-or` 或 `-o`）具体参考 -name 中的阐述，此处不再赘述。

以下示例查找项目工程中的文件 `JceObjectV2.h`：

```bash
$ find . -type f -name 'JceObjectV2.h'
./Classes/module/WaterMarkCamera/3rd/WirelessUnifiedProtocol/Serializable/JceObjectV2.h
./Classes/extern/Analytics/BuglyOA/BuglyCocoa/BuglyCocoa/JceProtocol/CocoaJce/JceObjectV2.h
./Pods/CocoaJCE/Include/JceObjectV2.h
```

以下示例查找项目工程中的软链 `JceObjectV2.h`：

```bash
$ find . -type l -name 'JceObjectV2.h'
./Pods/Headers/Public/CocoaJCE/JceObjectV2.h
./Pods/Headers/Private/CocoaJCE/JceObjectV2.h
```

当然，也可以用 `-o` 指定并列的 `-type ` 类型约束：

> 通过括号将同类条件（-type）括起来，方便归拢逻辑和提高阅读体验。

```bash
$ find . -name 'JceObjectV2.h' \( -type f -o -type l \)
./Classes/module/WaterMarkCamera/3rd/WirelessUnifiedProtocol/Serializable/JceObjectV2.h
./Classes/extern/Analytics/BuglyOA/BuglyCocoa/BuglyCocoa/JceProtocol/CocoaJce/JceObjectV2.h
./Pods/Headers/Public/CocoaJCE/JceObjectV2.h
./Pods/Headers/Private/CocoaJCE/JceObjectV2.h
./Pods/CocoaJCE/Include/JceObjectV2.h
```

如果 `JceObjectV2.h` 很明确是头文件（或软链替身），不可能为文件夹的话，也可不指定 `-type ` 选项，查找项目工程中的所有名为 `JceObjectV2.h` 的文件：

```bash
$ find . -name 'JceObjectV2.h'
```

### other

#### -path

```bash
     -path pattern
             True if the pathname being examined matches pattern.  Special shell pattern matching charac-
             ters (``['', ``]'', ``*'', and ``?'') may be used as part of pattern.  These characters may
             be matched explicitly by escaping them with a backslash (``\'').  Slashes (``/'') are treated
             as normal characters and do not have to be matched explicitly.
```

选项 `-path` 的参数可以使用通配符来匹配文件路径。  
`-name` 总是用给定的文件名进行匹配，`-path` 则将文件路径作为一个整体进行匹配。例如：

```bash
$ find /home/users -path "*/slynux/*"
```

可以匹配出以下路径：

```bash
/home/users/list/slynux.txt
/home/users/slynux/eg.css
```

[shell - How to exclude this / current / dot folder from find "type d" - Stack Overflow](https://stackoverflow.com/questions/13525004/how-to-exclude-this-current-dot-folder-from-find-type-d)

当 find -d 要过滤掉当前目录，除了 `! -name $targetDir` 名称排除，还可以 `! -path "$targetDir"` 通过路径排除。

```bash
targetDir="dir_path"
find "$targetDir" ! -path "$targetDir" -type d
```

#### -user/-group

按照文件属主、用户组来查找文件，查找属于该用户的所有文件。

```bash
$ find / -user $USER_ACCOUNT > $REPORT_FILE
```

查找 webdav 目录下 user 或 group 不为 `_www` 的文件。

```bash
$ find /usr/local/var/webdav ! -user _www -o ! -group _www
```

#### -size

可以按照文件长度来查找过滤文件，默认以块（block）为计量单位。
也可以用字节来计量，表达形式为 Nc、Nk、NM、NG。

```bash
     -size n[ckMGTP]
             True if the file's size, rounded up, in 512-byte blocks is n.  If n is followed by a c, then
             the primary is true if the file's size is n bytes (characters).  Similarly if n is followed
             by a scale indicator then the file's size is compared to n scaled as:

             k       kilobytes (1024 bytes)
             M       megabytes (1024 kilobytes)
             G       gigabytes (1024 megabytes)
             T       terabytes (1024 gigabytes)
             P       petabytes (1024 terabytes)
```

以下示例在 /home/apache 目录下查找大小恰好为100字节的文件：

```bash
$ find /home/apache -size 100c -print
```

以下示例在当前目录下查找大小超过10块（5120c）的文件：

```bash
$ find . -size +10 -print
# 字节计量
$ find . -size +5120c
# kilobytes计量
$ find . -size +5k
```

以下示例在当前目录下查找大小超过1M的文件：

```bash
# 字节计量
$ find . -size +1048576c -print
# kilobytes计量
$ find . -size +1024k -print
# megabytes计量
$ find . -size +1M -print
```

#### -regex

```bash
# macOS
     -regex pattern
             True if the whole path of the file matches pattern using regular expression.  To match a file
             named ``./foo/xyzzy'', you can use the regular expression ``.*/[xyz]*'' or ``.*/foo/.*'', but
             not ``xyzzy'' or ``/foo/''.
# ubuntu
       -regex pattern
              File name matches regular expression pattern.  This is a match on the whole path, not a  search.   For
              example,  to match a file named ./fubar3, you can use the regular expression `.*bar.' or `.*b.*3', but
              not `f.*r3'.  The regular expressions understood by find are by default Emacs Regular Expressions (ex‐
              cept that `.' matches newline), but this can be changed with the -regextype option.
```

#### -depth

find 命令在使用时会遍历所有的子目录，首先查找当前目录中的文件，然后再在其子目录中查找。

如果只需在当前目录中进行搜索，无须继续进入子目录深度查找，则可通过指定深度选项 `-maxdepth`/`-mindepth` 来限制 find 遍历查找的深度。

- 如果只允许 find 在当前目录中查找，深度可以设置为1；  
- 当需要向下两级时，深度可以设置为2；
- 其他情况可以依次类推。  

通过 `-maxdepth` 选项可指定最大搜索深度。
以下示例将 find 命令的最大搜索深度限制为1：

```bash
$ find . -maxdepth 1 -name "f*" -print
```

该命令列出当前目录下的所有名称以 f 打头的文件（夹）。
`-maxdepth 2` 则表示最多向下遍历两级子目录。

通过 `-mindepth` 选项则可用来查找并打印那些距离起始路径一定深度的所有文件。
如果想从第二级目录开始搜索，那么使用 `-mindepth 2` 可设置最小深度为2。
以下示例打印出深度距离当前目录至少两个子目录的所有文件：

```bash
$ find . -mindepth 2 -name "f*" -print
```

查找一级目录和二级目录下的 conf 文件：

```bash
$ find / -type f -name "*.conf" -not -path "/etc/fonts/*" ! -path "*/tmpfiles.d/*" -maxdepth 2 2>/dev/null
```

部分结果如下：

```bash
/etc/deluser.conf
/etc/sudo.conf
/etc/fuse.conf
/etc/overlayroot.conf
/etc/host.conf
/etc/adduser.conf
/etc/multipath.conf
/etc/ca-certificates.conf # line
/etc/sysctl.conf
/etc/ucf.conf
```

查找三级目录下的 conf 文件：

```bash
$ find / -type f -name "*.conf" -not -path "/etc/fonts/*" ! -path "*/tmpfiles.d/*" -mindepth 3 -maxdepth 3 2>/dev/null
```

部分结果如下：

```bash
/etc/avahi/avahi-daemon.conf
/etc/ldap/ldap.conf
/etc/pulse/client.conf
/etc/dhcp/dhclient.conf
/etc/ufw/ufw.conf
/etc/ufw/sysctl.conf
/etc/systemd/user.conf
/etc/systemd/resolved.conf
/etc/systemd/system.conf
/etc/systemd/sleep.conf
/etc/systemd/networkd.conf
/etc/udev/udev.conf
/etc/PackageKit/Vendor.conf
/etc/PackageKit/PackageKit.conf
/etc/lvm/lvm.conf
```

查找限定四级目录下的部分结果：

```bash
/run/NetworkManager/conf.d/netplan.conf
/run/systemd/resolve/resolv.conf
/usr/lib/systemd/resolv.conf
/usr/share/ufw/ufw.conf
/usr/share/adduser/adduser.conf
```

#### -prune

使用 `-prune` 选项可使 find 命令不在当前指定的目录中查找。
如果同时使用了 `-depth` 选项，那么 `-prune` 选项将被find命令忽略。

在搜索目录并执行某些操作时，有时为了提高性能，需要跳过一些子目录。
以下命令打印出不包括在 `.git` 目录中的所有文件的名称（路径）。

```bash
$ find workspace/project \( -name ".git" -prune \) -o \( -type f \)
```

以下为 find 的 man page 中的两个相关示例：

```bash
     find /usr/src -name CVS -prune -o -depth +6 -print
             Find files and directories that are at least seven levels deep in the working directory
             /usr/src.

     find /usr/src -name CVS -prune -o -mindepth 7 -print
             Is not equivalent to the previous example, since -prune is not evaluated below level seven.
```

## utility

### -exec

find 有一个选项 `-exec`，支持对每个find查找到的文件执行命令。

```bash
     -exec utility [argument ...] ;
             True if the program named utility returns a zero value as its exit status.  Optional
             arguments may be passed to the utility.  The expression must be terminated by a semicolon
             (``;'').  If you invoke find from a shell you may need to quote the semicolon if the shell
             would otherwise treat it as a control operator.  If the string ``{}'' appears anywhere in the
             utility name or the arguments it is replaced by the pathname of the current file.  Utility
             will be executed from the directory from which find was executed.  Utility and arguments are
             not subject to the further expansion of shell patterns and constructs.

     -exec utility [argument ...] {} +
             Same as -exec, except that ``{}'' is replaced with as many pathnames as possible for each
             invocation of utility.  This behaviour is similar to that of xargs(1).
```

> `{}` 表示一个匹配，对于任何匹配的文件名，`{}` 均会被该文件名所替换。

以下将 find 结果执行 `echo` 打印：

```bash
$ find . -type f -exec echo {} \;
```

结束分号（`;`）如果不加反斜杠转义的话，将会报错：

```bash
$ find . -type f -exec echo {} ;
find: -exec: no terminating ";" or "+"
```

为什么分号（`;`）需要转义呢？因为 Bash Shell 中使用空格或分号（**`;`**）连接无相关性的连续命令，即分号本身是一个 control operator。  

查找当前目录中的所有名为 `DerivedData` 的文件夹，并执行 `du -hs` 统计输出各个文件夹的磁盘占用大小。

```bash
$ find . -type d -name DerivedData -exec du -hs {} \;
385M	./Classes/base/WXBaseUtil/DerivedData
 22M	./Frameworks/WX/PublicProtocolFiles/DerivedData
 17G	./DerivedData
```

排除 `./ten/mars` 目录：

```bash
$ find . \( -name ./ten/mars -prune \) -o \( -type d -name DerivedData \) -exec du -hs {} \;
```

以下示例查找 `OfflineFile` 目录下所有的 cpp 文件，并将查找到的文件名存储到 `all_cpp_files.txt` 中。

```bash
$ find OfflineFile -type f -iname "*.cpp" > all_cpp_files.txt
```

这里使用 `>` 操作符将来自 find 的数据（CPP代码）重定向到 all_cpp_codes.cpp 文件。
没有使用 `>>`（追加）是因为 find 命令的全部输出就只有一个数据流（stdin），而只有当多个数据流被追加到单个文件中时才有必要使用 `>>`。

若要将查找到的所有cpp文件拼接写入一个文件 `all_cpp_codes.cpp`，则可借助 `-exec cat` 打开查看文件内容并重定向实现拼接：

```bash
$ find OfflineFile -type f -iname "*.cpp" -exec cat {} \; > all_cpp_codes.cpp
```

下面对查找到的所有文件名为 `JceObjectV2.h` 的文件（包括软链替身），进一步执行 `ls -F` 列举打印各文件属性，以便区分哪些是文件哪些是软链：

```bash
$ find . -name 'JceObjectV2.h' \( -type f -o -type l \) -exec ls -F {} \;
./Classes/extern/Analytics/BuglyOA/BuglyCocoa/BuglyCocoa/JceProtocol/CocoaJce/JceObjectV2.h*
./Classes/module/WaterMarkCamera/3rd/WirelessUnifiedProtocol/Serializable/JceObjectV2.h*
./Pods/CocoaJCE/Include/JceObjectV2.h*
./Pods/Headers/Private/CocoaJCE/JceObjectV2.h@
./Pods/Headers/Public/CocoaJCE/JceObjectV2.h@
```

#### +

有时候并不希望对每个文件都执行一次命令，而是希望使用**文件列表**作为命令参数，这样就可以少运行几次命令了。  
此种场景下，可以在 exec 中使用 `+` 来代替 `;` 达到预期效果。

以下man page中的示例删除 `/usr/ports/packages` 目录下所有失效的软链（源文件），这在系统维护清理软件包管理过程中可能产生的残留符号链接非常有用。

> `-L` 替代旧的 `-follow`，启用符号链接跟随模式，跟随符号链接并检查链接指向的目标文件状态，以便识别损坏链接。`-type l` 结合 `-L` 能检测到软链失效状态。
> `--` 为选项结束标记，即没有选项，防止文件名以 `-` 开头时被误认为选项。
> `+`：批量处理，将多个文件一次性传递给 rm 命令，比使用 `\;` 更高效。

```bash
# 建议执行前先查找预览
$ find -L /usr/ports/packages -type l -ls

# Delete all broken symbolic links in /usr/ports/packages.
$ find -L /usr/ports/packages -type l -exec rm -- {} +
```

等效命令如下：

```bash
# 使用 -delete 动作（更简洁）
find -L /usr/ports/packages -type l -delete

# 使用 xargs 处理
find -L /usr/ports/packages -type l -print0 | xargs -0 rm
```

以下示例中，查找当前目录下大小超过1M的文件，将结果汇聚为列表一次性传递给 `du -csh` 查看所占磁盘容量，进而管传给 sort 降序排列。

```bash
$ find . -size +1M -exec du -csh -- {} + | sort -rh
```

以下示例中，`-exec utility [argument ...] ;` 结果正确，但是报错 No such file or directory：

```bash
$ find testDir1 -type d -name "__MACOSX" -exec rm -rf {} \;
```

改为 `-exec utility [argument ...] {} +` 格式，则运行正常，不再报错：

```bash
$ find testDir1 -type d -name "__MACOSX" -exec rm -rf -- {} \+
```

### xargs

xargs 和 find 算是一对好基友，两者结合使用可以让任务变得更轻松。

#### usage

`find -exec utility [argument ...] {} +` 可以改为基于 `find | xargs` 的等效实现。  

上述查找当前目录中的所有名为 `DerivedData` 的文件夹并执行 `du -hs` 输出大小的示例，也可改为基于 xargs 的等效实现。

```bash
$ find . -type d -name DerivedData | xargs du -hs
```

上面查找拼接 all_cpp_codes 示例，也可借助 ls-grep 及 xargs 等效实现：

```bash
# 需要先 cd 到 OfflineFile 目录
# cat 找到的所有 cpp 文件，都重定向到 all 文件，相当于拼接
$ ls -R | grep '.*\.cpp$' | xargs cat > all_cpp_codes.cpp
# or
$ find OfflineFile -type f -iname "*.cpp" | xargs cat > all_cpp_codes.cpp
```

上面查找文件 `JceObjectV2.h` 并执行 `ls -F` 列举文件类型的 xargs 等效实现如下：

```bash
$ find . -name 'JceObjectV2.h' \( -type f -o -type l \) | xargs ls -F
```

上面查找当前目录下大小超过1M的文件，并将文件列表管传 `du -csh` 查看所占磁盘容量，进而管传给 sort 降序排列，改为基于 xargs 的等效实现如下：

```bash
# 注意：如果文件路径中子目录存在空格，例如 Visual Studio，则会报错！
$ find . -size +1M | xargs du -csh | sort -rh
```

上面统计过 `OfflineFile` 文件夹下所有参与编译的文件（Compile Sources）数量。
进一步思考，如何统计该子工程目录下所有参与编译的代码文件的代码行数呢？
借助 `xargs` 对每个文件执行 `wc -l` 行数统计即可。

```bash
$ find OfflineFile -type f \( -iname "*.c" -o -iname "*.cpp" -o -iname "*.m" -o -iname "*.mm" \) -print0 | xargs -0 wc -l

   98021 total
```

> 以上指定 `-print0` 替代隐含默认的 `-print` 将使用 `\0` 代替 `\n` 作为结果分隔符，每个文件（名/路径）后都隐含有一个字符 NUL（`\0`）。然后再通过 `xargs -0` 指定以 `\0` 而非 `\n` 来作为参数分隔符，从而正确获取参数列表，逐个文件调用 `wc -l` 统计每个文件中的行数。

当然，以上统计代码行数，包括了注释和空行部分，更专业的统计工具参考 [SLOCCount](https://dwheeler.com/sloccount/) 和 [cloc](https://github.com/AlDanial/cloc/)。

#### -t

xargs 的 `-t` 选项允许每次执行 xargs 后面的命令之前，先在 stderr 上打印出扩展开的真实命令。

```bash
$ find . -type d -iname "xcuserdata" | xargs -t rm -rf
rm -rf ./EmptyApplication.xcodeproj/xcuserdata ./EmptyApplication.xcodeproj/project.xcworkspace/xcuserdata

$ find . -type f -name "*.txt" | xargs -t ls -1lhFA
ls -1lhFA ./detail2.txt ./detail.txt ./data0.txt ./data1.txt ./data3.txt ./data2.txt ./data6.txt ./data.txt
...
```

以上 -t 调试输出，也验证了 xargs 同 `find -exec utility [argument ...] {} +` 的等效性。

#### -0

xargs 默认是以空白字元作为分割符，如果有一些档名或者是其他意义的名词内含有空白字元的时候，xargs 可能会误判分割导致参数错误。

> linux 下支持 `-d delim` 选项，macOS Shell 不支持。

我们无法预测分隔 find 命令输出结果的定界符究竟是什么（`\n` 或者空格），很多文件名中都可能会包含空格符（' '），因此 xargs 很可能会误认为它们是定界符。

接下来我们结合一个具体的例子，来分析一下 `find -print0` 和 `xargs -0` 选项的作用。

假设 testDir 目录结构如下，其中部分子目名称中带有空格：

```bash
$ tree -a
.
├── testDir1
├── testDir2
│   ├── testDir 21
│   │   ├── testDir211
│   │   │   └── .DS_Store
│   │   ├── testDir212
│   │   │   └── __MACOSX
│   │   └── testDir213
│   └── testDir23
│       ├── hello world.txt
│       └── test.txt
└── testDir3
    ├── testDir 31
    │   └── .DS_Store
    ├── testDir 32
    │   ├── testDir321
    │   │   └── __MACOSX
    │   │   └── .DS_Store
    │   └── testDir323
    │       ├── testDir3231
    │       └── testDir3232
    └── testDir33
```

`find` 默认对匹配到的文件（路径）执行打印操作（`-print`），以换行符 `\n` 作为分隔符将结果行（条目）进行分隔输出到控制台。

```bash
$ find . -type f -name ".DS_Store"
./testDir3/testDir 32/testDir322/.DS_Store
./testDir3/testDir 31/.DS_Store
./testDir2/testDir 21/testDir211/.DS_Store
```

尝试将 `find` 出的文件（路径）通过 `xargs` 管传作为参数传给 `ls -l` 列举查看每个文件的详细信息（The Long Format）。

当然，可以直接通过 find 支持的 `-ls` 选项来实现相同功能：`find . -type f -name ".DS_Store" -ls`。此处仅为演示 `xargs` 的使用。

ls 默认以空白作为参数列表分隔符，包含空格的文件路径被错误切割，导致报错 No such file or directory：

```bash
$ find . -type f -name ".DS_Store" | xargs -t ls -1
ls -1 ./testDir3/testDir 32/testDir322/.DS_Store ./testDir3/testDir 31/.DS_Store ./testDir2/testDir 21/testDir211/.DS_Store
ls: ./testDir2/testDir: No such file or directory
ls: ./testDir3/testDir: No such file or directory
ls: ./testDir3/testDir: No such file or directory
ls: 21/testDir211/.DS_Store: No such file or directory
ls: 31/.DS_Store: No such file or directory
ls: 32/testDir322/.DS_Store: No such file or directory
```

执行如下改进，可实现 `-ls` 同等效果：

首先，将 `find` 命令隐含的 `-print` 改为 `-print0`，指明使用 `\0` 代替 `\n` 作为结果分隔符。输出看起来是一行（实际上结尾没有换行符）：

```bash
$ find . -type f -name ".DS_Store" -print0
./testDir3/testDir 32/testDir322/.DS_Store./testDir3/testDir 31/.DS_Store./testDir2/testDir 21/testDir211/.DS_Store%
```

可以对 `find -print` 和 `find -print0` 结果管传给 `wc -l` 统计找到的结果（行）数看出它们的作用差异：

```bash
$ find . -type f -print | wc -l
       3

# 没有换行符，所以统计结果为0行
$ find . -type f -print0 | wc -l
       0
```

然后，为 `xargs` 添加 `-0` 选项，指定与 `find -print0` 输出一致的 NUL 字符（`\0`）作为导入参数列表分隔符。

> `-0, --null`: Change xargs to expect NUL (`\0`) characters as separators, instead of spaces and newlines.
>> This is expected to be used in concert with the `-print0` function in find(1).

这样，find 输出和 xargs 导入解析的分隔符一致，结果符合预期：

```bash
$ find . -type f -name ".DS_Store" -print0 | xargs -t0 ls -1
ls -1 ./testDir3/testDir 32/testDir322/.DS_Store ./testDir3/testDir 31/.DS_Store ./testDir2/testDir 21/testDir211/.DS_Store
./testDir2/testDir 21/testDir211/.DS_Store
./testDir3/testDir 31/.DS_Store
./testDir3/testDir 32/testDir322/.DS_Store
```

之前的例子中，如果文件路径中子目录存在空格（例如 Visual Studio），都会报错！

```bash
$ find . -type f -name "*.txt" | xargs rm -f
$ find . -size +1M | xargs du -csh | sort -rh
```

`find -print0` 搭配 `xargs -0` 使用一致的参数列表分割符，则可安全处理可能包含空格导致的路径问题：

```bash
$ find . -type f -name "*.txt" -print0 | xargs -0 rm -f
$ find . -type f -size +1M -print0 | xargs -0 du -csh | sort -rh
```

### demos

#### exclude dir

需求：find 查找 / 四级以内目录下的的所有 conf 文件，排除 /etc/fonts/ 和路径包含 tmpfiles.d 的目录，如下：

- ./etc/fonts/  
- ./etc/tmpfiles.d/  
- ./usr/lib/tmpfiles.d/  

[Exclude Certain Paths With the find Command](https://www.baeldung.com/linux/find-exclude-paths)  

```bash
# 2. Using the -prune Option
$ find . \( -path ./jpeg -prune -o -path ./mp3 -prune \) -o -print
# 3,4. Using the -not/! Operator; 
$ find . -type f -not -path '*/mp3/*'
```

[Find command Exclude or Ignore Files (e.g. Ignore All Hidden .dot Files )](https://www.cyberciti.biz/faq/find-command-exclude-ignore-files/)  

```bash
# find all *.txt files in the current directory but exclude ./Movies/, ./Downloads/, and ./Music/ folders:
$ find . -type f -name "*.txt" ! -path "./Movies/*" ! -path "./Downloads/*" ! -path "./Music/*" 
```

实测：

```bash
# 仅忽略了 /etc/fonts/*/*，还是打印 /etc/fonts/conf.avail,/etc/fonts/fonts.conf,/etc/fonts/conf.d
$ find / \( -path "/etc/fonts/*" -prune -o -path "*/tmpfiles.d/*" -prune \) -o -name "*.conf" -maxdepth 4
$ find / -type d \( -path "/etc/fonts/*" -o -path "*/tmpfiles.d/*" \) -prune -o -name "*.conf" -maxdepth 4
# 找到了路径匹配了两个目录，且后缀为conf的文件，与预期相反的结果
$ find / \( -path "/etc/fonts/*" -prune -o -path "*/tmpfiles.d/*" -prune \) -name "*.conf" -maxdepth 4
$ find / \( -path "/etc/fonts/*" -o -path "*/tmpfiles.d/*" \) -prune -name "*.conf" -maxdepth 4
# 符合预期！
$ find / -type f -name "*.conf" -not -path "/etc/fonts/*" ! -path "*/tmpfiles.d/*" -maxdepth 4
```

[How to exclude a directory in find . command](https://stackoverflow.com/questions/4210042/how-to-exclude-a-directory-in-find-command)  

https://stackoverflow.com/a/15736463

If -prune doesn't work for you, this will:

```bash
$ find -name "*.js" -not -path "./directory/*"
```

https://stackoverflow.com/a/4210072

```bash
# Use the -prune primary. For example, if you want to exclude ./misc:
$ find . -path ./misc -prune -o -name '*.txt' -print

# To exclude multiple directories, OR them between parentheses.
$ find . -type d \( -path ./dir1 -o -path ./dir2 -o -path ./dir3 \) -prune -o -name '*.txt' -print

# And, to exclude directories with a specific name at any level, use the -name primary instead of -path.
$ find . -type d -name node_modules -prune -o -name '*.json' -print

# From ~/ on my macOS cleans it up nicely ?
$ find . -type d \( -path "./Library/*" -o -path "./.Trash" \) -prune -o -name '.DS_Store' -print0 | xargs -0 rm
```

https://stackoverflow.com/a/16595367

```bash
# I find the following easier to reason about than other proposed solutions:
$ find build -not \( -path build/external -prune \) -name \*.js
# you can also exclude multiple paths
$ find build -not \( -path build/external -prune \) -not \( -path build/blog -prune \) -name \*.js
```

https://stackoverflow.com/a/4210234

I prefer the -not notation ... it's more readable:

```bash
$ find . -name '*.js' -and -not -path directory
```

https://stackoverflow.com/a/49296451

This is the only one that worked for me.

```bash
# Searching for "MyFile" excluding "Directory".
# Give emphasis to the stars * .
# works on macOS
$ find / -name MyFile ! -path '*/Directory/*'
# locate native package.json
$ find . -name package.json ! -path '*/node_modules/*'
```

另外，find / 还会有大量访问权限受限的错误提示：`find: ‘/lost+found’: Permission denied`。

[How can I exclude all "permission denied" messages from "find"?](https://stackoverflow.com/questions/762348/how-can-i-exclude-all-permission-denied-messages-from-find)

所以最终的答案如下：

```bash
$ find / -type f -name "*.conf" -not -path "/etc/fonts/*" ! -path "*/tmpfiles.d/*" -maxdepth 4 2>/dev/null
$ find / -not \( -path "/etc/fonts/*" -prune \) -not \( -path "*/tmpfiles.d/*" -prune \) -name "*.conf" -maxdepth 4 2>/dev/null
$ find nodejs/src -type f -iname "*banner.vue" -not -path "nodejs/src/node_modules/*" -not -path "nodejs/src/dist/*" 2>/dev/null
```

#### delete file

`-delete` 操作可以用来删除 find 匹配出来的结果文件（夹）。

递归查找当前目录及其子目录下所有的 `.o`/`.DS_Store` 文件，然后执行 `-delete` 删除操作。

```bash
# 末尾可追加 -print 打印删除的文件
$ find . -name "*.o" -delete
$ find . -type f -name ".DS_Store" -delete
```

> 默认执行 `-print` 打印查找结果；  
> 可显式指定 `-type f` 只查找文件类型；  

还可针对结果执行 `-exec rm` 或重定向给 xargs 作为参数执行 `rm` 命令。
以下示例清除 macOS 文件夹下自动生成的 `.DS_Store` 文件：

```bash
# 运行正常（末尾可追加 -print 打印删除的文件）
find testDir1 -name ".DS_Store" -exec rm -rf {} \;
# 运行正常（末尾可追加 -print 打印删除的文件）
find testDir1 -name ".DS_Store" -exec rm -rf -- {} \+
# 运行正常
find testDir1 -name ".DS_Store" -print0 | xargs -0 rm -rf
```

以下示例清除 visual studio 工程 sln/vcproj 下的 `*.user` 文件：

```bash
# delete file: *.user
echo "delete files: *.user"
#find . -name "*.user" -delete
#find . -name "*.user" -exec rm {} \;
find . -name "*.user" -print0 | xargs -0 rm -f
```

#### delete folder

一般 git 仓库的会配置忽略一些临时目录或文件，例如 __MACOSX、.DS_Store 等。
find 查找当前目录及其子目录下所有的 `__MACOSX` 目录，然后通过 `-delete` 删除之。

但是，-delete 删除目录时底层调用的应该是 rmdir，只能删除空目录，无法删除非空目录。
此时，可考虑将 find 结果管传给 xargs 作为参数进一步传递给 `rm -rf` 执行递归删除。

```bash
# 结果正确，报错 No such file or directory
$ find testDir1 -type d -name "__MACOSX" -exec rm -rf {} \;
# 运行正常（末尾可追加 -print 打印删除的文件夹）
$ find testDir1 -type d -name "__MACOSX" -exec rm -rf -- {} \+
# 运行正常
$ find testDir1 -type d -name "__MACOSX" -print0 | xargs -0 rm -rf
```

以下示例，查找当前目录下的 __MACOSX 子目录和隐藏文件 .DS_Store，并予以删除：

> **注意**：一定要添加括号表达式，否则 -o 后面部分进行了逻辑结合，运行结果非预期！

```bash
# 结果正确，报错 No such file or directory
$ find testDir1 \( -name "__MACOSX" -o -name ".DS_Store" \) -exec rm -rf {} \;
# 运行正常（末尾可追加 -print 打印删除的文件夹）
$ find testDir1 \( -name "__MACOSX" -o -name ".DS_Store" \) -exec rm -rf -- {} \+
# 运行正常
$ find testDir1 \( -name "__MACOSX" -o -name ".DS_Store" \) -print0 | xargs -0 rm -rf
```

---

以下示例清除指定目录下的文件夹（rm -rf递归强制删除）：

```bash
find "$targetDir"  -maxdepth 1 ! -path "$targetDir" -type d -print0 | xargs -0 rm -rf
```

以下示例清除 visual studio 工程 sln/vcproj 下编译生成的 `Debug` 文件夹：

```bash
# delete folder: Debug
echo "delete folder: Debug"
find . -type d -iname "debug" -print0 | xargs -0 rm -rf
```

以下示例清除 xcodeproj 目录下的 `xcuserdata` 文件夹：

```bash
# delete folder: xcuserdata
echo "delete folder: xcuserdata"
find . -type d -iname "xcuserdata" -print0 | xargs -0 rm -rf
```

以下示例清除 python 运行过程中生成的 `__pycache__` 文件夹：

```bash
# delete folder: __pycache__
echo "delete folder: __pycache__"
find . -type d -iname "__pycache__" -print0 | xargs -0 rm -rf
```

#### format files

`clang-format` 貌似只接受单个文件路径作为格式化目标参数。

```bash
$ cd ~/Projects/mars
$ clang-format -style=file -i mars/comm/messagequeue/message_queue.cc
```

如果想批量格式化某个子目录下的所有代码文件，可以在终端执行以下命令：

```bash
$ # 设置要格式化的子目录
$ subdir="mars/comm/messagequeue/"
```

find 递归查找并 more 滚动预览或统计 subdir 下将要格式化的代码文件：

```bash
# 或管传 | wc -l 统计数量
$ find $subdir -type f \( -iname "*.h" -iname "*.hpp" -iname "*.c" -o -iname "*.cpp" -o -iname "*.m" -o -iname "*.mm" \) | more
```

将 find 结果重定向给 xargs 传参给 clang-format 执行格式化：

```bash
$ find $subdir -type f \( -iname "*.h" -iname "*.hpp" -iname "*.c" -o -iname "*.cpp" -o -iname "*.m" -o -iname "*.mm" \) -print0 | xargs -0 clang-format --verbose -style=file -i
```

find 的 path 参数可接受多个目录：

```bash
$ subdir1="mars/comm/messagequeue/"
$ subdir2="mars/comm/coroutine/"
$ find $subdir1 $subdir2 -type f \( -iname "*.h" -iname "*.hpp" -iname "*.c" -o -iname "*.cpp" -o -iname "*.m" -o -iname "*.mm" \) -print0 | xargs -0 clang-format --verbose -style=file -i
```

#### copy files

下面示例将所有的.mp3文件移入目录 targetDir：

```bash
$ find $dirPath -type f -name "*.mp3" -exec mv {} $targetDir \;
```

下面示例将10天前的.txt文件备份到目录 targetDir：

```bash
$ find $dirPath -type f -mtime +10 -name "*.txt" -exec cp {} $targetDir \;
```

考虑这么一个需求场景：在Xcode工程的构建目录下，查找所有文件夹下的 `.d` 文件，然后拷贝到 `~/Downloads/dependencies` 目录下。

除了上面的 find -exec 实现方案外，基于while循环的子shell的表达实现如下：

```bash
$ cd DerivedData/Mars/Build/Intermediates.noindex
$ find . -type f -name "*.d" | (while read line; do cp $line ~/Downloads/dependencies; done)
```

实际运行展开如下：

```bash
cp -v file1.d ~/Downloads/dependencies
cp -v file2.d ~/Downloads/dependencies
...
```

到目前为止的 utility 用例场景，都是直接为特定的命令（例如 echo,cat,du,ls,rm）提供命令行参数，这些参数都直接源于 stdin，只是借助重定向 xargs 实现管接。

但在本案例中，cp 命令的拷贝目标文件夹（`target_directory`）是固定不变的，拷贝源参（`source_file`）则需要 find | xargs 提供。

此时可考虑借助 xargs 的 `-I` 选项，指定替换字符串为 `replstr`，将从 stdin 读取到的参数，替换掉 utility 命令中的占位参数（placeholder） `replstr`。

```bash
     -I	replstr
	     Execute utility for each input line, replacing one	or more	occur-
	     rences of replstr in up to	replacements (or 5 if no -R flag is
	     specified)	arguments to utility with the entire line of input.
```

基于 xargs 的更加简洁高效的等效表达如下：

```bash
# replstr = {}
$ find . -type f -name "*.d" -print0 | xargs -0 -I {} cp {} ~/Downloads/dependencies
```

使用 `-I` 的时候，命令以循环的方式执行。如果有3个参数（即 find 出了3个.d文件），那么命令就会连同 `{}` 一起被执行3次。  
在每一次的 cp 命令执行中，source_file 参数占位符 `{}` 都会被替换为 xargs 传递的相应参数作为拷贝源。

---

为方便调试及理解，可以给 xargs 带上 `-t` 选项，查看循环执行的cp命令展开。再配合 cp 的 `-v` 选项，可以看到拷贝流程。  
这样，命令行执行输出就更明了了：

```bash
# replstr = srcd
$ find . -type f -name "*.d" -print0 | xargs -0t -I srcd cp -v srcd ~/Downloads/dependencies
cp -v ./cDACoreOperateCallBack.d /Users/faner/Downloads/dependencies
./cDACoreOperateCallBack.d -> /Users/faner/Downloads/dependencies/cDACoreOperateCallBack.d
cp -v ./cDACoreListenerCallBack.d /Users/faner/Downloads/dependencies
./cDACoreListenerCallBack.d -> /Users/faner/Downloads/dependencies/cDACoreListenerCallBack.d
...
```

> 思考：xargs 如何一次性传递多个参数给后面的 utility 命令呢？这涉及到 `xargs -n` 分段划批和 Bash Shell 命令参数列表。

#### edit files

经常需要将某个目录中的所有符合条件的文件内的一部分文本进行替换，例如在网站的源文件目录中替换一个URI。

案例1：dos2unix 批量替换 - 在 vim 下执行 `:%s/\r//g` 可将DOS文件中的回车符 `^M` 替换为空（即删除）。

```bash
find ./ -type f print0 | xargs -0 sed -i 's/^M$//'
```

---

案例2：遍历项目目录下的所有.cpp文件，并将每个.cpp文件中的 Copyright 替换成 Copyleft。

可以使用find命令的 `-exec` 选项执行 sed 命令对每个查找到的文件执行查找替换：

```bash
# 为每个查找到的文件调用一次sed
$ find . -name "*.cpp" -exec sed -i '' 's/Copyright/Copyleft/g' {} \;
# 或者将多个文件名一并传递给sed
$ find . -name "*.cpp" -exec sed -i '' 's/Copyright/Copyleft/g' {} \+
```

当然，也可以对find结果重定向给 ` | xargs -I{}` 作为参数调用 sed 编辑替换：

```bash
$ find . -name "*.cpp" -print0 | xargs -0 -I{} sed -i '' 's/Copyright/Copyleft/g' {}
```

如果头部没有包含 Copyright 或 Copyleft，可以在头部补插一条标准的版权声明：

```bash
# replstr = file
$ find . -name "*.cpp" -print0 | xargs -0 -I file sed -i '' '1i\
// Tencent is pleased to support the open source community by making Mars available.\
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.\

' file
```
