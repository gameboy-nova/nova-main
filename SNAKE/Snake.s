
    EXPORT SNAKE_GAME
	import image
	import snake_up
	import downSnake
	import right_snake 
	import left_snake
	import snake_body
	import CHARS
	import DIGITS
	import GAME_MAIN
	import SNAKE_LABEL
	import SCORE_LABEL
	import WIN_MESSAGE
	import LOSE_MESSAGE
	import SCORE_MESSAGE
	import DRAW_RECT
	import CUSTOM_DELAY
	import DELAY_1_SECOND
	import PRINT
	import PRINT_NUM
	import TFT_DrawImage
	import GAME_BACK_HANDLE
	import BACK_TO_MAIN

    AREA MYDATA, DATA, READWRITE
 
;Colors
Red     EQU 0xF800  ; 11111 000000 00000
Green   EQU 0x07E0  ; 00000 111111 00000
Blue    EQU 0x001F  ; 00000 000000 11111
Yellow  EQU 0xFFE0  ; 11111 111111 00000
White   EQU 0xFFFF  ; 11111 111111 11111
Black   EQU 0x0000  ; 00000 000000 00000 
 
 
; Define register base addresses
RCC_BASE        EQU     0x40023800
GPIOA_BASE      EQU     0x40020000
GPIOB_BASE		EQU		0x40020400
GPIOC_BASE		EQU		0x40020800
GPIOD_BASE		EQU		0x40020C00
GPIOE_BASE		EQU		0x40021000
 
; Define register offsets
RCC_AHB1ENR     EQU     0x30
GPIO_MODER      EQU     0x00
GPIO_OTYPER     EQU     0x04
GPIO_OSPEEDR    EQU     0x08
GPIO_PUPDR      EQU     0x0C
GPIO_IDR        EQU     0x10
GPIO_ODR        EQU     0x14
 
; Control Pins on Port E
TFT_RST         EQU     (1 << 8)
TFT_RD          EQU     (1 << 10)
TFT_WR          EQU     (1 << 11)
TFT_DC          EQU     (1 << 12)
TFT_CS          EQU     (1 << 15)

; Game Pad buttons A
BTN_AR          EQU     (1 << 3)
BTN_AL          EQU     (1 << 5)
BTN_AU          EQU     (1 << 1)
BTN_AD          EQU     (1 << 4)

; Game Pad buttons B
BTN_BR          EQU     (1 << 7)
BTN_BL          EQU     (1 << 9)
BTN_BU          EQU     (1 << 8)
BTN_BD          EQU     (1 << 6)


BTN_BCK 		EQU 	(1 << 2)


DELAY_INTERVAL  EQU     0x18604 
SOURCE_DELAY_INTERVAL EQU   0x386004   
FRAME_DELAY 	EQU 	0x68605

; Screen
SCREEN_WIDTH EQU 320
SCREEN_HEIGHT EQU 240
; Print contants
ASCII_CHAR_OFFSET EQU 'A'
ASCII_NUM_OFFSET EQU '0'
CHAR_WIDTH EQU 16


;SNAKE INFO
SNAKE_SIZE DCB 0X1
SNAKE_ARRAY  SPACE 256 
	
DIRECTION DCB 	0X1

SYST_CVR EQU 0xE000E018  ; check this address is correct
APPLE_POSITION DCW 0X0809  ;  0X((X1),(Y1))      
Apple_random_pos DCW 0X0809
	EXPORT SNAKE_GAME
    AREA RESET, CODE, READONLY

SNAKE_GAME
	BL START_UP_SNAKE


Snake_Loop

	BL BACK_TO_MAIN


	BL get_random
    LDR R0, =2*FRAME_DELAY
    BL CUSTOM_DELAY
	;R12 does not change so it stores its last direction
    BL READ_INPUT
	LDR R0,=DIRECTION
	LDRB R12,[R0]

    CMP R12, #1
    BEQ MOV_UP_SNAKE
	
    CMP R12, #2
    BEQ MOV_DOWN_SNAKE

    CMP R12, #3
    BEQ MOV_RIGHT_SNAKE

    CMP R12, #4
    BEQ MOV_LEFT_SNAKE

	

    B Snake_Loop

MOV_UP_SNAKE

	LDR R8,=SNAKE_ARRAY
    LDRH R9,[R8]
	; PUT X IN R0, Y IN R1
	MOV R0,R9
	LSR R0,#8
	MOV R1,R9
	AND R1,#0xFF
	; IF I IN THE HIGHEST ROW 
	CMP R1,#3
	BEQ START_FROM_BOTTOM
	
	; IF NOT
	SUB R1,#1
	;PUT DIMENSION IN R9

    MOV R9,R0
	LSL R9,#8
	ADD R9,R1
	
	BL MOVE_THE_SNAKE
	 B Snake_Loop
START_FROM_BOTTOM
	MOV R1,#30
	;PUT DIMENSION IN R9
	MOV R9,R0
	LSL R9,#8
	ADD R9,R1
	BL MOVE_THE_SNAKE
    B Snake_Loop
MOV_DOWN_SNAKE
	LDR R8,=SNAKE_ARRAY
    LDRH R9,[R8]
	; PUT X IN R0, Y IN R1
	MOV R0,R9
	LSR R0,#8
	MOV R1,R9
	AND R1,#0xFF
	; IF I IN THE ROW 30 
	CMP R1,#30
	BEQ START_FROM_UP
	
	; IF NOT
	ADD R1,#1
	;PUT DIMENSION IN R9
	MOV R9,R0
	LSL R9,#8
	ADD R9,R1
	BL MOVE_THE_SNAKE
	B Snake_Loop
START_FROM_UP
	MOV R1,#3
	;PUT DIMENSION IN R9
	MOV R9,R0
	LSL R9,#8
	ADD R9,R1
	BL MOVE_THE_SNAKE
    B Snake_Loop

MOV_RIGHT_SNAKE
	LDR R8,=SNAKE_ARRAY
    LDRH R9,[R8]
	; PUT X IN R0, Y IN R1
	MOV R0,R9
	LSR R0,#8
	MOV R1,R9
	AND R1,#0xFF
	; IF I IN THE COLUMN 40 
	CMP R0,#40
	BEQ START_FROM_LEFT
	
	; IF NOT
	ADD R0,#1
	;PUT DIMENSION IN R9
	MOV R9,R0
	LSL R9,#8
	ADD R9,R1
	BL MOVE_THE_SNAKE
	B Snake_Loop
START_FROM_LEFT
	MOV R0,#1
	;PUT DIMENSION IN R9
	MOV R9,R0
	LSL R9,#8
	ADD R9,R1
	BL MOVE_THE_SNAKE
    B Snake_Loop


MOV_LEFT_SNAKE



	LDR R8,=SNAKE_ARRAY
    LDRH R9,[R8]
	; PUT X IN R0, Y IN R1
	MOV R0,R9
	LSR R0,#8
	MOV R1,R9
	AND R1,#0xFF
	; IF I IN THE COIUMN 1 
	CMP R0,#1
	BEQ START_FROM_RIGHT
	
	; IF NOT
	SUB R0,#1
	;PUT DIMENSION IN R9
	MOV R9,R0
	LSL R9,#8
	ADD R9,R1
	BL MOVE_THE_SNAKE
	B Snake_Loop
START_FROM_RIGHT
	MOV R0,#40
	;PUT DIMENSION IN R9
	MOV R9,R0
	LSL R9,#8
	ADD R9,R1
	BL MOVE_THE_SNAKE
    B Snake_Loop
GET_DIMENSIONS
    ;R1 = X1
	;R2 = Y1
	;R3 = X2
	;R4 = Y2
    ;GETS THE DIMENSION OF THE SNAKE TO REDRAW
    ;GET X,R6-Y,R7
    PUSH{R6-R9,LR}
    MOV R7,R9  ;GET Y
	AND R7,R7,#0XFF
    LSR R6,R9,#8
	AND R6,R6,#0XFF
    ;MULTIPLYING BY 8 
    LSL R6,#3
    LSL R7,#3
	
	SUB R6,#4
	SUB R7,#4
    ;GET X1,X2
    MOV R1,R6
    SUB R1,#4
    MOV R3,R6
    ADD R3,#3
    ;GET Y1,Y2
    MOV R2,R7
    SUB R2,#4
    MOV R4,R7
    ADD R4,#3
    POP {R6-R9,PC}

    ENDFUNC

	

START_UP_SNAKE
	;draw the whole background
	;R1 = X1
	;R2 = Y1
	;R3 = X2
	;R4 = Y2
	;R5 = COLOR
	PUSH{R0-R11,LR}
	MOV R1, #0
    MOV R2, #0									 
    MOV R3, #320
    MOV R4, #240                            
    LDR R5, =Black										 
	BL DRAW_RECT
	;Draw border
	MOV R1, #0
    MOV R2, #15									 
    MOV R3, #320
    MOV R4, #15                            
    LDR R5, =White
	BL DRAW_RECT

	MOV R1, #0
	MOV R2, #0
	LDR R3, =SNAKE_LABEL
	MOV R4, #White
	MOV R5, #Black
	BL PRINT

	MOV R1, #191
	MOV R2, #0
	LDR R3, =SCORE_LABEL
	MOV R4, #White
	MOV R5, #Black
	BL PRINT
	

;SET SNAKE DIMENSION
	LDR R0,=SNAKE_ARRAY
	LDR R1,[R0]
	MOV R1,#0x140F
	STR R1,[R0]
	MOV R1,#0x1410
	STR R1,[R0,#2]

	LDR R0,=SNAKE_SIZE
	LDRB R1,[R0]
	MOV R1,#0X02
	STRB R1,[R0]
;Draw Snake
	LDR R8,=SNAKE_ARRAY
    LDRH R9,[R8]
    BL GET_DIMENSIONS
	LDR R3,=snake_up
	BL TFT_DrawImage
	
	BL PRINT_SCORE

	LDR R8,=SNAKE_ARRAY
    LDRH R9,[R8,#2]                                                                               
    BL GET_DIMENSIONS
    LDR R3,=snake_body
	BL TFT_DrawImage
	

	;Draw_APPLE
	LDR R10,=APPLE_POSITION
	MOV R9,0X0303
	STRH R9,[R10]
	
	LDR R0,=Apple_random_pos
	MOV R9,0X0303
	STRH R9,[R0]
	
	BL Draw_APPLE
	LDR R0, =DIRECTION
	MOV R1,#1
	STRB R1,[R0]
	
	POP{R0-R11,PC}
	
	
	

    
;####################################################"Functions"##############################################################################################
 
;#####################################################################################################################################################################	
 

READ_INPUT
	PUSH {R0-R1, LR}

    LDR R0, =GPIOB_BASE + GPIO_IDR
    LDR R1, [R0]

	
    TST R1, #BTN_AR
	BNE COMMAND_RIGHT

    TST R1, #BTN_AL
	BNE COMMAND_LEFT

    TST R1, #BTN_AU
	BNE COMMAND_UP
    
    TST R1, #BTN_AD
	BNE COMMAND_DOWN
	
	TST R1, #1
	BNE GROWTH_COMMAND

    B END_INPUT

COMMAND_RIGHT
	CMP R12,#4
	BEQ END_INPUT
	LDR R0,=DIRECTION
	MOV R12,#3
	STRB R12,[R0]
	B END_INPUT

COMMAND_LEFT
	CMP R12,#3
	BEQ END_INPUT
	LDR R0,=DIRECTION
	MOV R12,#4
	STRB R12,[R0]
	B END_INPUT

COMMAND_DOWN
	CMP R12,#1
	BEQ END_INPUT
	LDR R0,=DIRECTION
	MOV R12,#2
	STRB R12,[R0]
	B END_INPUT
COMMAND_UP
	CMP R12,#2
	BEQ END_INPUT
	LDR R0,=DIRECTION
	MOV R12,#1
	STRB R12,[R0]
	B END_INPUT
	
GROWTH_COMMAND
	MOV R12,#5
;	TST R1, #1   ; D0 TO CHANGE COLOR
;	MOVNE R12,#5 ;INDICATES COLOR CHANGE COMMAND
 
END_INPUT
  
	POP {R0-R1, PC}
;#####################################################################################################################################################################	
	LTORG
 ;=================================SNAKE_LOGIC===========================
; this branch generate random num and put it in R0
get_random
	push{R0,R1,LR}
	LDR R1, =Apple_random_pos 
	LDRH R0, [R1]
	;AND R0,#0XFFFF
	;ADD R0,#0X0101
	;PUT X IN R2, Y IN R3
	MOV R2,R0
	LSR R2,#8
	AND R2,0XFF

	MOV R3,R0
	AND R3,0XFF
	
	ADD R2,#1
	CMP R2,#40 
	MOVEQ R2,#1

	ADD R3,#1
	CMP R3,#30 
	MOVEQ R3,#3

	;STORE X,Y IN R0
	MOV R0,R2
	LSL R0,#8
	ADD R0,R3

	STRH R0,[R1]
	POP{R0,R1,PC}
	
	
Draw_APPLE
		push{R0-R12,LR}
		
	; PUT APPLE POSITION IN R9
REDraw_APPLE
	BL get_random
	BL CHANGE_POS
	LDR R0,=APPLE_POSITION
	LDRH R9,[R0]	
		
	 	
		; detrmine wether there is a snake in r9 or not
		BL HAS_SNAKE     ; IF R10=0 -> THERE IS NOT A SNAKE ->RRAW
						 ; IF R10=1 -> THERE IS A SNAKE GET ANOTHER PLACE
		CMP R10,#1
        BEQ REDraw_APPLE	
		
		;DRAW THE APPLE
		;CHANGE THIS TO PICTURE :)
		;GET CORRECT DIMENSIONS
		BL GET_DIMENSIONS
		;SET COLOR RED
		;LDR R5,=Red
		;DRAW THE APPLE
	;	BL DRAW_RECT
		LDR R3, =image
		BL TFT_DrawImage
		
		POP{R0-R12,PC}
		
; IF THERE IS A SNAKE MAKE R10=1 
; IF FREE -> R10=0
HAS_SNAKE
	PUSH{R0-R9,LR}
	LDR R4,=SNAKE_ARRAY
	MOV R10,#0x0
	;SET R1 AS COUNT
	LDR R2,=SNAKE_SIZE
	LDRB R1,[R2]
; IF SNAKE LENGHT =1
	CMP R1,#1
	BEQ LAST_CHECK

	SUB R1,#1
	
COMPARE_LOOP
;SIZE 3

	LDRH R3,[R4,R1,LSL #1] 
	CMP R3,R9
	BEQ HAS_A_SNAKE
	SUB R1,#1
	CMP R1,#0
	BEQ LAST_CHECK
	B COMPARE_LOOP
	
LAST_CHECK
	LDRH R3,[R4]
	CMP R3,R9
	BEQ HAS_A_SNAKE
	B TO_END
	
HAS_A_SNAKE

; IF THERE IS A SNAKE MAKE R10=1 
	MOV R10,#0X1


TO_END

	POP{R0-R9,PC}
				

	
; PUT THE NEW POSITION OF HEAD IN R9 THEN CALL THE FUNCTION
;NEW POSITION IN R9
MOVE_THE_SNAKE

	PUSH{R0-R1,R9,LR}
	
	; CHECK IF I EAT MYSELF OR NOT
;	@ BL HAS_SNAKE
;	@ CMP R10,#1
;	@ BEQ LOSE_SCREEN
	BL HAS_SNAKE

	CMP R10,#1
	BEQ LOSE_SCREEN
	; CHECK IF I EAT AN APPLE OR NOT
	LDR R0,=APPLE_POSITION
	LDRH R1,[R0]
	CMP R9,R1
	BLEQ GROW_SNAKE
	BL REDRAW_SNAKE
       
	BL SHIFT_LOOP

END_MOVE
	POP{R0-R1,R9,PC}



GROW_SNAKE
	PUSH{R0-R3,LR}										 
	
	LDR R0,=SNAKE_SIZE
	LDRB R1,[R0]
	ADD R1,#1
	STRB R1,[R0]

	CMP R1,#17
	BEQ WIN_SCREEN

	LDR R2,=SNAKE_ARRAY
	SUB R1,#1
	LDRH R3,[R2,R1,LSL #1]
	MOV R3,#0
	STRH R3,[R2,R1,LSL #1]

	BL PRINT_SCORE

	BL Draw_APPLE
	
	POP{R0-R3,PC}

SHIFT_LOOP
	;PUSH{R0-R12,LR}



	LDR R4,=SNAKE_ARRAY
	
	LDR R10,=SNAKE_SIZE
	LDRB R1,[R10]
    
    ; Check if size is one get out of the loop
    CMP R1, #1
    BEQ SHIFT_END


	SUB R1,#1
	SUB R2, R1, #1
INLINE_LOOP	
	LDRH R5,[R4,R2,LSL #1]
	STRH R5,[R4,R1,LSL #1]
	SUB R2,#1
	SUB R1,#1

	CMP R1,#0 ;WHY NOT CMP R2,#0

	BNE INLINE_LOOP
	;TO MOVE LAST ELEMNT

SHIFT_END
	STRH R9, [R4]
    ; R3 was here before
	;POP{R0-R12,PC}
	B END_MOVE
	
WIN_SCREEN

	MOV R1, #0
    MOV R2, #0									 
    MOV R3, #320
    MOV R4, #240                            
    LDR R5, =Green										 
	BL DRAW_RECT
	MOV R1,#40
	MOV R2,#112
	LDR R3,=WIN_MESSAGE
	LDR R4,=Black
	LDR R5,=Green
	BL PRINT

	LDR R1, =SNAKE_GAME
	B GAME_BACK_HANDLE

	B .

LOSE_SCREEN

	MOV R1, #0
    MOV R2, #0									 
    MOV R3, #320
    MOV R4, #240                            
    LDR R5, =Red										 
	BL DRAW_RECT
	MOV R1,#88
	MOV R2,#112
	LDR R3,=LOSE_MESSAGE
	LDR R4,=Black
	LDR R5,=Red
	BL PRINT
	MOV R1,#104
	MOV R2,#144
	LDR R3,=SCORE_MESSAGE
	LDR R4,=Black
	LDR R5,=Red
	BL PRINT
	MOV R1,#200
	MOV R2,#144
	LDR R4,=SNAKE_SIZE
	LDRB R3,[R4]
	SUB R3,#2
	LDR R4,=Black
	LDR R5,=Red
	BL PRINT_NUM

	LDR R1, =SNAKE_GAME
	B GAME_BACK_HANDLE

	B .
	
REDRAW_SNAKE	
	PUSH{R5,R7,R11,R10,R8,R9,LR}	
	;R9 HAS THE NEW HEAD POSTION
	;DRAW NEW HEAD
	
	BL GET_DIMENSIONS
	
	LDR R11,=DIRECTION
	LDRB R12,[R11]
	
	CMP R12,#1
	BEQ UP_PHOTO
	
	CMP R12,#2
	BEQ DOWN_PHOTO
	
	CMP R12,#3
	BEQ RIGHT_PHOTO
	
	CMP R12,#4
	BEQ LEFT_PHOTO
	
UP_PHOTO
	LDR R3,=snake_up
	B DRAW
DOWN_PHOTO
	LDR R3,=downSnake
	B DRAW
RIGHT_PHOTO
	LDR R3,=right_snake
	B DRAW
LEFT_PHOTO
	LDR R3,=left_snake
	B DRAW	
	
	;LDR R5,=Green
DRAW	
	BL TFT_DrawImage
	
	
	LDR R7,=SNAKE_ARRAY
	;LDR R11,=SNAKE_SIZE
	;LDRB R10,[R11]
   ; SUB R10,#1
	LDRH R8,[R7]
	;CMP R8,#0

	
	MOV R7,R9
	MOV R9,R8
	BL GET_DIMENSIONS
	;LDR R5,=Green
	;BL DRAW_RECT
	LDR R3,=snake_body
	BL TFT_DrawImage

	MOV R9,R7
	LDR R7,=SNAKE_ARRAY
	LDR R11,=SNAKE_SIZE
	LDRB R10,[R11]
    SUB R10,#1
	LDRH R8,[R7,R10,LSL #1]
	CMP R8,#0

	MOV R7,R9
	MOV R9,R8
	BL GET_DIMENSIONS
	LDR R5,=Black
	BL DRAW_RECT
	MOV R9,R7

	POP{R5,R7,R11,R10,R8,R9,PC}
	
CHANGE_POS
	PUSH{R0-R2,LR}
	LDR R0,=Apple_random_pos
	LDR R1,=APPLE_POSITION
	LDRH R2,[R0]
	STRH R2,[R1]
	
	;BL Draw_APPLE
	POP{R0-R2,PC}

PRINT_SCORE
	PUSH{R0-R5,LR}
	MOV R1,#287
	MOV R2,#0
	LDR R4,=SNAKE_SIZE
	LDRB R3,[R4]
	SUB R3,#2
	LDR R4,=Black
	LDR R5,=White
	BL PRINT_NUM
	POP{R0-R5,PC}

END