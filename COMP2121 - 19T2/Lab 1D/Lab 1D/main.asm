.include "m2560def.inc"

.def i = r16
.def j = r17
.def k = r18
.def tempA = r19
.def tempB = r20
.def var = r21
.def tempCL = r22
.def tempCH = r23

.dseg

arrayA: .byte 25
arrayB: .byte 25
arrayC: .byte 50

.cseg

ldi zl, low(arrayA)
ldi zh, high(arrayA)
ldi yl, low(arrayB)
ldi yh, high(arrayB)
ldi xl, low(arrayC)
ldi xh, high(arrayC)

clr i
clr j
clr k
clr tempA
clr tempB
clr tempCL
clr tempCH

;create arrays A, B and C
inc_i: ;used to increment i
	cpi j, 5 ;is j 5?
	brlo inc_j ;if j is not 5 inc j
	clr j ;as j = 5, set j = 0
	
	cpi i, 5
	breq makeC ;as i = 5, start making array C
	inc i
	jmp inc_i 


inc_j: ;increment j and load in the values
	mov var, i ;array A
	add var, j
	st z+, var

	mov var, i ;array B
	sub var, j
	st y+, var

	clr var ;array C
	st x+, var
	st x+, var

	cpi j, 5
	breq inc_i
	inc j
	jmp inc_j

makeC:
	clr i
	clr j
	clr k
	ldi zl, low(arrayA)
	ldi zh, high(arrayA)
	ldi yl, low(arrayB)
	ldi yh, high(arrayB)
	ldi xl, low(arrayC)
	ldi xh, high(arrayC)

i_up:
	cpi j, 5
	brlt j_up
	clr j

	sbiw y, 5 ;return B to the first column

	cpi i, 5
	breq done
	inc i
	adiw z, 5 ;move A down a row
	jmp i_up

j_up:
	cpi k, 5
	brlt k_up
	clr k

	sbiw z, 5 ;return A to the first column
	sbiw y, 25 ;return B to the first row

	cpi j, 5
	breq i_up
	inc j
	adiw x, 2 ;shift C along one
	adiw y, 1 ;move B right one column
	jmp j_up
	
k_up:	
	ld tempA, z
	ld tempB, y
	ld tempCL, x+ ;load in the values
	ld tempCL, x+
	sbiw z, 2 ;return to the preload position

	mulsu tempA, tempB ;multi and add
	add tempCL, r0
	adc tempCH, r1
	st x+, tempCL ;store the values into C
	st x+, tempCH
	sbiw z, 2 ;return to the preload position

	cpi k, 5
	breq j_up
	inc k
	adiw z, 1 ;move A right one column
	adiw y, 5 ;move B down one row
	
	jmp k_up




done: rjmp done