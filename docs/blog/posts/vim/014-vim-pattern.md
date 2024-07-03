---
title: vim匹配
authors:
  - xman
date:
    created: 2017-10-18T12:20:00
categories:
    - vim
    - editor
tags:
    - vim
comments: true
---

本文简单梳理了 vim 搜索匹配模式，相关议题 `:h pattern`。

<!-- more -->

## clear search highlighting

[如何去掉当次搜索高亮？](http://forum.ubuntu.org.cn/viewtopic.php?p=815643)

[highlight - Vim clear last search highlighting - Stack Overflow](https://stackoverflow.com/questions/657447/vim-clear-last-search-highlighting)

After doing a search in Vim, I get all the occurrences highlighted. How can I disable that? I now do another search for something gibberish that can't be found. Is there a way to just temporarily disable the highlight and then re-enable it when needed again?

1. To turn off highlighting until the next search: `:noh`/`:nohl`/`:nohls`/`:nohlsearch`.
2. Or turn off highlighting completely: `:set nohlsearch`; type `:set hlsearch` to turn on again.
3. From the [VIM Documentation](http://vimdoc.sourceforge.net/htmldoc/pattern.html#last-pattern)，to clear the last used search pattern: `:let @/ = ""`

[Clear Search Highlight in Vim — tech.serhatteker.com](https://tech.serhatteker.com/post/2020-03/clear-search-highlight-in-vim/)

I personally use 'temporarily disable' with key mapping. I mapped :noh to <esc> key. Since hitting <esc> is a very common and intuitive situtation in Vim.

```vim
" noh - no highlight
map <esc> :noh <CR>
```

[Clear search highlight - VimTricks](https://vimtricks.com/p/clear-search-highlight/)

## incrementally highlights pattern

[incsearch](http://www.vim.org/scripts/script.php?script_id=5038)

[`incsearch.vim`](https://github.com/haya14busa/incsearch.vim) incrementally highlights ALL pattern matches unlike default 'incsearch'.

## Search across multiple lines

[Search across multiple lines](https://vim.fandom.com/wiki/Search_across_multiple_lines)

[How to substitute text across line breaks?](https://vi.stackexchange.com/questions/2830/how-to-substitute-text-across-line-breaks)  
[How to do a multiline search in vim](https://blog-en.openalfa.com/how-to-do-a-multiline-search-in-vim)  
[How to search and delete literal text spanning multiple lines?](https://www.reddit.com/r/vim/comments/28g7y3/how_to_search_and_delete_literal_text_spanning/)  

[Multiline Search and Replace](https://vi.stackexchange.com/questions/6589/multiline-search-and-replace)  
[Multi-line regex support in Vim](https://stackoverflow.com/questions/784176/multi-line-regex-support-in-vim)  

The search `/^abcd` finds `abcd` at the beginning of a line, and `/abcd$` finds abcd at the end of a line.  
However, in `/abcd^efgh` and `/abcd$efgh` the `^` and `$` are just **ordinary** characters with no special meaning.  
By contrast, each of the following has a special meaning anywhere in a search pattern.

meta   | pattern
-------|----------------------------------
`\n`   | a newline character (line ending)
`\_s`  | a whitespace (space or tab) or newline character
`\_^`  | the beginning of a line (zero width)
`\_$`  | the end of a line (zero width)
`\_.`  | any character including a newline

### shortest match first

相关议题：`:h non-greedy`

[vim下正则表达式的非贪婪匹配](https://www.cnblogs.com/vanwoos/p/5006431.html)  
[VIM中正则的非贪婪匹配](https://blog.csdn.net/csCrazybing/article/details/53781385)  

执行 `git merge origin/master` 后，想删除本地 ours HEAD 部分，采用 theirs MERGE_HEAD：

首先查找所有 conflict 的 ours 部分：

```
/^<<<<<<< HEAD\_$\_.\{-}\_^=======\_$
```

替换为空行：

```
:%s/^<<<<<<< HEAD\_$\_.\{-}\_^=======\_$//gc
```

但这并不是我们想要的，空行还是非预期占位一行。

### delete all patterns

[Delete all lines containing a pattern](https://vim.fandom.com/wiki/Delete_all_lines_containing_a_pattern)

[How to delete a multi-line match?](https://vi.stackexchange.com/questions/5265/how-to-delete-a-multi-line-match)  
[Efficient way to delete line containing certain text in vim with prompt](https://stackoverflow.com/questions/46781951/efficient-way-to-delete-line-containing-certain-text-in-vim-with-prompt)  

`:g` 可以删除 theirs 部分的单行结尾标记：

```
:g/^>>>>>>> origin\/master$/d
```

但是对于跨行匹配的结果，`:g` 只删除了第1行？

```
:g/^<<<<<<< HEAD\_$\_.\{-}\_^=======\_$/d
```

> global 命令先扫描 `[range]` 界定的行，然后对每个匹配的行进行标记 (对于一个跨行的匹配，则只针对开始的一行)。

另一种方法：基于 `gn` 选中 search pattern 命中高亮部分（[select text highlighted by search](https://superuser.com/questions/224865/vim-select-text-highlighted-by-search)），再执行删除。

先执行查找：

```
/^<<<<<<< HEAD\_$\_.\{-}\_^=======\_$
```

再执行 `gn$d`，然后重复 `gn$d`。

> `gn` 后如果不添加 `$`，执行删除后换行分隔符将占位一行。

参考 [**VIM提取/删除匹配行的方法**](https://zhuanlan.zhihu.com/p/19632777)，实现 KeepLines(pattern) 函数。

对于大型的文本处理，建议使用 sed/awk 命令。

**其他方案**

1. vscode 正则搜索  
2. sed/awk  
