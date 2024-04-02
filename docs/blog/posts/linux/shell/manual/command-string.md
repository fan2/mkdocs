---
title: Linux Command Strings
authors:
  - xman
date:
    created: 2019-10-28T11:00:00
categories:
    - wiki
    - linux
comments: true
---

Linux command strings, assignment, quoting, substituion, etc.

<!-- more -->

## assign

bash shell 中可通过等号（equality sign）赋值定义变量，右值即使没有引号（单/双）引用，默认视作**字符串**类型。

```Shell
faner@MBP-FAN:~|⇒  testString=define
faner@MBP-FAN:~|⇒  echo $testString
define
```

> 注意：在变量、等号和值之间不能出现空格。

### meta

当没有引号封闭（*unquoted*），遇到 **元字符**（metacharacter） 时，将自动分割为多条分组命令。

关于 bash shell 的元字符，参考 `man 1 bash` 中 DEFINITIONS 部分的定义：

```Shell
DEFINITIONS

metacharacter
 A character that, when unquoted, separates words. One of the following:

| & ; ( ) < > space tab newline
```

以下第一个空格将右值截断，实际有效的赋值命令1为 `testString=define` ，正常有效执行；  
string 为命令2，由于找不到 `string` 命令而提示报错。

```Shell
faner@MBP-FAN:~|⇒  testString=define string in shell command line
zsh: command not found: string
faner@MBP-FAN:~|⇒  echo $testString 
define
```

如果每个分组都为有效可执行命令，一般会依次执行。

> 参考下文的 `test1='test 1' test2='test 2'` 测试用例。  

但以下示例忽略了第一条赋值命令，而只执行了第2条 cd 命令？

```Shell
faner@MBP-FAN:~|⇒  testShellVar=string cd ~/Downloads
faner@MBP-FAN:~/Downloads|⇒  echo $testShellVar

faner@MBP-FAN:~/Downloads|⇒  
```

### escape

另外一种常见写法是利用单反斜杠 `\\` 转义掉空格等元字符含义，显式声明采用原生字符义。

以下对空格进行转义，当做原义使用时，等号右侧不再分割为多条命令，而是当做一整条字符串。

```Shell
faner@MBP-FAN:~|⇒  testString=define\ string\ in\ shell\ command\ line
faner@MBP-FAN:~|⇒  echo $testString
define string in shell command line
```

以下对分号和空格进行转义，当做原义使用时，不再执行 cd 切换目录。

```Shell
faner@MBP-FAN:~|⇒  testShellVar=string\;\ cd\ ~/Downloads
faner@MBP-FAN:~|⇒  echo $testShellVar
string; cd ~/Downloads
```

## QUOTING

除了利用单反斜杠 `\\` 转义掉空格等元字符含义，显式声明采用原生字符义外，一种更普适的方案是**引用**。

通过单引号（`'single_quoting'`）或双引号（`"double_quoting"`）来封闭引用是编程语言中常见的字符串定义方式。

```Shell
QUOTING

Quoting is used to remove the special meaning of certain characters or words to the shell. Quoting can be used to disable special treatment for special characters, to prevent reserved words from being recognized as such, and to prevent parameter expansion.

Each of the metacharacters listed above under DEFINITIONS has special meaning to the shell and must be quoted if it is to represent itself.
```

通过单引号闭包的字符串中的所有字符都采用原义，但是中间不能出现单引号自身，即使采用反斜杠（backslash）也无法转义（escape）。

```Shell
Enclosing characters in single quotes preserves the literal value of each character within the quotes. A single quote may not occur between single quotes, even when preceded by a backslash.
```

通过双引号闭包的字符串中的 $、\`、\\ 等字符将具有特殊意义。

```Shell
Enclosing characters in double quotes preserves the literal value of all characters within the quotes, with the exception of $, `, \, and, when history expansion is enabled, !.
```

### demo

定义包含空格和分号等元字符的字符串：

```Shell
# 单引号定义字符串
pi@raspberrypi:~ $ testString='define string in shell command line'
pi@raspberrypi:~ $ echo $testString 
define string in shell command line

# 双引号重定义字符串
faner@MBP-FAN:~|⇒  testShellVar="string cd ~/Downloads"
faner@MBP-FAN:~|⇒  echo $testShellVar 
string cd ~/Downloads
```

引述包含空格的文件名：

```Shell
# 单引号引用
mv 'a ~file name.txt' another.txt

# 双引号引用
mv "a ~file name.txt" another.txt
```

cd 进入包含空格的目录：

```Shell
faner@MBP-FAN:~|⇒  cd /Applications/Google\ Chrome.app/Contents/MacOS/
# 或将 cd 到的目录路径字符串整体用引号封闭，就无需对空格进行转义。
faner@MBP-FAN:~|⇒  cd "/Applications/Google Chrome.app/Contents/MacOS/"
```

在 `~/.zshrc` 中添加替身命令prefs，以便快捷打开系统偏好设置面板。

```Shell
alias prefs='open /System/Applications/System\ Preferences.app'
# 也可将 open 后面的app路径参数整体用双引号封闭
alias prefs='open "/System/Applications/System Preferences.app"'
```

在 `~/.zshrc` 中添加替身命令chrome，以便快捷打开 Google Chrome 浏览器，注意空格必须加转义。

```Shell
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
```

但是，对于 export 赋值环境变量，如果对右值整体加双引号引用，则其中的空格无需转义。

```Shell
export CHROME_EXECUTABLE=/Applications/Google\ Chrome.app/Contents/MacOS/launch-unsafe.sh
```

### vs. assign

引用一个变量值时，需要使用美元符号；而引用变量来对其进行赋值时不需要使用美元符号。

```Shell
#!/bin/bash
value1=10		#左值赋值
value2=$value1	#右值引用
echo The resulting value is $value2
```

## Command Substitution

shell 脚本中最有用的特性之一就是可以从命令输出中提取信息，并将其赋给变量。把输出赋给变量之后，就可以随意在脚本中使用了。

```
# man bash
   Command Substitution
       Command  substitution allows the output of a command to replace the command name.  There
       are two forms:


              $(command)
       or
              `command`

       Bash performs the expansion by executing command and replacing the command  substitution
       with  the  standard output of the command, with any trailing newlines deleted.  Embedded
       newlines are not deleted, but they may be removed during word  splitting.   The  command
       substitution $(cat file) can be replaced by the equivalent but faster $(< file).

       When the old-style backquote form of substitution is used, backslash retains its literal
       meaning except when followed by $, `, or \.  The first backquote not preceded by a back-
       slash  terminates the command substitution.  When using the $(command) form, all charac-
       ters between the parentheses make up the command; none are treated specially.

       Command substitutions may be nested.  To nest when using the backquoted form, escape the
       inner backquotes with backslashes.

       If  the substitution appears within double quotes, word splitting and pathname expansion
       are not performed on the results.
```

有两种方法可以将命令输出赋给变量：

1. 反引号字符（`）；  
2. $() 格式；  

### $

单引号将其闭包字符串中的 `$` 视作普通字符，不会替代解引用变量值：

```Shell
pi@raspberrypi:~ $ varLANG='env LANG=$LANG'
pi@raspberrypi:~ $ echo $varLANG 
env LANG=$LANG
```

双引号可识别闭包字符串中的特殊字符 `$`，解引用变量值并替换。

```Shell
pi@raspberrypi:~ $ varLC_CTYPE="LC_CTYPE = $LC_CTYPE"
pi@raspberrypi:~ $ echo ${varLC_CTYPE}
LC_CTYPE = UTF-8
```

双引号中若要打印普通的 `$` 符号，可使用反斜杠 `\$` 转义为普通字符。

```Shell
pi@raspberrypi:~ $ varLC_CTYPE="LC_CTYPE = \$LC_CTYPE"
pi@raspberrypi:~ $ echo ${varLC_CTYPE}
LC_CTYPE = $LC_CTYPE
```

在条件测试一节 [test](../program/4-sh-test.md) 中，对于 `[ -n $var ]` 或 `[ -z $var ]` 判空字符串时，如果 var 为未定义（unset）状态，那么 `$var` 会当做普通字符串，而不会解引用，导致 `-n` 测试通过！

> 具体参考 [shellcheck](../program/2-sh-shellcheck.md)，其中会警告 SC2070 和 SC2086。

为了安全对变量的引用进行判空，建议 Apply fix for SC2086 —— **加双引号确保安全解引用**，兼顾变量 unset 的情况。

- [ ] : <s>if [ -n $var ]; then echo "not empty" ; fi</s>  
- [x] : if [ -n "$var" ]; then echo "not empty" ; fi  

#### demo

```Shell
#!/bin/bash

testing=$(date) #命令替换
echo "The date and time are: " $testing #引用变量
```

下面的这个例子，通过命令替换获得当前日期并用它来生成当天的日志文件名。

```Shell
#!/bin/bash

today=$(date +%y%m%d)
ls /usr/bin -al > log.$today
```

以下右值引用中的 `$testPATH` 和 `${testPATH}` 可加双引号。

```Shell
# testPATH 初始值
pi@raspberrypi:~ $ testPATH=/usr/bin:/bin:/usr/sbin:/sbin

# 头部插入
pi@raspberrypi:~ $ testPATH=/usr/local/bin:$testPATH

# 尾部追加
pi@raspberrypi:~ $ testPATH=${testPATH}:/usr/local/sbin
```

以下 [brew 的官网首页](http://brew.sh/index.html) 给出的 Homebrew 安装命令：

```Shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

1. 调用 **curl** 下载 Homebrew 的 安装脚本 [install.rb](https://github.com/Homebrew/install/blob/master/install)  

	> `-f`, --fail: (HTTP)  Fail  silently (no output at all) on server errors.  
	> `-s`, --silent: Silent or quiet mode. Don't show progress meter or  error  messages. Makes  Curl mute.  
	> `-S`, --show-error: When used with -s, --silent, it makes curl show an error message if it fails.  
	> `-L`, --location: (HTTP)  If  the  server  reports  that the requested page has moved to a different location (indicated with a Location: header and a 3XX response code), this  option will  make  curl  redo  the  request  on  the new place.  

2. 调用 **ruby** 执行下载的安装脚本（install.rb）。

	> `-e` 'command': one line of script.  

以下选自 [清华大学开源软件镜像站](https://mirror.tuna.tsinghua.edu.cn/) 的 [Homebrew 镜像使用帮助](https://mirror.tuna.tsinghua.edu.cn/help/homebrew/)：

```Shell
# $(brew --repo) 可加双引号
faner@FAN-MB0:~|⇒  cd $(brew --repo)
faner@FAN-MB0:/usr/local/Homebrew|stable

# $(brew --repo) 可加双引号
⇒  cd $(brew --repo)/Library/Taps/homebrew/homebrew-core
faner@FAN-MB0:/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core|master
⇒  
```

#### secondary

考虑这样一种情形：传入参数 `$1` 为运行模式，mode可能取值 debug、profile、release。
先尝试从对应的配置文件 .env.debug(profile,release) 中读取 AUTH_TOKEN，如果读取不到，再尝试读取环境变量 DEBUG_AUTH_TOKEN（PROFILE_AUTH_TOKEN、RELEASE_AUTH_TOKEN）。

> export DEBUG_AUTH_TOKEN=`****************************************`

如果配置文件中未定义AUTH_TOKEN，首先要将mode（默认为debug）转换为大写的env_mode，再拼接出环境变量名env_token_key（DEBUG_AUTH_TOKEN），然后要读取名为env_token_key的环境变量的值。

如果直接引用 $env_mode_key，则其值为 DEBUG_AUTH_TOKEN。但我们实际，是想读取环境变量 DEBUG_AUTH_TOKEN 的值。
这里需要读取字符串定义的变量的值，实际上这个问题有点类似C语言中的二级指针解引用。

参考 [How to get a variable value if variable name is stored as string?](https://stackoverflow.com/questions/1921279/how-to-get-a-variable-value-if-variable-name-is-stored-as-string)，可以这样进行二级解引用赋值：`eval "env_token=\$$env_token_key"`。

```Shell
    # 配置文件未检测到令牌
    if [ -z "$auth_token" ]; then
        # 尝试读取环境变量 (DEBUG PROFILE RELEASE)_AUTH_TOKEN
        local env_mode=''
        env_mode=$(echo "$mode" | tr '[:lower:]' '[:upper:]')
        local env_token_key="$env_mode"_AUTH_TOKEN
        local env_token=''
        eval "env_token=\$$env_token_key" # string as var name
        if [ -n "$env_token" ]; then
            auth_token=$env_token
        else
            echo -e "\033[1;31m未检测到访问 CODING API 的身份认证信息\033[0m，\033[1m请按以下步骤申请配置：\033[0m"
        fi
    fi
```

### \`

在 shell 命令中，往往需要将其他命令执行结果作为输入信息，此时可使用 “\`command\`” 或 “$(command)” 引用 command 执行结果。

Linux Distributions 都可能拥有多个内核版本，且几乎 distribution 的所有内核版本都不相同。  
若想进入当前内核的模块目录，可以先执行 `uname -r` 获取发行版本信息（-r, --kernel-release），然后 cd 进入目前内核的驱动程序所放位置。

```Shell
pi@raspberrypi:~ $ uname -r
4.9.59-v7+
pi@raspberrypi:~ $ cd /lib/modules/`uname -r`/kernel
pi@raspberrypi:/lib/modules/4.9.59-v7+/kernel $ ls
arch  crypto  drivers  fs  kernel  lib  mm  net  sound
pi@raspberrypi:/lib/modules/4.9.59-v7+/kernel $ ls | wc -l
9
```

以上 \`uname -r\` 可替换为 `$(uname -r)` 或 `"$(uname -r)"`。

1. 先执行反单引号内的命令 `uname -r` 获取内核版本为 `4.9.59-v7+`；  
2. 将上述结果代入 cd 命令的目录中，得到实际命令 `/lib/modules/4.9.59-v7+/kernel`。  

鉴于反单引号容易打错或弄错，建议使用 **`$(uname -r)`** 这种解引用格式。

相比反引号，`$()` 可以区分左右，因此支持嵌套。

---

以下为查看和复位（reset） `brew --repo` 的 git url 信息：

```
git -C `brew --repo` remote get-url origin

git -C "$(brew --repo)" remote set-url origin https://github.com/Homebrew/brew.git
git -C "$(brew --repo homebrew/core)" remote set-url origin https://github.com/Homebrew/homebrew-core.git
git -C "$(brew --repo homebrew/cask)" remote set-url origin https://github.com/Homebrew/homebrew-cask.git

brew update
```
