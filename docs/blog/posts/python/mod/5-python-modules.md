---
title: python常用模块概览
authors:
  - xman
date:
    created: 2019-12-03T08:40:00
categories:
    - python
tags:
    - module
comments: true
---

Python内置模块 builtins 概览，包括常见 FUNCTIONS 和基础 CLASSES。

<!-- more -->

> [Popular Modules](https://www.programcreek.com/python/index/module/list)  

```shell
inspect.getmodule(object)
Try to guess which module an object was defined in.
```

## sys

- sys  

	> This module provides access to some objects used or maintained by the 
interpreter and to functions that interact strongly with the interpreter.

- os  

	> OS routines for NT or Posix depending on what system we're on.  

- platform  

	> This module tries to retrieve as much platform-identifying data as possible.  

> [Python中判断当前系统版本信息](https://www.crifan.com/python_get_current_system_os_type_and_version_info/)

## argparse

- getopt  

	> Parser for command line options.  
	> This module helps scripts to parse the command line arguments in
`sys.argv`.  It supports the same conventions as the Unix `getopt()`
function.  

- optparse  

	> A powerful, extensible, and easy-to-use option parser.

- argparse  

	> Command-line parsing library

---

通过 **getopt** 可解析 Python 传入的参数，**argparse** 则是一个可以自动生成使用帮助（usage）的 Python 模块。  

从2.7开始废弃 optparse 模块，建议使用 argparse。

> **argparse** module is an **optparse**-inspired command-line parsing library

参考：

> [Python命令行参数解析：getopt和argparse](https://blog.csdn.net/lanzheng_1113/article/details/77574446)  
> [python命令行参数处理：argparse、optparse和getopt](https://blog.csdn.net/seu_lyr/article/details/38334007)  
> [python入门：sys.argv与optparse与argparse与getopt的区别](https://blog.csdn.net/foryouslgme/article/details/52814276)  

## string

- string  

	> A collection of string constants.  

### path utilities

- [pathlib](https://docs.python.org/3/library/pathlib.html)  
- nturl2path/macurl2path  

	> Macintosh-specific module for conversion between pathnames and URLs.  

### glob & re

- glob  

	> Filename globbing utility.

- re  

	> Support for regular expressions (RE).

## time

- time  

	> This module provides various functions to manipulate time values.  

- datetime  

	> Fast implementation of the datetime type.  

- timeit  

	> Tool for measuring execution time of small code snippets.

## config

- sysconfig  

	> Access to Python's configuration information.  

- configparser  

	> Configuration file parser.  

## serialization

- xml  

	> Core XML support for Python.  

- json  

> **JSON** (JavaScript Object Notation) <http://json.org> is a subset of
JavaScript syntax (ECMA-262 3rd edition) used as a lightweight data
interchange format.

- plistlib  

	> a tool to generate and parse MacOSX .plist files.  

## storage

- tempfile  

	> Temporary files.  
> This module provides generic, low- and high-level interfaces for
creating temporary files and directories.  

- sqlite3  

## crypt

- random  

	> Random variable generators.  

- base64  

	> Base16, Base32, Base64 (RFC 3548), Base85 and Ascii85 data encodings.  

- binhex  

	> Macintosh binhex compression/decompression.  

- secrets  

	> Generate cryptographically strong pseudo-random numbers suitable for
managing secrets such as account authentication, tokens, and similar.  

- crypt  

	> Wrapper to the POSIX crypt library call and associated functionality.  

- ssl  

	> This module provides some more Pythonic support for SSL.  

## threading

- signal  
- threading  

	> Thread module emulating a subset of Java's threading model.

- dummy_threading  

	> Faux ``threading`` version using ``dummy_thread`` instead of ``thread``.

## network

- ipaddress  

	> A fast, lightweight IPv4/IPv6 manipulation library in Python.  
> This library is used to create/poke/manipulate IPv4 and IPv6 addresses
and networks.  

```shell
>>> import socket
# indicating if IPv6 is supported
>>> socket.has_ipv6
True
```

### socket

- socket  

	> This module provides socket operations and some related functions.
On Unix, it supports IP (Internet Protocol) and Unix domain sockets.
On other systems, it only supports IP. Functions specific for a
socket are available as methods of the socket object.

- socketserver  

	> Generic socket server classes.  

### select

- select  

	> This module supports asynchronous I/O on multiple file descriptors.

- selectors  

	> Selectors module.  
> This module allows high-level and efficient I/O multiplexing, built upon the
`select` module primitives.  

### asyncio

- asynchat  

	> A class supporting chat-style (command/response) protocols.  
> This class adds support for 'chat' style protocols - where one side
sends a 'command', and the other sends a response (examples would be
the common internet protocols - smtp, nntp, ftp, etc..).

- asyncio  

	> The asyncio package, tracking PEP 3156.

- asyncore  

	> Basic infrastructure for asynchronous socket service clients and servers.

### urllib

- urllib  

    - error  
    - parse  
    - request  
    - response  
    - robotparser  

- webbrowser  

	> Interfaces for launching and remotely controlling Web browsers.

### html & http

- html  

	> General functions for HTML manipulation.

- http  

    - client  
    - cookiejar  
    - cookies  
    - server  

- cgi  

	> Support module for **CGI** (Common Gateway Interface) scripts.  
	> This module defines a number of utilities for use by CGI scripts
written in Python.

### other libs

- ftplib  

	> An FTP client class and some helper functions.

- smtpd  

	> An RFC 5321 smtp proxy with optional RFC 1870 and RFC 6531 extensions.

- smtplib  

	> SMTP/ESMTP client class.

- telnetlib  

	> TELNET client class.

## trace

### syslog

- syslog  
- logging  

	> Logging package for Python. Based on PEP 282 and comments thereto in
comp.lang.python.

### trace

- symtable  

	> Interface to the compiler's internal symbol tables

- trace  

	> program/module to trace Python program or function execution

- traceback  

	> Extract, format and print information about Python stack traces.

## test

- unittest  

	> Python unit testing framework

- test  

	> Dummy file to make this directory a package.

参考：

- [Python单元测试——深入理解unittest](https://blog.csdn.net/hackerain/article/details/24095117)  
- [Python必会的单元测试框架 —— unittest](https://blog.csdn.net/huilan_same/article/details/52944782)  
