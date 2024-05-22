---
title: GDB Enhanced Extensions
authors:
  - xman
date:
    created: 2020-03-10T09:00:00
    updated: 2023-10-01T10:00:00
categories:
    - toolchain
comments: true
---

Vanilla GDB in its raw form has a rather uninformative interface and its syntax is arcane and difficult to approach. It sucks in terms of user experience and is terrible to use for reverse engineering and exploit development.

To make debugging easier and more productive, there are extensions for GDB such as `GEF`, `pwndbg` that provide a more informative view and additional commands.

<!-- more -->

## GDB Enhanced

[Blue Fox: Arm Assembly Internals and Reverse Engineering](https://www.amazon.com/Blue-Fox-Assembly-Internals-Analysis/dp/1119745306) | Chapter 11 Dynamic Analysis - Command-Line Debugging

1. [pwndbg](https://github.com/pwndbg/pwndbg): Exploit Development and Reverse Engineering with GDB Made Easy
2. [GEF](https://github.com/hugsy/gef) (GDB Enhanced Features): a modern experience for GDB with advanced debugging capabilities for exploit devs & reverse engineers on Linux
3. [PEDA](https://github.com/longld/peda) - Python Exploit Development Assistance for GDB

[Pwndbg + GEF + Peda — One for all, and all for one](https://infosecwriteups.com/pwndbg-gef-peda-one-for-all-and-all-for-one-714d71bf36b8)

Step 1 - git clone plugin:

```bash
$ cd ~ && mkdir gdbe

$ cd ~/gdbe
$ git clone https://github.com/pwndbg/pwndbg
$ cd pwndbg && ./setup.sh
$ echo "source ~/gdbe/pwndbg/gdbinit.py" > ~/.gdbinit_pwndbg

$ cd ~/gdbe
$ git clone https://github.com/hugsy/gef.git
$ cd gef && cp gef.py ~/.gdbinit-gef.py
```

Step 2 - config `.gitinit`:

```bash title=".gdbinit"
define init-pwndbg
source ~/.gdbinit_pwndbg
end
document init-pwndbg
Initializes PwnDBG
end

define init-gef
source ~/.gdbinit-gef.py
end
document init-gef
Initializes GEF (GDB Enhanced Features)
end
```

Step 3 - create exec files in `/usr/local/bin` folder:

```bash
$ sudo vim /usr/local/bin/gdb-pwndbg
#!/bin/sh
exec gdb -q -ex init-pwndbg "$@"

$ sudo vim /usr/local/bin/gdb-gef
#!/bin/sh
exec gdb -q -ex init-gef "$@"

$ sudo chmod +x /usr/local/bin/gdb-*
```

Now you can test it by running either one of the three commands:

- `gdb` - native
- `gdb-pwndbg`
- `gdb-gef`

## usage of gef

<https://hugsy.github.io/gef/>

`GEF` is a set of commands for x86/64, ARM, MIPS, PowerPC and SPARC to assist exploit developers and reverse-engineers when using old school GDB.

### context.layout

gef allows you to configure your own setup for the display, by re-arranging the order with which contexts will be displayed.

```bash
gef➤  gef config context.layout
────────────────────────────────────── GEF configuration setting: context.layout ──────────────────────────────────────
context.layout (str) = "legend regs stack code args source memory threads trace extra"

Description:
	Change the order/presence of the context sections
```

To hide a section, simply use the context.layout setting, and prepend the section name with - or just omit it.

```bash
gef➤ gef config context.layout "-legend regs stack code args -source -threads -trace extra memory"
```

This configuration will not display the legend, source, threads, and trace sections.

### context.nb_lines_code

`nb_lines_code` and `nb_lines_code_prev` configure how many lines to show after and before the PC, respectively(default is 6, 3).

```bash
gef➤  gef config context.nb_lines_code 10

# reload the settings during the session
gef➤  gef restore

# To save the current settings permanently
gef➤  gef save
```

## usage of pwndbg

<https://pwndbg.re/>

`pwndbg` is a GDB plug-in that makes debugging with GDB suck less, with a focus on features needed by low-level software developers, hardware hackers, reverse-engineers and exploit developers.
