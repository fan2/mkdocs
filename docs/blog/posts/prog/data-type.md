---
title: Data Type
authors:
  - xman
date:
    created: 2009-10-02T14:00:00
categories:
    - prog
comments: true
---

The type defines the **operations**(access or manipulate) that can be done on the data, the **meaning** of the data, and the **way** values of that type can be stored.

<!-- more -->

In computer science and computer programming, a [data type](https://en.wikipedia.org/wiki/Data_type) (or simply **type**) is a collection or grouping of data *values*, usually specified by a set of possible values, a set of allowed *operations* on these values, and/or a *representation* of these values as machine types.

A data type specification in a program constrains the possible values that an expression, such as a variable or a function call, might take. On literal data, it tells the [compiler](https://en.wikipedia.org/wiki/Compiler "Compiler") or [interpreter](https://en.wikipedia.org/wiki/Interpreter_\(computing\) "Interpreter (computing)") how the programmer intends to use the data. Most programming languages support basic data types of integer numbers (of varying sizes), floating-point numbers (which approximate real numbers), characters and Booleans.

## concept

A data type may be specified for many reasons: similarity, convenience, or to focus the attention. It is frequently a matter of good *organization* that aids the understanding of complex definitions. Almost all programming languages explicitly include the *notion* of data type, though the possible data types are often restricted by considerations of simplicity, computability, or regularity. An explicit data type declaration typically allows the compiler to choose an efficient machine representation, but the conceptual organization offered by data types should not be discounted.

Data types are used within [type systems](https://en.wikipedia.org/wiki/Type_system "Type system"), which offer various ways of defining, implementing, and using them. In a type system, a data type **represents** a constraint placed upon the interpretation of data, describing representation, interpretation and structure of values or objects stored in computer memory. The type system uses data type information to **check** correctness of computer programs that access or manipulate the data. A compiler may use the static type of a value to optimize the storage it needs and the choice of algorithms for operations on the value. 

Most programming languages also allow the programmer to define additional data types, usually by **combining** multiple elements of other types and defining the valid operations of the new data type. For example, a programmer might create a new data type named "complex number" that would include real and imaginary parts, or a color data type represented by three bytes denoting the amounts each of red, green, and blue, and a string representing the color's name.

## Machine data types

All data in computers based on digital electronics is represented as `bits` (alternatives 0 and 1) on the lowest level. The smallest addressable unit of data is usually a group of bits called a byte (usually an octet, which is 8 bits). The unit processed by machine code instructions is called a `word` (as of 2011, typically 32 or 64 bits).

Machine data types *expose* or make available fine-grained control over hardware, but this can also expose implementation details that make code less portable. Hence machine types are mainly used in systems programming or low-level programming languages. In higher-level languages most data types are *abstracted* in that they do not have a language-defined machine representation. The C programming language, for instance, supplies types such as Booleans, integers, floating-point numbers, etc., but the precise bit representations of these types are implementation-defined. The only C type with a precise machine representation is the `char` type that represents a byte.

## Classification

Data types may be categorized according to several factors:

- *Primitive data types* or built-in data types are types that are built-in to a language implementation. *User-defined data types* are non-primitive types. For example, Java's numeric types are primitive, while classes are user-defined.
- A value of an *atomic type* is a single data item that cannot be broken into component parts. A value of a *composite type* or *aggregate type* is a collection of data items that can be accessed individually. For example, an integer is generally considered atomic, although it consists of a sequence of bits, while an array of integers is certainly composite.
- *Basic data types* or *fundamental data types* are defined axiomatically from fundamental notions or by enumeration of their elements. *Generated data types* or *derived data types* are specified, and partly defined, in terms of other data types. All basic types are atomic. For example, integers are a basic type defined in mathematics, while an array of integers is the result of applying an array type generator to the integer type.

### Primitive data type

[Primitive data types](https://en.wikipedia.org/wiki/Primitive_data_type)

In computer science, `primitive data types` are a set of basic data types from which all other data types are constructed. Specifically it often refers to the limited set of data representations in use by a particular processor, which all compiled programs must use. Most processors support a similar set of primitive data types, although the specific representations vary. More generally, "primitive data types" may refer to the standard data types built into a programming language (`built-in types`). Data types which are not primitive are referred to as *derived* or *composite*.

Primitive types are almost always value types, but composite types may also be value types.

### Composite data type

[composite type](https://en.wikipedia.org/wiki/Composite_type)

In computer science, a `composite` data type or `compound` data type is any data type which can be constructed in a program using the programming language's primitive data types and other composite types. It is sometimes called a `structure` or `aggregate` type, although the latter term may also refer to arrays, lists, etc. The act of constructing a composite type is known as [composition](https://en.wikipedia.org/wiki/Object_composition). Composite data types are often contrasted with *scalar* variables.
