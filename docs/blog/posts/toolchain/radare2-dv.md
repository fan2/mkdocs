---
title: radare2 d/v modules - debug/visual
authors:
  - xman
date:
    created: 2023-10-02T18:00:00
categories:
    - toolchain
comments: true
---

So far, we've combed through the [basics - expr](./radare2-expr.md), [a module - analysis](./radare2-a.md) and [i/p modules - info/print](./radare2-ip.md).

In this article, I'll give an overview of the `d` and `v` modules:

1. `d`: Debugging module is dedicated to dynamic analysis. Support viewing registers, setting breakpoints, controlling program running process(continue, step), etc.
2. `v`: Visual mode is a user-friendly alternative to the command line that offers a variety of visualization features.

<!-- more -->

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

### dp - dump process

`dp`: list current pid and children
`dpq`: same as `dp`. just show the current process id
`dpe`: show path to executable

### dm - dump memory

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

Speaking of *libc*, a popular task for binary exploitation is to find the address of a specific symbol in a library. With this information in hand, you can build, for example, an exploit which uses ROP. This can be achieved using the `dmi` command. So if we want, for example, to find the address of [system](https://github.com/lattera/glibc/blob/master/sysdeps/posix/system.c) in the loaded *libc*, we can simply execute the following command:

```bash
[0x00400898]> dmi libc system ~system
385  0x00046dc4 0xffff9c326dc4 GLOBAL FUNC 40        __libc_system
1445 0x00046dc4 0xffff9c326dc4 WEAK   FUNC 40        system
2686 0x00122b10 0xffff9c402b10 GLOBAL FUNC 120       svcerr_systemerr
```

### dr - dump registers

See `ar` - Analysis Registers.

```bash
[0x000000000000]> dr?
Usage: dr  Registers commands
| dr                   show 'gpr' registers
| dr=                  show registers in columns

| dr?<register>        show value of given register
| dr??                 same as dr?`drp~=[0]+`

| dri                  show inverse registers dump (sorted by value)
| drl[j]               list all register names
| dro                  show previous (old) values of registers
| drp[?]               display current register profile
| drr                  show registers references (telescoping)
| drs[?]               stack register states
| drt[?]               show all register types
| drw <hexnum>         set contents of the register arena
```

Overview register file:

`drt[?]`: show all register types, e.g., `drt gpr 64`
`drp[?]`: display current register profile
`drl[j]`: list all register names, one per line
`dr`: show 'gpr' registers, one per line
`dr=`: show registers in columns, same as `show-compact-regs` in pwndbg
`dri`: show inverse registers dump (sorted by value)
`dr??`: list all reg roles alias names and values
`drr`: show registers references (telescoping)

Show content of specified register:

```bash
[0xaaaadec30754]> dr?pc # ?v PC
0xaaaadec30754
[0xaaaadec30754]> dr?BP # ?v $r{BP}
0xffffdd6b1210
[0xaaaadec30754]> dr sp # ?v $r:SP
0xffffdd6b1210
[0xaaaab3d30640]> dr x16; dr x17
0xaaaab3d30640
0xffffae99b010
```

View content of register in different modes(64-bit *X* / 32-bit *W*):

```bash
[0xaaaab3d30640]> dr x0
0xffffae9c6180
[0xaaaab3d30640]> dr w0
0xae9c6180
```

Filter register telescoping:

```bash
[0x004008e0]> drr ~BP
BP   x29    0xffffdf541500     [stack] sp,dsp,x29,d29 stack R W 0xffffdf541530
[0x004008e0]> drr ~SP
SP   sp     0xffffdf541500     [stack] sp,dsp,x29,d29 stack R W 0xffffdf541530
[0x004008e0]> drr ~x30
```

Refer to [ARM Push/Pop Stack Modes](../arm/arm-stack-modes.md) to see the r2 expr of armasm subroutine prologue/epilogue.

### db - debug breakpoints

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
| dbs <addr>                toggle breakpoin
| dbi <addr>                show breakpoint index in given offset
| dbi.                      show breakpoint index in current offset
| dbi- <idx>                remove by index

| dbie <idx>                enable breakpoint by index
| dbid <idx>                disable breakpoint by index

| dbw <addr> <r/w/rw>       add watchpoint

| dbt[?]                    show backtrace. See dbt? for more details
```

Add/Disable/Enable breakpoint at specified address:

```bash
[0x000000000000]> db 0xaaaae48e0640
[0x000000000000]> dbd 0xaaaae48e0640
[0x000000000000]> dbe 0xaaaae48e0640
```

After execute `aa` to analyze all, we can set breakpoints by symbol name:

```bash
[0x000000000000]> db entry0
[0x000000000000]> db entry0-$l # above
[0x000000000000]> db main # db sym.main
[0x000000000000]> db sym.main+64 # offset
[0x000000000000]> db sym.func
```

### dc - debug continuation

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
> dcu 0x00400920
> dcu entry0
> dcu main # dcu sym.main
> dcu sym.func
> dcu pc+12 # offset
```

### ds - debug step

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

`dss <num>`: skip <num\> step instructions, waive execution.
`dsu <address>`: almost equivalent to `dcu <address>`.
`ds 3`: equivalent to `dsu pc+12` / `dcu pc+12`.
`dsb`: step back, see [Reverse Debugging](https://book.rada.re/debugger/revdebug.html).

## v Mode

[Radare2 Book: 5. Visual mode](https://book.rada.re/visual_mode/intro.html)

### V - visual mode

Enter visual mode, convenient for disassembly view, based on current address (PC).

```bash
[0x000000000000]> V?
| V  visual mode (Vv = func/var anal, VV = graph mode, ...)
```

- `Ve`: Configure radare the visual way
- `Vp`: Open disassembly in visual mode
- `V!`: Access visual panels
- `Vpp`: Enter visual debugger mode

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

`p`: Cycle/Rotate/Traverse through visual modes.

!!! note "visual modes"

    The Visual mode uses "print modes" which are basically different panels that you can rotate. By default those are:

    > Hexdump panel -> Disassembly panel -> Debugger panel -> Hexadecimal words dump panel -> Hex-less hexdump panel -> Op analysis color map panel -> Annotated hexdump panel -> Hexdump panel -> [...]

    Notice that the top of the panel contains the command which is used.

`.`: seek to PC or entrypoint.

Type `v`, as a combination of `Vv`, will open *func/var analysis* panel.

```bash
.-- functions ----- pdr -------------------------------.
| (a)nalyze (-)delete (x)xrefs (X)refs (j/k) next/prev |
| (r)ename  (c)alls   (d)efine (Tab)disasm (_) hud     |
| (d)efine  (v)ars    (?)help  (:)shell    (q) quit    |
| (s)ignature edit                                     |
'------------------------------------------------------'
```

Type `V`, as a combination of `VV`, will enter Visual Graph mode.

> Use `:command` to execute r2 commands from inside Visual Mode. This is similar to VIM.

Type `!`(equivalent to `:v`) to enter *Visual Panels*.

In any of the `Vv` / `VV` / `:v` modes, press 'q' to exit and return to Visual mode.

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

### v - visual panels

Type `!`(equivalent to `:v`) from Visual mode, or type `v` from r2 console to enter Visual Panels mode.

> It's sort of GDB's [TUI display mode](../toolchain/gdb/6-gdb-debug-assembly.md) and context mode of gdb-pwndbg.

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

Type `v` again to open *func/var analysis* panel.

The useful Debugger view shows us the Disassembly, Stack and Registers. We can move around the binary via seeking and stepping.

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
| w      shuffle panels around in window mode
| x      show xrefs/refs of current function from/to data/
| X      close current panel
| z      swap current panel with the first one
```

1. `/`: highlight input keyword
2. `Tab`: move the focus to the next panel without changing their position.
3. `p`/`P`: swap current/focus panel with the next/previous one. Something like a first-person view.
4. `Enter`: maximize current panel in zoom mode. Press `Enter` or `q` to quit.
5. `space`: toggle graph / panels.
6. `m`: select the menu panel, use `hjkl` to navigate and `Enter` to choose.
7. `.`: seek to PC or entrypoint.
8. `g`: go/seek to given offset/address, e.g., `g main`, `g sym.func`.
9. `s`/`S`: step in / step over.
10. `c` Cursor is not available for the current(stack) panel?

Type `:` to enter Bottom Command mode, run r2 commands in prompt, e.g., `db`, `dc`.
Press `v`/`q` to exit and return back to Visual Panels mode.

[Radare2 - How to scale panel height in visual panels mode?](https://reverseengineering.stackexchange.com/questions/18846/radare2-how-to-scale-panel-height-in-visual-panels-mode)

Press `w` to enter Window mode:

- `hjkl` to move around (left-down-up-right)
- `HJKL` to resize panels vertically/horizontally

### VV - graph mode

Show call graph of function:

```bash
[0x000000000000]> VV @ sym.func
```

Toggle between disasm and graph with the `space` key.

Type `?` to list all the commands of Visual Graph mode.

```bash
| +/-/0                zoom in/out/default
| . (dot)              center graph to the current node
| , (comma)            toggle graph.few
| =                    toggle graph.layout
| :cmd                 run radare command
| /                    highlight text
| |                    set cmd.gprompt
| >                    show function callgraph (see graph.refs)
| <                    show program callgraph (see graph.refs)
| %                    find in disassembly (pdr~sentence) and navigate to it in graph
| b                    visual browse things
| c                    toggle graph cursor mode
| D                    toggle the mixed graph+disasm mode
| g                    go/seek to given offset
| o([A-Za-z]*)         follow jmp/call identified by shortcut (like ;[oa])
| O                    toggle asm.pseudo and asm.esil
| p/P                  rotate graph modes (normal, display offsets, minigraph, summary)
| q                    back to Visual mode
| R                    randomize colors
| s/S                  step / step over
| tab                  select next node
| TAB                  select previous node
| V                    toggle basicblock / call graphs
| y                    toggle self-adaptive
| Y                    fold current node
```

1. `R`: randomize colors
2. `=q`: clear registers above
3. `,`: toggle graph.few/more
4. `p/P`: toggle between four graph modes
4. `/`: highlight input keyword
5. `D`: toggle/cancel the mixed graph+disasm mode
6. `c`: toggle/cancel graph cursor mode, use `hjkl` to move focus node
7. `g`: go/seek to given offset, e.g., `g main`, `g sym.func`.

`p/P`: Cycle/Rotate/Traverse through graph modes.
Note the label inside square brackets of each node, such as `o[a-z]`, then type `oa` / `ob` / `oc` or `tab` to change central focus.

## refs

[Defeating ioli with radare2](https://dustri.org/b/defeating-ioli-with-radare2.html) - [IOLI-crackme.tar.gz](https://github.com/radareorg/radare2-book/raw/master/src/crackmes/ioli/IOLI-crackme.tar.gz)

[Reverse engineering with radare2](https://artik.blue/reversing)
[Reverse Engineering With Radare2](https://samsymons.com/blog/reverse-engineering-with-radare2-part-1/)
[Radare2 for reverse engineering](https://itnext.io/radare2-for-reverse-engineering-part1-eedf0a47b5cc)

Reverse Engineering With Radare2: [Part 1](https://insinuator.net/2016/08/reverse-engineering-with-radare2-intro/), [Part 2](https://insinuator.net/2016/08/reverse-engineering-with-radare2-part-2/), [Part 3](https://insinuator.net/2016/10/reverse-engineering-with-radare2-part-3/)
Reverse Engineering Using Radare2: [Part 1](https://goggleheadedhacker.com/blog/post/1), [Part 2](https://goggleheadedhacker.com/blog/post/2)
Reverse engineering using Radare2: [Part 1](https://hackyourmom.com/en/servisy/zvorotnij-inzhyniryng-iz-vykorystannyam-radare2/), [Part 2](https://hackyourmom.com/en/servisy/revers-inzhyniryng-ta-skrypty/zvorotnij-inzhyniryng-iz-vykorystannyam-radare2-chastyna-2/)

[Learning AArch64 Exploit Development on iOS with Radare2](https://codemuch.net/posts/armlab-ios-i/)
[Defeating macOS Malware Anti-Analysis Tricks with Radare2](https://www.sentinelone.com/labs/defeating-macos-malware-anti-analysis-tricks-with-radare2/)
[Reverse Engineering Go binaries Using Radare 2 and Python](https://research.ivision.com/reverse-engineering-go-binaries-using-radare-2-and-python.html)
