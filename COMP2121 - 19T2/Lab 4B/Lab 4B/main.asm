;Board settings: 
;Connect the four columns C0~C3 of the keypad to PL3~PL0 of PORTL and the four rows R0~R3 to PL7~PL4 of PORTL.
;Connect LED0~LED7 of LEDs to PC0~PC7 of PORTC.

; For I/O registers located in extended I/O map, "IN", "OUT", "SBIS", "SBIC", 
; "CBI", and "SBI" instructions must be replaced with instructions that allow access to 
; extended I/O. Typically "LDS" and "STS" combined with "SBRS", "SBRC", "SBR", and "CBR".

.include "m2560def.inc"
.def temp =r16
.def row =r17
.def col =r18
.def mask =r19
.def temp2 =r20
.equ PORTLDIR = 0xF0
.equ INITCOLMASK = 0xEF
.equ INITROWMASK = 0x01
.equ ROWMASK = 0x0F

.def Char_Count = r21 /////////////////////BRUTE FORCE TECH
.equ AsciiNum = 0b00110000
.equ AsciiLetter = 0b01000000
.equ AsciiHash = 0b00100011
.equ AsciiStar = 0b00101010

.equ F_CPU = 16000000
.equ DELAY_COUNTER = F_CPU / 4 / 100 - 4

//=== Macro for LCD display ===\\
.macro clear;load in and clear 2 bytes of data
	ldi YL, low(@0)
	ldi YH, high(@0)
	clr temp
	st Y+, temp
	st Y, temp
.endmacro

.macro do_lcd_command ;port in a command
	ldi temp, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro

.macro do_lcd_command_register ;reg friendly ver.
	mov temp, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro

.macro do_lcd_data ;write out data
	ldi temp, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro do_lcd_data_register ;reg friendly ver.
	mov temp, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.cseg
jmp RESET

.org 0x72
RESET:
	//Stack frame
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	//Keypad set up
	ldi temp, PORTLDIR ; columns are outputs, rows are inputs
	STS DDRL, temp     ; cannot use out
	
	//LCD pin set up
	ser temp
	out DDRF, temp ;lcd pins as out
	out DDRA, temp ;lcd control pins as out
	clr temp
	out PORTF, temp ;lcd display as clear
	out PORTA, temp ;lcd control as not writing or enabled

	//LCD set up
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00001000 ; display off?
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink

	clr char_count

main:
	ldi mask, INITCOLMASK ;set mask to 0 only column 1/bit5
	clr col ; clear column counter

colloop:
	STS PORTL, mask ; set column to mask value

	ldi temp, 0xFF ; implement a delay so the
delay: ; hardware can stabilize
	dec temp
	brne delay
	LDS temp, PINL ;Intake the keypad reg values 
	andi temp, ROWMASK ; read only the row bits
	cpi temp, 0xF ; check if any rows are grounded
	breq nextcol ; if not go to the next column
	ldi mask, INITROWMASK ; initialise row check
	clr row ; initial row

rowloop:      
	mov temp2, temp
	and temp2, mask ; check masked bit
	brne skipconv ; if the result is non-zero, we need to look again
	rcall convert ; if bit is clear, convert the bitcode and start again
	jmp main

skipconv:
	inc row ; else move to the next row
	lsl mask ; shift the mask to the next bit
	jmp rowloop

nextcol:     
	cpi col, 3 ; check if we're on the last column
	breq main ; if so, no buttons were pushed, so start again.

	sec ; else shift the column mask, we must set the carry bit
	rol mask ; and then rotate left by a bit, shifting the carry into bit zero. We need this to make sure all the rows have pull-up resistors
	inc col ; increment column value
	jmp colloop ; and check the next column
	

	;convert function converts the row and column given to a binary number and also outputs the value to PORTC.
	; Inputs come from registers row and col and output is in temp.
convert:
	cpi col, 3 ; if column is 3 we have a letter
	breq letters
	cpi row, 3 ; if row is 3 we have a symbol or 0
	breq symbols
	mov temp, row ; otherwise we have a number (1-9)
	lsl temp ; temp = row * 2
	add temp, row ; temp = row * 3
	add temp, col ; add the column address
	; to get the offset from 1
	inc temp ; add 1. Value of switch is
	; row*3 + col + 1.
	ldi temp2, AsciiNum
	add temp, temp2
	jmp convert_end

letters:
	clr temp
	inc temp
	add temp, row ; increment from 0xA by the row value
	ldi temp2, AsciiLetter
	add temp, temp2
	jmp convert_end

symbols:
	cpi col, 0 ; check if we have a star
	breq star
	cpi col, 1 ; or if we have zero
	breq zero
	ldi temp, AsciiHash ; we'll output 0xF for hash
	jmp convert_end

star:
	ldi temp, AsciiStar ; we'll output 0xE for star
	jmp convert_end

zero:
	ldi temp, AsciiNum ; set to zero

convert_end:
	do_lcd_data_register temp ; write value to LCD
	
	inc char_count
	cpi char_count, 16
	breq line2
	cpi char_count, 32
	breq line1
	rjmp convert_cont

	line1:
		do_lcd_command 0b10
		clr char_count
		rjmp convert_cont

	line2:
		do_lcd_command 0b11000000 ;go to line two which starts at pos 0x40

	convert_cont:
	call delay_30ms
	ret ; return to caller

//=== LCD screen commands ===\\\
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4

.macro lcd_set
	sbi PORTA, @0
.endmacro
.macro lcd_clr
	cbi PORTA, @0
.endmacro

; Send a command to the LCD (temp)
lcd_command:
	out PORTF, temp
	nop
	lcd_set LCD_E
	nop
	nop
	nop
	lcd_clr LCD_E
	nop
	nop
	nop
	ret

lcd_data:
	out PORTF, temp
	lcd_set LCD_RS
	nop
	nop
	nop
	lcd_set LCD_E
	nop
	nop
	nop
	lcd_clr LCD_E
	nop
	nop
	nop
	lcd_clr LCD_RS
	ret

lcd_wait:
	push temp
	clr temp
	out DDRF, temp
	out PORTF, temp
	lcd_set LCD_RW
lcd_wait_loop:
	nop
	lcd_set LCD_E
	nop
	nop
    nop
	in temp, PINF
	lcd_clr LCD_E
	sbrc temp, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser temp
	out DDRF, temp
	pop temp
	ret

delay_30ms:
	push r24
	ldi r24, 30
	delay_loop_loop:
	rcall delay_10ms
	dec r24
	brne delay_loop_loop
	pop r24
	ret

delay_10ms: ;80000c
	;out PORTC, temp
	;prologue
	push r24 ;2c
	push r25 ;2c
	ldi r25, high(Delay_Counter) ;1c
	ldi r24, low(Delay_Counter) ;1c

	delay_loop:
		sbiw r25:r24, 1 ;2c
		brne delay_loop ;2c if looping 1c if pass through
		pop r25 ;2c
		pop r24 ;2c
		nop ;1c
		nop ;1c
		nop ;1c
		ret ;4c