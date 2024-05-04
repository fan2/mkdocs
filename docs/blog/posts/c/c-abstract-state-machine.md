---
title: C Data Types - Abstract State Machine
authors:
  - xman
date:
    created: 2009-10-04T10:00:00
    updated: 2024-04-24T16:00:00
categories:
    - c
tags:
    - data_type
comments: true
---

C programs run in an abstract state machine that is mostly independent of the speciﬁc computer where it is launched.

<!-- more -->

---

**5 Basic values and data**:

We will now change our focus from “how things are to be done” (statements and expressions) to the things on which C programs operate: `values` and `data`. A concrete program at an instance in time has to *represent* values.

Similarly, representations of values on a computer can vary “culturally” from architecture to architecture or are determined by the *type* the programmer gave to the value. Therefore, we should try to reason primarily about values and not about representations if we want to write portable code.

!!! note "TAKEAWAY 5.1"

    TAKEAWAY 5.1 C programs primarily reason about values and not about their representation.

The representation that a particular value has should in most cases not be your concern; the compiler is there to organize the translation back and forth between values and representations.

---

**5.1 The abstract state machine**:

To explain the abstract state machine, we ﬁrst have to look into the concepts of a *value* (what state are we in), the *type* (what this state represents), and the *representation* (how state is distinguished). As the term abstract suggests, C’s mechanism allows different platforms to realize the abstract state machine of a given program differently according to their needs and capacities.

## 5.1.1 Values

A *value* in C is an abstract entity that usually exists beyond your program, the particular implementation of that program, and the representation of the value during a particular run of the program.

So far, most of our examples of values have been some kind of numbers. This is not an accident, but relates to one of the major concepts of C.

!!! note "TAKEAWAY 5.2"

    TAKEAWAY 5.2 All values are numbers or translate to numbers.

This property really concerns all values a C program is about, whether these are the characters or text we print, truth values, measures that we take, or relations that we investigate. Think of these numbers as mathematical entities that are independent of your program and its concrete realization.

The *data* of a program execution consists of all the assembled values of all objects at a given moment.

The *state* of the program execution is determined by:

- The executable
- The current point of execution
- The data
- Outside intervention, such as IO from the user

If we abstract from the last point, an executable that runs with the same data from the same point of execution must give the same result. But since C programs should be portable between systems, we want more than that. We don’t want the result of a computation to depend on the executable (which is platform speciﬁc) but ideally to depend only on the program speciﬁcation itself. An important step to achieve this platform independence is the concept of ***types***.

## 5.1.2 Types

A *type* is an additional property that C associates with values. Up to now, we have seen several such types, most prominently **size_t**, but also **double** and **bool**.

!!! note "TAKEAWAY 5.3~5.5"

    - TAKEAWAY 5.3 All values have a type that is statically determined.
    - TAKEAWAY 5.4 Possible operations on a value are determined by its type.
    - TAKEAWAY 5.5 A value’s type determines the results of all operations.

## 5.1.3 Binary representation and the abstract state machine

Unfortunately, the variety of computer platforms is not such that the C standard can completely impose the results of the operations on a given type. Things that are not completely speciﬁed as such by the standard are, for example, how the sign of a signed type is represented the (*sign representation*), and the precision to which a **double** ﬂoating-point operation is performed (*ﬂoating-point representation*). C only imposes properties on representations such that the results of operations can be deduced a *priori* from two different sources:

- The values of the operands
- Some characteristic values that describe the particular platform

For example, the operations on the type `size_t` can be entirely determined when inspecting the value of *SIZE_MAX* in addition to the operands. We call the model to represent values of a given type on a given platform the ***binary representation*** of the type.

!!! note "TAKEAWAY 5.6"

    TAKEAWAY 5.6 A type’s binary representation determines the results of all operations.

Generally, all information we need to determine that model is within reach of any C program: the C library headers provide the necessary information through named values (such as *SIZE_MAX*), operators, and function calls.

!!! note "TAKEAWAY 5.7"

    TAKEAWAY 5.7 A type’s binary representation is observable.

This binary representation is still a model and thus an abstract representation in the sense that it doesn’t completely determine how values are stored in the memory of a computer or on a disk or other persistent storage device. That representation is the object representation. In contrast to the binary representation, the object representation usually is not of much concern to us, as long as we don’t want to hack together values of objects in main memory or have to communicate between computers that have different platform models. Much later, in section 12.1, we will see that we can even observe the object representation, if such an object is stored in memory and we know its address.

As a consequence, all computation is ﬁxed through the values, types, and their binary representations that are speciﬁed in the program. The program text describes an abstract state machine C that regulates how the program switches from one state to the next. These transitions are determined by value, type, and binary representation only.

!!! note "TAKEAWAY 5.8"

    TAKEAWAY 5.8 (as-if) Programs execute as if following the abstract state machine.

---

!!! warning "Copyright clarification"

    Excerpt from [Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/).
    Copyright credit to [Jens Gustedt](https://gustedt.gitlabpages.inria.fr/modern-c/). 🫡
    For studying only, not commercial.
