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

So far, we've combed through the [basics - expr](./radare2-expr.md) and [a module - analysis](./radare2-a.md).

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
[0x000000000000]> !rabin2 -s test-gdb
[0x000000000000]> is?
Usage: is [*hjq]  List symbols from current selected binary
| is,[table-query]  list symbols in table using given expression
| is.               current symbol
| is*               same as above, but in r2 commands
| isj               in json format
```

List (libc) imports: `is~imp`

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
ps @ x0 # psz @ x0 # pfz @ x0
# specify estimated length
psz 48 @ x0
# explore what is there
?w x0
```

### pv - print value

```bash
[0xaaaab3ce0634]> pv?
Usage: pv[1248z][udj]  Print value(s) given size and endian (u for unsigned, d for signed decimal, j for json)
| pv                    print bytes based on asm.bits
| pv1[udj]              print 1 byte in memory
| pv2[udj]              print 2 bytes in memory
| pv4[udj]              print 4 bytes in memory
| pv8[udj]              print 8 bytes in memory
| pvp[udj]              print 4 or 8 bytes depending on asm.bits
| pve [1234] ([bsize])  print value with any endian (reorder bytes with the 1234 order)
| pvz                   print value as string (alias for ps)
```

Print 4*1 bytes in memory.

```bash
[0xaaaab3ce0634]> pv1 4
0x11
0xe6
0x47
0xf9

# 8bit hexpair list of 4 bytes
[0xaaaab3ce0634]> p8 4
11e647f9
```

Print 1*4 bytes in memory, interpreted according to endianess.

```bash
[0xaaaab3ce0634]> pv4
0xf947e611
```

Run `!echo $R2_ENDIAN`, `e arch.endian` or `e cfg.bigendian` to get the current endianess.

Specify endianess(byte-order) to change the interpretation/representation:

```bash
# interpret dword(4 bytes) as BE, see pfed below
[0xaaaab3ce0634]> pve 1234 4
0xaaaab3ce0634  300304377 (0x11e647f9)
# interpret dword(4 bytes) as LE(default endianess)
[0xaaaab3ce0634]> pve 4321 4
0xaaaab3ce0634  -112728559 (0xf947e611)
```

### pf - print format

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
```

Defining primitive [types](https://book.rada.re/analysis/types.html) requires an understanding of basic `pf` formats, you can find the whole list of format specifier in `pf??`:

```bash
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

# pf4d @ pc-4 will display in array format, see pf4b above

# quiet mode: pv4 4 @ pc-4 or pfq dddd @ pc-4
[0xaaaab3ce0634]> pf dddd @ pc-4
0xaaaab3ce0630 = 0x90000090
0xaaaab3ce0634 = 0xf947e611
0xaaaab3ce0638 = 0x913f2210
0xaaaab3ce063c = 0xd61f0220

# endianness already swapped, just decode it as BE.
$ rasm2 -de -a arm 0xf947e611
$ cstool arm64be 0xf947e611
$ cstool -d arm64be 0xf947e611
```

Add `e` option to swap endian temporally(see rax2 -ke):

```bash
[0xaaaab3ce0634]> pd 1
│           ;-- pc:
│           0xaaaab3ce0634      11e647f9       ldr x17, [x16, 0xfc8]

[0xaaaab3ce0634]> pfed opcode
 opcode : 0xaaaab3ce0634 = 0x11e647f9

[0xaaaab3ce0634]> pf edddd @pc-4
0xaaaab3ce0630 = 0x90000090
0xaaaab3ce0634 = 0x11e647f9
0xaaaab3ce0638 = 0x10223f91
0xaaaab3ce063c = 0x20021fd6
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
[0xaaaab3ce0634]> pxw $l # @ pc
0xaaaab3ce0634  0xf947e611                                   ..G.
[0xaaaab3ce0634]> pxW $l # @ pc
0xaaaab3ce0634 0xf947e611
[0xaaaab3ce0634]> pxW $l*4 # @ pc
0xaaaab3ce0634 0xf947e611
0xaaaac6e50638 0x913f2210
0xaaaac6e5063c 0xd61f0220
0xaaaac6e50640 0xd503201f
```

Dump bitstream to check against instruction opcode specs.

```bash
# bitstream of 32 bits / 4 bytes
[0xaaaab3ce0634]> pb $l*8 # pB $l
00010001111001100100011111111001

# bitstream of next instruction
[0xaaaab3ce0634]> pB $l @ pc+4
00010000001000100011111110010001

# dump bits in hexdump form
[0xaaaab3ce0634]> pxb $l*4 # @ pc
0xaaaab3ce0634 0001_0001  1110_0110  0100_0111  1111_1001  0x11e647f9  ..G.
0xaaaac6e50638 0001_0000  0010_0010  0011_1111  1001_0001  0x10223f91  ."?.
0xaaaac6e5063c 0010_0000  0000_0010  0001_1111  1101_0110  0x20021fd6   ...
0xaaaac6e50640 0001_1111  0010_0000  0000_0011  1101_0101  0x1f2003d5  . ..
```

Suppose old FP = 0xffffdf541530 before main, and `pdf` of main is as follows.

```asm
[0x004008e0]> pdf
            ;-- pc:
┌ 116: int main (int argc, char **argv);
│           ; arg int argc @ x0
│           ; arg char **argv @ x1
│           ; var int64_t var_28h @ sp+0x28
│           0x004008e0 b    fd7bbda9       stp x29, x30, [sp, -0x30]!
│           0x004008e4      fd030091       mov x29, sp
│           0x004008e8      e01f00b9       str w0, [sp, 0x1c]          ; argc
│           0x004008ec      e10b00f9       str x1, [sp, 0x10]          ; argv
```

After the prolog, we can check latest sp/SP and BP/FP:

```bash
# Filter register telescoping: drr ~SP
[0x004008e0]> dr sp # dr?rp # ?v $r:sp # ?v $r{sp}
0xffffdf541500

# Filter register telescoping: drr ~BP
[0x004008e0]> dr x29 # dr BP
0xffffdf541500

# last BP/FP
[0x004008e0]> xQq $w @ sp # pv @ sp
0x0000ffffdf541530

# Calculate the newly opened stack size
[0x004008e0]> ?v `xQq $w @ sp`-`dr sp`
0x30
# Save stack size for future reference
[0x004008e0]> %SIZE=`_` ; %SIZE
0x30

# last X30/LR
[0x004008e0]> xQq $w @ sp+8 # pv @ sp+8
0x0000ffffb7b073fc

# overwrite X30/LR: wv8 0x400550 @ sp+8
# overwrite stack: wv8 0x004005c0 @ sp+16

# Filter register telescoping: drr ~x30
# has not been changed since last call
[0x004008e0]> dr x30
0xffffb7b073fc
```

In the above case, $w*6 = 8\*6 = %SIZE = 0x30/48.

[View elements of the current stack](https://reverseengineering.stackexchange.com/questions/16844/how-to-get-a-nice-stack-view-in-radare2), following the current sp with 8 bytes(quad-words) as step unit.

```bash
# two machine word per line, equivalent to x/32xg $sp in GDB
[0x004008e0]> xq $w*6 @ sp # xq `%SIZE` @ sp
0xffffc8e74ac0  0x0000ffffc8e74af0  0x0000ffff981473fc   .J.......s......
0xffffc8e74ad0  0x0000ffffc8e74c68  0x00000001981473c0   hL.......s......
0xffffc8e74ae0  0x0000ffffc8e74c68  0x000000001819bac0   hL..............

# one machine word per line
# quiet mode: xQq $w*6 @ sp => pv 6 @ sp
[0x004008e0]> xQ $w*6 @ sp # xQ `%SIZE` @ sp
0xffffc8e74ac0 0x0000ffffc8e74af0 x29+48
0xffffc8e74ac8 0x0000ffff981473fc
0xffffc8e74ad0 0x0000ffffc8e74c68 x19
0xffffc8e74ad8 0x00000001981473c0
0xffffc8e74ae0 0x0000ffffc8e74c68 x19
0xffffc8e74ae8 0x000000001819bac0 x0

# show hexword references(Stack Telescoping)
[0x004008e0]> xr $w*6 @ sp # xr `%SIZE` @ sp
0xffffc8e74ac0 0x0000ffffc8e74af0   .J...... @ dsp [stack] stack R W 0xffffc8e74c00
0xffffc8e74ac8 0x0000ffff981473fc   .s...... /usr/lib/aarch64-linux-gnu/libc.so.6 library R X 'bl 0xffff9815cef0' 'libc.so.6'
0xffffc8e74ad0 0x0000ffffc8e74c68   hL...... [stack] x19,d19 stack R W 0xffffc8e751a5
0xffffc8e74ad8 0x00000001981473c0   .s...... 6846444480
0xffffc8e74ae0 0x0000ffffc8e74c68   hL...... [stack] x19,d19 stack R W 0xffffc8e751a5
0xffffc8e74ae8 0x000000001819bac0   ........ 404339392 x0,d0 aaaaaaaaaaa
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

[0x000000000000]> pd @0xaaaae7680754 # pdf @ sym.func
            ;-- func:
            0xaaaae7680754      ff8300d1       sub sp, sp, 0x20
            0xaaaae7680758      e00f00b9       str w0, [sp, 0xc]
            0xaaaae768075c      ff1b00b9       str wzr, [sp, 0x18]
            0xaaaae7680760      ff1f00b9       str wzr, [sp, 0x1c]
            0xaaaae7680764      08000014       b 0xaaaae7680784

            [...snip...]
```

`pdc`: pseudo disassembler output in C-like syntax.

```bash
[0x000000000000]> pdc @ sym.func
WARN: When cfg.debug is set, I refuse to create a fake stack
int sym.func (int x0, int x1) {
    loc_0xaaaae7680754:
        // CALL XREF from main @ 0xaaaacad607fc(x)
        sp = sp - 0x20 // stdio.h:4
        [sp + 0xc] = w0 // arg1
        [sp + 0x18] = 0 // stdio.h:5   The GNU C Library is free software// you can redistribute it and/or // arg1
        [sp + 0x1c] = 0 // stdio.h:6   modify it under the terms of the GNU Lesser General Public // arg1
        goto 0xaaaae7680784

        [...snip...]
```

Or enable config `asm.pseudo` to show pseudo instead of disassembly.

```bash
[0xaaaacad607a0]> e asm.pseudo=true
[0xaaaacad607a0]> pdf @ sym.func
            ; CALL XREF from main @ 0xaaaacad607fc(x)
┌ 76: sym.func (int64_t arg1, int64_t arg_20h);
│           ; arg int64_t arg1 @ x0
│           ; arg int64_t arg_20h @ sp+0x40
│           ; var int64_t var_ch @ sp+0xc
│           ; var int64_t var_18h @ sp+0x18
│           ; var int64_t var_1ch @ sp+0x1c
│           0xaaaacad60754      ff8300d1       sp = sp - 0x20          ; stdio.h:4
│           0xaaaacad60758      e00f00b9       [sp + 0xc] = w0         ; arg1
│           0xaaaacad6075c      ff1b00b9       [sp + 0x18] = 0         ; stdio.h:5   The GNU C Library is free software; you can redistribute it and/or ; arg1
│           0xaaaacad60760      ff1f00b9       [sp + 0x1c] = 0         ; stdio.h:6   modify it under the terms of the GNU Lesser General Public ; arg1
│       ┌─< 0xaaaacad60764      08000014       goto 0xaaaacad60784

        [...snip...]
[0xaaaacad607a0]> e asm.pseudo=false # reset to default
```

Seek to somewhere, then try to disassemble current address:

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

A journey into Radare 2: [Part 1](https://www.megabeets.net/a-journey-into-radare-2-part-1/), [Part 2](https://www.megabeets.net/a-journey-into-radare-2-part-2/)

[radare2逆向笔记](https://www.cnblogs.com/pannengzhi/p/play-with-radare2.html) - crackme0x00
[Using Radare2 to patch a binary](https://rderik.com/blog/using-radare2-to-patch-a-binary/)
[Understanding buffer overflows using Radare2](https://rderik.com/blog/understanding-buffer-overflows-using-radare2/)

[无情剑客Burning](https://www.freebuf.com/author/%E6%97%A0%E6%83%85%E5%89%91%E5%AE%A2Burning?type=article):

- [Radare2静态分析apk](https://cloud.tencent.com/developer/article/1755190)
- [Radare静态分析so文件-ARM64](https://cloud.tencent.com/developer/article/1756806)
- [Radare2和Frida结合实现破解](https://cloud.tencent.com/developer/article/1765439)
