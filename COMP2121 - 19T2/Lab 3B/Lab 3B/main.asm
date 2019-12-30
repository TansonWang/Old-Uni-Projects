.include "m2560def.inc"
.def temp =r16
.def counter =r18
.equ pattern1 = 0b00001111
.equ F_CPU = 8000000
.equ Delay_Counter = F_CPU/4/100 -4

.cseg
.org 0x0
jmp RESET ; interrupt vector for RESET
.org INT0addr ; INT0addr is the address of EXT_INT0 (External Interrupt 0)
jmp EXT_INT0 ; interrupt vector for External Interrupt 0
.org INT1addr ; INT1addr is the address of EXT_INT1 (External Interrupt 1)
jmp EXT_INT1 ; interrupt vector for External Interrupt 1

RESET:
	ldi temp, low(RAMEND) ; initialize stack pointer to point the high end of SRAM
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp
	ser temp ; temp=0b11111111
	out DDRC, temp ; Port C is set to all outputs
	clr temp ; temp=0b00000000
	out PORTC, temp
	out DDRD, temp ; Port D is set to all inputs
	out PORTD, temp
	ldi temp, (2 << ISC10) | (2 << ISC00) ; The built-in constants ISC10=2 and ISC00=0 are their bit numbers in EICRA register
	sts EICRA, temp ; temp=0b00001010, so both interrupts are configured as falling edge triggered interrupts
	in temp, EIMSK
	ori temp, (1<<INT0) | (1<<INT1) ; INT0=0 & INT1=1
	out EIMSK, temp ; Enable External Interrupts 0 and 1
	sei ; Enable the global interrupt
jmp main

EXT_INT0: ; Interrupt handler for External Interrupt 0
	inc counter
	sbrc counter, 0
	reti

	push temp ;get the current light arrangement
	in temp, SREG ;get the flags
	push temp ;save the flags
	
	;need to somehow retrieve the lights temp
	in temp, PORTC
	dec temp
	sbrc temp, 7 ;if temp is 0xff set back to pattern
	ldi temp, pattern1
	out PORTC, temp

	pop temp ;get the saved flags
	out SREG, temp ;restore the saved flags
	pop temp ;get the flag arrangement
	rcall delay_1000ms
reti

EXT_INT1: ; Interrupt handler for External Interrupt 1
	inc counter
	sbrc counter, 0
	reti

	push temp ;get the current light arrangement
	in temp, SREG ;get the flags
	push temp ;save the flags
	
	;need to somehow retrieve the lights temp
	in temp, PORTC
	inc temp
	sbrc temp, 4 ;if temp is 0b00010000 set back to pattern
	clr temp
	out PORTC, temp

	pop temp ;get the saved flags
	out SREG, temp ;restore the saved flags
	pop temp ;get the flag arrangement

	rcall delay_1000ms
reti

main: ; main does nothing but increments a counter
clr counter
sbr temp, pattern1
out PORTC, temp

loop:
	;rcall ext_int0
	rjmp loop ; An infinite loop must be at the end of the interrupt handler for RESET 


delay_1000ms: ;actually 8 000 706 cycles
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