---
draft: true
title: Linux Command - zip/unzip
authors:
  - xman
date:
    created: 2019-10-30T08:30:00
categories:
    - wiki
    - linux
    - command
tags:
    - zip
    - unzip
comments: true
---

linux 下的 压缩/解压缩（zip/unzip）命令。

<!-- more -->

[Using Compressed Data in Linux](https://ssc.wisc.edu/sscc/pubs/7-8.htm)  
[Linux gzip, gunzip, and zcat commands](https://www.computerhope.com/unix/uzcat.htm)  

A `.tar.gz` (also `.tgz`) file is nothing but an archive. It is a file that acts as a **container** for other files.  
An archive can contain many files, folders, and subfolders, usually in compressed form using `gzip` or `bzip2` program on Unix like operating systems.

extension     | extractor
--------------|------------
`.Z`          | compress
`.gz`         | gzip
`.bz2`        | bzip2
`.zip`        | zip (possibly a Windows program like `Winzip`)

## zip

**zip** = tar + compress

```
NAME
       zip - package and compress (archive) files

SYNOPSIS
       zip  [-aABcdDeEfFghjklLmoqrRSTuvVwXyz!@$]  [--longoption  ...]   [-b path] [-n suf-
       fixes] [-t date] [-tt date] [zipfile [file ...]]  [-xi list]

       zipcloak (see separate man page)

       zipnote (see separate man page)

       zipsplit (see separate man page)

       Note:  Command line processing in zip has been changed to support long options  and
       handle  all  options  and arguments more consistently.  Some old command lines that
       depend on command line inconsistencies may no longer work.

DESCRIPTION
       zip is a compression and file packaging utility for Unix, VMS, MSDOS, OS/2, Windows
       9x/NT/XP,  Minix, Atari, Macintosh, Amiga, and Acorn RISC OS.  It is analogous to a
       combination of the Unix commands tar(1) and  compress(1)  and  is  compatible  with
       PKZIP (Phil Katz's ZIP for MSDOS systems).
       
SEE ALSO
       compress(1), shar(1L), tar(1), unzip(1L), gzip(1L)
```

#### extension

If the name of the zip archive does not contain an extension, the extension `.zip` is added.  
If the name already contains an extension other than `.zip`, the existing extension is kept unchanged.  
However, split archives (archives split over multiple files) require the `.zip` extension on the last split.  

#### Command modes

zip now supports two distinct types of command modes, external and internal.  
The **external** modes (`add`, `update`, and `freshen`) read files from the file system(as well as from an existing archive) while the **internal** modes (`delete` and `copy`) operate exclusively on entries in an existing archive.

```
       add
              Update existing entries and add new files.  If the archive  does  not  exist
              create it.  This is the default mode.

       update (-u)
              Update  existing  entries if newer on the file system and add new files.  If
              the archive does not exist issue warning then create a new archive.

       freshen (-f)
              Update existing entries of an archive if newer on the file system.  Does not
              add new files to the archive.

       delete (-d)
              Select entries in an existing archive and delete them.

       copy (-U)
              Select  entries in an existing archive and copy them to a new archive.  This
              new mode is similar to update but command line patterns  select  entries  in
              the  existing archive rather than files from the file system and it uses the
              --out option to write the resulting archive to a new file rather than update
              the existing archive, leaving the original archive unchanged.
```

> 如果 zipfile 已存在，默认是以 `add` 方式追加；否则创建。

#### -O

`-O output-file` 保留原始压缩包，指定操作后的新压缩包：

```
       -O output-file
       --output-file output-file
              Process  the  archive changes as usual, but instead of updating the existing
              archive, output the new archive to output-file.  Useful for updating an  ar-
              chive  without changing the existing archive and the input archive must be a
              different file than the output archive.
```

#### -r

```
       -r
       --recurse-paths
              Travel the directory structure recursively; for example:

                     zip -r foo.zip foo

              or more concisely

                     zip -r foo foo

              Multiple source directories are allowed as in

                     zip -r foo foo1 foo2

              which first zips up foo1 and then foo2, going down each directory.
```

`zip -r myfile.zip ./*`：将当前目录下的所有文件和文件夹压缩成 myfile.zip 文件。

`zip -r foo "*.c"`：将当前目录下的所有c后缀的文件压缩成 foo.zip 文件。

#### -R

```
       -R
       --recurse-patterns
              Travel  the  directory  structure recursively starting at the current directory
```

#### -i

```
       -i files
       --include files
              Include only the specified files
```

只包含指定文件（子目录）：

```
# 将当前目录下的所有 *.c 打包成 foo(.zip)
zip -r foo . -i \*.c

# 将当前目录下的 dir 子目录打包成 foo(.zip)
zip -r foo . -i dir/\*
zip -r foo . -i "dir/*"
```

#### -x

```
       -x files
       --exclude files
              Explicitly exclude the specified files
```

将当前目录下的 foo 子目录（除了 *.o）压缩打包成 foo(.zip)：

```
zip -r foo foo -x \*.o
zip -r foo foo -x .DS_Store
zip -r foo foo -x __MACOSX/\*
```

#### -n

指定后缀的文件不压缩，只打包。

```
       -n suffixes
       --suffixes suffixes
              Do not attempt to compress files named with the given suffixes.  Such  files
              are  simply  stored  (0%  compression)  in  the output zip file, so that zip
              doesn't waste its time trying to compress them.  The suffixes are  separated
              by either colons or semicolons.  For example:

                     zip -rn .Z:.zip:.tiff:.gif:.snd  foo foo

              will  copy  everything  from foo into foo.zip, but will store any files that
              end in .Z, .zip, .tiff, .gif, or .snd without trying to compress them (image
              and  sound  files often have their own specialized compression methods).
```

## unzip

```
NAME
       unzip - list, test and extract compressed files in a ZIP archive

SYNOPSIS
       unzip     [-Z]    [-cflptTuvz[abjnoqsCDKLMUVWX$/:^]]    file[.zip]    [file(s) ...]
       [-x xfile(s) ...] [-d exdir]

DESCRIPTION
       unzip will list, test, or extract files from a ZIP archive, commonly found  on  MS-
       DOS systems.  The default behavior (with no options) is to extract into the current
       directory (and subdirectories below it) all files from the specified  ZIP  archive.
       A  companion  program,  zip(1L), creates ZIP archives; both programs are compatible
       with archives created by PKWARE's PKZIP and PKUNZIP for MS-DOS, but in  many  cases
       the program options or default behaviors differ.
       
SEE ALSO
       funzip(1L),  zip(1L),  zipcloak(1L),  zipgrep(1L),  zipinfo(1L),  zipnote(1L), zip-
       split(1L)
```

ARGUMENTS：

```
       file[.zip]
              Path  of  the ZIP archive(s).

       [file(s)]
              An optional list of archive members to be processed,  separated  by  spaces.

       [-x xfile(s)]
              An  optional  list of archive members to be excluded from processing.

       [-d exdir]
              An  optional directory to which to extract files.  By default, all files and
              subdirectories are recreated in the current directory;
```

file(s) 指定只解压出 zip 中的某些文件。
