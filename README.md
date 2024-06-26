![Static Badge](https://img.shields.io/badge/MCU-STM32-green "MCU:STM32")
![Static Badge](https://img.shields.io/badge/DAC-MCP4822-green "DAC:MCP4822")

# STM32_MCP4822 #

Some simple STM32 programs to explore analog output via the Microchip
MCP4822 dual 12-bit DAC.

The programs are in C and may be compiled with 'arm-none-eabi-gcc'
on Linux.
They generate ELF and BIN output files which are suitable to program
into STM32 chips for testing purposes.

The 'Makefile' also has targets for the STM32 programming tool 'stlink'.

## Chips Supported ##

At present, there's only support for the STM32F411 on the Black Pill
development board.
The main reason for this choice of chip is that I have dev boards
for those chips that I can use for testing.
Also, the STM32F411 has a hardware floating-point unit (FPU) which may
prove to be useful for these programs.

## ARM Toolchain ##

The programs have been compiled, linked and tested using a Linux version
of the 'arm-none-eabi-gcc' toolchain.
This can be installed directly or as part of the Arduino IDE.

The compiler, linker, and programmers are invoked from the Makefile in
the usual way.
Various parameters in the Makefile may be altered to suit the development
setup, e.g. the type of programmers used and the ports that they connect to.
The full pathname to the toolchain is also configured in the Makefile.

Special targets in the Makefile are provided to invoke the programming
device(s) and write the BIN files into the Flash memory in the chips.
These targets are called 'prog' and 'progdds'.

There's a Makefile target called 'clean' that deletes the object code files
and the ELF and BIN binary files.
It leaves the source code files untouched, of course.

## STM32 Programmers ##

I have tested the code with an 'ST-LINK V2' programmer.

## Test Setup ##

Blinking LEDs, of course!
The LED should blink at 1Hz (500ms on, 500ms off).
This frequency may be measured as a means of verifying correct
clocking of the STM32 chip.

On the STM32F411, a 500Hz square wave should be generated on pin PC14.
There's also a scope sync or trigger pulse on PB12 that is in phase with the
signal generated by the DDS.
<!--- The chip also generates a timing test pulse on PC2
(HIGH during the DDS ISR, LOW otherwise). --->
PC13 is the 1Hz LED.

Analog signals are read via ADC1 on ADC1\_IN1 and ADC1\_IN8.
More ADC inputs to be added later.

The serial port(s) should transmit a message at 9600 baud.

Serial input is accepted on UART0.
<!--- All the chips accept a letter 'r' to print the reset reason and
'~' to invoke a software reset.
The ATtiny1616 and ATmega4809 also accept 'i' to print the chip ID
bytes, 'n' to print the unique serial number and 'f' to print the
values of the fuse registers. --->

To select different waveforms, the chips accept 's' for a sinewave,
'q' for a squarewave, 't' for a triangle wave, and 'w' for a sawtooth.
This may change to become voltage-controlled in a future version.

## Future Enhancements ##

* Implement external op-amp connected to MCP4822
* Implement active low-pass filter on MCP4822 output
* Make waveform selection voltage-controlled
* Add more waveforms
* Store waveforms in Flash memory
* Add more control voltage (CV) analog inputs
* Test with other ARM chips (e.g. STM32F103 on Blue Pill)

