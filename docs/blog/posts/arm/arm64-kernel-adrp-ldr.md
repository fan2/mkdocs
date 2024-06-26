---
title: ADRP & LDR in arm64/kernel primary switch
authors:
    - xman
date:
    created: 2023-06-12T10:00:00
    updated: 2024-05-14T10:00:00
categories:
    - arm
    - linux
comments: true
---

In [linux arm64 kernel](https://github.com/torvalds/linux/tree/master/arch/arm64/kernel), the *transition* of the PC from the physical address space to the real virtual address space is completed with the last three instructions of [head.S](https://github.com/torvalds/linux/blob/v6.9/arch/arm64/kernel/head.S) after MMU enabled.

```asm
    ldr     x8, =__primary_switched
    adrp    x0, KERNEL_START        // __pa(KERNEL_START)
    br      x8                      // executed with the MMU enabled
```

<!-- more -->

## vmlinux.lds.S

The target file generated after kernel compilation is `vmlinux` in ELF format. The vmlinux is each source code according to the rules set by `vmlinux.lds`. The object file obtained after linking is not an executable file and cannot be run on the ARM platform.

The `vmlinux.lds` is generated after sorting the output of the linker `ld` by the `vmlinux.lds.S` during kernel compilation; `vmlinux.lds.S` is used to sort the sections in the output file and define related symbols.

When the kernel is compiled, `vmlinux.lds` serves as the linker script of the Makefile and participates in linking to generate the kernel image `vmlinux`.

In short, `vmlinux` is generated according to the `vmlinux.lds` linker script, and `vmlinux.lds` is generated by `vmlinux.lds.S`.

In linux/arch/arm64/kernel, the `vmlinux.lds.S` is the linking script for arm64 kernel.

`ENTRY(_text)` declared the kernel entry is *`_text`*, defined in section `.head.text`.

```asm title="arch/arm64/kernel/vmlinux.lds.S"
// [...snip...]

ENTRY(_text)

// [...snip...]

#define IDMAP_TEXT                      \
    . = ALIGN(SZ_4K);                   \
    __idmap_text_start = .;             \
    *(.idmap.text)                      \
    __idmap_text_end = .;

// [...snip...]

SECTIONS
{
    . = KIMAGE_VADDR;

    .head.text : {
        _text = .;
        HEAD_TEXT
    }
    .text : ALIGN(SEGMENT_ALIGN) {  /* Real text segment        */
        _stext = .;                 /* Text and read-only data    */
            IRQENTRY_TEXT
            SOFTIRQENTRY_TEXT
            ENTRY_TEXT
            TEXT_TEXT
            SCHED_TEXT
            LOCK_TEXT
            KPROBES_TEXT
            HYPERVISOR_TEXT
            *(.gnu.warning)
    }

    . = ALIGN(SEGMENT_ALIGN);
    _etext = .;            /* End of text section */

    // [...snip...]

    /* code sections that are never executed via the kernel mapping */
    .rodata.text : {
        TRAMP_TEXT
        HIBERNATE_TEXT
        KEXEC_TEXT
        IDMAP_TEXT
        . = ALIGN(PAGE_SIZE);
    }

    // [...snip...]
}
```

The section names `__HEAD` and `__INIT` are defined in init.h, of which the `__HEAD` is an alias of the section `.head.text`.

```c title="include/linux/init.h"
/* For assembly routines */
#define __HEAD		.section	".head.text","ax"
#define __INIT		.section	".init.text","ax"
#define __FINIT		.previous
```

Following the word "HEAD", there is a corresponding assembly file, `head.S`, in which the first instruction of the kernel is actually located.

## head.S

In head.S, the section directive macro `__HEAD` comes first and covers the subsequent instructions.

Skip the special NOP(`efi_signature_nop`), `b primary_entry` comes up, it heads to kernel start.

```asm title="arch/arm64/kernel/head.S" linenums="44" hl_lines="18"
/*
 * Kernel startup entry point.
 * ---------------------------
 *
 * The requirements are:
 *   MMU = off, D-cache = off, I-cache = on or off,
 *   x0 = physical address to the FDT blob.
 *
 * Note that the callee-saved registers are used for storing variables
 * that are useful before the MMU is enabled. The allocations are described
 * in the entry routines.
 */
    __HEAD
    /*
     * DO NOT MODIFY. Image header expected by Linux boot-loaders.
     */
    efi_signature_nop            // special NOP to identity as PE/COFF executable
    b    primary_entry           // branch to kernel start, magic

    // [...snip...]

    .section ".idmap.text","a"

    /*
     * The following callee saved general purpose registers are used on the
     * primary lowlevel boot path:
     *
     *  Register   Scope                      Purpose
     *  x19        primary_entry() .. start_kernel()        whether we entered with the MMU on
     *  x20        primary_entry() .. __primary_switch()    CPU boot mode
     *  x21        primary_entry() .. start_kernel()        FDT pointer passed at boot in x0
     */
SYM_CODE_START(primary_entry)

    // [...snip...]

SYM_CODE_END(primary_entry)
```

The first two subroutines of `primary_entry`, `record_mmu_state` and `preserve_boot_args`, are covered by the `__INIT` section(.init.text).

The following subroutines are covered by the `.idmap.text` section:

1. `__pi_create_init_idmap` : defined in pi/map_range.c, create initial ID map.

    - [\[PATCH v3 37/60\] arm64: kernel: Create initial ID map from C code](https://lore.kernel.org/lkml/20230307140522.2311461-38-ardb@kernel.org/)

2. `dcache_inval_poc`: invalidate page tables have been populated with non-cacheable accesses(MMU disabled)
3. `dcache_clean_poc`: if MMU and caches on, clean the ID mapped part of the primary boot code to the PoC
4. `init_kernel_el`: Starting from EL2(Hypervisor) or EL1(OS Kernel), configure the CPU to execute at proper level
5. `__cpu_setup`: defined in mm/proc.S, Initialise the processor for turning the MMU on.
6. `__primary_switch`: see below.

## __primary_switch

```asm title="arch/arm64/kernel/head.S" linenums="521" hl_lines="2-3 13-14"
SYM_FUNC_START_LOCAL(__primary_switch)
    adrp    x1, reserved_pg_dir     // ex- init_pg_dir?
    adrp    x2, init_idmap_pg_dir
    bl      __enable_mmu

    adrp    x1, early_init_stack
    mov     sp, x1
    mov     x29, xzr
    mov     x0, x20                 // pass the full boot status
    mov     x1, x21                 // pass the FDT
    bl      __pi_early_map_kernel   // Map and relocate the kernel

    ldr     x8, =__primary_switched
    adrp    x0, KERNEL_START        // __pa(KERNEL_START)
    br      x8                      // executed with the MMU enabled
SYM_FUNC_END(__primary_switch)
```

In `__primary_switch`, after starting the MMU, it will map and relocate the kernel, then jump to the virtual entry point.

- [\[PATCH 3/8\] arm64: kernel: perform relocation processing from ID map - Ard Biesheuvel](https://lore.kernel.org/lkml/1460992188-23295-4-git-send-email-ard.biesheuvel@linaro.org/)

Before `__enable_mmu`, `adrp x1, reserved_pg_dir` and `adrp x2, init_idmap_pg_dir` load PC-relative address, calculated at run-time, pure physical address.

- CPU would fault the reference of linking virtual address if using `LDR` without MMU.

`__pi_early_map_kernel`: defined in pi/map_kernel.c, takes over map and kernel relocation workload.

- [\[PATCH v3 34/60\] arm64: head: Move early kernel mapping routines into C code - Ard Biesheuvel](https://lore.kernel.org/lkml/20230307140522.2311461-35-ardb@kernel.org/)

Label `KIMAGE_VADDR` is declared before `_text` in vmlinux.lds.S.

```c title="arch/arm64/include/asm/memory.h"
/* the offset between the kernel virtual and physical mappings */
extern u64			kimage_voffset;

static inline unsigned long kaslr_offset(void)
{
    return (u64)&_text - KIMAGE_VADDR;
}
```

```c title="arch/arm64/kernel/pi/map_kernel.c"
asmlinkage void __init early_map_kernel(u64 boot_status, void *fdt)
{

    u64 va_base, pa_base = (u64)&_text;
    // [...snip...]
    va_base = KIMAGE_VADDR + kaslr_offset;
    map_kernel(kaslr_offset, va_base - pa_base, root_level); // map_segment...
}
```

!!! question "Why not just bl __primary_switched?"

    After `__enable_mmu` and `__pi_early_map_kernel`, why not just call `bl __primary_switched` directly?

    - Using `LDR` here is to locate from the running address to the link address.

### adrp x0, KERNEL_START

The `X0` register would obtain the runtime address through the `ADRP` instruction. That is the actual physical address of the operation. You might wonder why is the running address obtained by `ARDP` the physical address since the MMU has already turned on?

Going one step further, we could find that the `__primary_switch` subroutine is located in the ".idmap.text" section, which is the *identity mapping*. So although the address we get is a virtual address, it is the same as the actual physical address(VA=PA).

Let's take a closer look at what `KERNEL_START` is.

```asm
//arch/arm64/kernel/head.S
#define __PHYS_OFFSET       KERNEL_START

//arch/arm64/include/asm/memory.h
#define KERNEL_START        _text
#define KERNEL_END          _end
```

`__PHYS_OFFSET`/`KERNEL_START` actually ends up being `_text`, which is the physical start position of the kernel image. Therefore, after the kernel image is copied from boot to memory, the starting position of the image in physical memory is where `_text` is located. So the instruction `adrp x0, KERNEL_START` will set the physical start address of the kernel image in memory to `X0` as parameter for `__primary_switched`.

### ldr x8, =__primary_switched

`__primary_switched` is the symbol of the kernel, and its virtual address has been determined during the kernel compilation and linking process.

This instruction puts the virtual address of label `__primary_switched` into the `X8` register.

Then `br x8` instruction executes, the PC jumps to the real virtual address space for execution.

!!! info "switch from section .idmap.text to init.text"

    `__primary_switch` is located in the `.idmap.text` section.
    `__primary_switched` and macro `init_cpu_task` are covered by the `__INIT` section(.init.text).

## __primary_switched

`__primary_switched`(x0 = __pa(KERNEL_START)) is executed with the MMU enabled.

1. `msr vbar_el1, x8`: Set up an exception vector table.

    - macro `kernel_ventry` and `vectors` defined in arch/arm64/kernel/entry.S.

2. As commented, `kimage_voffset` = \_\_va(_text) - \_\_pa(_text).
3. Sets the `__boot_cpu_mode` flag depending on the CPU boot mode.
4. `bl start_kernel` invoke `start_kernel` defined in init/main.c.

```asm title="arch/arm64/kernel/head.S" linenums="212" hl_lines="11 21 24 32"
/*
 * The following fragment of code is executed with the MMU enabled.
 *
 *   x0 = __pa(KERNEL_START)
 */
SYM_FUNC_START_LOCAL(__primary_switched)
    adr_l    x4, init_task
    init_cpu_task x4, x5, x6

    adr_l    x8, vectors            // load VBAR_EL1 with virtual
    msr    vbar_el1, x8             // vector table address
    isb

    stp    x29, x30, [sp, #-16]!
    mov    x29, sp

    str_l    x21, __fdt_pointer, x5 // Save FDT pointer

    adrp    x4, _text               // Save the offset between
    sub    x4, x4, x0               // the kernel virtual and
    str_l    x4, kimage_voffset, x5 // physical mappings

    mov    x0, x20
    bl    set_cpu_boot_mode_flag

#if defined(CONFIG_KASAN_GENERIC) || defined(CONFIG_KASAN_SW_TAGS)
    bl    kasan_early_init
#endif
    mov    x0, x20
    bl    finalise_el2              // Prefer VHE if possible
    ldp    x29, x30, [sp], #16
    bl    start_kernel
    ASM_BUG()
SYM_FUNC_END(__primary_switched)
```

After kernel mapping, the `IDMAP_TEXT` was moved to `.rodata.text`, for it would never execute again. Please refer to [move identity map out of .text mapping](https://github.com/torvalds/linux/commit/af7249b317e4d0b3d5a0ebbb7ee7a0f336ca7bca).

> start_kernel -> setup_arch -> cpu_uninstall_idmap -> cpu_switch_mm.
