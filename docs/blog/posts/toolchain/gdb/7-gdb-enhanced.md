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

[CheatSheet → The most important and commonly used commands for easy reference.](https://pwndbg.re/CheatSheet.pdf)
[Documentation → Learn how pwndbg works and explore the official docs.](https://pwndbg.github.io/pwndbg)

`context` Print out the current register, instruction, and stack context.

### config

- `config` Shows pwndbg-specific configuration.
- `configfile` Generates a configuration file for the current pwndbg options.

```bash
pwndbg> config
Name                                       Value (Default)                                                                  Documentation
-----------------------------------------------------------------------------------------------------------------------------------------
ai-anthropic-api-key                       ''                                                                               Anthropic API key (will default to ANTHROPIC_API_KEY environment variable if not set)
ai-history-size                            3                                                                                maximum number of successive questions and answers to maintain in the prompt for the ai command

context-backtrace-lines                    8                                                                                number of lines to print in the backtrace context
context-clear-screen                       False                                                                            whether to clear the screen before printing the context
context-code-lines                         10                                                                               number of additional lines to print in the code context
context-ghidra                             'never'                                                                          when to try to decompile the current function with ghidra (slow and requires radare2/r2pipe or rizin/rzpipe) (valid values: always, never, if-no-source)
context-max-threads                        4                                                                                maximum number of threads displayed by the context command
context-output                             'stdout'                                                                         where pwndbg should output ("stdout" or file/tty).
context-sections                           'regs disasm code ghidra stack backtrace expressions threads heap-tracker'       which context sections are displayed (controls order)
context-source-code-lines                  10                                                                               number of source code lines to print by the context command
context-source-code-tabstop                8                                                                                number of spaces that a <tab> in the source code counts for
context-stack-lines                        8                                                                                number of lines to print in the stack context

dereference-limit                          5                                                                                max number of pointers to dereference in a chain
disasm-annotations                         True                                                                             Display annotations for instructions to provide context on operands and results
disasm-telescope-depth                     3                                                                                Depth of telescope for disasm annotations

emulate                                    'on'                                                                             Unicorn emulation of code from the current PC register
emulate-annotations                        True                                                                             Unicorn emulation for register and memory value annotations on instructions

hexdump-bytes                              64                                                                               number of bytes printed by hexdump command

hexdump-group-width                        -1                                                                               number of bytes grouped in hexdump command (If -1, the architecture's pointer size is used)
hexdump-width                              16                                                                               line width of hexdump command
ida-enabled                                False                                                                            whether to enable ida integration

kernel-vmmap                               'page-tables'                                                                    the method to get vmmap information when debugging via QEMU kernel

left-pad-disasm                            True                                                                             whether to left-pad disassembly

nearpc-lines                               10                                                                               number of additional lines to print for the nearpc command
nearpc-num-opcode-bytes                    0                                                                                number of opcode bytes to print for each instruction
nearpc-opcode-separator-bytes              1                                                                                number of spaces between opcode bytes

r2decompiler                               'radare2'                                                                        framework that your ghidra plugin installed (radare2/rizin)

show-compact-regs                          False                                                                            whether to show a compact register view with columns
show-compact-regs-columns                  2                                                                                the number of columns (0 for dynamic number of columns)
show-compact-regs-min-width                20                                                                               the minimum width of each column
show-compact-regs-separation               4                                                                                the number of spaces separating columns
show-flags                                 False                                                                            whether to show flags registers
show-retaddr-reg                           False                                                                            whether to show return address register

syntax-highlight                           True                                                                             Source code / assembly syntax highlight

telescope-framepointer-offset              True                                                                             print offset to framepointer for each address, if sufficiently small
telescope-lines                            8                                                                                number of lines to printed by the telescope command

You can set config variable with `set <config-var> <value>`
You can generate configuration file using `configfile` - then put it in your .gdbinit after initializing pwndbg
```

show a compact register view:

```bash
pwndbg> set show-compact-regs on
Set whether to show a compact register view with columns to 'on'.
```

Show flags(`CPSR`) and retaddr-reg(`LR`) register:

```bash
pwndbg> set show-flags on
Set whether to show flags registers to 'on'.

pwndbg> set show-retaddr-reg on
Set whether to show return address register to 'on'.
```

Increase number of DISASM/SOURCE code lines to print:

```bash
pwndbg> set context-code-lines 12
Set number of additional lines to print in the code context to 12.

pwndbg> set context-source-code-lines 12
Set number of source code lines to print by the context command to 12.
```

Increase number of code lines for `nearpc` command output:

```bash
pwndbg> set nearpc-lines 12
Set number of additional lines to print for the nearpc command to 12.
pwndbg> nearpc
```

Type `configfile` to show the changed configs:

```bash
pwndbg> configfile
Showing only changed values:
# context-code-lines: number of additional lines to print in the code context
# default: 10
set context-code-lines 12

# context-source-code-lines: number of source code lines to print by the context command
# default: 10
set context-source-code-lines 12

# nearpc-lines: number of additional lines to print for the nearpc command
# default: 10
set nearpc-lines 12

# show-compact-regs: whether to show a compact register view with columns
# default: off
set show-compact-regs on

# show-flags: whether to show flags registers
# default: off
set show-flags on

# show-retaddr-reg: whether to show return address register
# default: off
set show-retaddr-reg on
```

To save the current settings for pwndbg to the file system to have those options persist across all your future pwndbg sessions, copy the above output into `~/.gdbinit_pwndbg`:

```bash
$ cat ~/.gdbinit_pwndbg
source ~/gdbe/pwndbg/gdbinit.py

################################################################################
# configfile
################################################################################
# show-compact-regs: whether to show a compact register view with columns
# default: off
set show-compact-regs on

# show-flags: whether to show flags registers
# default: off
set show-flags on

# show-retaddr-reg: whether to show return address register
# default: off
set show-retaddr-reg on
```

### theme

- `theme` Shows pwndbg-specific theme configuration.
- `themefile` Generates a configuration file for the current pwndbg theme options.

```bash
pwndbg> theme
Name                                   Value (Default)    Documentation
-----------------------------------------------------------------------
backtrace-address-color                none               color for backtrace (address)
backtrace-frame-label                  ''                 frame number label for backtrace

code-prefix                            '►'                prefix marker for 'context code' command
code-prefix-color                      none               color for 'context code' command (prefix marker)

disable-colors                         False              whether to color the output or not
disasm-branch-color                    bold               color for disasm (branch/call instruction)

hexdump-address-color                  none               color for hexdump command (address label)
hexdump-ascii-block-separator          '│'                block separator char of the hexdump command
hexdump-byte-separator                 ' '                separator of single bytes in hexdump (does NOT affect group separator)
hexdump-colorize-ascii                 True               whether to colorize the hexdump command ascii section

highlight-color                        green,bold         color added to highlights like source/pc
highlight-pc                           True               whether to highlight the current instruction
highlight-source                       True               whether to highlight the closest source line
memory-code-color                      red                color for executable memory
memory-data-color                      purple             color for all other writable memory
memory-heap-color                      blue               color for heap memory
memory-rodata-color                    normal             color for all read only memory
memory-rwx-color                       underline          color added to all RWX memory
memory-stack-color                     yellow             color for stack memory

nearpc-prefix                          '►'                prefix marker for nearpc command
nearpc-prefix-color                    none               color for nearpc command (prefix marker)
nearpc-symbol-color                    normal             color for nearpc command (symbol)
nearpc-syscall-name-color              red                color for nearpc command (resolved syscall name)

syntax-highlight-style                 'monokai'          Source code / assembly syntax highlight stylename of pygments module

You can set config variable with `set <theme-var> <value>`
You can generate configuration file using `themefile` - then put it in your .gdbinit after initializing pwndbg
```

[Colors not friendly for light terminal · Issue #503 · pwndbg/pwndbg](https://github.com/pwndbg/pwndbg/issues/503)

It looks like the code syntax highlighting specifically relies on [pygments](https://pygments.org/), and its built-in styles. The default is `monokai`.

Set default looks great with `solarized light`:

```bash
pwndbg> set syntax-highlight-style default
Set Source code / assembly syntax highlight stylename of pygments module to 'default'.
pwndbg> context
```

Type `themefile` to show the changed configs:

```bash
pwndbg> themefile
Showing only changed values:
# syntax-highlight-style: Source code / assembly syntax highlight stylename of pygments module
# default: monokai
set syntax-highlight-style default
```

To save the current settings for pwndbg to the file system to have those options persist across all your future pwndbg sessions, copy the above output into `~/.gdbinit_pwndbg`:

```bash
cat ~/.gdbinit_pwndbg
source ~/gdbe/pwndbg/gdbinit.py

################################################################################
# configfile
################################################################################
# show-compact-regs: whether to show a compact register view with columns
# default: off
set show-compact-regs on

# show-flags: whether to show flags registers
# default: off
set show-flags on

# show-retaddr-reg: whether to show return address register
# default: off
set show-retaddr-reg on

################################################################################
# themefile
################################################################################

# syntax-highlight-style: Source code / assembly syntax highlight stylename of pygments module
# default: monokai
set syntax-highlight-style default
```
