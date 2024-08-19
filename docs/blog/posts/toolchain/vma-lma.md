---
title: VMA & LMA
authors:
    - xman
date:
    created: 2023-07-05T16:00:00
categories:
    - toolchain
    - elf
tags:
    - ld
comments: true
---

Every loadable or allocatable output section has *two* addresses. The first is the *`VMA`*, or virtual memory address. This is the address the section will have when the output file is run. The second is the *`LMA`*, or load memory address. This is the address at which the section will be loaded.

In most cases, the two addresses will be *the same*, because wherever the program is loaded into memory, that is where it will be executed. So what's the actual difference between the `VMA` and the `LMA`? Under what circumstances does `VMA != LMA`?

<!-- more -->

## assembly - VA & RVA

[assembly - VA (Virtual Address) & RVA (Relative Virtual Address)](https://stackoverflow.com/questions/2170843/va-virtual-address-rva-relative-virtual-address)

Usually the RVA in image files is relative to process base address when being loaded into memory, but some RVA may be relative to the "section" starting address in image or object files (you have to check the PE format spec for detail). No matter which, RVA is relative to "some" base VA.

1. Physical Memory Address is what CPU sees
2. Virtual Addreess (VA) is relative to Physical Address, per process (managed by OS)
3. RVA is relative to VA (file base or section base), per file (managed by linker and loader)

Most RVAs are given relative to the beginning of the file, but occasionally (especially when looking at object files instead of executables) you'll see an RVA based on the section.

## LD Basic Script Concepts

LD - [Basic Script Concepts](https://sourceware.org/binutils/docs/ld/Basic-Script-Concepts.html)

We need to define some basic concepts and vocabulary in order to describe the linker script language.

The linker combines input files into a single output file. The output file and each input file are in a special data format known as an *`object file format`*(see [ELF layout](../elf/elf-layout.md)). Each file is called an *`object file`*. The output file is often called an *`executable`*, but for our purposes we will also call it an *object file*. Each object file has, among other things, a list of *`sections`*. We sometimes refer to a section in an input file as an *input section*; similarly, a section in the output file is an *output section*.

Each section in an object file has a name and a size. Most sections also have an associated block of data, known as the *`section contents`*. A section may be marked as ***loadable***, which means that the contents should be loaded into memory when the output file is run. A section with no contents may be ***allocatable***, which means that an area in memory should be set aside, but nothing in particular should be loaded there (in some cases this memory must be zeroed out). A section which is neither loadable nor allocatable typically contains some sort of debugging information.

Every loadable or allocatable output section has *two* addresses. The first is the ***`VMA`***, or virtual memory address. This is the address the section will have when the output file is run. The second is the ***`LMA`***, or load memory address. This is the address at which the section will be loaded. In most cases the two addresses will be the *same*. An example of when they might be different is when a data section is loaded into *ROM*, and then **copied** into *RAM* when the program starts up (this technique is often used to initialize global variables in a *ROM* based system). In this case the ROM address would be the `LMA`, and the RAM address would be the `VMA`.

> You may ask, since the CPU can directly read the code from the ROM and run it, why do we need to move LMA and VMA around?

> Because, as the name implies, ROM is read-only, which can only be read but not written. The code section in the program is only read and does not involve modification or writing, so there is no problem. However, for the initialized data section (.data) and the uninitialized data section (.bss), most of the variables stored in them are not only read, but also modified and written to new values ​​during operation. For example, the typical self-increment statement `i++` involves *read-modify-write*(RMW). Therefore, if these variables in the data section are still stored in ROM, the new values ​​cannot be written back after modification.

> On the other hand, the speed at which the CPU reads code from ROM (such as the common Nor Flash) is much slower than the speed at which it reads from RAM (such as the common SDRAM). Therefore, it involves burning the code into ROM, and then reloading this part of the program at the beginning of the code. That is, it is copied from ROM (ie LMA) to SDRAM (ie VMA) and then run from RAM.

You can see the sections in an object file by using the [objdump](https://man7.org/linux/man-pages/man1/objdump.1.html) program with the ‘`-h`’ option.

Every object file also has a list of *`symbols`*, known as the *symbol table*. A symbol may be defined or undefined. Each symbol has a name, and each defined symbol has an address, among other information. If you compile a C or C++ program into an object file, you will get a defined symbol for every defined function and global or static variable. Every *undefined* function or global variable which is referenced in the input file will become an undefined symbol.

You can see the symbols in an object file by using the [nm](https://man7.org/linux/man-pages/man1/nm.1.html) program, or by using the [objdump](https://man7.org/linux/man-pages/man1/objdump.1.html) program with the ‘`-t`’ option.

## LD Output Section Address

LD - [Output Section Address (LD)](https://sourceware.org/binutils/docs/ld/Output-Section-Address.html)

The *address* is an expression for the `VMA` (the virtual memory address) of the output section. This address is optional, but if it is provided then the output address will be set exactly as specified.

If the output address is not specified then one will be chosen for the section, based on the heuristic below. This address will be adjusted to fit the alignment requirement of the output section. The alignment requirement is the strictest alignment of any input section contained within the output section.

The output section address heuristic is as follows:

- If an output memory *region* is set for the section then it is added to this region and its address will be the next free address in that region.
- If the MEMORY command has been used to create a list of memory regions then the first region which has attributes compatible with the section is selected to contain it. The section’s output address will be the next free address in that region; [MEMORY Command](https://sourceware.org/binutils/docs/ld/MEMORY.html).
- If no memory regions were specified, or none match the section then the output address will be based on the current value of the location counter.

For example:

```bash
.text . : { *(.text) }
```

and

```bash
.text : { *(.text) }
```

are subtly different. The first will set the address of the ‘`.text`’ output section to the current value of the location counter. The second will set it to the current value of the location counter aligned to the strictest alignment of any of the ‘`.text`’ input sections.

The *address* may be an arbitrary expression; [Expressions in Linker Scripts](https://sourceware.org/binutils/docs/ld/Expressions.html). For example, if you want to align the section on a 0x10 byte boundary, so that the lowest four bits of the section address are zero, you could do something like this:

```bash
.text ALIGN(0x10) : { *(.text) }
```

This works because `ALIGN` returns the current location counter aligned upward to the specified value.

Specifying *address* for a section will change the value of the location counter, provided that the section is non-empty. (Empty sections are ignored).

## LD Output Section LMA

LD - [Output Section LMA](https://sourceware.org/binutils/docs/ld/Output-Section-LMA.html)

Every section has a virtual address (`VMA`) and a load address (`LMA`); see [Basic Linker Script Concepts](https://sourceware.org/binutils/docs/ld/Basic-Script-Concepts.html). The virtual address is specified by the see [Output Section Address](https://sourceware.org/binutils/docs/ld/Output-Section-Address.html) described earlier. The load address is specified by the `AT` or `AT>` keywords. Specifying a load address is optional.

The `AT` keyword takes an expression as an argument. This specifies the exact load address of the section. The `AT>` keyword takes the name of a memory region as an argument. See [MEMORY Command](https://sourceware.org/binutils/docs/ld/MEMORY.html). The load address of the section is set to the next free address in the region, aligned to the section’s alignment requirements.

If neither `AT` nor `AT>` is specified for an allocatable section, the linker will use the following heuristic to determine the load address:

- If the section has a specific `VMA` address, then this is used as the `LMA` address as well.
- If the section is *not* allocatable then its `LMA` is set to its `VMA`.
- Otherwise if a memory region can be found that is compatible with the current section, and this region contains at least one section, then the `LMA` is set so the difference between the `VMA` and `LMA` is the same as the difference between the `VMA` and `LMA` of the last section in the located region.
- If no memory regions have been declared then a default region that covers the entire address space is used in the previous step.
- If no suitable region could be found, or there was no previous section then the `LMA` is set equal to the `VMA`.

This feature is designed to make it easy to build a ***ROM*** image. For example, the following linker script creates three output sections: one called ‘`.text`’, which starts at `0x1000`, one called ‘`.mdata`’, which is loaded at the end of the ‘`.text`’ section even though its VMA is `0x2000`, and one called ‘`.bss`’ to hold uninitialized data at address `0x3000`. The symbol `_data` is defined with the value `0x2000`, which shows that the location counter holds the `VMA` value, not the `LMA` value.

```bash
SECTIONS
  {
  .text 0x1000 : { *(.text) _etext = . ; }
  .mdata 0x2000 :
    AT ( ADDR (.text) + SIZEOF (.text) )
    { _data = . ; *(.data); _edata = . ;  }
  .bss 0x3000 :
    { _bstart = . ;  *(.bss) *(COMMON) ; _bend = . ;}
}
```

The *run-time* initialization code for use with a program generated with this linker script would include something like the following, to **copy** the initialized data from the ROM image to its runtime address. Notice how this code takes advantage of the symbols defined by the linker script.

```c
extern char _etext, _data, _edata, _bstart, _bend;
char *src = &_etext;
char *dst = &_data;

/* ROM has data at end of text; copy it.  */
while (dst < &_edata)
  *dst++ = *src++;

/* Zero bss.  */
for (dst = &_bstart; dst< &_bend; dst++)
  *dst = 0;
```

## references

[difference between VMA vs. LMA](https://www.embeddedrelated.com/showthread/comp.arch.embedded/77071-1.php)
[详解 LMA 与 VMA](https://blog.csdn.net/WIP56/article/details/139154878) - [eydwyz](https://blog.csdn.net/eydwyz/article/details/124179377), [cisen](https://github.com/cisen/blog/issues/887)
[虚拟内存地址VMA、装载内存地址LMA和位置无关代码PIC](https://blog.csdn.net/phunxm/article/details/8905309)
[10分鐘讀懂 linker scripts](https://blog.louie.lu/2016/11/06/10%E5%88%86%E9%90%98%E8%AE%80%E6%87%82-linker-scripts/) - [linker_script_vma_lma_example](https://github.com/mlouielu/linker_script_vma_lma_example)
[linker - Trying to understand the load memory address (LMA) and the binary file offset in an ARM binary image](https://stackoverflow.com/questions/54578360/trying-to-understand-the-load-memory-address-lma-and-the-binary-file-offset-in)
