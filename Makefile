CROSS   = /mnt/c/Users/Danie/Documents/Purdue_Coursework/Fall_2021/SoCET_VIP/RTOS/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-
CC      = $(CROSS)gcc
OBJCOPY = $(CROSS)objcopy
ARCH    = $(CROSS)ar

BUILD_DIR       = build
MARCH = -march=rv32imc
MABI = -mabi=ilp32
CPPFLAGS = \
	-I .  \
	-I ./Source/ \
	-I ./Source/include
CFLAGS  =  $(MARCH) $(MABI) -static -fvisibility=hidden -nostdlib -nostartfiles -mcmodel=medany \
	-Wall \
	-fmessage-length=0 \
	-ffunction-sections \
	-fdata-sections \
	-fno-builtin-printf \
	-lgcc
ASFLAGS = -mcmodel=medany $(MARCH) $(MABI)
LDFLAGS = -nostartfiles -Tfake_rom.lds \
	-Xlinker --gc-sections \
	-Xlinker --defsym=__stack_size=300 \
	$(MARCH) $(MABI)

#ifeq ($(DEBUG), 1)
    #CFLAGS += -Og -ggdb3
#else
    CFLAGS += -Os
#endif

SRCS = main.c \
        syscalls.c \
	./Source/list.c \
	./Source/queue.c \
	./Source/tasks.c \
	./Source/timers.c \
	./Source/port.c

ASMS = boot.S \
	./Source/portasm.S

OBJS = $(SRCS:%.c=$(BUILD_DIR)/%.o) $(ASMS:%.S=$(BUILD_DIR)/%.o)
DEPS = $(SRCS:%.c=$(BUILD_DIR)/%.d) $(ASMS:%.S=$(BUILD_DIR)/%.d)

$(BUILD_DIR)/RTOSDemo.axf: $(OBJS) fake_rom.lds Makefile
	$(CC) $(LDFLAGS) $(OBJS) -o $@

$(BUILD_DIR)/%.o: %.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/%.o: %.S Makefile
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(ASFLAGS) -MMD -MP -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

-include $(DEPS)
