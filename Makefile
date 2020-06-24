TARGET=libtinyusb.a
CC=arm-none-eabi-gcc
AR=arm-none-eabi-ar

TOP          = ..
FREERTOS_DIR = $(TOP)/freertos
LIB_DIR      = $(TOP)/libraries
HAL_DIR      = $(LIB_DIR)/STM32F4xx_HAL_Driver
CMSIS_DIR    = $(LIB_DIR)/CMSIS

INCDIR = . \
         src \
         $(TOP)/include/config \
         $(FREERTOS_DIR)/FreeRTOS/Source/include \
         $(FREERTOS_DIR)/FreeRTOS/Source/portable/GCC/ARM_CM4F \
         $(LIB_DIR) \
         $(HAL_DIR)/Inc \
         $(CMSIS_DIR)/Include \
         $(CMSIS_DIR)/Device/ST/STM32F4xx/Include

OBJDIR=obj

MCU=cortex-m4
DEVICE=STM32F401xC

###########################################

vpath %.c src

CDEFS = -DCFG_TUSB_MCU=OPT_MCU_STM32F4

CFLAGS  = -mcpu=$(MCU) -mlittle-endian  -mthumb -march=armv7e-m -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS += -g -O2 -Wall -D$(DEVICE) -DUSE_HAL_DRIVER -fstack-usage
CFLAGS += -ffreestanding -nostdlib -ffunction-sections -fdata-sections -Wl,--gc-sections
CFLAGS  += $(patsubst %,-I%, $(INCDIR))
CFLAGS += $(CDEFS)

SRCS = portable/st/synopsys/dcd_synopsys.c \
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
