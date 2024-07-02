---
title: Linux Shell Program - daemon 1
authors:
  - xman
date:
    created: 2019-11-06T11:10:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之后台执行。

<!-- more -->

vscode 在 `launch.json` 中如何预启动 proxy daemon sh 脚本？  
Android Studio `Before launch` 如何启动 proxy daemon sh 脚本？  

## sh

可以新开 `xterm -e` 或通过 `screen` 执行脚本。

[How to have terminal open when running shell script?](https://unix.stackexchange.com/questions/460561/how-to-have-terminal-open-when-running-shell-script)  
[Run a shell script in new terminal from current terminal](https://stackoverflow.com/questions/13648780/run-a-shell-script-in-new-terminal-from-current-terminal)  
[How can I make a script that opens terminal windows and executes commands in them?](https://askubuntu.com/questions/46627/how-can-i-make-a-script-that-opens-terminal-windows-and-executes-commands-in-the)  

[How to Run Linux Commands in Background](https://linuxize.com/post/how-to-run-linux-commands-in-background/)  

```Shell
# suppress the stdout and stderr messages
# redirect stdout to /dev/null and stderr to stdout
command > /dev/null 2>&1 &
```

`disown`: remove the job from the shell's job control

`nohup` stands for no hangup, ignores all hangup signals(SIGHUP).
`SIGHUP` is a signal that is sent to a process when its controlling terminal is closed.
If you log out or close the terminal, the process is not terminated.

```Shell
# output is redirected to the nohup.out file
nohup command &
```

[Screen](https://linuxize.com/post/how-to-use-linux-screen/) or GNU Screen is a terminal multiplexer program that allows you to start a screen session and open any number of windows (virtual terminals) inside that session. Processes running in Screen will continue to run when their window is not visible even if you get disconnected.

[Tmux](https://linuxize.com/post/getting-started-with-tmux/) is a modern alternative to GNU screen. With Tmux, you can also create a session and open multiple windows inside that session. Tmux sessions are persistent, which means that programs running in Tmux continue to run even if you close the terminal.

[How to Run Linux Shell Command / Script in Background](https://www.linuxtechi.com/run-linux-shell-command-in-background/)  

the command will still print the output to `STDOUT` or `STDERR` which will **prevent** you from executing other commands on the terminal.

```Shell
command &
```

A better approach is to redirect the command to `/dev/null` and later append the ampersand sign at the end as shown

```Shell
$ command &>/dev/null &
```

Another way you can run a command in the background is using the `nohup` command.
The `nohup` command, short for *no hang up*, is a command that keeps a process running even after exiting the shell.

It does this by blocking the processes from receiving a SIGHUP (Signal Hang UP) signal which is a signal that is typically sent to a process when it exits the terminal.

To send a command or script in the background and keep it running, use the syntax:

```Shell
$ nohup command &>/dev/null &
$ nohup shell-script.sh &>/dev/null &
```

[How to run a shell script in background?](https://askubuntu.com/questions/88091/how-to-run-a-shell-script-in-background)  

just add a `&` to the end of the command

```
command &
script.sh &
```

If you are running it in a terminal, and you want to then close the terminal, use `nohup` or `disown`

```Shell
# nohup
nohup script.sh &

# disown
script &
disown
```

If you want the script to remain after closing the terminal, another option is to use `setsid`:

```
setsid script.sh
```

For more information about the differences between nohup, disown, & and setsid: [Difference between nohup, disown and &](https://unix.stackexchange.com/q/3886/207557).

you can just switch `screen` and run your script on that 2nd screen. When script started on 2nd, switch back to 1st and do whatever you want. 2nd screen will be in the background as extra "terminal window". and it will not stop processing even when you close your ssh connection while beeing at 1st screen.

[How to run a command in the background and get no output?](https://stackoverflow.com/questions/9190151/how-to-run-a-command-in-the-background-and-get-no-output)  

Use nohup if your background job takes a long time to finish.

Redirect the stdout and stderr to `/dev/null` to ignore the output.

```Shell
nohup /path/to/your/script.sh > /dev/null 2>&1 &
```

Redirect the output to a file like this:

```Shell
# redirect both stdout and stderr to the same file
./a.sh > somefile 2>&1 &
# redirect stdout and stderr to two different files
./a.sh > stdoutfile 2> stderrfile &
```

You can use `/dev/null` as one or both of the files if you don't care about the stdout and/or stderr.

redirects output to null and keeps screen clear:

```Shell
command &>/dev/null &
```

Run in a subshell to remove notifications and close STDOUT and STDERR:

```Shell
(&>/dev/null script.sh &)
```

If they are in the same directory as your script that contains:

```Shell
./a.sh > /dev/null 2>&1 &
./b.sh > /dev/null 2>&1 &
```

- The `&` at the end is what makes your script run in the background.
- The `> /dev/null 2>&1` part is not necessary - it redirects the stdout and stderr streams, so you don't have to see them on the terminal, which you may want to do for noisy scripts with lots of output.

If you want to run the script in a linux kickstart you have to run as below .

```Shell
sh /tmp/script.sh > /dev/null 2>&1 < /dev/null &
```

These examples work fine, it works in background and does not show any output.

```Shell
nohup sh prog.sh proglog.log 2>&1 &
```

## scpt

macOS AppleScript 脚本后缀：`.scpt`, `.applescript`。

[How can Apple Script open a shell script with options in a Terminal window?](https://apple.stackexchange.com/questions/156974/how-can-apple-script-open-a-shell-script-with-options-in-a-terminal-window)

```AppleScript
tell application "Terminal"
    do script "~/testscript" & " -arg1" & " -arg2"
end tell
```

[do shell script without waiting](https://discussions.apple.com/thread/323661)  
[how to call a applescript/shell script without waiting for it](https://macscripter.net/viewtopic.php?id=27421)  
[How to run multiple shell scripts from applescript in background](https://stackoverflow.com/questions/40925336/how-to-run-multiple-shell-scripts-from-applescript-in-background)  

- [do shell script in AppleScript](https://developer.apple.com/library/archive/technotes/tn2065/_index.html)

I want to start a background server process; how do I make do shell script not wait until the command completes?

Use do shell script "command &> file_path &". do shell script will return immediately with no result and your AppleScript script will be running in parallel with your shell script. The shell script's output will go into `file_path`; if you don't care about the output, use `/dev/null`. There is no direct support for getting or manipulating the background process from AppleScript, but see the next question.

```AppleScript
do shell script "/bin/blah &> /dev/null &"
do shell script "/bin/blah > /dev/null 2>&1 &"
do shell script "/bin/blah &> /dev/null & echo $!" # dump process ID
```

The AppleScript code to run two commands in the background would look like this:

```AppleScript
set pid1 to do shell script command1 & " &> /dev/null & echo $!"
set pid2 to do shell script command2 & " &> /dev/null & echo $!"
```

The `pid1` and `pid2` variables will be set to the process ids of the two commands. 
You can later check whether the commands are still running by calling a function like this one:

```AppleScript
on isProcessRunning(pid)
    try
        do shell script "kill -0 " & pid
        set isRunning to true
    on error
        set isRunning to false
    end try
    return isRunning
end isProcessRunning
```
