.include "m2560def.inc"

.def temp = r16
.def row = r17
.def col = r18
.def mask = r19
.def temp2 = r20

.def temp3 = r21
.def temp4 = r22
.def temp5 = r23
.def max_stations = r24

.equ PORTLDIR = 0xF0
.equ INITCOLMASK = 0xEF
.equ INITROWMASK = 0x01
.equ ROWMASK = 0x0F

.equ LAST_COLUMN = 3
.equ UNSET_POSITION = 4
.equ MAX_CHARACTERS = 10

.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro

.macro mov_lcd_data
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro do_lcd_data
	ldi r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.dseg
array: .byte 111

.cseg
jmp RESET

.org 0x72

RESET:
	ldi zl, low(array)
	ldi zh, high(array)

    ldi temp, low(RAMEND)
    out SPL, temp
    ldi temp, high(RAMEND)
    out SPH, temp

    ldi temp, PORTLDIR ; columns are outputs, rows are inputs
    sts DDRL, temp     ; cannot use out

    ser temp
	out DDRF, temp
	out DDRA, temp
	clr temp
	out PORTF, temp
	out PORTA, temp

    do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_5ms
	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_1ms
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00001000 ; display off?
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink

    ldi temp3, 4
    ldi temp4, 1
    clr temp5

; Prompts for a station name
;    @0 is the current station number
.macro station_name_prompt
    do_lcd_command 0b00000001
    do_lcd_data 'S'
    do_lcd_data 'T'
    do_lcd_data 'A'
    do_lcd_data 'T'
    do_lcd_data 'I'
    do_lcd_data 'O'
    do_lcd_data 'N'
	do_lcd_data ' '
	mov_lcd_data @0
    do_lcd_data ' '
	do_lcd_data 'N'
    do_lcd_data 'A'
    do_lcd_data 'M'
    do_lcd_data 'E'
    do_lcd_data ':'
	do_lcd_command 0b11000000
.endmacro

; This subroutine is a sub-section of the  system configuration portion of the project
;    It reads in station names inputted by the user through the keypad
;       System configuration stored into a consecutive block of memory addresses in SRAM
read_in_stations:
    ; Prompt message shown on function call
    station_name_prompt temp4

        read_in_stations_loop:

            rcall keypad_listener ; listens for keypad presses, sets row and col values
            ; using row and col values, converts, stores and outputs character values into memory and LCD
            rcall character_convert

            cpi temp5, '#' ; end of input, exit the program if this is pressed
            breq read_in_stations_loop_exit

            rjmp read_in_stations_loop

            read_in_stations_loop_exit:

                adiw zh:zl, 1 ; Shift memory address by one to skip over time between stations value
                clr temp5

                ; check if we've reached maxed stations
                cpi temp4, max_stations
                breq read_in_stations_return 

                ; continue with read in stations loop
                inc temp4 
                rjmp read_in_stations

        read_in_stations_return:
            ret

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
    breq store_temp3

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
    ;    (key_distance_from_2 * 3) + 'A' + temp3 where, key_distance_from_2 = key press - 2,
    ;        'A' is decimal value 65 and temp3 is character position selection
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
    cpi temp3, LAST_COLUMN
    breq last_temp3

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

        cpi col, 2 ; hash represents end of input
        breq end_of_input

        ; otherwise do nothing
        jmp character_convert_end

    white_space:
        ldi temp, ' '

        ; do nothing if we've reached max characters, just waiting for end of input
        cpi temp5, MAX_CHARACTERS
        brne not_max_chars

        jmp character_convert_end

    end_of_input:

        ; Calculate how many memory addresses we need to pad by
        ldi temp, MAX_CHARACTERS
        mov temp2, temp5
        sub temp, temp2 ; MAX_CHARACTERS - temp5 = Padding
        ldi temp2, ' ' ; Character to write to memory

        cpi temp, 0 ; No padding required
        breq end_of_input_exit

        memory_padding:
            st z+, temp2
            dec temp ; Pad this amount of times
            brne memory_padding

        end_of_input_exit:
            ldi temp5, '#'
            jmp character_convert_end
    
    ; *** Position selection helpers ***
    store_temp3:
        ; Row is the character position to be used on next key press
        mov temp3, row 
        ret 

    ; *** Character conversion core helpers ***
    increment_result:
        inc temp

    last_temp3:
        ; Catches the case where blocks 1-6 and last position asked for 
        cpi temp2, 7
        ; Go back to listening for a key press
        brlt character_convert_end

        cpi temp2, 8 ; Catches the case for block 8
        breq character_convert_end

        ; Anything here has a valid last position selection
        add temp, temp3
        clr temp2

        ; do nothing if we've reached max characters, just waiting for end of input
        cpi temp5, MAX_CHARACTERS
        brne not_max_chars

        jmp character_convert_end

    character_convert_end:
        ; reset the temp3
        ldi temp3, 4
        ret ; return to caller

    not_max_chars:
        ; store in next memory address 
        st z+, temp
        ; output this character onto LCD
        mov_lcd_data temp
        ; increment the count
        inc temp5
        ret
;