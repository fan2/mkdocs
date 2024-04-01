---
title: 为Material博客添加Google Analytics和Vercount访问统计
authors:
  - xman
date:
    created: 2024-03-29T17:00:00
    updated: 2024-04-01T08:30:00
categories:
    - mkdocs
    - material
tags:
    - analytics
    - search
    - pageviews
comments: true
---

本文简要记录了为 Mkdocs Material Blog 添加 Google Analytics 统计分析服务。

[Setting up site analytics](https://squidfunk.github.io/mkdocs-material/setup/setting-up-site-analytics/): As with any other service offered on the web, understanding how your project documentation is actually used can be an essential success factor. Material for MkDocs natively integrates with [Google Analytics](https://developers.google.com/analytics) and offers a customizable cookie consent and a feedback widget.

<!-- more -->

## Google Analytics

[Google Analytics Guides](https://developers.google.com/analytics/devguides/collection/ga4) - [Introduction to Google Analytics 4](https://developers.google.com/analytics/devguides/collection/ga4) @[zh-cn](https://developers.google.com/analytics/devguides/collection/ga4?hl=zh-cn)

!!! info "Google Analytics 4"

    Google Analytics（分析）4 是一项分析服务，用于衡量您的网站和应用中的流量和互动情况。本文档提供了面向开发者群体的实现说明和参考资料。

参考：[将 Google Analytics（分析）与 Blogger 结合使用](https://support.google.com/blogger/answer/7039627)。

### Set up measurement

进入 [Google Analytics](https://analytics.google.com/analytics/)，使用 google 账号登录，然后点击 Set up measurement，按照提示开始创建评估账号。

1. Account creation: 填写名称
2. Property creation: 填写名称
3. Business details: 选择 Internet & Telecom, 1-10
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

### Admin Reports

后续登录进入 [Analytics | Home](https://analytics.google.com/analytics/)，即可查看对应 Account | Property 的流量统计分析数据。

点击左侧边栏最下方的 ⚙️ 按钮进入 Admin 管理页面，在 Data streams 中点选站点，可以看到 MEASUREMENT ID，默认已经开启 Events | Enhanced Measurement，包括 `Page views` 和 `Site search`。

点击左侧边栏的第二个 Reports 按钮，进入面板可以看到报告快照（Reports snapshot），还可查看其他详细指标：

1. `Acquisition`（获客）: User acquisition（用户获取情况），Traffic acquisition（流量来源情况）；
2. `Engagement`（参与度）: pages and screens, WHICH PAGES AND SCREENS GET THE MOST VIEWS?
3. `Retention`（留存）: HOW WELL DO YOU RETAIN YOUR USERS?

### Reporting API

可以借助 Google Analytics 提供的 Reporting API 将管理后台的数据拉取到网站前端，从而实现显示文章访问、阅读数量等功能。

[Measure pageviews  |  Google Analytics  |  Google for Developers](https://developers.google.com/analytics/devguides/collection/ga4/views?client_type=gtag)

[GA4 - Set up Analytics for a website and/or app - Analytics Help](https://support.google.com/analytics/answer/9304153) - Set up data collection for websites

[Reporting API V4](https://developers.google.com/analytics/devguides/reporting/core/v4)，[Analytics Reporting API v4](https://developers.google.com/analytics/devguides/reporting/core/v4/rest) & [Samples](https://developers.google.com/analytics/devguides/reporting/core/v4/samples)

- [自己建网站怎么添加Google Analytics统计代码查看每日流量](https://blog.naibabiji.com/tutorial/google-analytics.html)
- [使用 Google Analytics API 实现博客阅读量统计 - PRIN BLOG](https://prinsss.github.io/google-analytics-api-page-views-counter/)
- [用 Google Analytics + Vercel Serverless 为文章添加浏览量统计](https://spencer-blog-legacy.vercel.app/2020/06/serverless-ga-hit-count-api/)

## Google Search

[Search Console帮助](https://support.google.com/webmasters) - [Search Console 简介](https://support.google.com/webmasters/answer/9128668)

!!! info "Google Search Console"

    Google Search Console 是一项由 Google 提供的免费服务，可帮助您监控和维护您的网站在 Google 搜索结果中的展示情况以及排查问题。即使没有注册 Search Console，您的网页也可能会显示在 Google 搜索结果中，但 Search Console 可帮助您了解并改进 Google 处理您网站的方式。

参考：[让Google搜索到自己的博客](https://zoharandroid.github.io/2019-08-03-%E8%AE%A9%E8%B0%B7%E6%AD%8C%E6%90%9C%E7%B4%A2%E5%88%B0%E8%87%AA%E5%B7%B1%E7%9A%84%E5%8D%9A%E5%AE%A2/)、[Hexo 个人博客 SEO 优化（3）：改造你的博客，提升搜索引擎排名](https://juejin.cn/post/6844903600485826567)。

### Add a property

1. 查看网站是否被收录: 搜索框输入 site:duetorun.com
2. 在 [Google Search Console](https://search.google.com/search-console?hl=zh) 提交搜索资源（Add a property），选择网址前缀，将生成的 html 文件下载放到网站根目录，点击 [验证网站所有权](https://support.google.com/webmasters/answer/9008080#google_analytics_verification&zippy=%2Cgoogle-analytics%E5%88%86%E6%9E%90%E8%B7%9F%E8%B8%AA%E4%BB%A3%E7%A0%81)。

!!! note "其他验证方法"

    1. HTML 标记：向您网站的首页添加元标记
    2. Google Analytics（分析）：使用您的 Google Analytics（分析）账号，涉及到 [analytics.js](https://developers.google.com/analytics/devguides/collection/analyticsjs/) 或 [gtag.js](https://support.google.com/analytics/answer/1008080)
    3. Google 跟踪代碍管理器：使用您的 Google 跟踪代码管理器账号
    4. 域名提供商：将 DNS 记录与 Google 关联

3. 提交站点地图：Indexing - Sitemaps 上传 site/sitemap.xml。如果没有 sitemap.xml，可到 [xml-sitemaps](https://www.xml-sitemaps.com/) 输入网址生成。
4. 手动请求（重新）编入索引：URL inspection 输入博客网址，然后点击 TEST LIVE URL 手动生成 Page Index。

!!! info ""

    编制索引：正在处理数据，请过 1 天左右再来查看
    Indexing - Pages : Processing data, please check again in a day or so

### link account to analytics

回到 [Analytics | Home](https://analytics.google.com/analytics/)，检测到本 Google 账号注册了 Google Search Console，推荐关联账号。

!!! note "RECOMMENDATION: Link Account"

    Link your Search Console property "https://duetorun.com/" to analyze how search behavior relates to on-site behavior

    Recommended because you are a verified owner of your Search Console property and you have at least the editor role in Analytics

点击 Link Account 链接，将打开 Admin 面板，并自动定位到 Product links 底下新增项 `Search console links`。

点击右侧的 Link 链接按钮，开始 Link setup 流程。

1. `Choose Search Console property`：点开 Choose accounts -- Link to a property I manage，勾选列出的 property，点击 Confirm。

2. 点击 Next，`Select Web Stream`：Choose a data stream，勾选列出的 data stream。

3. 点击 Next，`Review and submit`，确认前两步的选择，没有问题点击 Submit 提交。

4. Results 显示 LINK CREATED。

返回到 Search Console links，可以看到关联的结果。

### indexing policies for search engines

[Using metadata in templates](https://squidfunk.github.io/mkdocs-material/reference/#using-metadata-in-templates)

In order to add custom meta tags to your document, you can extend the theme and override the `extrahead` block, e.g. to add indexing policies for search engines via the `robots` property.

复制 templates/main.html 到 overrides/main.html，在其中添加以下内容：

```html title="apply meta.robots if specified"
{% block extrahead %}
  {% if page and page.meta and page.meta.robots %}
    <meta name="robots" content="{{ page.meta.robots }}" />
  {% endif %}
{% endblock %}
```

这样，通过在页面头部设置元数据即可定制robots抓捕策略。

例如在 about 页面头部添加元数据禁止（Disallow）搜索引擎抓捕：

```Markdown
---
robots: noindex, nofollow
---

...
```

其他页面未指定robots策略，采取的是默认的“法无禁止即可为”的开放（Allow）抓取策略。

!!! info "Google Search Central"

    - [Robots Meta Tags Specifications](https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag)
    - [Robots.txt Introduction and Guide](https://developers.google.com/search/docs/crawling-indexing/robots/intro)
    - [Create and Submit a robots.txt File](https://developers.google.com/search/docs/crawling-indexing/robots/create-robots-txt)

## busuanzi counter

百度统计，谷歌分析等网站统计分析工具，虽然有不错的统计分析功能，但是都不能直接呈现在网站上，都需要进入相应的后台才能查看。

这里尝试使用 [不蒜子](https://busuanzi.ibruce.info/) 提供的统计脚本，将访客人数、访问量统计呈现在自己的网站上。

- [不蒜子实现网站访问量访客数统计](https://blog.csdn.net/weixin_43919632/article/details/101086922)
- [MkDocs实现网站访问统计(不蒜子)](https://blog.csdn.net/arnolan/article/details/105026738)

首先在引入脚本，直接在线嵌入或下载到本地：

```YAML
extra_javascript:
  # busuanzi statistics
  # //busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js
  - javascripts/busuanzi.pure.mini.js

```

### 首页统计总访问量

在站点首页 index.md 末尾添加 `本站总访问量` 和 `总访客数` 的统计：

```html
<span id="busuanzi_container_site_pv" style="font-size:0.8em;color=grey">本站总访问量 <span id="busuanzi_value_site_pv">pv</span> 次</span>，<span id="busuanzi_container_site_uv" style="font-size:0.8em;color=grey">总访客数 <span id="busuanzi_value_site_uv">uv</span> 次。</span>
```

本地调试时，这个统计貌似错乱，上线确认 OK。

!!! note ""

    也可考虑将 templates/partials/copyright.html 复制一份到 overrides/partials/ 下，将站点全局计数显示在底栏中间部位。

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

```Shell hl_lines="8"
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

复制 templates/blog-post.html 到 overrides/blog-post.html，在 page.config.readtime，即 【需要 x 分钟阅读时间】后面添加一行【阅读量：N】：

```html hl_lines="16-23"
                    {% if page.config.readtime %}
                      {% set time = page.config.readtime %}
                      <li class="md-nav__item">
                        <div class="md-nav__link">
                          {% include ".icons/material/clock-outline.svg" %}
                          <span class="md-ellipsis">
                            {% if time == 1 %}
                              {{ lang.t("readtime.one") }}
                            {% else %}
                              {{ lang.t("readtime.other") | replace("#", time) }}
                            {% endif %}
                          </span>
                        </div>
                      </li>
                    {% endif %}
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

- [解决不蒜子 (busuanzi) 文章计数出错问题](https://jdhao.github.io/2020/10/31/busuanzi_pv_count_error/)
- [Vercount: 一个比不蒜子更好的网站计数器](https://ohevan.com/vercount-website-counter-busuanzi-alternative.html)

从不蒜子切换到 [Vercount](https://vercount.one/) @[github](https://github.com/EvanNotFound/vercount)，只需直接替换不蒜子的 script 标签即可，不需要修改任何代码。数据会在初次访问时自动从不蒜子同步。

=== "海外访问优化版本"

    ```html
    <script defer src="https://vercount.one/js"></script>
    ```

=== "中国访问优化版本"

    ```html
    <script defer src="https://cn.vercount.one/js"></script>
    ```

将 mkdocs.yml 中的 `extra_javascript` 部分替换 busuanzi statistics 脚本为 https://vercount.one/js。

```YAML
extra_javascript:
  # busuanzi statistics
  - https://vercount.one/js
```

添加以上脚本之后，复用不蒜子的 pv/uv id，在 html 中插入以下统计标签，即可开始为你的网站统计访问量和访客量。

!!! note ""

    ```html
    本文总阅读量 <span id="busuanzi_value_page_pv">Loading</span> 次
    本文总访客量 <span id="busuanzi_value_page_uv">Loading</span> 人
    本站总访问量 <span id="busuanzi_value_site_pv">Loading</span> 次
    本站总访客数 <span id="busuanzi_value_site_uv">Loading</span> 人
    ```
