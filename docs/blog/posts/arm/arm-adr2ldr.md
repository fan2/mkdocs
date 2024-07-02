---
title: ARM from ADR to LDR
authors:
    - xman
date:
    created: 2023-06-10T09:00:00
categories:
    - arm
tags:
    - instruction
comments: true
---

The pseudo addressing mode instruction `LDR` allows an immediate data value or the address of a label to be loaded into a register. The `ADR` instruction forms address of a label at a PC-relative offset.

<!-- more -->

[ARM Assembly Language: Fundamentals and Techniques, 2nd Edition](https://www.oreilly.com/library/view/arm-assembly-language/9781482229851/) | Chapter 6: Constants and Literal Pools - 6.5 LOADING ADDRESSES INTO REGISTERS

At some point, you will need to load the address of a label or symbol into a register. Usually you do this to give yourself a starting point of a table, a list, or maybe a set of coefficients that are needed in a digital filter. For example, consider the ARM7TDMI code fragment below.

## ADR

```asm linenums="1"
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

The first two instructions load a known address (called an absolute address, since it doesn't move if you relocate your code in memory) into registers `r0` and `r3`. The third and fourth instructions are the pseudo-instruction `ADR`, which is particularly useful at loading addresses into a register. Why do it this way? Suppose that this section of code was to be used along with other blocks. You wouldn't necessarily know exactly where your data starts once the two sections are assembled, so it's easier to let the assembler **calculate** the addresses for you. As an example, if `image_data` actually started at address 0x8000 in memory, then this address gets moved into register `r1`, which we’ve renamed. However, if we change the code, move the image data, or add another block of code that we write later, then this address will change. By using `ADR`, we don't have to worry about the address.

Let's examine another example, this time to see how the `ADR` pseudo-instruction actually gets converted into real ARM instructions. Again, the code in this example doesn't actually do anything except set up pointers, but it will serve to illustrate how `ADR` behaves.

```asm title="EXAMPLE 6.4" linenums="1"
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

The third `ADR` tries to create an address where the label is on the other side of an 8000-byte block of memory. This doesn't work, but there is another pseudo-instruction: `ADRL`. Using *two* operations instead of one, the `ADRL` will calculate an offset that is within a range based on the addition of two values now, both created by the byte rotation scheme mentioned above (for ARM instructions). There is a fixed range for 32-bit Thumb instructions of ±1MB. You should note that if you invoke an `ADRL` pseudo-instruction in your code, it will generate two operations even if it could be done using only one, so be careful in loops that are sensitive to cycle counts. One other important point worth mentioning is that the label used with `ADR` or `ADRL` must be within the ***same*** code section. If a label is out of range in the same section, the assembler faults the reference. As an aside, if a label is out of range in other code sections, the linker faults the reference.

> `ADR r2, DataArea + 4300`: ADD `imm` is an unsigned immediate, in the range [0, 4095].

## LDR

There is yet another way of loading addresses into registers, and it is exactly the same as the `LDR` pseudo-instruction we saw earlier for loading constants. The syntax is

```asm
LDR <Rd>, =label
```

In this instance, the assembler will **convert** the pseudo-instruction into a load instruction, where the load reads the address from a literal pool that it creates. As with the case of loading constants, you must ensure that a literal pool is *within* range of the instruction. This pseudo-instruction differs from `ADR` and `ADRL` in that labels *outside* of a section can be referenced, and the linker will **resolve** the reference at link time.

The example below shows a few of the ways the `LDR` pseudo-instruction can be used, including using labels with their own offsets.

```asm title="EXAMPLE 6.5" linenums="1" hl_lines="18-21"
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

## ADR vs. LDR

Use the pseudo-instruction

```asm
ADR <Rd>, label
```

to put an address into a register whenever possible. The address is created by adding or subtracting an *offset* to/from the `PC`, where the offset is **calculated** by the assembler.

- If the above case fails, use the `ADRL` pseudo-instruction, which will calculate an offset using *two* separate `ADD` or `SUB` operations. Note that if you invoke an `ADRL` pseudo-instruction in your code, it will generate two operations even if it could be done using only one.

```asm
; EXAMPLE 6.4
        ADRL    r2, DataArea + 4300 ; => ADD r2, PC, #offset1
                                    ;    ADD r2, r2, #offset2
                                    ;    offset1 + offset2 = 4300
```

Use the pseudo-instruction

```asm
LDR <Rd>, =label
```

if you plan to reference labels in ***other*** sections of code, or you know that a literal table will exist and you don't mind the extra cycles used to fetch the literal from memory. Use the same caution with literal pools that you would for the construct

```asm
LDR <Rd>, = constant
```

Consult the Assembler User's Guide (ARM 2008a) for more details on the use of `ADR`, `ADRL` and `LDR` for loading addresses.

---

!!! warning "Copyright clarification"

    Copyright belongs to the original author. 🫡
    Excerpt/quotation for study only, non-commercial.
