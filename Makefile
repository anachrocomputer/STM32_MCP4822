# Makefile for bare-metal STM32F411 driving SPI colour OLED display and SPI DAC

# We'll pick up the GCC toolchain from the Arduino installation
ifeq ($(OS),Windows_NT)
ARDUINO=/Users/John.Honniball/AppData/Local/Arduino15
else
ARDUINO=/home/john/.arduino15
endif

# We need CMSIS from the ST repo STM32CubeF4, which is installed locally
CMSISDIR=../STM32CubeF4/Drivers/CMSIS

# ST-LINK is the Open Source tool used to program the STM32
ifeq ($(OS),Windows_NT)
STLINK_TOOLS=/Users/John.Honniball/Documents/bin/stlink-1.7.0-x86_64-w64-mingw32/bin
else
STLINK_TOOLS=/home/john/Arduino/hardware/Arduino_STM32/tools/linux/stlink
endif

MCU=cortex-m4
STM32MCU=STM32F411xE

ARM_TOOLS=$(ARDUINO)/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1/bin

CC=$(ARM_TOOLS)/arm-none-eabi-gcc
LD=$(ARM_TOOLS)/arm-none-eabi-gcc
OC=$(ARM_TOOLS)/arm-none-eabi-objcopy
SZ=$(ARM_TOOLS)/arm-none-eabi-size

STINFO=$(STLINK_TOOLS)/st-info
STFLASH=$(STLINK_TOOLS)/st-flash

LDSCRIPT=../STM32CubeF4/Projects/STM32F411RE-Nucleo/Examples/HAL/HAL_TimeBase_TIM/SW4STM32/STM32F4xx-Nucleo/STM32F411CEUx_FLASH.ld
STARTUP=$(CMSISDIR)/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s
SYSTEM=$(CMSISDIR)/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c

CFLAGS=-Wall -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -c -o $@ -Os -D$(STM32MCU) -I$(CMSISDIR)/Device/ST/STM32F4xx/Include -I$(CMSISDIR)/Include
LDFLAGS=-mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 --specs=nosys.specs -o $@ -T$(LDSCRIPT)
OCFLAGS=-R .stack -O binary
SZFLAGS=-B -d
INFOFLAGS=--descr

OBJS=spi_oled_dac.o ArmDds.o
ELFS=$(OBJS:.o=.elf)
BINS=$(OBJS:.o=.bin)

# Default target will compile and link all C sources, but not program anything
all: $(BINS)
.PHONY: all

spi_oled_dac.bin: spi_oled_dac.elf
	$(OC) $(OCFLAGS) spi_oled_dac.elf spi_oled_dac.bin

spi_oled_dac.elf: spi_oled_dac.o startup_stm32f411xe.o system_stm32f4xx.o
	$(LD) -mcpu=$(MCU) $(LDFLAGS) startup_stm32f411xe.o system_stm32f4xx.o spi_oled_dac.o
	$(SZ) $(SZFLAGS) spi_oled_dac.elf

spi_oled_dac.o: spi_oled_dac.c
	$(CC) -mcpu=$(MCU) $(CFLAGS) spi_oled_dac.c

ArmDds.bin: ArmDds.elf
	$(OC) $(OCFLAGS) ArmDds.elf ArmDds.bin

ArmDds.elf: ArmDds.o startup_stm32f411xe.o system_stm32f4xx.o
	$(LD) -mcpu=$(MCU) $(LDFLAGS) startup_stm32f411xe.o system_stm32f4xx.o ArmDds.o
	$(SZ) $(SZFLAGS) ArmDds.elf

ArmDds.o: ArmDds.c
	$(CC) -mcpu=$(MCU) $(CFLAGS) ArmDds.c

system_stm32f4xx.o: $(SYSTEM)
	$(CC) -mcpu=$(MCU) $(CFLAGS) $(SYSTEM)

startup_stm32f411xe.o: $(STARTUP)
	$(CC) -mcpu=$(MCU) $(CFLAGS) $(STARTUP)

# Target to invoke the programmer and program the flash memory of the MCU
prog: spi_oled_dac.bin
	$(STFLASH) write spi_oled_dac.bin 0x8000000

progdds: ArmDds.bin
	$(STFLASH) write ArmDds.bin 0x8000000

.PHONY: prog progdds

# Target 'teststlink' will connect to the programmer and read the
# device ID, but not program it
teststlink:
	$(STINFO) $(INFOFLAGS)

.PHONY: teststlink

# Target 'clean' will delete all object files, ELF files, and BIN files
clean:
	-rm -f $(OBJS) $(ELFS) $(BINS) startup_stm32f411xe.o system_stm32f4xx.o

.PHONY: clean


