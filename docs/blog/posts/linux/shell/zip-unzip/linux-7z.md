---
title: Linux Command - 7z
authors:
  - xman
date:
    created: 2019-10-30T10:20:00
categories:
    - wiki
    - linux
tags:
    - 7z
comments: true
---

linux 下的 压缩/解压缩 命令 —— 7z。

<!-- more -->

[7-Zip](https://www.7-zip.org/)  
[P7ZIP](http://p7zip.sourceforge.net/)  

执行 `brew install p7zip` 安装 7z 命令行工具：

## 7z

```
faner@FAN-MB1 ~$ 7z↵

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=utf8,Utf16=on,HugeFiles=on,64 bits,8 CPUs x64)

Usage: 7z <command> [<switches>...] <archive_name> [<file_names>...]
       [<@listfiles...>]

<Commands>
  a : Add files to archive
  b : Benchmark
  d : Delete files from archive
  e : Extract files from archive (without using directory names)
  h : Calculate hash values for files
  i : Show information about supported formats
  l : List contents of archive
  rn : Rename files in archive
  t : Test integrity of archive
  u : Update files to archive
  x : eXtract files with full paths
  
```

## man

`man 7z` 查看 manual：

### SYNOPSIS

```
NAME
       7z - A file archiver with highest compression ratio

SYNOPSIS
       7z [adeltux] [-] [SWITCH] <ARCHIVE_NAME> <ARGUMENTS>...
```

### DESCRIPTION

```
DESCRIPTION
       7-Zip  is  a file archiver with the highest compression ratio. The program supports
       7z (that implements LZMA compression algorithm), ZIP, CAB, ARJ, GZIP,  BZIP2,  TAR,
       CPIO,  RPM and DEB formats. Compression ratio in the new 7z format is 30-50% better
       than ratio in ZIP format.

       7z uses plugins to handle archives.


FUNCTION LETTERS
       a      Add

       d      Delete

       e      Extract

       l      List

       t      Test

       u      Update

       x      eXtract with full paths
       
SWITCHES

       -t{Type}
              Type of archive (7z, zip, gzip, bzip2 or tar. 7z format is default)
              
SEE ALSO
       7za(1), 7zr(1), bzip2(1), gzip(1), zip(1)
```


### refs

- [7z命令行下的最快压缩和解压缩说明](https://blog.csdn.net/weekdawn/article/details/81039364)  
- [用命令行的方式来执行7z压缩和解压缩](https://blog.csdn.net/oilcode/article/details/50063425)  

## demo

### add

`7z a avg_speed.7z files` :

```
FAN-MB1:zip $ 7z a avg_speed.7z ~/Downloads/Logs/*-avg_speed.log

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=utf8,Utf16=on,HugeFiles=on,64 bits,8 CPUs x64)

Scanning the drive:
4 files, 6856 bytes (7 KiB)

Creating archive: avg_speed.7z

Items to compress: 4


Files read from disk: 4
Archive size: 1594 bytes (2 KiB)
Everything is Ok
```

`7z a map_image.7z` ：

```
FAN-MB1:zip $ 7z a map_image.7z ~/Downloads/Images/map-*.png

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=utf8,Utf16=on,HugeFiles=on,64 bits,8 CPUs x64)

Scanning the drive:
3 files, 8099973 bytes (7911 KiB)

Creating archive: map_image.7z

Items to compress: 3


Files read from disk: 3
Archive size: 8004351 bytes (7817 KiB)
Everything is Ok
```

### list

示例1: `7z l avg_speed.7z` ：

```
faner@FAN-MB1:~/Downloads/zip
> file avg_speed.7z
avg_speed.7z: 7-zip archive data, version 0.4
faner@FAN-MB1:~/Downloads/zip
> file -bI avg_speed.7z
application/x-7z-compressed; charset=binary
```

```
FAN-MB1:zip $ 7z l avg_speed.7z

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=utf8,Utf16=on,HugeFiles=on,64 bits,8 CPUs x64)

Scanning the drive for archives:
1 file, 1594 bytes (2 KiB)

Listing archive: avg_speed.7z

--
Path = avg_speed.7z
Type = 7z
Physical Size = 1594
Headers Size = 231
Method = LZMA2:13
Solid = +
Blocks = 1

   Date      Time    Attr         Size   Compressed  Name
------------------- ----- ------------ ------------  ------------------------
2019-12-01 16:54:37 ....A         2394         1363  2019-12-01-10-avg_speed.log
2019-12-01 16:55:40 ....A         1638               2019-12-01-11-avg_speed.log
2019-12-01 17:00:15 ....A         1640               2019-12-01-15-avg_speed.log
2019-12-01 21:38:03 ....A         1184               2019-12-01-21-avg_speed.log
------------------- ----- ------------ ------------  ------------------------
2019-12-01 21:38:03               6856         1363  4 files
```

示例2: `7z l Audio.Hijack.v3.3.7.rar` 预览 rar 文件：

```
faner@FAN-MB1:~/Downloads/zip
> file Audio.Hijack.v3.3.7.rar
Audio.Hijack.v3.3.7.rar: RAR archive data, v5
faner@FAN-MB1:~/Downloads/zip
> file -bI Audio.Hijack.v3.3.7.rar
application/x-rar; charset=binary
```

```
FAN-MB1:zip $ 7z l Audio.Hijack.v3.3.7.rar

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=utf8,Utf16=on,HugeFiles=on,64 bits,8 CPUs x64)

Scanning the drive for archives:
1 file, 17370173 bytes (17 MiB)

Listing archive: Audio.Hijack.v3.3.7.rar

--
Path = Audio.Hijack.v3.3.7.rar
Type = Rar5
Physical Size = 17370173
Characteristics = Recovery Lock
Solid = -
Blocks = 1
Encrypted = -
Multivolume = -
Volumes = 1
Comment =
   0daydown.com

   Date      Time    Attr         Size   Compressed  Name
------------------- ----- ------------ ------------  ------------------------
2018-04-12 08:14:39 ....A     16511034     16511034  Audio.Hijack.v3.3.7.dmg
------------------- ----- ------------ ------------  ------------------------
2018-04-12 08:14:39           16511034     16511034  1 files
```

### extract

`7z e *.7z` 默认解压到当前目录，解压出来的文件平铺在当前目录，丢失了原有打包前的目录结构。

> 若想解压后，保持 `7z l` 中展示的打包前的目录结构，可使用 `x` 替换 `e` 子命令。

建议通过 `-o` 参数指定解压目录：`7z e avg_speed.7z -o./avg_speed`。

以下示范 macOS 下利用 7z 解压 rar 文件：

```
faner@MBP-FAN:~/Downloads/zip
> 7z e Audio.Hijack.v3.3.7.rar -o./Audio.Hijack.v3.3.7

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=utf8,Utf16=on,HugeFiles=on,64 bits,8 CPUs x64)

Scanning the drive for archives:
1 file, 17370173 bytes (17 MiB)

Extracting archive: Audio.Hijack.v3.3.7.rar
--
Path = Audio.Hijack.v3.3.7.rar
Type = Rar5
Physical Size = 17370173
Characteristics = Recovery Lock
Solid = -
Blocks = 1
Encrypted = -
Multivolume = -
Volumes = 1
Comment =
   0daydown.com

Everything is Ok

Size:       16511034
Compressed: 17370173
```
