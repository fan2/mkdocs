---
title: x86's ill-timed WORD
authors:
  - xman
date:
    created: 2021-10-10T12:00:00
categories:
    - CS
tags:
    - WORD
    - DWORD
    - QWORD
comments: true
---

The [word size](https://en.wikipedia.org/wiki/Word_(computer_architecture)) is the computer's *preferred* size for moving units of information around; technically it's the **width** of your processor's registers. It reflects the amount of data that can be transmitted between memory and the processor in one **chunk**. Likewise, it may reflect the size of data that can be manipulated by the CPU's ALU in one **cycle**.

Whereas, in the universe of x86, `word` continues to designate a 16-bit quantity. Microsoft's Windows API maintains the programming language definition of ***WORD*** as 16 bits, despite the fact that the API may be used on a 32- or 64-bit x86 processor.

<!-- more -->

[Word Size families](https://en.wikipedia.org/wiki/Word_(computer_architecture)#Size_families)

Another example is the x86 family, of which processors of three different word lengths (16-bit, later 32- and 64-bit) have been released, while `word` continues to designate a 16-bit quantity. As software is routinely ported from one word-length to the next, some APIs and documentation define or refer to an older (and thus shorter) word-length than the full word length on the CPU that software may be compiled for. Also, similar to how bytes are used for small numbers in many programs, a shorter word (16 or 32 bits) may be used in contexts where the range of a wider word is not needed (especially where this can save considerable stack space or cache memory space). For example, Microsoft's Windows API maintains the programming language definition of ***WORD*** as 16 bits, despite the fact that the API may be used on a 32- or 64-bit x86 processor, where the standard word size would be 32 or 64 bits, respectively. Data structures containing such different sized words refer to them as:

- `WORD` (16 bits/2 bytes)
- `DWORD` (32 bits/4 bytes)
- `QWORD` (64 bits/8 bytes)

A similar phenomenon has developed in Intel's x86 assembly language – because of the support for various sizes (and backward compatibility) in the instruction set, some instruction mnemonics carry "`d`" or "`q`" identifiers denoting "double-", "quad-" or "double-quad-", which are in terms of the architecture's *original* 16-bit word size.

An example with a different word size is the IBM System/360 family. In the System/360 architecture, System/370 architecture and System/390 architecture, there are 8-bit bytes, 16-bit halfwords, 32-bit words and 64-bit doublewords. The z/Architecture, which is the 64-bit member of that architecture family, continues to refer to 16-bit halfwords, 32-bit words, and 64-bit doublewords, and additionally features 128-bit quadwords.

[x64 ABI conventions](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions#x64-type-and-storage-layout) - [x64 type and storage layout](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions#x64-type-and-storage-layout) - Scalar types

- Byte - 8 bits / 1 bytes
- Word - 16 bits / 2 bytes
- Doubleword - 32 bits / 4 bytes
- Quadword - 64 bits / 8 bytes
- Octaword - 128 bits / 16 bytes

## The name of 16 and 32 bits

[The name of 16 and 32 bits](https://stackoverflow.com/questions/14181090/the-name-of-16-and-32-bits)  

[Jonathon Reinhart](https://stackoverflow.com/a/14181184/3721132):

A byte is the smallest unit of data that a computer can work with. The C language defines char to be one "byte" and has CHAR_BIT bits. On most systems this is 8 bits.

A word on the other hand, is usually the size of values typically handled by the CPU. Most of the time, this is the size of the general-purpose registers. The problem with this definition, is it doesn't age well.

For example, the MS Windows `WORD` datatype was defined back in the early days, when 16-bit CPUs were the norm. When 32-bit CPUs came around, the definition stayed, and a 32-bit integer became a `DWORD`. And now we have 64-bit `QWORD`s.

Far from "universal", but here are several different takes on the matter:

Far from "universal", but here are several different takes on the matter:

**Windows**:

- BYTE - 8 bits, unsigned
- WORD - 16 bits, unsigned
- DWORD - 32 bits, unsigned
- QWORD - 64 bits, unsigned

**GDB**:

- Byte
- Halfword (two bytes).
- Word (four bytes).
- Giant words (eight bytes).

<**stdint.h**\>:

- uint8_t - 8 bits, unsigned
- uint16_t - 16 bits, unsigned
- uint32_t - 32 bits, unsigned
- uint64_t - 64 bits, unsigned
- uintptr_t - pointer-sized integer, unsigned

(Signed types exist as well.)

If you're trying to write portable code that relies upon the size of a particular data type (e.g. you're implementing a network protocol), always use <stdint.h\>.

[gustaf r](https://stackoverflow.com/a/14181166/3721132): `word` is not a datatype, it rather denotes the *natural* register size of the underlying hardware.

## How many bits is a WORD

[How many bits is a WORD and is that constant over different architectures?](https://stackoverflow.com/questions/621657/how-many-bits-is-a-word-and-is-that-constant-over-different-architectures)  

[Guffa](https://stackoverflow.com/a/621665/3721132):

The machine word size depends on the architecture, but also how the operating system is running the application.

In Windows x64 for example an application can be run either as a 64 bit application (having a 64 bit mahine word), or as a 32 bit application (having a 32 bit machine word). So the size of a machine word can *differ* even on the same machine.

The term `WORD` has different meaning depending on how it's used. It can either mean a machine word, or a type with a specific size. In x86 assembly language `WORD`, DOUBLEWORD (`DWORD`) and QUADWORD (`QWORD`) are used for 2, 4 and 8 byte sizes, *regardless* of the machine word size.

---

[jalf](https://stackoverflow.com/a/621661/3721132):

A word is typically the "native" data size of the CPU. That is, on a 16-bit CPU, a word is 16 bits, on a 32-bit CPU, it's 32 and so on.

And the exception, of course, is x86, where a word is 16 bit wide (because x86 was *originally* a 16-bit CPU), a `DWORD` is 32-bit (because it became a 32-bit CPU), and a `QWORD` is 64-bit (because it now has 64-bit extensions bolted on).

[Pete Kirkham](https://stackoverflow.com/a/621673/3721132):

`WORD` is a Windows specific 16-bit integer type, and is hardware independent.

If you mean a machine word, then there's no need to shout.

## What's the size of a QWORD

[assembly - What's the size of a QWORD on a 64-bit machine? - Stack Overflow](https://stackoverflow.com/questions/55430725/whats-the-size-of-a-qword-on-a-64-bit-machine)

[Peter Cordes](https://stackoverflow.com/a/55430777/3721132):

In x86 terminology/documentation, a "`word`" is 16 bits because x86 evolved out of 16-bit 8086. Changing the meaning of the term as extensions were added would have just been confusing, because Intel still had to document 16-bit mode and everything, and instruction mnemonics like `cwd` (sign-extend word to dword) bake the terminology into the ISA.

- x86 word = 2 bytes
- x86 dword = 4 bytes (double word)
- x86 qword = 8 bytes (quad word)
- x86 double-quad or xmmword = 16 bytes

---

Most other 64-bit ISAs evolved out of 32-bit ISAs (AArch64, MIPS64, PowerPC64, etc.), or were 64-bit from the start (Alpha), so "word" means 32 bits in that context.

- 32-bit word = 4 bytes
- dword = 8 bytes (double word), e.g. MIPS `daddu` is 64-bit integer add
- qword = 16 bytes (quad word), if supported at all.

---

"Machine word" and putting labels on architectures.

The whole concept of "machine word" [doesn't really apply to x86](https://stackoverflow.com/questions/68229585/are-machine-code-instructions-fetched-in-little-endian-4-byte-words-on-an-intel/68229991#68229991), with its machine-code format being a byte stream, and equal support for multiple operand-sizes, and unaligned loads/stores that mostly don't care about naturally aligned stuff, only cache line boundaries for normal cacheable memory.

Even "word oriented" RISCs can have a different natural size for registers and cache accesses than their instruction width, or what their documentation uses as a "word".

The whole concept of "`word size`" is over-rated in general, not just on x86. Even 64-bit RISC ISAs can load/store aligned 32-bit or 64-bit memory with equal efficiency, so pick whichever is most useful for what you're doing. Don't base your choice on figuring out which one is the machine's "word size", unless there's only one maximally efficient size (e.g. 32-bit on some 32-bit RISCs), then you can usefully call that the word size.

## x86_64 byte-stream machine code

[x86 64 - Are machine code instructions fetched in little endian 4-byte words on an Intel x86-64 architecture? - Stack Overflow](https://stackoverflow.com/questions/68229585/are-machine-code-instructions-fetched-in-little-endian-4-byte-words-on-an-intel/68229991#68229991)

No, x86 machine code is a [byte-stream](https://stackoverflow.com/questions/60905135/how-to-interpret-objdump-disassembly-output-columns); there's nothing word-oriented about it, except for 32-bit displacements and immediates which are little-endian. e.g. in `add qword [rdi + 0x1234], 0xaabbccdd`. It's physically fetched in 16-byte or 32-byte chunks on modern CPUs, and split on instruction boundaries in parallel to feed to decoders in parallel.

```Shell
48    81   87     34 12 00 00    dd cc bb aa       
REX.W add ModRM    le32 0x1234    le32 0xaabbccdd le32 (sign-extended to 64-bit)

   add    QWORD PTR [rdi+0x1234],0xffffffffaabbccdd
```

**x86-64 is not a word-oriented architecture; there is no single natural word-size, and things don't have to be aligned.** That concept is not very useful when thinking about x86-64. The integer register width happens to be 8 bytes, but that's not even the default operand-size in machine code, and you can use any operand-size from byte to qword with most instructions, and for SIMD from 8 or 16 byte up to 32 or 64 byte. And most importantly, alignment of wider integers isn't required in machine code, or even for data.

**An x86 16-bit "word" has absolutely zero connection to the concept of a "machine word" in CPU architecture.**
