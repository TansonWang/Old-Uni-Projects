; Board settings: 1. Connect LCD data pins D0-D7 to PORTF0-7.
; 2. Connect the four LCD control pins BE-RS to PORTA4-7.
  
.include "m2560def.inc"
.equ prescalar = 8
.equ secondcycle = 1000000 / prescalar

.equ units = 0b00001111
.equ unitslimit = 0b00001001 ;9
.equ tens = 0b11110000
.equ tenslimit = 0b01010000 ;5
.equ NumAscii = 0b00110000

.def temp = r16
.def temp2 = r17
.def seconds = r18
.def minutes = r19

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

.macro do_lcd_command_register ;same as above but reg friendly
	mov temp, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro

.macro do_lcd_data ;write out data
	ldi temp, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro do_lcd_data_register ;same as above but reg friendly
	mov temp, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro show_tens_units ;@timer register
	mov temp, @0
	lsr temp ;roll it so its only tens
	lsr temp
	lsr temp
	lsr temp
	ldi temp2, NumAscii ;ascii for numbers
	add temp, temp2
	do_lcd_data_register temp

	ldi temp2, NumAscii
	mov temp, @0
	cbr temp, tens
	add temp, temp2
	do_lcd_data_register temp
.endmacro

.dseg
Sec_Count:.byte 2
Temp_Count:.byte 2


.cseg
.org 0
	jmp RESET
.org OVF0addr
	jmp TimerOVF0

TimerOVF0: //timer Overflow
	in temp, SREG
	push temp
	push YH
	push YL
	push r25
	push r24
	push r16
	push r17

	//Cycle counting
	lds r24, Temp_Count
	lds r25, Temp_Count+1
	adiw r25:r24, 1
	cpi r24, low(7812)
	ldi temp, high(7812)
	cpc r25, temp
	brne NOTSECOND_relay

	//stuff to do when its a second
	clr r24 ;clear the secondcycle counter
	clr r25

//check for seconds units limit before adding seconds
SecUnitAdd:
	mov temp, seconds
	andi temp, units
	cpi temp, unitslimit ;check if units is at the limit
	breq SecTensAdd ;increase unit tens
	inc seconds
	rjmp yump

//check for seconds tens limit before adding tens
SecTensAdd:
	cbr seconds, units ;clear the units of seconds
	mov temp, seconds
	andi temp, tens
	cpi temp, tenslimit ;check if tens is at the limit
	brsh MinUnitAdd ;increase minutes
	ldi temp, 0b00010000
	add seconds, temp ;increase tens of seconds
	rjmp yump

//check for minutes units limit before adding units
MinUnitAdd:
	clr seconds ;clear seconds
	mov temp, minutes
	andi temp, units
	cpi temp, unitslimit ;check if units is at the limit
	breq  MinTensAdd ;increase minutes tens
	inc minutes
	rjmp yump
NOTSECOND_RELAY:
	jmp NOTSECOND
//check for minutes tens limit before adding tens
MinTensAdd:
	cbr minutes, units ;remove units of minutes
	mov temp, minutes
	andi temp, tens
	cpi temp, tenslimit
	brsh allclear
	ldi temp, 0b00010000
	add minutes, temp
	rjmp yump

//minutes:seconds == 59:59 so go to 00:00
allclear:
	clr temp
	andi seconds, 0
	andi minutes, 0
	rjmp yump

yump: //something to show that sec/min has changed
	do_lcd_command 0b10
	show_tens_units minutes
	do_lcd_data ':'
	show_tens_units seconds

NOTSECOND: //somewhere to skip to if not sec
	sts Temp_Count, r24 //store timer0 triggers back
	sts Temp_Count+1, r25

epilogue:
	pop r17
	pop r16
	pop r24
	pop r25
	pop YL
	pop YH
	pop temp
	out SREG, temp
	reti

RESET:
	//stack frame
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	ser temp
	out DDRF, temp ;lcd pins as out
	out DDRA, temp ;lcd control pins as out
	clr temp
	out PORTF, temp ;lcd display as clear
	out PORTA, temp ;lcd control as not writing or enabled
	clr minutes
	clr seconds

	//LCD set up
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00001000 ; display off?
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink

	//timer0 overflow stuff
	clr temp
	out TCCR0A, temp ;disable the other timers
	ldi temp, 0b10
	out TCCR0B, temp ;set prescale to 8
	ldi temp, 1 <<TOIE0 ;unmask timer overflow 0
	sts TIMSK0, temp 
	clear Temp_Count ;clear seconds counter
	rjmp main

main:
	//lol wut
	//add time and crap like that

halt:
	rjmp halt

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

;
; Send a command to the LCD (temp)
;

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