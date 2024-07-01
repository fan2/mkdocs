---
title: ARM ADR vs. LDR
authors:
    - xman
date:
    created: 2023-06-10T10:00:00
categories:
    - arm
tags:
    - instruction
comments: true
---

Since both the `LDR` pseudo-instruction and the `ADRP` instruction can load the address of a label, and the `LDR` pseudo-instruction can address the 64-bit address space, and the addressing range of the `ADRP` instruction is the current PC address ±4GB, then what is the necessity of having an `ADRP` instruction when there's already an `LDR` pseudo-instruction?

<!-- more -->

## ADR faster than indirect LDR

In [Arm GNU Toolchain](../toolchain/arm-toolchain.md) and [ARM64 System calls](./a64-svc.md), we call `svc #0` to request Linux system call to write a character string to standard output device. It uses a combination of `adr`, `ldr` and `mov` instructions.

```asm title="write64.s" linenums="1" hl_lines="13 14"
    .text
    .align 2

    // syscall NR defined in /usr/include/asm-generic/unistd.h
    .equ    __NR_write, 64  // 0x40
    .equ    __NR_exit, 93   // 0x5d
    .equ    __STDOUT, 1

    .global _start          // Provide program starting address to linker

_start:
    mov x0, #__STDOUT
    adr x1, msg             // load PC-relative address
    ldr x2, len             // load content of PC-relative label(address)
    mov x8, #__NR_write
    svc #0                  // issue command to request system service

_exit:
    mov x0, #0
    mov x8, #__NR_exit
    svc #0

msg:
    .ascii "Hi A64!\n"

len:
    .word 8
```

[Modern Arm Assembly Language Programming: Covers Armv8-A 32-bit, 64-bit, and SIMD](https://www.amazon.com/Modern-Assembly-Language-Programming-Armv8/dp/1484262662/) | Chapter 9: Armv8-32 SIMD Floating-Point Programming - Packed Floating-Point Arithmetic - Conversions

```asm title="Ch09_03_.s" linenums="1" hl_lines="15 16"
        .text
CvtTab: .word F32_I32
        .word I32_F32
        .word F32_U32
        .word U32_F32
        .equ NumCvtTab, (. - CvtTab) / 4    // num CvtTab entries

// extern "C" bool PackedConvertF32_(Vec128& X, const Vec128& a, vtOp cvt_op);

        .global PackedConvertF32_
PackedConvertF32_:
        cmp r2, #NumCvtTab                 // cvt_op >= NumCvtOp?
        bhs InvalidArg                     // jump if yes
        vldm r1, {q0}                      // q0 = a
        adr r3, CvtTab                     // r3 = points to CvtTab
        ldr r3, [r3, r2, lsl #2]           // r3 = target jump address

        mov r2, r0                         // r2 = ptr to x
        mov r0, #1                         // valid cvt_op return code
        bx r3                              // jump to target
```

The next instruction, `adr r3,CvtTab` (form PC relative address), loads the address of CvtTab into `R3`. The `ADR` instruction is used here instead of a `ldr r3,=CvtTab` instruction since the target label is located within ±4095 bytes of the PC. Using an `ADR` instruction is also slightly *faster* since it eliminates the extra memory read cycle that the `LDR` instruction needs to load the target address from a literal pool as explained in Chapter 2. Following the `ADR` instruction is a `LDR r3,[r3,r2,lsl #2]` instruction that loads the correct label address from CvtTab.

The range of `ADR` is just as limited as an unconditional `b` or a `bl`. To address a label that is a greater distance away, yet within 4 GB in either direction, the `ADRP` instruction can be used in AArch64.

## LDR or ADR? non-PIC or PIC?

An address loaded using the `LDR` pseudo-instruction is fixed at link time, so the code is *not* position-independent(*non-PIC*). The address holding the ==constant== remains valid regardless of where the linker places the ELF section containing the `LDR` instruction.

Meanwhile, `ADR` produces [position-independent](https://en.wikipedia.org/wiki/Position-independent_code)(*PIC*) code, because the assembler generates an instruction that adds or subtracts a value to the `PC`. The expansive `ADRL` pseudo-instruction produces position-independent code too, because the address is PC-relative or register-relative.

The label used with `ADR` or `ADRL` must be within the ***same*** code section. If a label is out of range in the same section, the assembler faults the reference. As an aside, if a label is out of range in other code sections, the linker faults the reference.

if you plan to reference labels in ***other*** sections of code, or you know that a literal table will exist and you don’t mind the extra cycles used to fetch the literal from memory. Use the same caution with literal pools that you would for the construct `LDR <Rd>, = constant`.

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 7. Writing A32/T32 Assembly Language - 7.12 Load addresses to a register using LDR Rd, =label

The example of string copy also shows how, unlike the `ADR` and `ADRL` pseudo-instructions, you can use the `LDR` pseudo-instruction with labels that are *outside* the current section. The assembler places a *relocation directive* in the object code when the source file is assembled. The relocation directive instructs the linker to **resolve** the address at ^^link time^^. The address remains valid wherever the linker places the section containing the `LDR` and the literal pool.

[ARM 64-Bit Assembly Language](https://www.amazon.com/64-Bit-Assembly-Language-Larry-Pyeatt/dp/0128192216/) | 3 Load/store and branch instructions - 3.5 Branch instructions - 3.5.5 Form PC-relative address

The `ADR` instruction is helpful for **calculating** the address of labels at ^^run-time^^. This is particularly useful when the address of a label must be passed to a function as an argument(see *head.S* later), but the address cannot be determined at ^^compile time^^. For example, the address of some system libraries may not be set by the linker, but are set when the program is loaded and prepared to run. The addresses of labels in these libraries cannot be loaded with the `ldr Rx,=label` syntax, because the assembler and linker cannot predict the location of the label. The `ADR` instruction provides a way to get the address of the label.
