---
title: radare2 i/p modules - info/print
authors:
  - xman
date:
    created: 2023-10-02T16:00:00
categories:
    - toolchain
comments: true
---

So far, we've combed through the [radare2 basics](./radare2-basics.md) and [radare2 a module - analysis](./radare2-a.md).

In this article, I'll give an overview of the `i` and `p` modules:

1. `i`: displaying information about the binary(the program being debugged).
2. `p`: printing memory and data, such as the hexdump, the disassembly, and the strings.

<!-- more -->

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

### ie - info entrypoint

- `ie`: entrypoint
- `iee`: list constructors and destructors
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

- `iM`: show main address

```bash
[0xffffaa6d6c40]> iM
[Main]
vaddr=0xaaaae48e0754 paddr=0x00000754
```

### is - info symbols

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

### iS/iSS - sections & segments

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

Print string at `x0`(the first parameter for next call):

```bash
# with newline
ps @ x0 # psz @ x0
# without newline
psz 48 @ x0 # specify estimated length
# explore what is there
?w x0
```

### pf - printf

```bash
[0xffffa4386c40]> pf?
Usage: pf[.k[.f[=v]]|[v]]|[n]|[0|cnt][fmt] [a0 a1 ...]
Commands:
| pf fmt                     show data using the given format-string. See 'pf??' and 'pf???'.
| pf?                        help on commands
| pf??                       help on format characters
| pf???                      show usage examples
| pf* fmt_name|fmt           show data using (named) format as r2 flag create commands
| pf.                        list all format definitions
| pf.fmt_name                show data using named format
| pf.fmt_name.field_name     show specific data field using named format
| pf.fmt_name.field_name=33  set new value for the specified field in named format
| pf.fmt_name.field_name[i]  show element i of array field_name
| pf.fmt_name [0|cnt]fmt     define a new named format
| pf?fmt_name                show the definition of a named format
| pfb binfmt                 binary format
| pfc fmt_name|fmt           show data using (named) format as C string
| pfd.fmt_name               show data using named format as graphviz commands
| pfj fmt_name|fmt           show data using (named) format in JSON
| pfo fdf_name               load a Format Definition File (fdf)
| pfo                        list all format definition files (fdf)
| pfq fmt ...                quiet print format (do now show address)
| pfs[.fmt_name|fmt]         print the size of (named) format in bytes
| pfv.fmt_name[.field]       print value(s) only for named format. Useful for one-liners

[0xffffa4386c40]> pf??
Usage: pf[.k[.f[=v]]|[v]]|[n]|[0|cnt][fmt] [a0 a1 ...]
Format:
|  b       byte (unsigned)
|  B       resolve enum bitfield (see t?)
|  c       char (signed byte)
|  C       byte in decimal
|  d       dword (4 bytes in hex) (see 'i' and 'x')
|  D       disassemble one opcode
|  e       temporally swap endian
|  E       resolve enum name (see t?)
|  f       float value (4 bytes)
|  F       double value (8 bytes)
|  G       long double value (16 bytes (10 with padding))
|  i       signed integer value (4 bytes) (see 'd' and 'x')
|  n       next char specifies size of signed value (1, 2, 4 or 8 byte(s))
|  N       next char specifies size of unsigned value (1, 2, 4 or 8 byte(s))
|  o       octal value (4 byte)
|  p       pointer reference (2, 4 or 8 bytes)
|  q       quadword (8 bytes)
|  Q       uint128_t (16 bytes)
|  r       CPU register `pf r (eax)plop`
|  s       32bit pointer to string (4 bytes)
|  S       64bit pointer to string (8 bytes)
|  t       UNIX timestamp (4 bytes)
|  T       show Ten first bytes of buffer
|  u       uleb128 (variable length)
|  w       word (2 bytes unsigned short in hex)
|  x       0xHEX value and flag (fd @ addr) (see 'd' and 'i')
|  X       show formatted hexpairs
|  z       null terminated string
|  Z       null terminated wide string
|  ?       data structure `pf ? (struct_name)example_name`
|  *       next char is a pointer (honors asm.bits)
|  +       toggle show flags for each offset
|  :       skip 4 bytes
|  .       skip 1 byte
|  ;       rewind 4 bytes
|  ,       rewind 1 byte
```

1. `pfD` is simple version of `pd 1` without context;
2. `pfp`: pointer reference, analogous to `pxr`.
3. `pfS`: 64bit pointer to string.

Hexdump 4 raw bytes from pc.

```bash
# memory storage/bytearry perspective
[0xaaaab3ce0630]> pf4b @ pc
0xaaaab3ce0634 [0] {
  0xaaaab3ce0634 = 0x11
}
0xaaaab3ce0635 [1] {
  0xaaaab3ce0635 = 0xe6
}
0xaaaab3ce0636 [2] {
  0xaaaab3ce0636 = 0x47
}
0xaaaab3ce0637 [3] {
  0xaaaab3ce0637 = 0xf9
}
```

Hexdump one `d` dword(4 bytes) in hex, print with optional given labels.

```bash
# opcode fetched as LE, endianness swapped
[0xaaaab3ce0634]> pf1d opcode
 opcode : 0xaaaab3ce0634 = 0xf947e611

# endianness already swapped, just decode it as BE.
$ rasm2 -de -a arm 0xf947e611
$ cstool arm64be 0xf947e611
$ cstool -d arm64be 0xf947e611
```

`e` temporally swap endian:

```bash
[0xaaaab3ce0634]> pfed opcode
 opcode : 0xaaaab3ce0634 = 0x11e647f9

[0xaaaab3ce0634]> pd 1
│           ;-- pc:
│           0xaaaab3ce0634      11e647f9       ldr x17, [x16, 0xfc8]
```

`pfedd`: dump two dword in big-endian.
`pfeded`: dump one dword in big-endian, the next in default little-endian.

### px - hexdump

Show hexdump of N bytes.

> GDB flavored `x` is alias for `px`.

```bash
[0xffffbdb54c40]> x?
Usage: px[0afoswqWqQ][f]   # Print heXadecimal
| px                show hexdump
| px--[n]           context hexdump (the hexdump version of pd--3)
| px/               same as x/ in gdb (help x)
| px*               same as pc* or p8*, print r2 commands as in hexdump
| px0               8bit hexpair list of bytes until zero byte
| pxa               show annotated hexdump
| pxA[?]            show op analysis color map
| pxb               dump bits in hexdump form
| pxB               dump bits in bitmap form
| pxc               show hexdump with comments
| pxd[?1248]        signed integer dump (1 byte, 2 and 4)
| pxe               emoji hexdump! :)
| pxf               show hexdump of current function
| pxh               show hexadecimal half-words dump (16bit)
| pxH               same as above, but one per line
| pxi               HexII compact binary representation
| pxl               display N lines (rows) of hexdump
| pxo               show octal dump
| pxq               show hexadecimal quad-words dump (64bit)
| pxQ[q]            same as above, but one per line
| pxr[1248][qj]     show hexword references (q=quiet, j=json)
| pxs               show hexadecimal in sparse mode
| pxt[*.] [origin]  show delta pointer table in r2 commands
| pxu[?1248]        unsigned integer dump (1 byte, 2 and 4)
| pxw               show hexadecimal words dump (32bit)
| pxW[q]            same as above, but one per line (q=quiet)
| pxx               show N bytes of hex-less hexdump
| pxX               show N words of hex-less hexdump
```

`pxw` hexdump current word(A32/A64 instruction opcode length `$l=4`).

`pxw $l`(`pxw $l @ pc`): hexdump instruction opcode in pc, but default in little-endian.

```bash
[0xaaaab3ce0634]> pxw $l
0xaaaab3ce0634  0xf947e611                                   ..G.
```

Config `cfg.bigendian=false` and then reset, equivalent implementation of `pfed`

```bash
# temporally swap endian
[0xaaaab3ce0634]> e cfg.bigendian
false
[0xaaaab3ce0634]> e cfg.bigendian=true

[0xaaaab3ce0634]> pxw $l @ pc
0xaaaab3ce0634  0x11e647f9                                   ..G.

# reset endianness
[0xaaaab3ce0634]> e cfg.bigendian=true
```

View 32 items (\_\_WORDSIZE=`$w`) of the current stack, following the current sp:

```bash
# two machine word per line, equivalent to x/32xg $sp in GDB
pxq $w*32 @ sp
# one machine word per line
pxQ $w*32 @ sp
```

### pd - disassemble

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

Print/Disassemble 10 instructions following pc:

```bash
[0x000000000000]> pi 10

[0x000000000000]> pd 10

```

1. print the instruction to be executed next with.

    > gdb: `x/i $pc`; `disassemble $pc, $pc+4`.
    > r2: `pd 1`

2. disassemble 2 instructions above, exclude pc

    > gdb: `x/2i $pc-8`; `disassemble $pc-8, $pc`
    > r2: `pd -2`

3. disassemble 2 instructions below, exclude pc

    > gdb: `x/2i $pc+4`; `disassemble $pc+4, $pc+12`
    > r2: `pd 2 @ +$l`

4. disassemble 3 instructions backwards, include pc

    > gdb: `x/3i $pc-8`; `disassemble $pc-8, $pc+4`
    > r2: `pd 3 @ -2*$l`

5. disassemble 3 instructions forwards, include pc

    > gdb: `x/3i $pc`; `disassemble $pc, $pc+12`
    > r2: `pd 3`

6. context disassembly of 3 instructions

    > gdb: `x/7i $pc-12`; `disassemble $pc-12, $pc+16`
    > r2: `pd 7 @ -3*$l`. `pd-- 3` - three above, two below.

Disassemble a symbol/function at a memory address:

```bash
[0x000000000000]> is ~func
79  0x00000754 0xaaaae7680754 GLOBAL FUNC   76       func

[0x000000000000]> pd @0xaaaae7680754
            ;-- func:
            0xaaaae7680754      ff8300d1       sub sp, sp, 0x20
            0xaaaae7680758      e00f00b9       str w0, [sp, 0xc]
            0xaaaae768075c      ff1b00b9       str wzr, [sp, 0x18]
            0xaaaae7680760      ff1f00b9       str wzr, [sp, 0x1c]

            [...snip...]

```

Seek to somewhere, then try to disassemble:

```bash
[0x000000000000]> s main; pd 5 # s sym.main; pd 5
[0x000000000000]> s sym.func; pd 5
```

Disassemble function at current pc:

> Unlike `pdf`, `pif` does not display contexts such as address and opcode.

```bash
[0x000000000000]> pif
[0x000000000000]> pdf
```

After execute `aa` to analyze all, we can disassemble function by symbol name:

```bash
[0x000000000000]> pdf @ entry0
[0x000000000000]> pdf @ main # pdf @ sym.main
[0x000000000000]> pdf @ sym.func
```

Seek to somewhere, then try to disassemble as function:

```bash
[0x000000000000]> s main; pdf # s sym.main; pdf
[0x000000000000]> s sym.func; pdf
```

For given address <addr\>, try `pdf @addr`/`pd 1 @addr` to detect the symbol/label name.

> Equivalent to `info symbol ADDR` in GDB.

## refs

[Newest 'radare2' Questions](https://stackoverflow.com/questions/tagged/radare2)

[gdb list command? #1783](https://github.com/radareorg/radare2/issues/1783)
[Radare2 "pd" command](https://stackoverflow.com/questions/62319299/radare2-pd-command) - disassembly or opcodes
[How to dump function's disassembly using r2pipe](https://stackoverflow.com/questions/55402547/how-to-dump-functions-disassembly-using-r2pipe)
[How to make radare2 work for a large binary?](https://reverseengineering.stackexchange.com/questions/16112/how-to-make-radare2-work-for-a-large-binary/16115)

A journey into Radare 2: [Part 1](https://www.megabeets.net/a-journey-into-radare-2-part-1/), [Part 2](https://www.megabeets.net/a-journey-into-radare-2-part-2/)

[radare2逆向笔记](https://www.cnblogs.com/pannengzhi/p/play-with-radare2.html) - crackme0x00
[Using Radare2 to patch a binary](https://rderik.com/blog/using-radare2-to-patch-a-binary/)
[Understanding buffer overflows using Radare2](https://rderik.com/blog/understanding-buffer-overflows-using-radare2/)
