---
title: config clash.service on rpi4b-ubuntu
authors:
  - xman
date:
    created: 2024-05-01T10:00:00
categories:
    - ubuntu
comments: true
---

In this article I am going to write down where to download clash and how to configure the clash.service on a raspberry pi 4b(armv8/ubuntu).

<!-- more -->

As per usual, here is the background information on the platform.

```bash
$ echo $MACHTYPE
aarch64

$ arch
aarch64

$ cat /etc/issue
Ubuntu 22.04.4 LTS \n \l

# cat /etc/os-release
$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 22.04.4 LTS
Release:	22.04
Codename:	jammy

$ uname -a
Linux rpi4b-ubuntu 5.15.0-1055-raspi #58-Ubuntu SMP PREEMPT Sat May 4 03:52:40 UTC 2024 aarch64 aarch64 aarch64 GNU/Linux
```

## install clash

Since the original repository of [Dreamacro/clash](https://github.com/Dreamacro/clash) was removed by the author under pressure from the autocratic authorities, we can no longer use it.

But remember that the Internet has memory. Thanks to the [Wayback Machine](https://web.archive.org/), we can download the backup of [clash-linux-armv8-v1.7.1.gz](https://web.archive.org/web/20231003084307/https://github.com/Dreamacro/clash/releases/tag/v1.7.1).

> It's a bit outdated, but it still works. You can compile it yourself if you have the time, as [Clash Meta core have armv8/arm64 support](https://github.com/clash-verge-rev/clash-verge-rev/issues/19).

List compressed file contents:

```bash
$ gzip -l ~/Downloads/clash-linux-armv8-v1.7.1.gz
         compressed        uncompressed  ratio uncompressed_name
            3167003             8781824  63.9% /home/pifan/Downloads/clash-linux-armv8-v1.7.1

$ 7z l ~/Downloads/clash-linux-armv8-v1.7.1.gz

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=en_US.UTF-8,Utf16=on,HugeFiles=on,64 bits,4 CPUs LE)

Scanning the drive for archives:
1 file, 3167003 bytes (3093 KiB)

Listing archive: /home/pifan/Downloads/clash-linux-armv8-v1.7.1.gz

--
Path = /home/pifan/Downloads/clash-linux-armv8-v1.7.1.gz
Type = gzip
Headers Size = 28

   Date      Time    Attr         Size   Compressed  Name
------------------- ----- ------------ ------------  ------------------------
2021-09-15 20:29:46 .....      8781824      3167003  clash-linux-armv8
------------------- ----- ------------ ------------  ------------------------
2021-09-15 20:29:46            8781824      3167003  1 files

```

Unpack `clash-linux-armv8-v1.7.1.gz` using one of the following commands：

```bash
# auto delete gz after decompress
gzip -d clash-linux-armv8-v1.7.1.gz
gunzip clash-linux-armv8-v1.7.1.gz

# specify output dir, keep original gz
7z e clash-linux-armv8-v1.7.1.gz -o./clash
```

View file properties and permissions:

```bash
$ file clash-linux-armv8-v1.7.1
clash-linux-armv8-v1.7.1: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, stripped

$ ls -l .
total 12484
-rw-r--r-- 1 pifan pifan 8781824  Apr 28 08:27 clash-linux-armv8-v1.7.1

```

Add `x` permission to `clash-linux-armv8` to make it executable：

```bash
$ chmod +x clash-linux-armv8-v1.7.1

$ ls -l .
total 12484
-rwxr-xr-x 1 pifan pifan 8781824  Apr 28 08:27 clash-linux-armv8-v1.7.1

```

Move `clash-linux-armv8` to `/usr/local/bin/` ( PATH visible) as `clash`:

```bash
$ sudo mv clash-linux-armv8-v1.7.1 /usr/local/bin/clash

$ which clash
/usr/local/bin/clash
```

View help message and version info:

```bash
$ clash --help
Usage of clash:
  -d string
    	set configuration directory
  -ext-ctl string
    	override external controller address
  -ext-ui string
    	override external ui directory
  -f string
    	specify configuration file
  -secret string
    	override secret for RESTful API
  -t	test configuration and exit
  -v	show current version of clash

$ clash -v
Clash v1.7.1 linux arm64 with go1.17 Wed Sep 15 12:22:57 UTC 2021
```

## start run clash

When you execute the `clash` command for the first time, it will automatically create the configuration directory `~/.config/clash` and generate the default configuration file `config.yaml` and a GeoIP database named `Country.mmdb`.

```bash
$ clash
INFO[0000] Can't find config, create a initial config file
INFO[0000] Can't find MMDB, start download
FATA[0030] Initial configuration directory error: can't initial MMDB: can't download MMDB: Get "https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb": dial tcp 59.24.3.174:443: i/o timeout
```

Copy(`scp` thru SSH) the ready-made configuration file of [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) from macOS.

```bash
$ mkdir ~/.config/clash

$ mv config.yaml Country.mmdb ~/.config/clash

```

Run `clash` again, it should output log INFO like the following if it was started successfully.

```bash
$ clash
INFO[0000] Start initial compatible provider PROXY
INFO[0000] Start initial compatible provider FINAL
INFO[0000] Start initial compatible provider Hijacking
INFO[0000] HTTP proxy listening at: [::]:7890
INFO[0000] SOCKS proxy listening at: [::]:7891
INFO[0000] RESTful API listening at: 127.0.0.1:9090

```

Now that `clash` is running as well as expected, the best thing to do is to enable the Raspberry Pi to automatically start `clash` when it boots up.

You can type `crontab -e` to add a cron task entry `@reboot /usr/local/bin/clash -d /etc/clash` to accomplish this.

Here we copy the configuration files to the user-independent folder `/etc/clash` for global use.

```bash
# sudo cp -r ~/.config/clash /etc
sudo mkdir /etc/clash
sudo cp ~/.config/clash/* /etc/clash

$ ls -l /etc/clash
total 5780
-rw-r--r-- 1 root root   41420  Apr 28 09:38 config.yaml
-rw-r--r-- 1 root root 5870252  Apr 28 09:38 Country.mmdb
```

The most common way to do this is to install a [systemd](https://manpages.ubuntu.com/manpages/noble/en/man1/systemd.1.html) service.

## clash.service

Create a new systemd service `clash.service` to control the clash process, specifying the configuration directory with the `-d` option.

```bash
$ sudo vim /etc/systemd/system/clash.service

[Unit]
Description=Clash-v1.7.1
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Restart=on-abort
ExecStart=/usr/local/bin/clash -d /etc/clash

[Install]
WantedBy=multi-user.target
```

After configuring the service file, you can use the `systemctl` command to manage the service.

```bash
sudo systemctl start clash.service
sudo systemctl stop clash.service
sudo systemctl restart clash.service
sudo systemctl reload clash.service

# enable service @boot
sudo systemctl enable clash.service

# disable service @boot
sudo systemctl disable clash.service

# view status
systemctl status clash.service

# reload the systemd module after modifying the service
systemctl daemon-reload

# remove systemd service unit cfg
sudo rm /etc/systemd/system/clash.service
```

View service running status:

```bash
$ systemctl status clash
● clash.service - Clash-v1.7.1
     Loaded: loaded (/etc/systemd/system/clash.service; disabled; vendor preset: enabled)
     Active: active (running) since Wed 2024-04-28 09:46:01 CST; 2s ago
   Main PID: 167302 (clash)
      Tasks: 8 (limit: 742)
     Memory: 3.0M
        CPU: 154ms
     CGroup: /system.slice/clash.service
             └─167302 /usr/local/bin/clash -d /etc/clash

Apr 28 09:46:01 rpi4b-ubuntu systemd[1]: clash.service: Deactivated successfully.
Apr 28 09:46:01 rpi4b-ubuntu systemd[1]: Stopped Clash-v1.7.1.
Apr 28 09:46:01 rpi4b-ubuntu systemd[1]: Started Clash-v1.7.1.
Apr 28 09:46:01 rpi4b-ubuntu clash[167302]: time="2024-04-28T09:46:01+08:00" level=info msg="Start initial compatible provider FINAL"
Apr 28 09:46:01 rpi4b-ubuntu clash[167302]: time="2024-04-28T09:46:01+08:00" level=info msg="Start initial compatible provider Hijacking"
Apr 28 09:46:01 rpi4b-ubuntu clash[167302]: time="2024-04-28T09:46:01+08:00" level=info msg="Start initial compatible provider PROXY"
Apr 28 09:46:01 rpi4b-ubuntu clash[167302]: time="2024-04-28T09:46:01+08:00" level=info msg="HTTP proxy listening at: [::]:7890"
Apr 28 09:46:01 rpi4b-ubuntu clash[167302]: time="2024-04-28T09:46:01+08:00" level=info msg="SOCKS proxy listening at: [::]:7891"
Apr 28 09:46:01 rpi4b-ubuntu clash[167302]: time="2024-04-28T09:46:01+08:00" level=info msg="RESTful API listening at: 127.0.0.1:9090"
```

Run `journalctl` to query the *systemd* journal for details: `journalctl -xeu clash.service`.

Create symlink for boot load:

```bash
$ sudo systemctl enable clash
Created symlink /etc/systemd/system/multi-user.target.wants/clash.service → /etc/systemd/system/clash.service.
```

Try to visit web ui through RESTful API:

```bash
$ curl 127.0.0.1:9090
{"hello":"clash"}

# need clash-dashboard
$ curl 127.0.0.1:9090/ui
404 page not found
```

**Side Notes**: Kill the previously started process named `clash` with `sudo killall -9 clash` if it reports `bind: address already in use` errors.

## cmd_proxy.sh

For ease of use, you can add proxy shell commands to `/etc/environment`.

Here I write some proxy cmd alias in `$ZSH_CUSTOM/scripts/cmd_proxy.sh`:

```bash title="cmd_proxy.sh"
#!/usr/bin/env bash

################################################################################
# Setting up proxy for the cmdline terminal
# Usage：
#   1. Import the script in terminal using source command
#   2. Modify the network config information as needed
################################################################################

# predefined variables
loopback="127.0.0.1"
lan_proxy_ip="192.168.0.110"
mixed_port=7890
http_port=$mixed_port
https_port=$mixed_port
socks_port=$((mixed_port+1))
lan_socks_port=$mixed_port

# view proxy status
show_cmd_proxy() {
    echo "http_proxy=$http_proxy"
    echo "https_proxy=$https_proxy"
    echo "all_proxy=$all_proxy"
    echo "no_proxy=$no_proxy"
}

# set up proxy for cmdline terminal (clash)
alias set_clash_proxy="unset_cmd_proxy_q; export http_proxy=http://$loopback:$http_port; export https_proxy=http://$loopback:$https_port; export all_proxy=socks5://$loopback:$socks_port; export no_proxy='127.0.0.1, localhost, *.local, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12'; echo 'Set proxy successfully'"

# set up proxy for cmdline terminal (lan)
alias set_lan_proxy="unset_cmd_proxy_q; export http_proxy=http://$lan_proxy_ip:$http_port; export https_proxy=http://$lan_proxy_ip:$https_port; export all_proxy=socks5://$lan_proxy_ip:$lan_socks_port; export no_proxy='127.0.0.1, localhost, *.local, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12'; echo 'Set proxy successfully'"

# unset proxy
alias unset_cmd_proxy_q="unset http_proxy; unset https_proxy; unset all_proxy; unset no_proxy;"
alias unset_cmd_proxy="unset_cmd_proxy_q; echo 'Unset proxy successfully'"
```

Then append `source $ZSH_CUSTOM/scripts/cmd_proxy.sh` to `~/.zshrc`:

```bash
$ grep cmd_proxy ~/.zshrc
source $ZSH_CUSTOM/scripts/cmd_proxy.sh
```

After that, the handy proxy commands `show_cmd_proxy`, `set_clash_proxy`, `set_lan_proxy` and `unset_cmd_proxy` are available.

## passability test

Detect your external IP address with `curl`.

```bash
# curl ip.sb
# curl ip.gs
# curl cip.cc
# curl ifconfig.me
# curl cloudflare.com/cdn-cgi/trace
```

Prior to `set_clash_proxy` or `set_lan_proxy`, the damn GFW would block the connection and throw back `Network is unreachable` or `Connection timed out` when trying to cross the border.

```bash
# curl -v --connect-timeout 10 ifconfigg.appspot.com

$ git pull
fatal: unable to access 'https://github.com/clash-verge-rev/clash-verge-rev.git': GnuTLS recv error (-110): The TLS connection was non-properly terminated.

$ curl -v --connect-timeout 10 google.com
*   Trying 46.82.174.69:80...
* After 9984ms connect time, move on!
* connect to 46.82.174.69 port 80 failed: Connection timed out
* Connection timeout after 10001 ms
* Closing connection 0
curl: (28) Connection timeout after 10001 ms

$ curl -v --connect-timeout 10 https://api.telegram.org
*   Trying 162.125.80.6:443...
*   Trying 2a03:2880:f102:183:face:b00c:0:25de:443...
* Immediate connect fail for 2a03:2880:f102:183:face:b00c:0:25de: Network is unreachable
* After 4987ms connect time, move on!
* connect to 162.125.80.6 port 443 failed: Connection timed out
* Failed to connect to api.telegram.org port 443 after 5216 ms: Connection timed out
* Closing connection 0
curl: (28) Failed to connect to api.telegram.org port 443 after 5216 ms: Connection timed out
```

Add `-x|--proxy` option for curl to use the specified proxy, it successfully jailbreaks and connects to the outside world.

```bash
$ curl -x http://127.0.0.1:7890 --connect-timeout 10 ifconfigg.appspot.com
110.114.119.120
```

Running `set_clash_proxy` will export proxy configs to the cmdline terminal.
We don't need to specify proxy for connection to the outside world anymore.

```bash
$ git pull
remote: Enumerating objects: 180, done.
remote: Counting objects: 100% (180/180), done.
remote: Compressing objects: 100% (7/7), done.
remote: Total 94 (delta 51), reused 94 (delta 51), pack-reused 0
Unpacking objects: 100% (94/94), 41.88 KiB | 49.00 KiB/s, done.
...

$ curl -I http://www.google.com
HTTP/1.1 200 OK
...

$ curl --connect-timeout 10 google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>

$ curl -I https://api.telegram.org
HTTP/1.1 200 Connection established
Connection: close
...
```

## references

[使用 Clash 内核](https://notes.mraddict.top/tutorial/clash.html)
[树莓派搭建 Clash 透明代理/网关](https://www.huarzone.com/archives/20/)
[树莓派 Clash 透明代理(TProxy)](https://mritd.com/2022/02/06/clash-tproxy/)
[树莓派4B Ubuntu 中使用 Clash 实现科学上网教程](http://www.okey56.com/post/28.html)
[Set up Clash Client on Your Raspberry Pi 4](https://kevinxli.medium.com/set-up-clash-client-on-your-raspberry-pi-4-54e77f7f7fe4)

[Clash 服务运行 - Clash.Rev Docs](https://merlinkodo.github.io/Clash-Rev-Doc/startup/service/)
[Clash 以 systemd 服务的方式开机自启](https://github.com/Sitoi/SystemdClash)
[/etc/systemd/system/clash.service](https://gist.github.com/mayocream/8d7a01440f59e4d85771f74e23ad4744)
[一个支持节点与订阅链接的 Linux 命令行代理工具](https://github.com/mzz2017/gg)
