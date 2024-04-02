---
title: Linux Shell Program - function
authors:
  - xman
date:
    created: 2019-11-06T09:30:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之函数。

<!-- more -->

## 函数定义

bash shell 提供函数支持，方便将代码模块封装为函数，以便复用。

有两种创建函数的格式：

1. 函数名加括号；  
2. 采用关键字 function，后跟函数名；  

> 当前函数名可通过内置变量 `FUNCNAME` 获取。
> 当前函数的调用者可通过调用 `caller` 打印。

```Shell
#方式1
name() {
    commands
    # echo "FUNCNAME = $FUNCNAME"
}

#方式2
function name {
    commands
    # echo "FUNCNAME = $FUNCNAME"
}
```

[transfer.sh](https://transfer.sh/) - Easy file sharing from the command line

```Shell
transfer() {
    if [ $# -eq 0 ]; then
        echo "No arguments specified.\nUsage:\n transfer <file|directory>\n ... | transfer <file_name>" >&2
        return 1
    fi
    if tty -s; then
        file="$1"
        file_name=$(basename "$file")
        if [ ! -e "$file" ]; then
            echo "$file: No such file or directory" >&2
            return 1
        fi
        if [ -d "$file" ]; then
            file_name="$file_name.zip" ,
            (cd "$file" && zip -r -q - .) | curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name" | tee /dev/null,
        else
            cat "$file" | curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name" | tee /dev/null
        fi
    else
        file_name=$1
        curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name" | tee /dev/null
    fi
}
```

### 函数调用

在脚本中使用函数，只需要像其他shell命令一样，在行中指定函数名就行，无需括号。
如果想传递参数，直接通过空格分割指定位置参数即可。

### 函数参数

参考 [basic](./1-sh-basic.md) 中的命令行参数。

在脚本中指定函数时，必须将参数和函数放在同一行，像这样:

```Shell
    func1 $value1 10
```

然后函数可以用参数环境变量来获得参数值。

对于脚本，`$0` 为脚本名称；对于函数调用，`$0` 为函数名称。
空格相间的 $1,...,$9 为函数的位置参数，如果参数个数超过9个，可以以 `${10}`,`${11}` 这种形式引用。

1. `$#`：参数个数；  
2. `$1`、`$2`、...、`$9`，`${10}`、`${11}`、...：顺序位置参数；  
3. `${!#}` 代表最后一个参数；  

如果脚本的所有命令行参数，需要传递给函数，可通过 `func $@` 或 `func $*` 形式传递。

### 局部变量

函数使用两种类型的变量:

1. 全局变量  
2. 局部变量  

函数内部可以通过 local 修饰定义局部变量，限定作用域为函数内部。
调用函数后，变量在后续脚本中不可见，不可以引用访问。

> `local`: can only be used in a function

默认情况下，在脚本中定义的不加 local 修饰的变量都是全局变量。
调用函数后，变量在后续脚本中可以继续引用访问。

local关键字保证了变量作用域只局限在该函数中。
如果在脚本中该函数之外有同名的变量， 那么shell将会保持这两个变量的值是分离的。
这样，你就能很轻松地将函数内部变量和脚本中的其他变量隔离开了，只共享需要共享的全局变量。

以下是脚本 [brew.plugin.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/brew/brew.plugin.zsh) 中的代码片段：

```Shell
function brews() {
  local formulae="$(brew leaves | xargs brew deps --installed --for-each)"

}
```

## 函数返回

bash shell 会把函数当作一个小型脚本，运行结束时会返回一个退出状态码。
函数的退出状态码，实际上是最后一条命令执行的退出状态。
可以用标准变量 `$?` 来获取函数调用的返回状态码。

也可以用 return 命令指定返回一个 0～255 之间的整数值。
然后调用方通过 `if [ $? -eq 0 ]` 测试函数返回值。

如果想返回超过256的整数值或字符串类型，则可以考虑使用函数输出。

### 函数输出

正如可以这样 result=`dbl` 将命令的输出保存到shell变量中一样，也可以对函数的输出采用同样的处理办法。
下面是在脚本中使用这种方法的例子。

```Shell
#!/bin/bash
# using the echo to return a value

function dbl
{
    read -p "Enter a value: " value
    echo $[ $value * 2 ]
}

result=$(dbl)
echo "The new value is $result"
```

dbl 函数会用 echo 语句来显示计算的结果。

## 命令中定义函数

[Define function in unix/linux command line (e.g. BASH) - Stack Overflow](https://stackoverflow.com/questions/35465851/define-function-in-unix-linux-command-line-e-g-bash)

在终端中，如果想多个命令一起运行，可以把它们放在同一行中，彼此间用分号（`;`）隔开。
可以在命令行中定义包含多条命令的一行函数，但每条命令的结尾必须包含分号，这样shell才知道命令在哪分开。

此外，也可以在命令中输入函数，按照提示符输入即可。

假设有函数 check_python_version：

```Shell
check_python_version()
{
    if python -V &>/dev/null;
    then
        python_version=$(python -V) 1>/dev/null
        echo "python installed: $python_version"
        return 0
    else
        echo "python uninstalled!"
        return 1
    fi
}
```

以上脚本直接复制到命令行中，感叹号要转义，否则会截断提示 function else dquote>。

在命令行下逐行输入如下：

```Shell
check_python_version() {
function> if python -V &>/dev/null;
function if> then
function then> python_version=$(python -V) 1>/dev/null;
function then> echo "python installed: $python_version";
function then> return 0;
function then> else
function else> echo "python uninstalled\!";
function else> return 1;
function else> fi
function> }
```

然后输入 `check_python_version` 回车即可调用该函数。

以下函数将两句脚本用分号隔开放在同一行里：

```Shell
pman() { manpage=$(man -w $@); mandoc -T pdf $manpage | open -fa Preview; }
```

## 跨脚本调用

### source导入引用脚本

[Shell 脚本调用另一个脚本的三种方法](https://blog.csdn.net/K346K346/article/details/86751705)  
[在 Shell 脚本中调用另一个 Shell 脚本的三种方式](https://blog.csdn.net/simple_the_best/article/details/76285429)  

- fork: 如果脚本有执行权限的话，`path/to/foo.sh`。如果没有，`sh path/to/foo.sh`。  
- exec: `exec path/to/foo.sh`  
- source: `source path/to/foo.sh`  

`. aux_etc.sh`/`source aux_etc.sh` 的作用是在同一个shell进程中导入另一个文件（bash.sh）中的脚本，以便引用其中的变量，调用其中定义的函数。

> 类似 C/C++ 语言中的 `#include <cstdio>`、python 中的 `import os`、nodejs 中的 `const server = require('server');`。

如果不是在脚本所在目录，而是在外层目录执行sh，那么 source 引入脚本需要相对路径。

除了绝对路径，安全引入同目录下的其他脚本的写法如下：

```Shell
#!/bin/bash

source $(dirname $0)/aux_etc.sh

```

假如引入的脚本文件路径是拼接的字符串，则 ShellCheck 将会警告 [SC1090](https://github.com/koalaman/shellcheck/wiki/SC1090): Can't follow non-constant source. Use a directive to specify location.

参考 [Source from string? Is there any way in shell?](https://stackoverflow.com/questions/29324463/source-from-string-is-there-any-way-in-shell)，可考虑用 `eval` 来解释执行 source 语句：

> 以下脚本路径为 scripts/proxy/launch.sh，导入配置脚本的路径为 scripts/conf/debug.conf。

```Shell
    # 导入shell脚本格式的配置文件
    script_dir="$(dirname "$(dirname "$0")")"
    conf=$script_dir/config/"${run_mode:=debug}".conf
    # echo "conf = $conf"
    if [ -f "$conf" ]; then
        eval "source $conf"
    fi
```

### 终端调用脚本中的函数

假设我们创建了一个脚本 `~/Projects/shell/test-function.sh`，其内容如下：

```Shell
~/Projects/shell | cat test-function.sh
#!/bin/bash

use_python38()
{
	echo "which python3 = `which python3`"
	export PATH=/usr/local/opt/python@3.8/bin:$PATH
	echo "use_python38..."
	echo "which python3 = `which python3`"
}

file_name=$0
script_dir=$(dirname $0)
script_name=$(basename $0)
echo "file_name=$file_name"
echo "script_dir=$script_dir"
echo "script_name=$script_name"
```

在终端执行点或source命令导入加载脚本，然后就可以在当前命令行中引用sh脚本中定义的变量和函数了。

```Shell
~ | source ~/Projects/shell/test-function.sh

~ | echo $file_name
/Users/faner/Projects/shell/test-function.sh

~ | use_python38
which python3 = /usr/local/bin/python3
use_python38...
which python3 = /usr/local/opt/python@3.8/bin/python3
```

假设脚本 check_python_version.sh 只包含 check_python_version 函数，那么source导入终端，仅是导入函数。

如果 sh 脚本中有入口点 main 调用了 check_python_version 函数，那么source导入终端，直接运行脚本。

```Shell
#!/bin/bash

check_python_version()
{
    # ...
}

main()
{
    check_python_version
}

main "$@" # $*
```

source导入或运行脚本，与当前终端shell共享环境变量。
但直接在终端执行脚本，将按照Shebang新起子shell进程，环境变量可能与当前终端shell不一致。
在执行完sh后，脚本中未export导出的变量，无法再引用！

```Shell
~/Projects/shell | ./test-function.sh
file_name=./test-function.sh
script_dir=.
script_name=test-function.sh

# 变量file_name未export，执行完sh后不可见
~/Projects/shell | echo $file_name

```

### 调用其他脚本中的函数

[Bash编程入门-4：函数](https://zhuanlan.zhihu.com/p/59528626)

假设有两个脚本 `my_info.bash` 和 `app.bash`，内容如下：

```Shell
$ cat my_info.sh
#!/bin/bash

function my_info()
{
    lscpu >> $1
    uname –a >> $1
    free –h >> $1
}
```

```Shell
$ cat app.bash
#!/bin/bash

source ./my_info.bash  #引入另一个脚本
my_info output.file    #调用另一个脚本中的函数
```

运行 app.bash 时，执行到 source 命令那一行时，就会执行 my_info.bash 脚本。
在 app.bash 的后续部分，就可以调用 my_info.bash 中的 my_info 函数。
