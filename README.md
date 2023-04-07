# FreeRTOS-AFTx
FreeRTOS port for AFTx

To build, run make.
The build folder contains the kernel RTOSDemo.axf

To run an example, please use the qemu-system-riscv32 AFTx06 image that is present in asicfab(Socet33).
The command is riscv-qemu/riscv32-softmmu/qemu-system-riscv32 -M aftx06 
-nographic -d in_asm -singlestep 
-bios build/RTOSDemo.axf

FreeRTOS RTL Simulator run:

RTOSDemo.axf compiled to meminit.bin and SOC_ROM.sv created.

RTL simulator runs through bootloader, and xTaskCreateStatic and most of prvInitialiseNewTask.

Currently, stuck at prvInitialiseNewTask's memset in an infinite loop. Need to check #define macros for task notifications
