.include "m2560def.inc"

.dseg
.org 0x0200

.equ size = 6
.equ sizex2 = 12
.equ xvar = 0
.equ a0 = 100 ;poly A0 A1 A2... values
.equ a1 = -60 ;Most multiplied
.equ a2 = 120  ; ||
.equ a3 = -100 ; ||
.equ a4 = 50   ; \/
.equ a5 = -70 ; Least multiplied

.def rL = r16
.def rH = r17
.def over = r20
.def ytemp = r19
.def counter = r18

;Macro
.macro multiadd ;resultH, resultL, xvar, Avar, overflow
	;assuming 2 byte signed and 1 byte signed
	clr r15 ;result Third
	clr r14 ;result High
	clr r13 ;result Low
	clr r12 ;negative
	clr r11
	mov r10, @0
	mov r9, @2
	mov r8, @1
	mov r7, @3

	;check if Result is neg and set it to pos
	sbrs r10, 7
	inc r12
	sbrs r10, 7 ;if no is neg only run neg x1
	neg r10
	neg r10 ;if no is pos run neg x2

	;check if xvar is neg and set it to pos
	sbrs r9, 7
	inc r12
	sbrs r9, 7
	neg r9
	neg r9

	;do the mul
	mul r8, r9
	mov r13, r0
	mov r14, r1
	mul r10, r9
	add r14, r0
	adc r15, r1

	;do the add
	add r13, r7
	adc r14, r11
	adc r15, r11
	
	;Note that we only manipulate the lesser two bytes
	;so we have to sign the second byte
	;End check if value final should be negative
	inc r11
	cp r12, r11
	breq neganswer
	rjmp posanswer


	neganswer:
		clr r15 ;set to no overflow
		sbrs r14, 7 ;if r14 doesn't start with 1
		inc r15 ;overflow
		rjmp answersave

	posanswer:
		clr r15
		inc r15 ;set to overflow
		sbrs r14, 7; if r4  doesn't start with 1
		clr r15 ;set to no overflow
		rjmp answersave


	answersave:
		;save answers into slot
		mov @0, r14 ;resultH
		mov @1, r13 ;resultL
		mov @4, r15 ;overflow value
.endmacro

A_array:.byte size

.cseg

ldi zl, low(A_array)
ldi zh, high(A_array)

ldi r22, a0
st z+, r22
ldi r22, a1
st z+, r22
ldi r22, a2
st z+, r22
ldi r22, a3
st z+, r22
ldi r22, a4
st z+, r22
ldi r22, a5
st z+, r22
sbiw z, 6

start:
	clr rh
	clr rl
	clr over
	clr counter
	ldi r25, xvar
	cpi r25, 0
	breq zerocase
	rjmp loop

	zerocase:
	ldi r25, a5
	add r16, r25
	rjmp done

loop:
	ld ytemp, z+
	ldi r22, xvar
	multiadd rh, rl, r22, ytemp, over
	
	cpi counter, size
	inc counter
	brlo loop

done: rjmp done
