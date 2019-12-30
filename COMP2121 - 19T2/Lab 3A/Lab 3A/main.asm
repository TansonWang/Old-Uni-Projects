.include "m2560def.inc"
 
.equ init = 0b1111
 
.def temp = r16

.equ F_CPU = 16000000 ;cpu speed of the device
.equ DELAY_COUNTER = F_CPU / 4 / 100 - 4
 
.cseg
.org 0x0

ser temp
out DDRC, temp ;set leds to output

clr temp
out DDRD, temp ;set buttons to input

ldi temp, init
out PORTC, temp ;init setup for leds 
 
ldi yL, low(RAMEND) ;Stack Frame
ldi yH, high(RAMEND)
out SPL, yL
out SPH, yH
 
increment:
	sbic PIND, 1 ;button 1 pushed?
	rjmp decrement ;

	inc temp
	sbrc temp, 4
	clr temp

	out PORTC, temp
	rcall delay_1000ms
	rjmp decrement

decrement:
	sbic PIND, 0
	rjmp increment

	dec temp
	sbrc temp, 7
	ldi temp, init

	out PORTC, temp
	rcall delay_1000ms
	rjmp increment

delay_1000ms: ;actually 16 000 706 cycles
	push r23 ;2c
	ldi r23, 100 ;1c
	timerloop: ;x100
		dec r23 ;1c
		rcall delay_10ms ;3c
		cpi r23, 0 ;1c
		brne timerloop ;2c/1c if passthrough
	pop r23 ;2c
	ret ;4c

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
