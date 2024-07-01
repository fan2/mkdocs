---
title: GNU Assembler Directives
authors:
  - xman
date:
    created: 2023-06-15T15:00:00
categories:
    - arm
    - toolchain
comments: true
---

Directives are used mainly to deﬁne symbols, allocate storage, and control the behavior of the assembler. Directives allow the programmer to control how the assembler does its job.

<!-- more -->

## armasm Assembler Directives

[ARM Compiler armasm Reference Guide](https://developer.arm.com/documentation/dui0802/latest/Directives-Reference) | 10: Directives Reference
[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest/Directives-Reference) | 22. Directives Reference

[ARM Assembly Language: Fundamentals and Techniques, 2nd Edition](https://www.oreilly.com/library/view/arm-assembly-language/9781482229851/) | Chapter 4: Assembler Rules and Directives

## GNU Assembler Directives

[GNU as](https://sourceware.org/binutils/docs/as/index.html) - [7 Assembler Directives](https://sourceware.org/binutils/docs/as/Pseudo-Ops.html)

All assembler directives have names that begin with a period (‘`.`’). The names are case insensitive for most targets, and usually written in lower case.

[Programming with 64-Bit ARM Assembly Language](https://www.amazon.com/Programming-64-Bit-ARM-Assembly-Language/dp/1484258800/) | Appendix C: Assembler Directives

[Assembly Language Using the Raspberry Pi: A Hardware Software Bridge](https://www.amazon.com/Assembly-Language-Using-Raspberry-Pi-ebook/dp/B072KSM5GB) | Appendix H: Assembler Directives

directive | function
----------|---------
.align    | Set memory address to half-word, word, double-word, ... border
.text     | Inform linker to group following code with other instructions in memory
.ascii    | Put string of ASCII characters into memory                     
.asciz    | Put string of ASCII characters into memory with null at end
.data     | Inform linker to group following code with other data in memory
.global   | Inform the assembler of label to be passed on to the linker.
.ds       | Reserve block of memory for data storage
.end      | Identifies last line of text file (not required, but comforting to know nothing is missing)
.equ      | Define assembly time constant
.set      | Assign value to assembly time variable

[ARM 64-Bit Assembly Language](https://www.amazon.com/64-Bit-Assembly-Language-Larry-Pyeatt/dp/0128192216/) | 2 GNU assembly syntax

- 2.1 Structure of an assembly program - 2.1.3 Directives
- 2.3 GNU assembly directives

Each processor architecture has its own assembly language, created by the designers of the architecture. Although there are many similarities between assembly languages, the designers may choose different names for various directives. The GNU assembler supports a relatively large set of directives, and some of them have more than one name. This is because it is designed to handle assembling code for many different processors, without drastically changing the assembly language designed by the processor manufacturers.

The GNU assembler has many directives, but assembly programmers typically need to know only a few of them. All assembler directives begin with a period ‘`.`’ which is followed by a sequence of letters, usually in lower case. There are many other directives available in the GNU Assembler which are not covered here. Complete documentation is available online as part of the GNU Binutils package.

We will now cover some of the most commonly used directives for the GNU assembler.

### Selecting the current section

The instructions and data that make up a program are stored in different *sections* of the program file. There are several standard sections that the programmer can choose to **put** code and data in. Sections can also be further divided into numbered *subsections*. Each section has its own *address counter*, which is used to keep track of the *location* of bytes within that section. When a label is encountered, it is assigned the value of the current address counter for the currently active section.

Selecting a section and subsection is done by using the appropriate assembly directive. Once a section has been selected, all of the instructions and/or data will go into that section until another section is selected. The most important directives for selecting a section are:

- `.data subsection`: Instructs the assembler to append the following instructions or data to the data subsection numbered subsection(defaults to zero).
- `.text subsection`: Tells the assembler to append the following statements to the end of the text subsection numbered subsection(defaults to zero).
- `.bss subsection`: Tells the assembler to append the following statements to the end of the bss subsection numbered subsection(defaults to zero).
- `.section name`: create other sections. In order for custom sections to be linked into a program, the linker must be made aware of them. With the GNU tools, this can be accomplished by providing a linker script.

arch/arm64/kernel/head.S: `.section ".idmap.text","a"`

### Allocating space for variables and constants

There are several directives that allow the programmer to allocate and initialize static storage space for variables and constants. The assembler supports bytes, integer types, ﬂoating point types, and strings. These directives are used to allocate a ﬁxed amount of space in memory and optionally initialize the memory. Some of these directives allow the memory to be initialized using an expression. An expression can be a simple integer, or a C-style expression. The directives for allocating storage are as follows:

- `.byte expressions`: Each expression produces one byte of data.
- `[.2byte | .hword | .short] expressions`: emit a 16-bit number for each expression
- `[.4byte | .word | .long] expressions`: emit four bytes(32-bit) for each expression given
- `[.8byte | .quad] expressions`: emit eight bytes(64-bit) for each expression given
- `.ascii "string"`: expects zero or more string literals, assembles each string (with no trailing ASCII NULL character) into consecutive addresses.
- `[.asciz | string ] "string"`: each string is followed by an ASCII NULL character (zero). The “z” in `.asciz` stands for *zero*.
- `[.float | .single] flonums`: In AArch64, they are 4-byte IEEE standard single precision numbers.
- `.double flonums`: In AArch64, they are stored as 8-byte IEEE standard double precision numbers.
- `.rept count`: Repeat the sequence of lines between the `.rept` directive and the next `.endr` directive *count* times.

### Filling and aligning

On the AArch64 CPU, data can be moved to and from memory one byte at a time, two bytes at a time (half-word), four bytes at a time (word), or eight bytes at a time (double-word).

Moving a word between the CPU and memory takes signiﬁcantly more time if the address of the word is not aligned on a four-byte boundary (one where the least signiﬁcant *two* bits of the address are zero). Similarly, moving a half-word between the CPU and memory takes significantly more time if the address of the half-word is not aligned on a two-byte boundary (one where the least signiﬁcant bit of the address is zero), and moving a double-word takes more time if it is not aligned on an eight-byte boundary (one where the least signiﬁcant *three* bits of the address are zero).

Therefore, when declaring storage, it is important that double-words, words, and half-words are stored on appropriate boundaries. The following directives allow the programmer to insert as much space as necessary to align the next item on any boundary desired.

- `.align abs-expr, abs-expr, abs-expr`: Pad the location counter (in the current subsection) to a particular storage boundary. The ﬁrst expression speciﬁes the number of low-order zero bits the location counter must have after advancement.

    - That is aligned to power of 2, e.g., `.align 3` means to be aligned to $2^3=8$ bytes.

- `.balign[lw] abs-expr, abs-expr, abs-expr`: Adjust the location counter to a particular storage boundary. The ﬁrst expression is the byte-multiple for the alignment request.

    - For example, `.balign 16` = `.align 4` will insert ﬁll bytes until the location counter is an even multiple of 16.

- `[.skip | .space] size, fill`: Allocate a large area of memory and initialize it all to the same value. It is very useful for declaring large arrays in the `.bss` section.

### Setting and manipulating symbols

The assembler provides support for setting and manipulating symbols which can then be used in other places within the program. The labels that can be assigned to assembly statements and directives are one type of symbol. The programmer can also declare other symbols and use them throughout the program. Such symbols may not have an actual storage location in memory, but they are included in the assembler’s symbol table, and can be used anywhere that their value is required.

- `[.equ | .set] symbol, expression`: Sets the value of symbol to expression, similar to the C language `#define` directive.
- `.equiv symbol, expression`: like `.equ` and `.set`, except that the assembler will signal an error if the symbol is already deﬁned.
- `[.global | .globl] symbol`: Makes the symbol *visible* to the linker. If symbol is deﬁned within a file, and this directive is used to make it global, then it will be available to any file that is linked with the one containing the symbol. Without this directive, symbols are visible *only* within the file where they are deﬁned.
- `.comm symbol, length`: declares tentative symbol to be a common symbol, meaning that if it is deﬁned in more than one file, then all instances should be merged into a single symbol.

### Functions and objects

There are a few assembler directives that are used for deﬁning the size and type of labels. This information is stored in the object file along with the code and data, and is used by the linker and/or debugger.

- `.size name,expression`: set the size associated with a symbol. This information helps the linker to exclude unneeded code and/or data when creating an executable file, and helps the debugger to keep track of where it is in the program.

!!! example ".size main, .-main"

    ```asm
        .global	main
        .type	main, %function

    main:

        // [...snip...]

        .size	main, .-main
    ```

    The period “`.`” in the expression (`.-main`) is a reference to the current location counter value. The expression (`.-main`) means “Subtract the location of main from the current location.” This directive calculates how many bytes there are between the label main and the location of the `.size` directive, and provides that information for the linker and/or debugger.

- `.type name,type_description`: sets the type of a symbol name to be either a function or an object. Valid values for type_desription in GNU AArch64 assembly include:

	- `%function` : The symbol is a function name.
	- `%object` : The symbol is a data object.
	- `%tls_object` : The symbol is a thread-local data object.
	- `%common` : The symbol is a common (shared) object.
	- `%notype` : The symbol has no type.

!!! note "type_desription alternate prefix"

    Some assemblers, including some versions of the GNU assembler, a may require the `@` character instead of the `%` character.

### Conditional assembly

Sometimes it is desirable to skip assembly of portions of a file. The assembler provides some directives to allow conditional assembly. One use for these directives is to optionally assemble code as an aid for debugging.

- `.if expression`: `.if` marks the beginning of a section of code which is only considered part of the source program being assembled if the argument (which must be an absolute expression) is non-zero. The end of the conditional section of code must be marked by the `.endif` directive. Optionally, code may be included for the alternative condition by using the `.else` directive.
- `.ifdef symbol`: Assembles the following section of code if the speciﬁed symbol has been deﬁned.
- `.ifndef symbol` Assembles the following section of code if the speciﬁed symbol has not been deﬁned.
- `.else`: Assembles the following section of code only if the condition for the preceding `.if` or `.ifdef` was false.
- `.endif`: Marks the end of a block of code that is only assembled conditionally.

### Including other source files

`.include "file"`

This directive provides a way to include supporting files at speciﬁed points in the source program. The code from the included file is assembled as if it followed the point of the `.include` directive. When the end of the included file is reached, assembly of the original file continues. The search paths used can be controlled with the ‘`-I`’ command line parameter when running the assembler.

### Macros

The directives `.macro` and `.endm` allow the programmer to deﬁne macros that the assembler expands to generate assembly code. The GNU assembler supports simple macros. Some other assemblers have much more powerful macro capabilities.

- `.macro macname` / `.macro macname macargs ...`: Begin the deﬁnition of a macro called macname. If the macro deﬁnition requires arguments, their names are speciﬁed after the macro name, separated by commas or spaces. The programmer can supply a default value for any macro argument by following the name with ‘`=deflt`’.

- `.endm`: End the current macro deﬁnition.

- `.exitm`: Exit early from the current macro deﬁnition. This is usually used only within a `.if` or `.ifdef` directive.

- `\@`: This is a pseudo-variable used by the assembler to maintain a count of how many macros it has executed. That number can be accessed with ‘`\@`’, but only within a macro deﬁnition.

#### examples

The `\el` stands for the parameter to be replaced.
The `\()` indicates the end of the macro parameter.

```asm title="arch/arm64/kernel/entry.S"
    .macro kernel_ventry, el:req, ht:req, regsize:req, label:req
    .align 7

    b   el\el\ht\()_\regsize\()_\label
```

The IRQ 64-bit EL0 vector `kernel_ventry 0, t, 64, irq` will expand to `el0t_64_irq`.

```asm title="arch/arm64/kernel/entry.S"
    .macro entry_handler el:req, ht:req, regsize:req, label:req
SYM_CODE_START_LOCAL(el\el\ht\()_\regsize\()_\label)
    kernel_entry \el, \regsize
    mov	x0, sp
    bl	el\el\ht\()_\regsize\()_\label\()_handler
    .if \el == 0
    b	ret_to_user
    .else
    b	ret_to_kernel
    .endif
SYM_CODE_END(el\el\ht\()_\regsize\()_\label)
    .endm
```

The corresponding handler `entry_handler 0, t, 64, irq` will expand to `el0t_64_irq_handler`.
