---
title: C variables representation in ELF 2 - Relocations
authors:
    - xman
date:
    created: 2023-10-19T10:00:00
categories:
    - c
    - elf
comments: true
---

[Previously](./c-vars-elf-sections.md), we've explored program and section headers and typical sections in ELF.

In this post, I'll try to explore the symbols and their relocation according to the symbol table and the assembly.

<!-- more -->

## nm

- `readelf -s --syms`: Display the symbol table
- `objdump -t, --syms`: Display the contents of the symbol table(s)

Compared to `nm -S vars-section.o`, all symbols except the undefined ones (marked with `U`) have a determined virtual address in the first column based on the section they're in.

```bash
$ nm -S vars-section
0000000000000278 0000000000000020 r __abi_tag
                 U abort@GLIBC_2.17
0000000000012070 B __bss_end__
0000000000012070 B _bss_end__
0000000000012030 B __bss_start
0000000000012030 B __bss_start__
00000000000007f4 0000000000000014 t call_weak_fn
0000000000012030 0000000000000001 b completed.0
                 w __cxa_finalize@GLIBC_2.17
0000000000012000 D __data_start
0000000000012000 W data_start
0000000000000810 t deregister_tm_clones
0000000000000880 t __do_global_dtors_aux
0000000000011d70 d __do_global_dtors_aux_fini_array_entry
0000000000012008 D __dso_handle
0000000000011d78 a _DYNAMIC
0000000000012030 D _edata
0000000000012070 B __end__
0000000000012070 B _end
0000000000000b94 T _fini
00000000000008d0 t frame_dummy
0000000000011d68 d __frame_dummy_init_array_entry
0000000000000d90 r __FRAME_END__
00000000000008d4 0000000000000188 T func
0000000000011fc8 a _GLOBAL_OFFSET_TABLE_
                 w __gmon_start__
0000000000000c7c r __GNU_EH_FRAME_HDR
0000000000012038 0000000000000004 B i
00000000000006e0 T _init
0000000000000ba8 0000000000000004 R _IO_stdin_used
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
0000000000012010 0000000000000002 D j
0000000000012040 0000000000000008 B k
0000000000012048 0000000000000004 b l
                 U __libc_start_main@GLIBC_2.34
0000000000012012 0000000000000002 d m
0000000000000a5c 0000000000000138 T main
0000000000012050 0000000000000008 b n
0000000000012058 0000000000000008 b o.5
0000000000012014 0000000000000002 d p.4
                 U printf@GLIBC_2.17
0000000000012060 0000000000000004 b q.3
0000000000000840 t register_tm_clones
                 U __stack_chk_fail@GLIBC_2.17
                 U __stack_chk_guard@GLIBC_2.17
00000000000007c0 0000000000000034 T _start
0000000000012020 0000000000000008 D str1
0000000000012028 0000000000000008 d str2
                 U strlen@GLIBC_2.17
0000000000012030 D __TMC_END__
0000000000012064 0000000000000002 b u.2
0000000000012018 0000000000000004 d v.1
0000000000012068 0000000000000008 b w.0
```

## objdump

### all-headers

After linking, the symbols have been relocated, the `HAS_RELOC` flag has disappeared. There are two new flags `DYNAMIC`, `D_PAGED`, the former indicates that the ELF needs dynamic linking with NEEDED shared objects when ld, the latter indicates that paging is enabled. The start address/entry point is set to 0x00000000000007c0.

The "Program header" tells the operating system how to allocate pages to the process when the program is loaded into memory and run.

The `RELOCATION RECORDS` is also gone, a new part `Dynamic Section` appears.

Look at the `SYMBOL TABLE`, the address in the first column has been updated after relocation.

```bash
$ objdump -xw vars-section

vars-section:     file format elf64-littleaarch64
vars-section
architecture: aarch64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x00000000000007c0

Program Header:
    PHDR off    0x0000000000000040 vaddr 0x0000000000000040 paddr 0x0000000000000040 align 2**3
         filesz 0x00000000000001f8 memsz 0x00000000000001f8 flags r--
  INTERP off    0x0000000000000238 vaddr 0x0000000000000238 paddr 0x0000000000000238 align 2**0
         filesz 0x000000000000001b memsz 0x000000000000001b flags r--
    LOAD off    0x0000000000000000 vaddr 0x0000000000000000 paddr 0x0000000000000000 align 2**16
         filesz 0x0000000000000d94 memsz 0x0000000000000d94 flags r-x
    LOAD off    0x0000000000001d68 vaddr 0x0000000000011d68 paddr 0x0000000000011d68 align 2**16
         filesz 0x00000000000002c8 memsz 0x0000000000000308 flags rw-
 DYNAMIC off    0x0000000000001d78 vaddr 0x0000000000011d78 paddr 0x0000000000011d78 align 2**3
         filesz 0x0000000000000200 memsz 0x0000000000000200 flags rw-
    NOTE off    0x0000000000000254 vaddr 0x0000000000000254 paddr 0x0000000000000254 align 2**2
         filesz 0x0000000000000044 memsz 0x0000000000000044 flags r--
EH_FRAME off    0x0000000000000c7c vaddr 0x0000000000000c7c paddr 0x0000000000000c7c align 2**2
         filesz 0x0000000000000044 memsz 0x0000000000000044 flags r--
   STACK off    0x0000000000000000 vaddr 0x0000000000000000 paddr 0x0000000000000000 align 2**4
         filesz 0x0000000000000000 memsz 0x0000000000000000 flags rw-
   RELRO off    0x0000000000001d68 vaddr 0x0000000000011d68 paddr 0x0000000000011d68 align 2**0
         filesz 0x0000000000000298 memsz 0x0000000000000298 flags r--

Dynamic Section:
  NEEDED               libc.so.6
  NEEDED               ld-linux-aarch64.so.1
  INIT                 0x00000000000006e0
  FINI                 0x0000000000000b94
  INIT_ARRAY           0x0000000000011d68
  INIT_ARRAYSZ         0x0000000000000008
  FINI_ARRAY           0x0000000000011d70
  FINI_ARRAYSZ         0x0000000000000008
  GNU_HASH             0x0000000000000298
  STRTAB               0x00000000000003f0
  SYMTAB               0x00000000000002b8
  STRSZ                0x00000000000000d4
  SYMENT               0x0000000000000018
  DEBUG                0x0000000000000000
  PLTGOT               0x0000000000011f78
  PLTRELSZ             0x00000000000000a8
  PLTREL               0x0000000000000007
  JMPREL               0x0000000000000638
  RELA                 0x0000000000000530
  RELASZ               0x0000000000000108
  RELAENT              0x0000000000000018
  FLAGS                0x0000000000000008
  FLAGS_1              0x0000000008000001
  VERNEED              0x00000000000004e0
  VERNEEDNUM           0x0000000000000002
  VERSYM               0x00000000000004c4
  RELACOUNT            0x0000000000000006

Version References:
  required from ld-linux-aarch64.so.1:
    0x06969197 0x00 04 GLIBC_2.17
  required from libc.so.6:
    0x069691b4 0x00 03 GLIBC_2.34
    0x06969197 0x00 02 GLIBC_2.17
private flags = 0x0:

Sections:

[...snip...]

SYMBOL TABLE:
0000000000000238 l    d  .interp	0000000000000000              .interp
0000000000000254 l    d  .note.gnu.build-id	0000000000000000              .note.gnu.build-id
0000000000000278 l    d  .note.ABI-tag	0000000000000000              .note.ABI-tag
0000000000000298 l    d  .gnu.hash	0000000000000000              .gnu.hash
00000000000002b8 l    d  .dynsym	0000000000000000              .dynsym
00000000000003f0 l    d  .dynstr	0000000000000000              .dynstr
00000000000004c4 l    d  .gnu.version	0000000000000000              .gnu.version
00000000000004e0 l    d  .gnu.version_r	0000000000000000              .gnu.version_r
0000000000000530 l    d  .rela.dyn	0000000000000000              .rela.dyn
0000000000000638 l    d  .rela.plt	0000000000000000              .rela.plt
00000000000006e0 l    d  .init	0000000000000000              .init
0000000000000700 l    d  .plt	0000000000000000              .plt
00000000000007c0 l    d  .text	0000000000000000              .text
0000000000000b94 l    d  .fini	0000000000000000              .fini
0000000000000ba8 l    d  .rodata	0000000000000000              .rodata
0000000000000c7c l    d  .eh_frame_hdr	0000000000000000              .eh_frame_hdr
0000000000000cc0 l    d  .eh_frame	0000000000000000              .eh_frame
0000000000011d68 l    d  .init_array	0000000000000000              .init_array
0000000000011d70 l    d  .fini_array	0000000000000000              .fini_array
0000000000011d78 l    d  .dynamic	0000000000000000              .dynamic
0000000000011f78 l    d  .got	0000000000000000              .got
0000000000012000 l    d  .data	0000000000000000              .data
0000000000012030 l    d  .bss	0000000000000000              .bss
0000000000000000 l    d  .comment	0000000000000000              .comment
0000000000000000 l    df *ABS*	0000000000000000              Scrt1.o
0000000000000278 l     O .note.ABI-tag	0000000000000020              __abi_tag
0000000000000000 l    df *ABS*	0000000000000000              crti.o
00000000000007f4 l     F .text	0000000000000014              call_weak_fn
0000000000000000 l    df *ABS*	0000000000000000              crtn.o
0000000000000000 l    df *ABS*	0000000000000000              crtstuff.c
0000000000000810 l     F .text	0000000000000000              deregister_tm_clones
0000000000000840 l     F .text	0000000000000000              register_tm_clones
0000000000000880 l     F .text	0000000000000000              __do_global_dtors_aux
0000000000012030 l     O .bss	0000000000000001              completed.0
0000000000011d70 l     O .fini_array	0000000000000000              __do_global_dtors_aux_fini_array_entry
00000000000008d0 l     F .text	0000000000000000              frame_dummy
0000000000011d68 l     O .init_array	0000000000000000              __frame_dummy_init_array_entry
0000000000000000 l    df *ABS*	0000000000000000              vars-section.c
0000000000012048 l     O .bss	0000000000000004              l
0000000000012012 l     O .data	0000000000000002              m
0000000000012050 l     O .bss	0000000000000008              n
0000000000012028 l     O .data	0000000000000008              str2
0000000000012058 l     O .bss	0000000000000008              o.5
0000000000012014 l     O .data	0000000000000002              p.4
0000000000012060 l     O .bss	0000000000000004              q.3
0000000000012064 l     O .bss	0000000000000002              u.2
0000000000012018 l     O .data	0000000000000004              v.1
0000000000012068 l     O .bss	0000000000000008              w.0
0000000000000000 l    df *ABS*	0000000000000000              crtstuff.c
0000000000000d90 l     O .eh_frame	0000000000000000              __FRAME_END__
0000000000000000 l    df *ABS*	0000000000000000
0000000000011d78 l     O *ABS*	0000000000000000              _DYNAMIC
0000000000000c7c l       .eh_frame_hdr	0000000000000000              __GNU_EH_FRAME_HDR
0000000000011fc8 l     O *ABS*	0000000000000000              _GLOBAL_OFFSET_TABLE_
0000000000000000       F *UND*	0000000000000000              strlen@GLIBC_2.17
0000000000000000       F *UND*	0000000000000000              __libc_start_main@GLIBC_2.34
0000000000000000  w      *UND*	0000000000000000              _ITM_deregisterTMCloneTable
0000000000012000  w      .data	0000000000000000              data_start
0000000000012030 g       .bss	0000000000000000              __bss_start__
0000000000000000  w    F *UND*	0000000000000000              __cxa_finalize@GLIBC_2.17
0000000000012010 g     O .data	0000000000000002              j
0000000000012070 g       .bss	0000000000000000              _bss_end__
0000000000012030 g       .data	0000000000000000              _edata
0000000000000b94 g     F .fini	0000000000000000              .hidden _fini
0000000000012070 g       .bss	0000000000000000              __bss_end__
0000000000012000 g       .data	0000000000000000              __data_start
0000000000000000       F *UND*	0000000000000000              __stack_chk_fail@GLIBC_2.17
0000000000000000  w      *UND*	0000000000000000              __gmon_start__
0000000000000000       O *UND*	0000000000000000              __stack_chk_guard@GLIBC_2.17
0000000000012008 g     O .data	0000000000000000              .hidden __dso_handle
0000000000000000       F *UND*	0000000000000000              abort@GLIBC_2.17
0000000000000ba8 g     O .rodata	0000000000000004              _IO_stdin_used
00000000000008d4 g     F .text	0000000000000188              func
0000000000012070 g       .bss	0000000000000000              _end
00000000000007c0 g     F .text	0000000000000034              _start
0000000000012038 g     O .bss	0000000000000004              i
0000000000012070 g       .bss	0000000000000000              __end__
0000000000012040 g     O .bss	0000000000000008              k
0000000000012030 g       .bss	0000000000000000              __bss_start
0000000000000a5c g     F .text	0000000000000138              main
0000000000012030 g     O .data	0000000000000000              .hidden __TMC_END__
0000000000012020 g     O .data	0000000000000008              str1
0000000000000000  w      *UND*	0000000000000000              _ITM_registerTMCloneTable
0000000000000000       F *UND*	0000000000000000              printf@GLIBC_2.17
00000000000006e0 g     F .init	0000000000000000              .hidden _init

```

The `SYMBOL TABLE` part adds some additional information about the symbols compared to `nm -S`.

### disassemble

```bash
$ objdump -d vars-section

vars-section:     file format elf64-littleaarch64


Disassembly of section .init:

00000000000006e0 <_init>:
 6e0:	d503201f 	nop
 6e4:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
 6e8:	910003fd 	mov	x29, sp
 6ec:	94000042 	bl	7f4 <call_weak_fn>
 6f0:	a8c17bfd 	ldp	x29, x30, [sp], #16
 6f4:	d65f03c0 	ret

Disassembly of section .plt:

0000000000000700 <.plt>:
 700:	a9bf7bf0 	stp	x16, x30, [sp, #-16]!
 704:	b0000090 	adrp	x16, 11000 <__FRAME_END__+0x10270>
 708:	f947c611 	ldr	x17, [x16, #3976]
 70c:	913e2210 	add	x16, x16, #0xf88
 710:	d61f0220 	br	x17
 714:	d503201f 	nop
 718:	d503201f 	nop
 71c:	d503201f 	nop

0000000000000720 <strlen@plt>:
 720:	b0000090 	adrp	x16, 11000 <__FRAME_END__+0x10270>
 724:	f947ca11 	ldr	x17, [x16, #3984]
 728:	913e4210 	add	x16, x16, #0xf90
 72c:	d61f0220 	br	x17

0000000000000730 <__libc_start_main@plt>:
 730:	b0000090 	adrp	x16, 11000 <__FRAME_END__+0x10270>
 734:	f947ce11 	ldr	x17, [x16, #3992]
 738:	913e6210 	add	x16, x16, #0xf98
 73c:	d61f0220 	br	x17

0000000000000740 <__cxa_finalize@plt>:
 740:	b0000090 	adrp	x16, 11000 <__FRAME_END__+0x10270>
 744:	f947d211 	ldr	x17, [x16, #4000]
 748:	913e8210 	add	x16, x16, #0xfa0
 74c:	d61f0220 	br	x17

0000000000000750 <__stack_chk_fail@plt>:
 750:	b0000090 	adrp	x16, 11000 <__FRAME_END__+0x10270>
 754:	f947d611 	ldr	x17, [x16, #4008]
 758:	913ea210 	add	x16, x16, #0xfa8
 75c:	d61f0220 	br	x17

0000000000000760 <__gmon_start__@plt>:
 760:	b0000090 	adrp	x16, 11000 <__FRAME_END__+0x10270>
 764:	f947da11 	ldr	x17, [x16, #4016]
 768:	913ec210 	add	x16, x16, #0xfb0
 76c:	d61f0220 	br	x17

0000000000000770 <abort@plt>:
 770:	b0000090 	adrp	x16, 11000 <__FRAME_END__+0x10270>
 774:	f947de11 	ldr	x17, [x16, #4024]
 778:	913ee210 	add	x16, x16, #0xfb8
 77c:	d61f0220 	br	x17

0000000000000780 <printf@plt>:
 780:	b0000090 	adrp	x16, 11000 <__FRAME_END__+0x10270>
 784:	f947e211 	ldr	x17, [x16, #4032]
 788:	913f0210 	add	x16, x16, #0xfc0
 78c:	d61f0220 	br	x17

Disassembly of section .text:

00000000000007c0 <_start>:
 7c0:	d503201f 	nop
 7c4:	d280001d 	mov	x29, #0x0                   	// #0
 7c8:	d280001e 	mov	x30, #0x0                   	// #0
 7cc:	aa0003e5 	mov	x5, x0
 7d0:	f94003e1 	ldr	x1, [sp]
 7d4:	910023e2 	add	x2, sp, #0x8
 7d8:	910003e6 	mov	x6, sp
 7dc:	b0000080 	adrp	x0, 11000 <__FRAME_END__+0x10270>
 7e0:	f947f800 	ldr	x0, [x0, #4080]
 7e4:	d2800003 	mov	x3, #0x0                   	// #0
 7e8:	d2800004 	mov	x4, #0x0                   	// #0
 7ec:	97ffffd1 	bl	730 <__libc_start_main@plt>
 7f0:	97ffffe0 	bl	770 <abort@plt>

00000000000007f4 <call_weak_fn>:
 7f4:	b0000080 	adrp	x0, 11000 <__FRAME_END__+0x10270>
 7f8:	f947f000 	ldr	x0, [x0, #4064]
 7fc:	b4000040 	cbz	x0, 804 <call_weak_fn+0x10>
 800:	17ffffd8 	b	760 <__gmon_start__@plt>
 804:	d65f03c0 	ret
 808:	d503201f 	nop
 80c:	d503201f 	nop

0000000000000810 <deregister_tm_clones>:
 810:	d0000080 	adrp	x0, 12000 <__data_start>
 814:	9100c000 	add	x0, x0, #0x30
 818:	d0000081 	adrp	x1, 12000 <__data_start>
 81c:	9100c021 	add	x1, x1, #0x30
 820:	eb00003f 	cmp	x1, x0
 824:	540000c0 	b.eq	83c <deregister_tm_clones+0x2c>  // b.none
 828:	b0000081 	adrp	x1, 11000 <__FRAME_END__+0x10270>
 82c:	f947e821 	ldr	x1, [x1, #4048]
 830:	b4000061 	cbz	x1, 83c <deregister_tm_clones+0x2c>
 834:	aa0103f0 	mov	x16, x1
 838:	d61f0200 	br	x16
 83c:	d65f03c0 	ret

0000000000000840 <register_tm_clones>:
 840:	d0000080 	adrp	x0, 12000 <__data_start>
 844:	9100c000 	add	x0, x0, #0x30
 848:	d0000081 	adrp	x1, 12000 <__data_start>
 84c:	9100c021 	add	x1, x1, #0x30
 850:	cb000021 	sub	x1, x1, x0
 854:	d37ffc22 	lsr	x2, x1, #63
 858:	8b810c41 	add	x1, x2, x1, asr #3
 85c:	9341fc21 	asr	x1, x1, #1
 860:	b40000c1 	cbz	x1, 878 <register_tm_clones+0x38>
 864:	b0000082 	adrp	x2, 11000 <__FRAME_END__+0x10270>
 868:	f947fc42 	ldr	x2, [x2, #4088]
 86c:	b4000062 	cbz	x2, 878 <register_tm_clones+0x38>
 870:	aa0203f0 	mov	x16, x2
 874:	d61f0200 	br	x16
 878:	d65f03c0 	ret
 87c:	d503201f 	nop

0000000000000880 <__do_global_dtors_aux>:
 880:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
 884:	910003fd 	mov	x29, sp
 888:	f9000bf3 	str	x19, [sp, #16]
 88c:	d0000093 	adrp	x19, 12000 <__data_start>
 890:	3940c260 	ldrb	w0, [x19, #48]
 894:	35000140 	cbnz	w0, 8bc <__do_global_dtors_aux+0x3c>
 898:	b0000080 	adrp	x0, 11000 <__FRAME_END__+0x10270>
 89c:	f947ec00 	ldr	x0, [x0, #4056]
 8a0:	b4000080 	cbz	x0, 8b0 <__do_global_dtors_aux+0x30>
 8a4:	d0000080 	adrp	x0, 12000 <__data_start>
 8a8:	f9400400 	ldr	x0, [x0, #8]
 8ac:	97ffffa5 	bl	740 <__cxa_finalize@plt>
 8b0:	97ffffd8 	bl	810 <deregister_tm_clones>
 8b4:	52800020 	mov	w0, #0x1                   	// #1
 8b8:	3900c260 	strb	w0, [x19, #48]
 8bc:	f9400bf3 	ldr	x19, [sp, #16]
 8c0:	a8c27bfd 	ldp	x29, x30, [sp], #32
 8c4:	d65f03c0 	ret
 8c8:	d503201f 	nop
 8cc:	d503201f 	nop

00000000000008d0 <frame_dummy>:
 8d0:	17ffffdc 	b	840 <register_tm_clones>

00000000000008d4 <func>:
 8d4:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
 8d8:	910003fd 	mov	x29, sp
 8dc:	b0000080 	adrp	x0, 11000 <__FRAME_END__+0x10270>
 8e0:	f947f400 	ldr	x0, [x0, #4072]
 8e4:	f9400001 	ldr	x1, [x0]
 8e8:	f9001fe1 	str	x1, [sp, #56]
 8ec:	d2800001 	mov	x1, #0x0                   	// #0
 8f0:	52800080 	mov	w0, #0x4                   	// #4
 8f4:	b9001be0 	str	w0, [sp, #24]
 8f8:	52800040 	mov	w0, #0x2                   	// #2
 8fc:	b90023e0 	str	w0, [sp, #32]
 900:	b90027ff 	str	wzr, [sp, #36]
 904:	52800080 	mov	w0, #0x4                   	// #4
 908:	b9002be0 	str	w0, [sp, #40]
 90c:	52800100 	mov	w0, #0x8                   	// #8
 910:	b9002fe0 	str	w0, [sp, #44]
 914:	528000a0 	mov	w0, #0x5                   	// #5
 918:	b9001fe0 	str	w0, [sp, #28]
 91c:	90000000 	adrp	x0, 0 <__abi_tag-0x278>
 920:	912ec001 	add	x1, x0, #0xbb0
 924:	9100c3e0 	add	x0, sp, #0x30
 928:	b9400022 	ldr	w2, [x1]
 92c:	b9000002 	str	w2, [x0]
 930:	79400821 	ldrh	w1, [x1, #4]
 934:	79000801 	strh	w1, [x0, #4]
 938:	d0000080 	adrp	x0, 12000 <__data_start>
 93c:	91004000 	add	x0, x0, #0x10
 940:	79c00000 	ldrsh	w0, [x0]
 944:	2a0003e1 	mov	w1, w0
 948:	d0000080 	adrp	x0, 12000 <__data_start>
 94c:	9100e000 	add	x0, x0, #0x38
 950:	b9400000 	ldr	w0, [x0]
 954:	0b000020 	add	w0, w1, w0
 958:	93407c01 	sxtw	x1, w0
 95c:	d0000080 	adrp	x0, 12000 <__data_start>
 960:	91010000 	add	x0, x0, #0x40
 964:	f9400000 	ldr	x0, [x0]
 968:	8b000020 	add	x0, x1, x0
 96c:	aa0003e1 	mov	x1, x0
 970:	90000000 	adrp	x0, 0 <__abi_tag-0x278>
 974:	912f0000 	add	x0, x0, #0xbc0
 978:	97ffff82 	bl	780 <printf@plt>
 97c:	b9401be1 	ldr	w1, [sp, #24]
 980:	b9401fe0 	ldr	w0, [sp, #28]
 984:	0b000020 	add	w0, w1, w0
 988:	b9402fe1 	ldr	w1, [sp, #44]
 98c:	9100c3e2 	add	x2, sp, #0x30
 990:	aa0203e3 	mov	x3, x2
 994:	2a0103e2 	mov	w2, w1
 998:	2a0003e1 	mov	w1, w0
 99c:	90000000 	adrp	x0, 0 <__abi_tag-0x278>
 9a0:	912f8000 	add	x0, x0, #0xbe0
 9a4:	97ffff77 	bl	780 <printf@plt>
 9a8:	d0000080 	adrp	x0, 12000 <__data_start>
 9ac:	91016000 	add	x0, x0, #0x58
 9b0:	f9400000 	ldr	x0, [x0]
 9b4:	91000402 	add	x2, x0, #0x1
 9b8:	d0000081 	adrp	x1, 12000 <__data_start>
 9bc:	91016021 	add	x1, x1, #0x58
 9c0:	f9000022 	str	x2, [x1]
 9c4:	d0000081 	adrp	x1, 12000 <__data_start>
 9c8:	91005021 	add	x1, x1, #0x14
 9cc:	79c00021 	ldrsh	w1, [x1]
 9d0:	12003c21 	and	w1, w1, #0xffff
 9d4:	11000421 	add	w1, w1, #0x1
 9d8:	12003c21 	and	w1, w1, #0xffff
 9dc:	13003c22 	sxth	w2, w1
 9e0:	d0000081 	adrp	x1, 12000 <__data_start>
 9e4:	91005021 	add	x1, x1, #0x14
 9e8:	79000022 	strh	w2, [x1]
 9ec:	d0000081 	adrp	x1, 12000 <__data_start>
 9f0:	91005021 	add	x1, x1, #0x14
 9f4:	79c00021 	ldrsh	w1, [x1]
 9f8:	2a0103e4 	mov	w4, w1
 9fc:	d0000081 	adrp	x1, 12000 <__data_start>
 a00:	91018021 	add	x1, x1, #0x60
 a04:	b9400021 	ldr	w1, [x1]
 a08:	11000423 	add	w3, w1, #0x1
 a0c:	d0000082 	adrp	x2, 12000 <__data_start>
 a10:	91018042 	add	x2, x2, #0x60
 a14:	b9000043 	str	w3, [x2]
 a18:	2a0103e3 	mov	w3, w1
 a1c:	2a0403e2 	mov	w2, w4
 a20:	aa0003e1 	mov	x1, x0
 a24:	90000000 	adrp	x0, 0 <__abi_tag-0x278>
 a28:	91302000 	add	x0, x0, #0xc08
 a2c:	97ffff55 	bl	780 <printf@plt>
 a30:	d503201f 	nop
 a34:	b0000080 	adrp	x0, 11000 <__FRAME_END__+0x10270>
 a38:	f947f400 	ldr	x0, [x0, #4072]
 a3c:	f9401fe2 	ldr	x2, [sp, #56]
 a40:	f9400001 	ldr	x1, [x0]
 a44:	eb010042 	subs	x2, x2, x1
 a48:	d2800001 	mov	x1, #0x0                   	// #0
 a4c:	54000040 	b.eq	a54 <func+0x180>  // b.none
 a50:	97ffff40 	bl	750 <__stack_chk_fail@plt>
 a54:	a8c47bfd 	ldp	x29, x30, [sp], #64
 a58:	d65f03c0 	ret

0000000000000a5c <main>:
 a5c:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
 a60:	910003fd 	mov	x29, sp
 a64:	a90153f3 	stp	x19, x20, [sp, #16]
 a68:	f90013f5 	str	x21, [sp, #32]
 a6c:	b9003fe0 	str	w0, [sp, #60]
 a70:	f9001be1 	str	x1, [sp, #48]
 a74:	b9004fff 	str	wzr, [sp, #76]
 a78:	14000005 	b	a8c <main+0x30>
 a7c:	97ffff96 	bl	8d4 <func>
 a80:	b9404fe0 	ldr	w0, [sp, #76]
 a84:	11000400 	add	w0, w0, #0x1
 a88:	b9004fe0 	str	w0, [sp, #76]
 a8c:	b9404fe0 	ldr	w0, [sp, #76]
 a90:	7100081f 	cmp	w0, #0x2
 a94:	54ffff4d 	b.le	a7c <main+0x20>
 a98:	d0000080 	adrp	x0, 12000 <__data_start>
 a9c:	91004800 	add	x0, x0, #0x12
 aa0:	79c00000 	ldrsh	w0, [x0]
 aa4:	2a0003e1 	mov	w1, w0
 aa8:	d0000080 	adrp	x0, 12000 <__data_start>
 aac:	91012000 	add	x0, x0, #0x48
 ab0:	b9400000 	ldr	w0, [x0]
 ab4:	0b000020 	add	w0, w1, w0
 ab8:	93407c01 	sxtw	x1, w0
 abc:	d0000080 	adrp	x0, 12000 <__data_start>
 ac0:	91014000 	add	x0, x0, #0x50
 ac4:	f9400000 	ldr	x0, [x0]
 ac8:	8b000020 	add	x0, x1, x0
 acc:	f9002be0 	str	x0, [sp, #80]
 ad0:	f9402be1 	ldr	x1, [sp, #80]
 ad4:	90000000 	adrp	x0, 0 <__abi_tag-0x278>
 ad8:	9130e000 	add	x0, x0, #0xc38
 adc:	97ffff29 	bl	780 <printf@plt>
 ae0:	d0000080 	adrp	x0, 12000 <__data_start>
 ae4:	91019000 	add	x0, x0, #0x64
 ae8:	79c00000 	ldrsh	w0, [x0]
 aec:	2a0003e1 	mov	w1, w0
 af0:	d0000080 	adrp	x0, 12000 <__data_start>
 af4:	91006000 	add	x0, x0, #0x18
 af8:	b9400000 	ldr	w0, [x0]
 afc:	0b000020 	add	w0, w1, w0
 b00:	93407c01 	sxtw	x1, w0
 b04:	d0000080 	adrp	x0, 12000 <__data_start>
 b08:	9101a000 	add	x0, x0, #0x68
 b0c:	f9400000 	ldr	x0, [x0]
 b10:	8b000020 	add	x0, x1, x0
 b14:	f9002fe0 	str	x0, [sp, #88]
 b18:	f9402fe1 	ldr	x1, [sp, #88]
 b1c:	90000000 	adrp	x0, 0 <__abi_tag-0x278>
 b20:	91312000 	add	x0, x0, #0xc48
 b24:	97ffff17 	bl	780 <printf@plt>
 b28:	d0000080 	adrp	x0, 12000 <__data_start>
 b2c:	91008000 	add	x0, x0, #0x20
 b30:	f9400013 	ldr	x19, [x0]
 b34:	d0000080 	adrp	x0, 12000 <__data_start>
 b38:	91008000 	add	x0, x0, #0x20
 b3c:	f9400000 	ldr	x0, [x0]
 b40:	97fffef8 	bl	720 <strlen@plt>
 b44:	aa0003f5 	mov	x21, x0
 b48:	d0000080 	adrp	x0, 12000 <__data_start>
 b4c:	9100a000 	add	x0, x0, #0x28
 b50:	f9400014 	ldr	x20, [x0]
 b54:	d0000080 	adrp	x0, 12000 <__data_start>
 b58:	9100a000 	add	x0, x0, #0x28
 b5c:	f9400000 	ldr	x0, [x0]
 b60:	97fffef0 	bl	720 <strlen@plt>
 b64:	aa0003e4 	mov	x4, x0
 b68:	aa1403e3 	mov	x3, x20
 b6c:	aa1503e2 	mov	x2, x21
 b70:	aa1303e1 	mov	x1, x19
 b74:	90000000 	adrp	x0, 0 <__abi_tag-0x278>
 b78:	91316000 	add	x0, x0, #0xc58
 b7c:	97ffff01 	bl	780 <printf@plt>
 b80:	52800000 	mov	w0, #0x0                   	// #0
 b84:	a94153f3 	ldp	x19, x20, [sp, #16]
 b88:	f94013f5 	ldr	x21, [sp, #32]
 b8c:	a8c67bfd 	ldp	x29, x30, [sp], #96
 b90:	d65f03c0 	ret

Disassembly of section .fini:

0000000000000b94 <_fini>:
 b94:	d503201f 	nop
 b98:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
 b9c:	910003fd 	mov	x29, sp
 ba0:	a8c17bfd 	ldp	x29, x30, [sp], #16
 ba4:	d65f03c0 	ret
```

## RELOCATION

[Previously](./c-vars-gcc-c.md), in the output of `objdump -xdw vars-section.o`, Disassembly of section .text start at 0000000000000000 <func\>; as is shown above, <func\> is marked as 00000000000008d4 now.

Adding the bias to locate the corresponding disassembly snippets in `RELOCATION RECORDS FOR [.text]`.


### .rodata

Look at disassemble snippets of func() that references `.rodata`:

```bash
  48:	90000000 	adrp	x0, 0 <func>	48: R_AARCH64_ADR_PREL_PG_HI21	.rodata
  4c:	91000001 	add	x1, x0, #0x0	4c: R_AARCH64_ADD_ABS_LO12_NC	.rodata
```

The global `char *str1` is located at the top of the `.data.rel.local`(alias of `.rodata`) section.

```bash
SYMBOL TABLE:

0000000000000000 g     O .data.rel.local	0000000000000008 str1

RELOCATION RECORDS FOR [.data.rel.local]:
OFFSET           TYPE              VALUE
0000000000000000 R_AARCH64_ABS64   .rodata
```

!!! note "0x8d4+0x48=0x91c"

    As the vaddr/VMA of section `.rodata` is 0xba8, `0xbb0` is 0x8 bytes offset from it.

    ```bash
    91c:   90000000    adrp    x0, 0 <__abi_tag-0x278>
    920:   912ec001    add x1, x0, #0xbb0
    ```

    `char *str1`(`.data+0x20`) stores `.rodata+0x8`=0xbb0. 0xbb0 stores "hello" see `readelf -p .rodata vars-section` and `rabin2 -z vars-section`.

---

`.rodata+0x10` referenced by func() stands for `func global static: ijk = %ld\n`.

```bash
# disassemble snippets

  9c:	90000000 	adrp	x0, 0 <func>	9c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x10
  a0:	91000000 	add	x0, x0, #0x0	a0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x10
  a4:	94000000 	bl	0 <printf>	a4: R_AARCH64_CALL26	printf
```

!!! note "0x8d4+0x9c=0x970"

    As the vaddr/VMA of section `.rodata` is 0xba8, `0xbc0` is 0x18(not 0x10) bytes offset from it.

    ```bash
    970:   90000000    adrp    x0, 0 <__abi_tag-0x278>
    974:   912f0000    add x0, x0, #0xbc0
    978:   97ffff82    bl  780 <printf@plt>
    ```

    `.rodata+0x18`=0xbc0 points to the first printf formatter in `func()` which stores "func global static: ijk = %ld\n", see `readelf -p .rodata vars-section` and `rabin2 -z vars-section`.

---

`.rodata+0xa8` referenced by main() represents `strlen(%s) = %zu; strlen(%s) = %zu\n`.

```bash
# disassemble snippets

 2a0:	90000000 	adrp	x0, 0 <func>	2a0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xa8
 2a4:	91000000 	add	x0, x0, #0x0	2a4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xa8
 2a8:	94000000 	bl	0 <printf>	2a8: R_AARCH64_CALL26	printf
```

!!! note "0x8d4+0x2a0=0xb74"

    As the vaddr/VMA of section `.rodata` is 0xba8, `0xc58` is 0xb0(not 0xa8) bytes offset from it.

    ```bash
    b74:   90000000    adrp    x0, 0 <__abi_tag-0x278>
    b78:   91316000    add x0, x0, #0xc58
    b7c:   97ffff01    bl  780 <printf@plt>
    ```

    `.rodata+0xb0`=0xc58 points to the last printf formatter in `main()` which stores "strlen(%s) = %zu; strlen(%s) = %zu\n", see `readelf -p .rodata vars-section` and `rabin2 -z vars-section`.

### .data

Look at disassemble snippets of func() that references `.data+0x4`:

```bash
 10c:	90000001 	adrp	x1, 0 <func>	10c: R_AARCH64_ADR_PREL_PG_HI21	.data+0x4
 110:	91000021 	add	x1, x1, #0x0	110: R_AARCH64_ADD_ABS_LO12_NC	.data+0x4
```

According to `SYMBOL TABLE`, `.data+0x4` represents local `p` defined in func():

```bash
SYMBOL TABLE:

0000000000000004 l     O .data	0000000000000002 p.4
```

!!! note "0x8d4+0x10c=0x9e0"

    As the vaddr/VMA of section `.data` is 0x12000, +offset 0x14 = 0x12014 represents `p.4` according to the SYMBOL TABLE.

    ```bash
    9e0:   d0000081    adrp    x1, 12000 <__data_start>
    9e4:   91005021    add x1, x1, #0x14
    ```

Look at disassemble snippets of main() that references `.data+0x2`:

```bash
 1c4:	90000000 	adrp	x0, 0 <func>	1c4: R_AARCH64_ADR_PREL_PG_HI21	.data+0x2
 1c8:	91000000 	add	x0, x0, #0x0	1c8: R_AARCH64_ADD_ABS_LO12_NC	.data+0x2
```

According to `SYMBOL TABLE`, `.data+0x2` represents static `m` defined outside main():

```bash
SYMBOL TABLE:

0000000000000002 l     O .data	0000000000000002 m
```

!!! note "0x8d4+0x1c4=0xa98"

    As the vaddr/VMA of section `.data` is 0x12000, +offset 0x12 = 0x12012 represents `m` according to the SYMBOL TABLE.

    ```bash
    a98:   d0000080    adrp    x0, 12000 <__data_start>
    a9c:   91004800    add x0, x0, #0x12
    ```

### .bss

Look at disassemble snippets of func() that references `.bss+0x20`:

```bash
  d4:	90000000 	adrp	x0, 0 <func>	d4: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x20
  d8:	91000000 	add	x0, x0, #0x0	d8: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x20
```

According to `SYMBOL TABLE`, `.bss+0x20` represents static `o` defined in func():

```bash
SYMBOL TABLE:

0000000000000020 l     O .bss	0000000000000008 o.5
```

!!! note "0x8d4+0xd4=0x9a8"

    As the vaddr/VMA of section `.data` is 0x12000(`.bss` starts from 0x12030), +offset 0x58(`.bss`+0x28) = 0x12058 represents `o.5` according to the SYMBOL TABLE.

    ```bash
    9a8:   d0000080    adrp    x0, 12000 <__data_start>
    9ac:   91016000    add x0, x0, #0x58
    ```

Look at disassemble snippets of main() that references `.bss+0x10`:

```bash
 1d4:	90000000 	adrp	x0, 0 <func>	1d4: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x10
 1d8:	91000000 	add	x0, x0, #0x0	1d8: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x10
```

According to `SYMBOL TABLE`, `.bss+0x10` represents static uninitialized `l` defined outside main():

```bash
SYMBOL TABLE:

0000000000000010 l     O .bss	0000000000000004 l
```

!!! note "0x8d4+0x1d4=0xaa8"

    As the vaddr/VMA of section `.data` is 0x12000, +offset 0x48 = 0x12048(`.bss`+0x18) represents `l` according to the SYMBOL TABLE outputed by `nm` or `objdump -x`.

    ```bash
    aa8:   d0000080    adrp    x0, 12000 <__data_start>
    aac:   91012000    add x0, x0, #0x48
    ```

> Since the `.bss` section follows the `.data` section, the `.bss` members can also be located relative to the `.data` section.

### call

Data relocation is generally based on the base address of the section and the offset of the variable, while code relocation in the ARM system is mainly implemented based on the `B` series branch jump instructions. Refer to [ARM64 PCS - Procedure Call Standard](../arm/a64-pcs-concepts.md).

The main() routine mainly invokes three subroutines: *func*(), *printf*() and *strlen*(). In the disassemble output of intermediate object file `vars-section.o`, the subroutine calls are all translated into `bl 0` in the assembler. *`0`* is just a placeholder for an unspecified location.

At this moment, all of the targets are determined in ELF binary.

```bash
 a7c:   97ffff96    bl  8d4 <func>

 adc:   97ffff29    bl  780 <printf@plt>

 b24:   97ffff17    bl  780 <printf@plt>

 b40:   97fffef8    bl  720 <strlen@plt>

 b60:   97fffef0    bl  720 <strlen@plt>
```

First, let's take a look at the A64 [BL - Branch with link](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/BL--Branch-with-link-) instruction.

`BL <label>`: This instruction branches to a PC-relative offset.

31 | 30 | 29 | 28 | 27 | 26 | 25 | 24 | 23 | 22 | 21 | 20 | 19 | 18 | 17 | 16 | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0
---|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|---|---|---|---|---|---|---|---|---|--
1 | 0 | 0 | 1 | 0 | 1 | imm26

`<label>` is encoded as "imm26" times 4.

```c
constant bits(64) offset = SignExtend(imm26:'00', 64);
```

Look at 0xa7c, it's translated as `bl 8d4 <func>`. 0x8d4 is actually the location of <func\>, the target of the `BL` instruction.

```bash
a7c:   97ffff96    bl  8d4 <func>
```

Let's try to decode the machine code `0x97ffff96` and figure out the PC-relative offset.

Refer to [ARM ADR/ADRP demos](../arm/arm-adr-demo.md), we can analyse the instructions using [capstone-tool](https://www.capstone-engine.org/) or [Radare2/Rasm2](https://book.rada.re/tools/rasm2/intro.html).

```bash
# opcode fetched as LE, endianness swapped
$ rax2 Bx97ffff96
10010111111111111111111110010110b

# endianness already swapped, just decode it as BE.
# -a [arch] : set architecture
# -d: disassemble from hexpair bytes
# -e: use big endian instead of little endian
$ rasm2 -a arm -d 0x97ffff96 -e
bl 0xfffffffffffffe58

# arm64be = aarch64 + big endian
$ cstool arm64be 0x97ffff96
 0  97 ff ff 96  bl	#0xfffffffffffffe58

# -d: show detailed information of the instructions
$ cstool -d arm64be 0x97ffff96
 0  97 ff ff 96  bl	#0xfffffffffffffe58
	ID: 68 (bl)
	op_count: 1
		operands[0].type: IMM = 0xfffffffffffffe58
		operands[0].access: READ
	Registers modified: lr
	Groups: call jump branch_relative
```

imm26:'00' = 0b1111111111111111111001011000

```bash
$ rax2 1111111111111111111001011000b
0xffffe58
```

offset = SignExtend(imm26:'00', 64) = 0xfffffffffffffe58

Refer to [signedness-representation](../cs/signedness-representation.md), when X<0, parse the bit vector as an unsigned number, the following formula holds: $\lvert X \rvert+\overrightarrow{[X]_补}=2^n$

Use Linux [$((expr))](../linux/shell/program/5-sh-expr.md) or Python to calculate the offset, and then use `PRINTF(1)` command or Python's `print` method to format and print the offset.

```bash
$ printf "%#x\n" $((2**28-0xffffe58))
0x1a8

# python3 -c "print(hex(2**28-0xffffe58))"
$ python3 -c "print(hex(2**64-0xfffffffffffffe58))"
0x1a8
```

As the sign bit is 1, the IMM offset should be negative, so it's actually -0x1a8.
The `BL` target = PC+offset = 0xa7c-0x1a8 = 0x8d4.
We figured it out as expected!

As for `printf` in <stdio.h\> and `strlen` in <string.h\>, they are both implemented by GLIBC/*libc.so*.
The corresponding instructions are `bl  780 <printf@plt>` and `bl  720 <strlen@plt>`.
They involve reloc plt via GOT to resolve dynamic symbols, see the series for details:

- [puts@plt/rela/got - static analysis](../elf/plt-puts-analysis.md)
- [reloc puts@plt via GOT - pwndbg](../elf/plt-puts-pwndbg.md)
- [reloc puts@plt via GOT - r2 debug](../elf/plt-puts-r2debug.md)
