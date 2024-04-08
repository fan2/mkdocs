---
title: 使用rclone访问操作WebDav云盘
authors:
  - xman
date:
    created: 2024-03-18T15:30:00
categories:
    - macOS
    - webDAV
tags:
    - webDAV
    - rclone
comments: true
---

在 [使用命令行挂载操作WebDav云盘](./cmd-mount-webdav.md) 中梳理了 macOS/Linux 下调用 mount 命令挂载 WebDAV 云盘到本地的基本操作，并且示例了如何使用 curl 命令行访问操作 WebDAV 云盘。

本文让我们来看一看如何使用强大的 [rclone](https://rclone.org/) 命令行工具配置挂载 WebDAV 云盘，并对标 curl 梳理 rclone 访问操控 webDAV 云盘的常用命令。

<!-- more -->

!!! note "rclone works like a charm!"

    [rclone](https://rclone.org/): Rclone syncs your files to cloud storage

    Users call rclone "The Swiss army knife of cloud storage", and "Technology indistinguishable from magic".

Rclone has powerful cloud equivalents to the unix commands `rsync`, `cp`, `mv`, `mount`, `ls`, `ncdu`, `tree`, `rm`, and `cat`. Rclone's familiar syntax includes shell pipeline support, and `--dry-run` protection. It is used at the command line, in scripts or via its API.

Rclone mounts any local, cloud or virtual filesystem as a disk on Windows, macOS, linux and FreeBSD, and also serves these over SFTP, HTTP, WebDAV, FTP and DLNA.

Rclone is mature, open-source software originally inspired by rsync and written in [Go](https://golang.org/).

## rclone install

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

## rclone docs

[Overview of cloud storage systems](https://rclone.org/overview/#optional-features)

- [Local Filesystem](https://rclone.org/local/)
- [WebDAV](https://rclone.org/webdav/)

[Commands Index](https://rclone.org/commands/)

- This is an index of all commands in rclone. Run `rclone command --help` to see the help for that command.

[rclone serve](https://rclone.org/commands/rclone_serve/) - [webdav](https://rclone.org/commands/rclone_serve_webdav/)

[Remote Control / API](https://rclone.org/rc/) - [GUI](https://rclone.org/gui/)

[Usage](https://rclone.org/docs/)

## rclone config

在命令行输入 `rclone config` 进入交互式配置会话。

### rclone config webdav

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

### rclone config show

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

[rclone ls](https://rclone.org/commands/rclone_ls/)

There are several related list commands

*   `ls` to list size and path of objects only
*   `lsl` to list modification time, size and path of objects only
*   `lsd` to list directories only
*   `lsf` to list objects and directories in easy to parse format
*   `lsjson` to list objects and directories in JSON format

`ls`,`lsl`,`lsd` are designed to be human-readable. `lsf` is designed to be human and machine-readable. `lsjson` is designed to be machine-readable.

Note that `ls` and `lsl` recurse by default - use `--max-depth 1` to stop the recursion.

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

例2：将 ubuntu WebDAV 云盘 webdav\@rpi4b（除 C-C++/ 和 English/ 目录外）同步备份到外挂硬盘（/Volumes/WDHD/）下的文件夹 webdav@rpi4b：

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

可以通过 [cron](https://en.wikipedia.org/wiki/Cron) / [crontab - tables for driving bcron](https://manpages.ubuntu.com/manpages/focal/en/man5/crontab.5.html) 配置定时任务，每天自动执行同步。

参考 [How to Use Cron to Automate Linux Jobs on Ubuntu 20.04](https://www.cherryservers.com/blog/how-to-use-cron-to-automate-linux-jobs-on-ubuntu-20-04) 和 [How do I set up a Cron job? - Ask Ubuntu](https://askubuntu.com/questions/2368/how-do-i-set-up-a-cron-job)。

系统级别的 crontab 配置文件在 /etc/ 目录下（cron*）：

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

### crontab -e

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

在 cron table 末尾新增一条任务，每天凌晨 2:30 和中午 12:00 执行 rclone sync，将 webdav 云盘自动同步到外挂硬盘 /media/WDHD/：

```Shell title="crontab -e"
# auto backup at 2:30/12:00 a.m every day
# 30 2 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b >> /var/log/rclone.log 2>&1
30 2 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone.log
0 12 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone.log
```

!!! note "关于运行日志路径"

    建议通过 [--log-file=FILE](https://rclone.org/docs/#log-file-file) 选项为 rclone 指定用户级别的日志路径。
    如果要使用全局日志路径 /var/log/rclone.log，则需要先 `sudo touch` 再 `sudo chown` 为当前用户组。

输入 `:wq` 保存退出 vim，命令行提示 `crontab: installing new crontab`。

编辑的 personal crontab 将自动追加到 `/var/spool/cron/crontabs/$USER` 文件中。

!!! note "crontab list & remove"

    执行 `crontab -l` 可以查看当前用户的任务列表，或通过 `-u` 选项查看指定用户的任务列表 `crontab -l -u pifan`。
    执行 `crontab -r` 可以移除当前用户配置的任务列表，或 `crontab -ri` 带 interactive prompt 确认。

执行 `sudo systemctl restart cron.service` 重启定时任务使其生效。

### check logs

每天早上起来，检查日志文件，确认系统 cron 定时任务和 rclone sysnc 同步任务执行情况。

系统日志 /var/log/syslog 中，应该有类似的条目：

```dmesg
$ grep -a CRON /var/log/syslog
Apr  7 02:30:00 rpi4b-ubuntu CRON[62328]: (pifan) CMD (rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone.log)
```

也可以开启 cron 独立日志，这样后面可以直接查看 /var/log/cron.log。

!!! note "Use Independent Crontab Logs"

     1. `sudo vim /etc/rsyslog.d/50-default.conf`
     2. uncomment the line starting with the `cron.*`
     3. `sudo systemctl restart rsyslog`

确认 cron 定时任务执行后，再检查 rclone 运行日志 /home/pifan/.config/rclone/rclone.log，查看同步情况。

## Flags & Filtering

[Global Flags](https://rclone.org/flags/), [Rclone Filtering](https://rclone.org/filtering/)

- [Include-from intersection of patterns](https://forum.rclone.org/t/include-from-intersection-of-patterns/13455)
- [How to specify what folders to sync and what to exclude -- include, exclude, filter?](https://forum.rclone.org/t/how-to-specify-what-folders-to-sync-and-what-to-exclude-include-exclude-filter/21821)
- [Rclone copy using regex expression using include multiple expression for file name](https://forum.rclone.org/t/rclone-copy-using-regex-expression-using-include-multiple-expression-for-file-name/26846?page=2)

## refs

[rclone mount](https://rclone.org/commands/rclone_mount/)
[rclone nfsmount](https://rclone.org/commands/rclone_nfsmount/)

[Rclone云存储数据同步工具](https://www.cnblogs.com/varden/p/17181717.html)

[备份同步神器 Rclone 使用教程](https://cloud.tencent.com/developer/article/2192254)

[macOS系统下自动挂载rclone远程存储：实现开机启动项](https://kpfd.com/macos%E7%B3%BB%E7%BB%9F%E4%B8%8B%E8%87%AA%E5%8A%A8%E6%8C%82%E8%BD%BDrclone%E8%BF%9C%E7%A8%8B%E5%AD%98%E5%82%A8%E5%AE%9E%E7%8E%B0%E5%BC%80%E6%9C%BA%E5%90%AF%E5%8A%A8%E9%A1%B9)
