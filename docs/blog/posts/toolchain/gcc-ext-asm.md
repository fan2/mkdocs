---
title: GCC Extended Asm - C/C++ inline assembly
authors:
    - xman
date:
    created: 2023-10-15T10:00:00
categories:
    - toolchain
    - c
comments: true
---

With extended asm you can read and write C variables from assembler and perform jumps from assembler code to C labels.

<!-- more -->

[GCC - Using Assembly Language with C](https://gcc.gnu.org/onlinedocs/gcc/Using-Assembly-Language-with-C.html) - [Extended Asm](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html)
[GCC Inline Assembly and Its Usage in the Linux Kernel](https://dl.acm.org/doi/fullHtml/10.5555/3024956.3024958)

## Extended Asm

Extended asm syntax uses colons (‘`:`’) to delimit the operand parameters after the assembler template:

```c
asm asm-qualifiers ( AssemblerTemplate
                : OutputOperands
                [ : InputOperands
                [ : Clobbers ] ])

asm asm-qualifiers ( AssemblerTemplate
                    : OutputOperands
                    : InputOperands
                    : Clobbers
                    : GotoLabels)
```

- `AssemblerTemplate`: This is a literal string that is the template for the assembler code. It is a combination of fixed text and tokens that refer to the input, output, and goto parameters.
- `OutputOperands`: A comma-separated list of the C variables modified by the instructions in the AssemblerTemplate. An empty list is permitted.
- `InputOperands`: A comma-separated list of C expressions read by the instructions in the AssemblerTemplate. An empty list is permitted.
- `Clobbers`: A comma-separated list of registers or other values changed by the AssemblerTemplate, beyond those listed as outputs. An empty list is permitted.

### Input Operands

Input operands make values from C variables and expressions available to the assembly code.

Operands are separated by commas. Each operand has this format:

```c
[ [asmSymbolicName] ] constraint (cexpression)
```

#### constraint

A string constant specifying constraints on the placement of the operand; See [Constraints for asm Operands](https://gcc.gnu.org/onlinedocs/gcc/Constraints.html), for details.

Input constraint strings may ***not*** begin with either ‘`=`’ or ‘`+`’. When you list more than one possible location (for example, ‘"`irm`"’), the compiler chooses the most efficient one based on the current context. If you must use a specific register, but your Machine Constraints do not provide sufficient control to select the specific register you want, local register variables may provide a solution (see [Specifying Registers for Local Variables](https://gcc.gnu.org/onlinedocs/gcc/Local-Register-Variables.html)).

Input constraints can also be *digits* (for example, "`0`"). This indicates that the specified input must be in the same place as the output constraint at the (zero-based) index in the output constraint list. When using `asmSymbolicName` syntax for the output operands, you may use these names (enclosed in brackets ‘[]’) instead of digits.

If there are no output operands but there are input operands, place two consecutive colons where the output operands would go:

```c
__asm__ ("some instructions"
            : /* No outputs. */
            : "r" (Offset / 8));
```

Here is an example using symbolic names.

> [CMOVcc](https://mudongliang.github.io/x86/html/file_module_x86_id_34.html) is Conditional Move, `cmoveq`: Move if Equal to Zero.

```c
// input: test(%1), new(%2), old
// output: old(%0)
// equivalent: if (test == 0) old = new;
asm ("cmoveq %1, %2, %[result]"
        : [result] "=r"(result)
        : "r" (test), "r" (new), "[result]" (old));
```

#### cexpression

This is the C variable or expression being passed to the asm statement as input. The enclosing parentheses are a required part of the syntax.

### Output Operands

Operands are separated by commas. Each operand has this format:

```c
[ [asmSymbolicName] ] constraint (cvariablename)
```

#### constraint

A string constant specifying *`constraints`* on the placement of the operand; See [Constraints for asm Operands](https://gcc.gnu.org/onlinedocs/gcc/Constraints.html), for details.

Output constraints must begin with either ‘`=`’ (a variable overwriting an existing value) or ‘`+`’ (when reading and writing). When using ‘`=`’, do not assume the location contains the existing value on entry to the asm, except when the operand is tied to an input; see [Input Operands](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html#InputOperands).

After the prefix, there must be one or more additional constraints (see [Constraints for asm Operands](https://gcc.gnu.org/onlinedocs/gcc/Constraints.html)) that describe where the value *resides*. Common constraints include ‘`r`’ for register and ‘`m`’ for memory. When you list more than one possible location (for example, "`=rm`"), the compiler chooses the most efficient one based on the current context. If you list as many alternates as the asm statement allows, you permit the optimizers to produce the best possible code. If you must use a specific register, but your Machine Constraints do not provide sufficient control to select the specific register you want, local register variables may provide a solution (see [Specifying Registers for Local Variables](https://gcc.gnu.org/onlinedocs/gcc/Local-Register-Variables.html)).

#### cvariablename

Output operand expressions must be *lvalues*.

`cvariablename` Specifies a C lvalue expression to hold the output, typically a variable name. The enclosing parentheses are a required part of the syntax.

## examples

### i386 mov/add

A simple (if not particularly useful) example for i386 using `asm` might look like this:

```c
// move: the source comes first and the destination second in AT&T Syntax.
int src = 1;
int dst;

asm ("mov %1, %0\n\t"
    "add $1, %0"
    : "=r" (dst)
    : "r" (src));

printf("%d\n", dst);
```

This code makes no use of the optional `asmSymbolicName`. Therefore it references the first output operand as `%0` (were there a second, it would be `%1`, etc). The number of the first input operand is *one* greater than that of the *last* output operand.

Therefore, `dst` is %0, `src` is %1, and this code copies `src`(input) to `dst`(output) and add 1 to `dst`.

### i386 btsl

[BTS](https://blog.csdn.net/zwhfly/article/details/17647815) — Bit Test and Set

In the following i386 example, `old` (referred to in the template string as `%0`) and `*Base` (as `%1`) are outputs and `Offset` (`%2`) is an input:

```c
bool old;

__asm__ ("btsl %2,%1\n\t"   // Turn on zero-based bit #Offset in Base.
            "sbb %0,%0"     // Use the CF to calculate old.
            : "=r" (old), "+rm" (*Base)
            : "Ir" (Offset)
            : "cc");

return old;
```

clobber argument: The "`cc`" clobber indicates that the assembler code modifies the *`flags register`*. On some machines, GCC represents the condition codes as a specific hardware register; "`cc`" serves to name this register. On other machines, condition code handling is different, and specifying "`cc`" has no effect. But it is valid no matter what the target.

What does *`I`* mean in InputOperands `: "Ir" (Offset)`?

[Constraints for asm Operands](https://gcc.gnu.org/onlinedocs/gcc/Constraints.html) - [Simple Constraints](https://gcc.gnu.org/onlinedocs/gcc/Simple-Constraints.html):

> Other letters in the range ‘`I`’ through ‘`P`’ may be defined in a machine-dependent fashion to permit immediate integer operands with explicit integer values in specified ranges. For example, on the 68000, ‘`I`’ is defined to stand for the range of values 1 to 8. This is the range permitted as a shift count in the shift instructions.

### a64 add

Refer to [ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/latest) | 5: An Introduction to the ARMv8 Instruction Sets - 5.2 C/C++ inline assembly.

In this section, we briefly cover how to include assembly code within C or C++ language modules.

The `asm` keyword can incorporate inline GCC syntax assembly code into a function. For example:

```c linenums="1" hl_lines="6-8"
#include <stdio.h>

int add(int i, int j) {
    int res = 0;
    asm (
        "ADD %w[result], %w[input_i], %w[input_j]"
        : [result] "=r" (res)
        : [input_i] "r" (i), [input_j] "r" (j)
    );
    return res;
}

int main(int argc, char* argv[]) {
    int a = 1;
    int b = 2;
    int c = 0;

    c = add(a,b)

    printf("Result of %d + %d = %d\n", a, b, c);
}
```

The general form of an asm inline assembly statement is:

```c
asm(code [: output_operand_list [: input_operand_list [: clobber_list]]]);
```

where:

`code`(*AssemblerTemplate*) is the assembly code. In our example, this is `ADD %[result], %[input_i], %[input_j]`.

> Use `%w[name]` to operate on W(32) registers (as in this case). You can use `%x[name]` for X(64) registers too, but this is the default.

`output_operand_list`(*OutputOperands*) is an optional list of output operands, separated by commas. Each operand consists of a symbolic name in square brackets, a constraint string, and a C expression in parentheses. In this example, there is a single output operand: `[result] "=r" (res)`.

```c
[ [asmSymbolicName] ] constraint (cvariablename)
  [result]            "=r"       (res)
```

`input_operand_list`(*InputOperands*) is an optional list of input operands, separated by commas. Input operands use the same syntax as output operands. In this example, there are two input operands: `[input_i] "r" (i)` and `[input_j] "r" (j)`.

`clobber_list`(*Clobbers*) is an optional list of clobbered registers, or other values. In our example, this is omitted.

When calling functions between C/C++ and assembly code, you must follow the [AAPCS64](https://github.com/ARM-software/abi-aa/blob/2a70c42d62e9c3eb5887fa50b71257f20daca6f9/aapcs64/aapcs64.rst) rules.

### a64 barrier

Previously, in [ARM64 memory model - the reason for memory barriers](../arm/a64-memory-model.md), we mentioned that re-ordering at compile time can be avoided using the `barrier()` function macro.

```c
#define barrier() __asm__ __volatile__ ("" ::: "memory")
```

- [c - Working of \_\_asm__ \_\_volatile__ ("" : : : "memory")](https://stackoverflow.com/questions/14950614/working-of-asm-volatile-memory)
- [memory barrier --- asm volatile("" ::: "memory")](https://blog.csdn.net/KISSMonX/article/details/9105823)
- [gcc - difference in mfence and asm volatile ("" : : : "memory")](https://stackoverflow.com/questions/12183311/difference-in-mfence-and-asm-volatile-memory)

Let's analyze the definition of macro `barrier()`:

1. `__asm__`: The `asm` keyword is a GNU extension to indicate insert assembly code.
2. `__volatile__`: to disable certain optimizations, refer to [volatile in C/C++](../c/c-volatile.md).
3. `""`: *`AssemblerTemplate`* is empty.
4. `: : `: both the *`OutputOperands`* and *`InputOperands`* are empty.
5. *`Clobbers`* argument: `: "memory"`.

    - The "`memory`" clobber tells the compiler that the assembly code performs memory reads or writes to items other than those listed in the input and output operands (for example, accessing the memory pointed to by one of the input parameters). To ensure memory contains correct values, GCC may need to **flush** specific register values to memory before executing the *`asm`*. Further, the compiler does not assume that any values read from memory before an *`asm`* remain unchanged after that asm; it **reloads** them as needed. Using the "`memory`" clobber effectively forms a read/write memory barrier([memory_order_seq_cst; memory_order::seq_cst](https://en.cppreference.com/w/cpp/atomic/memory_order)) for the compiler.

    - Note that this clobber does not prevent the *processor* from doing speculative reads past the asm statement. To prevent that, you need processor-specific fence instructions(See [ARM64 Memory Ordering - barriers](../arm/a64-memory-barrier.md)).

### a64 arch_spin_lock

See [ARM64 Memory Barrier Cases](../arm/a64-memory-barrier-cases.md), the following is extracted from the `arch_spin_lock` implementation in linux 3.7.

```c linenums="1"
// <linux-3.7/arch/arm64/include/asm/spinlock.h>
static inline void arch_spin_lock(arch_spinlock_t *lock)
{
    unsigned int tmp;

    asm volatile (
    "   sevl\n"
    "1: wfe\n"
    "2: ldaxr %w0, [%1]\n"
    "   cbnz  %w0, 1b\n"
    "   stxr  %w0, %w2, [%1] \n"
    "   cbnz  %w0, 2b\n"
    : "=&r" (tmp)
    : "r" (&lock->lock), "r" (1)
    : "memory");
}
```

The *`AssemblerTemplate`* place multiple assembler instructions together in a single `asm` string, separated by the characters normally used in assembly code for the system. A combination that works in most places is a newline(`\n`) to break the line, plus a tab character(`\t`) to move to the instruction field (written as ‘`\n\t`’). Some assemblers allow semicolons as a line separator. However, note that some assembler dialects use semicolons to start a comment.

The first output operand `tmp` is `%w0`, the first input operand `&lock->lock` is `%1`, the second input operand `%w2` is constant *1*.

The corresponding C code for the AssemblerTemplate is as follows, lines per line:

```c linenums="9"
tmp = lock->lock;
if (tmp != 0) goto 1;
else lock->lock=1; // tmp saves the status result;
if (tmp != 0) goto 2;
```

What does *`&`* mean in OutputOperands `: "=&r" (tmp)`?

[Constraints for asm Operands](https://gcc.gnu.org/onlinedocs/gcc/Constraints.html) - [Constraint Modifier Characters](https://gcc.gnu.org/onlinedocs/gcc/Modifiers.html):

> Means (in a particular alternative) that this operand is an *earlyclobber* operand, which is written before the instruction is finished using the input operands. Therefore, this operand may not lie in a register that is read by the instruction or as part of any memory address.

> ‘`&`’ applies only to the alternative in which it is written. In constraints with multiple alternatives, sometimes one alternative requires ‘`&`’ while others do not.

The Clobber argument is `: "memory"` effectively forms a read/write memory barrier for the *AssemblerTemplate* code.

### a64 atomic_add

See [ARM64 Atomic operations](../arm/a64-atomic-operations.md), the following is extracted from the `arch_spin_lock` implementation in linux 3.7.

The code below uses the atomic addition function. The `atomic_add(i,v)` function is very simple. It adds `i` to `v` atomically.

```c linenums="1"
typede struct {
    int counter;
} atomic_t;

void atomic_add (int i, atomic_t *v)
{
    unsigned long tmp;
    int result;

    asm volatile("// atomic_add\n"
        "1: ldxr %w0, [%2] \n"
        "   add %w0, %w0, %w3\n"
        "   stxr %w1, %w0, [%2] \n"
        "   cbnz %w1, 1b"
        : "=&r" (result), "=&r" (tmp)
        : "r" (&v->counter), "Ir" (i)
        : "cc") ;
}
```

The *`AssemblerTemplate`* contains multiple assembler instructions separated by newline break (`\n`).

The first output operand `result` is `%w0`, the second output operand `temp` is `%w1`; the first input operand `&v->counter` is `%2`, the second input operand `i` is `%w3`.

The corresponding C code for the AssemblerTemplate is as follows, lines per line:

```c linenums="11"
result = v->counter;
result += i;
v->counter = result; // tmp saves the status result;
if (tmp != 0) goto 1;
```

See the cases above for the meaning of the constraints `"=&r"` and `"Ir"`.

---

Another simple way to to implement the `atomic_add()` function is to use the the `STADD` instruction.

```c linenums="1"
typede struct {
    int counter;
} atomic_t;

static inline void atomic_add(int i, atomic_t *v)
{
    asm volatile(
        "stadd %w[i], %[v]\n"
        : [i] "+r" (i), [v] "+Q" (v->counter)
        :
        : "cc");
}
```

The InputOperands `: ` is empty.

[STADD Ws, [Xn|SP]](https://developer.arm.com/documentation/dui0801/l/A64-Data-Transfer-Instructions/STADD--STADDL--STADDL--A64-): 32-bit, no memory ordering general registers. Atomic add on word or doubleword in memory, without return, atomically **loads** a 32-bit word or 64-bit doubleword from memory, **adds** the value held in a register to it, and **stores** the result back to memory.

What does `Q` mean in OutputOperands `[v] "+Q" (v-›counter)`?

[Constraints for asm Operands](https://gcc.gnu.org/onlinedocs/gcc/Constraints.html) - [Constraints for Particular Machines](https://gcc.gnu.org/onlinedocs/gcc/Machine-Constraints.html)

> `Q`: A memory address which uses a single base register with no offset.

`[v] "+Q" (v->counter)` is equivalent to `[v] "+r" (&v->counter)`?

### a64 cmpxchg_mb_64

For ARM64 architecture, one implementation of the `cmpxchg_mb_64()` function is as follows.

```c linenums="1"
u64 cmpxchg_mb_64 (volatile void *ptr, u64 old, u64 new)
{
    u64 tmp;

    asm volatile(
    "   mov x30, %x[old]\n"
    "   casal x30, %x[new], %[v]\n"
    "   mov %x[ret], x30"
    : [ret] "+r" (tmp), [v] "+Q" (*(unsigned long *)ptr)
    : [old] "r" (old), [new] "r" (new)
    : "memory");

    return tmp;
}
```

The *`AssemblerTemplate`* contains multiple assembler instructions separated by newline break (`\n`).

[CASAL](https://developer.arm.com/documentation/dui0801/l/A64-Data-Transfer-Instructions/CASA--CASAL--CAS--CASL--CASAL--CAS--CASL--A64-): Compare and Swap word or doubleword in memory.

- `CASAL Ws, Wt, [Xn|SP,#0]`: 32-bit, acquire and release general registers.
- load from memory with acquire semantics; store to memory with release semantics.

The corresponding C code for the AssemblerTemplate is as follows, lines per line:

```c linenums="6"
x30 = old; // load old value
if (x30 == *ptr) *ptr = new; // new is conditionally stored to ptr
tmp = x30; // return expected old
```

See the cases above for the meaning of the constraints `"+Q"`.
