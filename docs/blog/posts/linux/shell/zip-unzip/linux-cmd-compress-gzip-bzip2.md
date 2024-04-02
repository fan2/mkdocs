---
draft: true
title: Linux Command - compress/gzip/bzip2/xz
authors:
  - xman
date:
    created: 2019-10-30T10:10:00
categories:
    - wiki
    - linux
    - command
tags:
    - compress
    - gzip
    - bzip2
    - xz
comments: true
---

linux 下的 压缩/解压缩 命令 —— compress/gzip/bzip2/xz。

<!-- more -->

[Using Compressed Data in Linux](https://ssc.wisc.edu/sscc/pubs/7-8.htm)  
[Linux gzip, gunzip, and zcat commands](https://www.computerhope.com/unix/uzcat.htm)  

A `.tar.gz` (also `.tgz`) file is nothing but an archive.  
It is a file that acts as a **container** for other files.  
An archive can contain many files, folders, and subfolders, usually in compressed form using `gzip` or `bzip2` program on Unix like operating systems.

extension     | extractor
--------------|------------
`.Z`          | compress
`.gz`         | gzip
`.bz2`        | bzip2
`.zip`        | zip (possibly a Windows program like `Winzip`)

## compress/uncompress

DEPRECATED

**压缩算法**：adaptive Lempel-Ziv coding  
**文件后缀**：`.Z`  

```
COMPRESS(1)               BSD General Commands Manual              COMPRESS(1)

NAME
     compress, uncompress -- compress and expand data

SYNOPSIS
     compress [-fv] [-b bits] [file ...]
     compress -c [-b bits] [file ...]
     uncompress [-fv] [file ...]
     uncompress -c [file ...]

DESCRIPTION
     The compress utility reduces the size of files using adaptive Lempel-Ziv coding.
     Each file is renamed to the same name plus the extension .Z.  A file argument with a
     .Z extension will be ignored except it will cause an error exit after other arguments
     are processed.  If compression would not reduce the size of a file, the file is
     ignored.

     The uncompress utility restores compressed files to their original form, renaming the
     files by deleting the .Z extensions.  A file specification need not include the
     file's .Z extension.  If a file's name in its file system does not have a .Z exten-
     sion, it will not be uncompressed and it will cause an error exit after other argu-
     ments are processed.
     
SEE ALSO
     gunzip(1), gzexe(1), gzip(1), zcat(1), zmore(1), znew(1)
```

## gzip/gunzip

POPULAR

**压缩算法**：Lempel-Ziv coding (LZ77)  
**文件后缀**：`.gz`  

```
GZIP(1)                   BSD General Commands Manual                  GZIP(1)

NAME
     gzip -- compression/decompression tool using Lempel-Ziv coding (LZ77)

SYNOPSIS
     gzip [-cdfhkLlNnqrtVv] [-S suffix] file [file [...]]
     gunzip [-cfhkLNqrtVv] [-S suffix] file [file [...]]
     zcat [-fhV] file [file [...]]
     
SEE ALSO
     bzip2(1), compress(1), xz(1), fts(3), zlib(3)
```

- If invoked as `gunzip` then the `-d` option is enabled.  
- If invoked as `zcat` or `gzcat` then both the `-c` and `-d` options are enabled.  

## bzip2/bunzip2

ESSENTIAL

**压缩算法**：Burrows-Wheeler block sorting text compression
       algorithm, and Huffman coding，优于传统的 LZ77/LZ78-based 算法。  
**文件后缀**：`.bz2`, `.bz`, `.tbz2` or `.tbz`  

```
NAME
       bzip2, bunzip2 - a block-sorting file compressor, v1.0.6
       bzcat - decompresses files to stdout
       bzip2recover - recovers data from damaged bzip2 files


SYNOPSIS
       bzip2 [ -cdfkqstvzVL123456789 ] [ filenames ...  ]
       bunzip2 [ -fkvsVL ] [ filenames ...  ]
       bzcat [ -s ] [ filenames ...  ]
       bzip2recover filename
       
DESCRIPTION
       bzip2  compresses  files  using  the Burrows-Wheeler block sorting text compression
       algorithm, and Huffman coding.  Compression is generally considerably  better  than
       that  achieved by more conventional LZ77/LZ78-based compressors, and approaches the
       performance of the PPM family of statistical compressors.
```

`bzip2` and `bunzip2` will by default not overwrite existing files.  
If you want  this to happen, specify the `-f` flag.  

`bunzip2`  (or `bzip2 -d`) decompresses all specified files.

## xz/unxz

XZ Utils

```
NAME
       xz, unxz, xzcat, lzma, unlzma, lzcat - Compress or decompress .xz and .lzma files

SYNOPSIS
       xz [option...]  [file...]

COMMAND ALIASES
       unxz is equivalent to xz --decompress.
       xzcat is equivalent to xz --decompress --stdout.
       lzma is equivalent to xz --format=lzma.
       unlzma is equivalent to xz --format=lzma --decompress.
       lzcat is equivalent to xz --format=lzma --decompress --stdout.
       
DESCRIPTION
       xz  is  a general-purpose data compression tool with command line syntax similar to
       gzip(1) and bzip2(1).  The native file format is the .xz  format,  but  the  legacy
       .lzma format used by LZMA Utils and raw compressed streams with no container format
       headers are also supported.
```

- `lzmainfo` - show information stored in the .lzma file header  
- `xzdec`, lzmadec - Small .xz and .lzma decompressors  
- `xzcmp`, xzdiff, lzcmp, lzdiff - compare compressed files  
- `xzless`, lzless - view xz or lzma compressed (text) files  
- `xzmore`, lzmore - view xz or lzma compressed (text) files  
- `xzgrep` - search compressed files for a regular expression  

