---
title: SRE Toolkit - radare2 modes
authors:
  - xman
date:
    created: 2023-10-02T16:00:00
categories:
    - toolchain
comments: true
---

So far, we've combed through the basic usage of r2, see [previous post](./radare2-basics.md).

In this article, we'll focus on the different modes supported by r2.

<!-- more -->

- [r2 cheatsheet.pdf](https://scoding.de/uploads/r2_cs.pdf)
- [radare2-cheatsheet](https://github.com/historypeats/radare2-cheatsheet)
- [another radare2 cheatsheet](https://gist.github.com/williballenthin/6857590dab3e2a6559d7)

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

### pf

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

### px

Show hexdump of N bytes.

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

For given address <addr\>, try `pdf @addr`/`pd 1 @addr` to detect the symbol/label name.

> Equivalent to `info symbol ADDR` in GDB.

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

| drl[j]               list all register names
| dro                  show previous (old) values of registers
| drp[?]               display current register profile
| drr                  show registers references (telescoping)
| drs[?]               stack register states
| drt[?]               show all register types
| drw <hexnum>         set contents of the register arena
```

!!! example "dr - show registers"

    [0xffffbdb54c40]> dr?pc
    0xffffbdb54c40
    [0xffffbdb54c40]> dr?sp
    0xffffdf34f0b0

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
| dbs <addr>                toggle breakpoin| dbi <addr>                show breakpoint index in givengiven  offset
| dbi.                      show breakpoint index in current offset
| dbi- <idx>                remo by index

| dbie <idx>                enable breakpoint by index
| dbid <idx>                disable breakpoint by index

| dbw <addr> <r/w/rw>       add watchpoint

| dbt[?]                    show backtrace. See dbt? for more details
```

Add breakpoint at specified address:

```bash
[0x000000000000]> db <addr>
[0x000000000000]> db 0xaaaae48e0640
```

After execute `aa` to analyze all, we can set breakpoints by symbol name:

```bash
[0x000000000000]> db entry0
[0x000000000000]> db entry0-$l
[0x000000000000]> db entry0-2*$l
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

> It's sort of GDB's TUI mode and the default context mode of gdb-pwndbg.

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