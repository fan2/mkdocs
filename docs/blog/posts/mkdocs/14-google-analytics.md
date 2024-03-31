---
title: 安装Google Analytics
authors:
  - xman
date:
    created: 2024-03-29T17:00:00
categories:
    - material
tags:
    - analytics
comments: true
---

本文简要记录了为 Mkdocs Material Blog 添加 Google Analytics 统计分析服务。

[Setting up site analytics](https://squidfunk.github.io/mkdocs-material/setup/setting-up-site-analytics/): As with any other service offered on the web, understanding how your project documentation is actually used can be an essential success factor. Material for MkDocs natively integrates with [Google Analytics](https://developers.google.com/analytics) and offers a customizable cookie consent and a feedback widget.

<!-- more -->

## Google Analytics

登录 google 账号，然后进入 [Google Analytics](https://analytics.google.com/analytics/web/)，点击 Setup a Measurement，按照提示开始创建账号。

1. Account creation: 填写名称
2. Property creation: 填写名称
3. Business details: 选择 Internet & Telecom 1-10
4. Business objectives: 选择 Get baseline reports
5. Data collection: Web - Set up data stream

填写 site_url & site_name 后，获得 MEASUREMENT ID: `G-XXXXXXXXXX`。

在 mkdocs.yml 中添加配置即可：

```YAML
extra:
  analytics:
    provider: google
    property: G-XXXXXXXXXX

```

后续登录进入 <https://analytics.google.com/analytics/web/> 即可查看对应账户的流量统计分析数据。

## busuanzi

百度统计，谷歌分析等网站统计分析工具，虽然有不错的统计分析功能，但是都不能直接呈现在网站上，都需要进入相应的后台才能查看。

这里尝试使用不蒜子提供的统计脚本，将访客人数、访问量统计呈现在自己的网站上。

首先在引入脚本，直接在线嵌入或下载到本地：

```YAML
extra_javascript:
  # busuanzi statistics
  # //busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js
  - javascripts/busuanzi.pure.mini.js

```

### 首页统计总访问量

在站点首页 index.md 末尾添加 `本站总访问量` 和 `本站总访客数` 的统计：

```html
<span id="busuanzi_container_site_pv" style="font-size:0.8em;color=grey">本站总访问量 <span id="busuanzi_value_site_pv">pv</span> 次</span>，<span id="busuanzi_container_site_uv" style="font-size:0.8em;color=grey">总访客数 <span id="busuanzi_value_site_uv">uv</span> 次。</span>
```

本地调试时，这个统计貌似错乱，上线确认 OK。

### 博客文章阅读量

[Overriding templates](https://squidfunk.github.io/mkdocs-material/setup/setting-up-a-blog/#overriding-templates)

The following templates are added by the built-in blog plugin:

- blog.html – Template for blog, archive and category index
- blog-post.html – Template for blog post

首先查看安装 mkdocs-material 的 site-pacages 目录：

```Shell
$ mkdocs -V
mkdocs, version 1.5.3 from /usr/local/lib/python3.10/site-packages/mkdocs (Python 3.10)
```

在 site-packages 目录下找到 material，其 templates 目录下存放着网页模板文件：

```Shell
$ tree -L 1 /usr/local/lib/python3.10/site-packages/material/templates
/usr/local/lib/python3.10/site-packages/material/templates
├── 404.html
├── __init__.py
├── __pycache__
├── assets
├── base.html
├── blog-post.html
├── blog.html
├── main.html
├── mkdocs_theme.yml
├── partials
└── redirect.html

4 directories, 8 files
```

修改之前，先将 blog-post.html 备份为 0-blog-post.html。
在 blog-post.html 的 page.config.readtime，即 【需要 x 分钟阅读时间】后面添加一行【阅读量 N 次】：

```html
                    <li class="md-nav__item">
                      <div class="md-nav__link">
                        {% include ".icons/material/book-open-page-variant-outline.svg" %}
                        <span class="md-ellipsis" id="busuanzi_container_page_pv">
                          阅读量：<span id="busuanzi_value_page_pv">N/A</span>
                        </span>
                      </div>
                    </li>
```

从本地调试来看，文章阅读量貌似正确，上线确认桌面 Chrome 没问题。
但是 iPhone/iPad Safari 不准确，貌似是多篇全局累计。

> 注意：mkdocs-material 包升级时，会覆写掉 blog-post.html！

### 替换为 Vercount

从不蒜子切换到 [Vercount](https://vercount.one/) @[github](https://github.com/EvanNotFound/vercount)，只需直接替换不蒜子的 script 标签即可，不需要修改任何代码。

> 数据会在初次访问时自动从不蒜子同步。

```html
<script defer src="https://vercount.one/js"></script>
```

在你的网站中添加上面其中之一的 script 之后，和不蒜子一样，你的网站就可以开始统计了。

!!! note ""

    ```html
    本文总阅读量 <span id="busuanzi_value_page_pv">Loading</span> 次
    本文总访客量 <span id="busuanzi_value_page_uv">Loading</span> 人
    本站总访问量 <span id="busuanzi_value_site_pv">Loading</span> 次
    本站总访客数 <span id="busuanzi_value_site_uv">Loading</span> 人
    ```

参考：

- [不蒜子实现网站访问量访客数统计](https://blog.csdn.net/weixin_43919632/article/details/101086922)
- [MkDocs实现网站访问统计(不蒜子)](https://blog.csdn.net/arnolan/article/details/105026738)

- [解决不蒜子 (busuanzi) 文章计数出错问题](https://jdhao.github.io/2020/10/31/busuanzi_pv_count_error/)
- [Vercount: 一个比不蒜子更好的网站计数器](https://ohevan.com/vercount-website-counter-busuanzi-alternative.html)
