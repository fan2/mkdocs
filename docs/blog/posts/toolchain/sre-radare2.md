---
title: SRE Toolkit - radare2
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

- [Radare2 Book](https://book.rada.re/) - [intro](https://github.com/radareorg/radare2/blob/master/doc/intro.md#analyze) - [wiki](https://r2wiki.readthedocs.io/en/latest/) - [zh-cn](https://heersin.gitbook.io/radare2)
- [How-To: Radare2](https://r2.cole-ellis.com/)
- [r2 cheatsheet.pdf](https://scoding.de/uploads/r2_cs.pdf)
- [radare2-cheatsheet](https://github.com/historypeats/radare2-cheatsheet)
- [another radare2 cheatsheet](https://gist.github.com/williballenthin/6857590dab3e2a6559d7)

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

whereis/which shell command:

```bash
[0x000000000000]> wh r2
/snap/radare2/2571/bin/r2
[0x000000000000]> wh rabin2
/snap/radare2/2571/bin/rabin2
```

You can run radare2 toolset utilities such as `rabin2`, `rax2`, `ragg2`, `rafind2` directly from the r2 console.

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

### shell

The `!` prefix is used to execute a command in shell context.

List the toolset utility binutils with the same directory:

```bash
[0x000000000000]> !ls -l /snap/radare2/2571/bin/
```

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
[0x000000000000]> ! readelf -SW a.out
[0x000000000000]> ! objdump -hw a.out
[0x000000000000]> rabin2 -S test-gdb
[0x000000000000]> iS
```

Read segments from internal mode:

```bash
[0x000000000000]> rabin2 -SSS test-gdb
[0x000000000000]> rabin2 -SS test-gdb
[0x000000000000]> iSS
```

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

## i Mode

[Radare2 Book: 4.3. Sections](https://book.rada.re/basic_commands/sections.html)
[Binary Info: The i Module](https://r2.cole-ellis.com/radare2-modules/india)

Output mode:

- `*` : output in radare commands
- `j` : output in json
- `q` : simple quiet output

```bash
[0x000000000000]> i?
Usage: i  Get info from opened file (see rabin2's manpage)
| i[*jq]       show info of current file (in JSON)
| iA           list archs found in current binary
| ia           show all info (imports, exports, sections..)
| ib           reload the current buffer for setting of the bin (use once only)
| ic[?]        List classes, methods and fields (icj for json)
| iC[j]        show signature info (entitlements, ...)
| id[?]        show DWARF source lines information
| iD lang sym  demangle symbolname for given language
| ie[?]e[e]    entrypoint (iee to list constructors and destructors, ieee = entries+constructors)
| iE[?]        exports (global symbols)
| ig           guess size of binary program
| ih[?]        show binary headers (same as iH/-H to avoid conflict with -h in rabin2)
| iH[H]        show binary headers in plain text (iHH verbose output)
| ii[?][j*,]   list the symbols imported from other libraries
| iic          classify imports
| iI           binary info
| ik [query]   key-value database from RBinObject
| il           libraries
| iL [plugin]  list all RBin plugins loaded or plugin details
| im           show info about predefined memory allocation
| iM           show main address
| io [file]    load info from file (or last opened) use bin.baddr
| iO[?]        perform binary operation (dump, resize, change sections, ...)
| ir           list the relocations
| iR           list the resources
| is[?]        list the symbols
| iS[?]        list sections, segments and compute their hash
| it           file hashes
| iT           file signature
| iV           display file version info
| iw           show try/catch blocks
| iz[?]        strings in data sections (in JSON/Base64)
```

`i` / `iI`: show binary info, inclue `baddr`(base address).

### entrypoint

- `ie`: entrypoint
- `iee`: list constructors and destructors, 
- `ieee`: entries+constructors

```bash
[0xffffaa6d6c40]> ieq
0xaaaae48e0640

[0xffffaa6d6c40]> ie
[Entrypoints]
vaddr=0xaaaae48e0640 paddr=0x00000640 haddr=0x00000018 hvaddr=0xaaaae48e0018 type=program

1 entrypoints

[0xffffaa6d6c40]> ieee
[Constructors]
vaddr=0xaaaae48e0750 paddr=0x00000750 hvaddr=0xaaaae48f0d90 hpaddr=0x00000d90 type=init
vaddr=0xaaaae48e0700 paddr=0x00000700 hvaddr=0xaaaae48f0d98 hpaddr=0x00000d98 type=fini

2 entrypoints
[Entrypoints]
vaddr=0xaaaae48e0640 paddr=0x00000640 haddr=0x00000018 hvaddr=0xaaaae48e0018 type=program

1 entrypoints
```

[radare2 - What does paddr, baddr, laddr, haddr, and hvaddr refer to?](https://reverseengineering.stackexchange.com/questions/19782/what-does-paddr-baddr-laddr-haddr-and-hvaddr-refer-to)

- `vaddr` - Virtual Address
- `paddr` - Physical Address
- `laddr` - Load Address
- `baddr` - Base Address
- `haddr` - e_entry/AddressOfEntryPoint in binary header
- `hvaddr` - Header Physical Address
- `hpaddr` - e_entry/AddressOfEntryPoint offset in binary header

### symbols

Query for detailed usages of subcommands:

```bash
[0x000000000000]> !readelf -s test-gdb
[0x000000000000]> !objdump -t test-gdb
[0x000000000000]> !radare2.rabin2 -s test-gdb
[0x000000000000]> is?
Usage: is [*hjq]  List symbols from current selected binary
| is,[table-query]  list symbols in table using given expression
| is.               current symbol
| is*               same as above, but in r2 commands
| isj               in json format
```

### sections & segments

```bash
[0x000000000000]> iS?
Usage: iS [][jq*]  List sections and segments
| iS [entropy,sha1]  sections (choose which hash algorithm to use)
| iS.                current section
| iS,[table-query]   list sections in table using given expression
| iS=                show ascii-art color bars with the section ranges
| iSS                list memory segments (maps with om)

[0x000000000000]> iS,?
RTableQuery> comma separated. 'c' stands for column name.

 */head/10      same as | head -n 10
 */skip/10      skip the first 10 rows
 */tail/10      same as | tail -n 10

 c/sum          sum all the values of given column

```

Calculate size of text segment(section 0\~17):

```bash
[0x000000000000]> iS,*/head/18,vsize/sum
```

Calculate size of data segment(section 18\~27):

```bash
[0x000000000000]> iS,*/tail/9,vsize/sum
```

## p Mode

[Radare2 Book: 4.5. Print Modes](https://book.rada.re/basic_commands/print_modes.html)

```bash
[0x000000000000]> p?
Usage: p[=68abcdDfiImrstuxz] [arg|len] [@addr]
| p[b|B|xb] [len] ([S])   bindump N bits skipping S bytes
| p[iI][df] [len]         print N ops/bytes (f=func) (see pi? and pdi)
| p[kK] [len]             print key in randomart (K is for mosaic)
| p-[?][jh] [mode]        bar|json|histogram blocks (mode: e?search.in)
| p2 [len]                8x8 2bpp-tiles
| p3 [file]               print 3D stereogram image of current block
| p6[de] [len]            base64 decode/encode
| p8[?][dfjx] [len]       8bit hexpair list of bytes
| p=[?][bep] [N] [L] [b]  show entropy/printable chars/chars bars
| pa[?][edD] [arg]        pa:assemble  pa[dD]:disasm or pae: esil from hex
| pA[n_ops]               show n_ops address and type
| pb[?] [n]               bitstream of N bits
| pB[?] [n]               bitstream of N bytes
| pc[?][p] [len]          output C (or python) format
| pC[aAcdDxw] [rows]      print disassembly in columns (see hex.cols and pdi)
| pd[?] [sz] [a] [b]      disassemble N opcodes (pd) or N bytes (pD)
| pf[?][.name] [fmt]      print formatted data (pf.name, pf.name $<expr>)
| pF[?][apx]              print asn1, pkcs7 or x509
| pg[?][x y w h] [cmd]    create new visual gadget or print it (see pg? for details)
| ph[?][=|hash] ([len])   calculate hash for a block
| pi[?][bdefrj] [num]     print instructions
| pI[?][iI][df] [len]     print N instructions/bytes (f=func)
| pj[?] [len]             print as indented JSON
| pk [len]                print key in randomart mosaic
| pK [len]                print key in randomart mosaic
| pl[?][format] [arg]     print list of data (pl Ffvc)
| pm[?] [magic]           print libmagic data (see pm? and /m?)
| po[?] hex               print operation applied to block (see po?)
| pp[?][sz] [len]         print patterns, see pp? for more help
| pq[?][is] [len]         print QR code with the first Nbytes
| pr[?][glx] [len]        print N raw bytes (in lines or hexblocks, 'g'unzip)
| ps[?][pwz] [len]        print pascal/wide/zero-terminated strings
| pt[?][dn] [len]         print different timestamps
| pu[w] [len]             print N url encoded bytes (w=wide)
| pv[?][ejh] [mode]       show value of given size (1, 2, 4, 8)
| pwd                     display current working directory
| px[?][owq] [len]        hexdump of N bytes (o=octal, w=32bit, q=64bit)
| py([-:file]) [expr]     print clipboard (yp) run python script (py:file) oneliner `py print(1)` or stdin slurp `py-`
| pz[?] [len]             print zoom view (see pz? for help)
| pkill [process-name]    kill all processes with the given name
| pushd [dir]             cd to dir and push current directory to stack
| popd[-a][-h]            pop dir off top of stack and cd to it
```

### pd

```bash
[0xffff87d76c40]> pd?
Usage: p[dD][ajbrfils] [[-]len]   # Print N bytes/instructions bw/forward
| NOTE: len        parameter can be negative
| NOTE:            Pressing ENTER on empty command will repeat last print command in next page
| pD N             disassemble N bytes
| pd -N            disassemble N instructions backwards
| pd N             disassemble N instructions
| pd-- N           context disassembly of N instructions
| pda              disassemble all possible opcodes (byte per byte)
| pdaj             disassemble all possible opcodes (byte per byte) in JSON
| pdb[j]           disassemble basic block (j for JSON)
| pdc[?][c]        pseudo disassembler output in C-like syntax
| pdC              show comments found in N instructions
| pde[q|qq|j] N    disassemble N instructions following execution flow from current PC
| pdo N            convert esil expressions of N instructions to C (pdO for bytes)
| pdf              disassemble function
| pdfs             disassemble function summary
| pdi              like 'pi', with offset and bytes
| pdj              disassemble to json
| pdJ              formatted disassembly like pd as json
| pdk[?]           disassemble all methods of a class
| pdl              show instruction sizes
| pdp              disassemble by following pointers to read ropchains
| pdr              recursive disassemble across the function graph
| pdr.             recursive disassemble across the function graph (from current basic block)
| pdR              recursive disassemble block size bytes without analyzing functions
| pds[?]           print disasm summary, showing referenced names
| pdsb [N]         basic block summary
| pdsf[sjq]        show function summary of strings, calls, variables, references..
| pdss [N]         string summary in current function
| pdu[aceios?]     disassemble instructions until condition
| pd, [n] [query]  disassemble N instructions in a table (see dtd for debug traces)
| pdx [hex]        alias for pad or pix
```

Disassemble 10 instructions following pc:

```bash
[0x000000000000]> pd 10

```

Disassemble a symbol/function at a memory address:

```bash
[0x000000000000]> is
79  0x00000754 0xaaaae7680754 GLOBAL FUNC   76       func

[0x000000000000]> pd @0xaaaae7680754
            ;-- func:
            0xaaaae7680754      ff8300d1       sub sp, sp, 0x20
            0xaaaae7680758      e00f00b9       str w0, [sp, 0xc]
            0xaaaae768075c      ff1b00b9       str wzr, [sp, 0x18]
            0xaaaae7680760      ff1f00b9       str wzr, [sp, 0x1c]

            [...snip...]

```

Disassemble function at current pc:

```bash
[0x000000000000]> pdf
```

After execute `aa` to analyze all, we can disassemble function by symbol name:

```bash
[0x000000000000]> s main; pdf
[0x000000000000]> s sym.main; pdf
[0x000000000000]> pdf @ main
[0x000000000000]> pdf @ sym.main

[0x000000000000]> s sym.func; pdf
[0x000000000000]> pdf @ sym.func
```

## d Mode

[Radare2 Book: 10. Debugger](https://book.rada.re/debugger/getting_started.html)
[Debugging: The d Module](https://r2.cole-ellis.com/radare2-modules/delta)

```bash
[0x000000000000]> d?
Usage: d   # Debug commands
| d:[?] [cmd]              run custom debug plugin command
| db[?]                    breakpoints commands
| dbt[?]                   display backtrace based on dbg.btdepth and dbg.btalgo
| dc[?]                    continue execution
| dd[?][*+-tsdfrw]         manage file descriptors for child process
| de[-sc] [perm] [rm] [e]  debug with ESIL (see de?)
| dg <file>                generate a core-file (WIP)
| dh [plugin-name]         select a new debug handler plugin (see dbh)
| dH [handler]             transplant process to a new handler
| di[?]                    show debugger backend information (See dh)
| dk[?]                    list, send, get, set, signal handlers of child
| dL[?]                    list or set debugger handler
| dm[?]                    show memory maps
| do[?]                    open process (reload, alias for 'oo')
| doo[args]                reopen in debug mode with args (alias for 'ood')
| doof[file]               reopen in debug mode from file (alias for 'oodf')
| doc                      close debug session
| dp[?]                    list, attach to process or thread id
| dr[?]                    cpu registers
| ds[?]                    step, over, source line
| dt[?]                    display instruction traces
| dw <pid>                 block prompt until pid dies
| dx[?][aers]              execute code in the child process
| date [-b]                use -b for beat time
```

- `dbt`[?]: display backtrace based on dbg.btdepth and dbg.btalgo

### memory

```bash
[0x000000000000]> dm?
Usage: dm   # Memory maps commands
| dm                                list memory maps of target process

| dm=                               list memory maps of target process (ascii-art bars)
| dm.                               show map name of current address
| dm*                               list memmaps in radare commands

| dmi [addr|libname] [symname]      list symbols of target lib
| dmi* [addr|libname] [symname]     list symbols of target lib in radare commands
| dmi.                              list closest symbol to the current address

| dmm[?][j*]                        list modules (libraries, binaries loaded in memory)

| dmS[*] [addr|libname] [sectname]  list sections of target lib

```

After `r2 -Ad test-gdb`, we enter r2 console, the initial offset is `0xffffab36cc28`.

Let's try to find out which instruction is at that address and which module it belongs to.

First, type `dmm` to show linkmap / list loaded modules:

```bash
[0xffffab36cc28]> dmm
INFO: modules.get
0xaaaae4b60000 0xaaaae4b61000  /home/pifan/Projects/cpp/test-gdb
0xffffab36b000 0xffffab396000  /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
```

Use `dm.` to display the map name of the current address for further confirmation.

We can easily see that the current address/offset falls into the `ld` module.

Type `dmS.` or `dmS ld-linux-aarch64.so` to list sections of current/target lib/module.

It turns out that there are only two executable sections, the `.plt` section and `.text` section.

```bash
[0xffffab36cc28]> dmS ld-linux-aarch64.so
INFO: modules.get
[Sections]

nth paddr          size vaddr             vsize perm type       name
――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x00000000      0x0 0x00000000          0x0 ---- NULL       ld-linux-aarch64.so.1.

[...snip...]

10  0x00001ba0     0x70 0xffffab36cba0     0x70 -r-x PROGBITS   ld-linux-aarch64.so.1..plt
11  0x00001c40  0x1e464 0xffffab36cc40  0x1e464 -r-x PROGBITS   ld-linux-aarch64.so.1..text

[...snip...]
```

Compare the *vaddr* column, it's obvious that the current address/offset belongs to the `.plt` section.

Finally, we can `pd` the address to see the corresponding instructions.

```bash
[0xffffab36cc28]> pd @0xffffab36cba0
```

### registers

```bash
[0x000000000000]> dr?
Usage: dr  Registers commands
| dr                   show 'gpr' registers

| dr=                  show registers in columns
| dr?<register>        show value of given register
| dr??                 same as dr?`drp~=[0]+` # list all reg roles alias names and values

| drr                  show registers references (telescoping)
| drs[?]               stack register states
| drt[?]               show all register types
| drw <hexnum>         set contents of the register arena
```

### breakpoints

```bash
[0x000000000000]> db?
Usage: db   # Breakpoints commands

| db                        list breakpoints
| db*                       list breakpoints in r commands
| db sym.main               add breakpoint into sym.main
| db <addr>                 add breakpoint
| dbH <addr>                add hardware breakpoint
| db- <addr>                remove breakpoint
| db-*                      remove all the breakpoints

| dbc <addr> <cmd>          run command when breakpoint is hit
| dbC <addr> <cmd>          run command but continue until <cmd> returns zero
| dbd <addr>                disable breakpoint
| dbe <addr>                enable breakpoint
| dbs <addr>                toggle breakpoint

| dbi                       list breakpoint indexes
| dbi <addr>                show breakpoint index in givengiven  offset
| dbi.                      show breakpoint index in current offset
| dbi- <idx>                remove breakpoint by index

| dbie <idx>                enable breakpoint by index
| dbid <idx>                disable breakpoint by index

| dbt[?]                    show backtrace. See dbt? for more details
```

Add breakpoint at specified address:

```bash
[0x000000000000]> db <addr>
```

After execute `aa` to analyze all, we can set breakpoints by symbol name:

```bash
[0x000000000000]> db entry0
[0x000000000000]> db main
[0x000000000000]> db sym.main
[0x000000000000]> db sym.func
```

### continuation

```bash
[0x000000000000]> dc?
Usage: dc  Execution continuation commands
| dc                           continue execution of all children
| dc <pid>                     continue execution of pid
| dc[-pid]                     stop execution of pid
| dcb                          continue back until breakpoint
| dcc                          continue until call (use step into)
| dcco                         continue until call (use step over)
| dccu                         continue until unknown call (call reg)
| dce                          continue execution (pass exception to program)
| dcf                          continue until fork (TODO)
| dck <signal> <pid>           continue sending signal to process
| dcp                          continue until program code (mapped io section)
| dcr                          continue until ret (uses step over)
| dcs[?] <num>                 continue until syscall
| dct <len>                    traptrace from curseek to len, no argument to list
| dcu[?] [..end|addr] ([end])  continue until address (or range)
```

- `dcc`: continue until call (use step into)
- `dcr`: continue until ret (uses step over)
- `dcs[?] <num>`: continue until syscall

continue until address/symbol/function:

```bash
dcu entry0
dcu main
dcu sym.main
dcu sym.func
```

### Step

```bash
[0x000000000000]> ds?
Usage: ds  Step commands
| ds                step one instruction
| ds <num>          step <num> instructions
| dsb               step back one instruction
| dsf               step until end of frame
| dsi <cond>        continue until condition matches
| dsl               step one source line
| dsl <num>         step <num> source lines
| dso <num>         step over <num> instructions
| dsp               step into program (skip libs)
| dss <num>         skip <num> step instructions
| dsu[?] <address>  step until <address>. See 'dsu?' for other step until cmds.
```

## v Mode

[Radare2 Book: 5. Visual mode](https://book.rada.re/visual_mode/intro.html)

### V

```bash
[0x000000000000]> V?
| V  visual mode (Vv = func/var anal, VV = graph mode, ...)
```

Type `?` to list help menu of Visual mode, press `q` to quit the menu.

```bash
Visual Mode Help (short)
| ?  full help
| !  enter panels
| a  code analysis
| c  toggle cursor
| d  debugger / emulator
| e  toggle configurations
| i  insert / write
| m  moving around (seeking)
| p  print commands and modes
| v  view management
```

> Use `:command` to execute r2 commands from inside Visual Mode. This is similar to VIM.

Type `!`(equivalent to `:v`) to enter Visual Panels. To exit from it back to Visual mode, press `q`.
Type `c` to toggle the cursor mode, then type `hljk` to scroll the page like vim.

Type `d` to view help of debugger / emulator.

```bash
Visual Debugger Help:

 $   -> set the program counter (PC register)
 s   -> step in
 S   -> step over
 B   -> toggle breakpoint
 :dc -> continue
```

### v

Type `!`(equivalent to `:v`) from Visual mode, or type `v` from r2 console to enter Visual Panels mode.

```bash
[0x000000000000]> v?
Usage: v[*i]
| v             open visual panels
| v test        load saved layout with name test
| ve [fg] [bg]  define foreground and background for current panel
| v. [file]     load visual script (also known as slides)
| v= test       save current layout with name test
| vi test       open the file test in 'cfg.editor'
```

To open visual panels, use `v` command, press `q` to exit.

The useful Debugger view shows us the Disassembly, Stack and Registers. We can move around the binary via seeking and stepping.

Use the `p`/`P` command to swap current panel with the first/last one.

Type `?` to open the help panel, press `X` to close the help panel.

```bash
| |      split current panel vertically
| -      split current panel horizontally
| :      run r2 command in prompt
| !      swap into visual mode
| .      seek to PC or entrypoint
| *      show decompiler in the current panel
| /      highlight the keyword
| [1-9]  follow jmp/call identified by shortcut (like ;[1])
| ' '    (space) toggle graph / panels
| tab    go to the next panel
| Enter  maximize current panel in zoom mode
| b      browse symbols, flags, configurations, classes, .
| c      toggle cursor
| D      show disassembly in the current panel
| g      go/seek to given offset
| G      go/seek to highlight
| hjkl   move around (left-down-up-right)
| HJKL   move around (left-down-up-right) by page
| m      select the menu panel
| q      quit, or close a tab
| Q      close all the tabs and quit
| n/N    seek next/prev function/flag/hit (scr.nkey)
| s/S    step in / step over
| t/T    tab prompt / close a tab
| V      go to the graph mode
| x      show xrefs/refs of current function from/to data/
| X      close current panel
| z      swap current panel with the first one
```

1. `Tab`: move the focus to the next panel without changing their position.
2. `Enter`: maximize current panel in zoom mode. Press `Enter` or `q` to quit.
3. `space`: toggle graph / panels.
4. `m`: select the menu panel, use `hjkl` to navigate and `Enter` to choose.
5. `.`: seek to PC or entrypoint.
6. `g`: go/seek to given offset/address.
7. `s`/`S`: step in / step over.

Type `:` to enter Bottom Command mode, run r2 commands in prompt, e.g., `db`, `dc`.
Press `v`/`q` to exit and return back to Visual Panels mode.

### VV

Show call graph of function:

```bash
[0x000000000000]> VV @ sym.func
```

Toggle between disasm and graph with the `space` key.

Type `?` to list all the commands of Visual Graph mode.

```bash
| >                    show function callgraph (see graph.refs)
| <                    show program callgraph (see graph.refs)
| %                    find in disassembly (pdr~sentence) and navigate to it in graph
| c                    toggle graph cursor mode
| D                    toggle the mixed graph+disasm mode
| o([A-Za-z]*)         follow jmp/call identified by shortcut (like ;[oa])
| O                    toggle asm.pseudo and asm.esil
| q                    back to Visual mode
| R                    randomize colors
| s/S                  step / step over
| tab                  select next node
| TAB                  select previous node
```

Note the designations of each module node, such as `o[a-z]`, then type `oa` / `ob` / `oc` to change central focus.

## refs

[gdb list command ?](https://github.com/radareorg/radare2/issues/1783)
[Radare2 "pd" command](https://stackoverflow.com/questions/62319299/radare2-pd-command)
[How to dump function's disassembly using r2pipe](https://stackoverflow.com/questions/55402547/how-to-dump-functions-disassembly-using-r2pipe)
[How to make radare2 work for a large binary?](https://reverseengineering.stackexchange.com/questions/16112/how-to-make-radare2-work-for-a-large-binary/16115#16115)

[Disassembling with radare2](https://www.linuxdays.cz/2017/video/Tomas_Antecky-Disassembling_with_radare2.pdf)
A journey into Radare 2: [Part 1](https://www.megabeets.net/a-journey-into-radare-2-part-1/), [Part 2](https://www.megabeets.net/a-journey-into-radare-2-part-2/)

[Reverse Engineering With Radare2](https://samsymons.com/blog/reverse-engineering-with-radare2-part-1/)
[Radare2 for reverse engineering](https://itnext.io/radare2-for-reverse-engineering-part1-eedf0a47b5cc)

Reverse Engineering Using Radare2: [Part 1](https://goggleheadedhacker.com/blog/post/1), [Part 2](https://goggleheadedhacker.com/blog/post/2)
Reverse engineering using Radare2: [Part 1](https://hackyourmom.com/en/servisy/zvorotnij-inzhyniryng-iz-vykorystannyam-radare2/), [Part 2](https://hackyourmom.com/en/servisy/revers-inzhyniryng-ta-skrypty/zvorotnij-inzhyniryng-iz-vykorystannyam-radare2-chastyna-2/)

[Exploring ELF Binary Dynamics: Relocations and Sections in Depth](https://www.kayssel.com/post/binary-4/#navigating-the-world-of-lazy-binding-plt-and-got-in-elf-binaries)