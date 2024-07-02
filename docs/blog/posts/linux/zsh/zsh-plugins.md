---
title: macOS下zsh安装使用插件
authors:
  - xman
date:
    created: 2019-10-27T11:30:00
categories:
    - wiki
    - zsh
comments: true
---

zsh 插件的配置和使用记录。

<!-- more -->

[oh-my-zsh插件推荐](https://www.jianshu.com/p/9189eac3e52d)  
[一些实用常用插件推荐 for zsh（oh-my-zsh）](https://blog.e9china.net/lesson/yixieshiyongchangyongchajiantuijianforzshoh-my-zsh.html)  
[**awesome-zsh-plugins**](https://github.com/unixorn/awesome-zsh-plugins)  

## builtin

`~/.zshrc` 中定义了 ZSH 变量：

```Shell
$ head -10 ~/.zshrc
# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
```

oh-my-zsh 内置插件存放在 `$ZSH/plugins` 目录。

- https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins  
- https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins  

可在 `~/.zshrc` 中的 plugins 括号数组中添加启用插件，多个插件以空格或换行分隔。

### macos

[ohmyzsh/plugins/macos/](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos)

This plugin provides a few utilities to make it more enjoyable on macOS (previously named OSX).

| Command       | Description                                                 |
| :------------ | :---------------------------------------------------------- |
| `tab`         | Open the current directory in a new tab                     |
| `split_tab`   | Split the current terminal tab horizontally                 |
| `vsplit_tab`  | Split the current terminal tab vertically                   |
| `ofd`         | Open the current directory in a Finder window               |
| `pfd`         | Return the path of the frontmost Finder window              |
| `pfs`         | Return the current Finder selection                         |
| `cdf`         | `cd` to the current Finder directory                        |
| `pushdf`      | `pushd` to the current Finder directory                     |
| `quick-look`  | Quick-Look a specified file                                 |
| `man-preview` | Open a specified man page in Preview app                    |
| `showfiles`   | Show hidden files in Finder                                 |
| `hidefiles`   | Hide the hidden files in Finder                             |
| `itunes`      | DEPRECATED. Use `music` from macOS Catalina on              |
| `music`       | Control Apple Music. Use `music -h` for usage details       |
| `spotify`     | Control Spotify and search by artist, album, track and etc. |
| `rmdsstore`   | Remove .DS_Store files recursively in a directory           |
| `btrestart`   | Restart the Bluetooth daemon                                |
| `freespace`   | Erases purgeable disk space with 0s on the selected disk    |

几个有用的命令：

- `tab`：Terminal.app - Preferences - General - New tabs open with `Same Working Directory`，`⌘T` 打开新 tab 默认打开当前工作目录。  
- `ofd`：在 Finder 中定位到当前工作目录（reveal in finder），等效于执行 `open .` 命令。  
- `man-preview zsh`：等效于 `man -t zsh | open -fa "Preview"`，用 Preview.app 以 PDF 格式打开 zsh 的 man page。  
- `showfiles`/`hidefiles`：定位到 Finder 中 显示/隐藏 隐藏文件（Show/Hide hidden files）。  

---

其他macOS平台相关插件：

1. [brew](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/brew): adds several aliases for common brew commands.

> Homebrew 默认已经提供了针对 zsh 的智能完成提示，故 brew 插件了主要提供了部分 aliases。

2. [pod](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/pod): adds completion for CocoaPods

3. [xcode](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/xcode): provides a few utilities that can help you on your daily use of Xcode and iOS development.

4. [iterm2](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/iterm2)

   - [zsh-tab-colors](https://github.com/tysonwolker/iterm-tab-colors) - Automatically changes iTerm tab color based on the current working directory.  
   - [iterm-touchbar](https://github.com/iam4x/zsh-iterm-touchbar) - Display iTerm2 feedback in the MacbookPro TouchBar (Current directory, git branch & status).  
   - [iterm2colors](https://github.com/shayneholmes/zsh-iterm2colors) - Manage your iterm2's color scheme from the command line.  
   - [iterm2-tabs](https://github.com/gimbo/iterm2-tabs.zsh) - Set colors and titles of iTerm2 tabs. 安装使能参考 `vimman.zsh`。  

### nav

macOS 的 Bash Shell 内置了 *pushd*、*popd*、*dirs -v* 等管理cd导航堆栈的命令。

#### dircycle

[dircycle](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dircycle): Plugin for cycling through the directory stack

This plugin enables directory navigation similar to using back and forward on browsers or common file explorers like Finder or Nautilus. It uses a small zle trick that lets you cycle through your directory stack left or right using `Ctrl` + `Shift` + `Left` / `Right` . This is useful when moving back and forth between directories in development environments, and can be thought of as kind of a nondestructive *pushd*/*popd*/*dirs -v*.

快捷键：`^⇧←` / `→`。

相关插件：

1. [last-working-dir](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/last-working-dir)

    - Also adds a `lwd` function to jump to the last working directory.

2. [dirhistory](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dirhistory): 提供了几个类似资源管理器中的导航快捷键。

| Command       | Description                                                 |
| :------------ | :---------------------------------------------------------- |
| Shortcut      | Description                                                 |
| Alt + Left  / ⌥← | Go to previous directory                                    |
| Alt + Right / ⌥→ | Go to next directory                                        |
| Alt + Up    / ⌥↑ | Move into the parent directory                              |
| Alt + Down  / ⌥↓ | Move into the first child directory by alphabetical order   |

3. [per-directory-history](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/per-directory-history)

    - This plugin adds per-directory history for zsh, as well as a global history, and the ability to toggle between them with a keyboard shortcut.
    - Press `^G` (the Control and G keys simultaneously) to toggle between local and global histories.

#### z & j

- [z](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/z)  
- [autojump](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/autojump)  

可启用内置的 `z` 命令（jump around），和 `j` 命令（`autojump`）除了名字不一样，功能基本雷同。

**语法**（SYNOPSIS）：`z [-chlrtx] [regex1 regex2 ... regexn]`  

```Shell
Tracks your most used directories, based on 'frecency'.

After a short learning phase, z will take you to the most 'frecent' directory that matches ALL of the regexes given on the command line, in order.  
For example, z foo bar would match /foo/bar but not /bar/foo.  
```

选项参数（OPTIONS）：

- `-c`: restrict matches to subdirectories of the current directory  
- `-h`: show a brief help message  
- `-l`: list only  
- `-r`: match by rank only  
- `-t`: match by recent access only  
- `-x`: remove the current directory from the datafile  

示例（EXAMPLES）：

- `z foo`: cd to most frecent dir matching foo  
- `z foo bar`: cd to most frecent dir matching foo, then bar  
- `z -r foo`: cd to highest ranked dir matching foo  
- `z -t foo`: cd to most recently accessed dir matching foo  
- `z -l foo`: list all dirs matching foo (by frecency)  

输入 `z -h` 查看命令参数：

```Shell
[MBP-FAN:~]
[faner]% z -h
z [-cehlrtx] args
```

输入 `z -l` 查看最近访问的高频文件夹列表：

```Shell
[MBP-FAN:~] # 类似 dirs -v
[faner]% z -l
0.5        /Users/faner/.oh-my-zsh/plugins
1.5        /Users/faner/.oh-my-zsh/plugins/colorize
3          /Users/faner/Downloads
4          /Users/faner/Projects/git
14         /Users/faner/Projects/git/Utilities&Usages/SCM
20         /Users/faner/.oh-my-zsh/custom
20         /Users/faner/.oh-my-zsh/custom/plugins
28         /Users/faner/Projects/git/softwareConfig
36         /Users/faner/.oh-my-zsh/custom/scripts
42         /Users/faner/Projects/git/web
236        /Users/faner/.oh-my-zsh
```

#### jump

The [jump](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/jump) plugin allows to easily jump around the file system by manually adding marks. Those marks are stored as symbolic links in the directory `$MARKPATH` (default `$HOME/.marks`)

- `jump FOO`: jump to a mark named FOO  
- `mark FOO`: create a mark named FOO  
- `unmark FOO`: delete a mark  
- `marks`: lists all marks  

| Command            | Description                                                 |
| :----------------- | :---------------------------------------------------------- |
| `jump <mark-name>`   | Jump to the given mark                                      |
| `mark [mark-name]`   | Create a mark with the given name or with the name of the current directory if none is provided |
| `unmark <mark-name>` | Remove the given mark                                       |
| `marks`              | List the existing marks and the directories they point to   |

相关插件：

1. [scd](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/scd)：smart change of directory。

> Define `scd` shell function for changing to any directory with a few keystrokes.

> `scd` keeps history of the visited directories, which serves as an index of the known paths. The **directory index** is updated after every `cd` command in the shell and can be also filled manually by running `scd -a`.

2. [pj](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pj)：Set `$PROJECT_PATHS` in your `~/.zshrc`。

> The `pj` plugin (short for Project Jump) allows you to define several folders where you store your projects, so that you can jump there directly by just using the name of the project directory.

#### wd

[wd](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/wd) (warp directory) lets you jump to custom directories in zsh, without using `cd`. Why? Because `cd` seems inefficient when the folder is frequently visited or has a long path.

**warp point** 类似 *scd directory index*、*jump mark*，但 **wd** 支持更强大的跳转点支持。

查看 wd 版本：

```Shell
@MBP-FAN ➜ ~  wd -v
wd version 0.4.6
```

查看 wd 命令帮助：

```Shell
@MBP-FAN ➜ ~  wd help
Usage: wd [command] [point]

Commands:
    <point>         Warps to the directory specified by the warp point
    <point> <path>  Warps to the directory specified by the warp point with path appended
    add <point>     Adds the current working directory to your warp points
    add             Adds the current working directory to your warp points with current directory's name
    rm <point>      Removes the given warp point
    rm              Removes the given warp point with current directory's name
    show <point>    Print path to given warp point
    show            Print warp points to current directory
    list            Print all stored warp points
    ls  <point>     Show files from given warp point (ls)
    path <point>    Show the path to given warp point (pwd)
    clean           Remove points warping to nonexistent directories (will prompt unless --force is used)

    -v | --version  Print version
    -d | --debug    Exit after execution with exit codes (for testing)
    -c | --config   Specify config file (default ~/.warprc)
    -q | --quiet    Suppress all output
    -f | --force    Allows overwriting without warning (for add & clean)

    help            Show this extremely helpful text
```

常用命令：

- `wd add foo`: Add warp point to current working directory  

    > If a warp point with the same name exists, use `add!` to overwrite it.  
    > You can **omit** point name to use the <u>current directory's name</u> instead.  

- `wd foo`: warp to `foo` from an other directory (not necessarily)  
- `wd ..`/`wd ...`: warp back to previous directory with dot syntax, and so on.  
- `wd rm foo`: Remove warp point test point.  

    > You can **omit** point name to use the <u>current directory's name</u> instead.

- `wd list`: List all warp points (stored in `$HOME/.warprc`).  
- `wd ls foo`: List files in given warp point.  
- `wd path foo` Show path of given warp point.  
- `wd show`: List warp points to current directory, or optionally, path to given warp point.  
- `wd clean`: Remove warp points to non-existent directories.  

相关插件：[fasd](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fasd)

- Fasd (pronounced similar to "fast") is a command-line productivity booster. Fasd offers quick access to files and directories for POSIX shells.

#### navigation-tools

[ohmyzsh/plugins/zsh-navigation-tools/](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/zsh-navigation-tools)

Set of tools like `n-history` – multi-word history searcher, `n-cd` – directory bookmark manager, `n-kill` – `htop` like kill utility, and more. Based on `n-list`, a tool generating selectable curses-based list of elements that has access to current `Zsh` session, i.e. has broad capabilities to work together with it. 

### system

#### man

The [man](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/man) plugin adds a shortcut to insert man before the previous command.

#### aliases

With lots of 3rd-party amazing aliases installed, this plugin helps list the shortcuts that are currently available based on the plugins you have enabled.

Usage:

- `acs`: show all aliases by group.  
- `acs <keyword>`: filter aliases by `<keyword>` and highlight.  

还有一个类似插件 [alias-finder](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/alias-finder)。

zsh 默认定义了以下 alias：

- alias go="git-open"  
- alias cp="cp -i"  
- alias rm="trash" # rmtrash  

以下插件定义了一些常用的 alias 替身命令，可供参考。

- [lol](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/lol)  
- [brew](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/brew)  
- [singlechar](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/singlechar)  
- [common-aliases](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/common-aliases)  
- [systemadmin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/systemadmin)  

#### history

[history](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/history): Provides a couple of convenient aliases for using the `history` command to examine your command line history.

| Alias         | Description                                                 |
| :------------ | :---------------------------------------------------------- |
| `h`           | history	Prints your command history                       |
| `hs`          | history | grep	Use grep to search your command history   |
| `hsi`         | history | grep -i	Use grep to do a case-insensitive search of your command history |

**相关插件**：[history-substring-search](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/history-substring-search)

This is a clean-room implementation of the [Fish shell](https://fishshell.com)'s history search feature, where you can type in any part of any previously entered command and press the UP and DOWN arrow keys to cycle through the matching commands.  
You can also use <kbd>K</kbd> and <kbd>J</kbd> in VI mode or `^P` and `^N` in EMACS mode for the same.

类似第三方插件：[zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search): ZSH port of Fish history search (up arrow)

#### colorized

[colorize/](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/colorize): Plugin for **`highlighting file content`**

With this plugin you can syntax-highlight file contents of over 300 supported languages and other text formats.

Colorize will highlight the content based on the filename extension. If it can't find a syntax-highlighting method for a given extension, it will try to find one by looking at the file contents. If no highlight method is found it will just cat the file normally, without syntax highlighting.

> 基于 `pygmentize`，需要执行 `pip3 search Pygments` 安装 **Pygments** 插件。

**相关插件**：[colored-man-pages](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/colored-man-pages)

`colored-man-pages`：man page 页面彩色化（adds colors to man pages）。

- [Manpages 彩色版](https://linuxtoy.org/archives/colored-manpages.html)  
- [让bash的man看上去多姿多彩](https://blog.csdn.net/rainysia/article/details/8673199)  

#### fancy-ctrl-z

[ohmyzsh/plugins/fancy-ctrl-z/](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fancy-ctrl-z)

Use Ctrl-Z to switch back to Vim

I frequently need to execute random commands in my shell. To achieve it I pause Vim by pressing `Ctrl-z`, type command and press `fg` to switch back to Vim. The `fg` part really hurts me. I just wanted to hit `Ctrl-z` once again to get back to Vim. I could not find a solution, so I developed one on my own that works wonderfully with ZSH.

#### command-not-found

This plugin uses the [command-not-found](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/command-not-found) package for zsh to provide suggested packages to be installed if a command cannot be found.

类似 ubuntu bash shell 下执行未知命令的以下提示：

```Shell
pifan@rpi4b-ubuntu:~$ ifconfig
Command 'ifconfig' not found, but can be installed with:
sudo apt install net-tools
```

#### thefuck

[The Fuck](https://github.com/nvbn/thefuck) [plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/thefuck) — magnificent app which corrects your previous console command.

首先需要执行 `pip install thefuck` 或 `brew install thefuck` 安装 `thefuck` 校准工具。
启用该插件后，输入 `fuck` 或连按两次 `ESC` 可纠正上次控制台输入的错误并执行。

- Usage: Press `ESC` twice to correct previous console command.  
- Notes: `Esc-Esc` key binding conflicts with [sudo](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sudo) plugin.  

#### systemadmin

The [systemadmin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/systemadmin) plugin adds a series of aliases and functions which make a System Administrator's life easier.

其他相关插件：

- [shell-proxy](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/shell-proxy): a pure user-space program, shell-proxy setter, written in Python3 and Zsh.  
- [ssh-agent](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ssh-agent): starts automatically `ssh-agent` to set up and load whichever credentials you want for ssh connections.  

### utilities

#### copypath

[copypath](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copypath): Copies the path of given directory or file to the system clipboard.

- `copypath`: copies the absolute path of the current directory.
- `copypath <file_or_directory>`: copies the absolute path of the given file.

相关插件：[copyfile](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copyfile): Puts the contents of a file in your system clipboard so you can paste it anywhere.

run the command `copyfile <filename>` to copy the file named filename.

#### extract(x)

The [extract](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/extract) plugin defines a function called `extract` that extracts the archive file you pass it, and it supports a wide variety of archive filetypes.

This way you don't have to know what specific command extracts a file, you just do `extract <filename>` and the function takes care of the rest.

**`extract`** 是万能解压命令插件，一条 **extract** 命令搞定常见格式压缩包的解压，无需记忆 tar 等命令的复杂解压参数。

```Shell
$ x
Usage: extract [-option] [file ...]

Options:
    -r, --remove    Remove archive after unpacking.
```

#### encode64

[encode64](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/encode64): Alias plugin for encoding or decoding using base64 command.

| Function    | Alias  | Description   |
| :---------- | :----- | :------------ |
| encode64    | `e64`    | Encodes given data to base64      |
| decode64    | `d64`    | Decodes given data from base64    |

Base64 编解码快捷命令：

- alias e64=encode64  
- alias d64=decode64  

相关插件：[urltools](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/urltools): provides two aliases to URL-encode and URL-decode strings.

| Command       | Description                  |
| :------------ | :--------------------------- |
| `urlencode`   | URL-encodes the given string |
| `urldecode`   | URL-decodes the given string |

#### jsontools

[jsontools](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/jsontools): Handy command line tools for dealing with json data.

- **pp_json** - pretty prints json  
- **is_json** - returns true if valid json; false otherwise  
- **urlencode_json** - returns a url encoded string for the given json  
- **urldecode_json** - returns decoded json for the given url encoded string  

Usage is simple...just take your json data and pipe it into the appropriate jsontool.

```Shell
<json data> | <jsontools tool>
```

#### web-search

The [web-search](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/web-search) plugin adds aliases for searching with Google, Wiki, Bing, YouTube and other popular services.

web_search from terminal：直接在命令行发起搜索。

- alias bing='web_search bing'
- alias google='web_search google'
- alias yahoo='web_search yahoo'
- alias ddg='web_search duckduckgo'
- alias sp='web_search startpage'
- alias yandex='web_search yandex'
- alias github='web_search github'
- alias baidu='web_search baidu'
- alias ecosia='web_search ecosia'
- alias goodreads='web_search goodreads'
- alias qwant='web_search qwant'

**搜索示例**：`google oh-my-zsh`、 `bing zsh plugins`、 `baidu zsh 插件`


### editor

#### sublime

[sublime](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/sublime): Plugin for [Sublime Text](https://www.sublimetext.com/), a cross platform text and code editor, available for Linux, macOS, and Windows.

- `st`: launch Sublime Text  
- `stt`: equivalent to `st .`, opening the current folder in Sublime Text  
- `sst`: like `sudo st`, opening the file or folder in Sublime Text. Useful for editing system protected files.  

#### vscode

The [vscode](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/vscode) plugin provides useful aliases to simplify the interaction between the command line and VS Code or VSCodium editor.

Common aliases

| Alias                   | Command                        | Description                                                                                                 |
| ----------------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| vsc                     | code .                         | Open the current folder in VS code                                                                          |
| vsca `dir`              | code --add `dir`               | Add folder(s) to the last active window                                                                     |
| vscd `file` `file`      | code --diff `file` `file`      | Compare two files with each other.                                                                          |
| vscg `file:line[:char]` | code --goto `file:line[:char]` | Open a file at the path on the specified line and character position.                                       |
| vscn                    | code --new-window              | Force to open a new window.                                                                                 |
| vscr                    | code --reuse-window            | Force to open a file or folder in the last active window.                                                   |
| vscw                    | code --wait                    | Wait for the files to be closed before returning.                                                           |
| vscu `dir`              | code --user-data-dir `dir`     | Specifies the directory that user data is kept in. Can be used to open multiple distinct instances of Code. |

- `vsc`：相当于 `code .`，新开 vscode 窗口打开当前工作目录。  
- `vscn`：相当于 `code -n`，新开 vscode 窗口，其后可接 `.`、`file` 或 `folder`。  
- `vscr`：相当于 `code -r`，复用（覆盖）最后一个活跃窗口，其后可接 `.`、`file` 或 `folder`。  
- `vscd`：相当于 `code -d`，在最后一个活跃窗口打开文件对比。  

#### marked2

[marked2](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/marked2): Plugin for [Marked 2](http://marked2app.com), a previewer for Markdown files on Mac OS X 

- If `marked` is called without an argument, open Marked  
- If `marked` is passed a file, open it in Marked  

### develop

#### git

The [git](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git) plugin provides many aliases and a few useful functions.

See the [wiki](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugin:git) for a list of aliases and functions provided by the plugin.

`git` 插件提供了一系列的命令快捷缩写关联（Alias for Commands），这里就不一一列举，需要时可查询在线 wiki。

这里仅列出一些 Functions：

| Command                  | Description                             |
| ------------------------ | --------------------------------------- |
| `grename <old> <new>`    | Rename old branch to new, including in origin remote |
| `current_branch`         | Return the name of the current branch |
| `git_current_user_name`  | Returns the user.name config value |
| `git_current_user_email` | Returns the user.email config value |
| `git_main_branch`        | Returns the name of the main branch: main if it exists, master otherwise |
| `git_develop_branch`     | Returns the name of the develop branch: dev, devel, development if they exist, develop otherwise |

其他相关插件：

- [repo](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/repo)  
- [gitignore](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gitignore)  
- [git-prompt](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-prompt)  
- [git-lfs](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-lfs)  
- [git-flow](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-flow)  
- [git-flow-avh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-flow-avh)  
- [github](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/github)  
- [git-hubflow](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-hubflow)  

#### adb

[ohmyzsh/plugins/adb/](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/adb)

- Adds autocomplete options for all adb commands.  
- Add autocomplete for `adb -s`  

相关插件：[ant](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ant)。

#### httpie

The [httpie](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/httpie) plugin adds completion for [HTTPie](https://httpie.org/), which is a command line HTTP client, a user-friendly cURL replacement.

#### nvm

The [nvm](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nvm) plugin adds autocompletions for [nvm](https://github.com/nvm-sh/nvm) — a Node.js version manager. It also automatically sources nvm, so you don't need to do it manually in your `.zshrc`.

The [node](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/node) plugin adds `node-docs` function that opens specific section in [Node.js](https://nodejs.org/) documentation (depending on the installed version).

> `node-docs` 命令快速打开当前版本的 Node 帮助文档主页 —— Node.js v10.9.0 Documentation。

The [npm](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/npm) plugin provides completion as well as adding many useful aliases.

其他相关插件：

- [fnm](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fnm)  
- [deno](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/deno)  

#### python

- [autoenv](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/autoenv)  
- [autopep8](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/autopep8)  
- [pep8](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pep8)  
- [pyenv](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pyenv)  
- [pylint](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pylint)  
- [virtualenv](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenv)  
- [virtualenvwrapper](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenvwrapper)  

#### flutter

The [flutter](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/flutter) plugin provides completion and useful aliases.

## custom

第三方 **`plugin.zsh`** 插件的 安装、启用/禁用、卸载 可参考 `git-open`。

- `git clone https://github.com/paulirish/git-open.git $ZSH_CUSTOM/plugins/git-open`  
- `cd $ZSH_CUSTOM/plugins && git clone https://github.com/paulirish/git-open.git`  

第三方 **`zsh`** 插件的 安装、启用/禁用、卸载 可参考 `vimman`。

1. 克隆 git repo 到本地目录（`$ZSH_CUSTOM/scripts/`）：

	- `git clone https://github.com/yonchu/vimman.git $ZSH_CUSTOM/scripts/vimman`

2. 然后再在 `~/.zshrc` 中 source 脚本，重启 zsh 生效：

	- `source ~/.oh-my-zsh/custom/scripts/vimman/vimman.zsh`

### ls

[ls](https://github.com/zpm-zsh/ls): It improves the output of ls, and adds the following aliases:

- `l` - similar to ls  
- `la` - similar to ls, but show all files  
- `lsd` - show only directories  
- `ll` - show files line by line  

### vimman

[vimman](https://github.com/yonchu/vimman) - View vim plugin manuals (help) like man in zsh

vimehelp makes opening the vim help quickly in zsh.

git clone 到 `$ZSH_CUSTOM/scripts/vimman` 后，在 `~/.zshrc` 中 source 该 zsh 脚本重启生效。

示例：**`vimman number`** 查看 `number` 相关帮助主题：

```Shell
MBP-FAN ~ » vimman number
:help number
```

### git-open

[git-open](https://github.com/paulirish/git-open): Type `git open` to open the repo website (GitHub, GitLab, Bitbucket) in your browser.

> 进入 git 分支目录，执行 `git open` 或 `git-open` 即可调起浏览器打开 remote 仓库。

将插件从 git clone 到 `$ZSH_CUSTOM/plugins/git-open` 即可完成安装：

```Shell
faner on MBP-FAN in ~
$ git clone https://github.com/paulirish/git-open.git $ZSH_CUSTOM/plugins/git-open
Cloning into '/Users/faner/.oh-my-zsh/custom/plugins/git-open'...
remote: Counting objects: 651, done.
remote: Compressing objects: 100% (13/13), done.
remote: Total 651 (delta 5), reused 10 (delta 3), pack-reused 635
Receiving objects: 100% (651/651), 151.67 KiB | 72.00 KiB/s, done.
Resolving deltas: 100% (310/310), done.
Checking connectivity... done.
```

下载安装后配置到 `~/.zshrc` 的 **plugins** 中，再执行 `source .zshrc` 即可生效。
在 `~/.zshrc` 的 **plugins** 中移除该插件即可禁用，当然也可执行 `rm -rf $ZSH_CUSTOM/plugins/git-open` 移除卸载。

### zsh-256color

[zsh-256color](https://github.com/chrissicool/zsh-256color): This ZSH plugin enhances the terminal environment with 256 colors.

It looks at the chosen `TERM` environment variable and sees if there is respective (n-)curses' termcap/terminfo descriptors for 256 colors available.  
The result is a multicolor terminal, if available.  

### zsh-autosuggestions

[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): Fish-like fast/unobtrusive autosuggestions for zsh.

It suggests commands as you type based on history and completions.

在 zsh 中，输入部分单词，输入 **tab** 自动补齐或列举所有可能选项：

```Shell
# git 空格 tab 列举建议选项
faner on MBP-FAN in ~
$ git
zsh: do you wish to see all 148 possibilities (148 lines)?
```

通过上箭头 <kbd>↑</kbd> 可回溯历史匹配命令，有点类似 bash completion 的 reverse-search-history (C-r：`^r`)。

---

**`zsh-autosuggestions`** 插件基于历史输入命令提供智能匹配建议。

[Fish](http://fishshell.com/)-like fast/unobtrusive autosuggestions for zsh.  
It suggests commands as you type, based on command history.  

执行 git clone 命令将插件下载到 `$ZSH_CUSTOM/plugins/zsh-autosuggestions` 目录中，再在 `~/.zshrc` 中配置启用。

通过右箭头 <kbd>→</kbd> 可选中当前建议匹配，再按回车键或 C-j（`^j`）执行，或按 C-g（`^g`）放弃。

另外，同类插件推荐 [Incremental completion on zsh](https://mimosa-pudica.net/zsh-incremental.html)。

### zsh-syntax-highlighting

[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting): Fish shell-like syntax highlighting for Zsh.

- This package provides syntax highlighting for the shell zsh.  
- It enables highlighting of commands whilst they are typed at a zsh prompt into an interactive terminal.  
- This helps in reviewing commands before running them, particularly in catching syntax errors.  

执行 git clone 命令将插件下载到 `$ZSH_CUSTOM/plugins/zsh-syntax-highlighting` 目录中，再添加到 `~/.zshrc` 中的 plugins 中启用。

相关：[zsh-url-highlighter](https://github.com/ascii-soup/zsh-url-highlighter)  

## plugins

以下是 macOS zsh 配置文件 `~/.zshrc` 中启用的 plugins 插件备忘：

```Shell
plugins=(
    #---------macOS
    macos
    brew
    pod
    xcode
    #---------nav
    # zsh-interactive-cd # requires fzf
    # last-working-dir # lwd
    # dirhistory
    dircycle # ^⇧←/→
    z
    wd
    #---------sys
    # man # Esc + man: man prev command
    aliases # acs command
    colored-man-pages
    # sudo # esc twice to exec prev command with sudo
    # vi-mode # increase vi-like zsh functionality
    # timer # perf display command's execution time
    fancy-ctrl-z # Ctrl-Z to switch back to Vim
    command-not-found # provide suggested packages
    thefuck # esc twice to correct prev command
    # systemadmin # a series of aliases and functions
    # shell-proxy # shell-proxy setter
    ssh-agent
    #---------utility
    copypath
    copyfile
    extract # x command
    encode64
    urltools # urlencode, urldecode
    jsontools
    web-search
    #---------git
    git
    gitignore
    git-prompt
    #---------develop
    adb
    vscode
    # marked2
    nvm # adds autocompletions for nvm
    fnm # Fast Node Manager, alternative for nvm
    node # node-docs
    npm # npm aliases
    # yarn # yarnpkg.com, alternative for npm
    jenv # Java version manager
    python # python aliases
    # flutter # provides completion and useful aliases
    #---------custom 
    # ls # improves the output, adds several aliases
    git-open
    iterm2colors    # manage iterm2's color scheme
    zsh-tab-colors  # automatically changes iTerm tab color
    zsh-256color
    zsh-autosuggestions
    zsh-syntax-highlighting)
```

### manager

[ohmyzsh/plugins/wd/](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/wd) Setup 提供了几种常见 zsh 插件管理器中的安装方式。  
[zpm-zsh / ls](https://github.com/zpm-zsh/ls): How to install 提供了几种常见 zsh 插件管理器中的安装方式。  

除了 oh-my-zsh 自带的插件下载启用机制，还有以下几种可选 zsh plugin manager：

- [Antigen](https://github.com/zsh-users/antigen)  
- [Antibody](https://github.com/getantibody/antibody)  
- [prezto](https://github.com/sorin-ionescu/prezto)  
- [zplug](https://github.com/zplug/zplug)  
- [zpm](https://github.com/zpm-zsh/zpm)  
