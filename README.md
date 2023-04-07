# FreeRTOS-AFTx
FreeRTOS port for AFTx

To build, run make.
The build folder contains the kernel RTOSDemo.axf

To run an example, please use the qemu-system-riscv32 AFTx06 image that is present in asicfab(Socet33).
The command is riscv-qemu/riscv32-softmmu/qemu-system-riscv32 -M aftx06 
-nographic -d in_asm -singlestep 
-bios build/RTOSDemo.axf

Introduction

Real-Time Operating Systems are comprised of a task scheduler with prioritized preemptive scheduling that guarantees a hard-limit on when a task is bound to complete. This gives embedded systems determinism and an upper bound on timing constraints. They support the bare minimum for task switching and inter-task communication while being lightweight. They are used in embedded systems for time-critical applications where a bare-metal implementation using Interrupt-Driven programming would be time-consuming to develop and a full-featured kernel such as Linux would be overkill due to resource constraints such as the lack of a memory-management unit or sufficient RAM size.

A fun fact about RTOSs is that many catastrophic system failures can be traced back to RTOSs

https://www.rapitasystems.com/blog/what-really-happened-software-mars-pathfinder-spacecraft (VxWorks RTOS failure in Mars rover), 

https://www.securityweek.com/critical-industries-risk-eleven-zero-day-flaws-real-time-operating-system

https://militaryembedded.com/cyber/cybersecurity/securing-connected-embedded-devices-using-built-in-rtos-security

FreeRTOS is a popular RTOS framework.

https://www.freertos.org/Documentation/RTOS_book.html

https://www.aosabook.org/en/freertos.html

https://docs.aws.amazon.com/freertos/latest/userguide/dev-guide-freertos-kernel.html

https://www.freertos.org/porting-a-freertos-demo-to-different-hardware.html

Existing resources

A RISC-V port has already been done with privileged specification 1.7 for the UCB-Spike simulator and is available here. https://github.com/illustris/FreeRTOS-RISCV

Going through the above link, it can be seen that all the __asm__ instructions are supported by AFTx06 RISC-V core except the syscall (scall) privileged instruction (scall has been changed to ecall in the latest priv spec).

The scall instruction is called only when dealing with libc functions like printf, scanf, malloc, and network related functions as can be seen in the above link. 

Syscalls are required for IO related operations and memory management (heap) as they invoke the kernel to interact with hardware such as a UART port or display driver and assign heap chunks (e.g. brk syscall in linux).

At the moment, the initial port for AFTx will not support these functions.

FreeRTOS does not use system calls to switch tasks in "M" mode and to perform other scheduling functions. It only requires it in the scheduler if one is implementing user space and kernel space (for memory protection) which would cause a ecall or eret trap to either of the spaces.

It disables interrupts (makes atomic) by clearing the appropriate bits in the mstatus register (MIE bit) to create CRITICAL_ENTER() and CRITICAL_EXIT() functions

Since AFTx06 supports only one mode (Machine mode) it should follow these guidelines  

    To yield from a task (that is, to exit a task and let another proceed), portYIELD() should be modified by removing the "ecall" instruction (which is used when there is User Mode) and replacing it with asm code that renables interrupts and does a context switch by saving and then running vTaskSwitchContext and then restoring the context.
    The atomic/critical sections should be specified by disabling and enabling the interrupt controller before and after the atomic section.

    #define portENABLE_INTERRUPTS() __asm volatile ( "csrs mstatus,8" )

    #define portDISABLE_INTERRUPTS() __asm volatile ( "csrc mstatus,8" )
    Software interrupts have been disabled and instead only timer interrupts are used to switch tasks
    All interrupts enter the trap_entry function due to mtvec being set to point here. The interrupt is checked and jumps to TIMER_CMP_INT section.

At the moment since AFTx06 does not have an MMU (Memory-Management Unit) which includes TLB and Virtual Memory and since the SRAM size is limited, a static RTOS Object allocation model is chosen for the initial port. 

#define configSUPPORT_STATIC_ALLOCATION 1 #define configSUPPORT_DYNAMIC_ALLOCATION 0 in FreeRTOSConfig.h

All Create functions in main.c should be suffixed with Static.

Below is the link to allocating RTOS Objects at Compile time/Statically. The advantage to this is that it gives us the memory footprint at Link time. The only disadvantage is that dynamic malloc calls cannot be used.

https://www.freertos.org/a00110.html?_ga=2.152495417.1446366951.1613024492-1800443847.1611346809 (Required to add the two functions to static implementation)

https://www.freertos.org/Static_Vs_Dynamic_Memory_Allocation.html  Example: https://www.freertos.org/xQueueCreateStatic.html and https://www.freertos.org/xTaskCreateStatic.html

List of files of importance

Every port of the FreeRTOS kernel comprises of these files which are mandatory - list.c, queue.c, tasks.c and port.c, start.S, portASM.S, main.c/demo.c(for demonstration purpose where main is entry point)

list.c

list.c comprises of all the routines and data structures required to manage a list data structure to create a ready list object.

FreeRTOS uses a "ready list" (pxReadyTasksLists) to keep track of all tasks that are currently ready to run. It implements the ready list as an array of task lists.

queue.c

queue.c is the data structure implementation of queues for inter-task communications and task synchronization. It has both a head and tail pointer.

tasks.c

tasks.c comprises of the Task-Control Block (TCB) that is present in the stack along with the task itself for task management. It also implements a state machine for the task (running, ready to run, suspended, or blocked).

port.c

port.c is the file that changes across architectures and BSP (Board-Support Package).

portmacro.h declares all of the hardware-specific functions, while port.c and portasm.s contain all of the actual hardware-dependent code.

start.S

One-stage bootloader that calls main function

Created for AFTx using help from RISCVBusiness/verification/asm-env/selfasm/riscv_test.h

portASM.S

Links to port.c and includes all board specific initialization functions such as how to yield from a task (based on whether there is only M mode or M and U mode) and

how to save and restore context (stack and registers).

FreeRTOSConfig.h

This is where the timing parameters, the addresses of the interrupt controllers and other board specific #defines are made.

Current Implementation

Initial port includes only scheduler related files that are required to demonstrate basic task switches and inter-task communication and does not include driver support



FreeRTOS RTL Simulator run:

RTOSDemo.axf compiled to meminit.bin and SOC_ROM.sv created.

RTL simulator runs through bootloader, and xTaskCreateStatic and most of prvInitialiseNewTask.

Currently, stuck at prvInitialiseNewTask's memset in an infinite loop. Need to check #define macros for task notifications

![Screenshot](https://github.com/prakasr1208/FreeRTOS-AFTx-fork/2022-02-02 210239.png)
![Screenshot](https://github.com/prakasr1208/FreeRTOS-AFTx-fork/csrrtos.png)
![Screenshot](https://github.com/prakasr1208/FreeRTOS-AFTx-fork/memsetrtos.png)
![Screenshot](https://github.com/prakasr1208/FreeRTOS-AFTx-fork/frertosboot.png)
![Screenshot](https://github.com/prakasr1208/FreeRTOS-AFTx-fork/screenshot.png)
![Screenshot](https://github.com/prakasr1208/FreeRTOS-AFTx-fork/screenshot.png)

