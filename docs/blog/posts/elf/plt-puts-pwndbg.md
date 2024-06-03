---
title: puts@plt - pwndbg
authors:
    - xman
date:
    created: 2023-06-29T10:00:00
categories:
    - elf
tags:
    - PLT
    - GOT
comments: true
---

[Previously](./plt-puts-analysis.md) we've statically analysed the layout and ingredients of the DYN PIE ELF `a.out`. In particular, we've focused on dynamic sections/symbols and relocation entries.

In this article, we'll take a closer look at how shared dynamic symbols such as `puts` are resolved and relocated at runtime.

<!-- more -->

Run the DYN ELF `a.out` with the `-A` option using [GDB Enhanced Extensions](https://duetorun.com/blog/20200310/7-gdb-enhanced/) [pwndbg](https://github.com/pwndbg/pwndbg).

```bash
$ gdb-pwndbg a.out
Reading symbols from a.out...
(No debugging symbols found in a.out)
pwndbg: loaded 157 pwndbg commands and 48 shell commands. Type pwndbg [--shell | --all] [filter] for a list.
pwndbg: created $rebase, $base, $ida GDB functions (can be used with print/break)

pwndbg>
```

## static analysis

### elfsections

`elf|elfsections`: Prints the section mappings contained in the ELF header.

```bash
pwndbg> elf
0x238 - 0x253  .interp
0x254 - 0x278  .note.gnu.build-id
0x278 - 0x298  .note.ABI-tag
0x298 - 0x2b4  .gnu.hash
0x2b8 - 0x3a8  .dynsym
0x3a8 - 0x43a  .dynstr
0x43a - 0x44e  .gnu.version
0x450 - 0x480  .gnu.version_r
0x480 - 0x540  .rela.dyn
0x540 - 0x5b8  .rela.plt
0x5b8 - 0x5d0  .init
0x5d0 - 0x640  .plt
0x640 - 0x77c  .text
0x77c - 0x790  .fini
0x790 - 0x7a6  .rodata
0x7a8 - 0x7e4  .eh_frame_hdr
0x7e8 - 0x894  .eh_frame
0x10d90 - 0x10d98  .init_array
0x10d98 - 0x10da0  .fini_array
0x10da0 - 0x10f90  .dynamic
0x10f90 - 0x11000  .got
0x11000 - 0x11010  .data
0x11010 - 0x11018  .bss
```

`info target|files` -- Names of targets and files being debugged.

```bash
pwndbg> info target
Symbols from "/home/pifan/Projects/cpp/a.out".
Local exec file:
    `/home/pifan/Projects/cpp/a.out', file type elf64-littleaarch64.
    Entry point: 0x640
    0x0000000000000238 - 0x0000000000000253 is .interp
    0x0000000000000254 - 0x0000000000000278 is .note.gnu.build-id
    0x0000000000000278 - 0x0000000000000298 is .note.ABI-tag
    0x0000000000000298 - 0x00000000000002b4 is .gnu.hash
    0x00000000000002b8 - 0x00000000000003a8 is .dynsym
    0x00000000000003a8 - 0x000000000000043a is .dynstr
    0x000000000000043a - 0x000000000000044e is .gnu.version
    0x0000000000000450 - 0x0000000000000480 is .gnu.version_r
    0x0000000000000480 - 0x0000000000000540 is .rela.dyn
    0x0000000000000540 - 0x00000000000005b8 is .rela.plt
    0x00000000000005b8 - 0x00000000000005d0 is .init
    0x00000000000005d0 - 0x0000000000000640 is .plt
    0x0000000000000640 - 0x000000000000077c is .text
    0x000000000000077c - 0x0000000000000790 is .fini
    0x0000000000000790 - 0x00000000000007a6 is .rodata
    0x00000000000007a8 - 0x00000000000007e4 is .eh_frame_hdr
    0x00000000000007e8 - 0x0000000000000894 is .eh_frame
    0x0000000000010d90 - 0x0000000000010d98 is .init_array
    0x0000000000010d98 - 0x0000000000010da0 is .fini_array
    0x0000000000010da0 - 0x0000000000010f90 is .dynamic
    0x0000000000010f90 - 0x0000000000011000 is .got
    0x0000000000011000 - 0x0000000000011010 is .data
    0x0000000000011010 - 0x0000000000011018 is .bss
```

### puts@plt

`plt` -- Prints any symbols found in the `.plt` section if it exists.

```bash
pwndbg> plt
Section .plt 0x5d0-0x640:
0x5f0: __libc_start_main@plt
0x600: __cxa_finalize@plt
0x610: __gmon_start__@plt
0x620: abort@plt
0x630: puts@plt
```

[Previously](./plt-puts-analysis.md), we've statically disassembled the `.plt` section using `objdump` command.

```bash
pwndbg> !objdump -j .plt -d a.out
Disassembly of section .plt:

00000000000005d0 <.plt>:
 5d0:    a9bf7bf0     stp    x16, x30, [sp, #-16]!
 5d4:    90000090     adrp    x16, 10000 <__FRAME_END__+0xf770>
 5d8:    f947d211     ldr    x17, [x16, #4000]
 5dc:    913e8210     add    x16, x16, #0xfa0
 5e0:    d61f0220     br    x17
 5e4:    d503201f     nop
 5e8:    d503201f     nop
 5ec:    d503201f     nop

[...snip...]

0000000000000630 <puts@plt>:
 630:    90000090     adrp    x16, 10000 <__FRAME_END__+0xf770>
 634:    f947e611     ldr    x17, [x16, #4040]
 638:    913f2210     add    x16, x16, #0xfc8
 63c:    d61f0220     br    x17
```

As we can see from the above assembly, `0xfc8` is the offset of `puts` in `.rela.plt` entries of `readelf -r a.out` and relocation records of `objdump -R a.out` / `rabin2 -R a.out`.

BTW, before debugging, we can use `disassemble` or `x/i` to disassemble the instructions within the inactive ELF.

```bash
# inspect the address of the symbol
pwndbg> info addr puts@plt
Symbol "puts@plt" is at 0x630 in a file compiled without debugging.
# disassemble specified location within ELF image.
pwndbg> disassemble 0x630
Dump of assembler code for function puts@plt:
   0x0000000000000630 <+0>:	adrp	x16, 0x10000
   0x0000000000000634 <+4>:	ldr	x17, [x16, #4040]
   0x0000000000000638 <+8>:	add	x16, x16, #0xfc8
   0x000000000000063c <+12>:	br	x17
End of assembler dump.
```

## ld - starti

`starti`: Start the debugged program stopping at the first instruction.

```bash
pwndbg> starti
Starting program: /home/pifan/Projects/cpp/a.out

Program stopped.
0x0000fffff7fd9c40 in _start () from /lib/ld-linux-aarch64.so.1

─────────────────────────────[ DISASM / aarch64 / set emulate on ]─────────────────────────────
 ► 0xfffff7fd9c40 <_start>               bti    c
   0xfffff7fd9c44 <_start+4>             mov    x0, sp     X0 => 0xfffffffff2f0 ◂— 1
   0xfffff7fd9c48 <_start+8>             bl     #_dl_start                  <_dl_start>

   0xfffff7fd9c4c <_start+12>            mov    x21, x0
   0xfffff7fd9c50 <_dl_start_user>       ldr    x1, [sp]
   0xfffff7fd9c54 <_dl_start_user+4>     add    x2, sp, #8
   0xfffff7fd9c58 <_dl_start_user+8>     adrp   x4, #_rtld_global+4032
   0xfffff7fd9c5c <_dl_start_user+12>    ldr    w4, [x4, #0x2e4]
   0xfffff7fd9c60 <_dl_start_user+16>    cmp    w4, #0
   0xfffff7fd9c64 <_dl_start_user+20>    b.eq   #_dl_start_user+96          <_dl_start_user+96>

   0xfffff7fd9c68 <_dl_start_user+24>    sub    x1, x1, x4
───────────────────────────────────────────[ STACK ]───────────────────────────────────────────
```

### status info

`getfile` -- Gets the current file.

```bash
pwndbg> getfile
'/home/pifan/Projects/cpp/a.out'
```

`info program`: Execution status of the program.

```bash
pwndbg> i prog
    Using the running image of child process 202400.
Program stopped at 0xfffff7fd9c40.
Type "info stack" or "info registers" for more information.
```

`piebase` -- Calculate VA of RVA from PIE base.

```bash
pwndbg> piebase
Calculated VA from /home/pifan/Projects/cpp/a.out = 0xaaaaaaaa0000
```

### modules

`info sharedlibrary|dll`: Status of loaded shared object libraries.

```bash
pwndbg> i share
From                To                  Syms Read   Shared Object Library
0x0000fffff7fc3c40  0x0000fffff7fe20a4  Yes         /lib/ld-linux-aarch64.so.1
```

`linkmap` -- Show the state of the Link Map.

```bash
pwndbg> linkmap
Node Objfile Load Bias Dynamic Segment
```

`vmmap` -- Print virtual memory map pages.

```bash
pwndbg> vmmap
LEGEND: STACK | HEAP | CODE | DATA | RWX | RODATA
             Start                End Perm     Size Offset File
    0xaaaaaaaa0000     0xaaaaaaaa1000 r-xp     1000      0 /home/pifan/Projects/cpp/a.out
    0xaaaaaaab0000     0xaaaaaaab2000 rw-p     2000      0 /home/pifan/Projects/cpp/a.out
    0xfffff7fc2000     0xfffff7fed000 r-xp    2b000      0 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
    0xfffff7ff9000     0xfffff7ffb000 r--p     2000      0 [vvar]
    0xfffff7ffb000     0xfffff7ffc000 r-xp     1000      0 [vdso]
    0xfffff7ffc000     0xfffff8000000 rw-p     4000  2a000 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
    0xfffffffdf000    0x1000000000000 rw-p    21000      0 [stack]
```

Check the target files being debugged, the addresses of the entry point and the sections have been adapted to the runtime vaddr.

As you can see, some new sections of system-supplied *DSO* and */lib/ld-linux-aarch64.so.1* have appeared.

??? info "starti - info target"

    ```bash
    pwndbg> i target
    Symbols from "/home/pifan/Projects/cpp/a.out".
    Native process:
        Using the running image of child process 210208.
        While running this, GDB does not access memory from...
    Local exec file:
        `/home/pifan/Projects/cpp/a.out', file type elf64-littleaarch64.
        Entry point: 0xaaaaaaaa0640
        0x0000aaaaaaaa0238 - 0x0000aaaaaaaa0253 is .interp
        0x0000aaaaaaaa0254 - 0x0000aaaaaaaa0278 is .note.gnu.build-id
        0x0000aaaaaaaa0278 - 0x0000aaaaaaaa0298 is .note.ABI-tag
        0x0000aaaaaaaa0298 - 0x0000aaaaaaaa02b4 is .gnu.hash
        0x0000aaaaaaaa02b8 - 0x0000aaaaaaaa03a8 is .dynsym
        0x0000aaaaaaaa03a8 - 0x0000aaaaaaaa043a is .dynstr
        0x0000aaaaaaaa043a - 0x0000aaaaaaaa044e is .gnu.version
        0x0000aaaaaaaa0450 - 0x0000aaaaaaaa0480 is .gnu.version_r
        0x0000aaaaaaaa0480 - 0x0000aaaaaaaa0540 is .rela.dyn
        0x0000aaaaaaaa0540 - 0x0000aaaaaaaa05b8 is .rela.plt
        0x0000aaaaaaaa05b8 - 0x0000aaaaaaaa05d0 is .init
        0x0000aaaaaaaa05d0 - 0x0000aaaaaaaa0640 is .plt
        0x0000aaaaaaaa0640 - 0x0000aaaaaaaa077c is .text
        0x0000aaaaaaaa077c - 0x0000aaaaaaaa0790 is .fini
        0x0000aaaaaaaa0790 - 0x0000aaaaaaaa07a6 is .rodata
        0x0000aaaaaaaa07a8 - 0x0000aaaaaaaa07e4 is .eh_frame_hdr
        0x0000aaaaaaaa07e8 - 0x0000aaaaaaaa0894 is .eh_frame
        0x0000aaaaaaab0d90 - 0x0000aaaaaaab0d98 is .init_array
        0x0000aaaaaaab0d98 - 0x0000aaaaaaab0da0 is .fini_array
        0x0000aaaaaaab0da0 - 0x0000aaaaaaab0f90 is .dynamic
        0x0000aaaaaaab0f90 - 0x0000aaaaaaab1000 is .got
        0x0000aaaaaaab1000 - 0x0000aaaaaaab1010 is .data
        0x0000aaaaaaab1010 - 0x0000aaaaaaab1018 is .bss
        0x0000fffff7fc21c8 - 0x0000fffff7fc21ec is .note.gnu.build-id in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc21f0 - 0x0000fffff7fc2330 is .hash in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2330 - 0x0000fffff7fc248c is .gnu.hash in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2490 - 0x0000fffff7fc2868 is .dynsym in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2868 - 0x0000fffff7fc2b22 is .dynstr in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2b22 - 0x0000fffff7fc2b74 is .gnu.version in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2b78 - 0x0000fffff7fc2c1c is .gnu.version_d in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2c20 - 0x0000fffff7fc3b20 is .rela.dyn in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc3b20 - 0x0000fffff7fc3b98 is .rela.plt in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc3ba0 - 0x0000fffff7fc3c10 is .plt in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc3c40 - 0x0000fffff7fe20a4 is .text in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fe20a8 - 0x0000fffff7fe84e4 is .rodata in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fe84e4 - 0x0000fffff7fe84e5 is .stapsdt.base in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fe84e8 - 0x0000fffff7fe8de4 is .eh_frame_hdr in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fe8de8 - 0x0000fffff7fec3b4 is .eh_frame in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffc960 - 0x0000fffff7ffc968 is .init_array in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffc968 - 0x0000fffff7ffde20 is .data.rel.ro in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffde20 - 0x0000fffff7ffdfb0 is .dynamic in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffdfb0 - 0x0000fffff7ffdfe8 is .got in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffdfe8 - 0x0000fffff7ffe028 is .got.plt in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffe028 - 0x0000fffff7fff1c8 is .data in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fff1c8 - 0x0000fffff7fff370 is .bss in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffb0e8 - 0x0000fffff7ffb114 is .hash in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb118 - 0x0000fffff7ffb1a8 is .dynsym in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb1a8 - 0x0000fffff7ffb21f is .dynstr in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb220 - 0x0000fffff7ffb22c is .gnu.version in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb230 - 0x0000fffff7ffb268 is .gnu.version_d in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb268 - 0x0000fffff7ffb2bc is .note in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb2c0 - 0x0000fffff7ffb7e4 is .text in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb7e8 - 0x0000fffff7ffb8f8 is .dynamic in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb8f8 - 0x0000fffff7ffb900 is .got in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb900 - 0x0000fffff7ffb918 is .got.plt in system-supplied DSO at 0xfffff7ffb000
    ```

### plt & got

`plt` -- Prints any symbols found in the `.plt` section if it exists.

vaddr(puts@plt) += piebase = 0xaaaaaaaa0000 + 0000000000000630 = 0xaaaaaaaa0630.

```bash linenums="1" hl_lines="7"
pwndbg> plt
Section .plt 0xaaaaaaaa05d0-0xaaaaaaaa0640:
0xaaaaaaaa05f0: __libc_start_main@plt
0xaaaaaaaa0600: __cxa_finalize@plt
0xaaaaaaaa0610: __gmon_start__@plt
0xaaaaaaaa0620: abort@plt
0xaaaaaaaa0630: puts@plt
```

`got` -- Show the state of the Global Offset Table.

vaddr(puts@got) += piebase = 0xaaaaaaaa0000 + 0x00010fc8 = 0xaaaaaaab0fc8.

> 0x5d0 is the start of section `.plt`.

```bash linenums="1" hl_lines="10"
pwndbg> got
Filtering out read-only entries (display them with -r or --show-readonly)

State of the GOT of /home/pifan/Projects/cpp/a.out:
GOT protection: Full RELRO | Found 9 GOT entries passing the filter
[0xaaaaaaab0fa8] __libc_start_main@GLIBC_2.34 -> 0x5d0
[0xaaaaaaab0fb0] __cxa_finalize@GLIBC_2.17 -> 0x5d0
[0xaaaaaaab0fb8] __gmon_start__ -> 0x5d0
[0xaaaaaaab0fc0] abort@GLIBC_2.17 -> 0x5d0
[0xaaaaaaab0fc8] puts@GLIBC_2.17 -> 0x5d0
[0xaaaaaaab0fd8] _ITM_deregisterTMCloneTable -> 0
[0xaaaaaaab0fe0] __cxa_finalize@GLIBC_2.17 -> 0
[0xaaaaaaab0fe8] __gmon_start__ -> 0
[0xaaaaaaab0ff8] _ITM_registerTMCloneTable -> 0
```

## libc - entry

`entry` -- Start the debugged program stopping at its entrypoint address.

```bash
pwndbg> entry
Temporary breakpoint 1 at 0xaaaaaaaa0640
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".

Temporary breakpoint 1, 0x0000aaaaaaaa0640 in _start ()

──────────────────────────────────────────────────[ DISASM / aarch64 / set emulate on ]───────────────────────────────────────────────────
 ► 0xaaaaaaaa0640 <_start>       nop
   0xaaaaaaaa0644 <_start+4>     mov    x29, #0                 FP => 0
   0xaaaaaaaa0648 <_start+8>     mov    x30, #0                 LR => 0
   0xaaaaaaaa064c <_start+12>    mov    x5, x0                  X5 => 0xfffff7fc7180 (_dl_fini) ◂— stp x29, x30, [sp, #-0x90]!
   0xaaaaaaaa0650 <_start+16>    ldr    x1, [sp]                X1 => 1
   0xaaaaaaaa0654 <_start+20>    add    x2, sp, #8              X2 => 0xfffffffff2f8 —▸ 0xfffffffff5bf ◂— '/home/pifan/Projects/cpp/a.out'
   0xaaaaaaaa0658 <_start+24>    mov    x6, sp                  X6 => 0xfffffffff2f0 ◂— 1
   0xaaaaaaaa065c <_start+28>    adrp   x0, #0xaaaaaaab0000     X0 => 0xaaaaaaab0000 ◂— 0x10102464c457f
   0xaaaaaaaa0660 <_start+32>    ldr    x0, [x0, #0xff0]        X0 => 0xaaaaaaaa0754 (main) ◂— stp x29, x30, [sp, #-0x20]!
   0xaaaaaaaa0664 <_start+36>    mov    x3, #0                  X3 => 0
   0xaaaaaaaa0668 <_start+40>    mov    x4, #0                  X4 => 0
   0xaaaaaaaa066c <_start+44>    bl     #__libc_start_main@plt      <__libc_start_main@plt>

   0xaaaaaaaa0670 <_start+48>    bl     #abort@plt                  <abort@plt>
────────────────────────────────────────────────────────────────[ STACK ]─────────────────────────────────────────────────────────────────
```

Check PC(Program Counter) at the moment:

```bash
pwndbg> p $pc
$1 = (void (*)()) 0xaaaaaaaa0640 <_start>
pwndbg> i r pc
pc             0xaaaaaaaa0640      0xaaaaaaaa0640 <_start>
pwndbg> disassemble $pc
[...snip...]
```

### status info

The output of `getfile` and `piebase` remains as before.
But `i prog` shows that it stops at a brand new address.

```bash
pwndbg> i prog
    Using the running image of child Thread 0xfffff7ff7e60 (LWP 210269).
Program stopped at 0xaaaaaaaa0640.
It stopped at a breakpoint that has since been deleted.
Type "info stack" or "info registers" for more information.
```

### modules

As it runs to entry, the module `libc.so` is loaded into memory.

```bash linenums="1" hl_lines="4 10"
pwndbg> i share
From                To                  Syms Read   Shared Object Library
0x0000fffff7fc3c40  0x0000fffff7fe20a4  Yes         /lib/ld-linux-aarch64.so.1
0x0000fffff7e37040  0x0000fffff7f43090  Yes         /lib/aarch64-linux-gnu/libc.so.6

pwndbg> linkmap
Node           Objfile                                          Load Bias      Dynamic Segment
0xfffff7fff370 <Unknown, likely /home/pifan/Projects/cpp/a.out> 0xaaaaaaaa0000 0xaaaaaaab0da0
0xfffff7fff950 linux-vdso.so.1                                  0xfffff7ffb000 0xfffff7ffb7e8
0xfffff7ff7170 /lib/aarch64-linux-gnu/libc.so.6                 0xfffff7e10000 0xfffff7faaba8
0xfffff7ffeb88 /lib/ld-linux-aarch64.so.1                       0xfffff7fc2000 0xfffff7ffde20
```

Check `vmmap` again, there are four new segments of *libc.so* loaded into memory.

```bash linenums="1" hl_lines="7-10"
pwndbg> vmmap
LEGEND: STACK | HEAP | CODE | DATA | RWX | RODATA
             Start                End Perm     Size Offset File
    0xaaaaaaaa0000     0xaaaaaaaa1000 r-xp     1000      0 /home/pifan/Projects/cpp/a.out
    0xaaaaaaab0000     0xaaaaaaab1000 r--p     1000      0 /home/pifan/Projects/cpp/a.out
    0xaaaaaaab1000     0xaaaaaaab2000 rw-p     1000   1000 /home/pifan/Projects/cpp/a.out
    0xfffff7e10000     0xfffff7f98000 r-xp   188000      0 /usr/lib/aarch64-linux-gnu/libc.so.6
    0xfffff7f98000     0xfffff7fa7000 ---p     f000 188000 /usr/lib/aarch64-linux-gnu/libc.so.6
    0xfffff7fa7000     0xfffff7fab000 r--p     4000 187000 /usr/lib/aarch64-linux-gnu/libc.so.6
    0xfffff7fab000     0xfffff7fad000 rw-p     2000 18b000 /usr/lib/aarch64-linux-gnu/libc.so.6
    0xfffff7fad000     0xfffff7fb9000 rw-p     c000      0 [anon_fffff7fad]
    0xfffff7fc2000     0xfffff7fed000 r-xp    2b000      0 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
    0xfffff7ff7000     0xfffff7ff9000 rw-p     2000      0 [anon_fffff7ff7]
    0xfffff7ff9000     0xfffff7ffb000 r--p     2000      0 [vvar]
    0xfffff7ffb000     0xfffff7ffc000 r-xp     1000      0 [vdso]
    0xfffff7ffc000     0xfffff7ffe000 r--p     2000  2a000 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
    0xfffff7ffe000     0xfffff8000000 rw-p     2000  2c000 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
    0xfffffffdf000    0x1000000000000 rw-p    21000      0 [stack]
```

Check the target files being debugged, sections corresponding to `libc.so`'s segments have emerged from the water.

??? info "entry - info target"

    ```bash
    pwndbg> i target
    Symbols from "/home/pifan/Projects/cpp/a.out".
    Native process:
        Using the running image of child Thread 0xfffff7ff7e60 (LWP 210269).
        While running this, GDB does not access memory from...
    Local exec file:
        `/home/pifan/Projects/cpp/a.out', file type elf64-littleaarch64.
        Entry point: 0xaaaaaaaa0640
        0x0000aaaaaaaa0238 - 0x0000aaaaaaaa0253 is .interp
        0x0000aaaaaaaa0254 - 0x0000aaaaaaaa0278 is .note.gnu.build-id
        0x0000aaaaaaaa0278 - 0x0000aaaaaaaa0298 is .note.ABI-tag
        0x0000aaaaaaaa0298 - 0x0000aaaaaaaa02b4 is .gnu.hash
        0x0000aaaaaaaa02b8 - 0x0000aaaaaaaa03a8 is .dynsym
        0x0000aaaaaaaa03a8 - 0x0000aaaaaaaa043a is .dynstr
        0x0000aaaaaaaa043a - 0x0000aaaaaaaa044e is .gnu.version
        0x0000aaaaaaaa0450 - 0x0000aaaaaaaa0480 is .gnu.version_r
        0x0000aaaaaaaa0480 - 0x0000aaaaaaaa0540 is .rela.dyn
        0x0000aaaaaaaa0540 - 0x0000aaaaaaaa05b8 is .rela.plt
        0x0000aaaaaaaa05b8 - 0x0000aaaaaaaa05d0 is .init
        0x0000aaaaaaaa05d0 - 0x0000aaaaaaaa0640 is .plt
        0x0000aaaaaaaa0640 - 0x0000aaaaaaaa077c is .text
        0x0000aaaaaaaa077c - 0x0000aaaaaaaa0790 is .fini
        0x0000aaaaaaaa0790 - 0x0000aaaaaaaa07a6 is .rodata
        0x0000aaaaaaaa07a8 - 0x0000aaaaaaaa07e4 is .eh_frame_hdr
        0x0000aaaaaaaa07e8 - 0x0000aaaaaaaa0894 is .eh_frame
        0x0000aaaaaaab0d90 - 0x0000aaaaaaab0d98 is .init_array
        0x0000aaaaaaab0d98 - 0x0000aaaaaaab0da0 is .fini_array
        0x0000aaaaaaab0da0 - 0x0000aaaaaaab0f90 is .dynamic
        0x0000aaaaaaab0f90 - 0x0000aaaaaaab1000 is .got
        0x0000aaaaaaab1000 - 0x0000aaaaaaab1010 is .data
        0x0000aaaaaaab1010 - 0x0000aaaaaaab1018 is .bss
        0x0000fffff7fc21c8 - 0x0000fffff7fc21ec is .note.gnu.build-id in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc21f0 - 0x0000fffff7fc2330 is .hash in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2330 - 0x0000fffff7fc248c is .gnu.hash in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2490 - 0x0000fffff7fc2868 is .dynsym in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2868 - 0x0000fffff7fc2b22 is .dynstr in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2b22 - 0x0000fffff7fc2b74 is .gnu.version in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2b78 - 0x0000fffff7fc2c1c is .gnu.version_d in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc2c20 - 0x0000fffff7fc3b20 is .rela.dyn in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc3b20 - 0x0000fffff7fc3b98 is .rela.plt in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc3ba0 - 0x0000fffff7fc3c10 is .plt in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fc3c40 - 0x0000fffff7fe20a4 is .text in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fe20a8 - 0x0000fffff7fe84e4 is .rodata in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fe84e4 - 0x0000fffff7fe84e5 is .stapsdt.base in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fe84e8 - 0x0000fffff7fe8de4 is .eh_frame_hdr in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fe8de8 - 0x0000fffff7fec3b4 is .eh_frame in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffc960 - 0x0000fffff7ffc968 is .init_array in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffc968 - 0x0000fffff7ffde20 is .data.rel.ro in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffde20 - 0x0000fffff7ffdfb0 is .dynamic in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffdfb0 - 0x0000fffff7ffdfe8 is .got in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffdfe8 - 0x0000fffff7ffe028 is .got.plt in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffe028 - 0x0000fffff7fff1c8 is .data in /lib/ld-linux-aarch64.so.1
        0x0000fffff7fff1c8 - 0x0000fffff7fff370 is .bss in /lib/ld-linux-aarch64.so.1
        0x0000fffff7ffb0e8 - 0x0000fffff7ffb114 is .hash in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb118 - 0x0000fffff7ffb1a8 is .dynsym in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb1a8 - 0x0000fffff7ffb21f is .dynstr in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb220 - 0x0000fffff7ffb22c is .gnu.version in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb230 - 0x0000fffff7ffb268 is .gnu.version_d in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb268 - 0x0000fffff7ffb2bc is .note in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb2c0 - 0x0000fffff7ffb7e4 is .text in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb7e8 - 0x0000fffff7ffb8f8 is .dynamic in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb8f8 - 0x0000fffff7ffb900 is .got in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7ffb900 - 0x0000fffff7ffb918 is .got.plt in system-supplied DSO at 0xfffff7ffb000
        0x0000fffff7e10270 - 0x0000fffff7e10294 is .note.gnu.build-id in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e10294 - 0x0000fffff7e102b4 is .note.ABI-tag in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e102b8 - 0x0000fffff7e1485c is .gnu.hash in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e14860 - 0x0000fffff7e25c00 is .dynsym in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e25c00 - 0x0000fffff7e2d96b is .dynstr in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e2d96c - 0x0000fffff7e2f064 is .gnu.version in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e2f068 - 0x0000fffff7e2f2e0 is .gnu.version_d in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e2f2e0 - 0x0000fffff7e2f310 is .gnu.version_r in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e2f310 - 0x0000fffff7e36d20 is .rela.dyn in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e36d20 - 0x0000fffff7e36ee8 is .rela.plt in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e36ef0 - 0x0000fffff7e37040 is .plt in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7e37040 - 0x0000fffff7f43090 is .text in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7f43090 - 0x0000fffff7f44180 is __libc_freeres_fn in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7f44180 - 0x0000fffff7f6518c is .rodata in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7f6518c - 0x0000fffff7f6518d is .stapsdt.base in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7f65190 - 0x0000fffff7f651ab is .interp in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7f651ac - 0x0000fffff7f6b940 is .eh_frame_hdr in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7f6b940 - 0x0000fffff7f93114 is .eh_frame in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7f93114 - 0x0000fffff7f93622 is .gcc_except_table in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7f93628 - 0x0000fffff7f97404 is .hash in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7fa7da8 - 0x0000fffff7fa7db8 is .tdata in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7fa7db8 - 0x0000fffff7fa7e38 is .tbss in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7fa7db8 - 0x0000fffff7fa7dd0 is .init_array in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7fa7dd0 - 0x0000fffff7fa7eb8 is __libc_subfreeres in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7fa7eb8 - 0x0000fffff7fa7ec0 is __libc_atexit in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7fa7ec0 - 0x0000fffff7fa8a90 is __libc_IO_vtables in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7fa8a90 - 0x0000fffff7faaba8 is .data.rel.ro in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7faaba8 - 0x0000fffff7faad68 is .dynamic in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7faad68 - 0x0000fffff7faafe8 is .got in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7faafe8 - 0x0000fffff7fab098 is .got.plt in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7fab098 - 0x0000fffff7fac6e0 is .data in /lib/aarch64-linux-gnu/libc.so.6
        0x0000fffff7fac6e0 - 0x0000fffff7fb8e68 is .bss in /lib/aarch64-linux-gnu/libc.so.6
    ```

### plt & got

The `plt` output keeps the status quo.

Let's see where the symbol `libc/puts` is located at the moment.

```bash
pwndbg> i addr puts
Symbol "puts" is at 0xfffff7e7ae70 in a file compiled without debugging.
pwndbg> i sym 0xfffff7e7ae70
puts in section .text of /lib/aarch64-linux-gnu/libc.so.6
```

What remains to be seen is how the symbol `puts@plt` is connected with `libc/puts` at run time.

That's exactly the GOT's mission! Let's delve deeper and lift the veil.

> `got -r puts`: Filter by symbol name *puts*.

```bash linenums="1" hl_lines="13"
pwndbg> got
Filtering out read-only entries (display them with -r or --show-readonly)

State of the GOT of /home/pifan/Projects/cpp/a.out:
GOT protection: Full RELRO | Found 0 GOT entries passing the filter
pwndbg> got -r
State of the GOT of /home/pifan/Projects/cpp/a.out:
GOT protection: Full RELRO | Found 9 GOT entries passing the filter
[0xaaaaaaab0fa8] __libc_start_main@GLIBC_2.34 -> 0xfffff7e37434 (__libc_start_main) ◂— stp x29, x30, [sp, #-0x60]!
[0xaaaaaaab0fb0] __cxa_finalize@GLIBC_2.17 -> 0xfffff7e4d220 (__cxa_finalize) ◂— stp x29, x30, [sp, #-0x60]!
[0xaaaaaaab0fb8] __gmon_start__ -> 0
[0xaaaaaaab0fc0] abort@GLIBC_2.17 -> 0xfffff7e3704c (abort) ◂— stp x29, x30, [sp, #-0x150]!
[0xaaaaaaab0fc8] puts@GLIBC_2.17 -> 0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!
[0xaaaaaaab0fd8] _ITM_deregisterTMCloneTable -> 0
[0xaaaaaaab0fe0] __cxa_finalize@GLIBC_2.17 -> 0xfffff7e4d220 (__cxa_finalize) ◂— stp x29, x30, [sp, #-0x60]!
[0xaaaaaaab0fe8] __gmon_start__ -> 0
[0xaaaaaaab0ff8] _ITM_registerTMCloneTable -> 0
```

As is shown above, the dynamic symbol GOT entries have been resolved with the correct address.

Check the GOT entry above for `puts@plt`, it holds the address of `libc/puts`.

Dereference pointers starting at the address in GOT.

```bash
pwndbg> x/xg 0xaaaaaaab0fc8
0xaaaaaaab0fc8 <puts@got.plt>:	0x0000fffff7e7ae70
pwndbg> hexdump 0xaaaaaaab0fc8 8
+0000 0xaaaaaaab0fc8  70 ae e7 f7 ff ff 00 00                           │p.......│        │
pwndbg> telescope 0xaaaaaaab0fc8 1
00:0000│  0xaaaaaaab0fc8 (puts@got[plt]) —▸ 0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!
```

The facts behind the scenes have already been revealed under the telescope. Let's go one step further and complete the last piece of the puzzle.

Searching libc.so.6, `puts` is a weak symbol that shares the same address with another global symbol named `_IO_puts`.

!!! abstract "Global vs. weak symbols"

    According to [TIS-ELF v1.2](https://refspecs.linuxfoundation.org/elf/elf.pdf), weak symbols have lower precedence than global symbols.
    The link editor would honor the global definition and ignore the weak one.

```bash
[0xaaaae5360630]> !nm -gD /usr/lib/aarch64-linux-gnu/libc.so.6 | grep puts

000000000006ae70 T _IO_puts@@GLIBC_2.17
000000000006ae70 W puts@@GLIBC_2.17

[0xaaaae5360630]> !readelf -s /usr/lib/aarch64-linux-gnu/libc.so.6 | grep puts

   Num:    Value          Size Type    Bind   Vis      Ndx Name

  1400: 000000000006ae70   492 FUNC    WEAK   DEFAULT   12 puts@@GLIBC_2.17
  1409: 000000000006ae70   492 FUNC    GLOBAL DEFAULT   12 _IO_puts@@GLIBC_2.17

[0xaaaae5360630]> !objdump -t /usr/lib/aarch64-linux-gnu/libc.so.6 | grep puts

000000000006ae70  w    F .text	00000000000001ec puts
000000000006ae70 g     F .text	00000000000001ec _IO_puts
```

The value of symbol `puts` is `0x000000000006ae70`, which is the static absolute paddr and would be adjusted to vaddr when loaded into memory.

According to the latest `linkmap` output, the *Load Bias* of libc.so is 0xfffff7e10000, which is also the start address of the text segment LOAD0(perm=r-xp) according to the latest `vmmap` output.

Note that `vaddr = baddr + paddr`. Just add paddr/offset to the baddr/bias to check the correctness of the formula.

```bash
# p/x 0xfffff7e10000+0x6ae70
pwndbg> set var $puts_addr=0xfffff7e10000+0x6ae70
pwndbg> p/x $puts_addr
$2 = 0xfffff7e7ae70
```

Well, it's exactly the function address that the GOT entry slot `puts@plt`(0xaaaaaaab0fc8) holds.

You can simply use `x/i` or `disassemble` to probe what is there.

```bash
pwndbg> x/i $puts_addr
pwndbg> disassemble $puts_addr,$puts_addr+4
```

But I don't want to get ahead of the story. Let the story speak for itself.
Debug step by step, and the truth will emerge naturally.
Let's get on with the rest of the journey.

## c - main

### main

Set a breakpoint at `main`.

```bash
pwndbg> i addr main
Symbol "main" is at 0xaaaaaaaa0754 in a file compiled without debugging.
pwndbg> b *main
Breakpoint 2 at 0xaaaaaaaa0754
pwndbg> b main
Breakpoint 3 at 0xaaaaaaaa076c
pwndbg> i b
Num     Type           Disp Enb Address            What
2       breakpoint     keep y   0x0000aaaaaaaa0754 <main>
3       breakpoint     keep y   0x0000aaaaaaaa076c <main+24>
```

Continue to resume program execution until <main\>.

```bash
pwndbg> c
Continuing.

Breakpoint 2, 0x0000aaaaaaaa0754 in main ()

──────────────────────────────────────────────────────[ DISASM / aarch64 / set emulate on ]───────────────────────────────────────────────────────
 ► 0xaaaaaaaa0754 <main>       stp    x29, x30, [sp, #-0x20]!
   0xaaaaaaaa0758 <main+4>     mov    x29, sp                     FP => 0xfffffffff160 —▸ 0xfffffffff180 —▸ 0xfffffffff290 ◂— ...
   0xaaaaaaaa075c <main+8>     str    w0, [sp, #0x1c]
   0xaaaaaaaa0760 <main+12>    str    x1, [sp, #0x10]
   0xaaaaaaaa0764 <main+16>    adrp   x0, #0xaaaaaaaa0000         X0 => 0xaaaaaaaa0000 ◂— 0x10102464c457f
   0xaaaaaaaa0768 <main+20>    add    x0, x0, #0x798              X0 => 0xaaaaaaaa0798 ◂— ldnp d8, d25, [x10, #-0x140] /* 'Hello, Linux!' */
   0xaaaaaaaa076c <main+24>    bl     #puts@plt                   <puts@plt>

   0xaaaaaaaa0770 <main+28>    mov    w0, #0
   0xaaaaaaaa0774 <main+32>    ldp    x29, x30, [sp], #0x20
   0xaaaaaaaa0778 <main+36>    ret

   0xaaaaaaaa077c <_fini>      nop
   0xaaaaaaaa0780 <_fini+4>    stp    x29, x30, [sp, #-0x10]!
   0xaaaaaaaa0784 <_fini+8>    mov    x29, sp
────────────────────────────────────────────────────────────────────[ STACK ]─────────────────────────────────────────────────────────────────────
[...snip...]
──────────────────────────────────────────────────────────────────[ BACKTRACE ]───────────────────────────────────────────────────────────────────
 ► 0   0xaaaaaaaa0754 main
   1   0xfffff7e373fc __libc_start_call_main+108
   2   0xfffff7e374cc __libc_start_main+152
   3   0xaaaaaaaa0670 _start+48
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Continue to run until <main+24\>.

```bash
pwndbg> c
Continuing.

Breakpoint 3, 0x0000aaaaaaaa076c in main ()

──────────────────────────────────────────────────────[ DISASM / aarch64 / set emulate on ]───────────────────────────────────────────────────────
   0xaaaaaaaa0754 <main>       stp    x29, x30, [sp, #-0x20]!
   0xaaaaaaaa0758 <main+4>     mov    x29, sp                     FP => 0xfffffffff160 —▸ 0xfffffffff180 —▸ 0xfffffffff290 ◂— ...
   0xaaaaaaaa075c <main+8>     str    w0, [sp, #0x1c]
   0xaaaaaaaa0760 <main+12>    str    x1, [sp, #0x10]
   0xaaaaaaaa0764 <main+16>    adrp   x0, #0xaaaaaaaa0000         X0 => 0xaaaaaaaa0000 ◂— 0x10102464c457f
   0xaaaaaaaa0768 <main+20>    add    x0, x0, #0x798              X0 => 0xaaaaaaaa0798 ◂— ldnp d8, d25, [x10, #-0x140] /* 'Hello, Linux!' */
 ► 0xaaaaaaaa076c <main+24>    bl     #puts@plt                   <puts@plt>
        s: 0xaaaaaaaa0798 ◂— 'Hello, Linux!'

   0xaaaaaaaa0770 <main+28>    mov    w0, #0
   0xaaaaaaaa0774 <main+32>    ldp    x29, x30, [sp], #0x20
   0xaaaaaaaa0778 <main+36>    ret

   0xaaaaaaaa077c <_fini>      nop
   0xaaaaaaaa0780 <_fini+4>    stp    x29, x30, [sp, #-0x10]!
   0xaaaaaaaa0784 <_fini+8>    mov    x29, sp
────────────────────────────────────────────────────────────────────[ STACK ]─────────────────────────────────────────────────────────────────────
[...snip...]
──────────────────────────────────────────────────────────────────[ BACKTRACE ]───────────────────────────────────────────────────────────────────
 ► 0   0xaaaaaaaa076c main+24
   1   0xfffff7e373fc __libc_start_call_main+108
   2   0xfffff7e374cc __libc_start_main+152
   3   0xaaaaaaaa0670 _start+48
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Prints determined arguments for next call instruction.

```bash
pwndbg> x /s $x0
0xaaaaaaaa0798:	"Hello, Linux!"
pwndbg> dumpargs
        s:         0xaaaaaaaa0798 ◂— 'Hello, Linux!'
```

### puts@plt

Set a breakpoint at `puts@plt`.

```bash
pwndbg> info address puts@plt
Symbol "puts@plt" is at 0xaaaaaaaa0630 in a file compiled without debugging.
pwndbg> b *0xaaaaaaaa0630
Breakpoint 4 at 0xaaaaaaaa0630
pwndbg> i b
Num     Type           Disp Enb Address            What
2       breakpoint     keep y   0x0000aaaaaaaa0754 <main>
	breakpoint already hit 1 time
3       breakpoint     keep y   0x0000aaaaaaaa076c <main+24>
	breakpoint already hit 1 time
4       breakpoint     keep y   0x0000aaaaaaaa0630 <puts@plt>
```

Continue to run until <puts@plt\>.

```bash
pwndbg> c
Continuing.

Breakpoint 4, 0x0000aaaaaaaa0630 in puts@plt ()

*X30  0xaaaaaaaa0770 (main+28) ◂— mov w0, #0                                SP   0xfffffffff160 —▸ 0xfffffffff180 —▸ 0xfffffffff290 ◂— 0
*LR   0xaaaaaaaa0770 (main+28) ◂— mov w0, #0                               *PC   0xaaaaaaaa0630 (puts@plt) ◂— adrp x16, #0xaaaaaaab0000
*CPSR 0x80200000 [ N z c v q pan il d a i f el:0 sp ]

──────────────────────────────────────────────────────[ DISASM / aarch64 / set emulate on ]───────────────────────────────────────────────────────
 ► 0xaaaaaaaa0630 <puts@plt>       adrp   x16, #0xaaaaaaab0000     X16 => 0xaaaaaaab0000 ◂— 0x10102464c457f
   0xaaaaaaaa0634 <puts@plt+4>     ldr    x17, [x16, #0xfc8]       X17 => 0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!
   0xaaaaaaaa0638 <puts@plt+8>     add    x16, x16, #0xfc8         X16 => 0xaaaaaaab0fc8 (puts@got[plt]) —▸ 0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!
   0xaaaaaaaa063c <puts@plt+12>    br     x17                         <puts>
    ↓
   0xfffff7e7ae70 <puts>           stp    x29, x30, [sp, #-0x40]!
   0xfffff7e7ae74 <puts+4>         mov    x29, sp                     FP => 0xfffffffff120 —▸ 0xfffffffff160 —▸ 0xfffffffff180 —▸ 0xfffffffff290 ◂— ...
   0xfffff7e7ae78 <puts+8>         stp    x19, x20, [sp, #0x10]
   0xfffff7e7ae7c <puts+12>        adrp   x20, #sys_siglist+424       X20 => 0xfffff7faa000 (sys_siglist+424) ◂— 0
   0xfffff7e7ae80 <puts+16>        stp    x21, x22, [sp, #0x20]
   0xfffff7e7ae84 <puts+20>        mov    x22, x0                     X22 => 0xaaaaaaaa0798 ◂— ldnp d8, d25, [x10, #-0x140] /* 'Hello, Linux!' */
   0xfffff7e7ae88 <puts+24>        stp    x23, x24, [sp, #0x30]
   0xfffff7e7ae8c <puts+28>        bl     #__strlen_mte               <__strlen_mte>

   0xfffff7e7ae90 <puts+32>        mov    x19, x0
────────────────────────────────────────────────────────────────────[ STACK ]─────────────────────────────────────────────────────────────────────
[...snip...]
──────────────────────────────────────────────────────────────────[ BACKTRACE ]───────────────────────────────────────────────────────────────────
 ► 0   0xaaaaaaaa0630 puts@plt
   1   0xaaaaaaaa0770 main+28
   2   0xfffff7e373fc __libc_start_call_main+108
   3   0xfffff7e374cc __libc_start_main+152
   4   0xaaaaaaaa0670 _start+48
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

### nextjmp

Breaks at the next jump instruction `br x17`.

A cross-reference watershed is indicated by a down arrow in the code context.

```bash
pwndbg> nextjmp

Temporary breakpoint -10, 0x0000aaaaaaaa063c in puts@plt ()

*X16  0xaaaaaaab0fc8 (puts@got[plt]) —▸ 0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!
*X17  0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!

──────────────────────────────────────────────────────[ DISASM / aarch64 / set emulate on ]───────────────────────────────────────────────────────
   0xaaaaaaaa0630 <puts@plt>       adrp   x16, #0xaaaaaaab0000     X16 => 0xaaaaaaab0000 ◂— 0x10102464c457f
   0xaaaaaaaa0634 <puts@plt+4>     ldr    x17, [x16, #0xfc8]       X17 => 0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!
   0xaaaaaaaa0638 <puts@plt+8>     add    x16, x16, #0xfc8         X16 => 0xaaaaaaab0fc8 (puts@got[plt]) —▸ 0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!
 ► 0xaaaaaaaa063c <puts@plt+12>    br     x17                         <puts>
    ↓
   0xfffff7e7ae70 <puts>           stp    x29, x30, [sp, #-0x40]!
   0xfffff7e7ae74 <puts+4>         mov    x29, sp                     FP => 0xfffffffff120 —▸ 0xfffffffff160 —▸ 0xfffffffff180 —▸ 0xfffffffff290 ◂— ...
   0xfffff7e7ae78 <puts+8>         stp    x19, x20, [sp, #0x10]
   0xfffff7e7ae7c <puts+12>        adrp   x20, #sys_siglist+424       X20 => 0xfffff7faa000 (sys_siglist+424) ◂— 0
   0xfffff7e7ae80 <puts+16>        stp    x21, x22, [sp, #0x20]
   0xfffff7e7ae84 <puts+20>        mov    x22, x0                     X22 => 0xaaaaaaaa0798 ◂— ldnp d8, d25, [x10, #-0x140] /* 'Hello, Linux!' */
   0xfffff7e7ae88 <puts+24>        stp    x23, x24, [sp, #0x30]
   0xfffff7e7ae8c <puts+28>        bl     #__strlen_mte               <__strlen_mte>

   0xfffff7e7ae90 <puts+32>        mov    x19, x0
────────────────────────────────────────────────────────────────────[ STACK ]─────────────────────────────────────────────────────────────────────
[...snip...]
──────────────────────────────────────────────────────────────────[ BACKTRACE ]───────────────────────────────────────────────────────────────────
 ► 0   0xaaaaaaaa063c puts@plt+12
   1   0xaaaaaaaa0770 main+28
   2   0xfffff7e373fc __libc_start_call_main+108
   3   0xfffff7e374cc __libc_start_main+152
   4   0xaaaaaaaa0670 _start+48
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Step further to cross the boudary. It jumps from main->`puts@plt` to `puts` in *libc.so*.

```bash
pwndbg> s
__GI__IO_puts (str=0xaaaaaaaa0798 "Hello, Linux!") at ./libio/ioputs.c:35
35	./libio/ioputs.c: No such file or directory.

──────────────────────────────────────────────────────[ DISASM / aarch64 / set emulate on ]───────────────────────────────────────────────────────
   0xaaaaaaaa0630 <puts@plt>       adrp   x16, #0xaaaaaaab0000     X16 => 0xaaaaaaab0000 ◂— 0x10102464c457f
   0xaaaaaaaa0634 <puts@plt+4>     ldr    x17, [x16, #0xfc8]       X17 => 0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!
   0xaaaaaaaa0638 <puts@plt+8>     add    x16, x16, #0xfc8         X16 => 0xaaaaaaab0fc8 (puts@got[plt]) —▸ 0xfffff7e7ae70 (puts) ◂— stp x29, x30, [sp, #-0x40]!
   0xaaaaaaaa063c <puts@plt+12>    br     x17                         <puts>
    ↓
 ► 0xfffff7e7ae70 <puts>           stp    x29, x30, [sp, #-0x40]!
   0xfffff7e7ae74 <puts+4>         mov    x29, sp                     FP => 0xfffffffff120 —▸ 0xfffffffff160 —▸ 0xfffffffff180 —▸ 0xfffffffff290 ◂— ...
   0xfffff7e7ae78 <puts+8>         stp    x19, x20, [sp, #0x10]
   0xfffff7e7ae7c <puts+12>        adrp   x20, #sys_siglist+424       X20 => 0xfffff7faa000 (sys_siglist+424) ◂— 0
   0xfffff7e7ae80 <puts+16>        stp    x21, x22, [sp, #0x20]
   0xfffff7e7ae84 <puts+20>        mov    x22, x0                     X22 => 0xaaaaaaaa0798 ◂— ldnp d8, d25, [x10, #-0x140] /* 'Hello, Linux!' */
   0xfffff7e7ae88 <puts+24>        stp    x23, x24, [sp, #0x30]
   0xfffff7e7ae8c <puts+28>        bl     #__strlen_mte               <__strlen_mte>

   0xfffff7e7ae90 <puts+32>        mov    x19, x0
────────────────────────────────────────────────────────────────────[ STACK ]─────────────────────────────────────────────────────────────────────
[...snip...]
──────────────────────────────────────────────────────────────────[ BACKTRACE ]───────────────────────────────────────────────────────────────────
 ► 0   0xfffff7e7ae70 puts
   1   0xaaaaaaaa0770 main+28
   2   0xfffff7e373fc __libc_start_call_main+108
   3   0xfffff7e374cc __libc_start_main+152
   4   0xaaaaaaaa0670 _start+48
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Continue execution to the end. Hello, Linux! Hello, brave new world!

```bash
pwndbg> c
Continuing.
Hello, Linux!
[Inferior 1 (process 210924) exited normally]

pwndbg> q
```

## track-got

After `entry` or `sstart`, along with the loading of *libc.so*, the dynamic relocation entries in the `.rela.plt` section typed `R_AARCH64_JUMP_SLOT` would have been resolved.

Before entering `main`, it's a good time to enable the [GOT parsing/tracking feature](https://github.com/pwndbg/pwndbg/pull/1971) provided by the pwndbg extension.

First have a look at the usage of the command.

```bash
pwndbg> track-got -h
usage: track-got [-h] {enable,disable,info,query} ...

Controls GOT tracking

options:
  -h, --help            show this help message and exit

subcommands:
  Used to disable and query information about the tracker

  {enable,disable,info,query}
    enable              Enable GOT parsing
    disable             Disable GOT tracking
    info                Give an overview of the GOT tracker
    query               Queries detailed tracking information about a single entry in the GOT
```

Then type `track-got info` to show the tracking status.

```bash
pwndbg> track-got info
GOT call tracking is not enabled
```

Type `track-got enable` to enable the GOT tracker.

```bash
pwndbg> track-got enable
Hardware watchpoints have been disabled. Please do not turn them back on until
GOT tracking is disabled, as it may lead to unexpected silent errors.

They may be re-enabled with `set can-use-hw-watchpoints 1`

Enabled GOT tracking. Calls across dynamic library boundaries are now
instumented, and the number of calls and stack traces for every call will be
collected. You may check the current call information by using the
`track-got info` and `track-got query` commands. Run this command again to
diasble tracking.

Keep in mind that, currently, the tracker does not update across calls to
dlopen(), so, if one of those does happen, the tracker has to be manually
disabled and re-enabled in order to update the hooks.
```

Type `track-got info` to get an overview of the resolved GOT function entries.

It shows very clearly the essence of the core of the GOT. It's nothing but an array of function pointers, providing reference resolution through indirect addressing.

```bash
pwndbg> track-got info
Showing all GOT function entries and how many times they were called.

Calls from /home/pifan/Projects/cpp/a.out:
Address in GOT Function Address Symbol            Call Count
0xaaaaaaab0fa8 0xfffff7e37434   __libc_start_main 0 hits
0xaaaaaaab0fb0 0xfffff7e4d220   __cxa_finalize    0 hits
0xaaaaaaab0fb8 0x0              __gmon_start__    0 hits
0xaaaaaaab0fc0 0xfffff7e3704c   abort             0 hits
0xaaaaaaab0fc8 0xfffff7e7ae70   puts              0 hits

Calls from /lib/aarch64-linux-gnu/libc.so.6:
Address in GOT Function Address Symbol                   Call Count
0xfffff7fab000 0xfffff7e36ef0   realloc                  0 hits
0xfffff7fab008 0xfffff7e36ef0   __tls_get_addr           0 hits
0xfffff7fab010 0xfffff7ef5560   __getauxval              0 hits
0xfffff7fab018 0xfffff7e36ef0   _dl_exception_create     0 hits
0xfffff7fab020 0xfffff7e36ef0   calloc                   0 hits
0xfffff7fab028 0xfffff7e36ef0   free                     0 hits
0xfffff7fab030 0xfffff7e36ef0   _dl_find_dso_for_object  0 hits
0xfffff7fab038 0xfffff7e36ef0   _dl_deallocate_tls       0 hits
0xfffff7fab040 0xfffff7e36ef0   _dl_fatal_printf         0 hits
0xfffff7fab048 0xfffff7e36ef0   _dl_audit_symbind_alt    0 hits
0xfffff7fab050 0xfffff7e36ef0   _dl_rtld_di_serinfo      0 hits
0xfffff7fab058 0xfffff7e36ef0   _dl_allocate_tls         0 hits
0xfffff7fab060 0xfffff7fd5d40   __tunable_get_val        0 hits
0xfffff7fab068 0xfffff7e36ef0   _dl_allocate_tls_init    0 hits
0xfffff7fab070 0xfffff7e36ef0   __nptl_change_stack_perm 0 hits
0xfffff7fab078 0xfffff7e36ef0   malloc                   0 hits
0xfffff7fab080 0xfffff7e36ef0   _dl_audit_preinit        0 hits

Calls from /lib/ld-linux-aarch64.so.1:
Address in GOT Function Address Symbol               Call Count
0xfffff7ffe000 0xfffff7f3d290   _dl_catch_exception  0 hits
0xfffff7ffe008 0xfffff7f3d1e4   _dl_signal_exception 0 hits
0xfffff7ffe010 0xfffff7fd3cd0   __tls_get_addr       0 hits
0xfffff7ffe018 0xfffff7f3d234   _dl_signal_error     0 hits
0xfffff7ffe020 0xfffff7f3d390   _dl_catch_error      0 hits
```

### changes

There are a few gimmicks to make it work. That's what's behind the scenes.

First check the memory mapping again, and you'll see a new unnamed segment.

```bash
pwndbg> vmmap
[...snip...]
    0xfffff7fef000     0xfffff7ff7000 r-xp     8000      0 [anon_fffff7fef]
[...snip...]
```

Then check the GOT again, and you'll see that the mapping addresses have been changed to point to the new segment resolved as an `udf` instruction.

```bash
pwndbg> got -r
State of the GOT of /home/pifan/Projects/cpp/a.out:
GOT protection: Full RELRO | Found 9 GOT entries passing the filter
[0xaaaaaaab0fa8] __libc_start_main@GLIBC_2.34 -> 0xfffff7fef000 ◂— udf #0
[0xaaaaaaab0fb0] __cxa_finalize@GLIBC_2.17 -> 0xfffff7fef008 ◂— udf #0
[0xaaaaaaab0fb8] __gmon_start__ -> 0xfffff7fef010 ◂— udf #0
[0xaaaaaaab0fc0] abort@GLIBC_2.17 -> 0xfffff7fef018 ◂— udf #0
[0xaaaaaaab0fc8] puts@GLIBC_2.17 -> 0xfffff7fef020 ◂— udf #0
[0xaaaaaaab0fd8] _ITM_deregisterTMCloneTable -> 0
[0xaaaaaaab0fe0] __cxa_finalize@GLIBC_2.17 -> 0xfffff7e4d220 (__cxa_finalize) ◂— stp x29, x30, [sp, #-0x60]!
[0xaaaaaaab0fe8] __gmon_start__ -> 0
[0xaaaaaaab0ff8] _ITM_registerTMCloneTable -> 0
```

### tracking

When we run `b *main` and `continue`, it drops into `__libc_start_main` leaving a tracking hint.

```bash
[*] __libc_start_main@a.out called via GOT
```

Then it comes to `main`, backtrace as follows:

```bash
 ► 0   0xaaaaaaaa076c main+24
   1   0xfffff7e373fc __libc_start_call_main+108
   2   0xfffff7e374cc __libc_start_main+152
   3   0xaaaaaaaa0670 _start+48
```

Next we do `b puts@plt` and `continue`, the backtrace increments by one frame:

```bash
 ► 0   0xaaaaaaaa063c puts@plt+12
   1   0xaaaaaaaa0770 main+28
   2   0xfffff7e373fc __libc_start_call_main+108
   3   0xfffff7e374cc __libc_start_main+152
   4   0xaaaaaaaa0670 _start+48
```

Finally, `br x17` jumps to `puts`(aka `_IO_puts`, `__GI__IO_puts`) in *libc.so*, it gives a tracking hint:

```bash
[*] puts@a.out called via GOT

 ► 0   0xfffff7e7ae70 puts
   1   0xaaaaaaaa0770 main+28
   2   0xfffff7e373fc __libc_start_call_main+108
   3   0xfffff7e374cc __libc_start_main+152
   4   0xaaaaaaaa0670 _start+48
```
