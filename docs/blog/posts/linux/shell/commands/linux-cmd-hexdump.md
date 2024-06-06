---
title: Linux Command - hexdump
authors:
  - xman
date:
    created: 2019-11-01T08:30:00
    updated: 2024-05-20T10:30:00
categories:
    - wiki
    - linux
comments: true
---

`od` - dump files in octal and other formats.
`xxd` - make a hexdump or do the reverse.
`hexdump` - display file contents in hexadecimal, decimal, octal, or ascii.

<!-- more -->

## binhex

[Convert binary data to hexadecimal in a shell script](https://stackoverflow.com/questions/6292645/convert-binary-data-to-hexadecimal-in-a-shell-script)  
[Binary to hexadecimal and decimal in a shell script](https://unix.stackexchange.com/questions/65280/binary-to-hexadecimal-and-decimal-in-a-shell-script)  

[shell 编程进制转换](https://www.cnblogs.com/rykang/p/11880609.html)
[Linux Bash：进制间转换](https://juejin.cn/post/6844903952547315726)

第一种方式是基于 printf 函数格式化输出：

```bash
# hexadecimal to decimal
$ printf '%d\n' 0x24
36
# decimal to hexadecimal
$ printf '%x\n' 36
24
```

第二种方式是基于 `$((...))` 表达式，将其他进制转换为十进制：

```bash
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

```bash
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

## od

Linux/Unix（macOS）下的命令行工具 `od` 可按指定进制格式查看文档：

```bash
pi@raspberrypi:~ $ od --version
od (GNU coreutils) 8.26
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Jim Meyering.
```

```bash
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

```bash
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

## xxd

还有一个od类似的命令行工具是xxd。

```bash
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

```bash
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

## hd

Linux/Unix（macOS）下的命令行工具 `hexdump` 可按指定进制格式查看文档：

```bash
pi@raspberrypi:~ $ man hexdump

NAME
     hexdump, hd — ASCII, decimal, hexadecimal, octal dump

SYNOPSIS
     hexdump [-bcCdovx] [-e format_string] [-f format_file] [-n length] [-s skip] file ...
     hd [-bcdovx] [-e format_string] [-f format_file] [-n length] [-s skip] file ...
```

执行 `hd --help` 查看帮助概要（主要选项）：

```bash
$ hd --help

Usage:
 hd [options] <file>...

Display file contents in hexadecimal, decimal, octal, or ascii.

Options:
 -b, --one-byte-octal      one-byte octal display
 -c, --one-byte-char       one-byte character display
 -C, --canonical           canonical hex+ASCII display
 -d, --two-bytes-decimal   two-byte decimal display
 -o, --two-bytes-octal     two-byte octal display
 -x, --two-bytes-hex       two-byte hexadecimal display
 -L, --color[=<mode>]      interpret color formatting specifiers
                             colors are enabled by default
 -e, --format <format>     format string to be used for displaying data
 -f, --format-file <file>  file that contains format strings
 -n, --length <length>     interpret only length bytes of input
 -s, --skip <offset>       skip offset bytes from the beginning
 -v, --no-squeezing        output identical lines, causes hexdump to display all input data

 -h, --help                display this help
 -V, --version             display version

Arguments:
 <length> and <offset> arguments may be followed by the suffixes for
   GiB, TiB, PiB, EiB, ZiB, and YiB (the "iB" is optional)

For more details see hexdump(1).
```

### options

`-x`：以两个十六进制字节为一个显示单位。默认一行显示16个十六进制，即8组two-bytes（8/2 %04x）。
`-n`：只 dump 指定长度的内容，以 byte 为单位。
`-s`：跳过开头指定长度的字节。
`-v`：完整显示所有数据行，默认内容相同的行（ditto/idem）以`*`标识。
`-e`：指定显示格式。

---

> `hd` = `hexdump -C`

可以 hexdump 出 UTF-8 编码的文本文件，通过开头3个字节来判断是否带BOM：

> 如果开头3个字节为 `ef bb bf`，则为带 BOM 编码；否则为不带 BOM 编码。

```bash
# 等效 hexdump -C litetransfer.cpp | head -n 4; hd -n 64 tuple.h
faner@MBP-FAN:~/Downloads|⇒  hexdump -n 64 -C tuple.h
00000000  ef bb bf 0d 0a 23 70 72  61 67 6d 61 20 6f 6e 63  |.....#pragma onc|
00000010  65 0d 0a 0d 0a 6e 61 6d  65 73 70 61 63 65 20 41  |e....namespace A|
00000020  73 79 6e 63 54 61 73 6b  0d 0a 7b 0d 0a 0d 0a 2f  |syncTask..{..../|
00000030  2f 20 e5 85 83 e7 bb 84  28 54 75 70 6c 65 29 e6  |/ ......(Tuple).|
00000040
```

hexdump 静态链接的可执行文件 ELF32 的头 16 个字节（e_ident）

```bash
$ hexdump -n 16 swrite32
0000000 457f 464c 0101 0301 0000 0000 0000 0000
0000010

$ hexdump -x -n 16 swrite32
0000000    457f    464c    0101    0301    0000    0000    0000    0000
0000010
```

添加 `-C` 选项，左右混合显示 hex(single byte) + ASCII：

```bash
# hexdump -C -n 16 swrite32
$ hd -n 16 swrite32
00000000  7f 45 4c 46 01 01 01 03  00 00 00 00 00 00 00 00  |.ELF............|
00000010
```

复合 `-Cx` 选项，多一行 two-bytes-hex：

```bash
$ hd -x -n 16 swrite32
00000000  7f 45 4c 46 01 01 01 03  00 00 00 00 00 00 00 00  |.ELF............|
0000000    457f    464c    0101    0301    0000    0000    0000    0000
00000010
```

### -e format

可借助 `-e format` 选项指定打印格式。

> `-x` 的等效格式是 `-e '"%07.7_ax  " 8/2 "%04x " "\n"'`

每行打印 16 个 byte（1-%02x）：

```bash
$ hexdump -n 16 -e '"%07.7_ax  " 16/1 "%02x " "\n"' swrite32
0000000  7f 45 4c 46 01 01 01 03 00 00 00 00 00 00 00 00
```

每行打印 4 个 word（4-%08x）：

```bash
$ hexdump -n 16 -e '"%07.7_ax  " 4/4 "%08x " "\n"' swrite32
0000000  464c457f 03010101 00000000 00000000
```

复合 `-Ce`，加印一行指定格式：

```bash
# -e 开头的偏移量调整为 8 位，与 -C 对齐
$ hd -n 16 -e '"%08.8_ax  " 4/4 "%08x " "\n"' swrite32
00000000  7f 45 4c 46 01 01 01 03  00 00 00 00 00 00 00 00  |.ELF............|
00000000  464c457f 03010101 00000000 00000000
00000010
```

### demo - elf header

跳过头部 16 个字节的 e_ident，打印 half-word 类型的 e_type 和 e_machine：

```bash
# ET_EXEC, EM_ARM
$ hexdump -s 16 -n 4 swrite32
0000010 0002 0028
0000014

# ET_DYN, EM_AARCH64
$ hexdump -s 16 -n 4 write64
0000010 0003 00b7
0000014
```

[Output file with one byte per line in hex format](https://stackoverflow.com/questions/21713725/output-file-with-one-byte-per-line-in-hex-format-under-linux-bash)

```bash
# 每行打印一个字节
$ hexdump -v -n 16 -e '/1 "%02x\n"' swrite32
```

跳过头部 20 个字节（e_ident+e_type+e_machine），打印 word 类型的 e_version：

```bash
$ hexdump -s 20 -n 4 -e '"%07.7_ax  " 4/4 "%08x " "\n"' swrite32
0000014  00000001
$ hexdump -s 20 -n 4 -e '"%07.7_ax  " 4/4 "%08x " "\n"' write64
0000014  00000001
```

跳过头部 24 个字节（e_ident+e_type+e_machine+e_version），打印 Elf32_Addr/Elf64_Addr 类型的 e_entry：

```bash
$ hexdump -s 24 -n 4 -e '"%07.7_ax  " /4 "%8x " "\n"' swrite32
0000018  10339
$ readelf -h swrite32 | grep "Entry point address"
  Entry point address:               0x10339

$ hexdump -s 24 -n 8 -e '"%07.7_ax  " /8 "%16x " "\n"' write64
0000018  640
$ readelf -h write64 | grep "Entry point address"
  Entry point address:               0x640
```

### demo - rela/got

参考 [puts@plt/rela/got - static analysis](../../../elf/plt-puts-analysis.md)。

在 arm64/AArch64 等平台上，内存地址是 64 位的，要打印指针值需以 8-byte 的 double-word 或 giant-word 为一组。

Hexdump contents of PROGBITS section `.got` grouped by giant-word array.

> 原始 hexdump Offset 为不带 0x 前缀的十六进制，拼接 `"0x"` 编程字符串，无法直接参加计算，故转换为十进制。

```bash
$ got_offset=$(objdump -hw a.out | awk '/.got/{print "0x"$6}')
$ got_size=$(objdump -hw a.out | awk '/.got/{print "0x"$3}')
$ hexdump -v -s $got_offset -n $got_size -e '"%_ad\t" /8 "%016x\t" "\n"' a.out \
| awk 'BEGIN{print "Offset\t\tAddress\t\t\t\tValue"} \
{printf("%08x\t", $1); printf("%016x\t", $1+65536); print $2}'
Offset		Address				Value
00000f90	0000000000010f90	0000000000000000
00000f98	0000000000010f98	0000000000000000
00000fa0	0000000000010fa0	0000000000000000
00000fa8	0000000000010fa8	00000000000005d0
00000fb0	0000000000010fb0	00000000000005d0
00000fb8	0000000000010fb8	00000000000005d0
00000fc0	0000000000010fc0	00000000000005d0
00000fc8	0000000000010fc8	00000000000005d0
00000fd0	0000000000010fd0	0000000000010da0
00000fd8	0000000000010fd8	0000000000000000
00000fe0	0000000000010fe0	0000000000000000
00000fe8	0000000000010fe8	0000000000000000
00000ff0	0000000000010ff0	0000000000000754
00000ff8	0000000000010ff8	0000000000000000
```

As is shown in `readelf -d a.out`, `DT_RELAENT`=0x18, that means size of one RELA reloc is 24.

Hexdump contents of RELA section `.rela.plt` grouped by unit of giant-word, 3 units per line.

> Pay attention to the first giant-word: it points to `.got` entry.

```bash
$ rp_offset=$(objdump -hw a.out | awk '/.rela.plt/{print "0x"$6}')
$ rp_size=$(objdump -hw a.out | awk '/.rela.plt/{print "0x"$3}')
$ hexdump -v -s $rp_offset -n $rp_size -e '"%016_ax  " 3/8 "%016x " "\n"' a.out \
| awk 'BEGIN{print "address\t\t\t\toffset\t\t\tinfo\t\t\taddend"} 1'
address				offset			info			addend
0000000000000540  0000000000010fa8 0000000300000402 0000000000000000
0000000000000558  0000000000010fb0 0000000500000402 0000000000000000
0000000000000570  0000000000010fb8 0000000600000402 0000000000000000
0000000000000588  0000000000010fc0 0000000700000402 0000000000000000
00000000000005a0  0000000000010fc8 0000000800000402 0000000000000000
```
