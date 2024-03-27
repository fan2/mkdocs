
User Guide:

- [Command Line Interface](https://www.mkdocs.org/user-guide/cli/)
- [Deploying your docs](https://www.mkdocs.org/user-guide/deploying-your-docs/)

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
`-f`, --config-file | filename | Provide a specific MkDocs config. This can be a file name, or '-' to read from stdin. | None
`-d`, --site-dir | path | The directory to output the result of the documentation build. | None

## gh-deploy

Deploy your documentation to GitHub Pages

Usage: `mkdocs gh-deploy [OPTIONS]`

Name | Type | Description | Default
-----|------|-------------|--------
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
