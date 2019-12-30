.include "m2560def.inc"

.dseg
.org 0x0200
.def DivDL = r16 ;dividend
.def DivDH = r17
.def DivSL = r18 ;divisor original
.def DivSH = r19
.def varDivSL = r20 ;divisor var
.def varDivSH = r21
.def quoL = r22 ;quotient
.def quoH = r23
.def addL = r24 ;quotient adder
.def addH = r25


.cseg
ldi DivDL, low(64501)
ldi DivDH, high(64501)
ldi DivSL, low(10)
ldi DivSH, high(10)
mov varDivSL, DivSL
mov varDivSH, DivSH
clr quoL
clr quoH
ldi addL, 1
ldi addH,0


while1: ;make the var divisor 1 pos too large
	;compare Dividend and var divisor
	cp DivDL, varDivSL
	cpc DivDH, varDivSH
	brlo while2

	mov r26,varDivSL
	mov r27,varDivSH
	;avoid overflow
	andi r21,low(0x8000)
	andi r22,high(0x8000)
	add  r21,r22
	cpi r21,0
	brne while2

	;+ var divisor and quouotient adder by one pos
	lsl varDivSL
	rol varDivSH
	lsl addL
	rol addH

	rjmp while1

while2: ;dividend - var divisor, quouotient+
	;termination sequence
	;if the dividend is lower than the org. divisor
	cp DivDL, DivSL
	cpc DivDH, DivSH
	brlo end

	;check if the var divisor is range
	cp DivDL, varDivSL
	cpc DivDH, varDivSH
	brlo rightroll

	;subtraction
	sub DivDL, varDivSL
	sbc DivDH, varDivSH

	;quotient+
	add quoL, addL
	adc quoH, addH
	jmp while2


rightroll: ;roll the var divisor back into range
	lsr varDivSH
	ror varDivSL
	lsr addH
	ror addL
	jmp while2

end: rjmp end