.include "m2560def.inc"
.equ size = 6
.def counter = r16
.def ta1 = r17; setting the registers for Temp A
.def ta10 = r18
.def ta100 = r19
.def tb1 = r20; setting the registers for Temp B
.def tb10 = r21
.def tb100 = r22
.def f1 = r23; setting the registers for Final
.def f10 = r24
.def f100 = r25

.dseg
.org 0x200

.cseg
string:.db "325658"
	ldi zl, low(string << 1) ;create a pointer to z
	ldi zh, high(string << 1)
 

clr counter

main:
	ldi r26, 10
	ldi r27, 0
	lpm r28, z+; load in the data
	subi r28, 48; ascii to actual
	cpi counter, size
	breq done
	
	;Multiply the units of Final by 10 and move into Temp A
	mul f1, r26
	mov ta1, r0
	mov ta10, r1
	clr ta100

	;Multiply the r26s of Final by 10 and move into Temp B
	mul f10, r26
	mov tb10, r0
	mov tb100, r1
	clr tb1

	;Add Temp A and Temp B to make space for hundreds of Final
	add ta1, tb1
	adc ta10, tb10
	adc ta100, tb100

	;Multiply the hundreds of Final by 10 and move into Temp B
	mul f100, r26
	mov tb100, r0
	clr tb1
	clr tb10

	;Add Temp A and Temp B to get the 10x Final value
	add ta1, tb1
	adc ta10, tb10
	adc ta100, tb100

	;Add the data string value
	add ta1, r28
	adc ta10, r27; adding 0 to get carry value
	adc ta100, r27

	;Move into Final
	mov f1, ta1
	mov f10, ta10
	mov f100, ta100

	inc counter
	jmp main


done:
	rjmp done