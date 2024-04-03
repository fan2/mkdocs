---
title: Linux Shell Program - control
authors:
  - xman
date:
    created: 2019-11-06T09:30:00
categories:
    - linux
    - shell
tags:
    - condition
    - loop
comments: true
---

Linux 下的 Shell 编程之条件判断（conditions）和循环控制（loops）表达式。

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

### demo

??? info "test-if.sh"

    ```Shell
    #!/bin/bash
    
    test_if_1()
    {
        echo "----------------------------------------"
        echo "test_if_1"
        echo "----------------------------------------"
        # read -p "PLS input the num (1-10): " ANS
        echo -n "PLS input the num (1-10): "
        read num
    
        while [[ $num != 4 ]]
        do
            if [ $num -lt 4 ]
            then
                echo "Too small. Try again!"
                read num
            elif [ $num -gt 4 ]
            then
                echo "Too high. Try again!"
                read num
            else
                # echo "Congratulation, you are right!" # no output !?
                exit 0
            fi
        done
    
        echo "Congratulation, you are right!"
    }
    
    test_if_2()
    {
        echo "----------------------------------------"
        echo "test_if_2"
        echo "----------------------------------------"
    }
    
    test_if()
    {
        test_if_1
        test_if_2
    }
    
    test_if
    ```

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

3. 在 [How to detect the OS from a Bash script?](https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script) 中，基于 case 对 `$OSTYPE` 进行匹配，从而判断操作系统类型，参考 [get-ostype](./12-get-ostype.md)

??? info "test-case.sh"

    ```Shell
    #!/bin/bash

    test_case_1()
    {
        echo "----------------------------------------"
        echo "test_case_1"
        echo "----------------------------------------"
        # read -p "enter a number from 1 to 5:" ANS
        echo -n "enter a number from 1 to 5: "
        read ANS
        case $ANS in
            1) echo "you select 1"
                ;;
            2) echo "you select 2"
                ;;
            3) echo "you select 3"
                ;;
            4) echo "you select 4"
                ;;
            5) echo "you select 5"
                ;;
            *) echo "`basename $0`: This is not between 1 and 5" >&2
                exit 1
                ;;
        esac
    }

    test_case_2()
    {
        echo "----------------------------------------"
        echo "test_case_2"
        echo "----------------------------------------"
        read -p "Do you wish to proceed [y..n] : " ANS
        case $ANS in
            y|Y|yes|Yes) echo "yes is selected"
                ;;
            n|N) echo "no is selected"
                exit 0 # no error so only use exit 0 to terminate
                ;;
            *) echo "`basename $0`: Unknown response" >&2
                exit 1
                ;;
        esac
        # if we are here then a y|Y|yes|Yes was selected only
    }

    test_case()
    {
        test_case_1
        test_case_2
    }

    test_case
    ```


## for

for 命令允许创建一个遍历一系列值的循环，每次迭代都使用其中一个值来执行已定义好的一组命令。

```
for var in {list}
do
    command1
    command2
    ...
done
```

> 在 list 参数中，你需要提供迭代中要用到的一系列值。

### args

在 for 循环中省去 in 列表选项时，它将接受命令行位置参数作为参数，等效于：

```
for params in "$@"
```

或

```
for params in "$*"
```

### demo

??? info "test-for.sh"

    ```Shell
    #!/bin/bash

    test_for_1()
    {
        echo "----------------------------------------"
        echo "test_for_1"
        echo "----------------------------------------"
        for loop in 1 2 3 4 5
        do
            echo $loop
        done
    }

    # testing the C-style for loop
    test_for_2()
    {
        echo "----------------------------------------"
        echo "test_for_2"
        echo "----------------------------------------"
        for (( i=1; i <= 10; i++ ))
        do
            echo "The next number is $i"
        done
    }

    test_for_3()
    {
        echo "----------------------------------------"
        echo "test_for_3"
        echo "----------------------------------------"
        read -p "PLS input directory to list: " directory
        if [ -d $directory ]
        cd $directory # 如果不进入该目录，以下 -f 测试需要拼接绝对路径
        then
            for filename in `ls -1 $directory`
            do
                if [ -f $filename ]
                then
                    echo $filename
                fi
            done
        fi
    }

    # 使用 for 循环 ping 服务器列表
    test_for_4()
    {
        echo "----------------------------------------"
        echo "test_for_4"
        echo "----------------------------------------"
        HOSTS="www.qq.com www.tencent.com www.sogo.com"
        for host in $HOSTS
        do
            ping -c 2 $host
        done
    }

    test_for()
    {
        # test_for_0
        test_for_1
        test_for_2
        test_for_3
        test_for_4
    }

    echo "----------------------------------------"
    echo "test_for_0"
    echo "----------------------------------------"
    for arg
    do
        echo "You supplied $arg as a command line option"
    done

    test_for
    ```

## while

while 命令某种意义上是 if-then 语句和 for 循环的混杂体。

while 命令允许定义一个要测试的命令，然后循环执行一组命令，只要定义的测试命令返回的是退出状态码为0。
它会在每次迭代的一开始测试 test 命令，在 test 命令返回非零退出状态码时，while 命令会停止执行那组命令。

```
while test command
do
    other commands
done
```

??? info "test-while.sh"

    ```Shell
    #!/bin/bash
    
    test_while_1()
    {
        echo "----------------------------------------"
        echo "test_while_1"
        echo "----------------------------------------"
        COUNTER=0
        while [ $COUNTER -lt 5 ]
        do
            COUNTER=`expr $COUNTER + 1` # $[ $COUNTER + 1 ]
            echo $COUNTER
        done
    }
    
    # 用while循环逐行读取文本内容
    test_while_2()
    {
        echo "----------------------------------------"
        echo "test_while_2"
        echo "----------------------------------------"
        # read -p "enter filename:" FILE
        echo -n "PLS enter filename to readline: "
        read FILE
        if [ -f $FILE ]
        then
            while read LINE
            do
                echo $LINE
            done < $FILE
        fi
    }
    
    # 用while循环读取键盘输入
    test_while_3()
    {
        echo "----------------------------------------"
        echo "test_while_3"
        echo "----------------------------------------"
        echo "type <CTRL-D> to terminate"
        echo "enter your most liked films: "
        index=0
        while read FILM
        do
            # index+=1 # string contact!!!
            # index=`expr $index + 1`
            index=$[ $index + 1 ]
            echo "Yeah, great film[$index]: $FILM"
        done
    }
    
    test_while()
    {
        test_while_1
        test_while_2
        test_while_3
    }
    
    test_while
    ```

## until

和 while 命令类似，你可以在 until 命令语句中放入多个测试命令。
只有最后一个命令的退出状态码决定了 bash shell 是否执行已定义的 other commands。

1. 只有测试命令的退出状态码 **不为0**，bash shell 才会执行循环中列出的命令。
2. 当首次测试命令的退出状态码为0时，将一次也不执行循环体。

```
until test commands
do
    other commands
done
```

??? info "test-until.sh"

    ```Shell
    #!/bin/bash
    
    test_until_1()
    {
        echo "----------------------------------------"
        echo "test_until_1"
        echo "----------------------------------------"
        var1=100
        until [ $var1 -eq 0 ]
        do
            echo $var1
            var1=$[ $var1 - 25 ]
        done
    }
    
    # 用while循环逐行读取文本内容
    test_until_2()
    {
        echo "----------------------------------------"
        echo "test_until_2"
        echo "----------------------------------------"
        var1=100
        until echo $var1
              [ $var1 -eq 0 ]
        do
            echo Inside the loop: $var1
            var1=$[ $var1 - 25 ]
        done
    }
    
    test_until()
    {
        test_until_1
        test_until_2
    }
    
    echo "----------------------------------------"
    echo "test_until_0"
    echo "----------------------------------------"
    
    var0=0
    until [ $var0 -eq 0 ]
    do
        echo $var0
    done
    
    test_until
    ```
