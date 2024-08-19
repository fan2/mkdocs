---
title: Ubuntu Apport Core Dump
authors:
    - xman
date:
    created: 2023-07-05T14:00:00
categories:
    - toolchain
comments: true
---

[Core dump](https://en.wikipedia.org/wiki/Core_dump): In computing, a core dump, memory dump, crash dump, storage dump, system dump, or ABEND dump consists of the recorded state of the working memory of a computer program at a specific time, generally when the program has crashed or otherwise terminated abnormally. In practice, other key pieces of program state are usually dumped at the same time, including the processor registers, which may include the program counter and stack pointer, memory management information, and other processor and operating system flags and information.

[Core File Generation (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Core-File-Generation.html): A core file or core dump is a file that records the memory image of a running process and its process status (register values etc.). Its primary use is post-mortem debugging of a program that crashed while it ran outside a debugger. A program that crashes automatically produces a core file, unless this feature is disabled by the user.

<!-- more -->

## segmentation fault

```c title="modify-rodata.c"
#include <stdio.h>

char *str = "hello";
// static char *str = "world";

int main(int argc, char* argv[])
{
    // char *str = "Hello World!";
    char *ptr = str;
    *ptr = 'T';
    printf("ptr = %s\n", ptr);

    return 0;
}
```

On Raspiberry PI 3 Model B/aarch64/ubuntu, gcc compile and run the program:

```bash
$ gcc modify-rodata.c && ./a.out
[1]    62227 segmentation fault (core dumped)  ./a.out
```

## Apport Core Dump

[Ubuntu Apport Core Dump](https://bobcares.com/blog/ubuntu-apport-core-dump/)

- [Where are my core dump files?](https://blog.meinside.dev/Where-are-my-Core-Dump-Files/)
- [How to Set the Core Dump File Path](https://www.baeldung.com/linux/core-dumps-path-set)
- [Setting up an Ubuntu system to capture crash files](https://www.ibm.com/docs/en/storage-scale/5.1.9?topic=traces-setting-up-ubuntu-system-capture-crash-files)

When an app crashes in Ubuntu, [Apport](https://wiki.ubuntu.com/Apport) makes a core dump file that includes details about the program’s status at the moment of the crash.

```bash
$ systemctl status apport.service
● apport.service - LSB: automatic crash report generation
     Loaded: loaded (/etc/init.d/apport; generated)
     Active: active (exited) since Thu 2024-08-15 01:04:38 CST; 3 days ago
       Docs: man:systemd-sysv-generator(8)
        CPU: 181ms

8月 15 01:04:36 rpi3b-ubuntu systemd[1]: Starting LSB: automatic crash report generation...
8月 15 01:04:37 rpi3b-ubuntu apport[726]:  * Starting automatic crash report generation: apport
8月 15 01:04:38 rpi3b-ubuntu apport[726]:    ...done.
8月 15 01:04:38 rpi3b-ubuntu systemd[1]: Started LSB: automatic crash report generation.
```

If everything is configured properly, frequent user dumps captured by Apport for Ubuntu 20.04 are kept at `/var/lib/apport/coredump/`.

Alternatively, we can install [systemd-coredump](https://manpages.ubuntu.com/manpages/focal/man8/systemd-coredump.8.html) (`sudo apt install systemd-coredump`) to use the *`coredumpctl`* tool to manage core dumps. `systemd-coredump@.service` is a system service that can acquire core dumps from the kernel and handle them in various ways.

[Apport 2.28.0 gained systemd-coredump integration](https://discourse.ubuntu.com/t/apport-2-28-0-gained-systemd-coredump-integration/44910/1)

> As of Apport 2.28.0 in Ubuntu 24.04 systemd-coredump can be installed in parallel to Apport.

## unlimit core file size

[coredump - Can not find core-dump file in Ubuntu 18.04 and Ubuntu 20.04 - Stack Overflow](https://stackoverflow.com/questions/69951510/can-not-find-core-dump-file-in-ubuntu-18-04-and-ubuntu-20-04)

> Regular user dumps caught by Apport write to `/var/lib/apport/coredump/`.

[debugging - Where do I find core dump files, and how do I view and analyze the backtrace (stack trace) in one? - Ask Ubuntu](https://askubuntu.com/questions/1349047/where-do-i-find-core-dump-files-and-how-do-i-view-and-analyze-the-backtrace-st)

> For those running late model Ubuntu, apport will generate dumps in `/var/lib/apport/coredump`.

[ubuntu开启core dump - TruthHell](https://www.cnblogs.com/cong-wang/p/15026524.html)

In order to set up the system to create core dumps: Set `ulimit` to *unlimited*.

By default, the maximum size of a core file is set to 0, meaning no core files will be generated. We can check the core file size in your limits using `ulimit` command:

```bash
$ ulimit -c
0

$ ulimit -a | grep core

-c: core file size (blocks)         0
```

To allow core file generation, use the command `ulimit -c unlimited`. We can also edit the `/etc/security/limits.conf` file to set this limit for all users.

```bash
$ ulimit -c unlimited
```

After setting the core file size to unlimited, recheck and confirm the configuration:

```bash
$ ulimit -c
unlimited

$ ulimit -a | grep core

-c: core file size (blocks)         unlimited
```

After configuring the core file size, run the binary again and it will generate a core dump in the specified location if there's a crash or an exception.

```bash
$ gcc modify-rodata.c -g && ./a.out
[1]    64871 segmentation fault (core dumped)  ./a.out
```

Take a look at `/var/log/apport.log` to see the tracking logs.

```bash
$ cat /var/log/apport.log
[...snip...]
ERROR: apport (pid 64872) Sun Aug 18 17:28:39 2024: called for pid 64871, signal 11, core limit 18446744073709551615, dump mode 1
ERROR: apport (pid 64872) Sun Aug 18 17:28:39 2024: ignoring implausibly big core limit, treating as unlimited
ERROR: apport (pid 64872) Sun Aug 18 17:28:39 2024: executable: /home/pifan/Projects/cpp/modify-rodata/a.out (command line "./a.out")
ERROR: apport (pid 64872) Sun Aug 18 17:28:39 2024: executable does not belong to a package, ignoring
ERROR: apport (pid 64872) Sun Aug 18 17:28:39 2024: writing core dump to core._home_pifan_Projects_cpp_modify-rodata_a_out.1000.f51f0527-4e10-4be1-b463-4f8019c6299a.64871.30416479 (limit: -1)
```

## debugging with GDB

[Files (Debugging with GDB)](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Files.html): You may want to specify executable and core dump file names. The usual way to do this is at start-up time, using the arguments to GDB’s start-up commands.

Type `gdb a.out core` to launch GDB with specified core dump to enter gdb core debugging mode.

```bash
$ gdb a.out /var/lib/apport/coredump/core._home_pifan_Projects_cpp_modify-rodata_a_out.1000.f51f0527-4e10-4be1-b463-4f8019c6299a.64871.30416479

Reading symbols from a.out...
[New LWP 64871]
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".
Core was generated by `./a.out'.
Program terminated with signal SIGSEGV, Segmentation fault.
#0  0x0000aaaad0c407bc in main (argc=1, argv=0xffffe189e7b8) at modify-rodata.c:10
10	    *ptr = 'T';
```

[在ubuntu中进行core dump调试 | Yunfeng](https://vra.github.io/2017/12/03/ubuntu-core-dump-debug/)
[Segmentation fault (core dumped)错误常见原因总结](https://blog.csdn.net/weixin_44010117/article/details/107718757)

To print a backtrace of the entire stack, use the `backtrace` command, or its alias `bt`.
You can then analyse and troubleshoot based on the stack backtrace and error information.

```bash
$ readelf -p .rodata a.out

String dump of section '.rodata':
  [     8]  hello
  [    10]  ptr = %s\n

$ rabin2 -z a.out
[Strings]
nth paddr      vaddr      len size section type  string
―――――――――――――――――――――――――――――――――――――――――――――――――――――――
0   0x000007f8 0x000007f8 5   6    .rodata ascii hello
1   0x00000800 0x00000800 9   10   .rodata ascii ptr = %s\n
```

Use `objdump` to check the `.rodata` section, we can see Flags=`CONTENTS, ALLOC, LOAD, READONLY, DATA`, which explicitly indicates that it's **`READONLY`** DATA.

```bash
$ objdump -hw a.out | grep rodata
 14 .rodata            0000001a  00000000000007f0  00000000000007f0  000007f0  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
```

Use `rabin2` to check the `.rodata` section: type=`PROGBITS`, same as `.text` section and perm=`-r--` means `READONLY`.

```bash
$ rabin2 -S a.out | grep rodata
15  0x000007f0   0x1a 0x000007f0   0x1a -r-- PROGBITS    .rodata
```

Type `readelf -l`(--program-headers) to display the program headers and list the segment headers of the ELF.

In [reloc puts@plt via GOT - r2 debug](../elf/plt-puts-r2debug.md): Use `readelf -lW` to display the program headers, or `rabin2 -SSS` to list sections and segments and their mapping relationship.

1. The section `.rodata` and `.text` have been classified into the first loadable text segment *LOAD0*.
2. The `.data` and `.bss` seciton have been categorized into the second loadable data segment *LOAD1*.
3. After `r2 -d a.out` to start debugging, type `dm` to list the memory maps, you'll see that `r-x` marks *LOAD0`* segment; `rw-` marks *LOAD1`* segment.

In [reloc puts@plt via GOT - pwndbg](../elf/plt-puts-pwndbg.md): When debugging with pwndbg, `vmmap` will show the *`LOAD0`* and *`LOAD1`* Segments. **`LOAD0`**'s Perm=`r-xp` the pages store readonly code(text) and rodata(Read-Only DATA); **`LOAD1`**'s Perm=`rw-p`.

Based on the above information, we can know that read-only data is designed to be stored in the code page (yes, it is the code page!), and the attribute of the code page itself is `r-x`. Under normal circumstances, the program code will not "execute" the read-only data stored in the code page, so putting the read-only data in the code page can save some space (no need to allocate data pages for it) and ensure that the data cannot be modified (the code page is not writable). If the process tries to modify the data in the read-only area, a segmentation fault exception is thrown.

```c
const int i = 0;
const int *p = &i;

int main(int argc, char* argv[])
{
    *(int*)p = 0;

    return 0;
}
```

In our case, "Program terminated with signal SIGSEGV, Segmentation fault." [SIGSEGV](https://en.wikipedia.org/w/index.php?title=SIGSEGV&redirect=no)(`SEGV` stands for SEGmentation Violation) can be found in [<signal.h>](https://en.cppreference.com/w/c/program/signal).

[Segmentation fault](https://en.wikipedia.org/wiki/Segmentation_fault) lists four scenarios of exceptional situations/circumstances:

1. Writing to read-only memory(e.g. string literal, const variable)
2. Null pointer dereference(`*(int*)0 = 0`)
3. Buffer overflow
4. Stack overflow
