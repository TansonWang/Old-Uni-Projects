.include "m2560def.inc"

.def Al = r16
.def Ah = r17
.def Bl = r18
.def Bh = r19

start: ;load the values of A and B
	ldi Al = 1
	ldi Ah = 1
	ldi Bl = 1
	ldi Bh = 0

loop: ;Compare A and B
	cp Al, Bl
	cpc Ah, Bh
	breq done ;if Equal skip to end
	brsh do_ab ;if A => B go to A - B

	;B - A
	sub Bl, Al
	sbc Bh, Ah
	jmp loop


do_ab: ;A - B
	sub Al, Bl
	sbc Ah, Bh
	jmp loop

done: rjmp done