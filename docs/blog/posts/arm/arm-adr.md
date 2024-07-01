---
title: ARM ADR (PC-relative)
authors:
    - xman
date:
    created: 2023-06-07T09:00:00
categories:
    - arm
tags:
    - instruction
comments: true
---

The `ADR` instruction forms address of a label at a PC-relative offset.

It loads an address within a certain range, without performing a data load.

<!-- more -->

## A32

[Arm A-profile A32/T32 Instruction Set Architecture](https://developer.arm.com/documentation/ddi0597/latest/Base-Instructions/ADR--Form-PC-relative-address-?lang=en) | ADR (PC-relative)
[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest/A32-and-T32-Instructions/ADR--PC-relative-) ｜ 3: A32 and T32 Instructions - 3.19 ADR (PC-relative)
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest/A32-and-T32-Instructions/ADR--PC-relative---A32-) | 14. A32 and T32 Instructions - 14.10 ADR (PC-relative)

Generate a PC-relative address in the destination register, for a label in the current area.

**Syntax**

```asm
ADR{cond}{.W} Rd,label
```

> `label` is a PC-relative expression.
> `label` must be within a limited distance of the current instruction.

**instruction**

This instruction is used by the alias [SUB (immediate, from PC)](https://developer.arm.com/documentation/ddi0597/latest/Base-Instructions/SUB--immediate--from-PC---Subtract-from-PC--an-alias-of-ADR-?lang=en).
This instruction is used by the pseudo-instruction [SUB (immediate, from PC)](https://developer.arm.com/documentation/ddi0597/latest/Base-Instructions/SUB--immediate--from-PC---Subtract-from-PC--an-alias-of-ADR-?lang=en).

```c title="ADR Rd, label - imm"
constant d = UInt(Rd);
constant imm32 = A32ExpandImm(imm12);
constant add = TRUE;
```

`<label>`: For encoding A1 and A2: the label of an instruction or literal data item whose address is to be loaded into <Rd\>. The assembler calculates the required value of the offset from the Align(PC, 4) value of the `ADR` instruction to this label.

```c title="ADR Rd, label - Operation"
if ConditionPassed() then
    EncodingSpecificOperations();
    constant result = if add then (Align(PC32,4) + imm32) else (Align(PC32,4) - imm32);
    if d == 15 then          // Can only occur for A32 encodings
        ALUWritePC(result);
    else
        R[d] = result;
```

**Oﬀset range and architectures**

The assembler calculates the oﬀset from the PC for you. The assembler generates an error if label is out of range.

The following table shows the possible oﬀsets between the label and the current instruction:

Table 14-2. PC-relative offsets

Instruction                     | Oﬀset range
--------------------------------|------------
A32 `ADR`                       | See Syntax of [Operand2 as a constant](https://developer.arm.com/documentation/dui0802/b/A32-and-T32-Instructions/Operand2-as-a-constant?lang=en)
T32 `ADR`, 32-bit encoding      | ±4095
T32 `ADR`, 16-bit encoding ^a^  | 0-1020 ^b^

- ^a: `Rd` must be in the range `R0`-`R7`.
- ^b: Must be a multiple of 4.

> ADD/SUB Operand2 / `imm12` is an 12 bit unsigned immediate, in the range [0, 4095].

**Usage**

1. `ADR` produces position-independent code, because the assembler generates an instruction that adds or subtracts a value to the `PC`.

2. Use the `ADRL` pseudo-instruction to assemble a *wider* range of eﬀective addresses.

3. `label` must evaluate to an address in the *same* assembler area(code section) as the `ADR` instruction.

### example

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 7. Writing A32/T32 Assembly Language - 7.10 Load addresses to a register using ADR

The `ADR` instruction loads an address within a certain range, without performing a data load.

`ADR` accepts a PC-relative expression, that is, a label with an optional oﬀset where the address of the label is relative to the PC.

Example of a jump table implementation with ADR:

This example shows A32 code that implements a jump table. Here, the `ADR` instruction loads the address of the jump table.

```asm
        AREA   Jump, CODE, READONLY ; Name this block of code
        ARM                         ; Following code is A32 code
num     EQU    2                    ; Number of entries in jump table
        ENTRY                       ; Mark first instruction to execute
start                               ; First instruction to call
        MOV    r0, #0               ; Set up the three arguments
        MOV    r1, #3
        MOV    r2, #2
        BL     arithfunc            ; Call the function
stop
        MOV    r0, #0x18            ; angel_SWIreason_ReportException
        LDR    r1, =0x20026         ; ADP_Stopped_ApplicationExit
        SVC    #0x123456            ; AArch32 semihosting (formerly SWI)
arithfunc                           ; Label the function
        CMP    r0, #num             ; Treat function code as unsigned
                                    ; integer
        BXHS   lr                   ; If code is >= num then return
        ADR    r3, JumpTable        ; Load address of jump table
        LDR    pc, [r3,r0,LSL #2]   ; Jump to the appropriate routine
JumpTable
        DCD    DoAdd
        DCD    DoSub
DoAdd
        ADD    r0, r1, r2           ; Operation 0
        BX     lr                   ; Return
DoSub
        SUB    r0, r1, r2           ; Operation 1
        BX     lr                   ; Return
        END                         ; Mark the end of this file
```

In this example, the function arithfunc takes three arguments and returns a result in R0. The first argument determines the operation to be carried out on the second and third arguments: 

- **argument1=0**: Result = argument2 + argument3.
- **argument1=1**: Result = argument2 - argument3.

The `LDR PC,[R3,R0,LSL #2]` instruction loads the address of the required clause of the jump table into the PC. It:

1. Multiplies the clause number in `R0` by 4 to give a word oﬀset.
2. Adds the result to the address of the jump table(`R3`).
3. Loads the contents of the combined address into the `PC`.

---

[ARM Assembly Language: Fundamentals and Techniques, 2nd Edition](https://www.oreilly.com/library/view/arm-assembly-language/9781482229851/) | Chapter 5: Loads, Stores, and Addressing - 5.4 OPERAND ADDRESSING

EXAMPLE 5.4: Consider a simple ARM7TDMI program that moves a string of characters from one memory location to another.

```asm
SRAM_BASE   EQU 0X04000000      ; start of SRAM for STR910FM32
            AREA StrCopy, CODE
            ENTRY               ; mark the first instruction
Main
            ADR r1, srcstr      ; pointer to the first string
            LDR r0, =SRAM_BASE  ; pointer to the second string
strcopy
            LDRB r2, [r1], #1   ; load byte, update address
            STRB r2, [r0], #1   ; store byte, update address
            СМР r2, #0          ; check for zero terminator
            BNE strcopy         ; keep going if not

stop        B stop ; terminate the program
srcstr      DCB "This is my (source) string", 0
            END
```

We can use `ADR` to load the address of our source string into register `r1`.

## A64

[Arm A-profile A64 Instruction Set Architecture](https://developer.arm.com/documentation/ddi0602/latest/Base-Instructions/ADR--Form-PC-relative-address-?lang=en) | ADR
[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest/A64-General-Instructions/ADR) ｜ 5: A64 General Instructions - 5.11 ADR
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest/A64-General-Instructions/ADR--A64-) | 17. A64 General Instructions - 17.11 ADR : Form PC-relative address

Address of label at a PC-relative offset.

**Syntax**

```asm
ADR Xd, label
```

> `label` is the program label whose address is to be calculated. It is an offset from the address of this instruction, in the range ±1MB.

**Instruction**

```c title="ADR Xd, label - imm"
integer d = UInt(Rd);
bits(64) imm = SignExtend(immhi:immlo, 64);
```

`<label>` is the program label whose address is to be calculated. Its offset from the address of this instruction, in the range ±1MB, is encoded in "immhi:immlo"((23:5)<<2 | 30:29).

```c title="ADR Xd, label - Operation"
X[d, 64] = PC64 + imm;
```

**Usage**

Form PC-relative address adds an immediate value to the PC value to form a PC-relative address, and writes the result to the destination register.

### example

[A64 Instruction Set Architecture Guide](https://developer.arm.com/documentation/102374/latest) | 7. Registers in AArch64 - other registers

The Program Counter (`PC`) is not a general-purpose register in A64, and it cannot be used with data processing instructions. The `PC` can be read using:

```asm
ADR Xd, .
```

The `ADR` instruction returns the address of a label, calculated based on the current location. Dot (`.`) means ‘here’, so the shown instruction is returning the address of itself. This is equivalent to reading the `PC`. Some branch instructions, and some load/store operations, implicitly use the value of the `PC`.

## references

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest/A32-and-T32-Instructions/Memory-access-instructions)

- 3: A32 and T32 Instructions - 3.3 Memory access instructions

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest/An-Introduction-to-the-ARMv8-Instruction-Sets/The-ARMv8-instruction-sets/Addressing)

- 5: An Introduction to the ARMv8 Instruction Sets - 5.1 The ARMv8 instruction sets - 5.1.2 Addressing - Increased PC-relative offset addressing
