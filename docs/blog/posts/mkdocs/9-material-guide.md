---
title: 采用Material主题
authors:
  - xman
date:
    created: 2024-03-25
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

```Shell
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

## 参考借鉴

[使用 MkDocs 和 Material 主题搭建技术博客](http://www.cuishuaiwen.com:8000/zh/PROJECT/TECH-BLOG/mkdocs_and_material/) @[github](https://github.com/Shuaiwen-Cui/Infinity/)

[基于 Material for MkDocs 搭建静态网页](https://derrors.github.io/) @[github](https://github.com/Derrors/Derrors.github.io)

[把博客生成器从 Hugo 迁移到 Mkdocs](https://jia.je/meta/2023/07/15/migrate-from-hugo-to-mkdocs/) @[github](https://github.com/jiegec/blog-source/)

[Mkdocs Material使用记录](https://shafish.cn/blog/mkdocs/) - 详尽完备 @[github](https://github.com/tffats/shafish_blog)

[快来美化你的MKDocs吧](https://juejin.cn/post/7066641709198737416#heading-5) - material 配置

[Material for MkDocs改动的几个地方](https://zimohan.com/it/materialmkdocs.html)

[华中农业大学作重计算平台用户手册](http://hpc.ncpgr.cn/)