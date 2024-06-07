---
title: GNU Binutils - strings
authors:
    - xman
date:
    created: 2023-06-20T12:00:00
categories:
    - toolchain
    - elf
comments: true
---

[strings](https://man7.org/linux/man-pages/man1/strings.1.html) - print the sequences of printable characters in files.

For each *file* given, GNU `strings` prints the printable character sequences that are at least 4 characters long (or the number given with the options below) and are followed by an unprintable character.

strings is mainly useful for determining the contents of non-text files.

<!-- more -->

strings 一般用于查看二进制程序文件中的可显示/打印字符。

```bash
pifan@rpi3b-ubuntu $ man strings
STRINGS(1)                                 GNU Development Tools                                STRINGS(1)

NAME
       strings - print the sequences of printable characters in files

SYNOPSIS
       strings [-afovV] [-min-len]
               [-n min-len] [--bytes=min-len]
               [-t radix] [--radix=radix]
               [-e encoding] [--encoding=encoding]
               [-U method] [--unicode=method]
               [-] [--all] [--print-file-name]
               [-T bfdname] [--target=bfdname]
               [-w] [--include-all-whitespace]
               [-s] [--output-separator sep_string]
               [--help] [--version] file...

```

假设我们执行 `readelf -SW test-gdb` 获取得到部分段的 Offset/Size 如下所示：

```bash
$ readelf -SW test-gdb

Section Headers:
  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
  [ 1] .interp           PROGBITS        0000000000000238 000238 00001b 00   A  0   0  1

  [ 6] .dynstr           STRTAB          00000000000003a8 0003a8 000094 00   A  0   0  1

  [15] .rodata           PROGBITS        0000000000000830 000830 000034 00   A  0   0  8

  [23] .bss              NOBITS          0000000000011010 001010 000008 00  WA  0   0  1
  [24] .comment          PROGBITS        0000000000000000 001010 00002b 01  MS  0   0  1
  [25] .symtab           SYMTAB          0000000000000000 001040 000858 18     26  65  8
  [26] .strtab           STRTAB          0000000000000000 001898 000237 00      0   0  1
  [27] .shstrtab         STRTAB          0000000000000000 001acf 0000fa 00      0   0  1
```

查阅相关资料（[TIS - ELF v1.2](https://refspecs.linuxfoundation.org/elf/elf.pdf)）可知，以下几个 section 的内容都是字符串，其中 3 个 section 的 Type 为 STRTAB —— String Table。

- `.interp`: map to segment INTERP, contains only the location and size to a null terminated string describing where the program interpreter is. It is generally the location of the dynamic linker, which is also the program interpreter.
- `.dynstr`: This section holds strings needed for dynamic linking, most commonly the strings that represent the names associated with symbol table entries.
- `.comment`: This section holds version control information.
- `.strtab`: This section holds strings, most commonly the strings that represent the names associated with symbol table entries.
- `.shstrtab`: This section holds section names.

可使用 `readelf -p` 或 `objdump -j` 读取 section `.interp` 的内容：

```bash
$ readelf -p .interp test-gdb

String dump of section '.interp':
  [     0]  /lib/ld-linux-aarch64.so.1

$ objdump -j .interp -s test-gdb

test-gdb:     file format elf64-littleaarch64

Contents of section .interp:
 0238 2f6c6962 2f6c642d 6c696e75 782d6161  /lib/ld-linux-aa
 0248 72636836 342e736f 2e3100             rch64.so.1.
```

其他几个 section 使用 `readelf -p` 或 `objdump -j` 读取情况如下：

- [x] readelf -p .dynstr test-gdb
- [x] objdump -j .dynstr -s test-gdb
- [x] readelf -p .rodata test-gdb
- [x] objdump -j .rodata -s test-gdb
- [x] readelf -p .comment test-gdb
- [x] objdump -j .comment -s test-gdb
- [x] readelf -p .strtab test-gdb
- [ ] objdump -j .strtab test-gdb
- [x] readelf -p .shstrtab test-gdb
- [ ] objdump -j .shstrtab test-gdb

## od/strings

`readelf -S` 列出的 Section Headers，每个条目都给出了对应 section 相对 ELF 文件的的 Offset/Size。

除了使用 `readelf -p` 或 `objdump -j`，还可综合使用 hexdump,strings 等工具 dump 指定范围的 bytearray/strings。

=== "od/strings all"

    ```bash
    # offset in octet format
    $ od -S 3 test-gdb
    $ strings -t o -n 3 test-gdb

    # offset in hex format, default -n 4
    $ strings -t x test-gdb
    ```

=== "od/hexdump range"

    ```bash
    # .interp
    $ od -j 0x000238 -N 0x00001b -S 3 test-gdb
    $ hd -s 0x000238 -n 0x00001b test-gdb
    # one-byte named character
    # od -j 0x000238 -N 0x00001b -a test-gdb
    # hexdump -s 0x001898 -n 0x000237 -c test-gdb

    # .strtab
    $ od -j 0x001898 -N 0x000237 -S 3 test-gdb
    $ hd -s 0x001898 -n 0x000237 test-gdb
    ```

=== "head | tail | strings"

    ```bash
    # -c 只能接受十进制，故使用 $(()) 封闭计算表达式。
    # .comment
    $ head -c $((0x001010+0x00002b)) test-gdb | tail -c $((0x00002b)) | strings
    # .shstrtab
    $ head -c $((0x001acf+0x0000fa)) test-gdb | tail -c $((0x0000fa)) | strings
    ```

自动提取 test-gdb 指定 section 的 Offset/Size，然后提取纯字符串的半自动化脚本如下：

```bash
section="\.shstrtab"
pattern=".*$section\s.*"
secitem=$(readelf -SW test-gdb | grep -E $pattern)
off="0x"$(echo $secitem | awk '{print $5}')
sz=`echo $secitem | awk '{print "0x"$6}'`
head -c $((off+sz)) test-gdb | tail -c $((sz)) | strings
```

## rabin2

[Install radare2 on Ubuntu using the Snap Store | Snapcraft](https://snapcraft.io/install/radare2/ubuntu#install)

[radare2](https://www.radare.org/n/).[Rabin2](https://book.rada.re/tools/rabin2/intro.html) is a command-line utility that can analyze and extract information from binary files. It’s commonly used for reverse engineering, analyzing malware, and forensics analysis.

[Strings - The Official Radare2 Book](https://book.rada.re/tools/rabin2/strings.html)

Simply, we can use the `-zz` flag to get the strings from the whole binary file:

```bash
$ radare2.rabin2 -zz test-gdb
```

The `-z` option is used to list readable strings found in the `.rodata` section of ELF binaries, or the `.text` section of PE files.

```bash
$ radare2.rabin2 -z test-gdb
```

## refs

- [Linux command to retrieve a byte range from a file - Server Fault](https://serverfault.com/questions/406791/linux-command-to-retrieve-a-byte-range-from-a-file)
- [Linux command (like cat) to read a specified quantity of characters - Stack Overflow](https://stackoverflow.com/questions/218912/linux-command-like-cat-to-read-a-specified-quantity-of-characters)
- [linux - How to create a hex dump of file containing only the hex characters without spaces in bash? - Stack Overflow](https://stackoverflow.com/questions/2614764/how-to-create-a-hex-dump-of-file-containing-only-the-hex-characters-without-spac)
- [Finding Strings From Binary Files in Linux | Baeldung on Linux](https://www.baeldung.com/linux/find-string-binary-file)
