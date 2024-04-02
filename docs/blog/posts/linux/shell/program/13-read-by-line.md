---
title: Linux Shell Program - read by line
authors:
  - xman
date:
    created: 2019-11-06T10:40:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之逐行读取方式。

<!-- more -->

```Shell
$ cat data2.txt
One line of test text.
Two lines of test text.
Three lines of test text.
```

## awk

awk 默认对数据流逐行读取分析，每一行即为一条记录（Record），然后针对每条记录执行动作。

记录之间的分隔符可用 `RS` 配置，记录内部的字段分隔符可用 `FS` 指定。

以下为最简单的逐行处理，打印每行（`print $0`）。

```Shell
# 可简写为 awk 1 data2.txt
$ awk '1{print}' data2.txt
One line of test text.
Two lines of test text.
Three lines of test text.
```

可在中括号中替换 `print`，针对每行执行更多的其他操作。

## array

```Shell
$ array=($(cat data2.txt))
$ array=($(awk 1 data2.txt))
```

```Shell
$ echo $array
One line of test text. Two lines of test text. Three lines of test text.
$ echo ${#array[*]}
15
```

### IFS

以上示例中，从 data2.txt 中读入数据到 array 数组，但是数组长度不是3，而是15！

造成这个问题的原因是特殊的环境变量 `IFS`（Internal Field Separator），叫作内部字段分隔符。  

IFS环境变量定义了 bash shell 用作字段分隔符的一系列字符，默认情况下，bash shell 会将下列字符当作字段分隔符：

- 空格  
- 制表符  
- 换行符  

在 man bash 的 PARAMETERS 章节中有对 IFS 的定义和说明：

> **IFS** The Internal Field Separator that is used for word splitting after expansion and to split lines into words with the read builtin command. The default value is `<space><tab><newline>`.

如果 bash shell 在数据中看到了这些字符中的任意一个，它就会假定这表明了列表中一个新数据字段的开始。

命令行执行 `"$IFS"` 会提示非命令，看到 IFS 的值。

```Shell
$ "$IFS"
zsh: command not found:  \t\n
```

data2.txt 中有3行，但是每一行单词之间以空格分割，导致for循环读取了15个单词，而非三行。
若想按行读入数组，可临时更改环境变量 IFS 的值，执行前保存旧值，执行后恢复。

```Shell
$ OLDIFS=$IFS
$ IFS=$'\n'
$ array=($(cat data2.txt))
$ echo ${#array[@]}
3

$ for line in ${array[@]}; do
$ for> echo $line
$ for> done
One line of test text.
Two lines of test text.
Three lines of test text.

$ IFS=$OLDIFS # restore
```

以下为在脚本中逐行读取，并附带打印行号：

```Shell
#!/bin/bash

filename=$1

OLDIFS=$IFS
IFS=$'\n'
i=0

for line in `cat $filename`; do
    echo "$((i++)) : $line" 
done

IFS=$OLDIFS # restore

exit 0
```

执行结果如下：

```Shell
$ ./dumpFileLines.sh data2.txt
0 : One line of test text.
1 : Two lines of test text.
2 : Three lines of test text.
```

## while

[Read a file line by line assigning the value to a variable](https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable)

[standard form](http://mywiki.wooledge.org/BashFAQ/001) for reading lines from a file in a loop.

```Shell
while IFS= read -r line; do
    echo "Text read from file: $line"
done < my_filename.txt
```

- `IFS=` (or `IFS=''`) prevents leading/trailing whitespace from being trimmed.  
- `-r` prevents backslash escapes from being interpreted.  

Or you can put it in a bash file helper script, example contents:

```Shell
#!/bin/bash

while IFS= read -r line; do
    echo "Text read from file: $line"
done < "$1"
```

If the file isn’t a standard POSIX text file (= not terminated by a newline character), the loop can be modified to handle trailing partial lines:

```Shell
while IFS= read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
done < "$1"
```

Here, `|| [[ -n $line ]]` prevents the last line from being ignored if it doesn't end with a `\n` (since read returns a non-zero exit code when it encounters EOF).

```Shell
#! /bin/bash
cat filename | while read LINE; do
    echo $LINE
done
```

cat 重定向单行简写：`cat data2.txt | ( while read line; do echo $line; done )`
