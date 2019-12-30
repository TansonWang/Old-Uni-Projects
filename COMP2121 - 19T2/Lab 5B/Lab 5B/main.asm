.include "m2560def.inc"

.def temp = r16
.def speed = r17
.def twenty = r18

.def hole = r11
.def first_num = r12
.def second_num = r13
.def third_num = r14
.def ten = r15
.def a = r26
.def b = r19
.def Timertemp = r20
.def motor = r21
.def num = r22
.def counter = r23
.def counter2 = r24
.def c= r25

.dseg
TempCounter: .byte 2

.cseg 

.org 0x00 
    jmp RESET 
.org INT0addr     
    jmp EXT_INT0 
.org INT1addr    
    jmp EXT_INT1 
.org INT2addr
    jmp EXT_INT2
.org OVF0addr
    jmp Timer0OVF

.org 0x72
.macro do_lcd_data
	ldi r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro do_lcd_data_reg
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro

.macro clear
	ldi YL, low(@0)
	ldi YH, high(@0)
	clr temp
	st Y+, temp	
	st Y, temp
.endmacro 

.macro convert ;converts 1 byte into 3 decimals in 3 regs
	push temp
	clr num
	mov temp, @0
	mov b, @0
	mov c, @1
	ldi a, 100

	minus:
		cp temp,a
		brlt index
		sub temp, a
		inc num
		mov b, temp	
		rjmp minus

	index:
		cpi a, 100
		breq hundred
		cpi a, 10
		breq decade
		cpi a, 1
		breq unit

	hundred:
		mov first_num, num
		ldi a, 10
		mov temp, b
		clr num
		rjmp minus

	decade:
		mov second_num, num
		ldi a, 1
		mov temp, b
		clr num
		rjmp minus

	unit:
		mov third_num, num
		clr num

	cpi c,1
	brne end_convert
	ldi b,2
	add first_num,b	
	ldi b,5
	add second_num,b
	ldi b,6
	add third_num,b
	end_convert:
	pop temp
.endmacro

RESET:
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16
    
    ;//Setting Motor Power Modulator
        ser temp
        out DDRE, temp; set Motor Power as output
        ;this value and the operation mode determines the PWM duty cycle
        ldi temp,0
        sts OCR3BL, temp;OC3B low register
        clr temp
        sts OCR3BH, temp;0C3B high register
        ldi temp, (1<<CS30) ; CS30 = 1: no prescaling
        sts TCCR3B, temp; set the prescaling value
        ldi temp, (1<<WGM30)|(1<<COM3B1)
        ; WGM30=1: phase correct PWM, 8 bits
        ;COM3B1=1: make OC3B override the normal port functionality of the I/O pin PE2
        sts TCCR3A, temp
        sei

    ;//Setting LED
        ser temp 
        out DDRC, temp ;set leds to output     
    ;//Setting Up LCD Screen
        ser r16
        out DDRF, r16 ;set LCD screen to output
        out DDRA, r16 ;set LCD control pins to output

        clr r16
        out PORTF, r16 ;set LCD screen to 0
        out PORTA, r16 ;set LCD control pins to 0

        do_lcd_command 0b00111000 ; 2x5x7 Num Lines x font size
        do_lcd_command 0b00111000 ; 2x5x7
        do_lcd_command 0b00111000 ; 2x5x7
        do_lcd_command 0b00111000 ; 2x5x7
        do_lcd_command 0b00001000 ; display off?
        do_lcd_command 0b00000001 ; clear display
        do_lcd_command 0b00000110 ; increment, no display shift
        do_lcd_command 0b00001110 ; Cursor on, bar, no blink

    ;//Setting External Interrupts Buttons and Infra-red
        clr temp 
        out DDRD, temp ;set buttons and motor to input
        out PORTD, temp ;set buttons and motor to 0
        ldi temp, (2 << ISC20 | 2 << ISC10 | 2 << ISC00) ;values for ext. interrupt
        sts EICRA, temp ;Load in falling edge for ext. interrupt
        in temp, EIMSK ;load in current active interrupts
        ori temp, (1<<INT2 | 1<<INT1 | 1<<INT0)  ;note int0 = 0, int1 = 1
        out EIMSK, temp  ;enable ext. interrupts 0, 1 and 2
    ;//Setting Timer0 Overflow Interrupt
        ldi temp, 0b00000000
        out TCCR0A, temp
        ldi temp, 0b00000010
        out TCCR0B, temp ;set prescalar value to 8
        ldi temp, 1<<TOIE0 ;TOIE0 is the bit number of TOIE which is 0
        sts TIMSK0, temp ;enable Timer0 Overflow interrupt	

    sei ;enable global interrupt
    ldi twenty, 20
    clr speed
    jmp main 

main:
    rjmp main

mul10:								; multiply number by 10
	mul counter,ten
	mov counter,r0
	mov counter2,r1
	ret

print_answer:
	do_lcd_command 0b00000010
	do_lcd_data_reg first_num
	do_lcd_data_reg second_num
	do_lcd_data_reg third_num
	do_lcd_data 'r'
	do_lcd_data '/'
	do_lcd_data 's'
    ret
Timer0OVF:						;interrupt subroutine to Timer0
	in Timertemp, SREG;
	push Timertemp					; prologue starts
	push YH							; save all conflicting registers
	push YL
	push r25
	push r24						; prologue ends 

	lds r24, TempCounter
	lds r25, TempCounter+1
	adiw r25:r24, 1					; increase the temporary counter by 1
	cpi r24, low(781)				; check if TempCounter(r25:r24) = 7812
	ldi Timertemp, high(781)		; about 100ms
	cpc r25, Timertemp
	brne NotSecond

	rcall mul10

	convert counter,counter2

	ldi Timertemp, 0b00110000
	add first_num, Timertemp
	add second_num, Timertemp
	add third_num, Timertemp

	rcall print_answer

	clr counter
	clear TempCounter
	rjmp fin_Timer0OVF

	NotSecond:
		sts TempCounter, r24
		sts TempCounter+1, r25

	fin_Timer0OVF:
		pop r24
		pop r25
		pop YL
		pop YH
		pop Timertemp
		out SREG, Timertemp
	reti

EXT_INT0: ;increase button 
    push temp 
    in temp, SREG 
    push temp 
        
    cpi speed, 100 ;Check if already max speed
    breq end

    add speed, twenty ;add 20
    rjmp end

end:
    rcall delay_10ms
    out PORTC,speed
    sts OCR3BL, speed
    clr temp
    sts OCR3BH, temp

    pop temp 
    out SREG, temp 
    pop temp
    rcall delay_10ms
    reti 

EXT_INT1: ;decrease button
    push temp 
    in temp, SREG 
    push temp 
        
    cpi speed, 0 ;check if already min speed
    breq end

    sub speed, twenty ;sub 20 from speed
    rjmp end	

EXT_INT2: ;Infra-red detected a hole
	push motor 
	in motor, SREG 
	push motor 

	inc hole
	ldi motor, 4
	cp hole, motor
	brne no_revolution

	clr hole
	inc counter

	no_revolution:
		pop motor 
		out SREG, motor 
		pop motor 
    reti
;//=== LCD Stuff ===\\
	.equ LCD_RS = 7
	.equ LCD_E = 6
	.equ LCD_RW = 5
	.equ LCD_BE = 4

	.macro lcd_set
		sbi PORTA, @0
	.endmacro
	.macro lcd_clr
		cbi PORTA, @0
	.endmacro

	lcd_command:
		out PORTF, r16
		nop
		lcd_set LCD_E
		nop
		nop
		nop
		lcd_clr LCD_E
		nop
		nop
		nop
	ret

	lcd_data:
		out PORTF, r16
		lcd_set LCD_RS
		nop
		nop
		nop
		lcd_set LCD_E
		nop
		nop
		nop
		lcd_clr LCD_E
		nop
		nop
		nop
		lcd_clr LCD_RS
	ret

	lcd_wait:
		push r16
		clr r16
		out DDRF, r16
		out PORTF, r16
		lcd_set LCD_RW
		lcd_wait_loop:
		nop
		lcd_set LCD_E
		nop
		nop
		nop
		in r16, PINF
		lcd_clr LCD_E
		sbrc r16, 7
		rjmp lcd_wait_loop
		lcd_clr LCD_RW
		ser r16
		out DDRF, r16
		pop r16
	ret

;//=== Delay Stuff ===\\
.equ F_CPU = 16000000
.equ DELAY_COUNTER = F_CPU / 4 / 100 - 4
delay_10ms:
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