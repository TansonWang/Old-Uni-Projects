.include "m2560def.inc"

 
.equ addsec = 0b00000100 ;1 second
.equ secmax = 0b11110000 ;1 minute (sec[6],min[2]) 0x111100 = 60
 
.def temp = r16
.def onesec = r17

.equ F_CPU = 16000000
.equ DELAY_COUNTER = F_CPU / 4 / 100 - 4
 
.equ prescalar = 256
.equ secondcycle = 1000000 / prescalar /4

 .macro clear
	ldi YL, low(@0) ; load the memory address to Y pointer
	ldi YH, high(@0)
	clr temp ; set temp to 0
	st Y+, temp ; clear the two bytes at @0 in SRAM
	st Y, temp
.endmacro


 .dseg
 Sec_Count:.byte 2
 Temp_Count: .byte 2


.cseg
.org 0x0000
jmp RESET
jmp DEFAULT ; no handling for IRQ0.
jmp DEFAULT ; no handling for IRQ1.

.org OVF0addr ; OVF0addr is the address of Timer0 Overflow Interrupt Vector
jmp TimerOVF0 ; jump to the interrupt handler for Timer0 overflow. …
jmp DEFAULT ; default service for all other interrupts.
DEFAULT: reti ; no interrupt handling


RESET:
	ser temp
	out DDRC, temp ;set leds to output
	ldi yL, low(RAMEND) ;Stack Frame
	ldi yH, high(RAMEND)
	out SPL, yL
	out SPH, yH
rjmp main

TimerOVF0:
	in temp, SREG
	push temp
	push YH
	push YL
	push r25
	push r24

	lds r24, Temp_Count
	lds r25, Temp_Count+1
	adiw r25:r24, 1
	cpi r24, low(secondcycle)
	ldi temp, high(secondcycle)
	cpc r25, temp ;has there been sufficient cycles for 1 sec
	brne Notsecond ;not 1 sec
	
	;increase sec if enough cycles
	in temp, PORTC
	add temp, onesec
	cpi temp, secmax ;check for minute
	brsh minuteadd
	rjmp yump

minuteadd:
	inc temp
	cbr temp, $FC

yump:
	out PORTC, temp
	clr r24 ;clear cycle counter
	clr r25

Notsecond:
	sts Temp_Count, r24
	sts Temp_Count+1, r25

epilogue:
	pop r24
	pop r25
	pop YL
	pop YH
	pop temp
	out SREG, temp
	reti


 
main:
	ldi onesec, addsec
	ldi temp, 0x0
	out PORTC, temp
	clear Temp_Count

	clr temp
	out TCCR0A, temp
	ldi temp, 0b11
	out TCCR0B, temp
	ldi temp, 1<<TOIE0
	sts TIMSK0, temp
	sei
	
loop:
	;rcall timerovf0
	rjmp loop


