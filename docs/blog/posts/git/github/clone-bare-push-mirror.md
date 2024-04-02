---
title: github复制迁移仓库
authors:
  - xman
date:
    created: 2018-09-04T08:00:00
    updated: 2022-04-29T15:12:00
categories:
    - git
tags:
    - github
    - mirror
comments: true
---

如何克隆导入github外部仓库上的项目到内部仓库，并且保留源仓库的分支和提交信息？

<!-- more -->

具体参考 [GitHub-复制仓库](https://docs.github.com/cn/repositories/creating-and-managing-repositories/duplicating-a-repository) 和 [使用 git push –mirror 迁移 Git 项目](http://i.lckiss.com/?p=7230)。

要维护存储库的镜像而不对其进行复刻，可以运行特殊的克隆命令，然后镜像推送到新存储库。

具体示例如下，将 YYKit 从 github 克隆一份到 gitee 上：

```Shell
# 1. 创建仓库的裸克隆
$ git clone --bare https://github.com/ibireme/YYKit.git
# 2. 镜像推送至新仓库
$ git push --mirror https://gitee.com/fan2/YYKit.git
```

然后（移除本地的 github YYKit），重新clone拉下 gitee 仓库镜像 fan2/YYKit：

```Shell
$ rm -rf YYKit
$ git pull https://gitee.com/fan2/YYKit.git
```
