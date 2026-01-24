---
draft: true
title: Linux Shell Program - eval & exec
authors:
  - xman
date:
    created: 2019-11-06T10:50:00
    updated: 2026-01-22T18:50:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之执行 eval & exec。

<!-- more -->

参考 man bash - SHELL BUILTIN COMMANDS.

## eval: 动态命令构造器

```Shell
eval [arg ...]

The args are read and concatenated together into a single command. This command is then read and executed by the shell, and its exit status is returned as the value of eval. If there are no args, or only null arguments, eval returns 0.
```

`eval` 命令会执行两步操作：首先进行变量替换等操作，然后将结果作为一个完整的命令交给 Shell 执行。这个“二次解析”的特性，让它非常适合处理动态生成的命令。

### 动态变量赋值

当变量名本身也是变量时（间接引用），`eval` 就派上用场了。

```bash
# 假设变量名是动态生成的
var_name="username"
value="alice"
# 使用 eval 实现 username="alice"
eval "$var_name=\$value"
echo $username
# 输出：alice
```

### 执行包含特殊字符的命令

如果文件路径字符串变量中包含波浪线 `~` ，当读取文件路径时可能未展开替换导致报错，但是使用 `eval` 可以二次解析。

以下是正常的赋值，不带引号时波浪线 `~` 会展开替换为家目录（$HOME）的值：

```bash
# expands the tilde to $HOME/.zshrc before storing it
$ conf=~/.zshrc
# will work correctly
$ source $conf
```

如果使用引号将波浪线表达式封起，则无法应用展开(tilde expansion)，导致报错：

```bash
# Single quotes prevent tilde expansion, it's stored as a literal string
$ conf='~/.zshrc'
# source doesn't perform tilde expansion
$ source $conf
source: no such file or directory: ~/.zshrc
```

如果改成 `eval "source $conf"` 则成功执行，因为 `eval` 使得命令被重新解析了两次，这样波浪号展开就能生效。

1. source $conf - 直接执行时：

    - Shell 先进行变量展开：`$conf` → `~/.zshrc`
    - 然后执行 `source ~/.zshrc`，但此时 `~` 已经是字面字符串，不会被展开

2. eval "source $conf" - 使用 eval 时：

    - 第一次解析：`$conf` → `~/.zshrc`，命令变成字符串 `source ~/.zshrc`
    - `eval` 将这个字符串作为新命令再次解析执行时，先将 `~` 展开解析为 `/Users/faner` 再执行命令

简单来说，`eval` 触发了额外一轮 shell 解析，让波浪号展开得以执行。这是因为波浪号展开发生在 shell 解析阶段，而变量展开之后的字符串不会再次触发波浪号展开——除非用 `eval` 重新解析。

---

如果命令存储在变量中且包含管道、重定向等符号，直接执行变量会出错，而 `eval` 可以正确解析。

```bash
# 一个包含管道的复杂命令
cmd="ls -l | grep '\.txt$'"
# 直接执行 $cmd 会失败，因为管道符不会被解析
# 使用 eval 则可以正确执行
eval $cmd
```

### 从配置文件动态设置变量

结合循环，可以优雅地从配置文件中读取并设置变量。

```bash
# 假设 file 内容为：NAME Zhang AGE 20
while read KEY VALUE; do
    eval "$KEY=\"$VALUE\""
done < file
echo "$NAME is $AGE years old."
# 输出：Zhang is 20 years old.
```

**安全警告**：`eval` 会执行任意字符串，如果内容来自不可信的用户输入，可能带来严重安全风险（如命令注入），务必谨慎使用！

## exec: 进程替换与重定向专家

```Shell
exec [−cl] [−a name] [command [arguments]]

If command is specied, it replaces the shell. No new process is created. The arguments become the arguments to command. If the −l option is supplied, the shell places a dash at the beginning of the zeroth arg passed to command. This is what login(1) does. The −c option causes command to be executed with an empty environment. If −a is supplied, the shell passes name as the zeroth argument to the executed command. If command cannot be executed for some reason, a non-interactive shell exits, unless the shell option execfail is enabled, in which case it returns failure. An interactive shell returns failure if the ﬁle cannot be executed. If command is not speciﬁed, any redirections take effect in the current shell, and the return status is 0. If there is a redirection error, the return status is 1.
```

`exec` 的核心在于“替换”，当用它来执行命令时，它会用该命令替换当前的 Shell 进程，从而不创建新的子进程。

### 在脚本中启动最终程序

在脚本末尾使用 `exec` 启动主程序，可以节省一个进程资源，并且主程序继承当前 Shell 的 PID。

```bash
#!/bin/bash
# ... 一些准备工作 ...
# 用主程序替换当前 shell
exec /usr/bin/my-daemon --config config.file
# 这行之后的代码永远不会执行
```

### 永久重定向文件描述符

这是 `exec` 极为常用的功能，可以为整个脚本或当前 Shell 会话永久性地重定向输入/输出。

```bash
# 将后续所有标准输出和错误追加到日志文件
exec >> /var/log/myscript.log 2>&1
echo "这条信息会写入日志文件，不再显示在终端。"

# 打开一个文件作为输入
exec 3< /etc/passwd
read -u 3 line  # 从文件描述符 3 读取
exec 3<&-       # 读取完毕后关闭文件描述符
```

1. **`exec >> /var/log/myscript.log`**：`exec` 后面不跟命令，只跟重定向操作时，它会为当前整个 Shell 进程设置重定向规则。

    - `>> /var/log/myscript.log` 表示将标准输出（stdout，文件描述符 1）以追加模式重定向到文件 `/var/log/myscript.log`。
    - 与临时重定向（如 `echo "hello" > file.log`，只对当前命令有效）不同，`exec` 设置的重定向是**永久性**的，对后续所有命令都有效，直到再次改变或脚本结束。

2. **`2>&1`**：这个操作符将**标准错误（stderr，文件描述符 2）** 重定向到**标准输出（文件描述符 1）** 当前指向的位置。因为上一条命令已经将标准输出重定向到了日志文件，所以标准错误也会被一同发送到日志文件。

    - **效果**：执行这行后，脚本中所有后续命令的普通输出和错误信息都会**追加**到 `/var/log/myscript.log` 文件中，而不会显示在终端上。这非常适合用于脚本日志记录。

---

1. **`exec 3< /etc/passwd`**：这行命令以**只读**方式打开文件 `/etc/passwd`，并将其分配给自定义的文件描述符 `3`。文件描述符 `0`、`1`、`2` 是系统预留的，我们通常使用 `3` 到 `9` 的自定义描述符。
2. **`read -u 3 line`**：`-u` 选项告诉 `read` 命令从指定的文件描述符（这里是 `3`）而不是标准输入读取一行内容，并将其赋值给变量 `line`。这样就实现了从特定文件中读取数据。
3. **`exec 3<&-`**：这是关闭文件描述符 `3` 的标准写法。虽然 Shell 在脚本结束时会自动关闭它，但显式关闭是一个好习惯，可以释放资源，避免在脚本后续部分误操作。如果尝试使用已关闭的描述符，会收到 "Bad file descriptor" 错误。

### 切换 Shell 环境

如果你想在当前终端会话中永久切换到另一个 Shell（如 zsh），可以使用 `exec`。

```bash
exec zsh
```

## eval vs. exec

在 Bash shell 中，`eval` 和 `exec` 都是强大的内置命令，但它们的核心功能和使用场景有本质区别。简单来说，`eval` 用于**二次解析并执行命令字符串**，而 `exec` 用于**替换当前进程或操作文件描述符**。

下面这个表格能帮你快速抓住它们的主要区别。

| 特性 | `eval` | `exec` |
| :--- | :--- | :--- |
| **核心功能** | 二次解析字符串并作为命令执行 | 用命令替换当前进程，或操作文件描述符 |
| **进程关系** | 在当前 Shell 的子进程中执行命令 | 直接替换当前 Shell 进程，不创建新进程（执行命令时） |
| **是否返回** | **返回**原 Shell，继续执行后续命令 | **不返回**（执行命令时），原 Shell 被结束 |
| **主要用途** | 1. 动态构造并执行命令<br>2. 间接引用变量<br>3. 处理含特殊字符的命令 | 1. 在脚本中启动最终程序<br>2. 永久重定向输入/输出<br>3. 切换 Shell 环境 |

记住一个关键点就能很好区分它们：**`eval` 是为了“更好地运行命令”，而 `exec` 在运行命令时是为了“运行后取而代之”**。

-   当你需要 Shell 再次解析一个动态生成的**命令字符串**时，用 `eval`。
-   当你想用另一个命令**完全替换**当前 Shell，或者想要**永久地重定向**输入输出时，用 `exec`。
