---
title: ARM LDR literal and pseudo-instruction
authors:
    - xman
date:
    created: 2023-06-06T09:00:00
categories:
    - arm
tags:
    - instruction
comments: true
---

The AArch64 architecture is a classic example of a *load-store* architecture.

There are three fundamental addressing modes in AArch64 instructions: register offset, immediate offset, and literal.

The `LDR` instruction is either an ordinary memory access instruction or a pseudo-instruction that loads an address in a large range. When its second parameter is preceded by "`=`", it represents a pseudo-instruction.

The pseudo addressing mode allows an immediate data value or the address of a label to be loaded into a register, and may result in the assembler generating more than one instruction.

- Literal: `label`
- Pseudo load: `=<immediate|symbol>`

<!-- more -->

## Addressing modes

[ARM 64-Bit Assembly Language](https://www.amazon.com/64-Bit-Assembly-Language-Larry-Pyeatt/dp/0128192216/) | 3 Load/store and branch instructions - 3.3 Instruction components - 3.3.3 Addressing modes

The AArch64 architecture has a strict separation between instructions that perform computation and those that move data between the CPU and memory. Computational instructions can only modify registers, not main memory. Because of this separation between load/store operations and computational operations, it is a classic example of a ***load-store*** architecture.

All *computational* instructions assume that the registers already contain the data. *Load* instructions are used to move data from memory into the registers, and *store* instructions are used to move data from the registers to memory.

## LDR (PC-relative)

### A32

[Arm A-profile A32/T32 Instruction Set Architecture](https://developer.arm.com/documentation/ddi0597/2024-03/Base-Instructions/LDR--literal---Load-Register--literal--?lang=en) | LDR (literal)
[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest) ｜ 3: A32 and T32 Instructions - 3.47 LDR (PC-relative)
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 14. A32 and T32 Instructions - 14.51 LDR (PC-relative)

Load register. The address is an oﬀset from the PC.

**Syntax**

```asm
LDR{type}{cond}{.W} Rt, label
```

> `label` is a PC-relative expression.
> `label` must be within a limited distance of the current instruction.

**Instruction**

A1 (!(P == 0 && W == 1))

- `LDR{<c>}{<q>} <Rt>, <label>` // (Normal form)
- `LDR{<c>}{<q>} <Rt>, [PC, #{±}<imm>]` // (Alternative form)

```c title="LDR Rt, label - imm"
if P == '0' && W == '1' then SEE "LDRT";
constant t = UInt(Rt);  constant imm32 = ZeroExtend(imm12, 32);
constant add = (U == '1');  constant wback = (P == '0') || (W == '1');
if wback then UNPREDICTABLE;
```

`<imm12>`: For encoding A1: is the 12-bit(11:0) unsigned immediate byte offset, in the range 0 to 4095, defaulting to 0 if omitted, and encoded in the "imm12" field.

```c title="LDR Rt, label - Operation"
if ConditionPassed() then
    EncodingSpecificOperations();
    constant base = Align(PC32,4);
    constant address = if add then (base + imm32) else (base - imm32);
    constant data = MemU[address,4];
    if t == 15 then
        if address<1:0> == '00' then
            LoadWritePC(data);
        else
            UNPREDICTABLE;
    else
        R[t] = data;
```

**Oﬀset range and architectures**

The assembler calculates the oﬀset from the `PC` for you. The assembler generates an error if label is out of range.

The following table shows the possible oﬀsets between the label and the current instruction:

Table 14-11: PC-relative offsets

Instruction                                 | Offset range
--------------------------------------------|-------------
A32 LDR, LDRB, LDRSB, LDRH, LDRSH           | ±4095
A32 LDRD                                    | ±255
32-bit T32 LDR, LDRB, LDRSB, LDRH, LDRSH    | ±4095
32-bit T32 LDRD                             | ±1020
16-bit T32 LDR                              | 0-1020

### A64

[Arm A-profile A64 Instruction Set Architecture](https://developer.arm.com/documentation/ddi0602/2024-03/Base-Instructions/LDR--literal---Load-Register--literal--?lang=en) | LDR (literal)
[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest) ｜ 6: A64 Data Transfer Instructions - 6.18 LDR (literal)
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 18. A64 Data Transfer Instructions - 18.32 LDR (literal)

Load register (PC-relative literal).

**Syntax**

```asm
LDR Wt, label ; 32-bit general registers
LDR Xt, label ; 64-bit general registers
```

> `label` is the program label from which the data is to be loaded. It is an ==offset== from the address of this instruction, in the range ±1MB.

**Instruction**

Load Register (literal) calculates an address from the PC value and an immediate offset, loads a word from memory, and writes it to a register.

```c title="LDR Xt, label - offset"
integer t = UInt(Rt);
constant integer size = 4 << UInt(opc<0>);
boolean nontemporal = FALSE;
boolean tagchecked = FALSE;

bits(64) offset = SignExtend(imm19:'00', 64);
```

`<label>` is the program label from which the data is to be loaded. Its offset from the address of this instruction, in the range ±1MB, is encoded as "imm19"(23:5) times 4(Align(PC, 4)).

```c title="LDR Xt, label - Operation"
bits(64) address = PC64 + offset;
boolean privileged = PSTATE.EL != EL0;
AccessDescriptor accdesc = CreateAccDescGPR(MemOp_LOAD, nontemporal, privileged, tagchecked);

X[t, size * 8] = Mem[address, size, accdesc];
```

**Usage**

Load Register (literal) calculates an address from the PC value and an immediate oﬀset, loads a ==word== from memory, and writes it to a register. For information about memory accesses, see *Load/Store addressing modes* in the [Arm Architecture Reference Manual Armv8, for Armv8-A architecture proﬁle](https://developer.arm.com/documentation/ddi0487/latest).

**Examples**

```asm
len:    .word   0x20
.equ    offset, 0x20

// ...

ldr x2, len             // x2 = 0x20
ldr x3, offset          // ldr x3, [pc+0x20] => x3 = *(pc+0x20)
```

## LDR pseudo-instruction

### A32

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest) | 3: A32 and T32 Instructions - 3.49 LDR pseudo-instruction
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 14. A32 and T32 Instructions - 14.54 LDR pseudo-instruction

Load a register with either a 32-bit immediate value or an address.

**Syntax**

```asm
LDR{cond}{.W} Rt, =expr
LDR{cond}{.W} Rt, =label_expr
```

> `expr` evaluates to a numeric value.
> `label_expr` is a PC-relative or external expression of an address in the form of a label plus or minus a numeric value.

**Usage**

When using the `LDR` pseudo-instruction:

- If the value of expr can be loaded with a valid `MOV` or `MVN` instruction, the assembler uses that instruction.
- If a valid `MOV` or `MVN` instruction cannot be used, or if the `label_expr` syntax is used, the assembler places the constant in a literal pool and generates a PC-relative `LDR` instruction that reads the constant from the literal pool.

!!! note "LDR Rd, =label is not PIC"

    - An address loaded in this way is ﬁxed at link time, so the code is not position-independent.
    - The address holding the constant remains valid regardless of where the linker places the ELF section containing the `LDR` instruction.

The assembler places the value of `label_expr` in a literal pool and generates a PC-relative `LDR` instruction that loads the value from the literal pool.

If `label_expr` is an external expression, or is not contained in the current section, the assembler places a linker relocation directive in the object ﬁle. The linker generates the address at link time.

If `label_expr` is either a named or numeric local label, the assembler places a linker relocation directive in the object ﬁle and generates a symbol for that local label. The address is generated at link time. If the local label references T32 code, the T32 bit (bit 0) of the address is set.

The ==oﬀset== from the PC to the value in the literal pool must be less than ±4KB (in an A32 or 32-bit T32 encoding) or in the range 0 to +1KB (16-bit T32 encoding). You are responsible for ensuring that there is a literal pool within range.

If the label referenced is in T32 code, the `LDR` pseudo-instruction sets the T32 bit (bit 0) of `label_expr`.

**Examples**

```asm
        LDR     r3,=0xff0    ; loads 0xff0 into R3
                             ; =>  MOV.W r3,#0xff0
        LDR     r1,=0xfff    ; loads 0xfff into R1
                             ; =>  LDR r1,[pc,offset_to_litpool]
                             ;     ...
                             ;     litpool DCD 0xfff
        LDR     r2,=place    ; loads the address of
                             ; place into R2
                             ; =>  LDR r2,[pc,offset_to_litpool]
                             ;     ...
                             ;     litpool DCD place
```

### A64

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest) ｜ 6: A64 Data Transfer Instructions - 6.19 LDR pseudo-instruction
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 18. A64 Data Transfer Instructions - 18.33 LDR pseudo-instruction

Load a register with either a 32-bit or 64-bit immediate value or an address.

**Syntax**

```asm
LDR Wd, =expr
LDR Xd, =expr
LDR Wd, =label_expr
LDR Xd, =label_expr
```

> `expr` evaluates to a numeric value.
> `label_expr` is a PC-relative or external expression of an address in the form of a label plus or minus a numeric value.

**Usage**

When using the LDR pseudo-instruction, the assembler places the value of `expr` or `label_expr` in a *literal pool* and generates a PC-relative `LDR` instruction that reads the constant from the literal pool.

!!! note "LDR Rd, =label is not PIC"

    - An address loaded in this way is ﬁxed at link time, so the code is not position independent.
    - The address holding the constant remains valid regardless of where the linker places the ELF section containing the `LDR` instruction.

If `label_expr` is an external expression, or is not contained in the current section, the assembler places a linker relocation directive in the object ﬁle. The linker generates the address at link time.

If `label_expr` is a local label, the assembler places a linker relocation directive in the object ﬁle and generates a symbol for that local label. The address is generated at link time.

The ==oﬀset== from the PC to the value in the literal pool must be less than ±1MB . You are responsible for ensuring that there is a literal pool within range.

**Examples**

```asm
        LDR     w1,=0xfff    ; loads 0xfff into W1

                             ; =>  LDR w1,[pc,offset_to_litpool]
                             ;     ...
                             ;     litpool DCD 4095

        LDR     x2,=place    ; loads the address of
                             ; place into X2
                             ; =>  LDR x2,[pc,offset_to_litpool]
                             ;     ...
                             ;     litpool DCQ place
        LDR     x3, [x2]     ; load value from pointer(place)
```

!!! example "load PC-relative address"

    ```asm
    ldr x1, =msg1
    adr x2, msg2
    ```

## references

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest)

- 3: A32 and T32 Instructions - 3.3 Memory access instructions

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest)

- 7\. Writing A32/T32 Assembly Language - 7.8 Literal pools
- 13.5 PC-relative expressions - 13. Symbols, Literals, Expressions, and Operators

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest)

- 5: An Introduction to the ARMv8 Instruction Sets - 5.1 The ARMv8 instruction sets - 5.1.2 Addressing - Increased PC-relative offset addressing
