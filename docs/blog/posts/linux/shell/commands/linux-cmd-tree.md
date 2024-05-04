---
title: Linux Command - tree
authors:
  - xman
date:
    created: 2019-10-29T10:10:00
categories:
    - wiki
    - linux
tags:
    - tree
comments: true
---

linux 下的命令 tree 简介。

<!-- more -->

## [Microsoft DOS tree command](http://www.computerhope.com/treehlp.htm)

### function

以图形显示驱动器或路径的文件夹结构。

### help

`tree /?`：查看帮助

### usages & synopsis

`TREE [Drive:[[Path] [/F] [/A]`

option                      |  instruction
---------------------|----------------
`Drive:\Path`  | Drive and directory containing disk for display of directory structure.
`/F`          | Displays file **names** in each directory.<br>显示每个文件夹中文件的名称。 
`/A`          | ext characters used for linking lines, instead of graphic characters. `/a` is used with code pages that do not support graphic characters and to send output to printers that do not properly interpret graphic characters.<br>使用 ASCII 字符，而不使用扩展字符。

使用 `/F` 参数时显示所有目录及目录下的所有文件。

### demonstrations

1. 把 D 盘下的所有目录结构以树状结构导出，以文本文件 `dTree.txt` 保存在文件夹 `d:\` 下。

	> tree d: > d:\dTree.txt 或 tree d:\ > d:\dTree.txt

2. 把 D 盘下的所有目录及文件结构以树状结构导出，以文本文件 `dF.txt` 保存在文件夹 `d:\` 下。

	> tree d: /f > d:\dF.txt 或 tree d:\ /f > d:\dF.txt

### reference

[Windows 中的 Tree 命令你会用吗？](http://blog.csdn.net/hantiannan/article/details/7663893)  
[最强最全的Tree命令详解](http://www.blogjava.net/coderdream/archive/2008/01/18/176352.html)  
[Saving 'tree /f /a" results to a textfile with unicode support](http://stackoverflow.com/questions/138576/saving-tree-f-a-results-to-a-textfile-with-unicode-support)

## [macOS 下的 tree 命令](http://www.cnblogs.com/ayseeing/p/4097066.html)

### function

list contents of directories in a tree-like format.

### help

`tree --version`：查看版本（Print version and exit.）  
`tree --help`：查看帮助（Print usage and this help message and exit.）  
`man tree`：查看详细帮助手册  

### usages & synopsis

`tree [-acdfghilnpqrstuvxACDFQNSUX]`

```Shell
usage: tree [-acdfghilnpqrstuvxACDFJQNSUX] [-H baseHREF] [-T title ]
	[-L level [-R]] [-P pattern] [-I pattern] [-o filename] [--version]
	[--help] [--inodes] [--device] [--noreport] [--nolinks] [--dirsfirst]
	[--charset charset] [--filelimit[=]#] [--si] [--timefmt[=]<f>]
	[--sort[=]<name>] [--matchdirs] [--ignore-case] [--] [<directory list>]
```

1. ------- Listing options -------
2. -------- File options ---------
3. ------- Sorting options -------
4. ------- Graphics options ------
5. ------- XML/HTML/JSON options -------
6. ---- Miscellaneous options ----

### demonstrations

- `-d`：List directories only（打印目录）

```Shell
faner@FAN-MB0:~/Library/Application Support/FoldingText/Plug-Ins|
⇒  tree -d
.
├── change\ document\ expansion\ level.ftplugin
├── change\ number\ of\ heading\ levels.ftplugin
├── concentrate.ftplugin
├── date\ and\ time.ftplugin
├── paste\ table\ of\ shortcut\ keys.ftplugin
├── rendered_images.ftplugin
├── smart\ quotes.ftplugin
└── theme\ basic.ftplugin
    ├── assets
    │   └── Orig_ratio
    └── images

11 directories
```

- ` -L level`：Descend only level directories deep（指定目录层级）

```Shell
faner@FAN-MB0:~/Library/Application Support/Sublime Text 3/Packages|
⇒  tree -d -L 1
.
├── Clickable\ Urls
├── Codecs33
├── Color\ Scheme\ -\ Brogrammer
├── ConvertToUTF8
├── Delete\ Blank\ Lines
├── FileBrowser
├── Filter\ Lines
├── GBK\ Encoding\ Support
├── OmniMarkupPreviewer
├── User
├── backrefs
├── bs4
├── markupsafe
├── mdpopups
├── package_events
├── pathtools
├── pygments
├── python-jinja2
├── python-markdown
├── pyyaml
└── watchdog

21 directories
```

### reference

[mac安装tree命令](http://www.jianshu.com/p/1326756ad23e)  
[MAC终端中安装命令行工具TREE](http://coderlt.coding.me/2016/03/16/mac-osx-tree/)  
[mac 上使用tree命令生成树状目录](http://qingtong234.github.io/2016/01/07/mac上使用tree命令生成树状目录/)  
[mac 下的 tree 命令 终端展示你的目录树结构](http://yijiebuyi.com/blog/c0defa3a47d16e675d58195adc35514b.html)  
