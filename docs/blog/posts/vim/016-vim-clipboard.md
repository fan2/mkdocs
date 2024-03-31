---
title: vim剪切
authors:
  - xman
date:
    created: 2017-10-18T12:40:00
categories:
    - vim
    - editor
tags:
    - vim
comments: true
---

本文简单梳理了 vim 如何开启 `+clipboard` 及通过寄存器与系统剪贴板进行交互。

<!-- more -->

[os x 下 vim 无法复制到系统剪贴板的问题](https://www.v2ex.com/t/96300)  
[如何将 Vim 剪贴板里面的东西粘贴到 Vim 之外的地方？](https://www.zhihu.com/question/19863631)  

## reg

vim 输入 `:h reg` 查看寄存器相关内容：

```
5. Copying and moving text                              copy-move

                                                        quote
"{a-zA-Z0-9.%#:-"}      Use register {a-zA-Z0-9.%#:-"} for next delete, yank
                        or put (use uppercase character to append with
                        delete and yank) ({.%#:} only work with put).

                                                        :reg :registers
:reg[isters]            Display the type and contents of all numbered and
                        named registers.  If a register is written to for
                        :redir it will not be listed.
                        Type can be one of:
                        "c"     for characterwise text
                        "l"     for linewise text
                        "b"     for blockwise-visual text


:reg[isters] {arg}      Display the contents of the numbered and named
                        registers that are mentioned in {arg}.  For example:
                                :reg 1a
                        to display registers '1' and 'a'.  Spaces are allowed
                        in {arg}.

                                                        y yank
["x]y{motion}           Yank {motion} text [into register x].  When no
                        characters are to be yanked (e.g., "y0" in column 1),
                        this is an error when 'cpoptions' includes the 'E'
                        flag.

                                                        yy
["x]yy                  Yank [count] lines [into register x] linewise.

                                                        p put E353
["x]p                   Put the text [from register x] after the cursor
                        [count] times.
```

**Special registers**:

```
'"'     the unnamed register, containing the text of the last delete or yank
'%'     the current file name
'#'     the alternate file name
'*'     the clipboard contents (X11: primary selection)
'+'     the clipboard contents
'/'     the last search pattern
':'     the last command-line
'-'     the last small (less than a line) delete
'.'     the last inserted text
```

底行模式输入 `:reg` 可列举查看寄存器，输入 `:reg %` 查看当前文件名，输入 `:reg +`（或 `:reg *`）查看剪贴板寄存器。

> `%` 可作为很多命令的 range，例如 `:%d` 删除所有行，`:%s/foo/bar/gc` 查找替换全文。

---

寄存器是完成这一过程的 **中转站**。Vim 支持的寄存器非常多，其中常用的有 `a-zA-Z0-9+"`。

- `0-9`：表示数字寄存器，是 Vim 用来保存最近复制、删除等操作的内容，其中 0 号寄存器保存的是最近一次的操作内容。  
- `a-zA-Z`：表示用户寄存器，Vim 不会读写这部分寄存器；  
- `"`（单个双引号）：未命名的寄存器，是 Vim 的默认寄存器，例如删除、复制等操作的内容都会被保存到这里。  
- `+`：剪贴板寄存器，关联系统剪贴板，保存在这个寄存器中的内容可以被系统其他程序访问，也可以通过这个寄存器访问其他程序保存到剪贴板中的内容。  

vim 寄存器的数据作用域仅限于vim本地，甚至如果开多个vim窗口，每个窗口都有一套自己完整的寄存器，互相不影响。

### "" & "0

Vim 中执行删除（d,x,c）的内容都会被存放到默认的未命名寄存器（unnamed register,`""`）中，之后可以读取默认寄存器中的内容进行粘贴操作。  
Vim 中执行复制（y[ank]）命令时，要复制的文本不仅会被拷贝到无名寄存器中（`""`），还会拷贝到复制 *专用寄存器*（`"0`）中。  
这样，当我们在执行复制操作后，如果执行了删除操作，还可以执行 `"0p` 从复制专用寄存器中找回上次复制的内容进行粘贴。

### general

[Using vi buffers to copy lines](https://www1.udel.edu/it/help/unix/vi/vi-buffer.html)

The vi editor allows you to copy text from your file into `temporary buffers` for use in other places in the file during your current vi work session. Each buffer acts like temporary memory, or, as some programs call it, a "clipboard" where you can temporarily store information.

- `u`: undo;  
- `yy`: yank;  

`"ayy`	Copy the current line into a buffer named `a`.  
`"b7yy`	Copy 7 lines into a buffer named `b`.  
`"bp`	Put the information in the buffer named `b` after the current cursor position.  
`"bP`	Put the information in the buffer named `b` before the current cursor position.  

普通模式下，输入 `"%p` 在当前光标后插入当前文件名。

### uppercase

假设我们想搜索文档内所有的 `TODO` 并将其收集到一起，可参考以下步骤：

1. 执行 `qaq` 录制空宏，清除寄存器 `"a`；  
2. 执行 `:g/TODO/yank A`，将匹配的内容追加（而非覆盖）到指定寄存器。  

> use uppercase character to **append** with delete and yank

### C-r

在插入（编辑）模式下，按下 `<C-r>`，当前光标处将会显示 `"` 提示输入寄存器。
紧接着输入寄存器编号即可粘贴寄存器内容，例如输入 `%` 插入当前文件名。

```
:h <C-r>

CTRL-R {register}                                       c_CTRL-R c_<C-R>
                Insert the contents of a numbered or named register.  Between
                typing CTRL-R and the second character '"' will be displayed
                to indicate that you are expected to enter the name of a
                register.
```

## clipboard=unnamed

执行 `:set clipboard ?` 查看 clipboard 的值，默认为空。

在 `vim ~/.vimrc` 添加 `set clipboard=unnamed` 之后，y，d，x，p 和 ctrl-c/ctrl-v 一样，直接把内容复制到系统剪贴板。

不建议这么配置，因为 vim 没有自己的 reg buffer 了，会带来诸多不便。
建议开启 `+clipboard` 寄存器与系统剪贴板进行交互。

---

I just found that if you add following line into your `~/.vimrc` file,

```
set clipboard=unnamed
```

then VIM is **using system clipboard**

---

In your `~/.vimrc` file you can specify to automatically use the system clipboard for copy and paste.

On Windows set:

```
set clipboard=unnamed
```

On Linux set (vim 7.3.74+):

```
set clipboard=unnamedplus
```

On macOS:

`brew install vim`, and then append the following line to `~/.vimrc`

```
set clipboard=unnamed
```

now you can copy the line in vim with `yy` and paste it system-wide

## +clipboard

打开 vim 的 clipboard 属性后，vim 才会多出 `"+` 寄存器，映射为系统剪贴板。

[Vim: copy selection to OS X clipboard](https://stackoverflow.com/questions/677986/vim-copy-selection-to-os-x-clipboard)  

The vim that ships with OSX doesn't have `+clipboard` or `+xterm-clipboard`. You can verify this with `vim --version | grep clipboard`. It's possible to resolve this with `brew install vim --with-client-server`

```
faner$ which vim
/usr/bin/vim

faner$ vim --version | head -n 4
VIM - Vi IMproved 8.1 (2018 May 18, compiled Nov 13 2019 20:55:32)
Included patches: 1-503, 505-680, 682-1312
Compiled by root@apple.com
Normal version without GUI.  Features included (+) or not (-):

faner$ vim --version | grep clipboard
-clipboard         +jumplist          +persistent_undo   -vartabs
+eval              -mouse_gpm         +syntax            -xterm_clipboard
```

1. double-quote asterisk (`"*`) before any yank command will yank the results into the copy buffer. That works for Windows and Linux too.

2. On macos 10.8, vim is compiled with `-clipboard` so to use `"*y` you'll need to recompile. Luckily `brew install vim` would compile a new version easily for you and it will be `+clipboard`.

通过 brew 安装 vim 之后，将会支持 `+clipboard`：

```
$  which vim
/usr/local/bin/vim

$  readlink `which vim`
../Cellar/vim/8.2.0/bin/vim

$  vim --version | grep clipboard
+clipboard         +keymap            +printer           +vertsplit
+emacs_tags        -mouse_gpm         -sun_workshop      -xterm_clipboard
```

### "+

日常的 `<C-c>`、`<C-v>` 使用的是系统剪贴板（system clipboard）。系统剪贴板作为系统级别的全局变量，两边当然不能混用。  
所以 vim 专门提供了 `"+` 寄存器作为对系统剪贴板的映射，可以理解成自动把 `"+` 寄存器的内容再复制一份到系统剪贴板。  

非编辑模式下，输入 `"+yy` 复制光标所在行到系统剪贴板，再执行 `"+p` 将系统剪贴板的内容粘贴到 vim 当前光标处。

### copy/paste

[Copy and paste content from one file to another file in vi](https://stackoverflow.com/questions/4620672/copy-and-paste-content-from-one-file-to-another-file-in-vi)

When using `"*` register under X11, also see x11-selection. This also explains the related `"+` register.

requires `+clipboard` out of `vim --version`

If you are using VIM in Windows, you can get access to the clipboard (MS copy/paste) using:

`"*dd` -- cut a line (or 3dd to cut 3 lines)

`"*yy` -- copy a line (or 3yy to copy 3 lines)

`"*p` -- paste line(s) on line after the cursor

`"*P` -- paste line(s) on line before the cursor

The lets you paste between separate VIM windows or between VIM and PC applications (notepad, word, etc).
