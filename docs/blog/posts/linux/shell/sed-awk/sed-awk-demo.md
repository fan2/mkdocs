---
title: Linux Command - sed & awk demos
authors:
  - xman
date:
    created: 2019-11-05T10:30:00
categories:
    - wiki
    - linux
tags:
    - sed
    - awk
comments: true
---

Linux 下的 sed & awk 命令综合运用示例。

<!-- more -->

[sed & awk](https://www.oreilly.com/library/view/sed-awk/1565922255/)  
[Sed and Awk 101 Hacks](https://vds-admin.ru/sed-and-awk-101-hacks) - [ebook](https://www.thegeekstuff.com/sed-awk-101-hacks-ebook/)  

## networksetup

MacBook/macOS 下执行 `networksetup -listallhardwareports` 列举输出的 hardwareports：

```Shell
$ networksetup -listallhardwareports

Hardware Port: Wi-Fi
Device: en0
Ethernet Address: 61:e8:2d:ed:34:5e

Hardware Port: Bluetooth PAN
Device: en3
Ethernet Address: 61:e8:2d:ed:34:5f
```

MacBook/macOS 下执行 `networksetup -listallhardwareports` 列举输出的 networkservice：

```Shell
$ networksetup -listnetworkserviceorder
An asterisk (*) denotes that a network service is disabled.
(1) Wi-Fi
(Hardware Port: Wi-Fi, Device: en0)

(2) Bluetooth PAN
(Hardware Port: Bluetooth PAN, Device: en3)

(3) Thunderbolt Bridge
(Hardware Port: Thunderbolt Bridge, Device: bridge0)
```

如果是 iMac，有线网口往往是 en0，无线网口是 en1。

如何提取有线网口（Ethernet）和无线网卡（Wi-Fi）的接口名称呢？

基本思路：

1. networksetup -listallhardwareports：定位到 `Hardware Port: Wi-Fi` 所在行，再对下一行提取第二个域。  
2. networksetup -listnetworkserviceorder：定位到 `Hardware Port: Wi-Fi` 所在行，提取 Device: 后面的设备名。  

以下以获取 wlan 接口为例，如果要获取 eth 接口，请将 `Wi-Fi` 替换为 `Ethernet` 即可。

### dev

#### sed

可以基于 sed 实现：

```Shell
$ networksetup -listallhardwareports | sed -n '/Hardware Port: Wi-Fi/{n;p
pipe quote> }' | sed -n 's/^.*: //p' # sed 's/Device: //'
en0
# 先定位 Hardware Port: Wi-Fi 这一行，再管传 sed 提取 Device 后的设备名
$ networksetup -listnetworkserviceorder | sed -n '/Hardware Port: Wi-Fi/p' | sed 's/.*Device: \(.*\))/\1/'
en0
```

sed 进行替换删减时，替换的部分尽量少用 `Device: ` 这样的具体文本，多用 `^.*: ` 这种正则表达式进行模式匹配。

#### awk

```Shell
$ networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}'
en0
# 基于 sub 把收尾的括号去掉，去最后一个域
$ networksetup -listnetworkserviceorder | awk '/Hardware Port: Wi-Fi/{sub(/\(/, ""); sub(/\)/, ""); print $NF}'
# 先定位 Hardware Port: Wi-Fi 这一行，以(,)切割，取第三个域，再取冒号空格后的设备名
$ networksetup -listnetworkserviceorder | awk -F '[(,)]' '/Hardware Port: Wi-Fi/{print $(NF-1)}' | awk '{print $NF}'
en0
# 取巧一下：以(空格)切割，直接取第六个域
$ networksetup -listnetworkserviceorder | awk -F '[( )]' '/Hardware Port: Wi-Fi/{print $(NF-1)}'
```

对于固定格式的字段分割域值提取，还是 awk 稍显简洁。

### SSID

可对无线网口继续调用 `networksetup -getairportnetwork en0` 获取当前连接的 Wi-Fi 网络：

```Shell
$ networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}' | xargs networksetup -getairportnetwork
Current Wi-Fi Network: HiWiFi-5
```

#### sed

以上结果重定向给 sed，替换删除掉冒号前面的部分即可提取 SSID：

```Shell
$ | sed -n 's/^.*: //p'
```

#### awk

以上结果重定向给 awk，可提取 SSID：

```Shell
# 基于默认的空格分割
$ | awk '{print $NF}' # $4
# 基于 `: ` 分割
$ | awk -F ": " '{print $NF}' # $2
```

## airport

以下为 `airport -I` 输出的无线网络信息：

```Shell
$ airport -I
     agrCtlRSSI: -35
     agrExtRSSI: 0
    agrCtlNoise: -92
    agrExtNoise: 0
          state: running
        op mode: station
     lastTxRate: 867
        maxRate: 1300
lastAssocStatus: 0
    802.11 auth: open
      link auth: wpa2-psk
          BSSID: 94:d9:b4:fe:d4:57
           SSID: HiWiFi-5
            MCS: 9
        channel: 157,80
```

假如想提取各个字段的值，按照默认的FS分割，`op mode`、`802.11 auth`、`link auth` 这些将失效。
需要按照 `: ` 作为 FS 分割。

```Shell
$ airport -I | awk -F ': ' '{print $1}'
     agrCtlRSSI
     agrExtRSSI
    agrCtlNoise
    agrExtNoise
          state
        op mode
     lastTxRate
        maxRate
lastAssocStatus
    802.11 auth
      link auth
          BSSID
           SSID
            MCS
        channel

$ airport -I | awk -F ': ' '{print $2}'
-35
0
-92
0
running
station
867
1300
0
open
wpa2-psk
94:d9:b4:fe:d4:57
HiWiFi-5
9
157,80
```

### field 1

思考：如何去掉 `$1` 的前缀空格或制表符呢？

**思路1**：

基于 [sed](https://unix.stackexchange.com/questions/102008/how-do-i-trim-leading-and-trailing-whitespace-from-each-line-of-some-output) 首尾正则替换：

```Shell
$ airport -I | awk -F ': ' '{print $1}' | sed 's/^[ \t]*//;s/[ \t]*$//'
```

**思路2**：

基于 awk 的 sub 函数进行替换：

```Shell
$ airport -I | awk -F ': ' '{sub(/^[ \t\r\n]+/, "", $1); sub(/[ \t\r\n]+$/, "", $1); print $1}'
```

### SSID

进一步思考，如何提取指定域 SSID 的值，即获取当前连接的 Wi-Fi 名称呢？

基本思路：过滤出 SSID 那一行，再提取第二个域。

#### sed

```Shell
# 移除开头空格及 SSID: 
$ airport -I | sed -n 's/^ *SSID: //p'
HiWiFi-5

$ airport -I | sed -e "s/^ *SSID: //p" -e d
HiWiFi-5
```

注意 `sed -n 's/^.*SSID: //p'` 将会提取 SSID 和 BSSID。

- `sed -n 's/^ *SSID: //p'` 将会匹配 SSID；  
- `sed -n 's/^ *BSSID: //p'` 将会匹配 BSSID；  

#### awk

```Shell
$ airport -I | grep ' SSID' | awk '{print $2}'
HiWiFi-5
```

可省掉 grep，进一步简写为基于 awk 进行模式匹配过滤的表达式：

```Shell
$ airport -I | awk '/ SSID/{print $2}'
HiWiFi-5
```

## system_profiler

在 macOS 下，除了基于 networksetup 和 airport 之外，还可以基于 system_profiler 来获取当前连接的网络名称：

```Shell
$ system_profiler SPAirPortDataType | grep 'Current Network Information:' -A 2
          Current Network Information:
            HiWiFi-5:
              PHY Mode: 802.11ac
```

### sed

基于 sed 查找到 `Current Network Information:` 的下一行，再进行掐头去尾：

```Shell
$ system_profiler SPAirPortDataType | sed -n '/Current Network Information:/{n;p
}' | sed -n 's/^ *//p' | sed -n 's/:$//p'
```

### awk

基于 awk 的 sub 函数进行替换；

```Shell
$ system_profiler SPAirPortDataType | awk '/Current Network Information:/{getline; sub(/:/,"",$1); print $1}'
```

## ifconfig

基于 networksetup 获取无线网口名称，再调用 ifconfig 获取网络地址等信息（可通过重定向 xargs 传参）。

基本思路：找到对应网口 `en0`，提取第二个域值。

### sed

基于 sed 掐头去尾，可提取 IP 地址信息：

```Shell
$ ifconfig en0 | grep 'inet ' | sed 's/^.*inet //' | sed 's/ netmask.*//'
$ ifconfig en0 | sed -n '/inet /p' | sed 's/^.*inet //' | sed 's/ netmask.*//'
192.168.0.107
```

> `grep 'inet '` 也可用 `sed -n '/inet /p'` 替代。

### awk

用 awk 提取更加简洁：

```Shell
ifconfig en0 | awk '/inet /{print $2}'
192.168.0.107
```

### 综合示例

脚本 get_lan_ip.sh 将以上串联起来，先获取网口设备名，再判断网口状态，最后获取网络IP地址。

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

在该脚本中，先使用 `grep -q` 预匹配在役网口列表，以判断是否存在有线网口，存在再获取有线网卡接口名称（eth_dev）。

```Shell
# get_lan_ip.sh
get_lan_ip() {

        # 判断是否存在有线网口
        local has_eth=false
        networksetup -listallnetworkservices | grep -q 'Ethernet'
        if [ $? -eq 0 ]; then
            has_eth=true
        fi

        # 获取有线网卡接口名称

}
```

## udid

`ios-deploy -c` 打印连接的 iOS 设备信息：

```Shell
$ ios_device=`ios-deploy -c`
$ echo $ios_device
[....] Waiting up to 5 seconds for iOS device to be connected
[....] Found f45d8fa32cab22b136c86116f20d875f7e93ef52 (D10AP, iPhone 7, iphoneos, arm64) a.k.a. 'iPhone7Fan' connected through USB.
```

### sed

基于 sed 的 n 命令，[提取第二行](https://blog.csdn.net/WMSOK/article/details/78463199)：

```Shell
$ second_line=`echo $ios_device| sed -n 'n;p'`
$ echo $second_line
[....] Found f45d8fa32cab22b136c86116f20d875f7e93ef52 (D10AP, iPhone 7, iphoneos, arm64) a.k.a. 'iPhone7Fan' connected through USB.
```

再基于 sed 对第2行掐头去尾提取:

```Shell
$ udid=`echo $second_line | sed 's/.* Found //' | sed 's/ (.*//'`
$ echo $udid
f45d8fa32cab22b136c86116f20d875f7e93ef52
$ echo ${#udid}
40
```

### awk

基于 awk 对第2行指定 FS=`Found ` 分割提取：

```Shell
# sub 替换空格后面的部分为空
$ udid=`echo $second_line | awk -F "Found " '{sub(/ .*/, "", $2);print$2}'`
# 重定向二次基于默认的空格分割提取
$ udid=`echo $second_line | awk -F "Found " '{print$2}' | awk '{print $1}'`
```

仔细观察可知，包含 udid 的第二行本身就是基于空格排版的，可进一步精简 awk 语句。
直接基于 awk 正则过滤出包含 `Found` 的第2行，再打印分割域 field 3 即可。

```Shell
$ udid=`ios-deploy -c | awk '/Found/{print $3}'`
```
