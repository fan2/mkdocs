---
title: radare2 basics - sail
authors:
  - xman
date:
    created: 2023-10-02T10:00:00
categories:
    - toolchain
tags:
    - grep
    - config
    - expr
    - env
    - var
comments: true
---

After installing the radare2 toolset, we've come [on board](./radare2-basics.md).
Let's set sail with some important and frequently used commands.
First raw, then ripe. Well begun is half done.

<!-- more -->

## grep(~)

[2. First Steps - 2.2. Command Format](https://book.rada.re/first_steps/command_format.html)

The standard UNIX pipe `|` is also available in the *radare2* shell. You can use it to filter the output of an `r2` command with any shell program that reads from stdin, such as `grep`, `less`, `wc`. If you do not want to spawn anything, or you can’t, or the target system does not have the basic UNIX tools you need (Windows or embedded users), you can also use the built-in grep (`~`).

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

The `~` character enables internal grep-like function used to filter output of any command:

```bash
pd 20~call            ; disassemble 20 instructions and grep output for 'call'
```

Additionally, you can grep either for columns or for rows:

```bash
pd 20~call:0          ; get first row
pd 20~call:1          ; get second row
pd 20~call[0]         ; get first column
pd 20~call[1]         ; get second column
```

Or even combine them:

```bash
pd 20~call:0[0]       ; grep the first column of the first row matching 'call'
```

```bash
[0xaaaae7580754]> i~pic
pic      true

[0xaaaae7580754]> i~baddr
baddr    0xaaaae7580000

# show only column 1
[0xaaaae7580754]> i~baddr[1]
0xaaaae7580000
```

## config(e)

[Radare2 Book: 3. Configuration](https://book.rada.re/configuration/intro.html)

Use `r2 -H` to list all the environment variables that matter to know where it will be looking for files.

> R2_RCFILE=`~/.radare2rc`(aka `$HOME/.radare2rc`).

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

Show description:

```bash
[0x004005c8]> e? asm.symbol
show symbol+delta instead of absolute offset
[0x004005c8]> e? asm.comments
show comments in disassembly view (see 'e asm.cmt.')
[0x004005c8]> e?asm.describe
show opcode description
[0x004005c8]> e?asm.pseudo # see pdc
enable pseudo syntax
```

Filter config vars with description: `e??~whatever`

```bash
# e??asm will show lots of results, grep with concrete config name
[0x000000000000]> e??~asm.pseudo
          asm.pseudo: enable pseudo syntax
[0x000000000000]> e??~asm.describe
        asm.describe: show opcode description

# e??~arch will match more fuzzy results with the pattern
[0x000000000000]> e??arch
           arch.bits: word size in bits at arch decoder
        arch.decoder: select the instruction decoder to use
         arch.endian: set arch endianness
       arch.platform: define arch platform to use

[0xaaaadc6e0640]> e??~endian
         arch.endian: set arch endianness
       cfg.bigendian: use little (false) or big (true) endianness

[0x000000000000]> e arch.endian # !echo $R2_ENDIAN
little
[0x000000000000]> e cfg.bigendian
false
```

List possible values/view more options with question mark like `e conf.var = ?`.

```bash
[0xffffbc84ae70]> e asm.arch=?
[0xffffbc84ae70]> e bin.relocs.apply=?
[0xffffbc84ae70]> e search.in=?
[0xffffbc84ae70]> e dbg.bpinmap=?

# show offset relative instead of absolute address
[0xffffbc84ae70]> =?
func
flag
maps
dmap
fmap
sect
symb
libs
file
```

Config `bin.relocs.apply`:

```bash
[0xaaaadc6e0640]> e bin.relocs.apply
false
[0xaaaadc6e0640]> e bin.relocs.apply=true; e bin.relocs.apply
true
```

Config `search.in` to search in all memory maps:

```bash
[0x000000000000]> e search.in
dbg.map
[0x000000000000]> e search.in = dbg.maps; e search.in
dbg.maps
```

Config `cfg.bigendian=false` for temporary hexdump in BE.

```bash
# show current endianess
[0xaaaab3ce0634]> e cfg.bigendian
false
# temporally swap/invert endian
[0xaaaab3ce0634]> e!cfg.bigendian

# equivalent imp for `pfed`, `pve 1234 4`.
[0xaaaab3ce0634]> pxw $l @ pc

# reset endianness
[0xaaaab3ce0634]> e!cfg.bigendian
```

[Radare2 can't set breakpoint?](https://reverseengineering.stackexchange.com/questions/13689/radare2-noob-question-cant-set-breakpoint)

Set `e dbg.bpinmaps=false` so Radare2 allows you to set breakpoint without that restriction.

```bash
[0xffffbc84ae70]> e dbg.bpinmaps
true
[0xffffbc84ae70]> e dbg.bpinmaps=false; e dbg.bpinmaps
false
```

Useful configuration variables:

- Use UTF-8 chars: `e scr.utf8 = true`
- Curved UTF-8 corners: `e scr.utf8.curvy = true`
- User uppercase syntax: `e asm.ucase = true`
- Enable cache (r/w): `e io.cache = true`
- Show opcode description: `e asm.describe = true`
- Enable pseudo syntax: `e asm.pseudo = true`
- Show symbol+delta before addr: `e!asm.symbol`
- Don't show comments: `e!asm.comments`, see `e asm.cmt.` and `asm.usercomments`.

Write configuration to file for persistence:

```bash
!echo 'e asm.symbol=true' >> ~/.radare2rc
!echo 'e asm.comments=false' | tee -a ~/.radare2rc
```

To configure radare the visual way, use `Ve`.

## expr(?)

`?v`: show hex value of math expr.

```bash
[0x000000000000]> ???
Usage: ?[?[?]] expression

| ?$                               show value all the variables ($)
| ?b [num]                         show binary value of number
| ?P paddr                         get virtual address for given physical one
| ?p vaddr                         get physical address for given virtual address
| ?q num|expr                      compute expression like ? or ?v but in quiet mode
| ?v num|expr                      show hex value of math expr (no expr prints $?)
| ?vi[1248] num|expr               show decimal value of math expr [n bytes]
| ?vx num|expr                     show 8 digit padding in hex
| ?w addr                          show what's in this address (like pxr/pxq does)
| ?X num|expr                      returns the hexadecimal value numeric expr
```

Show all representation result for expr with single question mark.

```bash
[0xffffbc190c40]> ? 1989+64
int32   2053
uint32  2053
hex     0x805
octal   04005
unit    2.0K
segment 0000:0805
string  "\x05\b"
fvalue  2053.0
float   0.000000f
double  0.000000
binary  0b0000100000000101
base36  0_1l1
ternary 0t2211001
```

Telescope/dereference overflowed pc as prepended debruijn pattern string.

```bash
# -e(little-endian) incompatible with -r
# use rev to reverse lines characterwise
$ echo 0x4141764141754141 | xxd -rp | rev
AAuAAvAA%

$ echo -e `rax2 -c 0x4141764141754141`
AAuAAvAA

# ? pc ~string or ? $$ ~string
[0x4141764141754141]> ? 0x4141764141754141 ~string
string  "AAuAAvAA"

# get second column, like | awk '{print $2}'
[0x4141764141754141]> ? pc ~string[1]
"AAuAAvAA"
```

Perform simple arithmetic on the spot, results depending on the numeric base.

```bash
[0x000000000000]> ?vi 1989+64 # rax2 -k 1989+64
2053
[0x000000000000]> ?b 16 # rax2 b16 # rax2 Bx10
10000b
[0x000000000000]> ?v 1989+64 # rax2 1989+64
0x805
[0x000000000000]> ?X 1989+64
805
[0x000000000000]> ?vx 1989+64 # 8 digit padding
0x00000805
```

`?w <address>`: inspect what's in this address, not equivalent to `info symbol ADDR` in GDB.

```bash
[0xffffb6d45c40]> ?w 0xaaaad2f50640
/home/pifan/Projects/cpp/a.out .text entry0,section..text,_start entry0 program R X 'nop' 'a.out'
```

`?v <symbol>` acts as `afo <symbol>`, show the address for the symbol, similar to `info address SYM` in GDB.

```bash
[0xffff99b209d0]> ?v sym.main # afo sym.main
0xaaaae16307a0
[0xffff99b209d0]> ?v sym.func # afo sym.func
0xaaaae1630754
[0xffffa8098c40]> ?v segment.LOAD0
0xaaaade740000
```

## env(%)

```bash
[0x000000000000]> env?
| en           list environment vars
| env [k[=v]]  get/set environment variable

[0x000000000000]> %?
Usage: %[name[=value]]  Set each NAME to VALUE in the environment
| %             list all environment variables

[0x000000000000]> %??
Usage: %[name[=value]]  Set each NAME to VALUE in the environment
| %             list all environment variables
| %*            show env vars as r2 commands
| %j            show env vars in JSON format
| %SHELL        prints SHELL value
| %TMPDIR=/tmp  sets TMPDIR value to "/tmp"

Environment:
| R2_FILE           file name
| R2_OFFSET         10base offset 64bit value
| R2_BYTES          TODO: variable with bytes in curblock
| R2_XOFFSET        same as above, but in 16 base
| R2_BSIZE          block size
| R2_ENDIAN         'big' or 'little'
| R2_IOVA           is io.va true? virtual addressing (1,0)
| R2_DEBUG          debug mode enabled? (1,0)
| R2_BLOCK          TODO: dump current block to tmp file
| R2_SIZE           file size
| R2_ARCH           value of asm.arch
| R2_BITS           arch reg size (8, 16, 32, 64)
| RABIN2_LANG       assume this lang to demangle
| RABIN2_DEMANGLE   demangle or not
| RABIN2_PDBSERVER  e pdb.server

[0x000000000000]> ?
Usage: [.][times][cmd][~grep][@[@iter]addr!size][|>pipe] ; ...
Append '?' to any char command to get detailed help
Prefix with number to repeat command N times (f.ex: 3x)
| %var=value              alias for 'env' command

| _[?]                    Print last output

```

List/Dump Examples:

```bash
[0x000000000000]> env _ # %_
/snap/bin/r2
[0x000000000000]> env SHELL # %SHELL
/usr/bin/zsh
[0x000000000000]> _ # same as python REPL
/usr/bin/zsh
```

Show/filter env vars:

```bash
[0x000000000000]> %~term
TERM=xterm-256color
[0x000000000000]> %~Term
TERM_PROGRAM=WarpTerminal

[0x000000000000]> !echo $R2_FILE # %~R2_FILE
[0x000000000000]> !echo $R2_ENDIAN # %~R2_ENDIAN

# e asm.arch
[0x000000000000]> !echo $R2_ARCH # %~R2_ARCH
# e asm.bits
[0x000000000000]> !echo $R2_BITS # %~R2_BITS
```

Define a temporary environment variable at session level.

> To avoid overwriting, run `%~ENVVAR` to see if it's already there.

```bash
# check existence first: %~FP
[0x004008e0]> %FP=`xQq $w @ sp`
[0x004008e0]> %~FP
FP=0x0000ffffdf541530
[0x004008e0]> %FP
0x0000ffffdf541530

# check existence first: %~SP
[0x004008e0]> %SP=`dr sp`
[0x004008e0]> %~SP
SP=0xffffdf541500
[0x004008e0]> %SP
0xffffdf541500
```

Then you can refer to the vars in subsequent math expr or any r2 command.

```bash
[0x004008e0]> ?v `env FP`-`env SP` # ?v `%FP`-`%SP`
0x30
# save result(last output) in another var
[0x004008e0]> %SIZE=`_` ; %SIZE
0x30
# ref the var in r2 command
[0x004008e0]> xQ `%SIZE` @ sp
0xffffdf541500 0x0000ffffdf541530 sp+48
0xffffdf541508 0x0000ffffb7b073fc x30
0xffffdf541510 0x0000ffffdf541530 sp+48
0xffffdf541518 0x0000ffffb7b073c0
0xffffdf541520 0x0000ffffdf5416a8 x1
0xffffdf541528 0x0000000000000010 x9
```

## var($)

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
| $D            current debug map base address ?v $D @ rsp
| $DB           same as dbg.baddr, progam base address
| $DD           current debug map size
| $F            same as $FB
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
[0xaaaac30a07a0]> ?v pc # ?v $$
0xaaaac30a07a0
```

Define simple macros by alias.

```bash
[0xaaaac30a07a0]> $rip=1989+64
[0xaaaac30a07a0]> $rip?
1989+64

# list all self-defined aliases
# ?$: show value all the built-in variables, prefixed with $
[0xaaaac30a07a0]> $
$rip
[0xaaaac30a07a0]> $*
$rip=1989+64
```

Eval map/opcode/word size related \$ vars.

```bash
[0x000000000000]> ?v $MM
0x7fffffffffffffff

# display size of 1 opcode
[0x000000000000]> aos 1
4
[0x000000000000]> ?v $l
0x4
[0x000000000000]> e arch.bits
32

# display machine word size
[0x000000000000]> ?v $w
0x8
[0x000000000000]> e asm.bits
64
[0x000000000000]> !getconf LONG_BIT
64
```

Detect begin/end of current function:

```bash
[0x000000000000]> ?v $F # same as $FB
0x000000000000
[0x000000000000]> ?v $FE
0xaaaac30a07a0
```

`$r{reg}` is equivalent to `dr?<register>`, see `drl`, `dr??` and `dr=`.

```bash
[0x000000000000]> ?v $r{x0} # ?v $r:A0
0xfa
[0x000000000000]> ?v $r{PC} # dr?pc
0x000000000000
[0x000000000000]> ?v $r{BP} # dr bp
0xffffdca194e0
[0x000000000000]> ?v $r:SP # dr sp
0xffffdca194e0
```

## refs

[How-To: Radare2](https://r2.cole-ellis.com/)
[awesome-radare2](https://github.com/radareorg/awesome-radare2/blob/master/README.md)
[Radare2 vs. GDB](https://hurricanelabs.com/blog/learning-binary-reversing-radare2-vs-gdb/)
[Radare2 Explorations](https://monosource.gitbooks.io/radare2-explorations/)
[Radare2 — Keep It Or Leave It?](https://medium.com/@sagidana/radare2-keep-it-or-leave-it-3d45059ec0d1)

[Disassembling with radare2.pdf](https://www.linuxdays.cz/2017/video/Tomas_Antecky-Disassembling_with_radare2.pdf)
pancake - [Learning Radare In Practice.pdf](https://www.radare.org/get/THC2018.pdf)
[Overcoming fear: reversing with radare2.pdf](https://conference.hitb.org/hitbsecconf2019ams/materials/D1T3%20-%20Reversing%20with%20Radare2%20-%20Arnau%20Gamez%20Montolio.pdf)
