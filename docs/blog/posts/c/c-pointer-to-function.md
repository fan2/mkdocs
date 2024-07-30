---
title: C Pointers to Functions
authors:
  - xman
date:
    created: 2023-10-11T16:00:00
categories:
    - c
comments: true
---

There is yet another construct for which the *address-of* operator `&` can be used: ***functions***.

A [function pointer](https://en.wikipedia.org/wiki/Function_pointer), also called a subroutine pointer or procedure pointer, is a pointer referencing executable code, rather than data. Dereferencing the function pointer yields the referenced function, which can be invoked and passed arguments just as in a normal function call. Such an invocation is also known as an "indirect" call, because the function is being invoked indirectly through a variable instead of directly through a fixed identifier or address.

Function pointers allow different code to be executed at runtime. They can also be passed to a function to enable callbacks.

The advantage of using function pointers is that multiple modules implementing the same function can be identified together, making maintenance easier and the system structure clearer. Or to summarise: it is easy to design layers, promotes system abstraction, reduces coupling and separates the interface from the implementation.

<!-- more -->

## Pointers to Functions

[TCPL](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/) | Chapter 5 - Pointers and Arrays - 5.11 Pointers to Functions

In C, a function itself is not a variable, but it is possible to define pointers to functions, which can be assigned, placed in arrays, passed to functions, returned by functions, and so on. We will illustrate this by modifying the sorting procedure written earlier in this chapter so that if the optional argument `-n` is given, it will sort the input lines numerically instead of lexicographically.

A sort often consists of three parts - a ***comparison*** that determines the ordering of any pair of objects, an ***exchange*** that reverses their order, and a ***sorting algorithm*** that makes comparisons and exchanges until the objects are in order. The sorting algorithm is *independent* of the comparison and exchange operations, so by passing different comparison and exchange functions to it, we can arrange to sort by different criteria. This is the approach taken in our new sort.

Lexicographic comparison of two lines is done by `strcmp`, as before; we will also need a routine `numcmp` that compares two lines on the basis of numeric value and returns the same kind of condition indication as `strcmp` does. These functions are declared ahead of `main` and a pointer to the appropriate one is passed to `qsort`. We have skimped on error processing for arguments, so as to concentrate on the main issues.

```c
#include <stdio.h>
#include <string.h>

#define MAXLINES 5000       /* max #lines to be sorted */
char *lineptr[MAXLINES];    /* pointers to text lines */

int readlines(char *lineptr[], int nlines);
void writelines(char *lineptr[], int nlines);

void qsort(void *lineptr[], int left, int right, int (*comp)(void *, void *));
int numcmp(char *, char *);

/* sort input lines */
int main(int argc, char *argv[]) {

    int nlines;         /* number of input lines read */
    int numeric = 0;    /* 1 if numeric sort */

    if (argc > 1 && strcmp(argv[1], "-n") == 0)
        numeric = 1;
    if ((nlines = readlines(lineptr, MAXLINES)) >= 0) {
        qsort((void**) lineptr, 0, nlines-1, (int (*)(void*,void*))(numeric ? numcmp : strcmp));
        writelines(lineptr, nlines);
        return 0;
    } else {
        printf("input too big to sort\n");
        return 1;
    }
}
```

In the call to `qsort`, `strcmp` and `numcmp` are *addresses* of functions. Since they are known to be functions, the `&` is *not necessary*, in the same way that it is not needed before an array name.

We have written `qsort` so it can process any data type, not just character strings. As indicated by the function prototype, `qsort` expects an array of pointers, two integers, and a function with two pointer arguments. The generic pointer type `void *` is used for the pointer arguments. Any pointer can be cast to `void *` and back again without loss of information, so we can call `qsort` by casting arguments to `void *`. The elaborate cast of the function argument casts the arguments of the comparison function. These will generally have no effect on actual representation, but assure the compiler that all is well.

```c
/* qsort: sort v[left]...v[right] into increasing order */
void qsort(void *v[], int left, int right, 
           int (*comp)(void *, void *))
{
    int i, last;

    void swap(void *v[], int, int);

    if (left >= right)  /* do nothing if array contains */
        return;         /* fewer than two elements */
    swap(v, left, (left + right)/2);
    last = left;

    for (i = left+1; i <= right; i++)
        if ((*comp)(v[i], v[left]) < 0)
            swap(v, ++last, i);
    swap(v, left, last);
    qsort(v, left, last-1, comp);
    qsort(v, last+1, right, comp);
}
```

The declarations should be studied with some care. The fourth parameter of `qsort` is

```c
int (*comp)(void *, void *)
```

which says that `comp` is a pointer to a function that has two `void *` arguments and returns an `int`.

The use of `comp` in the line

```c
if ((*comp)(v[i], v[left]) < 0)
```

is consistent with the declaration: `comp` is a pointer to a function, `*comp` is the function, and

```c
(*comp)(v[i], v[left])
```

is the call to it. The parentheses are needed so the components are correctly associated; without them,

```c
int *comp(void *, void *) /* WRONG */
```

says that `comp` is a function returning a pointer to an int, which is very different.

We have already shown `strcmp`, which compares two strings. Here is `numcmp`, which compares two strings on a leading numeric value, computed by calling `atof`:

```c
#include <stdlib.h>

/* numcmp: compare s1 and s2 numerically */
int numcmp(char *s1, char *s2)
{
    double v1, v2;

    v1 = atof(s1);
    v2 = atof(s2);
    if (v1 < v2)
        return -1;
    else if (v1 > v2)
        return 1;
    else
        return 0;
}
```

The `swap` function, which exchanges two pointers, is identical to what we presented earlier in the chapter, except that the declarations are changed to `void *`.

```c
void swap(void *v[], int i, int j)
{
    void *temp;
    temp = v[i];
    v[i] = v[j];
    v[j] = temp;
}
```

A variety of other options can be added to the sorting program; some make challenging exercises.

## Function pointers in detail

[Modern C, 1st Edition, 2019](https://www.amazon.com/Modern-C-Jens-Gustedt-ebook/dp/B0978347Z6/) | 11 Pointers - 11.4 Function pointers

There is yet another construct for which the *address-of* operator `&` can be used: ***functions***. We saw this concept pop up when discussing the `atexit` function (section 8.7: Program termination and assertions), which is a function that receives a function argument. The rule is similar to that for array decay, which we described earlier:

> TAKEAWAY 11.22 (function decay): A function `f` without a following opening `(` decays to a pointer to its start.

Syntactically, functions and function pointers are also similar to arrays in type declarations and as function parameters:

```c
typedef void atexit_function(void);

// Two equivalent definitions of the same type, which hides a pointer
typedef atexit_function* atexit_function_pointer;
typedef void (*atexit_function_pointer)(void);

// Five equivalent declarations for the same function
void atexit(void f(void));
void atexit(void (*f)(void));
void atexit(atexit_function f);
void atexit(atexit_function* f);
void atexit(atexit_function_pointer f);
```

Which of the semantically equivalent ways of writing the function declaration is more readable could certainly be the subject of much debate. The second version, with the `(*f)` parentheses, quickly gets difficult to read; and the fifth is frowned upon because it hides a pointer in a type. Among the others, I personally slightly prefer the *fourth* over the first.

The C library has several functions that receive function parameters. We have seen `atexit` and `at_quick_exit`. Another pair of functions in <stdlib.h\> provides generic interfaces for searching ([bsearch](https://en.cppreference.com/w/c/algorithm/bsearch)) and sorting ([qsort](https://en.cppreference.com/w/c/algorithm/qsort)):

```c
void qsort( void* ptr, size_t count, size_t size,
            int (*comp)(const void*, const void*) );

void* bsearch( const void *key, const void *ptr, size_t count, size_t size,
               int (*comp)(const void*, const void*) );
```

For the sake of brevity, we can typedef the function pointer and rewrite the declarations as the preferable fourth version:

```c
typedef int compare_function(void const* , void const*);

void* bsearch(void const* key, void const* base,
              size_t n, size_t size,
              compare_function* compar);

void qsort(void * base,
           size_t n, size_t size,
           compare_function* compar);
```

Both receive an array `base` as argument on which they perform their task. The address to the first element is passed as a `void` pointer, so all type information is lost. To be able to handle the array properly, the functions have to know the size of the individual elements (`size`) and the number of elements (`n`).

In addition, they receive a comparison function as a parameter that provides the information about the sort order between the elements. By using such a function pointer, the `bsearch` and `qsort` functions are very *generic* and can be used with any data model that allows for an ordering of values. The elements referred by the `base` parameter can be of any type ***T*** (`int`, `double`, `string`, or application defined) as long as the `size` parameter correctly describes the size of `T` and as long as the function pointed to by `compar` knows how to compare values of type `T` consistently.

A simple version of such a function would look like this:

```c
int compare_unsigned (void const* a, void const* b) {
    unsigned const* A = a;
    unsigned const* B = b;
    if (*A < *B) return -1;
    else if (*A > *B) return +1;
    else return 0;
}
```

The convention is that the two arguments point to elements that are to be compared, and the return value is strictly negative if `a` is considered less than `b`, 0 if they are equal, and strictly positive otherwise.

The return type of `int` seems to suggest that `int` comparison could be done more simply:

```c
/* An invalid example for integer comparison */
int compare_int (void const* a, void const* b) {
    int const* A = a;
    int const* B = b;
    return *A - *B; // may overflow!
}
```

But this is not correct. For example, if `*A` is big, say `INT_MAX`, and `*B` is negative, the mathematical value of the difference can be larger than *INT_MAX*.

Because of the `void` pointers, a usage of this mechanism should always take care that the type conversions are *encapsulated* similar to the following:

```c
/* A header that provides searching and sorting for unsigned. */

/* No use of inline here; we always use the function pointer. */
extern int compare_unsigned (void const*, void const*);

inline
unsigned const* bearch_unsigned(unsigned const key[static 1],
                                size_t nmeb, unsigned const base[nmeb]) {
    return bsearch (key, base, nmeb, sizeof base[0], compare_unsigned);
}

inline
void gsort_unsigned(size_t nmeb, unsigned base[nmeb]) {
    qsort(base, nmeb, sizeof base[0], compare_unsigned);
}
```

Here, `bsearch` (binary search) searches for an element that compares equal to `key[0]` and returns it, or returns a *null* pointer if no such element is found. It supposes that array `base` is already *sorted* consistently to the ordering that is given by the comparison function. This assumption helps to speed up the search. Although this is not explicitly specified in the C standard, you can expect that a call to `bsearch` will never make more than $log_2(n)$ calls to `compar`.

If `bsearch` finds an array element that is equal to `*key`, it returns the pointer to this element. Note that this drills a hole in C's type system, since this returns an unqualified pointer to an element whose effective type might be `const` qualified. Use with care. In our example, we simply convert the return value to `unsigned const*`, such that we will never even see an unqualified pointer at the call side of `bsearch_unsigned`.

The name `qsort` is derived from the *quick sort* algorithm. The standard doesn't impose the choice of the sorting algorithm, but the expected number of comparison calls should be of the magnitude of $nlog_2(n)$, just like quick sort. There are no guarantees for upper bounds; you may assume that its worst-case complexity is at most quadratic, $O(n^2)$.

Whereas there is a catch-all pointer type, `void*`, that can be used as a generic pointer to object types, *no* such generic type or implicit conversion exists for function pointers.

> TAKEAWAY 11.23: Function pointers must be used with their exact type.

Such a strict rule is necessary because the calling conventions for functions with different prototypes may be quite different and the pointer itself does not keep track of any of this.

The following function has a subtle problem because the types of the parameters are different than what we expect from a comparison function:

```c
/* Another invalid example for an int comparison function */
int compare_int (int const* a, int const* b) {
    if (*a < *b) return -1;
    else if (*a > *b) return +1;
    else return 0;
}
```

When you try to use this function with `qsort`, your compiler should complain that the function has the wrong type. The variant that we gave earlier using intermediate `void const*` parameters should be almost as efficient as this invalid example, but it also can be guaranteed to be correct on all C platforms.

*Calling* functions and function pointers with the `(...)` operator has rules similar to those for arrays and pointers and the `[...]` operator:

> TAKEAWAY 11.24: The function call operator `(...)` applies to function pointers.

```c
double f(double a);

// Equivalent calls to f, steps in the abstract state machine
f(3);       // Decay → call
(&f)(3);    // Address of → call
(*f)(3);    // Decay → dereference → decay → call
(*&f)(3);   // Address of → dereference → decay → call
(&*f)(3);   // Decay → dereference → address of → call
```

So technically, in terms of the abstract state machine, the pointer decay is *always* performed, and the function is called via a function pointer. The first, "natural" call has a hidden evaluation of the `f` identifier that results in the function pointer.

Given all this, we can use function pointers almost like functions:

```c
// In a header
typedef int logger_function(char const*, ...);
extern logger_function* logger;
enum logs { log_pri, log_ign, log_ver, log_num };
```

This declares a global variable `logger` that will point to a function that prints out logging information. Using a function pointer will allow the user of this module to choose a particular function dynamically:

```c
// In a .c file (TU)
extern int logger_verbose(char const*, ...);
static
int logger_ignore(char const*, ...) {
    return 0;
}
logger_function* logger = logger_ignore;

static
logger_function* loggers = {
    [log_pri] = printf,
    [log_ign] = logger_ignore,
    [log_ver] = logger_verbose,
};
```

Here, we are defining tools that implement this approach. In particular, function pointers can be used as a base type for arrays (here `loggers`). Observe that we use two external functions (`printf` and `logger_verbose`) and one static function (`logger_ignore`) for the array initialization: the storage class is *not* part of the function interface.

The `logger` variable can be assigned just like any other pointer type. Somewhere at startup we can have

```c
if (LOGGER < log_num) logger = loggers[LOGGER];
```

Then this function pointer can be used anywhere to call the corresponding function:

```c
logger("Do we ever see line \%lu of file \%s?", __LINE__+0UL, __FILE__);
```

This call uses the special macros `__LINE__` and `__FILE__` for the line number and the name of the source file. We will discuss these in more detail in section 16.3 (Accessing the calling context).

When using pointers to functions, you should always be aware that doing so introduces an *indirection* to the function call. The compiler first has to fetch the contents of `logger` and can only then call the function at the address it found there. This has a certain overhead and should be avoided in time-critical code.

## concrete example - signal handler

[Advanced Programming in the UNIX ® Environment, Third Edition](https://www.amazon.com/Advanced-Programming-UNIX-Environment-3rd/dp/0321637739/) | Chapter 10. Signals

The simplest interface to the signal features of the UNIX System is the signal function.

```c
#include <signal.h>
void (*signal(int signo, void (*handler)(int)))(int);
    Returns: previous disposition of signal (see following) if OK, SIG_ERR on error
```

The `signo` argument is just the name of the signal from Figure 10.1. The value of `func` is (a) the constant `SIG_IGN`, (b) the constant `SIG_DFL`, or (c) the address of a function to be called when the signal occurs. If we specify `SIG_IGN`, we are telling the system to ignore the signal. (Remember that we cannot ignore the two signals `SIGKILL` and `SIGSTOP`.) When we specify `SIG_DFL`, we are setting the action associated with the signal to its default value (see the final column in Figure 10.1). When we specify the address of a function to be called when the signal occurs, we are arranging to "catch" the signal. We call the function either the *signal handler* or the *signal-catching function*.

The prototype for the `signal` function states that the function requires two arguments and returns a pointer to a function that returns nothing (void). The signal function's first argument, `signo`, is an integer. The second argument is a pointer to a function that takes a single integer argument and returns nothing. The function whose address is returned as the value of signal takes a single integer argument (the final `(int)`). In plain English, this declaration says that the signal handler is passed a single integer argument (the signal number) and that it returns nothing. When we call signal to establish the signal handler, the second argument is a pointer to the function. The return value from signal is the pointer to the *previous* signal handler.

> Many systems call the signal handler with additional, implementation-dependent arguments. We discuss this further in Section 10.14.

The perplexing `signal` function prototype shown at the beginning of this section can be made much simpler through the use of the following typedef [Plauger 1992]:

```c
typedef void Sigfunc(int);
```

Then the prototype becomes

```c
Sigfunc *signal(int, Sigfunc *);
```

We've included this typedef in *apue.h* (Appendix B) and use it with the functions in this chapter.

If we examine the system's header [<signal.h\>](https://en.cppreference.com/w/c/program/signal), we will probably find declarations of the form

```c
#define SIG_ERR (void (*)())-1
#define SIG_DFL (void (*)())0
#define SIG_IGN (void (*)())1
```

These constants can be used in place of the "pointer to a function that takes an integer argument and returns nothing," the second argument to `signal`, and the return value from `signal`. The three values used for these constants need not be −1, 0, and 1. They must be three values that can never be the address of any declarable function. Most UNIX systems use the values shown.

---

Along with the definition of `SIG_DFL`, there is an example in the classic book [C Traps and Pitfalls](https://www.amazon.com/C-Traps-Pitfalls-Andrew-Koenig/dp/0201179288/): `(*(void(*)())0)()`, try to analyze the meaning of this expression.

1. `void(*)()`, this is a function pointer type, the function pointed to has no parameters and no return value.
2. `(void(*)())0`, this is to force 0 to be converted to a function pointer type. 0 is an address, which means that a function is stored in a section with a first address of 0.
3. `(*(void(*)())0)`, this is to read (dereference) the content of a section of memory starting at address 0, and its content is the function stored in a section with a first address of 0.
4. `(*(void(*)())0)()`, this is a function call.

It seems very simple, right? Let's rewrite the above example:

```c
(*(char * * (*)(char * *, char * *))0) (char * *, char * *);
```

Without the above analysis, it might not be easy to understand this expression. But now it should be a very simple thing, what do you think?

!!! note "Section 10.14: sigaction Function"

    The `sigaction` function allows us to examine or modify (or both) the action associated with a particular signal. This function supersedes the `signal` function from earlier releases of the UNIX System. Indeed, at the end of this section, we show an implementation of `signal` using `sigaction`.
