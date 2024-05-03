---
title: Linux Command - grep
authors:
  - xman
date:
    created: 2019-11-02T10:00:00
categories:
    - wiki
    - linux
    - command
tags:
    - grep
comments: true
---

grep 过滤筛选出符合条件的行，起源于 vim（ex）编辑器中的模式匹配命令：`:g/re/p`。
grep命令会在输入或指定的文件中查找包含匹配指定模式的字符的行，输出就是包含了匹配模式的行。

<!-- more -->

以下是各大平台对 grep 的定义：

- unix/POSIX、debian、ubuntu：`grep` - search a file for a pattern  
- FreeBSD/Darwin：`grep`, egrep, fgrep, rgrep -- file pattern searcher  
- macOS：`grep`, egrep, fgrep, zgrep, zegrep, zfgrep -- file pattern searcher
- linux：`grep` - print lines that match patterns  

执行 `grep -V` 查看版本信息：

```Shell
# macOS
> grep -V
grep (BSD grep) 2.5.1-FreeBSD

# raspberrypi
pi@raspberrypi:~ $ grep -V
grep (GNU grep) 2.27
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

## man

以下是各大平台的 grep 在线手册：

- unix/POSIX - [grep](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/grep.html)
- FreeBSD/Darwin - [grep](https://www.freebsd.org/cgi/man.cgi?query=grep)  

- linux - [grep(1)](http://man7.org/linux/man-pages/man1/grep.1.html) & [grep(1p)](http://man7.org/linux/man-pages/man1/grep.1p.html)  
- debian - [grep](https://manpages.debian.org/buster/9base/grep.1plan9.en.html)  

- ubuntu - [grep](https://manpages.ubuntu.com/manpages/jammy/en/man1/grep.1plan9.html)  

- Windows - [findstr](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr)  

### usage

执行 `grep --help` 可查看简要帮助（Usage）。  

执行 `man grep` 可查看详细帮助手册（Manual Page）：

```Shell
# macOS
$ man grep
GREP(1)                   BSD General Commands Manual                  GREP(1)

NAME
     grep, egrep, fgrep, zgrep, zegrep, zfgrep -- file pattern searcher

SYNOPSIS
     grep [-abcdDEFGHhIiJLlmnOopqRSsUVvwxZ] [-A num] [-B num] [-C[num]] [-e pattern] [-f file]
          [--binary-files=value] [--color[=when]] [--colour[=when]] [--context[=num]] [--label]
          [--line-buffered] [--null] [pattern] [file ...]

DESCRIPTION
     The grep utility searches any given input files, selecting lines that match one or more patterns.  By
     default, a pattern matches an input line if the regular expression (RE) in the pattern matches the
     input line without its trailing newline.  An empty expression matches every line.  Each input line
     that matches at least one of the patterns is written to the standard output.

     grep is used for simple patterns and basic regular expressions (BREs); egrep can handle extended reg-
     ular expressions (EREs).  See re_format(7) for more information on regular expressions.  fgrep is
     quicker than both grep and egrep, but can only handle fixed patterns (i.e. it does not interpret reg-
     ular expressions).  Patterns may consist of one or more lines, allowing any of the pattern lines to
     match a portion of the input.

     zgrep, zegrep, and zfgrep act like grep, egrep, and fgrep, respectively, but accept input files com-
     pressed with the compress(1) or gzip(1) compression utilities.
```

查看正则表达式（regex）相关的手册：

```Shell
faner@MBP-FAN:~|⇒  man 7 re_format
faner@MBP-FAN:~|⇒  man 3 regex
```

## options

### Pattern Syntax

以下为 `man grep` 中的模式说明：

```Shell
OPTIONS

   Generic Program Information
       --help Output a usage message and exit.

       -V, --version
              Output the version number of grep and exit.

   Matcher Selection
       -E, --extended-regexp
              Interpret PATTERN as an extended regular expression (ERE, see below).

       -F, --fixed-strings
              Interpret PATTERN as a list of fixed strings (instead of regular expressions), separated by newlines, any of which is to be matched.

       -G, --basic-regexp
              Interpret PATTERN as a basic regular expression (BRE, see below).  This is the default.

       -P, --perl-regexp
              Interpret the pattern as a Perl-compatible regular expression(PCRE).  This is experimental and grep -P may warn of unimplemented features.
```

`grep`, `egrep`, `fgrep` - print lines matching a pattern

the variant programs **`egrep`** and **`fgrep`** are the same as `grep -E` and `grep -F`, respectively.  
These variants are **deprecated**, but are provided for backward compatibility.  

默认选项是 `-G`(`--basic-regexp`)，即 **BRE**。  
如果要支持 **`?`**, **`+`** 和 **`|`**，则需要显式指定 `-E` 选项，即执行 **ERE**。

### Matching Control

1. `-e` 支持输入多个模式；  
2. `-i`：支持忽略大小写敏感；  
3. `-v`：支持输出不匹配的行；  

```Shell

-e pattern, --regexp=pattern

  Specify a pattern used during the search of the input: an input line is selected if it matches
  any of the specified patterns.  
  This option is most useful when multiple -e options are used to
  specify multiple patterns, or when a pattern begins with a dash (`-`).

# 默认大小写敏感，该选项支持忽略大小写敏感
  -i, --ignore-case         ignore case distinctions

# 匹配补集，过滤输出不包含模式的行
  -v, --invert-match        select non-matching lines

# 匹配整个单词、整行
  -w, --word-regexp         force PATTERN to match only whole words
  -x, --line-regexp         force PATTERN to match only whole lines
```

### General Output Control

1. `-l` 只输出匹配的文件名；  
2. `-c` 只输出匹配的行数（条目数）；  
3. `-m` 限定最多查找匹配条目数；  
4. `-q` 预检判断是否存在匹配条目；  

```Shell
Output control:
# 只打印匹配的部分，而非匹配的行，用的较少
  -o, --only-matching
          Prints only the matching part of the lines.

# 输出文件名+匹配行
  -H, Always print filename headers with output lines.

# 只列举（不）满足匹配条件的文件名，不输出具体的匹配行
  -L, --files-without-match  print only names of FILEs containing no match
  -l, --files-with-matches  print only names of FILEs containing matches

# 仅打印匹配的行数，用于统计匹配条目数
  -c, --count               print only a count of matching lines per FILE

# 最多查找条目（达标停止查找），也可以 grep | head -n NUM 截取只输出前N个匹配结果
  -m, --max-count=NUM       stop after NUM matches

# 不向STDOUT输出结果，只要匹配到了一条即退出（相当于 -m 1），适合只判断是否匹配而不关注具体匹配结果的场景。
## 也可用于大量查找的预测试，用 $? 来判断匹配结果：0 表示成功匹配（到一条）；1 表示匹配失败。
  -q, --quiet, --silent
          Quiet mode: suppress normal output.  grep will only search a file until a match has been found,
          making searches potentially less expensive.

# 当传入的文件或文件夹不存在时，屏蔽不输出 No such file or directory 等错误提示信息，避免淹没查找结果。
  -s, --no-messages
          Silent mode.  Nonexistent and unreadable files are ignored (i.e. their error messages are sup-
          pressed).
```

### Context Line Control

指定输出查找结果上下文信息。

```Shell
# 顺便打印查找结果上面 NUM 行
  -B, --before-context=NUM  print NUM lines of leading context
# 顺便打印查找结果下面 NUM 行
  -A, --after-context=NUM   print NUM lines of trailing context
# 顺便打印查找结果上面和下面各 NUM 行
  -C, --context=NUM         print NUM lines of output context
  -NUM                      same as --context=NUM

```

### Output Line Prefix Control

1. `-h`：不输出文件名，只输出匹配行；  
2. `-n`：打印匹配行的行号；  

```Shell

  -b, --byte-offset         print the byte offset with output lines

# 默认为 -H，输出匹配的文件名和行信息；指定 -h 则不输出文件名，只输出匹配行
  -H      Always print filename headers with output lines.
  -h, --no-filename
          Never print filename headers (i.e. filenames) with output lines.

# 顺便打印行号
  -n, --line-number         print line number with output lines
      --line-buffered       flush output on every line

```

### File and Directory Selection

`-r` 递归搜索目录，遍历查找指定目录及其子目录下的所有文件。

```Shell
# 递归遍历查找指定目录及其子目录下的所有文件
  -R, -r, --recursive       Recursively search subdirectories listed.

# 将二进制文件当做文本文件处理
  -a, --text                equivalent to --binary-files=text

# 忽略二进制文件，不予查找
  -I      Ignore binary files.  This option is equivalent to --binary-file=without-match option.

# 针对目录的行为，-d recurse 等效于 -r
  -d action, --directories=action
          Specify the demanded action for directories.  It is 'read' by default, which means that the
          directories are read in the same manner as normal files.  Other possible values are 'skip' to
          silently ignore the directories, and 'recurse' to read them recursively, which has the same
          effect as the -R and -r option.

# 指定要搜索的文件名称模式，--exclude 优先 --include
  --include=GLOB
          If specified, only files matching the given filename pattern are searched.  Note that --exclude
          patterns take priority over --include patterns.  Patterns are matched to the full path speci-
          fied, not only to the filename component.

# -R 递归模式，只匹配符合名称模式的文件夹，进入搜索。linux下没有该选项。
  --include-dir
          If -R is specified, only directories matching the given filename pattern are searched.  Note
          that --exclude-dir patterns take priority over --include-dir patterns.

# 指定要排除搜索的文件名称模式，--exclude 优先 --include
  --exclude=GLOB
          If specified, it excludes files matching the given filename pattern from the search.  Note that
          --exclude patterns take priority over --include patterns, and if no --include pattern is speci-
          fied, all files are searched that are not excluded.  Patterns are matched to the full path
          specified, not only to the filename component.

# -R 递归模式，排除符合名称模式的文件夹，不进入搜索
  --exclude-dir=GLOB
          If -R is specified, it excludes directories matching the given filename pattern from the
          search.  Note that --exclude-dir patterns take priority over --include-dir patterns, and if no
          --include-dir pattern is specified, all directories are searched that are not excluded.

# 关于符号链接软链的处理
    -p      If -R is specified, no symbolic links are followed.  This is the default.
    -O      If -R is specified, follow symbolic links only if they were explicitly listed on the command
            line.  The default is not to follow symbolic links.
    -S      If -R is specified, all symbolic links are followed.  The default is not to follow symbolic
            links.
```
## Examples

### basic

To find all occurrences of the word `patricia` in a file:

    $ grep 'patricia' myfile

To find all occurrences of the pattern `.Pp` at the *beginning* of a line:

    $ grep '^\.Pp' myfile

The apostrophes ensure the entire expression is evaluated by grep instead of by the user's shell.  
The caret `^` matches the null string at the beginning of a line, and the `\` escapes the `.`, which would
otherwise match any character.

从最近100条日志中查找 fan 提交的记录：

```Shell
svn log -l 100 | grep fan
svn log --search fan -l 100
```

git-log 的 `--grep` 选项支持过滤提交日志：

```Shell
git log -100 --author=fan --grep='文件' --stat
```

### ls-grep

`ls -al | grep '^d'`：过滤出 ls 结果中以 d 开头的（即文件夹）。

递归查找当前目录下所有包含 git 冲突起始标记的文件：

```Shell
grep -lr '<<<<<<<' .
grep -lr '<<<<<<<' . | xargs git checkout --theirs
```

递归扫描当前目录下所有文件，执行 file 命令查看文件信息，然后 grep 过滤出编码为 ISO-8859 的文件个数：

```Shell
find . -type f -exec file {} \; | grep -c 'ISO-8859'
15
```

### find-grep

以下示例在当前目录下查找名称为 src 的子目录，并在所有子目录下，执行 grep 查找包含 XPTask 的文件。

```Shell
# -r 递归查找
# -I 忽略二进制文件
# -m10 只查找前10条
# --exclude 排除特殊后缀的文件
find . -type d -name src | xargs grep -rIm10 --exclude="*.o" --exclude="*.o.d" 'XPTask'
```

以下示例递归遍历 nodejs/src 目录，但是排除 dist 目录，查找 `InquiryEntrance`。

> 相当于 vscode 等 IDE 编辑器中 Search: Find in Files 全局查找（findInFiles）。

```Shell
# -l 只输出匹配的文件名
grep -rIl --exclude-dir=dist 'InquiryEntrance' nodejs/src
# 输出匹配的文件名和行及行号
grep -rIn --exclude-dir=dist 'InquiryEntrance' nodejs/src
```

在 Xcode sdk-path 下的 usr/include 中查找宏 `WORD_BIT` 和 `__WORDSIZE` 定义所在的文件：

```Shell
$ cd `xcrun --show-sdk-path`
# grep -R -H "#define LONG_BIT" usr/include 2>/dev/null
$ grep -R -H "#define WORD_BIT" usr/include 2>/dev/null
usr/include/i386/limits.h:#define WORD_BIT        32
usr/include/arm/limits.h:#define WORD_BIT        32

$ grep -R -l "#define __WORDSIZE" usr/include 2>/dev/null
usr/include/stdint.h:#define __WORDSIZE 64
usr/include/stdint.h:#define __WORDSIZE 32
```

在 rpi4b-ubuntu 下的 /usr/include 中查找宏 `WORD_BIT` 和 `__WORDSIZE` 定义所在的文件：

```Shell
# -l: 只输出匹配文件
$ grep -R -l "#*define WORD_BIT" /usr/include 2>/dev/null

$ grep -R -l "#*define __WORDSIZE" /usr/include 2>/dev/null
/usr/include/aarch64-linux-gnu/bits/wordsize.h
```

### multiple patterns

[How do I grep for multiple patterns with pattern having a pipe character?](https://unix.stackexchange.com/questions/37313/how-do-i-grep-for-multiple-patterns-with-pattern-having-a-pipe-character)

包含 `foo|bar`（注意这里的 `|` 为普通字符，非正则或）：

```Shell
grep -- 'foo|bar' *.txt
```

如果想正则过滤包含 `foo` 或 `bar` 的行，则需要转义：

```Shell
grep -- 'foo\|bar' *.txt
```

从 myapp.log 日志中过滤包含 `start: role` 和 `stop: role` 的行，并打印行号：

```Shell
grep -n 'start: role\|stop: role' myapp.log
```

---

或者用 `-E` 通过扩展 egrep 实现按或查找，这样可以省掉转义字符：

```Shell
grep -E 'foo|bar' # 等效于 egrep 'foo|bar'
```

当然，也可以用 `-e` 指定多个匹配模式：

```Shell
grep -e 'foo' -e 'bar' myfile
```

ls 递归列举当前目录下的文件，然后按照文件名匹配过滤出部分文件予以删除：

```Shell
rm $(ls -AR | grep -e .DS_Store -e AVEngine.log -e *_WTLOGIN.*.log)
```

---

如果想过滤出不包含 `foo` 和 `bar` 的行，可指定 `-v` 选项进行反向过滤：

```Shell
grep -v -e 'foo' -e 'bar' myfile
```

以下 ps 结果管传给 grep，其中包含了 grep 进程，通过 `grep -v 'grep'` 过滤掉 grep 进程信息。

```Shell
ps -ef | grep 'nginx:' | grep -v 'grep'
ps aux | grep 'nginx:' | grep -v 'grep'
# 或者添加 -l 选项
ps -lef | grep 'nginx:'
```

## refs

[linux中grep命令的用法](https://www.cnblogs.com/flyor/p/6411140.html)
