---
title: Linux Command - tar/bzip2
authors:
  - xman
date:
    created: 2019-10-30T09:30:00
    updated: 2026-05-30T12:00:00
categories:
    - wiki
    - linux
tags:
    - tar
comments: true
---

linux 下的 压缩/解压缩（tar）命令。

<!-- more -->

[Archiving and compression - ArchWiki](https://wiki.archlinux.org/title/Archiving_and_compression): The traditional Unix archiving and compression tools are separated according to the [Unix philosophy](https://en.wikipedia.org/wiki/Unix_philosophy "wikipedia:Unix philosophy"):

- A [file archiver](https://en.wikipedia.org/wiki/File_archiver "wikipedia:File archiver") combines several files into one archive file, e.g. [tar](https://www.gnu.org/software/tar/manual/).
- A [compression](https://en.wikipedia.org/wiki/Data_compression "wikipedia:Data compression") tool compresses and decompresses data, e.g. [gzip](https://www.gzip.org/).

These tools are often used in sequence by firstly creating an archive file and then compressing it.

A GNU compressed archive, commonly ending in `.gz`, `.tar.gz`, or `.tgz`, is a file compressed using the [GNU Gzip Project](https://www.gnu.org/software/gzip/). It compresses data to save space without losing quality. Often, multiple files are **bundled** together using tar before compression, creating a "tarball".

- [GNU tar 1.35: 8.1.1 Creating and Reading Compressed Archives](https://www.gnu.org/software/tar/manual/html_node/gzip.html)

An archive is a file that acts as a **container** for other files. It can contain many files, folders, and subfolders, usually in compressed form using `gzip` or `bzip2` program on Unix like operating systems.

extension     | extractor
--------------|------------
`.Z`          | compress
`.gz`         | gzip
`.bz2`        | bzip2
`.zip`        | zip (possibly a Windows program like `Winzip`)

A compressed archive bundles multiple files and folders into a single file while shrinking their total size. This makes file sharing, backups, and storage much easier.

- Popular formats include `.zip` for broad compatibility, `.rar` for high ratios, and `.7z` for maximum compression.

## tar - tape archives

[tar](https://en.wikipedia.org/wiki/Tar_(computing)) is a file format and a file archiver program. The program **combines** multiple files into a *single* archive file in the *tar* file format. It was originally developed for magnetic tape computer storage – reading and writing data for a sequential I/O device with no file system, and the name is short for the format description "**t**ape **ar**chive". When stored in a file system, a file that tar reads and writes is often called a _tarball_.

```bash
NAME
     tar -- manipulate tape archives

SYNOPSIS
     tar [bundled-flags <args>] [<file> | <pattern> ...]
     tar {-c} [options] [files | directories]
     tar {-r | -u} -f archive-file [options] [files | directories]
     tar {-t | -x} [options] [patterns]
```

`-f`（`--file=ARCHIVE`）: Use archive file or device ARCHIVE.

**Operation mode**:

- `-c`/`--create`：创建打包
- `-r`/`--append`：追加打包

```bash
       -c, --create
              Create a new archive.  Arguments supply the names of the files
              to be archived.  Directories are archived recursively, unless
              the --no-recursion option is given.

       -r, --append
              Append files to the end of an archive.  Arguments have the
              same meaning as for -c (--create).
```

- `-t`/`--list`：列举、查看、预览
- `-x`/`--extract`：解包还原

```bash
       -t, --list
              List the contents of an archive.  Arguments are optional.
              When given, they specify the names of the members to list.

       -x, --extract, --get
              Extract files from an archive.  Arguments are optional.  When
              given, they specify names of the archive members to be
              extracted.
```

**Compression options**:

指定 `-c`、`-t` 或 `-x` 的压缩/查看/解压缩方式：

- `-z`/`--gzip`：gzip/gunzip
- `-j`/`--bzip2`：bzip2/bunzip2

```bash
       -z, --gzip, --gunzip, --ungzip
              Filter the archive through gzip(1).

       -Z, --compress, --uncompress
              Filter the archive through compress(1).

       -j, --bzip2
              Filter the archive through bzip2(1).

       -J, --xz
              Filter the archive through xz(1).
```

If your system does not use GNU tar, you can still create a compressed tar file, via the following syntax:

```bash
$ tar -cvf - file1 file2 dir3 | gzip > archive.tar.gz

$ tar -cvf - file1 file2 dir3 | gzip > archive.tar.gz
```

## tar+gzip(.tgz)

`gzip` -- compression/decompression tool using Lempel-Ziv coding (LZ77)

**SYNOPSIS**: `gunzip` = `gzip -d`

- `gzip [-cdfhkLlNnqrtVv] [-S suffix] file [file [...]]`
- `gunzip [-cfhkLNqrtVv] [-S suffix] file [file [...]]`
- `zcat [-fhV] file [file [...]]`

**Usage Demo**:

- 压缩(`-c`)：`tar -czvf compressed_archive.tar.gz /path/to/dir/`  
- 列举(`-t`)：`tar -tzvf compressed_archive.tar.gz`  
- 解压(`-x`)：`tar -xzvf compressed_archive.tar.gz -C /path/to/dir/`  

**文件后缀**：`.tar.gz`(`.tgz`) = 打包（`.tar`） + 压缩（`.gz`）。

### create

tar 利用 gzip（`-z`）压缩打包（`-c`）文件（`-f`）：

```bash
# 将所有的 *.log 文件打包到 avg_speed.tar.gz
$ tar -czv -f avg_speed.tar.gz ~/Downloads/Logs/*-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-10-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-11-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-15-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-21-avg_speed.log

# 将所有的 *.png 文件打包到 map_image.tar.gz
$ tar -czv -f map_image.tar.gz ~/Downloads/Images/map-*.png
tar: Removing leading '/' from member names
a Users/faner/Downloads/Images/map-深圳市东湖公园.png
a Users/faner/Downloads/Images/map-深圳市梧桐山森林公园.png
a Users/faner/Downloads/Images/map-深圳市民中心周边公园.png
```

### list(preview)

file 命令查看文件属性：

```bash
$ file avg_speed.tar.gz
avg_speed.tar.gz: gzip compressed data, last modified: Sun Dec 15 02:08:21 2019, from Unix, original size modulo 2^32 19456

# -b, --brief ; -I, --mime
$ file -bI avg_speed.tar.gz
application/gzip; charset=binary
```

tar 利用 gzip（`-z`） 列举/查看/预览（`-t`）压缩打包文件（`-f`）：

```bash
$ tar -tzv -f avg_speed.tar.gz
-rw-r--r--  0 faner  staff    2394 Dec  1 16:54 Users/faner/Downloads/Logs/2019-12-01-10-avg_speed.log
-rw-r--r--  0 faner  staff    1638 Dec  1 16:55 Users/faner/Downloads/Logs/2019-12-01-11-avg_speed.log
-rw-r--r--  0 faner  staff    1640 Dec  1 17:00 Users/faner/Downloads/Logs/2019-12-01-15-avg_speed.log
-rw-r--r--  0 faner  staff    1184 Dec  1 21:38 Users/faner/Downloads/Logs/2019-12-01-21-avg_speed.log

$ tar -tzv -f map_image.tar.gz
-rw-r--r--  0 faner  staff 2619042 Dec  2  2018 Users/faner/Downloads/Images/map-深圳市东湖公园.png
-rw-r--r--  0 faner  staff 2592064 Dec  2  2018 Users/faner/Downloads/Images/map-深圳市梧桐山森林公园.png
-rw-r--r--  0 faner  staff 2888867 Dec  2  2018 Users/faner/Downloads/Images/map-深圳市民中心周边公园.png
```

### extract

tar 利用 gzip（`-z`） 解压（`-x`）压缩打包文件（`-f`）到指定目录（`-C`）：

> 如果不通过 `-C` 指定解压目录，则默认解压到当前目录！

```bash
$ mkdir avg_speed.tar

$ tar -xzv -f avg_speed.tar.gz -C ./avg_speed.tar
x 2019-12-01-10-avg_speed.log
x 2019-12-01-11-avg_speed.log
x 2019-12-01-15-avg_speed.log
x 2019-12-01-21-avg_speed.log
```

## tar+bzip2(.tbz2)

`bzip2`, `bunzip2` - a block-sorting file compressor
`bzcat` - decompresses files to stdout
`bzip2recover` - recovers data from damaged bzip2 files

**SYNOPSIS**: `bunzip2` = `bzip2 -d`

- `bzip2 [ -cdfkqstvzVL123456789 ] [ filenames ...  ]`
- `bunzip2 [ -fkvsVL ] [ filenames ...  ]`
- `bzcat [ -s ] [ filenames ...  ]`
- `bzip2recover filename`

use `bzip2` compression instead of `gzip` compression.

`-j` : Compress archive using `bzip2` program in Linux or Unix  

`-j` 替代 `-z`，即可用 bzip2 替换 gzip。

- 压缩(`-c`)：`tar -cjvf compressed_archive.tar.bz2 /path/to/dir/`  
- 列举(`-t`)：`tar -tjvf compressed_archive.tar.bz2`  
- 解压(`-x`)：`tar -xjvf compressed_archive.tar.bz2 -C /path/to/dir/`  

**文件后缀**：`.tar.bz2`(`.tbz2`) = 打包（`.tar`） + 压缩（`.bz2`）。

### create

tar 利用 bzip2（`-j`）压缩打包（`-c`）文件（`-f`）：

```bash
# 将所有的 *.log 文件打包到 avg_speed.tar.bz2
$ tar -cjv -f avg_speed.tar.bz2 ~/Downloads/Logs/*-avg_speed.log

# 将所有的 *.png 文件打包到 map_image.tar.bz2
$ tar -cjv -f map_image.tar.bz2 ~/Downloads/Images/map-*.png
```

### list(preview)

file 命令查看文件属性：

```bash
$ file avg_speed.tar.bz2
avg_speed.tar.bz2: bzip2 compressed data, block size = 900k

# -b, --brief ; -I, --mime
$ file -bI avg_speed.tar.bz2
application/x-bzip2; charset=binary
```

tar 利用 bzip2（`-j`） 列举/查看/预览（`-t`）压缩打包文件（`-f`）：

```bash
$ tar -tjv -f avg_speed.tar.bz2

$ tar -tjv -f map_image.tar.bz2
```

### extract

tar 利用 bzip2（`-z`） 解压（`-x`）压缩打包文件（`-f`）到指定目录（`-C`）：

> 如果不通过 `-C` 指定解压目录，则默认解压到当前目录！

```bash
$ mkdir avg_speed.tar

$ tar -xjv -f avg_speed.tar.bz2 -C ./avg_speed.tar
```
