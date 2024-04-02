---
draft: true
title: Linux Shell Program - eval & exec
authors:
  - xman
date:
    created: 2019-11-06T10:50:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之执行 eval & exec。

<!-- more -->

参考 man bash - SHELL BUILTIN COMMANDS.

## eval

```Shell
eval [arg ...]

The args are read and concatenated together into a single command. This command is then read and executed by the shell, and its exit status is returned as the value of eval. If there are no args, or only null arguments, eval returns 0.
```

## exec

```Shell
exec [−cl] [−a name] [command [arguments]]

If command is specied, it replaces the shell. No new process is created. The arguments become the arguments to command. If the −l option is supplied, the shell places a dash at the beginning of the zeroth arg passed to command. This is what login(1) does. The −c option causes command to be executed with an empty environment. If −a is supplied, the shell passes name as the zeroth argument to the executed command. If command cannot be executed for some reason, a non-interactive shell exits, unless the shell option execfail is enabled, in which case it returns failure. An interactive shell returns failure if the ﬁle cannot be executed. If command is not speciﬁed, any redirections take effect in the current shell, and the return status is 0. If there is a redirection error, the return status is 1.
```
