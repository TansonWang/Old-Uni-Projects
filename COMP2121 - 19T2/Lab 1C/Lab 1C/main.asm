.include "m2560def.inc"

.def counter = r16
.def tempL = r17
.def tempH = r18
.def finalL = r19
.def finalH = r20

.dseg
array: .byte 20

.cseg
clr counter
clr tempL
clr tempH
clr finalL
clr finalH

ldi zl, low(array)
ldi zh, high(array)
ldi r21, 200

make_Array: ;load the array into Z
	inc counter
	mul counter, r21
	mov tempL, r0
	mov tempH, r1
	st z+, tempL
	st z+, tempH
	
	cpi counter, 10
	brne make_Array ;repeat until you've done this 10 times

ldi zl, low(array) ;reset the z pointer back to the start of the array
ldi zh, high(array)
clr counter ;reset counter to 0

adding:
	inc counter
	ld tempL, z+ ;load in the array
	ld tempH, z+
	
	add finalL, tempL ;addition
	adc finalH, tempH

	cpi counter, 10
	brne adding

done: rjmp done