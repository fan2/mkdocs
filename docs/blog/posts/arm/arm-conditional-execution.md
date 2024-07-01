---
title: ARM Conditional Execution
authors:
    - xman
date:
    created: 2023-06-14T12:00:00
categories:
    - arm
comments: true
---

In this article, we'll explore ARM program flow based on conditional execution.

<!-- more -->

## Program flow control

[Learn the architecture - A64 Instruction Set Architecture Guide](https://developer.arm.com/documentation/102374/latest) | Program flow & PCS

Ordinarily, a processor executes instructions in program order. This means that a processor executes instructions in the same order that they are set in memory. One way to change this order is to use *`branch`* instructions. Branch instructions change the program flow and are used for *loops*, *decisions* and *function calls*.

The A64 instruction set also has some *`conditional branch`* instructions. These are instructions that change the way they execute, based on the results of previous instructions.

!!! note "ROP protection"

    Armv8.3-A and Armv8.5-A introduced instructions to protect against return oriented programming(ROP) and jump-oriented programming.

    See GCC related [Instrumentation Options](https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html): `-fstack-protector`, `-fstack-check`, `-fstack-clash-protection`.

- loops and decisions: Unconditional, Conditional
- generating condition code
- conditional select instructions

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest/A32-and-T32-Instructions) | 3: A32 and T32 Instructions

- 3.24 `B`, `BL`, `BX`, and `BLX`: Branch, Branch with Link, Branch and exchange instruction set, Branch with Link and exchange instruction set.
- 3.27 `CBZ` and `CBNZ`: Compare and Branch on Zero, Compare and Branch on Non-Zero.
- 3.93 `TST` and `TEQ`: Test bits and Test Equivalence.

The instructions that can be conditional have an optional condition code, shown in syntax descriptions as *`{cond}`*. Table 5 shows the condition codes that you can use.

## Conditional execution

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 8. [Condition Codes](https://developer.arm.com/documentation/dui0801/l/Condition-Codes) - 8.2 Conditional execution in A32 code

Almost all A32 instructions can be executed conditionally on the value of the condition flags in the APSR. You can either add a condition code suffix to the instruction or you can conditionally skip over the instruction using a conditional branch instruction.

Using conditional branch instructions to control the flow of execution can be more efficient when a series of instructions depend on the same condition.

**Conditional instructions to control execution**

```asm
; flags set by a previous instruction
    LSLEQ r0, r0, #24
    ADDEQ r0, r0, #2
    ;...
```

**Conditional branch to control execution**

```asm
; flags set by a previous instruction
    BNE over
    LSL r0, r0, #24
    ADD r0, r0, #2
over
    ;...
```

---

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 5. [Overview of AArch64 state](https://developer.arm.com/documentation/dui0801/l/Overview-of-AArch64-state) - 5.8 Conditional execution in AArch64 state

In AArch64 state, the `NZCV` register holds copies of the N, Z, C, and V condition flags. The processor uses them to determine whether to execute conditional instructions. The NZCV register contains the flags in bits[31:28\].

The condition flags are accessible in all exception levels, using the `MSR` and `MRS` instructions.

A64 makes less use of conditionality than A32. For example, in A64:

- Only a few instructions can set or test the condition flags.
- There is no equivalent of the T32 `IT` instruction.
- The only conditionally executed instruction, which behaves as a NOP if the condition is false, is the conditional branch, `B.cond`.

---

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 8. [Condition Codes](https://developer.arm.com/documentation/dui0801/l/Condition-Codes) - 8.4 Conditional execution in A64 code

In the A64 instruction set, there are a few instructions that are truly conditional. Truly conditional means that when the condition is false, the instruction advances the program counter but has no other effect.

The conditional branch, `B.cond` is a truly conditional instruction. The condition code is appended to the instruction with a '`.`' delimiter, for example `B.EQ`.

There are other truly conditional branch instructions that execute depending on the value of the Zero condition flag. You cannot append any condition code suffix to them. These instructions are:

- `CBNZ`.
- `CBZ`.
- `TBNZ`.
- `TBZ`.

There are a few A64 instructions that are unconditionally executed but use the condition code as a source operand. These instructions always execute but the operation depends on the value of the condition code. These instructions can be categorized as:

- Conditional data processing instructions, for example `CSEL`.
- Conditional comparison instructions, `CCMN` and `CCMP`.

In these instructions, you specify the condition code in the final operand position, for example `CSEL Wd,Wm,Wn,NE`.

## Condition code suffixes

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest) | 3: A32 and T32 Instructions - 3.17 [Condition codes](https://developer.arm.com/documentation/dui0802/b/A32-and-T32-Instructions/Condition-codes) - Table 5. Condition code suffixes
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 8. [Condition Codes](https://developer.arm.com/documentation/dui0801/l/Condition-Codes) - 8.11 Condition code suffixes - Table 1. Condition code suffixes

| Suffix | Meaning                                   |
|--------|-------------------------------------------|
| `EQ`   | Equal                                     |
| `NE`   | Not equal                                 |
| `CS`   | Carry set (identical to HS)               |
| `HS`   | Unsigned higher or same (identical to CS) |
| `CC`   | Carry clear (identical to LO)             |
| `LO`   | Unsigned lower (identical to CC)          |
| `MI`   | Minus or negative result                  |
| `PL`   | Positive or zero result                   |
| `VS`   | Overflow                                  |
| `VC`   | No overflow                               |
| `HI`   | Unsigned higher                           |
| `LS`   | Unsigned lower or same                    |
| `GE`   | Signed greater than or equal              |
| `LT`   | Signed less than                          |
| `GT`   | Signed greater than                       |
| `LE`   | Signed less than or equal                 |
| `AL`   | Always (this is the default)              |

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 8. [Condition Codes](https://developer.arm.com/documentation/dui0801/l/Condition-Codes) - 8.12 [Condition code suffixes and related flags](https://developer.arm.com/documentation/dui0801/l/Condition-Codes/Condition-code-suffixes-and-related-flags)

Condition code suffixes define the conditions that must be met for the instruction to execute.

The following table shows the condition codes that you can use and the flag settings they depend on:

Table 1. Condition code suffixes and related flags

| Suffix       | Flags                     | Meaning                                  |
|--------------|---------------------------|------------------------------------------|
| `EQ`         | Z set                     | Equal                                    |
| `NE`         | Z clear                   | Not equal                                |
| `CS` or `HS` | C set                     | Higher or same (unsigned >= )            |
| `CC` or `LO` | C clear                   | Lower (unsigned < )                      |
| `MI`         | N set                     | Negative                                 |
| `PL`         | N clear                   | Positive or zero                         |
| `VS`         | V set                     | Overflow                                 |
| `VC`         | V clear                   | No overflow                              |
| `HI`         | C set and Z clear         | Higher (unsigned >)                      |
| `LS`         | C clear or Z set          | Lower or same (unsigned <=)              |
| `GE`         | N and V the same          | Signed >=                                |
| `LT`         | N and V differ            | Signed <                                 |
| `GT`         | Z clear, N and V the same | Signed >                                 |
| `LE`         | Z set, N and V differ     | Signed <=                                |
| `AL`         | Any                       | Always. This suffix is normally omitted. |

The optional condition code is shown in syntax descriptions as `{cond}`. This condition is encoded in A32 instructions and in A64 instructions. For T32 instructions, the condition is encoded in a preceding `IT` instruction. An instruction with a condition code is only executed if the condition flags meet the specified condition.

The following is an example of conditional execution in A32 code:

```asm
    ADD     r0, r1, r2    ; r0 = r1 + r2, don't update flags

    ADDS    r0, r1, r2    ; r0 = r1 + r2, and update flags
    ADDSCS  r0, r1, r2    ; If C flag set then r0 = r1 + r2,
                          ; and update flags
    CMP     r0, r1        ; update flags based on r0-r1.
```

## references

[ARM 64-Bit Assembly Language](https://www.amazon.com/64-Bit-Assembly-Language-Larry-Pyeatt/dp/0128192216/)

- 2 GNU assembly syntax - 2.3 GNU assembly directives - 2.3.6 Conditional assembly
- 3 Load/store and branch instructions - 3.3 Instruction components - 3.3.1 Setting and using condition flags
- 4 Data processing and other instructions - 4.2 Data processing instructions - 4.2.10 Conditional operations
- 5 Structured programming - 5.2 Selection - 5.2.2 If-then-else statement

[Programming with 64-Bit ARM Assembly Language](https://www.amazon.com/Programming-64-Bit-ARM-Assembly-Language/dp/1484258800/) | Chapter 4: Controlling Program Flow

- Unconditional Branch
- About Condition Flags
- Branch on Condition

[Arm Assembly Internals and Reverse Engineering](https://www.amazon.com/Blue-Fox-Assembly-Internals-Analysis/dp/1119745306) 

- Chapter 7 Conditional Execution
- Chapter 8 Control Flow
