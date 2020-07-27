TARGET=libtinyusb.a
CC=arm-none-eabi-gcc
AR=arm-none-eabi-ar

TOP          = ..
LIB_DIR      = $(TOP)/libraries
HAL_DIR      = $(LIB_DIR)/STM32L0xx_HAL_Driver
CMSIS_DIR    = $(LIB_DIR)/CMSIS

INCDIR = . \
         src \
         $(TOP)/include/config \
         $(LIB_DIR) \
         $(HAL_DIR)/inc \
         $(CMSIS_DIR)/Include \
         $(CMSIS_DIR)/Device/ST/STM32L0xx/Include

OBJDIR=obj

MCU=cortex-m0plus
DEVICE=STM32L082xx

###########################################

vpath %.c src

CDEFS = -DCFG_TUSB_MCU=OPT_MCU_STM32L0

CFLAGS  = -mlittle-endian -mthumb -mcpu=$(MCU) -march=armv6s-m
CFLAGS += -g -O2 -Wall -D$(DEVICE) -DUSE_HAL_DRIVER -fstack-usage
CFLAGS += -ffreestanding -nostdlib -ffunction-sections -fdata-sections -Wl,--gc-sections
CFLAGS  += $(patsubst %,-I%, $(INCDIR))
CFLAGS += $(CDEFS)

SRCS = portable/st/stm32_fsdev/dcd_stm32_fsdev.c \
       device/usbd.c \
       device/usbd_control.c \
       class/cdc/cdc_device.c \
       class/midi/midi_device.c \
       class/hid/hid_device.c \
       class/usbtmc/usbtmc_device.c \
       class/vendor/vendor_device.c \
       class/msc/msc_device.c \
       tusb.c \
       common/tusb_fifo.c

OBJS = $(addprefix $(OBJDIR)/, $(SRCS:.c=.o))

.PHONY: all

all: init $(TARGET)

init:
	@if [ ! -d "obj/" ]; then mkdir obj; fi
	@$(foreach DIR,$(sort $(dir $(SRCS))), if [ ! -e $(OBJDIR)/$(DIR) ]; \
		then mkdir -p $(OBJDIR)/$(DIR); fi; )

$(OBJDIR)/%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $^

$(TARGET): $(OBJS)
	$(AR) -r $@ $(OBJS)

clean:
	rm -rf obj/* $(TARGET)
