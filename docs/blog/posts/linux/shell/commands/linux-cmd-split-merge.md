---
title: Linux Command - file split & merge
authors:
  - xman
date:
    created: 2019-10-29T12:30:00
categories:
    - wiki
    - linux
    - command
tags:
    - split
    - cat
comments: true
---

linux 下分割和合并文件命令简介。

<!-- more -->

## diff

[How to Compare Two Files in Bash Script](https://www.squash.io/how-to-compare-two-files-in-bash-script/)

[unix - how to compare output of two ls in linux](https://stackoverflow.com/questions/13622107/how-to-compare-output-of-two-ls-in-linux)

[Compare two files and output the differences](https://superuser.com/questions/805522/compare-two-files-and-output-the-differences)

## join

[Bash join ls output - Stack Overflow](https://stackoverflow.com/questions/4234366/bash-join-ls-output)

No need to run ls twice, just put multiple file specifications as arguments.

```Shell
ls $dir1 $dir2

(ls $dir1; ls $dir2) | sort

{ ls $dir1 && ls $dir2; }

find $dir1 $dir2 -mindepth 1 -maxdepth 1 | sort
```

## comm

[Intersection of two lists in Bash - Stack Overflow](https://stackoverflow.com/questions/2696055/intersection-of-two-lists-in-bash)

Use the [comm](https://www.man7.org/linux/man-pages/man1/comm.1.html) command:

```Shell
comm -12 <(ls $dir1) <(ls $dir2)
```

```Shell
ls $dir1 | sort > /tmp/one_list
ls $dir2 | sort > /tmp/two_list
comm -12 /tmp/one_list /tmp/two_list
```

comm requires the inputs to be sorted. In this case, ls automatically sorts its output, but other uses may need to do this:

```Shell
comm -12 <(some-command | sort) <(some-other-command | sort)
```

Alternative with `sort`:

Intersection of two lists: 

```Shell
sort <(ls $dir1) <(ls $dir2) | uniq -d
```

Symmetric difference of two lists:

```Shell
sort <(ls $dir1) <(ls $dir2) | uniq -u
```

任务：macOS 查找/usr/bin/ 和/Library/Developer/CommandLineTools/usr/bin/ 下的同名文件。

```Shell
dir1=/Library/Developer/CommandLineTools/usr/bin
dir2=/usr/bin

comm -12 <(ls $dir1) <(ls $dir2)
sort <(ls $dir1) <(ls $dir2) | uniq -d
```

## split

[How to split a large text file into smaller files with equal number of lines?](https://stackoverflow.com/questions/2016894/how-to-split-a-large-text-file-into-smaller-files-with-equal-number-of-lines)

```
✗ split -h
split: illegal option -- h
usage: split [-a sufflen] [-b byte_count] [-l line_count] [-p pattern]
             [file [prefix]]
```

将大文件 `mybigfile.txt` 分割成小文件，每个小文件最多20万行：

```
split -l 200000 mybigfile.txt
```

基于 `sed` 提取 1~100 行内容到文件：

```
sed -n '1,100p' filename > output.txt
```

[How to Split Large Text File into Smaller Files in Linux](https://linoxide.com/linux-how-to/split-large-text-file-smaller-files-linux/)

[11 Useful split command examples for Linux/UNIX systems](https://www.linuxtechi.com/split-command-examples-for-linux-unix/)

## merge

### Windows

Merge a text (.txt) file in the Windows command line

Type in the following command to merge all TXT files in the current directory into the file named newfile.txt (any name could be used).

```
copy *.txt newfile.txt
```

### Linux

Merge a file in the Linux command line

Linux users can merge two or more files into one file using the merge command or lines of files using the paste command.

[Linux merge command](https://www.computerhope.com/unix/merge.htm)

[Linux paste command](https://www.computerhope.com/unix/upaste.htm)

#### cat

unix/POSIX - [cat](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/cat.html)  
FreeBSD/Darwin - [cat](https://www.freebsd.org/cgi/man.cgi?query=cat)  

linux - [cat(1)](https://man7.org/linux/man-pages/man1/cat.1.html) - [cat(1p)](https://man7.org/linux/man-pages/man1/cat.1p.html)  
debian/Ubuntu - [cat](https://manpages.debian.org/buster/coreutils/cat.1.en.html)  

[cat(1)](https://man7.org/linux/man-pages/man1/cat.1.html) - concatenate files and print on the standard output

SYNOPSIS: `cat [OPTION]... [FILE]...`

macOS 下 cat 命令只支持7个选项 `cat [-benstuv] [file ...]`

```
     -b      Number the non-blank output lines, starting at 1.

     -e      Display non-printing characters (see the -v option), and display a dollar sign (`$') at the end
             of each line.

     -n      Number the output lines, starting at 1.

     -s      Squeeze multiple adjacent empty lines, causing the output to be single spaced.

     -t      Display non-printing characters (see the -v option), and display tab characters as `^I'.

     -u      Disable output buffering.

     -v      Display non-printing characters so they are visible.  Control characters print as `^X' for con-
             trol-X; the delete character (octal 0177) prints as `^?'.  Non-ASCII characters (with the high
             bit set) are printed as `M-' (for meta) followed by the character for the low 7 bits.
```

`-n`：number all output lines，打印所有行号。  
`-b`：number nonempty output lines, overrides `-n`。非空行才显示行号。  
`-s`：suppress repeated empty output lines，将两行以上的空行压缩为一行空白。  
`-v`：use `^` and `M-` notation, except for *LFD* and *TAB*。  
`-e`(end)：显示非打印字符，在 `-v` 的基础上，行末 LFD 显示`$`符号。linux 下等效于 `-vE`。  
`-t`(tab)：显示非打印字符，在 `-v` 的基础上，制表符 TAB 显示为`^I`。linux 下等效于 `-vT`。  

> Windows CRLF 时，`-v` 将在行末显示 `^M`。  
> `-et` 相当于 linux 下的 `-A` = `-vET`。  

linux 下多出3个选项：

```
       -A, --show-all
              equivalent to -vET

       -E, --show-ends
              display $ at end of each line

       -T, --show-tabs
              display TAB characters as ^I
```

---

[Linux: Putting two or more files together using cat](http://www.techpository.com/linux-putting-two-or-more-files-together-using-cat/)  
[How to Combine Text Files Using the “cat” Command in Linux](https://www.howtogeek.com/278599/how-to-combine-text-files-using-the-cat-command-in-linux/)  
[How can I concatenate two files in Unix?](https://superuser.com/questions/228878/how-can-i-concatenate-two-files-in-unix)  

通过命令行在 file4 末尾追加输入内容：

```
cat >> file4.txt
```

> 输入最后一行后，换行 + Ctrl-D 结束。

将 file1、file2 这2个文件追加到 file3 尾部:

```
cat file1.txt file2.txt >> file3.txt
```

将 file1、file2、file3 这3个文件合并成 file4（覆盖）:

```
cat file1.txt file2.txt file3.txt > file4.txt
```

---

[How can I cat multiple files together into one without intermediary file?](https://stackoverflow.com/questions/4072361/how-can-i-cat-multiple-files-together-into-one-without-intermediary-file)

```
for file in file1 file2 file3 ... fileN; do
  cat "$file" >> bigFile && rm "$file"
done
```

---

假如当前目录下有几个日志文件，并且是按照时间排序的：

```
Logs $ ls
1001-10K.log 1003-20K.log 1004-30K.log 1006-40K.log 1007-50K.log 1009-60K.log 1010-70K.log
Logs $ ls -1
1001-10K.log
1003-20K.log
1004-30K.log
1006-40K.log
1007-50K.log
1009-60K.log
1010-70K.log
```

可将所有文件（名）作为 cat 的列表参数，将它们拼接成一个大的日志进行综合分析：

```
Logs $ ls | xargs cat > ../1001_1010-10K_70K.log
```

> 如果要从多层目录中筛检文件，需要 `ls -R | grep ` 或借助 `find` 命令。

#### tee

如果文件不存在，则会新建文件；
如果文件已存在，则会 Truncate/Overwrite 覆写已有文件：

```
cat file1.txt file2.txt file3.txt | tee file4.txt
```

如果想追加到已存在文件尾部，可指定 `-a` 选项：

```
cat file1.txt file2.txt file3.txt | tee -a file4.txt
```
