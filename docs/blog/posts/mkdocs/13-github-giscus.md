---
title: 为Material博客配置giscus评论插件
authors:
  - xman
date:
    created: 2024-03-29T16:30:00
    updated: 2024-03-31T18:00:00
categories:
    - mkdocs
    - material
tags:
    - giscus
comments: true
---

本文简要记录了为 Mkdocs Material Blog 添加 GitHub giscus 评论插件。

[Adding a comment system](https://squidfunk.github.io/mkdocs-material/setup/adding-a-comment-system/): Material for MkDocs allows to easily add the third-party comment system of your choice to the footer of any page by using theme extension. As an example, we'll be integrating [Giscus](https://giscus.app/), which is Open Source, free, and uses GitHub discussions as a backend.

<!-- more -->

## Enable giscus

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

## config comments

再按照 Material 官方教程，在 docs 同级目录创建目录 overrides/partials，创建 comments.html 文件，插入 Enable giscus 脚本。

??? info "overrides/partials/comments.html"

    ```html hl_lines="4-19"
    {% if page.meta.comments %}
      <h2 id="__comments">{{ lang.t("meta.comments") }}</h2>
      <!-- Insert generated snippet here -->
      <script src="https://giscus.app/client.js"
        data-repo="fan2/mkdocs"
        data-repo-id="R_kgDOLltxSg"
        data-category="Announcements"
        data-category-id="DIC_kwDOLltxSs4CeURH"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="1"
        data-input-position="top"
        data-theme="preferred_color_scheme"
        data-lang="zh-CN"
        data-loading="lazy"
        crossorigin="anonymous"
        async>
      </script>

      <!-- Synchronize Giscus theme with palette -->
      <script>
        var giscus = document.querySelector("script[src*=giscus]")

        // Set palette on initial load
        var palette = __md_get("__palette")
        if (palette && typeof palette.color === "object") {
          var theme = palette.color.scheme === "slate"
            ? "transparent_dark"
            : "light"

          // Instruct Giscus to set theme
          giscus.setAttribute("data-theme", theme) 
        }

        // Register event handlers after documented loaded
        document.addEventListener("DOMContentLoaded", function() {
          var ref = document.querySelector("[data-md-component=palette]")
          ref.addEventListener("change", function() {
            var palette = __md_get("__palette")
            if (palette && typeof palette.color === "object") {
              var theme = palette.color.scheme === "slate"
                ? "transparent_dark"
                : "light"

              // Instruct Giscus to change theme
              var frame = document.querySelector(".giscus-frame")
              frame.contentWindow.postMessage(
                { giscus: { setConfig: { theme } } },
                "https://giscus.app"
              )
            }
          })
        })
      </script>
    {% endif %}
    ```

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

!!! info

    The Disqus integration was removed in v8 in favor of theme customization. The new guide explains how to achieve the same result with some block overrides. Note that in the future we might throw that out too in favor of a leaner solution (maybe giscus), as Disqus free version has become too horrible to use.

## refs

[为Mkdocs网站添加评论系统（以giscus为例）](https://blog.csdn.net/m0_63203517/article/details/133819706)
[基于 giscus 为网站添加评论系统](https://fengchao.pro/blog/comment-system-with-giscus/)
