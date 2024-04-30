---
title: Dump Compiler Options
authors:
  - xman
date:
    created: 2009-10-05T10:00:00
    updated: 2024-04-03T10:00:00
categories:
    - toolchain
comments: true
---

Inspect and dump mainstream compiler(gcc/clang/msvc) predefined macros, c/c++ standard and search paths.

<!-- more -->

## Predefined macros

[Pre-defined C/C++ Compiler Macros](https://github.com/cpredef/predef)

[Guide to predefined macros in C++ compilers (gcc, clang, msvc etc.)](https://blog.kowalczyk.info/article/j/guide-to-predefined-macros-in-c-compilers-gcc-clang-msvc-etc..html)

### gnu/gcc

[Predefined Macros (The C Preprocessor)](https://gcc.gnu.org/onlinedocs/cpp/Predefined-Macros.html)

- [Standard Predefined Macros](https://gcc.gnu.org/onlinedocs/cpp/Standard-Predefined-Macros.html)
- [Common Predefined Macros](https://gcc.gnu.org/onlinedocs/cpp/Common-Predefined-Macros.html)

[Invocation (The C Preprocessor)](https://gcc.gnu.org/onlinedocs/cpp/Invocation.html): You can invoke the preprocessor either with the `cpp` command, or via `gcc -E`.

[GCC Preprocessor Options](https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html)

`-dletters`: Says to make debugging dumps during compilation as specified by letters.

```Shell
-dM
Instead of the normal output, generate a list of ‘#define’ directives for all the macros defined during the execution of the preprocessor, including predefined macros. This gives you a way of finding out what is predefined in your version of the preprocessor. Assuming you have no file foo.h, the command

touch foo.h; cpp -dM foo.h

shows all the predefined macros.
```

[g++ - GCC dump preprocessor defines - Stack Overflow](https://stackoverflow.com/questions/2224334/gcc-dump-preprocessor-defines)

echo 空流预编译：

```Shell
# echo | cpp -dM -
# echo | gcc -E -dM -
# echo | g++ -E -dM -
$ echo | gcc -x c -E -dM -
$ echo | g++ -x c++ -E -dM -
```

或指定空文件 /dev/null 预编译：

```Shell
# cpp -dM - < /dev/null
# gcc -E -dM - < /dev/null
$ gcc -x c -E -dM - < /dev/null
$ gcc -x c++ -E -dM - < /dev/null
# or
$ gcc -x c -E -dM /dev/null
$ gcc -x c++ -E -dM /dev/null
```

包含特定头文件：

```Shell
$ echo "#include <stdio.h>" | cpp -dM -
# cpp -dM -include sys/socket.h - < /dev/null
$ gcc -E -dM -include sys/socket.h - < /dev/null
```

指定C++版本：

```Shell
$ echo | gcc -x c++ -E -dM -std=c++11 -
$ gcc -x c++ -E -dM -std=c++11 /dev/null
```

### llvm/clang

[Clang Preprocessor options](https://clang.llvm.org/docs/ClangCommandLineReference.html#preprocessor-options)

- [Dumping preprocessor state](https://clang.llvm.org/docs/ClangCommandLineReference.html#id8)

在 macOS 上，gcc/g++ 是 XcodeDefault.xctoolchain 下 clang/clang++ 的 [shims or wrapper](http://stackoverflow.com/questions/9329243/xcode-4-4-and-later-install-command-line-tools/) executables。

clang 兼容 gcc 大部分常规命令，可替代 gcc 执行 `-E -dM` 预处理命令，输出预定义宏。

clang 还可通过 `-arch` 选项指定 CPU 架构，输出对应 CPU 下的一些预定义宏。

> 参考 [clang -print-targets](https://stackoverflow.com/questions/15036909/how-to-list-supported-target-architectures-in-clang) 中的 Registered Targets。

IA32（_ILP32）/IA64（_LP64）：

```Shell
$ clang -x c -E -dM -arch i386 /dev/null
$ clang -x c -E -dM -arch x86_64 /dev/null
```

ARM32（_ILP32）/ARM64（_LP64）：

```Shell
$ clang -x c -E -dM -arch armv7s /dev/null
$ clang -x c -E -dM -arch arm64 /dev/null
```

可以通过管道导给 grep 过滤不同 CPU 架构下 `__SIZEOF_INT__`，`__SIZEOF_LONG__`，`__SIZEOF_POINTER__`，`__BYTE_ORDER__`，`__BIGGEST_ALIGNMENT__` 等预定义宏。

### msvc

[Preprocessor](https://learn.microsoft.com/en-us/cpp/preprocessor/preprocessor?view=msvc-170)
[Predefined macros](https://learn.microsoft.com/en-us/cpp/preprocessor/predefined-macros?view=msvc-170)
[/P (Preprocess to a File)](https://learn.microsoft.com/en-us/cpp/build/reference/p-preprocess-to-a-file?view=msvc-170)

Preprocesses C and C++ source files and writes the preprocessed output to a file.

The following command line preprocesses `ADD.C`, preserves comments, adds #line directives, and writes the result to a file, `ADD.I`:

```Shell
CL /P /C ADD.C
```

[Provide the ability to list predefined macros and their values like gcc and Clang do with their '-E -dM' options - Developer Community](https://developercommunity.visualstudio.com/t/provide-the-ability-to-list-predefined-macros-and/934925)

[c++ - How to find out cl.exe's built-in macros - Stack Overflow](https://stackoverflow.com/questions/3665537/how-to-find-out-cl-exes-built-in-macros)

`/P` preprocessor flag will emit the currently active macros based on the project build settings. I am not sure if it is exactly the equivalent of gcc command you have shown. The output is in `.I` file.

```Shell
echo // > foo.cpp; cl /Zc:preprocessor /PD foo.cpp

# For C
echo // > foo.cpp; cl /nologo /Zc:preprocessor /PD /EHs /TC foo.cpp | sort; rm foo.cpp, foo.obj

# For C++
echo // > foo.cpp; cl /nologo /Zc:preprocessor /PD /EHs /TP foo.cpp | sort; rm foo.cpp, foo.obj
```

## c/c++ standard

[g++ - How can I find the default version of the c++ language standard used by my compiler and change it? - Stack Overflow](https://stackoverflow.com/questions/75679555/how-can-i-find-the-default-version-of-the-c-language-standard-used-by-my-compi)

### gnu/gcc

[gcc - How can I tell what standard my C is in? - Software Engineering Stack Exchange](https://softwareengineering.stackexchange.com/questions/313882/how-can-i-tell-what-standard-my-c-is-in)

[Language Standards Supported by GCC](https://gcc.gnu.org/onlinedocs/gcc/Standards.html)

> 2.1 C Language: The default, if no C language dialect options are given, is `-std=gnu17`.
> 2.2 C++ Language: The default, if no C++ language dialect options are given, is `-std=gnu++17`.


```Shell title="gcc -std=c++ @rpi4b-ubuntu"
$ gcc --version
gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

$ man gcc | grep -e "-std=c++"
           -std=c++98.
               GNU dialect of -std=c++98.
               GNU dialect of -std=c++11.  The name gnu++0x is deprecated.
               GNU dialect of -std=c++14.  The name gnu++1y is deprecated.
               GNU dialect of -std=c++17.  This is the default for C++ code.  The name gnu++1z
               GNU dialect of -std=c++20.  Support is experimental, and could change in
               GNU dialect of -std=c++2b.  Support is highly experimental, and will almost
           This flag is enabled by default for -std=c++17.

$ man g++ | grep "This is the default for C++ code"
               GNU dialect of -std=c++17.  This is the default for C++ code.  The name gnu++1z
```

[Which C++ standard is the default when compiling with g++? - Stack Overflow](https://stackoverflow.com/questions/44734397/which-c-standard-is-the-default-when-compiling-with-g/44735016#44735016)

You can also check with `gdb`:

1. $ g++ -g hello.cpp : Compile program with -g flag to generate debug info
2. $ gdb a.out : Debug program with gdb
3. (gdb) b main : Put a breakpoint at main
4. (gdb) r : Run program (will pause at breakpoint)
5. (gdb) info source - lldb 没有 info 命令

Prints out something like:

```Shell title="gdb info source @rpi4b-ubuntu"
(gdb) info source
Current source file is hello.cpp
Compilation directory is /home/pifan/Projects/cpp
Located in /home/pifan/Projects/cpp/hello.cpp
Contains 7 lines.
Source language is c++.
Producer is GNU C++17 11.4.0 -mlittle-endian -mabi=lp64 -g -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection.
Compiled with DWARF 5 debugging format.
Does not include preprocessor macro info.
(gdb) exit
```

[What is the default C -std standard version for the current GCC (especially on Ubuntu)? - Stack Overflow](https://stackoverflow.com/questions/14737104/what-is-the-default-c-std-standard-version-for-the-current-gcc-especially-on-u)

```Shell title="rpi4b-ubuntu"
$ gcc -x c -E -dM /dev/null | grep -F __STDC_VERSION__
#define __STDC_VERSION__ 201710L

$ g++ -x c++ -E -dM /dev/null | grep -F __cplusplus
#define __cplusplus 201703L
```

If you feel like finding it out empirically without reading any manuals.

```c title="stdc.c"
#include <stdio.h>

int main(void) {
#ifdef __STDC_VERSION__
    printf("__STDC_VERSION__ = %ld \n", __STDC_VERSION__);
#endif
#ifdef __STRICT_ANSI__
    puts("__STRICT_ANSI__");
#endif
    return 0;
}
```

Test with:

```Shell
#!/usr/bin/env bash
for std in c89 c99 c11 c17 gnu89 gnu99 gnu11 gnu17; do
  echo $std
  gcc -std=$std -o c.out stdc.c
  ./c.out
  echo
done
echo default
gcc -o c.out stdc.c
./c.out
```

rpi4b-ubuntu 下输出：

```Shell
default
__STDC_VERSION__ = 201710
```

```cpp title="stdcpp.cpp"
#include <iostream>

int main(void) {
#ifdef __cplusplus
    std::cout << __cplusplus << std::endl;
#endif
#ifdef __STRICT_ANSI__
    std::cout << "__STRICT_ANSI__" << std::endl;
#endif
    return 0;
}
```

Test with:

```Shell
#!/usr/bin/env bash
for std in c++98 c++11 c++14 c++17 gnu++98 gnu++11 gnu++14 gnu++17; do
  echo $std
  g++ -std=$std -o cpp.out stdcpp.cpp
  ./cpp.out
  echo
done
echo default
g++ -o cpp.out stdcpp.cpp
./cpp.out
```

rpi4b-ubuntu 下输出：

```Shell
default
201703
```

### llvm/clang

[C Language Features](https://clang.llvm.org/docs/UsersManual.html#c-language-features)

> If no -std option is specified, clang defaults to `gnu17` mode.

[Clang - C++ Programming Language Status](https://clang.llvm.org/cxx_status.html)

C++17 implementation status:

> Clang 5 and later implement all the features of the ISO C++ 2017 standard.
> By default, Clang 16 or later builds C++ code according to the `C++17` standard.

```Shell title="clang default @mbpa2991/macOS_Sonoma"
$ man clang | grep -F default
              The default C language standard is gnu17, except on PS4, where
              The default C++ language standard is gnu++98.
```

[libc++ woes with Xcode 14 | Apple Developer Forums](https://forums.developer.apple.com/forums/thread/721698)

[What is the default C -std standard version for the current GCC (especially on Ubuntu)? - Stack Overflow](https://stackoverflow.com/questions/14737104/what-is-the-default-c-std-standard-version-for-the-current-gcc-especially-on-u)

```Shell title="macOS clang/gcc"
gcc -E -dM -x c /dev/null | grep -F __STDC_VERSION__
#define __STDC_VERSION__ 201710L

g++ -E -dM -x c++ /dev/null | grep -F __cplusplus
#define __cplusplus 199711L
```

mbpa2991/macOS_Sonoma 下执行 `./stdc.sh` 输出：

```Shell
default
__STDC_VERSION__ = 201710
```

mbpa2991/macOS_Sonoma 下执行 `./stdcpp.sh` 输出：

```Shell
default
199711
```

#### _LIBCPP_VERSION

[⚙ D134187 [libc++] Document the format of _LIBCPP_VERSION](https://reviews.llvm.org/D134187)

- [llvm-project/libcxx/include/__config](https://github.com/llvm/llvm-project/blob/ad0dfb4f5e07c337af45e1c4f515b762d2d1c395/libcxx/include/__config)

> `_LIBCPP_VERSION` represents the version of libc++, which matches the version of LLVM.
> Given a LLVM release LLVM XX.Y.ZZ (e.g. LLVM 16.0.1 == 16.0.01), _LIBCPP_VERSION is defined to XXYZZ.

[⚙ D26062 Alternative solution for detecting libc++'s version.](https://reviews.llvm.org/D26062)

[XCode now defaults to C++20 : r/cpp](https://www.reddit.com/r/cpp/comments/v6ydea/xcode_now_defaults_to_c20/)

执行 grep 搜索 `_LIBCPP_VERSION` 的定义：

```Shell
grep -R -H "#define _LIBCPP_VERSION" --include=__config --exclude-dir=System / 2>/dev/null
```

??? info "_LIBCPP_VERSION"

    ```Shell
    $ cmdpath=/Library/Developer/CommandLineTools
    $ grep -R -H "#define _LIBCPP_VERSION" $cmdpath 2>/dev/null

    /Library/Developer/CommandLineTools/usr/include/c++/v1/__config:#define _LIBCPP_VERSION 11000
    /Library/Developer/CommandLineTools/usr/include/c++/v1/version:#define _LIBCPP_VERSIONH
    /Library/Developer/CommandLineTools/usr/include/c++/v1/__cxx_version:#define _LIBCPP_VERSIONH

    /Library/Developer/CommandLineTools/SDKs/MacOSX11.3.sdk/usr/include/c++/v1/__config:#define _LIBCPP_VERSION 12000
    /Library/Developer/CommandLineTools/SDKs/MacOSX11.3.sdk/usr/include/c++/v1/version:#define _LIBCPP_VERSIONH
    /Library/Developer/CommandLineTools/SDKs/MacOSX13.3.sdk/usr/include/c++/v1/version:#define _LIBCPP_VERSIONH
    /Library/Developer/CommandLineTools/SDKs/MacOSX14.4.sdk/usr/include/c++/v1/version:#define _LIBCPP_VERSIONH

    $ xcdevpath=`xcode-select -p`
    $ grep -R -H "#define _LIBCPP_VERSION" $xcdevpath 2>/dev/null

    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include/c++/v1/version:#define _LIBCPP_VERSIONH
    /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/c++/v1/version:#define _LIBCPP_VERSIONH
    ```

[c++ - How to detect the libstdc++ version in Clang? - Stack Overflow](https://stackoverflow.com/questions/21622561/how-to-detect-the-libstdc-version-in-clang)

```cpp title="libcpp_version.cpp"
#include <iostream>
#include <string>

using namespace std;

int main(int argc, const char * argv[])
{
    cout<<"_LIBCPP_VERSION = "<<_LIBCPP_VERSION<<endl;
    return 0;
}
```

clang 15.0.0 下输出 _LIBCPP_VERSION = 170006。

```Shell
# c++/g++/clang++
$ clang++ libcpp_version.cpp -o libcpp_version && ./libcpp_version
_LIBCPP_VERSION = 170006
```

### msvc

[Predefined macros](https://learn.microsoft.com/en-us/cpp/preprocessor/predefined-macros?view=msvc-170)

`_MSVC_LANG` Defined as an integer literal that specifies the C++ language standard targeted by the compiler. It's set only in code compiled as C++. The macro is the integer literal value `201402L` by default, or when the `/std:c++14` compiler option is specified. .

[/std (Specify Language Standard Version)](https://learn.microsoft.com/en-us/cpp/build/reference/std-specify-language-standard-version?view=msvc-170)

**C standards support**: You can invoke the Microsoft C compiler by using the [/TC or /Tc](https://learn.microsoft.com/en-us/cpp/build/reference/tc-tp-tc-tp-specify-source-file-type?view=msvc-170) compiler option. It's used by default for code that has a `.c` file extension, unless overridden by a `/TP` or `/Tp` option. The *default* C compiler (that is, the compiler when `/std:c11` or `/std:c17` isn't specified) implements ANSI C89, but includes several Microsoft extensions, some of which are part of ISO C99.

**C++ standards support**: The `/std` option in effect during a C++ compilation can be detected by use of the [\_MSVC\_LANG](https://learn.microsoft.com/en-us/cpp/preprocessor/predefined-macros?view=msvc-170) preprocessor macro. For more information, see [Preprocessor Macros](https://learn.microsoft.com/en-us/cpp/preprocessor/predefined-macros?view=msvc-170).

!!! note "Important"

    Because some existing code depends on the value of the macro `__cplusplus` being `199711L`, the MSVC compiler doesn't change the value of this macro unless you explicitly opt in by setting [/Zc:\_\_cplusplus](https://learn.microsoft.com/en-us/cpp/build/reference/zc-cplusplus?view=msvc-170). Specify `/Zc:__cplusplus` and the `/std` option to set `__cplusplus` to the appropriate value.

    [Predefined macros: \_\_cplusplus - cppreference.com](https://en.cppreference.com/w/cpp/preprocessor/replace#Predefined_macros)

The `/std:c++14` option enables C++14 standard-specific features implemented by the MSVC compiler. This option is the *default* for code compiled as C++. It's available starting in Visual Studio 2015 Update 3.

## Search Paths

### Header Search Paths

运行 `clang -v -x c -E /dev/null` 或 `clang -v -x c++ -E /dev/null` 执行预处理，可以查看 C/C++ 语言的 Header Search Paths。

```Shell
#include "..." search starts here:
#include <...> search starts here:
 /usr/local/include
 /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/include
 /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include
 /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include
 /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks (framework directory)
End of search list.
```

If you want to see your header include paths for `libstdc++` and `libc++`, do this:

```Shell
# GNU C++ runtime
$ echo | clang -x c++ -Wp,-v -stdlib=libstdc++ -fsyntax-only -

# LLVM C++ runtime
$ echo | clang -x c++ -Wp,-v -stdlib=libc++ -fsyntax-only -
```

涉及到两个选项：

1. [Preprocessor Options](https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html) - `-Wp,option` : to bypass the compiler driver and pass option directly through to the preprocessor.
2. [Warning Options](https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html) - `-fsyntax-only` : Check the code for syntax errors, but don’t do anything beyond that.

=== "macOS <stdio.h\> / <iostream\>"

    ```Shell
    # gcc stdc.c -E -### : llvm-gcc 调用 clang -cc1 预处理
    $ gcc stdc.c -E -v
    /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/stdio.h

    # g++ stdcpp.cpp -E -### : llvm-g++ 也是调用 clang -cc1 预处理
    $ g++ stdcpp.cpp -E -v
    /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/c++/v1/iostream
    ```

=== "rpi4b-ubuntu <stdio.h\> / <iostream\>"

    ```Shell
    # gcc stdc.c -E -### : 调用 /usr/lib/gcc/aarch64-linux-gnu/11/cc1 -E 预处理
    $ gcc stdc.c -E -v

    #include "..." search starts here:
    #include <...> search starts here:
     /usr/lib/gcc/aarch64-linux-gnu/11/include
     /usr/local/include
     /usr/include/aarch64-linux-gnu
     /usr/include
    End of search list.

    /usr/include/stdio.h

    COMPILER_PATH=/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/:/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/
    LIBRARY_PATH=/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../../lib/:/lib/aarch64-linux-gnu/:/lib/../lib/:/usr/lib/aarch64-linux-gnu/:/usr/lib/../lib/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../:/lib/:/usr/lib/
    COLLECT_GCC_OPTIONS='-E' '-v' '-mlittle-endian' '-mabi=lp64'

    # g++ stdcpp.cpp -E -### : 调用 /usr/lib/gcc/aarch64-linux-gnu/11/cc1plus -E 预处理
    $ g++ stdcpp.cpp -E -v

    /usr/include/c++/11/iostream

    COMPILER_PATH=/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/:/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/
    LIBRARY_PATH=/usr/lib/gcc/aarch64-linux-gnu/11/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../../lib/:/lib/aarch64-linux-gnu/:/lib/../lib/:/usr/lib/aarch64-linux-gnu/:/usr/lib/../lib/:/usr/lib/gcc/aarch64-linux-gnu/11/../../../:/lib/:/usr/lib/
    COLLECT_GCC_OPTIONS='-E' '-v' '-shared-libgcc' '-mlittle-endian' '-mabi=lp64'
    ```

---

VC2015 的头文件 INCLUDE 路径为：

- C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\include
- C:\Program Files (x86)\Windows Kits\10\Include\10.0.10150.0\ucrt

### Library Search Paths

执行 `clang -Xlinker -v` 指定链接选项，不指定链接目标，则只显示 configured to support archs 信息：

- [Options for Linking](https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html) - `-Xlinker option` : Pass option as an option to the linker.

```Shell
$ clang -Xlinker -v
@(#)PROGRAM:ld PROJECT:ld-1053.12
BUILD 15:45:29 Feb  3 2024
configured to support archs: armv6 armv7 armv7s arm64 arm64e arm64_32 i386 x86_64 x86_64h armv6m armv7k armv7m armv7em
will use ld-classic for: armv6 armv7 armv7s arm64_32 i386 armv6m armv7k armv7m armv7em
LTO support using: LLVM version 15.0.0 (static support for 29, runtime is 29)
TAPI support using: Apple TAPI version 15.0.0 (tapi-1500.3.2.2)
```

也可执行 `clang -print-targets` 查看 Registered Targets，参考 [How to list supported target architectures in clang?](https://stackoverflow.com/questions/15036909/how-to-list-supported-target-architectures-in-clang)。

指定链接空文件 /dev/null，可以查看 Library/Framework search paths，直接报错：

```Shell title="clang -Xlinker -v @mbpa2991/macOS_Sonoma"
$ clang -Xlinker -v /dev/null
@(#)PROGRAM:ld PROJECT:ld-1053.12
BUILD 15:45:29 Feb  3 2024
configured to support archs: armv6 armv7 armv7s arm64 arm64e arm64_32 i386 x86_64 x86_64h armv6m armv7k armv7m armv7em
will use ld-classic for: armv6 armv7 armv7s arm64_32 i386 armv6m armv7k armv7m armv7em
LTO support using: LLVM version 15.0.0 (static support for 29, runtime is 29)
TAPI support using: Apple TAPI version 15.0.0 (tapi-1500.3.2.2)
Library search paths:
        /usr/local/lib
        /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib
        /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib/swift
Framework search paths:
        /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks
clang: error: unable to execute command: Segmentation fault: 11
clang: error: linker command failed due to signal (use -v to see invocation)
```

!!! note "macOS 编译链接 C/C++"

    macOS 上编译链接 C 代码：dry-run: `gcc stdc.c -###`；compile: `gcc stdc.c -o c.out -v`。
    macOS 上编译链接 C++ 代码：dry-run: `g++ stdcpp.cpp -###`；compile: `g++ stdcpp.cpp -o cpp.out -v`。

    - gcc/g++ 都只调用了 `clang cc1` 和 `ld` 两步命令。
    - gcc std.c 链接 `libLTO.dylib`、`-lSystem` 和 `libclang_rt.osx.a`；g++ stdcpp.cpp 在 -lSystem 前面插增链接选项 `-lc++`。
    - 执行 `otool -L c.out` / `otool -L cpp.out` 可查看依赖的动态库（dylib）。

Ubuntu 下执行 gcc/g++ 命令，调用 collect2 和 ld 链接，最终报错：

=== "gcc collect2 -lc"

    ```Shell
    $ gcc -Xlinker -v /dev/null
    collect2 version 11.4.0
    /usr/bin/ld -plugin /usr/lib/gcc/aarch64-linux-gnu/11/liblto_plugin.so -plugin-opt=/usr/lib/gcc/aarch64-linux-gnu/11/lto-wrapper -plugin-opt=-fresolution=/tmp/cc2Mlb39.res -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s -plugin-opt=-pass-through=-lc -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s --build-id --eh-frame-hdr --hash-style=gnu --as-needed -dynamic-linker /lib/ld-linux-aarch64.so.1 -X -EL -maarch64linux --fix-cortex-a53-843419 -pie -z now -z relro /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/Scrt1.o /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/crti.o /usr/lib/gcc/aarch64-linux-gnu/11/crtbeginS.o -L/usr/lib/gcc/aarch64-linux-gnu/11 -L/usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu -L/usr/lib/gcc/aarch64-linux-gnu/11/../../../../lib -L/lib/aarch64-linux-gnu -L/lib/../lib -L/usr/lib/aarch64-linux-gnu -L/usr/lib/../lib -L/usr/lib/gcc/aarch64-linux-gnu/11/../../.. -v -lgcc --push-state --as-needed -lgcc_s --pop-state -lc -lgcc --push-state --as-needed -lgcc_s --pop-state /usr/lib/gcc/aarch64-linux-gnu/11/crtendS.o /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/crtn.o
    GNU ld (GNU Binutils for Ubuntu) 2.38
    /usr/bin/ld: /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/Scrt1.o: in function `_start':
    (.text+0x1c): undefined reference to `main'
    /usr/bin/ld: (.text+0x20): undefined reference to `main'
    collect2: error: ld returned 1 exit status
    ```

=== "g++ collect2 -lstdc++"

    ```Shell
    $ g++ -x c++ -Xlinker -v /dev/null
    collect2 version 11.4.0
    /usr/bin/ld -plugin /usr/lib/gcc/aarch64-linux-gnu/11/liblto_plugin.so -plugin-opt=/usr/lib/gcc/aarch64-linux-gnu/11/lto-wrapper -plugin-opt=-fresolution=/tmp/ccx8f9Ks.res -plugin-opt=-pass-through=-lgcc_s -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lc -plugin-opt=-pass-through=-lgcc_s -plugin-opt=-pass-through=-lgcc --build-id --eh-frame-hdr --hash-style=gnu --as-needed -dynamic-linker /lib/ld-linux-aarch64.so.1 -X -EL -maarch64linux --fix-cortex-a53-843419 -pie -z now -z relro /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/Scrt1.o /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/crti.o /usr/lib/gcc/aarch64-linux-gnu/11/crtbeginS.o -L/usr/lib/gcc/aarch64-linux-gnu/11 -L/usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu -L/usr/lib/gcc/aarch64-linux-gnu/11/../../../../lib -L/lib/aarch64-linux-gnu -L/lib/../lib -L/usr/lib/aarch64-linux-gnu -L/usr/lib/../lib -L/usr/lib/gcc/aarch64-linux-gnu/11/../../.. -v /tmp/ccqgv1oL.o -lstdc++ -lm -lgcc_s -lgcc -lc -lgcc_s -lgcc /usr/lib/gcc/aarch64-linux-gnu/11/crtendS.o /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/crtn.o
    GNU ld (GNU Binutils for Ubuntu) 2.38
    /usr/bin/ld: /usr/lib/gcc/aarch64-linux-gnu/11/../../../aarch64-linux-gnu/Scrt1.o: in function `_start':
    (.text+0x1c): undefined reference to `main'
    /usr/bin/ld: (.text+0x20): undefined reference to `main'
    collect2: error: ld returned 1 exit status
    ```

!!! note "Ubuntu 编译链接 C/C++"

    ubuntu 上编译链接 C 代码：dry-run: `gcc stdc.c -###`；compile: `gcc stdc.c -o c.out -v`。

    - gcc 依次调用 cc1->as->collect2，链接 Scrt1.o,crti.o,crtbeginS.o,`-lc`（[g]libc）,crtendS.o,crtn.o。

    ubuntu 上编译链接 C++ 代码：dry-run: `g++ stdcpp.cpp -###`；compile: `g++ stdcpp.cpp -o cpp.out -v`。

    - g++ 依次调用 cc1plus->as->collect2，链接 Scrt1.o,crti.o,crtbeginS.o,`-lstdc++`（libstdc++）,crtendS.o,crtn.o。

    **说明**：

    - gcc 的 `cc1` 已经集成了 [cpp](https://gcc.gnu.org/onlinedocs/cpp/Invocation.html) 预处理。
    - [collect2](https://gcc.gnu.org/onlinedocs/gccint/Collect2.html) 内部调用 *real* `ld` 完成最终的链接工作。
    - 关于 crt(C Runtime)，参考 [crtbegin.o vs. crtbeginS.o](https://stackoverflow.com/questions/22160888/what-is-the-difference-between-crtbegin-o-crtbegint-o-and-crtbegins-o) 和 [Mini FAQ about the misc libc/gcc crt files.](https://dev.gentoo.org/~vapier/crt.txt)。

---

VC2015 的库文件 LIB 路径为：

- C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\lib
- C:\Program Files (x86)\Windows Kits\10\Lib\10.0.10150.0\ucrt\x86

## Library Dependencies

执行 gcc/g++ 编译链接时，可指定 `-###` dry-run，查看完整编译链接流程：

- gcc stdc.c -###
- g++ stdcpp.cpp -###

[ABI Policy and Guidelines](https://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html) - Checking Active

- [elf - Determine direct shared object dependencies of a Linux binary? - Stack Overflow](https://stackoverflow.com/questions/6242761/determine-direct-shared-object-dependencies-of-a-linux-binary)
- [windows - Discovery of Dynamic library dependency on Mac OS & Linux - Stack Overflow](https://stackoverflow.com/questions/1057234/discovery-of-dynamic-library-dependency-on-mac-os-linux)
- [How to find out the dynamic libraries executables loads when run? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/120015/how-to-find-out-the-dynamic-libraries-executables-loads-when-run)

[c++ - How do you find what version of libstdc++ library is installed on your linux machine? - Stack Overflow](https://stackoverflow.com/questions/10354636/how-do-you-find-what-version-of-libstdc-library-is-installed-on-your-linux-mac)

### ldd

`ldd` - print shared object dependencies.

ldd 打印依赖的动态共享库：libc.so.6, libstdc++.so.6。

=== "ldd c.out"

    ```Shell
    rpi4b-ubuntu $ ldd c.out
    	linux-vdso.so.1 (0x0000ffffa4f6c000)
    	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000ffffa4d70000)
    	/lib/ld-linux-aarch64.so.1 (0x0000ffffa4f33000)
    ```

=== "ldd cpp.out"

    ```Shell
    rpi4b-ubuntu $ ldd cpp.out
    	linux-vdso.so.1 (0x0000ffff968c5000)
    	libstdc++.so.6 => /lib/aarch64-linux-gnu/libstdc++.so.6 (0x0000ffff96640000)
    	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000ffff96490000)
    	libm.so.6 => /lib/aarch64-linux-gnu/libm.so.6 (0x0000ffff963f0000)
    	/lib/ld-linux-aarch64.so.1 (0x0000ffff9688c000)
    	libgcc_s.so.1 => /lib/aarch64-linux-gnu/libgcc_s.so.1 (0x0000ffff963c0000)
    ```

---

macOS 与 Linux 上的 ldd 对应的命令是 `otool -L`：

```Shell
mbpa2991 $ otool -L c.out
c.out:
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1345.100.2)

mbpa2991 $ otool -L cpp.out
cpp.out:
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 1700.255.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1345.100.2)
```

但 /usr/lib 下并没有找到这两个 dylib，参考：

- [Why are my system libraries and frameworks not visible in macOS Monterey?](https://stackoverflow.com/questions/70549365/why-are-my-system-libraries-and-frameworks-not-visible-in-macos-monterey)
- [Missing librairies in /usr/lib on Big Sur?](https://developer.apple.com/forums/thread/655588): Since Big Sur, it somehow all became virtual.

在 macOS 上的 Library search paths 中过滤 libSystem 和 libc++，只搜到了 libSystem.B.tbd 和 libc++.1.tbd 及一堆软链替身（如 libc.tbd、libc++.tbd）：

```Shell
$ ls -l /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib | grep -E "lib(System|c\+\+)"
-rw-r--r--    1 root  wheel  309826 Nov 17  2021 libSystem.B.tbd
lrwxr-xr-x    1 root  wheel      15 Oct  7  2021 libSystem.tbd -> libSystem.B.tbd
-rw-r--r--    1 root  wheel  145622 Nov 13  2021 libc++.1.tbd
lrwxr-xr-x    1 root  wheel      12 Oct  7  2021 libc++.tbd -> libc++.1.tbd
-rw-r--r--    1 root  wheel   10571 Nov 13  2021 libc++abi.tbd
lrwxr-xr-x    1 root  wheel      13 Oct  7  2021 libc.tbd -> libSystem.tbd
lrwxr-xr-x    1 root  wheel      13 Oct  7  2021 libdl.tbd -> libSystem.tbd
lrwxr-xr-x    1 root  wheel      13 Oct  7  2021 libgcc_s.1.tbd -> libSystem.tbd
lrwxr-xr-x    1 root  wheel      13 Oct  7  2021 libm.tbd -> libSystem.tbd
lrwxr-xr-x    1 root  wheel      13 Oct  7  2021 libpoll.tbd -> libSystem.tbd
lrwxr-xr-x    1 root  wheel      13 Oct  7  2021 libproc.tbd -> libSystem.tbd
lrwxr-xr-x    1 root  wheel      13 Oct  7  2021 libpthread.tbd -> libSystem.tbd
```

查看 libSystem.B.tbd 可知，libSystem 不提供任何符号和代码，它链接了 /usr/lib/system 中的许多其他 dylib，并将它们的符号作为自己的符号重新导出（reexported-libraries）。


```Shell
$ tree /usr/lib/system
/usr/lib/system
├── introspection
│   ├── libdispatch.dylib
│   └── libsystem_pthread.dylib
├── libsystem_kernel.dylib
├── libsystem_platform.dylib
├── libsystem_pthread.dylib
└── wordexp-helper

2 directories, 6 files
```

!!! note "tdb vs. dylib"

    关于 tdb 和 dylib 的关系，参考：

    - [Why Xcode 7 shows \*.tbd instead of \*.dylib?](https://stackoverflow.com/questions/31450690/why-xcode-7-shows-tbd-instead-of-dylib)
    - [macOS/iOS dylib、tbd 和 Framework 库详解](https://juejin.cn/post/7143496837188550692)

    `*.dylib` is the compiled binary that contains the machine code.
    `TDB` is the acronym for "Text Based Dylib stubs".
    `*.tbd` is a smaller text file, similar to a cross-platform module map.

### ldconfig

`ldconfig` - configure dynamic linker run-time bindings.

- `-p` / --print-cache: Print the lists of directories and candidate libraries stored in the current cache.

ldconfig -p 打印缓存中的动态共享库 libc.so.6, libstdc++.so.6。

=== "ldconfig -p | grep libc.so"

    ```Shell
    rpi4b-ubuntu $ ldconfig -p | grep libc.so
    	libc.so.6 (libc6,AArch64, OS ABI: Linux 3.7.0) => /lib/aarch64-linux-gnu/libc.so.6
    ```

=== "ldconfig -p | grep libstdc++"

    ```Shell
    rpi4b-ubuntu $ ldconfig -p | grep libstdc++
    	libstdc++.so.6 (libc6,AArch64) => /lib/aarch64-linux-gnu/libstdc++.so.6
    ```

### objdump

#### -f

执行 `file` 命令查看 libc.so 文件属性（determine file type）：

```Shell
$ file /lib/aarch64-linux-gnu/libc.so.6
/lib/aarch64-linux-gnu/libc.so.6: ELF 64-bit LSB shared object, ARM aarch64, version 1 (GNU/Linux), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=9e27cf97f03940293c6df3b107674ceda9c825d8, for GNU/Linux 3.7.0, stripped
```

执行 `file` 命令查看 libstdc++.so 文件属性：

```Shell
$ file /lib/aarch64-linux-gnu/libstdc++.so.6
/lib/aarch64-linux-gnu/libstdc++.so.6: symbolic link to libstdc++.so.6.0.30

$ file /lib/aarch64-linux-gnu/libstdc++.so.6.0.30
/lib/aarch64-linux-gnu/libstdc++.so.6.0.30: ELF 64-bit LSB shared object, ARM aarch64, version 1 (GNU/Linux), dynamically linked, BuildID[sha1]=a012b2bb77110e84b266cd7425b50e57427abb02, stripped
```

`objdump -a` 查看 archive header；`objdump -f` 查看 file header。

- `-a`, --archive-headers    Display archive header information
- `-f`, --file-headers       Display the contents of the overall file header

```Shell
objdump -f /lib/aarch64-linux-gnu/libc.so.6

/lib/aarch64-linux-gnu/libc.so.6:     file format elf64-littleaarch64
architecture: aarch64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x00000000000275e0

objdump -f /lib/aarch64-linux-gnu/libstdc++.so.6

/lib/aarch64-linux-gnu/libstdc++.so.6:     file format elf64-littleaarch64
architecture: aarch64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x0000000000000000
```

#### -x

`objdump -x`（--all-headers）: Display all available header information, including the symbol table and relocation entries.

1. Dynamic Section: 中的 NEEDED 为依赖的（动态）库：libc.so.6, libstdc++.so.6。
2. Version References: 中的 required 为依赖的（动态）库：GLIBC_2.17/GLIBC_2.34,GLIBCXX_3.4。
3. 依赖的符号后面也有 @GLIBC_2.17/@GLIBC_2.34,@GLIBCXX_3.4 标记。

=== "objdump -x c.out"

    ```Shell
    rpi4b-ubuntu $ objdump -x c.out

    Dynamic Section:
      NEEDED               libc.so.6

    Version References:
      required from libc.so.6:
        0x06969197 0x00 03 GLIBC_2.17
        0x069691b4 0x00 02 GLIBC_2.34

    SYMBOL TABLE:

    0000000000000000       F *UND*	0000000000000000              __libc_start_main@GLIBC_2.34
    0000000000000000       F *UND*	0000000000000000              printf@GLIBC_2.17
    ```

=== "objdump -x cpp.out"

    ```Shell
    rpi4b-ubuntu $ objdump -x cpp.out

    Dynamic Section:
      NEEDED               libstdc++.so.6
      NEEDED               libc.so.6

    Version References:
      required from libc.so.6:
        0x069691b4 0x00 04 GLIBC_2.34
        0x06969197 0x00 03 GLIBC_2.17
      required from libstdc++.so.6:
        0x08922974 0x00 02 GLIBCXX_3.4

    SYMBOL TABLE:

    0000000000000000       O *UND*	0000000000000000              _ZSt4cout@GLIBCXX_3.4
    ```

### readelf

`readelf -h`: Display the ELF file header.
`readelf -l`(--program-headers, --segments): Display the program headers
`readelf -S`(--section-headers, --sections): Display the sections' header
`readelf -e`(--headers): Equivalent to: -h -l -S
`readelf -d`(--dynamic): Displays the contents of the file's dynamic section, if it has one.
`readelf -a`(--all): Displays the complete structure of an object ﬁle.

=== "readelf -d c.out"

    ```Shell
    rpi4b-ubuntu $ readelf -d c.out

    Dynamic section at offset 0xda0 contains 27 entries:
      Tag        Type                         Name/Value
     0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
    ```

=== "readelf -d cpp.out"

    ```Shell
    rpi4b-ubuntu $ readelf -d cpp.out

    Dynamic section at offset 0xd60 contains 28 entries:
      Tag        Type                         Name/Value
     0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
     0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
    ```

> 其中 NEEDED 标记表示依赖（动态）库：libc.so.6, libstdc++.so.6。

### nm

`nm` - list symbols from object files.

> 依赖的符号后面也有 @GLIBC_2.17/@GLIBC_2.34,@GLIBCXX_3.4 标记。

=== "nm c.out"

    ```Shell
    rpi4b-ubuntu $ nm c.out

    0000000000000790 R _IO_stdin_used
                     w _ITM_deregisterTMCloneTable
                     w _ITM_registerTMCloneTable
                     U __libc_start_main@GLIBC_2.34
    0000000000000754 T main
                     U printf@GLIBC_2.17
    ```

=== "nm cpp.out"

    ```Shell
    rpi4b-ubuntu $ nm cpp.out
    0000000000000a10 t _Z41__static_initialization_and_destruction_0ii
                     U _ZNSolsEl@GLIBCXX_3.4
                     U _ZNSolsEPFRSoS_E@GLIBCXX_3.4
                     U _ZNSt8ios_base4InitC1Ev@GLIBCXX_3.4
                     U _ZNSt8ios_base4InitD1Ev@GLIBCXX_3.4
                     U _ZSt4cout@GLIBCXX_3.4
                     U _ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@GLIBCXX_3.4
    ```

man nm 查看 [nm(1) - Linux manual page](https://man7.org/linux/man-pages/man1/nm.1.html)，其中有关于 symbol type 的详细说明。
