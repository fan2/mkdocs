---
title: Linux Shell Program - function
authors:
  - xman
date:
    created: 2019-11-06T09:40:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之条件判断表达式。

<!-- more -->

## if

### if-then

最基本的结构化命令就是 if-then 语句。

`if-then` 语句格式如下:

```Shell
if command
then
    commands
fi
```

如果该命令的退出状态码是0（该命令成功运行），位于 then 部分的命令就会被执行。
如果该命令的退出状态码是其他非0值，then 部分的命令就不会被执行，而是继续执行脚本中的下一个命令。

`fi` 语句用来表示 `if-then` 语句到此结束，类似 HTML 语言中的闭合标签。

---

你可能看到过 if-then 语句的另一种形式：

```Shell
if command; then
    commands
fi
```

通过把分号放在待求值的命令尾部，就可以将 then 语句写在同一行中了，这样看起来更像其他编程语言中的 if-then 语句。

也可以将整个 `if ... them ... fi` 写到一行内，方便在命令行中单行快捷测试：

```Shell
if [ -n "$HOME" ]; then echo "HOME is defined"; fi
if [ -z "$ZDOTDIR" ]; then echo "ZDOTDIR not defined"; fi
```

### if-then-else

当 if 语句中的命令返回退出状态码0时，then 部分中的命令会被执行，这跟普通的 if-then 语句一样。
当 if 语句中的命令返回非零退出状态码时，bash shell 会执行 else 部分的命令。

```
if command
then
    commands
else
    commands
fi
```

### elif

可以使用 else 部分的另一种形式：`elif`。
elif 使用另一个 if-then 语句延续 else 部分，这样就不用再书写多个 if-then 语句了。

```
if command1
then
    commands
elif command2
then
    more commands
fi
```

elif 语句行提供了另一个要测试的命令，这类似于原始的 if 语句行。
如果 elif 后命令的退出状态码是0，则 bash 会执行第二个 then 语句部分的命令。
使用这种嵌套方法，代码更清晰，逻辑更易懂。

## case

你会经常发现自己在尝试计算一个变量的值，在一组可能的值中寻找特定值。
在这种情形下，你不得不写出很长的 if-then-else 语句。
elif 语句继续 if-then 检查，为比较变量寻找特定的值。

有了 case 命令，就不需要再写出所有的 elif 语句来不停地检查同一个变量的值了。
**case** 命令会采用列表格式来检查单个变量的多个可能取值，类似枚举命中测试。

```Shell
case variable in
    pattern1 | pattern2) commands1;;
    pattern3) commands2;;
    *) default commands;;
esac
```

case 命令会将指定的变量与不同模式进行比较，可以通过竖线操作符在一行中并列多个匹配模式。模式匹配后会执行右括号后面的命令。

最后一行的星号通配所有与已知模式不匹配的值，类似其他编程语言中的 default fallbak 分支。

### demo

1. 以下为 ubuntu 的 bash 配置文件 `~/.bashrc` 中的内容：

```Shell
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
```

2. 在 [ohmyzsh/plugins/extract/extract.plugin.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/extract/extract.plugin.zsh) 中基于 case 判断各种压缩包文件的后缀，调用不同的系统命令进行解压。

3. 在 [How to detect the OS from a Bash script?](https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script) 中，基于 case 对 `$OSTYPE` 进行匹配，从而判断操作系统类型。

```Shell
# https://stackoverflow.com/a/18434831
function get_ostype_2 {
    local platform2='unknown'
    case "$OSTYPE" in
    linux*)
        platform2='linux'
        ;;
    darwin*)
        platform2='macos'
        ;;
    bsd*)
        platform2='bsd'
        ;;
    solaris*)
        platform2='solaris'
        ;;
    msys*)
        platform2='win(msys)'
        ;;
    cygwin*)
        platform2='win(cygwin)'
        ;;
    *) ;;
    esac
    echo "$platform2"
}

# https://stackoverflow.com/a/29239609
if_nix() {
    case "$OSTYPE" in
    *linux* | *hurd* | *msys* | *cygwin* | *sua* | *interix*) sys="gnu" ;;
    *bsd* | *darwin*) sys="bsd" ;;
    *sunos* | *solaris* | *indiana* | *illumos* | *smartos*) sys="sun" ;;
    esac
    [[ "${sys}" == "$1" ]]
}
```