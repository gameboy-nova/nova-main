; Pin Configuration
;   +--------- TFT ---------+
;   |      D0   =  PA0      |
;   |      D1   =  PA1      |
;   |      D2   =  PA2      |
;   |      D3   =  PA3      |
;   |      D4   =  PA4      |
;   |      D5   =  PA5      |
;   |      D6   =  PA6      |
;   |      D7   =  PA7      |
;   |-----------------------|
;   |      RST  =  PA8      |
;   |      BCK  =  PA9      |
;   |      RD   =  PA10     |
;   |      WR   =  PA11     |
;   |      RS   =  PA12     |
;   |      CS   =  PA15     |
;   +-----------------------+
	IMPORT MSG
	IMPORT MSG2
    IMPORT PLAYER
    IMPORT DIGITS
    IMPORT CUSTOM_DELAY
    IMPORT PRINT
    IMPORT PRINT_NUM
    IMPORT DRAW_TITLE
    IMPORT DELAY_1_SECOND
    IMPORT DRAW_RECT
    IMPORT TFT_DrawCenterRect
    IMPORT DRAW_DIGIT
    IMPORT DRAW_DIGITAL
    IMPORT TFT_DrawImage
    IMPORT TFT_FillScreen
	IMPORT GAME_MAIN
    IMPORT GAME_BACK_HANDLE
    IMPORT BACK_TO_MAIN
    IMPORT Ball
    IMPORT TFT_DrawImage_Center
    EXPORT PongMain
    
	AREA MYPONGDATA, DATA, READWRITE

;Colors
Black   EQU 0x0000
DarkGreen EQU 0x142A
LightGreen EQU 0x1f06
DARKBLUE EQU 0x001F
DARKRED EQU 0x7800
P1_CLR  EQU 0x001F
P2_CLR  EQU 0x7800 
BallColour EQU 0xFFFF
BACK_COLOUR EQU 0x1f06
Lines_Colour EQU 0xFFFF

GPIOA_BASE      EQU     0x40020000
GPIOB_BASE		EQU		0x40020400

GPIO_IDR        EQU     0x10

; Constants
SCREEN_WIDTH    EQU     320
SCREEN_HEIGHT   EQU     240
HBAT_WIDTH      EQU     3   ;Half the BatWidth, for easier drawing from center
HBAT_HEIGHT     EQU     15  ;Same with BAT_WIDTH
BAT_WIDTH       EQU     7   
BAT_HEIGHT      EQU     41   
BALL_SIZE       EQU     9       ; this should be 9 for the symmetry of the ball like ||||*||||
HBALL_SIZE      EQU     4
BAT_MOVE_SPEED  EQU     6
BALL_MOVE_SPEED EQU    	5
UPPER_BOUND     EQU     30       ; IF BALL HITS THAT BOUND IT REBOUNCES
LOWER_BOUND     EQU     5
RIGHT_BOUND     EQU     3
LEFT_BOUND      EQU     3
TITLE_X         EQU     120
TITLE_Y         EQU     5
Score1_X        EQU     72
Score2_X        EQU     232
P1LABEL_X            EQU     2
P2LABEL_X            EQU     286
Score_Y         EQU     5
CHAR_SIZE       EQU     20
CHAR_MEM_SIZE   EQU     520
MAX_SCORE       EQU     5    

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
; Print contants
ASCII_CHAR_OFFSET EQU 'A'
ASCII_NUM_OFFSET EQU '0'
CHAR_WIDTH EQU 16

; Game state variables
p1_score        DCB     0
p2_score        DCB     0
ball_x          DCW     160     ; Initial ball position
ball_y          DCW     120

;ball_dx/dy is x/y motion state :
;0->no change
;1->increase
;2->decrease
ball_dx         DCW     0       ; Ball direction (1 or 2)
ball_dy         DCW     1       ; initial position goes to the right player

p1_Y            DCW     120      ; Player 1 bat position
p2_Y            DCW     120     ; Player 2 bat position
p1_X            EQU     30
p2_X            EQU     290

DELAY_INTERVAL  EQU     0x18604 
SOURCE_DELAY_INTERVAL EQU   0x386004   
FRAME_DELAY 	EQU 	0x10500

    AREA PONGRESET, CODE, READONLY
	
PongMain FUNCTION
    BL VARS_INIT

    LDR R5, =BACK_COLOUR
    BL TFT_FillScreen

    BL DELAY_1_SECOND
	
	BL PONGGAME_MAIN

    B .
    ENDFUNC

P1_WIN
   ; LDR R5, =P1_CLR
   ; BL TFT_FillScreen
      ;Draw Score
    MOV R1, Score1_X
    MOV R2, Score_Y
    LDR R3, =p1_score
    LDRB R3, [R3]
    BL	DRAW_DIGIT

    MOV R1, #40
	MOV R2, #127
	LDR R3, =MSG
	MOV R4, #P1_CLR
	MOV R5, #BACK_COLOUR ; THIS IS THE BACKGROUND
	BL PRINT
    B GAME_DONE
    
P2_WIN
    ;LDR R5, =P2_CLR
    ;BL TFT_FillScreen
    MOV R1, Score2_X
    MOV R2, Score_Y
    LDR R3, =p2_score
    LDRB R3, [R3]
    BL	DRAW_DIGIT

    MOV R1, #40
	MOV R2, #127
	LDR R3, =MSG2
	MOV R4, #P2_CLR 
	MOV R5, #BACK_COLOUR  ; THIS IS THE BACKGROUND
	BL PRINT
    B GAME_DONE

;####################################################*"Functions"*##############################################################################################
	LTORG
PONGGAME_MAIN    
    PUSH {R0-R12, LR}
    LDR R1, =p1_score
    LDRB R1, [R1]
    CMP R1, MAX_SCORE
    BEQ P1_WIN

    LDR R1, =p2_score
    LDRB R1, [R1]
    CMP R1, MAX_SCORE
    BEQ P2_WIN

    ;First wait for button press
    LDR R5, =BACK_COLOUR
    BL TFT_FillScreen

 ;DRAWING BLACK OF SCORE
    MOV R1,#0
    MOV R2,#0
    MOV R3,#319
    MOV R4,#UPPER_BOUND-4
    MOV R5,#Black
    BL DRAW_RECT
 
 ;Draw P1 LABEL

    MOV R1, P1LABEL_X
	MOV R2, Score_Y
	LDR R3, =PLAYER
	MOV R4, #P1_CLR
	MOV R5, #Black ; THIS IS THE BACKGROUND
	BL PRINT

    MOV R1,P1LABEL_X+CHAR_WIDTH
    MOV R2,Score_Y
    MOV R3,1
    BL PRINT_NUM

;Draw P2 LABEL
     MOV R1, P2LABEL_X
	MOV R2, Score_Y
	LDR R3, =PLAYER
	MOV R4, #P2_CLR
	MOV R5, #Black ; THIS IS THE BACKGROUND
	BL PRINT

    
    MOV R1,P2LABEL_X+CHAR_WIDTH
    MOV R2,Score_Y
    MOV R3,2
    BL PRINT_NUM

    ;Render Initial Objects
    LDR R5, =P1_CLR
    LDR R6, =P2_CLR
    BL RENDER_BATS
    LDR R5, =BACK_COLOUR
    BL RENDER_BALL

    ;Draw Title of Game (PING)
    BL DRAW_TITLE
    

    ;Draw Score
    MOV R1, Score1_X
    MOV R2, Score_Y
    LDR R3, =p1_score
    LDRB R3, [R3]
    BL	DRAW_DIGIT

    MOV R1, Score2_X
    MOV R2, Score_Y
    LDR R3, =p2_score
    LDRB R3, [R3]
    BL	DRAW_DIGIT
    

DrawBorders
; LEFT BOUND
    MOV R1,#LEFT_BOUND-1
    MOV R2,#UPPER_BOUND-1
    MOV R3,#LEFT_BOUND-1
    MOV R4,#SCREEN_HEIGHT-LOWER_BOUND+1
    MOV R5,#Lines_Colour
    BL DRAW_RECT
; RIGHT BOUND
    MOV R1,#(SCREEN_WIDTH-RIGHT_BOUND+1)
    MOV R3,#(SCREEN_WIDTH-RIGHT_BOUND+1)
    BL DRAW_RECT

;   UPPER BOUND
    MOV R1,#LEFT_BOUND-1
    MOV R2,#UPPER_BOUND-1
    MOV R3,#SCREEN_WIDTH-RIGHT_BOUND+1
    MOV R4,#UPPER_BOUND-1
    BL DRAW_RECT

;   LOWER BOUND
    MOV R2,#SCREEN_HEIGHT-LOWER_BOUND+1
    MOV R4,#SCREEN_HEIGHT-LOWER_BOUND+1
    BL DRAW_RECT


WAIT_FOR_PRESS
    BL GET_STATE
    BL BACK_TO_MAIN
    CMP R3, #0
    BEQ WAIT_FOR_PRESS
GAME_LOOP

	BL BACK_TO_MAIN

    ;Get state
    ;-TODO- DONE!
    BL GET_STATE

    ;Erase Previous Rendered objects
    LDR R5, =BACK_COLOUR
    LDR R6, =BACK_COLOUR
    BL RENDER_BALL
    CMP R3, #0
    BLNE RENDER_BATS
    
    ;Update Positions
    ;-TODO- DONE!
    BL UPDATE_POS

    ;Re-render the new objects
    LDR R5, =P1_CLR
    LDR R6, =P2_CLR
    BL RENDER_BATS
    LDR R5, =BallColour
    BL RENDER_BALL



    ;Delay
	LDR R0, =2*FRAME_DELAY
	BL CUSTOM_DELAY
            
    ;Check for End Events (Win Score Reached/Exit Button pressed ... etc)
    ;TODO:

    ;Loop to GAME_MAIN

    B GAME_LOOP
	POP {R0-R12,PC}
    ;TODO: DISPLAY WIN SCREEN

GAME_DONE
; CHECK IF A BUTTON IS PRESSED 
    LDR R1, =PongMain
	B GAME_BACK_HANDLE
    B .



;#####################################################################################################################################################################	
; Initializes the variables with the appropriate values
VARS_INIT
    PUSH {R0-R1, LR}             ; Save R0, R1 and Link Register

    ; Initialize p1_score to 0
    LDR  R0, =p1_score
    MOV  R1, #0
    STRB R1, [R0]

    ; Initialize p2_score to 0
    LDR  R0, =p2_score
    STRB R1, [R0]

    ; Initialize ball_x to 160
    LDR  R0, =ball_x
    MOV  R1, #160
    STRH R1, [R0]

    ; Initialize ball_y to 120
    LDR  R0, =ball_y
    MOV  R1, #((SCREEN_HEIGHT-UPPER_BOUND)/2+UPPER_BOUND)
    STRH R1, [R0]

    ; Initialize ball_dx to 1 (left)
    LDR  R0, =ball_dx
    MOV  R1, #2
    STRH R1, [R0]

    ; Initialize ball_dy to 2 (up)
    LDR  R0, =ball_dy
    MOV  R1, #2
    STRH R1, [R0]

    ; Initialize p1_Y to 120
    LDR  R0, =p1_Y
    MOV  R1, #((SCREEN_HEIGHT-UPPER_BOUND)/2+UPPER_BOUND)
    STRH R1, [R0]

    ; Initialize p2_Y to 120
    LDR  R0, =p2_Y
    STRH R1, [R0]

    POP {R0-R1, LR}              ; Restore R0 and Link Register
    BX   LR ; Return from subroutine

;#####################################################################################################################################################################	
; R5 -> P1 Render Colour
; R6 -> P2 Render Color
RENDER_BATS
    PUSH {R0-R4,R7-R12, LR}

    MOV R1, #p1_X
    LDR R2, =p1_Y
    LDRH R2, [R2]
    MOV R3, #HBAT_WIDTH
    MOV R4, #HBAT_HEIGHT
    BL TFT_DrawCenterRect

    MOV R5, R6
	MOV R1, #p2_X
    LDR R2, =p2_Y
    LDRH R2, [R2]
    MOV R3, #HBAT_WIDTH
    MOV R4, #HBAT_HEIGHT
    BL TFT_DrawCenterRect

    POP {R0-R4,R7-R12, PC}

; R5 -> Render Colour
RENDER_BALL
    PUSH {R0-R4,R6-R12, LR}

    LDR R1, =ball_x
    LDRH R1, [R1]
    LDR R2, =ball_y
    LDRH R2, [R2]

    MOV R0, #BACK_COLOUR
    CMP R5, R0
    BNE RENDER_BALL_IMAGE

    MOV R3, #HBALL_SIZE
    MOV R4, #HBALL_SIZE
    BL TFT_DrawCenterRect
    B END_RENDER_BALL
RENDER_BALL_IMAGE
    LDR R3, =Ball
    BL TFT_DrawImage_Center

END_RENDER_BALL
    POP {R0-R4,R6-R12, PC}
;#####################################################################################################################################################################	
;R3->STATE
;0000->NoChange, 0001->A_Up, 0010->A_Down, 0100->B_Up, 1000->B_Down
;Allows for multiple states at the same time (ie. 0101 A_Up & B_Up)
GET_STATE
        PUSH {R0-R1, LR}
        ; Load the value of buttons pressed
        LDR R0, =GPIOB_BASE + GPIO_IDR
        LDRH R1, [R0]

        MOV R3, #0

        TST R1, #BTN_AU         
        ORRNE R3, #(1 << 0)
        TST R1, #BTN_AD         
        ORRNE R3, #(1 << 1)
        TST R1, #BTN_BU         
        ORRNE R3, #(1 << 2)
        TST R1, #BTN_BD         
        ORRNE R3, #(1 << 3)

        POP {R0-R1, PC}
;#####################################################################################################################################################################	
;R3 -> STATE
;R1 -> p1_y
;R2 -> p2_y
;R4 -> ball_x
;R5 -> ball_y
;R6 -> Adresses register
;R8 -> ball_dx, R9 -> ball_dy
    LTORG
UPDATE_POS  
    PUSH    {R1-R2, R4-R12, LR}

    ; LOAD PLAYER 1 POS TO R1
    LDR R6, =p1_Y
    LDRH R1, [R6] 
    ; LOAD PLAYER 2 POS TO R2
    LDR R6, =p2_Y
    LDRH R2, [R6]

    LDR R6, =ball_x
    LDRH R4, [R6]

    LDR R6, =ball_y
    LDRH R5, [R6]

    ; LOAD ball_dx & ball_dy
    LDR R6, =ball_dx
    LDRH R8, [R6]

    LDR R6, =ball_dy
    LDRH R9, [R6]
P1_UPDATE
    TST R3, #(1 << 0)
    SUBNE R1, R1, #BAT_MOVE_SPEED
    
    TST R3, #(1 << 1)
    ADDNE R1, R1, #BAT_MOVE_SPEED

    CMP R1, #(20 + UPPER_BOUND)
    MOVLT R1, #(20 + UPPER_BOUND) ;TODO change to HBALL_Height 

    CMP R1, #(220 - LOWER_BOUND)
    MOVGT R1, #(220 - LOWER_BOUND)
END_P1

P2_UPDATE
    TST R3, #(1 << 2)
    SUBNE R2, R2, #BAT_MOVE_SPEED

    TST R3, #(1 << 3)
    ADDNE R2, R2, #BAT_MOVE_SPEED

    CMP R2, #(20 + UPPER_BOUND)
    MOVLT R2, #(20 + UPPER_BOUND)

    CMP R2, #(220 - LOWER_BOUND)
    MOVGT R2, #(220 - LOWER_BOUND)
END_P2

BALL_UPDATE
;#####################################################################################################################################################################	
;CHECK COLLISIONS:

    B COLLISION_CHECK

;#####################################################################################################################################################################	

BALL_X_UPDATE
    CMP R8,#0
    BEQ BALL_Y_UPDATE

    CMP R8,#1
    ADDEQ     R4, R4,#BALL_MOVE_SPEED     ; x += BALL_X_SPEED
    BEQ BALL_Y_UPDATE

    CMP R8,#2
    SUBEQ   R4,R4,#BALL_MOVE_SPEED

BALL_Y_UPDATE        
    CMP R9,#0
    BEQ END_BALL

    CMP R9,#1
    ADDEQ R5,R5,#BALL_MOVE_SPEED
    BEQ END_BALL

    CMP R9,#2
    SUBEQ R5, R5,#BALL_MOVE_SPEED ; y -= BALL_Y_SPEED

END_BALL
;#####################################################################################################################################################################	
END_UPDATE
    LDR R6, =p1_Y
    STRH R1, [R6]
    LDR R6, =p2_Y
    STRH R2, [R6]
    LDR R6, =ball_x
    STRH R4, [R6]
    LDR R6, =ball_y
    STRH R5, [R6]
    LDR R6, =ball_dx
    STRH R8, [R6]
    LDR R6, =ball_dy
    STRH R9, [R6]

    POP     {R1-R2, R4-R12, PC}

;#####################################################################################################################################################################	
COLLISION_CHECK
;R3 -> STATE
;R1 -> p1_y
;R2 -> p2_y
;R4 -> ball_x
;R5 -> ball_y
;R6 -> Adresses register
;R8 -> ball_dx, R9 -> ball_dy

FLOOR_CHECK
    CMP R5, #(SCREEN_HEIGHT-LOWER_BOUND-HBALL_SIZE-2)
    MOVGE R9, #2 ; decrease y
    BGE COLDONE

CEIL_CHECK
    CMP R5, #(UPPER_BOUND + HBALL_SIZE+2)
    MOVLE R9, #1 ; increase y
    BLE COLDONE

LEFT_CHECK  
    CMP R4, #(LEFT_BOUND + HBALL_SIZE+3)
    BLE P2Scores
    

RIGHT_CHECK
    LDR R11, =(SCREEN_WIDTH - RIGHT_BOUND - HBALL_SIZE-3) 
    CMP R4, R11
    BGE P1Scores
    
;R3 -> STATE
;R1 -> p1_y
;R2 -> p2_y
;R4 -> ball_x
;R5 -> ball_y
;R6 -> Adresses register
;R8 -> ball_dx, R9 -> ball_dy

P1_BAT_CHECK
    MOV R7, #0

    LDR R10, =p1_Y
    LDRH R10, [R10]
    ADD R10, R10, #(HBAT_HEIGHT+HBALL_SIZE)
    CMP R5, R10
    ADDLE R7, R7, #1
    BGT P2_BAT_CHECK


    SUB R10, R10, #(HBAT_HEIGHT+HBALL_SIZE)
    SUB R10, R10, #(HBAT_HEIGHT+HBALL_SIZE)
    CMP R5, R10
    ADDGE R7, R7, #1
    BLT P2_BAT_CHECK
    
    CMP R4, #(p1_X + HBAT_WIDTH + HBALL_SIZE) 
    ADDLE R7, R7 ,#1

    CMP R4, #(p1_X - HBAT_WIDTH)
    ADDGE R7, R7 ,#1


    CMP R7, #4
    MOVEQ R8, #1
    BEQ COLDONE

P2_BAT_CHECK
    MOV R7, #0

    LDR R10, =p2_Y
    LDRH R10, [R10]
    ADD R10, R10, #(HBAT_HEIGHT+HBALL_SIZE)
    CMP R5, R10
    ADDLE R7, R7, #1
    BGT COLDONE

    SUB R10, R10, #(HBAT_HEIGHT+HBALL_SIZE)
    SUB R10, R10, #(HBAT_HEIGHT+HBALL_SIZE)
    CMP R5, R10
    ADDGE R7, R7, #1
    BLT COLDONE
    
    LDR R10, =283
    CMP R4, R10
    ADDGE R7, R7 ,#1
    
    LDR R10, =298
    CMP R4, R10
    ADDLE R7, R7 ,#1

    CMP R7, #4
    MOVEQ R8, #2

COLDONE

    B BALL_X_UPDATE
;----------------------------------------------------------------------------
P1Scores   ; Player 1 scores
    PUSH{R0,R1}
        LDR     R0, =p1_score
        LDRB    R1, [R0]
        ADD     R1, R1, #1
        STRB    R1, [R0]
    POP{R0,R1}
        B      ResetAll      ; Resets The Ball LOCATION In Memory NOT IN REGISTERS R4,R5 SO THAT WE CAN REMOVE OLD BALL
                
P2Scores        ; Player 2 scores
    PUSH{R0,R1}
        LDR     R0, =p2_score
        LDRB    R1, [R0]
        ADD     R1, R1, #1
        STRB    R1, [R0]
    POP{R0,R1}
        B      ResetAll
;#####################################################################################################################################################################	

ResetAll       
    PUSH    {R0-R1}

    ; Initialize ball_x to 160
    LDR  R0, =ball_x
    MOV  R1, #160
    STRH R1, [R0]

    ; Initialize ball_y to 120
    LDR  R0, =ball_y
    MOV  R1, #((SCREEN_HEIGHT-UPPER_BOUND)/2+UPPER_BOUND)
    STRH R1, [R0]
    
    ; Initialize p1_Y to 120
    LDR  R0, =p1_Y
    MOV  R1, #((SCREEN_HEIGHT-UPPER_BOUND)/2+UPPER_BOUND)
    STRH R1, [R0]

    ; Initialize p2_Y to 120
    LDR  R0, =p2_Y
    STRH R1, [R0]

    LDR R0, =ball_dx
    STRH R8, [R0]
    LDR R6, =ball_dy
    STRH R9, [R0]

    POP     {R0-R1}

    B PONGGAME_MAIN
;#####################################################################################################################################################################	
    END