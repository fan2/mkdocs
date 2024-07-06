---
title: C Pointer as Function Argument
authors:
  - xman
date:
    created: 2023-10-08T10:00:00
categories:
    - c
comments: true
---

So far, we've discussed [C Pointers and Arrays](./c-pointer-array.md), [C Character Pointer and String Manipulation](./c-pointer-string.md) and [C Pointer and Array Cross Reference with Mismatched Type](./c-pointer-array-crossref.md). To be frank, there are some very confusing names for some of these concepts, and it's very easy for even an old hand programmer to get them all mixed up.

In this article, we'll explore the syntax of passing parameters to functions using arrays or pointers. What does it actually do behind the scenes? Can it really pass an array or a pointer to a function? What is the connection and difference between these two ways of passing parameters?

<!-- more -->

Related contents: [ABI & Calling conventions](../cs/calling-convention.md), [ARM64 PCS - Procedure Call Standard](../arm/a64-pcs-concepts.md), [ARM64 PCS - calling convention and stack layout](../arm/a64-pcs-demo.md).

## Pointers and Function Arguments

[TCPL](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628/) | Chapter 5 - Pointers and Arrays - 5.2 Pointers and Function Arguments

Since C passes arguments to functions by *value*, there is no direct way for the called function to *alter* a variable in the calling function. For instance, a sorting routine might exchange two out-of-order arguments with a function called `swap`. It is not enough to write **`swap(a, b);`** where the `swap` function is defined as

```c
void swap(int x, int y) /* WRONG */
{
    int temp;

    temp = x;
    x = y;
    y = temp;
}
```

Because of call by value, `swap` can't affect the arguments `a` and `b` in the routine that called it. The function above swaps ***copies*** of `a` and `b`.

The way to obtain the desired effect is for the calling program to pass ***pointers*** to the values to be changed: **`swap(&a, &b);`** Since the operator `&` produces the address of a variable, `&a` is a pointer to `a`. In swap itself, the parameters are declared as pointers, and the operands are accessed indirectly through them.

```c
void swap(int *px, int *py) /* interchange *px and *py */
{
    int temp;

    temp = *px;
    *px = *py;
    *py = temp;
}
```

### implementation of getint

Pointer arguments enable a function to access and *change* objects in the function that called it. As an example, consider a function `getint` that performs free-format input conversion by breaking a stream of characters into integer values, one integer per call. `getint` has to return the value it found and also signal end of file when there is no more input. These values have to be *passed back* by separate paths, for no matter what value is used for `EOF`, that could also be the value of an input integer.

One solution is to have `getint` return the end of file status as its function value, while using a pointer argument to store the converted integer back in the calling function. This is the scheme used by `scanf` as well; see Section 7.4.

The following loop fills an array with integers by calls to `getint`:

```c
int n, array[SIZE], getint(int *);

for (n = 0; n < SIZE && getint(&array[n]) != EOF; n++)
    ;
```

Each call sets `array[n]` to the next integer found in the input and increments `n`. Notice that it is essential to pass the address of `array[n]` to getint. Otherwise there is no way for `getint` to *communicate* the converted integer *back* to the caller.

Our version of `getint` returns EOF for end of file, zero if the next input is not a number, and a positive value if the input contains a valid number.

```c linenums="1" hl_lines="23"
#include <ctype.h>

int getch(void); void ungetch(int);

/* getint: get next integer from input into *pn */
int getint(int *pn) 
{
    int c, sign;

    while (isspace(c = getch())) /* skip white space */
        ;

    if (!isdigit(c) && c != EOF && c != '+' && c != '-') {
        ungetch(c); /* it is not a number */
        return 0;
    }

    sign = (c == '-') ? -1 : 1;
    if (c == '+' || c == '-')
        c = getch();

    for (*pn = 0; isdigit(c), c = getch())
        *pn = 10 * *pn + (c - '0');

    *pn *= sign;
    if (c != EOF)
        ungetch(c);
    
    return c;
}
```

## Array and Pointer Parameters

[《C语言深度解剖（第3版）》](https://item.jd.com/12720594.html) | 第 4 章 指针和数组 - 4.6 数组参数和指针参数

### pass an array to function?

Let's begin with the example:

```c title="array-as-param.c"
void fun(char a[10])
{
    char c = a[3];
}

int main(int argc, char* argv[])
{
    char b[10] = "abcdefg";
    fun(b[10]);

    return 0;
}
```

Looking at the above call, `fun(b[10])` attempts to pass the "array" `b[10]` to the function `fun`. But is this correct? Does `b[10]` represent an array?

Obviously not. We know that `b[0]` represents an element of an array, and so does `b[10]`. It's just that the array is out of bounds, and the `b[10]` doesn't exist.

But at the compilation stage, the compiler doesn't actually calculate the address of `b[10]` and take the value, so it passes at compilation time. There are no errors, but the compiler still gives two warnings:

```bash
$ cl array-as-param.c
warning C4047: 'function' : 'char * 'differs in levels of indirection from 'char'
warning C4024: 'fun' : different types for formal and actual parameter 1

$ cc array-as-param.c
array-as-param.c: In function ‘main’:
array-as-param.c:9:10: warning: passing argument 1 of ‘fun’ makes pointer from integer without a cast [-Wint-conversion]
    9 |     fun(b[10]);
      |         ~^~~~
      |          |
      |          char
array-as-param.c:1:15: note: expected ‘char *’ but argument is of type ‘char’
    1 | void fun(char a[10])
      |          ~~~~~^~~~~
```

These two warnings clearly tell us that the function declaration requires a parameter of type `char *`, but the actual parameter passed is of type `char`, which does not match. Although the compiler does not give an error, there will definitely be problems running the function in this way. It will throw a memory access exception. Let's analyse the cause. There are actually at least two serious errors here.

1. `b[10]` does not exist. At compile time, no error is reported because the actual address is not taken. However, at runtime, the actual address of `b[10]` is calculated and the value is taken, which throws an array access out-of-bounds exception.

2. The compiler has warned us that a parameter of type `char *` is required, but a parameter of type `char` is passed. The `fun` function would force the passed `char` data to be converted to a `char*` address, which also causes an error. This is because char takes 1 byte, while `char *` takes 4 or 8, up to the width of the memory bus.

Mistake No. 1 is well understood, so what about mistake No. 2?

The parameter of the `fun` function is clearly declared as an array, so why does the compiler say that the type `char *` is required? Don't worry, let's change the way the function is called:

```c
    fun(b);
```

Since `b` is an array, there should be no problem passing `b` as the actual parameter, right?

Debug and run. Everything is normal. No problem. Done! Easy, right? But do you really understand what is going on? Is array `b` really passed into the function?

### Cannot pass an array to function

We can check for ourselves with the following code snippets.

```c
void fun(char a[10])
{
    int i = sizeof(a) ;
    char c = a[3];
}
```

If the array `b` is really passed to the function, the value of `i` should be 10. However, the test comes out `i` is 8 (in AArch64)! How come? Is array `b` really not passed to the function?

!!! note "array-to-pointer decay"

    Yes, it is not passed because of this rule: In the C language, when a one-dimensional array is passed as a function parameter, the compiler always interprets it as a pointer to the address of its first element.

Undoubtedly, there is a reason for this.

In the C language, all data arguments that are not in array form are called by *value*. Specifically, a copy of the argument is made and passed to the called function. The function cannot change the value of the actual variable used as the argument, only the copy passed to it.

However, if the entire array is to be copied, the overhead in terms of space and time is very large. More importantly, in most cases you don't really need a copy of the whole array. You just want to tell the function which particular array (element) you are interested in at a particular time. In this case, the above rules are in place to save time and space, and to improve the efficiency of the program.

Similarly, the return value of a function cannot be an array, only a pointer. A concept that needs to be made clear here is that the function itself has no type, only the return value of the function has a type. Therefore, the statement "a certain type of function" is wrong in some books, so be careful.

After the above explanation, I think you have understood the above rules and their origins. The warning given by the compiler above "the parameter of the function is a pointer of type `char *`" is also understandable.

Now that we can rewrite the `fun` function as follows:

```c
void fun (char * р)
{
    char c = p[3]; // or char c = *(p+3);
}
```

Likewise, you can try this:

```c
void fun(char a[10])
{
    char c = a[3];
}

int main(int argc, char* argv[])
{
    char b[100] = "abcdefg";
    fun (b) ;

    return 0;
}
```

There is absolutely no problem with execution, and the actual array size passed has nothing to do with the array size specified by the function parameter.

In this case we can do the following modification:

```c
void fun(char a[])
{
    char c = a[3];
}
```

This version is probably better, as it doesn't give the wrong impression that you can only pass an array of 10 elements.

### pass a pointer to function?

Let's rewrite the example discussed in the first section:

```c
void fun (char *p)
{
    char c = p[3]; // or char c = *(p+3);
}

int main(int argc, char* argv[])
{
    char *p2 = "abcdefg";
    fun(p2);

    return 0;
}
```

Does this function call actually pass `p2` *itself* to the `fun` function?

We know that `p2` is a local variable in the `main` function, and that it is only valid within the `main` function. Here we need to clarify one thing: the variable in the `main` function is not a global variable, it is a local variable, but its life cycle is the same as that of the global variable. Bear it in mind that global variables are always defined outside the function.

Because it is a local variable of the function, the real `p2` cannot be used between function calls. What about function calls? Simple: make a *backup* of the actual parameter and pass it to the called function, i.e. make a backup of `p2`. Assuming the backup name is `_p2`, what is passed to the function is `_p2`, not `p2` itself.

### Cannot pass a pointer itself to function

This is very similar to how Sun Wukong used his external body skills to pluck hair and clone the little monkey. The `fun` function is similar when passing parameters. It uses the copy of `_p2` instead of the real `p2`.

So, let's look at the following classic interview question:

```c
void GetMemory(char *p, int num)
{
    p = (char *)malloc(num * sizeof(char));
}

int main(int argc, char* argv[])
{
    char *str = NULL;

    GetMemory(str, 10);
    strcpy(str, "hello");
    free(str); // free nothing, memory leak

    return 0;
}
```

Error when running `strcpy(str，"hello")`. Look at the value of `str`, it would still be `NULL`. This means that `str` remains the same as before, and the new memory block allocated by `malloc` was not returned to `str` as expected. So what's wrong?

It's actually passed to `_str`, which is the backup of `str` when `GetMemory` is called. As analysed earlier, `_str` is a local variable that is only visible during the execution of the `GetMemory` function, there's no way to get it out. How can we solve this problem?

The first solution is to use `return` to return the newly allocated memory from `malloc`.

```c
char *GetMemory(char *p, int num)
{
    p = (char *)malloc(num * sizeof(char));
    return p;
}

int main(int argc, char* argv[])
{
    char *str = NULL;

    str = GetMemory(str, 10);
    strcpy(str, "hello");
    free(str);

    return 0;
}
```

This method is simple and easy to understand.

The second solution is to use multilevel pointers instead. Change the type of the formal parameter `p` from `char *` to `char **`, which is usually called `pointer's pointer` or `pointer to pointer`.

```c
char *GetMemory(char **p, int num)
{
    *p = (char *)malloc(num * sizeof(char));
}

int main(int argc, char* argv[])
{
    char *str = NULL;

    GetMemory(&str, 10);
    strcpy(str, "hello");
    free(str);

    return 0;
}
```

Note that the parameter passed here is `&str` instead of `str`. In this case, the address of `str` is passed, which is a value. Inside the `GetMemory` function, the key (`*`) is used to open the lock: `*(&str)` equals `str`.
