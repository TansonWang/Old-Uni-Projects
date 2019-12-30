.include "m2560def.inc"

;//=== Keypad Defs ===\\
	.def temp =r16
	.def row =r17
	.def col =r18
	.def mask =r19
	.def temp2 =r20
	.equ PORTLDIR = 0xF0
	.equ INITCOLMASK = 0xEF
	.equ INITROWMASK = 0x01
	.equ ROWMASK = 0x0F

;//===  Personal use Defs and Equs ===\\
	;Desperate times call for desperate measures
	.def TravelTime = r8
	.def currStation = r7
	.def stoptime = r6

	.def temp3 = r21
	.def temp4 = r22
	.def temp5 = r23

	.def stationNum = r24
	.equ motorSpeed = 0

	.equ AsciiNum = 0b00110000
	.equ AsciiLetter = 0b01000000
	.equ AsciiHash = 0b00100011
	.equ AsciiStar = 0b00101010

	.equ LAST_COLUMN = 3
	.equ UNSET_POSITION = 4
	.equ MAX_CHARACTERS = 10

	.equ hashcol = 0b10111111
	.equ hashrow = 0b1000

;//=== Delay Defs and Equs ===\\
	.equ F_CPU = 16000000
	.equ DELAY_COUNTER = F_CPU / 4 / 100 - 4

;//=== Macro for LCD display ===\\
	.macro clear;load in and clear 2 bytes of data
		ldi YL, low(@0)
		ldi YH, high(@0)
		clr temp
		st Y+, temp
		st Y, temp
	.endmacro

	.macro do_lcd_command ;port in a command
		ldi temp, @0
		rcall lcd_command
		rcall lcd_wait
	.endmacro

	.macro mov_lcd_command ;reg friendly ver.
		mov temp, @0
		rcall lcd_command
		rcall lcd_wait
	.endmacro

	.macro do_lcd_data ;write out data
		ldi temp, @0
		rcall lcd_data
		rcall lcd_wait
	.endmacro

	.macro mov_lcd_data ;reg friendly ver.
		mov temp, @0
		rcall lcd_data
		rcall lcd_wait
	.endmacro

	.macro ascii_print
		ldi temp, 48
		mov temp2, @0
		add temp2, temp
		mov_lcd_data temp2
	.endmacro

.dseg
array: .byte 110
times: .byte 11 ;USED FOR LAST STATION TO FIRST TIME TECH

.cseg
.org 0x0
jmp RESET

.org INT0addr
jmp Button_pushed
.org INT1addr
jmp Button_pushed

Button_pushed:
	push temp
	ldi temp, 0xff
	mov r5, temp
	pop temp
reti

RESET:
	;//Array Frame
		ldi zl, low(array)
		ldi zh, high(array)
		ldi yl, low(times)
		ldi yh, high(times)
	;//Stack frame
		ldi temp, low(RAMEND-100)
		out SPL, temp
		ldi temp, high(RAMEND-100)
		out SPH, temp

	;//Keypad Set Up
		ldi temp, PORTLDIR ; columns are outputs, rows are inputs
		STS DDRL, temp     ; cannot use out

	;//LCD Set Up
		;//LCD pin Set Up
			ser temp
			out DDRF, temp ;lcd pins as out
			out DDRA, temp ;lcd control pins as out
			clr temp
			out PORTF, temp ;lcd display as clear
			out PORTA, temp ;lcd control as not writing or enabled

		do_lcd_command 0b00111000 ; 2x5x7
		do_lcd_command 0b00111000 ; 2x5x7
		do_lcd_command 0b00111000 ; 2x5x7
		do_lcd_command 0b00111000 ; 2x5x7
		do_lcd_command 0b00111000 ; 2x5x7
		do_lcd_command 0b00001000 ; display off?
		do_lcd_command 0b00000001 ; clear display
		do_lcd_command 0b00000110 ; increment, no display shift
		do_lcd_command 0b00001110 ; Cursor on, bar, no blink

	;//LED Set Up
		ser temp
		out DDRC, temp ;set LEDS to output
		clr temp
		out PORTC, temp ;set LEDS to 0
	;//External Interrupt Set Up
		;Currently just the buttons
		clr temp
		out DDRD, temp ;set interrupt port to input
		out PORTD, temp ;set interrupt port to 0
		ldi temp, (2 << ISC10 | 2 << ISC00) ;set falling edge interrupt for buttons
		sts EICRA, temp ;Load in falling edge for ext. interrupt
		in temp, EIMSK ;load in current active ext. interrupts
		ori temp, (1<<INT0) | (1<<INT1)  ;note int0 = 0, int1 = 1
		out EIMSK, temp  ;enable ext. interrupts 0 and 1
		cli ;disable global interrupt
	
	;PWM and Motor Set Up
		ser temp
		out DDRE, temp ;set motor power as output
		STS DDRH, temp
		ldi temp,0 ;this value and the operation mode determines the PWM duty cycle
		sts OCR4CL, temp ;Load pulse width/speed into OC4C low register
		clr temp
		sts OCR4CH, temp ;Load pulse width/speed into 0C4C high register
		ldi temp, (1<<CS30) ; CS30 = 1: no prescaling
		sts TCCR4B, temp; set the prescaling value
		ldi temp, (1<<WGM30)|(1<<COM4C1)
		; WGM30=1: phase correct PWM, 8 bits
		;COM4C1=1: make OC4C override the normal port functionality of the I/O pin PE2
		sts TCCR4A, temp
		sei
	;//Other
		;Station 1 Name
			ldi temp, 'S'
			st z+, temp
			ldi temp, 'T'
			st z+, temp
			ldi temp, 'A'
			st z+, temp
			ldi temp, 'T'
			st z+, temp
			ldi temp, 'I'
			st z+, temp
			ldi temp, 'O'
			st z+, temp
			ldi temp, 'N'
			st z+, temp
			ldi temp, ' '
			st z+, temp
			ldi temp, '1'
			st z+, temp
			ldi temp, '!'
			st z+, temp
		;Station 2 Name
			ldi temp, 'S'
			st z+, temp
			ldi temp, 'T'
			st z+, temp
			ldi temp, 'A'
			st z+, temp
			ldi temp, 'T'
			st z+, temp
			ldi temp, 'I'
			st z+, temp
			ldi temp, 'O'
			st z+, temp
			ldi temp, 'N'
			st z+, temp
			ldi temp, ' '
			st z+, temp
			ldi temp, '2'
			st z+, temp
			ldi temp, '!'
			st z+, temp
		;Time Array
			ldi temp, 5 ;last to s1
			st y+, temp
			ldi temp, 3 ;s1 to s2
			st y+, temp
	
	ldi zl, low(array)
	ldi zh, high(array)
	ldi yl, low(times)
	ldi yh, high(times)
	clr temp
	ldi stationNum, 2
	ldi temp, 2
	mov stoptime, temp
	jmp main

main:
	call maxStations
	call read_in_stations
	call timeBetweenStations
	call stopTimeRequest
	call next_section
	loop:
	call RP ;internal eternal loop
	jmp loop

;//=== Keypad Start ===\\
	;Keypadcheck | A subroutine that will loop until a key is pressed
	;Changes the values of row and col to represent the key pressed
	Keypad:
			ldi mask, INITCOLMASK ;set mask to 0 only column 1/bit5
			clr col ; clear column counter

		colloop:
			STS PORTL, mask ; set column to mask value

			ldi temp, 0xFF ; implement a delay so the
		delay: ; hardware can stabilize
			dec temp
			brne delay
			LDS temp, PINL ;Intake the keypad reg values 
			andi temp, ROWMASK ; read only the row bits
			cpi temp, 0xF ; check if any rows are grounded
			breq nextcol ; if not go to the next column
			ldi mask, INITROWMASK ; initialise row check
			clr row ; initial row

		rowloop:      
			mov temp2, temp
			and temp2, mask ; check masked bit
			brne skipconv ; if the result is non-zero, we need to look again
			ret ; if bit is clear, convert the bitcode and start again

		skipconv:
			inc row ; else move to the next row
			lsl mask ; shift the mask to the next bit
			jmp rowloop

		nextcol:     
			cpi col, 3 ; check if we're on the last column
			breq Keypad ; if so, no buttons were pushed, so start again.

			sec ; else shift the column mask, we must set the carry bit
			rol mask ; and then rotate left by a bit, shifting the carry into bit zero. We need this to make sure all the rows have pull-up resistors
			inc col ; increment column value
			jmp colloop ; and check the next column
;//=== Keypad End ===\\

;//=== Convertion Numbers Start ===\\
	;Intakes rows and columns to give a row number
	;Star is taken as end of squence
	;temp is then 0 = no err, 1 = no num, 2 = big num err (>10)
	;store value of key into temp3
	convert_numbers:
			cpi col, 3 ; if column is 3 we have a letter
			breq letters ;but no letters so keypad check
			cpi row, 3 ; if row is 3 we have a symbol or 0
			breq symbols
			mov temp, row ; otherwise we have a number (1-9)
			lsl temp ; temp = row * 2
			add temp, row ; temp = row * 3
			add temp, col ; add the column address
			; to get the offset from 1
			inc temp ; add 1. Value of switch is
			; row*3 + col + 1.

			ldi temp2, 10 ;multiply temp3 by 10
			mul temp3, temp2
			mov temp3, r0
			add temp3, temp ;then add the curr num value

			ldi temp2, AsciiNum
			add temp, temp2
			jmp convert_end

		letters:
			ldi temp, 1
			ret

		symbols:
			cpi col, 0 ; check if we have a star
			breq star
			cpi col, 1 ; or if we have zero
			breq zero
			ldi temp, 1
			ret
			;jmp Keypad_numbers ;hash so return to keypad check

		star: ;either store temp3 or clear it and err message
			cpi temp3, 11 ;same or higher than 11 is err
			brsh convert_numbers_error
			cpi temp3, 0
			breq convert_numbers_error
			inc temp4
			rcall delay_30ms
			do_lcd_command 0b1
			clr temp
			ret
			;jmp Keypad_numbers_start ;success so print new question

		zero:
			ldi temp2, 10
			mul temp3, temp2
			mov temp3, r0
			ldi temp, AsciiNum ; set to zero

		convert_end:
			mov_lcd_data temp ; write value to LCD
			call delay_30ms
			ldi temp, 1
			ret
			;jmp Keypad_numbers ; return to keypad checker

		convert_numbers_error:
			ldi temp, 2
			ret

;//=== Convertion Numbers End ===\\

;//=== Convertion Characters Start ===\\
	; Using row and col, determine which key was pressed
	;    @0 is the register location to store result
	.macro determine_key_press
		; Key number value (1-9) is (row * 3) + col + 1
		mov @0, row
		lsl @0
		add @0, row 
		add @0, col 
		inc @0
	.endmacro

	; Translates and stores (in SRAM) valid keypad presses into capital letters.
	;    Achieves this by first reading a 'character position' specified by column 3 key selection
	;       i.e. 'A' represents character position 0, 'B' as position 1, ... and 'C' as position 4 (if applicable)
	;    Followed by selecting the desired keypad 'character block'
	;       Example: character position 'A' (position 0) for keypad character block '2' returns capital letter 'A'
	character_convert:

		; Keys in the column 3 determine character position for the keypad character block which in turn 
		;    determines the character selection
		cpi col, LAST_COLUMN
		breq store_position_selection

		; Check for zero or hash key presses
		;     D key should be caught by the above case before this one
		;         Only valid ones here are [*,0,#]
		cpi row, 3 
		breq zero_or_hash

		; Check whether or not a position has been saved into position selection register
		;    Return to caller if position has not been stored i.e. go back to listening for keypad press
		cpi temp3, UNSET_POSITION
		breq character_convert_end

		; Character conversion entry point
		;    Use character position selection and keypad character block selection to determine capital letter
		determine_key_press temp

		; Case where character block 1 is pressed
		;    No letters are present in this block therefore do nothing
		cpi temp, 1
		breq character_convert_end
		
		; Character conversion core algo
		;    (key_distance_from_2 * 3) + 'A' + position_selection where, key_distance_from_2 = key press - 2,
		;        'A' is decimal value 65 and position_selection is character position selection
		subi temp, 2 ; calculate key_distance_from_2
		mov temp2, temp ; store result to temp2

		; Multiply key_distance_from_2 by 3 which gives the character distance from '65'
		;    (key_distance_from_2 * 2) + key_distance_from_2 = (key_distance_from_2 * 3) = Character distance from '65'
		lsl temp
		add temp, temp2

		; Add calculated character distance from 'A' (the origin/ start)
		ldi temp2, 'A'
		add temp, temp2

		determine_key_press temp2 ; temp overwritten, we can determine the original key press as we still have row, col values saved 

		; Position selection addition
		;   Case where postion selection is 3
		;      Need to catch this case for character blocks 7 and 9 as they have 4 character selections to choose from
		;         i.e. Block 7 = [P,Q,R,S] and Block 9 = [W,X,Y,Z]
		
		inc r15 ;Increase r15
		out PORTC, r15

		cpi temp2, 8
		brlo normalPositionAddition
		inc temp		

		normalPositionAddition:
		cpi temp3, LAST_COLUMN
		breq last_position_selection
		
		; Position selection anything but last column
		add temp, temp3
		clr temp2 

		cpi temp5, MAX_CHARACTERS
		brne not_max_chars ; do nothing if we've reached max characters, just waiting for end of input

		jmp character_convert_end

		; *** Character convert helpers ***
		zero_or_hash:
			cpi col, 1 ; zero represents white space character
			breq white_space

			cpi col, 0 ; hash represents end of input
			breq end_of_input

			; otherwise do nothing
			jmp character_convert_end

		white_space:
			ldi temp, ' '

			;dec r15 ;Decrease if space
			out PORTC, r15

			; do nothing if we've reached max characters, just waiting for end of input
			cpi temp5, MAX_CHARACTERS
			brne not_max_chars

			jmp character_convert_end
		
		character_convert_end:
			; reset the position_selection
			ldi temp3, 4
			rcall delay_10ms
			ret ; return to caller
		
		end_of_input:
			; Calculate how many memory addresses we need to pad by
			ldi temp, MAX_CHARACTERS
			mov temp2, temp5
			sub temp, temp2 ; MAX_CHARACTERS - character_count = Padding
			ldi temp2, ' ' ; Character to write to memory

			cpi temp, 0 ; No padding required
			breq end_of_input_exit

			memory_padding:
				st z+, temp2
				dec temp ; Pad this amount of times
				brne memory_padding

			end_of_input_exit:
				ldi temp5, '*'
				jmp character_convert_end
		
		; *** Position selection helpers ***
		store_position_selection:
			; Row is the character position to be used on next key press
			mov temp3, row 
			ret 

		; *** Character conversion core helpers ***
		last_position_selection:
			; Catches the case where blocks 1-6 and last position asked for 
			cpi temp2, 7
			; Go back to listening for a key press
			brlo character_convert_end

			cpi temp2, 8 ; Catches the case for block 8
			breq character_convert_end

			; Anything here has a valid last position selection
			add temp, temp3
			clr temp2

			; do nothing if we've reached max characters, just waiting for end of input
			cpi temp5, MAX_CHARACTERS
			brne not_max_chars

			jmp character_convert_end

		not_max_chars:
			; store in next memory address 
			st z+, temp
			; output this character onto LCD
			mov_lcd_data temp
			
			rcall delay_30ms
			inc temp5
			ret
;//=== Convertion Characters End ===\\

;//=== Stations Names ===\\
	; Prompts for a station name
	; @0 is the current station number
	.macro station_name_prompt
		inc @0
		do_lcd_command 0b00000001
		do_lcd_data 'S'
		do_lcd_data 'T'
		do_lcd_data 'A'
		do_lcd_data 'T'
		do_lcd_data 'I'
		do_lcd_data 'O'
		do_lcd_data 'N'
		do_lcd_data ' '
		ldi temp, 0b00110000
		add temp, @0
		mov_lcd_data temp
		do_lcd_data ' '
		do_lcd_data 'N'
		do_lcd_data 'A'
		do_lcd_data 'M'
		do_lcd_data 'E'
		do_lcd_data ':'
		do_lcd_command 0b11000000
		dec @0
	.endmacro

	read_in_stations_end:
		ret

	read_in_stations:
		ldi zl, low(array)
		ldi zh, high(array)
		ldi temp3, 4
		ldi temp4, 0
		clr temp5

		read_in_stations_start:
			clr r15
			cp temp4, stationNum
			breq read_in_stations_end
			clr temp5
			station_name_prompt temp4
			jmp read_in_stations_loop
			
			read_in_stations_loop:
				rcall keypad
				rcall character_convert

				cpi temp5, '*'
				brne read_in_stations_loop

				ldi temp , 0
				cp r15, temp
				breq read_in_stations_error

				inc temp4
				;do_lcd_data '@'			
				;ascii_print temp4			Print currStation
				;ascii_print stationNum		Print max No. stations
				rcall delay_100ms
				jmp read_in_stations_start

		read_in_stations_error:
			sbiw z, 10
			ldi temp5, 10
			read_in_stations_error_loop:
				ldi temp, ' '
				st z+, temp
				dec temp5
				brne read_in_stations_error_loop
			sbiw z, 10
			do_lcd_command 0b1
			do_lcd_data 'E'
			do_lcd_data 'r'
			do_lcd_data	'r'
			do_lcd_data 'o'
			do_lcd_data 'r'
			do_lcd_data ' '
			rcall delay_100ms
			rjmp read_in_stations_start

;//=== Stations Names End ===\

;//=== Max Stations Start ===\\
	.macro askForNumStation
		do_lcd_command 0b1
		do_lcd_data 'N'
		do_lcd_data 'u'
		do_lcd_data	'm'
		do_lcd_data 'b'
		do_lcd_data 'e'
		do_lcd_data 'r'
		do_lcd_data ' '
		do_lcd_data 'o'
		do_lcd_data 'f'
		do_lcd_command 0b11000000 ;second line
		do_lcd_data 'S'
		do_lcd_data 't'
		do_lcd_data 'a'
		do_lcd_data	't'
		do_lcd_data 'i'
		do_lcd_data 'o'
		do_lcd_data 'n'
		do_lcd_data 's'
		do_lcd_data ':'
	.endmacro
	maxStations_end: 
		ret
	maxStations:
		clr temp4
	maxStations_start:
		cpi temp4, 1
		breq maxStations_end
		clr temp3
		askForNumStation
		jmp maxStations_loop

	maxStations_loop: 
		rcall keypad
		rcall convert_numbers
		cpi temp, 1 ;not num repeat
		breq maxStations_loop
		cpi temp, 2 ;big num error
		breq maxStations_error_message
		cpi temp3, 2 ;lower than 2 error
		brlo maxStations_error_message2
		mov stationNum, temp3
		rjmp maxStations_start ;correct num

	maxStations_error_message:
		do_lcd_command 0b1
		do_lcd_data 'E'
		do_lcd_data 'r'
		do_lcd_data	'r'
		do_lcd_data 'o'
		do_lcd_data 'r'
		do_lcd_data ' '
		rcall delay_30ms
		rjmp maxStations_start

	maxStations_error_message2:
		do_lcd_command 0b1
		do_lcd_data 'E'
		do_lcd_data 'r'
		do_lcd_data	'r'
		do_lcd_data 'o'
		do_lcd_data 'r'
		do_lcd_data ' '
		do_lcd_data '<'
		do_lcd_data '2'
		rcall delay_100ms
		clr temp4
		rjmp maxStations_start
;//=== Max Stations End ===\\

;//=== Loading Bar Start ===\\
	next_section:
		;message
		do_lcd_command 0b1
		do_lcd_data 'P'
		rcall delay_30ms
		do_lcd_data 'L'
		rcall delay_30ms
		do_lcd_data	'E'
		rcall delay_30ms
		do_lcd_data 'A'
		rcall delay_30ms
		do_lcd_data 'S'
		rcall delay_30ms
		do_lcd_data 'E'
		rcall delay_30ms
		do_lcd_data ' '
		do_lcd_data 'W'
		rcall delay_30ms
		do_lcd_data 'A'
		rcall delay_30ms
		do_lcd_data 'I'
		rcall delay_30ms
		do_lcd_data 'T'
		rcall delay_30ms
		do_lcd_command 0b11000000
		do_lcd_data 'L'
		rcall delay_30ms
		do_lcd_data 'O'
		rcall delay_30ms
		do_lcd_data 'A'
		rcall delay_30ms
		do_lcd_data 'D'
		rcall delay_30ms
		do_lcd_data 'I'
		rcall delay_30ms
		do_lcd_data 'N'
		rcall delay_30ms
		do_lcd_data 'G'
		rcall delay_30ms
		clr temp2
		next_section_loop:
		inc temp2
		do_lcd_data 0b00101101
		do_lcd_command 0b10000 ;go back one
		rcall delay_100ms
		do_lcd_data 0b00101111
		do_lcd_command 0b10000
		rcall delay_100ms
		do_lcd_data 0b01111100
		do_lcd_command 0b10000
		rcall delay_100ms
		do_lcd_data 0b11001101
		do_lcd_command 0b10000
		rcall delay_100ms
		cpi temp2, 1
		brlo next_section_loop
		ret
;//=== Loading Bar End ===\\

;//=== Time Between Stations Start ===\\
	.macro endWrap ;num
		;inc num unless its at the max then wrap around
		ldi temp, AsciiNum
		sub @0, temp
		cp @0, stationNum
		brlo endWrap_end
		sub @0, stationNum
		endWrap_end:
		inc @0
		ldi temp, AsciiNum
		add @0, temp
	.endmacro
	.macro Askfortime
		do_lcd_data 'T'
		do_lcd_data 'i'
		do_lcd_data	'm'
		do_lcd_data 'e'
		do_lcd_data ' '
		do_lcd_data 'f'
		do_lcd_data 'r'
		do_lcd_data 'o'
		do_lcd_data 'm'
		do_lcd_data ' '
		do_lcd_command 0b11000000
		do_lcd_data 'S'
		ldi temp2, AsciiNum
		add temp2, temp4
		endWrap temp2
		mov_lcd_data temp2
		do_lcd_data ' '
		do_lcd_data 't'
		do_lcd_data 'o'
		do_lcd_data ' '
		do_lcd_data 'S'
		endWrap temp2
		mov_lcd_data temp2
		do_lcd_data ':'
	.endmacro
	timeBetweenStations_end:
		ld temp4, -Y ;load in last value
		ldi YL, low(times)
		ldi YH, high(times)
		st y, temp4 ;store last value, see bellow note
		ret
	timeBetweenStations:
		do_lcd_command 0b1
		ld temp4, y+ ;====================================================== NOTE SHIFTING ONE PLACE FOR STORAGE TECH WHERE THE LAST STATION TO FIRST STATION TIME IS STORED AT THE START
		clr temp4
		
	timeBetweenStations_start:
		cp temp4, stationNum
		breq timeBetweenStations_end
		clr temp3
		Askfortime
		jmp timeBetweenStations_loop
	timeBetweenStations_loop: 
		rcall keypad
		rcall convert_numbers
		cpi temp, 1 ;not num repeat
		breq timeBetweenStations_loop
		cpi temp, 2 ;big num error
		breq timeBetweenStations_error_message
		;correct number stored into y
		st y+, temp3 ;store the correct num into y
		rjmp timeBetweenStations_start

	timeBetweenStations_error_message:
		do_lcd_command 0b1
		do_lcd_data 'E'
		do_lcd_data 'r'
		do_lcd_data	'r'
		do_lcd_data 'o'
		do_lcd_data 'r'
		do_lcd_data ' '
		

		rcall delay_30ms
		do_lcd_command 0b11000000 ;second row
		jmp timeBetweenStations_start ;restart
;//=== Time Between Station End ===\\

;//=== Stop Time Request Start ===\\
	.macro askForStopTime
		do_lcd_command 0b1
		do_lcd_data 'S'
		do_lcd_data 't'
		do_lcd_data	'o'
		do_lcd_data 'p'
		do_lcd_data ' '
		do_lcd_data 't'
		do_lcd_data 'i'
		do_lcd_data 'm'
		do_lcd_data 'e'
		do_lcd_data ' '
		do_lcd_data 'i'
		do_lcd_data 's'
		do_lcd_data	' '
		do_lcd_command 0b11000000 ;second line
		do_lcd_data ' '
		do_lcd_data ' '
		do_lcd_data ' '
		do_lcd_data 's'
		do_lcd_data 'e'
		do_lcd_data 'c'
		do_lcd_data 'o'
		do_lcd_data 'n'
		do_lcd_data 'd'
		do_lcd_data 's'
		clr temp2
		back_10_loop:
			do_lcd_command 0b10000 ;go back one
			inc temp2
		cpi temp2, 10
		brlo back_10_loop
	.endmacro
	stopTimeRequest_end: 
		ret
	stopTimeRequest:
		clr temp4
	stopTimeRequest_start:
		cpi temp4, 1
		breq stopTimeRequest_end
		clr temp3
		askForStopTime
		jmp stopTimeRequest_loop
	stopTimeRequest_loop: 
		rcall keypad
		rcall convert_numbers
		cpi temp, 1 ;not num repeat
		breq stopTimeRequest_loop
		cpi temp3, 11 ;big num error
		brsh stopTimeRequest_error_message
		cpi temp3, 2 ;lower than 2 error
		brlo stopTimeRequest_error_message2
		
		mov stoptime, temp3
		rjmp stopTimeRequest_start ;correct num
	stopTimeRequest_error_message:
		do_lcd_command 0b1
		do_lcd_data 'E'
		do_lcd_data 'r'
		do_lcd_data	'r'
		do_lcd_data 'o'
		do_lcd_data 'r'
		do_lcd_data ' '
		do_lcd_data '>'
		do_lcd_data '1'
		do_lcd_data '0'
		rcall delay_100ms
		rjmp stopTimeRequest_start
	stopTimeRequest_error_message2:
		do_lcd_command 0b1
		do_lcd_data 'E'
		do_lcd_data 'r'
		do_lcd_data	'r'
		do_lcd_data 'o'
		do_lcd_data 'r'
		do_lcd_data ' '
		do_lcd_data '<'
		do_lcd_data '2'
		rcall delay_100ms
		clr temp4
		rjmp stopTimeRequest_start
;//=== Stop Time Request End ===\\

;//=== Read and Print Stations Start ===\\
	.macro	PrintName
		;"Next:" message
			do_lcd_command 0b1
			do_lcd_data 'N'
			rcall delay_10ms
			do_lcd_data 'E'
			rcall delay_10ms
			do_lcd_data 'X'
			rcall delay_10ms
			do_lcd_data 'T'
			rcall delay_10ms
			do_lcd_data ':'

		;Name of Next Stop
		clr r1
		Loop_PN:
			ld temp, z+
			mov_lcd_data temp
			inc r1
			ldi temp, 10
			cp r1, temp
			brlo Loop_PN
		;do_lcd_data '@'
		rcall delay_100ms
	.endmacro
	
	.macro hashCheck
		push temp2
		ldi mask, hashcol
		sts PORTL, mask
		ldi temp, 0xFF
		hashCheck_stablisation:
			dec temp2
			brne hashCheck_stablisation
		LDS temp2, PINL
		andi temp2, ROWMASK
		cpi temp2, ROWMASK
		breq zeroReturn
		ldi mask, hashrow
		and temp2, mask
		brne zeroReturn
		ldi temp, 0xFF
		mov @0, temp
		out PORTC, temp
		rcall delay_100ms
		rjmp hashCheck_end

		zeroReturn:
			clr @0
		hashCheck_end:
		pop temp2
	.endmacro

	hashInterrupt:
		;"EMERGENCY STOP" message
			do_lcd_command 0b11000000
			do_lcd_data 'E'
			rcall delay_10ms
			do_lcd_data 'M'
			rcall delay_10ms
			do_lcd_data 'E'
			rcall delay_10ms
			do_lcd_data 'R'
			rcall delay_10ms
			do_lcd_data 'G'
			rcall delay_10ms
			do_lcd_data 'E'
			rcall delay_10ms
			do_lcd_data 'N'
			rcall delay_10ms
			do_lcd_data 'C'
			rcall delay_10ms
			do_lcd_data 'Y'
			rcall delay_10ms
			do_lcd_data ' '
			rcall delay_10ms
			do_lcd_data 'S'
			rcall delay_10ms
			do_lcd_data 'T'
			rcall delay_10ms
			do_lcd_data 'O'
			rcall delay_10ms
			do_lcd_data 'P'
			rcall delay_10ms
		

		push r12
		clr r12
		ldi temp, 0
		sts OCR4CL, temp
		sts OCR4CH, temp

		interrupt_loop:
			hashCheck temp
			sbrc temp, 0
			rjmp hashInterrupt_end

			rcall delay_10ms
			inc r12
			ldi temp, 20
			cp r12, temp
			brlo interrupt_loop
			ldi temp, 0b11
			out PORTC, temp

			ldi temp, 33
			cp r12, temp
			brlo interrupt_loop
			ldi temp, 0b00
			out PORTC, temp
			ldi temp, 0
			mov r12, temp
			rjmp interrupt_loop

		hashInterrupt_end:
		ldi temp, motorSpeed
		sts OCR4CL, temp
		clr temp
		sts OCR4CH, temp
		pop r12
		;Clear "EMERGENCY STOP" message
			do_lcd_command 0b11000000
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_data ' '
			do_lcd_command 0b11000000
			clr r2
			block_loop:
				inc r2
				do_lcd_data 0xff
				cp r2, r3
				brne block_loop
		ldi temp, 0b10101010
		out PORTC, temp
	ret

	.macro travelling
		push r15
		push r14
		push r13
		sei
		ldi temp, motorSpeed
		sts OCR4CL, temp
		clr temp
		sts OCR4CH, temp

		ldi temp, 0b10101010
		out PORTC, temp

		clr r3
		do_lcd_command 0b11000000
		do_lcd_data 0xff

		mov r14, TravelTime
		travelling_loop:
			inc r3
			ldi temp, 100
			mov r15, temp
			in temp, pinc
			com temp
			out PORTC, temp
			travelling_1s:
				rcall delay_10ms
				hashCheck temp
				sbrc temp, 0
				rcall hashInterrupt
				dec r15
				brne travelling_1s
			do_lcd_data 0xff
			dec r14
			brne travelling_loop
		
		clr temp
		out PORTC, temp
		cli
		pop r13
		pop r14
		pop r15
	.endmacro

	.macro stopping
		do_lcd_command 0b1
		do_lcd_data 'T'
		do_lcd_data 'R'
		do_lcd_data 'A'
		do_lcd_data 'I'
		do_lcd_data 'N'
		do_lcd_data ' '
		do_lcd_data 'S'
		do_lcd_data 'T'
		do_lcd_data 'O'
		do_lcd_data 'P'
		do_lcd_data 'P'
		do_lcd_data 'I'
		do_lcd_data 'N'
		do_lcd_data 'G'
		do_lcd_command 0b11000000

		clr temp
		sts OCR4CL, temp
		sts OCR4CH, temp
		mov r15, stoptime
		clr r14
		clr temp
		out PORTC, temp
		stopping_loop:
			ldi temp, 100
			mov r14, temp
			stopping_1s:
				in temp, pinc
				inc temp
				out PORTC, temp
				rcall delay_10ms
				dec r14
				brne stopping_1s
			dec r15
			brne stopping_loop
		ldi temp, 0
		mov r5, temp
	.endmacro

	RP:
		do_lcd_command 0B1
		;do_lcd_data '#'
		;rcall delay_30ms
		ldi zl, low(array)
		ldi zh, high(array)
		ldi yl, low(times)
		ldi yh, high(times)
		clr currStation
		inc currStation
		adiw z, 10
		ld temp, y+
		ld temp, y+
		mov TravelTime, temp

	RP_loop:
		PrintName
		;do_lcd_data '$'
		;rcall delay_100ms
		inc currStation
		;ascii_print currStation
		;rcall delay_100ms
		
		cp currStation, stationNum ;last name check
		brlo cont ;not last name
		
		ldi zl, low(array)
		ldi zh, high(array)
		ldi yl, low(times)
		ldi yh, high(times)
		clr currStation

		cont:
		;ascii_print TravelTime
		;rcall delay_100ms
		travelling
		ldi temp, 0xFF
		cp temp, r5
		brne cont2_relay
		jmp cancer
		cont2_relay: jmp cont2
		cancer:
		stopping

		cont2:
		ld temp, y+
		mov TravelTime, temp
		;ascii_print stoptime
		;rcall delay_100ms
		jmp RP_loop


;//=== Read and Print Stations End ===\\


;//=== LCD screen commands ===\\\
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

	; Send a command to the LCD (temp)
		lcd_command:
			out PORTF, temp
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
			out PORTF, temp
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
			push temp
			clr temp
			out DDRF, temp
			out PORTF, temp
			lcd_set LCD_RW
		lcd_wait_loop:
			nop
			lcd_set LCD_E
			nop
			nop
			nop
			in temp, PINF
			lcd_clr LCD_E
			sbrc temp, 7
			rjmp lcd_wait_loop
			lcd_clr LCD_RW
			ser temp
			out DDRF, temp
			pop temp
			ret
	
	delay_100ms:
		rcall delay_30ms
		rcall delay_30ms
		rcall delay_30ms
		rcall delay_10ms
		ret
	
	delay_30ms:
		push r24
		ldi r24, 30
		delay_loop_loop:
		rcall delay_10ms
		dec r24
		brne delay_loop_loop
		pop r24
		ret

	delay_10ms: ;80000c
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
;//=== LCD screen commands end ===\\\