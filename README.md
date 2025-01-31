# CH32V003-drives-ST7735-SPI-LCD-RISCV-ASSEMBLY-CODE-without-library
Assembly code to drive ST7735 LCD with CH32V003 chip. Used GCC compiler to assemblle the code.
with current version can draw rectangle , filled rectangle , default font 16x32 , can double to 32x64
on the fly,horizontal line, vertical line , fill screen with colour of choice,clear screen.
commands to assemble code
riscv32-unknown-elf-as -g test1_ver3.S -o test1_ver3.O                                  # assemble
riscv32-unknown-elf-objcopy -O ihex a.out test1_ver3.hex                                # create elf
riscv32-unknown-elf-ld -T CH32V003.ld -Map=final.map test1_ver3.O                       # convert elf to hex
connections
#CS  = PC1
#DC  = PC2
#CLK = PC5
#MOSI= PC6
#BL  = direct 3.3v

UART TX & RX is on PD5 & PD6

![image](https://github.com/sahasradal/CH32V003-drives-ST7735-SPI-LCD-RISCV-ASSEMBLY-CODE-without-library/assets/36818909/fe7e39b9-a151-47a3-81c6-c11967956933)
