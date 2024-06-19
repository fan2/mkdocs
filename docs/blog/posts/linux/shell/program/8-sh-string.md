---
title: Linux Shell Program - string
authors:
  - xman
date:
    created: 2019-11-06T09:50:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之字符串常用操作。

<!-- more -->

[linux shell 字符串操作详解](https://www.iteye.com/blog/justcoding-1963463)  
[shell 变量的高级用法](https://www.cnblogs.com/crazymagic/p/11067147.html)  

## 变量替换

参考 man bash - `Parameter Expansion` 章节

```Shell
$ man bash

       ${parameter:-word}
              Use Default Values.  If parameter is unset or null, the  expansion  of  word  is  substituted.
              Otherwise, the value of parameter is substituted.
       ${parameter:=word}
              Assign  Default  Values.   If parameter is unset or null, the expansion of word is assigned to
              parameter.  The value of parameter is then substituted.   Positional  parameters  and  special
              parameters may not be assigned to in this way.
       ${parameter:?word}
              Display  Error  if  Null or Unset.  If parameter is null or unset, the expansion of word (or a
              message to that effect if word is not present) is written to the standard error and the shell,
              if it is not interactive, exits.  Otherwise, the value of parameter is substituted.
       ${parameter:+word}
              Use  Alternate  Value.   If  parameter is null or unset, nothing is substituted, otherwise the
              expansion of word is substituted.

```

[shell 编程：:后面跟-=?+的意义](https://handerfly.github.io/shell/2019/04/03/shell%E7%BC%96%E7%A8%8B%E5%86%92%E5%8F%B7%E5%8A%A0-%E7%AD%89%E5%8F%B7-%E5%8A%A0%E5%8F%B7-%E5%87%8F%E5%8F%B7-%E9%97%AE%E5%8F%B7/)  
[shell之变量替换：:=、=、:-、-、=?、?、:+、+句法](https://www.cnblogs.com/fhefh/archive/2011/04/22/2024750.html)  

[POSIX](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02) 文档中的这张表说得很清楚：

|    |*parameter*<br>**Set and Not Null** |*parameter*<br>**Set But Null** |*parameter*<br>**Unset** |
|:--|:--|:--|:--|
|**${***parameter***:-***word***}** |substitute *parameter* |substitute *word* |substitute *word* |
|**${***parameter***-***word***}** |substitute *parameter* |substitute null |substitute *word* |
|**${***parameter***:=***word***}** |substitute *parameter* |assign *word* |assign *word* |
|**${***parameter***=***word***}** |substitute *parameter* |substitute null |assign *word* |
|**${***parameter***:?***word***}** |substitute *parameter* |error, exit |error, exit |
|**${***parameter***?***word***}** |substitute *parameter* |substitute null |error, exit |
|**${***parameter***:+***word***}** |substitute *word* |substitute null |substitute null |
|**${***parameter***+***word***}** |substitute *word* |substitute *word* |substitute null |

[shell 脚本 ${1:-"false"}的含义](https://blog.csdn.net/fhaitao2009/article/details/104165211)

如果 $1 存在并且不为空，则 a=$1；未定义或为空，则 a=false;

[Usage of :- (colon dash) in bash](https://stackoverflow.com/questions/10390406/usage-of-colon-dash-in-bash)  

`${PUBLIC_INTERFACE:-eth0}`: If `$PUBLIC_INTERFACE` exists and isn't null, return its value, otherwise return "eth0".

### demo

in `/etc/zshrc`: If `ZDOTDIR` is unset(or empty), `HOME` is used instead.

```Shell
$ vim /etc/zshrc

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
```

[zsh-autosuggestions/INSTALL](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)：如果变量 `ZSH_CUSTOM` 未定义或为空，则替换为 `~/.oh-my-zsh/custom`。

```Shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

[How variables inside braces are evaluated](https://unix.stackexchange.com/questions/286335/how-variables-inside-braces-are-evaluated)  

Omitting the `:` drops the "*or null*" part of all these definitions.

This is all described in the [bash(1) manpage](http://man7.org/linux/man-pages/man1/bash.1.html), and in [POSIX](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02).

1. 变量未定义：

```Shell
# 未定义变量
~  $ unset a
# 变量未定义，返回default
~  $ echo "${a:-default}"
default
# 变量未定义，返回default
~  $ echo "${a-default}"
default
```

2. 变量有定义，但为空值（空字符串）

```Shell
# 定义变量，但赋值为空
~  $ a= # a=''
# 变量a已定义，但值为空，返回a
~  $ echo "${a:-default}"
default
# 变量a已定义，返回a——空值
~  $ echo "${a-default}"

~  $
```

3. 定义变量，且非空值

```Shell
# 定义变量，且有赋值（非空），返回a
~  $ a=test
~  $ echo "${a:-default}"
test
~  $ echo "${a-default}"
test
```

4. 变量未定义或为空，赋默认值

```Shell
# 变量未定义，赋默认值
~  $ unset a
~  $ echo "${a:=default}"
default
~  $ echo $a
default

# 变量为空值，赋默认值
~ $ echo $a
default
~ $ a=''
~ $ echo "${a:=default}"
default
```

The `+` form might seem strange, but it is useful when constructing variables in several steps:

```Shell
PATH="${PATH}${PATH:+:}/blah/bin"
```

will add `:` before `/blah/bin` only if PATH is non-empty, which avoids having a path starting with `:`.

- 如果 PATH 未定义或为空，则什么也不做，第一个环境变量不用添加冒号前缀分隔符；  
- 如果 PATH 有定义或非空，则相当于在现有 PATH 后面追加变量：`PATH=${PATH}:/blash/bin`；  

### default

以下是一段来自生产实践中的sh脚本，基于 `:=` 来给未定义或空值变量赋默认值兜底：

```Shell
    # 兜底启动角色和模式
    echo "role = ${role:=client}"
    echo "mode = ${mode:=debug}"

    # 兜底默认服务和代理端口
    echo "web_port = ${web_port:=8080}"
    echo "proxy_port = ${proxy_port:=8010}"
```

以下sh脚本中调用get_lan_ip函数，预期其中会定义未export的全局变量lan_ip。

```Shell
    get_lan_ip
    echo "lan_ip = $lan_ip"
```

由于无法确保第三方脚本中的其他函数是否定义了该变量，ShellCheck 会报引用安全警告：

[SC2154](https://github.com/koalaman/shellcheck/wiki/SC2154): lan_ip is referenced but not assigned.

如果局域网 LAN IP 获取不到，往往意味着网络服务不可用，可以使用 `:?` 进行判空警告。

```Shell
    echo "lan_ip = ${lan_ip:?unset or null}"
```

这样，如果 lan_ip 未定义或为空值，则直接报错中止退出（exit 1）。

```
Wi-Fi en0 : status=inactive
./scripts/proxy/launch_shelf.sh: line 33: lan_ip: unset or null
```

### read

我们来看一下 [How to read from a file or standard input in Bash](https://stackoverflow.com/questions/6980090/how-to-read-from-a-file-or-standard-input-in-bash) 这个问题，优先从文件读入参数，否则从stdin接受输入。

Read either the first argument or from stdin

`file=${1--}`（`file=${1:--}`，等效于 `${1:-/dev/stdin}`），可理解为 `[ "$1" ] && file=$1 || file="-"`。

以下脚本，从文件$1或stdin读取数据传给cat，然后输出到文件$2或stdout。

```Shell
cat "${1:-/dev/stdin}" > "${2:-/dev/stdout}"
```

## 字符串长度

字符串长度计算表达式：`${#string}`

```
$ file_path=/Users/faner/Downloads/iosdeploy_download/Documents/2905558360/image_original_flash
$ echo $file_path
/Users/faner/Downloads/iosdeploy_download/Documents/2905558360/image_original_flash
```

字符串长度：

```
# echo ${#file_path}
83
$ strlen=${#file_path}
$ echo $strlen
83
```

`unset string1` 或 `string1=""` 时，字符串长度为0。
`string1=" "` 时，字符串长度为1。

```
$ if [ ${#string1} -gt 0 ]
then
    print 'hello'
else
    print 'world'
fi
```

## 索引区间

> 注意：字符串的索引从0开始。

表达式 | 含义
-------|---
`${string:offset}`          | 在 $string 中, 从索引位置 position 开始提取子串至末尾
`${string:offset:length}`   | 在 $string 中, 从索引位置 position 开始提取，总计 length 个字符的子串

```Shell
$ man bash

       ${parameter:offset}
       ${parameter:offset:length}
              Substring Expansion.  Expands to up to length characters of parameter starting at the  charac-
              ter specified by offset.  If length is omitted, expands to the substring of parameter starting
              at the character specified by offset.  length  and  offset  are  arithmetic  expressions  (see
              ARITHMETIC EVALUATION below).  length must evaluate to a number greater than or equal to zero.
              If offset evaluates to a number less than zero, the value is used as an offset from the end of
              the  value of parameter.  If parameter is @, the result is length positional parameters begin-
              ning at offset.  If parameter is an array name indexed by @ or *, the  result  is  the  length
              members of the array beginning with ${parameter[offset]}.  A negative offset is taken relative
              to one greater than the maximum index of the specified array.  Note  that  a  negative  offset
              must  be  separated  from  the colon by at least one space to avoid being confused with the :-
              expansion.  Substring indexing is zero-based unless the positional  parameters  are  used,  in
              which case the indexing starts at 1.
```

从左向右截取子串：

- `${str:0:1}`: 表示从左边第1个字符开始，截取1个字符，即第一个字符。  
- `${str:0:5}`：表示从左边第1个字符开始，截取5个字符。  
- `${str:7}`：表示从左边第8个字符开始，一直到结尾。  

从右向左截取子串：

- `${str:0-1:1}`: 表示从右边第1个字符开始，截取1个字符，即最后一个字符。  
- `${str:0-2:2}`: 表示从右边第2个字符开始，截取2个字符，即末尾两个字符。  
- `${str:0-5}`：表示从右边第5个字符开始，一直到结尾。  
- `${str:0-7:5}`：表示从右边第7个字符开始，截取5个字符。  

```Shell
name="this is my name";
# 1:4 从第2个开始 到索引4截止
$ echo ${name:1:5}
his i
# 不能省略开始索引
$ echo ${name::4}
zsh: closing brace expected
# ::4 从第一个字符开始 往后截取4个字符
$ echo ${name:0:4}
this
```

## 索引位置

[Linux shell 获得字符串所在行数及位置](https://www.cnblogs.com/xiaolincoding/p/11366274.html)

可以借助 awk 中的 `index` 函数，在 awk 的 BEGIN 中针对 shell 字符串变量进行操作：

```
$ str='uellevcmpottcap'
$ str1='ott'
$ awk 'BEGIN{print index("'${str}'","'${str1}'") }'
```

当然，也可以将 shell 变量传递作为 awk 变量，在 awk 脚本内部操作变量：

> [shell 查找字符串中字符出现的位置](https://www.cnblogs.com/sea-stream/p/11403014.html)

```
$ a="The cat sat on the mat"
$ test="cat"
$ index=`awk -v a="$a" -v b="$test" 'BEGIN{print index(a,b)}'`
$ echo $index
5
```

**注意**：返回的索引从 1 开始。

## [字符串拼接](https://www.cnblogs.com/wuac/p/11121709.html)

字符串五种拼接模式：

```Shell
#!/bin/bash
name="Shell"
str="Test"

str1=$name$str      #中间不能有空格
str2="$name $str"   #如果被双引号包围，那么中间可以有空格
str3="$name: $str"
str4=$name": "$str  #中间可以出现别的字符串
str5="${name}Script: ${str}" #这个时候需要给变量名加上大括号

echo $str1
echo $str2
echo $str3
echo $str4
echo $str5
```

运行结果：

```
ShellTest
Shell Test
Shell: Test
Shell: Test
ShellScript: Test
```

经常需要在shell环境变量 `PATH` 中头插或追加第三方工具的路径：

```
# testPATH 初始值
pi@raspberrypi:~ $ testPATH=/usr/bin:/bin:/usr/sbin:/sbin

# 头部插入
pi@raspberrypi:~ $ testPATH=/usr/local/bin:$testPATH

# 尾部追加
pi@raspberrypi:~ $ testPATH=${testPATH}:/usr/local/sbin
```

## 字符串包含

[Shell判断字符串包含关系的几种方法](https://blog.csdn.net/iamlihongwei/article/details/59484029)  
[Shell判断字符串是否包含小结](https://blog.csdn.net/Primeprime/article/details/79625306)  
[shell判断字符串包含关系](https://zhuanlan.zhihu.com/p/51708411)  

### 利用通配符

`[[ ]]`: 判断命令  

```Shell
#!/bin/bash

A="helloworld"
B="low"
if [[ $A == *$B* ]]
then
    echo "包含"
else
    echo "不包含"
fi
```

### 利用字符串运算符

`=~`: 正则式匹配符号  

```Shell
#!/bin/bash

strA="helloworld"
strB="low"
if [[ $strA =~ $strB ]]
then
    echo "包含"
else
    echo "不包含"
fi
```

### 利用grep查找

```Shell
#!/bin/bash

strA="long string"
strB="string"
result=$(echo $strA | grep "${strB}")
#if [[ "$result" != "" ]]
#if [ "$result" != "" ]
#if [ -n "$result" ]
if [ $? -eq 0 ] && [ -n "$result" ]
then
    echo "包含"
else
    echo "不包含"
fi
```

### 利用 case in 语句

```Shell
#!/bin/bash

thisString="1 2 3 4 5" # 源字符串
searchString="1 2" # 搜索字符串
case $thisString in 
    *"$searchString"*) echo Enemy Spot ;;
    *) echo nope ;;
esac
```

### 运用替换运算

```Shell
#!/bin/bash

STRING_A=$1
STRING_B=$2
if [[ ${STRING_A/${STRING_B}//} == $STRING_A ]]
then
    ## is not substring.
    echo N
    return 0
else
    ## is substring.
    echo Y
    return 1
fi
```

## [字符串截取](https://blog.csdn.net/qq_33951180/article/details/68059098)

### 截左留右

`#` 和 `##` 号截断左边留取右边子串（非贪婪模式，贪婪模式）

```Shell
$ man bash

       ${parameter#word}
       ${parameter##word}
              The word is expanded to produce a pattern just as in pathname expansion. If the pattern 
              matches the beginning of the value of parameter, then the result of the expansion is the 
              expanded value of parameter with the shortest matching pattern (the ``#'' case) or the longest 
              matching pattern (the ``##'' case) deleted. If parameter is @ or *, the pattern removal oper-
              ation is applied to each positional parameter in turn, and the expansion is the resultant 
              list. If parameter is an array variable subscripted with @ or *, the pattern removal opera-
              tion is applied to each member of the array in turn, and the expansion is the resultant list.

```

表达式 | 含义
---------|----------
`${string#substring}`	| 从变量 $string 的开头, 删除最短匹配 $substring 的子串
`${string##substring}`	| 从变量 $string 的开头, 删除最长匹配 $substring 的子串

> 其中 substring 可以是一个正则表达式。

```
$ file_path=/Users/faner/Downloads/iosdeploy_download/Documents/2905558360/image_original_flash
$ suffix=${file_path#*iosdeploy_download}
$ echo $suffix
/Documents/2905558360/image_original_flash
```

### 截右留左

`%` 和 `%%` 号截断右边留取左边子串（非贪婪模式，贪婪模式）

```Shell
$ man bash

       ${parameter%word}
       ${parameter%%word}
              The word is expanded to produce a pattern just as in pathname expansion. If the pattern 
              matches a trailing portion of the expanded value of parameter, then the result of the expan-
              sion is the expanded value of parameter with the shortest matching pattern (the ``%'' case) or 
              the longest matching pattern (the ``%%'' case) deleted. If parameter is @ or *, the pattern 
              removal operation is applied to each positional parameter in turn, and the expansion is the 
              resultant list. If parameter is an array variable subscripted with @ or *, the pattern 
              removal operation is applied to each member of the array in turn, and the expansion is the 
              resultant list.

```

表达式 | 含义
---------|----------
`${string%substring}`	| 从变量 $string 的结尾, 删除最短匹配 $substring的子串
`${string%%substring}`	| 从变量 $string 的结尾, 删除最长匹配 $substring 的子串

> 其中 substring 可以是一个正则表达式。

```
$ file_path=/Users/faner/Downloads/iosdeploy_download/Documents/2905558360/image_original_flash
$ prefix=${file_path%/Documents/*}
$ echo $prefix
/Users/faner/Downloads/iosdeploy_download
```

### refs

[bash shell字符串的截取](https://www.cnblogs.com/liuweijian/archive/2009/12/27/1633661.html)  
[Shell字符串截取](http://c.biancheng.net/view/1120.html) - 非常详细  
[shell截取字符串的方法](https://www.jianshu.com/p/4ceca1a2d265)  

[Linux Shell 截取字符串](https://www.cnblogs.com/fengbohello/p/5954895.html)  
[Shell脚本8种字符串截取方法总结](https://www.jb51.net/article/56563.htm)
[shell脚本查找、抽取指定字符串的方法](https://blog.csdn.net/u011006622/article/details/85048488)  

[extract substring using regex in shell script](https://stackoverflow.com/questions/40422067/extract-substring-using-regex-in-shell-script)  
[How to extract a value from a string using regex and a shell?](https://stackoverflow.com/questions/3320416/how-to-extract-a-value-from-a-string-using-regex-and-a-shell)  

[Extract word from string using grep/sed/awk](https://askubuntu.com/questions/697120/extract-word-from-string-using-grep-sed-awk)  
[How to extract string following a pattern with grep, regex or perl](https://stackoverflow.com/questions/5080988/how-to-extract-string-following-a-pattern-with-grep-regex-or-perl)  

## 字符串替换

[字符串操作 ${} 的截取，删除和替换](https://www.jianshu.com/p/2305fc9351c2)  
[Shell脚本中替换字符串等操作](https://blog.csdn.net/jeffiny/article/details/83271889)  

```Shell
$ man bash

       ${parameter/pattern/string}
              The pattern is expanded to produce a pattern just as  in  pathname  expansion.   Parameter  is
              expanded and the longest match of pattern against its value is replaced with string.  If Ipat-
              tern begins with /, all matches of pattern are replaced with string.  Normally only the  first
              match  is  replaced.  If pattern begins with #, it must match at the beginning of the expanded
              value of parameter.  If pattern begins with %, it must match at the end of the expanded  value
              of  parameter.   If string is null, matches of pattern are deleted and the / following pattern
              may be omitted.  If parameter is @ or *, the substitution operation is applied to  each  posi-
              tional  parameter  in turn, and the expansion is the resultant list.  If parameter is an array
              variable subscripted with @ or *, the substitution operation is applied to each member of  the
              array in turn, and the expansion is the resultant list.

```

expr    | note
--------|--------
`${string/substring/replacement}`  | 使用 $replacement, 代替第一个匹配的 $substring
`${string//substring/replacement}` | 使用 $replacement, 代替所有匹配的 $substring
`${string/#substring/replacement}` | 如果 $string 的前缀匹配 $substring, 那么就用 $replacement 来代替匹配到的 $substring
`${string/%substring/replacement}` | 如果 $string 的后缀匹配 $substring, 那么就用 $replacement 来代替匹配到的 $substring

### 普通替换

`${string/match_string/replace_string}`: 将 string 中第一个 match_string 替换成 replace_string；  
`${string//match_string/replace_string}`: 将 string 中的 match_string 全部替换成 replace_string；  

```
$ str=123abc123
$ echo "${str/123/r}"
rabc123
$ echo "${str//123/r}"
rabcr
```

将 `2905558360/FileRecv` 中的 / 替换为 -；

```
> str='2905558360/FileRecv'
> echo $str
2905558360/FileRecv

> echo "${str/\//-}"
2905558360-FileRecv
```

### 前后缀替换

`${string/#match_string/replace_string}`: 将 string 中第一个 match_string 替换成 replace_string  
`${string/%match_string/replace_string}`: 将 string 中最后一个 match_string 替换成 replace_string  

```
$ str=123abc123
$ echo "${str/#123/r}"
rabc123
$ echo "${str/%123/r}"
123abcr
```

### demo

doc_subdir 字符串值为 "2015952713/FileRecv" 或 "/2015952713/FileRecv/"，如果是后者需要移除首尾的 `/`：

1. 去掉开头的 `/` 两种方法：

- 截左留右：`sub_dir=${sub_dir#/}`;  
- 前缀替换为空：`sub_dir=${sub_dir/#\//}`;  

2. 去掉结尾的 `/` 两种方法：

- 截右留左：`sub_dir=${sub_dir%/}`;  
- 后缀替换为空：`sub_dir=${sub_dir/%\//}`;  

```Shell
    sub_dir=$doc_subdir
    if [ ${sub_dir:0:1} = "/" ]   # 去掉开头的 /
    then
        sub_dir=${sub_dir#/} # sub_dir=${sub_dir/#\//}
    fi
    if [ ${sub_dir:0-1:1} = "/" ] # 去掉结尾的 /
    then
        sub_dir=${sub_dir%/} # sub_dir=${sub_dir/%\//}
    fi
    
    sub_folder="/Documents/$sub_dir/" # 拼接沙盒路径
```

移除首尾的 `/` 后，要生成临时文件名，中间的 `/` 需要全部替换为 `-`：

```Shell
    file_name=${sub_dir//\//-} # 替换 / 为 -
    ls_out_file="./ios-deploy-list-Documents-$file_name.txt"
```

## trim spaces

如何移除字符串两侧的空格呢？

[How to trim string in bash](https://linuxhint.com/trim_string_bash/)  
[How to trim whitespace from a Bash variable?](https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable)  
[How do I trim leading and trailing whitespace from each line of some output?](https://unix.stackexchange.com/questions/102008/how-do-i-trim-leading-and-trailing-whitespace-from-each-line-of-some-output)  

参考 [Linux Pipeline（管道）](../pipeline/Pipelines.md) 中的 `tr` 命令，可采用 `| tr -s '[:space:]'` 或 `| tr -d '[:space:]'` 压缩/移除所有的空格。

```Shell
$ echo "  0xDEADBEEF" | tr -d ' '
0xDEADBEEF
$ echo "0xFEEDBABE    " | tr -d '[:space:]'
0xFEEDBABE%
$ echo "  0xDEADBEEF   0xFEEDBABE    " | tr -d '[:space:]'
0xDEADBEEF0xFEEDBABE%
$ echo "  0xDEADBEEF   0xFEEDBABE    " | tr -s '[:space:]'
 0xDEADBEEF 0xFEEDBABE
```

无论是 `tr -d` 还是 `tr -s`，对于只想移除首尾空格的处理都不够理想，此时可以改用 `xargs` 命令。

默认情况下，`xargs` 将其标准输入中的内容以空白(包括空格、tab、回车换行等)分割成多个 arguments 之后当作命令行参数传递给其后面的命令。基于这一原理，可以采用 ` | xargs` 移除首尾和中间的无效空格。

```Shell
$ echo "  0xDEADBEEF" | xargs
0xDEADBEEF
$ echo "0xFEEDBABE    " | xargs
0xFEEDBABE
$ echo "  0xDEADBEEF   0xFEEDBABE    " | xargs
0xDEADBEEF 0xFEEDBABE
```

### 字符串截取

可以基于bash内置提供的变量替换之字符串截取，来实现移除字符串首尾空格。

```Shell
trim()
{
    local trimmed="$1"

    # Strip leading spaces.
    while [[ $trimmed == ' '* ]]; do
       trimmed="${trimmed## }"
    done
    # Strip trailing spaces.
    while [[ $trimmed == *' ' ]]; do
        trimmed="${trimmed%% }"
    done

    echo "$trimmed"
}
```

### sed

sed 的强项就文本行替换移除，基于sed可很直观地实现这一目标。

```Shell
echo "  BAADDAAD   FEEDBABE    DEADBEEF     " | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'
echo "  BAADDAAD   FEEDBABE    DEADBEEF     " | sed -e 's/^[[:blank:]]*//' -e 's/[[:blank:]]*$//'
echo "  BAADDAAD   FEEDBABE    DEADBEEF     " | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'
```

```Shell
function ltrim ()
{
    sed -E 's/^[[:space:]]+//'
}

function rtrim ()
{
    sed -E 's/[[:space:]]+$//'
}

function trim ()
{
    ltrim | rtrim
}
```

### awk

另外，基于 awk 提供的 sub（gsub）替换函数也可实现这一目标。

```Shell
echo "  BAADDAAD   FEEDBABE    DEADBEEF     " | awk '{gsub(/^[ \t]+/,""); gsub(/[ \t]+$/,""); print $0 }'
echo "  BAADDAAD   FEEDBABE    DEADBEEF     " | awk '{gsub(/^[[:blank:]]+|[[:blank:]]+$/,""); print $0 }'
echo "  BAADDAAD   FEEDBABE    DEADBEEF     " | awk '{gsub(/^[[:blank:]]+|[[:blank:]]+$/,"")}1'
```

参考 awk [trim](https://gist.github.com/andrewrcollins/1592991) 函数。

[注意以下脚本会把中间的空格压缩](https://unix.stackexchange.com/a/205854)：

```Shell
echo "  BAADDAAD   FEEDBABE    DEADBEEF     " | awk '{$1=$1};1'
```

> when you assign something to one of the fields, awk rebuilds the whole record (as printed by print) by joining all fields (`$1`, ..., `$NF`) with `OFS` (space by default).
