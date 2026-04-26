.MODEL SMALL
.STACK 100h
; degiskenleri tanimliyoruz
.DATA
    welcome DB 'HARF YAKALAMA OYUNUNA HOSGELDINIZ$'
    instructions DB 'A: sepet sola D: sepet saga B: basla$'
    hiz DB 1
    score DB 0
    msg1 DB 'hiz=$'
    msg2 DB ' score=$'
    statusLabel DB 'hiz=  score=   $'
    msg3 DB ' bir harf gir: $'
    basket DB '\________/$'
    next_letter_prompt DB 'Baslamak icin B ye bas$'
    falling_char DB 0
    fall_row DB 5
    fall_col DB 0
    fall_counter DB 0
    prev_row DB 0
    prev_col DB 0
    basketX DB 20
    prev_basketX DB 20
    blank_basket DB '          $'
    game_over_msg DB '45 pauana ulastiniz tebrikler'
    
.CODE
    MOV AX, @DATA
    MOV DS, AX
    
    ; Print welcome message
    MOV AH, 09h
    MOV DX, OFFSET welcome
    INT 21h
    
    ; New line
    MOV DL, 0Dh
    MOV AH, 02h
    INT 21h
    MOV DL, 0Ah
    MOV AH, 02h
    INT 21h
    
    ; Print instructions
    MOV AH, 09h
    MOV DX, OFFSET instructions
    INT 21h
    
    ; New line
    MOV DL, 0Dh
    MOV AH, 02h
    INT 21h
    MOV DL, 0Ah
    MOV AH, 02h
    INT 21h
    

    ; Print " bir harf gir: "
    MOV AH, 09h
    MOV DX, OFFSET msg3
    INT 21h
    
    ; Read a character from keyboard
    MOV AH, 01h
    INT 21h
    MOV BL, AL
    
    ; New line
    MOV DL, 0Dh
    MOV AH, 02h
    INT 21h
    MOV DL, 0Ah
    MOV AH, 02h
    INT 21h

        ; Print next letter prompt
    MOV AH, 09h
    MOV DX, OFFSET next_letter_prompt
    INT 21h
    
    
    
    ; Read keyboard input
    MOV AH, 01h
    INT 21h
    
    ; Check if input is 'B'
    CMP AL, 'B'
    JNE generate_letter
    
    generate_letter:

    ; New line
    MOV DL, 0Dh
    MOV AH, 02h
    INT 21h
    MOV DL, 0Ah
    MOV AH, 02h
    INT 21h

    
    ; Generate random letter (A-Z)
    MOV AH, 00h
    INT 1Ah
    MOV AL, DL
    MOV CL, 26
    XOR AH, AH
    DIV CL
    ADD AL, 'A'
    MOV falling_char, AL

    ; Generate random column (20-79)
    MOV AH, 00h
    INT 1Ah
    MOV AL, DL
    MOV CL, 60
    XOR AH, AH
    DIV CL
    ADD AL, 20
    MOV fall_col, AL

    ; Loop to display falling letter 17 times
    falling_loop:

    ; Check keyboard input without blocking
    MOV AH, 01h
    INT 16h
    JZ no_key_pressed

    ; Read key
    MOV AH, 00h
    INT 16h

    ; Check for 'A' key (move left)
    CMP AL, 'A'
    JE move_basket_left
    CMP AL, 'a'
    JE move_basket_left

    ; Check for 'D' key (move right)
    CMP AL, 'D'
    JE move_basket_right
    CMP AL, 'd'
    JE move_basket_right

    JMP no_key_pressed

move_basket_left:
    MOV AL, basketX
    CMP AL, 0
    JBE no_key_pressed
    MOV AL, basketX
    MOV prev_basketX, AL
    DEC basketX
    
    ; Clear previous basket position
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 20
    MOV DL, prev_basketX
    INT 10h
    MOV AH, 09h
    MOV DX, OFFSET blank_basket
    INT 21h
    JMP no_key_pressed

move_basket_right:
    MOV AL, basketX
    CMP AL, 70
    JAE no_key_pressed
    MOV AL, basketX
    MOV prev_basketX, AL
    INC basketX
    
    ; Clear previous basket position
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 20
    MOV DL, prev_basketX
    INT 10h
    MOV AH, 09h
    MOV DX, OFFSET blank_basket
    INT 21h

no_key_pressed:

    ; Set cursor position to row 20, col basketX
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 20
    MOV DL, basketX
    INT 10h
    
    ; Print basket
    MOV AH, 09h
    MOV DX, OFFSET basket
    INT 21h
    
    ; Clear previous letter position if not first iteration
    CMP fall_counter, 0
    JE skip_clear
    MOV AH, 02h
    MOV BH, 0
    MOV DH, prev_row
    MOV DL, prev_col
    INT 10h
    MOV AH, 02h
    MOV DL, ' '
    INT 21h
skip_clear:
    
    ; Set cursor position for falling letter
    MOV AH, 02h
    MOV BH, 0
    MOV DH, fall_row
    MOV DL, fall_col
    INT 10h
    
    ; Print falling character
    MOV AH, 02h
    MOV DL, falling_char
    INT 21h
    
    ; Update previous position
    MOV AL, fall_row
    MOV prev_row, AL
    MOV AL, fall_col
    MOV prev_col, AL
    
    ; Increment row
    INC fall_row
    INC fall_counter
    
    ; Apply speed-based delay between iterations
    MOV AL, hiz
    CMP AL, 1
    JE delay_1
    JMP check_fall_count

    MOV AL, hiz
    CMP AL, 2
    JE delay_2
    JMP check_fall_count

    MOV AL, hiz
    CMP AL, 3
    JE delay_3
    JMP check_fall_count

    MOV AL, hiz
    CMP AL, 4
    JMP check_fall_count


check_fall_count:
    ; Check if we've fallen 17 times
    CMP fall_counter, 17
    JL falling_loop

    ; Check catch: is falling char in basket column range and matches input
    MOV AL, fall_col
    MOV CL, basketX
    MOV CH, basketX
    ADD CH, 10
    
    ; Check if fall_col is within basket range
    CMP AL, CL
    JL miss_letter
    CMP AL, CH
    JG miss_letter
    
    ; fall_col is in basket range, check if letter matches
    MOV AL, falling_char
    CMP AL, BL
    JNE wrong_letter
    
    ; Correct letter caught
    INC score
    JMP miss_letter
    
wrong_letter:
    ; Wrong letter caught, subtract 5
    SUB score, 5
    JMP check_game_end

check_game_end:
    ; Check if score reached 45
    CMP score, 45
    JL miss_letter
    
    ; Game over - score reached 45
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 10
    MOV DL, 15
    INT 10h
    MOV AH, 09h
    MOV DX, OFFSET game_over_msg
    INT 21h
    
    ; Exit game
    MOV AH, 4Ch
    INT 21h

miss_letter:
    call update_speed
    call update_status
    ; Clear last letter from screen
    MOV AH, 02h
    MOV BH, 0
    MOV DH, prev_row
    MOV DL, prev_col
    INT 10h
    MOV AH, 02h
    MOV DL, ' '
    INT 21h

    MOV fall_row, 5
    MOV fall_counter, 0
    JMP generate_letter

update_speed:
    MOV AL, score
    CMP AL, 30
    JGE speed_4
    CMP AL, 20
    JGE speed_3
    CMP AL, 10
    JGE speed_2
    MOV AL, 1
    JMP speed_done

speed_2:
    MOV AL, 2
    JMP speed_done

speed_3:
    MOV AL, 3
    JMP speed_done

speed_4:
    MOV AL, 4

speed_done:
    MOV hiz, AL
    RET

delay_1:
    mov cx, 05FFh

    bekle_1:
    loop bekle_1
    JMP check_fall_count

delay_2:
    mov cx, 03FFh

    bekle_2:
    loop bekle_2
    JMP check_fall_count

delay_3:
    mov cx, 02FFh

    bekle_3:
    loop bekle_3
    JMP check_fall_count


update_status:
    MOV DH, 4
    MOV DL, 0
    CALL set_cursor
    MOV DX, OFFSET statusLabel
    MOV AH, 09h
    INT 21h

    MOV DH, 4
    MOV DL, 4
    CALL set_cursor
    MOV AL, hiz
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV DH, 4
    MOV DL, 12
    CALL set_cursor
    MOV AL, score
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    RET

set_cursor:
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    RET

    ; New line
    MOV DL, 0Dh
    MOV AH, 02h
    INT 21h
    MOV DL, 0Ah
    MOV AH, 02h
    INT 21h
    
    
    
    ; Exit
    MOV AH, 4Ch
    INT 21h
END