---
title: Mkdocs上手
authors:
  - xman
date:
    created: 2024-03-20T00:00:00
categories:
    - mkdocs
comments: true
---

[Getting Started](https://www.mkdocs.org/getting-started/)

Install mkdocs, get started with your first documentation project.

<!-- more -->

## site_name & site_url

The `site_name` and `site_url` configuration options are the only two **required** options in your configuration file. When you create a new project, the `site_url` option is assigned the placeholder value: https://example.com. If the final location is known, you can change the setting now to point to it. Or you may choose to leave it alone for now. Just be sure to edit it before you deploy your site to a production server.

修改站点名称，并指定 URL 链接：

```YAML
site_name: 逃跑计划
site_url: https://duetorun.com/
```

## adding pages to nav

参考 User Guide - [Writing your docs](https://www.mkdocs.org/user-guide/writing-your-docs/) - Configure Pages and Navigation:

The `nav` configuration setting in your mkdocs.yml file defines which pages are included in the global site navigation menu as well as the structure of that menu. If not provided, the navigation will be automatically created by discovering all the Markdown files in the documentation directory. An automatically created navigation configuration will always be sorted alphanumerically by file name (except that index files will always be listed first within a sub-section). You will need to manually define your navigation configuration if you would like your navigation menu sorted differently.

All paths in the navigation configuration must be relative to the `docs_dir` configuration option with default value `docs`.

Any pages not listed in your navigation configuration will still be rendered and included with the built site, however, they will not be linked from the global navigation and will not be included in the previous and next links. Such pages will be "**hidden**" unless linked to directly.

---

As our documentation site will include some navigation headers, you may want to edit the configuration file and add some information about the order, title, and nesting of each page in the navigation header by adding a `nav` setting.

添加 nav 导航，导航栏依次是 `逃跑计划`、`Home`、`About`。

```YAML
site_name: 逃跑计划
site_url: https://duetorun.com/

# 页面导航
nav:
  - Home: index.md
  - About: about.md
```

添加页面 `mkdocs/mkdocs介绍.md`，并将其添加到导航：

```YAML
# 页面导航
nav:
  - Home: index.md
  - Mkdocs: mkdocs/mkdocs介绍.md
  - About: about.md
```

以上配置后，在导航栏的 `Home` 和 `About` 间插入 `Mkdocs`。

如果想导航栏按照目录层次生成层级菜单，可以在 nav 中配置：

```YAML
- Mkdocs:
  - mkdocs: mkdocs/mkdocs介绍.md
```

以上配置中，导航栏一级入口 `Mkdocs`，点击下拉的次级文章标题为 `mkdocs`。
也可依此继续配置三级、四级层叠菜单。

> Note that if a title is defined for a page in the navigation, that title will be used throughout the site for that page and will override any title defined within the page itself.

如果没有指定次级标题，首选文首的一级标题 `# title`，其次文件名（英文首字母大写）。

```YAML
  - Mkdocs:
    - mkdocs/mkdocs介绍.md
```

> Titles **inferred** from the contents of the Markdown file or, if no title is defined within the file, of the file name. To override the title in the `nav` setting add a title right before the filename.

[Writing with Markdown](https://www.mkdocs.org/user-guide/writing-your-docs/#writing-with-markdown) - Meta-Data:

MkDocs will attempt to determine the title of a document in the following ways, in order:

1. A title defined in the `nav` configuration setting for a document.
2. A title defined in the `title` meta-data key of a document.
3. A `level 1` Markdown header on the first line of the document body.
4. The `filename` of a document.

## change theme

Now change the configuration file to alter how the documentation is displayed by changing the theme. Edit the mkdocs.yml file and add a `theme` setting:

```
theme: readthedocs
```

关于主题，详情参考官网相关说明：

1. Home | Features: Great themes available

    There's a stack of good looking themes available for MkDocs. Choose between the built in themes: `mkdocs` and `readthedocs`, select one of the third-party themes (on the [MkDocs Themes](https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes) wiki page as well as the [MkDocs Catalog](https://github.com/mkdocs/catalog#-theming)), or build your own.

1. User Guide 相关专题：

    - [Choosing your Theme](https://www.mkdocs.org/user-guide/choosing-your-theme/)
    - [Customizing Your Theme](https://www.mkdocs.org/user-guide/customizing-your-theme/)
    - [Localizing Your Theme](https://www.mkdocs.org/user-guide/localizing-your-theme/)

## change Favicon

By default, MkDocs uses the [MkDocs favicon](https://www.mkdocs.org/img/favicon.ico) icon. To use a different icon, create an `img` subdirectory in the `docs` directory and copy your custom `favicon.ico` file to that directory. MkDocs will automatically detect and use that file as your favicon icon.

默认自动检测 docs/img/favicon.ico 作为图标。可自己制作或网上搜索喜欢的ico，存放为 docs/img/favicon.ico。

这个不够灵活，material 主题支持指定任意格式的图片文件作为 theme|favicon。

## Building the site

Execute `mkdocs build` to build the documentation.
This will create a new directory, named `site`.

`site` 目录即是 mkdocs 这个 static site generator 生成（generate）的静态网页。

可以将其部署到服务器，以下为 ubuntu/nginx 下最简单的本地部署：

```Shell
$ sudo mv /usr/share/nginx/html/ /usr/share/nginx/html_bak/
$ sudo ln -s /home/pifan/Sites/mkdocs/site/ /usr/share/nginx/html
```
