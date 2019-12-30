;Board settings: 
;Connect the four columns C0~C3 of the keypad to PL3~PL0 of PORTL and the four rows R0~R3 to PL7~PL4 of PORTL.
;Connect LED0~LED7 of LEDs to PC0~PC7 of PORTC.

;For I/O registers located in extended I/O map, "IN", "OUT", "SBIS", "SBIC", 
;"CBI", and "SBI" instructions must be replaced with instructions that allow access to 
;extended I/O. Typically "LDS" and "STS" combined with "SBRS", "SBRC", "SBR", and "CBR".
//Defs\\
    .include "m2560def.inc"
    .def temp =r16
    .def row =r17
    .def col =r18
    .def mask =r19
    .def temp2 =r20
    .def totalL = r22
    .def totalH = r23
    .def CurrL = r24
    .def CurrH = r25
    .def CalcFlags = r26 ;[SyntaxErr, OverflowErr, sign/num, N/A, N/A, N/A, N/A, N/A]
    .equ PORTLDIR = 0xF0
    .equ INITCOLMASK = 0xEF
    .equ INITROWMASK = 0x01
    .equ ROWMASK = 0x0F

    .def Char_Count = r21 ;;;;;;;;;;BRUTE FORCE TECH
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
;load in and clear 2 bytes of data
.macro clear ;high byte, low byte
	ldi YL, low(@0)
	ldi YH, high(@0)
	clr temp
	st Y+, temp
	st Y, temp
.endmacro

;port in a command
.macro do_lcd_command ;command in hex
	ldi temp, @0
	rcall lcd_command
	rcall lcd_wait
	call delay_30ms
.endmacro

;same but for reg
.macro do_lcd_command_register ;reg with command
	mov temp, @0
	rcall lcd_command
	rcall lcd_wait
	call delay_30ms
.endmacro

;write out data onto the lcd, does Lcd_limit_check
.macro do_lcd_data ;data in ascii hex
	ldi temp, @0
	rcall lcd_data
	rcall lcd_wait
	call Lcd_limit_check
	call delay_30ms
.endmacro

;same but for reg, does Lcd_limit_check
.macro do_lcd_data_register ;reg with ascii hex
	mov temp, @0
	rcall lcd_data
	rcall lcd_wait
	call Lcd_limit_check
	call delay_30ms
.endmacro

;Print num as ascii
;Uses do_lcd_data_register
.macro print_asciiNum ;num
	push temp
	ldi temp, AsciiNum
	add temp, @0
	do_lcd_data_register temp
	pop temp
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
    sbr @0, 7
	pop temp2
	pop temp
.endmacro

;Subtracts two signed No., puts a signed No. into totalH/L
;Works with overflow err flag
;Uses r15, r14, r13, r12
.macro do_subtract ;totalH, totalL, CurrH, CurrL
	mov r15, @0
	mov r14, @1
	mov r13, @2
	mov r12, @3
 
	sub r14, r12
	sbc r15, r13
	cbr CalcFlags, 6 ;clear overflow err flag
	brbc 3, do_subtract_end ;skip to end if overflow flag not set
	sbr CalcFlags, 6 ;set overflow err flag

	do_subtract_end:
	mov @0, r15 ;set the new total value
	mov @1, r14
	clr @2 ;clear the value of curr
	clr @3
.endmacro

;Adds two signed No., puts a signed No. into totalH/L
;Works with overflow err flag
;Uses r15, r14, r13, r12
.macro do_addition ;totalH, totalL, CurrH, CurrL
	mov r15, @0
	mov r14, @1
	mov r13, @2
	mov r12, @3

	add r14, r12
	adc r15, r13
	cbr CalcFlags, 6 ;clear overflow err flag
	brbc 3, do_addition_end ;skip to end if overflow flag not set
	sbr CalcFlags, 6 ;set overflow err flag

	do_addition_end:
	mov @0, r15 ;set the new total value
	mov @1, r14
	clr @2 ;clear the value of curr
	clr @3
.endmacro

;Divides total by divisor and prints out each value + the remainder
;Does not account for neg numbers
;Uses Lcd_limit_check, print_asciiNum
;Pushes and uses temp, temp2, CurrL, CurrH, r17
.macro do_division ;totalH, totalL, DivisorH, DivisorL
	push temp
	push temp2
	push CurrL
	push CurrH
	push r17

	ldi r17, 0xF0
	mov temp, @1 ;totalL
	mov temp2, @0 ;totalH
	mov CurrL, @3 ;DivisorL
	mov CurrH, @2 ;DivisorH

	do_division_loop1: ;make the var divisor 1 pos too large
		cp temp, CurrL
		cpc temp2, CurrH
		brlo do_division_loop2

		lsl CurrL
		rol CurrH
		rjmp do_division_loop1

	do_division_loop2: ;dividend - divisor until done
		;If value is lower than org end sequence
		cp temp, @3 ;DivisorL
		cpc temp2, @2 ;DivisorH
		brlo do_division_end

		cp temp, CurrL ;check if divisor is in range
		cpc temp2, CurrH
		brlo rightroll

		sub temp, CurrL ;subtract divisor from dividend
		sbc temp2, CurrH
		inc r17 ;increase subtract counter

		rjmp do_division_loop2

	rightroll: ;roll the divisor back into range
		sbrs r17, 7 ;is it the first one?
		print_asciiNum r17 ;show all but the first sub no.
		clr r17 ;clear subtract counter
		lsr CurrL
		ror CurrH
		rjmp do_division_loop2

	do_division_end:
	print_asciiNum temp ;print the remainder
	do_lcd_data '#'

	pop r17
	pop CurrH
	pop CurrL
	pop temp2
	pop temp
.endmacro

;Checks flags and prints all necessary information
;Uses CalcFlags, do_division, do_lcd_data, lcd_limit_check
;Pushes temp, temp2
.macro do_equal ;totalH, totalL
    do_lcd_data 'A'
	ldi temp, AsciiEqual
	do_lcd_data_register temp

	sbrs CalcFlags, 7 ;check for syntax error
	jmp syntaxerror

do_lcd_data 'B'

	sbrc CalcFlags, 6 ;check for overflow error
	jmp OverflowError

do_lcd_data 'C'

	;No errors? Check for negative
	sbrs totalH, 7
	jmp do_equal_normal

	;Is negative so print a minus
	do_lcd_data '-'
	com totalH
	neg totalL
	sbr CalcFlags, 5

	;Use do_division
	do_equal_normal:
		ldi temp, 10
		clr temp2
		do_division totalH, totalL, temp2, temp

		sbrc CalcFlags, 5
		rjmp do_equal_negative_cont
		jmp do_equal_end

	do_equal_negative_cont:
		com totalH
		neg totalL
		jmp do_equal_end

	syntaxerror:
		do_lcd_data 'I'
		do_lcd_data 'n'
		do_lcd_data 'c'
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
		do_lcd_data 'n'
        jmp do_equal_end
	
	OverflowError:
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
		jmp do_equal_end

	do_equal_end:
	clr CalcFlags
.endmacro

.cseg
jmp RESET

.org 0x72
RESET:
	;Stack frame
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	;Keypad set up
	ldi temp, PORTLDIR ;columns are outputs, rows are inputs
	STS DDRL, temp     ;cannot use out
	
	;LCD pin set up
	ser temp
	out DDRF, temp ;lcd pins as out
	out DDRA, temp ;lcd control pins as out
	clr temp
	out PORTF, temp ;lcd display as clear
	out PORTA, temp ;lcd control as not writing or enabled

	;LCD set up
	do_lcd_command 0b00110000 ;1x5x7
	do_lcd_command 0b00110000 ;1x5x7
	do_lcd_command 0b00110000 ;1x5x7
	do_lcd_command 0b00110000 ;1x5x7
	do_lcd_command 0b00110000 ;1x5x7
	do_lcd_command 0b00001000 ;display off?
	do_lcd_command 0b00000001 ;clear display
	do_lcd_command 0b00000110 ;increment, no display shift
	do_lcd_command 0b00001110 ;Cursor on, bar, no blink

	clr char_count
	clr CalcFlags
    clr totalL
    clr totalH
    clr CurrL
    clr CurrH
    clr CalcFlags

//=== Keypad Checking and Manipulation ===\\
main:
	ldi mask, INITCOLMASK ;initial column mask
	clr col ;initial column
colloop:
	STS PORTL, mask ;set column to mask value
	;(sets column 0 off)
	ldi temp, 0xFF ;implement a delay so the

delay: ;hardware can stabilize
	dec temp
	brne delay
	LDS temp, PINL ;read PORTL. Cannot use in 
	andi temp, ROWMASK ;read only the row bits
	cpi temp, 0xF ;check if any rows are grounded
	breq nextcol ;if not go to the next column
	ldi mask, INITROWMASK ;initialise row check
	clr row ;initial row

rowloop:      
	mov temp2, temp
	and temp2, mask ;check masked bit
	brne skipconv ;if the result is non-zero, we need to look again
	rcall convert ;if bit is clear, convert the bitcode and start again
	jmp main

skipconv:
	inc row ;else move to the next row
	lsl mask ;shift the mask to the next bit
	jmp rowloop

nextcol:     
	cpi col, 3 ; check if we're on the last column
	breq main ;if so, no buttons were pushed, so start again.

	sec ;else shift the column mask, we must set the carry bit
	rol mask ;and then rotate left by a bit, shifting the carry into bit zero. We need this to make sure all the rows have pull-up resistors
	inc col ;increment column value
	jmp colloop ;and check the next column
	

	;convert function converts the row and column given to a binary number and also outputs the value to PORTC.
	;Inputs come from registers row and col and output is in temp.
convert:
	cpi col, 3 ;if column is 3 we have a letter
	breq letters
	cpi row, 3 ;if row is 3 we have a symbol or 0
	breq symbols_relay
	mov temp, row ;otherwise we have a number (1-9)
	lsl temp ;temp = row * 2
	add temp, row ;temp = row * 3
	add temp, col ;add the column address
	;to get the offset from 1
	inc temp ;add 1. Value of switch is
	;row*3 + col + 1.

	;change the value of current number
	clr temp2
	Numx10 CurrH, CurrL ;inc the stored num by one position
	add CurrL, temp ;then add the new num
	adc CurrH, temp2
	cbr CalcFlags, 5 ;set last item as number

	ldi temp2, AsciiNum
	add temp, temp2
	jmp convert_end

symbols_relay:
	jmp symbols

letters:
    sbr CalcFlags, 7 ;preset to a syntax error
	sbrs CalcFlags, 5 ;check if last item was an expression (1)
	cbr CalcFlags, 7 ;If not, not a syntax error
	sbr CalcFlags, 5 ;set last item to be expression

	cpi row, 0
	breq Letter_A
	cpi row, 1
	breq Letter_B
	cpi row, 2
	breq Letter_C
	sbr CalcFlags, 7 ; Syntax error
	ldi temp, AsciiLetterD ;D is an error
	jmp convert_end

Letter_A: ;Do_subtract
	do_subtract totalH, totalL, CurrH, CurrL
	ldi temp, AsciiMinus
	jmp convert_end

Letter_B: ;Do_addition
	do_addition totalH, totalL, CurrH, CurrL
	ldi temp, AsciiPlus
	jmp convert_end

Letter_C: ;Do_equal and ret
	do_equal totalH, totalL
	ret

symbols:
	cpi col, 1 ;or if we have zero
	breq zero
	sbr CalcFlags, 7;Star and Hash as Syntax Error
	cpi col, 0 ;check if we have a star
	breq star
	ldi temp, AsciiHash ;Hash is an error
	jmp convert_end

star:
	ldi temp, AsciiStar ;Star is an error
	jmp convert_end

zero:
	Numx10 CurrH, CurrL ;inc the stored num by one position
	cbr CalcFlags, 5 ;set last item to number
	ldi temp, AsciiNum ;set to zero

convert_end:
	do_lcd_data_register temp ;write value to LCD
	;call delay_30ms
	ret ;return to caller

;Check for lcd full -> shifting
;Uses Char_count
lcd_limit_check: ;N/A
	inc char_count
	cpi char_count, 16 ;if lcd full set to shifting
	brne lcd_limit_check_end
	do_lcd_command 0b111 ;set lcd to shifting
	lcd_limit_check_end:
	;do_lcd_data '@'
	ret

;=== LCD screen commands ===\\\
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

    ;Send a command to the LCD (temp)
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