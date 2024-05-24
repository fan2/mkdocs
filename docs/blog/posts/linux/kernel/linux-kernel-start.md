---
title: Linux Kernel Start Routine
authors:
  - xman
date:
    created: 2019-11-14T10:00:00
categories:
    - linux
    - resource
comments: true
---

The Linux booting process involves multiple stages and is in many ways similar to the BSD and other Unix-style boot processes, from which it derives. Although the Linux booting process depends very much on the computer architecture, those architectures share similar stages and software components, including system startup, bootloader execution, loading and startup of a Linux kernel image, and execution of various startup scripts and daemons. Those are grouped into 4 steps: system startup, bootloader stage, kernel stage, and init process.

There are many debts waiting to be paid. Lots of work waiting to be done. At the moment I am just collecting some reference material for future study.

<!-- more -->

[Booting process of Linux](https://en.wikipedia.org/wiki/Booting_process_of_Linux)

- [Booting ARM Linux](https://docs.kernel.org/arch/arm/booting.html)
- [Booting AArch64 Linux](https://docs.kernel.org/arch/arm64/booting.html)
- [ARM64 Kernel Booting Process](https://community.nxp.com/pwmxy87654/attachments/pwmxy87654/imx-processors%40tkb/5659/2/How%20to%20boot%20the%20kernel.pdf)

[Linux内核启动流程-基于ARM64](https://mshrimp.github.io/2020/04/19/Linux%E5%86%85%E6%A0%B8%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B-%E5%9F%BA%E4%BA%8EARM64/)
[Linux内核启动流程（一）head.S分析](https://blog.csdn.net/u014001096/article/details/131342636)
[arm64架构linux内核地址转换__pa(x)与__va(x)分析](https://www.cnblogs.com/liuhailong0112/p/14465697.html)

[Linux 内核内存初始化](https://zhuanlan.zhihu.com/p/645314088)
[Linux 内存初始化-启动阶段的内存初始化](https://zhuanlan.zhihu.com/p/619480064)

[内存映射第一步：idmap & swapper](https://blog.csdn.net/xiaoqiaoq0/article/details/107967119)
[arm64关于idmap和swapper mapping的理解](https://blog.csdn.net/qq_30025621/article/details/89388622)

蜗窝科技：

- [内存初始化（上）](http://www.wowotech.net/memory_management/mm-init-1.html)
- 内存初始化代码分析：[（一）](http://www.wowotech.net/memory_management/__create_page_tables_code_analysis.html)，[（二）](http://www.wowotech.net/memory_management/memory-layout.html)，[（三）](http://www.wowotech.net/memory_management/mem_init_3.html)
- [ARM64 Kernel Image Mapping的变化](http://www.wowotech.net/memory_management/436.html)

[Linux ARM64 KASLR Implementation(1): Kernel Image Randomization](https://rhythm16.github.io/kaslr_en/) - [zh-tw](https://rhythm16.github.io/kaslr/)
[Linux ARM64 KASLR Implementation(2): Linear Mapping Randomization](https://rhythm16.github.io/kaslr2_en/) - [zh-tw](https://rhythm16.github.io/kaslr2/)

!!! quote "Nourishing the Lord of Life"

    Daoism -> Zhuangzi : [Nourishing the Lord of Life](https://ctext.org/zhuangzi/nourishing-the-lord-of-life/)

    There is a limit to our life, but to knowledge there is no limit. With what is limited to pursue after what is unlimited is a perilous thing; and when, knowing this, we still seek the increase of our knowledge, the peril cannot be averted.
