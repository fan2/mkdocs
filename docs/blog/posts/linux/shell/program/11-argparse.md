---
title: Linux Shell Program - argparse
authors:
  - xman
date:
    created: 2019-11-06T10:20:00
categories:
    - linux
    - shell
tags:
    - getopt
comments: true
---

Linux 下的 Shell 编程之参数解析（argparse）。

<!-- more -->

## shift左移变量

bash shell工具箱中另一件工具是shift命令，该命令能够用来操作命令行参数。
跟字面上的意思一样，shift命令会根据它们的相对位置来移动命令行参数。

shift命令会将每个参数变量向左移动一个位置（有点像二进制位移 `<<` ）：
变量 $3 的值会移到 $2 中，变量 $2 的值会移到 $1 中，而原来变量 $1 的值则会向左溢出。

> 注意：变量$0的值，也就是程序名，不会改变。

这是遍历命令行参数的另一个好方法，尤其是在不知道参数个数时。
你可以只操作第一个参数，移动参数，然后继续操作第一个参数。

> 使用 shift 命令的时候要小心：如果某个参数被移出，它的值就被丢弃了，无法再恢复。

以下示例解释了其工作机制：

1. 以第一个参数变量值非空作为while循环条件；  
2. 当 $1 为空（字符串长度为零）时，循环结束。  

```Shell
$ cat test13.sh

#!/bin/bash
# demonstrating the shift command

echo
count=1
while [ -n "$1" ]; do
    echo "Parameter #$count = $1"
    count=$((count + 1))
    shift
done
```

测试结果：

```Shell
$ ./test13.sh rich barbara katie jessica

Parameter #1 = rich
Parameter #2 = barbara
Parameter #3 = katie
Parameter #4 = jessica
```

另外，你也可以一次性移动多个位置，只需要给shift命令提供一个位移参数，指明要移动的位置数就行了。

```Shell
$ cat test14.sh

#!/bin/bash
# demonstrating a multi-position shift 
#
echo
echo "The original parameters: $*"
shift 2
echo "Here's the new first parameter: $1"
```

测试结果：

```Shell
$ ./test14.sh -b -c -d -e -f

The original parameters: -b -c -d -e -f
Here's the new first parameter: -d
```

## 判断选项开关

bash 提供的很多命令会同时提供开关选项和键值参数，选项一般是跟在单破折线（`-`）后面的单个字母（或字符串）。

bash 大部分命令，以 `--` 作为选项和参数的分界符：`--` 前为选项，`--` 后为文件名或其他参数。

具体参考 man bash OPTIONS:

> `−−`: A `−−` **signals** the end of options and disables further option processing. 
> Any arguments after the `−−` are treated as *filenames* and *arguments*. 
> An argument of `−` is equivalent to `−−`.

在 SHELL BUILTIN COMMANDS 开头即阐述了内置命令的选项和参数以 `--` 分隔的惯例。

> Unless otherwise noted, each builtin command documented in this section as accepting options preceded by `−` accepts `−−` to **signify** the end of the options. 
> For example, the `:`, `true`, `false`, and `test` builtins do not accept options.

一般，可以用case来检查每个选项是否有效，进而执行对应的命令。
不管选项按什么顺序出现在命令行上，这种方法都适用。

```Shell
$ cat test15.sh

#!/bin/bash
# extracting command line options as parameters
#
echo
while [ -n "$1" ]; do
    case "$1" in
    -a) echo "Found the -a option" ;;
    -b) echo "Found the -b option" ;;
    -c) echo "Found the -c option" ;;
    *) echo "$1 is not an option" ;;
    esac
    shift
done
```

测试结果：

```Shell
$ ./test15.sh -a -b -c -d

Found the -a option
Found the -b option
Found the -c option
-d is not an option

$ ./test15.sh -d -c -a

-d is not an option
Found the -c option
Found the -a option
```

## 选项和参数分离

经常会遇到在shell脚本中同时使用选项和参数的情况，Linux中处理这个问题的标准方式是用特殊字符来将二者分开。
对Linux来说，这个特殊字符是双破折线（`--`），用来表明选项列表结束和普通参数开始。
在双破折线之后，脚本将剩下的命令行参数当作参数，而不是选项来处理了。
要检查双破折线，只要在case语句中加一项就行了。

以下测试脚本中，在遇到双破折线时，脚本用break命令来跳出while循环。
由于过早地跳出了循环，需要再加一条shift命令来将双破折线移出参数变量。
后续从$1开始就可以按照普通参数解析。

```Shell
$ cat test16.sh

#!/bin/bash
# extracting options and parameters

echo
while [ -n "$1" ]; do
    case "$1" in
    -a) echo "Found the -a option" ;;
    -b) echo "Found the -b option" ;;
    -c) echo "Found the -c option" ;;
    --)
        shift
        break
        ;;
    *) echo "$1 is not an option" ;;
    esac
    shift
done
#
count=1
for param in $@; do
    echo "Parameter #$count: $param"
    count=$((count + 1))
done
```

测试结果：

```Shell
$ ./test16.sh -c -a -b test1 test2 test3

Found the -c option
Found the -a option
Found the -b option
test1 is not an option
test2 is not an option
test3 is not an option

$ ./test16.sh -c -a -b -- test1 test2 test3

Found the -c option
Found the -a option
Found the -b option
Parameter #1: test1
Parameter #2: test2
Parameter #3: test3
```

当脚本遇到双破折线时，它会停止处理选项，并将剩下的参数都当作命令行参数。

## 处理带值的选项

有些选项会带上一个额外的参数值，在这种情况下，命令行看起来如下：

```Shell
$ ./testing.sh -a test1 -b -c -d test2
```

当命令行选项要求额外的参数时， 脚本必须能检测到并正确处理。

下面是如何处理的例子：case语句定义了三个选项，`-b` 选项还需要一个额外的参数值。
当前处置选项是 `$1`，参数值是紧随其后的 `$2`，可从 `$2` 中提取出参数值。
因为这个选项占用了两个参数位，所以还需要使用shift命令，消除额外参数占位。

```Shell
$ cat test17.sh

#!/bin/bash
# extracting command line options and values

echo
while [ -n "$1" ]; do
    case "$1" in
    -a) echo "Found the -a option" ;;
    -b)
        param="$2"
        echo "Found the -b option, with parameter value $param"
        shift
        ;;
    -c) echo "Found the -c option" ;;
    --)
        shift
        break
        ;;
    *) echo "$1 is not an option" ;;
    esac
    shift
done
#
count=1
for param in "$@"; do
    echo "Parameter #$count: $param"
    count=$((count + 1))
done
```

测试结果：

```Shell
$ ./test17.sh -a -b test1 -d

Found the -a option
Found the -b option, with parameter value test1
-d is not an option

$ ./test17.sh -b test1 -a -d

Found the -b option, with parameter value test1
Found the -a option
-d is not an option
```

现在shell脚本中已经有了处理命令行选项的基本能力，但还有一些限制。
比如，如果你想将多个选项放进一个参数中时，它就不能正常工作了。

```Shell
$ ./test17.sh -ac
-ac is not an option
```

在Linux中，合并选项是一种很常见的写法，建议提供这种对用户更友好的特性支持。
幸好，有另外一种处理选项的方法能够帮忙。

## 使用 getopt 命令

getopt 命令是一个在处理命令行选项和参数时非常方便的工具。
它能够识别命令行参数，从而在脚本中更方便地解析出选项参数。

getopt命令可以接受一系列任意形式的命令行选项和参数，并自动将它们转换成适当的格式。
它的命令格式如下：

```Shell
getopt optstring parameters
```

`optstring` 是这个过程的关键所在，它定义了命令行有效的选项字母，还定义了哪些选项字母需要带参数值。

- 首先，在optstring中列出你要在脚本中用到的每个命令行选项字母。
- 然后，在每个需要参数值的选项字母后加一个冒号（:）。

getopt命令会基于你定义的optstring解析提供的选项及参数。

### getopt 命令解析机制

下面是个getopt如何工作的简单例子。

```Shell
$ getopt ab:cd -a -b test1 -cd test2 test3
-a -b test1 -c -d -- test2 test3
```

optstring定义了四个有效选项字母：a、b、c和d，`b:` 说明b选项需要跟一个参数值。

当getopt命令运行时，它会检查提供的参数列表，并基于提供的optstring进行解析。

1. 自动将合并选项 `-cd` 分解成两个选项。  
2. 解析到最后一个选项 `-d`，会插入双破折线来分隔后续的普通参数。  

如果指定了一个不在optstring中声明的字母选项，默认情况下会产生一条错误消息。

```Shell
$ getopt ab:cd -a -b test1 -cde test2 test3
getopt: invalid option -- e
 -a -b test1 -c -d -- test2 test3
```

如果想忽略这条错误消息，可以在 getopt 命令后加上 `-q` 选项。

```Shell
$ getopt -q ab:cd -a -b test1 -cde test2 test3
-a -b 'test1' -c -d -- 'test2' 'test3'
```

注意：getopt命令的选项（`-q`）必须出现在optstring之前。

接下来可以在脚本中使用此命令处理命令行选项了。

### 在脚本中使用 getopt

可以在脚本中使用getopt来格式化脚本所携带的任何命令行选项或参数，但用起来略微复杂。
方法是用getopt命令生成的格式化后的版本来替换已有的命令行选项和参数，**set** 命令能够处理shell中的各种变量。

set命令的选项之一是双破折线（--），它会将命令行参数替换成set命令的命令行值。然后，该方法会将原始脚本的命令行参数传给getopt命令。
之后再将getopt命令的输出传给set命令，用getopt格式化后的命令行参数来替换原始的命令行参数，看起来如下所示。

```Shell
set -- $(getopt -q ab:cd "$@")
```

现在原始的命令行参数变量的值会被getopt命令的输出替换，而getopt已经为我们格式化好了命令行参数。
利用该方法，现在就可以写出能帮我们处理命令行参数的脚本。

```Shell
$ cat test18.sh

#!/bin/bash
# Extract command line options & values with getopt
#
set -- $(getopt -q ab:cd "$@")
#
echo
while [ -n "$1" ]; do
    case "$1" in
    -a) echo "Found the -a option" ;;
    -b)
        param="$2" echo "Found the -b option, with parameter value $param"
        shift
        ;;
    -c) echo "Found the -c option" ;;
    --)
        shift
        break
        ;;
    *) echo "$1 is not an option" ;;
    esac
    shift
done
#
count=1
for param in "$@"; do
    echo "Parameter #$count: $param"
    count=$((count + 1))
done
```

测试结果：

- 在 Ubuntu Desktop 21.10 / bash version 5.1.8(1) 上执行结果符合预期；  
- 该用例在 macOS 11.6.4 / bash version 3.2.57(1) 上的执行结果非预期。  

```Shell
$ ./test18.sh -ac

Found the -a option
Found the -c option

$ ./test18.sh -a -b test1 -cd test2 test3 test4

Found the -a option
Found the -b option, with parameter value
Found the -c option
-d is not an option
Parameter #1: 'test2'
Parameter #2: 'test3'
Parameter #3: 'test4'
```

现在看起来相当不错了，但是在getopt命令中仍然隐藏着一个小问题，具体看看下面这个例子。

```Shell
./test18.sh -a -b test1 -cd "test2 test3" test4

Found the -a option
Found the -b option, with parameter value
Found the -c option
-d is not an option
Parameter #1: 'test2
Parameter #2: test3'
Parameter #3: 'test4
```

getopt命令并不擅长处理带空格和引号的参数值。它会将空格当作参数分隔符，而不是根据双引号将二者当作一个参数。
幸而还有另外一个办法能解决这个问题。

### mac平台的兼容性问题

test18.sh 在 macOS 11.6.4 / bash version 3.2.57(1) 上运行结果非预期。

在 macOS 中执行 [man getopt](https://ss64.com/osx/getopt.html) 可查看说明手册和用例。

[How can I make bash deal with long param using "getopt" command in mac?](https://stackoverflow.com/questions/12152077/how-can-i-make-bash-deal-with-long-param-using-getopt-command-in-mac)  
[【Shell】Linux和Mac下脚本参数的解析](http://witmax.cn/shell-mac-parse-parameters.html)  

在macOS上可考虑执行 `brew install gnu-getopt` 安装 gnu-getopt 来替代默认的 getopt。

## 使用更高级的 getopts

[关于Bash的内置getopts命令](https://thawk.github.io/%E8%BD%AF%E4%BB%B6/bash-getopts/)  

getopts命令（注意是复数）内建于bash shell，它跟近亲getopt看起来很像，但多了一些扩展功能。

> 参考 man bash - SHELL BUILTIN COMMANDS - `getopts optstring name [args]`

与getopt不同，前者将命令行上选项和参数处理后只生成一个输出，而getopts命令能够和已有的shell参数变量配合默契。
每次调用它时，它一次只处理命令行上检测到的一个参数。处理完所有的参数后，它会退出并返回一个大于0的状态码。
这让它非常适合用解析命令行所有参数的循环中。

getopts命令的格式如下：

```Shell
getopts optstring variable
```

optstring值类似于getopt命令中的那个，有效的选项字母都会列在optstring中。

- 如果选项字母需要带参数值，可在字母后加一个冒号。
- 要屏蔽错误消息的话，可在optstring之前加一个冒号。
- getopts命令将当前参数保存在命令行中定义的variable中。

getopts命令会用到两个环境变量。

- 如果选项需要跟一个参数值，`OPTARG` 环境变量就会保存这个值。
- `OPTIND` 环境变量则保存了参数列表中getopts正在处理的参数位置。

在处理完选项之后，执行 `shift $[ $OPTIND - 1 ]` 移位，可以继续处理其他命令行参数了。

### 处理短选项

让我们看个使用getopts命令的简单例子。

```Shell
$ cat test19.sh

#!/bin/bash
# simple demonstration of the getopts command
#
echo
while getopts :ab:c opt; do
    case "$opt" in
    a) echo "Found the -a option" ;;
    b) echo "Found the -b option, with value $OPTARG" ;;
    c) echo "Found the -c option" ;;
    *) echo "Unknown option: $opt" ;;
    esac
    echo "OPTIND = $OPTIND"
done
```

测试结果：

```Shell
$ ./test19.sh -ab test1 -c

Found the -a option
Found the -b option, with value test1
Found the -c option
```

while语句定义了getopts命令，指明了要查找哪些命令行选项，以及每次迭代中存储它们的变量名（opt）。
本例中case判断单字母选项不用单破折线，因为getopts命令解析命令行选项时会移除开头的单破折线。
getopts命令在参数值中可以包含空格，可以解决上一节getopt遗留的问题。

```Shell
$ ./test19.sh -b "test1 test2" -a

Found the -b option, with value test1 test2
Found the -a option
```

另一个好用的功能是支持将选项字母和参数值放在一起使用，而不用加空格。

```Shell
$ ./test19.sh -abtest1

Found the -a option
Found the -b option, with value test1
```

getopts命令能够从 `-b` 选项中正确解析出test1值。
除此之外，getopts还能够将命令行上找到的所有未定义的选项统一输出成问号。

```Shell
$ ./test19.sh -d

Unknown option: ?

$ ./test19.sh -acde

Found the -a option
Found the -c option
Unknown option: ?
Unknown option: ?
```

optstring中未定义的选项字母会以问号形式发送给代码。
getopts命令知道何时停止处理选项，并将参数留给你处理。
在getopts处理每个选项时，它会将 `OPTIND` 环境变量值增一。
在getopts完成处理时，你可以使用shift命令和OPTIND值来移动参数。

```Shell
$ cat test20.sh

#!/bin/bash
# Processing options & parameters with getopts #
echo
while getopts :ab:cd opt; do
    case "$opt" in
    a) echo "Found the -a option" ;;
    b) echo "Found the -b option, with value $OPTARG" ;;
    c) echo "Found the -c option" ;;
    d) echo "Found the -d option" ;;
    *) echo "Unknown option: $opt" ;;
    echo "OPTIND = $OPTIND"
    esac
done
#
shift $((OPTIND - 1))
#
echo
count=1
for param in "$@"; do
    echo "Parameter $count: $param"
    count=$((count + 1))
done
```

测试结果：

> 需要注意的是，解析到第一个非破折号加单字母（test2）开始，后续都会当成普通参数。

```Shell
$ ./test20.sh -a -b test1 -cd -e test2 -f test3 --help test4

Found the -a option
Found the -b option, with value test1
Found the -c option
Found the -d option
Unknown option: ?

Parameter 1: test2
Parameter 2: -f
Parameter 3: test3
Parameter 4: --help
Parameter 5: test4
```

### 调试 OPTIND

每一轮 while 执行时，getopts 将解析索引 `OPTIND` 位置选项，解析完一个位置后，OPTIND++ 指向下一位置。

为了更直观地理解 OPTIND 索引机制，我们稍作修改 test19 和 test20 脚本，添加一些调试输出。

给 test19.sh（optspec=`:ab:c`）的 esac 后添加调试输出 `echo "OPTIND = $OPTIND"`。

```Shell
$ ./test19.sh -a -b test1 -c -d test2 -e

Found the -a option
OPTIND = 2 # next option index for -b
Found the -b option, with value test1
OPTIND = 4 # next option index for -c
Found the -c option
OPTIND = 5 # next option index for -d
Unknown option: ?
OPTIND = 6 # next option index for ?
```

1. 初始化 OPTIND=1，getopts 开始解析第一个选项 `-a`，解析完 OPTIND++=2；  
2. getopts 继续解析 OPTIND 索引的第二个选项 `-b`，解析后 OPTIND++=3；  
    - 由于b:带参，故继续解析 OPTIND 索引的第三个选项 `test1`，赋值给 OPTARG 作为选项二的参数，解析后 OPTIND++=4；  
3. getopts 继续解析 OPTIND 索引的第四个选项 `-c`，解析后 OPTIND++=5；  
4. getopts 继续解析 OPTIND 索引的第五个选项 `-d`，非预期参数，解析后 OPTIND++=6；  
5. getopts 继续解析 OPTIND 索引的第六个选项 `test2`，非破折线单字母，选项解析完毕，后面视作普通参数。  

```Shell
$ ./test19.sh -ab test1 -c -d test2 -e

Found the -a option
OPTIND = 1 # next option index for -b
Found the -b option, with value test1
OPTIND = 3 # next option index for -c
Found the -c option
OPTIND = 4 # next option index for -d
Unknown option: ?
OPTIND = 5 # next option index for ?
```

> 合并选项 -ab 占用一个位置。

1. 初始化 OPTIND=1，getopts 开始解析第一个选项 `-ab`，解析出 `-a`，由于有合并选项，维持 OPTIND；  
2. getopts 继续从 OPTIND 索引的第一个合并选项中解析出 `-b`，OPTIND++=2；  
    - 由于b:带参，故继续解析 OPTIND 索引的第二个选项 `test1`，赋值给 OPTARG 作为选项二的参数，解析后 OPTIND++=3；  
3. getopts 继续解析 OPTIND 索引的第三个选项 `-c`，解析后 OPTIND++=4；  
4. getopts 继续解析 OPTIND 索引的第四个选项 `-d`，非预期参数，解析后 OPTIND++=5；  
5. getopts 继续解析 OPTIND 索引的第五个选项 `test2`，非破折线单字母，选项解析完毕，后面视作普通参数。  

---

给 test20.sh（optspec=`:ab:cd`）的 esac 后添加调试输出 `echo "OPTIND = $OPTIND"`。

```Shell
$ ./test20.sh -a -b test1 -cd -e test2 -f test3 --help test4

Found the -a option
OPTIND = 2
Found the -b option, with value test1
OPTIND = 4
Found the -c option
OPTIND = 4
Found the -d option
OPTIND = 5
Unknown option: ?
OPTIND = 6

Parameter 1: test2
Parameter 2: -f
Parameter 3: test3
Parameter 4: --help
Parameter 5: test4
```

> 合并选项 -cd 占用一个位置。

1. 初始化 OPTIND=1，getopts 开始解析第一个选项 `-a`，解析完 OPTIND++=2；  
2. getopts 继续解析 OPTIND 索引的第二个选项 `-b`，解析后 OPTIND++=3；  
    - 由于b:带参，故继续解析 OPTIND 索引的第三个选项 `test1`，赋值给 OPTARG 作为选项二的参数，解析后 OPTIND++=4；  
3. getopts 继续解析 OPTIND 索引的第四个选项 `-cd`，解析出 `-c`，由于有合并选项，维持 OPTIND；  
4. getopts 继续从 OPTIND 索引的第四个合并选项中解析出 `-d`，OPTIND++=5；  
5. getopts 继续解析 OPTIND 索引的第五个选项 `-e`，非预期参数，解析后 OPTIND++=6；  
6. getopts 继续解析 OPTIND 索引的第六个选项 `test2`，非破折线单字母，选项解析完毕，后面视作普通参数。  

最后执行 `shift $((OPTIND - 1))` 或 `shift $[ $OPTIND - 1 ]`，将 test2 左移五位到 -a 原来的位置 `$1`。

### 处理长选项

[Using getopts to process long and short command line options](https://stackoverflow.com/questions/402377/using-getopts-to-process-long-and-short-command-line-options)

- 翻译1：[使用getopts处理长和短命令行选项](https://qastack.cn/programming/402377/using-getopts-to-process-long-and-short-command-line-options)  
- 翻译2：[使用getopts处理长和短命令行选项](https://blog.csdn.net/asdfgh0077/article/details/104261645)  

#### RapaNui

RapaNui 的回答 - https://stackoverflow.com/a/12523979：

> getops with long/short flags as well as long arguments

**问题**：解析短选项后的长选项，前面的短选项会继续命中长选项处理default case `*)`，报错 *Long: >>>>>>>> invalid options (long)*，但实际解析正常。

#### Arvid Requate

Arvid Requate 的回答 - https://stackoverflow.com/a/7680682：

> The Bash builtin getopts function can be used to parse long options by putting a dash character followed by a colon into the optspec.

在进入长选项(-)的case中增加打印调试信息：

```Shell
    -)
        echo "opt=$opt, OPTARG=$OPTARG, OPTIND=$OPTIND" # debug
        case "${OPTARG}" in
```

看看 `--longOption Value` 和 `--longOption=Value` 两种情形下的处理逻辑。

`--longOption Value`：getopts命令解析命令行选项时会移除开头的单破折线。

- 当前解析到第二个选项为 -，其参数为 loglevel：输出 `opt=-, OPTARG=loglevel`，下一个选项位置为 OPTIND=3；  
- OPTARG=loglevel 为真正的长选项，读取其后下一个选项位置的值，作为其参数值：`val="${!OPTIND}"`；  
- OPTIND 自增后移到参数 `-g`，继续while循环处理后续选项。  

```Shell
$ ./getopts-7680682.sh -v --loglevel 2 -g
Found option '-v'
opt=-, OPTARG=loglevel, OPTIND=3
Parsing option: '--loglevel', value: '2'
Non-option argument: '-g'
```

`--longOption=Value`：getopts命令解析命令行选项时会移除开头的单破折线。

- 当前解析到第二个选项为 -，其参数为 loglevel=2：输出 `opt=-, OPTARG=loglevel=2`，下一个参数位置为 OPTIND=3；  
- 从OPTARG中解析出等号左边的长选项及其右边的参数值；  

```Shell
$ argparse/getopts-7680682.sh -v --loglevel=2 -g
Found option '-v'
opt=-, OPTARG=loglevel=2, OPTIND=3
Parsing option: '--loglevel', value: '2'
Non-option argument: '-g'
```

思考：这种写法，针对长选项预定义了case。如果有多个长选项，则无法普适。

#### Adam Katz

Adam Katz 的回答 - https://stackoverflow.com/a/28466267：

> Long options can be parsed by the standard getopts builtin as “arguments” to the - “option”  
> This is portable and native POSIX shell – no external programs or bashisms are needed.  

在 Arvid Requate 的基础上进行了完善，首先分析长选项 `--longOption=Value`。
基于 OPTARG（longOption=Value），提取真正长选项 OPT 及其值 OPTARG，后续同义长短选项合并case处理。

- 短选项后续的值以空格分隔；长选项后面带值需要以等号(=)赋值。

测试用例：注意长选项带值需要用等号。

```Shell
# 增加开关选项 -d --dogtail
$ ./getopts-28466267.sh -ab paramB --charlie=paramC --dogtail D E F G
Found short option 'a'
Parsing short option: 'b', value: 'paramB'
>>> long option: '--charlie=paramC'
Parsing long option: 'charlie', value: 'paramC'
>>> long option: '--dogtail'
Found long option 'dogtail'
last params: D E F G
```

考虑兼容支持长选项空格后带参数情形，疑难是无法知晓长选项后是否带参数（need_arg）？

need_arg 函数判断输入的长选项名称（参数 `$1`）是否需要带参数。  

> 预定义了三个需要带参数的选项：--bravo、--charlie、--electric。

```Shell
# 判断输入的长选项名称是否需要带参数
need_arg() {
    # if ! [ $# -eq 0 ]
    if [ $# -gt 0 ]; then
        case $1 in
        bravo | charlie | electric )
            return 0
            ;;
        *)
            # echo "Unkown option: $1" >&2
            return 1
            ;;
        esac
    else
        return 1
    fi
}
```

测试结果如下，能满足一般性需求。

```Shell
# 增加选项（要带参数）-e --electric
$ ./getopts-28466267.sh -ab paramB --charlie=paramC --dogtail --electric paramE F G H
Found short option 'a'
Parsing short option: 'b', value: 'paramB'
>>> long option: '--charlie=paramC'
Parsing long option: 'charlie', value: 'paramC'
>>> long option: '--dogtail'
Found long option 'dogtail'
>>> long option: '--electric paramE'
Parsing long option: 'electric', value: 'paramE'
last params: F G H
```

## 相关参考

[Shell 脚本的参数解析工具](https://www.escapelife.site/posts/9b814911.html)

- [shell - 参数解析三种方式(手工, getopts, getopt)](https://bummingboy.top/2017/12/19/shell%20-%20%E5%8F%82%E6%95%B0%E8%A7%A3%E6%9E%90%E4%B8%89%E7%A7%8D%E6%96%B9%E5%BC%8F(%E6%89%8B%E5%B7%A5,%20getopts,%20getopt)/)  

1. 手工解析使用空格分隔  
2. 手工解析使用等号分隔  
3. 使用 getopts 工具  
4. 使用 argbash 工具  

[使用 getopts 和 getopt 命令处理命令行选项](https://www.jianshu.com/p/ad05cffede0b)  

- getopt 能处理长参数和短参数格式，mac上默认不支持；  
- getopts 只能处理短参数格式，兼容linux和mac；  
