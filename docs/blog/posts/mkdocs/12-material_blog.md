---
title: Material博客
authors:
  - xman
date:
    created: 2024-03-28
categories:
    - mkdocs
    - material
---

[Setting up a blog](https://squidfunk.github.io/mkdocs-material/setup/setting-up-a-blog/)

Material for MkDocs makes it very easy to build a blog, either as a sidecar to your documentation or standalone. Focus on your content while the engine does all the heavy lifting, automatically generating [archive](https://squidfunk.github.io/mkdocs-material/plugins/blog/#archive) and [category](https://squidfunk.github.io/mkdocs-material/plugins/blog/#categories) indexes, post slugs, configurable pagination and more.

[Built-in blog plugin](https://squidfunk.github.io/mkdocs-material/plugins/blog/)

<!-- more -->

## blog plugin

The built-in blog plugin adds support for building a blog from a folder of posts, which are annotated with dates and other structured data. First, add the following lines to mkdocs.yml:

```YAML
  plugins:
    - blog
```

启用后，首次 serve 或 build，在 docs 目录下会创建一个 blog 文件夹：

```Shell
$ tree -L 2 docs/blog
docs/blog
├── index.md
└── posts

2 directories, 1 file
```

## Blog only

如果想把 mkdocs 站点当做纯博客，可以去掉 blog 中间层目录，直接在 docs 目录下 posts。

You might need to build a pure blog without any documentation. In this case, you can create a folder tree like this:

```Shell
.
├─ docs/
│  ├─ posts/ 
│  ├─ .authors.yml
│  └─ index.md
└─ mkdocs.yml
```

And add the following lines to mkdocs.yml:

```YAML
plugins:
  - blog:
      blog_dir: . 
```

With this configuration, the url of the blog post will be `/<post_slug>` instead of `/blog/<post_slug>`.

## doc with Blog

正常是笔记文档+博客，博客只是其中一个专项入口。

在 blog/posts 下创建一个 hello-world.md：

```Shell
.
├─ docs/
│  └─ blog/
│     ├─ posts/
│     │  └─ hello-world.md 
│     └─ index.md
└─ mkdocs.yml
```

Create a new file called hello-world.md and add the following lines:

```Markdown
---
draft: true 
date: 2024-01-31 
categories:
  - Hello
  - World
---

# Hello world!

Here is the content

...

```

that `archive` and `category` indexes have been automatically generated for you.

## How it works

The plugin scans the configured *posts* directory for `.md` files from which paginated views are automatically generated. If not configured otherwise, the plugin expects that your project has the following directory layout, and will create any missing directories or files for you:

```Shell
.
├─ docs/
│  └─ blog/
│     ├─ posts/
│     └─ index.md
└─ mkdocs.yml
```

The `index.md` file in the blog directory is the entry point to your blog – a paginated view listing all posts in reverse chronological order. Besides that, the plugin supports automatically creating archive and category pages that list a subset of posts for a time interval or category.

**Post URLs** are completely configurable, no matter if you want your URLs to include the post's date or not. Rendered dates always display in the locale of the site language of your project. Like in other static blog frameworks, posts can be annotated with a variety of metadata, allowing for easy integration with other built-in plugins, e.g., the social and tags plugin.

Posts can be organized in nested folders with a directory layout that suits your specific needs, and can make use of all components and syntax that Material for MkDocs offers, including admonitions, annotations, code blocks, content tabs, diagrams, icons, math, and more.

## config blog

1. 配置 blog.blog_dir
2. 配置 blog.post_url_format
3. 配置 pagination_per_page
4. nav 导航加入 blog 入口

```YAML
plugins:
  # enabled by default, but must be re-added when other plugins are used.
  - search
  # categorize any page with tags as part of the front matter of the page
  - tags
  - blog:
      blog_dir: blog
      # post_dir: posts
      post_date_format: long
      post_url_date_format: yyyyMMdd
      post_url_format: "{date}/{file}"
      pagination_per_page: 10

# 页面导航
nav:
  - Blog: blog/index.md
```

## Adding an excerpt

内容摘要 + 继续阅读

blog 默认的摘要和正文内容分割符为：`post_excerpt_separator: <!-- more -->`

---

The blog index, as well as archive and category indexes can either list the entire content of each post, or excerpts of posts. An excerpt can be created by adding a <!-- more --> separator after the first few paragraphs of a post:

```Markdown
# Hello world!

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
massa, nec semper lorem quam in massa.

<!-- more -->
...
```

When the built-in blog plugin generates all indexes, the content before the excerpt separator is automatically extracted, allowing the user to start reading a post before deciding to jump in.

## meta-data

### Adding categories

blog 默认启用了分类插件。

Categories are an excellent way for grouping your posts thematically on dedicated index pages. This way, a user interested in a specific topic can explore all of your posts on this topic. Make sure categories are enabled and add them to the front matter categories property:

```Markdown
---
date: 2024-01-31
categories:
  - Hello
  - World
---

# Hello world!
...
```

If you want to save yourself from typos when typing out categories, you can define your desired categories in mkdocs.yml as part of the `categories_allowed` configuration option. The built-in blog plugin will stop the build if a category is not found within the list.

### Adding tags

需要显式启用 tags 插件。

Besides categories, the built-in blog plugin also integrates with the built-in tags plugin. If you add tags in the front matter tags property as part of a post, the post is linked from the tags index:

```Markdown
---
date: 2024-01-31
tags:
  - Foo
  - Bar
---

# Hello world!
...
```

As usual, the tags are rendered above the main headline and posts are linked on the tags index page, if configured. Note that posts are, as pages, only linked with their titles.

### Changing the slug

在文章开头的 meta 信息中可以指定 slug。

Slugs are the shortened description of your post used in the URL. They are automatically generated, but you can specify a custom slug for a page:

```
---
slug: hello-world
---

# Hello there world!
...
```

### Setting the reading time

需要 x 分钟阅读时间。

When enabled, the readtime package is used to compute the expected reading time of each post, which is rendered as part of the post and post excerpt. Nowadays, many blogs show reading times, which is why the built-in blog plugin offers this capability as well.

Sometimes, however, the computed reading time might not feel accurate, or result in odd and unpleasant numbers. For this reason, reading time can be overridden and explicitly set with the front matter readtime property for a post:

```Markdown
---
date: 2024-01-31
readtime: 15
---

# Hello world!
...
```

This will disable automatic reading time computation.

## Adding pages

正常情况下，配置好了 blog_dir/post_dir 后，mkdocs-material 会自动监测扫描 posts 目录下 `.md` 文件，并将博客列表添加到博客首页 index.md(index.html)。

当然，除了在 nav 中配置 blog 入口，也可手动将 blog 下的其他文件加入 nav 导航。

Besides **posts**, it's also possible to add static pages to your blog by listing the pages in the `nav` section of mkdocs.yml. All generated indexes are included after the last specified page. For example, to add a page on the authors of the blog, add the following to mkdocs.yml:

```YAML
nav:
  - Blog:
    - blog/index.md
    - blog/authors.md
      ...
```
