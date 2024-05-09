---
title: vim编辑
authors:
  - xman
date:
    created: 2017-10-18T11:10:00
categories:
    - vim
    - editor
tags:
    - vim
comments: true
---

本文梳理了使用 vim 进行撤销、重做，修改、复制、删除，行缩进、行合并，批量编辑和保存、退出等日常基础操作。

<!-- more -->

## 撤销、重做

### 撤销（undo previous actions）

参考：`/usr/share/vim/vim[0-9][0-9]/doc/undo.txt`

| 按键 | 说明         | 备注                                                         |
| ---- | ------------ | ------------------------------------------------------------ |
| `u`  | 撤销（undo） | 直到`Already at oldest change`                               |
| `U`  | 撤销（undo） | 撤销针对光标所在行的操作：<br>undo all the changes on a line |

```shell
**Undo branches**：                                *undo-branches* *undo-tree*

Above we only discussed **one line** of undo/redo.  But it is also possible to **branch off**.  
This happens when you undo a few changes and then make a new change.  The undone changes become a branch.  
You can go to that branch with the following commands.
```

| 按键                    | 说明                                   |
| ----------------------- | -------------------------------------- |
| `:undol[ist]`           | List the leafs in the tree of changes. |
| `g-` / `:ea`/`:earlier` | Go to older text state.                |
| `g+` / `:lat`/`:later`  | Go to newer text state.                |

**`:undol[ist]` Example**:

| number | changes | time     | saved |
| -----: | ------: | -------: | ----- |
| 8      | 8       | 06:30:15 |
| 10     | 9       | 06:30:30 |
| 11     | 9       | 06:30:34 |
| 12     | 9       | 06:30:37 |

The "number" column is the change number.  
This number continuously increases and can be used to identify a specific ***undo-able*** change

### 重做（redo = undo the undo's）

| 按键    | 说明         | 备注                            |
| ------- | ------------ | ------------------------------- |
| `<C-r>` | 重做（redo） | 直到 `Already at newest change` |

### 重复（repeat last change/cmd）

参考：`/usr/share/vim/vim[0-9][0-9]/doc/repeat.txt`

| 按键 | 说明               | 备注                     |
| ---- | ------------------ | ------------------------ |
| `.`  | 重复执行刚才的命令 | 不包括`undo`和`redo`命令 |

**说明：**  
若先按下数字（1\~9），再按下`.`，可重复执行指定次数。

## 修改（change）

参考：`/usr/share/vim/vim[0-9][0-9]/doc/change.txt`

### 替换字符（replace char）

| 按键 | 说明               | 备注                                     |
| ---- | ------------------ | ---------------------------------------|
| `r`  | 替换光标所在的字符 | replace char，只替换一次<br/>替换后恢复指令模式 |
| `R`  | 进入REPLACE MODE   | 连续修改替换，`<Esc>` 退出。               |

#### case

| 按键   | 说明                      | 备注                              |
| ------|--------------------------|-----------------------------------|
| `~`   | switch uppper/lower case | Toggle case (Case => cASE)        |
| `gU`  | Uppercase                | 先选定再执行；或后接 motion，例如 `w`  |
| `gu`  | Lowercase                | 先选定再执行；或后接 motion，例如 `w`  |
| `gUU` | Uppercase current line   | also `gUgU` |
| `guu` | Lowercase current line   | also `gugu` |

### 复制（yank/copy）

| 按键     | 说明                                                                                                                                                    | 备注                                                                                                                                |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `y`      | 按下`l`，向右复制一个字符<br/>按下`h`，向左复制一个字符<br/>按下`w`，向右复制一个单词<br/> 按下`e`，向右复制至单词末<br/> 按下`b`，向左复制一个单词 | copy char forward<br/>copy char backward<br/>copy word forward，包括空格<br/> copy word forward，不包括空格<br/> copy word backward |
| `y0`     | 复制到行首                                                                                                                                              | copy to BOL                                                                                                                         |
| `y$`     | 复制到行末                                                                                                                                              | copy to EOL                                                                                                                         |

**说明：**

若先按下数字（1\~9），再按下 `y`、`Y` 或 `yy`，则表示复制指定数量的字符、单词或行。

#### 复制行

 按键 | 说明 | 备注
-----|-----|---
 `Y`/`yy`  | **复制本行** | copy/Yank line<br/>按`p`会插入粘贴到新起下一行 
 `y1G`     | 复制本行到首行 | copy to BOF 
 `yG`      | 复制本行到末行 | copy to EOF 
 `y-`/`yk` | 复制当前及上一行    | copy line above 
 `y+`      | 复制当前及下一行    | copy line below 

以下为复制当前行及其下4行（共复制5行）的操作方法：

1. `y4k` 复制当前行及其上4行；`y4+` 复制当前行及其下4行；  
2. 普通模式执行 `5yy`: 复制当前光标所在及其下总共5行；  
3. 假设当前光标在第4行，普通模式执行 `y8G`(或 `y8gg`)，复制第4到8共5行；  
4. 底行模式执行 `:4,8y` 复制第4到8共5行；  
5. 假设当前光标在第4行，`V4j` 向下选中第4到8行，再执行 `y` 即可复制。按下 `.` 可重复向下复制5行。  

### 粘贴（paste/put back）

| 按键            | 说明                                              | 备注                                                                |
| --------------- | ------------------------------------------------- | ------------------------------------------------------------------- |
| `p`             | 向**后**粘贴                                      | paste forward<br/>在当前光标所在字符的后面粘贴                      |
| `P`(`<S-p>`)    | 向**前**粘贴                                      | paste backward<br/>在当前光标所在字符的前面粘贴                     |
| `:r [filename]` | 在当前光标所在行的下面读入filename文档的内容      |
| `:r !date`      | 将`date`命令执行结果（当前日期）写入当前vim光标处 | reads the output of the `date` command and puts it below the cursor |

**说明：**

1. `P`和`p`的区别，相当于`i`和`a`。  
2. `y`和`p`的复制粘贴只针对vim编辑器有效，`y`（包括下文中的`d`剪切操作）复制的内容不在系统剪切板中，在vim外无法使用`<C-v>`进行粘贴。  
3. 若先按下数字（1\~9），再按下`p`或`P`，则表示重复粘贴指定次数。  

> `2yy`：复制两行。

---

vim 粘贴自动缩进导致格式混乱问题解决方案：

[configuration - Turning off auto indent when pasting text into vim - Stack Overflow](https://stackoverflow.com/questions/2514445/turning-off-auto-indent-when-pasting-text-into-vim)

在 ~/.vimrc 中添加以下行:

```vim
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
```

### 删除（delete）

#### x/s（delete char）

| 按键           | 说明                                        | 备注                                     |
| -------------- | ------------------------------------------- | ---------------------------------------- |
| `x`            | 向右删除一个字符(`dl`)                      | delete char forward                      |
| `X`（`<S-x>`） | 退格删除一个字符(`dh`)                      | delete char backward/backspace           |
| `s`            | 向右删除一个字符(`cl`)，<br/>并进入编辑模式 | delete char forward and enter inset mode |
| `S`            | 删除本行(`cc`)，并进入编辑模式              | Delete [count] lines and start insert.   |

**说明：**

- 实际上这里的删除都是 `delete [into register x]`，等效于剪切，可使用 `p`/`P` 粘贴回来。  
- 若先按下数字（1\~9），再按下 `x`/`X` 或 `d`/`dd`，则表示删除指定数量的字符、单词或行。  
- 组合命令效果：`xp` 相当于交换两个字符的位置。  
- 可按键 `v` 进入可视模式（Visual Mode），针对选定内容作复制、删除操作。  

#### d/c（delete motion/object）

| 按键          | 说明                                                                                                                                                                                                    | 备注                                                                                                                                                                                                                                                                            |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `d`           | 按下`l`，相当于`x`<br/>按下`h`，相当于`X` <br/>按下`w`，向右删除一个单词 <br/>按下`e`，向右删除至单词末<br/>按下`b`，向左删除一个单词 <br/>按下`j`，删除本行及下一行 <br/>按下`k`，删除本行及上一行 | delete char forward<br/>delete char backward/backspace<br/>delete word forward，不包括下一个单词首字，删除空格<br/>delete to the end of the word，包括下一个单词首字，保留词间空格<br/>delete word backward<br/>delete current line and below<br/>delete current line and above |
| `d0`          | 删除至行首                                                                                                                                                                                              | delete to BOL                                                                                                                                                                                                                                                                   |
| `D`/`d$`      | 删除至行末                                                                                                                                                                                              | delete to EOL                                                                                                                                                                                                                                                                   |

`d*` 这种语法格式称为：`operator + motion` / `operator + object`。

**删除后编辑：**

> 与`d`、`D`/`d$`、`dd`、`dG`对应的有`c`、`C`/`c$`、`cc`/**`S`**、`cG`。  
> `c`命令相对`d`命令不同的是**删除后进入insert模式**，相当于**修改**（ `c` 意即 ***change*** ）。

**说明：**

- 实际上这里的删除都是 `delete [into register x]`，等效于剪切，可使用 `p`/`P` 粘贴回来。
- 在**operator**和**motion**之间或之前增加数字（prepend motion with a number:）：
	`d [number] motion`或`[number] d motion`

	> `d2w`或`2dw`：删除光标所在（之后）的两个单词（word）。

- 组合命令效果：

	> `dt.` 表示删除当前位置到下一个句号之间的内容。

- 可按键 `v` 进入可视模式（Visual Mode），针对选定内容作复制、删除操作。

#### 删除行（delete line）

结合行间移动的 motion，我们可以推演组合围绕当前行进行上下行的删除。

 按键 | 说明           | 备注               
---- | -------------- | ------------------
 `dd`          | **删除本行**  | delete line，下行上移 
 `dgg` / `d1G` | 删除本行到首行 | delete current line to first line 
 `dG`          | 删除本行到末行 | delete current line to last line 
 `d-` | 删除到上一行首 | 删除当前行和上一行 
 `d+` | 删除到下一行首 | 删除当前行和下一行 

在操作符（operator）和移动（motion） 之间插入数字，则表示删除向上/下的几行。

> `d3-`：删除当前行及向上的3行，总共删除4行；  
> `d3+`：删除当前行及向下的3行，总共删除4行。  
> `d2d`或`2dd`：删除两行。  
> `ddp` 相当于交换两行的位置。  

删除多行的操作方法参考复制。

> [How can I delete multiple lines in vi?](https://stackoverflow.com/questions/15912868/how-can-i-delete-multiple-lines-in-vi)  
> [How to Delete Line in VIM on Linux](https://linoxide.com/linux-how-to/how-to-delete-line-vim-linux/)  
> [How to delete lines in Vim](https://www.educative.io/answers/how-to-delete-lines-in-vim)

## 行缩进

The ">" and "<" commands are handy for changing the indentation within
programs.  
Use the '**shiftwidth**' option to set the size of the white space which these commands insert or delete.  Normally the 'shiftwidth' option is 8.

| 指令               | 说明                                                         |
| ------------------ | ------------------------------------------------------------ |
| `<`{motion}        | Shift {motion} lines one 'shiftwidth' leftwards.             |
| `<<`               | Shift [count] lines one 'shiftwidth' leftwards.              |
| {Visual}[count]`<` | Shift the highlighted lines [count] 'shiftwidth' leftwards.  |
| `>`{motion}        | Shift {motion} lines one 'shiftwidth' rightwards.            |
| `>>`               | Shift [count] lines one 'shiftwidth' rightwards.             |
| {Visual}[count]`>` | Shift the highlighted lines [count] 'shiftwidth' rightwards. |

| 命令                        | 说明                                                                                                                    |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `:[range]<`                 | Shift [range] lines one \'shiftwidth\' left. <br/>Repeat `<` for shifting multiple \'shiftwidth\'s.                     |
| `:[range]< {count}`         | Shift {count} lines one \'shiftwidth\' left, starting with [range].<br/>Repeat `<` for shifting multiple 'shiftwidth's. |
| `:[range]le[ft] [indent]`   | left align lines in [range].  Sets the indent in the lines to [indent] (default 0).                                     |
| `:[range]> [flags]`         | Shift {count} [range] lines one 'shiftwidth' right.<br/>Repeat `>` for shifting multiple 'shiftwidth's.                 |
| `:[range]> {count} [flags]` | Shift {count} lines one 'shiftwidth' right, starting with [range].<br/>Repeat `>` for shifting multiple 'shiftwidth's.  |

**说明：**

> See |ex-flags| for [flags].

## 行合并

| 按键 | 说明                   | 备注                   |
| ---- | ---------------------- | ---------------------- |
| `J`  | 合并两行（Join Lines） | 将下一行合并到当前行。 |

## 批量编辑

[vi/vim 中如何在每行行首或行尾插入指定字符串](http://www.cnblogs.com/Dennis-mi/articles/5939635.html)  

可前向参考 《010 - vim 搜索》中的 `:s` 批量查找替换示例。

> [技巧：Vim 的纵向编辑模式](https://www.ibm.com/developerworks/cn/linux/l-cn-vimcolumn/index.html)

### 行编辑复制粘贴和删除

`v`               | 普通模式切换到可视模式       | 从当前光标开始选择：<br/>- 通过 `h`/`l` 或 `b`/`w` 展开行内选择<br/>- 通过`j`/`k`扩展行间选择
`V`(`<S-v>`)      | 普通模式切换到可视**行**模式 | VISUAL LINE：<br/>针对整行选定模式

敲 `v` 从普通模式切换到可视模式，然后可利用方向键展开行内/行间选择，或敲 `V`(`<S-v>`) 切换到可视行模式支持整行选定。
然后再对选定的内容执行复制（y）、粘贴（p）或删除（d）。

### 列编辑插入

1. 按 <kbd>0</kbd>（或 <kbd>^</kbd>）将鼠标移动到行首（非空白字元），按 `CTRL-V` 快捷键进入 VISUAL BLOCK 列选模式；  
2. 通过上下方向键（<kbd>j</kbd>、<kbd>k</kbd>）移动光标，将需要注释的行的开头标记起来；  
3. 按下大写的 <kbd>I</kbd>（`<S-i>`）进入行首插入模式，输入注释符（`//` 或 `#`），然后按下 <kbd>Esc</kbd> 退出插入模式，返回普通模式查看列插入结果。  

为当前行及其下5行（共6行）的行首添加 `//` 注释符号的操作系列：

```
0        "定位到行首
<C-v>    "进入 VISUAL BLOCK 模式
5j       "光标列位向下扩展5行
I        "进入列块的行首插入模式
//       "输入要插入的注释符号
esc      "退出 INSERT 模式，返回普通模式
```

> 也可以利用 `.` 重复操作：`I// <esc>`，然后按 `j.` 重复在下面的各行首插入。

如果想为当前行及其下5行（共6行）的行尾添加 `//` 注释符号呢？这里的问题在于每一行的长短不一。操作系列如下：

```
<C-v>    "进入 VISUAL BLOCK 模式
5j$      "光标列位向下扩展5行，扩展至行尾
A        "进入列块的行尾追加模式
//       "输入要插入的注释符号
esc      "退出 INSERT 模式，返回普通模式
```

> 也可以利用 `.` 重复操作：`A// <esc>`，然后按 `j.` 重复在下面的各行首插入。

如果想在当前行及其下5行（共6行）的行尾的 `;` 之后添加 ` // `，可以利用 `.` 重复操作：`f;A // <esc>`，然后按 `j.` 重复在下面的各行首插入。

### 列编辑删除

如果上一步的注释是单个字符 `#`，可按照以下步骤移除：

1. 按 `CTRL-V` 快捷键进入 VISUAL BLOCK 列选模式；  
2. 通过上下方向键（<kbd>j</kbd>、<kbd>k</kbd>）移动光标，将需要反注释的行的开头字符 `#` 标记起来；  
3. 按 <kbd>x</kbd> 键批量删除列选的 `#` 字符。  

如果上一步的注释是双字符 `//`，则第2步需按下 `l` 先向右扩选一列，再按 `j` 向下扩选行范围，然后再按下 <kbd>d</kbd> 键删除列选。

> 当然也可以先按 `j` 向下扩选行，再 `l` 向右扩选1列。

### 插入行号

[如何使用Vim为每一行自动编号？](https://www.zhihu.com/question/20240867)  

#### nl

`:%!nl` : 在所有非空行前加入行号  
`:%!nl -ba` : 在所有行前加入行号 利用 Linux 命令 nl 来实现的  

#### line

> [如何使用Vim为每一行自动编号？](https://www.zhihu.com/question/20240867)

每行（包括空白行）前面插入行号：

```shell
:%s/^/\=line(".")/
```

> 当 `:s` 命令的替换字符串以 `\=` 开头时，表示以表达式的计算结果作为替换值。

以下在每行前面添加 `行号,`：

```shell
:%s/^/\=line('.').','/
```

以下在每行前面添加 `行号,TAB`：

```shell
:%s/^/\=line(".").",\t"/
```

## 保存退出（save & exit）

> 详情参考 `/usr/share/vim/vim[0-9][0-9]/doc/editing.txt` 章节。

### Discard(recover)

关键字：`:edit!` *discard*  
命令：`:e[dit]! [++opt] [+cmd]`  
作用：从磁盘重新加载，覆盖当前缓存的修改。

```Shell
Edit the current file always.
Discard any changes to the current buffer.
This is useful if you want to start all over again.
```

### Writing(w,up,sav)

关键字：***writing***, ***save-file***  

关键字：`:w`, *:write*  
**命令**：`:w[rite][!] [++opt]`  
帮助：`:h :w[rite]`  
作用：将 vim 编辑缓存回写文件。  

```Shell
Write the whole buffer to the current file.  
'!' forcefully write when 'readonly' is set  
```

关键字：`:up`, *:update*  
**命令**：`:[range]up[date][!] [++opt] [>>] [file]`  
帮助：`:h :up[date]`  
作用：当有编辑时，将改动回写文件。  

```Shell
Like ":write", but only write when the buffer has been modified.  
```

关键字：`:sav`, *:saveas*  
**命令**：`:sav[eas][!] [++opt] {file}`  
帮助：`:h :sav[eas]`  
作用：将 vim 编辑缓存另存为指定文件。  

```Shell
Save the current buffer under the name {file} and set the filename of the current buffer to {file}.  
The [!] is needed to overwrite an existing file.  
```

#### mkdir

当执行 `vim filepath` 或 `:edit filepath` 中间的目录不存在时，尝试回写保存将提示目录不存在的出错信息。
此时，可以调用 shell 命令 `mkdir -p ` 按需创建中间目录进行补救：

```
:!mkdir -p %:h
:write
```

#### sudo

如果 vim 以普通身份打开了 root 用户的文件（例如 `/etc/hosts`），尝试将修改后的 buffer 回写磁盘，则提示没有权限：

```
:write
E45: 'readonly' option is set(add ! to override)
```

`:w!` 尝试强制写入：

```
:w!
"etc/hosts" E212: Can`t open file for writing
```

现在的问题在于，我们没有写 `/etc/hosts` 文件的权限。

这个文件是由 root 用户拥有的，可以通过以下这条怪模怪样的命令补救：

```
:w !sudo tee % > /dev/null
```

`:write !{cmd}` 这条命令会把缓冲区的内容作为标准输入传给指定的 `{cmd}`。  
以上命令会把缓冲区的内容当作标准输入，并用它来覆盖 `/etc/hosts` 的内容。

#### WRITING WITH MULTIPLE BUFFERS(wa)

关键字：***buffer-write***  

关键字：`:wa`, *:wall*  
**命令**：`:wa[ll][!]`  
帮助：`:h :wa[ll]`  
作用：将 vim 所有编辑缓存回写到对应文件。  

```Shell
Write all changed buffers.  
with suffix '!': forcefully write even the ones that are readonly.  
```

### Writing and quitting(wq)

关键字：***write-quit***  

关键字：`:q`, *:quit*  
**命令**：`:q[uit][!]`  
帮助：`:h :q[uit]`  
作用：关闭退出当前 vim 窗口；如有改动可追加 `!` 放弃修改强制退出。  

```Shell
Quit the current window. Quit Vim if this is the last window.  
with suffix '!': Quit without writing, also when currently visible buffers have changes.  
```

关键字：`:confirm`, *:conf*  
**命令**：`:conf[irm] {command}`  
帮助：`:h conf[irm]`  
作用：退出时，如有需要弹出确认框。

```Shell
Quit, but give prompt when changes have been made  
```

例如：如果当前文档有改动但未保存，输入 `:conf[irm] q[uit]`，将弹出 confirm 文本提示：

```
Save changes to "/tmp/*"?
[Y]es, (N)o, (C)ancel: 
```

关键字：`:wq`  
**命令**：`:wq[!] [++opt] {file}`  
帮助：`:h :wq`  
作用：将 vim 编辑缓存回写保存到文件并退出。如果是 `vim -R` 打开的文档或 `sudo vim` 打开的无写权限文档，可追加 `!` 强制保存退出。

```Shell
Write the current file to {file} and quit.  
with suffix '!': forcefully write when 'readonly'.  
```

### Last Line Mode

| 命令                            | 说明                         | 备注                                                                                                                               |
| ------------------------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `:q`                            | 退出（quit）                 | 如果无修改直接退出；<br/>否则提示`No write since last change (add ! to override) `                                                 |
| `:q!` / `ZQ`                    | 强制退出                     | 放弃修改                                                                                                                           |
| `:w`/`:write` / `:up`/`:update` | 写入（write）保存            | 从swap buffer写入文件；<br/>若以只读方式打开，则提示'readonly' option is set (add ! to override)；<br/>也可另存为：`:w [filename]` |
| `:w!`                           | 若文本属性为只读时，强制保存 |
| `:wq` / `ZZ` / `:x`/`:exit`     | 保存并退出                   |
| `:wq!`                          | 强制保存并退出               |

### 保存部分文件

`:m,n w <file>`: 将 m 行到 n 行部分的内容保存到文件 file 中；  
`:m,n w >> <file>`: 将 m 行到 n 行的内容追加到文件 file 末尾  

To write a range of lines to another file you can use:  
Where `<m>` and `<n>` are numbers (or symbols) that designate a range of lines.  
For using the desktop clipboard, take a look at the `+g` commands.  

---

While editing the file, make marks where you want the start and end to be using

`ma` - sets the a mark  
`mb` - sets the b mark  

Then, to copy that into another file, just use the w command:

```
:'a,'b w /name/of/output/file.txt
```
