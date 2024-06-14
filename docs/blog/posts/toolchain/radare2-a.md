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

So far, we've combed through the basic usage of r2, see [previous post](./radare2-basics.md).

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

## flags

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

## refs

[Newest 'radare2' Questions](https://stackoverflow.com/questions/tagged/radare2)

[gdb list command? #1783](https://github.com/radareorg/radare2/issues/1783)
[Radare2 "pd" command](https://stackoverflow.com/questions/62319299/radare2-pd-command) - disassembly or opcodes
[How to dump function's disassembly using r2pipe](https://stackoverflow.com/questions/55402547/how-to-dump-functions-disassembly-using-r2pipe)
[How to make radare2 work for a large binary?](https://reverseengineering.stackexchange.com/questions/16112/how-to-make-radare2-work-for-a-large-binary/16115)
[how to give a name to global varrible in radare2?](https://stackoverflow.com/questions/54950056/how-to-give-a-name-to-global-varrible-in-radare2)
