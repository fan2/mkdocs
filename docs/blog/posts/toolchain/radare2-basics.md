---
title: radare2 basics - embark
authors:
  - xman
date:
    created: 2023-10-02T09:00:00
categories:
    - toolchain
tags:
    - installation
    - start
    - shell
comments: true
---

[radare](https://www.radare.org/n/): UNIX-like reverse engineering framework and command-line toolset.

The Radare2 project is a set of small command-line utilities that can be used together or independently.

<!-- more -->

## installation

### thru git

The recommended way to install radare2 is via Git using acr/make or meson:

```bash
git clone https://github.com/radareorg/radare2
radare2/sys/install.sh
```

Run `sys/install.sh` for the default acr+make+symlink installation.

```bash
$ radare2/sys/install.sh
/home/pifan/Projects/radare2
WARNING: Updating from remote repository
From https://github.com/radareorg/radare2
 * branch                  master     -> FETCH_HEAD
Already up to date.
Warning: Cannot find system wide capstone
[*] Finding gmake is a tracked alias for /usr/bin/gmake OK
[*] Configuring the build system ... OK
[*] Checking out capstone... OK
[*] Checking out vector35-arm64... OK
[*] Checking out vector35-armv7... OK
[*] Running configure... OK
[*] Ready. You can now run 'make'.

[...snip...]

mkdir -p "/usr/local/bin" && \
for BINARY in r2r r2pm ravc2 rax2 rasm2 rabin2 rahash2 radiff2 radare2 rafind2 rarun2 ragg2 r2agent rasign2 ; do ln -fs "/home/pifan/Projects/radare2/binr/$BINARY/$BINARY" "/usr/local/bin/$BINARY" ; done
cd .. && ln -fs "/home/pifan/Projects/radare2/binr/r2pm/r2pm" "/usr/local/bin/r2pm"
cd .. && rm -rf "/usr/local/share/radare2/5.9.3/r2pm"
cd .. && mkdir -p "/usr/local/share/radare2/5.9.3/"
rm -f "/usr/local/bin/r2"
cd .. && ln -fs "/home/pifan/Projects/radare2/binr/radare2/radare2" "/usr/local/bin/r2"
cd .. && ln -fs "/usr/local/bin/radare2" "/usr/local/bin/r2p"
```

The radare2 toolset binaries are symbolically linked to /usr/local/bin.

```bash
$ ls -l /usr/local/bin
total 12
lrwxrwxrwx 1 root root 20 May 17 17:50 cloudflared -> /usr/bin/cloudflared
-rwxr-xr-x 1 root root 46 Jun 11 08:23 gdb-dashboard
-rwxr-xr-x 1 root root 40 May 22 11:32 gdb-gef
-rwxr-xr-x 1 root root 43 May 22 11:32 gdb-pwndbg
lrwxrwxrwx 1 root root 49 Jun 14 18:28 r2 -> /home/pifan/Projects/radare2/binr/radare2/radare2
lrwxrwxrwx 1 root root 49 Jun 14 18:28 r2agent -> /home/pifan/Projects/radare2/binr/r2agent/r2agent
lrwxrwxrwx 1 root root 42 Jun 14 18:28 r2-indent -> /home/pifan/Projects/radare2/sys/indent.sh
lrwxrwxrwx 1 root root 22 Jun 14 18:28 r2p -> /usr/local/bin/radare2
lrwxrwxrwx 1 root root 43 Jun 14 18:28 r2pm -> /home/pifan/Projects/radare2/binr/r2pm/r2pm
lrwxrwxrwx 1 root root 41 Jun 14 18:28 r2r -> /home/pifan/Projects/radare2/binr/r2r/r2r
lrwxrwxrwx 1 root root 47 Jun 14 18:28 rabin2 -> /home/pifan/Projects/radare2/binr/rabin2/rabin2
lrwxrwxrwx 1 root root 49 Jun 14 18:28 radare2 -> /home/pifan/Projects/radare2/binr/radare2/radare2
lrwxrwxrwx 1 root root 49 Jun 14 18:28 radiff2 -> /home/pifan/Projects/radare2/binr/radiff2/radiff2
lrwxrwxrwx 1 root root 49 Jun 14 18:28 rafind2 -> /home/pifan/Projects/radare2/binr/rafind2/rafind2
lrwxrwxrwx 1 root root 45 Jun 14 18:28 ragg2 -> /home/pifan/Projects/radare2/binr/ragg2/ragg2
lrwxrwxrwx 1 root root 49 Jun 14 18:28 rahash2 -> /home/pifan/Projects/radare2/binr/rahash2/rahash2
lrwxrwxrwx 1 root root 47 Jun 14 18:28 rarun2 -> /home/pifan/Projects/radare2/binr/rarun2/rarun2
lrwxrwxrwx 1 root root 49 Jun 14 18:28 rasign2 -> /home/pifan/Projects/radare2/binr/rasign2/rasign2
lrwxrwxrwx 1 root root 45 Jun 14 18:28 rasm2 -> /home/pifan/Projects/radare2/binr/rasm2/rasm2
lrwxrwxrwx 1 root root 45 Jun 14 18:28 ravc2 -> /home/pifan/Projects/radare2/binr/ravc2/ravc2
lrwxrwxrwx 1 root root 43 Jun 14 18:28 rax2 -> /home/pifan/Projects/radare2/binr/rax2/rax2
```

Check r2 version:

```bash
$ r2 -v
radare2 5.9.3 32233 @ linux-arm-64
birth: git.5.9.2-104-g0da877ec63 2024-06-14__18:14:28
commit: 0da877ec63433aa342179bb4fe095f3e73d98d4d
options: gpl -O? cs:5 cl:2 make
$ which r2
/usr/local/bin/r2
$ readlink `which r2`
/home/pifan/Projects/radare2/binr/radare2/radare2
```

### snap install

Or install radare2 on Ubuntu with [snap](https://ubuntu.com/core/services/guide/snaps-intro):

- [Managing Ubuntu Snaps](https://hackernoon.com/managing-ubuntu-snaps-the-stuff-no-one-tells-you-625dfbe4b26c)
- [snap install - Ubuntu snap 使用筆記](https://foreachsam.github.io/book-util-snap/book/content/command/snap-install/)

- [Install radare2 on Ubuntu using the Snap Store](https://snapcraft.io/install/radare2/ubuntu)
- [Installing and Managing Snap Packages on Ubuntu 22](https://reintech.io/blog/installing-managing-snap-packages-ubuntu-22)

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

```

List /snap/bin:

```bash
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

$ ls -l /snap/bin

$ tree -L 1 /snap/bin
```

Check radare2 version:

```bash
$ which radare2
/snap/bin/radare2

$ whereis radare2
radare2: /snap/bin/radare2

# radare2 -v
$ radare2.r2 -v

$ snap run radare2
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

```

When a manual alias is set, the original application name will continue to function.
Removing a manually created alias is also straightforward:

```bash
$ sudo snap unalias r2
```

Maintenance commands:

- Update package: `snap refresh radare2`
- Enable or disable radare2: `snap enable|disable radare2`
- Uninstall radare2: `snap remove radare2`

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

[Debug mode not working in radare2](https://www.reddit.com/r/LiveOverflow/comments/9f8fws/debug_mode_not_working_in_radare2_bin_0x07/)

```bash
$ r2 -d a.out
ERROR: unknown error in debug_attach
ERROR: unknown error in debug_attach
ERROR: unknown error in debug_attach
ERROR: Cannot open 'dbg://./a.out' for writing
```

---

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

[Building 'apropos' command for radare2](https://medium.com/@longledinh/building-apropos-command-for-radare2-3b9d15a2325a) with [longld/r2apropos.py-v1.6.0](https://gist.github.com/longld/3bcdc28535237fd359be6407f1df03b2)

Quick trick inside an r2shell - Interactive help search: 

> Type `?*~...` and ++enter++ , then do instant apropos search.

### status

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

[0x000000000000]> i ~intrp
intrp    /lib/ld-linux-aarch64.so.1

[0x000000000000]> i ~mode
mode     rwx

[0x000000000000]> i ~machine
machine  ARM aarch64

[0x000000000000]> i ~type
type     DYN (Shared object file)
bintype  elf

[0x000000000000]> i ~canary
canary   false

[0x000000000000]> ob
* 0 3 arm-64 ba:0xaaaacb8f0000 sz:8361 /home/pifan/Projects/cpp/test-gdb
```

`dpe`: show path to executable
`dp`: list current pid and children
`dpq`: same as dp. just show the current process id

```bash
[0x000000000000]> dpe
/home/pifan/Projects/cpp/test-gdb

[0x000000000000]> dp
INFO: Selected: 9250 9250
 * 9250 ppid:9227 uid:1000 s ./test-gdb

[0x000000000000]> dpq
9250
```

### reopen

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

`ood[?]`: reopen in debug mode
`oodf [file]`: reopen in debug mode using the given file

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
[0x000000000000]> !rabin2 -I test-gdb
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

Take the internal evaluation as a parameter for a shell command.

```bash
[0x41764141754141]> rax2 -r `dr pc`
int64   18425896129347905
uint64  18425896129347905
hex     0x41764141754141
octal   01013544050135240501
unit    16.4P
segment 14175000:0141
string  "AAuAAvA"
float   15.328431f
double  0.000000
binary  0b01000001011101100100000101000001011101010100000101000001
base36  0_51ffntovght
ternary 0t10022111022200110121022011120022202
```

### pipe

The standard UNIX pipe `|` is also available in the radare2 shell. You can use it to filter the output of an r2 command with any shell program that reads from stdin, such as `grep`, `less`, `wc`. If you do not want to spawn anything, or you can’t, or the target system does not have the basic UNIX tools you need (Windows or embedded users), you can also use the built-in grep (`~`).

```bash
[0xaaaacad607a0]> @?

| >file               pipe output of command to file
| >>file              append to file
| H>file              pipe output of command to file in HTML
| H>>file             append to file with the output of command in HTML
| `pdi~push:0[0]`     replace output of command inside the line
| |cmd                pipe output to command (pd|less) (.dr*)
```

Typical example of filter binary file info:

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

Redirection without output, following covers front(see `wt?`):

```bash
[0x000000000000]> ?v sym.imp.puts > sym_addr.txt
[0x000000000000]> ?v reloc.puts > sym_addr.txt
```

Use `tee` to write to both stdout and file:

```bash
[0x000000000000]> ?v sym.imp.puts | tee sym_addr.txt
[0x000000000000]> ?v reloc.puts | tee sym_addr.txt
```

Append to the given FILE, do not overwrite:

```bash
[0x000000000000]> ?v sym.imp.puts | tee -a sym_addr.txt
[0x000000000000]> ?v reloc.puts | tee -a sym_addr.txt
[0x000000000000]> ieq | tee -a sym_addr.txt
```

## refs

[Radare2 Book](https://book.rada.re/) - [intro](https://github.com/radareorg/radare2/blob/master/doc/intro.md#analyze) - [zh-cn](https://heersin.gitbook.io/radare2)
[r2wiki](https://r2wiki.readthedocs.io/en/latest/) - [Tips](https://r2wiki.readthedocs.io/en/latest/home/tips/)
[macho - r2wiki](https://r2wiki.readthedocs.io/en/latest/analysis/macho/#osx-code-signing)
[The Rizin Handbook](https://book.rizin.re/)

[r2 cheatsheet.pdf](https://scoding.de/uploads/r2_cs.pdf)
[radare2-cheatsheet](https://github.com/historypeats/radare2-cheatsheet)
[another radare2 cheatsheet](https://gist.github.com/williballenthin/6857590dab3e2a6559d7)
