---
title: AArch64 Execution States
authors:
    - xman
date:
    created: 2023-06-02T09:00:00
categories:
    - arm
tags:
    - AArch64
    - AArch32
comments: true
---

The AArch64 processor provides two major modes of operation, referred to as ***execution states***. They are 32-bit AArch32 state, and 64-bit AArch64 state.

<!-- more -->

## Execution states

[Assembly challange - Raspberry Pi Forums](https://forums.raspberrypi.com/viewtopic.php?t=228003)

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/a/An-Introduction-to-the-ARMv8-Instruction-Sets) | 3.1 Execution states

The ARMv8 architecture defines two ***Execution States***, *AArch64* and *AArch32*. Each state is used to describe execution using 64-bit wide general-purpose registers or 32-bit wide general-purpose registers, respectively. While ARMv8 AArch32 retains the ARMv7 definitions of privilege, in AArch64, privilege level is determined by the Exception level. Therefore, execution at `ELn` corresponds to privilege `PLn`.

When in AArch64 state, the processor executes the A64 instruction set. When in AArch32 state, the processor can execute either the A32 (called ARM in earlier versions of the architecture) or the T32 (Thumb) instruction set.

The following diagrams show the organization of the Exception levels in AArch64 and AArch32.

<figure markdown="span">
    ![Figure 3.3. Exception levels in AArch64](https://documentation-service.arm.com/static/5fbd26f271eff94ef49c7036)
    <figcaption>Figure 3-3 Exception levels in AArch64</figcaption>
</figure>

## Changing execution state

[Arm Compiler armasm User Guide](https://developer.arm.com/documentation/dui0801/latest) | 3.4 Changing between AArch64 and AArch32 states

The processor must be in the correct execution state for the instructions it is executing.

A processor that is executing A64 instructions is operating in AArch64 state. In this state, the instructions can access both the 64-bit and 32-bit registers.

A processor that is executing A32 or T32 instructions is operating in AArch32 state. In this state, the instructions can only access the 32-bit registers, and not the 64-bit registers.

A processor based on the Arm ® v8 architecture can run applications built for AArch32 and AArch64 states but a change between AArch32 and AArch64 states can only happen at exception boundaries.

Arm Compiler toolchain builds images for either the AArch32 state or AArch64 state. Therefore, an image built with Arm Compiler toolchain can either contain only A32 and T32 instructions or only A64 instructions.

A processor can *only* execute instructions from the instruction set that matches its *current* execution state. A processor in AArch32 state cannot execute A64 instructions, and a processor in AArch64 state cannot execute A32 or T32 instructions. You must ensure that the processor never receives instructions from the wrong instruction set for the current execution state.

---

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/a/An-Introduction-to-the-ARMv8-Instruction-Sets) | 3.3 Changing execution state

There are times when you must change the execution state of your system. This could be, for example, if you are running a 64-bit operating system, and want to run a 32-bit application at `EL0`. To do this, the system must *change* to `AArch32`.

When the application has completed or execution returns to the OS, the system can *switch back* to `AArch64`. Figure 3-7 shows that you cannot do it the other way around. An AArch32 operating system cannot host a 64-bit application.

<figure markdown="span">
    ![Figure 3.7. Moving between AArch32 and AArch64](https://documentation-service.arm.com/static/5fbd26f271eff94ef49c7013)
    <figcaption>Figure 3-7 Moving between AArch32 and AArch64</figcaption>
</figure>

To change between execution states at the same Exception level, you have to switch to a higher Exception level then return to the original Exception level. For example, you might have 32-bit and 64-bit applications running under a 64-bit OS. In this case, the 32-bit application can execute and generate a Supervisor Call (`SVC`) instruction, or receive an interrupt, causing a switch to `EL1` and AArch64. (See [Exception handling instructions](https://developer.arm.com/documentation/den0024/a/The-A64-instruction-set/System-control-and-other-instructions/Exception-handling-instructions?lang=en).) The OS can then do a task switch and return to `EL0` in AArch64. Practically speaking, this means that you cannot have a *mixed* 32-bit and 64-bit application, because there is no direct way of calling between them.

You can *only* change execution state by changing Exception level.

- Taking an exception might change from AArch32 to AArch64, and returning from an exception may change from AArch64 to AArch32.
- Code at `EL3` cannot take an exception to a higher exception level, so cannot change execution state, except by going through a reset.

Interworking between the two states is therefore performed at the level of the Secure monitor, hypervisor or operating system. A hypervisor or operating system executing in AArch64 state can support AArch32 operation at lower privilege levels. This means that an OS running in AArch64 can *host* both AArch32 and AArch64 applications. Similarly, an AArch64 hypervisor can host both AArch32 and AArch64 guest operating systems. However, a 32-bit operating system cannot host a 64-bit application and a 32-bit hypervisor cannot host a 64-bit guest operating system.

For the highest implemented Exception level (`EL3` on the Cortex-A53 and Cortex-A57 processors), which execution state to use for each Exception level when taking an exception is fixed. The Exception level can only be changed by resetting the processor. For `EL2` and `EL1`, it is controlled by the [System registers](https://developer.arm.com/documentation/den0024/a/ARMv8-Registers/System-registers?lang=en).

---

[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/a/An-Introduction-to-the-ARMv8-Instruction-Sets) | 5.3 Switching between the instruction sets

It is not possible to use code from the two execution states within a single application. There is no interworking between A64 and A32 or T32 instruction sets in ARMv8 as there is between A32 and T32 instruction sets. Code written in A64 for the ARMv8 processors cannot run on ARMv7 Cortex-A series processors. However, code written for ARMv7-A processors can run on ARMv8 processors in the AArch32 execution state. This is summarized in Figure 5-1.

<figure markdown="span">
    ![Figure 5.1. Switching between instruction sets](https://documentation-service.arm.com/static/5fbd26f271eff94ef49c7029)
    <figcaption>Figure 5-1 Switching between instruction sets</figcaption>
</figure>

## references

[32 bit assembly code in aarch64 - ODROID](https://forum.odroid.com/viewtopic.php?t=20203)
[32 Bit executables in AARCH64 system - ODROID](https://forum.odroid.com/viewtopic.php?t=18806)

[How can I assembly and run arm32 code in my aarch64 phone using termux? : r/termux](https://www.reddit.com/r/termux/comments/g7tzlj/how_can_i_assembly_and_run_arm32_code_in_my/)
[linux - Running 32-bit ARM binary on aarch64 not working despite CONFIG_COMPAT - Stack Overflow](https://stackoverflow.com/questions/59379848/running-32-bit-arm-binary-on-aarch64-not-working-despite-config-compat)
[How to run 32-bit (armhf) binaries on 64-bit (arm64) Debian OS on Raspberry Pi? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/625576/how-to-run-32-bit-armhf-binaries-on-64-bit-arm64-debian-os-on-raspberry-pi)

[How to switch from default aarch32 to aarch64? - Arm Community](https://community.arm.com/support-forums/f/architectures-and-processors-forum/53344/how-to-switch-from-default-aarch32-to-aarch64)
[How Linux arm64 switch between AArch32 and AArch64 - Stack Overflow](https://stackoverflow.com/questions/60220759/how-linux-arm64-switch-between-aarch32-and-aarch64)
