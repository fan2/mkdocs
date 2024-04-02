---
draft: true
title: Linux Command - tar/bzip2
authors:
  - xman
date:
    created: 2019-10-30T09:40:00
categories:
    - wiki
    - linux
    - command
tags:
    - zip
    - unzip
comments: true
---

linux 下的 压缩/解压缩（tar）命令。

<!-- more -->

## [tar](http://man7.org/linux/man-pages/man1/tar.1.html)

BSD General Commands Manual

```
NAME
     tar -- manipulate tape archives

SYNOPSIS
     tar [bundled-flags <args>] [<file> | <pattern> ...]
     tar {-c} [options] [files | directories]
     tar {-r | -u} -f archive-file [options] [files | directories]
     tar {-t | -x} [options] [patterns]
```

`-f`（`--file=ARCHIVE`）: Use archive file or device ARCHIVE.

**Operation mode**

`-c`：创建打包；

```
       -c, --create
              Create a new archive.  Arguments supply the names of the files
              to be archived.  Directories are archived recursively, unless
              the --no-recursion option is given.

       -r, --append
              Append files to the end of an archive.  Arguments have the
              same meaning as for -c (--create).
```

`-t`：列举、查看、预览；  
`-x`：解包还原；  

```
       -t, --list
              List the contents of an archive.  Arguments are optional.
              When given, they specify the names of the members to list.

       -x, --extract, --get
              Extract files from an archive.  Arguments are optional.  When
              given, they specify names of the archive members to be
              extracted.
```

**Compression options**

指定 `-c`、`-t` 或 `-x` 的压缩/解压缩方式：

`-z`：gzip/gunzip；  
`-j`：bzip2/bunzip2；  

```
       -z, --gzip, --gunzip, --ungzip
              Filter the archive through gzip(1).

       -Z, --compress, --uncompress
              Filter the archive through compress(1).

       -j, --bzip2
              Filter the archive through bzip2(1).

       -J, --xz
              Filter the archive through xz(1).
```

### c

[How do I Compress a Whole Linux or UNIX Directory?](https://www.cyberciti.biz/faq/how-do-i-compress-a-whole-linux-or-unix-directory/)

=> Create the archive(`.tar`)  
=> Compress the archive(`.gz`)  
=> Additional operations includes listing or updating the archive  

```
tar -czvf archive-name.tar.gz directory-name
```

### t

`-t, --list` : List archive contents to stdout.  

To view a detailed table of contents (list all files) for this archive, enter:

```
tar -tzvf data.tar.gz
```

### x

[HowTo: Open a Tar.gz File In Linux / Unix](https://www.cyberciti.biz/faq/howto-open-a-tar-gz-file-in-linux-unix/)  

`-x` : **Extract** files from given archive

```
tar -xzvf data.tar.gz
```

---

By defaults files will be extracted into the current directory. 

> `$ tar -xzvf prog-1-jan-2005.tar.gz` will extract all files in current directory

To change the directory use `-C` option. In this example, extract files in `/data/projects` directory:

```
$ tar -xzvf prog-1-jan-2005.tar.gz -C /tmp
$ tar -xzvf data.tar.gz -C /data/projects
```

#### j(bzip2)

use `bzip2` compression instead of `gzip` compression

`-j` : Compress archive using `bzip2` program in Linux or Unix  

j 替代 z，即可用 bzip2 替换 gzip。

- 压缩(`-c`)：`tar -cjvf my-compressed.tar.bz2 /path/to/dir/`  
- 列举(`-t`)：`tar -tjvf my-compressed.tar.bz2`  
- 解压(`-x`)：`tar -xjvf my-compressed.tar.bz2 -C /path/to/dir/`  

**文件后缀**：`.tar.bz2` = 打包（`.tar`）+压缩（`.bz2`）

`filename.tbz2`（`filename.tar.bz2`） 和 `filename.tbz`（`filename.tar.bz`） 解压出 `filename.tar`。

### non gnu/tar

If your system does not use GNU tar, you can still create a compressed tar file, via the following syntax:

```
tar -cvf - file1 file2 dir3 | gzip > archive.tar.gz
```
