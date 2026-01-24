---
title: Mkdocs构建部署
authors:
  - xman
date:
    created: 2024-03-23T00:00:00
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
# python3 -m mkdocs get-deps
pifan@rpi4b-ubuntu~/Sites/mkdocs $ mkdocs get-deps
mkdocs
mkdocs-material
pymdown-extensions
```

## serve

Run the builtin development server: `mkdocs serve [OPTIONS]`, see usage with `mkdoc serve --help`.

Name             | Type    | Description                                                                         | Default
-----------------|---------|-------------------------------------------------------------------------------------|--------
`-a`, --dev-addr | text    | IP address and port to serve documentation locally (default: localhost:8000)        | None
--no-livereload  | boolean | Disable the live reloading in the development server                                | False
--livereload     | boolean | Enable the live reloading in the development server                                 | False
--dirty          | text    | Only re-build files that have changed.                                              | False
`-c`, --clean    | text    | Build the site without any effects of mkdocs serve - pure mkdocs build, then serve. | False
`-w`, --watch    | path    | A directory or file to watch for live reloading. Can be supplied multiple times.    | []
`-v`, --verbose  | boolean | Enable verbose output                                                               | False

1. 默认的 IP 端口是 localhost:8000，可指定 `-a 0.0.0.0:8000`，方便局域网调试。
2. 指定 `--dirty` 只增量编译改动的文件，文档规模增大后，可提高调试时的热加载反馈。

执行 `mkdocs serve` 启动本地测试服务：`-a` 指定监听端口；`--livereload` 开启热加载；`--dirty` 只编译改动的文件。

```bash hl_lines="5"
$ mkdocs serve -a 0.0.0.0:8000 --livereload --dirty
INFO    -  Building documentation...
WARNING -  A 'dirty' build is being performed, this will likely lead to inaccurate navigation and other links within your site. This option is designed for site development purposes only.
INFO    -  Documentation built in 23.15 seconds
INFO    -  [08:12:44] Watching paths for changes: 'docs', 'mkdocs.yml'
INFO    -  [08:12:44] Serving on http://0.0.0.0:8000/
```

当修改了 mkdocs.yml 文件或 docs 目录下的文件，浏览器会自动刷新。

```bash hl_lines="1 4"
INFO    -  [08:15:38] Detected file changes
INFO    -  Building documentation...
INFO    -  Documentation built in 0.55 seconds
INFO    -  [08:15:39] Reloading browsers
```

在 mkdocs.yml 中配置了博客的 URL 格式：

```yaml
      post_url_date_format: yyyyMMdd
      post_url_format: "{date}/{file}"
```

### vscode task

在 vscode 中修改某篇博客后，我们希望能在本地浏览器中打开该博客文章，以便预览修改后的渲染效果。
要预览修改后的文档，只能从 blog 中逐级点开进入；或者基于当前打开文档的创建时间和文件名，手动拼接出 URL 再在浏览器中打开。
由于每篇博客的创建时间都在开头的 meta 声明中，无法快速拼接出其 URL。可以考虑基于 vscode task 自动化这个过程，加快调试效率。

> VS Code tasks are used to run scripts and automate processes within the editor, such as building, linting, testing, or deploying software, without having to use the command line directly. They integrate with various external tools like npm, Gulp, Make, and Rake.

在 vscode 中，创建 .vscode/tasks.json 任务配置文件来配置编译/调试任务。

1. task 1: Start mkdocs serve with HMR，执行 *serve.sh* 启动 mkdocs serve 热加载服务。

```json
            "label": "Start mkdocs serve with HMR",
            "type": "shell",
            "command": ".vscode/serve.sh",
```

2. task 2: Preview blog in Google Chrome，执行 *preview.sh* 在浏览器中预览博客文章。

    - [Variables reference](https://code.visualstudio.com/docs/reference/variables-reference)：vscode 内置变量 `${file}` 为当前打开文件的绝对路径（含文件名和扩展名）。

```json
            "label": "Preview blog in Google Chrome",
            "type": "shell",
            "command": ".vscode/preview.sh",
            "args": [
                "${file}"
            ],
```

在脚本 preview.sh 中，首先读取传入的文件内容基于 `sed` 命令提取出日期，再拼接不含扩展名的文件名，即为博客相对路径（blog_path）。
假设监听的端口为8000，则博客的 base_url = `http://localhost:8000/blog`，基于 base_url 和 blog_path 拼接出博客 URL（blog_url）。
preview.sh 脚本最后调用 `open -a "Google Chrome" $blog_url` 在 Google Chrome 浏览器中新开 tab 打开博客进行预览。

```bash
# get the absolute path of current openned file of vscode
file=$1
echo "blog file = $file"
full_file_name=$(basename $file)    # get file name with extension
file_name=${full_file_name%.*}      # remove extension .md

# extract blog created time and concat with file name to build blog url
created_date=$(sed -n 's/.*created: \(.*\)T.*/\1/p' $file | tr -d '-')
blog_path=$created_date/$file_name  # concat blog path
blog_url=$MKDOCS_BLOG/$blog_path    # concat blog url

# open blog url in Google Chrome Browser
echo "open in Google Chrome: $blog_url"
open -a "Google Chrome" $blog_url
```

在 vscode 中，`⌘⇧P` 打开命令面板（Pallette），输入选择 *Tasks: Run Task*：

1. *Start mkdocs serve with HMR* 启动 `mkdocs serve --livereload --dirty` 热加载服务。
2. *Preview blog in Google Chrome* 在 Chrome 浏览器中预览 vscode 当前打开的博客文章。

## build

Build the MkDocs documentation: `mkdocs build [OPTIONS]`

Name                    | Type     | Description                                                                           | Default
------------------------|----------|---------------------------------------------------------------------------------------|--------
`-c`, --clean / --dirty | boolean  | Remove old files from the site_dir before building (the default).                     | True
`-f`, --config-file     | filename | Provide a specific MkDocs config. This can be a file name, or '-' to read from stdin. | None
`-d`, --site-dir        | path     | The directory to output the result of the documentation build.                        | None
`-v`, --verbose         | boolean  | Enable verbose output                                                                 | False

关于 [build速度](http://hpc.ncpgr.cn/linux/086-mkdocs/#buildsu-du) 问题：

mkdocs build 默认使用了 `--clean` 选项，即会在build之前删掉所有之前build时创建的静态文件，如果文档数量较多，整个过程速度会比较慢，如本站build的时间约为25秒，build期间网站不可使用。如果修改比较频繁，则比较影响使用体验。

因此对大型文档网站，只对部分页面进行了修改，可以使用 `mkdocs build --dirty`，只build修改了页面，速度会快很多，如本站使用 `mkdocs build --dirty` 后build的时间缩短为不到2秒。

[官方解释](https://www.mkdocs.org/about/release-notes/#version-016-2016-11-04):

For large sites the build time required to create the pages can become problematic, thus a "dirty" build mode was created. This mode simply compares the modified time of the generated HTML and source markdown. If the markdown has changed since the HTML then the page is re-constructed. Otherwise, the page remains as is. It is important to note that this method for building the pages is for development of content only, since the navigation and other links do not get updated on other pages.

## gh-deploy

Deploy your documentation to GitHub Pages: `mkdocs gh-deploy [OPTIONS]`

Name                    | Type    | Description                                                                                                                              | Default
------------------------|---------|------------------------------------------------------------------------------------------------------------------------------------------|--------
`-c`, --clean / --dirty | boolean | Remove old files from the site_dir before building (the default).                                                                        | True
`-m`, --message         | text    | A commit message to use when committing to the GitHub Pages remote branch. Commit {sha} and MkDocs {version} are available as expansions | None
`-b`, --remote-branch   | text    | The remote branch to commit to for GitHub Pages. This overrides the value specified in config                                            | None
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

## deploy to Cloudflare Pages

[Cloudflare Pages](https://pages.cloudflare.com/) 是 Cloudflare 提供的静态站点托管服务，支持 GitHub、GitLab、Bitbucket 等主流代码托管平台。

1. 登入 Cloudflare，点击左侧菜单的 Workers & Pages，进入 Pages 控制台，点击 `Import an existing Git repository`：

![Workers&Pages-Get_started](./images/Cloudflare_Page/1-Workers&Pages-Get_started.jpg)

2. 点击【Connect Github】按钮：

![Deploy_a_site_from_Github](./images/Cloudflare_Page/2-Deploy_a_site_from_Github.png)

3. 输入 Github account 账号，选择一个仓库 `mkdocs`：

![Connect_Github-Select_repository](./images/Cloudflare_Page/3-Connect_Github-Select_repository.jpg)

4. 在弹出的 Github 授权界面中，点击【Install & Authorize】按钮：

![Install&Authorize_on_your_personal_github_account](./images/Cloudflare_Page/4-Install&Authorize_on_your_personal_github_account.png)

5. 输入 Project name: `mkdocs`，Framework preset 选择 MkDocs 框架，输入构建命令（Build command）: `mkdocs build`。

??? warning "dependency requirements of mkdocs-material"

    参考 [Build image · Cloudflare Pages docs](https://developers.cloudflare.com/pages/configuration/build-image/#supported-languages-and-tools)，构建机 Supported languages and tools 默认安装了 python/pip，但是并没有 mkdocs。

    需要在执行 `mkdocs build` 的工程目录下放置 requirements.txt 以便构建机（Workers）预安装依赖的 mkdocs-material 工具集。

    在工程目录下执行 `mkdocs get-deps` 获取依赖：mkdocs-material 依赖 `mkdocs` 和 `pymdown-extensions`。

    ```bash
    $ mkdocs get-deps
    mkdocs
    mkdocs-material
    pymdown-extensions
    ```

    假如还要依赖 `mkdocs-callouts` 插件，以便将 Obsidian style callouts 转换成 mkdocs supported 'admonitions' (a.k.a. callouts)，则项目的直接依赖如下：

    ```yaml title='requirements.in'
    mkdocs-material~=9.7.0
    mkdocs-callouts>=1.16.0
    ```

    接下来，可借助 `pip-tools` 的 `pip-compile` 命令或 `uv` 的 `pip compile` 来基于 `requirements.in` 生成完整的 `requirements.txt`。

    ```bash
    $ uv pip compile requirements.in -o requirements.txt

    $ cat requirements.txt
    # This file was autogenerated by uv via the following command:
    #    uv pip compile requirements.in -o requirements.txt
    babel==2.17.0
        # via mkdocs-material
    backrefs==6.1
        # via mkdocs-material
    certifi==2025.11.12
        # via requests
    # ...
    ```

![Set_up_builds_and_deployments](./images/Cloudflare_Page/5-Set_up_builds_and_deployments.png)

6. 点击【Custom Domains】，Enter domain 输入在 Cloudflare 上购买托管的域名，下一步 Configure DNS 显示 Cloudflare 将会为站点配置一条 DNS 记录，点击【Activate domain】进入验证（Verifying）：

![Custom_domains-Enter_Domain-Confirm_New_DNS](./images/Cloudflare_Page/6-Custom_domains-Enter_Domain-Confirm_New_DNS.png)

![Custom_domains-Activate_domain-Verifying](./images/Cloudflare_Page/7-Custom_domains-Activate_domain-Verifying.jpg)

7. 在 Cloudflare 的 DNS Records 管理界面，可以找到刚刚添加的 CNAME 记录：

![Confirm_new_DNS_Record_under_domain_management](./images/Cloudflare_Page/8-Confirm_new_DNS_Record_under_domain_management.png)

8.回到 Workers & Pages / mkdocs 的 Custom domains 界面，可以看到自定义域名已经激活生效：

![Custom_domains-Active](./images/Cloudflare_Page/9-Custom_domains-Active.png)

上面已将 Cloudflare Pages 项目连接到 GitHub 库，当向分支推送更改时将会自动触发 Cloudflare Workers 构建部署 Pages。
