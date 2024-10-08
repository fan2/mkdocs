---
title: Mkdocs构建部署
authors:
  - xman
date:
    created: 2024-03-23
    updated: 2024-04-02T08:00:00
categories:
    - mkdocs
comments: true
---

User Guide:

- [Command Line Interface](https://www.mkdocs.org/user-guide/cli/)
- [Deploying your docs](https://www.mkdocs.org/user-guide/deploying-your-docs/)

本文梳理了 `build` 构建和 `gh-deploy` 部署命令及部署工作流。

<!-- more -->

## get-deps

Show required PyPI packages inferred from plugins in mkdocs.yml

Usage: `mkdocs get-deps [OPTIONS]`

检查当前 mkdocs.yml 中配置的插件依赖的 PyPI 包。

```Shell
pifan@rpi4b-ubuntu~/Sites/mkdocs $ python3 -m mkdocs get-deps
markdown-checklist
mkdocs
mkdocs-material
pymdown-extensions
```

## serve

Run the builtin development server: `mkdocs serve [OPTIONS]`

Name | Type | Description | Default
-----|------|-------------|--------
`-a`, --dev-addr | text | IP address and port to serve documentation locally (default: localhost:8000) | None
--no-livereload | boolean | Disable the live reloading in the development server. | False
--dirty | text | Only re-build files that have changed. | False
`-c`, --clean | text | Build the site without any effects of mkdocs serve - pure mkdocs build, then serve. | False
`-w`, --watch | path | A directory or file to watch for live reloading. Can be supplied multiple times. | []
`-v`, --verbose | boolean | Enable verbose output | False

1. 默认的 IP 端口是 localhost:8000，可指定 `-a 0.0.0.0:8000`，方便局域网调试。
2. 指定 `--dirty` 只增量编译改动的文件，文档规模增大后，此项可提高调试时的实时加载反馈。

## build

Build the MkDocs documentation: `mkdocs build [OPTIONS]`

Name | Type | Description | Default
-----|------|-------------|--------
`-c`, --clean / --dirty | boolean | Remove old files from the site_dir before building (the default). | True
`-f`, --config-file | filename | Provide a specific MkDocs config. This can be a file name, or '-' to read from stdin. | None
`-d`, --site-dir | path | The directory to output the result of the documentation build. | None
`-v`, --verbose | boolean | Enable verbose output | False

关于 [build速度](http://hpc.ncpgr.cn/linux/086-mkdocs/#buildsu-du) 问题：

mkdocs build 默认使用了 `--clean` 选项，即会在build之前删掉所有之前build时创建的静态文件，如果文档数量较多，整个过程速度会比较慢，如本站build的时间约为25秒，build期间网站不可使用。如果修改比较频繁，则比较影响使用体验。

因此对大型文档网站，只对部分页面进行了修改，可以使用 `mkdocs build --dirty`，只build修改了页面，速度会快很多，如本站使用 `mkdocs build --dirty` 后build的时间缩短为不到2秒。

[官方解释](https://www.mkdocs.org/about/release-notes/#version-016-2016-11-04):

For large sites the build time required to create the pages can become problematic, thus a "dirty" build mode was created. This mode simply compares the modified time of the generated HTML and source markdown. If the markdown has changed since the HTML then the page is re-constructed. Otherwise, the page remains as is. It is important to note that this method for building the pages is for development of content only, since the navigation and other links do not get updated on other pages.

## gh-deploy

Deploy your documentation to GitHub Pages: `mkdocs gh-deploy [OPTIONS]`

Name | Type | Description | Default
-----|------|-------------|--------
`-c`, --clean / --dirty | boolean | Remove old files from the site_dir before building (the default). | True
`-m`, --message | text | A commit message to use when committing to the GitHub Pages remote branch. Commit {sha} and MkDocs {version} are available as expansions | None
`-b`, --remote-branch | text | The remote branch to commit to for GitHub Pages. This overrides the value specified in config | None
`-r`, --remote-name | text | The remote name to commit to for GitHub Pages. This overrides the value specified in config
`--no-history` | boolean | Replace the whole Git history with one new commit. | False
`-d`, --site-dir | path | The directory to output the result of the documentation build. | None

Behind the scenes, MkDocs will build your docs and use the `ghp-import` tool to commit them to the `gh-pages` branch and push the gh-pages

`gh-deploy` 命令执行 `mkdocs build`，然后将生成的静态网页 site 提交到 `gh-pages` 分支（默认的 remote-branch）。

## workflow

在主分支 master 修改了源码 mkdocs.yml 和 docs，本地 serve 验证后，自行 commit-push 提交。

build 会生成 site 目录，gh-deploy 会上传其内容至 gh-pages。
在 .gitignore 中添加 `site/`，使 master 分支忽略临时产物。

**提交流程**：先提交 master，再执行 `gh-deploy` 提交到部署分支。

> gh-deploy 会检测 mkdocs.yml 配置文件。

1. 可采用 `-m` 自定义本次部署提交

    - 默认日志格式是 `Deployed <master-last-commit-hash> with MkDocs version: 1.5.3`。

2. 可通过 `-b` 指定本次部署提交分支，下次不指定，还是提交到默认分支 `gh-pages`。
3. 可通过 `-r` 指定本次部署提交仓库，默认仓库是 `origin`，可指定 `upstream`。
4. `--no-history` 清除部署分支旧的提交记录，以此次提交作为部署起点。

## deploy to nginx

刚好之前在 Raspberry Pi 4B/Ubuntu 上用 nginx 部署 WebDav 服务，81 端口服务只使用了 /webdav 二级路由，可以考虑将 mkdocs material blog 挂载到根路由。

!!! note ""

    关于 nginx 配置，[rpi4b-ubuntu安装nginx-extras并配置WebDav](../webdav/ubuntu-install-nginx-full-config-webdav.md) 中有详细阐述。

ubuntu 下执行 `nginx -V` 可知 nginx 的默认工作空间为 --prefix=/usr/share/nginx。

对于自启的非80服务（这里监听 81 端口），`location /` 未指定 root 时，Docroot 默认为 /usr/share/nginx/html。

这里懒得修改 webdav 配置文件了，假设工程存储在 ~/Sites/mkdocs 目录，执行 `mkdocs build` 生成的静态站点产物目录为 site，那么只需将 site 软链为 /usr/share/nginx/html 即可完成部署，参考 [用mkdocs+nginx搭建个人网站](https://zhuanlan.zhihu.com/p/551345157)。

```Shell
$ sudo mv /usr/share/nginx/html/ /usr/share/nginx/html_bak/
$ sudo ln -s /home/pifan/Sites/mkdocs/site/ /usr/share/nginx/html
```

局域网内，在浏览器输入 http://rpi4b-ubuntu.local:81/（或使用 IP 代替 host），即可访问博客站点。

接下来，可自行购买 VPS 将站点部署上去；或 [将域名交由 cloudflare 托管](https://developers.cloudflare.com/registrar/get-started/transfer-domain-to-cloudflare/)，然后创建一条 [Cloudflare Zero Trust](https://one.dash.cloudflare.com/) 内网穿透隧道（Cloudflare Tunnel），将内网服务（blog+webdav）暴露到公网。

=== "Cloudflare Zero Trust"

    Cloudflare Zero Trust provides the power of Cloudflare's global network to your internal teams and infrastructure. It empowers users with secure, fast, and seamless access to any device on the Internet.

=== "Cloudflare Tunnel"

    Cloudflare Tunnel (formerly Argo Tunnel) establishes a secure outbound connection within your infrastructure to connect applications and machines to Cloudflare.

=== "cloudflared"

    cloudflared is the software powering Cloudflare Tunnel. It runs on origin servers to connect to Cloudflare's network and on client devices for non-HTTP traffic.

[Cloudflare Docs](https://developers.cloudflare.com/) - [Cloudflare Zero Trust docs](https://developers.cloudflare.com/cloudflare-one/) - [Create a locally-managed tunnel (CLI)](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-local-tunnel/)

