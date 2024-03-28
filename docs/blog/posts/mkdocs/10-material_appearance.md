---
title: Material外观
authors:
  - xman
date:
    created: 2024-03-26
categories:
    - mkdocs
    - material
---

Match your brand's colors, fonts, icons, logo, and more with a few lines of configuration – Material for MkDocs makes it easy to extend the basic configuration or alter the appearance.

<!-- more -->

## Logo & Icons

[Changing the logo and icons](https://squidfunk.github.io/mkdocs-material/setup/changing-the-logo-and-icons/?h=#changing-the-logo-and-icons)

支持以下图标：

- [Material Design](https://materialdesignicons.com/)
- [FontAwesome](https://fontawesome.com/icons?d=gallery&m=free)
- [Octicons](https://octicons.github.com/)
- [github markdown](https://github.com/zhangjw-THU/Emoji)
- [github commit](https://github.com/shafishcn/git-commit-emoji-cn)

可以通过将favicon变量设置为.ico或图像文件来更改默认图标。

```YAML
theme:
  name: material
  favicon: 'assets/images/favicon.ico'
```

Logo 应为矩形，最小分辨率为128x128，留出一定的边缘空间，并在透明地面上由高对比度区域组成，因为它将放置在彩色标题栏。

```YAML
theme:
  name: material
  logo: 'images/logo.svg'
```

或者使用 Material Design 图标：

```YAML
theme:
  name: material
  icon:
      logo: material/cloud
```

这里 favicon 和 logo 复用本地 356x356 规格的图片：

```YAML
  favicon: assets/hold_yourself.jpg
  logo: assets/hold_yourself.jpg
```

## Colors

[Changing the colors](https://squidfunk.github.io/mkdocs-material/setup/changing-the-colors/)

支持跟随系统主题切换：System preference | Automatic light / dark mode。

采用官方博客配置 [mkdocs.yml](https://github.com/squidfunk/mkdocs-material/blob/master/mkdocs.yml)：

```YAML
  palette:
    - media: "(prefers-color-scheme)"
      toggle:
        icon: material/link
        name: Switch to light mode
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/toggle-switch
        name: Switch to dark mode
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      primary: black
      accent: indigo
      toggle:
        icon: material/toggle-switch-off
        name: Switch to system preference
```
