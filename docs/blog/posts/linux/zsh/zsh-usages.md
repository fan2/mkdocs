---
title: macOS下zsh的使用配置
authors:
  - xman
date:
    created: 2019-10-27T10:30:00
categories:
    - wiki
    - zsh
comments: true
---

zsh 帮助、环境变量和配置相关的使用记录。

<!-- more -->

## zsh 版本

执行 `zsh --version` 或 `echo $ZSH_VERSION` 可查看 **zsh** 版本：

```Shell
# 查看 zsh 版本

faner@MBP-FAN:~|⇒  zsh --version
zsh 5.3 (x86_64-apple-darwin17.0)

faner@MBP-FAN:~|⇒  echo $ZSH_VERSION
5.3

```

## zsh 帮助

执行 `man zsh` 可查看 zsh 帮助手册：

```Shell
################################################################################
# man zsh
################################################################################

faner@MBP-FAN:~/.oh-my-zsh/custom|master
ZSH(1)                                                                                     ZSH(1)



NAME
       zsh - the Z shell

OVERVIEW
       Because  zsh  contains  many features, the zsh manual has been split into a number of sec-
       tions:

       zsh          Zsh overview (this section)
       zshroadmap   Informal introduction to the manual
       zshmisc      Anything not fitting into the other sections
       zshexpn      Zsh command and parameter expansion
       zshparam     Zsh parameters
       zshoptions   Zsh options
       zshbuiltins  Zsh built-in functions
       zshzle       Zsh command line editing
       zshcompwid   Zsh completion widgets
       zshcompsys   Zsh completion system
       zshcompctl   Zsh completion control
       zshmodules   Zsh loadable modules
       zshtcpsys    Zsh built-in TCP functions
       zshzftpsys   Zsh built-in FTP client
       zshcontrib   Additional zsh functions and utilities
       zshall       Meta-man page containing all of the above
```

可 man 查看各个子主题，或 `man zshall` 查看完整文档。

## ZSH 环境变量

输入 `echo $ZSH` 再按 tab 键可列举所有以 ZSH 开头的环境变量：

```Shell
################################################################################
# ZSH envirment variables
################################################################################

faner@MBP-FAN:~|⇒  echo $ZSH
ZSH                            ZSH_NAME                       ZSH_THEME_GIT_PROMPT_PREFIX
ZSH_ARGZERO                    ZSH_PATCHLEVEL                 ZSH_THEME_GIT_PROMPT_SUFFIX
ZSH_CACHE_DIR                  ZSH_SPECTRUM_TEXT              ZSH_THEME_TERM_TAB_TITLE_IDLE
ZSH_COMPDUMP                   ZSH_SUBSHELL                   ZSH_THEME_TERM_TITLE_IDLE
ZSH_CUSTOM                     ZSH_THEME                      ZSH_VERSION
ZSH_DISABLE_COMPFIX            ZSH_THEME_GIT_PROMPT_CLEAN     zsh_eval_context
ZSH_EVAL_CONTEXT               ZSH_THEME_GIT_PROMPT_DIRTY     zsh_scheduled_events
```

### ZSH 目录

```Shell
################################################################################
# ZSH DIR
################################################################################

faner@MBP-FAN:~|⇒  echo $ZSH
/Users/faner/.oh-my-zsh

faner@MBP-FAN:~|⇒  cd $ZSH
faner@MBP-FAN:~/.oh-my-zsh|master ⇒

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_CACHE_DIR
/Users/faner/.oh-my-zsh/cache

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_COMPDUMP
/Users/faner/.zcompdump-MBP-FAN-5.3

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_CUSTOM
/Users/faner/.oh-my-zsh/custom

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_DISABLE_COMPFIX
true

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_EVAL_CONTEXT
toplevel
```

#### git 仓库

```Shell
faner@MBP-FAN:~/.oh-my-zsh|master ⇒  git remote -v
origin	https://github.com/robbyrussell/oh-my-zsh.git (fetch)
origin	https://github.com/robbyrussell/oh-my-zsh.git (push)
```

#### 子目录

```Shell
faner@MBP-FAN:~/.oh-my-zsh|master ⇒  ls -1
CONTRIBUTING.md
LICENSE.txt
README.md
cache
custom
lib
log
oh-my-zsh.sh
plugins
templates
themes
tools

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  tree -L 1
.
├── CONTRIBUTING.md
├── LICENSE.txt
├── README.md
├── cache
├── custom
├── lib
├── log
├── oh-my-zsh.sh
├── plugins
├── templates
├── themes
└── tools

8 directories, 4 files
```

- `cache`：缓存；  
- `custom`：个性化配置目录，自安装的插件和主题可放这里；  
- `lib`：提供了核心功能的脚本库；  
- `log`：日志；  
- `plugins`：自带插件的存在放位置;  
- `templates`：自带模板的存在放位置;  
- `themes`：自带主题文件的存在放位置;  
- `tools`：提供安装、升级等功能的快捷工具;  

### ZSH 名称

```Shell
################################################################################
# ZSH_NAME
################################################################################

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_NAME
zsh

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_PATCHLEVEL
zsh-5.3-0-g4cfdbdb

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_SPECTRUM_TEXT
Arma virumque cano Troiae qui primus ab oris

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_SUBSHELL
0
```

### ZSH 主题

```Shell
################################################################################
# ZSH_THEME
################################################################################

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_THEME
pygmalion

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_THEME_GIT_PROMPT_CLEAN

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_THEME_GIT_PROMPT_DIRTY
%{%}⚡%{%}

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_THEME_GIT_PROMPT_PREFIX
%{%}%{%}

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_THEME_GIT_PROMPT_SUFFIX
%{%}

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_THEME_TERM_TAB_TITLE_IDLE
%15<..<%~%<<

faner@MBP-FAN:~/.oh-my-zsh|master ⇒  echo $ZSH_THEME_TERM_TITLE_IDLE
%n@%m: %~

```

zsh 默认主题是 `robbyrussell`，可在 `~/.zshrc` 中修改为 `pygmalion`：

```Shell
ZSH_THEME="pygmalion" #"robbyrussell"
```

可将主题设置为随机（`random`），这样每次启动新 zsh 命令行窗口时，会随机从默认主题中选择一个。  

根据提示可知当前加载的主题名称：

```Shell
[oh-my-zsh] Random theme '/Users/faner/.oh-my-zsh/themes/duellj.zsh-theme' loaded...
```

当觉得当前主题比较中意时，可配置到 `~/.zshrc` 作为 ZSH_THEME。  

- https://github.com/robbyrussell/oh-my-zsh/wiki/Themes  
- https://github.com/robbyrussell/oh-my-zsh/wiki/External-themes  
- https://github.com/unixorn/awesome-zsh-plugins#themes  

## ZSH 配置

`~/.zshrc`

[zshrc配置](https://www.cnblogs.com/halu126/p/7589170.html)

man zsh 可知，zsh 的配置文件如下：

```
# man zsh on macOS

FILES
       $ZDOTDIR/.zshenv
       $ZDOTDIR/.zprofile
       $ZDOTDIR/.zshrc
       $ZDOTDIR/.zlogin
       $ZDOTDIR/.zlogout
       ${TMPPREFIX}*   (default is /tmp/zsh*)
       /etc/zshenv
       /etc/zprofile
       /etc/zshrc
       /etc/zlogin
       /etc/zlogout    (installation-specific - /etc is the default)
```

## omz 插件

Oh My Zsh 默认自带的插件存放在 `~/.oh-my-zsh/plugins` 目录中，可以 cd 进入查看。

Oh My Zsh 默认只启用了 git 插件：

```Shell
# ~/.zshrc
plugins=(git)
```

可进入 git 插件目录，执行 `git remote -v` 查看插件远端仓库；
打开 `README.md` 文档可查看插件说明：

```Shell
faner@MBP-FAN:~|⇒  cd $ZSH/plugins
cd $ZSH/plugins

faner@MBP-FAN:~/.oh-my-zsh/plugins/git|master
⇒  git remote -v
git remote -v
origin	https://github.com/robbyrussell/oh-my-zsh.git (fetch)
origin	https://github.com/robbyrussell/oh-my-zsh.git (push)

faner@MBP-FAN:~/.oh-my-zsh/plugins/git|master
⇒  open README.md
```

> The git plugin provides many aliases and a few useful functions.  
> See the [wiki](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugin:git) for a list of aliases and functions provided by the plugin.  

---

如需启用更多插件，可在括号中以空格相隔加入所需插件：

```Shell
plugins=(git svn history)
```

更多插件可参考：

https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins  
https://github.com/unixorn/awesome-zsh-plugins  
https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins-Overview  

## omz 更新

当 **Oh-My-Zsh** 有更新时，默认提示确认是否升级。  
可在 `~/.zshrc` 中添加 **`DISABLE_UPDATE_PROMPT=true`** 禁用提示自动更新。  

或执行 **`upgrade_oh_my_zsh`** 命令手动更新：

```Shell
faner@MBP-FAN:~/.oh-my-zsh|master ⇒  upgrade_oh_my_zsh
Updating Oh My Zsh
remote: Counting objects: 1671, done.
remote: Compressing objects: 100% (845/845), done.
remote: Total 1671 (delta 887), reused 1482 (delta 723), pack-reused 0
Receiving objects: 100% (1671/1671), 378.39 KiB | 43.00 KiB/s, done.
Resolving deltas: 100% (887/887), completed with 183 local objects.
From https://github.com/robbyrussell/oh-my-zsh
 * branch            master     -> FETCH_HEAD
   4cb7307..0853b74  master     -> origin/master
 LICENSE.txt                                             |    2 +-
 README.md                                               |   38 +-

 260 files changed, 7672 insertions(+), 2508 deletions(-)

 create mode 100644 custom/themes/example.zsh-theme

 mode change 100644 => 100755 themes/trapd00r.zsh-theme

First, rewinding head to replay your work on top of it...
Fast-forwarded master to 0853b74fef0fa3a05af7487ff9b15a7f714bb037.
         __                                     __
  ____  / /_     ____ ___  __  __   ____  _____/ /_
 / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \
/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / /
\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/
                        /____/
Hooray! Oh My Zsh has been updated and/or is at the current version.
To keep up on the latest news and updates, follow us on twitter: https://twitter.com/ohmyzsh
Get your Oh My Zsh swag at:  https://shop.planetargon.com/

```

**最新提示**：Note: `upgrade_oh_my_zsh` is deprecated. Use `omz update` instead.

执行 `omz help` 查看帮助：

```Shell
$ omz help
Usage: omz <command> [options]

Available commands:

  help                Print this help message
  changelog           Print the changelog
  plugin <command>    Manage plugins
  pr     <command>    Manage Oh My Zsh Pull Requests
  reload              Reload the current zsh session
  theme  <command>    Manage themes
  update              Update Oh My Zsh
  version             Show the version
```

执行 omz 更新，会自动更新内置插件（存放在 `$ZSH/plugins` 目录）。

### 更新 custom 插件

[oh my zsh - How to auto-update custom plugins in Oh My Zsh? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/477258/how-to-auto-update-custom-plugins-in-oh-my-zsh)

Oh My Zsh upgrades are handled by the `$ZSH/tools/upgrade.sh` script. To update any custom plugins (assuming those are Git clones), you can add these lines to the end of the script before the exit command:

```Shell
cd $ZSH_CUSTOM
printf "\n${BLUE}%s${RESET}\n" "Updating custom plugins, scripts and themes"

for plugin in ./*/*; do
  if [ -d "$plugin/.git" ]; then
     printf "${YELLOW}%s${RESET}\n" "${plugin%/}"
     # git -C "$plugin" pull
  fi
done
```

也可以下载使用 [autoupdate](https://github.com/TamCore/autoupdate-oh-my-zsh-plugins) 插件。

> oh-my-zsh plugin for auto updating of git-repositories in `$ZSH_CUSTOM` folder.
