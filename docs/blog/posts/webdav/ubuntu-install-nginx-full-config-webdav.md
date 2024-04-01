---
title: rpi4b-ubuntu安装nginx-extras并配置WebDav
authors:
  - xman
date:
    created: 2024-03-18T15:00:00
    updated: 2024-04-01T20:00:00
categories:
    - ubunbu
    - nginx
    - webDAV
tags:
    - nginx
    - webDAV
comments: true
---

手头的 raspberry pi 4b 安装了 ubuntu server，默认已内置 nginx。但是，和 macOS 上通过 brew 安装的 nginx 一样，http_dav 模块只支持基础的 webdav 服务，如果要支持完整的 webdav 服务，需要安装 dav-ext 扩展模块。

<!-- more -->

rpi4b 的 CPU 和 OS 信息如下：

=== "arch"

    ```Shell
    pifan@rpi4b-ubuntu $ arch
    aarch64

    pifan@rpi4b-ubuntu $ echo $MACHTYPE
    aarch64
    ```

=== "os"

    ```Shell
    pifan@rpi4b-ubuntu $ cat /etc/issue
    Ubuntu 22.04.4 LTS \n \l

    pifan@rpi4b-ubuntu $ lsb_release -a
    No LSB modules are available.
    Distributor ID:	Ubuntu
    Description:	Ubuntu 22.04.4 LTS
    Release:	22.04
    Codename:	jammy
    ```

!!! note "How to install Ubuntu Server on Raspberry Pi?"

    [Install Ubuntu on a Raspberry Pi](https://ubuntu.com/download/raspberry-pi)
    [How to install Ubuntu Server on your Raspberry Pi](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi)

## installed nginx

关于 nginx 命令帮助，执行 `nginx -h` 或 `man nginx`。

### nginx -V

执行 `nginx -V` 可查看详细的 configure arguments，包括 `prefix`、`conf-path`、`pid-path`、`http-log-path` 和 `error-log-path`，以及以 `with` 开头的已安装的模块（module）。

!!! note "nginx -V path"

    默认工作空间：--prefix=/usr/share/nginx
    默认配置文件：--conf-path=/etc/nginx/nginx.conf
    默认日志路径：

    - --http-log-path=/var/log/nginx/access.log
    - --error-log-path=/var/log/nginx/error.log

??? info "nginx -V details"

    ```Shell
    $ nginx -V
    nginx version: nginx/1.18.0 (Ubuntu)
    built with OpenSSL 3.0.2 15 Mar 2022
    TLS SNI support enabled
    configure arguments: --with-cc-opt='-g -O2 -ffile-prefix-map=/build/nginx-glNPkO/nginx-1.18.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-geoip2 --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_sub_module
    ```

### curl localhost

执行 `curl localhost` 请求 web 服务，正常返回 `Welcome to nginx!` 欢迎页面（/var/www/html/index.nginx-debian.html）：

??? info "Welcome to nginx!"

    ```html
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
    ```

## install nginx-extras

`nginx -V` 输出的 dav 相关的只有 `--with-http_dav_module`，要想使用完整的 webDAV 服务，还得自行安装 dav-ext 扩展模块。

- The [nginx webdav module](http://nginx.org/en/docs/http/ngx_http_dav_module.html) only supports PUT, DELETE, MKCOL, COPY, and MOVE.
- The [dav\_ext module](https://github.com/arut/nginx-dav-ext-module) adds support for PROPFIND, OPTIONS, LOCK and UNLOCK.

基于已经安装的 nginx，只需要安装 `nginx-extras` 扩展包即可，其中包含了 dav-ext 和 headers-more 模块。

当然，也可以卸载 nginx，重装 nginx-full 完整版。

```Shell
$ sudo apt install nginx-extras

The following additional packages will be installed:
  geoip-database libgeoip1 libnginx-mod-http-auth-pam libnginx-mod-http-cache-purge
  libnginx-mod-http-dav-ext libnginx-mod-http-echo libnginx-mod-http-fancyindex
  libnginx-mod-http-geoip libnginx-mod-http-headers-more-filter libnginx-mod-http-perl
  libnginx-mod-http-subs-filter libnginx-mod-http-uploadprogress libnginx-mod-http-upstream-fair
  libnginx-mod-nchan libnginx-mod-stream-geoip

The following NEW packages will be installed:
  geoip-database libgeoip1 libnginx-mod-http-auth-pam libnginx-mod-http-cache-purge
  libnginx-mod-http-dav-ext libnginx-mod-http-echo libnginx-mod-http-fancyindex
  libnginx-mod-http-geoip libnginx-mod-http-headers-more-filter libnginx-mod-http-perl
  libnginx-mod-http-subs-filter libnginx-mod-http-uploadprogress libnginx-mod-http-upstream-fair
  libnginx-mod-nchan libnginx-mod-stream-geoip nginx-extras

Get:3 https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports jammy-updates/universe arm64 libnginx-mod-http-dav-ext arm64 1.18.0-6ubuntu14.4 [17.8 kB]

Selecting previously unselected package libnginx-mod-http-dav-ext.
Preparing to unpack .../02-libnginx-mod-http-dav-ext_1.18.0-6ubuntu14.4_arm64.deb ...
Unpacking libnginx-mod-http-dav-ext (1.18.0-6ubuntu14.4) ...


Setting up libnginx-mod-http-dav-ext (1.18.0-6ubuntu14.4) ...
```

安装完毕 nginx-extras，重新执行 `nginx -V`，除了默认的 `--with-http_dav_module`，多了两项：

- --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-dav-ext
- --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-headers-more-filter

??? info "nginx -V"

    ```Shell
    $ nginx -V
    nginx version: nginx/1.18.0 (Ubuntu)
    built with OpenSSL 3.0.2 15 Mar 2022
    TLS SNI support enabled
    configure arguments: --with-cc-opt='-g -O2 -ffile-prefix-map=/build/nginx-glNPkO/nginx-1.18.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-geoip2 --with-http_addition_module --with-http_flv_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_mp4_module --with-http_perl_module=dynamic --with-http_random_index_module --with-http_secure_link_module --with-http_sub_module --with-http_xslt_module=dynamic --with-mail=dynamic --with-mail_ssl_module --with-stream=dynamic --with-stream_geoip_module=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-headers-more-filter --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-auth-pam --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-cache-purge --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-dav-ext --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-ndk --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-echo --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-fancyindex --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/nchan --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/rtmp --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-uploadprogress --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-upstream-fair --add-dynamic-module=/build/nginx-glNPkO/nginx-1.18.0/debian/modules/http-subs-filter
    ```

## config webdav

Ubuntu 下 nginx 配置 WebDav 服务的流程和 macOS 下差不多，参考上一篇 [macOS重装nginx-full并配置WebDav](./mac-install-nginx-full-config-webdav.md)。

### mkdir for webdav

nginx 默认的 Docroot 是 `/var/www/html`，在其同级创建 webdav 共享文件夹 `/var/www/webdav`，

这里采用和 macOS 上一样的用户管理策略，chown 用户为 www-data:www-data。

```Shell
$ mkdir /usr/local/var/webdav
$ sudo chown -R www-data:www-data /var/www/webdav
```

!!! info "who is www-data?"

    [What is the www-data user?](https://askubuntu.com/questions/873839/what-is-the-www-data-user)
    [linux 下 nginx 默认使用 www-data 用户组](https://blog.csdn.net/gent__chen/article/details/50969781)

    nginx.conf 中定义了 worker process 的执行用户：

    ```nginx title="nginx.conf"
    user www-data;
    ```

    ```Shell
    $ id www-data
    uid=33(www-data) gid=33(www-data) groups=33(www-data)
    ```

!!! warning "never run a website from within your home directory"

    自定义的 webdav 等服务的 Docroot 不要放在 home 目录下，防止遍历泄露数据，详情参考 [Permissions problems with /var/www/html and my own home directory for a website document root](https://askubuntu.com/questions/767504/permissions-problems-with-var-www-html-and-my-own-home-directory-for-a-website)。

??? question "为什么不建议把服务目录设置到家目录下？"

    一开始，我将 webdav 共享目录配置到家目录下 `/home/pifan/Sites/davnas/`，结果客户端浏览器访问首页 http://rpi4b-ubuntu.local:81/webdav，密码校验成功后，总是报错 403 forbidden。

    查看实时访问错误日志：

    ```Shell
    $ tail -f /var/log/nginx/webdav.error.log

    2024/03/23 06:01:25 [crit] 52483#52483: *4 stat() "/home/pifan/Sites/davnas/" failed (13: Permission denied), client: 192.168.0.110, server: localhost, request: "PROPFIND /webdav/ HTTP/1.1", host: "rpi4b-ubuntu.local:81"
    ```

    [Nginx: stat() failed (13: permission denied)](https://stackoverflow.com/questions/25774999/nginx-stat-failed-13-permission-denied)

    `ls -al /home/` 可以看到 HOME **pifan** 目录 owner 是 pifan:ubuntu，权限是 `drwxr-x---`，其他人没有权限。

    而 nginx 要求用户 www-data 要能 cd 进每一级目录执行 stat 检查文件状态，也即需要 x 权限。

    cd /home/pifan/ 两级测试通过，在 cd 一级测试失败：

    ```bash
    $ sudo -u www-data stat /home/pifan/Sites
    stat: cannot statx '/home/pifan/Sites': Permission denied
    ```

    参考 [Nginx only works when setting worker-process user to root](https://stackoverflow.com/questions/56493642/nginx-only-works-when-setting-worker-process-user-to-root)，需要对共享目录 /home/pifan/ 添加所有人（其他人）的 x 权限。

    [解决Nginx出现403 forbidden (13: Permission denied)报错的四种方法](https://www.cnblogs.com/huchong/p/10031523.html)
    [Nginx 日志 failed (13: Permission denied) 错误（13：权限被拒绝）](https://www.cnblogs.com/hunttown/p/16691668.html)

    由于启动用户和nginx工作用户不一致所致：查看 nginx: master process 启动用户是 root，nginx: worker process 用户是 www-data。

    将 nginx.conf 的 user 改为和启动用户一致：`sudo vim /etc/nginx/nginx.conf` 修改第一行的 `user www-data;` 为 `user root;`，然后执行 `sudo systemctl restart nginx` 重启 nginx 服务。

    不建议这么干，还是建议遵从 nginx 的设计，修改 webdav 共享目录的 owner，以 www-data 身份执行 web 操作！

### htpasswd add user

先安装 apache2-utils，以便使用 htpasswd/htdigest 命令创建密码。

```Shell
$ sudo apt-get install apache2-utils -y
```

这里使用 Basic 认证，具体配置参考 [Restricting Access with HTTP Basic Authentication](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/)。

```Shell
htpasswd -c /etc/nginx/.htpasswd $username
New password:
Re-type new password:
Adding password for user $username
```

### nginx conf

nginx 默认配置文件为 --conf-path=/etc/nginx/nginx.conf，nginx 启动时会加载该配置文件。

nginx.conf 中定义了 worker process 执行用户 `user www-data;` 和默认的日志路径：

!!! info "Logging Settings"

    ```nginx title="/etc/nginx/nginx.conf"
        ##
        # Logging Settings
        ##

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
    ```

#### Virtual Host

nginx.conf 导入加载虚拟主机配置（Virtual Host Configs），包括 conf.d 下的 conf 文件和 sites-enabled 下的所有配置文件。

!!! info "Virtual Host Configs"

    ```nginx title="/etc/nginx/nginx.conf"
    	##
    	# Virtual Host Configs
    	##

    	include /etc/nginx/conf.d/*.conf;
    	include /etc/nginx/sites-enabled/*;
    ```

conf.d 下默认为空，/etc/nginx/sites-enabled 下有一个默认的配置文件 default，它是符号链接（symlink），指向 /etc/nginx/sites-available/default。

```Shell
$ ls -l /etc/nginx/sites-enabled
total 0
lrwxrwxrwx 1 root root 34 Feb 24  2022 default -> /etc/nginx/sites-available/default
```

这个默认启用的站点就是 nginx 安装之后的 default_server，监听周知的 80 端口，Docroot 为 /var/www/html：

```nginx title="/etc/nginx/sites-enable/default -> /etc/nginx/sites-available/default"
# Default server configuration
#
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    # Add index.php to the list if you are using PHP
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        try_files $uri $uri/ =404;
    }

}
```

再来看看 sites-available/default 中的注释说明：

!!! note "/etc/nginx/sites-available/default"

    \# In most cases, administrators will remove this file from sites-enabled/ and
    \# leave it as reference inside of sites-available where it will continue to be
    \# updated by the nginx packaging team.

按照这个文档的建议，最好先在 /etc/nginx/sites-available/ 下创建可用站点，然后再软链（symlink）到 /etc/nginx/sites-enabled 下启用站点。

- [nginx 的 sites-available 和 sites-enabled 的区别](https://www.jianshu.com/p/42c4ffd044e6)
- [sites-available/enabled 与 conf.d 对比](https://blog.csdn.net/weixin_34182361/article/details/112809900)
- [nginx 启用站点和可用站点](https://skyao.gitbooks.io/learning-nginx/content/configure/vhost/action_domian.html)

#### webdav.conf

和 macOS 下的配置 webdav 思路一样，可以编辑 sites-available/default，在 default_server 下挂一个二级路径 `location webdav/` 路由。

另一种思路是配置独立的 webdav server，不与 default_server 搅合在一起。

按照 nginx 的配置管理逻辑，在 sites-available 下新建 webdav 配置文件：

```Shell title="添加可用站点"
$ sudo vim /etc/nginx/sites-available/webdav.conf
```

> 当然，也可以将 webdav 配置文件 webdav.conf 直接放在 conf.d 目录下，不需要时改后缀即可。

默认的 server 监听 80 端口，这里新建 server 监听 81 端口，并设置日志文件路径。

完整的 webdav.conf 记录备忘如下：

??? info "/etc/nginx/sites-available/webdav.conf"

    ```nginx
    # config lock for macOS Client
    dav_ext_lock_zone zone=webdav:10m;

    server {
        listen 81;
        server_name localhost;

        # 设置使用UTF-8编码,防止中文文件名乱码
        charset utf-8;

        # 设置日志文件路径
        error_log /var/log/nginx/webdav.error.log error;
        access_log /var/log/nginx/webdav.access.log combined;

        # [nginx不浏览直接下载文件](https://www.cnblogs.com/oxspirt/p/10250744.html)
        location / {
            if ($request_filename ~* ^.*?\.(txt|doc|pdf|rar|gz|zip|docx|exe|xlsx|ppt|pptx)$) {
                add_header Content-Disposition: 'attachment;';
            }
        }

        location /webdav {
            # webdav 共享服务目录（可考虑放在 opt/ 下）
            ## 请注意 chown 为 nginx worker 用户 www-data:www-data
            root /var/www;
            # alias /var/www/webdav;

            # webdav 用户(www-data)的默认权限
            dav_access user:rw group:rw all:r;

            # auth_basic 参数被用作域，并在授权弹窗中显示。
            auth_basic "webdav";
            # htpasswd 用户密码文件存放的位置
            auth_basic_user_file /etc/nginx/.htpasswd;

            # webdav 及 ext 允许的操作
            dav_methods PUT DELETE MKCOL COPY MOVE;
            dav_ext_methods PROPFIND OPTIONS LOCK UNLOCK;
            dav_ext_lock zone=webdav;

            # 开启支持目录浏览功能
            autoindex on;
            # 显示出文件的大概大小，单位是KB或者MB或者GB
            autoindex_exact_size off;

            # 启用完整的创建目录支持
            ## 默认情况下，PUT方法只能在已存在的目录里创建文件
            create_full_put_path on;

            # 临时缓存文件位置
            client_body_temp_path /tmp/webdav;

            # 最大上传文件限制, 0表示无限制
            client_max_body_size 4G;

            ########################################
            # 为各种方法的URI后加上斜杠，解决各平台webdav客户端的兼容性问题
            ########################################

            # issue: ngx_http_dav_module.c 判断 MKCOL 指令的 URI 必须以 / 结尾
            # 注意：如果是 alias，注意调整 rewrite 路径，或换成 root！
            if ($request_method ~ MKCOL) {
                rewrite ^(.*[^/])$ $1/ break;
            }

            # issue: ngx_http_dav_module.c 判断 MOVE 指令的 URI 和 Destination URI 结尾的 / 必须匹配
            # scenario: MOVE 文件夹 Destination URI 未以 / 结尾: /webdav/test/ --> /webdav/test2
            # error log: both URI and "Destination" URI should be either collections or non-collections
            set $dest $http_destination;
            if (-d $request_filename) {
                rewrite ^(.*[^/])$ $1/;
                set $dest $dest/;
            }

            # 需要安装 --with-headers-more-module
            if ($request_method ~ (MOVE|COPY)) {
                more_set_input_headers 'Destination: $dest';
            }
        }

        # Bonus: Stopping Finder's Garbage
        # https://www.robpeck.com/2020/06/making-webdav-actually-work-on-nginx/
        location ~ \.(_.*|DS_Store|Spotlight-V100|TemporaryItems|Trashes|hidden|localized)$ {
            access_log off;
            error_log off;

            if ($request_method = PUT) {
                return 403;
            }
            return 404;
        }

        location ~ \.metadata_never_index$ {
            return 200 "Don't index this drive, Finder!";
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
    ```

最后，记得将 sites-available 下的 webdav.conf 软链一份到 sites-enabled 目录下启用站点：

```Shell title="软链启用站点"
$ sudo ln -s /etc/nginx/sites-available/webdav.conf /etc/nginx/sites-enabled
```

#### restart nginx server

每次修改了 nginx 配置文件，需要重新加载配置（或重启服务），可以通过以下三种方式：

1. `sudo nginx -s reload`
2. `sudo systemctl reload nginx`
3. `sudo systemctl restart nginx`

[how to reload nginx - systemctl or nginx -s?](https://superuser.com/questions/710986/how-to-reload-nginx-systemctl-or-nginx-s)

可以执行 `sudo systemctl status nginx` 查看 nginx 运行状态。

!!! tip "How to stop nginx service?"

    ```Shell
    $ sudo nginx -s stop
    $ sudo systemctl kill nginx
    $ sudo systemctl stop nginx
    ```

### webdav test

关于 webdav 的连接测试，参考 [macOS上基于httpd搭建WebDav服务](./mac-setup-httpd-dav.md) - 局域网连接验证WebDAV服务 和 [使用命令行挂载操作WebDAV云盘](./cmd-mount-webdav.md) 中的相关说明。

1. 执行 curl localhost:81 验证 web 服务是否正常；

!!! info ""

    自启的非80服务（这里监听 81 端口），location / 未指定 root，Docroot 默认为 --prefix=/usr/share/nginx 下的 html 目录。

2. WebDAV 客户端访问 http://rpi4b-ubuntu.local:81/webdav/ 验证 webDAV 服务是否正常。

调试期间，可在 nginx 服务器执行 `tail -f tail -f /var/log/nginx/webdav.error.log`（或 access.log）实时查看滚动日志。

## refs

[Nginx安装webdav](https://blog.csdn.net/Abin17618/article/details/132580806) - Debian+OMV
[Ubuntu使用nginx搭建webdav文件服务器的详细过程](https://juejin.cn/post/7290837333926477843)
[Ubuntu使用nginx搭建webdav文件服务器的详细过程](https://www.cainiao.io/archives/1133)
