---
title: ARM Architecture
authors:
  - xman
date:
    created: 2023-03-13T12:00:00
categories:
    - CS
tags:
    - arm
    - profile
comments: true
---

`ARM` 最初的简称是 *Acorn RISC Machine*。ARM 使用的内核与指令集并不一一对应。

1990年11月，Acorn、Apple 和 VLSI 共同出资创建了 ARM。Acorn RISC Machine 也正式更名为 *Advanced RISC Machine*。

ARM11 之后，ARM 处理器内核不再以 ARM 作为前缀。但 `ARM` 这个单词并没有在 Cortex 系列中消失，Cortex的三大系列 *M-R-A*，合起来就是 ARM。

<!-- more -->

## arch

[About the Arm architecture](https://developer.arm.com/documentation/102404/0201/About-the-Arm-architecture?lang=en)

The Arm architecture is one of the most popular processor architectures in the world. Billions of Arm-based devices are shipped every year.

The following table describes the three architecture profiles: A, R, and M:

**A**-Profile (Applications) | **R**-Profile (Real-Time) | **M**-Profile (Microcontroller)
-------------------------|-----------------------|----------------------------
High performance | Targeted at systems with real-time requirements | Small, highly power- efficient devices
Designed to run a complex operating system, such as Linux or Windows | Commonly found in networking equipment, and embedded control systems | Found at the heart of many IoT devices

These three profiles allow the Arm architecture to be tailored to the needs of different use cases, while still sharing several base features.

!!! note "Arm brands"

    Arm `Cortex` and Arm `Neoverse` are the brand names that are used for the Arm processor IP offerings. Our partners offer other processor brands using the Arm architecture.

![Arm-Arch](./images/Arm_Architecture.png)

This example smartphone contains the following processor types:

- An **A**-profile processor as the main CPU running a rich OS like Android.
- A cellular modem, based on an **R**-profile processor, provides connectivity.
- Several **M**-profile processors handle operations like system power management.
- The SIM card uses SecurCore, an M-profile processor with additional security features. SecurCore processors are commonly used in smart cards.

[Introduction to the Armv8-M Architecture and its Programmers Model User Guide](https://developer.arm.com/documentation/107656/0101/Introduction-to-Armv8-architecture-and-architecture-profiles):

The `Armv8` architecture has several different profiles. These profiles are variants of the architecture that target different markets and use cases. The Armv8-M architecture is one of these architecture profiles.

Arm defines three architecture profiles: Application (***A***), Real-time (***R***), and Microcontroller (***M***).

## Apple

[Apple silicon](https://en.wikipedia.org/wiki/Apple_silicon)

[List of iPhone models](https://en.wikipedia.org/wiki/List_of_iPhone_models)

[List of Apple's mobile device codes types](https://gist.github.com/adamawolf/3048717)

[iPhone chip list: Here's what A-series chip is in each model - 9to5Mac](https://9to5mac.com/2022/07/27/iphone-chip-list/)

[List of Apple processors | Apple Wiki | Fandom](https://apple.fandom.com/wiki/List_of_Apple_processors)

- Apple A7 — (2013) introduced in the iPhone 5S, the company's first 64-bit mobile processor. Also used in the 2nd and 3rd generation iPad minis and 1st generation iPad Air.

## Raspberry Pi

[Raspberry Pi Specifications](https://en.wikipedia.org/wiki/Raspberry_Pi#Specifications)

model | Release date | Soc | ISA | CPU
------|--------------|------|-----|----
RPi 3 Model B | Feb 2016 | BCM2837 | ARMv8-A (64/32-bit) | 4× Cortex-A53 1.2 GHz
RPi 4 Model B | Jun 2019​/May 2020 | BCM2711 | ARMv8-A (64/32-bit) | 4× Cortex-A72 1.5 GHz or 1.8 GHz
RPi 5 | Oct 2023 | BCM2712 | ARMv8.2-A (64/32-bit) | 4× Cortex-A76 2.4 GHz

[RPi3 in ARMv8 Mode » Raspberry Pi Geek](https://www.raspberry-pi-geek.com/Archive/2017/23/Operating-the-Raspberry-Pi-3-in-64-bit-mode)

## references

[ARM vs. Harvard vs. von Neumann](https://www.reddit.com/r/AskElectronics/comments/1dchu7/arm_vs_harvard_vs_von_neumann/)
[GENERAL: Harvard vs von Neumann Architectures](https://developer.arm.com/documentation/ka002816/latest/)
[How to explain the harvard architecture of ARM processor at instruction level?](https://community.arm.com/support-forums/f/architectures-and-processors-forum/8615/how-to-explain-the-harvard-architecture-of-arm-processor-at-instruction-level)
