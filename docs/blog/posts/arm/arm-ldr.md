---
title: ARM LDR Literal and Pseudo instructions
authors:
    - xman
date:
    created: 2023-06-06T09:00:00
categories:
    - arm
tags:
    - AArch64
    - AArch32
comments: true
---

There are three fundamental addressing modes in AArch64 instructions: register offset, immediate offset, and literal.

The pseudo addressing mode allows an immediate data value or the address of a label to be loaded into a register, and may result in the assembler generating more than one instruction.

- Literal: `label`
- Pseudo load: `=<immediate|symbol>`

<!-- more -->

## LDR (PC-relative)

### A32

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest) ｜ 3: A32 and T32 Instructions - 3.47 LDR (PC-relative)
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 14. A32 and T32 Instructions - 14.51 LDR (PC-relative)

Load register. The address is an oﬀset from the PC.

**Syntax**

```asm
LDR{type}{cond}{.W} Rt, label
```

> `label` is a PC-relative expression.
> `label` must be within a limited distance of the current instruction.

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

**Instruction**

[Arm A-profile A32/T32 Instruction Set Architecture | LDR (literal)](https://developer.arm.com/documentation/ddi0597/2024-03/Base-Instructions/LDR--literal---Load-Register--literal--?lang=en)

A1 (!(P == 0 && W == 1))

- `LDR{<c>}{<q>} <Rt>, <label>` // (Normal form)
- `LDR{<c>}{<q>} <Rt>, [PC, #{+/-}<imm>]` // (Alternative form)

```asm
if P == '0' && W == '1' then SEE "LDRT";
constant t = UInt(Rt);  constant imm32 = ZeroExtend(imm12, 32);
constant add = (U == '1');  constant wback = (P == '0') || (W == '1');
if wback then UNPREDICTABLE;
```

<imm12\>: For encoding A1: is the 12-bit(11:0) unsigned immediate byte offset, in the range 0 to 4095, defaulting to 0 if omitted, and encoded in the "imm12" field.

### A64

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest) ｜ 6: A64 Data Transfer Instructions - 6.18 LDR (literal)
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 18. A64 Data Transfer Instructions - 18.32 LDR (literal)

Load register (PC-relative literal).

**Syntax**

```asm
LDR Wt, label ; 32-bit general registers
LDR Xt, label ; 64-bit general registers
```

> `label`: Is the program label from which the data is to be loaded. It is an offset from the address of this instruction, in the range ±1MB.

**Usage**

Load Register (literal) calculates an address from the PC value and an immediate oﬀset, loads a ==word== from memory, and writes it to a register. For information about memory accesses, see *Load/Store addressing modes* in the [Arm Architecture Reference Manual Armv8, for Armv8-A architecture proﬁle](https://developer.arm.com/documentation/ddi0487/latest).

For example:

```asm
len:    .word   0x20
.equ    offset, 0x20

// ...

ldr x2, len             // x2 = 0x20
ldr x3, offset          // ldr x3, [pc+0x20] => x3 = *(pc+0x20)
```

**Instruction**

[Arm A-profile A64 Instruction Set Architecture | LDR (literal)](https://developer.arm.com/documentation/ddi0602/2024-03/Base-Instructions/LDR--literal---Load-Register--literal--?lang=en)

64-bit (opc == 01) : `LDR <Xt>, <label>`

```asm
integer t = UInt(Rt);
constant integer size = 4 << UInt(opc<0>);
boolean nontemporal = FALSE;
boolean tagchecked = FALSE;

bits(64) offset = SignExtend(imm19:'00', 64);
```

<label\> is the program label from which the data is to be loaded. Its offset from the address of this instruction, in the range +/-1MB, is encoded as "imm19"(23:5) times 4(Align(PC, 4)).

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

The oﬀset from the PC to the value in the literal pool must be less than ±4KB (in an A32 or 32-bit T32 encoding) or in the range 0 to +1KB (16-bit T32 encoding). You are responsible for ensuring that there is a literal pool within range.

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

#### LDR Rd,=const

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 7. Writing A32/T32 Assembly Language - 7.7 Load immediate values using LDR Rd, =const

The `LDR Rd,=const` pseudo-instruction generates the most eﬃcient single instruction to load any 32-bit ==number==.

You can use this pseudo-instruction to generate constants that are out of range of the `MOV` and `MVN` instructions.

The `LDR` pseudo-instruction generates the most eﬃcient single instruction for the speciﬁed immediate value:

- If the immediate value can be constructed with a single `MOV` or `MVN` instruction, the assembler generates the appropriate instruction.
- If the immediate value cannot be constructed with a single `MOV` or `MVN` instruction, the assembler:

    - Places the value in a literal pool (a portion of memory embedded in the code to hold constant values).
    - Generates an `LDR` instruction with a PC-relative address that reads the constant from the literal pool.

For example:

```asm
    LDR      rn, [pc, #offset to literal pool]
                          ; load register n with one word
                          ; from the address [pc + offset]
```

You must ensure that there is a literal pool within range of the `LDR` instruction generated by the assembler.

!!! example "stack pointer initialized"

    ```asm
    STACK_BASE EQU 0x20000200
    LDR sp, =STACK_BASE

    SRAM_BASE EQU 0x40000000 ; start of RAM on LPC2132
    LDR sp, =SRAM_BASE ; MOV r13, #SRAM_BASE
    ```

#### LDR Rd,=label

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 7. Writing A32/T32 Assembly Language - 7.12 Load addresses to a register using LDR Rd, =label

The `LDR Rd,=label` pseudo-instruction places an address in a literal pool and then loads the ==address== into a register.

The assembler converts an `LDR Rd,=label` pseudo-instruction by:

- Placing the address of *label* in a literal pool (a portion of memory embedded in the code to hold constant values).
- Generating a PC-relative `LDR` instruction that reads the address from the literal pool, for example:

```asm
LDR rn [pc, #offset_to_literal_pool]
                                    ; load register n with the address pc + offset
```

You must ensure that the literal pool is within range of the `LDR` pseudo-instruction that needs to access it.

---

***Example*** of loading using `LDR Rd, =label`

The following example shows a section with two literal pools. The ﬁnal `LDR` pseudo-instruction needs to access the second literal pool, but it is out of range. Uncommenting this line causes the assembler to generate an error.

The instructions listed in the comments are the A32 instructions generated by the assembler.

1. By default, a literal pool is placed at every END directive.

    - Directive `LTORG` forces the assembler to build literal pool 1 between the two subroutines;
    - Literal Pool 2 is automatically inserted after the `END` directive;

2. the first `LDR r3` in `func2` could use Literal Pool 1 to create a PC-relative offset, whereas the second `LDR r4` couldn't share Literal Pool 1, it would place in Literal Pool 2.

3. distance between `LDR r4` and Literal Pool 2 is farther than 8000, overflow 4095.

```asm
; refer to ARM Assembly Language
;   6.3 LOADING CONSTANTS INTO REGISTERS, Example
;   6.5 LOADING ADDRESSES INTO REGISTERS, EXAMPLE 6.5

        AREA   LDRlabel, CODE, READONLY
        ENTRY                     ; Mark first instruction to execute
start
        BL     func1              ; Branch to first subroutine
        BL     func2              ; Branch to second subroutine
stop
        MOV    r0, #0x18          ; angel_SWIreason_ReportException
        LDR    r1, =0x20026       ; ADP_Stopped_ApplicationExit
        SVC    #0x123456          ; AArch32 semihosting (formerly SWI)
func1
        LDR    r0, =start         ; => LDR r0,[PC, #offset into Literal Pool 1]
        LDR    r1, =Darea + 12    ; => LDR r1,[PC, #offset into Literal Pool 1]
        LDR    r2, =Darea + 6000  ; => LDR r2,[PC, #offset into Literal Pool 1]
        BX     lr                 ; Return
        LTORG                     ; Literal Pool 1
func2
        LDR    r3, =Darea + 6000  ; => LDR r3,[PC, #offset into Literal Pool 1]
                                  ; (sharing with previous literal)
        ; LDR   r4, =Darea + 6004 ; If uncommented, produces an error because
                                  ; Literal Pool 2 is out of range.
        BX     lr                 ; Return
Darea   SPACE  8000               ; Starting at the current location, clears
                                  ; a 8000 byte area of memory to zero.
        END                       ; Literal Pool 2 is automatically inserted
                                  ; after the END directive.
                                  ; It is out of range of all the LDR
                                  ; pseudo-instructions in this example.
```

***Example*** of string copy

The example also shows how, unlike the `ADR` and `ADRL` pseudo-instructions, you can use the `LDR` pseudo-instruction with labels that are *outside* the current section. The assembler places a *relocation* directive in the object code when the source ﬁle is assembled. The relocation directive instructs the linker to *resolve* the address at link time. The address remains valid wherever the linker places the section containing the `LDR` and the literal pool.

```asm
; refer to ARM Assembly Language, 5.4 OPERAND ADDRESSING, EXAMPLE 5.4

        AREA    StrCopy, CODE, READONLY
        ENTRY                       ; Mark first instruction to execute
start
        LDR     r1, =srcstr         ; Pointer to first string
        LDR     r0, =dststr         ; Pointer to second string
        BL      strcopy             ; Call subroutine to do copy
stop
        MOV     r0, #0x18           ; angel_SWIreason_ReportException
        LDR     r1, =0x20026        ; ADP_Stopped_ApplicationExit
        SVC     #0x123456           ; AArch32 semihosting (formerly SWI)
strcopy
        LDRB    r2, [r1],#1         ; Load byte and update address
        STRB    r2, [r0],#1         ; Store byte and update address
        CMP     r2, #0              ; Check for zero terminator
        BNE     strcopy             ; Keep going if not
        MOV     pc,lr               ; Return
        AREA    Strings, DATA, READWRITE
srcstr  DCB     "First string - source",0
dststr  DCB     "Second string - destination",0
        END
```

### A64

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest) ｜ 6: A64 Data Transfer Instructions - 6.19 LDR pseudo-instruction
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 18. A64 Data Transfer Instructions - 18.33 LDR pseudo-instruction

Load a register with either a 32-bit or 64-bit immediate value or an address.

**Syntax**:

```asm
LDR Wd, =expr
LDR Xd, =expr
LDR Wd, =label_expr
LDR Xd, =label_expr
```

> `expr` evaluates to a numeric value.
> `label_expr` is a PC-relative or external expression of an address in the form of a label plus or minus a numeric value.

**Usage**:

When using the LDR pseudo-instruction, the assembler places the value of `expr` or `label_expr` in a *literal pool* and generates a PC-relative `LDR` instruction that reads the constant from the literal pool.

!!! note "LDR Rd, =label is not PIC"

    - An address loaded in this way is ﬁxed at link time, so the code is not position independent.
    - The address holding the constant remains valid regardless of where the linker places the ELF section containing the `LDR` instruction.

If `label_expr` is an external expression, or is not contained in the current section, the assembler places a linker relocation directive in the object ﬁle. The linker generates the address at link time.

If `label_expr` is a local label, the assembler places a linker relocation directive in the object ﬁle and generates a symbol for that local label. The address is generated at link time.

The oﬀset from the PC to the value in the literal pool must be less than ±1MB . You are responsible for ensuring that there is a literal pool within range.

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
