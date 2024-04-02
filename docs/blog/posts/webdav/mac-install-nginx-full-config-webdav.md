---
title: macOS重装nginx-full并配置WebDav
authors:
  - xman
date:
    created: 2024-03-18T10:00:00
    updated: 2024-04-02T09:00:00
categories:
    - macOS
    - nginx
    - webDAV
tags:
    - nginx
    - webDAV
comments: true
---

之前在 macOS 上使用 brew 安装过 nginx，但是缺乏 webdav 的扩展支持模块。
为了使用 nginx 替换 httpd 来搭建 webDAV 服务，需要重新安装 nginx-full。

<!-- more -->

## installed nginx

### which

    $ which nginx
    /usr/local/bin/nginx

    $ readlink `which nginx`
    ../Cellar/nginx/1.21.1/bin/nginx

### brew info

执行 `brew info nginx` 命令可查看 nginx 安装配置信息：

*   Docroot: `/usr/local/var/www`
*   默认配置：`/usr/local/etc/nginx/nginx.conf`
*   默认端口：`8080`

```Shell
$ brew info nginx

    Docroot is: /usr/local/var/www

    The default port has been set in /usr/local/etc/nginx/nginx.conf to 8080 so that
    nginx can run without sudo.

    nginx will load all files in /usr/local/etc/nginx/servers/.

    To restart nginx after an upgrade:
      brew services restart nginx

    Or, if you don't want/need a background service you can just run:
      /usr/local/opt/nginx/bin/nginx -g daemon off;
```

可通过 brew services 启动服务，执行 `brew help services` 可查看服务相关控制操作。

- [sudo] brew services [list]:
- [sudo] brew services info
- [sudo] brew services run
- [sudo] brew services start
- [sudo] brew services stop 
- [sudo] brew services restart

### nginx -V

关于 nginx 命令帮助，执行 `nginx -h` 或 `man nginx`。

执行 `nginx -V` 可查看详细的 configure arguments，包括 `prefix`、`conf-path`、`pid-path`、`http-log-path` 和 `error-log-path`，以及以 `with` 开头的已安装的模块（module）。

!!! note "nginx -V path"

    默认工作空间：--prefix=/usr/local/Cellar/nginx/1.25.1_1
    默认配置文件：--conf-path=/usr/local/etc/nginx/nginx.conf
    默认日志路径：

    - --http-log-path=/usr/local/var/log/nginx/access.log
    - --error-log-path=/usr/local/var/log/nginx/error.log

??? info "nginx -V details"

    ```Shell
    $ nginx -V
    nginx version: nginx/1.25.1
    built by clang 13.0.0 (clang-1300.0.29.30)
    built with OpenSSL 3.1.1 30 May 2023
    TLS SNI support enabled
    configure arguments: --prefix=/usr/local/Cellar/nginx/1.25.1_1 --sbin-path=/usr/local/Cellar/nginx/1.25.1_1/bin/nginx --with-cc-opt='-I/usr/local/opt/pcre2/include -I/usr/local/opt/openssl@3/include' --with-ld-opt='-L/usr/local/opt/pcre2/lib -L/usr/local/opt/openssl@3/lib' --conf-path=/usr/local/etc/nginx/nginx.conf --pid-path=/usr/local/var/run/nginx.pid --lock-path=/usr/local/var/run/nginx.lock --http-client-body-temp-path=/usr/local/var/run/nginx/client_body_temp --http-proxy-temp-path=/usr/local/var/run/nginx/proxy_temp --http-fastcgi-temp-path=/usr/local/var/run/nginx/fastcgi_temp --http-uwsgi-temp-path=/usr/local/var/run/nginx/uwsgi_temp --http-scgi-temp-path=/usr/local/var/run/nginx/scgi_temp --http-log-path=/usr/local/var/log/nginx/access.log --error-log-path=/usr/local/var/log/nginx/error.log --with-compat --with-debug --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_degradation_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-ipv6 --with-mail --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module
    ```

## reinstall nginx-full

由于使用 macOS 自带的 Apache Httpd 搭建的 webDAV 使用体验不太理想，因此考虑改用 nginx 搭建。

但是，之前使用 brew 安装的 nginx 只有 http_dav 标准模块，详见 `nginx -V` 输出的 `--with-http_dav_module`。
要想使用完整的 webDAV 服务，还得自行安装 dav-ext 扩展模块。

- The [nginx webdav module](http://nginx.org/en/docs/http/ngx_http_dav_module.html) only supports PUT, DELETE, MKCOL, COPY, and MOVE.
- The [dav\_ext module](https://github.com/arut/nginx-dav-ext-module) adds support for PROPFIND, OPTIONS, LOCK and UNLOCK.

### brew tap denji/homebrew-nginx

之前的 homebrew/nginx 这个 tap 已经不再维护了，执行 `brew tap homebrew/nginx` 将报错：

> Error: `homebrew/nginx` was deprecated. This tap is now empty and all its contents were either deleted or migrated.

现在可以使用 `denji/homebrew-nginx` 这个 tap，执行`brew tap denji/homebrew-nginx` 添加源。

### brew unlink nginx

在正式安装 nginx 之前，先执行 `brew unlink nginx` 解除已安装的 nginx 的链接：

!!! note "What about conflicts?"

    You are free to install this version alongside a current install of NGINX from `Homebrew/homebrew` if you wish. However, they cannot be linked at the same time. To **switch** between them use brew's built in linking system.

        brew unlink nginx
        brew link nginx-full

在安装之前，可以执行 `brew info nginx-full` 或 `brew options nginx-full` 查看有哪些安装选项。

### brew install nginx-full

然后，参考 [Update 'dav-ext-nginx-module.rb' from v0.1.0 to v3.0.0 · Issue #362](https://github.com/denji/homebrew-nginx/issues/362)，执行 brew install 命令，指定需要安装的模块：

- 移除 --with-image-filter，有依赖 --with-gd；补充添加 --with-headers-more-module，后面 nginx 配置会用到。

```Shell
brew install nginx-full \
    --with-debug \
    --with-addition \
    --with-auth-req \
    --with-webdav \
    --with-dav-ext-module \
    --with-headers-more-module \
    --with-gunzip \
    --with-gzip-static \
    --with-realip \
    --with-slice \
    --with-status \
    --with-sub \
    --with-subs-filter-module \
    --with-http2 \
    --with-xslt \
    --with-mail \
    --with-mail-ssl \
    --with-pcre-jit \
    --with-stream \
    --with-stream-ssl \
    --with-stream-ssl-preread \
    --with-auth-pam-module \
    --with-echo-module

```

安装成功输出如下，从中可以获取到一些有用的安装配置信息：

??? info "Installing nginx-full from denji/nginx"

    ```Shell
    ==> Installing nginx-full from denji/nginx
    ==> ./configure --with-http_ssl_module --with-pcre --with-ipv6 --sbin-path=/usr/local/Cellar/nginx-full/1.25.4
    ==> make install
    ==> Caveats
    Docroot is: /usr/local/var/www

    The default port has been set in /usr/local/etc/nginx/nginx.conf to 8080 so that
    nginx can run without sudo.

    nginx will load all files in /usr/local/etc/nginx/servers/.

    - Tips -
    Run port 80:
     $ sudo chown root:wheel /usr/local/opt/nginx-full/bin/nginx
     $ sudo chmod u+s /usr/local/opt/nginx-full/bin/nginx
    Reload config:
     $ nginx -s reload
    Reopen Logfile:
     $ nginx -s reopen
    Stop process:
     $ nginx -s stop
    Waiting on exit process
     $ nginx -s quit

    To start denji/nginx/nginx-full now and restart at startup:
      sudo brew services start denji/nginx/nginx-full
    Or, if you don't want/need a background service you can just run:
      /usr/local/opt/nginx-full/bin/nginx -g daemon\ off\;
    ==> Summary
    🍺  /usr/local/Cellar/nginx-full/1.25.4: 9 files, 1.5MB, built in 45 seconds
    ==> Running `brew cleanup nginx-full`...
    Disable this behaviour by setting HOMEBREW_NO_INSTALL_CLEANUP.
    Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).
    ```

安装成功后，执行 `brew link nginx-full` 提示已经自动链接上了。

```Shell
brew link nginx-full
Warning: Already linked: /usr/local/Cellar/nginx-full/1.25.4
To relink, run:
  brew unlink nginx-full && brew link nginx-full
```

后续如果需要再次重装，可执行 `brew reinstall nginx-full ...` 命令。

### nginx -V

重新执行 `nginx -V`，检查是否包含了 webdav 及其扩展模块：

*   \--with-http\_dav\_module
*   \--add-module=/usr/local/share/dav-ext-nginx-module
*   \--add-module=/usr/local/share/headers-more-nginx-module

??? info "nginx -V"

    ```Shell
    $ nginx -V
    nginx version: nginx/1.25.4
    built by clang 15.0.0 (clang-1500.3.9.4)
    built with OpenSSL 3.2.1 30 Jan 2024
    TLS SNI support enabled
    configure arguments: --prefix=/usr/local/Cellar/nginx-full/1.25.4 --with-http_ssl_module --with-pcre --with-ipv6 --sbin-path=/usr/local/Cellar/nginx-full/1.25.4/bin/nginx --with-cc-opt='-I/usr/local/include -I/usr/local/opt/pcre/include -I/usr/local/opt/openssl@3/include' --with-ld-opt='-L/usr/local/lib -L/usr/local/opt/pcre/lib -L/usr/local/opt/openssl@3/lib' --conf-path=/usr/local/etc/nginx/nginx.conf --pid-path=/usr/local/var/run/nginx.pid --lock-path=/usr/local/var/run/nginx.lock --http-client-body-temp-path=/usr/local/var/run/nginx/client_body_temp --http-proxy-temp-path=/usr/local/var/run/nginx/proxy_temp --http-fastcgi-temp-path=/usr/local/var/run/nginx/fastcgi_temp --http-uwsgi-temp-path=/usr/local/var/run/nginx/uwsgi_temp --http-scgi-temp-path=/usr/local/var/run/nginx/scgi_temp --http-log-path=/usr/local/var/log/nginx/access.log --error-log-path=/usr/local/var/log/nginx/error.log --with-http_addition_module --with-http_auth_request_module --with-debug --with-http_gunzip_module --with-http_gzip_static_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-pcre-jit --with-http_realip_module --with-http_slice_module --with-http_stub_status_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-http_sub_module --with-http_dav_module --with-http_xslt_module --add-module=/usr/local/share/auth-pam-nginx-module --add-module=/usr/local/share/dav-ext-nginx-module --add-module=/usr/local/share/echo-nginx-module --add-module=/usr/local/share/headers-more-nginx-module --add-module=/usr/local/share/subs-filter-nginx-module
    ```

## nginx test

### Docroot

查看 Docroot `/usr/local/var/www/` 文件（夹）属性：

*   owner 都是当前用户：faner\:admin

```Shell
$ ls -l /usr/local/var/
total 0
drwxr-xr-x   3 faner  admin   96 May 13  2020 cache
drwxrwxr-x   4 faner  admin  128 May 28  2021 homebrew
drwxr-xr-x   3 faner  admin   96 Jan 22  2022 log
drwxr-xr-x  30 faner  admin  960 Mar  7  2021 mysql
drwxr-xr-x   4 faner  admin  128 Jan 28  2022 run
drwxr-xr-x   4 faner  admin  128 Dec 28  2021 www

$ ls -l /usr/local/var/www/
total 16
-rw-r--r--  1 faner  admin  497 Dec 28  2021 50x.html
-rw-r--r--  1 faner  admin  615 Dec 28  2021 index.html
```

### nginx -t

nginx -t 检测默认配置文件（/usr/local/etc/nginx/nginx.conf）:

```Shell
$ nginx -t
nginx: the configuration file /usr/local/etc/nginx/nginx.conf syntax is ok
nginx: configuration file /usr/local/etc/nginx/nginx.conf test is successful
```

执行 `nginx -T` 查看配置详情：

```Shel
$ nginx -T
nginx: the configuration file /usr/local/etc/nginx/nginx.conf syntax is ok
nginx: configuration file /usr/local/etc/nginx/nginx.conf test is successful
# configuration file /usr/local/etc/nginx/nginx.conf:

...
```

### start nginx

按照默认配置启动 nginx，只需要执行 `nginx` 命令即可。

或者执行 `brew services start` 启动常驻服务：

```Shell
$ sudo brew services start denji/nginx/nginx-full
Warning: Taking root:admin ownership of some nginx-full paths:
  /usr/local/Cellar/nginx-full/1.25.4/bin
  /usr/local/Cellar/nginx-full/1.25.4/bin/nginx
  /usr/local/opt/nginx-full
  /usr/local/opt/nginx-full/bin
  /usr/local/var/homebrew/linked/nginx-full
This will require manual removal of these paths using `sudo rm` on
brew upgrade/reinstall/uninstall.
==> Successfully started `nginx-full` (label: homebrew.mxcl.nginx-full)
```

!!! note "worker user"

    **注意**：sudo 以 root 身份启动 nginx 的 master process，由于 nginx.conf 中未指定 user，默认以 nobody 启动 worker progress。执行 `ps aux | grep nginx` 可查看 nginx 相关进程。

### curl localhost:8080

执行 `curl localhost:8080` 请求 web 服务，正常返回 `Welcome to nginx!` 欢迎页面（/usr/local/var/www/index.html）：

??? info "Welcome to nginx!"

    ```html
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    html { color-scheme: light dark; }
    body { width: 35em; margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif; }
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

## config webdav

安装好 nginx 后，配置 webdav 服务的主要流程和 httpd 差不多。

### mkdir for webdav

nginx 安装完成提示的 Docroot 是 `/usr/local/var/www`。

在其同级创建 webdav 共享文件夹：`mkdir /usr/local/var/webdav`。

### htpasswd add user

这里使用 Basic 认证，具体配置参考 [Restricting Access with HTTP Basic Authentication](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/)。

```Shell
htpasswd -c /usr/local/etc/nginx/.htpasswd $username
New password:
Re-type new password:
Adding password for user $username
```

### nginx user

[Nginx user 配置引发的血案 - 大象笔记 ](https://www.sunzhongwei.com/nginx-user-conf-and-endless-loop.html)

尝试在 nginx.conf 中修改 user 为 `_www _www`，复用 Apache Httpd 用户，执行 `nginx -t` 检测报错：

```Shell
nginx -t
nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /usr/local/etc/nginx/nginx.conf:3
nginx: the configuration file /usr/local/etc/nginx/nginx.conf syntax is ok
nginx: configuration file /usr/local/etc/nginx/nginx.conf test is successful
```

nginx 只有运行于 root 时，才能在 nginx.conf 中指定 worker user。

执行 `sudo brew services stop` 停止服务后，再执行 chown：

```Shell
 $ mkdir /usr/local/var/webdav
 $ sudo chown -R _www:_www /usr/local/var/webdav/
```

在 nginx.conf 中设置 `root /usr/local/var` 或指定 alias 为 `/usr/local/var/webdav/`。

### nginx.conf

`nginx -V` 输出 `--prefix=/usr/local/Cellar/nginx-full/1.25.4`，此为 macOS 下 brew 安装的 nginx 默认工作空间。
执行 `ls -l` 可以看到其下有个符号链接 html 指向 `/usr/local/var/www`，此即 Docroot。

```Shell
$ ls -l /usr/local/Cellar/nginx-full/1.25.4

lrwxr-xr-x  1 faner  admin      16 Mar 24 09:10 html -> ../../../var/www

```

nginx.conf 中默认根路径配置的 root html 指向 Docroot，后续可按需指向自己的站点目录。

```nginx
            location / {
                root html;
                index index.html index.htm;
            }
```

#### reuse server

在原有配置文件 `/usr/local/etc/nginx/nginx.conf` 中加入新的二级路径映射配置：

> \#user  nobody; 表示以当前用户启动。

1.  新增 dav\_ext\_lock\_zone
2.  指定 charset utf-8;
3.  新增 location /webdav

完整的 nginx.conf 记录备忘如下：

??? info "nginx.conf: reuse 8080 for webdav"

    ```nginx title="/usr/local/etc/nginx/nginx.conf"
    #user  nobody;
    user   _www _www;

    http {
        # config lock for macOS Client
        dav_ext_lock_zone zone=webdav:10m;

        server {
            listen 8080;
            server_name localhost;

            #charset koi8-r;
            # 设置使用UTF-8编码,防止中文文件名乱码
            charset utf-8;

            #access_log  logs/host.access.log  main;

            location / {
                root html;
                index index.html index.htm;
            }

            location /webdav {
                # webdav 共享服务目录（可考虑放在 opt/ 下）
                ## 请注意 chown 为 nginx worker 用户 _www:_www
                root /usr/local/var;
                # alias /usr/local/var/webdav;

                # webdav 用户(_www)的默认权限
                dav_access user:rw group:rw all:r;

                # auth_basic 参数被用作域，并在授权弹窗中显示。
                auth_basic "webdav";
                # htpasswd 用户密码文件存放的位置
                auth_basic_user_file /usr/local/etc/nginx/.htpasswd;

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
                client_body_temp_path /tmp;

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

                # 需要安装 headers-more module
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

            #error_page  404              /404.html;

            # redirect server error pages to the static page /50x.html
            #
            error_page 500 502 503 504 /50x.html;
            location = /50x.html {
                root html;
            }

        }

    }
    ```

#### config new server

无论是 brew info 还是 brew install 输出的信息中，都有一句：

> nginx will load all files in /usr/local/etc/nginx/servers/.

默认配置 nginx.conf 最后有一句 `include servers/*`，意思是会加载 servers 下的所有配置：

```nginx title="/usr/local/etc/nginx/nginx.conf"
http {

    # HTTPS server
    #
    include servers/*;
}
```

因此，可以保留默认的 nginx.conf(.default)，在 servers 下新建 webdav.conf，新建一个 server 监听端口 81 专用于 webdav 服务。

完整的 webdav.conf 记录备忘如下：

??? info "webdav.conf: listen 81"

    ```nginx title="/usr/local/etc/nginx/servers/webdav.conf"
    # config lock for macOS Client
    dav_ext_lock_zone zone=webdav:10m;

    server {
        listen 81;
        server_name localhost;

        # 设置使用UTF-8编码,防止中文文件名乱码
        charset utf-8;

        error_log /usr/local/var/log/nginx/webdav.error.log error;
        access_log /usr/local/var/log/nginx/webdav.access.log combined;

        # [nginx不浏览直接下载文件](https://www.cnblogs.com/oxspirt/p/10250744.html)
        location / {
            # 这里先提供默认页面，后面按需提供website路径
            root html; # prefix/html symlink to /usr/local/var/www
            index index.html index.htm;

            if ($request_filename ~* ^.*?\.(txt|doc|pdf|rar|gz|zip|docx|exe|xlsx|ppt|pptx)$) {
                add_header Content-Disposition: 'attachment;';
            }
        }

        location /webdav {
            # webdav 共享服务目录（可考虑放在 opt/ 下）
            ## 请注意 chown 为 nginx worker 用户 _www:_www
            root /usr/local/var;
            # alias /usr/local/var/webdav;

            # webdav 用户(_www)的默认权限
            dav_access user:rw group:rw all:r;

            # auth_basic 参数被用作域，并在授权弹窗中显示。
            auth_basic "webdav";
            # htpasswd 用户密码文件存放的位置
            auth_basic_user_file /usr/local/etc/nginx/.htpasswd;

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
            client_body_temp_path /tmp;

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

            # 需要安装 headers-more module
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

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root html;
        }
    }
    ```

#### restart nginx server

每次修改了 nginx 配置文件，需要重新加载配置（或重启服务），可以通过以下两种方式：

1. `sudo nginx -s reload`
2. `sudo brew services restart denji/nginx/nginx-full`

!!! tip "How to stop nginx service?"

    ```Shell
    $ sudo nginx -s stop
    # keep registered
    $ sudo brew services kill denji/nginx/nginx-full
    # unregister
    $ sudo brew services stop denji/nginx/nginx-full
    ```

### webdav test

关于 webdav 的连接测试，参考 [macOS上基于httpd搭建WebDav服务](./mac-setup-httpd-dav.md) - 局域网连接验证WebDAV服务 和 [使用命令行挂载操作WebDAV云盘](./cmd-mount-webdav.md) 中的相关说明。

1. 执行 curl localhost:81 验证 web 服务是否正常；
2. WebDAV 客户端访问 http://mbpa1398.local:81/webdav/ 验证 webDAV 服务是否正常。

调试期间，可在 nginx 服务器执行 `tail -f /usr/local/var/log/nginx/webdav.error.log` 实时查看滚动日志。

webdav 运行过程中，会产生一些 cache 文件，可使用 find 命令查找并按需执行 -delete 删除：

=== "macOS cache"

    ```Shell
    $ find /usr/local/var/webdav/ -type f -name "._*" -o -name "*.DS_Store"
    ```

=== "webdav cache"

    ```Shell
    $ find /usr/local/var/webdav/ -type f -name ".DAV" -o -name ".*.swp"
    ```

## refs

[修复Nginx的WebDAV功能](https://www.cnblogs.com/yunteng/p/12449604.html)

1.  修改源代码自己编译
2.  修改配置文件 rewrite

[Nginx webdav 在 Dolphin 上的一些坑](https://nworm.icu/post/nginx-webdav-dolphin-deken/)

1.  无法上传大文件(状态码: 413)
2.  无法创建文件夹(状态码: 409)
3.  无法删除文件夹(状态码: 409)
4.  无法复制/移动文件夹(状态码: 409) - headers-more-nginx-module
