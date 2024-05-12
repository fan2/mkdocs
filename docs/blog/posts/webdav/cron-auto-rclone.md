---
title: 基于cron配置rclone自动同步任务
authors:
  - xman
date:
    created: 2024-03-18T15:45:00
    updated: 2024-04-15T17:00:00
categories:
    - macOS
    - ubuntu
    - webDAV
tags:
    - rclone
    - crontab
comments: true
---

在上一篇《[使用rclone访问操作WebDav云盘](./rclone-access-webdav.md)》中，我们系统梳理了强大的 rclone 命令行工具常用命令和惯用法。

本篇介绍在 macOS/ubuntu 下使用 cron 配置定时任务（crontab），实现本地与云盘之间同步备份自动化。

<!-- more -->

## cron/crontab

[Bisync](https://rclone.org/bisync/): On Linux or Mac, consider setting up a crontab entry. `bisync` can safely run in concurrent cron jobs thanks to lock files it maintains.

!!! info "cron, crontab, and cronjob"

    [Difference between cron, crontab, and cronjob?](https://stackoverflow.com/questions/21615673/difference-between-cron-crontab-and-cronjob)

    - `Cron`: Cron comes from chron, the Greek prefix for ‘time’. Cron is a daemon which runs at the times of system boot.
    - `Crontab`: Crontab (CRON TABle) is a file which contains the schedule of cron entries to be run and at specified times. File location varies by operating systems.
    - `Cron job` or `cron schedule`: Cron job or cron schedule is a specific set of execution instructions specifying day, time and command to execute. crontab can have multiple execution statements.

可以通过 [cron](https://en.wikipedia.org/wiki/Cron) / [crontab - tables for driving systemd-cron](https://manpages.ubuntu.com/manpages/noble/en/man5/crontab.5.html) 配置定时任务，每天自动执行同步。

参考 [How to Use Cron to Automate Linux Jobs on Ubuntu 20.04](https://www.cherryservers.com/blog/how-to-use-cron-to-automate-linux-jobs-on-ubuntu-20-04) 和 [How do I set up a Cron job? - Ask Ubuntu](https://askubuntu.com/questions/2368/how-do-i-set-up-a-cron-job)。

ubuntu 系统级别的 crontab 配置文件在 /etc/ 目录下（cron*）：

```Shell
# ls -l /etc/cron*
$ ls -l /etc | grep cron
drwxr-xr-x 2 root root       4096 Nov  6  2022 cron.d
drwxr-xr-x 2 root root       4096 Apr  7 05:00 cron.daily
drwxr-xr-x 2 root root       4096 Nov  6  2022 cron.hourly
drwxr-xr-x 2 root root       4096 Nov  6  2022 cron.monthly
-rw-r--r-- 1 root root       1136 Aug  6  2021 crontab
drwxr-xr-x 2 root root       4096 Nov  6  2022 cron.weekly
```

每个用户有一个以用户名命名的 crontab 配置文件，存放在 `/var/spool/cron/crontabs` 目录下。

macOS 下执行 `man cron`，FILES 显示 Directory for personal crontab files 为 `/usr/lib/cron/tabs`。

```Shell
$ sudo ls -l /usr/lib/cron/
total 0
-rw-r--r--  1 root    wheel   0 Mar 30 15:19 at.deny
-rw-r--r--  1 root    wheel   6 Mar 30 15:19 cron.deny
drwxr-xr-x  2 daemon  wheel  64 Mar 30 15:19 jobs
drwxr-xr-x  2 daemon  wheel  64 Mar 30 15:19 spool
drwx------  3 root    wheel  96 Mar 30 15:19 tabs
drwx------  2 root    wheel  64 Mar 30 15:19 tmp

$ sudo ls -l /usr/lib/cron/tabs

```

## cron/ubuntu

用户可执行 `crontab -e` 打开一个类似 `/tmp/crontab.CNG0fm/crontab` 的临时文件，编辑 personal crontab。

在 rpi4b-ubuntu 上首次执行 `crontab -e`（注意不要 sudo），提示选择编辑器，选择 vim 打开编辑：

```Shell
$ pifan@rpi4b-ubuntu ~
crontab -e
no crontab for pifan - using an empty one

Select an editor.  To change later, run 'select-editor'.
  1. /usr/bin/vim.gtk3
  2. /bin/nano        <---- easiest
  3. /usr/bin/vim.basic
  4. /usr/bin/vim.tiny
  5. /bin/ed

Choose 1-5 [2]: 3
```

文档注释中有关于配置项的说明：

```Shell title="crontab -e Cron Syntax"
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

??? note "man 5 crontab"

    ```Shell
    Instead of the first five fields, one of eight special strings may appear:

        string         meaning
        ------         -------
        @reboot        Run once, at startup.
        @yearly        Run once a year, "0 0 1 1 *".
        @annually      (same as @yearly)
        @monthly       Run once a month, "0 0 1 * *".
        @weekly        Run once a week, "0 0 * * 0".
        @daily         Run once a day, "0 0 * * *".
        @midnight      (same as @daily)
        @hourly        Run once an hour, "0 * * * *".

    `8-11` for an hours entry specifies execution at hours 8, 9, 10 and 11.

    A list is a set of numbers (or ranges) separated by commas. Examples: `1,2,5,9`, `0-4,8-12`.

    `0-23/2` can be used in the hours field to specify command execution every other hour

    if you want to say ``every two hours'', just use `*/2`.

    EXAMPLE CRON FILE
           # run five minutes after midnight, every day
           5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1
           # run at 2:15pm on the first of every month — output mailed to paul
           15 14 1 * *     $HOME/bin/monthly
           # run at 10 pm on weekdays, annoy Joe
           0 22 * * 1-5    mail -s "It's 10pm" joe%Joe,%%Where are your kids?%
           23 0-23/2 * * * echo "run 23 minutes after midn, 2am, 4am ..., everyday"
           5 4 * * sun     echo "run at 5 after 4 every Sunday"
           0 */4 1 * mon   echo "run every 4th hour on the 1st and on every Monday"
           0 0 */2 * sun   echo "run at midn on every Sunday that's an uneven date"
           # Run on every second Saturday of the month
           0 4 8-14 * *    test $(date +\%u) -eq 6 && echo "2nd Saturday"

           # Execute a program and run a notification every day at 10:00 am
           0 10 * * *  $HOME/bin/program | DISPLAY=:0 notify-send "Program run" "$(cat)"
    ```

执行 `crontab -e` 在末尾新增一条测试任务，每分钟执行 echo 写入文件 crontab.log。

```Shell title="crontab -e test"
*/1 * * * * echo "echo from crontab." >> $HOME/Downloads/output/crontab.log
# */1 * * * * echo "$(date) : echo from crontab." >> $HOME/Downloads/output/crontab.log
```

`tail -f crontab.log`，整点分钟观察 crontab.log 是否有追加内容，以验证 cron 任务正常调度。

确认 cron 任务调度正常后，在 cron table 末尾新增一条 rclone 命令测试任务：

```Shell title="crontab -e test rclone"
*/1 * * * * rclone version >> $HOME/Downloads/output/crontab.log
```

整点分钟，观察 crontab.log，确认 rclone version 被 cron 正常调度执行。

每天定点执行 rclone sync，将 webdav 云盘自动同步到外挂硬盘（`/media/WDHD/`）。

```Shell title="crontab -e hourly"
# auto backup every two hours(0,2,4,6,8,10,12,14,16,18,20,22)
# 0 */2 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b >> /var/log/rclone.log 2>&1
0 */2 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone-`date +\%Y\%m\%d`.log
```

如果后续文件改动不是那么频繁，可以改为每天同步一次，日志文件按月命名。

```Shell title="crontab -e daily"
# 每天凌晨1点同步备份
0 1 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone-`date +\%Y\%m`.log
```

输入 `:wq` 保存退出 vim，命令行提示 `crontab: installing new crontab`。

> webdav 编辑大文件时经常出现同步问题导致文件损坏，可指定 `--min-size SizeSuffix` 选项，只备份大于 SizeSuffix（例如 10M）的大文件。

!!! note "关于 rclone 运行日志路径"

    可通过 `--log-file=FILE` 选项指定用户级别的日志路径。
    参考 [Sending cron output to a file with a timestamp in its name](https://serverfault.com/questions/117360/sending-cron-output-to-a-file-with-a-timestamp-in-its-name)，日志文件按天或月命名。
    如若使用全局日志路径 /var/log/rclone.log，则需先 `sudo touch` 再 `sudo chown` 为当前用户组。
    macOS 下的 rclone 运行日志可考虑放到全局日志路径 /usr/local/var/log 下，或放在家目录配置文件夹下。

编辑的 personal crontab 将自动追加到 `/var/spool/cron/crontabs/$USER` 文件中。

执行 `sudo systemctl restart cron.service` 重启 cron 服务（可选）。

!!! note "crontab list & remove"

    执行 `crontab -l` 可以查看当前用户的任务列表，或通过 `-u` 选项查看指定用户的任务列表 `crontab -l -u pifan`。
    执行 `crontab -r` 可以移除当前用户配置的任务列表，或 `crontab -ri` 带 interactive prompt 确认。

### cron run sh

以上 crontab 直接配置命令行运行 rclone 执行网盘同步，下面给出一个 crontab 配置运行 Shell 脚本的范例。

1. 创建用户脚本文件 `touch ~/Scripts/cp-config-to-smb.sh`，每天零点执行 `cp` 命令将 zsh、vim 配置文件同步到外挂硬盘备份文件夹。

    ??? info "cp-config-to-smb.sh"

        ```Shell linenums="1"
        #!/usr/bin/env bash

        backup_config() {
          # config filepath
          config=$1
          # folder=${config%/*}
          filename=${config##*/}
          name=${filename%.*}
          ext=${filename##*.}

          filedate=$(date -r "$config" +%Y%m%d)

          dstfile=""
          if [ -z "$name" ]; then
            dstfile="$dstpath/$host-$filedate.$ext"
          else
            dstfile="$dstpath/$host-$filedate-$name.$ext"
          fi

          # -u: copy only when the SOURCE file is newer than the destination file
          #            or when the destination file is missing
          echo -e "$(date +%Y/%m/%d\ %H:%M:%S): cp sync config $filename" >> "$logfile"
          if cp -v -u "$config" "$dstfile" &>> "$logfile"; then
            echo -e "$(date +%Y/%m/%d\ %H:%M:%S): cp sync success.\n" >> "$logfile"
          else
            echo -e "$(date +%Y/%m/%d\ %H:%M:%S): cp sync failed.\n" >> "$logfile"
          fi
        }

        main() {
          backup_config "$HOME/.zshrc"
          backup_config "$HOME/.vimrc"
          backup_config "/etc/vim/vimrc.local"
        }

        ############################################################
        # main entry
        ############################################################
        # echo "param count = $#"
        # echo "params = $@"

        # 1. make path for logfile
        # echo "dirname = $(dirname $0)"
        dir=$(dirname $0)
        # echo "basename = $(basename $0)"
        name=$(basename $0)
        name=${name%.*}
        logfile=$dir/$name".log"

        # 2. extract hostname, ignore domain
        # echo $HOST
        hostname=$(hostname)
        host=${hostname%%.*}

        # 3. backup destination: mount_smbfs
        dstpath="/media/WDHD/backups/config"

        # 4. main routine entry
        main "$@" # $*
        ```

2. 保存脚本文件后，执行 `chmod +x ~/Scripts/cp-config-to-smb.sh` 添加可执行权限。
3. 执行 `crontab -e` 添加 cron 定时调度任务。

```Shell title="crontab -e daily"
# 1. 本地配置同步到 mount_smbfs, @daily @midnight
0 0 * * * $HOME/Scripts/cp-config-to-smb.sh

# 2. 每天凌晨2点同步备份
0 2 * * * rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone-`date +\%Y\%m`.log
```

## cron/macOS

在 macOS 上首次执行 `crontab -e`，将临时打开一个空文件，默认使用编辑器 /usr/bin/vi。
在末尾新增一条测试任务，每分钟执行 echo(date) 写入文件 crontab.log。

```Shell title="crontab -e test"
*/1 * * * * echo "echo from crontab." >> /Users/faner/Downloads/output/crontab.log
# */1 * * * * echo "$(date) : echo from crontab." >> /Users/faner/Downloads/output/crontab.log
```

保存退回到终端，命令行显示以下内容：

```Shell
$ crontab -e
crontab: no crontab for faner - using an empty one
crontab: installing new crontab
```

执行 `crontab -l` 可以查看配置内容。

> personal crontab 目录下会多出一个以当前用户名（$USER）命名的配置文件，如 /usr/lib/cron/tabs/faner。

整点分钟，观察 crontab.log 是否有追加内容，以验证 cron 任务正常执行。

如果之前未在 macOS 上配置过 cron 服务，大概率会失败，参照下文步骤配置。

### config cron service

!!! note "macOS 下的 cron"

    macOS 下的 cron 是系统启动服务（LaunchDaemons），每次执行 `crontab -e` 编辑保存，都提示需要授权终端管理员权限！

首先从 launchctl list 中查找 cron 服务：

```Shell
$ sudo launchctl list | grep 'cron'
86386	0	com.vix.cron
```

其中第一列是服务进程ID（pid）；第二列是服务状态，0代表正常；第三列是服务plist名。

尝试执行 `locate com.vix.cron` 全局查找 cron 服务的配置文件位置：

```Shell
$ locate com.vix.cron

WARNING: The locate database (/var/db/locate.database) does not exist.
To create the database, run the following command:

  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

Please be aware that the database can take some time to generate; once
the database has been created, this message will no longer appear.
```

按照提示执行加载 `com.apple.locate` 服务，创建一个database：

```Shell
$ sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
```

然后，再次执行 `locate com.vix.cron` 查找到 cron 服务的配置文件位置：

```Shell
$ locate com.vix.cron
/System/Library/LaunchDaemons/com.vix.cron.plist
```

执行 cat 或 vim 查看该配置文件，发现其 PathState 中的 `/etc/crontab` 配置文件默认不存在。

??? info "com.vix.cron.plist"

    ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
     	"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
     	<key>Label</key>
     	<string>com.vix.cron</string>
     	<key>ProgramArguments</key>
     	<array>
     		<string>/usr/sbin/cron</string>
     	</array>
     	<key>KeepAlive</key>
     	<dict>
     		<key>PathState</key>
     		<dict>
     			<key>/etc/crontab</key>
     			<true/>
     		</dict>
     	</dict>
     	<key>QueueDirectories</key>
     	<array>
     		<string>/usr/lib/cron/tabs</string>
     	</array>
     	<key>EnableTransactions</key>
     	<true/>
     </dict>
     </plist>
    ```

执行 `sudo vim /etc/crontab` 创建 `/etc/crontab` 文件，参考 ubuntu 填入以下模版内容：

```Shell title="/etc/crontab"
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
```

!!! note "macOS 重启 cron 服务"

    1. cron 服务开启、关闭、重启：

        - sudo /usr/sbin/cron start
        - sudo /usr/sbin/cron stop
        - sudo /usr/sbin/cron restart

    2. 如果修改了配置文件，执行 launchctl load 命令（可添加 -w 选项）重新加载配置：

        - sudo launchctl load /System/Library/LaunchDaemons/com.vix.cron.plist
        - sudo launchctl unload /System/Library/LaunchDaemons/com.vix.cron.plist

执行完以上配置，再观察检查 crontab.log。

如果还没有内容，可能是该测试命令涉及到写磁盘文件，需要给 cron 授权写磁盘权限。

- [Crontab is not running /usr/local/bin/ script](https://stackoverflow.com/questions/59123499/crontab-is-not-running-local-bin-script-catalina-bigsur)
- [How to Fix Cron Permission Issues in macOS](https://osxdaily.com/2020/04/27/fix-cron-permissions-macos-full-disk-access/)
- [Fixing cron jobs in macOS](https://www.bejarano.io/fixing-cron-jobs-in-mojave/)

!!! note "授权 cron 写磁盘权限"

     1. 执行 `which cron` 查找到 cron 命令的位置：/usr/sbin/cron。
     2. 打开 macOS 设置(System Settings)，隐私与安全性(Privacy & Security)，点进完全磁盘访问权限(Full Disk Access)。
     3. 点按左下角的 + 号，在打开的访达窗口按 ++shift+command+g++ 调出路径访问方式，输入 `/usr/sbin/cron` 回车，找到 cron 命令添加。

正常情况下，到这一步，`tail -f crontab.log` 应该可以看到每分钟追加写入了一行当前日期时间。

### cron test rclone

确认 cron 任务调度正常后，在 cron table 末尾新增一条 rclone 命令测试任务：

```Shell title="crontab -e test rclone"
*/1 * * * * rclone version >> /Users/faner/Downloads/output/crontab.log
```

这一次，没有在 ubuntu 上那么幸运，整点分钟观察 crontab.log，rclone version 没有被 cron 调度执行。

cron 执行出错时默认会通过 MTA 服务给系统管理员发邮件，执行 `vim /var/mail/$USER` 检查当前用户的邮箱。

果然，其中提示找不到 rclone 命令：

```Shell
/bin/sh: rclone: command not found
```

!!! question "为啥 echo/date 和 ubuntu 下的 rclone 能找到呢？"

    1. echo 是内置命令（shell built-in command）。
    2. root 启动的 shell 环境变量预定义在 macOS 下的 `/etc/paths` 和 ubuntu 下的 `/etc/environment`。
    3. date 命令的 owner 为 root，其安装路径在 macOS 为 `/bin/date`，在 ubuntu 为 `/usr/bin/date`，均在 root shell PATH 中。
    4. ubuntu 下执行 `sudo apt install rclone` 以 root 身份安装的 rclone，其 path 为 /usr/bin/rclone，亦在 root shell PATH 中。

在 macOS 下执行 `ls -l $(which rclone)` 或 `stat $(which rclone)` 可以看到当前用户通过 brew 安装的 rclone 路径为 `/usr/local/bin/rclone`，不在 root shell PATH 中，故 root 执行 cron 时找不到 rclone 命令。

将 rclone 命令改为绝对路径 `/usr/local/bin/rclone`，cron 任务调度正常。

```Shell title="crontab -e"
*/1 * * * * /usr/local/bin/rclone version >> /Users/faner/Downloads/output/crontab.log
```

### cron rclone sync

验证 cron 正常调度 rclone 后，接下来在 crontab 中配置 rclone 定时同步备份任务。

编写一个 shell 脚本 /usr/local/etc/scripts/rclone-sync-linkin-words.sh，定时将本地 LINKIN-WORDS-7000 目录下的 PDF 文件同步到局域网 SMB 共享盘（smbhd@rpi4b:）上。

需先执行 `sudo chmod +x rclone-sync-linkin-words.sh` 赋予其他用户对该脚本的可执行权限。

备份脚本 `rclone-sync-linkin-words.sh` 使用 date 或 stat 命令检查文件最后修改时间。

=== "date -r"

    ```Shell
    $ date -r test.txt
    Sat Mar 16 16:53:38 CST 2024

    $ date -r test.txt +%s
    1710579218

    $ date -r test.txt +%Y%m%d%H%M%S
    20240316165338
    ```

=== "macOS: stat -f"

    > `-f format`: Display information using the specified format.  See the Formats section for a description of valid formats.

    ```Shell
    # To display a file's modification time:
    $ stat -f %m test.txt
    1710579218

    # To display the same modification time in a readable format
    $ stat -f %Sm test.txt
    Mar 16 16:53:38 2024

    # To display the same modification time in a readable and sortable format
    $ stat -f %Sm -t %Y%m%d%H%M%S test.txt
    20240316165338
    ```

=== "ubuntu: stat -c"

    > `-c` / --format=FORMAT: use the specified FORMAT instead of the default; output a newline after each use of FORMAT

    ```Shell
    $ stat -c %Y test.txt
    1710579219

    $ stat -c %y test.txt
    2024-03-16 16:53:39.000000000 +0800

    $ date -d "@$(stat -c %Y test.txt)" '+%Y%m%d%H%M%S'
    20240316165339
    ```

如果在最后修改时间到当前时间间隔内（往前-5s）已经有备份，说明最近没有改动，有改动才执行备份。
每次备份成功后，执行 `delete` 滚动老化删除一天之前（--min-age 24h）的旧备份。

!!! question "Why not use filtering flag --max-age?"

    如果执行 sync 或 copy 同步目录，可使用 rclone 提供的 `--max-age 2h` 选项。
    这里执行 copyto 命令备份特定文件，不适用 `--max-age` 选项，故自行等效实现。

??? info "rclone-sync-linkin-words.sh"

    ```Shell linenums="1"
    #!/usr/bin/env bash

    # predefined variables
    logfile="/Users/faner/.config/rclone/rclone-$(date +%Y%m).log"
    filename="恋词考研英语-全真题源报刊7000词-索引红版"
    srcfile="/Users/faner/Documents/English/LINKIN-WORDS-7000/$filename.pdf"
    dstpath="smbhd@rpi4b:WDHD/backups/English"
    dstfile="$dstpath/$filename-$(date +%Y%m%d%H).pdf"

    # curdate=$(date +%Y/%m/%d\ %H:%M:%S)
    curdate_sec="$(date +%s)"

    filedate=$(date -r $srcfile +%Y/%m/%d\ %H:%M:%S)
    filedate_sec="$(date -r $srcfile +%s)"

    passed_sec=$((curdate_sec - filedate_sec))

    elapsed_sec=$passed_sec
    elapsed_min=0
    elapsed_hour=0
    elapsed_day=0
    
    # calculate datediff
    if [ $elapsed_sec -ge 60 ]; then
      elapsed_min=$((elapsed_sec / 60))
      elapsed_sec=$((elapsed_sec % 60))
      if [ $elapsed_min -ge 60 ]; then
        elapsed_hour=$((elapsed_min / 60))
        elapsed_min=$((elapsed_min % 60))
        if [ $elapsed_hour -ge 24 ]; then
          elapsed_day=$((elapsed_hour / 24))
          elapsed_hour=$((elapsed_hour % 24))
        fi
      fi
    fi
    
    # format datediff
    elapsed_time=$(printf '%sd-%sh-%sm-%ss' "$elapsed_day" "$elapsed_hour" "$elapsed_min" "$elapsed_sec")
    echo "$(date +%Y/%m/%d\ %H:%M:%S) DEBUG : $filename.pdf, modification: $filedate, $elapsed_time ago." >> "$logfile"
    
    # check copy during modification
    checkpoint=$((passed_sec + 5)) # rewind for seconds
    lastcopy=$(/usr/local/bin/rclone lsf --max-age=$checkpoint $dstpath)
    # backupcount=$(/usr/local/bin/rclone lsf --max-age=$checkpoint $dstpath | wc -l)
    
    # check modification since last backup
    if [ ${#lastcopy} -ne 0 ]; then # remain unchanged
      echo -e "$(date +%Y/%m/%d\ %H:%M:%S) DEBUG : retain latest backup: $lastcopy\n" >> "$logfile"
    else # spotted gap
      echo -e "$(date +%Y/%m/%d\ %H:%M:%S) DEBUG : execute backup to fill the gap." >> "$logfile"
      if /usr/local/bin/rclone copyto -v "$srcfile" "$dstfile" --log-file="$logfile"; then
        /usr/local/bin/rclone delete -v "$dstpath" --min-age 24h --log-file="$logfile"
      else
        echo -e "$(date +%Y/%m/%d\ %H:%M:%S) DEBUG : backup failed, keep old backups.\n" >> "$logfile"
      fi
    fi
    ```

调试阶段可以 `--dry-run` 相关 rclone 同步命令，先在终端以当前身份执行 rclone-sync-linkin-words.sh，确保运行和输出符合预期。

然后，再在 `crontab -e` 中配置调度任务，先每分钟执行一次，验证调度执行情况。

```Shell title="crontab -e test"
*/1 * * * * /usr/local/etc/scripts/rclone-sync-linkin-words.sh
```

cron 调度任务调试验证 OK 后，再修改调度频率：

```Shell title="crontab -e"
# 1. 本地同步到 SMB, 每隔两小时（7,9,11,13,15,17,19,21,23）
0 7-23/2 * * * /usr/local/etc/scripts/rclone-sync-linkin-words.sh
```

以上脚本执行 rclone copyto，copy from local to remote（upload），读本地写远端，不涉及本地写磁盘权限问题。

再添加一个 rclone sync 同步脚本，将本地当前用户的 zsh、vim、vscode 的配置每天备份到局域网 SMB 共享盘上（smbhd@rpi4b:WDHD/backups/config）。

??? info "rclone-sync-config.sh"

    ```Shell linenums="1"
    #!/usr/bin/env bash

    backup_config() {
      # config filepath
      config=$1
      # folder=${config%/*}
      filename=${config##*/}
      name=${filename%.*}
      ext=${filename##*.}

      filedate=$(date -r "$config" +%Y%m%d)

      if [ -z "$name" ]; then
        dstfile="$dstpath/$host-$filedate.$ext"
      else
        dstfile="$dstpath/$host-$filedate-$name.$ext"
      fi

      # overwriting existing file, skipping identical files
      # -u: Skip files that are newer on the destination
      echo -e "$(date +%Y/%m/%d\ %H:%M:%S) DEBUG : execute backup $filename." >> "$logfile"
      if /usr/local/bin/rclone copyto -v -u "$config" "$dstfile" --log-file="$logfile"; then
        echo -e "$(date +%Y/%m/%d\ %H:%M:%S) DEBUG : backup success.\n" >> "$logfile"
      else
        echo -e "$(date +%Y/%m/%d\ %H:%M:%S) DEBUG : backup failed, keep old backups/config.\n" >> "$logfile"
      fi
    }

    main() {
      zshrc="/Users/faner/.zshrc"
      backup_config $zshrc
      vimrc="/Users/faner/.vimrc"
      backup_config $vimrc
      vscode_settings="/Users/faner/Library/Application Support/Code/User/settings.json"
      backup_config "$vscode_settings"
    }

    ############################################################
    # main entry
    ############################################################
    # echo "param count = $#"
    # echo "params = $@"

    # predefined variables
    logfile="/Users/cliff/.config/rclone/rclone-$(date +%Y%m).log"
    dstpath="smbhd@rpi4b:WDHD/backups/config"

    # extract hostname, ignore domain
    # echo $HOST
    hostname=$(hostname)
    host=${hostname%%.*}

    main "$@" # $*
    ```

再添加一条 rclone sync 调度任务，将远端 webdav 云盘定时同步到本地：

```Shell title="crontab -e"
# 1. 本地配置同步到 SMB, @daily @midnight
0 0 * * * /usr/local/etc/scripts/rclone-sync-config.sh

# 2. 本地文件同步到 SMB, 每隔两小时（7,9,11,13,15,17,19,21,23）
0 7-23/2 * * * /usr/local/etc/scripts/rclone-sync-linking-words.sh

# 3. webdav 同步到本地, 每隔两小时（8,10,12,14,16,18,20,22,0)
0 0,8-23/2 * * * /usr/local/bin/rclone sync -v webdav@rpi4b: /Users/faner/Documents/webdav-backup --log-file=/Users/faner/.config/rclone/rclone-`date +\%Y\%m`.log
```

rclone sync from remote to local（download），涉及写磁盘权限问题，需按照上文的步骤授权 rclone 写磁盘权限。

## check logs

每天检查日志文件，确认系统 cron 定时任务和 rclone sysnc 同步任务执行情况。

系统日志 /var/log/syslog 中，应该有类似的条目：

```dmesg
$ grep -a CRON /var/log/syslog
Apr  7 02:30:00 rpi4b-ubuntu CRON[62328]: (pifan) CMD (rclone sync -v webdav-rpi4b: /media/WDHD/webdav@rpi4b --log-file=/home/pifan/.config/rclone/rclone.log)
```

也可以开启 cron 独立日志，后续直接查看 /var/log/cron.log。

!!! note "Use Independent Crontab Logs"

     1. `sudo vim /etc/rsyslog.d/50-default.conf`
     2. uncomment the line starting with the `cron.*`
     3. `sudo systemctl restart rsyslog`

---

macOS 的系统日志 /var/log/system.log 中没有搜到任何 cron 相关的运行日志。

参考 [macos - Mac OS X cron log / tracking](https://stackoverflow.com/questions/5475800/mac-os-x-cron-log-tracking)，执行 `log show --process cron` 可以看到 crontab/cron 的 Activity 活动日志。

!!! note "cron -x debugflag"

    [macos - Log of cron actions on OS X](https://superuser.com/questions/134864/log-of-cron-actions-on-os-x) 中提到，参考 man cron 中的 `-x debugflag`，可修改 com.vix.cron.plist，为 ProgramArguments 添加 `-x` 调试选项，并配置 StandardErrorPath 为 /var/log/cron.log。尚未具体实践验证。

---

确认 cron 定时任务执行后，再检查配置目录 ~/.config/rclone/ 下当天/月的运行日志 rclone-`date`.log，查看同步情况。

## refs

[调研-分布式任务调度（CRONTAB）](https://yuerblog.cc/2018/04/09/research-about-distributed-crontab/)
[使用 RClone 实现 Unraid 的异地容灾](https://juejin.cn/post/7131650853307416589)
[一个命令让Linux定时打包备份指定目录文件夹并同步备份到各大网盘](https://wzfou.com/vps-one-backup/)

[schedule using crontab on macOS](https://medium.com/@justin_ng/how-to-run-your-script-on-a-schedule-using-crontab-on-macos-a-step-by-step-guide-a7ba539acf76)
[Schedule job with crontab on macOS](https://chethansp.medium.com/schedule-job-with-crontab-on-macos-d47a1fda47e5)
[Linux Crontab: 15 Awesome Cron Job Examples](https://www.thegeekstuff.com/2009/06/15-practical-crontab-examples/)

[记录一次macOS上crontab未成功执行问题的排查过程！](https://blog.humh.cn/?p=947)
[macOS 电脑—设置 crontab](https://zhuanlan.zhihu.com/p/564215492)

online cron schedule expression generator:

- [Cron Guru](https://crontab.guru/)
- [toolfk](https://www.toolfk.com/tools/generate-crontab.html)
- [utils](https://utils.fun/crontab)
