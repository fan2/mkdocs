---
title: Linux Shell Program - array
authors:
  - xman
date:
    created: 2019-11-06T10:00:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之数组常用操作。

<!-- more -->

[Arrays in unix shell?](https://stackoverflow.com/questions/1878882/arrays-in-unix-shell)  
[Working with Arrays in Linux Shell Scripting – Part 8](https://www.tecmint.com/working-with-arrays-in-linux-shell-scripting/)  

## 数组的定义

定义一个数组 `array`：

```sh
$ array=()
$ array=("A" "B" "ElementC" "ElementE")
```

整体打印数组内容：

```sh
$ echo $array
A B ElementC ElementE
$ echo ${array[@]}
$ echo ${array[*]}
```

## 数组长度

用 `${#数组名[@或*]}` 可以得到数组长度。

```sh
$ echo ${#array[@]}
$ echo ${#array[*]}
4
```

## 访问数组元素

按索引获取数组元素：

> 实际索引从1开始。

```sh
$ echo ${array[0]}

$ echo ${array[1]}
A
$ echo ${array[2]}
B
$ echo ${array[3]}
ElementC
$ echo ${array[4]}
ElementE
```

循环遍历数组元素：

```sh
for element in "${array[@]}"
do
    echo "$element"
done
```

遍历结果输出：

```sh
A
B
ElementC
ElementE
```

C 语言写法：

```sh
b=0
while [ $b -lt $c ]
do
  echo ${filelist[$b]}
  ((b++))
done
```

### 数组索引区间切片

`${array[@]}` 代表整个数组，则切片写法如下：

- `${array[@]:0:2}` 表示数组从0（索引为0+1）开始的2个元素，即 `${array[1]}`、`${array[2]}`；  
- `${array[@]:2:3}` 表示数组从2（索引为2+1）开始的3个元素；  
- `${array[@]:2}` 表示数组从2（索引为2+1）开始，直到结尾；  

```Shell
array=("A" "B" "C" "D" "E")
$ echo ${array[@]:0:2}
A B
$ echo ${array[@]:2:3}
C D E
$ echo ${array[@]:2}
C D E
```

### C风格按照索引写入

[进入某个目录将目录下面的文件名存入数组](https://blog.csdn.net/u011046042/article/details/49680781)  

```sh
cd $yourpathname
j=0
for i in `ls -1`
do
    folder_list[j]=$i
    j=`expr $j + 1`
done
```

[在shell中把ls的输出存进一个数组变量中](https://blog.csdn.net/baidu_35757025/article/details/64439508)  

```sh
c=0
for file in `ls`
do
  filelist[$c]=$file
  ((c++))
done
```

或者：

```sh
c=0
for file in *
do
  filelist[$c]="$file" # 为了准确起见，此处要加上双引号
  ((c++))
done
```

或者：

```sh
set -a myfiles
index=0
for f in `ls`; do myfiles[index]=$f; let index=index+1; done
```

**注意**：用这种方法，如果文件名中有空格的话，会将一个文件名以空格为分隔符分成多个存到数组中，最后出来的结果就是错误的。

---

把filelist数组内容输出到屏幕上：

```sh
b=0
while [ $b -lt $c ]
do
  echo ${filelist[$b]}
  ((b++))
done
```

或者

```sh
b=0
for value in ${filelist[*]}
do
  echo $value
done
```

用 `${#数组名[@或*]}` 可以得到数组长度。

在屏幕上输出filelist数组长度：

```sh
echo ${#filelist[*]}
```

## Mutable Access

[How to add/remove an element to/from the array in bash?](https://unix.stackexchange.com/questions/328882/how-to-add-remove-an-element-to-from-the-array-in-bash)

[Mutable list or array structure in Bash? How can I easily append to it?](https://stackoverflow.com/questions/2013396/mutable-list-or-array-structure-in-bash-how-can-i-easily-append-to-it)  

### add an element at head/tail

To add an element to the beginning of an array use.

```sh
arr=("new_element" "${arr[@]}")
```

Generally, you would do.

```sh
arr=("new_element1" "new_element2" "..." "new_elementN" "${arr[@]}")
```

To add an element to the end of an array use.

```sh
arr=( "${arr[@]}" "new_element" )
```

Or instead

```sh
arr+=( "new_element" )
```

Generally, you would do.

```sh
arr=( "${arr[@]}" "new_element1" "new_element2" "..." "new_elementN")
# Or
arr+=( "new_element1" "new_element2" "..." "new_elementN" )
```

### add an element to specific index

To add an element to specific index of an array use.

Let's say we want to add an element to the position of Index2 `arr[2]`, we would actually do **merge** on below sub-arrays:

1. Get all elements before Index position2 arr[0] and arr[1];  
2. Add an element to the array;  
3. Get all elements with Index position2 to the last arr[2], arr[3], ....  

```sh
arr=( "${arr[@]:0:2}" "new_element" "${arr[@]:2}" )
```

### removing an element from the array

In addition to removing an element from an array (let's say element `#2`), we need to **concatenate** two sub-arrays. 
The first sub-array will hold the elements *before* element `#2` and the second sub-array will contain the elements *after* element `#2`.

```sh
arr=( "${arr[@]:0:2}" "${arr[@]:3}" )
```

`${arr[@]:0:2}` will get two elements `arr[0]` and `arr[1]` starts from the beginning of the array.  
`${arr[@]:3}` will get all elements from index3 arr[3] to the last.  

Another possibility to remove an element is Using `unset` (actually assign 'null' value to the element)

```sh
unset arr[2]
```

Use replace pattern if you know the value of your elements.

```sh
arr=( "${arr[@]/PATTERN/}" )
```

## text to line array

在执行 find、grep 等命令时，每一条结果往往对应一行文本，可将文本行管道传输给 xargs 等进行后续处理。

如果当前Shell环境没有安装 sed、awk 等行编辑器，可以将文本文件转换为文本行数组，然后遍历数组进行逐行处理。

```sh
array=($(cat issue-file-list.txt)) # array=($(awk 1 issue-file-list.txt))
echo ${#array[*]}

for file in ${array[@]}; do
    clang-format --verbose -style=file -i $file
done
```

当然，通过行编辑器 sed、awk 来逐行输出，进而执行进一步操作。

`sed -n '1,$p' issue-file-list.txt | xargs clang-format --verbose -style=file -i`
`awk 1 issue-file-list.txt | xargs clang-format --verbose -style=file -i`
