---
title: ARM ADRP and ADRL pseudo-instruction
authors:
    - xman
date:
    created: 2023-06-08T09:00:00
categories:
    - arm
tags:
    - instruction
comments: true
---

`ADRL` is similar to the `ADR` instruction, except `ADRL` can load a *wider* range of addresses because it generates *two* data processing instructions.

1. In A32, the `ADRL` pseudo-instruction calculates an offset using two separate `ADD` or `SUB` operations.
2. In A64, on the other hand, `ADRL` assembles to two instructions, an `ADRP` followed by an `ADD`.

<!-- more -->

## ADRP (A64)

[Arm A-profile A64 Instruction Set Architecture](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/ADRP--Form-PC-relative-address-to-4KB-page-) | ADRP
[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest/A64-General-Instructions/ADRP) ｜ 5: A64 General Instructions - 5.13 ADRP
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest/A64-General-Instructions/ADRP--A64-) | 17. A64 General Instructions - 17.13 ADRP (A64): Form PC-relative address to 4KB page.

Load register (PC-relative literal).

**Syntax**

```asm
ADRP Xd, label
```

> `label` is the program label whose 4KB page address is to be calculated. An offset from the page address of this instruction, in the range ±4GB.

**Instruction**

Form PC-relative address to 4KB page adds an immediate value that is *shifted* left by 12 bits, to the PC value to form a PC-relative address, with the bottom 12 bits masked out, and writes the result to the destination register.

```c title="ADRP <Xd>, <label> imm"
integer d = UInt(Rd);
bits(64) imm = SignExtend(immhi:immlo:Zeros(12), 64);
```

`<label>` is the program label whose 4KB page address is to be calculated. Its offset from the page address of this instruction, in the range ±4GB, is encoded as "immhi:immlo"((23:5)<<2 | 30:29) times 4096.

> 2^21^<<12 = 2^33^ = 2*2^32^ = ±4GB.

```c title="ADRP <Xd>, <label> Operation"
bits(64) base = PC64<63:12>:Zeros(12);
X[d, 64] = base + imm;
```

**Usage**

Load Register (literal) calculates an address from the PC value and an immediate oﬀset, loads a word from memory, and writes it to a register. For information about memory accesses, see *Load/Store addressing modes* in the [Arm Architecture Reference Manual Armv8, for Armv8-A architecture profile](https://developer.arm.com/documentation/ddi0487/latest).

## ADRL pseudo-instruction

### A32

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest/A32-and-T32-Instructions/ADRL-pseudo-instruction) ｜ 3: A32 and T32 Instructions - 3.21 ADRL pseudo-instruction
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest/A64-General-Instructions/ADRL-pseudo-instruction--A64-) | 14. A32 and T32 Instructions - 14.12 ADRL pseudo-instruction

Load a PC-relative or register-relative address into a register.

**Syntax**

```asm
ADRL{cond} Rd,label
```

> `label` is a PC-relative or register-relative expression.

**Usage**

1. `ADRL` always assembles to *two* 32-bit instructions. Even if the address can be reached in a single instruction, a second, redundant instruction is produced.

2. If the assembler cannot construct the address in two instructions, it generates an error message and the assembly fails. You can use the `LDR` pseudo-instruction for loading a wider range of addresses.

3. `ADRL` is similar to the `ADR` instruction, except `ADRL` can load a *wider* range of addresses because it generates two data processing instructions.

4. `ADRL` produces position-independent code, because the address is PC-relative or register-relative.

5. If label is PC-relative, it must evaluate to an address in the *same* assembler area(code section) as the `ADRL` pseudo-instruction.

**Architectures and range**

The available range depends on the instruction set in use:

- `A32` The range of the instruction is any value that can be generated by two `ADD` or two `SUB` instructions. That is, any value that can be produced by the addition of two values, each of which is 8 bits rotated right by any even number of bits within a 32-bit word. See [Operand2 as a constant](https://developer.arm.com/documentation/dui0802/b/A32-and-T32-Instructions/Operand2-as-a-constant?lang=en) for more information.
- `T32`, 32-bit encoding ±1MB bytes to a byte, halfword, or word-aligned address.
- `T32`, 16-bit encoding `ADRL` is not available.

The given range is relative to a point four bytes (in T32 code) or two words (in A32 code) after the address of the current instruction.

### A64

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest/A64-General-Instructions/ADRL-pseudo-instruction) ｜ 5: A64 General Instructions - 5.12 ADRL pseudo-instruction
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest/A64-General-Instructions/ADRL-pseudo-instruction--A64-) | 17. A64 General Instructions - 17.12 ADRL pseudo-instruction

Load a PC-relative address into a register. It is similar to the `ADR` instruction but `ADRL` can load a wider range of addresses than `ADR` because it generates *two* data processing instructions.

**Syntax**

```asm
ADRL Wd,label
ADRL Xd,label
```

**Usage**

1. `ADRL` assembles to two instructions, an `ADRP` followed by `ADD`.

2. If the assembler cannot construct the address in two instructions, it generates a relocation. The linker then generates the correct oﬀsets.

3. `ADRL` produces position-independent code, because the address is calculated relative to PC.

**Examples**

```asm
ADRL x0, mylabel ; loads address of mylabel into x0
```

## references

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest/A32-and-T32-Instructions/Memory-access-instructions)

- 3: A32 and T32 Instructions - 3.3 Memory access instructions

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest/An-Introduction-to-the-ARMv8-Instruction-Sets/The-ARMv8-instruction-sets/Addressing)

- 5: An Introduction to the ARMv8 Instruction Sets - 5.1 The ARMv8 instruction sets - 5.1.2 Addressing - Increased PC-relative offset addressing
