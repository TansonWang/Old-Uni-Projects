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

.def calcFlags = r22 ;[Syn, Over, Sign/Num, Add, Sub]
.def currL = r23
.def currH = r24
.def totalL = r25
.def totalH = r26
.def tempH = r15
.def tempL = r14

.def Counter = r21 /////////////////////BRUTE FORCE TECH
.equ AsciiNum = 0b00110000
.equ AsciiLetter = 0b01000000
.equ AsciiHash = 0b00100011
.equ AsciiStar = 0b00101010
.equ AsciiPlus = 0b00101011
.equ AsciiMinus = 0b00101101
.equ AsciiEqual = 0b00111101
.equ AsciiLetterD = 0b01000100

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

//=== Macro for Maths ===\\
.macro Numx10_add ;NumH, NumL, temp2
	clr temp2
    sbrc @0, 7
    inc temp2 ;is one if neg value

	;Num << 3
    lsl r14
    rol r15
    lsl r14
    rol r15
    lsl r14
    rol r15

	;Num << 1
    lsl @1
    rol @0

	; << 8 + << 1 = x10
    add @1, r14
    adc @0, r15

	;x10 + temp
	add @1, @2
	clr r14
	adc @0, r14


    sbrc temp2, 0
    sbr temp2, 0b10000000 ;set bit 7
	mov @0, temp2

.endmacro

.macro division
	clr temp2
	ldi temp, 10
	clr r17
	clr r18

	fat_loop:
		cp totalL, temp
		cpc totalH, temp2
		brlo sub_loop

		lsl temp
		ror temp2
		rjmp fat_loop
	
	sub_loop:
		cpi temp, 10
		clr r13
		cpc temp2, r13
		brlo division_end

		cp totalL, temp
		cpc totalH, temp2
		brlo rightroll

		sub totalL, temp
		sbc totalH, temp2
		inc r17

		rjmp sub_loop

	rightroll:
		lds r15, AsciiNum
		add r17, r15
		do_lcd_data_register r17
		clr r17
		lsr temp
		ror temp2
		rjmp sub_loop
	division_end:
.endmacro

.macro equals
	do_lcd_data AsciiEqual

	sbrc calcFlags, 4 ;syn err
	jmp syntaxErr

	sbrc calcFlags, 3 ;over err
	jmp overflowErr

	sbrs totalH, 7 ;check neg
	jmp do_division ;pos

	;neg so print - and 2's com it
	do_lcd_data '-'
	com totalH
	neg totalL
	sbr calcFlags, 0b10000

	do_division:
		division
		sbrc calcFlags, 5
		jmp neg_cont
		jmp equals_end

		neg_cont:
			com totalH
			neg totalL
			jmp equals_end

	syntaxErr:
		do_lcd_data 'I'
		rcall LCD_full
		jmp equals_end

	overflowErr:
		do_lcd_data 'O'
		rcall LCD_full
		jmp equals_end

	equals_end:
	clr calcFlags
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

	clr counter
	clr calcFlags
	clr currH
	clr currL
	clr totalH
	clr totalL

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

;Subroutine
convert:
	cpi col, 3 ; if column is 3 we have a letter
	breq letters
	cpi row, 3 ; if row is 3 we have a symbol or 0
	breq symbols_relay
	mov temp, row ; otherwise we have a number (1-9)
	lsl temp ; temp = row * 2
	add temp, row ; temp = row * 3
	add temp, col ; add the column address
	; to get the offset from 1
	inc temp ; add 1. Value of switch is
	; row*3 + col + 1.

	Numx10_add currH, currL, temp
	ldi temp2, AsciiNum
	add temp, temp2
	jmp convert_end

symbols_relay:
	jmp symbols

letters:
	sbrc row, 3 ;end if d was pressed
	jmp whatishappening

	sbrc calcFlags, 2 ;if previous item was sign
	sbr calcFlags, 0b10000 ;syntax error
	sbr calcFlags, 0b10 ;is sign
	call executeSign
	cpi row, 0
	breq Letter_A
	cpi row, 1
	breq Letter_B
	cpi row, 2
	breq Letter_C
	ret

	Letter_A:
		sbr calcFlags, 0 ;subbing
		ldi temp, AsciiMinus
		jmp convert_end

	Letter_B:
		sbr calcFlags, 1 ;adding
		ldi temp, AsciiPlus
		jmp convert_end

	Letter_C:
		equals
		jmp whatishappening

symbols:
	cpi col, 1 ; or if we have zero
	breq zero
	ret

zero:
	clr temp
	Numx10_add currH, currL, temp
	ldi temp, AsciiNum ; set to zero
	jmp convert_end

convert_end:
	do_lcd_data_register temp ; write value to LCD
	call LCD_full
	whatishappening:
	call delay_30ms
	ret ; return to caller

executeSign:
	sbrc calcFlags, 0
	rjmp minus
	add totalL, currL
	adc totalH, currH
	brbc 3, executeSign_end
	sbr calcFlags, 3
	executeSign_end:
	ret

	minus:
		sub totalL, currL
		sbc totalH, currH
		brbc 3, executeSign_end
		sbr calcFlags, 3
		ret


;subroutine
LCD_full:
	inc counter
	cpi counter, 16
	breq go_2
	cpi counter, 32
	breq go_1
	ret

	go_1:
		lcd_clr LCD_RS
		lcd_clr LCD_RW
		do_lcd_command 0b1
		clr counter
		ret
	go_2:
		lcd_clr LCD_RS
		lcd_clr LCD_RW
		do_lcd_command 0b11000000
		ret

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