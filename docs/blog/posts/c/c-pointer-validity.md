---
title: C Pointer Validity
authors:
  - xman
date:
    created: 2023-10-11T10:00:00
categories:
    - c
comments: true
---

Previously, we've discussed [const qualifier](./c-const-readonly.md) and [Named Constants](./c-named-const.md) in C. Today let's go back to the root and have a look at null pointers and pointer validity. After all, everything starts at zero and disappears without a trace.

<!-- more -->

## Pointer validity

Earlier (TAKEAWAY 11.1: Using `*` with an indeterminate or null pointer has undefined behavior.) we saw that we must be careful about the address that a pointer contains (or does not contain). Pointers have a value, the address they contain, and that value can change.

Setting a pointer to `0` if it does not have a valid address is very important and should not be forgotten. It helps to check and keep track of whether a pointer has been set.

> TAKEAWAY 11.9: Pointers have truth.

To avoid clunky comparisons (TAKEAWAY 3.3: Don't compare to 0, false, or true.), in C programs you often will see code like this:

```c
char const* name = 0; // Do something that eventually sets name

if (name) {
    printf("today's name is %s\n", name);
} else {
    printf("today we are anonymous\n");
}
```

Therefore, it is important to control the state of all pointer variables. We have to ensure that pointer variables are *always* null, unless they point to a valid object that we want to manipulate.

> TAKEAWAY 11.10: Set pointer variables to `0` as soon as you can.

In most cases, the simplest way to ensure this is to initialize pointer variables explicitly (TAKEAWAY 6.22: Always initialize pointers.).

We have seen some examples of *representations* of different types: that is, the way the platform stores the value of a particular type in an object. The representation of one type, `size_t`, say, could be completely senseless to another type, for example `double`. As long as we only use variables directly, C's type system will protect us from any mixup of these representations; a `size_t` object will always be accessed as such and never be interpreted as a (senseless) `double`.

If we did not use them carefully, pointers could break that barrier and lead us to code that tries to interpret the representation of a `size_t` as `double`. More generally, C even has coined a term for bit patterns that are nonsense when they are interpreted as a specific type: a ***trap representation*** for that type. This choice of words (*trap*) is meant to intimidate.

> TAKEAWAY 11.11: Accessing an object that has a trap representation of its type has undefined behavior.

Ugly things can happen if you do, so please don't try.

Thus, not only must a pointer be set to an object (or null), but such an object also must have the correct type.

> TAKEAWAY 11.12: When dereferenced, a pointed-to object must be of the designated type.

As a direct consequence, a pointer that points beyond array bounds must not be dereferenced:

```c
double A[2] = { 0.0, 1.0, };
double* p = &A[0];
printf ("element %g\n", *p);    // Referencing object
++p;                            // Valid pointer
printf ("element %g\n", *p) ;   // Referencing object
++p;                            // Valid pointer, no object
printf ("element %g\n", *p);    // Referencing non-object
                                // Undefined behavior
```

Here, on the last line, `p` has a value that is beyond the bounds of the array. Even if this might be the address of a valid object, we don't know anything about the object it is pointing to. So even if `p` is valid at that point, accessing the contents as a type of `double` makes no sense, and C generally forbids such access.

In the previous example, the pointer addition itself is *correct*, as long as we don't access the object on the last line. The valid values of pointers are all addresses of array elements and the address beyond the array. Otherwise, `for` loops with pointer addition as in the example wouldn't work reliably.

> TAKEAWAY 11.13: A pointer must point to a valid object or one position beyond a valid object or be null.

So the example only worked up to the last line because the last `++p` left the pointer value *just* one element after the array. This version of the example still follows a similar pattern as the one before:

```c
double A[2] = { 0.0, 1.0, };
double* p = &A[0];
printf ("element %g\n", *p);    // Referencing object
p += 2;                         // Valid pointer, no object
printf ("element %g\n", *p);    // Referencing non-object
                                // Undefined behavior
```

Whereas this last example may **crash** at the increment operation:

```c
double A[2] = { 0.0, 1.0, };
double* p = &A[0];
printf ("element %g\n", *p);    // Referencing object
p += 3;                         // Invalid pointer addition
                                // Undefined behavior
```

## Null pointers

You may have wondered why, in all this discussion about pointers, the macro [NULL](https://en.cppreference.com/w/c/types/NULL) has not yet been used. The reason is that, unfortunately, the simple concept of a "generic pointer of value 0" didn't succeed very well.

C has the concept of a *`null pointer`* that corresponds to a `0` value of any pointer type.

> Note the different capitalization of *null* versus `NULL`.

Here,

```c
double const * const nix = 0;
double const * const nax = nix;
```

`nix` and `nax` would be pointer objects of value `0`. But unfortunately, a *`null pointer constant`* is then not what you'd expect.

First, here the term *constant* refers to a compile-time constant, not to a const-qualified object. So for that reason, both pointer objects are *not* null pointer constants. Second, the permissible type for these constants is restricted: it may be any constant expression of integer type or of type `void*`. Other pointer types are not permitted, and we will learn about pointers of that "type" in section 12.4 (Pointers to unspecific objects).

The definition in the C standard of a possible expansion of the macro `NULL` is quite loose; it just has to be a null pointer constant. Therefore, a C compiler could choose any of the following for it:

Expansion | Type
----------|---------
0U        | unsigned
0 / '\0'  | signed

Enumeration constant of value `0`:

const    | type
---------|-------------------
0UL      | unsigned long
0L       | signed long
0ULL     | unsigned long long
0LL      | signed long long
(void*)0 | void*

Commonly used values are `0`, `0L`, and `(void*)0`.

It is important that the type behind `NULL` is not prescribed by the C standard. Often, people use it to emphasize that they are talking about a pointer constant, which it simply isn't on many platforms. Using `NULL` in a context that we have not mastered completely is even dangerous. This will in particular appear in the context of functions with a variable number of arguments, which will be discussed in section 16.5.2 (A detour: variadic functions). For the moment, we will go for the simplest solution:

> TAKEAWAY 11.14: Don't use `NULL`.

`NULL` hides more than it clarifies. Either use `0` or, if you really want to emphasize that the value is a pointer, use the magic token sequence `(void*)0` directly. For example, POSIX requires `NULL` to be defined as an integer constant expression with the value ​`0`​ cast to `void*`.

## Wild pointers

In [C Named Constants](./c-named-const.md), we've mentioned one particular property of pointers that distinguishes them from other variables is their *state*. Pointers are either valid, null, or indeterminate.

Because it is uninitialized, its state is indeterminate. Indeterminate pointers(aka *`wild pointers`*) lead to *undefined* behavior.

Any use of wild pointers would do you harm and leave your program in an undefined state (takeaway 5.55). Thus, if we can't ensure that a pointer is valid, we *must* at least ensure that it is set to null.

Often mentioned in conjunction with wild pointers, there is also the concept of dangling pointers.

A *`dangling pointer`* points to a memory address which *used to* hold a variable. Since the address it points at is no longer reserved, using it will lead to *unexpected* results.

```c linenums="1" hl_lines="8"
int main(int argc, char* argv[])
{
    int *ptr;
    ptr = (int *)malloc(sizeof(int));
    *ptr = 1;
    printf("%d", *ptr); /* prints 1 */
    free(ptr);          /* deallocation */
    *ptr = 5;
    printf("%d", *ptr); /* may or may not print 5 */

    return 0;
}
```

Though the memory has been deallocated by `free(ptr)`, the pointer to integer `ptr` still points to that unreserved memory address.

To a certain extent, a dangling pointer can also be considered a type of wild pointer. They all point to unsafe areas where access should be prohibited in order to avoid undefined consequences.

Finally, let's look at two other words that related to "wild" and end with a summary.

- *Feral child*: a child who is unwanted and unattended; a child who is unruly and mischievous.
- *Feral dog*: a dog without an owner, a dog without a chain, a dog that likes to bite people everywhere.

The best way to deal with a feral child is to give them a set of rules and discipline them well. If you find that it does not follow the rules, you should punish it. The best way to deal with a wild dog is to tie it up with a dog chain and prevent it from running around.

Dealing with a wild pointer is probably more difficult than dealing with a wild child or a wild dog. We need to use both methods of dealing with wild children and wild dogs. We need both rules and chains.

Earlier we compared memory with a ruler and easy memory. 0mm on the ruler is the memory address 0, the zero pointer. The chain that binds the "wild pointer" is this "0". It is best to initialise the pointer variable to `0` when defining it, and to set it to `0` after using it.

Remember to always initialize pointers. Always keep pointers in a certain state, pointing to something(valid) or nothing(null), don't let them invalid(undefined, indeterminate; wild, dangling)!

In a nutshell, except when in use, guarantee that the pointer is always "tied" to address `0`, so it will be obedient.

---

!!! warning "Copyright clarification"

    Excerpt from [Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/) | 11.1 Pointer operations.
    Copyright credit to [Jens Gustedt](https://gustedt.gitlabpages.inria.fr/modern-c/). 🫡
    For studying only, not commercial.
