---
title: Linux sed & awk
authors:
  - xman
date:
    created: 2019-11-04T08:00:00
categories:
    - wiki
    - linux
tags:
    - sed
    - awk
comments: true
---

Linux 下的 sed & awk 命令概述。

<!-- more -->

## summary

从grep到sed和awk的学习过程是很自然的。  
sed和awk是一般用户、程序员和系统管理员们处理文本文件的有力工具。  
sed的名字来源于其功能，它是个字符流编辑器（stream editor），可以很好地完成对多个文件的一系列编辑工作。  
awk的名字来源于它的开发人Aho、Weinberger和Kernighan，它是一种程序设计语言，非常适合结构化数据的处理和格式化报表的生成。  

## generality

awk 的起源可以追溯到 sed 和 grep，并且经由这两个程序追溯到ed（最初的unix行编辑器）。
如果你使用过vi，那么你一定熟悉其底层的行编辑器ex（它依然是ed中特征的扩展集）。

sed 和 awk 控制指令不同，但有着相似的语法，有如下共性：

1. 面向字符流，逐行读取输入。  
2. 允许用户在脚本中指定指令。  
3. 支持使用正则表达式进行模式匹配。  

## refs

[Linux三大利器grep，sed，awk](https://segmentfault.com/a/1190000015885994)  
[Linux文本处理（Linux三剑客grep、sed和awk）详解](http://c.biancheng.net/linux_tutorial/text_processing/)  

[Unix Shell Programming grep,sed,awk](https://www.genuinecoder.com/unix-shell-programming-grep-sed-awk-html/)  

[sed & awk](https://www.oreilly.com/library/view/sed-awk/1565922255/)  
[Sed and Awk 101 Hacks](https://vds-admin.ru/sed-and-awk-101-hacks) - [ebook](https://www.thegeekstuff.com/sed-awk-101-hacks-ebook/)  
