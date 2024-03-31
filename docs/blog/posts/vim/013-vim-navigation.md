---
title: vim导航
authors:
  - xman
date:
    created: 2017-10-18T12:10:00
categories:
    - vim
    - editor
tags:
    - vim
comments: true
---

除了查看和编辑文件内容以外，vim 还允许查看导航目录的内容。

vim 发行版中自带的 `netrw` 插件允许我们对文件系统进行管理。

<!-- more -->

```
Netrw makes reading files, writing files, browsing over a network, and
local browsing easy!  First, make sure that you have plugins enabled, so
you'll need to have at least the following in your <.vimrc>:
(or see netrw-activate)

        set nocp                    " 'compatible' is not set
        filetype plugin on          " plugins are enabled

(see 'cp' and :filetype-plugin-on)
```

在 `~/.vimrc` 中添加以下配置，确保 vim 已被配置为可加载插件：

```
"去掉有关vi一致性模式，避免以前版本的一些bug和局限
set nocp "nocompatible
"允许vim加载文件类型插件($VIMRUNTIME/ftplugin.vim)
filetype plugin on
```

## netrw-explore

`netrw-explore`: Directory Exploring Commands

[Vim: you don't need NERDtree or (maybe) netrw](https://shapeshed.com/vim-netrw/)  

vim 内置的 netrw 的 *`:Explore`* 及 *`:*explore`* 系列命令支持文件浏览导航功能。

输入 `:h netrw` 或 `:h netrw-explore` 查看相关帮助。

```Shell
netrw-explore  netrw-hexplore netrw-nexplore netrw-pexplore
netrw-rexplore netrw-sexplore netrw-texplore netrw-vexplore netrw-lexplore
DIRECTORY EXPLORATION COMMANDS  {{{2

     :[N]Explore[!]  [dir]... Explore directory of current file      :Explore
     :[N]Hexplore[!] [dir]... Horizontal Split & Explore             :Hexplore
     :[N]Lexplore[!] [dir]... Left Explorer Toggle                   :Lexplore
     :[N]Sexplore[!] [dir]... Split&Explore current file's directory :Sexplore
     :[N]Vexplore[!] [dir]... Vertical   Split & Explore             :Vexplore
     :Texplore       [dir]... Tab & Explore                          :Texplore
     :Rexplore            ... Return to/from Explorer                :Rexplore

     Used with :Explore **/pattern : (also see netrw-starstar)
     :Nexplore............. go to next matching file                :Nexplore
     :Pexplore............. go to previous matching file            :Pexplore
```

截止目前，我们有3种常见的多文件工作流：

1. 复用同一窗口

```
                                                        :edit_f
:e[dit] [++opt] [+cmd] {file}
```

2. 分屏窗口

```
:[N]new [++opt] [+cmd] {file}
[N]vne[w] [++opt] [+cmd] [file]                        :vne :vnew

:[N]sp[lit] [++opt] [+cmd] {file}                       :split_f
:[N]sp[lit] [++opt] [+cmd] [file]                       :sp :split
```

3. 标签页

```
:[count]tabe[dit] [++opt] [+cmd] {file}
:[count]tabnew [++opt] [+cmd] {file}
```

如果想导航浏览工作目录选择打开更多文件进行编辑，可以结合 vim 内置的导航插件。

### Ex(plore)

`:Explore`（简写为 `:Ex`/`:E`），在当前窗格打开当前文档所在的目录，可执行 `:Rexplore`（简写为 `:Rex`/`Re`）随时返回编辑文档；
或浏览选择打开新的文件（复用当前窗口），然后通过 `:bn`/`:bN` 切换buffer。

```
                                                netrw-:Explore
:Explore  will open the local-directory browser on the current file's
          directory (or on directory [dir] if specified).  The window will be
          split only if the file has been modified and 'hidden' is not set,
          otherwise the browsing window will take over that window.  Normally
          the splitting is taken horizontally.
          Also see: netrw-:Rexplore
:Explore! is like :Explore, but will use vertical splitting.

                                                netrw-:Rexplore
:Rexplore  This command is a little different from the other Explore commands
           as it doesn't necessarily open an Explorer window.
```

按下 `-` 可返回上一级目录（也可移动到 `..` 再按下 `<CR>`）。

> `netrw--` : Going Up

在导航窗格中，按下 `qf` 可查看光标所在本地文件的属性信息：

> `netrw-qf` : Displaying Information About File

#### Lex(plore)

`:Lexplore`（简写为 `:Lex`/`:Le`） 与 `:Explore`（简写为 `:Ex`） 的唯一区别是，在左侧打开当前文档所在的目录。
点击目录中的的节点，打开浏览文档时，复用覆盖右侧窗口，但是保留左侧导航窗格。

```
                                                netrw-:Lexplore
:[N]Lexplore [dir] toggles a full height Explorer window on the left hand side
          of the current tab.  It will open a netrw window on the current
          directory if [dir] is omitted; a :Lexplore [dir] will show the
          specified directory in the left-hand side browser display no matter
          from which window the command is issued.

          By default, :Lexplore will change an uninitialized g:netrw_chgwin
          to 2; edits will thus preferentially be made in window#2.

          The [N] specifies a g:netrw_winsize just for the new :Lexplore
          window.

          Those who like this method often also like tree style displays;
          see g:netrw_liststyle.

:[N]Lexplore! [dir] is similar to :Lexplore, except that the full-height
          Explorer window will open on the right hand side and an
          uninitialized g:netrw_chgwin will be set to 1 (eg. edits will
          preferentially occur in the leftmost window).
```

#### op

当光标停留在导航窗格时，还可以按下 `d`/`R`/`D` 快捷实现创建文件夹、重命名/删除文件（夹）等操作。

| cmd       | desc                          |
| --------- | ----------------------------- |
| netrw-`d` | Making A New Directory        |
| netrw-`R` | Renaming Files Or Directories |
| netrw-`D` | Deleting Files Or Directories |

### Sex(plore)

可以基于 `:Sexplore`/`:Hexplore`/`:Vexplore`（`:Sex`/`:Hex`/`:Vex`）打开独立的导航窗口，实现split分屏浏览打开新文件。

```
                                                netrw-:Sexplore
:[N]Sexplore will always split the window before invoking the local-directory
          browser.  As with Explore, the splitting is normally done
          horizontally.
:[N]Sexplore! [dir] is like :Sexplore, but the splitting will be done vertically.

                                                netrw-:Hexplore
:Hexplore  [dir] does an :Explore with :belowright horizontal splitting.
:Hexplore! [dir] does an :Explore with :aboveleft  horizontal splitting.

                                                netrw-:Vexplore
:[N]Vexplore  [dir] does an :Explore with :leftabove  vertical splitting.
:[N]Vexplore! [dir] does an :Explore with :rightbelow vertical splitting.
```

### Tex(plore)

可以基于 `:Te` 打开独立的导航标签页，实现tab分页浏览打开新文件。

```
                                                netrw-:Texplore
:Texplore  [dir] does a :tabnew before generating the browser window
```

### browsing-item

在 `Ex` 或 `Ve` 导航窗格中按下 `<CR>` 时，会复用当前窗口打开光标所在的文件 item（目录导航将被覆盖）。

如果想导航窗格常驻，可通过 `:Le` 打开窗格常驻左侧；或在 `Ex`/`Ve` 导航窗格中按 `o`/`v`/`t`，新开分屏或标签页打开文件。

| cmd       | desc                                      |
| --------- | ----------------------------------------- |
| netrw-`o` | Browsing With A Horizontally Split Window |
| netrw-`v` | Browsing With A Vertically Split Window   |
| netrw-`t` | Browsing With A New Tab                   |

可修改打开方式的配置项为 1/2/3，默认以 `o`/`v`/`t` 打开浏览。

```
  g:netrw_browse_split          when browsing, <cr> will open the file by:
                                =0: re-using the same window  (default)
                                =1: horizontally splitting the window first
                                =2: vertically   splitting the window first
                                =3: open file in new tab
                                =4: act like "P" (ie. open previous window)
```

## settings

`:NetrwSettings`: 打开 Netrw Settings Window 配置窗口，可查看当前配置值，也可修改。

```
With the NetrwSettings.vim plugin,
        :NetrwSettings
will bring up a window with the many variables that netrw uses for its
settings.  You may change any of their values; when you save the file, the
settings therein will be used.  One may also press "?" on any of the lines for
help on what each of the variables do.

(also see: netrw-browser-var netrw-protocol netrw-variables)
```

NETRW BROWSER VARIABLES 相关议题：`netrw-browser-settings`(netrw-browser-options, netrw-browser-var)

以下为 *netrw* 部分定制配置：

```
"==============================================================================
" // netrw-browser-settings
"==============================================================================

"change from above splitting to below splitting
let g:netrw_alto              = 1
"change from left splitting to right splitting
let g:netrw_altv              = 1

"vertically splitting when browsing
let g:netrw_browse_split      = 2

"tree style listing
let g:netrw_liststyle         = 3

"specify initial size of new windows made with o/v
let g:netrw_winsize           = 25 "percentage
```

## [VOoM](http://www.vim.org/scripts/script.php?script_id=2657)

github mirror：[voom.vim](https://github.com/vim-voom/VOoM)  

使用 pathogen 安装 Voom 插件后，使用 vim 打开 `*.md` 文档，然后输入 `:Voom markdown` 即可左侧新建分屏窗口展示 markdown 文档大纲（TOC）。输入 `:q` 即可关闭 TOC 导航窗格。
