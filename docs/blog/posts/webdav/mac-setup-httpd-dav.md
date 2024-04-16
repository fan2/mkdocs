---
title: macOS上基于httpd搭建WebDav服务
authors:
  - xman
date:
    created: 2024-03-16T23:10:00
    updated: 2024-04-16T17:40:00
categories:
    - macOS
    - webDAV
tags:
    - httpd
    - webDAV
comments: true
---

在局域网中，要想共享或访问 macOS 机器上的文件，可以通过文件共享、屏幕共享或 [远程登录](https://apple.stackexchange.com/questions/278744/command-line-enable-remote-login-and-remote-management) 这几种方式：

1. **FS**（SMB）: [Set up file sharing on Mac](https://support.apple.com/zh-sg/guide/mac-help/mh17131/mac)，[Control access to your Public folder on Mac](https://support.apple.com/zh-sg/guide/mac-help/mchlp1775/mac)。
2. **SSH**+SFTP: [Allow a remote computer to access your Mac](https://support.apple.com/en-hk/guide/mac-help/mchlp1066/mac)
3. **Screen Sharing**（VNC）: [Turn Mac screen sharing on or off](https://support.apple.com/en-hk/guide/mac-help/mh11848/mac)，[Share the screen of another Mac](https://support.apple.com/en-hk/guide/mac-help/mh14066/mac)。
4. **RD**: [Enable remote management for Remote Desktop](https://support.apple.com/en-hk/guide/remote-desktop/apd8b1c65bd/mac)

FS 模式一般默认开放给 everyone 只读，可以以 Guest User 身份免登录访问，但是一旦涉及到要开放写权限，会涉及到系统账户分级分组管理和ACL权限控制和分配粒度问题。局域网内怎么样部署简易轻量的共享同步存储系统呢？

在多终端设备时代，很多人都购买了在线网络云盘服务，或者自己动手DIY搭建部署家庭局域网NAS私有云服务器，作为家里的数据和影音中心，方便文件共享和存储备份同步。另一个日益增长的需求就是分布式协作，Google文档、腾讯文档等产品就是解决这类问题的在线协同编辑的办公软件。

<!-- more -->

早在1996年，加州大学尔湾分校博士毕业生Jim Whitehead就与W3C共同主办了两场会议讨论了万维网上的分布式创作问题，并成立了WebDAV工作小组。

!!! quote "WebDAV wiki"

    **WebDAV** 是 Web-based Distributed Authoring and Versioning 的缩写，即基于Web的分布式编写和版本控制。它是对 HTTP 的扩展，为用户在服务器上创建、更改和移动文档提供了一个框架，方便用户间协同编辑和管理存储在万维网服务器上的文档。

因为基于HTTP，WebDAV 在广域网上共享文件有天然的优势，移动端文件管理APP大多都支持WebDAV协议，使用HTTPS还能保安全性。微软的Office和自家Sharepoint服务器通信，苹果的iWork套件也是基于WebDAV。Apache和Nginx都扩展支持WebDAV，可作为WebDAV文件共享服务器软件。

本文记录了在 macOS 上基于内置的 Apache Httpd 搭建 WebDAV 服务的步骤流程，以供备忘和参考。

## 配置 Apache httpd

Apache Httpd 配置文件：`/etc/apache2/httpd.conf`。

```Shell
$ cd /etc/apache2/
//  备份文件，以防不测
$ sudo cp httpd.conf httpd.conf.bak
$ sudo vim httpd.conf
```

其中定义了默认的文档服务目录：

```aconf title="/etc/apache2/httpd.conf" 
DocumentRoot "/Library/WebServer/Documents"
<Directory "/Library/WebServer/Documents">
```

### 修改 ServerName

macOS 上可通过以下命令获取主机名：

*   hostname
*   scutil --get ComputerName
*   scutil --get LocalHostName

搜索 ServerName 注释行，设置与主机名称一致

```Shell
ServerName mbpa1398:80
```
### 启动验证 httpd 服务

由于尚未配置 webdav 扩展服务，暂时先不管 webDAV 服务，先把 httpd server 跑起来。

!!! warning "wfsctl should be disabled"

    请先执行 `wfsctl status` 命令检查 wfsctl 是否为禁用状态：

    ```Shell
    $ sudo wfsctl status
    disabled
    ```

    如果否，请执行 `sudo wfsctl stop` 停止，否则可能会有端口冲突等问题导致后续无法访问。

执行 `sudo apachectl -k start` 启动 Apache Httpd 服务，然后在本地命令行输入 `curl localhost`，正常应返回 DocumentRoot 下的 index.html.en 页面：

```HTML
<html><body><h1>It works!</h1></body></html>
```

或在浏览器输入 <http://localhost> 或 <http://mbpa1398.local> 看看是否正常输出 `It works!` 。

[Stopping and Restarting Apache HTTP Server - Apache HTTP Server Version 2.4](https://httpd.apache.org/docs/2.4/en/stopping.html)

### 启用 Dav 扩展服务配置

移除以下配置文件中 5 行行首的注释：

```aconf title="/etc/apache2/httpd.conf" hl_lines="6"
 92 #LoadModule auth_digest_module libexec/apache2/mod_auth_digest.so
165 #LoadModule dav_module libexec/apache2/mod_dav.so
176 #LoadModule dav_fs_module libexec/apache2/mod_dav_fs.so
177 #LoadModule dav_lock_module libexec/apache2/mod_dav_lock.so

533 #Include /private/etc/apache2/extra/httpd-dav.conf
```

1.  LoadModule 加载 mod\_dav 相关的三个动态库和用于 digest auth  验证的动态库。
2.  Include 包含（引入）dav 扩展服务配置（extra/httpd-dav.conf）。

!!! note ""

    如果使用默认的认证方式 AuthType Digest，则需加载 mod\_auth\_digest.so。
    如果改为 Basic，默认已经加载了 mod\_auth\_basic.so，无需加载 mod\_auth\_digest.so。

## 配置 httpd 扩展 Dav 服务

Httpd 的 Dav 扩展服务配置文件：/etc/apache2/extra/httpd-dav.conf。

```Shell
$ cd extra
# 备份配置文件
$ sudo cp httpd-dav.conf httpd-dav.conf.bak
# 编辑配置文件
$ sudo vim httpd-dav.conf
```

### 设置共享目录文件夹

macOS 下自带的 Apache Httpd 服务的站点目录有两级：

1. 系统级的根目录：httpd.conf 中配置的 DocumentRoot（`/Libraray/WebServer/Ducuments`），对应网址： http://localhost/。
2. 用户级的根目录：对应配置 httpd-userdir.conf（`～/Sites`），对应网址：http://localhost/~user/。

httpd.conf 中默认未启用用户级站点配置 httpd-userdir.conf：

```Shell
# User home directories
#Include /private/etc/apache2/extra/httpd-userdir.conf
```

httpd-userdir.conf 内容如下：

```Shell
#Include /private/etc/apache2/users/*.conf
<IfModule bonjour_module>
       RegisterUserSite customized-users
</IfModule>
```

在 /etc/apache2/users/ 目录下，可以看到当前用户的配置 faner.conf：

```aconf title="/etc/apache2/users/faner.conf"
<Directory "/Users/faner/Sites/">
    Options Indexes MultiViews
    Require all granted
</Directory>
```

按照 Apache 的部署策略，本机的全局站点部署在系统级根目录，用户级的站点部署在家目录下的 Sites 下。

---

暂时没有使用 Apache 部署个人站点的需求，所以先在 `~Sites` 下新建 DAVNAS 目录用作 WebDAV 共享服务。

第19行指定共享服务目录：/Users/faner/Sites/DAVNAS。
第17行设置 alias 名字为 /webdav，为后续访问 URL 的根路径。

```aconf title="/etc/apache2/extra/httpd-dav.conf"
 17 Alias /webdav "/Users/faner/Sites/DAVNAS"
 18
 19 <Directory "/Users/faner/Sites/DAVNAS">
```

httpd.conf 中指定了运行 httpd daemon 进程的用户和组：

```aconf title="/etc/apache2/extra/httpd-dav.conf"
User _www
Group _www
```

macOS 下 mkdir/touch 新创建的文件（夹），默认对 staff 工作组和 everyone 都开放了 Read Only 权限。

客户端通过 HTTP Basic/Digest 认证访问 web 服务，运行 httpd 服务的 `_www._www` 用户作为 everyone，拥有对 Directory 目录的只读浏览权限。

想要让 httpd 有权限修改/写入共享的 Directory 目录，需要将该目录更改为 `_www._www` 用户组名下。调用 `chown` 命令即可：

```Shell title="将共享目录 owner 改为 httpd 用户"
$ sudo chown -R _www:_www /Users/faner/Sites/DAVNAS
```

此项修改将导致本地管理员无法直接写 Directory 目录，详见后续讨论。

### 配置 DavLockDB 目录

创建 /opt/webdav/var 目录：

```Shell
$ sudo mkdir -p /opt/webdav/var
# -R?
$ sudo chown _www:_www /opt/webdav/var
```

修改 httpd-dav.conf 第 15 行的 DavLockDB 路径配置：

```aconf title="/etc/apache2/extra/httpd-dav.conf"
# 15 DavLockDB "/usr/var/DavLock"
15 DavLockDB /opt/webdav/var/DavLock
```

### 创建 WebDAV 访客用户

新建存储密码的文件 user.passwd，并修改所属的用户和组。

```Shell
$ sudo touch /opt/webdav/user.passwd
$ sudo chown _www:_www /opt/webdav/user.passwd
```

紧接着，根据不同的 AuthType 执行不同的命令，为 webdav 域新增用户 username。

其中， `-c` 选项将 truncate 已存在的密码文件。

=== "AuthType Digest - htdigest"

    ```Shell
    $ sudo htdigest -c /opt/webdav/user.passwd webdav $username
    ```

=== "AuthType Basic - htpasswd"

    ```Shell
    $ sudo htpasswd -c /opt/webdav/user.passwd $username
    ```

根据提示，为新增的用户（username）设置密码并确认。

!!! tip

    可以提前创建多个账号，分配给不同的局域网访客用户。

## httpd-dav.conf 主要改动部分

### AuthType Basic

*   改：DavLockDB
*   改：AuthName
*   改：AuthUserFile
*   注：AuthDigestProvider

```aconf title="/etc/apache2/extra/httpd-dav.conf" hl_lines="8"
15 DavLockDB "/opt/webdav/var/DavLock"
16
17 Alias /webdav "/Users/faner/Sites/DAVNAS"
18
19 <Directory "/Users/faner/Sites/DAVNAS">
20     Dav On
21
22     AuthType Basic
23     AuthName webdav
24     # You can use the htdigest program to create the password database:
25     #   htdigest -c "/usr/user.passwd" $AuthName $username
26     AuthUserFile "/opt/webdav/user.passwd"
27     # AuthDigestProvider file
29
30     # Allow universal read-access, but writes are restricted
31     # to the admin user.
32     <RequireAny>
33        Require method GET POST OPTIONS
34        Require user $username
35    </RequireAny>
36 </Directory>
```

### AuthType Digest

*   改：DavLockDB
*   改：AuthName
*   改：AuthUserFile
*   增：Require valid-user
*   注：`<RequireAny>...</RequireAny>`

```aconf title="/etc/apache2/extra/httpd-dav.conf" hl_lines="8"
15 DavLockDB "/opt/webdav/var/DavLock"
16
17 Alias /webdav "/Users/faner/Sites/DAVNAS"
18
19 <Directory "/Users/faner/Sites/DAVNAS">
20     Dav On
21
22     AuthType Digest
23     AuthName webdav
24     # You can use the htdigest program to create the password database:
25     #   htdigest -c "/usr/user.passwd" DAV-upload admin
26     AuthUserFile "/opt/webdav/user.passwd"
27     Require valid-user
28     AuthDigestProvider file
29
30     # Allow universal read-access, but writes are restricted
31     # to the admin user.
32 #    <RequireAny>
33 #        Require method GET POST OPTIONS
34 #        Require user admin
35 #    </RequireAny>
36 </Directory>
```

### 配置多个共享目录

建议把要共享的内容放在一个共享目录（DAVNAS），然后通过 /webdav 访问。

如果有多个共享目录，可以复制 Alias、Directory，建立多组 URL 路径映射。

```aconf title="/etc/apache2/extra/httpd-dav.conf"
Alias /webdav1 "/Users/faner/Sites/DAVNAS1"

<Directory "/Users/faner/Sites/DAVNAS1">
    Dav On
    # Dav access control
</Directory>

Alias /webdav2 "/Users/faner/Sites/DAVNAS2"

<Directory "/Users/faner/Sites/DAVNAS2">
    Dav On
    # Dav access control
</Directory>
```

这样，后续就可以通过 /webdav1, /webdav2 分别访问不同的共享目录。

## 授予 httpd 完全磁盘访问权限

将 DAVNAS 共享目录分配给 `_www:_www` 后，还得给 httpd 相关 daemon 进程分配磁盘访问权限，这样才能读写磁盘文件系统。

打开 macOS 设置(System Settings)，隐私与安全性(Privacy & Security)，完全磁盘访问权限(Full Disk Access)，

点按左下角的 + 号，在打开的访达窗口按 ++shift+command+g++ 调出路径访问方式，输入 `/usr/sbin/httpd` 回车，找到 httpd 命令添加。

依此方法，添加 `/usr/sbin/htdigest`（或 `/usr/sbin/htpasswd`）。

## 验证更新配置重启Apache Httpd

!!! tip "查看 apache httpd 服务配置"

    在验证服务之前，可以调用 `apachectl` 或 `httpd` 命令查看配置：

    ```Shell
    $ apachectl -t -D DUMP_INCLUDES
    $ apachectl -t -D DUMP_RUN_CFG
    ```

执行 `apachectl -t`（或 `apachectl configtest`）检查 Apache Httpd 配置文件：如果仅输出一行  `Syntax OK` 代表配置正确；否则，表示配置有问题，请按提示检查配置文件，也可查看分析问题日志 /var/log/apache2/error\_log。

如果 configtest 遇到以下错误，请执行 `sudo mkdir /private/var/log/apache2` 创建 apache2 日志文件夹。

```Shell
$ apachectl -t
(2)No such file or directory: AH02291: Cannot access directory '/private/var/log/apache2/' for main error log
AH00014: Configuration check failed
```

配置文件验证无误后，执行 `sudo apachectl graceful` 重载配置文件使生效。

最后，重新启动 Apache 服务器：`sudo apachectl -k restart`。

!!! tip "How to stop apache service"

    ```Shell
    $ sudo apachectl -k stop
    $ sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null
    ```

## 局域网连接验证WebDAV服务

打开本机访达（Finder），按 Command+k 连接服务器，输入 <http://mbpa1398.local/webdav/>，然后输入在 user.passwd 中配置的账户密码，看看是否可以正常访问。

!!! note ""

    如果机器名无法解析（unable to resolve host），可以换成局域网 IP 访问：<http://192.168.0.100/webdav/> ， 或者考虑在 /etc/hosts 中添加条目：127.0.0.1 mbpa1398.local 。

本机验证通过后，在局域网其他终端（例如 Mac Finder，iPhone PDF expert）上尝试连接 webdav 服务。连接成功后，即可进行简单的多用户协作。

这样，就将 DAVNAS 配置为家庭局域网内的数据中心，支持多设备共享和编辑同步文件。

将配置文件 httpd-dav.conf 中的  Directory 配置为外挂硬盘，例如 `/Volumes/WDHD`，即可变为简陋的 NAS。

有条件的，可以进一步升级支持 HTTPS 安全访问，需要在 httpd.conf 引入 httpd-ssl.conf 并配置加载 ssl 相关模块，还得使用 openssl 创建自签名证书。

如果家里的宽带有分配公网 IP，可以在路由器中配置端口映射，支持外网访问。这样，即使身在外边，也可远程访问家里的 WebDAV 服务。

---

关于食用体验问题，参考 [macOS上使用httpd/WebDav遇到的问题](./mac-webdav-issues.md)。
现已改装 nginx 配置 webdav 服务，参考 [macOS重装nginx-full并配置WebDav](./mac-install-nginx-full-config-webdav.md)。
客户端改用免费的 [Cyberduck](https://cyberduck.io/)，搭配 [rclone+crontab](./rclone-access-webdav.md) 定时自动同步备份，they just work like a charm!

## 参考

wiki - [WebDAV](https://en.wikipedia.org/wiki/WebDAV)
[网络存储文件共享之 WebDAV](https://zhuanlan.zhihu.com/p/352216119)
[在 Mac mini Server 上配置 WebDAV 文件共享](https://zhuanlan.zhihu.com/p/651442490)
