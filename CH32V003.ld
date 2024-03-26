ENTRY(start)
MEMORY
{
    rom (rx) : ORIGIN = 0x00000000, LENGTH = 16k
    ram (xrw) : ORIGIN = 0x20000000, LENGTH = 2k
}
SECTIONS
{
    .text : { *(.text*) } > rom
    .rodata : { *(.rodata*) } > rom
    .bss : { *(.bss*) } > ram
}

