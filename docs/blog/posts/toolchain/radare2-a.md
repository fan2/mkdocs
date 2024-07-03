---
title: radare2 a module - analysis
authors:
  - xman
date:
    created: 2023-10-02T11:00:00
categories:
    - toolchain
comments: true
---

So far, we've combed through the basic usage of r2, see [basics](./radare2-basics.md) and [expr](./radare2-expr.md).

In this article, I'll give an overview of the `a` module that supports analysis.

<!-- more -->

[Radare2 Book: 8. Analysis](https://book.rada.re/analysis/intro.html)

Code analysis is the process of finding patterns, combining information from different sources and process the disassembly of the program in multiple ways in order to understand and extract more details of the logic behind the code.

Radare2 has many different code analysis techniques implemented under different commands and configuration options, and it's important to understand what they do and how that affects in the final results before going for the default-standard `aaaaa` way because on some cases this can be too slow or just produce false positive results.

As long as the whole functionalities of `r2` are available with the API as well as using commands. This gives you the ability to implement your own analysis loops using any programming language, even with `r2` oneliners, shellscripts, or analysis or core native plugins.

The analysis will show up the *internal* data structures to identify basic blocks, function trees and to extract opcode-level information.

The most common radare2 analysis command sequence is `aa`, which stands for "*analyze all*". That all is referring to all symbols and entry-points. If your binary is stripped you will need to use other commands like `aaa`, `aab`, `aar`, `aac` or so.

Take some time to understand what each command does and the results after running them to find the best one for your needs.

## a

Help on the usage of `a`(analysis) command-class.

```bash
[0x000000000000]> a?
Usage: a  [abdefFghoprxstc] [...]
| a                alias for aai - analysis information
| a:[cmd]          run a command implemented by an analysis plugin (like : for io)
| a*               same as afl*;ah*;ax*
| aa[?]            analyze all (fcns + bbs) (aa0 to avoid sub renaming)
| a8 [hexpairs]    analyze bytes
| ab[?]            analyze basic block
| ac[?]            manage classes
| aC[?]            analyze function call
| ad[?]            analyze data trampoline (wip) (see 'aod' to describe mnemonics)
| ad [from] [to]   analyze data pointers to (from-to)
| ae[?] [expr]     analyze opcode eval expression (see ao)
| af[?]            analyze functions
| aF               same as above, but using anal.depth=1
| ag[?] [options]  draw graphs in various formats
| ah[?]            analysis hints (force opcode size, ...)
| ai [addr]        address information (show perms, stack, heap, ...)
| aj               same as a* but in json (aflj)
| aL[jq]           list all asm/anal plugins (See `e asm.arch=?` and `La[jq]`)
| an[?] [name]     show/rename/create whatever var/flag/function used in current instruction
| ao[?] [len]      analyze Opcodes (or emulate it)
| aO[?] [len]      analyze N instructions in M bytes
| ap               find prelude for current offset
| ar[?]            like 'dr' but for the esil vm. (registers)
| as[?] [num]      analyze syscall using dbg.reg
| av[?] [.]        show vtables
| avg[?] [.]       manage global variables
| ax[?]            manage refs/xrefs (see also afx?)
```

## aa

`aa`: analyze all (fcns + bbs).

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
```

`aaa`: autoname functions after aa (see `afna`).

```bash
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

## af

analyze functions.

```bash
[0x000000000000]> af?
Usage: af
| af ([name]) ([addr])                     analyze functions (start at addr or $$)
| af+ addr name [type] [diff]              hand craft a function (requires afb+)
| af- [addr]                               clean all function analysis data (or function at addr)
| afa                                      analyze function arguments in a call (afal honors dbg.funcarg)
| afB 16                                   set current function as thumb (change asm.bits)
| afb[?] [addr]                            List basic blocks of given function
| afb+ fcnA bbA sz [j] [f] ([t]( [d]))     add bb to function @ fcnaddr
| afbF([0|1])                              Toggle the basic-block 'folded' attribute
| afc[?] type @[addr]                      set calling convention for function
| afC[lc] ([addr])@[addr]                  calculate the Cycles (afC) or Cyclomatic Complexity (afCc)
| afd[addr]                                show function + delta for given offset
| afF[1|0|]                                fold/unfold/toggle
| afi [addr|fcn.name]                      show function(s) information (verbose afl)
| afj [tableaddr] [elem_sz] [count] [seg]  analyze function jumptable (adding seg to each elem)
| afl[?] [ls*] [fcn name]                  list functions (addr, size, bbs, name) (see afll)
| afm name                                 merge two functions
| afM name                                 print functions map
| afn[?] name [addr]                       rename name for function at address (change flag too)
| afna                                     suggest automatic name for current offset
| afo[?j] [fcn.name]                       show address for the function name or current offset
| afr ([name]) ([addr])                    analyze functions recursively
| afs[?] ([fcnsign])                       get/set function signature at current address (afs! uses cfg.editor)
| afS[stack_size]                          set stack frame size for function at current address
| aft[?]                                   type matching, type propagation
| afu addr                                 resize and analyze function from current address until addr
| afv[absrx]?                              manipulate args, registers and variables in function
| afx[m]                                   list function references, subsumes pifc
```

`af+ addr name [type] [diff]`: hand craft a function (requires `afb+`)
`af- [addr]`: clean all function analysis data (or function at addr)
`afn[?] name [addr]`: rename name for function at address (change *flag* too). In visual mode, use `dr` instead.
`afo[?j] [fcn.name]`: show address for the function name or current offset

For example, grep symbol `__libc_start_main` in libc:

```bash
[0x004005c0]> dmi libc ~__libc_start_main
659  0x00027434 0xffff86567434 GLOBAL FUNC 348       __libc_start_main
660  0x00027434 0xffff86567434 GLOBAL FUNC 348       __libc_start_main
[0x004005c0]> pd 40 @ 0xffff86567434
   x10 + 142292           0xffff86567434      fd7bbaa9       stp x29, x30, [sp, -0x60]!
   x10 + 142296           0xffff86567438      fd030091       mov x29, sp
   x10 + 142300           0xffff8656743c      f35301a9       stp x19, x20, [sp, 0x10]
   x10 + 142304           0xffff86567440      f403012a       mov w20, w1
   x10 + 142308           0xffff86567444      f30302aa       mov x19, x2
   [...snip...]
```

Try to show address for the function name:

```bash
[0x004005c0]> afo __libc_start_main
[0x004005c0]>
[0x004005c0]> ?w __libc_start_main
__libc_start_main
```

Hand craft function `__libc_start_main`:

```bash
[0x004005c0]> af+ 0xffff86567434 __libc_start_main
[0x004005c0]> ?w __libc_start_main # dumb afo still mutes
/usr/lib/aarch64-linux-gnu/libc.so.6 __libc_start_main library R X 'stp x29, x30, [sp, -0x60]!' 'libc.so.6'
[0x004005c0]> pd 40 @ 0xffff86567434
┌ 0: int __libc_start_main (func main, int argc, char **ubp_av, func init, func fini, func rtld_fini, void *stack_end);
   __libc_start_main + 0              0xffff86567434      fd7bbaa9       stp x29, x30, [sp, -0x60]!
   __libc_start_main + 4              0xffff86567438      fd030091       mov x29, sp
   __libc_start_main + 8              0xffff8656743c      f35301a9       stp x19, x20, [sp, 0x10]
   __libc_start_main + 12             0xffff86567440      f403012a       mov w20, w1
   __libc_start_main + 16             0xffff86567444      f30302aa       mov x19, x2
   [...snip...]
```

The newly crafted function is also added to flagspace functions.

```bash
[0x004005c0]> fs functions ; f ~__libc_start_main
0xffff86567434 0 __libc_start_main
```

### afv

Function variables manipulation.

```bash
[0x004008e0]> afv?
Usage: afv[rbs]   Function variables manipulation
| afv*                          output r2 command to add args/locals to flagspace
| afv-([name])                  remove all or given var
| afv=                          list function variables and arguments with disasm refs
| afva                          analyze function arguments/locals
| afvb[?]                       manipulate bp based arguments/locals
| afvd name                     output r2 command for displaying the value of args/locals in the debugger
| afvf                          show BP relative stackframe variables
| afvn [new_name] ([old_name])  rename argument/local
| afvr[?]                       manipulate register based arguments
| afvR [varname]                list addresses where vars are accessed (READ)
| afvs[?]                       manipulate sp based arguments/locals
| afvt [name] [new_type]        change type for given argument/local
| afvW [varname]                list addresses where vars are accessed (WRITE)
| afvx                          show function variable xrefs (same as afvR+afvW)
```

## ag

Type `?*~...` and ++enter++ , then do an instant apropos search with the keyword `graph`.

```bash
[0x004008e0]> ?*~...

[...snip...]

# type "graph" to apropos search
0> graph|
 - | V                       visual mode (Vv = func/var anal, VV = graph mode, ...)
   | /g[g] [from]                 find all graph paths A to B (/gg follow jumps, see search.count and anal.depth)
   | ag[?] [options]  draw graphs in various formats
   | aarr       analyze all function reference graph to find more functions (EXPERIMENTAL)
   | acg                                                        print inheritance ascii graph
   | aeg [expr]               esil data flow graph
   | aegf [expr] [register]   esil data flow graph filter
   Usage: ag<graphtype><format> [addr]
   Graph commands:
   | aga[format]             data references graph
   | agA[format]             global data references graph
   | agc[format]             function callgraph
   | agC[format]             global callgraph
   | agd[format] [fcn addr]  diff graph
   | agf[format]             basic blocks function graph
   | agi[format]             imports graph
   | agr[format]             references graph
   | agR[format]             global references graph
   | agx[format]             cross references graph
   | agg[format]             custom graph
   | agt[format]             tree map graph
   | ag-                     clear the custom graph
   | agn[?] title body       add a node to the custom graph
   | age[?] title1 title2    add an edge to the custom graph
   | d                       graphviz dot
   | g                       graph Modelling Language (gml)
   | w [path]                write to path or display graph image (see graph.gv.format)
   | axg[j*] [addr]  show xrefs graph to reach current function
   | axfg [addr]  display commands to generate graphs according to the xrefs
   | axtg ([addr])  display commands to generate graphs according to the xrefs
   | cg[?][afo] [file]        compare graphdiff current file and find similar functions
   Usage: cg  Graph compare
   | cgo        opcode-bytes code graph diff
   | dmhbg [bin_num]                              Display double linked list graph of main_arena's bin [Under developemnt]
   | dmhg [malloc_state]                          Display heap graph of a particular arena
   | dmhg                                         Display heap graph of heap segment
   | dtg                                graph call/ret trace
   | dtg*                               graph in agn/age commands. use .dtg*;aggi for visual
   | f= [glob]                 list range bars graphics with flag offsets and sizes
   | fg[*] ([prefix])          construct a graph with the flag names
   | icg [str]          List classes hirearchy graph with agn/age (match str if provided)
   | pdr              recursive disassemble across the function graph
   | pdr.             recursive disassemble across the function graph (from current basic block)
   | pfd.fmt_name               show data using named format as graphviz commands
   | txg           render the type xrefs graph (usage .txg;aggv)
```

Type `ag?` to see usage of *Graph commands* and *Output formats*.

```bash
[0x000000000000]> ag?
Usage: ag<graphtype><format> [addr]
Graph commands:

[...snip...]

Output formats:

[...snip...]

```

## flags

After the analysis, radare2 associates names to interesting offsets in the file such as Sections, Function, Symbols, and Strings. Those names are called *`flags`*. Flags can be grouped into *`flag spaces`*. A flag space is a namespace for flags of similar characteristics or type. To list the flag spaces run `fs`.

```bash
[0x004005c0]> f?
Usage: f [?] [flagname]   # Manage offset-name flags
| f                         list flags (will only list flags from selected flagspaces)
| f?flagname                check if flag exists or not, See ?? and ?!
| f. [*[*]]                 list local per-function flags (*) as r2 commands
| f.blah=$$+12              set local function label named 'blah' (f.blah@$$+12)
| f.-blah                   delete local function label named 'blah'
| f. fname                  list all local labels for the given function
| f,                        table output for flags
| f*                        list flags in r commands
| f name 12 @ 33            set flag 'name' with length 12 at offset 33
| f name = 33               alias for 'f name @ 33' or 'f name 1 33'
| f name 12 33 [cmt]        same as above + optional comment
| f-.blah@fcn.foo           delete local label from function at current seek (also f.-)
| f--                       delete all flags and flagspaces (deinit)
| f+name 12 @ 33            like above but creates new one if doesnt exist
| f-name                    remove flag 'name'
| f-@addr                   remove flag at address expression
| f= [glob]                 list range bars graphics with flag offsets and sizes
| fa [name] [alias]         alias a flag to evaluate an expression
| fb [addr]                 set base address for new flags
| fb [addr] [flag*]         move flags matching 'flag' to relative addr
| fc[?][name] [color]       set color for given flag
| fC [name] [cmt]           set comment for given flag
| fd[?] addr                return flag+delta
| fe [name]                 create flag name.#num# enumerated flag. (f.ex: fe foo @@= 1 2 3 4)
| fe-                       resets the enumerator counter
| ff ([glob])               distance in bytes to reach the next flag (see sn/sp)
| fi [size] | [from] [to]   show flags in current block or range
| fg[*] ([prefix])          construct a graph with the flag names
| fj                        list flags in JSON format
| fl (@[flag]) [size]       show or set flag length (size)
| fla [glob]                automatically compute the size of all flags matching glob
| fm addr                   move flag at current offset to new address
| fn                        list flags displaying the real name (demangled)
| fnj                       list flags displaying the real name (demangled) in JSON format
| fN                        show real name of flag at current address
| fN [[name]] [realname]    set flag real name (if no flag name current seek one is used)
| fo                        show fortunes
| fO [glob]                 flag as ordinals (sym.* func.* method.*)
| fr [[old]] [new]          rename flag (if no new flag current seek one is used)
| fR[?] [from] [to] [mask]  relocate all flags matching from&~m
| fs[?]+-*                  manage flagspaces
| ft[?]*                    flag tags, useful to find all flags matching some words
| fV[*-] [nkey] [offset]    dump/restore visual marks (mK/'K)
| fx[d]                     show hexdump (or disasm) of flag:flagsize
| fq                        list flags in quiet mode
| fz[?][name]               add named flag zone -name to delete. see fz?[name]
```

`f name 12 @ 33`: set flag 'name' with length 12 at offset 33
`f name = 33`: alias for 'f name @ 33' or 'f name 1 33'
`f name 12 33 [cmt]`: same as above + optional comment
`f+name 12 @ 33`: like above but creates new one if doesnt exist
`f-name`: remove flag 'name'
`f-@addr`: remove flag at address expression
`fr [[old]] [new]`: rename flag (if no new flag current seek one is used)

Continuing with the above `af+` example, there's a branch instruction at offset 148 of `__libc_start_main`:

```bash
[0x004005c0]> pd 1 @ __libc_start_main+148
   __libc_start_main + 148            0xffff865674c8      b2ffff97       bl 0xffff86567390
```

Set flag `__libc_start_call_main` with default length 1 at the branch target:

```bash
[0x004005c0]> f __libc_start_call_main=0xffff86567390

[0x004005c0]> pd 1 @ __libc_start_main+148
   __libc_start_main + 148            0xffff865674c8      b2ffff97       bl __libc_start_call_main
```

Try to disassemble 0xffff86567390, the `asm.symbol` column now will show offset based on the flag.

> Pure flag is more like a label. It doesn't do function analysis yet, so there's no prototype or afv.

```bash
[0x004005c0]> pd 32 @ 0xffff86567390
   __libc_start_call_main + 0              ;-- __libc_start_call_main:
   __libc_start_call_main + 0              0xffff86567390      fd7bafa9       stp x29, x30, [sp, -0x110]!
   __libc_start_call_main + 4              0xffff86567394      830b00f0       adrp x3, 0xffff866da000
   __libc_start_call_main + 8              0xffff86567398      fd030091       mov x29, sp
   [...snip...]
```

### fs

`fs`: manage flagspaces.

```bash
[0x004005c0]> fs?
Usage: fs [*] [+-][flagspace|addr]   # Manage flagspaces
| fs            display flagspaces
| fs*           display flagspaces as r2 commands
| fsj           display flagspaces in JSON
| fs *          select all flagspaces
| fs flagspace  select flagspace or create if it doesn't exist
| fs-flagspace  remove flagspace
| fs-*          remove all flagspaces
| fs+foo        push previous flagspace and set
| fs-           pop to the previous flagspace
| fs-.          remove the current flagspace
| fsq           list flagspaces in quiet mode
| fsm [addr]    move flags at given address to the current flagspace
| fss           display flagspaces stack
| fss*          display flagspaces stack in r2 commands
| fssj          display flagspaces stack in JSON
| fsr newname   rename selected flagspace
```

We can choose a flag space using `fs <flagspace>` and print the flags it contains using `f`.

```bash
[0x004005c0]> fs
    0 * classes
    5 * format
  180 * functions
    7 * imports
   67 * registers
    7 * relocs
   29 * sections
   10 * segments
    5 * strings
   37 * symbols
```

List flags from selected flagspace strings:

```bash
[0x004005c0]> # fs strings; f
[0x004005c0]> fs imports; f
0x00400520 16 sym.imp.__libc_start_main
0x00400530 16 loc.imp.__gmon_start__
0x00400540 16 sym.imp.abort
0x00400550 16 sym.imp.puts
0x00400560 16 sym.imp.strcmp
0x00400570 16 sym.imp.__isoc99_scanf
0x00400580 16 sym.imp.strcpy
[0x004005c0]> ?v sym.imp.puts
0x400550
[0x004005c0]> afo sym.imp.puts
0x00400550
```

## CC

Type `?*~...` and ++enter++ , then do instant apropos search `comment`.

```bash
[0x004005c0]> C?
Usage: C[-LCvsdfm*?][*?] [...]   # Metadata management
| CC! [@addr]                         edit comment with $EDITOR
| CC[?] [-] [comment-text] [@addr]    add/remove comment
| CC.[addr]                           show comment in current address
| CCa[+-] [addr] [text]               add/remove comment at given address
| Ct.[@addr]                          show comment at current or specified address
```

`CC`: Comments Management.

```bash
[0x004005c0]> CC?
Usage: CC[-+!*au] [base64:..|str] @ addr
| CC!                     edit comment using cfg.editor (vim, ..)
| CC [text]               append comment at current address
| CC                      list all comments in human friendly form
| CC*                     list all comments in r2 commands
| CC+ [text]              append comment at current address
| CC, [table-query]       list comments in table format
| CCF [file]              show or set comment file
| CC- @ cmt_addr          remove comment at given address
| CC.                     show comment at current offset
| CCf                     list comments in function
| CCf-                    delete all comments in current function
| CCu base64:AA== @ addr  add comment in base64
| CCu good boy @ addr     add good boy comment at given address
```

`Ct`: Manage comments for variable types.

```bash
[0x004005c0]> Ct?
Usage: Ct [.|-] [@ addr]   # Manage comments for variable types
| Ct                        list all variable type comments
| Ct comment-text [@ addr]  place comment at current or specified address
| Ct. [@ addr]              show comment at current or specified address
| Ct- [@ addr]              remove comment at current or specified address
```

`fC [name] [cmt]`: set comment for given flag.

### demo

Continuing with the above `f __libc_start_call_main` example.
The instruction `blr x3` at offset +104 will jump to the C main function.

```bash
[0x004005c0]> pd 32 @ 0xffff94b97390

   __libc_start_call_main + 104        │   0xffff94b973f8      60003fd6       blr x3

```

Add a comment for the call main instruction:

```bash
[0x004005c0]> CC b main @ 0xffff94b973f8 # CC b main @ __libc_start_call_main+104
# a=@, save you typing the @ address sign.
[0x004005c0]> # CCa+ 0xffff94b973f8 b main # CCa+ __libc_start_call_main+104 b main
```

To show user comments in disassembly, you should first toggle `e asm.cmt.user`.

```bash
# show user comments even if asm.comments is false
[0x004005c0]> e asm.cmt.user
false
[0x004005c0]> e!asm.cmt.user
```

They type `CC.[addr]` to show comment at the addr.

```bash
# show comment in the address(or based on label offset)
[0x004005c0]> CC.__libc_start_call_main+104 # CC.0xffff94b973f8
b main
```

`pd` again to check the comment for confirmation.

```bash
[0x004005c0]> pd 32 @ 0xffff94b97390

   __libc_start_call_main + 104        │   0xffff94b973f8      60003fd6       blr x3 ; b main

```

Use `CCu` to modify/overwrite existed comment:

```bash
[0x004005c0]> CCu nop then b main @ __libc_start_call_main + 104
```

Finally, you can use `CC-` to remove comment.

```bash
[0x004005c0]> CC- @ 0xffff94b973f8 # CCa- __libc_start_call_main+104
```

You can also use `Ct`/`Ct.`/`Ct-` to place/show/remove comments at specified address for varibales.
It is distinguished from the usual comments by differences in color.

## refs

[Newest 'radare2' Questions](https://stackoverflow.com/questions/tagged/radare2)

[gdb list command? #1783](https://github.com/radareorg/radare2/issues/1783)
[Radare2 "pd" command](https://stackoverflow.com/questions/62319299/radare2-pd-command) - disassembly or opcodes
[How to dump function's disassembly using r2pipe](https://stackoverflow.com/questions/55402547/how-to-dump-functions-disassembly-using-r2pipe)
[How to make radare2 work for a large binary?](https://reverseengineering.stackexchange.com/questions/16112/how-to-make-radare2-work-for-a-large-binary/16115)
[how to give a name to global varrible in radare2?](https://stackoverflow.com/questions/54950056/how-to-give-a-name-to-global-varrible-in-radare2)
