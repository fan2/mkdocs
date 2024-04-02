---
draft: true
title: Linux Command - sed help
authors:
  - xman
date:
    created: 2019-11-04T08:00:00
categories:
    - wiki
    - linux
tags:
    - sed
comments: true
---

Linux 下的 sed 命令帮助。

<!-- more -->

## Introduction

WIKI - [sed](https://en.wikipedia.org/wiki/Sed)  

sed ("stream editor") is a Unix utility that parses and transforms text, using a simple, compact programming language. sed was developed from 1973 to 1974 by Lee E. McMahon of Bell Labs, and is available today for most operating systems. sed was based on the scripting features of the interactive editor [ed](https://en.wikipedia.org/wiki/Ed_(text_editor)) ("editor", 1971) and the earlier [qed](https://en.wikipedia.org/wiki/QED_(text_editor)) ("quick editor", 1965–66). sed was one of the earliest tools to support [regular expressions](https://en.wikipedia.org/wiki/Regular_expression), and remains in use for text processing, most notably with the `substitution` command. Popular alternative tools for plaintext string manipulation and "stream editing" include [AWK](https://en.wikipedia.org/wiki/AWK) and [Perl](https://en.wikipedia.org/wiki/Perl).

GNU.org - [sed, a stream editor](https://www.gnu.org/software/sed/manual/sed.html) - [Introduction](https://www.gnu.org/software/sed/manual/html_node/Introduction.html)

`Sed` is a stream editor. A stream editor is used to perform basic text transformations on an input stream (a file or input from a pipeline). While in some ways similar to an editor which permits scripted edits (such as `ed`), sed works by making only one pass over the input(s), and is consequently more efficient. But it is sed's ability to filter text in a pipeline which particularly distinguishes it from other types of editors.

[Sed - An Introduction and Tutorial by Bruce Barnett](https://www.grymoire.com/Unix/Sed.html#toc_Sed_-_An_Introduction_and_Tutorial_by_Bruce_Barnett)  

## version

### raspberrypi

执行 `sed --version` 查看版本信息：

```Shell
pi@raspberrypi:~ $ sed --version
sed (GNU sed) 4.4
Copyright (C) 2017 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Jay Fenlason, Tom Lord, Ken Pizzini,
and Paolo Bonzini.
GNU sed home page: <http://www.gnu.org/software/sed/>.
General help using GNU software: <http://www.gnu.org/gethelp/>.
E-mail bug reports to: <bug-sed@gnu.org>.
```

## man

- 执行 `sed --help` 可查看简要帮助（Usage）；  
- 执行 `man sed` 可查看帮助手册。  

以下是各大平台的 sed 在线手册：

- unix/POSIX - [sed - stream editor](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sed.html)  
- FreeBSD/Darwin - [sed -- stream editor](https://www.freebsd.org/cgi/man.cgi?query=sed)  

- linux - [sed - stream editor for filtering and transforming text](http://man7.org/linux/man-pages/man1/sed.1.html)  
- debian - [sed - stream editor](https://manpages.debian.org/buster/9base/sed.1plan9.en.html)  

- ubuntu - [sed - stream editor](https://manpages.ubuntu.com/manpages/jammy/en/man1/ls.1plan9.html)  

### macOS

macOS 执行 `sed --help` 可查看帮助概要信息：

```Shell
faner@FAN-MB1: ~ $ sed --help
sed: illegal option -- -
usage: sed script [-Ealn] [-i extension] [file ...]
       sed [-Ealn] [-i extension] [-e script] ... [-f script_file] ... [file ...]
FAIL: 1
```

macOS 执行 `man sed` 可查看详细帮助手册（Manual Page）：

```Shell
faner@FAN-MB1: ~ $ man sed

SED(1)                    BSD General Commands Manual                   SED(1)

NAME
     sed -- stream editor

SYNOPSIS
     sed [-Ealn] command [file ...]
     sed [-Ealn] [-e command] [-f command_file] [-i extension] [file ...]

DESCRIPTION
     The sed utility reads the specified files, or the standard input if no files are specified, modi-
     fying the input as specified by a list of commands.  The input is then written to the standard
     output.

     A single command may be specified as the first argument to sed.  Multiple commands may be speci-
     fied by using the -e or -f options.  All commands are applied to the input in the order they are
     specified regardless of their origin.
```

### raspberrypi

raspberrypi 执行 `sed --help` 可查看帮助概要信息：

```Shell
pi@raspberrypi:~ $ sed --help

Usage: sed [OPTION]... {script-only-if-no-other-script} [input-file]...

  -n, --quiet, --silent
                 suppress automatic printing of pattern space
  -e script, --expression=script
                 add the script to the commands to be executed
  -f script-file, --file=script-file
                 add the contents of script-file to the commands to be executed
  --follow-symlinks
                 follow symlinks when processing in place
  -i[SUFFIX], --in-place[=SUFFIX]
                 edit files in place (makes backup if SUFFIX supplied)
  -l N, --line-length=N
                 specify the desired line-wrap length for the `l' command
  --posix
                 disable all GNU extensions.
  -E, -r, --regexp-extended
                 use extended regular expressions in the script
                 (for portability use POSIX -E).
  -s, --separate
                 consider files as separate rather than as a single,
                 continuous long stream.
      --sandbox
                 operate in sandbox mode.
  -u, --unbuffered
                 load minimal amounts of data from the input files and flush
                 the output buffers more often
  -z, --null-data
                 separate lines by NUL characters
      --help     display this help and exit
      --version  output version information and exit

If no -e, --expression, -f, or --file option is given, then the first
non-option argument is taken as the sed script to interpret.  All
remaining arguments are names of input files; if no input files are
specified, then the standard input is read.

GNU sed home page: <http://www.gnu.org/software/sed/>.
General help using GNU software: <http://www.gnu.org/gethelp/>.
E-mail bug reports to: <bug-sed@gnu.org>.
```

raspberrypi 执行 `man sed` 可查看详细帮助手册（Manual Page）：

```Shell
pi@raspberrypi:~ $ man sed

SED(1)                                  User Commands                                  SED(1)

NAME
       sed - stream editor for filtering and transforming text

SYNOPSIS
       sed [OPTION]... {script-only-if-no-other-script} [input-file]...

DESCRIPTION
       Sed is a stream editor.  A stream editor is used to perform basic text transformations
       on an input stream (a file or input from a pipeline).  While in some ways  similar  to
       an editor which permits scripted edits (such as ed), sed works by making only one pass
       over the input(s), and is consequently more efficient.  But it  is  sed's  ability  to
       filter text in a pipeline which particularly distinguishes it from other types of edi‐
       tors.
```

## options

sed 主要有5个常用命令选项：

选项         | 描述
------------|------------------------------------------------
`-n`        | 不产生命令输出，使用 print 命令来完成输出
`-e script` | 在处理输入中，将 script 中指定的命令添加到已有的命令中
`-f file`   | 在处理输入中，将 file 中指定的命令添加到已有的命令中
`-E`(`-r`)  | 支持扩展型正则表达式
`-i`        | 编辑完回写

### macOS

```Shell
faner@FAN-MB1: ~ $ man sed

     -e command
             Append the editing commands specified by the command argument to the list of commands.

     -f command_file
             Append the editing commands found in the file command_file to the list of commands.  The
             editing commands should each be listed on a separate line.

     -i extension
             Edit files in-place, saving backups with the specified extension.  If a zero-length extension
             is given, no backup will be saved.  It is not recommended to give a zero-length extension when
             in-place editing files, as you risk corruption or partial content in situations where disk
             space is exhausted, etc.

     -n      By default, each line of input is echoed to the standard output after all of the commands
             have been applied to it.  The -n option suppresses this behavior.
```

### raspberrypi

```Shell
pi@raspberrypi:~ $ man sed

       -n, --quiet, --silent

              suppress automatic printing of pattern space

       -e script, --expression=script

              add the script to the commands to be executed

       -f script-file, --file=script-file

              add the contents of script-file to the commands to be executed

       -i[SUFFIX], --in-place[=SUFFIX]

              edit files in place (makes backup if SUFFIX supplied)
```

## notes

[sed 工具](https://dywang.csie.cyut.edu.tw/dywang/linuxProgram/node41.html)

系列笔记章节：

1. [sed-basic](./sed-basic.md)  
2. [sed-iacds](./sed-iacds.md)  
3. [sed-NDP](./sed-NDP.md)  
