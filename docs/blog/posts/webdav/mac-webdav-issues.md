---
title: macOS上使用WebDav遇到的问题
authors:
  - xman
date:
    created: 2024-03-17T10:10:00
categories:
    - macOS
    - webDAV
tags:
    - webDAV
    - umask
comments: true
---

在 macOS 上基于 Apache Httpd 的 dav 扩展搭建起 webDAV 服务后，使用过程中遇到了一些体验问题：

1. 本地管理员无法修改共享目录问题
2. Finder 挂载 WebDAV 卡死问题

本文记录了问题分析和方案探讨。

<!-- more -->

## 本地无法修改共享目录问题探讨

在服务器配置 WebDav 服务目录 Directory（/Users/faner/Sites/DAVNAS）时，将其 owner 修改为了 httpd 用户（ `_www._www`）。

这样修改后，本地其他用户（包括当前用户）将无法再直接写该目录。当前用户 `faner:staff`  尝试写入时要求密码认证，认证后可以强制写入，但是 owner 就变成了当前用户 faner，httpd 用户 _www 又没有这个文件的写入权限了！

所以，对于 WebDAV 共享服务目录，预期所有用户都统一以 WebDAV 客户形式请求 httpd-dav 服务器以 `_www` 身份对其执行写入操作。带来的不便之处在于，即使服务器本地管理员，也需连接挂载到本地（/Volumes/webdav）之后才能执行写入操作。

!!! danger

    **最简单粗暴的方案**：修改 httpd.conf 中的 User:Group 为当前用户组 faner:staff（共享服务目录相应也需要 chown），即 httpd 以当前用户的身份启动服务，当前用户当然可以直接修改写入共享服务目录。

如果害怕 httpd 以管理员身份运行权限过高甚至为非作歹，最好还是维持 httpd.conf 中默认的 User:Group 配置。那么，我们就得探究其他的变通方案。

这里涉及到 UNX 读写文件的权限控制问题，让我们按照以下步骤探究一下服务器本地和加载的“云盘”下文件（夹）的权限。

1. 使用 `ls -l ` 命令，查看服务器本地共享目录（/Users/faner/Sites/DAVNAS）的权限是 drwxr-xr-x(755)。
2. 登录 WebDAV 服务后，本地挂载点 /Volumes/webdav 下看到的文件（夹）权限是`rwx------`（700），即当前用户拥有对该云盘的全部权限。
3. 向云盘粘贴写入文件后，回到本地共享目录查看，其文件（夹）的 owner 是 _www，文件夹权限是 `drwxr-xr-x`(755)，文件权限是 `-rw-r--r--`(644)。

macOS/Linux 下，系统按照 `umask` 设置用户创建文件（夹）的默认权限。在命令行输入 `umask` 其值为 022（八进制），即 owner 拥有全部权限，同时屏蔽了用户组 g 和其他用户 o 的写权限。

当创建一个文件夹时，其权限=777 & ~umask（Python下计算：oct(0o777 & ~0o022) = '0o755'），文件的权限是 `-rw-r--r--`(644)，即 owner 拥有读写权限，用户组 g 和其他用户 o 拥有只读权限。

根据以上分析，按照 umask 权限屏蔽策略，只有 httpd 用户（_www） 这个 owner 对 WebDav 服务目录 Directory 拥有写权限，其他用户（包括当前用户 faner:staff）只有只读权限。

!!! note

    **解决思路**：如果有办法修改 httpd 用户（_www）的 umask 为 002，即开放其所在用户组（_www）的写权限，然后执行 `sudo dscl . -append /Groups/_www GroupMembership faner` 将当前用户 faner 加入 _www 用户组，当前用户即有权限直接写本地 WebDav 服务目录 Directory。

### 现有 umask 下的方案探索

[Webdav (Apache) 的文件权限问题](https://github.com/solomonxie/blog-in-the-issues/issues/35#issuecomment-441922148) 给出了一种解决方案：

1. 将共享目录的 owner 从 _www:_www 修改为 faner:_www：

```bash
sudo chown -R faner:_www /Users/faner/Sites/DAVNAS
```

2. 为组加上`s` 标志，这样其下新建的文件就会自动 setgid 为 `_www` 组的 ID：

```bash
sudo chmod -R g+s /Users/faner/Sites/DAVNAS
```

> For a directory, `g+s` overrides the group id that new files and directories will have (it is usually inherited from the creator).

在这种方案中，改变文件夹的 owner 和 mod，当前用户 faner 不用加入 _www 组，即可在共享文件夹新建文件（夹）。

- 新建文件夹隶属 faner:_www，权限为 drwxr-xr-x
- 新建文件隶属 faner:_www，权限为 -rw-r--r--

受现有 umask=022 制约，新建的文件（夹）的用户组均无 w 权限。
webdav 客户端对应的 httpd 用户 _www 将只有 r 读浏览权限，无法写入！

---

考虑为共享目录所属组 _www 开放写权限：

```Shell
# 755 -> 775
$ sudo chmod -R g+w ~/Sites/DAVNAS
```

并将当前用户 faner 加入 _www 组：

```Shell
# -delete 删除
$ sudo dscl . -append /Groups/_www GroupMembership faner
```

这样的话，共享目录维持为 `_www:_www` 所有，_www 组员 faner 可向根目录修改写入数据。

但是，faner:_www 在根目录新建文件属性为 `-rw-r--r--@`，一旦被 webdav 客户端修改，其 owner 变为 _www，属性中的 `@` 消失，本地管理员 faner 又无权修改该文件！

- 客户端新建的文件 owner 为 _www:_www，faner 在本地无权修改写入！

归根结底，还是受现有 umask=022 制约，新建的文件夹并不会继承根目录的 g+w，即用户组均无 w 写权限。服务端 faner 或客户端 _www 建的文件夹，彼此都无权修改写入！

所以，此部分仅作为探索记录，奇技淫巧和歪门邪道终究不能登堂入室取得正果。

### 尝试将 umask 修改为 002？

CentOS、Ubuntu 下的方案参考 [Setting the umask of the Apache user](https://stackoverflow.com/questions/428416/setting-the-umask-of-the-apache-user)：

```Shell
# CentOS
$ echo "umask 002" >> /etc/sysconfig/httpd
$ service httpd restart

# Debian and Ubuntu
echo "umask 002" /etc/apache2/envvars
service apache2 restart
```

macOS 下，参考 [Apache2 & umasks](https://krypted.com/mac-security/apache2-umasks/)，需要修改 apache 的环境变量配置文件 /usr/sbin/envvars：

```Shell
$ sudo vim /usr/sbin/envvars
# set custom umask, allow group writing
umask 002
```

参考 [Set umask in OS X Yosemite](https://stackoverflow.com/questions/27888296/set-umask-in-os-x-yosemite) 和 [Mac umask apache](https://gist.github.com/integer/10376739)，修改 org.apache.httpd.plist 配置文件：

```Shell hl_lines="5 6"
$ sudo vim /System/Library/LaunchDaemons/org.apache.httpd.plist

add

        <key>Umask</key>
        <integer>002</integer>

in <dict> section

$ sudo apachectl stop
$ sudo apachectl start
```

可惜的是，以上两个系统配置文件均隶属 root:wheel， 即使执行 `sudo -i` 或 `sudo su - ` 切换到 root 身份，进入恢复模式执行 `csrutil disable` 关闭 SIP（[System Integrity Protection](https://en.wikipedia.org/wiki/System_Integrity_Protection)），也还是处于只读保护状态，无法修改。至于想通过 `sudo mount -uw /` 把整个磁盘重新 mount 为可写模式更是痴心妄想！

网上有很多此类问题的讨论，随着 macOS 系统的安全策略升级，有些方案已经失效： 

- [MAC: Root User Not Getting Edit Permissions](https://stackoverflow.com/questions/39303791/mac-root-user-not-getting-edit-permissions)
- [Cannot add/modify system or root dir files even though I'm logged in as root user](https://discussions.apple.com/thread/251670400?sortBy=best)
- [Can't edit read only file even when root](https://superuser.com/questions/1159290/cant-edit-read-only-file-even-when-root)
- [Still can't edit /System/Library after disabling SIP : r/MacOS](https://www.reddit.com/r/MacOS/comments/mwbox5/still_cant_edit_systemlibrary_after_disabling_sip/)

!!! info "苹果官方相关文档"

    [Signed system volume security in iOS, iPadOS and macOS - Apple Support (HK)](https://support.apple.com/en-hk/guide/security/secd698747c9/web)
    [About the read-only system volume in macOS Catalina or later](https://support.apple.com/en-us/HT210650): Apple has made changes to Catalina to lock down the system files which are now stored and mounted as a read-only volume.

在 [Set a custom umask in macOS](https://support.apple.com/en-us/101914) 中，官方给出了修改 umask 的方案，不过只能针对 system 和 user（所有用户）全局设置，无法针对具体用户（_www）设置 umask。

```Shell
# user: 所有用户
sudo launchctl config user umask nnn
# system: 系统用户
sudo launchctl config system umask nnn
```

config 目标只能为 system | user，尝试执行 `sudo launchctl config user umask 002` 报错：

```Shell
sudo launchctl config _www umask 002

Usage: launchctl config <system|user> <parameter> <value>
When given the "system" argument, modifies the configuration for the system
domain. When given the "user" argument on supported platforms, modifies the
configuration for all user domains. You must reboot for changes to take effect.
Note that if a service specifies a conflicting configuration, the service's
parameter will be preferred.

Supported configuration parameters are:

umask <integer as octal>
Modifies the umask(2) applied to services launched in the domain.

path <string>
Modifies the PATH environment variable set on each service in the
domain.
```

当然，如果不介意，也可通过这种方式全局修改所有用户（user ）的 umask 为 002，向同一用户组开放写权限。

期待 apache 官方未来预留一个用户级环境变量的配置机会，或者采用 nginx 平替（[为www-data用户(nginx)更改umask值](https://www.volcengine.com/theme/4190945-W-7-1)）。

或者，暂时就此作罢，服务器本地管理员也登录挂载 WebDAV 云盘后，统一以 Web HTTP 客户身份同步操作云盘。

## Finder 挂载 WebDAV 卡死问题

macOS Finder 对 WebDAV 的支持貌似不是那么好，可选择 Finder 的替代品 [QSpace](https://qspace.awehunt.com/en-us/index.html)，或使用免费的 [Cyberduck](https://cyberduck.io/)（[Help Docs](https://docs.duck.sh/)），或考虑专业的云盘加载工具软件 [Mountain Duck](https://mountainduck.io/)、[CloudMounter](https://cloudmounter.net/) 等。

!!! note "WebDAVDevs/awesome-webdav"

    [A curated list of awesome apps that support WebDAV and tools related to it.](https://github.com/WebDAVDevs/awesome-webdav)

    - Contents
    - Resources
    - Servers
    - PWA and online apps
    - Command line tools
    - Desktop apps
    - Mobile apps
    - Libraries
    - Cloud providers
    - Extensions
    - Contributing

从实际体验来看，iPad/iPhone 上的 PDF Expert 挂载局域网 WebDAV 后，工作得挺稳定，回写同步做得比较好。在 macOS 上编辑 PDF 文件，时不时转菊花，有时候等一会能恢复，有时候等了很久还是卡死。

此时，使用 `⌥+⌘+esc` 打开查看 Force Quit Applications 窗口，其中 PDF Expert 为 not responding 卡死状态，点击底下的 Relaunch 按钮，也并没有解决问题。过一会回到 Finder 中的 `/Volumes/webdav`，点几下也卡死。在 Force Quit Applications 窗口点选 Finder Relaunch，Finder 关闭后迟迟没有重新打开。

最初，遇到这种情况没辙，只能按住电源键强制重启，但是总这么搞也不是办法。稍微研究了一下，通过 macOS 提供的诊断工具箱，可以找到相关进程杀之。

通过 `ps aux | grep webdav` 过滤 webdav 相关的进程，或利用 `lsof` 命令过滤服务器 IP 查找出 webdav 网络连接和进程 PID。

!!! question

    lsof 显示有些 TCP 连接处于 `SYN_SENT` 状态一直等待服务器确认，具体有待进一步研究分析。

```Shell
$ ps aux | grep webdav
# or
$ lsof -nPi4 +c0 +M | grep 192.168.0.100
```

假设获取到进程的 COMMAND=`webdavfs_agent`， PID=`3231`，执行 kill 命令杀死 webdav 进程，Finder 重获新生。

```Shell
$ sudo kill -9 3231
# or
$ sudo killall -9 webdavfs_agent
```

参考：

- [Webdav slowness problem on catalina and Big Sur (Finder)](https://www.reddit.com/r/MacOS/comments/ikr7jj/webdav_slowness_problem_on_catalina_and_big_sur/)

- [How to forceably unmount stuck network share in Mac OS X?](https://superuser.com/questions/249611/how-to-forceably-unmount-stuck-network-share-in-mac-os-x)

---

对于稍大一点文件的编辑同步，Finder 卡死问题频发，确实令人头痛不已。
不想折腾，果断弃坑。现已改用 [Cyberduck](https://cyberduck.io/) + [Rclone](https://rclone.org/)，they just work like a charm!
