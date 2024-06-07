---
title: SRE Toolkit - radare2 basics
authors:
  - xman
date:
    created: 2023-10-02T09:00:00
categories:
    - toolchain
comments: true
---

[radare](https://www.radare.org/n/): UNIX-like reverse engineering framework and command-line toolset.

The Radare2 project is a set of small command-line utilities that can be used together or independently.

<!-- more -->

- [Radare2 Book](https://book.rada.re/) - [intro](https://github.com/radareorg/radare2/blob/master/doc/intro.md#analyze) - [zh-cn](https://heersin.gitbook.io/radare2)
- [r2wiki](https://r2wiki.readthedocs.io/en/latest/) - [Tips](https://r2wiki.readthedocs.io/en/latest/home/tips/)
- [How-To: Radare2](https://r2.cole-ellis.com/)
- [awesome-radare2](https://github.com/radareorg/awesome-radare2/blob/master/README.md)
- [Radare2 vs. GDB](https://hurricanelabs.com/blog/learning-binary-reversing-radare2-vs-gdb/)
- [Radare2 Explorations](https://monosource.gitbooks.io/radare2-explorations/)
- [Radare2 — Keep It Or Leave It?](https://medium.com/@sagidana/radare2-keep-it-or-leave-it-3d45059ec0d1)

## installation

install radare2 on Ubuntu with [snap](https://ubuntu.com/core/services/guide/snaps-intro):

- [Managing Ubuntu Snaps](https://hackernoon.com/managing-ubuntu-snaps-the-stuff-no-one-tells-you-625dfbe4b26c)
- [snap install - Ubuntu snap 使用筆記](https://foreachsam.github.io/book-util-snap/book/content/command/snap-install/)

- [Install radare2 on Ubuntu using the Snap Store](https://snapcraft.io/install/radare2/ubuntu)
- [Installing and Managing Snap Packages on Ubuntu 22](https://reintech.io/blog/installing-managing-snap-packages-ubuntu-22)

### snap install

```bash
$ sudo snap install radare2 --classic
Download snap "core24" (410) from channel "stable"
...
radare2 5.9.2 from pancake installed
```

Display snap list:

```bash
# ls -1 /snap/
$ ls /snap/
bare  core22  firefox        gtk-common-themes  README  snapd-desktop-integration
bin   core24  gnome-42-2204  radare2            snapd   snap-store

$ snap list
Name                       Version           Rev    Tracking         Publisher   Notes
bare                       1.0               5      latest/stable    canonical✓  base
core22                     20240408          1383   latest/stable    canonical✓  base
core24                     20240426          410    latest/stable    canonical✓  base
firefox                    126.0-2           4281   latest/stable/…  mozilla✓    -
gnome-42-2204              0+git.510a601     178    latest/stable/…  canonical✓  -
gtk-common-themes          0.1-81-g442e511   1535   latest/stable/…  canonical✓  -
radare2                    5.9.2             2571   latest/stable    pancake     classic
snap-store                 41.3-77-g7dc86c8  1114   latest/stable/…  canonical✓  -
snapd                      2.63              21761  latest/stable    canonical✓  snapd
snapd-desktop-integration  0.9               159    latest/stable/…  canonical✓  -
```

List /snap/bin:

```bash
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

$ ls -l /snap/bin

$ tree -L 1 /snap/bin
/snap/bin
├── firefox -> /usr/bin/snap
├── firefox.geckodriver -> /usr/bin/snap
├── geckodriver -> firefox.geckodriver
├── radare2 -> /usr/bin/snap
├── radare2.r2 -> /usr/bin/snap
├── radare2.r2agent -> /usr/bin/snap
├── radare2.r2frida-compile -> /usr/bin/snap
├── radare2.r2p -> /usr/bin/snap
├── radare2.r2pm -> /usr/bin/snap
├── radare2.r2r -> /usr/bin/snap
├── radare2.rabin2 -> /usr/bin/snap
├── radare2.radiff2 -> /usr/bin/snap
├── radare2.rafind2 -> /usr/bin/snap
├── radare2.ragg2 -> /usr/bin/snap
├── radare2.rahash2 -> /usr/bin/snap
├── radare2.rarun2 -> /usr/bin/snap
├── radare2.rasign2 -> /usr/bin/snap
├── radare2.rasm2 -> /usr/bin/snap
├── radare2.ravc2 -> /usr/bin/snap
├── radare2.rax2 -> /usr/bin/snap
├── radare2.sleighc -> /usr/bin/snap
├── radare2.yara -> /usr/bin/snap
├── radare2.yarac -> /usr/bin/snap
├── snap-store -> /usr/bin/snap
├── snap-store.ubuntu-software -> /usr/bin/snap
└── snap-store.ubuntu-software-local-file -> /usr/bin/snap

0 directories, 26 files

```

Check radare2 version:

```bash
$ which radare2
/snap/bin/radare2

$ whereis radare2
radare2: /snap/bin/radare2

# radare2 -v
$ radare2.r2 -v
radare2 5.9.2 0 @ linux-arm-64
birth: git.5.9.2 2024-05-27__15:16:35
commit: 5.9.2
options: gpl release -O1 cs:5 cl:0 make

$ snap run radare2
Usage: r2 [-ACdfjLMnNqStuvwzX] [-P patch] [-p prj] [-a arch] [-b bits] [-c cmd]
          [-s addr] [-B baddr] [-m maddr] [-i script] [-e k=v] file|pid|-|--|=
```

Seek for usage help:

```bash
$ radare2 -h
$ radare2.rabin2 -h
```

### snap alias r2

[command line - What is the correct way to create alias to snap package in Ubuntu 16.04?](https://askubuntu.com/questions/915060/what-is-the-correct-way-to-create-alias-to-snap-package-in-ubuntu-16-04)

```bash
$ echo "alias r2='snap run radare2'" >> ~/.zshrc
```

[Commands and aliases | Snapcraft documentation](https://snapcraft.io/docs/commands-and-aliases)

The following exposes a new command under /snap/bin to support calling the `radare2` application as `r2`:

```bash
$ sudo snap alias radare2 r2
Added:
  - radare2 as r2

$ snap aliases radare2
Command  Alias  Notes
radare2  r2     manual

$ snap aliases
Command  Alias  Notes
lxd.lxc  lxc    -
radare2  r2     manual

$ r2 -v
radare2 5.9.2 0 @ linux-arm-64
birth: git.5.9.2 2024-05-27__15:16:35
commit: 5.9.2
options: gpl release -O1 cs:5 cl:0 make
```

When a manual alias is set, the original application name will continue to function.
Removing a manually created alias is also straightforward:

```bash
$ sudo snap unalias r2
```

## start

`-d`: debug the executable 'file' or running process 'pid', behaved as `gdb -> starti`.

```bash
$ r2 -d test-gdb
```

`r2 -A`: run 'aaa' command to analyze all referenced code.

```bash
$ r2 -Ad test-gdb
```

Open file in write mode:

```bash
$ r2 -Adw test-gdb
```

`-B [baddr]`: set base address for PIE binaries, [not working](https://github.com/radareorg/radare2/issues/9051).

whereis/which shell command:

```bash
[0x000000000000]> wh r2
/snap/radare2/2571/bin/r2
[0x000000000000]> wh rabin2
/snap/radare2/2571/bin/rabin2
```

You can run radare2 toolset utilities such as `rabin2`, `rax2`, `ragg2`, `rafind2` directly from the r2 console.

### usage

Type `?` to list <command-class\> prefixes.

```bash
[0xaaaab9840640]> ?
Usage: [.][times][cmd][~grep][@[@iter]addr!size][|>pipe] ; ...
Append '?' to any char command to get detailed help
Prefix with number to repeat command N times (f.ex: 3x)
| %var=value              alias for 'env' command
| "[?]["..|.."]           quote a command to avoid evaluaing special chars
| *[?] off[=[0x]value]    pointer read/write data/values (see ?v, wx, wv)
| (macro arg0 arg1)       manage scripting macros
| .[?] [-|(m)|f|!sh|cmd]  Define macro or load r2, cparse or rlang file
| ,[?] [/jhr]             create a dummy table import from file and query it to filter/sort
| :cmd                    run an io command (same as =!)
| _[?]                    Print last output
| =[?] [cmd]              send/listen for remote commands (rap://, raps://, udp://, http://, <fd>)
| <[...]                  push escaped string into the RCons.readChar buffer
| /[?]                    search for bytes, regexps, patterns, ..
| ![?] [cmd]              run given command as in system(3)
| #[?] !lang [..]         Hashbang to run an rlang script
| a[?]                    analysis commands
| b[?]                    display or change the block size
| c[?] [arg]              compare block with given data
| C[?]                    code metadata (comments, format, hints, ..)
| d[?]                    debugger commands
| e[?] [a[=b]]            list/get/set config evaluable vars
| f[?] [name][sz][at]     add flag at current address
| g[?] [arg]              generate shellcodes with r_egg
| i[?] [file]             get info about opened file from r_bin
| k[?] [sdb-query]        run sdb-query. see k? for help, 'k *', 'k **' ...
| l[?] [filepattern]      list files and directories
| L[?] [-] [plugin]       list, unload load r2 plugins
| m[?]                    mountpoint / filesystems (r_fs) related commands
| o[?] [file] ([offset])  open file at optional address
| p[?] [len]              print current block with format and length
| P[?]                    project management utilities
| q[?] [ret]              quit program with a return value
| r[?] [len]              resize file
| s[?] [addr]             seek to address (also for '0x', '0x1' == 's 0x1')
| t[?]                    types, noreturn, signatures, C parser and more
| T[?] [-] [num|msg]      Text log utility (used to chat, sync, log, ...)
| u[?]                    uname/undo seek/write
| v                       panels mode
| V                       visual mode (Vv = func/var anal, VV = graph mode, ...)
| w[?] [str]              multiple write operations
| x[?] [len]              alias for 'px' (print hexadecimal)
| y[?] [len] [[[@]addr    yank/paste bytes from/to memory
| z[?]                    zignatures management
| ?[??][expr]             Help or evaluate math expression
| ?$?                     show available '$' variables and aliases
| ?@?                     misc help for '@' (seek), '~' (grep) (see ~?""?)
| ?>?                     output redirection
| ?|?                     help for '|' (pipe)
```

### reopen

list opened files:

```bash
| o                         list opened files
| ob[?] [lbdos] [...]       list opened binary files backed by fd
| oo[?][+bcdnm]             reopen current file (see oo?) (reload in rw or debugger)
```

Check current opened/debugging file:

```bash
[0x000000000000]> i ~baddr
baddr    0xaaaacb8f0000

[0x000000000000]> i ~^file
file     /home/pifan/Projects/cpp/test-gdb

[0x000000000000]> ob
* 0 3 arm-64 ba:0xaaaacb8f0000 sz:8361 /home/pifan/Projects/cpp/test-gdb
```

reopen current file:

```bash
[0x000000000000]> oo?
Usage: oo [arg]  Map opened files
| oo           reopen current file
| oo+          reopen in read-write
| oob [baddr]  reopen loading rbin info (change base address?)
| ooc          reopen core with current file
| ood[?]       reopen in debug mode
| oom[?]       reopen in malloc://
| oon          reopen without loading rbin info
| oon+         reopen in read-write mode without loading rbin info
| oonn         reopen without loading rbin info, but with header flags
| oonn+        reopen in read-write mode without loading rbin info, but with
```

reload current file:

```bash
[0x000000000000]> do?
Usage: do   # Debug (re)open commands
| do            open process (reload, alias for 'oo')
| doo [args]    Reopen in debug mode with args (alias for 'ood')
| doof [args]   Reopen in debug mode from file (alias for 'oodf')
```

## shell

The `!` prefix is used to execute a command in shell context.

```bash
[0x000000000000]> !?
Usage: !<cmd>    Run given command as in system(3)
```

### toolset

Execute external shell to read ELF headers:

```bash
[0x000000000000]> !readelf -h test-gdb
[0x000000000000]> !objdump -f test-gdb
```

Execute radare2 internal command with external/internal mode:

```bash
[0x000000000000]> !radare2.rabin2 -I test-gdb
[0x000000000000]> rabin2 -I test-gdb
[0x000000000000]> iI

[0x000000000000]> rabin2 -e test-gdb
[0x000000000000]> ie
```

Read section headers from both external/internal mode:

```bash
[0x000000000000]> !readelf -SW a.out
[0x000000000000]> !objdump -hw a.out
[0x000000000000]> rabin2 -S test-gdb
[0x000000000000]> iS
```

Read segments from internal mode:

```bash
[0x000000000000]> rabin2 -SSS test-gdb
[0x000000000000]> rabin2 -SS test-gdb
[0x000000000000]> iSS
```

### list

r2 built-in listing commands:

```bash
[0x000000000000]> l?
Usage: l[erls] [arg]  Internal less (~..) and file listing (!ls)
| lu [path]                same as #!lua
| ll [path]                same as ls -l
| lr [path]                same as ls -r
| li                       list source of current function (like gdb's 'list' command)
| ls [-e,-l,-j,-q] [path]  list files in current or given directory
| ls -e [path]             list files using emojis
| ls -l [path]             same as ll (list files with details)
| ls -j [path]             list files in json format
| ls -q [path]             quiet output (one file per line)
| le[ss] [path]            same as cat file~.. (or less)
```

List the toolset utility binutils with the same directory:

```bash
[0x000000000000]> ll /snap/radare2/2571/bin/
[0x000000000000]> !ls -l /snap/radare2/2571/bin/
```

### pipe

The standard UNIX pipe `|` is also available in the radare2 shell. You can use it to filter the output of an r2 command with any shell program that reads from stdin, such as `grep`, `less`, `wc`. If you do not want to spawn anything, or you can’t, or the target system does not have the basic UNIX tools you need (Windows or embedded users), you can also use the built-in grep (`~`).

```bash
[0x000000000000]> # i ~baddr
[0x000000000000]> i | grep baddr
baddr    0xaaaacb8f0000

[0x000000000000]> # i ~^file
[0x000000000000]> i | grep ^file
file     /home/pifan/Projects/cpp/test-gdb
```

Combining internal and external commands via pipe to extract the current filename for further use.

```bash
[0x000000000000]> ob | awk '{print $NF}'
/home/pifan/Projects/cpp/test-gdb
[0x000000000000]> i | awk '/^file/ {print $NF}'
/home/pifan/Projects/cpp/test-gdb
```

## env

```bash
[0x000000000000]> env?
| en           list environment vars
| env [k[=v]]  get/set environment variable

[0x000000000000]> %?
Usage: %[name[=value]]  Set each NAME to VALUE in the environment
| %             list all environment variables

[0x000000000000]> ?
Usage: [.][times][cmd][~grep][@[@iter]addr!size][|>pipe] ; ...
Append '?' to any char command to get detailed help
Prefix with number to repeat command N times (f.ex: 3x)
| %var=value              alias for 'env' command

| _[?]                    Print last output

```

Examples:

```bash
[0x000000000000]> env _
/snap/bin/r2
[0x000000000000]> env SHELL
/usr/bin/zsh
[0x000000000000]> %_
/snap/bin/r2
[0x000000000000]> %SHELL
/usr/bin/zsh
[0x000000000000]> _
/usr/bin/zsh
```

## config

[Radare2 Book: 3. Configuration](https://book.rada.re/configuration/intro.html)

```bash
[0x000000000000]> e?
Usage: e [var[=value]]  Evaluable vars
| e?asm.bytes        show description
| e??                list config vars with description
| e a                get value of var 'a'
| e a=b              set var 'a' the 'b' value
| e.a=b              same as 'e a=b' but without using a space
| e,[table-query]    show the output in table format
| e/asm              filter configuration variables by name
| e:k=v:k=v:k=v      comma or colon separated k[=v]
| e-                 reset config vars
| e*                 dump config vars in r commands
| e!a                invert the boolean value of 'a' var
| ec[?] [k] [color]  set color for given key (prompt, offset, ...)
| ee [var]           open cfg.editor to change the value of var
| ed                 open editor to change the ~/.radare2rc
| ed-[!]             delete ~/.radare2c (Use ed-! to delete without prompting)
| ej                 list config vars in JSON
| eJ                 list config vars in verbose JSON
| en                 list environment vars
| env [k[=v]]        get/set environment variable
| er [key]           set config key as readonly. no way back
| es [space]         list all eval spaces [or keys]
| et [key]           show type of given config variable
| ev [key]           list config vars in verbose format
| evj [key]          list config vars in verbose format in JSON
```

[Radare2 can't set breakpoint?](https://reverseengineering.stackexchange.com/questions/13689/radare2-noob-question-cant-set-breakpoint)

Set `e dbg.bpinmaps=false` so Radare2 allows you to set breakpoint without that restriction.

```bash
[0xffffbc84ae70]> e dbg.bpinmaps
true
[0xffffbc84ae70]> e dbg.bpinmaps=false
[0xffffbc84ae70]> e dbg.bpinmaps
false
```

## expr

### evaluation

`?v`: show hex value of math expr.

```bash
[0x000000000000]> ???
Usage: ?[?[?]] expression

| ?$                               show value all the variables ($)
| ?P paddr                         get virtual address for given physical one
| ?p vaddr                         get physical address for given virtual address
| ?q num|expr                      compute expression like ? or ?v but in quiet mode
| ?v num|expr                      show hex value of math expr (no expr prints $?)
| ?vi[1248] num|expr               show decimal value of math expr [n bytes]

```

`?v <symbol>` acts as `afo <symbol>`, it will show the address for the symbol, equivalent to `info address SYM` in GDB.

```bash
[0xffff99b209d0]> # afo sym.main
[0xffff99b209d0]> ?v sym.main
0xaaaae16307a0
[0xffff99b209d0]> # afo sym.func
[0xffff99b209d0]> ?v sym.func
0xaaaae1630754
```

### variables

```bash
[0x000000000000]> $?
Usage: $alias[=cmd] [args...]  Alias commands and data (See ?$? for help on $variables)
| $                        list all defined aliases
| $*                       list all defined aliases and their values, with unprintable characters escaped

[0x000000000000]> ?$?
Usage: ?v [$.]
| flag          offset of flag
| ${ev}         get value of eval config variable
| $$            here (current virtual seek)

| $alias=value  alias commands (simple macros)
| $B            base address (aligned lowest map address)
| $FB           begin of function
| $FE           end of function
| $l            opcode length
| $M            map address (lowest map address)
| $m            opcode memory reference (e.g. mov eax,[0x10] => 0x10)
| $MM           map size (lowest map address)
| $r{reg}       get value of named register ($r{PC} and $r:PC syntax is supported)
| $S            section offset
| $SS           section size
| $w            get word size, 4 if asm.bits=32, 8 if 64, ...
```

Seek here/print current address.

```bash
# equivalent to s : print current address
# $$: here (current virtual seek)
[0xaaaac30a07a0]> ?v $$
0xaaaac30a07a0
```

Define simple macros.

```bash
[0xaaaac30a07a0]> $rip=19890604
[0xaaaac30a07a0]> $rip?
19890604
```

Get map/word/opcode size.

```bash
[0xaaaac30a0754]> ?v $MM
0x7fffffffffffffff
[0x000000000000]> ?v $w
0x8
[0xaaaac30a0754]> ?v $l
0x4
```

begin/end of function:

```bash
[0xaaaac30a0754]> ?v $FB
0xaaaac30a0754
[0xaaaac30a0754]> ?v $FE
0xaaaac30a07a0
```

`$r{reg}` is equivalent to `dr?<register>`, see `drl`, `dr??` and `dr=`.

```bash
[0xaaaac30a0754]> ?v $r{x0}
0xfa
[0xaaaac30a0754]> ?v $r:A0
0xfa
[0xaaaac30a0754]> ?v $r{PC}
0xaaaac30a0754
[0xaaaac30a0754]> ?v $r{BP}
0xffffdca194e0
[0xaaaac30a0754]> ?v $r:SP
0xffffdca194e0
```

### grep

```bash
[0x000000000000]> @?
[0x000000000000]> ?@?
Usage: [.:"][#]<cmd>[*] [`cmd`] [@ addr] [~grep] [|syscmd] [>[>]file]
| ~?                  count number of lines (like wc -l)
| ~??                 show internal grep help
| ~..                 internal less
| ~{}                 json indent
| ~<>                 xml indent
| ~<100               ascii-art zoom of console buffer
| ~{}..               json indent and less
| ~word               grep for lines matching word
| ~!word              grep for lines NOT matching word
| ~word[2]            grep 3rd column of lines matching word
| ~word:3[0]          grep 1st column from the 4th line matching word

| >file               pipe output of command to file
| >>file              append to file
| |cmd                pipe output to command (pd|less) (.dr*)

[0x000000000000]> ~??
Usage: [command]~[modifier][word,word][endmodifier][[column]][:line]
modifier:
```

## analysis

[Radare2 Book: 8. Analysis](https://book.rada.re/analysis/intro.html)

Code analysis is the process of finding patterns, combining information from different sources and process the disassembly of the program in multiple ways in order to understand and extract more details of the logic behind the code.

Radare2 has many different code analysis techniques implemented under different commands and configuration options, and it's important to understand what they do and how that affects in the final results before going for the default-standard `aaaaa` way because on some cases this can be too slow or just produce false positive results.

As long as the whole functionalities of `r2` are available with the API as well as using commands. This gives you the ability to implement your own analysis loops using any programming language, even with `r2` oneliners, shellscripts, or analysis or core native plugins.

The analysis will show up the *internal* data structures to identify basic blocks, function trees and to extract opcode-level information.

The most common radare2 analysis command sequence is `aa`, which stands for "*analyze all*". That all is referring to all symbols and entry-points. If your binary is stripped you will need to use other commands like `aaa`, `aab`, `aar`, `aac` or so.

Take some time to understand what each command does and the results after running them to find the best one for your needs.

```bash
Usage: aa[0*?]   # see also 'af' and 'afna'
| aa                     alias for 'af@@ sym.*;af@entry0;afva'
| aaa[?]                 autoname functions after aa (see afna)
| aab                    abb across bin.sections.rx
| aac [len]              analyze function calls (af @@ `pi len~call[1]`)
| aac* [len]             flag function calls without performing a complete analysis
| aar[?] [len]           analyze len bytes of instructions for references
```

Begin with executing `aa` (analyse all) or `aaa` to make our life easier.

```bash
[0x000000000000]> aa
INFO: Analyze all flags starting with sym. and entry0 (aa)
INFO: Analyze imports (af@@@i)
INFO: Analyze entrypoint (af@ entry0)
INFO: Analyze symbols (af@@@s)
INFO: Recovering variables
INFO: Analyze all functions arguments/locals (afva@@@F)

[0x000000000000]> aaa
INFO: Analyze all flags starting with sym. and entry0 (aa)
INFO: Analyze imports (af@@@i)
INFO: Analyze entrypoint (af@ entry0)
INFO: Analyze symbols (af@@@s)
INFO: Recovering variables
INFO: Analyze all functions arguments/locals (afva@@@F)
INFO: Analyze function calls (aac)
INFO: Analyze len bytes of instructions for references (aar)
INFO: Finding and parsing C++ vtables (avrr)
INFO: Analyzing methods
INFO: Finding function preludes (aap)
INFO: Finding xrefs in noncode sections (e anal.in=io.maps.x; aav)
INFO: Skipping function emulation in debugger mode (aaef)
INFO: Recovering local variables (afva)
INFO: Skipping type matching analysis in debugger mode (aaft)
INFO: Propagate noreturn information (aanr)
INFO: Use -AA or aaaa to perform additional experimental analysis
```

After the analysis, radare2 associates names to interesting offsets in the file such as Sections, Function, Symbols, and Strings. Those names are called *`flags`*. Flags can be grouped into *`flag spaces`*. A flag space is a namespace for flags of similar characteristics or type. To list the flag spaces run `fs`.

We can choose a flag space using `fs <flagspace>` and print the flags it contains using `f`.

```bash
[0xaaaae4870754]> fs
    0 * classes
    5 * format
  678 * functions
    5 * imports
   67 * registers
   28 * sections
   10 * segments
    2 * strings
   34 * symbols
[0xaaaae4870754]> fs strings; f
0xaaaae4870838 21 str.result_1_100____ld_n
0xaaaae4870850 20 str.result_1_250____d_n
[0xaaaae4870754]> fs imports; f
0xaaaae48705f0 16 sym.imp.__libc_start_main
0xaaaae4870600 16 sym.imp.__cxa_finalize
0xaaaae4870610 16 loc.imp.__gmon_start__
0xaaaae4870620 16 sym.imp.abort
0xaaaae4870630 16 sym.imp.printf
[0xaaaae4870754]> fs symbols; f
```
