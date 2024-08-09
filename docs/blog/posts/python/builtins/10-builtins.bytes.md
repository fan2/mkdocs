---
title: python内置模块之字节(bytes,bytearray)
authors:
  - xman
date:
    created: 2019-12-04T09:30:00
categories:
    - python
tags:
    - bytes
    - bytearray
comments: true
---

Python内置模块中的字节流（bytes/bytearray）的基本用法。

<!-- more -->

[Binary Sequence Types — bytes, bytearray, memoryview](https://docs.python.org/3/library/stdtypes.html#binary-sequence-types-bytes-bytearray-memoryview)

- [Bytes Objects](https://docs.python.org/3/library/stdtypes.html#bytes) objects are immutable sequences of single bytes.  
- [Bytearray Objects](https://docs.python.org/3/library/stdtypes.html#bytearray) objects are a mutable counterpart to bytes objects.  
- [Bytes and Bytearray Operations](https://docs.python.org/3/library/stdtypes.html#bytes-methods)  

## bytes

Bytes objects are **immutable** sequences of single bytes.

class bytes 构造声明如下：

```
```Shell
>>> help(bytes)

class bytes(object)
 |  bytes(iterable_of_ints) -> bytes
 |  bytes(string, encoding[, errors]) -> bytes
 |  bytes(bytes_or_buffer) -> immutable copy of bytes_or_buffer
 |  bytes(int) -> bytes object of size given by the parameter initialized with null bytes
 |  bytes() -> empty bytes object
 |
 |  Construct an immutable array of bytes from:
 |    - an iterable yielding integers in range(256)
 |    - a text string encoded using the specified encoding
 |    - any object implementing the buffer API.
 |    - an integer
```

构造方式1：传入整数数组（值小于256），对应可显示的ASCII码。

```Shell
>>> bytes([65, 66, 67, 68])
b'ABCD'
>>> bytes([97, 98, 99, 100])
b'abcd'
```

构造方式2：

```Shell
>>> bytes('abcd', encoding='utf-8')
b'abcd'
```

### bytes literals

[2.4.1. String and Bytes literals](https://docs.python.org/3/reference/lexical_analysis.html#string-and-bytes-literals)

Bytes literals are always prefixed with 'b' or 'B'; they produce an instance of the `bytes` type instead of the `str` type. They may only contain ASCII characters; bytes with a numeric value of 128 or greater must be expressed with **escapes**.

以b开头命名的字符串为字节流串：

```
>>> ba=b'\xcf\xc7'
>>> int.from_bytes(ba, byteorder='big')
53191
```

### fromhex

类方法 `fromhex` 将一个十六进制字符串转换为字节流。

```Shell
 |  ----------------------------------------------------------------------
 |  Class methods defined here:
 |
 |  fromhex(string, /) from builtins.type
 |      Create a bytes object from a string of hexadecimal numbers.

```

The string must contain two hexadecimal digits per byte, with ASCII whitespace being ignored.

```Shell
>>> bytes.fromhex('B9 01EF')
b'\xb9\x01\xef'

>>> bytes.fromhex('2Ef0 F1f2  ')
b'.\xf0\xf1\xf2'
```

### hexdump

hex 方法将 bytes 对象存储的字节串按十六进制输出，类似 hexdump 指令。

```Shell
 |  hex(...)
 |      Create a str of hexadecimal numbers from a bytes object.
 |
 |        sep
 |          An optional single character or byte to separate hex bytes.
 |        bytes_per_sep
 |          How many bytes between separators.  Positive values count from the
 |          right, negative values count from the left.
```

```Shell
>>> b'\xf0\xf1\xf2'.hex()
'f0f1f2'

>>> b1=bytes([65, 66, 67, 68])
>>> b1.hex()
'41424344'
# 字节之间以:分割
>>> b1.hex(':')
'41:42:43:44'
# 每2个字节为一组，从右往左
>>> b2.hex(':', 2)
'b9:01ef'
# 每2个字节为一组，从左往右
>>> b2.hex(':', -2)
'b901:ef'
```

## bytearray

bytearray objects are a **mutable** counterpart to bytes objects.

构造方法基本同 bytes 类。

```Shell
class bytearray(object)
 |  bytearray(iterable_of_ints) -> bytearray
 |  bytearray(string, encoding[, errors]) -> bytearray
 |  bytearray(bytes_or_buffer) -> mutable copy of bytes_or_buffer
 |  bytearray(int) -> bytes array of size given by the parameter initialized with null bytes
 |  bytearray() -> empty bytes array
 |
 |  Construct a mutable bytearray object from:
 |    - an iterable yielding integers in range(256)
 |    - a text string encoded using the specified encoding
 |    - a bytes or a buffer object
 |    - any object implementing the buffer API.
 |    - an integer
 |
```

### fromhex

```Shell
>>> bytearray.fromhex('2Ef0 F1f2  ')
bytearray(b'.\xf0\xf1\xf2')
```

### access as list

Since bytearray objects are sequences of integers (akin to a list), for a bytearray object b, `b[0]` will be an integer, while `b[0:1]` will be a bytearray object of length 1.

You can always convert a bytearray object into a list of integers using `list(b)`.

可按索引位置访问字节：

```Shell
>>> ba=bytearray.fromhex('cfc7')
>>> ba[0]
207
>>> hex(ba[0])
'0xcf'
>>> ba[1]
199
>>> hex(ba[1])
'0xc7'
>>> list(ba)
[207, 199]
```

### hexdump

同 bytes，bytearray 也支持 hex dump 十六进制字节流：


```Shelll
>>> bytearray(b'\xf0\xf1\xf2').hex()
'f0f1f2'
```

## int

### from_bytes

类方法 `from_bytes()` 将字节串（数组），按给定的字节序解析构造整数。

```
class int(object)

 |  Class methods defined here:
 |
 |  from_bytes(bytes, byteorder, *, signed=False) from builtins.type
 |      Return the integer represented by the given array of bytes.
```

```
>>> num1 = int.from_bytes(b'\xff' * 2, byteorder = 'big')
>>> num2 = int.from_bytes(b'\xff' * 4, byteorder = 'little')
>>> num1
65535
>>> num2
4294967295
```

---

十六进制 0xcfc7 的大端无符号数，最高位1的位权为 `2**15`：

```Shell
# 2**15+20423(0x4fc7)
>>> int.from_bytes(b'\xcf\xc7', byteorder='big')
53191
```

十六进制 0xcfc7 的大端有符号数，在补码表示下，最高位1为符号位，位权为 `-2**15`）：

```Shell
# -2**15+20423(0x4fc7)
>>> int.from_bytes(b'\xcf\xc7', byteorder='big', signed=True)
-12345
```

### to_bytes

实例方法 `to_bytes()` 打印一个整数在内存存储中的字节数组表示：

> [Converting int to bytes in Python 3](https://stackoverflow.com/questions/21017698/converting-int-to-bytes-in-python-3)

```Shell
class int(object)

 |  to_bytes(self, /, length, byteorder, *, signed=False)
 |      Return an array of bytes representing an integer.
```

- length：按多少个字节数组存储（输出）。
- byteorder：为方便分析可先填 big，也可读取实际的 sys.byteorder。
- signed：默认为False，即默认按无符号数处理，可按需置 True 将按有符号数处理。

无符号数（正数）53191的unsigned short大端内存表示为：

```Shell
>>> (53191).to_bytes(2, 'big')
b'\xcf\xc7'
```

将length扩大到4，即将 unsigned short 16 扩展为 unsigned int 32，只需要在高位补0即可。

```Shell
>>> (53191).to_bytes(4, 'big')
b'\x00\x00\xcf\xc7'
```

---

有符号数（负数）-12345 在内存中按大端字节序的补码表示：

```Shell
>>> (-12345).to_bytes(2, 'big', signed=True)
b'\xcf\xc7'
```

基于负数的补码表示机制推导如下：

short负数（2Byte-16bit）s=-12345，最高第15位为符号位为1，第14~0位的十进制值为u，则：

s=`-2**15+u` => u=`2**15+s` => u=`2**15-12345`=20423 => hex(u)='0x4fc7'，
最高第15位符号位置1，则负数s的十六进制补码表示是0xcfc7。

将length扩大到4，即将 short 16 扩展为 int 32，只需要在高位补1即可。

```Shell
>>> (-12345).to_bytes(4, 'big', signed=True)
b'\xff\xff\xcf\xc7'
```

## float

```Shell
>>> help(float)

 |  fromhex(string, /) from builtins.type
 |      Create a floating-point number from a hexadecimal string.
```

```Shell
>>> float.fromhex('0x1.ffffp10')
2047.984375
>>> float.fromhex('-0x1p-1074')
-5e-324
```

## struct

[struct — Interpret bytes as packed binary data](https://docs.python.org/3/library/struct.html) - [struct --- 将字节串解读为打包的二进制数据](https://docs.python.org/zh-cn/3/library/struct.html)

此模块可以执行 Python 值和以 Python bytes 对象表示的 C 结构之间的转换。 这可以被用来处理存储在文件中或是从网络连接等其他来源获取的二进制数据。 它使用 格式字符串 作为 C 结构布局的精简描述以及与 Python 值的双向转换。

- [struct — Binary Data Structures](https://pymotw.com/3/struct/)
- [python之struct 模块详解](https://blog.51cto.com/u_15073468/2791685)
- [Python使用struct处理二进制](https://www.cnblogs.com/gala/archive/2011/09/22/2184801.html)

### 字节顺序，大小和对齐方式

默认情况下，C类型以机器的本机格式和字节顺序表示，并在必要时通过跳过填充字节进行正确对齐（根据C编译器使用的规则）。

或者根据下表格式字符串的第一个字符，可用于指示打包数据的字节顺序、大小和对齐方式：

> 缺省为 `@`。

字符 | 字节顺序 | 大小 | 对齐方式
-----|---------|-----|---------
`@` | 按原字节 | 按原字节 | 按原字节
`=` | 按原字节 | 标准 | 无
`<` | 小端 | 标准 | 无
`>` | 大端 | 标准 | 无
`!` | 网络（=大端） | 标准 | 无

1. 可使用 `sys.byteorder` 来检查你的系统字节顺序。

    - 在 macOS 下，可通过 `system_profiler SPHardwareDataType`、`system_profiler SPSoftwareDataType`、`sw_vers` 等命令查看系统软硬件信息。

2. 本机大小和对齐方式是使用 C 编译器的 `sizeof` 表达式来确定的，这总是会与本机字节顺序相绑定。
3. 标准大小仅取决于格式字符；请参阅下文 格式字符 部分中的表格。
4. 请注意 '@' 和 '=' 之间的区别：两个都使用本机字节顺序，但后者的大小和对齐方式是标准化的。

注释：

1. 填充只会在连续结构成员之间自动添加。 填充不会添加到已编码结构的开头和末尾。
2. 当使用非本机大小和对齐方式即 '<', '>', '=', and '!' 时不会添加任何填充。
3. 要将结构的末尾对齐到符合特定类型的对齐要求，请以该类型代码加重复计数的零作为格式结束。

### 格式字符

格式 | C 类型 | Python 类型 | 标准大小 | 备注
----|--------|------------|--------|-----
x | 填充字节 | 无 | N/A | (7)
c | char | 长度为 1 的字节串 | 1 | N/A
b | signed | 整数 | 1 | (1), (2)
B | unsigned | 整数 | 1 | (2)
? | _Bool | bool | 1 | (1)
h | short | 整数 | 2 | (2)
H | unsigned short | 整数 | 2 | (2)
i | int | 整数 | 4 | (2)
I | unsigned | 整数 | 4 | (2)
l | long | 整数 | 4 | (2)
L | unsigned | 整数 | 4 | (2)
q | long | 整数 | 8 | (2)
Q | unsigned | 整数 | 8 | (2)
n | ssize_t | 整数 | N/A | (3)
N | size_t | 整数 | N/A | (3)
e | (6) | float | 2 | (4)
f | float | float | 4 | (4)
d | double | float | 8 | (4)
s | char[] | 字节串 | N/A | N/A
p | char[] | 字节串 | N/A | N/A
P | void | 整数 | N/A | (5)

### 示例

#### hhi -> hhq

```Python
#%%
import struct
import binascii

print(struct.calcsize('hhi'))
packed = struct.pack('hhi', 1, 2, 3)
print(packed)
print(binascii.hexlify(packed))

print(struct.calcsize('>hhi'))
packed = struct.pack('>hhi', 1, 2, 3)
print(packed)
print(binascii.hexlify(packed))
```

从输出结果看，默认是小端字节序：

```
8
b'\x01\x00\x02\x00\x03\x00\x00\x00'
b'0100020003000000'
8
b'\x00\x01\x00\x02\x00\x00\x00\x03'
b'0001000200000003'
```

将 `hhi` 换成 `hhl`：

1. 字节顺序、大小、对齐方式按原字节，short s1+short s2共占4个字节，补充4个字节填0与后面long l按原字节是8个字节对齐，结构体整体size=16。
2. 指定大端字节顺序，short s1+short s2共占4个字节，无对齐标准大小，紧接着l(long)也占4个字节，结构体整体size=8。

> 注意：q(long)才占8个字节！

```
16
b'\x01\x00\x02\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00'
b'01000200000000000300000000000000'
8
b'\x00\x01\x00\x02\x00\x00\x00\x03'
b'0001000200000003'
```

将 `hhi` 换成 `hhq`，calcsize 分别是 16、12（=标准大小=2+2+8）。

`hhi` 和 `hhq` 等效的C语言测试代码，sizeof 分别输出：4,8,8,16。

1. S1：s1+s2共占4个字节，与i占的4个字节对齐，无需填充，结构体整体size=8。
2. S2：s1+s2共占4个字节，需补充4个字节，与l占的8个字节对齐，结构体整体size=16。

```C
#include <stdio.h>

typedef struct tagS1 {
    short s1;
    short s2;
    int i;
} S1;

typedef struct tagS2 {
    short s1;
    short s2;
    long l;
} S2;

int main(int argc, char** argv) {
    printf("sizeof int = %lu\n", sizeof(int));
    printf("sizeof long = %lu\n", sizeof(long));
    printf("sizeof S1 = %lu\n", sizeof(S1));
    printf("sizeof S2 = %lu\n", sizeof(S2));

    return 0;
}
```

#### hhq,hqh,qhh

需要注意的是，struct.calcsize 计算的尺寸和C语言中的struct布局占用的字节数可能不一致：

```Python
# %%
import struct
import binascii


print(struct.calcsize('hhq'))
packed = struct.pack('hqh', 1, 2, 3)
print(packed)
print(binascii.hexlify(packed))

print(struct.calcsize('hqh'))
packed = struct.pack('hqh', 1, 2, 3)
print(packed)
print(binascii.hexlify(packed))

print(struct.calcsize('qhh'))
packed = struct.pack('hqh', 1, 2, 3)
print(packed)
print(binascii.hexlify(packed))
```

运行结果：

- struct.calcsize('hhq') = 16 = 2+2+(4)+8
- struct.calcsize('hqh') = 18 = 2+(6)+8+2
- struct.calcsize('qhh') = 12 = 8+2+2

**分析**：前面的短字节填充对齐后面的长字节，长字节后面的短字节不用再对齐。

---

等效的C语言测试代码，sizeof 分别为 16, 24, 16。

```C
#include <stdio.h>

typedef unsigned char *byte_pointer;

void show_bytes(byte_pointer start, size_t len) {
    size_t i;
    printf("0x");
    for (i=0; i<len; i++)
        printf("%.2x", start[i]);
    printf("\n");
}

// hhq
typedef struct tagS2 {
    short s1;
    short s2;
    long l;
} S2;

// hqh
typedef struct tagS3 {
    short s1;
    long l;
    short s2;
} S3;

// qhh
typedef struct tagS4 {
    long l;
    short s1;
    short s2;
} S4;

int main(int argc, char** argv) {
    // hexdump bytearray
    printf("sizeof S2 = %lu\n", sizeof(S2));
    S2 s2 = {1, 2, 3};
    show_bytes((byte_pointer)&s2, sizeof(S2));

    printf("sizeof S3 = %lu\n", sizeof(S3));
    S3 s3 = {1, 2, 3};
    show_bytes((byte_pointer)&s3, sizeof(S3));

    printf("sizeof S4 = %lu\n", sizeof(S4));
    S4 s4 = {1, 2, 3};
    show_bytes((byte_pointer)&s4, sizeof(S4));

    return 0;
}
```

在 macOS（litte-endian）上的运行结果如下：

```
sizeof S2 = 16
0x01000200000000000300000000000000
sizeof S3 = 24
0x010000000000000002000000000000000300000000000000
sizeof S4 = 16
0x01000000000000000200030000000000
```

对 sizeof struct 长度的简析：

- 16=2+2+(4)+8
- 24=2+(6)+8+2+(6)
- 16=8+2+2+(4)
