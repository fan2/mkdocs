---
title: 采用Material主题
authors:
  - xman
date:
    created: 2024-03-25T00:00:00
    updated: 2024-04-01T13:20:00
categories:
    - mkdocs
    - material
comments: true
---

[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)

Documentation that simply works

Material for MkDocs is a powerful documentation framework on top of MkDocs, a static site generator for project documentation.

<!-- more -->

## 安装 mkdocs-material

[Getting started](https://squidfunk.github.io/mkdocs-material/getting-started/) - [Installation](https://squidfunk.github.io/mkdocs-material/getting-started/)

```bash
$ pip install mkdocs-material
# or 
$ pip3 install mkdocs-material
# or 
$ python3 -m pip install mkdocs-material
```

## 设置主题为 material

[Getting started](https://squidfunk.github.io/mkdocs-material/getting-started/) - [Creating your site](https://squidfunk.github.io/mkdocs-material/creating-your-site/) - Configuration

**Minimal configuration**：

在 mkdocs.yml 配置文件中，指定主题 material，替换默认的 mkdocs 主题：

```YAML
# 指定主题
theme:
  name: material

```

## Setup & Customization

**Advanced configuration**: 

Material for MkDocs comes with many configuration options. The [Setup](https://squidfunk.github.io/mkdocs-material/setup/) section explains in great detail how to configure and customize colors, fonts, icons and much more

1. Site structure
2. Appearance
3. Content
4. Optimization

[Getting started](https://squidfunk.github.io/mkdocs-material/getting-started/) - [Customization](https://squidfunk.github.io/mkdocs-material/customization/)

1. Adding assets
2. Extending the theme
3. Theme development

## MkDocs Material Preview

[MkDocs Material Preview - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=0x10.mkdocs-material-preview): A VS Code extension that enhances the built-in Markdown preview to render **[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)** and **[Zensical](https://zensical.org/)** components that are not supported by the default Markdown renderer.

它通过附加插件来扩展 VS Code 内置的 Markdown 解析器--`markdown-it`，从而增强支持渲染/预览以下 Material 特性组件：

- **Admonitions** — `!!! type "title"` (standard), `??? type` (collapsible), `???+ type` (collapsible, open)
- **Content Tabs** — `=== "Tab Title"` with CSS-only tab switching
- **Code Enhancements** — `title="file.py"`, `hl_lines="2 4-6"`, `linenums="1"` on fenced code blocks

它是预览 Material for MkDocs/Zensical 语法最高效的方式，无需任何配置步骤，只需打开预览界面即可使用。

The relevant commands in Command Pallete are as follows: 

1. Markdown: Toggle Preview View
2. Markdown: Open Preview to the Side
3. Markdown: Open Preview
4. Markdown: Switch to Preview View

## 参考借鉴

Stackoverflow - [Questions tagged mkdocs-material](https://stackoverflow.com/questions/tagged/mkdocs-material)

[Migrating my blog from Jekyll Minimal Mistakes to Mkdocs Material](https://copdips.com/2023/12/migrating-my-blog-from-jekyll-minimal-mistakes-to-mkdocs-material.html) @[github](https://github.com/copdips/copdips.github.io)

claassen.net - [Blogging with mkdocs](https://claassen.net/geek/blog/2024/01/blogging-with-mkdocs.html)

[使用 MkDocs 和 Material 主题搭建技术博客](http://www.cuishuaiwen.com:8000/zh/PROJECT/TECH-BLOG/mkdocs_and_material/) @[github](https://github.com/Shuaiwen-Cui/Infinity/)

[基于 Material for MkDocs 搭建静态网页](https://derrors.github.io/) @[github](https://github.com/Derrors/Derrors.github.io)

[把博客生成器从 Hugo 迁移到 Mkdocs](https://jia.je/meta/2023/07/15/migrate-from-hugo-to-mkdocs/) @[github](https://github.com/jiegec/blog-source/)

[Mkdocs Material使用记录](https://shafish.cn/blog/mkdocs/) - 详尽记录 @[github](https://github.com/tffats/shafish_blog)

[快来美化你的MKDocs吧](https://juejin.cn/post/7066641709198737416#heading-5) - material 配置

[Material for MkDocs改动的几个地方](https://zimohan.com/it/materialmkdocs.html)
