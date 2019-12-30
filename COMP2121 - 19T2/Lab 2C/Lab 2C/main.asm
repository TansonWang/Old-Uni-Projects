.include "m2560def.inc"
.def a = r16
.def b = r17
.def c = r18
.def n = r19
.def counter = r20
.def counterH = r21
.def temp = r23
.def temp0 =r22


.dseg
.org 0x0200

.cseg
ldi yh, high(RAMEND-4)
ldi yl, low (RAMEND-4)

ldi a, 1
ldi b, 2
ldi c, 3
ldi n, 15
ldi temp, 1
ldi temp0, 0



start:
	clr counter
	out spl, yl
	out sph, yh

	std y+1, a
	std y+2, b
	std y+3, c
	std y+4, n

	rcall move

	jmp end

move:
	;prologue
	;push push push
	push r28
	push r29
	in r28, spl
	in r29, sph
	sbiw r28, 4
	out sph, r29 ;set the stack pointer to the top
	out spl, r28

	std y+4, n
	std y+3, a
	std y+2, c
	std y+1, b

	cpi n, 1
	brne else
	add counter, temp
	adc counterH, temp0

epilogue:
	;pop pop pop
	adiw r28, 4
	out sph, r29
	out spl, r28
	pop r29
	pop r28

	ret

else:
	ldd n, y+4
	ldd a, y+3
	ldd b, y+2
	ldd c, y+1
	sub n, temp 
	rcall move

	mov n, temp
	ldd a, y+3
	ldd c, y+2
	ldd b, y+1
	rcall move

	ldd n, y+4
	ldd b, y+3
	ldd c, y+2
	ldd a, y+1
	sub n, temp
	rcall move

	rjmp epilogue

end: rjmp end