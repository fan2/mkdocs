---
title: Mkdocs配置
authors:
  - xman
date:
    created: 2024-03-21
categories:
    - mkdocs
comments: true
---

User Guide - [Configuration](https://www.mkdocs.org/user-guide/configuration/)

Project settings are configured by default using a YAML configuration file in the project directory named mkdocs.yml. You can specify another path for it by using the -f/--config-file option (see mkdocs build --help).

As a minimum, this configuration file must contain the `site_name`. All other settings are optional.

<!-- more -->

## Documentation layout

### exclude_docs

> New in version 1.5

This config defines patterns of files (under [`docs_dir`](https://www.mkdocs.org/user-guide/configuration/#docs_dir)) to not be picked up into the built site.

Example:

    exclude_docs: |
      api-config.json    # A file with this name anywhere.
      drafts/            # A "drafts" directory anywhere.
      /requirements.txt  # Top-level "docs/requirements.txt".
      *.py               # Any file with this extension anywhere.
      !/foo/example.py   # But keep this particular file.

This follows the [.gitignore pattern format](https://git-scm.com/docs/gitignore#_pattern_format).

Note that `mkdocs serve` does *not* follow this setting and instead displays excluded documents but with a "DRAFT" mark. To prevent this effect, you can run `mkdocs serve --clean`.

The following defaults are always implicitly prepended - to exclude dot-files (and directories) as well as the top-level `templates` directory:

    exclude_docs: |
      .*
      /templates/

So, in order to really start this config fresh, you'd need to specify a negated version of these entries first.

Otherwise you could for example opt only certain dot-files back into the site:

    exclude_docs: |
      !.assets  # Don't exclude '.assets' although all other '.*' are excluded

### not_in_nav

> New in version 1.5

**Not**e: This option does *not* actually exclude anything from the nav.

If you want to include some docs into the site but intentionally exclude them from the nav, normally MkDocs warns about this.

Adding such patterns of files (relative to [`docs_dir`](https://www.mkdocs.org/user-guide/configuration/#docs_dir)) into the `not_in_nav` config will prevent such warnings.

Example:

    nav:
      - Foo: foo.md
      - Bar: bar.md

    not_in_nav: |
      /private.md

As the previous option, this follows the .gitignore pattern format.

**Note**: Adding a given file to [`exclude_docs`](https://www.mkdocs.org/user-guide/configuration/#exclude_docs) takes precedence over and implies `not_in_nav`.
