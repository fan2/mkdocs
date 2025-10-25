---
title: Linux Command - sed iacds
authors:
  - xman
date:
    created: 2019-11-04T10:00:00
categories:
    - wiki
    - linux
tags:
    - sed
comments: true
---

Linux 下的 sed 命令基本操作。

- i: insert before;  
- a: append after;  
- c: change line;  
- d: delete line;  
- s: substitute;  

<!-- more -->

## i(nsert)

插入命令（insert）在指定行之前插入新行。  
插入文本时，不能指定范围，只允许通过一个地址模式指定插入位置。  

debian/raspberrypi 下可单行输入：

```bash
# raspberrypi
$ echo "Test Line 2" | sed 'i Test Line 1'
Test Line 1
Test Line 2

$ echo "Test Line 2" | sed 'i\Test Line 1'
Test Line 1
Test Line 2
```

macOS 下单行执行，提示命令 i 后面预期跟一个 `\`：

```bash
# macOS
$ echo "Test Line 2" | sed 'i Test Line 1'
sed: 1: "i Test Line 1": command i expects \ followed by text
```

i 后面添加反斜杠 `\`，又提示 `\` 后不能有内容：

```bash
# macOS
$ echo "Test Line 2" | sed 'i\Test Line 1'
sed: 1: "i\Test Line 1": extra characters after \ at the end of i command
FAIL: 1
```

需要在 `\` 处换行，跨行折行输入：

```bash
# macOS
$ echo "Test Line 2" | sed 'i\
pipe quote> Test Line 1'
Test Line 1Test Line 2

# 需要显式换行

$ echo "Test Line 2" | sed 'i\
pipe quote> Test Line 1
pipe quote> '
Test Line 1
Test Line 2
```

下面示例插入新行到文件的第三行前：

```bash
$ cat data6.txt
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.
```

```bash
# macOS 需要显式换行
$ sed '3i\
quote> This is an inserted line.
quote> ' data6.txt
This is line number 1.
This is line number 2.
This is an inserted line.
This is line number 3.
This is line number 4.
```

### 插入多行

以下示例在所有find查找到的cpp文件头部补插一条标准的版权声明：

```bash
# macOS
$ find . -name "*.cpp" -print0 | xargs -I file -0 sed -i '' '1i\
// Tencent is pleased to support the open source community by making Mars available.\
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.\

' file
```

> 注意：中间多行末尾需要添加反斜杠续行！

## a(ppend)

追加命令（append）在指定行之后添加新行。  
附加文本时，不能指定范围，只允许通过一个地址模式指定附加位置。  

debian/raspberrypi 下可单行输入；macOS 下需折行输入：

```bash
# raspberrypi 下单行输入
$ echo "Test Line 2" | sed 'a Test Line 1'
# macOS 需要显式换行
$ echo "Test Line 2" | sed 'a\
pipe quote> Test Line 1
pipe quote> '
Test Line 2
Test Line 1
```

下面示例添加新行到文件的第三行后：

```bash
# raspberrypi 下单行输入
## 行号和命令之间的空格可有可无
$ sed '3 a This is an appened line.' data6.txt
## 命令和追加文本之间需要空格或反斜杠
$ sed '3a This is an appened line.' data6.txt
$ sed '3a\This is an appened line.' data6.txt

# macOS 需要显式换行
$ sed '3 a\
quote> This is an appened line.
quote> ' data6.txt
This is line number 1.
This is line number 2.
This is line number 3.
This is an appened line.
This is line number 4.
```

### 追加多行

以下在第三行后追加两行，注意添加必要的反斜杠续行符：

```bash
# raspberrypi 下单行输入
$ sed '3a append line 1\nappend line 2' data6.txt
# 以下换行写法，append line 1后需添加续行符，否则 append line 2 被解读成 a(ppend line 2)
# 第3行后追加 append line 1，其他行后都非预期追加了 ppend line 2。
$ sed '3 a append line 1
append line 2' data6.txt
This is line number 1.
ppend line 2
This is line number 2.
ppend line 2
This is line number 3.
append line 1
ppend line 2
This is line number 4.
ppend line 2

# macOS 需要a后面显示换行，append line 2 后面的续行符可选
$ sed '3 a\
quote> append line 1\
quote> append line 2
quote> ' data6.txt
This is line number 1.
This is line number 2.
This is line number 3.
append line 1
append line 2
This is line number 4.
```


## c(hange)

修改命令（change）允许修改数据流中整行文本的内容。
它和插入、附加命令的工作机制一样，你必须在 sed 命令中单独指定新行。

debian/raspberrypi 下可单行输入；macOS 下需折行输入：

```bash
# raspberrypi
$ sed '3 c This is a changed line.' data6.txt
$ sed '3c This is a changed line.' data6.txt
$ sed '3c\This is a changed line.' data6.txt
# macOS需要显式换行
$ sed '3c\
quote> This is a changed line.
quote> ' data6.txt
This is line number 1.
This is line number 2.
This is an changed line.
This is line number 4.
```

## d(elete)

删除命令（delete）可以删除文本流中的特定（匹配）行。

```bash
$ sed '3d' data6.txt
This is line number 1.
This is line number 2.
This is line number 4.
```

- `sed '2,3d' data6.txt` : 删除特定行区间；  
- `sed '3,$d' data6.txt` : 删除特定行至文末；  
- `sed '/number 1/d' data6.txt` : 删除模式匹配行；  
- `sed '/^$/d' data6.txt` : 删除模式匹配（空白）行；  

### pattern range

`sed '/1/,/3/d' data6.txt` : 删除两个模式匹配区间的行；  

对于删除模式匹配区间行，第1个模式会 **打开** 行删除功能，第2个模式会 **关闭** 行删除功能。
sed 编辑器会删除两个指定行之间的所有行（包括指定的行）。

需要特别注意的是，只要匹配到了开始模式，删除功能就会打开，这可能导致意外的结果。
如果开始模式触发了删除，但是没有找到停止模式，那么会将数据流剩余行全部删除。

例如以下命令可以过滤打印 git 冲突文件中 ours 部分：

```bash
$ sed -n '/^<<<<<<< HEAD$/,/^=======$/p' Git-Conflict.h
```

但是将 p 替换为 d 命令，尝试删除 ours 部分？未能如愿，删除全文，输出为空。

---

[Sed – Deleting Multiline Patterns](https://gryzli.info/2017/06/26/sed-deleting-multiline-patterns/)

考虑工程根目录下有以下 code owner 的 CR 配置文件 `bak.code.yml`：

```YAML
- path: /Classes/ui/DeviceMgr/PrinterTableView.h
  owners:
  - zhangsan
  - lisi
  - wangwu
  owner_rule: 1
- path: /Classes/ui/DeviceMgr/PrinterTableView.m
  owners:
  - zhangsan
  - lisi
  - wangwu
  owner_rule: 1
- path: /Classes/ui/DeviceMgr/PrinterDeviceCell.h
  owners:
  - zhangsan
  - lisi
  - wangwu
  owner_rule: 1
- path: /Classes/ui/DeviceMgr/PrinterDeviceCell.m
  owners:
  - zhangsan
  - lisi
  - wangwu
  owner_rule: 1

```

以下 sed 语句从 bak.code.yml 中查找匹配目录 `/Classes/ui/DeviceMgr/` 对应的 CR 规则区块：

```bash
sed -n '/- path: \/Classes\/ui\/DeviceMgr\//,/owner_rule/p' bak.code.yml
```

移除以上匹配的 CR owner 规则区块，并直接回写到原文件：

```bash
# 回写之前，备份到 bak.code.yml.bak
sed -i '.bak' '/- path: \/Classes\/ui\/DeviceMgr\//,/owner_rule/d' bak.code.yml

# 指定备份扩展名为空，即不备份
sed -i '' '/- path: \/Classes\/ui\/DeviceMgr\//,/owner_rule/d' bak.code.yml
```

## s(ubstitue)

在 [string](../../program/8-sh-string.md) 提到 bash 支持内置的模式匹配替换（`${parameter/pattern/string}`），详情参考 man bash 中的 Parameter Expansion 一节。

sed支持s命令（substitue），对文本行执行模式匹配和替换。

```bash
s/pattern/replacement/flags

[address[，address]] s/pattern-to-find/replacement-pattern/[n g p w]
```

有4种可用的替换标记：

- `n`：表明新文本将替换第n处模式匹配的地方，标记可指定替换每行中出现的第n处；  
- `g`：表明新文本将替换所有模式匹配的地方，标记指定替换每行中匹配的所有地方；  
- `p`：表明原先行的内容要打印出来，一般搭配 `-n` 使用；  
- `w`：file，将匹配替换的结果写到文件中。  

> 不指定 flags 时，默认只替换每行中出现的第一处。

以下示例，用 `s` 命令实现字符串替换：

```bash
$ echo "This is a test" | sed 's/test/big test/'
This is a big test
```

以下示例将文件中的 `dog` 替换为 `cat`。

```bash
$ cat detail.txt
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
```

基于bash字符串模式匹配替换的写法如下：

```bash
$ sentence="The quick brown fox jumps over the lazy dog"
$ echo $sentence
The quick brown fox jumps over the lazy dog

$ echo ${sentence/dog/cat}
The quick brown fox jumps over the lazy cat
```

基于 sed 的替换命令写法如下：

```bash
$ sed 's/dog/cat/' detail.txt
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
```

> 当 replacement 为空时，相当于删除效果。

以下示例将 AAA 替换为空，相当于移除：

```bash
# 基于bash字符串模式匹配替换
$ test_text="12312312343242AAAdfasdfasdfasdfasdfadAAAfsdgfsdfgfgfgdfgasdfg"
$ echo ${test_text//AAA/}
12312312343242dfasdfasdfasdfasdfadfsdgfsdfgfgfgdfgasdfg

# 基于 sed 替换的写法如下
$ echo "12312312343242AAAdfasdfasdfasdfasdfadAAAfsdgfsdfgfgfgdfgasdfg" | sed 's/AAA//g'
12312312343242dfasdfasdfasdfasdfadfsdgfsdfgfgfgdfgasdfg
```

以下是一些典型的 s 命令查找删除示例：

- `sed 's/^.//g docs.txt'`：删除行首的一个字符；  
- `sed 's/^[0-9]//g docs.txt'`：删除行首的一个数字；  
- `sed 's/^0*//g docs.txt'`：删除行首的所有0；  
- `sed 's/\.$//g' docs.txt`：删除行尾的句点；  
- `sed 's/##*//g' dos.txt`：删除两个及以上的 `#` 号；  
- `sed 's/-*//g docs.txt'`：删除所有的横线-；  

### 多重替换模式

当需要同时匹配多个模式时，可以使用连续重定向管道传递：

```bash
$ cat detail.txt | sed 's/brown/green/' | sed 's/dog/cat/'
```

执行两次 s 替换命令，多条命令之间用分号（`;`）隔开：

```bash
$ sed 's/brown/green/; s/dog/cat/' detail.txt
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
```

也可基于次提示符来跨行输入，每一行是一条独立命令，行尾不用输入分号。

```bash
$ sed '
quote> s/brown/green/
quote> s/fox/elephant/
quote> s/dog/cat/' detail.txt
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
```

也可以使用 `-e` 选项：

```
$ sed -e 's/brown/green/' -e 's/fox/elephant/' -e 's/dog/cat/' detail.txt
```

### 替换模式分隔符

有时你会在文本字符串中遇到一些不太方便在替换模式中使用的字符。  
替换文件中的路径名会比较麻烦。例如，用 csh 替换 /etc/passwd 文件中的 bash：

```bash
sed 's/\/bin\/bash/\/bin\/csh/' /etc/passwd
```

由于正斜线（`/`）通常用作路径分隔符，因而如果它出现在了模式文本中的话，必须用反斜线来转义。  
sed 编辑器允许指定其他字符作为替换分隔标记符：

```bash
sed 's!/bin/bash!/bin/csh!' /etc/passwd
```

上述示例中，感叹号 `!` 被用作s命令分隔符，也可以使用 `#` 号。

### 匹配模式整体引用

如果想引用替换命令中匹配的模式部分，可以使用 `&` 符号引用。
`&` 命令保存发现模式以便在替换模式中引用。

基于 `&` 符号引用，可支持在匹配的模式前后附加内容。
典型的例子是，对匹配的文本添加括号、引号等对称封闭标签。

以下示例，给单词 c(h)at 添加双引号：

```bash
$ echo "The cat sleeps in his hat." | sed 's/.at/"&"/g'
The "cat" sleeps in his "hat".
```

#### before

在匹配部分的前面插入内容：

```bash
$ sed 's/line number/head &/g' data6.txt
This is head line number 1.
This is head line number 2.
This is head line number 3.
This is head line number 4.
```

如果想在行首插入，则要这么写：

```bash
$ sed 's/.*line number/head &/g' data6.txt
# 或
$ sed 's/.*line number.*/head &/g' data6.txt
head This is line number 1.
head This is line number 2.
head This is line number 3.
head This is line number 4.
```

#### after

在匹配部分的后面插入内容：

```bash
$ sed 's/line number/& tail/g' data6.txt
This is line number tail 1.
This is line number tail 2.
This is line number tail 3.
This is line number tail 4.
```

在行尾后面插入内容：

```
$ sed 's/line number.*/& tail/g' data6.txt
This is line number 1. tail
This is line number 2. tail
This is line number 3. tail
This is line number 4. tail
```

### 分组子模式前向引用

`&` 命令会提取匹配替换命令中指定模式的整个字符串，但有时候可能只想提取这个字符串的一部分。

sed 编辑器用圆括号来定义替换模式中的子模式，替代表达式中用反斜杠和数字表明子模式位置。

以下示例，将 System Administrator 替换为 System User：

```bash
$ echo "The System Administrator manual" | sed 's/\(System\) Administrator/\1 User/'
The System User manual
```

以下示例，将 c(h)at 前面的 furry 移除：

```bash
$ echo "That furry cat is pretty" | sed 's/furry \(.at\)/\1/'
That cat is pretty

$ echo "That furry hat is pretty" | sed 's/furry \(.at\)/\1/'
That hat is pretty
```

以下示例为 macOS 下提取 Wi-Fi 接口名，将整体替换成匹配的部分：

```bash
networksetup -listnetworkserviceorder | sed -n '/Hardware Port: Wi-Fi/p' | sed 's/(.*Device: \(.*\))/\1/'
# 将过滤和替换合并在一起：
networksetup -listnetworkserviceorder | sed -n '/Hardware Port: Wi-Fi/s/(.*Device: \(.*\))/\1/p'
```

以下使用 sed 过滤目标行并使用模式替换移除前缀。

```bash
local nwi_prefix="Network interfaces: "
# 1. 先管传 sed/grep 模式匹配再管传执行 s 命令将整体替换成匹配的部分
# scutil --nwi | sed -n "/$nwi_prefix/p" | sed "s/$nwi_prefix\(.*\)/\1/")
# 2. 先模式匹配再执行 s 命令将前缀替换为空的合并写法
scutil --nwi | sed -n "/$nwi_prefix/s/$nwi_prefix//p"
```

#### insert

以下示例通过 sed 的正则循环匹配，在数字之间添加千位分隔符（Thousands Separators）。

Thousands-Separators

```
$ echo "12345678" | sed '{
pipe quote> :start
pipe quote> s/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/
pipe quote> t start
pipe quote> }'
12,345,678
```

以上正则表达式匹配两个子模式：

1. 第一个子模式是以数字结尾的任意长度字符；  
2. 第二个子模式是三位数字；  

如果这两种模式匹配找到了，则在它们之间添加一个逗号：`12345,678` - `12,345,678`。

这里用到了跳转标签和测试命令：

1. 如果匹配成立，满足 t 测试条件，则回跳到标签 start 处循环执行下一次匹配。  
2. 直到最后一次，未匹配上不满足 t 测试条件，运行至大括号结束。  

#### extract

index.html 中 base href 的格式为 `<base href="/baseUrl/">`，如何提取 href 的值 `/baseUrl/` ？

**分析**：左侧为固定的起始边界 `<base href="`，右侧为固定结束边界 `">`，中间是需要提取的 `/baseUrl/` 部分。

将中间需要提取的部分视作一个分组子模式，然后将整行替换为中间的部分，即实现了子模式提取。

> **注意**：需要考虑开头和结尾的空白字符。

```bash
$ sed 's/^.*<base href="\(.*\)">.*$/\1/' index.html
# 模拟测试用例
$ echo '<base href="/">' | sed 's/^.*<base href="\(.*\)">.*$/\1/'
$ echo '<base href="/an:tgit/">' | sed 's/^.*<base href="\(.*\)">.*$/\1/'
```

**思考**：baseUrl 两边可能使用的是单引号，如何改进以同时适配单、双引号的情况？

---

考虑这样一种场景：局域网内的某台服务器（raspi-ubuntu）由于采用了DHCP，如何查找它的IP地址，以便进行SSH连接呢？

假设我们知道设备wifi接口（wlan0）的MAC地址是以 `dc:a6:32` 开头，那么在 SSH 客户端，可以通过 arp 查询该 MAC 地址对应的 IP。

```bash
$ arp -a | grep "dc:a6:32"
? (192.168.0.114) at dc:a6:32:**:**:** on en0 ifscope [ethernet]
```

实际上，arp 命令输出的 ARP 报文格式是固定的，括号中即为对应设备分配占用的 IP 地址。
那么，如何提取这个IP地址呢？

思路同上，将括号中需要提取的部分视作一个分组子模式，然后将整行替换为中间的部分，即实现了子模式提取。

- 界定左侧边界：`.*(`；  
- 界定右侧边界：`).*`；  
- 中间部分括号引用为子模式  

```bash
# sed前向引用，替换提取指定子模式
$ arp -na | grep "dc:a6:32" | sed 's/.*(\(.*\)).*/\1/'
```

#### replace

index.html 中 base href 的格式为 `<base href="/baseUrl/">`，如何将 href 的值替换为 `/an:coding/` ？

**分析**：

1. 左侧起始部分，可分组引用为子模式 \1 = `<base href="`；  
2. 右侧结束部分，可分组引用为子模式 \2 = `">`；  
3. 中间可标记为 `.*`，匹配 href 值部分；  

基于子模式分组引用占位首尾边界，拼接中间部分替换为新的 href 值（`/an:coding/`），即达目的。

```bash
$ sed 's/\(<base href="\).*\(">\)/\1\/an:coding\/\2/' index.html
# 模拟测试用例
$ echo '<base href="/">' | sed 's/\(<base href="\).*\(">\)/\1\/an:coding\/\2/'
$ echo '<base href="/an:tgit/">' | sed 's/\(<base href="\).*\(">\)/\1\/an:coding\/\2/'
```

**思考**：baseUrl 两边可能使用的是单引号，如何改进以同时适配单、双引号的情况？
