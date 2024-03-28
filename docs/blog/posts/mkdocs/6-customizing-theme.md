---
title: Mkdocs定制主题
authors:
  - xman
date:
    created: 2024-03-22
categories:
    - mkdocs
---

User Guide - [Customizing Your Theme](https://www.mkdocs.org/user-guide/customizing-your-theme/)。

Altering a theme to suit your needs.

If you would like to make a few tweaks to an existing theme, there is no need to create your own theme from scratch. For minor tweaks which only require some CSS and/or JavaScript, you can use the `docs_dir`. However, for more complex customizations, including overriding templates, you will need to use the theme `custom_dir` setting.

<!-- more -->

## Using the docs_dir

The `extra_css` and `extra_javascript` configuration options can be used to make tweaks and customizations to existing themes. To use these, you simply need to include either CSS or JavaScript files within your documentation directory.

For example, to change the color of the headers in your documentation, create a file called (for example) style.css and place it next to the documentation Markdown. In that file add the following CSS.

```css
h1 {
  color: red;
}
```

Then you need to add it to mkdocs.yml:

```YAML
extra_css:
  - style.css
```

> **Note**: Any extra CSS or JavaScript files will be added to the generated HTML document after the page content. If you desire to include a JavaScript library, you may have better success including the library by using the theme `custom_dir`.

## Using the theme custom_dir

The `theme.custom_dir` configuration option can be used to point to a directory of files which **override** the files in a parent theme. The parent theme would be the theme defined in the `theme.name` configuration option. Any file in the `custom_dir` with the same name as a file in the parent theme will **replace** the file of the same name in the parent theme. Any additional files in the `custom_dir` will be added to the parent theme. The contents of the `custom_dir` should mirror the directory structure of the parent theme. You may include templates, JavaScript files, CSS files, images, fonts, or any other media included in a theme.

> **Note**: For this to work, the `theme.name` setting must be set to a known installed theme. If the name setting is instead set to null (or not defined), then there is no theme to override and the contents of the `custom_dir` must be a complete, standalone theme. See the Theme Developer Guide for more information.

For example, the mkdocs theme (browse source), contains the following directory structure (in part):

```
- css\
- fonts\
- img\
  - favicon.ico
  - grid.png
- js\
- 404.html
- base.html
- content.html
- nav-sub.html
- nav.html
- toc.html
```

To override any of the files contained in that theme, create a new directory next to your `docs_dir`:

```Shell
mkdir custom_theme
```

And then point your `mkdocs.yml` configuration file at the new directory:

```YAML
theme:
  name: mkdocs
  custom_dir: custom_theme/
```

To override the 404 error page ("file not found"), add a new template file named 404.html to the `custom_theme` directory. For information on what can be included in a template, review the Theme Developer Guide.

To override the favicon, you can add a new icon file at `custom_theme/img/favicon.ico`.

To include a JavaScript library, copy the library to the `custom_theme/js/ directory`.

Your directory structure should now look like this:

```
- docs/
  - index.html
- custom_theme/
  - img/
    - favicon.ico
  - js/
    - somelib.js
  - 404.html
- config.yml
```

> **Note**: Any files included in the parent theme (defined in name) but not included in the `custom_dir` will still be utilized. The `custom_dir` will only override/replace files in the parent theme.
