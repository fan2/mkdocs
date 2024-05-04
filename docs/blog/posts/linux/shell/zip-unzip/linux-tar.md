---
title: Linux Command - tar/bzip2
authors:
  - xman
date:
    created: 2019-10-30T10:00:00
categories:
    - wiki
    - linux
tags:
    - tar
comments: true
---

linux 下的 压缩/解压缩（tar）命令。

<!-- more -->

## .tar.gz

### create

tar 利用 gzip（`-z`） 压缩打包（`-c`）log、image 文件：

```
FAN-MB1:zip $ tar -czv -f avg_speed.tar.gz ~/Downloads/Logs/*-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-10-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-11-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-15-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-21-avg_speed.log

FAN-MB1:zip $ tar -czv -f map_image.tar.gz ~/Downloads/Images/map-*.png
tar: Removing leading '/' from member names
a Users/faner/Downloads/Images/map-深圳市东湖公园.png
a Users/faner/Downloads/Images/map-深圳市梧桐山森林公园.png
a Users/faner/Downloads/Images/map-深圳市民中心周边公园.png
```

### list(preview)

file 命令查看文件属性：

```
faner@FAN-MB1:~/Downloads/zip
> file avg_speed.tar.gz
avg_speed.tar.gz: gzip compressed data, last modified: Sun Dec 15 02:08:21 2019, from Unix, original size modulo 2^32 19456
faner@FAN-MB1:~/Downloads/zip
> file -bI avg_speed.tar.gz
application/gzip; charset=binary
```

`tar -tzvf` 用 gzip（`-z`） 查看打包（`-t`） 文件：

```
FAN-MB1:zip $ tar -tzv -f avg_speed.tar.gz
-rw-r--r--  0 faner  staff    2394 Dec  1 16:54 Users/faner/Downloads/Logs/2019-12-01-10-avg_speed.log
-rw-r--r--  0 faner  staff    1638 Dec  1 16:55 Users/faner/Downloads/Logs/2019-12-01-11-avg_speed.log
-rw-r--r--  0 faner  staff    1640 Dec  1 17:00 Users/faner/Downloads/Logs/2019-12-01-15-avg_speed.log
-rw-r--r--  0 faner  staff    1184 Dec  1 21:38 Users/faner/Downloads/Logs/2019-12-01-21-avg_speed.log

FAN-MB1:zip $ tar -tzv -f map_image.tar.gz
-rw-r--r--  0 faner  staff 2619042 Dec  2  2018 Users/faner/Downloads/Images/map-深圳市东湖公园.png
-rw-r--r--  0 faner  staff 2592064 Dec  2  2018 Users/faner/Downloads/Images/map-深圳市梧桐山森林公园.png
-rw-r--r--  0 faner  staff 2888867 Dec  2  2018 Users/faner/Downloads/Images/map-深圳市民中心周边公园.png
```

### extract

如果不通过 `-C` 指定解压目录，则默认解压到当前目录！！！

```
faner@MBP-FAN:~/Downloads/zip
> mkdir avg_speed.tar

faner@MBP-FAN:~/Downloads/zip
> tar -xzv -f avg_speed.tar.gz -C ./avg_speed.tar
x 2019-12-01-10-avg_speed.log
x 2019-12-01-11-avg_speed.log
x 2019-12-01-15-avg_speed.log
x 2019-12-01-21-avg_speed.log
```

## .tar.bz2

### create

tar 利用 bzip2（`-j`） 压缩打包（`-c`）log、image 文件：

```
FAN-MB1:zip $ tar -cjv -f avg_speed.tar.bz2 ~/Downloads/Logs/*-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-10-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-11-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-15-avg_speed.log
a Users/faner/Downloads/Logs/2019-12-01-21-avg_speed.log

FAN-MB1:zip $ tar -cjv -f map_image.tar.bz2 ~/Downloads/Images/map-*.png
tar: Removing leading '/' from member names
a Users/faner/Downloads/Images/map-深圳市东湖公园.png
a Users/faner/Downloads/Images/map-深圳市梧桐山森林公园.png
a Users/faner/Downloads/Images/map-深圳市民中心周边公园.png
```

### list(preview)

file 命令查看文件属性：

```
faner@FAN-MB1:~/Downloads/zip
> file avg_speed.tar.bz2
avg_speed.tar.bz2: bzip2 compressed data, block size = 900k
faner@FAN-MB1:~/Downloads/zip
> file -bI avg_speed.tar.bz2
application/x-bzip2; charset=binary
```

`tar -tjvf` 用 bzip2（`-j`） 查看打包（`-t`） 文件：预览压缩包内容：

```
FAN-MB1:zip $ tar -tjv -f avg_speed.tar.bz2
-rw-r--r--  0 faner  staff    2394 Dec  1 16:54 Users/faner/Downloads/Logs/2019-12-01-10-avg_speed.log
-rw-r--r--  0 faner  staff    1638 Dec  1 16:55 Users/faner/Downloads/Logs/2019-12-01-11-avg_speed.log
-rw-r--r--  0 faner  staff    1640 Dec  1 17:00 Users/faner/Downloads/Logs/2019-12-01-15-avg_speed.log
-rw-r--r--  0 faner  staff    1184 Dec  1 21:38 Users/faner/Downloads/Logs/2019-12-01-21-avg_speed.log

FAN-MB1:zip $ tar -tjv -f map_image.tar.bz2
-rw-r--r--  0 faner  staff 2619042 Dec  2  2018 Users/faner/Downloads/Images/map-深圳市东湖公园.png
-rw-r--r--  0 faner  staff 2592064 Dec  2  2018 Users/faner/Downloads/Images/map-深圳市梧桐山森林公园.png
-rw-r--r--  0 faner  staff 2888867 Dec  2  2018 Users/faner/Downloads/Images/map-深圳市民中心周边公园.png
```

### extract

如果不通过 `-C` 指定解压目录，则默认解压到当前目录！！！

```
faner@FAN-MB1:~/Downloads/zip
> mkdir avg_speed.tar

faner@FAN-MB1:~/Downloads/zip
> tar -xjv -f avg_speed.tar.bz2 -C ./avg_speed.tar
x 2019-12-01-10-avg_speed.log
x 2019-12-01-11-avg_speed.log
x 2019-12-01-15-avg_speed.log
x 2019-12-01-21-avg_speed.log
```
