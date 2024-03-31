---
title: vim光标
authors:
  - xman
date:
    created: 2017-10-18T10:50:00
categories:
    - vim
    - editor
tags:
    - vim
comments: true
---

光标定位可参考：**`/usr/share/vim/vim[0-9][0-9]/doc/motion.txt`**
可通过 `:help h` 或 `:h CTRL-N` 搜索帮助。

<!-- more -->

## 移动光标

※※ 要移動光標，請依照說明分別按下 `h`、`j`、`k`、`l` 鍵。 ※※

             ^
             k              提示︰ h 的鍵位于左邊，每次按下就會向左移動。
       < h       l >               l 的鍵位于右邊，每次按下就會向右移動。
             j                     j 鍵看起來很象一支尖端方向朝下的箭頭（down arrow）。
             v

在 Normal Mode 下，你当然也可以直接通过方向键（←↓↑→）来实现光标的移动，但 vi/vim 的宗旨是手指尽量集中在键盘中间排，以最小幅度的按键操作完成大部分定位及编辑工作。

| 按键          | 说明 | 备注             |
| ------------- | ---- | ---------------- |
| `h`           | ←    | `<Left>`         |
| `j` / `<C-n>` | ↓    | `<Down>`，next   |
| `k` / `<C-p>` | ↑    | `<Up>`，previous |
| `l`           | →    | `<Right>`        |

在 Insert Mode 下，按下 **`hjkl`** 将输入普通的字母，此时只能通过方向键来移动光标，或 <Esc> 切回 Normal Mode 定位光标再切换回继续编辑。

> 5h：光标向左移动5个字符位置；5k：光标向上移动5个字符。

`j`、`k` 默认按照自然行上下移动光标；`gj`、`gk` 则按照屏幕行上下移动光标。

## 位置回溯

| 按键    | 说明             | 备注                          |
| ------- | ---------------- | ----------------------------- |
| `<C-o>` | 光标回到上次位置 | takes back to older positions |
| `<C-i>` | 光标回到下次位置 | takes to newer positions      |

vim 打开文件之后，光标一般都在文件开头，想要跳到上次关闭文件前的位置可按下 `'0` 。

`. ：跳转到最近修改过的位置并定位编辑点；  
'. ：跳转到最近修改过的位置但不定位编辑点。  

## 单词定位

| 按键              | 说明                                                   |
| ----------------- | ------------------------------------------------------ |
| `b` / `<S-Left>`  | 移动到上一单词首                                       |
| `w` / `<S-Right>` | 移动到下一单词首（单词字母前）                         |
| `e`               | 移动到当前单词尾（光标移到当前单词的最后一个字母前）   |
| `ge`              | 移动到前一个单词尾（光标移到当前单词的最后一个字母前） |

> 5w：光标从当前单词向右移动到第5个单词的首字符位置；5ge：光标从当前单词向左移动到第5个单词的末字符位置。

**`W`**、**`B`**、**`E`** 命令操作的单词是以空白字符（空格、Tab）分隔的字串。  

***示例1***：以下摘自 `~/.zhsrc`：

```shell
 26 # Uncomment the following line to disable auto-setting terminal title.
```

假设当前光标位于 auto-setting 的字符 a 前，按3次 `w` 或 1次 `W` 都将跳到 `terminal` 前。

***示例2***：以下摘自 `vimtutor` Lesson 4.4: THE SUBSTITUTE COMMAND：

```shell
Type   :%s/old/new/g      to change every occurrence in the whole file.
```

假设当前光标位于 to 前，按8次 `b` 或 1次 `B` 都将跳到 `:` 前。  

## 行内定位

| 按键      | 说明                   | 备注                                               |
| --------- | ---------------------- | -------------------------------------------------- |
| `0` / `|` | 移到行首（`Home`）     | "hard" BOL(Begin Of Line)                          |
| `^` / `_` | 移到行首（非空白字符） | "soft" BOL                                         |
| `$`       | 移到行尾（`End`）      | EOL(End Of Line)                                   |
| `{n}␣`    | 向右（下）移动n个字符  | 数字+空格                                          |
| `%`       | 跳到匹配的括号处       | MATCHING PARENTHESES SEARCH: <br/>"{}"、"[]"、"()" |

## 行间定位

| 按键      | 说明           | 备注       |
| --------- | -------------- | ---------- |
| `-`       | 移动到上一行首 | 非空白字元 |
| `+`       | 移动到下一行首 | 非空白字元 |
| `{n}<CR>` | 向下移动n行    | 数字+回车  |

## 行跳转定位

| 按键                      | 说明                 | 备注                                                |
| ------------------------- | -------------------- | --------------------------------------------------- |
| `gg` / `:0`               | **移到文件第一行首** | 第一行 BOL：<br/>move to the start of the file      |
| `G` / `:$`                | **移到文件末尾行首** | 最后一行的 EOL：<br/>move to the bottom of the file |
| `{n}gg` / `{n}G` / `:{n}` | 移到第n行            | n为行数                                             |

vim在打开文件时，光标默认定位在第一行行首，实际上可通过 `+` 选项带参数指定打开时定位跳转到指定行。

```shell
➜  ~  vim --help
usage: vim [arguments] [file ..]       edit specified file(s)

Arguments:
   --			Only file names after this
   
   +			Start at end of file
   +<lnum>		Start at line <lnum>
```

1. `+<num>`指定打开时光标所在行：  
	> ➜  ~  vim +39 /usr/share/vim/vim[0-9][0-9]/doc/motion.txt
2. `+`打开文件时光标定位到最后一行，方便append编辑：  
	> ➜  ~  vim + /usr/share/vim/vim[0-9][0-9]/doc/motion.txt

## 句段定位

方便以句、段为单位回溯/推进阅读：

| 按键 | 说明          | 备注                                                                  |
| ---- | ------------- | --------------------------------------------------------------------- |
| `(`  | 移到上一句首  | sentences backward                                                    |
| `)`  | 移到下一句首  | sentences forward                                                     |
| `{`  | 移到上一段首  | paragraphs backward                                                   |
| `}`  | 移到下一段首  | paragraphs forward                                                    |
| `[[` | 移到上一句首{ | [count] sections backward or to the previous '{' in the first column. |
| `]]` | 移到下一句首{ | [count] sections forward or to the next '{' in the first column.      |
| `[]` | 移到上一句首} | [count] sections backward or to the previous '}' in the first column. |
| `][` | 移到下一句首} | [count] sections forward or to the next '}' in the first column.      |

**说明：**

> `[[` 跳转至上一个函数（要求代码块中 <kbd>{</kbd> 必须单独占一行）  
> `]]` 跳转至下一个函数（要求代码块中 <kbd>{</kbd> 必须单独占一行）  

## 屏显定位

| 按键          | 说明                 |
| ------------- | -------------------- |
| `H` (`<S-h>`) | 移到当前屏幕的首行   |
| `M` (`<S-m>`) | 移到当前屏幕的中间行 |
| `L` (`<S-l>`) | 移到当前屏幕的末行  |

**说明：**

> 这三个键控屏移仅针对当前屏幕显示范围进行上中下三点定位，方便当前显示区域阅读，而非全文定位。  
> 结合 jk 可进行更细颗粒度的行跳转定位。  

还有一些快捷指令可以基于当前光标所在位置（行）滚动屏幕，以聚焦编辑。

| 按键          | 说明                 |
| ------------- | -------------------- |
| `zz`          | Center this line |
| `z.`          | Center the screen on the cursor |
| `zt`          | Scroll the screen so the cursor is at the top |
| `zb`          | Scroll the screen so the cursor is at the bottom |

## 滚屏定位

| 按键    | 说明                     | 备注                    |
| ------- | ------------------------ | ----------------------- |
| `<C-e>` | 屏幕向下移动一行         | move forward one-line   |
| `<C-y>` | 屏幕向上回滚一行         | move backward one-line  |
| `<C-d>` | 屏幕向下滚动半页         | move **d**own half-page |
| `<C-u>` | 屏幕向上回滚半页         | move **u**p half-page   |
| `<C-f>` | 屏幕向下滚动一页(`PgDn`) | **f**orward             |
| `<C-b>` | 屏幕向上回滚一页(`PgUp`) | **b**ackward            |

滚屏定位可参考：**`/usr/share/vim/vim[0-9][0-9]/doc/scroll.txt`**
可通过 `:help CTRL-D` 或 `:h CTRL-U` 搜索帮助。

> \<C-f\> / \<C-b\> 在 bash shell 命令行输入中是向前/后移动一个字符。  
> \<C-d\> 在 bash shell 命令行输入中是向前删除一个字符；\<C-u\> 则是向后删除到行首或整行。  

**等效实现**：

- `Lzt` 实现 `<C-f>` 的效果；  
- `Hzb` 实现 `<C-b>` 的效果；  

## 参考

[VIM跳转技巧](http://www.cnblogs.com/eyong/p/3588646.html)  
[在vim上实现跳转到定义处的方法](http://blog.csdn.net/jubincn/article/details/7671725)  
[vim括号匹配等跳转技巧](http://blog.csdn.net/caisini_vc/article/details/38351133)  
