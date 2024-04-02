---
title: Linux Shell Program - shellcheck
authors:
  - xman
date:
    created: 2019-11-06T09:00:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程语法检查工具 —— shellcheck。

<!-- more -->

[Google Shell 风格指南](https://zh-google-styleguide.readthedocs.io/en/latest/google-shell-styleguide/contents/)

## Android Studio

Android Studio 打开 sh 脚本时，会建议安装 [Shell Script](https://plugins.jetbrains.com/plugin/13122-shell-script) 插件。

Integration with external tools:

- [ShellCheck](https://github.com/koalaman/shellcheck),  
- [Shfmt](https://github.com/mvdan/sh),  
- [Explainshell](https://explainshell.com/)  

### Reformat

Android Studio 通过菜单 Code - Reformat 可格式化当前文档，macOS 下的 [键盘快捷键](https://developer.android.com/studio/intro/keyboard-shortcuts) 为 ⌘⌥L。
执行格式化当前sh脚本时，会查找当前语言的格式化工具，下载安装 shell script formatter - shfmt。

Shell Script 插件设置的默认缩进为2个空格，可考虑对齐 vscode 等编辑器 [use 4-space wide tab](https://stackoverflow.com/questions/61578404/how-to-use-4-space-wide-tab-character-in-android-studio)，具体到 Prefs Settings -> Editor -> Code Style -> Shell Script 修改 Tab Size 和 Indent 为 4。

## vscode

macOS 下先用 brew 安装 shellcheck 和 shfmt 工具：

- [shellcheck](https://www.shellcheck.net/): Static analysis and lint tool, for (ba)sh scripts  
    - [ShellCheck wiki](https://github.com/koalaman/shellcheck/wiki/)
- [shfmt](https://github.com/mvdan/sh): Autoformat shell script source code  
    - [shfmt documentation](https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd)

```Shell
$ brew install shellcheck
$ brew install shfmt
```

然后在 vscode 中搜索安装 shellcheck 和 shfmt 两个插件：

- [shellcheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)  
- [shfmt](https://marketplace.visualstudio.com/items?itemName=mkhl.shfmt)  

shellcheck 默认配置了 `"shellcheck.run": "onType"`，编写代码时实时检查。

如果遇到 shellcheck 报错，可以在 [Finding documentation for a check](https://github.com/koalaman/shellcheck/wiki/Checks) 点击查询具体某一个 SC 提示说明文档。

在 vscode 中，打开编辑 sh 脚本文件，可通过 `⇧⌘P` 调起控制面板执行 Format Document 命令（快捷键 `⇧⌥F`） 调用 *shfmt* 格式化当前文档。

## cases

以下是 get_lan_ip.sh 脚本中的部分警告分析。

??? note "get_lan_ip.sh"

    ```Shell
    #!/bin/bash

    # shellcheck disable=2034

    # 获取 macOS 本机网口的局域网地址（LAN IP）
    # 支持 Ethernet、Wi-Fi，暂未支持 Thunderbolt Bridge
    ## output: lan_ip
    get_lan_ip() {
        # 简单正则匹配一下IP地址，无法判错 192.168 这种半截地址，
        # 包含了 [ -z "$lan_ip" ] 未定义或为空等情况。
        if ! [[ $lan_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            # 获取有线网卡接口名称
            local has_eth=false
            if networksetup -listallnetworkservices | grep -q 'Ethernet'; then
                has_eth=true
            fi
            local eth_dev=''
            local eth_status='inactive'
            local eth_inet=''
            if [ $has_eth = true ]; then
                eth_dev=$(networksetup -listallhardwareports | awk '/Hardware Port: Ethernet/{getline; print $NF}')
                if [ -n "$eth_dev" ]; then
                    eth_status=$(ifconfig "$eth_dev" | awk '/status:/{print $NF}')
                    if [ "$eth_status" = active ]; then
                        eth_inet=$(ifconfig "$eth_dev" | awk '/inet /{print $2}')
                        echo "Ethernet $eth_dev : status=$eth_status, inet=$eth_inet"
                    else
                        echo "Ethernet $eth_dev : status=$eth_status"
                    fi
                fi
            fi
            # 获取无线网卡接口名称
            local has_wlan=false
            if networksetup -listallnetworkservices | grep -q 'Wi-Fi'; then
                has_wlan=true
            fi
            local wlan_dev=''
            local wlan_status='inactive'
            local wlan_inet=''
            if [ $has_wlan = true ]; then
                wlan_dev=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $NF}')
                if [ -n "$wlan_dev" ]; then
                    wlan_status=$(ifconfig "$wlan_dev" | awk '/status:/{print $NF}')
                    if [ "$wlan_status" = active ]; then
                        # 获取Wi-Fi SSID
                        # local wlan_ssid=$(airport -I | awk '/ SSID/{print $2}')
                        local wlan_ssid=''
                        wlan_ssid=$(networksetup -getairportnetwork "$wlan_dev" | awk '{print $NF}')
                        # 获取 IPv4 地址
                        wlan_inet=$(ifconfig "$wlan_dev" | awk '/inet /{print $2}')
                        echo "Wi-Fi $wlan_dev : status=$wlan_status, ssid=$wlan_ssid, inet=$wlan_inet"
                    else
                        echo "Wi-Fi $wlan_dev : status=$wlan_status"
                    fi
                fi
            fi

            # 根据网口活跃状态，优先获取有线网络
            # if eth not bootped, try get wlan
            if [ $has_eth = true ] && [ "$eth_status" = active ]; then
                if [ -n "$eth_inet" ]; then
                    lan_ip=$eth_inet
                elif [ $has_wlan = true ] && [ "$wlan_status" = active ]; then
                    if [ -n "$wlan_inet" ]; then
                        lan_ip=$wlan_inet
                    fi
                fi
            elif [ $has_wlan = true ] && [ "$wlan_status" = active ]; then
                if [ -n "$wlan_inet" ]; then
                    lan_ip=$wlan_inet
                fi
            fi
        fi
    }
    ```

### SC2070

```Shell
if [ -n $eth_dev ]; then
    ...
fi
```

以上代码片段将报两个警告：

1. [SC2070](https://github.com/koalaman/shellcheck/wiki/SC2070): `-n` doesn't work with unquoted arguments. Quote or use `[[ ]]`.  
2. [SC2086](https://github.com/koalaman/shellcheck/wiki/SC2086): Double quote to prevent globbing and word splitting.  

因为 `eth_dev` 可能未定义（unset），那么此时 $eth_dev 被视为普通字符串，不符合预期。  
根据 ShellCheck 的静态语法警告提示，有两种修复方案：（1）加双引号安全解引用；（2）将单中括号改为双中括号。  

### SC2181

```Shell
        # 判断是否存在有线网口
        local has_eth=false
        networksetup -listallnetworkservices | grep -q 'Ethernet'
        if [ $? -eq 0 ]; then
            has_eth=true
        fi
```

以上代码片段将报警告 [SC2181](https://github.com/koalaman/shellcheck/wiki/SC2181): Check exit code directly with e.g. `if mycmd;`, not indirectly with `$?`.

根据提示，建议不用 `$?` 来判断命令执行状态，而是将命令语句直接放在 if 的 condition 位置：

```Shell
        # 判断是否存在有线网口
        local has_eth=false
        if networksetup -listallnetworkservices | grep -q 'Ethernet'; then
            has_eth=true
        fi
```

### disable

- [Inline ignore messages #145](https://github.com/koalaman/shellcheck/issues/145)  
- [How to suppress irrelevant ShellCheck messages?](https://stackoverflow.com/questions/52659038/how-to-suppress-irrelevant-shellcheck-messages)  

1. 在 get_lan_ip.sh 中引入同目录的脚本 aux_etc.sh，以下相对引入将会报错：

[SC1091](https://github.com/koalaman/shellcheck/wiki/SC1091): Not following: "./aux_etc.sh" was not specified as input (see shellcheck -x).

```Shell
# shellcheck source="./aux_etc.sh"
source "$(dirname "$0")"/aux_etc.sh
```

如果确认逻辑无误，可以加一个行禁用规则 SC1091 的 disable 注释，以便忽略警告：

```Shell
# shellcheck disable=SC1091
# shellcheck source="./aux_etc.sh"
source "$(dirname "$0")"/aux_etc.sh
```

2. 在工具函数脚本 aux_etc.sh 中，可能有些函数内会定义变量，此时 ShellCheck 会报错：

[SC2034](https://github.com/koalaman/shellcheck/wiki/SC2034): foo appears unused. Verify it or export it.

这些变量非 local、非 export，默认为全局变量，调用方可能会引用这些变量。
此时，我们可以注释禁用规则 SC2034，以便忽略相关警告：

```Shell
#!/bin/bash

# shellcheck disable=2034
# shellcheck disable=SC2034

```

也可在一行中忽略多条规则：

```Shell

# shellcheck disable=SC1091,SC2034

```
