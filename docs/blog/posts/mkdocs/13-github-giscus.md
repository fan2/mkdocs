---
title: 安装giscus评论插件
authors:
  - xman
date:
    created: 2024-03-29T16:30:00
categories:
    - material
tags:
    - giscus
comments: true
---

本文简要记录了为 Mkdocs Material Blog 添加 GitHub giscus 评论插件。

[Adding a comment system](https://squidfunk.github.io/mkdocs-material/setup/adding-a-comment-system/): Material for MkDocs allows to easily add the third-party comment system of your choice to the footer of any page by using theme extension. As an example, we'll be integrating [Giscus](https://giscus.app/), which is Open Source, free, and uses GitHub discussions as a backend.

<!-- more -->

点进 <https://github.com/apps/giscus> 右侧点击 Install，授权 Repository access。

再进入 <https://giscus.app/> Configuration

**language** 选择 `简体中文`（默认为 en）。

**Repository**：

> The Discussions feature is turned on by [enabling it for your repository](https://docs.github.com/en/github/administering-a-repository/managing-repository-settings/enabling-or-disabling-github-discussions-for-a-repository).

按照链接说明，点进 repo 的 Settings，下滑到 Features 部分，勾选 `Discussions`。

返回 giscus.app 重新填写 repo 名称 `fan2/mkdocs`，验证通过。

**Discussion Category** 选择 `Announcements`。

**Features** 勾选以下选项：

- [x] `Emit discussion metadata`
- [x] `Place the comment box above the comments`
- [x] `Load the comments lazily`

拷贝生成的 Enable giscus 脚本。

再按照 Material 官方教程，在 docs 同级目录创建目录 overrides/partials，创建 comments.html 文件，插入 Enable giscus 脚本。

在配置文件中指定 custom_dir：

```YAML
theme:
  name: material
  custom_dir: overrides
```

在要开启评论的md文章开头元数据开启评论：

```Markdown
---
comments: true
---

# Page title
...

```

---

Relevant background: [Disqus integration is broken in latest releases](https://github.com/squidfunk/mkdocs-material/issues/3433)

The Disqus integration was removed in v8 in favor of theme customization. The new guide explains how to achieve the same result with some block overrides. Note that in the future we might throw that out too in favor of a leaner solution (maybe giscus), as Disqus free version has become too horrible to use.
