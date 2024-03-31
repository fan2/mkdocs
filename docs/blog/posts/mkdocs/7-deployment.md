---
title: Mkdocs构建部署
authors:
  - xman
date:
    created: 2024-03-23
categories:
    - mkdocs
comments: true
---

User Guide:

- [Command Line Interface](https://www.mkdocs.org/user-guide/cli/)
- [Deploying your docs](https://www.mkdocs.org/user-guide/deploying-your-docs/)

本文梳理了 `build` 和 `gh-deploy` 部署命令及部署工作流。

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

## build

Build the MkDocs documentation

Usage: `mkdocs build [OPTIONS]`

Name | Type | Description | Default
-----|------|-------------|--------
`-c`, --clean / --dirty | boolean | Remove old files from the site_dir before building (the default). | True
`-f`, --config-file | filename | Provide a specific MkDocs config. This can be a file name, or '-' to read from stdin. | None
`-d`, --site-dir | path | The directory to output the result of the documentation build. | None

关于 [build速度](http://hpc.ncpgr.cn/linux/086-mkdocs/#buildsu-du) 问题：

mkdocs build 默认使用了 `--clean` 选项，即会在build之前删掉所有之前build时创建的静态文件，如果文档数量较多，整个过程速度会比较慢，如本站build的时间约为25秒，build期间网站不可使用。如果修改比较频繁，则比较影响使用体验。

因此对大型文档网站，只对部分页面进行了修改，可以使用 `mkdocs build --dirty`，只build修改了页面，速度会快很多，如本站使用 `mkdocs build --dirty` 后build的时间缩短为不到2秒。

[官方解释](https://www.mkdocs.org/about/release-notes/#version-016-2016-11-04):

For large sites the build time required to create the pages can become problematic, thus a "dirty" build mode was created. This mode simply compares the modified time of the generated HTML and source markdown. If the markdown has changed since the HTML then the page is re-constructed. Otherwise, the page remains as is. It is important to note that this method for building the pages is for development of content only, since the navigation and other links do not get updated on other pages.

## gh-deploy

Deploy your documentation to GitHub Pages

Usage: `mkdocs gh-deploy [OPTIONS]`

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
