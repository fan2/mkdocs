---
title: Markdown扩展
authors:
  - xman
date:
    created: 2024-03-24
categories:
    - mkdocs, markdown
---

User Guide - [Writing your docs](https://www.mkdocs.org/user-guide/writing-your-docs/)。

MkDocs pages must be authored in [Markdown](https://daringfireball.net/projects/markdown/).

MkDocs uses the [Python-Markdown](https://python-markdown.github.io/) library to render Markdown documents to HTML.

<!-- more -->

## markdown_extensions

MkDocs includes support for extending the Markdown syntax with Python-Markdown [extensions](https://python-markdown.github.io/extensions/). See the MkDocs' [markdown\_extensions](https://www.mkdocs.org/user-guide/configuration/#markdown_extensions) configuration setting for details on how to enable extensions.

MkDocs includes some extensions by default, which are highlighted below.

1. Internal links: `toc`
2. Meta-Data: `meta`
3. Tables: `tables`
4. Fenced code blocks: `fenced_code`

    - 貌似默认主题已带代码高亮，参考 [Choosing your Theme](https://www.mkdocs.org/user-guide/choosing-your-theme/) - mkdocs。

建议启用以下扩展：

1. `nl2br`
2. `sane_lists`
3. `footnotes`
4. `codehilite`: 需要安装 Pygments

## More extensions

[User Guide](https://www.mkdocs.org/user-guide/configuration/) - Configuration

Formatting options | markdown_extensions

The Python-Markdown documentation provides a [list of extensions](https://python-markdown.github.io/extensions/) which are available out-of-the-box. For a list of configuration options available for a given extension, see the documentation for that extension.

You may also install and use various third party extensions ([Python-Markdown wiki](https://github.com/Python-Markdown/markdown/wiki/Third-Party-Extensions), [MkDocs project catalog](https://github.com/mkdocs/catalog)). Consult the documentation provided by those extensions for installation instructions and available configuration options.

### checklist

[checklist](https://github.com/FND/markdown-checklist): Adds GitHub-style task lists with checkboxes

执行 `pip install markdown-checklist` 安装扩展插件，然后在 mkdocs.yml 中引入：

```YAML
markdown_extensions:

   - markdown_checklist.extension
```

- [ ] undo1
- [ ] undo2
- [x] done1
- [x] done2

## YAML Style Meta-Data

YAML style meta-data consists of YAML key/value pairs wrapped in YAML style delimiters to mark the start and/or end of the meta-data. The first line of a document must be `---`. The meta-data ends at the first line containing an end deliminator (either `---` or `...`). The content between the delimiters is parsed as YAML.

```YAML
---
title: My Document
summary: A brief description of my document.
authors:
    - Waylan Limberg
    - Tom Christie
date: 2018-07-10
some_url: https://example.com
---
This is the first paragraph of the document.
```

YAML is able to detect data types. Therefore, in the above example, the values of `title`, `summary` and `some_url` are strings, the value of `authors` is a list of strings and the value of `date` is a datetime.date object. Note that the YAML keys are case sensitive and MkDocs expects keys to be all lowercase. The top level of the YAML must be a collection of key/value pairs, which results in a Python dict being returned. If any other type is returned or the YAML parser encounters an error, then MkDocs does not recognize the section as meta-data, the page's meta attribute will be empty, and the section is not removed from the document.

关于 metadata 的扩展使用案例，参考：

- [Mkdocs Material使用记录](https://shafish.cn/blog/mkdocs/)
- [Material for MkDocs改动的几个地方](https://zimohan.com/it/materialmkdocs.html)
