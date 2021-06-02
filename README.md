# FreeRTOS-AFTx
FreeRTOS port for AFTx

To build, run make.
The build folder contains the kernel RTOSDemo.axf

To run an example, please use the qemu-system-riscv32 AFTx06 image that is present in asicfab(Socet33)
riscv-qemu/riscv32-softmmu/qemu-system-riscv32 -M aftx06 
-nographic -d in_asm -singlestep 
-bios build/RTOSDemo.axf
