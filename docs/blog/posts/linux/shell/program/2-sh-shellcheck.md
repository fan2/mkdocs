---
title: Linux Shell Program - shellcheck
authors:
  - xman
date:
    created: 2019-11-06T09:00:00
    updated: 2026-01-31T09:00:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 脚本格式化工具 `shfmt` 及语法检查工具 `shellcheck`。

<!-- more -->

[Google Shell 风格指南](https://zh-google-styleguide.readthedocs.io/en/latest/google-shell-styleguide/contents/)

## Android Studio

Android Studio 打开 sh 脚本时，会建议安装 [Shell Script](https://plugins.jetbrains.com/plugin/13122-shell-script) 插件。

Integration with external tools:

- [ShellCheck](https://github.com/koalaman/shellcheck),  
- [Shfmt](https://github.com/mvdan/sh),  
- [Explainshell](https://explainshell.com/)  

### Reformat

Android Studio 通过菜单 Code - Reformat 可格式化当前文档，macOS 下的 [键盘快捷键](https://developer.android.com/studio/intro/keyboard-shortcuts) 为 ⌘⌥L。
执行格式化当前sh脚本时，会查找当前语言的格式化工具，下载安装 shell script formatter - shfmt。

Shell Script 插件设置的默认缩进为2个空格，可考虑对齐 vscode 等编辑器 [use 4-space wide tab](https://stackoverflow.com/questions/61578404/how-to-use-4-space-wide-tab-character-in-android-studio)，具体到 Pref Settings -> Editor -> Code Style -> Shell Script 修改 Tab Size 和 Indent 为 4。

## vscode

macOS 下先用 brew 安装 shfmt 和 shellcheck 命令行工具：

- [shfmt](https://github.com/mvdan/sh): Autoformat shell script source code  
    - [shfmt documentation](https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd)

- [shellcheck](https://www.shellcheck.net/): Static analysis and lint tool, for (ba)sh scripts  
    - [ShellCheck wiki](https://github.com/koalaman/shellcheck/wiki/)

执行 `brew info shfmt` 查看 shfmt 介绍，再执行 `brew install shfmt` 安装 shfmt。

```bash
$ brew info shfmt
==> shfmt ✔: stable 3.12.0 (bottled), HEAD
Autoformat shell script source code
https://github.com/mvdan/sh

$ brew install shfmt
```

执行 `brew info shellcheck` 查看 shellcheck 介绍，再执行 `brew install shellcheck` 安装 shellcheck。

```bash
$ brew info shellcheck
==> shellcheck ✔: stable 0.11.0 (bottled), HEAD
Static analysis and lint tool, for (ba)sh scripts
https://www.shellcheck.net/

$ brew install shellcheck
```

然后，在 vscode 中搜索安装 shellcheck 和 shfmt 插件：

- [shfmt](https://marketplace.visualstudio.com/items?itemName=mkhl.shfmt)  
- [shellcheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)  

### shfmt

在 vscode 中，打开编辑 sh 脚本文件，可通过 `⇧⌘P` 调起控制面板执行 Format Document 命令（快捷键 `⇧⌥F`） 调用 *shfmt* 格式化当前文档。

执行 `shfmt -h` 查看 shfmt 帮助信息，执行 `man shfmt` 查看详细文档。

```bash
$ shfmt -h
usage: shfmt [flags] [path ...]

shfmt formats shell programs. If the only argument is a dash ('-') or no
arguments are given, standard input will be used. If a given path is a
directory, all shell scripts found under that directory will be used.

Printer options:

  -i,  --indent uint       0 for tabs (default), >0 for number of spaces
  -bn, --binary-next-line  binary ops like && and | may start a line
  -ci, --case-indent       switch cases will be indented
  -sr, --space-redirects   redirect operators will be followed by a space
  -kp, --keep-padding      keep column alignment paddings
  -fn, --func-next-line    function opening braces are placed on a separate line
  -mn, --minify             minify the code to reduce its size (implies -s)

Formatting options can also be read from EditorConfig files; see 'man shfmt'
for a detailed description of the tool's behavior.
For more information and to report bugs, see https://github.com/mvdan/sh.
```

#### executableArgs

在 vscode 控制面板中执行 `Preferences: Open Default Settings (JSON)` 打开默认设置文件，可以看到有3个配置选项：

```json
{
  // shfmt
  // Additional arguments to pass to the shfmt executable
  "shfmt.executableArgs": [],

  // Path to or name of the shfmt executable
  "shfmt.executablePath": "shfmt",

  // Format files marked `ignore` with [EditorConfig](https://editorconfig.org/)? (shfmt itself only ignores them when scanning directories.)
  "shfmt.formatIgnored": true

},
```

可以为 executableArgs 添加一些 Printer options，如：

- `-i 4`: 缩进使用4个空格
- `-bn`: 二元运算符放在新行
- `-ci`: 缩进 case 语句
- `-sr`: 重定向符号后加空格
- `-kp`: 保持缩进

在 vscode 控制面板中执行 `Preferences: Open User Settings (JSON)` 打开用户设置文件，配置 *executableArgs* 参数:

```json
    "shfmt.executableArgs": [
        "-i",
        "4",
        "-bn",
        "-ci",
        "-sr",
        "-kp"
    ]
```

### shellcheck

shellcheck 默认配置了 `"shellcheck.run": "onType"`，编写代码时实时检查。

如果遇到 shellcheck 报错，可以在 [Finding documentation for a check](https://github.com/koalaman/shellcheck/wiki/Checks) 点击查询具体某一个 SC 提示说明文档。

以下是 get_lan_ip.sh 脚本中的部分警告分析。

#### SC2070

```bash
if [ -n $eth_dev ]; then
    ...
fi
```

以上代码片段将报两个警告：

1. [SC2070](https://github.com/koalaman/shellcheck/wiki/SC2070): `-n` doesn't work with unquoted arguments. Quote or use `[[ ]]`.  
2. [SC2086](https://github.com/koalaman/shellcheck/wiki/SC2086): Double quote to prevent globbing and word splitting.  

因为 `eth_dev` 可能未定义（unset），那么此时 $eth_dev 被视为普通字符串，不符合预期。  
根据 ShellCheck 的静态语法警告提示，有两种修复方案：（1）加双引号安全解引用；（2）将单中括号改为双中括号。  

#### SC2181

```bash
        # 判断是否存在有线网口
        local has_eth=false
        networksetup -listallnetworkservices | grep -q 'Ethernet'
        if [ $? -eq 0 ]; then
            has_eth=true
        fi
```

以上代码片段将报警告 [SC2181](https://github.com/koalaman/shellcheck/wiki/SC2181): Check exit code directly with e.g. `if mycmd;`, not indirectly with `$?`.

根据提示，建议不用 `$?` 来判断命令执行状态，而是将命令语句直接放在 if 的 condition 位置：

```bash
        # 判断是否存在有线网口
        local has_eth=false
        if networksetup -listallnetworkservices | grep -q 'Ethernet'; then
            has_eth=true
        fi
```

#### disable

- [Inline ignore messages #145](https://github.com/koalaman/shellcheck/issues/145)  
- [How to suppress irrelevant ShellCheck messages?](https://stackoverflow.com/questions/52659038/how-to-suppress-irrelevant-shellcheck-messages)  

1. 在 get_lan_ip.sh 中引入同目录的脚本 aux_etc.sh，以下相对引入将会报错：

[SC1091](https://github.com/koalaman/shellcheck/wiki/SC1091): Not following: "./aux_etc.sh" was not specified as input (see shellcheck -x).

```bash
# shellcheck source="./aux_etc.sh"
source "$(dirname "$0")"/aux_etc.sh
```

如果确认逻辑无误，可以加一个行禁用规则 SC1091 的 disable 注释，以便忽略警告：

```bash
# shellcheck disable=SC1091
# shellcheck source="./aux_etc.sh"
source "$(dirname "$0")"/aux_etc.sh
```

2. 在工具函数脚本 aux_etc.sh 中，可能有些函数内会定义变量，此时 ShellCheck 会报错：

[SC2034](https://github.com/koalaman/shellcheck/wiki/SC2034): foo appears unused. Verify it or export it.

这些变量非 local、非 export，默认为全局变量，调用方可能会引用这些变量。
此时，我们可以注释禁用规则 SC2034，以便忽略相关警告：

```bash
#!/bin/bash

# shellcheck disable=2034
# shellcheck disable=SC2034

```

也可在一行中忽略多条规则：

```bash

# shellcheck disable=SC1091,SC2034

```
