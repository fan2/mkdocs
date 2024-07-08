---
title: C Named Constants
authors:
  - xman
date:
    created: 2023-10-10T10:00:00
categories:
    - c
comments: true
---

`const`-qualified read-only variables must be *initialized* and *named* at the same time as they are defined.

Pointers are opaque objects that can remain in a *valid*, *null* or indeterminate state. Always initialise pointers to *0* as soon as possible.

<!-- more -->

A common issue even in small programs is that they use special values for some purposes that are textually *repeated* all over. If for one reason or another this value changes, the program falls apart. Take an artificial setting as an example where we have arrays of strings, on which we would like to perform some operations:

Here we use the constant 3 in several places, and with three different "meanings" that are not very correlated. For example, an addition to our set of corvids would require two separate code changes. In a real setting, there might be many more places in the code that depend on this particular value, and in a large code base this can be very tedious to maintain.

> **TAKEAWAY** 5.38: All constants with a particular meaning must be ***named***.

It is equally important to distinguish constants that are *equal*, but for which equality is just a coincidence.

> **TAKEAWAY** 5.39: All constants with different meanings must be ***distinguished***.

C has surprisingly little means to specify named constants, and its terminology even causes a lot of confusion about which constructs effectively lead to *compile-time* constants. So we first have to get the terminology straight before we look into the only proper named constants that C provides: **enumeration** constants. The latter will help us to replace the different versions of 3 in our example with something more explanatory.

```c
char const * const bird[3] = { "raven", "magpie", "jay", };
char const * const pronoun[3] = { "we", "you", "they", };
char const * const ordinal[3] = { "first", "second", "third", };

// ...

for (unsigned i = 0; i < 3; ++i)
    printf("Corvid %u is the %s\n", i, bird[i]);

// ...

for (unsigned i = 0; i < 3; ++i)
    printf("%s plural pronoun is %s\n", ordinal[i], pronoun[i]);
```

A second, generic, mechanism complements this feature with simple text replacement: **macros**. Macros only lead to compile-time constants if their replacements are composed of literals of base types, as we have seen. If we want to provide something close to the concept of constants for more-complicated data types, we have to provide them as temporary objects.

## Read-only objects

Don't confuse the term `constant`, which has a very specific meaning in C, with objects that can't be modified. For example, in the previous code, `bird`, `pronoun`, and `ordinal` are not constants according to our terminology; they are **const**-qualified objects. This ***qualifier*** specifies that we don't have the right to change this object. For `bird`, *neither* the array entries *nor* the actual strings can be modified, and your compiler should give you a diagnostic if you try to do so:

> **TAKEAWAY**: 5.40: An object of const-qualified type is read-only.

That doesn't mean the compiler or run-time system may not perhaps change the value of such an object: other parts of the program may see that object without the qualification and change it. The fact that you cannot write the summary of your bank account directly (but only read it) doesn't mean it will remain constant over time.

There is another family of read-only objects that unfortunately are not protected by their type from being modified: *`string literals`*.

> **TAKEAWAY** 5.41: String literals are read-only.

If introduced today, the type of string literals would certainly be `char const[]`, an array of const-qualified characters. Unfortunately, the `const` keyword was introduced to the C language much *later* than string literals, and therefore it remained as it is for backward compatibility.

Arrays such as `bird` also use another technique to handle string literals. They use a *pointer* type, `char const * const`, to "refer" to a string literal. A visualization of such an array looks like this:

```text
                  [0]                      [1]                      [2]
        +--------------------+   +--------------------+   +--------------------+
        | char const * const |   | char const * const |   | char const * const |
        +--------------------+   +--------------------+   +--------------------+
        ↓                        ↓                        ↓
        "raven"                  "magpie"                 "jay"
```

That is, the string literals themselves are not stored inside the array bird but in some *other* place, and bird only refers to those places. We will see much later, in section 6.2 (Pointers as opaque types) and chapter 11 (Pointers), how this mechanism works.

## Pointers as opaque types

We now have seen the concept of pointers pop up in several places, in particular as a `void *` argument and return type, and as `char const * const` to manipulate references to string literals. Their main property is that they do not directly contain the information that we are interested in: rather, they refer, or *point*, to the data. C's syntax for pointers always has the peculiar `*`:

```c
char const * const p2string = "some text";
```

It can be visualized like this:

```text
            +--------------------+
  p2string  | char const * const |
            +--------------------+
            ↓
            "some text"
```

Compare this to the earlier array `jay0`, which itself contains all the characters of the string that we want it to represent:

```c
char jay0[] = "jay";
```

```text
             [0]            [1]            [2]            [3]
        +----------+   +----------+   +----------+   +-----------+
  jay0  | char 'j' |   | char 'a' |   | char 'y' |   | char '\0' |
        +----------+   +----------+   +----------+   +-----------+
```

In this first exploration, we only need to know some simple properties of pointers. The binary representation of a pointer is completely up to the platform and is not our business.

> **TAKEAWAY** 6.17: Pointers are *opaque* objects.

This means we will only be able to deal with pointers through the operations that the C language allows for them. As I said, most of these operations will be introduced later; in our first attempt, we will only need *initialization*, *assignment*, and *evaluation*.

One particular property of pointers that distinguishes them from other variables is their *state*.

> **TAKEAWAY** 6.18: Pointers are valid, null, or indeterminate.

For example, our variable `p2string` is always valid, because it points to the string literal `"some text"`, and, because of the second const, this association can never be changed.

The `null` state of any pointer type corresponds to our old friend *0*(NULL), sometimes known under its pseudonym *false*.

> **TAKEAWAY** 6.19: Initialization or assignment with 0 makes a pointer null.

Take the following as an example:

```c
char const * const p2nothing = 0;
```

We visualize this special situation like this:

```text
             +--------------------+
  p2nothing  | char const * const |
             +--------------------+
             ↓
             NULL
```

Note that this is different from pointing to an *empty* string:

```c
char const * const p2empty = "";
```

```text
          +--------------------+
  p2empty | char const * const |
          +--------------------+
          ↓
          ""
```

Usually, we refer to a pointer in the null state as a *null pointer*. Surprisingly, disposing of null pointers is really a feature.

> **TAKEAWAY** 6.20: In logical expressions, pointers evaluate to *false* if they are null.

Note that such tests can't distinguish valid pointers from indeterminate ones. So, the really "bad" state of a pointer is *indeterminate*, since this state is not observable.

> **TAKEAWAY** 6.21: Indeterminate pointers lead to *undefined* behavior.

An example of an indeterminate pointer could look like this:

```c
char const * const p2invalid;
```

```text
             +--------------------+
  p2invalid  | char const * const |
             +--------------------+
             ↓
             ☒
```

Because it is uninitialized, its state is indeterminate, and any use of it would do you harm and leave your program in an undefined state (takeaway 5.55). Thus, if we can't ensure that a pointer is valid, we *must* at least ensure that it is set to null.

> **TAKEAWAY** 5.55: Once the abstract state machine reaches an undeﬁned state, no further assumption about the continuation of the execution can be made.
> **TAKEAWAY** 6.22: Always initialize pointers.

---

!!! warning "Copyright clarification"

    Excerpt from [Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/).
    Copyright credit to [Jens Gustedt](https://gustedt.gitlabpages.inria.fr/modern-c/). 🫡
    For studying only, not commercial.
