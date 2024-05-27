---
title: vim搜索
authors:
  - xman
date:
    created: 2017-10-18T11:50:00
categories:
    - vim
    - editor
tags:
    - vim
comments: true
---

本文简单梳理了 vim 搜索查找和替换的基本操作。

<!-- more -->

参考：`/usr/share/vim/vim[0-9][0-9]/doc/change.txt`

[Search and replace](https://vim.fandom.com/wiki/Search_and_replace)  

## f,t 搜索字符

指令                 | 说明
--------------------|------------------------
`t{char}`           | Till **before** [count]'th occurrence of {char} to right.
`T{char}`           | Till **before** [count]'th occurrence of {char} to left.
`f{char}`           | To [count]'th occurrence of {char} to the right.
`F{char}`           | To the [count]'th occurrence of {char} to the left.

### repeat

指令                 | 说明
--------------------|------------------------
`;`                 | Repeat latest f, t, F or T [count] times.
`,`                 | Repeat latest f, t, F or T in **opposite** direction [count] times.

> 对应帮助文档：motion.txt

## /,* 搜索查找

> 对应帮助文档：pattern.txt，帮助命令 `:h pattern-overview`、`:h regexp` 或 `:h vimgrep`。

命令                | 说明            | 备注
--------------------|----------------|--------
`/phrase`           | searches FORWARD for the phrase  | `\c`可以忽略大小写（ignore case），`\C`则区分大小写
`?phrase`           | searches BACKWARD for the phrase | `\c`可以忽略大小写（ignore case），`\C`则区分大小写
`*phrase`           | search forward : `/<phrase>`   | 向下查找当前光标所在单词
`#phrase`           | search backward : `?<phrase>`  | 向上查找当前光标所在单词

在 `/` 或 `?` 后输入关键字后，按回车键开始搜索，然后按 <kbd>n</kbd>/<kbd>N</kbd> 查找下/上一个。

- `n`: to find the next occurrence in the same direction  
- `N`: to search in the opposite direction  
- `gn`: Search forward for the last used search pattern, and start *Visual* mode to select the match.  

> 对于文本 `This is his idea`，执行 `/his` 将会命中 This 和 his；执行 `/\<his\>` 将只命中 his。

参考 [**VI**(1P)](http://man7.org/linux/man-pages/man1/vi.1p.html) 的 **EXTENDED DESCRIPTION** 的以下章节：

- Find Regular Expression（Synopsis: `/`）  
- Scan Backwards for Regular Expression（Synopsis: `?`）  
- Repeat Regular Expression Find (Forward)（Synopsis: `n`）  
- Repeat Regular Expression Find (Reverse)（Synopsis: `N`）  

[Vi and Vim Editor: 12 Powerful Find and Replace Examples](http://www.thegeekstuff.com/2009/04/vi-vim-editor-search-and-replace-examples/)    

由于配置了查找匹配高亮显示（hls/hlsearch），查找到的匹配结果会高亮显示，如果想去除搜索结果高亮，可以参考 [vim-pattern](./014-vim-pattern.md)。

### repeat

`/phrase` 和 `?phrase` 尾部可添加 `/` 和 `?` 进行闭合，后面可以添加其他选项，例如 `/phrase/e` 定位到结尾字符前。

`/<CR>`(`//<CR>`) 和 `?<CR>`(`??<CR>`) 均按上次的关键词进行查找。

> `q/` 和 `q?` 可查看查找历史。

### visual expansion

查找命令不仅限于在普通模式下使用，还可以在可视模式及操作符待决模式中使用它。

例句：`This phrase takes time but eventually gets to the point.`

假设当前光标在单词 `takes` 的首字母，删除 `takes time but eventually` 的操作序列如下：

1. `v`: 进入可视模式；  
2. `/ge`：扩大选取到 gets 的 `g`；  
3. `h`：光标回退到空格；  
4. `d`：删除选中的 `takes time but eventually `；  

## `:g` 通配

```bash
                                                :g :global E148
:[range]g[lobal]/{pattern}/[cmd]
                        Execute the Ex command [cmd] (default ":p") on the
                        lines within [range] where {pattern} matches.

:[range]g[lobal]!/{pattern}/[cmd]
                        Execute the Ex command [cmd] (default ":p") on the
                        lines within [range] where {pattern} does NOT match.
```

在 vim 中输入 `:g/{pattern}` 命令可列出所有通配模式 `pattern` 的行。  

- 执行 `:g/{pattern}/d` 删除所有匹配行。  
- 执行 `:g/{pattern}/m0` 或 `:g/{pattern}/m$` 跳转到第一个或最后一个匹配行。  

### regex

http://vimregex.com/

参考 [**VI**(1P)](http://man7.org/linux/man-pages/man1/vi.1p.html) 的 **EXTENDED DESCRIPTION** 的以下章节：

- Find Regular Expression（Synopsis: `/`）  

### vimgrep

[Show only matching lines?](https://vi.stackexchange.com/questions/2280/show-only-matching-lines)  
[How to filter text matched by global command?](https://vi.stackexchange.com/questions/10860/how-to-filter-text-matched-by-global-command)  

在 vim 中查找过滤包含关键字的行（filter lines），除了执行的 global pattern match 之外，也可执行 **vimgrep** 命令执行高级查找过滤。

1. 执行以下命令查找整个文件内的关键字 `{pattern}`：

	> `:vimgrep {pattern} %`

   - `:cn` - jump to the next match  
   - `:cp` - jump to the previous match  
   - `:cwin`/`:copen` - open a window containing the list of matches  

2. 执行 `:cwin` 打开查找结果 buffer。在其中可使用上下方向键或<kbd>j</kbd><kbd>k</kbd>定位，按下<kbd>enter</kbd>键跳转到原文匹配行。  

3. 执行 `:sav filterlines.txt` 可将结果 buffer 保存到指定文件（filterlines.txt）中。  

### Permute Lines: Reverse

经典案例：[Reverse order of lines](https://vim.fandom.com/wiki/Reverse_order_of_lines)

reverse all lines in the current buffer:

```vim
:g/^/m0
```

1. `:` start command-line mode.  
2. `g` means you'll take an action on any lines where a regular expression matches  
3. `/` begins the regular expression (could have used any valid delimiter)  
4. `^` matches the start of a line (which matches all lines in the buffer)  
5. the second `/` ends the regular expression; the rest is an Ex command to execute on all matched lines (i.e. all lines in buffer)  
6. `m` means move (`:help :move`)  
7. `0` is the destination line (beginning of buffer)  

> 在 Unix-like 系统上，如果有 `tac` 命令，可以执行 `:%!tac` 利用外部命令实现行序翻转。

以下为 /share/vim/vim82/doc/change.txt 中关于 `:move` 帮助的部分文字：

```bash
1346 :[range]m[ove] {address}                        :m :mo :move E134
1347                         Move the lines given by [range] to below the line
1348                         given by {address}.
1349
1350 ==============================================================================
1351 6. Formatting text                                      formatting
1352
1353 :[range]ce[nter] [width]                                :ce :center
1354                         Center lines in [range] between [width] columns
1355                         (default 'textwidth' or 80 when 'textwidth' is 0).
```

执行 `:1350,1353g/^/m1349`，可将 1350~1353 这4行移动到 1349 行下面（的1350行），实现行序翻转：

```bash
1346 :[range]m[ove] {address}                        :m :mo :move E134
1347                         Move the lines given by [range] to below the line
1348                         given by {address}.
1349
1350 :[range]ce[nter] [width]                                :ce :center
1351
1352 6. Formatting text                                      formatting
1353 ==============================================================================
1354                         Center lines in [range] between [width] columns
1355                         (default 'textwidth' or 80 when 'textwidth' is 0).
```

可分步执行查看逐行移动的操作结果：

1. `:1350m1349`：将1350行移动到1350行，不变；  
2. `:1351m1349`：将1351行移动到1350行，原1350行下移至1351行；  
3. `:1352m1349`：将1352行移动到1350行，1350行（原1351行）下移至1351行；  
4. `:1353m1349`：将1353行移动到1350行，1350行（原1352行）下移至1351行；  

> 在 Unix-like 系统上，如果有 `tac` 命令，可以执行 `:1350,1353!tac` 利用外部命令实现行序翻转。

### Delete Global Pattern Lines

[search - How to delete searched line and next - Vi and Vim Stack Exchange](https://vi.stackexchange.com/questions/8504/how-to-delete-searched-line-and-next)

`:g/{pattern}/,+3d`: delete the current line and the 3 following

[Delete all lines containing a pattern | Vim Tips Wiki | Fandom](https://vim.fandom.com/wiki/Delete_all_lines_containing_a_pattern)

deleting all lines that are empty or that contain only whitespace:

```vim
:g/^\s*$/d
```

To specify lines that do not contain a pattern, use `g!`, which is equivalent to `v`.

The next example shows use of \| ("or") to delete all lines except those that contain "error" or "warn" or "fail":

```vim
:v/error\|warn\|fail/d
```

`g` can also be combined with a range to restrict it to certain lines only. For example to delete all lines containing "profile" from the current line to the end of the file:

```vim
:.,$g/profile/d
```

## `:s` 查找替换

> 对应帮助文档：change.txt

按键                | 说明
--------------------|------------------------
`:s/old/new`        | only changes the **first** occurrence of "old" in the line.
`:s/old/new/g`      | Adding the `g` flag means to substitute **globally** in the line, <br/>change all occurrences of "old" in the line.
`:#,#s/old/new/g`   | where #,# are the *line numbers* of the **range** of lines <br/>where the substitution is to be done.
`:%s/old/new/g`     | to change every occurrence in the ***whole file***.
`:%s/old/new/gc`    | to find every occurrence in the ***whole file***, with a *prompt* whether to substitute or not.

- **`/g`** 尾缀（suffix）代表对行内所有匹配都执行（替换）操作；  
- `/c` 尾缀（suffix）代表执行操作前弹出确认（confirm prompt）；  
- **`%`** 前缀（prefix）代表针对被编辑文件的所有行都执行后续操作；  

```Shell
[i]     Ignore case for the pattern.
[I]     Don't ignore case for the pattern.
```

可以参考分析帮助文档中的示例：

```bash
Examples: >
# \0: replaced with the whole matched pattern
  :s/a\|b/xxx\0xxx/g             modifies "a b"      to "xxxaxxx xxxbxxx"

  :s/\([abc]\)\([efg]\)/\2\1/g   modifies "af fa bg" to "fa fa gb"

# 中间插入换行符，相当于切割分行
  :s/abcde/abc^Mde/              modifies "abcde"    to "abc", "de" (two lines)

# 转义为原始符号，只是在当前行末添加两个字符(^M)
  :s/$/\^M/                      modifies "abcde"    to "abcde^M"


  :s/\w\+/\u\0/g                 modifies "bla bla"  to "Bla Bla"
  :s/\w\+/\L\u\0/g               modifies "BLA bla"  to "Bla Bla"

command         text    result ~
:s/aa/a^Ma/     aa      a<line-break>a
:s/aa/a\^Ma/    aa      a^Ma
:s/aa/a\\^Ma/   aa      a\<line-break>a

(you need to type CTRL-V <CR> to get a ^M here)

```

### substitute delete

将换行符（old=`^$\n`）的空行替换为空（new=空），相当于移除空行。

- `:%s/^$\n//g` or `:1,$s/^$\n//g`

`:%s/\n//g`：删除换行符；  
`:%s/\r//g`：删除DOS文件中的回车符`^M`；  

[vi - Efficient way to delete line containing certain text in vim with prompt - Stack Overflow](https://stackoverflow.com/questions/46781951/efficient-way-to-delete-line-containing-certain-text-in-vim-with-prompt)

The most efficient way is to combine :glboal and :norm

```vim
:g/test/norm dd
:g/test/d
```

Substitute with matched pattern:

```vim
:%s/.*text.*\n//gc
```

Mix `:help global` and `:help substitute`:

```vim
:g/text/s/.*\n//c
```

### add comment

> [VIM多行注释/反注释](http://blog.csdn.net/xufeng0991/article/details/50201561)  
> [vim多行注释和取消注释](http://www.cnblogs.com/Ph-one/p/5641872.html)  
> [vim行首加入某字符](http://blog.csdn.net/xxxxxx91116/article/details/7960097)  
> [vi/vim 中如何在每行行首或行尾插入指定字符串](http://www.cnblogs.com/Dennis-mi/articles/5939635.html)  

1. 在所有行首添加注释符号（//）：  

    - `:%s/^/\/\//g`  
    - `:%s#^#//#g`（用 `#` 或 `+` 代替 `/`，old 或 new 中的 `/` 不用转义）  

    > 说明：行首（old=`^`）替换为注释符号（new=`//`）。 
    > 若将 `^` 替换为 `$` 则针对行尾操作。  

2. 为 20~50 行首添加注释符号（//）：  

    - `:20,50 s/^/\/\//g` or `:20,50s#^#//#g`

3. 在 markdown 文档的 143~145 这3行首插入 `- `，使之成为 Unordered List：

    - `143,145s#^#- #`

4. 为 20~50 行首移除注释符号（//）：

    - `:20,50 s/^\/\///g`  
    - `:20,50s#^//##g`  

    > 说明：行首的注释符号（old=`^//`）替换为空（new=空），相当于删除。  
