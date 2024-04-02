---
title: Linux Shell Program - xtrace
authors:
  - xman
date:
    created: 2019-11-06T09:00:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 调试命令 —— set -x / +x / -o。

<!-- more -->

[Setting shell options](https://bash.cyberciti.biz/guide/Setting_shell_options)

How do I set and unset shell variable options?

To **set** shell variable option use the following syntax:

```
set -o variableName
```

To **unset** shell variable option use the following syntax:

```
set +o variableName
```

[5 Simple Steps On How To Debug A Bash Shell Script](https://www.shell-tips.com/bash/debug-script/)

three basic types of errors:

- Syntax Error  
- Runtime Error  
- Logic Error  

五步调试法：

1. Step 1: Use a Consistent Debug Library  
2. Step 2: Check For Syntax Error  
3. Step 3: Trace Your Script Command Execution  
4. Step 4: Use The Extended Debug Mode  
5. Step 5: Provide Meaningful Debug Logs  

## set

[Bash built-in: set -x (set -o xtrace)](https://renenyffenegger.ch/notes/Linux/shell/bash/built-in/set/x)  

`set -x` (long notation: `set -o xtrace`) traces commands before executing them.

set命令可辅助脚本调试。

以下是 set 命令常用的调试选项：

- `set -n`：读命令但并不执行。  
- `set -v`：显示读取的所有行。  
- `set -x`：显示所有命令及其参数。  

将set选项关闭，只需用 `+` 替代 `-`。  
有人总认为 `+` 应该为开，而 `-` 应为关闭，但实际刚好相反。  
可以在脚本开始时将 set 选项打开，然后在结束时关闭它；或在认为有问题的特殊语句段前后用 `-x` ~ `+x` 设置闭合调试区域。

> bash shell环境变量 `BASH_XTRACEFD` 若设置成了有效的文件描述符（0、1、2），则 `set -x` 调试选项生成的跟踪输出可被重定向，通常用来将跟踪输出到一个文件中。

### refs

[Inline debug (xtrace) in scripts](https://unix.stackexchange.com/questions/253381/inline-debug-xtrace-in-scripts)

[Turn on xtrace with environment variable](https://unix.stackexchange.com/questions/536263/turn-on-xtrace-with-environment-variable)

[how to silently disable xtrace in a shell script?](https://stackoverflow.com/questions/17365784/how-to-silently-disable-xtrace-in-a-shell-script)

Sandbox it in a subshell:

```
(set -x; do_thing_you_want_traced)
```

[shell 脚本中set -x 与set +x 的区别](https://blog.csdn.net/hanbo_112/article/details/53640559)  

linux shell 脚本编写好要经过漫长的调试阶段，可以使用 `sh -x` 执行支持调试，但是在远程调用脚本的时候有诸多不便。

要想知道脚本内部执行的变量的值或执行结果，可以在脚本内部用 `set -x` 等相关命令开始调试。

- `set -x`：开启  
- `set +x`：关闭  
- `set -o`：查看  

[Linux 脚本中生成日志 set -x](https://www.cnblogs.com/qqjue/archive/2012/07/25/2607683.html)

- `set -x` 是开启  
- `set +x` 是关闭  
- `set -o` 是查看 (xtrace)  

针对部分script，可以选择 `set -x` 和 `set +x` 配套使用。比如在一个脚本里：

```Shell
set -x            # activate debugging from here
w
set +x            # stop debugging from here
```

[解释bash脚本中set -e与set -o pipefail的作用](https://blog.csdn.net/t0nsha/article/details/8606886)

`set -e`：表示一旦脚本中有命令的返回值为非0，则脚本立即退出，后续命令不再执行。

## DEBUG

前面介绍的调试手段是Bash内建的，它们通常以固定的格式生成调试信息。
若需要以自定义格式显示调试信息，则可通过传递 `_DEBUG` 环境变量来进行此类调试。

下面的示例代码，在每一个需要打印调试信息的语句前加上DEBUG。

> 在Bash中，命令 `:` 告诉shell不要进行任何操作。

```Shell
#!/bin/bash 

function DEBUG() {
    [ "$_DEBUG" == "on" ] && $@ || :
}

for i in {1..10}
do
    DEBUG echo $i
done
```

如果没有把 `_DEBUG=on` 传递给脚本，那么调试信息就不会打印出来。

可以将调试开关环境变量设置为"on"，再运行上面的脚本打印调试信息：

```
$ _DEBUG=on ./script.sh
```
