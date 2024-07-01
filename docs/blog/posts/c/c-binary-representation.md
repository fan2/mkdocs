---
title: C Basic Types - Binary Representions
authors:
  - xman
date:
    created: 2021-10-04T14:00:00
    updated: 2024-04-26T16:00:00
categories:
    - c
tags:
    - data_type
    - binary_representation
comments: true
---

Values have a type and a binary representation.

The *binary representation* of a type is a *model* that describes the possible values for that type. It is not the same as the in-memory *object representation* that describes the more or less physical storage of values of a given type.

!!! note "TAKEAWAY 5.49"

    TAKEAWAY 5.49 The same value may have different binary representations.

<!-- more -->

## 5.7.1 Unsigned integers

We have seen that unsigned integer types are those arithmetic types for which the standard arithmetic operations have a nice, closed mathematical description. They are closed under arithmetic operations:

!!! note "Unsigned wrap"

    TAKEAWAY 5.50 Unsigned arithmetic wraps nicely.

In mathematical terms, they implement a *ring*, $\Bbb{z}$~N~, the set of integers modulo some number $N$. The values that are representable are $0, \ldots, N−1$. The maximum value $N−1$ completely determines such an unsigned integer type and is made available through a macro with terminating `_MAX` in the name. For the basic unsigned integer types, these are `UINT_MAX`, `ULONG_MAX`, and `ULLONG_MAX` , and they are provided through <limits.h\>. As we have seen, the one for `size_t` is `SIZE_MAX` from <stdint.h\>.

The binary representation for non-negative integer values is always exactly what the term indicates: such a number is represented by binary digits $b_0, b_1, \ldots, b_{p-1}$ called ***bits***. Each of the bits has a value of 0 or 1. The value of such a number is computed as

$$
\sum_{i=0}^{p-1}b_i\ast2^i
$$

The value *p* in that binary representation is called the ***precision*** of the underlying type. Bit $b_0$ is called the ***least-significant bit***, and LSB, $b_{p−1}$ is the ***most-significant bit***(MSB).

Of the bits $b_i$ that are 1, the one with minimal index *i* is called the ***least-significant bit set***, and the one with the highest index is the ***most-significant bit set***. For example, for an unsigned type with $p = 16$, the value 240 would have $b_4 = 1, b_5 = 1, b_6 = 1$, and $b_7 = 1$. All other bits of the binary representation are 0, the least-significant bit set *i* is $b_4$, and the most-significant bit set is $b_7$. From (5.1), we see immediately that $2^p$ is the first value that cannot be represented with the type. Thus $N = 2^p$ and

!!! note "TAKEAWAY 5.51"

    The maximum value of any integer type is of the form $2^p − 1$.

Observe that for this discussion of the representation of non-negative values, we haven’t argued about the signedness of the type. These rules apply *equally* to signed and unsigned types. Only for unsigned types, we are lucky, and what we have said so far completely suffices to describe such an unsigned type.

!!! note "TAKEAWAY 5.52"

    Arithmetic on an unsigned integer type is determined by its precision.

Finally, table 5.4 shows the bounds of some of the commonly used scalars throughout this book.

Name | [min, max] | Where | Typical
-----|------------|-------|---------
size_t | [0, SIZE_MAX] | <stdint.h\> | [0, 2^w^−1], w = 32, 64
double | [±DBL_MIN, ±DBL_MAX ] | <float.h\> | [±2^−w−2^, ±2^w^], w = 1024
signed | [INT_MIN, INT_MAX] | <limits.h\> | [−2^w^, 2^w^ − 1], w = 31
unsigned | [0, UINT_MAX] | <limits.h\> | [0, 2^w^−1], w = 32
bool | [false, true ] | <stdbool.h\> | [0, 1]
ptrdiff_t | [PTRDIFF_MIN, PTRDIFF_MAX ] | <stdint.h\> | [−2^w^, 2^w^−1], w = 31, 63
char | [CHAR_MIN, CHAR_MAX ] | <limits.h\> | [0, 2^w−1], w = 7, 8
unsigned char | [0, UCHAR_MAX ] | <limits.h\> | [0, 255]

## 5.7.5 Signed integers

Signed types are a bit more complicated than unsigned types. A C implementation has to decide about two points:

- What happens on arithmetic overflow?
- How is the sign of a signed type represented?

Signed and unsigned types come in pairs according to their integer rank, with the notable two exceptions from table 5.1: char and bool. The binary representation of the signed type is constrained by the inclusion diagram that we have seen above.

!!! note "TAKEAWAY 5.54"

    TAKEAWAY 5.54 Positive values are represented independently from signedness.

Or, stated otherwise, a positive value with a signed type has the same representation as in the corresponding unsigned type. That is why the maximum value for any integer type can be expressed so easily (takeaway 5.51): signed types also have a precision, p, that determines the maximum value of the type.

The next thing the standard prescribes is that signed types have one additional bit, the ***sign bit***. If it is 0, we have a positive value; if it is 1, the value is negative. Unfortunately, there are different concepts of how such a sign bit can be used to obtain a negative number. C allows three different ***sign representations***:

- Sign and magnitude
- Ones’ complement
- Two’s complement

The first two nowadays probably only have historical or exotic relevance: for sign and magnitude, the magnitude is taken as positive values, and the sign bit simply specifies that there is a minus sign. Ones’ complement takes the corresponding positive value and complements all bits. Both representations have the disadvantage that two values evaluate to 0: there is a positive and a negative 0.

Commonly used on modern platforms is the two’s complement representation. It performs exactly the same arithmetic as we have seen for unsigned types, but the upper half of unsigned values (those with a high-order bit of 1) is interpreted as being negative. The following two functions are basically all that is needed to interpret unsigned values as signed values:

```c title="is_signed_less.c" linenums="1"
# inclue <limits.h>

bool is_negative(unsigned a) {
    unsigned const int_max = UINT_MAX/2;
    return a > int_max;
}

bool is_signed_less(unsigned a, unsigned b) {
    if (is_negative(b) && !is_negative(a)) return false;
    else return a < b;
}
```

Table 5.6 shows an example of how the negative of our example value 240 can be constructed. For unsigned types, `-A` can be computed as `~A + 1`. Two’s complement representation performs exactly the same bit operation for signed types as for unsigned types. It only *interprets* representations that have the high-order bit as being negative.

Op | Value | b15 … b0
---|-------|---------
A | 240 | 0000000011110000
~A | 65295 | 1111111100001111
+1 | 65295 | 0000000000000001
-A | 65296 | 1111111100010000

Prove that for unsigned arithmetic:

- A + ~A is full of '1', the maximum value of 2^w^ (w=16).
- A + ~A is −1.
- A + (~A + 1) == 0, 2^w^-1 overflow to 2^w^.

When done that way, signed integer arithmetic will again behave more or less nicely. Unfortunately, there is a pitfall that makes the outcome of signed arithmetic difficult to predict: overflow. Where unsigned values are forced to wrap around, the behavior of a signed overflow is ***undefined***. The following two loops look much the same:

```c
for (unsigned i = 1; i; ++i) do_something();
for (signed i = 1; i; ++i) do_something();
```

We know what happens for the first loop: the counter is incremented up to `UINT_MAX` and then wraps around to 0. All of this may take some time, but after UINT_MAX-1 iterations, the loop stops because i will have reached `0`.

For the second loop, everything looks similar. But because here the behavior of overflow is *undefined*, the compiler is allowed to *pretend* that it will never happen. Since it also knows that the value at the start is positive, it may assume that i, as long as the program has defined behavior, is never negative or 0. The as-if Rule (takeaway 5.8) allows it to optimize the second loop to

```c
while (true) do_something();
```

That’s right, an infinite loop.

!!! note "TAKEAWAY 5.55"

    TAKEAWAY 5.55 Once the abstract state machine reaches an undefined state, no further assumption about the continuation of the execution can be made.

Not only that, the compiler is allowed to do what it pleases for the operation itself (“Undefined? so let’s define it”), but it may also assume that it will never reach such a state and draw conclusions from that.

Commonly, a program that has reached an undefined state is referred to as “having” or “showing” undefined behavior. This wording is a bit unfortunate; in many such cases, a program does not “show” any visible signs of weirdness. In the contrary, bad things will be going on that you will not even notice for a long time.

!!! note "TAKEAWAY 5.56"

    TAKEAWAY 5.56 It is your responsibility to avoid undefined behavior of all operations.

What makes things even worse is that on some platforms with some standard compiler options, the compilation will just look right. Since the behavior is undefined, on such a platform, signed integer arithmetic might turn out to be basically the same as unsigned. But changing the platform, the compiler, or some options can change that. All of a sudden, your program that worked for years crashes out of nowhere.

Basically, what we have discussed up to this chapter always had well-defined behavior, so the abstract state machine is always in a well-defined state. Signed arithmetic changes this, so as long as you don’t need it, avoid it. We say that a program performs a trap C (or just traps) if it is terminated abruptly before its usual end.

!!! note "TAKEAWAY 5.57~5.59"

    TAKEAWAY 5.57 Signed arithmetic may trap badly.
    TAKEAWAY 5.58 In two’s complement representation, INT_MIN < -INT_MAX.
    TAKEAWAY 5.59 Negation may overflow for signed arithmetic.

For signed types, bit operations work with the binary representation. So the value of a bit operation depends in particular on the sign representation. In fact, bit operations even allow us to detect the sign representation:

```c title="signed_magic.c" linenums="1"
char const * sign_rep[4] =
{
    [1] = ”sign and magnitude”,
    [2] = ”ones' complement”,
    [3] = ”two's complement”,
    [0] = ”weird”, 
};
enum { sign_magic = -1&3, };

/* ... */

printf(”Sign representation: %s.\n”, sign_rep[sign_magic]);
```

The shift operations then become really messy. The semantics of what such an operation is for a negative value is not clear.

!!! note "TAKEAWAY 5.60"

    TAKEAWAY 5.60 Use unsigned types for bit operations.

## 5.7.6 Fixed-width integer types

The precision for the integer types that we have seen so far can be inspected indirectly by using macros from [<limits.h\>](https://en.cppreference.com/w/c/types/limits), such as `UINT_MAX` and `LONG_MIN`. The C standard only gives us a *minimal* precision for them. For the unsigned types, these are

type    | minimal precision
--------|---------
bool | 1
unsigned char | 8
unsigned short | 16
unsigned | 16
unsigned long | 32
unsigned long long | 64

Under usual circumstances, these guarantees should give you enough information; but under some technical constraints, such guarantees might not be sufficient, or you might want to emphasize a particular precision. This may be the case if you want to use an unsigned quantity to represent a bit set of a known maximal size. If you know that 32-bit will suffice for your set, depending on your platform, you might want to choose `unsigned` or `unsigned long` to represent it.

The C standard provides names for *exact-width integer types* in [<stdint.h\>](https://en.cppreference.com/w/c/types/integer). As the name indicates, they are of an exact prescribed “width,” which for provided unsigned types is guaranteed to be the same as their precision.

!!! note "TAKEAWAY 5.61~5.62"

    TAKEAWAY 5.61 If the type uint{==N==}_t is provided, it is an unsigned integer type with exactly N bits of width and precision.
    TAKEAWAY 5.62 If the type int{==N==}_t is provided, it is signed, with two’s complement representation and has a width of exactly N bits and a precision of N − 1.

None of these types is guaranteed to exist, but for a convenient set of powers of two, the `typedef` must be provided if types with the corresponding properties exist.

!!! note "TAKEAWAY 5.63"

    TAKEAWAY 5.63 If types with the required properties exist for values of N = 8, 16, 32, and 64, types uint{==N==}_t and int{==N==}_t, respectively, must be provided.

Nowadays, platforms usually provide `uint8_t`, `uint16_t`, `uint32_t`, and `uint64_t` unsigned types and `int8_t`, `int16_t`, `int32_t`, and `int64_t` signed types.

---

!!! warning "Copyright clarification"

    Excerpt from [Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/).
    Copyright credit to [Jens Gustedt](https://gustedt.gitlabpages.inria.fr/modern-c/). 🫡
    For studying only, not commercial.
