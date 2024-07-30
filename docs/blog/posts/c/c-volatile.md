---
title: volatile in C/C++
authors:
  - xman
date:
    created: 2023-10-14T10:00:00
categories:
    - c
    - cpp
comments: true
---

[volatile (computer programming)](http://en.wikipedia.org/wiki/Volatile_variable) - [Why is volatile needed in C?](https://stackoverflow.com/questions/246127/why-is-volatile-needed-in-c)

`volatile` in C actually came into existence for the purpose of ***not*** caching the values of the variable automatically. It will tell the compiler not to cache the value of this variable. So it will generate code to take the value of the given `volatile` variable from the main memory every time it encounters it. This mechanism is used because at any time the value can be modified by the OS or any interrupt. So using `volatile` will help us accessing the value *afresh* every time.

<!-- more -->

## volatile in C

[TCPL](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/) | Appendix A - Reference Manual

A.4 Meaning of Identifiers | A.4.4 Type Qualifiers

> An object's type may have additional qualifiers. Declaring an object `const` announces that its value will not be changed; declaring it `volatile` announces that it has special properties relevant to optimization.

A.8 Declarations | A.8.2 Type Specifiers

> The `const` and `volatile` properties are new with the ANSI standard. The purpose of `const` is to announce objects that may be placed in *read-only* memory, and perhaps to **increase** opportunities for optimization. The purpose of `volatile` is to force an implementation to **suppress** optimization that could otherwise occur. For example, for a machine with memory-mapped input/output, a pointer to a device register might be declared as a pointer to `volatile`, in order to prevent the compiler from removing apparently redundant references through the pointer.

### inhibit optimization

[Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/) | 15 Performance | 15.3 Measurement and inspection

Listing 15.1 Measuring several code snippets repeatedly & Listing 15.6 Instrumenting three for loops with struct timespec

```c
timespec_get(&t[0], TIME_UTC);
/* Volatile for i ensures that the loop is effected */
for (uint64_t volatile i = 0; i < iterations; ++i) {
    /* do nothing */
}
timespec_get(&t[1], TIME_UTC);
/* s must be volatile to ensure that the loop is effected */
for (uint64_t i = 0; i < iterations; ++i) {
    s = i;
}
timespec_get(&t[2], TIME_UTC);
/ * Opaque computation ensures that the loop is effected */
for (uint64_t i = 1; accu0 < upper; i += 2) {
    accu0 += i;
}
timespec_get(&t[3], TIME_UTC);
```

In fact, when trying to measure `for` loops with no inner statement, we face a severe problem: an empty loop with no effect can and will be **eliminated** at compile time by the optimizer. Under normal production conditions, this is a good thing; but here, when we want to measure, this is annoying. Therefore, we show three variants of loops that should *not* be optimized out. The first declares the loop variable as `volatile` such that all operations on the variable must be emitted by the compiler. Listings 15.7 and 15.8 show GCC's and Clang's versions of this loop. We see that to comply with the `volatile` qualification of the loop variable, both have to issue several `load` and `store` instructions.

Listing 15.7 GCC's version of the first loop from Listing 15.6:

```asm
.L510:
    movq 24 (%rsp), %rax    // load i
    addq $1, %rax           // ++i
    movq %rax, 24 (%rsp)    // store i
    movq 24 (%rsp), %rax    // load i
    cmpq %rax, %r12
    ja .L510
```

Listing 15.8 Clang's version of the first loop from listing 15.6:

```asm
.LBB9_17:
    incq 24 (%rsp)          // ++i
    movq 24 (%rsp), %rax
    cmpq %r14, %rax
    jb .LBB9_17
```

For the next loop, we try to be a bit more economical by only forcing one volatile store to an auxiliary variable `s`. As we can see in listings 15.9, the result is assembler code that looks quite efficient: it consists of four instructions, an *addition*, a *comparison*, a *jump*, and a *store*.

Listing 15.9 GCC's version of the second loop from listing 15.6:

```asm
.L509:
    movq %rax, s (%rip)     // s = i
    addq $1, %rax           // ++i
    сmрq %rax, %r12
    jne .L509
```

To come even closer to the loop of the real measurements, in the next loop we use a trick: we perform index computations and comparisons for which the result is meant to be *opaque* to the compiler. Listing 15.10 shows that this results in assembler code similar to the previous, only now we have a second *addition* instead of the *store* operation.

Listing 15.10 GCC's version of the third loop from listing 15.6:

```asm
.L500:
    addq %rax, %rbx         // accu0 += i;
    addq $2, %rax           // i += 2
    cmpq %rbx, %r13         // accu0 < upper ?
    ja .L500
```

Table 15.1 summarizes the results we collected here and relates the differences between the various measurements. As we might expect, we see that loop 1 with the `volatile` store is 80% *faster* than the loop with a `volatile` loop counter. So, using a `volatile` loop counter is not a good idea, because it can deteriorate the measurement.

On the other hand, moving from loop 1 to loop 2 has a not-very-pronounced impact. The 6% gain that we see is smaller than the standard deviation of the test, so we can't even be sure there is a gain at all. If we would really like to know whether there is a difference, we would have to do more tests and hope that the standard deviation was narrowed down.

### block optimization

[Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/) | 17 Variations in control flow | 17.5 Long jumps

As a consequence, optimization can't make correct assumptions about objects that are changed in the normal code path of `setjmp` and referred to in one of the exceptional paths. There is only one recipe against that.

> TAKEAWAY 17.16: Objects that are modified across `longjmp` must be volatile.

Syntactically, the qualifier `volatile` applies similar to the other qualifiers `const` and `restrict` that we have encountered. If we declare depth with that qualifier

```c
unsigned volatile depth = 0;
```

and amend the prototype of descend accordingly, all accesses to this object will *use* the value that is ***stored*** in memory. Optimizations that try to make assumptions about its value are ***blocked*** out.

!!! note ""

    > TAKEAWAY 17.17: volatile objects are ***reloaded*** from memory each time they are ***accessed***.
    > TAKEAWAY 17.18: volatile objects are ***stored*** to memory each time they are ***modified***.

So `volatile` objects are ***protected*** from optimization, or, if we look at it negatively, they ***inhibit*** optimization. Therefore, you should only make objects `volatile` if you really need them to be.

## volatile in C++


### volatile Qualifier

[C++-Primer(5e)-3p-2013](https://www.amazon.com/Primer-5th-Stanley-B-Lippman/dp/0321714113) | 19. Specialized Tools and Techniques

Defined Terms: `volatile` Type qualifier that signifies to the compiler that a variable might be changed outside the direct control of the program. It is a signal to the compiler that it may not perform certain optimizations.

19.8 Inherently Nonportable Features | 19.8.2 volatile Qualifier

Programs that deal directly with hardware often have data elements whose value is controlled by processes outside the direct control of the program itself. For example, a program might contain a variable updated by the system clock. An object should be declared `volatile` when its value might be changed in ways outside the control or detection of the program. The `volatile` keyword is a directive to the compiler that it **should not** perform optimizations on such objects.

The `volatile` qualifier is used in much the same way as the `const` qualifier. It is an additional modifier to a type:

```cpp
volatile int display_register;  // int value that might change
volatile Task * curr_task;      // curr_task points to a volatile object
volatile int iax[max_size];     // each element in iax is volatile
volatile Screen bitmapBuf;      // each member of bitmapBuf is volatile
```

There is no interaction between the `const` and `volatile` type qualifiers. A type can be both `const` and `volatile`, in which case it has the properties of both.

In the same way that a class may define `const` member functions, it can also define member functions as `volatile`. Only `volatile` member functions may be called on `volatile` objects.

§ 2.4.2 (p. 62) described the interactions between the `const` qualifier and pointers. The same interactions exist between the `volatile` qualifier and pointers. We can declare pointers that are `volatile`, pointers to `volatile` objects, and pointers that are `volatile` that point to `volatile` objects:

```cpp
volatile int v;                 // v is a volatile int
int *volatile vip;              // vip is a volatile pointer to int
volatile int *ivp;              // ivp is a pointer to volatile int
volatile int *volatile vivp;    // vivp is a volatile pointer to volatile int
int *ip = &v;                   // error: must use a pointer to volatile
*ivp = &v;                      // ok: ivp is a pointer to volatile
vivp = &v;                      // ok: vivp is a volatile pointer to volatile
```

As with `const`, we may assign the address of a `volatile` object (or copy a pointer to a `volatile` type) only to a pointer to `volatile`. We may use a `volatile` object to initialize a reference only if the reference is `volatile`.

**Synthesized Copy Does Not Apply to volatile Objects**

One important difference between the treatment of `const` and `volatile` is that the synthesized *copy*/*move* and assignment operators cannot be used to *initialize* or *assign* from a `volatile` object. The synthesized members take parameters that are references to (nonvolatile) `const`, and we cannot bind a nonvolatile reference to a `volatile` object.

If a class wants to allow `volatile` objects to be copied, moved, or assigned, it must define its *own* versions of the copy or move operation. As one example, we might write the parameters as `const volatile` references, in which case we can copy or assign from any kind of `Foo`:

```cpp
class Foo {
public:
    // copy from a volatile object
    Foo(const volatile Food);
    // assign from a volatile object to a nonvolatile object
    Foo& operator=(volatile const Foo&);
    // assign from a volatile object to a volatile object
    Foo& operator=(volatile const Foo&) volatile;
    // remainder of class Foo
};
```

Although we can define copy and assignment for `volatile` objects, a deeper question is whether it makes any sense to copy a `volatile` object. The answer to that question depends intimately on the reason for using `volatile` in any particular program.

### external modification

[The_C++_Programming_Language(4e)-2013](https://www.stroustrup.com/4th.html) | 41. Concurrency - 41.4 volatile

The `volatile` specifier is used to indicate that an object can be **modified** by something *external* to the thread of control. For example:

```cpp
volatile const long clock_register; // updated by the hardware clock
```

A `volatile` specifier basically tells the compiler ***not*** to optimize away apparently redundant reads and writes. For example:

```cpp
auto t1 {clock_register};
// ... no use of clock_register here ...
auto t2 {clock_register};
```

Had *`clock_register`* not been `volatile`, the compiler would have been perfectly entitled to eliminate one of the reads and assume `t1==t2`.

Do not use `volatile` except in low-level code that deals directly with hardware.

Do not assume that `volatile` has special meaning in the memory model. It does not. It is not – as in some later languages – a synchronization mechanism. To get synchronization, use an `atomic`, a `mutex`, or a `condition_variable`.

---

Another use for volatile is signal handlers. If you have code like this:

```c
int quit = 0;
while (!quit)
{
    /* very small loop which is completely visible to the compiler */
}
```

The compiler is allowed to notice the loop body does not touch the `quit` variable and convert the loop to a `while (true)` loop. Even if the `quit` variable is set on the signal handler for `SIGINT` and `SIGTERM`; the compiler has no way to know that.

However, if the `quit` variable is declared `volatile`, the compiler is forced to **load** it every time, because it can be modified *elsewhere*. This is exactly what you want in this situation.

```c
volatile int quit = 0;
while (!quit)
{
    /* very small loop which is completely visible to the compiler */
}
```

`volatile` is only used to prevent compiler optimizations that would normally be useful and desirable. It is nothing about *thread safety*, *atomic access* or even *memory order*.

At run time, the processor may *still* reorder the data and command assignment, depending on the processor architecture. The hardware could get the wrong data (suppose a gadget is mapped to hardware I/O). A `memory barrier` is needed between data and command assignment.

## volatile in ARM

[ARM Compiler toolchain Using the Compiler Version 5.01](https://developer.arm.com/documentation/dui0472/m/compiler-coding-practices/compiler-optimization-and-the-volatile-keyword)

Higher optimization levels can reveal problems in some programs that are not apparent at lower optimization levels, for example, missing `volatile` qualifiers.

This can manifest itself in a number of ways. Code might become stuck in a loop while polling hardware, multi-threaded code might exhibit strange behavior, or optimization might result in the removal of code that implements deliberate timing delays. In such cases, it is possible that some variables are required to be declared as `volatile`.

The declaration of a variable as `volatile` tells the compiler that the variable can be modified at any time externally to the implementation, for example, by the operating system, by another thread of execution such as an interrupt routine or signal handler, or by hardware. Because the value of a `volatile`\-qualified variable can change at any time, the *`actual`* variable in memory must always be accessed whenever the variable is referenced in code. This means the compiler cannot perform optimizations on the variable, for example, caching its value in a register to avoid memory accesses. Similarly, when used in the context of implementing a sleep or timer delay, declaring a variable as `volatile` tells the compiler that a specific type of behavior is intended, and that such code must not be optimized in such a way that it removes the intended functionality.

In contrast, when a variable is not declared as `volatile`, the compiler can **assume** its value cannot be modified in unexpected ways. Therefore, the compiler can perform optimizations on the variable.

The use of the `volatile` keyword is illustrated in the two sample routines of the following table. Both of these routines loop reading a buffer until a status flag `buffer_full` is set to true. The state of `buffer_full` can change asynchronously with program flow.

The two versions of the routine differ only in the way that `buffer_full` is declared. The first routine version is incorrect. Notice that the variable `buffer_full` is not qualified as `volatile` in this version. In contrast, the second version of the routine shows the same loop where `buffer_full` is correctly qualified as `volatile`.

Table 5-5 C code for nonvolatile and volatile buffer loops

=== "Nonvolatile version of buffer loop"

    ```c
    int buffer_full;
    int read_stream(void)
    {
        int count = 0;
        while (!buffer_full)
        {
            count++;
        }
        return count;
    }
    ```

=== "Volatile version of buffer loop"

    ```c
    volatile int buffer_full;
    int read_stream(void)
    {
        int count = 0;
        while (!buffer_full)
        {
            count++;
        }
        return count;
    }
    ```

The following table shows the corresponding disassembly of the machine code produced by the compiler for each of the examples above, where the C code for each implementation has been compiled using the option `-O2`.

Table 5-6 Disassembly for nonvolatile and volatile buffer loop

=== "Nonvolatile version of buffer loop"

    ```asm linenums="1" hl_lines="4"
    read_stream PROC
        LDR      r1, |L1.28|
        MOV      r0, #0         // load count
        LDR      r1, [r1, #0]   // load buffer_full
    |L1.12|
        CMP      r1, #0
        ADDEQ    r0, r0, #1     // count += 1
        BEQ      |L1.12|        // infinite loop
        BX       lr
        ENDP
    |L1.28|
        DCD      ||.data||
        AREA ||.data||, DATA, ALIGN=2
    buffer_full
        DCD      0x00000000
    ```

=== "Volatile version of buffer loop"

    ```asm linenums="1" hl_lines="5"
    read_stream PROC
        LDR      r1, |L1.28|
        MOV      r0, #0         // load count
    |L1.8|
        LDR      r2, [r1, #0];  // load buffer_full
        CMP      r2, #0
        ADDEQ    r0, r0, #1     // count += 1
        BEQ      |L1.8|
        BX       lr
        ENDP
    |L1.28|
        DCD      ||.data||
        AREA ||.data||, DATA, ALIGN=2
    buffer_full
        DCD      0x00000000
    ```

In the disassembly of the nonvolatile version of the buffer loop in the above table, the statement `LDR r0, [r0, #0]` loads the value of `buffer_full` into register `r0` *outside* the loop labeled `|L1.12|`. Because `buffer_full` is not declared as `volatile`, the compiler assumes that its value cannot be modified outside the program. Having already read the value of `buffer_full` into `r0`, the compiler **omits** reloading the variable when optimizations are enabled, because its value cannot change. The result is the infinite loop labeled `|L1.12|`.

In contrast, in the disassembly of the volatile version of the buffer loop, the compiler assumes the value of `buffer_full` can change outside the program and performs no optimizations. Consequently, the value of `buffer_full` is loaded into register `r0` *inside* the loop labeled `|L1.8|`. As a result, the loop `|L1.8|` is implemented correctly in assembly code.

To avoid optimization problems caused by changes to program state external to the implementation, you must declare variables as `volatile` whenever their values can change unexpectedly in ways unknown to the implementation.

In practice, you must declare a variable as `volatile` whenever you are:

- Accessing memory-mapped peripherals.
- Sharing global variables between multiple threads.
- Accessing global variables in an *interrupt routine* or *signal handler*.

The compiler does not optimize the variables you have declared as `volatile`.

## references

[6.49 When is a Volatile Object Accessed?](https://gcc.gnu.org/onlinedocs/gcc/Volatiles.html)
[7.1 When is a Volatile C++ Object Accessed?](https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Volatiles.html)
[c++ - Is the definition of "volatile" this volatile, or is GCC having some standard compliancy problems? - Stack Overflow](https://stackoverflow.com/questions/38230856/is-the-definition-of-volatile-this-volatile-or-is-gcc-having-some-standard-co)

[volatile - Multithreaded Programmer's Best Friend](http://www.drdobbs.com/184403766)
[C++ and the Perils of Double-Checked Locking](http://www.aristeia.com/Papers/DDJ_Jul_Aug_2004_revised.pdf)
[Re: Usage of C "volatile" Keyword in Embedded Development](http://www.expertcore.org/viewtopic.php?f=18&t=2674#p7737)
[Nils Pipenbrinck's highly-voted answer](https://stackoverflow.com/a/246148/1677912)
[Why the "volatile" type class should not be used](https://www.kernel.org/doc/html/latest/process/volatile-considered-harmful.html#why-the-volatile-type-class-should-not-be-used)
