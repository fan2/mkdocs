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

The pseudo addressing mode instruction `LDR` allows an immediate data value or the address of a label to be loaded into a register. The `ADR` instruction forms address of a label at a PC-relative offset.

Since both the `LDR` pseudo-instruction and the `ADRP` instruction can load the address of a label, and the `LDR` pseudo-instruction can address the 64-bit address space, and the addressing range of the `ADRP` instruction is the current PC address ±4GB, then what is the necessity of having an `ADRP` instruction when there's already an `LDR` pseudo-instruction?

<!-- more -->

## LDR or ADR?

An address loaded using the `LDR` pseudo-instruction is ﬁxed at link time, so the code is *not* position independent. The address holding the constant remains valid regardless of where the linker places the ELF section containing the `LDR` instruction.

Meanwhile, `ADR` produces position-independent(*PIC*) code, because the assembler generates an instruction that adds or subtracts a value to the `PC`. The expansive `ADRL` pseudo-instruction produces position-independent code too, because the address is PC-relative or register-relative.

the label used with `ADR` or `ADRL` must be within the ***same*** code section. If a label is out of range in the same section, the assembler faults the reference. As an aside, if a label is out of range in other code sections, the linker faults the reference.

if you plan to reference labels in ***other*** sections of code, or you know that a literal table will exist and you don’t mind the extra cycles used to fetch the literal from memory. Use the same caution with literal pools that you would for the construct `LDR <Rd>, = constant`.

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 7. Writing A32/T32 Assembly Language - 7.12 Load addresses to a register using LDR Rd, =label

The example of string copy also shows how, unlike the `ADR` and `ADRL` pseudo-instructions, you can use the `LDR` pseudo-instruction with labels that are *outside* the current section. The assembler places a *relocation* directive in the object code when the source ﬁle is assembled. The relocation directive instructs the linker to **resolve** the address at link time. The address remains valid wherever the linker places the section containing the `LDR` and the literal pool.

[ARM 64-Bit Assembly Language](https://www.amazon.com/64-Bit-Assembly-Language-Larry-Pyeatt/dp/0128192216/) | 3 Load/store and branch instructions - 3.5 Branch instructions - 3.5.5 Form PC-relative address

The `ADR` instruction is helpful for calculating the address of labels at run-time. This is particularly useful when the address of a label must be passed to a function as an argument, but the address cannot be determined at compile time. For example, the address of some system libraries may not be set by the linker, but are set when the program is loaded and prepared to run. The addresses of labels in these libraries cannot be loaded with the `ldr Rx,=label` syntax, because the assembler and linker cannot predict the location of the label. The `ADR` instruction provides a way to get the address of the label.

## ADR locates label faster within ±4K

[Modern Arm Assembly Language Programming: Covers Armv8-A 32-bit, 64-bit, and SIMD](https://www.amazon.com/Modern-Assembly-Language-Programming-Armv8/dp/1484262662/) | Chapter 9: Armv8-32 SIMD Floating-Point Programming - Packed Floating-Point Arithmetic - Conversions

```asm title="Ch09_03_.s"
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

Figure 9-1. Jump table CvtTab location counter label offsets for example Ch09_03

## Considerations and decision-making

[ARM Assembly Language: Fundamentals and Techniques, 2nd Edition](https://www.oreilly.com/library/view/arm-assembly-language/9781482229851/) | Chapter 6: Constants and Literal Pools - 6.5 LOADING ADDRESSES INTO REGISTERS

At some point, you will need to load the address of a label or symbol into a register. Usually you do this to give yourself a starting point of a table, a list, or maybe a set of coefficients that are needed in a digital filter. For example, consider the ARM7TDMI code fragment below.

```asm
SRAM_BASE   EQU 0X04000000          ; start of SRAM for STR910FM32/LPC2132
            AREA FILTER, CODE

dest        RNO ; destination pointer
image       RN1 ; image data pointer
coeff       RN2 ; coefficient table pointer
pointer     RN3 ; temporary pointer
            ENTRY
            CODE32
Main
        ; initialization area
        LDR dest, =#SRAM_BASE   ; move memory base into dest(r0)
        MOV pointer, dest       ; current pointer(r3) is destination
        ADR image, image_data   ; load image data pointer
        ADR coeff, consines     ; load coefficient pointer
        BL filter               ; execute one pass of filter
```

The first two instructions load a known address (called an absolute address, since it doesn’t move if you relocate your code in memory) into registers `r0` and `r3`. The third and fourth instructions are the pseudo-instruction `ADR`, which is particularly useful at loading addresses into a register. Why do it this way? Suppose that this section of code was to be used along with other blocks. You wouldn’t necessarily know exactly where your data starts once the two sections are assembled, so it’s easier to let the assembler **calculate** the addresses for you. As an example, if `image_data` actually started at address 0x8000 in memory, then this address gets moved into register `r1`, which we’ve renamed. However, if we change the code, move the image data, or add another block of code that we write later, then this address will change. By using `ADR`, we don’t have to worry about the address.

Let’s examine another example, this time to see how the `ADR` pseudo-instruction actually gets converted into real ARM instructions. Again, the code in this example doesn’t actually do anything except set up pointers, but it will serve to illustrate how `ADR` behaves.

```asm title="EXAMPLE 6.4"
        AREA    adrlabel,CODE,READONLY
        ENTRY                       ; mark first instruction to execute

Start   BL      func                ; branch to subroutine 
stop    B       stop                ; terminate 
        LTORG                       ; create a literal pool 
func    ADR     r0, Start           ; => SUB r0, PC, #offset to Start 
        ADR     r1, DataArea        ; => ADD r1, PC, #offset to DataArea 
        ;ADR    r2, DataArea + 4300 ; This would fail because the offset 
                                    ; cannot be expressed by operand2 of ADD 
        ADRL    r2, DataArea + 4300 ; => ADD r2, PC, #offset1 
                                    ; ADD r2, r2, #offset2 
        BX      lr                  ; return

DataArea
        SPACE   8000                ; starting at the current location, 
                                    ; clears an 8000-byte area of memory to 0
        END
```

You will note that the program calls a subroutine called `func`, using a branch and link operation (`BL`). The next instruction is for ending the program, so we really only need to examine what happens after the `LTORG` directive. The subroutine begins with a label, `func`, and an `ADR` pseudo-instruction to load the starting address of our main program into register `r0`. The assembler actually creates either an `ADD` or `SUB` instruction with the Program Counter to do this. Similar to the `LDR` pseudo-instruction we saw previously, by knowing the value of the Program Counter at the time when this `ADD` or `SUB` reaches the execute stage of the pipeline, we can simply take that value and modify it to **generate** an address. The catch is that the offset must be a particular type of number. For ARM instructions, that number must be one that can be created using a byte value rotated by an even number of bits, exactly as we saw in Section 6.2 (if rejected by the assembler, it will generate an error message to indicate that an offset cannot be represented by 0–255 and a rotation). For 32-bit Thumb instructions, that number must be within ±4095 bytes of a byte, half-word, or word-aligned address. If you notice the second `ADR` in this example, the distance between the instruction and the label DataArea is small enough that the assembler will use a simple `ADD` instruction to create the constant.

The third `ADR` tries to create an address where the label is on the other side of an 8000-byte block of memory. This doesn’t work, but there is another pseudo-instruction: `ADRL`. Using *two* operations instead of one, the `ADRL` will calculate an offset that is within a range based on the addition of two values now, both created by the byte rotation scheme mentioned above (for ARM instructions). There is a fixed range for 32-bit Thumb instructions of ±1MB. You should note that if you invoke an `ADRL` pseudo-instruction in your code, it will generate two operations even if it could be done using only one, so be careful in loops that are sensitive to cycle counts. One other important point worth mentioning is that the label used with `ADR` or `ADRL` must be within the ***same*** code section. If a label is out of range in the same section, the assembler faults the reference. As an aside, if a label is out of range in other code sections, the linker faults the reference.

> `ADR r2, DataArea + 4300`: ADD `imm` is an unsigned immediate, in the range [0, 4095].

There is yet another way of loading addresses into registers, and it is exactly the same as the `LDR` pseudo-instruction we saw earlier for loading constants. The syntax is

```asm
LDR <Rd>, =label
```

In this instance, the assembler will **convert** the pseudo-instruction into a load instruction, where the load reads the address from a literal pool that it creates. As with the case of loading constants, you must ensure that a literal pool is *within* range of the instruction. This pseudo-instruction differs from `ADR` and `ADRL` in that labels *outside* of a section can be referenced, and the linker will **resolve** the reference at link time.

The example below shows a few of the ways the `LDR` pseudo-instruction can be used, including using labels with their own offsets.

```asm title="EXAMPLE 6.5"
; refer to ## armasm_user_guide, 7.12 Load addresses to a register using LDR Rd, =label, Example

        AREA    IDRlabel, CODE, READONLY
        ENTRY                       ; Mark first instruction to execute
start
        BL      func1               ; branch to first subroutine
        BL      func2               ; branch to second subroutine
stop    B       stop                ; terminate

func1
        LDR     r0, =start          ;=> LDR RO, [PC, #offset into Literal Pool 1]
        LDR     r1, =Darea + 12     ;=> LDR R1, [PC, #offset into Lit. Pool 1]
        LDR     r2, =Darea + 6000   ;=> LDR R2, [PC, #offset into Lit. Pool 1]
        BX      lr                  ; return

        LTORG
func2
        LDR     r3, =Darea + 6000   ;=> LDR R3, [PC, #offset into Lit. Pool 1]
                                    ; (sharing with previous literal)
        ; LDR    r4, =Darea +6004   ; if uncommented produces an error
                                    ; as literal pool 2 is out of range
        BX          lr              ; return
Darea
        SPACE    8000               ; starting at the current location, clears
                                    ; an 8000-byte area of memory to zero
        END                         ; literal pool 2 is out of range of the LDR
                                    ; instructions above
```

You can see the first three `LDR` statements in the subroutine `func1` would actually be PC-relative loads from a literal pool that would exist in memory at the `LTORG` statement. Additionally, the first load statement in the second subroutine could use the *same* literal pool to create a PC-relative offset. As the `SPACE` directive has cleared an 8000-byte block of memory, the second load instruction cannot reach the second literal pool, since it must be *within* 4 kilobytes(12 bits, ±4095).

**So to summarize**:

Use the pseudo-instruction

```asm
ADR <Rd>, label
```

to put an address into a register whenever possible. The address is created by adding or subtracting an *offset* to/from the `PC`, where the offset is **calculated** by the assembler.

- If the above case fails, use the `ADRL` pseudo-instruction, which will calculate an offset using *two* separate `ADD` or `SUB` operations. Note that if you invoke an `ADRL` pseudo-instruction in your code, it will generate two operations even if it could be done using only one.

```asm
; EXAMPLE 6.4
        ADRL    r2, DataArea + 4300 ; => ADD r2, PC, #offset1 
                                    ; ADD r2, r2, #offset2 
```

Use the pseudo-instruction

```asm
LDR <Rd>, =label
```

if you plan to reference labels in ***other*** sections of code, or you know that a literal table will exist and you don’t mind the extra cycles used to fetch the literal from memory. Use the same caution with literal pools that you would for the construct

```asm
LDR <Rd>, = constant
```

Consult the Assembler User’s Guide (ARM 2008a) for more details on the use of `ADR`, `ADRL` and `LDR` for loading addresses.

---

!!! warning "Copyright clarification"

    Copyright belongs to the original author. 🫡
    Excerpt/quotation for study only, non-commercial.
