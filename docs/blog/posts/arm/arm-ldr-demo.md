---
title: ARM LDR Literal and Pseudo demos
authors:
    - xman
date:
    created: 2023-06-06T10:00:00
categories:
    - arm
comments: true
---

In the [previous article](./arm-ldr.md), we've combed AMR `LDR` PC-relative and Pseudo instruction to load a value or address to a register.

Here we collect some enlightening demos from some classic textbooks to consolidate knowledge that is not solid.

<!-- more -->

## demo1

[ARM 64-Bit Assembly Language](https://www.amazon.com/64-Bit-Assembly-Language-Larry-Pyeatt/dp/0128192216/) | 3 Load/store and branch instructions - 3.3 Instruction components - 3.3.3 Addressing modes

An example pseudo-instruction and its disassembly are shown in Listing 3.1 and Listing 3.2.

Listing 3.1 LDR pseudo-instruction.

```asm
.text
ldr x0, =0x123456789abcdef0
ret
```

Listing 3.2 Disassembly of LDR pseudo-instruction

```asm
// little endian
0: 58000040 ldr x0, 8 <.text+0x8>
4: d65f03c0 ret
8: 9abcdef0 .word 0x9abcdef0
c: 12345678 .word 0x12345678
```

## demo2

[Programming with 64-Bit ARM Assembly Language](https://www.amazon.com/Programming-64-Bit-ARM-Assembly-Language/dp/1484258800/) | Chapter 5: Thanks for the Memories - Loading a Register with an Address - PC Relative Addressing

PC relative addressing has one more trick up its sleeve; it gives us a way to load any 64-bit quantity into a register in only one instruction, for example, consider

```asm
LDR X1, =0x1234ABCD1234ABCD
```

This assembles into

```asm
ldr X1, #8
// here missed an instruction ?
.quad 0x1234abcd1234abcd
```

The GNU Assembler is helping us out by putting the constant we want into memory, then creating a PC relative instruction to load it.

For PC relative addressing, it really becomes addressing relative to the current instruction. In the preceding example, “`ldr X1, #8`” means 8 words(instructions) from the current instruction.

In fact, this is how the Assembler handles all data labels. When we specified

```asm
LDR X1, =helloworld
```

the Assembler did the same thing; it created the address of the hellostring in memory and then loaded the contents of that memory location, not the helloworld string.

These constants the Assembler creates are placed at the *end* of the `.text` section which is where the Assembly instructions go, not in the `.data` section. This makes them read-only in normal circumstances, so they can’t be modified. Any data that you want to modify should go in a `.data` section.

## demo3

[Blue Fox: Arm Assembly Internals and Reverse Engineering](https://www.amazon.com/Blue-Fox-Assembly-Internals-Analysis/dp/1119745306) | Chapter 6 Memory Access Instructions - Addressing Modes and Offset Forms - Literal (PC-Relative) Addressing - Loading Constants

`LDR` can also load a constant value or the address of a label using the specialized syntax `LDR Rn,=value`. This syntax is also useful for cases when you write assembly and a constant cannot be directly encoded into a `MOV` instruction.

```asm
; A32
_start:
    ldr r0, =0x55555555 // Set r0 to 0x55555555
    ldr r1, =_start     // Set r1 to address of _start

; A64
_start:
    ldr x1, =0xaabbccdd99887766 // Set x1 to 0xaabbccdd99887766
    ldr x2, =_start             // Set x2 to address of _start
```

This syntax is a directive to the assembler to place the constant in a nearby *literal pool* and to translate the instruction into a PC-relative load of this constant at runtime, as you can see in this disassembly output:

```asm
Disassembly of section .text:

0000000000400078 <_start>:
    400078:     58000041    ldr         X1, 400080 <_start+0x8>
    40007C:     58000062    ldr         x2, 400088 <_start+0x10>
    400080:     99887766    .word       0х99887766 // <literal pool>
    400084:     aabbccdd    .word       0xaabbccdd
    400088:     00400078    .word       0х00400078
    40008C:     00000000    .word       0x00000000 // </literal pool>
```

The assembler groups and deduplicates the constants in the literal pool and writes them at the end of the section, or “spills” them explicitly when it encounters an `LTORG` directive in the assembly file.

Literal pools cannot be placed anywhere in memory; they must be *close* to the instruction using it. How close, and the direction, depends on the instruction and architecture using it, given in Table 6.15.

Table 6.15: LDR Literal Pool Locality Requirements

INSTRUCTION SET | INSTRUCTION  | LITERAL POOL LOCALITY REQUIREMENT
----------------|--------------|----------------------------------
A32             | LDR          | PC ± 4KB
T32             | LDR.W        | PC ± 4KB
idem            | LDR (16-bit) | Within 1KB strictly forwards from PC
A64             | LDR          | PC ± 1MB

By default, an assembler will try to rewrite literal loads into an equivalent `MOV` or `MVN` instruction. A PC-relative LDR instruction will be used only if this is not possible.

---

!!! warning "Copyright clarification"

    Copyright belongs to the original author. 🫡
    Excerpt/quotation for study only, non-commercial.
