---
title: Linux Shell Program - map
authors:
  - xman
date:
    created: 2019-11-06T10:10:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之字典常用操作。

<!-- more -->

## linux

raspi Ubuntu Desktop 21.10 上自带的 bash shell 版本是 5.1.8：

```bash
rpi4b-ubuntu% bash --version
GNU bash, version 5.1.8(1)-release (aarch64-unknown-linux-gnu)
Copyright (C) 2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

[The usage of Linux shell map](https://developpaper.com/the-usage-of-linux-shell-map/)  
[Linux Shell：Map的用法](https://www.cnblogs.com/yy3b2007com/p/11267237.html)  

在 Linux 的 bash 中，可以使用关联数组（associative array）来实现类似 map 或 dict 的功能。

```bash
# 声明一个关联数组
declare -A my_map

# 一次性声明并初始化
declare -A my_map=(
    ["key1"]="value1"
    ["key2"]="value2"
    ["key3"]="value3"
)
```

### 基本操作

```bash
# 添加/修改元素
my_map["name"]="Alice"
my_map["age"]="25"
my_map["city"]="New York"

# 获取元素
echo ${my_map["name"]}    # 输出: Alice
echo ${my_map["age"]}     # 输出: 25

# 获取所有值
echo ${my_map[@]}    # 输出所有值
echo ${my_map[*]}    # 输出所有值

# 获取所有键
echo ${!my_map[@]}   # 输出所有键
echo ${!my_map[*]}   # 输出所有键

# 获取元素数量
echo ${#my_map[@]}   # 输出元素个数
```

### 遍历操作

```bash
# 遍历所有键值对
for key in "${!my_map[@]}"; do
    echo "Key: $key, Value: ${my_map[$key]}"
done

# 遍历所有值
for value in "${my_map[@]}"; do
    echo "Value: $value"
done
```

### 检查键

```bash
# 方法1：使用 -v 检查（bash 4.3+）
if [[ -v my_map["key"] ]]; then
    echo "键存在"
fi

# 方法2：检查值是否为空
if [[ -n "${my_map[key]+x}" ]]; then
    echo "键存在"
fi

# 方法3：更安全的检查
key_to_check="name"
if [[ ${my_map[$key_to_check]+_} ]]; then
    echo "键 $key_to_check 存在，值为: ${my_map[$key_to_check]}"
else
    echo "键 $key_to_check 不存在"
fi
```

### 删除元素

```bash
# 删除单个元素
unset my_map["key1"]

# 清空整个关联数组
unset my_map
declare -A my_map
```

### 完整示例

```bash
#!/bin/bash

# 声明关联数组
declare -A user_info=(
    ["username"]="alice"
    ["uid"]="1001"
    ["home"]="/home/alice"
    ["shell"]="/bin/bash"
)

# 添加更多信息
user_info["group"]="developers"
user_info["email"]="alice@example.com"

# 显示所有信息
echo "=== 用户信息 ==="
for key in "${!user_info[@]}"; do
    printf "%-10s: %s\n" "$key" "${user_info[$key]}"
done

# 检查特定键
if [[ ${user_info["email"]+_} ]]; then
    echo -e "\n邮箱地址: ${user_info["email"]}"
fi

# 修改值
user_info["email"]="alice.new@example.com"
echo "更新后的邮箱: ${user_info["email"]}"

# 删除信息
unset user_info["shell"]
echo -e "\n删除后的键: ${!user_info[@]}"
```

## macOS

[Mac下shell命令支持map](https://www.zengxi.net/2020/01/mac-shell-support-map/)

macOS 自带的bash是3.x版本的：

```bash
$ bash --version
GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin20)
Copyright (C) 2007 Free Software Foundation, Inc.
```

shell中的 declare 命令不支持 `-A` 这个参数，会报下面的错误：

```bash
declare: -A: invalid option
declare: usage: declare [-afFirtx] [-p] [name[=value] ...]
```

可考虑通过 brew 安装最新版本的bash

```bash
brew install bash
```

然后，sh脚本文件开头的 Shebang 注意从 `#!/bin/bash` 替换成 `#!/usr/local/bin/bash`，否则还是用旧版本的bash来执行。

[Mac环境下shell脚本中的map](https://www.jianshu.com/p/a55480b793b0)

macOS 下执行 sh 脚本，declare -A 报错不支持该选项：

```bash
bash-3.2$ sh cmd.sh
d.sh: line 2: declare: -A: invalid option
declare: usage: declare [-afFirtx] [-p] [name[=value] ...]
```

macOS 的默认 Bash 还是3.x版本，不支持map这种数据结构。

所以有两种解决方案：

1. 升级bash到 4.x 以上版本；  
2. 用其他方式：比如 if elif 去到达相同的结果；  

### 字符串模拟

适用于 bash 3.2 的使用字符串模拟关联数组 map：

```bash
#!/usr/bin/env bash

################################################################################
# 定义：使用前缀+键名作为变量名
prefix="map_"

# 设置值
function map_set() {
    local key="$1"
    local value="$2"
    local var_name="${prefix}${key}"
    eval "$var_name='$value'"
}

# 获取值
function map_get() {
    local key="$1"
    local var_name="${prefix}${key}"
    eval "echo \$$var_name"
}

# 检查键是否存在
function map_has() {
    local key="$1"
    local var_name="${prefix}${key}"
    # 如果变量存在（即使值为空），扩展为 x（非空），eval 退出码为零
    # 否则扩展为空字符串（为空），eval 退出码非零
    eval "[[ -n \${$var_name+x} ]]"
}

# 删除键
function map_delete() {
    local key="$1"
    local var_name="${prefix}${key}"
    unset "$var_name"
}

# 获取所有键
function map_keys() {
    compgen -A variable "${prefix}" | sed "s/^${prefix}//"
}
```

### map_set

调用 `map_set` 定义 k:v 键值对：

```bash
#-------------------------------------------------
# key=remote_bucket
map_set "cf_r2_icloud" "cloud.duetorun.com"
#-------------------------------------------------
```

### map_get

调用 `map_has` 判断是否定义了键值对，如果定义了调用 `map_get` 获取自定义域名：

```bash
key=${remote}_${bucket}
if map_has "$key"; then
    custom_domain=$(map_get "$key")
    echo "custom_domain for $key=$custom_domain"
else
    echo "custom_domain for $key=undefined!"
    return 1
fi
```
