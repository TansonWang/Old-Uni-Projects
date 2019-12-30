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

.def totalL = r21
.def totalH = r22
.def currL = r23
.def currH = r24
.def calcFlags = r25 ;[SyntaxErr, OverflowErr, sign/num, Add, Sub, N/A, N/A, N/A]

.def Char_Count = r26 /////////////////////BRUTE FORCE TECH
.equ AsciiNum = 0b00110000 ;general case for num
.equ AsciiHash = 0b00100011
.equ AsciiStar = 0b00101010
.equ AsciiLetter = 0b01000000 ;general case for Letter
.equ AsciiPlus = 0b00101011
.equ AsciiMinus = 0b00101101
.equ AsciiEqual = 0b00111101
.equ AsciiLetterD = 0b01000100

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

.macro do_lcd_command_register
	mov temp, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro

.macro do_lcd_data ;write out data
	ldi temp, @0
	rcall lcd_data
	rcall lcd_wait
	rcall Full_Lcd
.endmacro

.macro do_lcd_data_register
	mov temp, @0
	rcall lcd_data
	rcall lcd_wait
	rcall Full_Lcd
	rcall delay_10ms
.endmacro

//=== Macro for Calculator ===\\
;Increase a signed num by a place, puts a signed num into H/L
;Uses r15, r14, r13
;Pushes temp, temp2
.macro Numx10 ;highnum, lownum
	push temp
	push temp2
	mov r15, @0
	mov r14, @1
    
    clr temp
    sbrc @0, 7
    inc temp ;is one if neg value

	do_multiply:
    lsl r14
    rol r15
    lsl r14
    rol r15
    lsl r14
    rol r15

    lsl @1
    rol @0

    add @1, r14
    adc @0, r15

    sbrc temp, 0
    sbr @0, 0b10000000 ;set bit 7
	pop temp2
	pop temp
.endmacro

.macro subtraction
	sub totalL, currL
	sbc totalH, currH
	brbc 3, subtraction_end ;overflow flag?
	sbr calcFlags, 0b100000 ;Set overflow err flag (6)

	subtraction_end:
.endmacro

.macro addition
	add totalL, currL
	adc totalH, currH
	brbc 3, addition_end ;overflow flag?
	sbr calcFlags, 0b100000 ;Set overflow err flag (6)

	Addition_end:
.endmacro

.macro equals
	do_lcd_data AsciiEqual ;print '='

	sbrc calcFlags, 5 ;skip if last item was num (0)
	jmp syntaxErr
	sbrc calcFlags, 7 ;skip if no syntax err flag
	jmp syntaxErr
	sbrc calcFlags, 6 ;skip if no overflow err flag
	jmp overflowErr

	;No errors? Check for neg
	sbrc totalH, 7 ;skip if not neg
	jmp neg_total

	;Not Err or Neg? Nice
	division
	jmp equals_end

	neg_total:
	do_lcd_data '-' ;print '-' for neg
	com totalH ;the first num is auto 0 so dw
	neg totalL
	division
	jmp equals_end

	syntaxErr:
		do_lcd_data 'I'
		do_lcd_data 'n'
		do_lcd_data 'c'/*
		do_lcd_data 'o'
		do_lcd_data 'r'
		do_lcd_data 'r'
		do_lcd_data 'e'
		do_lcd_data 'c'
		do_lcd_data 't'
		do_lcd_data ' '
		do_lcd_data 'e'
		do_lcd_data 'x'
		do_lcd_data 'p'
		do_lcd_data 'r'
		do_lcd_data 'e'
		do_lcd_data 's'
		do_lcd_data 's'
		do_lcd_data 'i'
		do_lcd_data 'o'
		do_lcd_data 'n'*/
		jmp equals_end

	overflowErr:
		do_lcd_data 'O'
		do_lcd_data 'v'
		do_lcd_data 'e'
		do_lcd_data 'r'
		do_lcd_data 'f'
		do_lcd_data 'l'
		do_lcd_data 'o'
		do_lcd_data 'w'
		do_lcd_data ' '
		do_lcd_data 'o'
		do_lcd_data 'c'
		do_lcd_data 'c'
		do_lcd_data 'u'
		do_lcd_data 'r'
		do_lcd_data 'r'
		do_lcd_data 'e'
		do_lcd_data 'd'
		jmp equals_end

	equals_end:
.endmacro

.macro division
	do_lcd_data '?'

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

	ser temp
	out DDRC, temp ;set leds to output
	out PORTC, temp

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
	do_lcd_command 0b00110000 ; 1x5x7
	do_lcd_command 0b00110000 ; 1x5x7
	do_lcd_command 0b00110000 ; 1x5x7
	do_lcd_command 0b00110000 ; 1x5x7
	do_lcd_command 0b00110000 ; 1x5x7
	do_lcd_command 0b00001000 ; display off?
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink

	clr char_count
	clr totalL
	clr totalH
	clr currL 
	clr currH 
	clr calcFlags

main:
	ldi mask, INITCOLMASK ; initial column mask
	clr col ; initial column
colloop:
	STS PORTL, mask ; set column to mask value
	; (sets column 0 off)
	ldi temp, 0xFF ; implement a delay so the

delay: ; hardware can stabilize
	dec temp
	brne delay
	LDS temp, PINL ; read PORTL. Cannot use in 
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
	breq letters_relay
	cpi row, 3 ; if row is 3 we have a symbol or 0
	breq symbols
	mov temp, row ; otherwise we have a number (1-9)
	lsl temp ; temp = row * 2
	add temp, row ; temp = row * 3
	add temp, col ; add the column address
	; to get the offset from 1
	inc temp ; add 1. Value of switch is
	; row*3 + col + 1.

	;Increase current num by a mag and then add temp
	Numx10 currH, currL
	add currL, temp
	clr temp2
	adc currL, temp2
	cbr calcFlags, 0b10000 ;set (5) last item to num (0)

	ldi temp2, AsciiNum
	add temp, temp2
	jmp convert_end

letters_relay:
	jmp letters

symbols:
	sbrc col, 0 ;Is row 1? (0b01)
	jmp zero
	ret

	zero:
		cbr calcFlags, 0b10000 ;set (5) last item to num (0)
		Numx10 currH, currL
		ldi temp, AsciiNum ; set to zero
		jmp convert_end

letters: ;WIP
	call execute_addsub
	sbrc calcFlags, 5 ;Was the last in a num (0)
	sbr calcFlags, 0b10000000;No? T'was a syntax err (7)
	sbr calcFlags, 0b10000 ;Set (5) last item to expr. (1)

	cpi row, 1 ;Is it row 1? (B) (0b01)
	breq Letter_B
	cpi row, 0 ;Is it row 0? (A) (0b00)
	breq Letter_A
	cpi row, 2 ;Is it row 2? (C) (0b10)
	breq Letter_C

	sbr calcFlags, 0b10000000 ;D is an err
	ldi temp, AsciiLetterD
	rjmp letter_end

	Letter_A:
		sbr calcFlags, 3 ;set sub flag
		ldi temp, AsciiMinus
		jmp letter_end
	
	Letter_B:
		sbr calcFlags, 0b1000 ;set add flag (4)
		out portC, calcFlags
		ldi temp, AsciiPlus
		jmp letter_end

	Letter_C:
		equals
		jmp Wutishappening
	letter_end:
	jmp convert_end

convert_end:
	do_lcd_data_register temp ; write value to LCD
	Wutishappening:
	call delay_30ms
	out PORTC, calcFlags
	ret ; return to caller

execute_addsub:
	sbrc calcFlags, 4 ;If add flag set
	addition
	sbrc calcFlags, 3 ;If sub flag set
	subtraction

	cbr calcFlags, 0b1000 ;Clr add (4) and sub (3) flags
	cbr calcFlags, 0b100 ;So it will be set afresh
	ret

Full_Lcd:
	inc char_count
	sbrc char_count, 5 ;if 16 or higher
	do_lcd_command 0b111 ;set lcd to shifting
	ret

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