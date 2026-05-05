---
title: Linux Command - 7z
authors:
  - xman
date:
    created: 2019-10-30T10:20:00
    updated: 2026-04-26T21:30:00
categories:
    - wiki
    - linux
tags:
    - 7z
comments: true
---

linux 下的 压缩/解压缩 命令 —— 7z。

<!-- more -->


[7-Zip](https://www.7-zip.org/): p7zip@[github](https://github.com/p7zip-project/p7zip), P7ZIP@[sourceforge](http://p7zip.sourceforge.net/)  

- [7z命令行下的最快压缩和解压缩说明](https://blog.csdn.net/weekdawn/article/details/81039364)  
- [用命令行的方式来执行7z压缩和解压缩](https://blog.csdn.net/oilcode/article/details/50063425)  

macOS 下执行 `brew info p7zip` 查看 7-Zip 信息：

```bash
$ brew info p7zip
==> p7zip ✔: stable 17.06 (bottled)
7-Zip (high compression file archiver) implementation
https://github.com/p7zip-project/p7zip
Installed (on request)
/opt/homebrew/Cellar/p7zip/17.06 (107 files, 9.6MB) *
  Poured from bottle using the formulae.brew.sh API on 2025-04-20 at 17:29:49
From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/p/p7zip.rb
License: LGPL-2.1-or-later AND GPL-2.0-or-later
==> Downloading https://formulae.brew.sh/api/formula/p7zip.json
==> Analytics
install: 11,710 (30 days), 34,403 (90 days), 122,191 (365 days)
install-on-request: 10,130 (30 days), 29,899 (90 days), 103,578 (365 days)
build-error: 1 (30 days)
```

执行 `brew install p7zip` 安装 7-Zip 命令行工具 `7z`。

## 7z

输入 `7z` 或 `7z --help` 查看命令帮助（Usage）：

```bash
$ 7z↵

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

<Switches>
  -- : Stop switches parsing
  ...
```

## man

执行 `man 7z` 查看使用手册。

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

## demo

### add

Add logs into avg_speed.7z:

```bash
$ 7z a avg_speed.7z ~/Downloads/Logs/*-avg_speed.log

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

Add pngs into map_image.7z:

```bash
$ 7z a map_image.7z ~/Downloads/Images/map-*.png

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

Use the `file` command to view the file properties.

```bash
$ file avg_speed.7z
avg_speed.7z: 7-zip archive data, version 0.4

$ file -bI avg_speed.7z
application/x-7z-compressed; charset=binary
```

Use the subcommand `7z l` (short for *list*) to view the contents of a compressed file suffixed with 7z.

```bash
$ 7z l avg_speed.7z

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

View the contents of a compressed file suffixed with rar.

```bash
$ file Audio.Hijack.v3.3.7.rar
Audio.Hijack.v3.3.7.rar: RAR archive data, v5

$ file -bI Audio.Hijack.v3.3.7.rar
application/x-rar; charset=binary

$ 7z l Audio.Hijack.v3.3.7.rar

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

### delete

`7z d` 删除 Archive.zip 中的 `__MACOSX` 文件夹：

```bash
# zip -d map_image-arch.zip __MACOSX/\*
$ 7z d Archive.zip __MACOSX
```

`7z d` 删除 Archive.zip 中的 `.DS_Store` 文件及 `__MACOSX` 文件夹：

```bash
# zip -d Archive.zip .DS_Store __MACOSX/\*
$ 7z d Archive.zip .DS_Store __MACOSX
```

### extract

`7z e *.7z` 默认解压到当前目录，解压出来的文件平铺在当前目录，丢失了原有打包前的目录结构。

> 若想解压后，保持 `7z l` 中展示的打包前的目录结构，可使用 `x` 替换 `e` 子命令。

建议通过 `-o` 参数指定解压目录：`7z e avg_speed.7z -o./avg_speed`。

以下示范 macOS 下利用 7z 解压 rar 文件：

```bash
$ 7z e Audio.Hijack.v3.3.7.rar -o./Audio.Hijack.v3.3.7

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

---

`e` 和 `x` 这两个命令的核心区别在于**是否保留压缩包内部的目录结构**。

* **`e` (Extract) 是“暴力倾倒”**：不管文件原来在哪，全拿出来**平铺**放在一起。
* **`x` (eXtract with full paths) 是“专业复原”**：原封不动地**还原**原来的文件夹层级。

假设有一个名叫 `data.7z` 的压缩包，里面的目录结构如下：

```text
data.7z
├── report.pdf
├── images
│   └── photo.jpg
└── docs
    └── note.txt
```

#### e 命令：简单粗暴的“暴力倾倒”

**行为逻辑**：7z 会把压缩包里**所有的文件**直接扔到你指定的目录（如果不指定，就是当前目录），**彻底抛弃**它们原本所在的 `images` 或 `docs` 文件夹。
**生动场景**：当你下载了一个壁纸包，里面几十张图片全部分门别类放在各个文件夹里，但你只想把它们全部拿出来设为桌面轮换，根本不在乎它们原来叫什么文件夹。这时候用 `e` 最省事。
**操作演示**：

```bash
# 把 data.7z 里的所有文件直接扔到当前目录
7z e data.7z
```

**解压后的结果**（所有文件混在一起）：

```text
./report.pdf
./photo.jpg
./note.txt
```

#### x 命令：严谨细致的“专业复原”

**行为逻辑**：7z 会像一个专业的档案管理员一样，不仅把文件拿出来，还会**自动帮你建好原本的文件夹**，把文件各归各位。
**生动场景**：这是你**90%的情况下都应该使用的命令**。比如你在备份网站数据、传输代码项目，或者下载了别人整理好的学习资料。一旦丢了目录结构，整个项目可能就跑不起来，或者变得一团糟。
**操作演示**：

```bash
# 完整还原 data.7z 内部的文件夹和文件
7z x data.7z
```

**解压后的结果**（完美复刻原结构）：

```text
./data/          <-- (如果压缩包顶层有文件夹，会自动生成)
├── report.pdf
├── images
│   └── photo.jpg
└── docs
    └── note.txt
```

#### 避坑小贴士

在日常使用中，**强烈建议你把 `x` 命令刻在肌肉记忆里**。

因为如果你习惯使用 `e`，但某天遇到一个里面全是 `index.html` 的庞大代码库，执行完 `e` 后，你会发现几百个同名文件互相覆盖，或者全部挤在一个文件夹里，根本分不清谁是谁，到时候就只能欲哭无泪地重新下载了。
