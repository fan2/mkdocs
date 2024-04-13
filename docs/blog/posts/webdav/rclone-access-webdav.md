---
title: 使用rclone访问操作WebDav云盘并配置crontab定时自动同步
authors:
  - xman
date:
    created: 2024-03-18T15:30:00
    updated: 2024-04-11T12:00:00
categories:
    - macOS
    - ubuntu
    - webDAV
tags:
    - webDAV
    - rclone
comments: true
---

在 [使用命令行挂载操作WebDav云盘](./cmd-mount-webdav.md) 中梳理了 macOS/Linux 下调用 mount 命令挂载 WebDAV 云盘到本地的基本操作，并且示例了如何使用 curl 命令行访问操作 WebDAV 云盘。

本文让我们来看一看如何使用强大的 [rclone](https://rclone.org/) 命令行工具配置挂载 WebDAV 云盘，并对标 curl 梳理 rclone 访问操控 webDAV 云盘的常用命令。

最后，在 macOS/ubuntu 下使用 cron 配置定时任务（crontab），实现本地与云盘之间同步备份自动化。

<!-- more -->

!!! note "rclone works like a charm!"

    [rclone](https://rclone.org/): Rclone syncs your files to cloud storage

    Users call rclone "The Swiss army knife of cloud storage", and "Technology indistinguishable from magic".

Rclone has powerful cloud equivalents to the unix commands `rsync`, `cp`, `mv`, `mount`, `ls`, `ncdu`, `tree`, `rm`, and `cat`. Rclone's familiar syntax includes shell pipeline support, and `--dry-run` protection. It is used at the command line, in scripts or via its API.

Rclone mounts any local, cloud or virtual filesystem as a disk on Windows, macOS, linux and FreeBSD, and also serves these over SFTP, HTTP, WebDAV, FTP and DLNA.

Rclone is mature, open-source software originally inspired by rsync and written in [Go](https://golang.org/).

## install

macOS 下使用包管理器 `brew` 搜索安装 rclone；ubuntu 下使用包管理器 `apt` 搜索安装 rclone。

=== "macOS"

    - `brew search rclone`: 搜索 rclone 包
    - `brew info rclone`: 显示 rclone 包信息
    - `brew install rclone`: 安装 rclone

=== "ubuntu"

    - `apt search rclone`: 搜索 rclone 相关包
    - `apt list rclone`: 搜索匹配包名 rclone
    - `apt show rclone`: 显示 rclone 包详细信息
    - `[sudo] apt install rclone`: 安装 rclone

安装完成后，执行 `rclone version` 查看版本信息：

=== "macOS"

    ```Shell
    $ rclone version
    rclone v1.66.0
    - os/version: darwin 14.5 (64 bit)
    - os/kernel: 23.5.0 (x86_64)
    - os/type: darwin
    - os/arch: amd64
    - go/version: go1.22.1
    - go/linking: dynamic
    - go/tags: none
    ```

=== "ubuntu"

    ```Shell
    $ rclone version
    rclone v1.53.3-DEV
    - os/arch: linux/arm64
    - go version: go1.18.1
    ```

执行 `rclone config paths`、`rclone config show` 查看配置信息。

## docs

[Overview of cloud storage systems](https://rclone.org/overview/#optional-features)

- [Local Filesystem](https://rclone.org/local/)
- [WebDAV](https://rclone.org/webdav/)

[Commands Index](https://rclone.org/commands/)

- This is an index of all commands in rclone. Run `rclone command --help` to see the help for that command.

[rclone mount](https://rclone.org/commands/rclone_mount/) / [nfsmount](https://rclone.org/commands/rclone_nfsmount/)

[rclone serve](https://rclone.org/commands/rclone_serve/) - [webdav](https://rclone.org/commands/rclone_serve_webdav/)

[Remote Control / API](https://rclone.org/rc/) - [GUI](https://rclone.org/gui/)

[Usage](https://rclone.org/docs/): [Filtering](https://rclone.org/filtering/), [Flags](https://rclone.org/flags/)

## config

在命令行输入 `rclone config` 进入交互式配置会话。

### config webdav

以下使用 `rclone config` 交互式配置 webDAV 服务，其中高亮行是交互输入。

??? note "rclone config webdav"

    ```Shell linenums="1" hl_lines="6 9 124 130 150 156 164 166 168 173 178 191 206"
    $ rclone config
    No remotes found, make a new one?
    n) New remote
    s) Set configuration password
    q) Quit config
    n/s/q> n

    Enter name for new remote.
    name> webdav@rpi4b

    Option Storage.
    Type of storage to configure.
    Choose a number from below, or type in your own value.
    1 / 1Fichier
    \ (fichier)
    2 / Akamai NetStorage
    \ (netstorage)
    3 / Alias for an existing remote
    \ (alias)
    4 / Amazon S3 Compliant Storage Providers including AWS, Alibaba, ArvanCloud, Ceph, ChinaMobile, Cloudflare, DigitalOcean, Dreamhost, GCS, HuaweiOBS, IBMCOS, IDrive, IONOS, LyveCloud, Leviia, Liara, Linode, Minio, Netease, Petabox, RackCorp, Rclone, Scaleway, SeaweedFS, StackPath, Storj, Synology, TencentCOS, Wasabi, Qiniu and others
    \ (s3)
    5 / Backblaze B2
    \ (b2)
    6 / Better checksums for other remotes
    \ (hasher)
    7 / Box
    \ (box)
    8 / Cache a remote
    \ (cache)
    9 / Citrix Sharefile
    \ (sharefile)
    10 / Combine several remotes into one
    \ (combine)
    11 / Compress a remote
    \ (compress)
    12 / Dropbox
    \ (dropbox)
    13 / Encrypt/Decrypt a remote
    \ (crypt)
    14 / Enterprise File Fabric
    \ (filefabric)
    15 / FTP
    \ (ftp)
    16 / Google Cloud Storage (this is not Google Drive)
    \ (google cloud storage)
    17 / Google Drive
    \ (drive)
    18 / Google Photos
    \ (google photos)
    19 / HTTP
    \ (http)
    20 / Hadoop distributed file system
    \ (hdfs)
    21 / HiDrive
    \ (hidrive)
    22 / ImageKit.io
    \ (imagekit)
    23 / In memory object storage system.
    \ (memory)
    24 / Internet Archive
    \ (internetarchive)
    25 / Jottacloud
    \ (jottacloud)
    26 / Koofr, Digi Storage and other Koofr-compatible storage providers
    \ (koofr)
    27 / Linkbox
    \ (linkbox)
    28 / Local Disk
    \ (local)
    29 / Mail.ru Cloud
    \ (mailru)
    30 / Mega
    \ (mega)
    31 / Microsoft Azure Blob Storage
    \ (azureblob)
    32 / Microsoft Azure Files
    \ (azurefiles)
    33 / Microsoft OneDrive
    \ (onedrive)
    34 / OpenDrive
    \ (opendrive)
    35 / OpenStack Swift (Rackspace Cloud Files, Blomp Cloud Storage, Memset Memstore, OVH)
    \ (swift)
    36 / Oracle Cloud Infrastructure Object Storage
    \ (oracleobjectstorage)
    37 / Pcloud
    \ (pcloud)
    38 / PikPak
    \ (pikpak)
    39 / Proton Drive
    \ (protondrive)
    40 / Put.io
    \ (putio)
    41 / QingCloud Object Storage
    \ (qingstor)
    42 / Quatrix by Maytech
    \ (quatrix)
    43 / SMB / CIFS
    \ (smb)
    44 / SSH/SFTP
    \ (sftp)
    45 / Sia Decentralized Cloud
    \ (sia)
    46 / Storj Decentralized Cloud Storage
    \ (storj)
    47 / Sugarsync
    \ (sugarsync)
    48 / Transparently chunk/split large files
    \ (chunker)
    49 / Union merges the contents of several upstream fs
    \ (union)
    50 / Uptobox
    \ (uptobox)
    51 / WebDAV
    \ (webdav)
    52 / Yandex Disk
    \ (yandex)
    53 / Zoho
    \ (zoho)
    54 / premiumize.me
    \ (premiumizeme)
    55 / seafile
    \ (seafile)
    Storage> 51 # 注释：或直接输入 webdav

    Option url.
    URL of http host to connect to.
    E.g. https://example.com.
    Enter a value.
    url> http://rpi4b-ubuntu.local:81/webdav/

    Option vendor.
    Name of the WebDAV site/service/software you are using.
    Choose a number from below, or type in your own value.
    Press Enter to leave empty.
    1 / Fastmail Files
    \ (fastmail)
    2 / Nextcloud
    \ (nextcloud)
    3 / Owncloud
    \ (owncloud)
    4 / Sharepoint Online, authenticated by Microsoft account
    \ (sharepoint)
    5 / Sharepoint with NTLM authentication, usually self-hosted or on-premises
    \ (sharepoint-ntlm)
    6 / rclone WebDAV server to serve a remote over HTTP via the WebDAV protocol
    \ (rclone)
    7 / Other site/service or software
    \ (other)
    vendor> 7

    Option user.
    User name.
    In case NTLM authentication is used, the username should be in the format 'Domain\User'.
    Enter a value. Press Enter to leave empty.
    user> xman

    Option pass.
    Password.
    Choose an alternative below. Press Enter for the default (n).
    y) Yes, type in my own password
    g) Generate random password
    n) No, leave this optional password blank (default)
    y/g/n> y
    Enter the password:
    password:
    Confirm the password:
    password:

    Option bearer_token.
    Bearer token instead of user/pass (e.g. a Macaroon).
    Enter a value. Press Enter to leave empty.
    bearer_token> # 注释：这里暂时直接回车忽略

    Edit advanced config?
    y) Yes
    n) No (default)
    y/n> n

    Configuration complete.
    Options:
    - type: webdav
    - url: http://rpi4b-ubuntu.local:81/webdav/
    - vendor: other
    - user: xman
    - pass: *** ENCRYPTED ***
    Keep this "webdav@rpi4b" remote?
    y) Yes this is OK (default)
    e) Edit this remote
    d) Delete this remote
    y/e/d> y

    Current remotes:

    Name                 Type
    ====                 ====
    webdav@rpi4b         webdav

    e) Edit existing remote
    n) New remote
    d) Delete remote
    r) Rename remote
    c) Copy remote
    s) Set configuration password
    q) Quit config
    e/n/d/r/c/s/q> q
    ```

这里示例配置 webDAV，也可选择配置本地磁盘（或外挂硬盘/SSD）或局域网 SMB 等 FS（File Sharing）服务。

- 28 / Local Disk \\ (local)
- 43 / SMB / CIFS \\ (smb)

如果中途不小心输错或后续想更改配置，可输入 `rclone config edit` 选择编辑已有的配置。

> ⚠️：在 ubuntu 中，remote name 中不能包含 @ 符号，可改为 - 替代：webdav-rpi4b。

### config show

rclone config 配置完成后，可调用相关命令 dump/show 相关配置信息：

| Command | Description |
|---------|-------------|
| [rclone config paths](https://rclone.org/commands/rclone_config_paths/) | Show paths used for configuration, cache, temp etc.                           |
| [rclone config file](https://rclone.org/commands/rclone_config_file/)   | Show path of configuration file in use.                                       |
| [rclone config show](https://rclone.org/commands/rclone_config_show/)   | Print (decrypted) config file, or the config for a single remote.             |
| [rclone config dump](https://rclone.org/commands/rclone_config_dump/)   | Dump the config file as JSON.                                                 |
| [rclone listremotes](https://rclone.org/commands/rclone_listremotes/)   | List all the remotes in the config file and defined in environment variables. |

查看配置文件路径：

```Shell
$ rclone config paths
Config file: /Users/faner/.config/rclone/rclone.conf
Cache dir:   /Users/faner/Library/Caches/rclone
Temp dir:    /var/folders/k6/7f8bh1ws4ygfg9pcq48w5tk00000gn/T

$ rclone config file
Configuration file is stored at:
/Users/faner/.config/rclone/rclone.conf
```

查看配置文件中的配置：

```Shell
$ rclone config show
[webdav@rpi4b]
type = webdav
url = http://rpi4b-ubuntu.local:81/webdav/
vendor = other
user = xman
pass = *** ENCRYPTED ***

$ rclone config dump
{
    "webdav@rpi4b": {
        "pass": "*** ENCRYPTED ***",
        "type": "webdav",
        "url": "http://rpi4b-ubuntu.local:81/webdav/",
        "user": "xman",
        "vendor": "other"
    }
}%
```

列举配置文件中已配置的远端服务（名称）：

```Shell
$ rclone listremotes
webdav@rpi4b:
```

## ls

`ls` 系列命令语义同 bash shell 中的 `ls`，拉取远端目录（fetch remote:path）并显示列表（list）。

[Commands Index](https://rclone.org/commands/)

| Command | Description |
|---------|-------------|
| [rclone ls](https://rclone.org/commands/rclone_ls/)         | List the objects in the path with size and path.                    |
| [rclone lsd](https://rclone.org/commands/rclone_lsd/)       | List all directories/containers/buckets in the path.                |
| [rclone lsf](https://rclone.org/commands/rclone_lsf/)       | List directories and objects in remote\:path formatted for parsing. |
| [rclone lsjson](https://rclone.org/commands/rclone_lsjson/) | List directories and objects in the path in JSON format.            |
| [rclone lsl](https://rclone.org/commands/rclone_lsl/)       | List the objects in path with modification time, size and path.     |
| [rclone tree](https://rclone.org/commands/rclone_tree/)     | List the contents of the remote in a tree like fashion. |
| [rclone cat](https://rclone.org/commands/rclone_cat/)       | Concatenates any files and sends them to stdout. |

There are several related list commands:

*   `ls` to list size and path of objects only
*   `lsl` to list modification time, size and path of objects only
*   `lsd` to list directories only
*   `lsf` to list objects and directories in easy to parse format
*   `lsjson` to list objects and directories in JSON format

`ls`,`lsl`,`lsd` are designed to be human-readable. `lsf` is designed to be human and machine-readable. `lsjson` is designed to be machine-readable.

Note that `ls` and `lsl`** recurse** by default - use `--max-depth 1` to stop the recursion.

The other list commands `lsd`,`lsf`,`lsjson` do not recurse by default - use `-R` to make them recurse.

`ls` 命令递归列举根路径下的所有文件（大小和路径）：

```Shell
$ rclone ls webdav@rpi4b:
      ...

$ rclone tree webdav@rpi4b:
      ...
```

`ls` 命令递归列举 `/mkdocs` 下的所有文件（大小和路径）：

```Shell
$ rclone ls webdav@rpi4b:/mkdocs
      310 hello-world-2.c
      310 hello-world-3.c
      310 hello-world-4.c
      279 hello-world.c
```

`lsl` 命令相比 `ls` 增加显示文件的修改时间（modification time）：

```Shell
$ rclone lsl webdav@rpi4b:
      ...

# /表示根路径，可省略
$ rclone lsl webdav@rpi4b:/mkdocs
      310 2024-04-01 18:05:13.000000000 hello-world-2.c
      310 2024-04-01 18:05:18.000000000 hello-world-3.c
      310 2024-04-01 18:25:27.000000000 hello-world-4.c
      279 2024-04-01 18:02:26.000000000 hello-world.c
```

`lsd` 命令显示指定路径（根目录）下的目录/容器/桶：

```Shell
$ rclone lsd webdav@rpi4b:
          -1 2024-04-05 08:34:31        -1 CS
          -1 2024-04-03 10:53:51        -1 English_Docs
          -1 2024-03-25 10:17:59        -1 The_Economist
          -1 2024-04-01 18:25:31        -1 mkdocs
```

`lsf` 命令以一种简单的方式列举目录（和文件）：

```Shell
$ rclone lsf webdav@rpi4b:
CS/
English_Docs/
The_Economist/
mkdocs/

# 过滤不显示 CS 和 mkdocs 目录
$ rclone lsf webdav@rpi4b: --exclude "{CS/**,mkdocs/**}"
English_Docs/
The_Economist/

$ rclone tree --max-depth 1 webdav@rpi4b:
/
├── CS
├── English_Docs
├── The_Economist
└── mkdocs

0 directories, 0 files
```

关于过滤，参考 [Filtering](https://rclone.org/filtering/) 选项参数。

- [Include-from intersection of patterns](https://forum.rclone.org/t/include-from-intersection-of-patterns/13455)
- [How to specify what folders to sync and what to exclude -- include, exclude, filter?](https://forum.rclone.org/t/how-to-specify-what-folders-to-sync-and-what-to-exclude-include-exclude-filter/21821)
- [Rclone copy using regex expression using include multiple expression for file name](https://forum.rclone.org/t/rclone-copy-using-regex-expression-using-include-multiple-expression-for-file-name/26846?page=2)

`lsjson` 命令以 json 格式列举目录：

```Shell
$ rclone lsjson webdav@rpi4b:
[
{"Path":"CS","Name":"CS","Size":-1,"MimeType":"inode/directory","ModTime":"2024-04-05T00:34:31Z","IsDir":true},
{"Path":"English_Docs","Name":"English_Docs","Size":-1,"MimeType":"inode/directory","ModTime":"2024-04-03T02:53:51Z","IsDir":true},
{"Path":"The_Economist","Name":"The_Economist","Size":-1,"MimeType":"inode/directory","ModTime":"2024-03-25T02:17:59Z","IsDir":true},
{"Path":"mkdocs","Name":"mkdocs","Size":-1,"MimeType":"inode/directory","ModTime":"2024-04-01T10:25:31Z","IsDir":true}
]
```

## mkdir

语义同 bash shell 中的 `mkdir`，创建目录（remote:path）。

| Command | Description |
|---------|-------------|
| [rclone mkdir](https://rclone.org/commands/rclone_mkdir/) | Make the path if it doesn't already exist. |

在根目录 /webdav 下新建文件夹 rcdir：

```Shell
$ rclone lsf webdav@rpi4b:
CS/
English_Docs/
The_Economist/
mkdocs/

$ rclone mkdir webdav@rpi4b:rcdir

$ rclone lsf webdav@rpi4b:
CS/
English_Docs/
The_Economist/
mkdocs/
rcdir/
```

## copy

基本语义同 bash shell 中的 `cp`，支持端到端的文件（夹）复制。

| Command | Description |
|---------|-------------|
| [rclone copy](https://rclone.org/commands/rclone_copy/)       | Copy files from source to dest, skipping identical files.    |
| [rclone copyto](https://rclone.org/commands/rclone_copyto/)   | Copy files from source to dest, skipping identical files.    |
| [rclone copyurl](https://rclone.org/commands/rclone_copyurl/) | Copy the contents of the URL supplied content to dest\:path. |

**copy**:

1. If dest\:path doesn't exist, it is created and the source\:path contents go there.
2. To copy single files, use the [copyto](https://rclone.org/commands/rclone_copyto/) command instead.

**copyto**:

1. If source:path is a file or directory then it copies it to a file or directory *named* dest:path.
2. This can be used to upload single files to other than their current name.
3. If the source is a directory then it acts exactly like the [copy](https://rclone.org/commands/rclone_copy/) command.

### upload from local

将当前目录下文件夹 mkdocs/script/ 中的所有文件复制到 test/script 目录下：

*   如果目标目录不存在，会逐级创建目录（mkdir -p test/script）。

```Shell
$ rclone copy mkdocs/script/ webdav@rpi4b:test/script
```

将当前目录下的文件 test.txt 拷贝上传（copy upload）到目录 rcdir 下：

```Shell
$ rclone copy test.txt webdav@rpi4b:rcdir

$ rclone lsf webdav@rpi4b:rcdir
test.txt
```

```Shell
# 仅拷贝 srcpath 中 5s 之内有变动的文件
$ rclone copy -v ~/Downloads/testdir webdav@mbpa2991:testdir --max-age 5
```

**注意**：如果使用 copyto 命令，会将 rcdir 视作文件：

```Shell
# 将当前目录下的 test.txt 文件复制为远端文件 rcdir
$ rclone copyto test.txt webdav@rpi4b:rcdir
```

使用 copyto 命令，dstpath 部分指定上传后的目标文件名。
例如，将 test.txt 上传为 rcdir/test2.txt：

```Shell
$ rclone copyto test.txt webdav@rpi4b:rcdir/test2.txt

$ rclone lsf webdav@rpi4b:rcdir
test.txt
test2.txt
```

**注意**：如果使用 copy 命令，会将 test2.txt 视作目录：

```Shell
# 将当前目录下的 test.txt 文件复制到远端目录 rcdir/test2.txt/ 下
$ rclone copy test.txt webdav@rpi4b:rcdir/test2.txt

$ rclone lsf webdav@rpi4b:rcdir
test.txt
test2.txt/

$ rclone lsf webdav@rpi4b:rcdir/test2.txt
test.txt
```

### download from remote

将 rcdir 目录下的所有文件下载到当前目录（pwd）：

```Shell
$ rclone copy webdav@rpi4b:rcdir .
```

将 rcdir 目录下的所有文件下载到当前目录的 rcdir 文件夹下：

*   如果当前目录下不存在 rcdir 文件夹，则自动创建。

```Shell
$ rclone copy webdav@rpi4b:rcdir ./rcdir
```

将远端文件 rcdir/test2.txt 拷贝下载到当前目录（pwd）下：

```Shell
$ rclone copy webdav@rpi4b:rcdir/test2.txt .
```

将远端文件夹 English/恋词考研英语-全真题源报刊7000词/ 拷贝到 Documents 同名目录：

```Shell
rclone copy webdav@rpi4b:English/恋词考研英语-全真题源报刊7000词/ Documents/English/恋词考研英语-全真题源报刊7000词/
```

将远端文件 rcdir/test2.txt 拷贝下载到当前目录（pwd），并命名为 test3.txt：

```Shell
$ rclone copyto webdav@rpi4b:rcdir/test2.txt ./test3.txt
```

### server-side copy

server-side copy 复制文件夹：

```Shell
$ rclone copy webdav@rpi4b:rcdir webdav@rpi4b:rcdir1

$ rclone lsf webdav@rpi4b:
CS/
English_Docs/
The_Economist/
mkdocs/
rcdir/
rcdir1/
```

server-side copy 复制文件：

```Shell
$ rclone copyto webdav@rpi4b:rcdir/test.txt webdav@rpi4b:rcdir/test3.txt

$ rclone lsf webdav@rpi4b:rcdir
test.txt
test2.txt
test3.txt

$ rclone copyto webdav@rpi4b:rcdir/test.txt webdav@rpi4b:rcdir/test4.txt

$ rclone lsf webdav@rpi4b:rcdir
test.txt
test2.txt
test3.txt
test4.txt
```

## move

基本语义同 bash shell 中的 `mv`，支持端到端的文件（夹）移动。

| Command | Description |
|---------|-------------|
| [rclone move](https://rclone.org/commands/rclone_move/)     | Move files from source to dest.             |
| [rclone moveto](https://rclone.org/commands/rclone_moveto/) | Move file or directory from source to dest. |

**move**:

1. Moves the contents of the source directory to the destination directory.
2. To move single files, use the [moveto](https://rclone.org/commands/rclone_moveto/) command instead.

**moveto**:

1. If source:path is a file or directory then it moves it to a file or directory *named* dest:path.
2. This can be used to rename files or upload single files to other than their existing name.
3. If the source is a directory then it acts exactly like the [move](https://rclone.org/commands/rclone_move/) command.

!!! note "move vs. copy"

    在上面使用 `copy` 的场合，都可以替换为 `move`。
    区别在于 `copy` 是复制-粘贴，而 `move` 相当于剪切-粘贴。

server-side move：不同目录为移动，相同目录相当于重命名。

将文件 rcdir1/test4.txt 重命名 rcdir1/test3.txt：

```Shell
$ rclone moveto webdav@rpi4b:rcdir1/test4.txt webdav@rpi4b:rcdir1/test3.txt

rclone lsf webdav@rpi4b:rcdir1
test.txt
test2.txt
test3.txt
```

将根目录下的 test 文件夹重命名为 test2：

```Shell
$ rclone move webdav@rpi4b:test webdav@rpi4b:test2
```

将 rcdir/test4.txt 移动到 rcdir1 目录：

```Shell
$ rclone move webdav@rpi4b:rcdir/test4.txt webdav@rpi4b:rcdir1

$ rclone lsf webdav@rpi4b:rcdir
test.txt
test2.txt
test3.txt

$ rclone lsf webdav@rpi4b:rcdir1
test.txt
test2.txt
test4.txt
```

将 English 目录下的 mp3 和 pdf 文件（不递归子目录）移动到子文件夹 The_Economist 下：

```Shell
$ rclone move --include "/*.{mp3,pdf}" webdav@rpi4b:English webdav@rpi4b:English/The_Economist --dry-run
```

## delete/rmdir/purge

### delete

| Command | Description |
|---------|-------------|
| [rclone deletefile](https://rclone.org/commands/rclone_deletefile/) | Remove a single file from remote. |
| [rclone delete](https://rclone.org/commands/rclone_delete/)         | Remove the files in path.         |

deletefile 语义同 bash shell 中的 `rm -f file`；delete 语义同 bash shell 中的 `rm -rf folder`。

删除远端文件 rcdir1/test.txt：

```Shell
$ rclone deletefile webdav@rpi4b:rcdir1/test.txt

$ rclone lsf webdav@rpi4b:rcdir1
test2.txt
test3.txt
```

删除远端文件夹 rcdir1 下的所有文件：

```Shell
$ rclone delete webdav@rpi4b:rcdir1

$ rclone lsf webdav@rpi4b:rcdir1

```

### rmdir

| Command | Description |
|---------|-------------|
| [rclone rmdir](https://rclone.org/commands/rclone_rmdir/)   | Remove the empty directory at path.      |
| [rclone rmdirs](https://rclone.org/commands/rclone_rmdirs/) | Remove empty directories under the path. |

再在根目录下创建个2文件夹 rcdir2、rcdir3

```Shell
$ rclone mkdir webdav@rpi4b:rcdir2
$ rclone mkdir webdav@rpi4b:rcdir3

$ rclone lsf webdav@rpi4b:
CS/
English_Docs/
The_Economist/
mkdocs/
rcdir/
rcdir1/
rcdir2/
rcdir3/
```

使用 `rmdir` 命令移除根目录下的空文件夹 rcdir1：

```Shell
$ rclone rmdir webdav@rpi4b:rcdir1

$ rclone lsf webdav@rpi4b:
CS/
English_Docs/
The_Economist/
mkdocs/
rcdir/
rcdir2/
rcdir3/
```

使用 `rmdirs` 子命令一次性移除根目录下所有的空文件夹（rcdir2、rcdir3）：

```Shell
$ rclone rmdirs webdav@rpi4b:

rclone lsf webdav@rpi4b:
CS/
English_Docs/
The_Economist/
mkdocs/
rcdir/
```

### purge

rmdir/rmdirs 命令只能删除空文件夹，如果想一步清理文件夹内容并删除文件夹，可以使用 `purge` 命令（≈ delete + rmdir）：

| Command | Description |
|---------|-------------|
| [rclone purge](https://rclone.org/commands/rclone_purge/) | Remove the path and all of its contents. |

删除远端目录 rcdir/test2.txt 下的所有文件及文件夹：

```Shell
$ rclone purge webdav@rpi4b:rcdir/test2.txt

rclone lsf webdav@rpi4b:rcdir
test.txt
test1.txt
test3.txt
```

## sync/bisync

| Command                                                     | Description                                                 |
| ----------------------------------------------------------- | ----------------------------------------------------------- |
| [rclone sync](https://rclone.org/commands/rclone_sync/)     | Make source and dest identical, modifying destination only. |
| [rclone bisync](https://rclone.org/commands/rclone_bisync/) | Perform bidirectional synchronization between two paths.    |

### sync

Sync the source to the destination, changing the destination only. Doesn't transfer files that are identical on source and destination, testing by size and modification time or MD5SUM. Destination is updated to match source, including deleting files if necessary (except duplicate objects, see below). If you don't want to delete files from destination, use the [copy](https://rclone.org/commands/rclone_copy/) command instead.

**Important**: Since this can cause data loss, test first with the `--dry-run` or the `--interactive`/`-i` flag.

```Shell
rclone sync --interactive SOURCE remote:DESTINATION

```

Note that files in the destination won't be deleted if there were any errors at any point. Duplicate objects (files with the same name, on those providers that support it) are also not yet handled.

本地目录（文件夹）想和云盘同步时，可采用 `sync` 命令。

例1：将本地目录 `/usr/local/var/webdav/` 同步到 webDAV 云盘 webdav\@rpi4b:

```Shell
rclone sync /usr/local/var/webdav/ webdav@rpi4b:
```

例2：仅同步 srcpath 中 1h 之内有变动的文件：

```Shell
rclone sync -v ~/Downloads/testdir webdav@mbpa2991:testdir --max-age 1h
```

例3：将 ubuntu WebDAV 云盘 webdav\@rpi4b（除 C-C++/ 和 English/ 目录外）同步备份到外挂硬盘（/Volumes/WDHD/）下的文件夹 webdav@rpi4b：

```Shell
# --exclude "{C-C++/*, English/*}"
# 2-stderr 重定向到 1-stdout，管传给 tee 输出控制台并且保存（-a: append）到日志文件。
$ rclone sync -v webdav@rpi4b: /Volumes/WDHD/webdav@rpi4b --exclude "C-C++/" --exclude "English/" 2>&1 | tee -a ~/.config/rclone/rclone.log

# 补充备份 English 文件夹
$ rclone sync -v webdav@rpi4b:English /Volumes/WDHD/webdav@rpi4b/English 2>&1 | tee -a ~/.config/rclone/rclone.log

# 补充备份 C-C++ 文件夹
$ rclone sync -v webdav@rpi4b:C-C++ /Volumes/WDHD/webdav@rpi4b/C-C++ 2>&1 | tee -a ~/.config/rclone/rclone.log
```

也可根据实际需求，选择只同步某些子文件夹。

!!! note "一种典型的单向同步工作流"

    1. 先将云盘某个目录 remote\:dstpath 拷贝检出（类似 git clone check) 到本地文件夹 srcpath。
    2. 然后，以 srcpath 为工作目录进行本地文件编辑活动，包括新建、移动、删除等一系列操作。
    3. 编辑完毕，执行 `rclone sync srcpath dest:dstpath` 命令即可同步本地数据到服务端。

### bisync

Perform bidirectional synchronization between two paths.

[Bisync](https://rclone.org/bisync/) provides a bidirectional cloud sync solution in rclone. It retains the Path1 and Path2 filesystem listings from the prior run. On each successive run it will:

*   list files on Path1 and Path2, and check for changes on each side. Changes include `New`, `Newer`, `Older`, and `Deleted` files.
*   Propagate changes on Path1 to Path2, and vice-versa.

Bisync is **in beta** and is considered an **advanced command**, so use with care. Make sure you have read and understood the entire [manual](https://rclone.org/bisync) (especially the [Limitations](https://rclone.org/bisync/#limitations) section) before using, or data loss can result. Questions can be asked in the [Rclone Forum](https://forum.rclone.org/).

See [full bisync description](https://rclone.org/bisync/) for details.

```Shell
rclone bisync remote1:path1 remote2:path2 [flags]

```

假设配置了两个云盘：webdav@mbpa1398 和 webdav@rpi4b，彼此之间相当于备份。

在内网操作 webdav@mbpa1398，远程操作 webdav@rpi4b。

可采用 `bisync` 命令执行双向同步：

```Shell
rclone bisync webdav@mbpa1398: webdav@rpi4b:
```

假如某个文件基点为 file，在云盘 1 编辑为 file1，在云盘 2 编辑为 file2，双向同步时将以最后修改时间戳为准，没法自动合并？

- [Two-way (bidirectional) synchronization](https://github.com/rclone/rclone/issues/118)
- [Bisync missed syncing changed file - no error, no warning](https://forum.rclone.org/t/bisync-missed-syncing-changed-file-no-error-no-warning/41174)
- [rclone bisync --resync : discrepency in keeping updated/modified files](https://forum.rclone.org/t/rclone-bisync-resync-discrepency-in-keeping-updated-modified-files/38495)

一种可能的安全的工作流是，每次开始编辑（或编辑完）任何一个云盘，总是执行 bisync （先）双向同步，确保数据同步。

所以，最好以一个为主（编辑），另一个为辅（备份）。这样，相当于将主盘增量同步到备份盘。此时，退化为单向 sync：

```Shell
rclone sync webdav@mbpa1398: webdav@rpi4b:
```

## crontab

[Bisync](https://rclone.org/bisync/): On Linux or Mac, consider setting up a crontab entry. `bisync` can safely run in concurrent cron jobs thanks to lock files it maintains.

可以通过 [cron](https://en.wikipedia.org/wiki/Cron) / [crontab - tables for driving bcron](https://manpages.ubuntu.com/manpages/noble/en/man5/crontab.5.html) 配置定时任务，每天自动执行同步。

参考 [How to Use Cron to Automate Linux Jobs on Ubuntu 20.04](https://www.cherryservers.com/blog/how-to-use-cron-to-automate-linux-jobs-on-ubuntu-20-04) 和 [How do I set up a Cron job? - Ask Ubuntu](https://askubuntu.com/questions/2368/how-do-i-set-up-a-cron-job)。

ubuntu 系统级别的 crontab 配置文件在 /etc/ 目录下（cron*）：

```Shell
# ls -l /etc/cron*
$ ls -l /etc | grep cron
drwxr-xr-x 2 root root       4096 Nov  6  2022 cron.d
drwxr-xr-x 2 root root       4096 Apr  7 05:00 cron.daily
drwxr-xr-x 2 root root       4096 Nov  6  2022 cron.hourly
drwxr-xr-x 2 root root       4096 Nov  6  2022 cron.monthly
-rw-r--r-- 1 root root       1136 Aug  6  2021 crontab
drwxr-xr-x 2 root root       4096 Nov  6  2022 cron.weekly
```

每个用户有一个以用户名命名的 crontab 配置文件，存放在 `/var/spool/cron/crontabs` 目录下。

macOS 下执行 `man cron`，FILES 显示 Directory for personal crontab files 为 `/usr/lib/cron/tabs`。

```Shell
$ sudo ls -l /usr/lib/cron/
total 0
-rw-r--r--  1 root    wheel   0 Mar 30 15:19 at.deny
-rw-r--r--  1 root    wheel   6 Mar 30 15:19 cron.deny
drwxr-xr-x  2 daemon  wheel  64 Mar 30 15:19 jobs
drwxr-xr-x  2 daemon  wheel  64 Mar 30 15:19 spool
drwx------  3 root    wheel  96 Mar 30 15:19 tabs
drwx------  2 root    wheel  64 Mar 30 15:19 tmp

$ sudo ls -l /usr/lib/cron/tabs

```

### ubuntu

用户可执行 `crontab -e` 打开一个类似 `/tmp/crontab.CNG0fm/crontab` 的临时文件，编辑 personal crontab。

在 rpi4b-ubuntu 上首次执行 `crontab -e`（注意不要 sudo），提示选择编辑器，选择 vim 打开编辑：

```Shell
$ pifan@rpi4b-ubuntu ~
crontab -e
no crontab for pifan - using an empty one

Select an editor.  To change later, run 'select-editor'.
  1. /usr/bin/vim.gtk3
  2. /bin/nano        <---- easiest
  3. /usr/bin/vim.basic
  4. /usr/bin/vim.tiny
  5. /bin/ed

Choose 1-5 [2]: 3
```

文档注释中有关于配置项的说明：

```Shell title="crontab -e Cron Syntax"
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

??? note "man 5 crontab"

    ```Shell
    Instead of the first five fields, one of eight special strings may appear:

        string         meaning
        ------         -------
        @reboot        Run once, at startup.
        @yearly        Run once a year, "0 0 1 1 *".
        @annually      (same as @yearly)
        @monthly       Run once a month, "0 0 1 * *".
        @weekly        Run once a week, "0 0 * * 0".
        @daily         Run once a day, "0 0 * * *".
        @midnight      (same as @daily)
        @hourly        Run once an hour, "0 * * * *".

    `8-11` for an hours entry specifies execution at hours 8, 9, 10 and 11.

    A list is a set of numbers (or ranges) separated by commas. Examples: `1,2,5,9`, `0-4,8-12`.

    `0-23/2` can be used in the hours field to specify command execution every other hour

    if you want to say ``every two hours'', just use `*/2`.

    EXAMPLE CRON FILE
           # run five minutes after midnight, every day
           5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1
           # run at 2:15pm on the first of every month — output mailed to paul
           15 14 1 * *     $HOME/bin/monthly
           # run at 10 pm on weekdays, annoy Joe
           0 22 * * 1-5    mail -s "It's 10pm" joe%Joe,%%Where are your kids?%
           23 0-23/2 * * * echo "run 23 minutes after midn, 2am, 4am ..., everyday"
           5 4 * * sun     echo "run at 5 after 4 every Sunday"
           0 */4 1 * mon   echo "run every 4th hour on the 1st and on every Monday"
           0 0 */2 * sun   echo "run at midn on every Sunday that's an uneven date"
           # Run on every second Saturday of the month
           0 4 8-14 * *    test $(date +\%u) -eq 6 && echo "2nd Saturday"

           # Execute a program and run a notification every day at 10:00 am
           0 10 * * *  $HOME/bin/program | DISPLAY=:0 notify-send "Program run" "$(cat)"
    ```

执行 `crontab -e` 在末尾新增一条测试任务，每分钟执行 echo 写入文件 time.txt。

```Shell title="crontab -e test"
*/1 * * * * echo "echo from crontab" >> /home/pifan/Downloads/time.txt
```

整点分钟，观察 time.txt 是否有追加内容，以验证 cron 任务正常执行。

在 cron table 末尾新增一条任务，每天定点执行 rclone sync，将 webdav 云盘自动同步到外挂硬盘（`/media/WDHD/`）。

```Shell title="crontab -e hourly"
# auto backup every two hours(0,2,4,6,8,10,12,14,16,18,20,22)
# 0 */2 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b >> /var/log/rclone.log 2>&1
0 */2 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone-`date +\%Y\%m\%d`.log
```

如果后续文件改动不是那么频繁，可以改为每天同步一次，日志文件按月命名。

> webdav 编辑大文件时经常出现同步问题导致文件损坏，可指定 `--min-size SizeSuffix` 选项，只备份大于 SizeSuffix（例如 10M）的大文件。

```Shell title="crontab -e daily"
# 每天凌晨1点同步备份
0 1 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone-`date +\%Y\%m`.log
```

输入 `:wq` 保存退出 vim，命令行提示 `crontab: installing new crontab`。

编辑的 personal crontab 将自动追加到 `/var/spool/cron/crontabs/$USER` 文件中。

执行 `sudo systemctl restart cron.service` 重启定时任务使其生效。

!!! note "关于 rclone 运行日志路径"

    建议通过 [--log-file=FILE](https://rclone.org/docs/#log-file-file) 选项为 rclone 指定用户级别的日志路径。
    参考 [Sending cron output to a file with a timestamp in its name](https://serverfault.com/questions/117360/sending-cron-output-to-a-file-with-a-timestamp-in-its-name)，日志文件按天命名。
    如若使用全局日志路径 /var/log/rclone.log，则需先 `sudo touch` 再 `sudo chown` 为当前用户组。
    macOS 下的 rclone 运行日志可以考虑放到 /usr/local/var/log 目录下。

!!! note "crontab list & remove"

    执行 `crontab -l` 可以查看当前用户的任务列表，或通过 `-u` 选项查看指定用户的任务列表 `crontab -l -u pifan`。
    执行 `crontab -r` 可以移除当前用户配置的任务列表，或 `crontab -ri` 带 interactive prompt 确认。


### macOS

在 macOS 上首次执行 `crontab -e`，将临时打开一个空文件，默认使用编辑器 /usr/bin/vi。
在末尾新增一条测试任务，每分钟执行 date 写入文件 time.txt。

```Shell title="crontab -e test"
*/1 * * * * date >> /Users/faner/Downloads/time.txt
```

保存退回到终端，命令行显示以下内容：

```Shell
$ crontab -e
crontab: no crontab for faner - using an empty one
crontab: installing new crontab
```

执行 `crontab -l` 可以查看配置内容。

> personal crontab 目录下会多出一个以当前用户名（$USER）命名的配置文件，如 /usr/lib/cron/tabs/faner。

整点分钟，观察 time.txt 是否有追加内容，以验证 cron 任务正常执行。

如果之前未在 macOS 上配置过 cron，大概率会失败，按照以下步骤配置。

!!! note "macOS 下的 cron"

    macOS 下的 cron 是系统启动服务（LaunchDaemons），每次执行 `crontab -e` 编辑保存，都提示需要授权终端管理员权限！

首先从 launchctl list 中查找 cron 服务：

```Shell
$ sudo launchctl list | grep 'cron'
86386	0	com.vix.cron
```

其中第一列是服务进程ID（pid）；第二列是服务状态，0代表正常；第三列是服务plist名。

尝试执行 `locate com.vix.cron` 全局查找 cron 服务的配置文件位置：

```Shell
$ locate com.vix.cron

WARNING: The locate database (/var/db/locate.database) does not exist.
To create the database, run the following command:

  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

Please be aware that the database can take some time to generate; once
the database has been created, this message will no longer appear.
```

按照提示执行加载 `com.apple.locate` 服务，创建一个database：

```Shell
$ sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
```

然后，再次执行 `locate com.vix.cron` 查找到 cron 服务的配置文件位置：

```Shell
$ locate com.vix.cron
/System/Library/LaunchDaemons/com.vix.cron.plist
```

执行 cat 或 vim 查看该配置文件，发现其 PathState 中的 `/etc/crontab` 配置文件默认不存在。

??? info "com.vix.cron.plist"

    ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
     	"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
     	<key>Label</key>
     	<string>com.vix.cron</string>
     	<key>ProgramArguments</key>
     	<array>
     		<string>/usr/sbin/cron</string>
     	</array>
     	<key>KeepAlive</key>
     	<dict>
     		<key>PathState</key>
     		<dict>
     			<key>/etc/crontab</key>
     			<true/>
     		</dict>
     	</dict>
     	<key>QueueDirectories</key>
     	<array>
     		<string>/usr/lib/cron/tabs</string>
     	</array>
     	<key>EnableTransactions</key>
     	<true/>
     </dict>
     </plist>
    ```

执行 `sudo vim /etc/crontab` 创建 `/etc/crontab` 文件，参考 ubuntu 填入以下模版内容：

```Shell title="/etc/crontab"
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
```

!!! note "macOS 重启 cron 服务"

    1. cron 服务开启、关闭、重启：

        - sudo /usr/sbin/cron start
        - sudo /usr/sbin/cron stop
        - sudo /usr/sbin/cron restart

    2. 如果修改了配置文件，执行 launchctl load 命令（可添加 -w 选项）：

        - sudo launchctl load /System/Library/LaunchDaemons/com.vix.cron.plist
        - sudo launchctl unload /System/Library/LaunchDaemons/com.vix.cron.plist

执行完以上配置，再观察检查 time.txt。如果还没有内容，可能是该测试命令涉及到写磁盘文件，需要给 cron 授权。

!!! note "授权 cron 写磁盘权限"

     [How to Fix Cron Permission Issues in macOS](https://osxdaily.com/2020/04/27/fix-cron-permissions-macos-full-disk-access/)
     1. 执行 `which cron` 查找到 cron 命令的位置：/usr/sbin/cron。
     2. 打开 macOS 设置(System Settings)，隐私与安全性(Privacy & Security)，点进完全磁盘访问权限(Full Disk Access)。
     3. 点按左下角的 + 号，在打开的访达窗口按 ++shift+command+g++ 调出路径访问方式，输入 `/usr/sbin/cron` 回车，找到 cron 命令添加。

正常情况下，到这一步，time.txt 中应该可以看到，每分钟追加写入了一行当前日期时间。

接下来配置 crontab 定时任务，白天每隔两小时备份一下特定文件，并按时辰命名。

```Shell title="crontab -e"
# every two hour: 5,7,9,11,13,15,17,19,21,23
0 5-23/2 * * * rclone copyto -v /Users/faner/Documents/English/LINKIN-WORDS-7000/恋词考研英语-全真题源报刊7000词-索引红版.pdf smbhd@rpi4b:WDHD/backups/English/恋词考研英语-全真题源报刊7000词-索引红版-`date +\%Y\%m\%d\%H`.pdf --log-file=/Users/faner/.config/rclone/rclone-`date +\%Y\%m`.log
```

先把调度时间改为每分钟，看看是否正常运行：

```Shell title="crontab -e"
*/1 * * * * rclone copyto -v /Users/faner/Documents/English/LINKIN-WORDS-7000/恋词考研英语-全真题源报刊7000词-索引红版.pdf smbhd@rpi4b:WDHD/backups/English/恋词考研英语-全真题源报刊7000词-索引红版-`date +\%Y\%m\%d\%H\%M`.pdf --log-file=/Users/faner/.config/rclone/rclone-`date +\%Y\%m`.log
```

等了几分钟，查看 rclone 日志文件没有相应运行日志，在 dstpath 中也没有看到预期同步的文件。

cron 执行出错时默认会通过 MTA 服务给系统管理员发邮件，执行 `vim /var/mail/$USER` 检查当前用户的邮箱。

果然，其中提示找不到 rclone 命令：

```Shell
/bin/sh: rclone: command not found
```

执行 `which rclone`，显示 brew 安装的 rclone 路径为 `/usr/local/bin/rclone`。

可能系统服务启动的 shell 环境的 PATH 中并没有 /usr/local/bin。

将 rclone 命令改为绝对路径 `/usr/local/bin/rclone`：

```Shell title="crontab -e"
*/1 * * * * /usr/local/bin/rclone copyto -v /Users/faner/Documents/English/LINKIN-WORDS-7000/恋词考研英语-全真题源报刊7000词-索引红版.pdf smbhd@rpi4b:WDHD/backups/English/恋词考研英语-全真题源报刊7000词-索引红版-`date +\%Y\%m\%d\%H\%M`.pdf --log-file=/Users/faner/.config/rclone/rclone-`date +\%Y\%m`.log
```

!!! note ""

    由于以上命令是 rclone copyto remote（upload），读本地写远端，所以不涉及本地写磁盘权限问题。
    如果是 rclone copyto local（download），可能涉及写磁盘权限问题，按照上面的步骤开启授权即可。

验证任务生效后，将调度时间修改为预期的同步频率，后续核对日志校验定时备份任务执行情况。

```Shell title="crontab -e : 每隔 2h，执行同步脚本"
0 7-23/2 * * * /usr/local/etc/scripts/rclone-sync.sh
```

需执行 `sudo chmod +x /usr/local/etc/scripts/rclone-sync.sh` 赋予其他用户对该脚本的可执行权限。

备份脚本 `rclone-sync.sh` 使用 date 或 stat 命令检查文件最后修改时间。

=== "date -r"

    ```Shell
    $ date -r test.txt
    Sat Mar 16 16:53:38 CST 2024

    $ date -r test.txt +%s
    1710579218

    $ date -r test.txt +%Y%m%d%H%M%S
    20240316165338
    ```

=== "macOS: stat -f"

    > `-f format`: Display information using the specified format.  See the Formats section for a description of valid formats.

    ```Shell
    # To display a file's modification time:
    $ stat -f %m test.txt
    1710579218

    # To display the same modification time in a readable format
    $ stat -f %Sm test.txt
    Mar 16 16:53:38 2024

    # To display the same modification time in a readable and sortable format
    $ stat -f %Sm -t %Y%m%d%H%M%S test.txt
    20240316165338
    ```

=== "ubuntu: stat -c"

    > `-c` / --format=FORMAT: use the specified FORMAT instead of the default; output a newline after each use of FORMAT

    ```Shell
    $ stat -c %Y test.txt
    1710579219

    $ stat -c %y test.txt
    2024-03-16 16:53:39.000000000 +0800

    $ date -d "@$(stat -c %Y test.txt)" '+%Y%m%d%H%M%S'
    20240316165339
    ```

如果在 2h 定时周期内无改动则 dry-run，有改动才备份；备份成功后，老化删除一天之前的旧备份。

!!! note "Why not use filtering flag --max-age ?"

    如果执行 sync 或 copy 同步目录，可使用 rclone 提供的 `--max-age 2h` 选项。
    这里执行 copyto 命令备份特定文件，不适用 `--max-age` 选项，故自行等效实现。

??? info "rclone-sync.sh"

    ```Shell
    #!/bin/bash

    logfile="/Users/faner/.config/rclone/rclone-$(date +%Y%m).log"
    filename="恋词考研英语-全真题源报刊7000词-索引红版"
    srcfile="/Users/faner/Documents/English/LINKIN-WORDS-7000/$filename.pdf"
    dstpath="smbhd@rpi4b:WDHD/backups/English"
    dstfile="$dstpath/$filename-$(date +%Y%m%d%H).pdf"

    curdate=$(date +%Y/%m/%d\ %H:%M:%S)
    curdate_sec="$(date +%s)"

    filedate=$(date -r $srcfile +%Y/%m/%d\ %H:%M:%S)
    filedate_sec="$(date -r $srcfile +%s)"

    passed_sec=0
    elapsed_sec=0
    elapsed_min=0
    elapsed_hour=0
    elapsed_day=0
    
    passed_sec=$((curdate_sec - filedate_sec))
    elapsed_sec=$passed_sec
    if [ $elapsed_sec -ge 60 ]; then
      elapsed_min=$((elapsed_sec / 60))
      elapsed_sec=$((elapsed_sec % 60))
      if [ $elapsed_min -ge 60 ]; then
        elapsed_hour=$((elapsed_min / 60))
        elapsed_min=$((elapsed_min % 60))
        if [ $elapsed_hour -ge 24 ]; then
          elapsed_day=$((elapsed_hour / 24))
          elapsed_hour=$((elapsed_hour % 24))
        fi
      fi
    fi
    
    elapsed_time=$(printf '%sd-%sh-%sm' "$elapsed_day" "$elapsed_hour" "$elapsed_min")
    echo "$curdate DEBUG : $filename.pdf, modification: $filedate, $elapsed_time ago." >>"$logfile"
    
    checkpoint=$((passed_sec + 1)) # rewind for a second
    backupcount=$(rclone lsf --max-age=$checkpoint $dstpath | wc -l)
    
    if [ "$backupcount" -eq "0" ]; then # modified since last backup, execute backup
      if /usr/local/bin/rclone copyto -v "$srcfile" "$dstfile" --log-file="$logfile"; then
        /usr/local/bin/rclone delete -v "$dstpath" --min-age 24h --log-file="$logfile"
      else
        echo -e "backup failed, keep old backups.\n" >>"$logfile"
      fi
    else # remain unchanged since last backup
      echo -e "remain unchanged, keep old backup: $(rclone lsf --max-age=$checkpoint $dstpath)\n" >>"$logfile"
    fi
    ```

### check logs

每天检查日志文件，确认系统 cron 定时任务和 rclone sysnc 同步任务执行情况。

系统日志 /var/log/syslog 中，应该有类似的条目：

```dmesg
$ grep -a CRON /var/log/syslog
Apr  7 02:30:00 rpi4b-ubuntu CRON[62328]: (pifan) CMD (rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone.log)
```

也可以开启 cron 独立日志，后续直接查看 /var/log/cron.log。

!!! note "Use Independent Crontab Logs"

     1. `sudo vim /etc/rsyslog.d/50-default.conf`
     2. uncomment the line starting with the `cron.*`
     3. `sudo systemctl restart rsyslog`

---

macOS 的系统日志 /var/log/system.log 中没有搜到任何 cron 相关的运行日志。

参考 [macos - Mac OS X cron log / tracking](https://stackoverflow.com/questions/5475800/mac-os-x-cron-log-tracking)，执行 `log show --process cron` 可以看到 crontab/cron 的 Activity 活动日志。

!!! note "cron -x debugflag"

    [macos - Log of cron actions on OS X](https://superuser.com/questions/134864/log-of-cron-actions-on-os-x) 中提到，参考 man cron 中的 `-x debugflag`，可修改 com.vix.cron.plist，为 ProgramArguments 添加 `-x` 调试选项，并配置 StandardErrorPath 为 /var/log/cron.log。尚未具体实践验证。

---

确认 cron 定时任务执行后，再检查配置目录 ~/.config/rclone/ 下当天/月的运行日志 rclone-`date`.log，查看同步情况。

## refs

[Rclone云存储数据同步工具](https://www.cnblogs.com/varden/p/17181717.html)
[备份同步神器 Rclone 使用教程](https://cloud.tencent.com/developer/article/2192254)
[rclone 选项参数 --min-age/--max-age 的理解](https://blog.csdn.net/neowell/article/details/134009677)

[使用 RClone 实现 Unraid 的异地容灾](https://juejin.cn/post/7131650853307416589)
[一个命令让Linux定时打包备份指定目录文件夹并同步备份到各大网盘](https://wzfou.com/vps-one-backup/)

[schedule using crontab on macOS: A step-by-step guide](https://medium.com/@justin_ng/how-to-run-your-script-on-a-schedule-using-crontab-on-macos-a-step-by-step-guide-a7ba539acf76)
[Schedule job with crontab on macOS](https://chethansp.medium.com/schedule-job-with-crontab-on-macos-d47a1fda47e5)

[记录一次macOS上crontab未成功执行问题的排查过程！](https://blog.humh.cn/?p=947)
[macOS 电脑—设置 crontab](https://zhuanlan.zhihu.com/p/564215492)
