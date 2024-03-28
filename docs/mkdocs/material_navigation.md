[Setting up navigation](https://squidfunk.github.io/mkdocs-material/setup/setting-up-navigation/)

## instant loading

When instant loading is enabled, clicks on all internal links will be intercepted and dispatched via [XHR](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) without fully reloading the page. Add the following lines to mkdocs.yml:

> The `site_url` setting must be set.

```YAML
theme:
  features:
    - navigation.instant
```

`Instant prefetching`(sponsors only) is a new experimental feature that will start to fetch a page once the user hovers over a link. This will reduce the perceived loading time for the user, especially on slow connections, as the page will be available immediately upon navigation. Enable it with:

```YAML
theme:
  features:
    - navigation.instant
    - navigation.instant.prefetch
```

`Progress indicator`: In order to provide a better user experience on slow connections when using instant navigation, a progress indicator can be enabled. It will be shown at the top of the page and will be hidden once the page has fully loaded. You can enable it in mkdocs.yml with:

```YAML
theme:
  features:
    - navigation.instant
    - navigation.instant.progress
```

The progress indicator will only show if the page hasn't finished loading after 400ms, so that fast connections will never show it for a better instant experience.

## Anchor tracking

When anchor tracking is enabled, the URL in the address bar is automatically updated with the active anchor as highlighted in the table of contents. Add the following lines to mkdocs.yml:

```YAML
theme:
  features:
    - navigation.tracking # 在url中使用标题定位锚点
```

## Navigation tabs

When tabs are enabled, top-level sections are rendered in a menu layer below the header for viewports above 1220px, but remain as-is on mobile.1 Add the following lines to mkdocs.yml:

```YAML
theme:
  features:
    - navigation.tabs
```

When sticky tabs are enabled, navigation tabs will lock below the header and always remain visible when scrolling down. Just add the following two feature flags to mkdocs.yml:

```YAML
theme:
  features:
    - navigation.tabs # 顶部显示导航顶层nav（也就是第一个节点）
    - navigation.tabs.sticky # 滚动时隐藏顶部nav，需要配合navigation.tabs使用
```

## Table of contents

`Anchor following`: When anchor following for the table of contents is enabled, the sidebar is automatically scrolled so that the active anchor is always visible. Add the following lines to mkdocs.yml:

```YAML
theme:
  features:
    - toc.follow
```

`Navigation integration`: When navigation integration for the table of contents is enabled, it is always rendered as part of the navigation sidebar on the left. Add the following lines to mkdocs.yml:

```YAML
theme:
  features:
    - toc.integrate # 右侧 TOC 集成到左侧 nav sidebar
```

### hide per doc

在 Markdown 文档开头的 meta-data 中可以设置隐藏左侧 nav 和右侧 toc 侧边栏。

The navigation and/or table of contents sidebars can be hidden for a document with the front matter hide property. Add the following lines at the top of a Markdown file:

```Markdown
---
hide:
  - navigation
  - toc
---

# Page title
...

```

## Back-to-top button

A back-to-top button can be shown when the user, after scrolling down, starts to scroll up again. It's rendered centered and just below the header. Add the following lines to mkdocs.yml:

```YAML
theme:
  features:
    - navigation.top # 开启一键回到页面顶部按钮
```

## Header - Automatic hiding

[Setting up the header](https://squidfunk.github.io/mkdocs-material/setup/setting-up-the-header/)

When autohiding is enabled, the header is automatically hidden when the user scrolls past a certain threshold, leaving more space for content. Add the following lines to mkdocs.yml:

```YAML
theme:
  features:
    - header.autohide # 向下滚动时自动隐藏header
```

## Footer

[Setting up the footer](https://squidfunk.github.io/mkdocs-material/setup/setting-up-the-footer/)

The footer can include links to the previous and next page of the current page. If you wish to enable this behavior, add the following lines to mkdocs.yml:

```YAML
theme:
  features:
    - navigation.footer # 开启底部上一篇/下一篇导航
```

### hide per doc

在 Markdown 文档开头的 meta-data 中可以设置隐藏底部上一篇/下一篇导航。

The footer navigation showing links to the previous and next page can be hidden with the front matter hide property. Add the following lines at the top of a Markdown file:

```YAML
---
hide:
  - footer
---

# Page title
...

```
