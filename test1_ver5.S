SRAM_start = 0x20000000
SRAM_end   = 0x20000800	
STACK = 0x20000800
fclk = 24000000   			# 24Mhz RCO internal 
.equ R32_RCC_APB2PCENR, 0x40021018
.equ R32_GPIOC_CFGLR, 0x40011000
.equ R32_GPIOD_CFGLR, 0x40011400
.equ R32_GPIOD_OUTDR, 0x4001140C
.equ R32_USART_BRR, 0x40013808
.equ R32_USART_CTLR1, 0x4001380C
.equ R32_RCC_APB1PRSTR, 0x40021010 
.equ R16_SPI_CTLR1, 0x40013000
.equ R16_SPI_CTLR2, 0x40013004
.equ R16_SPI_CTLR1, 0x40013000
.equ R32_USART_STATR, 0x40013800
.equ R32_USART_DATAR, 0x40013804
.equ R16_SPI_STATR, 0x40013008
.equ R16_SPI_DATAR, 0x4001300C
.equ R32_GPIOC_BSHR, 0x40011010 

#ST7735 1.8inch 128 x 160 LCD
.equ COLOR_BLACK , 0x0000
.equ COLOR_WHITE , 0xffff
.equ COLOR_RED ,0xf800
.equ COLOR_GREEN, 0x07e0
.equ COLOR_BLUE , 0x001f
.equ COLOR_MAGENTA, 0xf81f
.equ COLOR_CYAN , 0xffe0
.equ COLOR_YELLOW, 0x07ff
.equ ST7735_NOP , 0x00
.equ ST7735_SWRESET, 0x01
.equ ST7735_RDDID  , 0x04
.equ ST7735_RDDST   , 0x09
.equ ST7735_SLPIN ,  0x10
.equ ST7735_SLPOUT,  0x11
.equ ST7735_PTLON  , 0x12
.equ ST7735_NORON   , 0x13

.equ ST7735_INVOFF,0x20
.equ ST7735_INVON  , 0x21
.equ ST7735_DISPOFF , 0x28
.equ ST7735_DISPON , 0x29
.equ ST7735_CASET , 0x2A
.equ ST7735_RASET  , 0x2B
.equ ST7735_RAMWR , 0x2C
.equ ST7735_RAMRD , 0x2E

.equ ST7735_PTLAR, 0x30
.equ ST7735_COLMOD, 0x3A
.equ ST7735_MADCTL, 0x36

.equ ST7735_FRMCTR1, 0xB1
.equ ST7735_FRMCTR2, 0xB2
.equ ST7735_FRMCTR3, 0xB3
.equ ST7735_INVCTR , 0xB4
.equ ST7735_DISSET5, 0xB6

.equ ST7735_PWCTR1, 0xC0
.equ ST7735_PWCTR2, 0xC1
.equ ST7735_PWCTR3, 0xC2
.equ ST7735_PWCTR4, 0xC3
.equ ST7735_PWCTR5, 0xC4
.equ ST7735_VMCTR1, 0xC5

.equ ST7735_RDID1 ,   0xDA
.equ ST7735_RDID2,    0xDB
.equ ST7735_RDID3,    0xDC
.equ ST7735_RDID4,    0xDD

.equ ST7735_PWCTR6, 0xFC

.equ ST7735_GMCTRP1,  0xE0
.equ ST7735_GMCTRN1,  0xE1
.equ DC_COMMAND,   0
.equ DC_DATA,      0x40

.equ Rotat_UP, 0x00
.equ Rotat_LEFT, 0xa0	  
.equ Rotat_RIGHT, 0x60
.equ Rotat_DOWN, 0xc0 
.equ width,  128
.equ height, 160
.equ MADCTL_MY,  0x80
.equ MADCTL_MX,   0x40
.equ MADCTL_MV,   0x20
.equ MADCTL_ML,   0x10
.equ MADCTL_RGB, 0x00
.equ MADCTL_BGR, 0x08
.equ MADCTL_MH,  0x04

########
# Default mapping (NSS/PC1, CK/PC5, MISO/PC7, MOSI/PC6).Push-pull multiplexed output for full duplex master mode, hardware NSS
# MSB first ,CPL0,CHPA1,full duplex,hardware SS control
###########################
# CH32V003 PIN OUT 
###########################
#CS  = PC1
#DC  = PC2
#CLK = PC5
#MOSI= PC6
#BL  = PC3
#########################################   VARIABLES
fclk 		= 24000000   		# 24Mhz RCO internal , AHB =8Mhz by default
state 		= 0x2000000C 		# located in SRAM
result1 	= 0x20000010 		# 0x20000010 to 0x20000018 is used for storing result in decimal format
result2 	= 0x20000014
fraction 	= 0x20000018
fraction2  	= 0x2000001C
result_lo 	= 0x20000020
result_hi 	= 0x20000024
modulo 		= 0x20000028
scratch 	= 0x2000002C
XYC 		= 0x20000030
XYCOLOUR 	= 0x20000034
dividend 	= 0x20000038 
divisor 	= 0x2000003C
scratchpad 	= 0x20000040
mem 		= 0x20000044
FONTCOLOR       = 0x20000058		#b3b2 = font colour, b1b0 = background color
counter		= 0x2000005C
counter1        = 0x20000060
buffer1		= 0x20000064
buffer2		= 0x20000068


.macro push val
  addi sp, sp, -4
  sw \val, 0(sp)
.endm

.macro pop val
  lw \val, 0(sp)
  addi sp, sp, 4
.endm

.macro fontcolor val
  la x10,FONTCOLOR
  addi x10,x10,2
  li x7, \val
  sh x7,0(x10)	
.endm

.macro bgcolor val
  la x10,FONTCOLOR
  li x7, \val
  sh x7,0(x10)
.endm

.macro PRINT val
  li x15,\val
  call select_font
  call DRAW_CHAR32
.endm



.macro FILLSCREEN val
  li x15,\val
  call FILL_SCREEN
.endm

.macro SETCURSOR x y x1 y1 
  la x10,XYC
  li x15,\x
  sb x15,0(x10)
  addi x10,x10,1
  li x15,\x1
  sb x15,0(x10)
  addi x10,x10,1
  li x15,\y
  sb x15,0(x10)
  addi x10,x10,1
  li x15,\y1
  sb x15,0(x10)
  call setTFTwindow
.endm

.macro drawHline x y x1 colour
  la x10,XYC
  li x15,\x
  sb x15,0(x10)
  addi x10,x10,1
  li x15,\x1
  sb x15,0(x10)
  addi x10,x10,1
  li x15,\y
  sb x15,0(x10)
  addi x10,x10,1
  li x15,\y
  sb x15,0(x10)
  call setTFTwindow
  la x10,XYCOLOUR		# point x11 to XYCOLOUR variable
  addi x10,x10,2		# increase  address to byte2 , lo byte of colour
  li x15,\colour		# load colour data supplied ,half word
  sb x15,0(x10)			# store the low byte in XYCOLOUR byte2
  srli x15,x15,8		# shift out low byte from x15 with only high byte remaining
  addi x10,x10,1		# point to byte3 , hi byte of colour in XYCOLOUR
  sb x15,0(x10)			# store hi byte of colour
  call PIXEL_REPEAT1		# call PIXEL_REPEAT1 subroutine to print the pixels as per coordinates supplied in line2
.endm

.macro drawVline x y y1 colour
  la x10,XYC
  li x15,\x
  sb x15,0(x10)
  addi x10,x10,1
  li x15,\x
  sb x15,0(x10)
  addi x10,x10,1
  li x15,\y
  sb x15,0(x10)
  addi x10,x10,1
  li x15,\y1
  sb x15,0(x10)
  call setTFTwindow
  la x10,XYCOLOUR		# point x11 to XYCOLOUR variable
  addi x10,x10,2		# increase  address to byte2 , lo byte of colour
  li x15,\colour		# load colour data supplied ,half word
  sb x15,0(x10)			# store the low byte in XYCOLOUR byte2
  srli x15,x15,8		# shift out low byte from x15 with only high byte remaining
  addi x10,x10,1		# point to byte3 , hi byte of colour in XYCOLOUR
  sb x15,0(x10)			# store hi byte of colour
  call PIXEL_REPEAT1		# call PIXEL_REPEAT1 subroutine to print the pixels as per coordinates supplied in line2
.endm

.macro drawRECTANGLE x y width height colour
  la x10,XYC			# point x10 to variable XYC
  li x15,\x
  sb x15,0(x10)
  addi x10,x10,1		# increase the XYC pointer to byte1
  li x15,\width	
  addi x15,x15,\x
  sb x15,0(x10)			# store width
  li x15,\y
  addi x10,x10,1		# increase pointer to byte2 in XYC
  sb x15,0(x10)			# store start of y
  addi x10,x10,1		# increase pointer to byte3 in XYC
  li x15,\y
  sb x15,0(x10)			# start y is stored in byte3 XYC, y axis =0 , horizontal line drawn
  call setTFTwindow
  la x10,XYCOLOUR		# point x11 to XYCOLOUR variable
  addi x10,x10,2		# increase  address to byte2 , lo byte of colour
  li x15,\colour		# load colour data supplied ,half word
  sb x15,0(x10)			# store the low byte in XYCOLOUR byte2
  srli x15,x15,8		# shift out low byte from x15 with only high byte remaining
  addi x10,x10,1		# point to byte3 , hi byte of colour in XYCOLOUR
  sb x15,0(x10)			# store hi byte of colour
  call PIXEL_REPEAT1		# call PIXEL_REPEAT1 subroutine to print the pixels as per coordinates supplied by macro
  la x10,XYC			# point x10 to variable XYC
  li x15,\x			# load x15 with x0 start
  sb x15,0(x10)			# store in XYC byte0
  addi x10,x10,1		# increase the XYC pointer to byte1
  li x15,\x			# load x15 with x0 start
  sb x15,0(x10)			# store width as x0, no horizontal component line will be vertical from start x,y
  addi x10,x10,1		# point x10 to byte2 of the XYC
  li x15,\x			# load x15 with x0 start
  sb x15,0(x10)			# vertical line starts here fron x,y
  addi x10,x10,1		# increase XYC pointer to byte3 y1(destination height)  
  li x15,\height		# load the height , final value of the vertical line
  addi x15,x15,\y
  sb x15,0(x10)			# store in byte3 of XYC
  call setTFTwindow
  call PIXEL_REPEAT1		# call PIXEL_REPEAT1 subroutine to print the pixels as per coordinates supplied in line2
  la x10,XYC			# point x10 to variable XYC
  li x15,\width			# load x15 with width, we start drawing line from diagonal opposite x,y to complete rectangle
  addi x15,x15,\x
  sb x15,0(x10)			# store in XYC byte0
  addi x10,x10,1		# increase the XYC pointer to byte1
  li x15,\width			# load x15 with width, x0-x1=0 since start and end is width ,  vertical line will be drawn
  addi x15,x15,\x
  sb x15,0(x10)			# store in XYC byte0
  addi x10,x10,1		# increase the XYC pointer to byte2
  li x15,\y			# load x15 with y start		
  sb x15,0(x10)			# store in XYC byte2
  addi x10,x10,1		# point x10 to byte3 of XYC
  li x15,\height		# load x15 with height , final destination pixel of vertical line
  addi x15,x15,\y		
  sb x15,0(x10)			# store in XYC byte3
  call setTFTwindow		#
  call PIXEL_REPEAT1		# call PIXEL_REPEAT1 subroutine to print the pixels as per coordinates supplied by macro  
  la x10,XYC			# point x10 to variable XYC
  li x15,\x			# load x15 with x start, 
  sb x15,0(x10)			# store in XYC byte0
  addi x10,x10,1		# increase the XYC pointer to byte1
  li x15,\width			# load x15 with width, x0-x1= >0 horizontal line will be drawn
  addi x15,x15,\x
  sb x15,0(x10)			# store in XYC byte1
  addi x10,x10,1		# increase the XYC pointer to byte2
  li x15,\height		# load x15 with height , y starts with height diagnoal opposite of x,y
  addi x15,x15,\y		
  sb x15,0(x10)			# store in XYC byte2
  addi x10,x10,1		# point x10 to byte3 of XYC
  li x15,\height		# load x15 with height , height - height = 0 , vertical component 0 , only horizontal line
  addi x15,x15,\y		
  sb x15,0(x10)			# store in XYC byte3
  call setTFTwindow		#
  call PIXEL_REPEAT1		# call PIXEL_REPEAT1 subroutine to print the pixels as per coordinates supplied by macro  
.endm

.macro fillRECTANGLE x y width height colour
  la x10,XYC			# point x10 to XYC
  li x15,\x			# load x15 with start value x
  sb x15,0(x10)			# store x in byte0 of XYC
  addi x10,x10,1		# point X10 to byte1 of XYC
  li x15,\width 		# load width of the rectanglex in x15
  addi x15,x15,\x
  sb x15,0(x10)			# store in byte1 of XYC
  addi x10,x10,1		# point x10 to byte2 of XYC
  li x15,\y			# load start of rectangley in x15
  sb x15,0(x10)			# store in byte2 of XYC
  addi x10,x10,1		# point x10 to byte3 of XYC
  li x15,\height 		# load height of rectangle in x15
  addi x15,x15,\y
  sb x15,0(x10)			# store in byte3 of XYC
  call setTFTwindow		# set rectangle window in LCD with above coordinates
  la x10,XYCOLOUR		# point x11 to XYCOLOUR variable
  addi x10,x10,2		# increase  address to byte2 , lo byte of colour
  li x15,\colour		# load colour data supplied ,half word
  sb x15,0(x10)			# store the low byte in XYCOLOUR byte2
  srli x15,x15,8		# shift out low byte from x15 with only high byte remaining
  addi x10,x10,1		# point to byte3 , hi byte of colour in XYCOLOUR
  sb x15,0(x10)			# store hi byte of colour
  call PIXEL_REPEAT1		# call PIXEL_REPEAT1 subroutine to print the pixels as per coordinates supplied in line2
.endm












#include CH32V003_reg.S
.align 4
.text
.global start
start:
sp_init:
    	la sp, STACK			# initialize stack pointer
		
#Enable GPIO clocks & AFIO in APB2 clock register
        
    	la x10,R32_RCC_APB2PCENR	# load address of APB2PCENR register to x10 ,for enabling GPIO A,D,C peripherals
	lw x11,0(x10)			# load contents from peripheral register R32_RCC_APB2PCENR pointed by x10
	li x7,((1<<2)|(1<<4)|(1<<5)|(1<<0)|(1<<12)|(1<<14))	# 1<<IOPA_EN,1<<IOPC_EN,1<<IOPD_EN,1<<AFIOEN,1<<SPI enable port A,C,D and AFIO functions
	or x11,x11,x7			# or values 
	sw x11,0(x10)			# store modified enable values in R32_RCC_APB2PCENR

#configure GPIO PortC as multiplex push-pull output for SPI
	la x10,R32_GPIOC_CFGLR		# load pointer x10 with address of R32_GPIOC_CFGLR , I2C SDA & SCL is on portC PC1,PC2
	lw x11,0(x10)			# load contents from register pointed by x10
	li x7,~((0xf<<4)|(0xf<<8)|(0xf<<20)|(0xf<<24)|(0xf<<28))	# clear pc1,pc5,pc6,pc7. we need to setup PC1 ,PC5,PC6,PC7 for SPI
	and x11,x11,x7			# clear  mode and cnf bits for selected pin C1,C2
	li x7,((0xB<<4)|(0x3<<8)|(0xB<<20)|(0xB<<24)|(0xB<<28))		# PC1,PC5,PC6,PC7 = multiplex pushpull output 50mhz , 0b1011
	or x11,x11,x7			# OR value to register
	sw x11,0(x10)			# store in R32_GPIOC_CFGLR

#configure GPIO 
	la x10,R32_GPIOD_CFGLR		# load pointer x10 with address of R32_GPIOD_CFGLR , GPIO configuration register
	lw x11,0(x10)			# load contents from register pointed by x10
	li x7,~((0xf<<20)|(0xf<<24)|(0xf<<16))	#clear pd4,pd5,pd6. we need to setup PD5 & PD6 for usart tx and rx and pd4 for led
	and x11,x11,x7			# clear pd4,pd5,pd6 mode and cnf bits for selected pin D4,D5,D6
	li x7,((0x8<<24)|(0xB<<20)|(0x3<<16))	# pd6 = input with PU/PD,pd5= multiplex pushpull output 50mhz,pd4= normal pushpull output 50hz
	or x11,x11,x7			# OR value to register
	sw x11,0(x10)			# store in R32_GPIOD_CFGLR

#enable pull up for input	
	la x10,R32_GPIOD_OUTDR		# enable pullup resistor by setting OUTDR register
	lw x11,0(x10)			# this setting of GPIO_OUTDR for pullup resistor effects if corresonding pin is selected as input
	li x7,(1<<6)			#when PD6 is input with resistor selected 1= pullup and 0 = pulldown
	or x11,x11,x7
	sw x11,0(x0)

#configure USART baud
	la x10,R32_USART_BRR		# USART BAUD setting
	lw x11,0(x10)			# copy R32_USART_BRR to x11
	li x7,((52<<4)|(1<<0))		# 52.1 in BRR =9600
	or x11,x11,x7			# or registers
	sw x11,0(x10)			# store in R32_USART_BRR

#setup UART control and enable	
	la x10,R32_USART_CTLR1		# load x10 with R32_USART_CTLR1 address
	lw x11,0(x10)			# load to x11 contents
	li x7,(1<<13)|(1<<3)|(1<<2)	# enable USART UE, TX,RX bits		# UE 
	or x11,x11,x7
	sw x11,0(x10)			# store back new values

SPI_CONFIG:
	la x10,R32_RCC_APB1PRSTR	# set pointer to clock control  peripheral reset register 
	lw x11,0(x10)			# load contents to x11
	li x7,(1<<12)			# shift 1 to 12th bit position
	or x11,x11,x7			# OR with x11
	sw x11,0(x10)			# set bit 12 of R32_RCC_APB1PRSTR to reset SPI peripheral
	not x7,x7			# invert values in x7
	and x11,x11,x7			# and x11 to write a 0 in 21st bit
	sw x11,0(x10)			# store 0 in 12th bit to restart SPI engine


	la x10,R16_SPI_CTLR1
	lw x11,0(x10)
	li x7,((1<<2)|(1<<3)|(1<<8))	# MSTR,BR(FHCLK /4),SSI
	or x11,x11,x7
	sw x11,0(x10)

	
	la x10,R16_SPI_CTLR2
	lw x11,0(x10)
	li x7,(1<<2)			# SSOE bit
	or x11,x11,x7
	sw x11,0(x10)

	la x10,R16_SPI_CTLR1
	lw x11,0(x10)
	li x7,(1<<6)			# SPE , enable SPI
	or x11,x11,x7
	sw x11,0(x10)


	call ST7735_init		# ST3375 LCD initialization routine


.align 4

#test UART transmission,transmits string SAJEEV SANKARAN CH32V003 UART

	la x10,name			# load address of label "name" to x10, string to be transmitted
string_loop:
	lb x8,0(x10)			# load 1 byte from 0 offset of "name"
	beqz x8,finish			# if byte in x8 null branch to label "finish"
	call USART_TX			# call subroutine USART_TX to transmit byte
	addi x10,x10,1			# increase pointer by 1 byte
	j string_loop			# jump back to label string_loop until null is encountered
finish:
	nop

	li x8,0x0d			# line feed
	call USART_TX			# call uart
	li x8,0x0a			# carriage feed
	call USART_TX			# call uart
####################################################
.align 4
	call CLEAR_SCREEN		# macro clear screen to blackout screen

	FILLSCREEN COLOR_BLUE		# macro FILLSCREEN called with blue colour
	li x6,2000000
	call delay			# approx 1 second delay
	FILLSCREEN COLOR_RED		# macro FILLSCREEN called with red colour
	li x6,2000000
	call delay			# approx 1 second delay
	FILLSCREEN COLOR_GREEN		# macro FILLSCREEN called with green colour
	li x6,2000000
	call delay			# approx 1 second delay
	FILLSCREEN COLOR_MAGENTA	# macro FILLSCREEN called with magenta colour
	li x6,2000000
	call delay			# approx 1 second delay
	FILLSCREEN COLOR_CYAN		# macro FILLSCREEN called with cyan colour
	li x6,2000000
	call delay			# approx 1 second delay
	FILLSCREEN COLOR_YELLOW		# macro FILLSCREEN called with yellow colour
	li x6,2000000
	call delay			# approx 1 second delay

	SETCURSOR 0, 0, 15, 31		# x = 0 ,y =0, x1 =15, y1 =31 ,sets cursor/window in order of x,y,x1,y1 (macro)

	fontcolor COLOR_RED		# stores RED colour for font in FONTCOLOR variable (macro)
	bgcolor COLOR_WHITE		# stores white colour for font background in FONTCOLOR variable (macro)

	PRINT 'Z'			# macro searches and prints an ascii character, call after setting window , font colour
	li x6,2000000
	call delay			# approx 1 second delay

	call push_cursor1		# moves cursor to next legal position on the screen 128x160,new window will be created with off set based on the set window data
	PRINT 'b'			# prints default 16x32 fonts
	li x6,2000000
	call delay			# approx 1 second delay

	SETCURSOR 0, 0, 31, 63		# x = 0 ,y =0, x1 =15, y1 =31
	fontcolor COLOR_MAGENTA		# set font colour magenta (macro)
	bgcolor COLOR_WHITE		# set background colour white(macro)
	li x15,'9'			# char to be enlarged and printed
	call select_font		# subroutine calculates address of font in x15 register and loads it to variable "state"in SRAM
	call DRAW_CHAR_DOUBLE		# subroutine multiplies default 16x32 in this code to 32x64 font
	li x6,2000000
	call delay			# approx 1 second delay

	FILLSCREEN COLOR_WHITE		#
	SETCURSOR 0, 0, 15, 31		# x = 0 ,y =0, x1 =15, y1 =31

					# below loop will print all character in the font table with 1 second delay 16x32 default
	li x15,' '			# laod space in x15 , font array starts with ascii " "
	la x10,mem			# point to variable mem in sram with x10 register
	sb x15,0(x10)			# store byte ' ' in mem
	li x14,0x80			# load 0x80/128 which is total count of ascii characters in the font look up table
loopall:
	call select_font		# call subroutine to locate address of font in x15 and load it in variable state
	call DRAW_CHAR32		# call subroutine to print 16x32 font pointed by the cursor
	call push_cursor1		# move cursor one box ahead for the next char
	li x6,2000000
	call delay			# approx 1 second delay
	la x10,mem			# point to variable mem in sram with x10 register
	lb x15,0(x10)			# reload the already printed char again as x15 is changed while writing char
	addi x15,x15,1			# increase by 1 the ascii value
	sb x15,0(x10)			# store the new char in mem
	bne x15,x14,loopall		# check whether x15 is equal to 0x80 stored in x14

	drawRECTANGLE 10,10,40,50,COLOR_BLACK     # draws a unfilled rectangle with black lines

	fillRECTANGLE 50,50,100,100,COLOR_GREEN	  # draws a filled rectangle in green colour


	call CLEAR_SCREEN	# macro clear screen to blackout screen


	la x10,buffer2
	li x7,0x323214		# byte2 =x,byte1=y,byte0=r ,50,50,20 in hex
	sw x7,0(x10)
	la x10, XYCOLOUR
	li x7,COLOR_WHITE
	slli x7,x7,16
	sw x7,0(x10)
	call fillCircle



	la x10,buffer2
	li x7,0x646419		# byte2 =x,byte1=y,byte0=r ,50,50,20 in hex
	sw x7,0(x10)
	call fillCircle
here:
	j here








.align 4
#########################################################################
#  USART ROUTINES
#########################################################################

USART_TX:
	addi sp,sp,-16			# add space in stack
	sw ra,0(sp)			# push ra
	sw x7,4(sp)			# push x7
	sw x10,8(sp)			# push x10
	sw x11,12(sp)			# push x11

	la x10,R32_USART_STATR		# load address of usart status register
	lw x11,0(x10)			# load contents of status register in x11
	andi x11,x11,(1<<7)		# mask out 7th bit, transmit buffer empty flag
	beqz x11,USART_TX		# if 0 transmit buffer full, wait until bit is set
	#li x8,0x30
	mv x7,x8			# move byte in x8 to x7
	la x10,R32_USART_DATAR		# x10 has the address of data register
	sb x7,0(x10)			#store byte in x7 to data register
TC_check:
	la x10,R32_USART_STATR		# get contents of status register again
	lw x11,0(x10)
	andi x11,x11,(1<<6)		# check transmit complete bit
	beqz x11,TC_check		# wait if bit is 0 , when transmit complete = 1
		
	lw x11,12(sp)			# pop x11
	lw x10,8(sp)			# pop x10
	lw x7,4(sp)			# pop x7
	lw ra,0(sp)			# pop ra
	addi sp,sp,16			# set SP back 16 bytes
	ret				# return to caller	



		
#########################################################################
#######SPI_SUBROUTINES:
#########################################################################
SPI_WRITE:
	addi sp,sp,-12			# move stack pointer 3 words
	sw ra,0(sp)			# push return address
	sw x10,4(sp)			# push x10
	sw x11,8(sp)			# push x11
SPIW_LOOP:
	la x10,R16_SPI_STATR		# set pointer x10 to SPI status register
	lw x11,0(x10)			# copy contents to x11
	andi x11,x11,(1<<1)		# TXE bit , AND x11 with TXE,transmission buffer empty bit mask
	beqz x11,SPIW_LOOP		# if TXE bit not set wait in a tight loop
	la x10,R16_SPI_DATAR		# once TXE bit is set ,point SPI data register with x10
	sw x15,0(x10)			# store data in x15 to SPI data register

	lw x11,8(sp)			# pop x11
	lw x10,4(sp)			# pop x10
	lw ra,0(sp)			# pop return address register
	addi sp,sp,12			# restore stack pointer to old position
	ret				# return to caller
#####################	
SPI_READ:
	addi sp,sp,-12			# move stack pointer 3 words
	sw ra,0(sp)			# push return address
	sw x10,4(sp)			# push x10
	sw x11,8(sp)			# push x11
SPIR_LOOP:
	la x10,R16_SPI_STATR		# set pointer x10 to SPI status register
	lw x11,0(x10)			# copy contents to x11
	andi x11,x11,(1<<0)		# RXNE bit, AND with RXNE bit mask , receive buffer not empty bit mask
	beqz x11,SPIR_LOOP		# if RXNE bit not set wait in a tight loop, wait till data arrive in receive register
	la x10,R16_SPI_DATAR		# x10 points to SPI data register
	lw x15,0(x10)			# load data to x15 from address pointed by x10(SPI data register)

	lw x11,8(sp)			# pop x11
	lw x10,4(sp)			# pop x10
	lw ra,0(sp)			# pop return address register
	addi sp,sp,12			# restore stack pointer to old position
	ret				# return to caller
#######################################################################################################################
# DATA_ON routine to make DC pin PD4 made high to indicate data is being transmitted
#######################################################################################################################
DATA_ON:
	addi sp,sp,-16			# move stack pointer 3 words
	sw ra,0(sp)			# push return address
	sw x10,4(sp)			# push x10
	sw x11,8(sp)			# push x11
	sw x7,12(sp)

	la x10,R32_GPIOC_BSHR		# R32_GPIOD_BSHR register sets and resets GPIOD pins, load address into pointer x10
	lw x11,0(x10)			# load contents to x11
	li x7,(1<<2)			# set pd4 by shifting 1 to bit position 4
	or x11,x11,x7			# OR with x11
	sw x11,0(x10)			# store x11 to R32_GPIOD_BSHR

	lw x7,12(sp)
	lw x11,8(sp)			# pop x11
	lw x10,4(sp)			# pop x10
	lw ra,0(sp)			# pop return address register
	addi sp,sp,16			# restore stack pointer to old position
	ret				# return to caller
##########################################################################################################################
# COMMAND_ON , routine to make DC pin PD4 low to indicate TFT commands are transmitted
##########################################################################################################################
COMMAND_ON:
	addi sp,sp,-16			# move stack pointer 3 words
	sw ra,0(sp)			# push return address
	sw x10,4(sp)			# push x10
	sw x11,8(sp)			# push x11
	sw x7,12(sp)

	la x10,R32_GPIOC_BSHR		# R32_GPIOD_BSHR register sets and resets GPIOD pins, load address into pointer x10
	lw x11,0(x10)			# load contents to x11
	li x7,(1<<18)			# reset pd4 by shifting 1 into bit position 20 of R32_GPIOD_BSHR
	or x11,x11,x7			# OR with x11
	sw x11,0(x10)			# store x11 to R32_GPIOD_BSHR

	lw x7,12(sp)
	lw x11,8(sp)			# pop x11
	lw x10,4(sp)			# pop x10
	lw ra,0(sp)			# pop return address register
	addi sp,sp,16			# restore stack pointer to old position
	ret				# return to caller


####################################################################
# call with value in x6-100000# 50ms,1000000# 500ms,20000# 10ms,
####################################################################

delay:	
	addi sp,sp,-8			# move sp 2 words
	sw ra,0(sp)			# push ra
	sw x6,4(sp)			# push x6
#	li x6,2000000			# load an arbitarary value 20000000 to t1 register		
dloop:
	addi x6,x6,-1			# subtract 1 from t1
	bne x6,zero,dloop		# if t1 not equal to 0 branch to label loop
	lw x6,4(sp)			# pop x6
	lw ra,0(sp)			# pop ra
	addi sp,sp,8			# sp back 2 words
	ret				# return to caller

################################################################################

#####################################################################################
## call PIXEL_REPEAT to fill entire screen with colour stored in upper 2 bytes of 
## XYCOLOUR . 
####################################################################################
PIXEL_REPEAT:
	addi sp,sp,-12			# move stack pointer 3 words
	sw ra,0(sp)			# push return address
	sw x10,4(sp)
	sw x5,8(sp)
	
	li x5,20480			# length ((x1-x0)*(y1-y0)) = total number of pixels to be written
	call setTFTwindow		# 128 x 160 = 20480 pixels
repeat_pixel:
	call TFTpixel			# TFTpixel subroutine transmits colour to one pixel
	addi x5,x5,-1			# The pixel pointer internal to the TFT auto increments after each write and detrmined by the boundaries set by setTFTwindow routine
	bnez x5,repeat_pixel		# If x5 register is not 0 repeat sending colour data to pixels

	lw x5,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)			# pop return address register
	addi sp,sp,12			# restore stack pointer to old position
	ret				# return to caller
###########################################################################	


##########################################################################################################################
#### TFTpixel writes colour data , should be called after calling setTFTwindow and required colour in XYCOLOUR byte3&byte2
############################################################################################################################
TFTpixel:
	addi sp,sp,-8			# move stack pointer 3 words
	sw ra,0(sp)			# push return address
	sw x10,4(sp)
	call DATA_ON			# DC pin PD4 high indicating LCD that data foloows
	li x10,XYCOLOUR			# point to XYCOLOUR which holds colour data in hiher bytes
	addi x10,x10,3			# point to byte3
	lb x15,0(x10)			# load hi byte colour to x15
	addi x10,x10,-1			# move pointer x10 to byte2 of XYCOLOUR
	call SPI_WRITE			# send hi byte of colour in x15 with SPI
	lb x15,0(x10)			# low byte colour
	call SPI_WRITE			# send low byte via spi
	lw x10,4(sp)
	lw ra,0(sp)			# pop return address register
	addi sp,sp,8			# restore stack pointer to old position
	ret				# return to caller
############################################################################
###############################################################################
# routine to clear screen and fill black colour , direct call , no prerequisites
###############################################################################
CLEAR_SCREEN:
	addi sp,sp,-12
	sw ra,0(sp)
	sw x7,4(sp)
	sw x10,8(sp)
	li x7,0xA0008000		# 160 ,0,128,0 screen size in pixels
	la x10,XYC			# load address of XYC to hold coordinates
	sw x7,0(x10)			# store coordinnates in XYC
	la x10,XYCOLOUR			# point x10 to XYCOLOUR
	li x7,COLOR_BLACK		# load black colour in x7
	slli x7,x7,16			# shift lhs 16 steps , loaded values is shifted to high bytes
	sw x7,0(x10)			# store colour values in XYCOLOUR
	call PIXEL_REPEAT		# call PIXEL_REPEAT to write pixels
	lw x10,8(sp)
	lw x7,4(sp)
	lw ra,0(sp)
	addi sp,sp,12
	ret
################################################################################################################
# FILL_SCREEN ,routine to fill screen with desired colour, load colour in x15 to call FILL_SCREEN or use macro
##################################################################################################################
FILL_SCREEN:
	addi sp,sp,-16
	sw ra,0(sp)
	sw x7,4(sp)
	sw x10,8(sp)
	sw x11,12(sp)
	li x7,0xA0008000		# 160 ,0,128,0 screen size in pixels
	la x10,XYC			# point x10 to XYC ,holds pixel coordinates
	sw x7,0(x10)			# store coordinates in XYC
	la x10,XYCOLOUR			# point x10 to XYCOLOUR
#	la x11,FONTCOLOR		# colour
#	lh x7,0(x11)			# byte0 and byte1 holds background colour
#	addi x10,x10,2			# byte2,byte3 holds colour data for PIXEL_WRITE
	slli x15,x15,16			# colour value is loaded in x15 outside this routine, shft 16 left to align with XYCOLOUR
	sw x15,0(x10)			# store colour in XYCOLOUR
	call PIXEL_REPEAT		# call PIXEL_REPEAT to fill colour data in screen
	lw x11,12(sp)
	lw x10,8(sp)
	lw x7,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret

##############################################################################################
###  setTFTwindow sets the area where the colour to be filled , load XYC before calling
#############################################################################################

setTFTwindow:	
	addi sp,sp,-8			# move stack pointer 3 words
	sw ra,0(sp)			# push return address
	sw x10,4(sp)
	li x6 , 2000			# 1ms
	call delay			# ims delay
	call COMMAND_ON			# DC pin pulled low , commands to be transmitted
	li x15,ST7735_CASET		#/* col address command */
	call SPI_WRITE			# transmit command via spi
	li x6 , 2000			# 1ms
	call delay			# 1ms delay for SPI to finish transmission
	call DATA_ON			# pull DC high to transmit data
	li x15,0x00			# D16 to D8 of 1st parameter of column
	call SPI_WRITE			# transmit command via spi
	li x10,XYC			# XYC in sram stores x0,x1,y0,y1 coordinates
	lb x15,0(x10)			# write X0 start of x coordinate to x15 UART loader,D7 to D0 of 1st parameter
	addi x10,x10,1			# increase XYC address by 1 byte
	call SPI_WRITE			# write x0 to LCD
	li x15,0x00			# D16 to D8 of 2nd parameter of column
	call SPI_WRITE			# transmit command via spi
	lb x15,0(x10)			# write X1 end of x coordinate to x15
	addi x10,x10,1			# increase XYC address by 1 byte
	call SPI_WRITE			# write x1 to LCD	
	li x6 , 2000			# 1ms
	call delay

	call COMMAND_ON			# DC pin pulled low , commands to be transmitted
	li x15,ST7735_RASET		#/* Row address command */
	call SPI_WRITE			# transmit command via spi
	li x6 , 2000			# 1ms
	call delay			# 1ms delay
	call DATA_ON			# DC pin pulled hi for data
	li x15,0x00			# hi byte of row is 0 ,
	call SPI_WRITE			# write via SPI
	lb x15,0(x10)			# write Y0 start of x coordinate to x15
	addi x10,x10,1			# increase XYC address by 1 byte
	call SPI_WRITE			# write Y0 to LCD
	li x15,0x00			# hi byte is 0
	call SPI_WRITE			# spi write
	lb x15,0(x10)			# write Y1 end of y coordinate to x15
	call SPI_WRITE			# write Y0 to LCD, x10 not increased as 4 coordinates written
	li x6 , 2000			# 1ms
	call delay			# 1ms delay
	call COMMAND_ON			# pull DC low for command
	li x15,ST7735_RAMWR		# command for LCD RAM access
	call SPI_WRITE			# transmit command via SPI
	li x6 , 2000			# 1ms
	call delay			# call 1ms delay
	lw x10,4(sp)
	lw ra,0(sp)			# pop return address register
	addi sp,sp,8			# restore stack pointer to old position
	ret				# return to caller	

###################################################################################
# RAMWR command Memory range: (0000h, 0000h) -> (007Fh, 09Fh) , 128x160x18-bit memory can be written by this command
###################################################################################	

################################################################################################
# multiplication routine , multiplies a1 and a2 , used in PIXEL_REPEAT1 to calculate total pixels
###################################################################################################
soft_mul:			# 32 bit multiplication subroutine
	addi sp,sp,-32		# adjust stack pointer
	sw ra,0(sp)		# PUSH
	sw a0,4(sp)
	sw a1,8(sp)		# PUSH
	sw a2,12(sp)		# PUSH
	sw a3,16(sp)		# PUSH
	sw a4,20(sp)		# PUSH
	sw a5,24(sp)		# PUSH
	sw t0,28(sp)

#	li a1,0xffffffff 	# multiplicand
#	la t0,modulo		# point t0 to modulo register
#	lw a1,0(t0)		# copy remainder/modulo to a1 , multiplicand
# 	li a2,1000		# multiplier
 	li a3,0x00000000 	# result_lo
 	li a4,0x00000000 	# result_hi
	li a5,0			# working register 
 	beqz a1,load0
 	beqz a2,load0
 
 start1:
 	call ROR		# rotate right multiplier to test lsb is 0 or 1
 	bnez x3,multiply	# if lsb =1 branch to repeated adding of multiplicant to result register
 finishmul:
 	call RLL2		# shift multiplicand left or multiply by 2
 	beqz a2,exit_proc	# if a2 is 0 branch to exit_proc
 	J start1		# repeat loop
load0:
 	li a3,0
 exit_proc:
 	#j exit_proc
	la t0,result_lo		# point t0 to result_lo register
	sw a3,0(t0)		# store result of multiplication( modulo * 1000)
	la t0,result_hi		# point t0 to result_hi register to store carry
	sw a4,0(t0)		# store high byte result of multiplication( modulo * 1000)

	lw t0,28(sp)
	lw a5,24(sp)		# POP
	lw a4,20(sp)		# POP
	lw a3,16(sp)		# POP
	lw a2,12(sp)		# POP
	lw a1,8(sp)		# POP
	lw a0,4(sp)		# POP
	lw ra,0(sp)		# POP
	addi sp,sp,32
 	ret			# return to division routine
 multiply:
 	add a5,a3,a1		# add multiplicant to low result register and store final result in a5 for processing
 	sltu a0,a5,a3		# set a0 to 1 if result of addition a3:a1 i a5 is greater than a3
 	sltu x3,a5,a1		# set x3 to 1 if result of addition a3:a1 in a5 is greater than a1
 	or a0,a0,x3		# or a0 and x3 , if 1 carry if a0 = 0 no carry
 	bnez a0,carryset	# if a0 = 1 carry set, branch to label carry set
 	mv a3,a5		# result in working register copied to a3 low result register
 	J finishmul		# jump to label finishmul
 carryset:			# reach here only if carryset
 	mv a3,a5		# copy a5 to low result a3
 	addi a4,a4,1		# add carry to a4 high register result
 	J finishmul		# jump to label finishmul
 
 ROR:
 	li x3,0			# clear carry
 	mv t0,a2		# copy number in a2 to t0
 	andi t0,t0,1		# extract lsb is 0 or 1
 	beqz t0,zzz		# if lab is 0 branch to zzz
 	li x3,1		# if lsb is 1 carry occured , load 1 in carry register x3
 	srli a2,a2,1		# shift right a2 by 1 postion 
 	ret			# return to caller
 zzz:				# reach here if lsb =0
 	li x3,0			# load x3 0 indicating carry bit is 0
 	srli a2,a2,1		# right shift multiplier once. divide multiplier by 2
 	ret			# return to caller
 
 ROL:
 	li x3,0			# 
 	mv t0,a2
 	li x3,0x80000000
 	and t0,t0,x3
 	beqz t0,zzz1
 	li x3,1			# carry
 	slli a2,a2,1
 	ret
 zzz1:
 	li x3,0
 	slli a2,a2,1
 	ret
 
 RLL2:				# rotate left 2 registers a3:a5
 	mv a5,a4		# copy contents of a4 to a5
 	li x3,0			# clear x3
 	mv t0,a1		# copy multiplicant to t0
 	li x3 ,0x80000000	# load x3 MSB bitmask
 	and t0,t0,x3		# and with 0x800000000 to extract the MSB
 	bnez t0,OR1		# if MSB = 1 branch to OR1 label
 	slli a1,a1,1		# shift left 1 position a1 register ( multiplicant)
 	slli a5,a5,1		# shift left 1 position working register with value of a4 register ( multiplicant)
 	beqz a2,exit		# if multiplier register is 0 exit
 	mv a4,a5		# copy back the shifter multiplicant to a4
 	ret
 OR1:
 	mv a5,a4
 	slli a1,a1,1
 	slli a5,a5,1
 	li x3,1
 	or a5,a5,x3
 	beqz a2,exit
 	mv a4,a5
 	ret
exit:
	ret


##########################################################################################################
#
#	li t1,4				# t1 counter = 4
#	
#readloop2:
#	lb t2,3(x10)			# loads 1 byte to t2 from result
#	call bin_to_ascii		# convert bin to ascii
#	addi x10,x10,-1			# decrease pointer
#	addi t1,t1,-1			# decrease counter
#	bnez t1,readloop2		# loop till counter is 0
#	li x8,0x0d			# line feed
#	call USART_TX			# call uart
#	li x8,0x0a			# carriage feed
#	call USART_TX			# call uart
##########################################################################################################
# converts 1 byte into ASCII represented hexadecimal value , load byte in t2
##########################################################################################################
bin_to_ascii:
	addi sp,sp,-4
	sw ra,0(sp)
	mv a3,t2
	andi a3,a3,0xf0
	srli a3,a3,4
	slti a4,a3,10			# set a4 to 1 if a3 is less than 10 ,10and higher a4=0
	beqz a4 ,letter1
	ori a3,a3,0x30
	#mv a0,a3
	mv x8,a3
	call USART_TX
	j low_nibble
letter1:
	addi a3,a3,0x37
	#mv a0,a3
	mv x8,a3
	call USART_TX
low_nibble:
	mv a3,t2
	andi a3,a3,0x0f
	slti a4,a3,10			# set a4 to 1 if a3 is less than 10 ,10and higher a4=0
	beqz a4 ,letter2
	ori a3,a3,0x30
	#mv a0,a3
	mv x8,a3
	call USART_TX
	j exit_bin_to_ascii
letter2:
	addi a3,a3,0x37
	#mv a0,a3
	mv x8,a3
	call USART_TX
exit_bin_to_ascii:
	lw ra,0(sp)
	addi sp,sp,4
	ret
#################################################################################################
# PIXEL_REPEAT should be called after loading the y1,y0,x1,x0 pixel coordinates in variable XYC
# to print rectagle/line on LCD , automatically sets window
#################################################################################################

PIXEL_REPEAT1:
	addi sp,sp,-36			# move stack pointer 3 words
	sw ra,0(sp)			# push return address
	sw x5,4(sp)
	sw x6,8(sp)
	sw x7,12(sp)
	sw x8,16(sp)
	sw x10,20(sp)
	sw x11,24(sp)
	sw x12,28(sp)
	la x10,result_lo
	lw x7,0(x10)
	sw x7,32(sp)
	la x10,XYC
	lbu x5,0(x10)			# x0 from XYC
	addi x10,x10,1			# byte1
	lbu x6,0(x10)			# x1 from XYC
	beq x5,x6,only_lineH		# if X1 and x0 is same ,horizontal component is 0 , probably a vertical line ,branch to only_lineH
	sub x5,x6,x5			# x1-x0
	mv x11,x5			# x11 = a1 multiplicand
	J not_lineH			# x1 not = to x0 means this is a rectangle and not a line, jump to not_lineH
only_lineH:
	mv x11,x5			# x11 = a1 multiplicand
not_lineH:
	addi x10,x10,1			# byte2
	lbu x6,0(x10)			# y0
	addi x10,x10,1			# byte3
	lbu x7,0(x10)			# y1
	beq x7,x6,only_lineV
	sub x6,x7,x6			# y1-y0
	mv x12,x6			# x11 = a1 multiplicand
	j not_lineV
only_lineV:
	mv x12,x7			# x11 = a1 multiplicand
not_lineV:
	call soft_mul			# muliplication subroutine
	la x10,result_lo
	lw x5,0(x10)			# length ((x1-x0)*(y1-y0)) = total number of pixels to be written
	call setTFTwindow		# sets the write window for the calculated number of pixels in the given rectangle
repeat_pixel1:
	call TFTpixel			# writes single pixel
	addi x5,x5,-1			# reduce counter
	bnez x5,repeat_pixel1		# if counter is above 0 repeat writing pixel
	la x10,result_lo
	lw x7,32(sp)
	sw x7,0(x10)
	lw x12,28(sp)
	lw x11,24(sp)
	lw x10,20(sp)
	lw x8,16(sp)
	lw x7,12(sp)
	lw x6,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)			# pop return address register
	addi sp,sp,36			# restore stack pointer to old position
	ret				# return to caller
###################################################################################################################
# ST7735_init subroutines load the initialization values for the LCD
###################################################################################################################

ST7735_init:
	addi sp,sp,-12
	sw ra,0(sp)
	sw x6,4(sp)
	sw x15,8(sp)
	call COMMAND_ON
	li x15,ST7735_SWRESET
	call SPI_WRITE
	li x6 , 100000			# 50ms
	call delay
	
	li x15,ST7735_SLPOUT
	call SPI_WRITE
	li x6 , 1000000			# 500ms
	call delay

	li x15,ST7735_COLMOD
	call SPI_WRITE
	li x6 , 2000			# 1ms delay for SPI to finish transmission
	call delay
	call DATA_ON
	li x15,0x05			#16-bit color , 5-6-5 RGB
	call SPI_WRITE
	li x6 , 20000			# 10ms
	call delay

	call COMMAND_ON
	li x15,ST7735_FRMCTR1
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay
	call DATA_ON
	li x15,0x00			#fastest refresh
	call SPI_WRITE
	li x15,0x06			#6 lines front porch
	call SPI_WRITE
	li x15,0x03			#3 lines front porch
	call SPI_WRITE
	li x6 , 20000			# 10ms
	call delay

	call COMMAND_ON
	li x15,ST7735_MADCTL		#Memory access ctrl (directions)
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay
	call DATA_ON
	li x15,0xC8			#Row addr/col addr, bottom to top refresh
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay
	
	call COMMAND_ON
	li x15,ST7735_DISSET5		#Display settings  no delay:
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay
	call DATA_ON
	li x15,0x15			#1 clk cycle nonoverlap, 2 cycle gate rise, 3 cycle osc equalize
	call SPI_WRITE
	li x15,0x02			#Fix on VTL
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay

	call COMMAND_ON
	li x15,ST7735_INVCTR		#Display inversion control
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay
	call DATA_ON
	li x15,0x00			#Line inversion
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay

	call COMMAND_ON
	li x15,ST7735_GMCTRP1		#
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay
	call DATA_ON
	li x15,0x09			#
	call SPI_WRITE
	li x15,0x16			#
	call SPI_WRITE
	li x15,0x09			#
	call SPI_WRITE
	li x15,0x20			#
	call SPI_WRITE
	li x15,0x21			#
	call SPI_WRITE
	li x15,0x1B			#
	call SPI_WRITE
	li x15,0x13			#
	call SPI_WRITE
	li x15,0x19			#
	call SPI_WRITE
	li x15,0x17			#
	call SPI_WRITE
	li x15,0x15			#
	call SPI_WRITE
	li x15,0x1E			#
	call SPI_WRITE
	li x15,0x2B			#
	call SPI_WRITE
	li x15,0x04			#
	call SPI_WRITE
	li x15,0x05			#
	call SPI_WRITE
	li x15,0x02			#
	call SPI_WRITE
	li x15,0x0E			#
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay
	
	call COMMAND_ON
	li x15,ST7735_GMCTRN1		#
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay
	call DATA_ON
	li x15,0x0B			#
	call SPI_WRITE
	li x15,0x14			#
	call SPI_WRITE
	li x15,0x08			#
	call SPI_WRITE
	li x15,0x1E			#
	call SPI_WRITE
	li x15,0x22			#
	call SPI_WRITE
	li x15,0x1D			#
	call SPI_WRITE
	li x15,0x18			#
	call SPI_WRITE
	li x15,0x1E			#
	call SPI_WRITE
	li x15,0x1B			#
	call SPI_WRITE
	li x15,0x1A			#
	call SPI_WRITE
	li x15,0x24			#
	call SPI_WRITE
	li x15,0x2B			#
	call SPI_WRITE
	li x15,0x06			#
	call SPI_WRITE
	li x15,0x06			#
	call SPI_WRITE
	li x15,0x02			#
	call SPI_WRITE
	li x15,0x0F			#
	call SPI_WRITE
	li x6 , 2000			# 1ms
	call delay
#
	call COMMAND_ON
	li x15,ST7735_NORON 		#Normal display on,
	call SPI_WRITE
	li x6 , 20000			# 10ms
	call delay

	call COMMAND_ON
	li x15,ST7735_DISPON 		#Main screen turn on
	call SPI_WRITE
	li x6 ,1000000			# 500ms
	call delay
	lw x15,8(sp)
	lw x6,4(sp)
	lw ra,0(sp)
	addi sp,sp,12
	ret
################################################################################################################
#################################################################################################################
# DRAW_CHAR32, prints default 16x32font. after setting window ,load font address in variable state directly or use subroutine
# select_font , x5 array count,set fontcolor & bgcolor before calling
##################################################################################################################
DRAW_CHAR32:
	addi sp,sp,-28
	sw ra,0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x5,12(sp)
	sw x7,16(sp)
	sw x4,20(sp)
	sw x6,24(sp)
	li x10,state		# point x10 to variable state which has address of the font
	lw x11,0(x10)		# copy address of font to new pointer x11 from state
	li x5,64		# number of bytes in the font, a font in this code has a 64 byte array, a macro can be developed later
loadbyte:
	beqz x5,font_finish	# check byte counter x5 is equal to 0, if equal branch to font_finish
	li x4,8			# load bit counter x4 with 8 bits
	lbu x7,0(x11)		# load x7 byte from font array
	addi x11,x11,1		# increase x11 to next byte address
	addi x5,x5,-1		# decrease byte counter
#	beqz x5,font_finish
extract:
	andi x6,x7,0x80		# extract the msb by anding with 0x80
	beqz x6,BGW		# if msb is 0 branch to BGW
	call FONT_COLOUR	# if msb is 1 call FONT_COLOUR subroutine to print font
	slli x7,x7,1		# shift x7 left by 1 bit
	addi x4,x4,-1		# decrease bit counter
	bnez x4,extract		# if bit counter is greater than 0 repeat
	j loadbyte		# if x4 is 0 jump to loadbyte to start with another byte
BGW:
	call BG_COLOUR   	# call subroutine BG_COLOUR to print background colour
	slli x7,x7,1		# shift 1 bit left
	addi x4,x4,-1		# reduce bit counter
	bnez x4,extract		# if bit counter is greater than 0 repeat
	j loadbyte		# if x4 is 0 jump to loadbyte to start with another byte
font_finish:
	lw x6,24(sp)
	lw x4,20(sp)
	lw x7,16(sp)
	lw x5,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,28
	ret

BG_COLOUR:
	addi sp,sp,-16
	sw ra, 0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x7,12(sp)
	la x11,FONTCOLOR		# point x11 to FONTCOLOR
	la x10,XYCOLOUR			# point x10 to XYCOLOUR
	addi x10,x10,3			# point to byte3 ,colour hi byte stored here
	addi x11,x11,1			# back ground colour hibyte for font stored here
	lb x7,0(x11)
	sb x7,0(x10)			# hi byte
	addi x10,x10,-1
	addi x11,x11,-1
	lb x7,0(x11)
	sb x7,0(x10)			# lo byte
	call TFTpixel
	lw x7,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret


FONT_COLOUR:
	addi sp,sp,-16
	sw ra, 0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x7,12(sp)
	la x11,FONTCOLOR
	la x10,XYCOLOUR
	addi x10,x10,3			# point to byte3
	addi x11,x11,3			# font colour hibyte for font stored here
	lb x7,0(x11)
	sb x7,0(x10)
	addi x10,x10,-1			# point to byte2
	addi x11,x11,-1			# point to byte2
	lb x7,0(x11)
	sb x7,0(x10)
	call TFTpixel
	lw x7,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret

############################################################################

push_cursor1:
	addi sp,sp,-24
	sw ra,0(sp)
	sw x11,4(sp)
	sw x10,8(sp)
	sw x7,12(sp)
	sw x5,16(sp)
	sw x6,20(sp)
	la x10,XYC		# point x10 to XYC 
	la x11,scratch		# point x11 to scratch
	addi x10,x10,1		# point to x1 XYC, current cursor x1
	lb x7,0(x10)		
	sb x7,0(x11)		# store (oldx1) current cursor x in x0 scratch
	addi x10,x10,-1         # old x0 ,XYC
	lb x5,0(x10)		# load old x0
	sub x5,x7,x5		# width in x5
	add x5,x7,x5		# add width with old x1 to get new x1
	li x6, width		# 128 pixels
	bltu x5,x6,hpush	# if less than 128 pixels branch to hpush
				# reset x to 0 and increase y by height of font
	addi x10,x10,3		#old y1
	lb x7,0(x10)		# loa old y1
	addi x11,x11,2		# store in x11 new y0
	sb x7,0(x11)		# store new y0
	addi x10,x10,-1		#y0
	lb x5,0(x10)		#old y0
	sub x5,x7,x5		#old y1-y0 = height
	add x5,x7,x5		# new y0 + height = new y1
	li x6,height		# 160 pixels
	bltu x5,x6,vpush	# if height less than 160 pixels branch  to vpush
	
	lb x5,0(x10)		# old y0
	addi x10,x10,1		# point to old y1 in XYC
	lb x7,0(x10)		# old y1
	sub x5,x7,x5		# y1-y0 = height
	addi x11,x11,1          # new y1
	sb x5,0(x11)		# new y1
	li x7,0
	addi x11,x11,-1		# new y0
	sb x7,0(x11)            # new y0 , Y coordinate becomes y0= 0 ,y1 = heigt of font
	
	addi x10,x10,-3         # old x0
	lb x5,0(x10)
	addi x10,x10,1		# old x1
	lb x7,0(x10)
	sub x5,x7,x5		# x1-x0 = width
	addi x11,x11,-1		# new x1
	sb x5,0(x11)		# new x1
	addi x11,x11,-1		# new x0
	sb x0,0(x11)
	
	j outout
			
vpush:					
	addi x11,x11,1		# point to new y1
	sb x5,0(x11)		# new y1 = (old y1-y0) + old y1
	li x7,0			# 0 for x0 as new line write starts at 0
	addi x11,x11,-3		# point to new x0
	sb x7,0(x11)		# new x0 has value 0 pixel
	addi x10,x10,-1		# x10 points to old x1
	lb x7,0(x10)		# load old x1
	addi x10,x10,-1		# point to old x0
	lb x5,0(x10)		# load old x0
	sub x5,x7,x5		# x1-x0 = width of font
	addi x11,x11,1		# point to new x1
	sb x5,0(x11)		# store width in new x1 , 0,width will be new x coordinates
	j outout
hpush:
	addi x11,x11,1		# point to new x1
	sb x5,0(x11)		#
	addi x11,x11,1		# y0
	addi x10,x10,2		# y0
	lb x7,0(x10)		# old y0
	sb x7,0(x11)		# new y0
	addi x11,x11,1		# y1
	addi x10,x10,1		# y1
	lb x7,0(x10)		# old y1
	sb x7,0(x11)		# new y1
	
outout:
	la x11,scratch
	la x10,XYC
	lw x7,0(x11)
	sw x7,0(x10)
	call setTFTwindow
	lw x6,20(sp)
	lw x5,16(sp)
	lw x7,12(sp)
	lw x10,8(sp)
	lw x11,4(sp)
	lw ra,0(sp)
	addi sp,sp,24
	ret

##############################################################################
# call select font with ascii char in x15, will store address of font in state
##############################################################################
select_font:
	addi sp,sp,-16
	sw ra,0(sp)
	sw x7,4(sp)
	sw x10,8(sp)
	sw x11,12(sp)
	la x10,space		# load address of 1st font "space"
	li x7,0x20		# ascii space
	sub x7,x15,x7		# difference between 1st char of list and requested font in x15
	beqz x7,loadfont
searchfont:
	addi x10,x10,64
	addi x7,x7,-1
	bnez x7,searchfont
loadfont:
	la x11,state
	sw x10,0(x11)		# store address of font in X10 to "state" which will be used by DRAW_CHAR32
	lw x11,12(sp)
	lw x10,8(sp)
	lw x7,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret

#########################################################################################
# doubles 16x32 font to 32x64
#########################################################################################

DRAW_CHAR_DOUBLE:
	addi sp,sp,-32
	sw ra,0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x5,12(sp)
	sw x7,16(sp)
	sw x4,20(sp)
	sw x6,24(sp)
	sw x12,28(sp)
	la x10,counter
	li x11,4
	sw x11,0(x10)
	la x10,state
	lw x11,0(x10)
#	la x11,A
	li x5,128
loadbyte1:
	li x4,8
	lbu x7,0(x11)
	addi x11,x11,1
	addi x5,x5,-1
	beqz x5,font_finish1
repeat_column:
	la x10,counter
	lw x12,0(x10)
	addi x12,x12,-1
	sw x12,0(x10)
	li x6,2
	beq x12,x6,reset_pointer
	bnez x12,extract1
#######	addi x11,x11,2
	la x10,counter
	li x6,4
	sw x6,0(x10)
extract1:
	andi x6,x7,0x80
	beqz x6,BGW1
	call FONT_COLOUR1
	slli x7,x7,1
	addi x4,x4,-1
	bnez x4,extract1
	j loadbyte1
BGW1:
	call BG_COLOUR1
	slli x7,x7,1
	addi x4,x4,-1
	bnez x4,extract1
	j loadbyte1
font_finish1:
	lw x12,28(sp)
	lw x6,24(sp)
	lw x4,20(sp)
	lw x7,16(sp)
	lw x5,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,32
	ret


.align 4
BG_COLOUR1:
	addi sp,sp,-16
	sw ra, 0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x7,12(sp)
	la x11,FONTCOLOR
	la x10,XYCOLOUR
	addi x10,x10,3			# point to byte3 ,colour hi byte stored here
	addi x11,x11,1			# back ground colour hibyte for font stored here
	lb x7,0(x11)
	sb x7,0(x10)			# hi byte
	addi x10,x10,-1
	addi x11,x11,-1
	lb x7,0(x11)
	sb x11,0(x10)			# lo byte
	call TFTpixel
	call TFTpixel
	lw x7,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret
	
.align 4
FONT_COLOUR1:
	addi sp,sp,-16
	sw ra, 0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x7,12(sp)
	la x11,FONTCOLOR
	la x10,XYCOLOUR
	addi x10,x10,3			# point to byte3
	addi x11,x11,3			# font colour hibyte for font stored here
	lb x7,0(x11)
	sb x7,0(x10)
	addi x10,x10,-1			# point to byte2
	addi x11,x11,-1			# point to byte2
	lb x7,0(x11)
	sb x7,0(x10)
	call TFTpixel
	call TFTpixel
	lw x7,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret
reset_pointer:
	addi x11,x11,-2
	j extract1
######################################################################################

fillCircle:
	addi sp,sp,-36
	sw ra,0(sp)
	sw x7,4(sp)
	sw x8,8(sp)
	sw x9,12(sp)
	sw x10,16(sp)
	sw x11,20(sp)
	sw x12,24(sp)
	sw x13,28(sp)
	sw x14,32(sp)
	la x10,buffer2
	lb x7,0(x10)			# radius
	mv a1,x7			# radius ,X11
	mv a2,x7			# radius ,x12
	call soft_mul			# radius square
	la x10,result_lo		# result in result_lo = radius square
	la x11,buffer1			# place to store r^2 in buffer1
	lw x7,0(x10)			# copy from result_lo
	sw x7,0(x11)			# store radius square in buffer1
	li x7,0				# i ,i counter initiated in x7 .0 to radius max
circle_loop:
	mv a1,x7			# move new value of i to a1 for squaring with softmul routine
	mv a2,x7			# move new value of i to a1 for squaring with softmul routine
	call soft_mul			# soft_mul multiplies value in (a1 & a2)x11 & x12 , result will be stored in result_lo
	la x10,buffer1			# square of r
	la x11,result_lo		# square of i 
	lw x8,0(x10)			# square of r in x8
	lw x9,0(x11)			# square of i in x9
	sub x10,x8,x9			# rsq -isq store in x10, value to be rooted in x10
	call floor_sqrt			# length of base in result_lo
	la x11,result_lo		# result_lo holds the base = sqrt operation
	lw x9,0(x11)			# base in x9
	la x14,buffer2			# radius ,x ,y stored in buffer2
	lb x10,0(x14)			# radius in x10
	addi x14,x14,1			# point x14 to byte1 which holds y
	lb x11,0(x14)			# x11 is loaded with byte1 ,y. x and y are same and can be used alterntely	
	sub x12,x11,x9			# starting of line is (x-base) (x0 of horizontal line) in x12
	add x13,x11,x7			# position of y of upper horizontal line from center,(y+i) , new y in x13
	add x14,x9,x9			# end of horizontal line x1 is (base x 2)+ x0, (base +base)+x0 = x1
	add x14,x14,x12			# (base +base)+x0 = x1
	la x10,XYC			# holds pixel coordinates of horizontal line 
	sb x12,0(x10)			# x0
	addi x10,x10,1
	sb x14,0(x10)			# x1
	addi x10,x10,1
	sb x13,0(x10)			# y0
	addi x10,x10,1
	sb x13,0(x10)			# y1
	call PIXEL_REPEAT1		# prints pixels based on the cordinates in XYC
	la x11,result_lo		# result_lo holds the base = sqrt operation
	lw x9,0(x11)			# base in x9
	la x14,buffer2			# radius ,x ,y stored in buffer2
	lb x10,0(x14)			# radius in x10
	addi x14,x14,1			# point x14 to byte1 which holds y
	lb x11,0(x14)			# x11 is loaded with byte1 ,y. x and y are same and can be used alterntely	
	sub x12,x11,x9			# starting of line is (x-base) (x0 of horizontal line) in x12
	sub x13,x11,x7			# position of y of upper horizontal line from center,(y-i) , new y in x13
	add x14,x9,x9			# end of horizontal line x1 is base x 2, base +base = x1
	add x14,x14,x12			# (base +base)+x0 = x1
	la x10,XYC
	sb x12,0(x10)			# x0
	addi x10,x10,1
	sb x14,0(x10)			# x1
	addi x10,x10,1
	sb x13,0(x10)			# y0
	addi x10,x10,1
	sb x13,0(x10)			# y1
	call PIXEL_REPEAT1
	addi x7,x7,1			# increase i by 1 count till the length of radius r
	la x10,buffer2
	lb x12,0(x10)			# load radius in x12
	bne x7,x12,circle_loop		# if i is less than radius loop back to circle_loop
	lw x14,32(sp)
	lw x13,28(sp)
	lw x12,24(sp)
	lw x11,20(sp)
	lw x10,16(sp)
	lw x9,12(sp)
	lw x8,8(sp)
	lw x7,4(sp)
	lw ra,0(sp)
	addi sp,sp,36
	ret
############################################################################################

# needs value in x10, square root in result_lo
floor_sqrt:
	addi sp,sp,-28
	sw ra,0(sp)
	sw x5,4(sp)
	sw x7,8(sp)
	sw x8,12(sp)
	sw x10,16(sp)
	sw x13,20(sp)
	sw x14,24(sp)
        li   x5, 0            # unsigned int s = 0;
        li   x8, 1            # unsigned int i = 1;t1
        slli x8, x8, 15       # i = i << 15
for_next_bit:
        beqz x8, next_bit_end # if i == 0 goto next_bit_end
        add  x7, x5, x8       # t2 = s + i
#        mul  t3, t2, t2       # t3 = (t2)^2 = (s+i)^2
	mv a1,x7
	mv a2,x7
	call soft_mul
	
	la x13,result_lo
	lw x14,0(x13)

        bltu x10, x14, if_x_is_less_than_t3     # if a0 < t3 then don't add
        add  x5, x5, x8       # s = s + i
	
if_x_is_less_than_t3:
        srli x8, x8, 1        # i = i >> 1
        j for_next_bit        # goto for_next_bit
next_bit_end: 
	
	mv x10, x5
	la x7,result_lo
	sw x10,0(x7)
        lw x14,24(sp)
        lw x13,20(sp)
        lw x10,16(sp)
	lw x8,12(sp)
        lw x7,8(sp)
        lw x5,4(sp)
        lw ra,0(sp)
        addi sp,sp,28
        ret

#########################################################################
# D_ASCII subroutine for converting binary in result1 to DECIMAL (ASCII)
#########################################################################

D_ASCII:			
	addi sp,sp,-32		# adjust stack pointer
	sw ra,28(sp)		# PUSH
	sw x15,24(sp)		# PUSH
	sw x11,20(sp)		# PUSH
	sw x8,16(sp)		# PUSH
	sw x7,12(sp)		# PUSH
	sw x5,8(sp)		# PUSH
	sw x4,4(sp)		# PUSH
	sw t1,0(sp)		# PUSH
	li x4,0			# clear register
	li x5,0			# clear register
	li x7,0			# clear register
	li x8,0			# clear register
	li x15,0		# clear register
	
	la x10,result1		# result1
	lw x4,0(x10)		# copy result1 to x4
#	li x4,0xffffffff	# 32bit word to be converted into ascii chars
	li x7,1000000000	# divisor
Y1:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X1		# if result negative(not divisible) branch to X1
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y1			# jump to label Y1 till not divisible
X1:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	la x10,mem		# set pointer x10 to SRAM register mem to store the byte
	sb x15,0(x10)		# store byte in mem+0
	li x15,0		# clear result
	li x7,100000000		# load x7 with new divisor
Y2:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X2		# if result negative(not divisible) branch to X2
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y2			# jump to label Y2 till not divisible
X2:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+1 to store the byte
	sb x15,0(x10)		# store byte in mem+1
	li x15,0		# clear result
	li x7,10000000		# load x7 with new divisor
Y3:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X3		# if result negative(not divisible) branch to X3
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y3			# jump to label Y3 till not divisible
X3:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+2 to store the byte
	sb x15,0(x10)		# store byte in mem+2
	li x15,0		# clear result
	li x7,1000000		# load x7 with new divisor
Y4:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X4		# if result negative(not divisible) branch to X4
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y4			# jump to label Y4 till not divisible
X4:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+3		
	sb x15,0(x10)		# store byte in mem+3
	li x15,0		# clear result
	li x7,100000		# load x7 with new divisor
Y5:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X5		# if result negative(not divisible) branch to X5
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y5			# jump to label Y5 till not divisible
X5:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+4 to store the byte
	sb x15,0(x10)		# store byte in mem+4
	li x15,0		# clear result
	li x7,10000		# load x7 with new divisor
Y6:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X6		# if result negative(not divisible) branch to X6
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y6			# jump to label Y6 till not divisible
X6:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+5 to store the byte
	sb x15,0(x10)		# store byte in mem+5
	li x15,0		# clear result
	li x7,1000		# load x7 with new divisor
Y7:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X7		# if result negative(not divisible) branch to X7
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y7			# jump to label Y7 till not divisible
X7:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+6 to store the byte
	sb x15,0(x10)		# store byte in mem+6
	li x15,0		# clear result
	li x7,100		# load x7 with new divisor
Y8:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X8		# if result negative(not divisible) branch to X8
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y8			# jump to label Y8 till not divisible
X8:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+7 to store the byte
	sb x15,0(x10)		# store byte in mem+7
	li x15,0		# clear result
	li x7,10		# load x7 with new divisor
Y9:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X9		# if result negative(not divisible) branch to X9
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y9			# jump to label Y9 till not divisible
X9:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+8 to store the byte
	sb x15,0(x10)		# store byte in mem+8
	li x15,0		# clear result
	mv x15,x4
X10:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+9 to store the byte	
	sb x15,0(x10)		# store byte in mem+9

	lw t1,0(sp)		# POP
	lw x4,4(sp)		# POP
	lw x5,8(sp)		# POP
	lw x7,12(sp)		# POP
	lw x8,16(sp)		# POP
	lw x11,20(sp)		# POP
	lw x15,24(sp)		# POP
	lw ra,28(sp)		# POP
	addi sp,sp,32		# adjust stack pointer
	ret			# return to caller
##############################################################################################
##############################################################################################
# Prints 10 bytes from result1 to USART with lead 0 suppress, values to be stored in mem0-mem9
##############################################################################################
print:
	addi sp,sp,-20		# adjust stack pointer
	sw ra,16(sp)		# PUSH
	sw x11,12(sp)		# PUSH
	sw x10,8(sp)		# PUSH
	sw x8,4(sp)		# PUSH
	sw t1,0(sp)		# PUSH

	li x11,scratch		# point x11 to scratch register in SRAM
	sw zero,0(x11)		# clear scratch register
	li x10,mem		# point to address mem ,top byte stored in mem0 lowest byte in mem+9, need to print top byte 1st
	li t1,0			# byte counter loaded with 10 , total 10 bytes to be printed (0-9)
	li x8,10		# max count of 10bytes in x8

	la x15,scratchpad	# macro num_chars will store number of characters to be printed in scratchpad byte0
	lb x7,0(x15)		# load x7 with number of chars to be pprinted
	sub x8,x8,x7		# subtract total char count and number to be printed
	add x10,x10,x8		# increase address of mem pointer to diffrence of above
	mv t1,x8		# adjust the counter also to the count matching address
	add x8,x8,x7		# restore total count desired
Z1:
	lb x15,0(x10)		# load byte from mem, msb to lsb
	li x4,0x30		# load ascii 0 in x4
	beq x15,x4,supress0	# if result1 byte in x15 is equal to ascii 0 in x4 branch to suppress0 label
	li x11,scratch		# point x11 to scratch if x8 is not 0,that means we have found the 1st byte that is not 0, all leading 0s finished
	li x5,1			# load x5 with 1
	sw x5,0(x11)		# store in scratch register in sram , used as a flag to indicate all leading 0s are finished
print1:
	addi x10,x10,1		# increase the address by 1 byte
	addi t1,t1,1		# increase the byte counter once
	call select_font	# font is selected and stored in state
	call DRAW_CHAR32
	call push_cursor1
	bne t1,x8,Z1		# if t1 not equal to 10 as loaded in x8 loop back to print1 till al 10 bytes are transmitted via usart
	lw t1,0(sp)		# POP
	lw x8,4(sp)		# POP
	lw x10,8(sp)		# POP
	lw x11,12(sp)		# POP
	lw ra,16(sp)		# POP
	addi sp,sp,20		# adjust stack pointer
	ret			# return to caller
supress0:
	li x11,scratch		# point x11 to scratch	
	lw x5,0(x11)		# copy value of scratch to x5
	bnez x5,no_more_supress	# if x5 is not 0 branch to label "no_more_supress"
	li x8,0x20		# if x5 is 0 load x8 with space/blank	
	li x4,9			# load x4 with value 9, suppose the whole value is 0, we dont want to display blank space, test this is 9th byte 2nd last byte
	beq t1,x4,last0is0	# if t1 equals 9 in x4 branch to label "last0is0" which will keep last 0 as 0 on screen
no_more_supress:
	J print1		# no 0 suppression jump to print1	
last0is0:
	li x15,0x30		# load ascii 0 for last 0
	J print1		# jump to print1

#######################################################################################
show_memory:
	addi sp,sp,-20
	sw ra,0(sp)
	sw t1,4(sp)
	sw t2,8(sp)
	sw x8,12(sp)
	sw x10,16(sp)

	la x10,XYC
	li t1,4				# t1 counter = 4
readloop2:
	lb t2,3(x10)			# loads 1 byte to t2 from result
	call bin_to_ascii		# convert bin to ascii
	addi x10,x10,-1			# decrease pointer
	addi t1,t1,-1			# decrease counter
	bnez t1,readloop2		# loop till counter is 0
	li x8,0x0d			# line feed
	call USART_TX			# call uart
	li x8,0x0a			# carriage feed
	call USART_TX			# call uart

	lw x10,16(sp)
	lw x8,12(sp)
	lw t2,8(sp)
	lw t1,4(sp)
	lw ra,0(sp)
	addi sp,sp,20
	ret

show_register:
	addi sp,sp,-20
	sw ra,0(sp)
	sw t1,4(sp)
	sw t2,8(sp)
	sw x8,12(sp)
	sw x10,16(sp)


	la x10,scratch
	mv t1,sp
	sw t1,0(x10)
	li t1,4				# t1 counter = 4
readloop1:
	lb t2,3(x10)			# loads 1 byte to t2 from result
	call bin_to_ascii		# convert bin to ascii
	addi x10,x10,-1			# decrease pointer
	addi t1,t1,-1			# decrease counter
	bnez t1,readloop1		# loop till counter is 0
	li x8,0x0d			# line feed
	call USART_TX			# call uart
	li x8,0x0a			# carriage feed
	call USART_TX			# call uart

	lw x10,16(sp)
	lw x8,12(sp)
	lw t2,8(sp)
	lw t1,4(sp)
	lw ra,0(sp)
	addi sp,sp,20
	ret

############################################################################
.section .rodata
.global CONSTANTS

name: .string "SAJEEV SANKARAN CH32V003 UART"
eol: .byte 0x0d,0x0a,0x00

.align 4

line1: .word 0x640a0a0a   
color1: .word 0xf8000000


############################################################################
.section .rodata
.global font1632

#    * code=32, hex=0x20, ascii=" "
space:
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */


#     * code=33, hex=0x21, ascii="!"
exclaim:
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x03,0xC0 #,  /* 0000001111000000 */
.byte    0x07,0xE0 #,  /* 0000011111100000 */
.byte    0x0F,0xF0 #,  /* 0000111111110000 */
.byte    0x0F,0xF0 #,  /* 0000111111110000 */
.byte    0x0F,0xF0 #,  /* 0000111111110000 */
.byte    0x0F,0xF0 #,  /* 0000111111110000 */
.byte    0x0F,0xF0 #,  /* 0000111111110000 */
.byte    0x0F,0xF0 #,  /* 0000111111110000 */
.byte    0x07,0xE0 #,  /* 0000011111100000 */
.byte    0x07,0xE0 #,  /* 0000011111100000 */
.byte    0x07,0xE0 #,  /* 0000011111100000 */
.byte    0x03,0xC0 #,  /* 0000001111000000 */
.byte    0x03,0xC0 #,  /* 0000001111000000 */
.byte    0x03,0xC0 #,  /* 0000001111000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x03,0xC0 #,  /* 0000001111000000 */
.byte    0x03,0xC0 #,  /* 0000001111000000 */
.byte    0x03,0xC0 #,  /* 0000001111000000 */
.byte    0x03,0xC0 #,  /* 0000001111000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */
.byte    0x00,0x00 #,  /* 0000000000000000 */


#     * code=34, hex=0x22, ascii="""
dq:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x3C,0x3C  #,  /* 0011110000111100 */
.byte    0x3C,0x3C  #,  /* 0011110000111100 */
.byte    0x3C,0x3C  #,  /* 0011110000111100 */
.byte    0x3C,0x3C  #,  /* 0011110000111100 */
.byte    0x3C,0x3C  #,  /* 0011110000111100 */
.byte    0x1C,0x38  #,  /* 0001110000111000 */
.byte    0x0C,0x30  #,  /* 0000110000110000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=35, hex=0x23, ascii="#"
hash:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#    * code=36, hex=0x24, ascii="$"
dollar:
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x3F,0xF0  #,  /* 0011111111110000 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0xF8,0x7C  #,  /* 1111100001111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF0,0x1C  #,  /* 1111000000011100 */
.byte    0xF0,0x00  #,  /* 1111000000000000 */
.byte    0xF0,0x00  #,  /* 1111000000000000 */
.byte    0xF8,0x00  #,  /* 1111100000000000 */
.byte    0x7F,0xF0  #,  /* 0111111111110000 */
.byte    0x3F,0xF8  #,  /* 0011111111111000 */
.byte    0x00,0x7C  #,  /* 0000000001111100 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0xE0,0x3C  #,  /* 1110000000111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF8,0x7C  #,  /* 1111100001111100 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0x3F,0xF0  #,  /* 0011111111110000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=37, hex=0x25, ascii="%"
percentage:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x78,0x78  #,  /* 0111100001111000 */
.byte    0xFC,0x78  #,  /* 1111110001111000 */
.byte    0xCC,0xF0  #,  /* 1100110011110000 */
.byte    0xCC,0xF0  #,  /* 1100110011110000 */
.byte    0xFD,0xE0  #,  /* 1111110111100000 */
.byte    0x79,0xE0  #,  /* 0111100111100000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x1E,0x78  #,  /* 0001111001111000 */
.byte    0x1E,0xFC  #,  /* 0001111011111100 */
.byte    0x3C,0xCC  #,  /* 0011110011001100 */
.byte    0x3C,0xCC  #,  /* 0011110011001100 */
.byte    0x78,0xFC  #,  /* 0111100011111100 */
.byte    0x78,0x78  #,  /* 0111100001111000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=38, hex=0x26, ascii="&"
and:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x0F,0xC0  #,  /* 0000111111000000 */
.byte    0x1F,0xE0  #,  /* 0001111111100000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x1D,0xE0  #,  /* 0001110111100000 */
.byte    0x1F,0xC0  #,  /* 0001111111000000 */
.byte    0x3F,0x1C  #,  /* 0011111100011100 */
.byte    0x7F,0xBC  #,  /* 0111111110111100 */
.byte    0xFB,0xF8  #,  /* 1111101111111000 */
.byte    0xF1,0xF0  #,  /* 1111000111110000 */
.byte    0xF0,0xF0  #,  /* 1111000011110000 */
.byte    0xF0,0xE0  #,  /* 1111000011100000 */
.byte    0xF0,0xE0  #,  /* 1111000011100000 */
.byte    0xF0,0xE0  #,  /* 1111000011100000 */
.byte    0xF0,0xF0  #,  /* 1111000011110000 */
.byte    0xF9,0xF0  #,  /* 1111100111110000 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0x3F,0x3C  #,  /* 0011111100111100 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=39, hex=0x27, ascii="'"
ucoma:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x1F,0x00  #,  /* 0001111100000000 */
.byte    0x3E,0x00  #,  /* 0011111000000000 */
.byte    0x3C,0x00  #,  /* 0011110000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=40, hex=0x28, ascii="("
obracket:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x70  #,  /* 0000000001110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0x70  #,  /* 0000000001110000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=41, hex=0x29, ascii=")"
cbracket:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x0E,0x00  #,  /* 0000111000000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0E,0x00  #,  /* 0000111000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=42, hex=0x2A, ascii="*"
asterix:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x38,0x70  #,  /* 0011100001110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x1F,0xE0  #,  /* 0001111111100000 */
.byte    0x0F,0xC0  #,  /* 0000111111000000 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0x0F,0xC0  #,  /* 0000111111000000 */
.byte    0x1F,0xE0  #,  /* 0001111111100000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x38,0x70  #,  /* 0011100001110000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=43, hex=0x2B, ascii="+"
plus:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=44, hex=0x2C, ascii=","
coma:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x07,0xC0  #,  /* 0000011111000000 */
.byte    0x0F,0x80  #,  /* 0000111110000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=45, hex=0x2D, ascii="-"
minus:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=46, hex=0x2E, ascii="."
period:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=47, hex=0x2F, ascii="/"
fslash:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x78  #,  /* 0000000001111000 */
.byte    0x00,0x78  #,  /* 0000000001111000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x1E,0x00  #,  /* 0001111000000000 */
.byte    0x1E,0x00  #,  /* 0001111000000000 */
.byte    0x3C,0x00  #,  /* 0011110000000000 */
.byte    0x3C,0x00  #,  /* 0011110000000000 */
.byte    0x78,0x00  #,  /* 0111100000000000 */
.byte    0x78,0x00  #,  /* 0111100000000000 */
.byte    0xF0,0x00  #,  /* 1111000000000000 */
.byte    0xF0,0x00  #,  /* 1111000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=48, hex=0x30, ascii="0"
zero:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7C,0xF8  #,  /* 0111110011111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7C,0xF8  #,  /* 0111110011111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */



#     * code=49, hex=0x31, ascii="1"
one:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x07,0xC0  #,  /* 0000011111000000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x1F,0xC0  #,  /* 0001111111000000 */
.byte     0x3F,0xC0  #,  /* 0011111111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x3F,0xFC  #,  /* 0011111111111100 */
.byte     0x3F,0xFC  #,  /* 0011111111111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=50, hex=0x32, ascii="2"
two:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xE0,0x3C  #,  /* 1110000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x7C  #,  /* 0000000001111100 */
.byte     0x00,0xF8  #,  /* 0000000011111000 */
.byte     0x01,0xF0  #,  /* 0000000111110000 */
.byte     0x03,0xE0  #,  /* 0000001111100000 */
.byte     0x07,0xC0  #,  /* 0000011111000000 */
.byte     0x0F,0x80  #,  /* 0000111110000000 */
.byte     0x1F,0x00  #,  /* 0001111100000000 */
.byte     0x3E,0x00  #,  /* 0011111000000000 */
.byte     0x7C,0x00  #,  /* 0111110000000000 */
.byte     0xF8,0x00  #,  /* 1111100000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=51, hex=0x33, ascii="3"
three:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x78  #,  /* 0000000001111000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x00,0x78  #,  /* 0000000001111000 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=52, hex=0x34, ascii="4"
four:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x01,0xF0  #,  /* 0000000111110000 */
.byte     0x03,0xF0  #,  /* 0000001111110000 */
.byte     0x07,0xF0  #,  /* 0000011111110000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x1F,0xF0  #,  /* 0001111111110000 */
.byte     0x3E,0xF0  #,  /* 0011111011110000 */
.byte     0x7C,0xF0  #,  /* 0111110011110000 */
.byte     0xF8,0xF0  #,  /* 1111100011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x03,0xFC  #,  /* 0000001111111100 */
.byte     0x03,0xFC  #,  /* 0000001111111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=53, hex=0x35, ascii="5"
five:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xFF,0xF0  #,  /* 1111111111110000 */
.byte     0xFF,0xF8  #,  /* 1111111111111000 */
.byte     0x00,0x7C  #,  /* 0000000001111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */

 
#     * code=54, hex=0x36, ascii="6"
six:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x1F,0xF0  #,  /* 0001111111110000 */
.byte     0x3E,0x00  #,  /* 0011111000000000 */
.byte     0x7C,0x00  #,  /* 0111110000000000 */
.byte     0xF8,0x00  #,  /* 1111100000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xFF,0xF0  #,  /* 1111111111110000 */
.byte     0xFF,0xF8  #,  /* 1111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=55, hex=0x37, ascii="7"
seven:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x7C  #,  /* 0000000001111100 */
.byte     0x00,0xF8  #,  /* 0000000011111000 */
.byte     0x01,0xF0  #,  /* 0000000111110000 */
.byte     0x03,0xE0  #,  /* 0000001111100000 */
.byte     0x07,0xC0  #,  /* 0000011111000000 */
.byte     0x0F,0x80  #,  /* 0000111110000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=56, hex=0x38, ascii="8"
eight:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x78,0x78  #,  /* 0111100001111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x78,0x78  #,  /* 0111100001111000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=57, hex=0x39, ascii="9"
nine:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xFC  #,  /* 0111111111111100 */
.byte     0x3F,0xFC  #,  /* 0011111111111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x7C  #,  /* 0000000001111100 */
.byte     0x00,0xF8  #,  /* 0000000011111000 */
.byte     0x01,0xF0  #,  /* 0000000111110000 */
.byte     0x3F,0xE0  #,  /* 0011111111100000 */
.byte     0x3F,0xC0  #,  /* 0011111111000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */

   



#     * code=58, hex=0x3A, ascii=":"
colon:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=59, hex=0x3B, ascii=";"
semicolon:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x07,0xC0  #,  /* 0000011111000000 */
.byte    0x0F,0x80  #,  /* 0000111110000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=60, hex=0x3C, ascii="<"
lessthan:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x7C  #,  /* 0000000001111100 */
.byte    0x00,0xF8  #,  /* 0000000011111000 */
.byte    0x01,0xF0  #,  /* 0000000111110000 */
.byte    0x03,0xE0  #,  /* 0000001111100000 */
.byte    0x07,0xC0  #,  /* 0000011111000000 */
.byte    0x0F,0x80  #,  /* 0000111110000000 */
.byte    0x1F,0x00  #,  /* 0001111100000000 */
.byte    0x3E,0x00  #,  /* 0011111000000000 */
.byte    0x3E,0x00  #,  /* 0011111000000000 */
.byte    0x1F,0x00  #,  /* 0001111100000000 */
.byte    0x0F,0x80  #,  /* 0000111110000000 */
.byte    0x07,0xC0  #,  /* 0000011111000000 */
.byte    0x03,0xE0  #,  /* 0000001111100000 */
.byte    0x01,0xF0  #,  /* 0000000111110000 */
.byte    0x00,0xF8  #,  /* 0000000011111000 */
.byte    0x00,0x7C  #,  /* 0000000001111100 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=61, hex=0x3D, ascii="="
equal:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=62, hex=0x3E, ascii=">"
greaterthan:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x3C,0x00  #,  /* 0011110000000000 */
.byte    0x3E,0x00  #,  /* 0011111000000000 */
.byte    0x1F,0x00  #,  /* 0001111100000000 */
.byte    0x0F,0x80  #,  /* 0000111110000000 */
.byte    0x07,0xC0  #,  /* 0000011111000000 */
.byte    0x03,0xE0  #,  /* 0000001111100000 */
.byte    0x01,0xF0  #,  /* 0000000111110000 */
.byte    0x00,0xF8  #,  /* 0000000011111000 */
.byte    0x00,0x7C  #,  /* 0000000001111100 */
.byte    0x00,0x7C  #,  /* 0000000001111100 */
.byte    0x00,0xF8  #,  /* 0000000011111000 */
.byte    0x01,0xF0  #,  /* 0000000111110000 */
.byte    0x03,0xE0  #,  /* 0000001111100000 */
.byte    0x07,0xC0  #,  /* 0000011111000000 */
.byte    0x0F,0x80  #,  /* 0000111110000000 */
.byte    0x1F,0x00  #,  /* 0001111100000000 */
.byte    0x3E,0x00  #,  /* 0011111000000000 */
.byte    0x3C,0x00  #,  /* 0011110000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=63, hex=0x3F, ascii="?"
question:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x3F,0xF0  #,  /* 0011111111110000 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0xF8,0x7C  #,  /* 1111100001111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x7C  #,  /* 0000000001111100 */
.byte    0x00,0xF8  #,  /* 0000000011111000 */
.byte    0x01,0xF0  #,  /* 0000000111110000 */
.byte    0x03,0xE0  #,  /* 0000001111100000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=64, hex=0x40, ascii="@"
amperesand:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x3F,0xF0  #,  /* 0011111111110000 */
.byte    0x7F,0xF8  #,  /* 0111111111111000 */
.byte    0xF8,0x7C  #,  /* 1111100001111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF1,0xFC  #,  /* 1111000111111100 */
.byte    0xF3,0xFC  #,  /* 1111001111111100 */
.byte    0xF3,0xFC  #,  /* 1111001111111100 */
.byte    0xF3,0xFC  #,  /* 1111001111111100 */
.byte    0xF3,0xFC  #,  /* 1111001111111100 */
.byte    0xF3,0xFC  #,  /* 1111001111111100 */
.byte    0xF3,0xF0  #,  /* 1111001111110000 */
.byte    0xF1,0xF0  #,  /* 1111000111110000 */
.byte    0xF0,0x00  #,  /* 1111000000000000 */
.byte    0xF8,0x00  #,  /* 1111100000000000 */
.byte    0x7F,0xF0  #,  /* 0111111111110000 */
.byte    0x3F,0xF0  #,  /* 0011111111110000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */



#    * code=65, hex=0x41, ascii="A"
A:
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x03,0x00  #/* 0000001100000000 */
.byte     0x07,0x80  #/* 0000011110000000 */
.byte     0x0F,0xC0  #/* 0000111111000000 */
.byte     0x1F,0xE0  #/* 0001111111100000 */
.byte     0x3F,0xF0  #/* 0011111111110000 */
.byte     0x7C,0xF8  #/* 0111110011111000 */
.byte     0xF8,0x7C  #/* 1111100001111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xFF,0xFC  #/* 1111111111111100 */
.byte     0xFF,0xFC  #/* 1111111111111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0xF0,0x3C  #/* 1111000000111100 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */


#     * code=66, hex=0x42, ascii="B"
B:
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0xFF,0xF0  #/* 1111111111110000 */
.byte     0xFF,0xF8  #/* 1111111111111000 */
.byte     0x3C,0x7C  #/* 0011110001111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x78  #/* 0011110001111000 */
.byte     0x3F,0xF0  #/* 0011111111110000 */
.byte     0x3F,0xF0  #/* 0011111111110000 */
.byte     0x3C,0x78  #/* 0011110001111000 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x7C  #/* 0011110001111100 */
.byte     0xFF,0xF8  #/* 1111111111111000 */
.byte     0xFF,0xF0  #/* 1111111111110000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */


#     * code=67, hex=0x43, ascii="C"
C: 
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x1F,0xF0  #/* 0001111111110000 */
.byte     0x3F,0xF8  #/* 0011111111111000 */
.byte     0x7C,0x7C  #/* 0111110001111100 */
.byte     0xF8,0x3C  #/* 1111100000111100 */
.byte     0xF0,0x1C  #/* 1111000000011100 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x00  #/* 1111000000000000 */
.byte     0xF0,0x1C  #/* 1111000000011100 */
.byte     0xF8,0x3C  #/* 1111100000111100 */
.byte     0x7C,0x7C  #/* 0111110001111100 */
.byte     0x3F,0xF8  #/* 0011111111111000 */
.byte     0x1F,0xF0  #/* 0001111111110000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */


#     * code=68, hex=0x44, ascii="D"
D:
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0xFF,0xC0  #/* 1111111111000000 */
.byte     0xFF,0xE0  #/* 1111111111100000 */
.byte     0x3C,0xF0  #/* 0011110011110000 */
.byte     0x3C,0x78  #/* 0011110001111000 */
.byte     0x3C,0x78  #/* 0011110001111000 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x78  #/* 0011110001111000 */
.byte     0x3C,0x78  #/* 0011110001111000 */
.byte     0x3C,0xF0  #/* 0011110011110000 */
.byte     0xFF,0xE0  #/* 1111111111100000 */
.byte     0xFF,0xC0  #/* 1111111111000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */


#     * code=69, hex=0x45, ascii="E"
E:
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0xFF,0xFC  #/* 1111111111111100 */
.byte     0xFF,0xFC  #/* 1111111111111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x1C  #/* 0011110000011100 */
.byte     0x3C,0x0C  #/* 0011110000001100 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0xC0  #/* 0011110011000000 */
.byte     0x3C,0xC0  #/* 0011110011000000 */
.byte     0x3F,0xC0  #/* 0011111111000000 */
.byte     0x3F,0xC0  #/* 0011111111000000 */
.byte     0x3C,0xC0  #/* 0011110011000000 */
.byte     0x3C,0xC0  #/* 0011110011000000 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0x0C  #/* 0011110000001100 */
.byte     0x3C,0x1C  #/* 0011110000011100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0xFF,0xFC  #/* 1111111111111100 */
.byte     0xFF,0xFC  #/* 1111111111111100 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */


#     * code=70, hex=0x46, ascii="F"
F:
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0xFF,0xFC  #/* 1111111111111100 */
.byte     0xFF,0xFC  #/* 1111111111111100 */
.byte     0x3C,0x3C  #/* 0011110000111100 */
.byte     0x3C,0x1C  #/* 0011110000011100 */
.byte     0x3C,0x0C  #/* 0011110000001100 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0xC0  #/* 0011110011000000 */
.byte     0x3C,0xC0  #/* 0011110011000000 */
.byte     0x3F,0xC0  #/* 0011111111000000 */
.byte     0x3F,0xC0  #/* 0011111111000000 */
.byte     0x3C,0xC0  #/* 0011110011000000 */
.byte     0x3C,0xC0  #/* 0011110011000000 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0x3C,0x00  #/* 0011110000000000 */
.byte     0xFF,0x00  #/* 1111111100000000 */
.byte     0xFF,0x00  #/* 1111111100000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */
.byte     0x00,0x00  #/* 0000000000000000 */


#     * code=71, hex=0x47, ascii="G"
G:
.byte     0x00,0x00  #  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x1F,0xF0  #,  /* 0001111111110000 */
.byte     0x3F,0xF8  #,  /* 0011111111111000 */
.byte     0x7C,0x7C  #,  /* 0111110001111100 */
.byte     0xF8,0x3C  #,  /* 1111100000111100 */
.byte     0xF0,0x1C  #,  /* 1111000000011100 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF1,0xFC  #,  /* 1111000111111100 */
.byte     0xF1,0xFC  #,  /* 1111000111111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x3C  #,  /* 1111100000111100 */
.byte     0x7C,0x7C  #,  /* 0111110001111100 */
.byte     0x3F,0xFC  #,  /* 0011111111111100 */
.byte     0x1F,0xEC  #,  /* 0001111111101100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=72, hex=0x48, ascii="H"
H:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#   * code=73, hex=0x49, ascii="I"
I:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=74, hex=0x4A, ascii="J"
J:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x03,0xFC  #,  /* 0000001111111100 */
.byte     0x03,0xFC  #,  /* 0000001111111100 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF9,0xF0  #,  /* 1111100111110000 */
.byte     0x7F,0xE0  #,  /* 0111111111100000 */
.byte     0x3F,0xC0  #,  /* 0011111111000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=75, hex=0x4B, ascii="K"
K: 
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3C,0xF8  #,  /* 0011110011111000 */
.byte     0x3D,0xF0  #,  /* 0011110111110000 */
.byte     0x3F,0xE0  #,  /* 0011111111100000 */
.byte     0x3F,0xC0  #,  /* 0011111111000000 */
.byte     0x3F,0xC0  #,  /* 0011111111000000 */
.byte     0x3F,0xE0  #,  /* 0011111111100000 */
.byte     0x3D,0xF0  #,  /* 0011110111110000 */
.byte     0x3C,0xF8  #,  /* 0011110011111000 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=76, hex=0x4C, ascii="L"
L:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x0C  #,  /* 0011110000001100 */
.byte     0x3C,0x1C  #,  /* 0011110000011100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=77, hex=0x4D, ascii="M"
M:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xFC,0xFC  #,  /* 1111110011111100 */
.byte     0xFC,0xFC  #,  /* 1111110011111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=78, hex=0x4E, ascii="N"
N:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x3C  #,  /* 1111100000111100 */
.byte     0xF8,0x3C  #,  /* 1111100000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0xFE,0x3C  #,  /* 1111111000111100 */
.byte     0xFE,0x3C  #,  /* 1111111000111100 */
.byte     0xFF,0x3C  #,  /* 1111111100111100 */
.byte     0xFF,0x3C  #,  /* 1111111100111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF3,0xFC  #,  /* 1111001111111100 */
.byte     0xF3,0xFC  #,  /* 1111001111111100 */
.byte     0xF1,0xFC  #,  /* 1111000111111100 */
.byte     0xF1,0xFC  #,  /* 1111000111111100 */
.byte     0xF0,0xFC  #,  /* 1111000011111100 */
.byte     0xF0,0xFC  #,  /* 1111000011111100 */
.byte     0xF0,0x7C  #,  /* 1111000001111100 */
.byte     0xF0,0x7C  #,  /* 1111000001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=79, hex=0x4F, ascii="O"
O:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=80, hex=0x50, ascii="P"
P:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFF,0xF0  #,  /* 1111111111110000 */
.byte     0xFF,0xF8  #,  /* 1111111111111000 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3F,0xF8  #,  /* 0011111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=81, hex=0x51, ascii="Q"
Q:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0xBC  #,  /* 1111001110111100 */
.byte     0xF3,0xFC  #,  /* 1111001111111100 */
.byte     0xF9,0xFC  #,  /* 1111100111111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0xE0  #,  /* 0000000011100000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0x7C  #,  /* 0000000001111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=82, hex=0x52, ascii="R"
R:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFF,0xF0  #,  /* 1111111111110000 */
.byte     0xFF,0xF8  #,  /* 1111111111111000 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3F,0xF8  #,  /* 0011111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x3F,0xE0  #,  /* 0011111111100000 */
.byte     0x3D,0xF0  #,  /* 0011110111110000 */
.byte     0x3C,0xF8  #,  /* 0011110011111000 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=83, hex=0x53, ascii="S"
S:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0x78,0x00  #,  /* 0111100000000000 */
.byte     0x3F,0x00  #,  /* 0011111100000000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x03,0xF0  #,  /* 0000001111110000 */
.byte     0x00,0x78  #,  /* 0000000001111000 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=84, hex=0x54, ascii="T"
T:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xC7,0x8C  #,  /* 1100011110001100 */
.byte     0xC7,0x8C  #,  /* 1100011110001100 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=85, hex=0x55, ascii="U"
U:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=86, hex=0x56, ascii="V"
V:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7C,0xF8  #,  /* 0111110011111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x03,0x00  #,  /* 0000001100000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=87, hex=0x57, ascii="W"
W:   
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0x7C,0xF8  #,  /* 0111110011111000 */
.byte     0x7C,0xF8  #,  /* 0111110011111000 */
.byte     0x38,0x70  #,  /* 0011100001110000 */
.byte     0x38,0x70  #,  /* 0011100001110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=88, hex=0x58, ascii="X"
X:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x78,0x78  #,  /* 0111100001111000 */
.byte     0x78,0x78  #,  /* 0111100001111000 */
.byte     0x3C,0xF0  #,  /* 0011110011110000 */
.byte     0x3C,0xF0  #,  /* 0011110011110000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x3C,0xF0  #,  /* 0011110011110000 */
.byte     0x3C,0xF0  #,  /* 0011110011110000 */
.byte     0x78,0x78  #,  /* 0111100001111000 */
.byte     0x78,0x78  #,  /* 0111100001111000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=89, hex=0x59, ascii="Y"
Y:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3E,0x7C  #,  /* 0011111001111100 */
.byte     0x1F,0xF8  #,  /* 0001111111111000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x07,0xE0  #,  /* 0000011111100000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=90, hex=0x5A, ascii="Z"
Z:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xE0,0x3C  #,  /* 1110000000111100 */
.byte     0xC0,0x3C  #,  /* 1100000000111100 */
.byte     0x00,0x7C  #,  /* 0000000001111100 */
.byte     0x00,0xF8  #,  /* 0000000011111000 */
.byte     0x01,0xF0  #,  /* 0000000111110000 */
.byte     0x03,0xE0  #,  /* 0000001111100000 */
.byte     0x07,0xC0  #,  /* 0000011111000000 */
.byte     0x0F,0x80  #,  /* 0000111110000000 */
.byte     0x1F,0x00  #,  /* 0001111100000000 */
.byte     0x3E,0x00  #,  /* 0011111000000000 */
.byte     0x7C,0x00  #,  /* 0111110000000000 */
.byte     0xF8,0x00  #,  /* 1111100000000000 */
.byte     0xF0,0x0C  #,  /* 1111000000001100 */
.byte     0xF0,0x1C  #,  /* 1111000000011100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */




#     * code=91, hex=0x5B, ascii="["
sqbracketo:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x0F,0xF0  #,  /* 0000111111110000 */
.byte    0x0F,0xF0  #,  /* 0000111111110000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0xF0  #,  /* 0000111111110000 */
.byte    0x0F,0xF0  #,  /* 0000111111110000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=92, hex=0x5C, ascii="\"
backslash:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0xF0,0x00  #,  /* 1111000000000000 */
.byte    0xF0,0x00  #,  /* 1111000000000000 */
.byte    0x78,0x00  #,  /* 0111100000000000 */
.byte    0x78,0x00  #,  /* 0111100000000000 */
.byte    0x3C,0x00  #,  /* 0011110000000000 */
.byte    0x3C,0x00  #,  /* 0011110000000000 */
.byte    0x1E,0x00  #,  /* 0001111000000000 */
.byte    0x1E,0x00  #,  /* 0001111000000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0x78  #,  /* 0000000001111000 */
.byte    0x00,0x78  #,  /* 0000000001111000 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x3C  #,  /* 0000000000111100 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=93, hex=0x5D, ascii="]"
sqbracketc:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x0F,0xF0  #,  /* 0000111111110000 */
.byte    0x0F,0xF0  #,  /* 0000111111110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x00,0xF0  #,  /* 0000000011110000 */
.byte    0x0F,0xF0  #,  /* 0000111111110000 */
.byte    0x0F,0xF0  #,  /* 0000111111110000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=94, hex=0x5E, ascii="^"
power:
.byte    0x03,0x00  #,  /* 0000001100000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x0F,0xC0  #,  /* 0000111111000000 */
.byte    0x1F,0xE0  #,  /* 0001111111100000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x78,0x78  #,  /* 0111100001111000 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xE0,0x1C  #,  /* 1110000000011100 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=95, hex=0x5F, ascii="_"
underscore:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0xFF,0xFF  #,  /* 1111111111111111 */
.byte    0xFF,0xFF  #,  /* 1111111111111111 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=96, hex=0x60, ascii="`"
upostrophy:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x00  #,  /* 0000111100000000 */
.byte    0x0F,0x80  #,  /* 0000111110000000 */
.byte    0x07,0xC0  #,  /* 0000011111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=97, hex=0x61, ascii="a"
a:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xC0  #,  /* 0011111111000000 */
.byte     0x3F,0xE0  #,  /* 0011111111100000 */
.byte     0x01,0xF0  #,  /* 0000000111110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF0  #,  /* 0111111111110000 */
.byte     0xF8,0xF0  #,  /* 1111100011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF9,0xF0  #,  /* 1111100111110000 */
.byte     0x7F,0xFC  #,  /* 0111111111111100 */
.byte     0x3F,0x3C  #,  /* 0011111100111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=98, hex=0x62, ascii="b"
b:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFC,0x00  #,  /* 1111110000000000 */
.byte     0xFC,0x00  #,  /* 1111110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3F,0x80  #,  /* 0011111110000000 */
.byte     0x3F,0xE0  #,  /* 0011111111100000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x3C,0xF8  #,  /* 0011110011111000 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3F,0xF8  #,  /* 0011111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=99, hex=0x63, ascii="c"
c:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=100, hex=0x64, ascii="d"
d:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x03,0xF0  #,  /* 0000001111110000 */
.byte     0x03,0xF0  #,  /* 0000001111110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x1F,0xF0  #,  /* 0001111111110000 */
.byte     0x3C,0xF0  #,  /* 0011110011110000 */
.byte     0x78,0xF0  #,  /* 0111100011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0x79,0xF0  #,  /* 0111100111110000 */
.byte     0x3F,0xFC  #,  /* 0011111111111100 */
.byte     0x1F,0x3C  #,  /* 0001111100111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=101, hex=0x65, ascii="e"
e:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x00  #,  /* 1111000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=102, hex=0x66, ascii="f"
f:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x3C,0xF0  #,  /* 0011110011110000 */
.byte     0x3C,0x70  #,  /* 0011110001110000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=103, hex=0x67, ascii="g"
g:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0x3C  #,  /* 0011111100111100 */
.byte     0x7F,0xFC  #,  /* 0111111111111100 */
.byte     0xF9,0xF0  #,  /* 1111100111110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF8,0xF0  #,  /* 1111100011110000 */
.byte     0x7F,0xF0  #,  /* 0111111111110000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF9,0xF0  #,  /* 1111100111110000 */
.byte     0x7F,0xE0  #,  /* 0111111111100000 */
.byte     0x3F,0xC0  #,  /* 0011111111000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=104, hex=0x68, ascii="h"
h:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFC,0x00  #,  /* 1111110000000000 */
.byte     0xFC,0x00  #,  /* 1111110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0xF0  #,  /* 0011110011110000 */
.byte     0x3F,0xF8  #,  /* 0011111111111000 */
.byte     0x3F,0xFC  #,  /* 0011111111111100 */
.byte     0x3F,0x3C  #,  /* 0011111100111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=105, hex=0x69, ascii="i"
i:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x1F,0x80  #,  /* 0001111110000000 */
.byte     0x1F,0x80  #,  /* 0001111110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=106, hex=0x6A, ascii="j"
j:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0xFC  #,  /* 0000000011111100 */
.byte     0x00,0xFC  #,  /* 0000000011111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3E,0x7C  #,  /* 0011111001111100 */
.byte     0x1F,0xF8  #,  /* 0001111111111000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=107, hex=0x6B, ascii="k"
k:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFC,0x00  #,  /* 1111110000000000 */
.byte     0xFC,0x00  #,  /* 1111110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3C,0xF8  #,  /* 0011110011111000 */
.byte     0x3D,0xF0  #,  /* 0011110111110000 */
.byte     0x3F,0xE0  #,  /* 0011111111100000 */
.byte     0x3F,0xC0  #,  /* 0011111111000000 */
.byte     0x3F,0xC0  #,  /* 0011111111000000 */
.byte     0x3F,0xE0  #,  /* 0011111111100000 */
.byte     0x3D,0xF0  #,  /* 0011110111110000 */
.byte     0x3C,0xF8  #,  /* 0011110011111000 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0xFC,0x3C  #,  /* 1111110000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=108, hex=0x6C, ascii="l"
l:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x1F,0x80  #,  /* 0001111110000000 */
.byte     0x1F,0x80  #,  /* 0001111110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x07,0x80  #,  /* 0000011110000000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=109, hex=0x6D, ascii="m"
m:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFC,0xF0  #,  /* 1111110011110000 */
.byte     0xFF,0xF8  #,  /* 1111111111111000 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=110, hex=0x6E, ascii="n"
n:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF3,0xF0  #,  /* 1111001111110000 */
.byte     0xFF,0xF8  #,  /* 1111111111111000 */
.byte     0x3E,0x7C  #,  /* 0011111001111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=111, hex=0x6F, ascii="o"
o:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=112, hex=0x70, ascii="p"
p:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF3,0xF0  #,  /* 1111001111110000 */
.byte     0xFF,0xF8  #,  /* 1111111111111000 */
.byte     0x3E,0x7C  #,  /* 0011111001111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x7C  #,  /* 0011110001111100 */
.byte     0x3F,0xF8  #,  /* 0011111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=113, hex=0x71, ascii="q"
q: 
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0x3C  #,  /* 0011111100111100 */
.byte     0x7F,0xFC  #,  /* 0111111111111100 */
.byte     0xF9,0xF0  #,  /* 1111100111110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF8,0xF0  #,  /* 1111100011110000 */
.byte     0x7F,0xF0  #,  /* 0111111111110000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x00,0xF0  #,  /* 0000000011110000 */
.byte     0x03,0xFC  #,  /* 0000001111111100 */
.byte     0x03,0xFC  #,  /* 0000001111111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=114, hex=0x72, ascii="r"
r:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF3,0xF0  #,  /* 1111001111110000 */
.byte     0xFF,0xF8  #,  /* 1111111111111000 */
.byte     0x3F,0x7C  #,  /* 0011111101111100 */
.byte     0x3E,0x3C  #,  /* 0011111000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0x3C,0x00  #,  /* 0011110000000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0xFF,0x00  #,  /* 1111111100000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=115, hex=0x73, ascii="s"
s:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0xF0,0x7C  #,  /* 1111000001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x78,0x00  #,  /* 0111100000000000 */
.byte     0x3E,0x00  #,  /* 0011111000000000 */
.byte     0x1F,0x80  #,  /* 0001111110000000 */
.byte     0x07,0xE0  #,  /* 0000011111100000 */
.byte     0x01,0xF0  #,  /* 0000000111110000 */
.byte     0x00,0x78  #,  /* 0000000001111000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x3C  #,  /* 1111100000111100 */
.byte     0x7F,0xF8  #,  /* 0111111111111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=116, hex=0x74, ascii="t"
t:  
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x01,0x00  #,  /* 0000000100000000 */
.byte     0x03,0x00  #,  /* 0000001100000000 */
.byte     0x07,0x00  #,  /* 0000011100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0xFF,0xF0  #,  /* 1111111111110000 */
.byte     0xFF,0xF0  #,  /* 1111111111110000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x00  #,  /* 0000111100000000 */
.byte     0x0F,0x1C  #,  /* 0000111100011100 */
.byte     0x0F,0xBC  #,  /* 0000111110111100 */
.byte     0x07,0xF8  #,  /* 0000011111111000 */
.byte     0x03,0xF0  #,  /* 0000001111110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=117, hex=0x75, ascii="u"
u:     
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF0,0xF0  #,  /* 1111000011110000 */
.byte     0xF9,0xF0  #,  /* 1111100111110000 */
.byte     0x7F,0xFC  #,  /* 0111111111111100 */
.byte     0x3F,0x3C  #,  /* 0011111100111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=118, hex=0x76, ascii="v"
v:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3C,0x3C  #,  /* 0011110000111100 */
.byte     0x3E,0x7C  #,  /* 0011111001111100 */
.byte     0x1F,0xF8  #,  /* 0001111111111000 */
.byte     0x0F,0xF0  #,  /* 0000111111110000 */
.byte     0x07,0xE0  #,  /* 0000011111100000 */
.byte     0x03,0xC0  #,  /* 0000001111000000 */
.byte     0x01,0x80  #,  /* 0000000110000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=119, hex=0x77, ascii="w"
w:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF3,0x3C  #,  /* 1111001100111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xF7,0xBC  #,  /* 1111011110111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0x7C,0xF8  #,  /* 0111110011111000 */
.byte     0x38,0x70  #,  /* 0011100001110000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=120, hex=0x78, ascii="x"
x:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0x7C,0xF8  #,  /* 0111110011111000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x0F,0xC0  #,  /* 0000111111000000 */
.byte     0x1F,0xE0  #,  /* 0001111111100000 */
.byte     0x3F,0xF0  #,  /* 0011111111110000 */
.byte     0x7C,0xF8  #,  /* 0111110011111000 */
.byte     0xF8,0x7C  #,  /* 1111100001111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=121, hex=0x79, ascii="y"
y:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xF8,0x3C  #,  /* 1111100000111100 */
.byte     0x7F,0xFC  #,  /* 0111111111111100 */
.byte     0x3F,0xFC  #,  /* 0011111111111100 */
.byte     0x00,0x3C  #,  /* 0000000000111100 */
.byte     0x00,0x7C  #,  /* 0000000001111100 */
.byte     0x00,0xF8  #,  /* 0000000011111000 */
.byte     0x01,0xF0  #,  /* 0000000111110000 */
.byte     0xFF,0xE0  #,  /* 1111111111100000 */
.byte     0xFF,0xC0  #,  /* 1111111111000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=122, hex=0x7A, ascii="z"
z:
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xF0,0xF8  #,  /* 1111000011111000 */
.byte     0xF1,0xF0  #,  /* 1111000111110000 */
.byte     0x03,0xE0  #,  /* 0000001111100000 */
.byte     0x07,0xC0  #,  /* 0000011111000000 */
.byte     0x0F,0x80  #,  /* 0000111110000000 */
.byte     0x1F,0x00  #,  /* 0001111100000000 */
.byte     0x3E,0x00  #,  /* 0011111000000000 */
.byte     0x7C,0x00  #,  /* 0111110000000000 */
.byte     0xF8,0x3C  #,  /* 1111100000111100 */
.byte     0xF0,0x3C  #,  /* 1111000000111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0xFF,0xFC  #,  /* 1111111111111100 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */
.byte     0x00,0x00  #,  /* 0000000000000000 */


#     * code=123, hex=0x7B, ascii="{"
curlyo:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0xFC  #,  /* 0000000011111100 */
.byte    0x01,0xFC  #,  /* 0000000111111100 */
.byte    0x03,0xE0  #,  /* 0000001111100000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x3F,0x00  #,  /* 0011111100000000 */
.byte    0x3F,0x00  #,  /* 0011111100000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xE0  #,  /* 0000001111100000 */
.byte    0x01,0xFC  #,  /* 0000000111111100 */
.byte    0x00,0xFC  #,  /* 0000000011111100 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=124, hex=0x7C, ascii="|"
sslash:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=125, hex=0x7D, ascii="}"
curlyc:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x3F,0x00  #,  /* 0011111100000000 */
.byte    0x3F,0x80  #,  /* 0011111110000000 */
.byte    0x07,0xC0  #,  /* 0000011111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x00,0xFC  #,  /* 0000000011111100 */
.byte    0x00,0xFC  #,  /* 0000000011111100 */
.byte    0x01,0xE0  #,  /* 0000000111100000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x03,0xC0  #,  /* 0000001111000000 */
.byte    0x07,0xC0  #,  /* 0000011111000000 */
.byte    0x3F,0x80  #,  /* 0011111110000000 */
.byte    0x3F,0x00  #,  /* 0011111100000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=126, hex=0x7E, ascii="~"
tidle:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x3C,0x1C  #,  /* 0011110000011100 */
.byte    0x7F,0x3C  #,  /* 0111111100111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xF3,0xF8  #,  /* 1111001111111000 */
.byte    0xE0,0xF0  #,  /* 1110000011110000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=127, hex=0x7F, ascii="^?"
house:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x03,0x00  #,  /* 0000001100000000 */
.byte    0x07,0x80  #,  /* 0000011110000000 */
.byte    0x0F,0xC0  #,  /* 0000111111000000 */
.byte    0x1F,0xE0  #,  /* 0001111111100000 */
.byte    0x3F,0xF0  #,  /* 0011111111110000 */
.byte    0x7C,0xF8  #,  /* 0111110011111000 */
.byte    0xF8,0x7C  #,  /* 1111100001111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xF0,0x3C  #,  /* 1111000000111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0xFF,0xFC  #,  /* 1111111111111100 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */


#     * code=248, hex=0xF8, ascii="!x" degree^0
celcius:
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x0F,0xC0  #,  /* 0000111111000000 */
.byte    0x1F,0xE0  #,  /* 0001111111100000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x3C,0xF0  #,  /* 0011110011110000 */
.byte    0x1F,0xE0  #,  /* 0001111111100000 */
.byte    0x0F,0xC0  #,  /* 0000111111000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */
.byte    0x00,0x00  #,  /* 0000000000000000 */





