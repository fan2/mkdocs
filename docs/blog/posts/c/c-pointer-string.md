---
title: C Character Pointer and String Manipulation
authors:
  - xman
date:
    created: 2023-10-06T10:00:00
categories:
    - c
comments: true
---

In C program, a "string" is a null-terminated array of char. To be more precise, it's an array of characters terminated with a `'\0'` to mark the end.

C *doesn't* provide any operators for processing an entire string of characters as a unit, *only* arrays and pointers are involved.

<!-- more -->

## null-terminated string

The ASCII code corresponding to the character `'0'` is 0x30/48; and the ASCII code corresponding to `'\0'` is 0, which corresponds to the null character `NUL`. See [ASCII Table](https://www.asciitable.com/).

```c
    char nul = '\0'; // char c = 0;  // NUL
    char zero = '0'; // char c = 48; // 0x30
```

The most typical example is the [memset](https://en.cppreference.com/w/c/string/byte/memset) function defined in <string.h\>, it fills a buffer with a character.

```c
void *memset( void *dest, int ch, size_t count );
```

Usually, we'll initialize a new allocated memory with 0, the null character `'\0'`(`NUL`).

A null-terminated byte string (NTBS) is a sequence of nonzero bytes followed by a byte with value zero (the terminating null character). Each byte in a byte string encodes one character of some character set. For example, the character array `{'\x63','\x61','\x74','\0'}` is an [NTBS](https://en.cppreference.com/w/c/string/byte)(Null-terminated byte strings) holding the string `"cat"`(`{'c', 'a', 't', '\0'}`) in ASCII encoding.

```c
char s1[4] = "cat"; // char s1[] = {'c', 'a', 't', '\0'};
```

Typically, the string `"120"` contains both charater `'0'` and `'\0'`:

```c
char s2[4] = "120"; // char s1[] = {'1', '2', '0', '\0'};
```

That is, a string like `cat`, `120` always has one more element than is visible, which contains the value `0`(`'\0'`), so here the array has length 4.

It should be noted that [strlen](https://en.cppreference.com/w/c/string/byte/strlen) returns the length of the given null-terminated byte string, that is, the number of characters in a character array whose first element is pointed to by str up to and not including the first null character.

```c
size_t strlen( const char* str );
```

Both `strlen(s1)` and `strlen("120")` will return 3.

The following table shows the size and length of different versions of the definition of the string `"cat"`.

string             | sizeof | strlen
-------------------|--------|-------
char *s1="cat";    | 8      | 3
char s2[]="cat";   | 4      | 3
char s3[10]="cat"; | 10     | 3

1. `s1` is a pointer variable, sizeof any pointer returns `8` on rpi4b-ubuntu/aarch64.
2. `sizeof(s2)` returns exactly 4 by summing 3 non-zero bytes and 1 null character.
3. `sizeof(s3)` sizeof(s3)` returns the array size, 10 as declared.
4. `strlen("cat")` always return 3.

## character pointers

[TCPL](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/) | Chapter 5 - Pointers and Arrays - 5.5 Character Pointers and Functions

A string constant, written as `"I am a string"` is an array of characters. In the internal representation, the array is terminated with the null character `'\0'` so that programs can find the end. The length in storage is thus *one more* than the number of characters between the double quotes.

Perhaps the most common occurrence of string constants is as arguments to functions, as in `printf("hello, world\n");` When a character string like this appears in a program, access to it is through a character pointer; `printf` receives a pointer to the beginning of the character array. That is, a string constant is accessed by a pointer to its first element.

String constants need not be function arguments. If `pmessage` is declared as `char *pmessage;` then the statement `pmessage = "now is the time";` assigns to `pmessage` a pointer to the character array. This is *not* a string copy; *only* pointers are involved. C *does not* provide any operators for processing an entire string of characters as a unit.

There is an important difference between these definitions:

```c
char amessage[] = "now is the time"; /* an array */
char *pmessage = "now is the time"; /* a pointer */
```

`amessage` is an array, just big enough to hold the sequence of characters and `'\0'` that initializes it. Individual characters within the array may be changed but `amessage` will always refer to the *same* storage.

On the other hand, `pmessage` is a pointer, initialized to point to a string constant; the pointer may subsequently be *modified* to point elsewhere, but the result is undefined if you try to modify the string contents.

```text
           +------+       +-----------------+
amessage:  |  ⭕️--|----→  |now is the time\0|
           +------+       +-----------------+

           +-----------------+
amessage:  |now is the time\0|
           +-----------------+
```

We will illustrate more aspects of pointers and arrays by studying versions of two useful functions adapted from the standard library. The first function is `strcpy(s,t)`, which copies the string `t` to the string `s`. It would be nice just to say `s=t` but this copies the pointer, not the characters. To copy the characters, we need a *loop*. The array version first:

```c
/* strcpy: copy t to s; array subscript version */
void strcpy(char *s, char *t)
{
    int i;

    i = 0;
    while ((s[i] = t[i]) != '\0')
        i++;
}
```

For contrast, here is a version of `strcpy` with pointers:

```c
/* strcpy: copy t to s; pointer version */
void strcpy(char *s, char *t)
{
    int i;

    i = 0;
    while ((*s = *t) != '\0') {
        s++;
        t++;
    }
}
```

Because arguments are passed by value, `strcpy` can use the parameters `s` and `t` in any way it pleases. Here they are conveniently initialized pointers, which are marched along the arrays a character at a time, until the `'\0'` that terminates t has been copied into `s`.

In practice, `strcpy` would not be written as we showed it above. Experienced C programmers would prefer

```c
/* strcpy: copy t to s; pointer version 2 */
void strcpy(char *s, char *t)
{
    while ((*s++ = *t++) != '\0');
}
```

This moves the increment of `s` and `t` into the test part of the loop. The value of `*t++` is the character that `t` pointed to before `t` was incremented; the postfix `++` doesn't change t until after this character has been fetched. In the same way, the character is stored into the old `s` position before `s` is incremented. This character is also the value that is compared against `'\0'` to control the loop. The net effect is that characters are copied from `t` to `s`, up and *including* the terminating `'\0'`.

As the final abbreviation, observe that a comparison against `'\0'` is *redundant*, since the question is merely whether the expression is zero. So the function would likely be written as

```c
/* strcpy: copy t to s; pointer version 3 */
void strcpy(char *s, char *t)
{
    while (*s++ = *t++);
}
```

Although this may seem cryptic at first sight, the notational convenience is considerable, and the idiom should be mastered, because you will see it frequently in C programs.

The `strcpy` in the standard library (<string.h\>) returns the target string as its function value.

The second routine that we will examine is `strcmp(s,t)`, which compares the character strings `s` and `t`, and returns negative, zero or positive if `s` is lexicographically less than, equal to, or greater than `t`. The value is obtained by subtracting the characters at the first position where `s` and `t` *disagree*.

```c
/* strcmp: return <0 if s<t, 0 if s==t, >0 if s>t */
int strcmp(char *s, char *t)
{
    int i;

    for (i = 0; s[i] == t[i]; i++)
        if (s[i] == '\0')
            return 0;

    return s[i] - t[i];
}
```

The pointer version of `strcmp`:

```c
/* strcmp: return <0 if s<t, 0 if s==t, >0 if s>t */
int strcmp(char *s, char *t)
{
    for ( ; *s == *t; s++, t++)
        if (*s == '\0')
            return 0;

    return *s - *t;
}
```

Since `++` and `--` are either prefix or postfix operators, other combinations of `*` and `++` and `--` occur, although less frequently. For example, `*--p` decrements `p` before fetching the character that `p` points to. In fact, the pair of expressions

```c
*p++ = val; /* push val onto stack */
val = *--p; /* pop top of stack into val */
```

are the standard idiom for pushing and popping a stack.

The header <string.h\> contains declarations for the functions mentioned in this section, plus a variety of other string-handling functions from the standard library.

## const string literals

When a string constant appears in an expression, its value is a constant pointer. The compiler stores a copy of the specified characters somewhere in memory and stores a pointer to the first character.

1. `"cat"+1`: return a pointer that points to the second character 'a'
2. `*"cat"`: dereference the first character, return 'c'
3. `"cat"[2]`: array-and-index expression, return the third character 't'
4. `*("cat"+4)`: `*("cat"+3)` returns `'\0'`, one more step offside, returns unknown

So when would you use the above expression? Consider converting numbers within sixteen to hexadecimal characters and printing them out.

```c
    remainder = value % 16;
    if (remainder < 10) //0~9
        putchar(remainder + '0');
    else 10~15
        putchar(remainder - 10 + 'A');
```

The following code solves this problem in a more convenient way:

```c
    putchar("0123456789ABCDEF"[value % 16]);
```
