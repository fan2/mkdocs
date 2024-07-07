---
title: C Pointer and Array Cross Reference with Mismatched Type
authors:
  - xman
date:
    created: 2023-10-07T10:00:00
categories:
    - c
comments: true
---

So far, we've discussed [C Pointers and Arrays](./c-pointer-array.md), [C Character Pointer and String Manipulation](./c-pointer-string.md). There are very confusingly named concepts and it's very easy to get them mixed up.

In this article, we'll see what happens when an external reference is declared with the wrong but compatible type. There are two cases involved, refer array as pointer and opposite.

<!-- more -->

## Ref array as pointer

Suppose the character array is defined in file 1 as follows:

```c
char a[100];
```

The external variable declaration referenced in file 2 is as follows:

```c
extern char *a;
```

Here, array `a` is defined in file 1, and it is declared as a pointer in file 2. Is there anything wrong with this? Isn't it often said that pointers and arrays are similar, and can even be used interchangeably? But, unfortunately, this is wrong. You may still remember what I said [previously](./c-pointer-array.md): arrays are arrays, and pointers are pointers. They are two completely different things! There is no relationship between them, but they are often dressed in similar clothes to confuse you. Let's try to analyze this problem.

At the beginning of Chapter 1, I emphasized the difference between definitions and declarations. Definitions allocate memory, while declarations do not. Definitions can only appear once, while declarations can appear multiple times. Here, `extern` promises the compiler that the name `a` has been defined in another file. The name `a` used in the following code is defined in another file. Looking back at the discussion of lvalues ​​and rvalues ​​in the previous article, we know that if the compiler needs an address (and possibly an offset) to perform an operation, it can directly read or write the memory at this address by unlocking it (using the key `*`), without having to first find the place where the address is stored. On the contrary, for a pointer, you must first find the place where the address is stored, take out the address value, and then unlock the address (still using the key `*`).

This is why `extern char a[]` is equivalent to `extern char a[100]`. Because it is just a declaration and no space is allocated, the compiler does not need to know how many elements the array has. Both declarations tell the compiler that `a` is an array defined in another file, and `a` also represents the address of the first element of the array, that is, the starting address of this memory block. The addresses of other elements in the array can be expressed in the form of base address + offset.

However, when you declare it as `extern char *a`, the compiler naturally thinks that `a` is a pointer variable, which occupies 4/8 bytes in 32/64-bit systems respectively. These 4/8 bytes store an address, and the character type data is stored at this address. Although in file 1, the compiler knows that a is an array, but in file 2, the compiler does not know this. Most compilers use files as translation units, and the compiler only processes according to the types declared in this file. Therefore, although the actual size of a is 100 bytes, in file 2, the compiler thinks that a only occupies 4/8 bytes.

We know that the compiler will treat any data stored in a pointer variable as an address. Therefore, if we need to access these character type data, we must first get the address stored in the pointer variable `a`.

Assume that the original array `a` stores 100 characters, e.g. {'B', 'A', 'A', 'D', 'D', 'A', 'A', 'D', 'F', 'E', 'E', 'D', 'B', 'A', 'B', 'E', ...}. Under x86_64/AArch64 platforms, the compiler will only see the first 8 bytes (the binary encoding of the ASCII characters).

```bash
$ echo "BAADDAAD" | xxd
00000000: 4241 4144 4441 4144 0a                   BAADDAAD.
```

The compiler takes out the first 8 bytes (the ASCII code of the character) at once according to the `uintptr_t` type and obtains `0x4441414444414142` in little-endian order, which may not be a valid address and is not expected even if it is valid.

## Ref pointer as array

Obviously, according to the above analysis, if we declare the array defined in file 1 as a pointer in file 2, an error will occur. Similarly, if it is defined as a pointer in file 1 and declared as an array in file 2, an error will also occur.

Suppose the character pointer is defined in file 1 as follows:

```c
char *p = "abcdefg";
```

The external char array declaration referenced in file 2 is as follows:

```c
extern char p[];
```

In file 1, the compiler allocates 4/8 bytes of space and names it `p`; at the same time, `p` stores the address of the first character of the string constant `"abcdefg"`; this constant string literal itself is stored in the static area of ​​memory(probably .rodata section), and its content cannot be changed. In file 2, the compiler considers `p` to be an array with a size of 4/8 bytes, and the array stores data of type char.

In file 2, the *pointer-to-array* promotion (as opposed to the *array-to-pointer decay* rule) is applied to the variable-length array. The block of memory (with pointer width) to which `p` is bound is treated as an array. For a convenient mnemonic, we note it as `_p`, which satisfies the following facts: `_p = &p` and `*_p = p`.

Suppose on AArch64, its address is 0xaaaab4461078, corresponding to atomic bytearray {0x78, 0x10, 0x46, 0xb4, 0xaa, 0xaa, 0x00, 0x00}. In file 2, the compiler treats the value (address) of the pointer variable `p` as an array of 8 char types, and dereferences the bytes in sequence according to the char/byte type. These are not all valid characters, nor are they the addresses of the memory blocks we want. If `p[i]`(actually `_p[i]`) is assigned a value (i ∈ [0,7]), the legal address originally saved in `p` will be destroyed, making it impossible to find the memory it originally pointed to, and even causing an illegal memory access exception.

## test programs

Based on the analysis above, we can design a comprehensive test program.

In file 1(crossdef.c), we define char array and pointer to string literal. function `disclose_a()` outputs pointer `a` and dereference the first character/byte, function `disclose_p()` does the same thing.

```c title="array-pointer-crossdef.c"
#include <stdio.h>

char a[100] = {'B', 'A', 'A', 'D', 'D', 'A', 'A', 'D', 'F', 'E', 'E', 'D', 'B', 'A', 'B', 'E'};
char *p = "abcdefg";

void disclose_a() {
    printf("a = %p, *a = (%c, %#x)\n", a, *a, *a);
}

void disclose_p() {
    printf("p = %p, *p = (%c, %#x)\n", p, *p, *p);
}
```

File 2(crossref.c) contains the main routine, it declares external references to `a` and `p` defined in file 1, but with a deliberately mismatched prototype.

```c title="array-pointer-crossref.c"
#include <stdio.h>
#include <stdint.h> // uintptr_t

extern char *a;
extern char p[];

extern void disclose_a();
extern void disclose_p();

void ref_array_as_pointer() {
    disclose_a();
    printf("a = %p\n", a);
    printf("*a = %#x\n", *a);

    // for (int i=0; i<8; i++) {
    //     printf("a[%d] = %#x\n", i, a[i]);
    // }
}

void ref_pointer_as_array() {
    disclose_p();
    printf("p = %p\n", p);
    printf("*p = %#x\n", *p);

    // for (int i=0; i<8; i++) {
    //     printf("p[%d] = %#x\n", i, p[i]);
    // }
}

int main(int argc, char* argv[]) {
    int c;
    printf("input 'a' or 'p' to choose test case: ");

    while ((c=getchar()) != EOF) {
        if (c == 'a') {
            ref_array_as_pointer();
            break;
        } else if (c == 'p') {
            ref_pointer_as_array();
            break;
        }
    }

    return 0;
}
```

Run the following command to compile the C program.

```bash
$ cc array-pointer-crossdef.c array-pointer-crossref.c -o array-pointer-crossref
```

Run the binary ELF and input `a` according to the tips.

```bash
$ ./array-pointer-crossref
input 'a' or 'p' to choose test case: a
a = 0xaaaab51e1010, *a = (B, 0x42)
a = 0x4441414444414142
[1]    44102 segmentation fault (core dumped)  ./array-pointer-crossref
```

The following ascii graph illustrates the address and layout of array `a`.

```text
0xaaaab51e1010                        a
      |   +---------------------------^----------------------------+
       \ /                                                          \
  --------------------------------------------------------------------------
     ⚡️  | 'B' | 'A' | 'A' | 'D' | 'D' | 'A' | 'A' | 'D' | ... | xxx | ⚡️
  --------------------------------------------------------------------------
         a[0]  a[1]  a[2]  a[3]  a[4]  a[5]  a[6]  a[7]   ...  a[99]
```

!!! note "Cross reference array as pointer"

    In fact, the actual type of `a` is `char[100]`. There is a forced typecast in file 2(crossref.c). When `a` is treated as a normal pointer, it takes whatever it contains as an address. Since the pointer width(`__SIZEOF_POINTER__`)=8 in AArch64, it will group the first 8 characters/bytes as a unit, forming the address 0x4441414444414142.

    However, accessing the illegal address will throw a *`segmentation fault`* exception.

Run the binary ELF again and input `p`:

```bash
$ ./array-pointer-crossref
input 'a' or 'p' to choose test case: p
p = 0xaaaacf3009d8, *p = (a, 0x61)
p = 0xaaaacf311078
*p = 0xd8
```

Type `rax2 -x 0xaaaacf3009d8` to output in hexpairs or `rax2 -c 0xaaaacf3009d8` to output in C string.

The following ascii graph illustrates the address and layout of literal string (character array `a`) and pointer `p`.

```text
                                                         a
                +-------------------+  +-----------------^-----------------+
                ↑                   ↓ /                                      \
        +--------------+      -----------------------------------------------------
        |0xaaaacf3009d8|         ⚡️  | 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | ⚡️
        +--------------+      -----------------------------------------------------
        p       ↑                  / a[0]  a[1]  a[2]  a[3]  a[4]  a[5]  a[6]
0xaaaacf311078  |             0xaaaacf3009d8
                |
        +--------------+
        |0xaaaacf311078|
        +--------------+
        _p
```

!!! note "Cross reference pointer as array"

    The pointer variable `p` is at `0xaaaacf311078`, when treated as an array, its content `0xaaaacf3009d8` (the address of the string literal) is split as a character array. According to the latent implication of the array name, when used as rvalue, it returns the address of the first element, which is `0xaaaacf311078`. So `*p` will dereference the first character/byte and return `0xd8` under LSB(Least Significant Byte comes first).

    Here it's all about `p`, nothing to do with `a`.

The content of this article may be a bit confusing and brain-bending, but if you understand it thoroughly, you will really get to grips with the concepts and essence of arrays and pointers. At least, that's how it feels to me. I hope it helps you a little.

As usual, let's see what the compiler does under the hood. This will help our understanding from the ground up.

Type `r2 -Ad array-pointer-crossref` to launch debugging with radare2. See [radare2 basics - embark](../toolchain/radare2-basics.md), [reloc puts@plt via GOT - r2 debug](../elf/plt-puts-r2debug.md) and [C Pointer Explanation in armasm](./c-pointer-armasm.md) for some references if you're not familiar with r2.

> ***Aside***: The Address Space Layout Randomisation (ASLR) mechanism ensures that the program is loaded at a different address each time it is run, to mitigate exploits.

### list sections

Use `readelf`, `objdump` or `rabin2` to display the sections' header statically.

```bash
readelf -SW array-pointer-crossref
objdump -hw array-pointer-crossref
rabin2 -S array-pointer-crossref
```

After start debugging with r2, we can use `iS` command to list sections:

```bash
[0xaaaad08408c0]> iS
[Sections]

nth paddr        size vaddr           vsize perm type        name
―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x00000000    0x0 0x00000000        0x0 ---- NULL
1   0x00000238   0x1b 0xaaaad0840238   0x1b -r-- PROGBITS    .interp
2   0x00000254   0x24 0xaaaad0840254   0x24 -r-- NOTE        .note.gnu.build-id
3   0x00000278   0x20 0xaaaad0840278   0x20 -r-- NOTE        .note.ABI-tag
4   0x00000298   0x1c 0xaaaad0840298   0x1c -r-- GNU_HASH    .gnu.hash
5   0x000002b8  0x108 0xaaaad08402b8  0x108 -r-- DYNSYM      .dynsym
6   0x000003c0   0x9c 0xaaaad08403c0   0x9c -r-- STRTAB      .dynstr
7   0x0000045c   0x16 0xaaaad084045c   0x16 -r-- GNU_VERSYM  .gnu.version
8   0x00000478   0x30 0xaaaad0840478   0x30 -r-- GNU_VERNEED .gnu.version_r
9   0x000004a8  0x108 0xaaaad08404a8  0x108 -r-- RELA        .rela.dyn
10  0x000005b0   0x90 0xaaaad08405b0   0x90 -r-- RELA        .rela.plt
11  0x00000640   0x18 0xaaaad0840640   0x18 -r-x PROGBITS    .init
12  0x00000660   0x80 0xaaaad0840660   0x80 -r-x PROGBITS    .plt
13  0x00000700  0x2b8 0xaaaad0840700  0x2b8 -r-x PROGBITS    .text
14  0x000009b8   0x14 0xaaaad08409b8   0x14 -r-x PROGBITS    .fini
15  0x000009d0   0x97 0xaaaad08409d0   0x97 -r-- PROGBITS    .rodata
16  0x00000a68   0x5c 0xaaaad0840a68   0x5c -r-- PROGBITS    .eh_frame_hdr
17  0x00000ac8  0x12c 0xaaaad0840ac8  0x12c -r-- PROGBITS    .eh_frame
18  0x00000d78    0x8 0xaaaad0850d78    0x8 -rw- INIT_ARRAY  .init_array
19  0x00000d80    0x8 0xaaaad0850d80    0x8 -rw- FINI_ARRAY  .fini_array
20  0x00000d88  0x1f0 0xaaaad0850d88  0x1f0 -rw- DYNAMIC     .dynamic
21  0x00000f78   0x88 0xaaaad0850f78   0x88 -rw- PROGBITS    .got
22  0x00001000   0x80 0xaaaad0851000   0x80 -rw- PROGBITS    .data
23  0x00001080    0x0 0xaaaad0851080    0x8 -rw- NOBITS      .bss
24  0x00001080   0x2b 0x00000000       0x2b ---- PROGBITS    .comment
25  0x000010ab   0x60 0x00000000       0x60 ---- PROGBITS    .debug_aranges
26  0x0000110b  0x251 0x00000000      0x251 ---- PROGBITS    .debug_info
27  0x0000135c  0x1a1 0x00000000      0x1a1 ---- PROGBITS    .debug_abbrev
28  0x000014fd  0x10e 0x00000000      0x10e ---- PROGBITS    .debug_line
29  0x0000160b  0x120 0x00000000      0x120 ---- PROGBITS    .debug_str
30  0x0000172b   0x68 0x00000000       0x68 ---- PROGBITS    .debug_line_str
31  0x00001798  0xa08 0x00000000      0xa08 ---- SYMTAB      .symtab
32  0x000021a0  0x2ac 0x00000000      0x2ac ---- STRTAB      .strtab
33  0x0000244c  0x14a 0x00000000      0x14a ---- STRTAB      .shstrtab
```

#### telescope .rodata

Use `readelf` or `objdump` to display specified section's content statically.

```bash
readelf -x .rodata array-pointer-crossref # or -p
objdump -j .rodata -s array-pointer-crossref
```

During debugging with radare2, use `xr` to telescope the `.rodata`.

```bash
[0xaaaad08408c0]> xr $w*(`iS,name/eq/.rodata ~.rodata[2]`/8) @ `iS,name/eq/.rodata ~.rodata[3]`
0xaaaad08409d0 0x0000000000020001   ........ @ obj._IO_stdin_used 131073
0xaaaad08409d8 0x0067666564636261   abcdefg. @ str.abcdefg ascii ('a')
0xaaaad08409e0 0x202c7025203d2061   a = %p,  @ str.a___p__a____c___x__n ascii ('a')
0xaaaad08409e8 0x632528203d20612a   *a = (%c ascii ('*')
0xaaaad08409f0 0x000a29782325202c   , %#x)..
0xaaaad08409f8 0x202c7025203d2070   p = %p,  @ str.p___p__p____c___x__n ascii ('p')
0xaaaad0840a00 0x632528203d20702a   *p = (%c ascii ('*')
0xaaaad0840a08 0x000a29782325202c   , %#x)..
0xaaaad0840a10 0x000a7025203d2061   a = %p.. @ str.a___p_n
0xaaaad0840a18 0x782325203d20612a   *a = %#x @ str.a___x_n ascii ('*')
0xaaaad0840a20 0x000000000000000a   ........ 10 x10,d10
0xaaaad0840a28 0x000a7025203d2070   p = %p.. @ str.p___p_n
0xaaaad0840a30 0x782325203d20702a   *p = %#x @ str.p___x_n ascii ('*')
0xaaaad0840a38 0x000000000000000a   ........ 10 x10,d10
0xaaaad0840a40 0x6127207475706e69   input 'a @ str.input_a_or_p_to_choose_test_case: ascii ('i')
0xaaaad0840a48 0x27702720726f2027   ' or 'p' ascii (''')
0xaaaad0840a50 0x6f6f6863206f7420    to choo ascii (' ')
0xaaaad0840a58 0x2074736574206573   se test  ascii ('s')
```

#### telescope .data

Use `readelf` or `objdump` to display specified section's content statically.

```bash
readelf -x .data array-pointer-crossref # or -p
objdump -j .data -s array-pointer-crossref
```

During debugging with radare2, use `xr` to telescope the `.data`, see [reloc puts@plt via GOT - r2 debug
](./xxx.md).

```bash
[0xaaaad08408c0]> xr $w*(`iS,name/eq/.data ~.data[2]`/8) @ `iS,name/eq/.data ~.data[3]`
0xaaaad0851000 ..[ null bytes ]..   00000000 loc.__data_start
0xaaaad0851008 0x0000aaaad0851008   ........ @ obj.__dso_handle /home/pifan/Projects/cpp/pointer/array-pointer-crossref .data __dso_handle program R W 0xaaaad0851008
0xaaaad0851010 0x4441414444414142   BAADDAAD @ obj.a x0,d0 ascii ('B')
0xaaaad0851018 0x4542414244454546   FEEDBABE ascii ('F')
0xaaaad0851020 ..[ null bytes ]..   00000000
0xaaaad0851078 0x0000aaaad08409d8   ........ @ obj.p /home/pifan/Projects/cpp/pointer/array-pointer-crossref .rodata str.abcdefg program R X 'invalid' 'array-pointer-crossref' abcdefg
```

### dm memory maps

List memory maps of current/target process.

> `loc.__data_start` corresponds to `.data` section

```bash
[0xaaaad08408c0]> dm
# segment.LOAD0
0x0000aaaad0840000 - 0x0000aaaad0841000 * usr     4K s r-x /home/pifan/Projects/cpp/pointer/array-pointer-crossref /home/pifan/Projects/cpp/pointer/array-pointer-crossref ; map._home_pifan_Projects_cpp_pointer_array_pointer_crossref.r_x
# segment.LOAD1
0x0000aaaad0850000 - 0x0000aaaad0851000 - usr     4K s r-- /home/pifan/Projects/cpp/pointer/array-pointer-crossref /home/pifan/Projects/cpp/pointer/array-pointer-crossref ; map._home_pifan_Projects_cpp_pointer_array_pointer_crossref.rw_
0x0000aaaad0851000 - 0x0000aaaad0852000 - usr     4K s rw- /home/pifan/Projects/cpp/pointer/array-pointer-crossref /home/pifan/Projects/cpp/pointer/array-pointer-crossref ; loc.__data_start
0x0000aaaaf3293000 - 0x0000aaaaf32b4000 - usr   132K s rw- [heap] [heap]
0x0000ffffa9f50000 - 0x0000ffffaa0d8000 - usr   1.5M s r-x /usr/lib/aarch64-linux-gnu/libc.so.6 /usr/lib/aarch64-linux-gnu/libc.so.6
0x0000ffffaa0d8000 - 0x0000ffffaa0e7000 - usr    60K s --- /usr/lib/aarch64-linux-gnu/libc.so.6 /usr/lib/aarch64-linux-gnu/libc.so.6
0x0000ffffaa0e7000 - 0x0000ffffaa0eb000 - usr    16K s r-- /usr/lib/aarch64-linux-gnu/libc.so.6 /usr/lib/aarch64-linux-gnu/libc.so.6
0x0000ffffaa0eb000 - 0x0000ffffaa0ed000 - usr     8K s rw- /usr/lib/aarch64-linux-gnu/libc.so.6 /usr/lib/aarch64-linux-gnu/libc.so.6
0x0000ffffaa0ed000 - 0x0000ffffaa0f9000 - usr    48K s rw- unk0 unk0
0x0000ffffaa116000 - 0x0000ffffaa141000 - usr   172K s r-x /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.r_x
0x0000ffffaa14b000 - 0x0000ffffaa14d000 - usr     8K s rw- unk1 unk1
0x0000ffffaa14d000 - 0x0000ffffaa14f000 - usr     8K s r-- [vvar] [vvar] ; map._vvar_.r__
0x0000ffffaa14f000 - 0x0000ffffaa150000 - usr     4K s r-x [vdso] [vdso] ; map._vdso_.r_x
0x0000ffffaa150000 - 0x0000ffffaa152000 - usr     8K s r-- /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ; map._usr_lib_aarch64_linux_gnu_ld_linux_aarch64.so.1.rw_
0x0000ffffaa152000 - 0x0000ffffaa154000 - usr     8K s rw- /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1
0x0000ffffc678d000 - 0x0000ffffc67ae000 - usr   132K s rw- [stack] [stack] ; map._stack_.rw_
```

### sym.disclose_a

`printf("a = %p, *a = (%c, %#x)\n", a, *a, *a);`: rvalue of array name and dereference.

- +12/+28/+48: x0/x0/x1 = loc.data_start+0x10 = 0x0000aaaad0851010, see `dm`
- +16/+32: w0 = ldrb [0x0000aaaad0851010] = 0x42('B'), see `.data`
- +20/+36\~+40: w1 = w0; w3 = w0, w2 = w1 (=w0);
- +52/+56: x0 = segment.LOAD0+0x9e0 = 0xaaaad08409e0, see `dm` and `.rodata`

**params**: x0, x1, w2, w3

```bash
[0xaaaad08408c0]> pdf @ sym.disclose_a
┌ 76: sym.disclose_a ();
│  sym.disclose_a + 0              0xaaaad0840814 b    fd7bbfa9       stp x29, x30, [sp, -0x10]!
│  sym.disclose_a + 4              0xaaaad0840818      fd030091       mov x29, sp
│  sym.disclose_a + 8              0xaaaad084081c      800000b0       adrp x0, loc.data_start
│  sym.disclose_a + 12             0xaaaad0840820      00400091       add x0, x0, 0x10
│  sym.disclose_a + 16             0xaaaad0840824      00004039       ldrb w0, [x0]
│  sym.disclose_a + 20             0xaaaad0840828      e103002a       mov w1, w0
│  sym.disclose_a + 24             0xaaaad084082c      800000b0       adrp x0, loc.data_start
│  sym.disclose_a + 28             0xaaaad0840830      00400091       add x0, x0, 0x10
│  sym.disclose_a + 32             0xaaaad0840834      00004039       ldrb w0, [x0]
│  sym.disclose_a + 36             0xaaaad0840838      e303002a       mov w3, w0
│  sym.disclose_a + 40             0xaaaad084083c      e203012a       mov w2, w1
│  sym.disclose_a + 44             0xaaaad0840840      800000b0       adrp x0, loc.data_start
│  sym.disclose_a + 48             0xaaaad0840844      01400091       add x1, x0, 0x10
│  sym.disclose_a + 52             0xaaaad0840848      00000090       adrp x0, segment.LOAD0
│  sym.disclose_a + 56             0xaaaad084084c      00802791       add x0, x0, 0x9e0
│  sym.disclose_a + 60             0xaaaad0840850      a0ffff97       bl sym.imp.printf
│  sym.disclose_a + 64             0xaaaad0840854      1f2003d5       nop
│  sym.disclose_a + 68             0xaaaad0840858      fd7bc1a8       ldp x29, x30, [sp], 0x10
└  sym.disclose_a + 72             0xaaaad084085c      c0035fd6       ret
```

### sym.ref_array_as_pointer

1. `extern char *a;`: see ascii graph above

    - `char **_a = &a` = 0x0000aaaad0850000+0xfe8 = 0x0000aaaad0850fe8

2. `printf("a = %p\n", a);`: rvalue of pointer

    - +16: x0 = *_a = a = 0x0000aaaad0851010
    - +20: x0 = *a = 0x4441414444414142("BAADDAAD")
    - +24: x1 = x0
    - +28\~+32: x0 = segment.LOAD0+0xa10 = 0xaaaad0840a10

3. `printf("*a = %#x\n", *a);`: dereference pointer

    - +44: x0 = *_a = a = 0x0000aaaad0851010
    - +48: x0 = *a = 0x4441414444414142("BAADDAAD")
    - +52: ldrb w0 = [0x4441414444414142] => SIGNAL 11(SIGSEGV), segmentation fault

```bash
[0xaaaad08408c0]> pdf @ sym.ref_array_as_pointer
┌ 84: sym.ref_array_as_pointer ();
│  sym.ref_array_as_pointer + 0              0xaaaad08408b4 b    fd7bbfa9       stp x29, x30, [sp, -0x10]!
│  sym.ref_array_as_pointer + 4              0xaaaad08408b8      fd030091       mov x29, sp
│  sym.ref_array_as_pointer + 8              0xaaaad08408bc      d6ffff97       bl sym.disclose_a
│  sym.ref_array_as_pointer + 12             ;-- x30:
│  sym.ref_array_as_pointer + 12             ;-- d30:
│  sym.ref_array_as_pointer + 12             0xaaaad08408c0 b    80000090       adrp x0, map._home_pifan_Projects_cpp_pointer_array_pointer_crossref.rw_
│  sym.ref_array_as_pointer + 16             0xaaaad08408c4      00f447f9       ldr x0, [x0, 0xfe8]
│  sym.ref_array_as_pointer + 20             0xaaaad08408c8      000040f9       ldr x0, [x0]
│  sym.ref_array_as_pointer + 24             ;-- pc:
│  sym.ref_array_as_pointer + 24             0xaaaad08408cc      e10300aa       mov x1, x0
│  sym.ref_array_as_pointer + 28             0xaaaad08408d0      00000090       adrp x0, segment.LOAD0
│  sym.ref_array_as_pointer + 32             0xaaaad08408d4      00402891       add x0, x0, 0xa10
│  sym.ref_array_as_pointer + 36             0xaaaad08408d8      7effff97       bl sym.imp.printf
│  sym.ref_array_as_pointer + 40             0xaaaad08408dc      80000090       adrp x0, map._home_pifan_Projects_cpp_pointer_array_pointer_crossref.rw_
│  sym.ref_array_as_pointer + 44             0xaaaad08408e0      00f447f9       ldr x0, [x0, 0xfe8]
│  sym.ref_array_as_pointer + 48             0xaaaad08408e4      000040f9       ldr x0, [x0]
│  sym.ref_array_as_pointer + 52             0xaaaad08408e8      00004039       ldrb w0, [x0]
│  sym.ref_array_as_pointer + 56             0xaaaad08408ec      e103002a       mov w1, w0
│  sym.ref_array_as_pointer + 60             0xaaaad08408f0      00000090       adrp x0, segment.LOAD0
│  sym.ref_array_as_pointer + 64             0xaaaad08408f4      00602891       add x0, x0, 0xa18
│  sym.ref_array_as_pointer + 68             0xaaaad08408f8      76ffff97       bl sym.imp.printf
│  sym.ref_array_as_pointer + 72             0xaaaad08408fc      1f2003d5       nop
│  sym.ref_array_as_pointer + 76             0xaaaad0840900      fd7bc1a8       ldp x29, x30, [sp], 0x10
└  sym.ref_array_as_pointer + 80             0xaaaad0840904      c0035fd6       ret
```

### sym.disclose_p

`printf("p = %p, *p = (%c, %#x)\n", p, *p, *p);`: rvalue of pointer and dereference.

- +12/+24/+44: x0 = loc.data_start+0x78 = 0x0000aaaad0851078, see `dm`
- +16/+28/+48: x1/x0/x0 = ldr [0x0000aaaad0851078] = 0x0000aaaad08409d8, see `.data`, link to `.rodata`
- +32/+52: w0 = ldrb [0x0000aaaad08409d8] = 0x61('a'), see `.rodata`
- +36/+56: w2 = w0 ;w3 = w0
- +60/+64: x0 = segment.LOAD0+0x9f8 = 0xaaaad08409f8, see `dm` and `.rodata`

**params**: x0, x1, w2, w3

```bash
[0xaaaad08408c0]> pdf @ sym.disclose_p
┌ 84: sym.disclose_p ();
│  sym.disclose_p + 0              0xaaaad0840860 b    fd7bbfa9       stp x29, x30, [sp, -0x10]!
│  sym.disclose_p + 4              0xaaaad0840864      fd030091       mov x29, sp
│  sym.disclose_p + 8              0xaaaad0840868      800000b0       adrp x0, loc.data_start
│  sym.disclose_p + 12             0xaaaad084086c      00e00191       add x0, x0, 0x78
│  sym.disclose_p + 16             0xaaaad0840870      010040f9       ldr x1, [x0]
│  sym.disclose_p + 20             0xaaaad0840874      800000b0       adrp x0, loc.data_start
│  sym.disclose_p + 24             0xaaaad0840878      00e00191       add x0, x0, 0x78
│  sym.disclose_p + 28             0xaaaad084087c      000040f9       ldr x0, [x0]
│  sym.disclose_p + 32             0xaaaad0840880      00004039       ldrb w0, [x0]
│  sym.disclose_p + 36             0xaaaad0840884      e203002a       mov w2, w0
│  sym.disclose_p + 40             0xaaaad0840888      800000b0       adrp x0, loc.data_start
│  sym.disclose_p + 44             0xaaaad084088c      00e00191       add x0, x0, 0x78
│  sym.disclose_p + 48             0xaaaad0840890      000040f9       ldr x0, [x0]
│  sym.disclose_p + 52             0xaaaad0840894      00004039       ldrb w0, [x0]
│  sym.disclose_p + 56             0xaaaad0840898      e303002a       mov w3, w0
│  sym.disclose_p + 60             0xaaaad084089c      00000090       adrp x0, segment.LOAD0
│  sym.disclose_p + 64             0xaaaad08408a0      00e02791       add x0, x0, 0x9f8
│  sym.disclose_p + 68             0xaaaad08408a4      8bffff97       bl sym.imp.printf
│  sym.disclose_p + 72             0xaaaad08408a8      1f2003d5       nop
│  sym.disclose_p + 76             0xaaaad08408ac      fd7bc1a8       ldp x29, x30, [sp], 0x10
└  sym.disclose_p + 80             0xaaaad08408b0      c0035fd6       ret
```

### sym.ref_pointer_as_array

1. `extern char p[];`: see ascii graph above

    - `char **_p = &p` = segment.LOAD1+0xfd8 = 0x0000aaaad0850fd8

2. `printf("p = %p\n", p);`: rvalue of array name = `&p[0]`

    - +16: x1 = ldr [_p] = 0xaaaad0851078

3. `printf("*p = %#x\n", *p);`: dereference pointer

    - +36: x1 = ldr [_p] = 0xaaaad0851078
    - +40: w0 = ldrb [0xaaaad0851078] = first byte of 0x0000aaaad08409d8 = 0xd8
    - +44: w1 = w0

```bash
[0xaaaad08408c0]> pdf @ sym.ref_pointer_as_array
┌ 72: sym.ref_pointer_as_array ();
│  sym.ref_pointer_as_array + 0              0xaaaad0840908 b    fd7bbfa9       stp x29, x30, [sp, -0x10]!
│  sym.ref_pointer_as_array + 4              0xaaaad084090c      fd030091       mov x29, sp
│  sym.ref_pointer_as_array + 8              0xaaaad0840910      d4ffff97       bl sym.disclose_p
│  sym.ref_pointer_as_array + 12             0xaaaad0840914      80000090       adrp x0, map._home_pifan_Projects_cpp_pointer_array_pointer_crossref.rw_
│  sym.ref_pointer_as_array + 16             0xaaaad0840918      01ec47f9       ldr x1, [x0, 0xfd8]
│  sym.ref_pointer_as_array + 20             0xaaaad084091c      00000090       adrp x0, segment.LOAD0
│  sym.ref_pointer_as_array + 24             0xaaaad0840920      00a02891       add x0, x0, 0xa28
│  sym.ref_pointer_as_array + 28             0xaaaad0840924      6bffff97       bl sym.imp.printf
│  sym.ref_pointer_as_array + 32             0xaaaad0840928      80000090       adrp x0, map._home_pifan_Projects_cpp_pointer_array_pointer_crossref.rw_
│  sym.ref_pointer_as_array + 36             0xaaaad084092c      00ec47f9       ldr x0, [x0, 0xfd8]
│  sym.ref_pointer_as_array + 40             0xaaaad0840930      00004039       ldrb w0, [x0]
│  sym.ref_pointer_as_array + 44             0xaaaad0840934      e103002a       mov w1, w0
│  sym.ref_pointer_as_array + 48             0xaaaad0840938      00000090       adrp x0, segment.LOAD0
│  sym.ref_pointer_as_array + 52             0xaaaad084093c      00c02891       add x0, x0, 0xa30
│  sym.ref_pointer_as_array + 56             0xaaaad0840940      64ffff97       bl sym.imp.printf
│  sym.ref_pointer_as_array + 60             0xaaaad0840944      1f2003d5       nop
│  sym.ref_pointer_as_array + 64             0xaaaad0840948      fd7bc1a8       ldp x29, x30, [sp], 0x10
└  sym.ref_pointer_as_array + 68             0xaaaad084094c      c0035fd6       ret
```

---

The subject content of this article is referenced from the classic [《C语言深度解剖（第3版）》](https://item.jd.com/12720594.html) | 第 4 章 指针和数组 - 4.3 指针和数组之间的恩恩怨怨 - 4.3.3 指针和数组的定义与声明.

Sincere thanks to the original author!
