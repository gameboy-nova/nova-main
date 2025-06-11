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

    AREA MYDATA, DATA, READWRITE
    import P1_DOWN
    import P2_DOWN

    import P1_IDLE
    import P2_IDLE

    import P1_UP
    import P2_UP
	
    IMPORT GAME_BACK_HANDLE

	IMPORT EXPLOSION_FRAME_1
    IMPORT EXPLOSION_FRAME_2
    IMPORT EXPLOSION_FRAME_3

    IMPORT CHARS
    IMPORT DIGITS

    import SIMPLE_ENEMY
    IMPORT P1_WIN_MSG
    IMPORT P2_WIN_MSG
    IMPORT WELCOME_MSG_1
    IMPORT WELCOME_MSG_2

    import DRAW_RECT
    import DELAY_1_SECOND
    import CUSTOM_DELAY
		
	IMPORT TFT_DrawCenterRect
    IMPORT DRAW_DIGIT
    IMPORT DRAW_DIGITAL
    IMPORT TFT_DrawImage_Center
    IMPORT TFT_FillScreen
	IMPORT GAME_MAIN
    IMPORT PRINT
    IMPORT PRINT_NUM
    IMPORT BACK_TO_MAIN

    IMPORT GAME_TITLE
    EXPORT STAR_BLAST_MAIN


;Player positions
RAND_SEED   DCD      0x00000000
P1_SCORE   DCD      0x00000000
P2_SCORE   DCD      0x00000000
P1_POS_Y    DCW      0x0000
P2_POS_Y    DCW      0x0000
P1_BULLET SPACE 3
P2_BULLET SPACE 3

ENEMIES_SIZE EQU 20
ENEMIES_POS SPACE (ENEMIES_SIZE * 3)
ENEMIES_DATA SPACE (ENEMIES_SIZE)


;Colors
Red     EQU 0xF800
Green   EQU 0x0340
Blue    EQU 0x001F
Yellow  EQU 0xFFE0
Black   EQU 0x0000
White   EQU 0xFFFF
Gray    EQU 0xe73d
Pink    EQU 0xf81f
Orange  EQU 0xfce1
Purple  EQU 0x5153
Dark_Blue EQU 0x1c74
BACKGROUND      EQU    Black

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

; Control Pins on Port A
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

; Screen
SCREEN_WIDTH EQU 320
SCREEN_HEIGHT EQU 240
RIGHT_BOUNDRY EQU 250
LEFT_BOUNDRY EQU 70
; Space_Ship
SHIP_WIDTH      EQU     20
SHIP_HEIGHT     EQU     20
; Bullet
BULLET_WIDTH EQU 2
; Player
P1_X      EQU    15
P1_START_Y      EQU    120
P2_X      EQU    305
P2_START_Y      EQU    120
PLAYER_SPEED EQU 2
BULLET_SPEED EQU 4
MAX_SCORE EQU 15
UPPER_PLAYER_BOUND EQU 20
; Enemey
ENEMEY_WIDTH EQU 10
ENEMEY_HEIGHT EQU 10
ENEMEY_CHANCE EQU 50

ENEMEY_LV1_CHANCE EQU 70
ENEMEY_LV2_CHANCE EQU 20 + ENEMEY_LV1_CHANCE
ENEMEY_LV3_CHANCE EQU 10 + ENEMEY_LV2_CHANCE
START_FRAME_GENERATE EQU 80
MIN_FRAME_GENERATE EQU 50
; Input States
P1_UP_STATE EQU (1 << 0)
P1_DOWN_STATE EQU (1 << 1)
P1_BULLET_STATE EQU (1 << 4)
P2_UP_STATE EQU (1 << 2)
P2_DOWN_STATE EQU (1 << 3)
P2_BULLET_STATE EQU (1 << 5)
; Print contants
ASCII_CHAR_OFFSET EQU 'A'
ASCII_NUM_OFFSET EQU '0'
CHAR_WIDTH EQU 16


DELAY_INTERVAL  EQU     0x18604 
SOURCE_DELAY_INTERVAL EQU   0x386004   
FRAME_DELAY 	EQU 	0xA8604
MOVEMENT_DELAY       EQU    0x10FFF

    AREA RESET, CODE, READONLY
	
__main FUNCTION

STAR_BLAST_MAIN
    MOV R1, #0
    MOV R2, #0
    MOV R3, #320
    MOV R4, #240
    MOV R5, #BACKGROUND
    BL DRAW_RECT

    
    MOV R1,#88
    MOV R2, #104
    LDR R3, =WELCOME_MSG_1
    MOV R4, #White
    MOV R5, #Black
    BL PRINT
    MOV R1,#72
    MOV R2, #120
    LDR R3, =WELCOME_MSG_2
    MOV R4, #White
    MOV R5, #Black
    BL PRINT

    LDR R0, =GPIOB_BASE + GPIO_IDR
    MOV R10, #0
WELCOME_SCREEN_LOOP
    LDR R1, [R0]
    MOV R5, #0x3FA
    TST R1, R5
    BNE SKIP_WELCOME_SCREEN
    
    ADD R10, R10, #1
    B WELCOME_SCREEN_LOOP

SKIP_WELCOME_SCREEN


    MOV R1, #0
    MOV R2, #0
    MOV R3, #320
    MOV R4, #240
    MOV R5, #BACKGROUND
    BL DRAW_RECT
    
    ; Adding R10, R0 THE random seed to get a random one each time
    LDR R0, =RAND_SEED
	LDR R1, =0x37DBF5E3
    ADD R1, R1, R10
    STR R1, [R0]

    ;initialization
    BL MEMORY_SETUP

    BL RENDER_PLAYERS

    MOV R1, #0
    MOV R2,#0
    MOV R3, #320
    MOV R4, #18
    MOV R5, #White
    BL DRAW_RECT

    MOV R1,#80
    MOV R2, #1
    LDR R3, =GAME_TITLE
    MOV R4, #Black
    MOV R5, #White
    BL PRINT
    
    BL GENERATE_ENEMIES
    MOV R11, #START_FRAME_GENERATE
    MOV R10, R11

START_BLAST_LOOP

    BL BACK_TO_MAIN

    MOV R1,#32
    MOV R2, #1
    LDR R0, =P1_SCORE
    LDR R3, [R0]
    MOV R4, #Black
    MOV R5, #White
    BL PRINT_NUM

    MOV R1,#272
    MOV R2, #1
    LDR R0, =P2_SCORE
    LDR R3, [R0]
    MOV R4, #Black
    MOV R5, #White
    BL PRINT_NUM

    BL HANDLE_EXPLOSIONS
    BL CHOOSE_ENEMEY_GENERATE
    BL GET_INPUT
    BL SHOOT_BULLET

    BL CLEAR_RENDER
    BL UPDATE_PLAYERS_POS


    BL UPDATE_BULLET_POS

    BL CHECK_ENEMIES_COLLISIONS


    BL RENDER_PLAYERS



    BL HANDLE_WIN
    BNE END_GAME

    LDR R0, =MOVEMENT_DELAY
    BL CUSTOM_DELAY


    B START_BLAST_LOOP
END_GAME
    LDR R1, =STAR_BLAST_MAIN
	B GAME_BACK_HANDLE
    B .
    ENDFUNC

    LTORG

MEMORY_SETUP
    PUSH{R0, R1, LR}
    LDR R0, =P1_POS_Y
    MOV R1, #P1_START_Y
    STRH R1, [R0]
    
    LDR R0, =P2_POS_Y
    MOV R1, #P2_START_Y
    STRH R1, [R0]

    ; Setting the intial value of the bullet
    LDR R0, =P1_BULLET
    MOV R1, #0xFFFF
    MOV R2, #0
    BL SET_POS

    LDR R0, =ENEMIES_POS
    MOV R10, #ENEMIES_SIZE
RESET_ENEMIES_POS_LOOP
    MOV R1, #0xFFFF
    MOV R2, #0
    BL SET_POS
    
    ADD R0, R0, #3
    SUBS  R10, R10, #1
    BNE RESET_ENEMIES_POS_LOOP

    LDR R0, =ENEMIES_DATA
    MOV R10, #ENEMIES_SIZE
    MOV R1, #0x3
RESET_ENEMIES_DATA_LOOP
    STRB R1, [R0], #1    
    SUBS  R10, R10, #1
    BNE RESET_ENEMIES_DATA_LOOP

    LDR R0, =P2_BULLET
    MOV R1, #0xFFFF
    MOV R2, #0
    BL SET_POS

    

    LDR R0, =P1_SCORE
	MOV R1, #0
    STR R1, [R0]


    LDR R0, =P2_SCORE
	MOV R1, #0
    STR R1, [R0]

    POP{R0, R1, PC}


HANDLE_WIN
    PUSH {R0-R12, LR}

P1_WIN
    LDR R0, =P1_SCORE
    LDR R1, [R0]

    CMP R1, #MAX_SCORE
    BLT P1_WIN_END

    MOV R1, #0
    MOV R2, #0
    MOV R3, #SCREEN_WIDTH
    MOV R4, #SCREEN_HEIGHT
    MOV R5, #Blue
    BL DRAW_RECT

    MOV R1,#64
    MOV R2, #112
    LDR R3, =P1_WIN_MSG
    MOV R4, #White
    MOV R5, #Blue
    BL PRINT

    MOVS R0, #1
    B END_WIN
P1_WIN_END
    MOVS R0, #0


P2_WIN
    LDR R0, =P2_SCORE
    LDR R1, [R0]

    CMP R1, #MAX_SCORE
    BLT P2_WIN_END

    MOV R1, #0
    MOV R2, #0
    MOV R3, #SCREEN_WIDTH
    MOV R4, #SCREEN_HEIGHT
    MOV R5, #Green
    BL DRAW_RECT

    MOV R1,#64
    MOV R2, #112
    LDR R3, =P2_WIN_MSG
    MOV R4, #White
    MOV R5, #Green
    BL PRINT

    MOVS R0, #1
    B END_WIN
P2_WIN_END
    MOVS R0, #0


END_WIN

    POP {R0-R12,PC}

GET_INPUT
	PUSH {R0-R1,LR}

	LDR R0, =GPIOB_BASE + GPIO_IDR
    LDR R1, [R0]

    MOV R7, #0

    ; Player 1 States
    TST R1, #BTN_AU
    ORRNE R7, #P1_UP_STATE

    TST R1, #BTN_AD
    ORRNE R7, #P1_DOWN_STATE

    TST R1, #BTN_AR 
    ORRNE R7, #P1_BULLET_STATE

    ; Player 2 States
    TST R1, #BTN_BU
    ORRNE R7, #P2_UP_STATE

    TST R1, #BTN_BD
    ORRNE R7, #P2_DOWN_STATE

    TST R1, #BTN_BR
    ORRNE R7, #P2_BULLET_STATE

	POP {R0-R1, PC}


GET_POS
    ; R0 is the offset of the position
    ; first 8 bits for Y and the other 16 bits for X

    PUSH{LR}
    LDRH R1, [R0, #1]
    LDRB R2, [R0]
    POP{PC}

SET_POS
    ; R0 is the offset of the position
    ; first 8 bits for Y and the other 16 bits for X

    PUSH{LR}
    STRH R1, [R0, #1]
    STRB R2, [R0]
    POP{PC}


IS_VALID
    PUSH {R4,LR}
    BL GET_POS
    MOV R4, #0xFFFF
    CMP R1, R4
    POP {R4,PC}

;#####################################################################################################################################################################	
; ENEMEY HANDLING
;#####################################################################################################################################################################	
LTORG

HANDLE_EXPLOSIONS
    PUSH {R0-R12,LR}

    LDR R9, =ENEMIES_POS
    LDR R11, =ENEMIES_DATA
    MOV R10, #ENEMIES_SIZE
UPDATE_EXPLOSIONS_LOOP
    MOV R5, #0
    LDRB R5, [R11]

    CMP R5, #3
    BGE SKIP_EXPLOSION_UPDATE


    CMP R5, #0
    LDREQ R3, =EXPLOSION_FRAME_1
    CMP R5, #1
    LDREQ R3, =EXPLOSION_FRAME_2
    CMP R5, #2
    MOVEQ R0, R9
    BLEQ GET_POS
    BLEQ DESTROY_ENEMY
    BEQ SKIP_DRAW_FRAME
    
    MOV R0, R9
    BL GET_POS
    BL TFT_DrawImage_Center
SKIP_DRAW_FRAME
    ADD R5, R5, #1
    STRB R5, [R11]


SKIP_EXPLOSION_UPDATE
    ADD R9, R9, #3
    ADD R11, R11, #1
    SUBS R10, R10, #1
    BNE UPDATE_EXPLOSIONS_LOOP
    
    POP {R0-R12, PC}


CHOOSE_ENEMEY_GENERATE
    PUSH {R0-R9, LR}
    SUBS R10, R10, #1
    BNE SKIP_CHOOSE_ENEMEY_GENERATE

    CMP R11, #MIN_FRAME_GENERATE
    SUBGT R11, R11, #1

    MOV R10, R11

    BL GENERATE_ENEMIES

    
    
SKIP_CHOOSE_ENEMEY_GENERATE
    POP {R0-R9,PC}



GENERATE_ENEMIES
    PUSH {R0-R12, LR}

    LDR R0, =ENEMIES_POS
    MOV R10, #ENEMIES_SIZE
GENERATE_ENEMIES_LOOP
    ; Check if position is valid and generate an enemy if so
    BL IS_VALID
    BNE SKIP_GENRATION

    BL GENERATE_ENEMEY
    B END_GENERATE

SKIP_GENRATION
    ADD R0, R0, #3
    SUBS  R10, R10, #1
    BNE GENERATE_ENEMIES_LOOP


END_GENERATE
    POP {R0-R12, PC}

CHECK_ENEMIES_COLLISIONS
    PUSH {R0-R12, LR}

    LDR R0, =ENEMIES_POS
    LDR R1, =ENEMIES_DATA
    MOV R10, #ENEMIES_SIZE
BASIC_ENEMEY_COLLISION_LOOP
    MOV R3, #0
    LDRB R3, [R1]
    ;CMP R3, #3
    ;BLE SKIP_BASIC_ENEMEY_COLLISION

    BL CHECK_ENEMY_COLLISION

SKIP_BASIC_ENEMEY_COLLISION
    ADD R0, R0, #3
    ADD R1, R1, #1
    SUBS  R10, R10, #1
    BNE BASIC_ENEMEY_COLLISION_LOOP

    POP {R0-R12, PC}


GENERATE_ENEMEY
    PUSH {R0-R12,LR}
    ; R0 takes an enemey position's address
    BL GET_RANDOM_ENEMEY_POS
    BL SET_POS
    



    ; change this
    LDR R3, =SIMPLE_ENEMY
    BL TFT_DrawImage_Center

    POP {R0-R12,PC}
    LTORG
GET_ENEMY_TYPE
    PUSH {R0-R4, LR}
    MOV R1, #1
    MOV R2, #100
    BL RAND_RANGE

    CMP R3, #ENEMEY_LV1_CHANCE
    MOVLE R5, #1
    CMP R3, #ENEMEY_LV2_CHANCE
    MOVLE R5, #2
    CMP R3, #ENEMEY_LV3_CHANCE
    MOVLE R5, #3

    POP {R0-R4, PC}



GET_RANDOM_ENEMEY_POS
    PUSH {R0,R3-R5,LR}

    MOV R1, #0
    MOV R2, #(RIGHT_BOUNDRY - LEFT_BOUNDRY) / 10 - 1
    BL RAND_RANGE

    MOV R5, R3

    MOV R1, #4
    MOV R2, #SCREEN_HEIGHT / 10 - 2
    BL RAND_RANGE

    
    MOV R0, #10
    MUL R5, R5, R0 ; R5 = X * 10
    MUL R2, R3, R0 ; R2 = Y * 10

    ADD R1, R5, #LEFT_BOUNDRY

    ADD R1, R1, #ENEMEY_WIDTH / 2
    ADD R2, R2, #ENEMEY_HEIGHT / 2

    POP {R0,R3-R5,PC}


DESTROY_ENEMY
    PUSH {R0-R12,LR}
    ; R0 has enemy position
    MOV R3, #ENEMEY_WIDTH / 2
    MOV R4, #ENEMEY_HEIGHT / 2
    MOV R5, #BACKGROUND
    BL TFT_DrawCenterRect

    LDR R1, =0xFFFF
    MOV R2, #0
    BL SET_POS

   
    POP {R0-R12,PC}


CHECK_ENEMY_COLLISION
    PUSH{R0-R12, LR}
    ; R0 contains enemey position
    MOV R12, R0

HANDLE_COLLISION_P1
    MOV R0, R12
    BL IS_VALID
    BEQ END_HANDLE_COLLISION_P1

    LDR R0, =P1_BULLET
    BL GET_POS

    MOV R5, R1
    MOV R6, R2

    MOV R0, R12
    BL GET_POS

    SUB R1, R1, R5
    ; GET ABSOLUTE (X_player - X_enemy)
    CMP R1, #0
    RSBLT R1, R1, #0

    SUB R2, R2, R6
    ; GET ABSOLUTE (Y_player - Y_enemy)
    CMP R2, #0
    RSBLT R2, R2, #0

    CMP R1, #ENEMEY_WIDTH / 2
    BGT END_HANDLE_COLLISION_P1

    CMP R2, #ENEMEY_HEIGHT / 2
    BGT END_HANDLE_COLLISION_P1



    ; Reset data information
    LDR R10, =ENEMIES_POS
    SUB R10, R12, R10
    MOV R0, #3
    UDIV R10, R10, R0

    LDR R0, =ENEMIES_DATA
    MOV R1, #0
    STRB R1, [R0, R10]


    LDR R0, =P1_BULLET
    BL GET_POS
    BL DESTROY_BULLET
    BL CLEAR_BULLET

    LDR R0, =P1_SCORE
    LDR R1, [R0]
    ADD R1, R1, #1
    STR R1, [R0]
END_HANDLE_COLLISION_P1

HANDLE_COLLISION_P2
    MOV R0, R12
    BL IS_VALID
    BEQ END_HANDLE_COLLISION_P2

    LDR R0, =P2_BULLET
    BL GET_POS

    MOV R5, R1
    MOV R6, R2

    MOV R0, R12
    BL GET_POS

    SUB R1, R1, R5
    ; GET ABSOLUTE (X_player - X_enemy)
    CMP R1, #0
    RSBLT R1, R1, #0

    SUB R2, R2, R6
    ; GET ABSOLUTE (Y_player - Y_enemy)
    CMP R2, #0
    RSBLT R2, R2, #0

    CMP R1, #ENEMEY_WIDTH / 2
    BGT END_HANDLE_COLLISION_P2

    CMP R2, #ENEMEY_HEIGHT / 2
    BGT END_HANDLE_COLLISION_P2

   ; Reset data information
    LDR R10, =ENEMIES_POS
    SUB R10, R12, R10
    MOV R0, #3
    UDIV R10, R10, R0

    LDR R0, =ENEMIES_DATA
    MOV R1, #0
    STRB R1, [R0, R10]

    LDR R0, =P2_BULLET
    BL GET_POS
    BL DESTROY_BULLET
    BL CLEAR_BULLET

    LDR R0, =P2_SCORE
    LDR R1, [R0]
    ADD R1, R1, #1
    STR R1, [R0]
END_HANDLE_COLLISION_P2

    POP {R0-R12, PC}

;#####################################################################################################################################################################	
; BULLET HANDLING
;#####################################################################################################################################################################	

SHOOT_BULLET
    PUSH {R0-R4,LR}

P1_SHOOT_BULLET
    TST R7, #P1_BULLET_STATE
    BEQ END_P1_SHOOT_BULLET

    ; Check if bullet is active
    LDR R0, =P1_BULLET
    BL IS_VALID
    BNE END_P1_SHOOT_BULLET
    
    ; Start X position
    MOV R1, #P1_X + SHIP_WIDTH / 2 + 5

    ; Y position similar to player 1
    LDR R0, =P1_POS_Y
    LDRH R2, [R0]

    LDR R0, =P1_BULLET
    BL SET_POS
END_P1_SHOOT_BULLET

P2_SHOOT_BULLET
    TST R7, #P2_BULLET_STATE
    BEQ END_P2_SHOOT_BULLET

    ; Check if bullet is active
    LDR R0, =P2_BULLET
    BL IS_VALID
    BNE END_P2_SHOOT_BULLET

    ; Start X position
    MOV R1, #P2_X - SHIP_WIDTH / 2 - 5

    ; Y position similar to player 2
    LDR R0, =P2_POS_Y
    LDRH R2, [R0]

    LDR R0, =P2_BULLET
    BL SET_POS
END_P2_SHOOT_BULLET

    POP {R0-R4, PC}


DESTROY_BULLET
    ; R0 has the bullet address
    PUSH {R0-R4,LR}

    MOV R1, #0xFFFF
    MOV R2, #0
    BL SET_POS

    POP {R0-R4, PC}

UPDATE_BULLET_POS
    PUSH {R0-R4,LR}

P1_BULLET_HANDLE 
   LDR R0, =P1_BULLET
   ; Check if bullet is active
   BL IS_VALID ; R1, R2 are set with X, Y
   BEQ END_P1_BULLET

   BL CLEAR_BULLET

   ADD R1, R1, #BULLET_SPEED

    ; Check bullet boundries
   CMP R1, #RIGHT_BOUNDRY
   LDRGE R0, =P1_BULLET
   BLGE DESTROY_BULLET
   BGE END_P1_BULLET

   ; UPDATE BULLET POSTION
   BL SET_POS
   BL DRAW_BULLET
END_P1_BULLET

P2_BULLET_HANDLE 
    LDR R0, =P2_BULLET
    ; Check if bullet is active
    BL IS_VALID ; R1, R2 are set with X, Y
    BEQ END_P2_BULLET

    BL CLEAR_BULLET

    SUB R1, R1, #BULLET_SPEED

    ; Check bullet boundries
    CMP R1, #LEFT_BOUNDRY
    LDRLT R0, =P2_BULLET
    BLLT DESTROY_BULLET
    BLT END_P2_BULLET

    ; Update bullet position
    BL SET_POS
    BL DRAW_BULLET
END_P2_BULLET
    POP{R0-R4,PC}




DRAW_BULLET
; TAKES R1 = X_Center, R2 = X_Center
    PUSH {R0-R4, LR} 

    
    MOV R3, #BULLET_WIDTH / 2
    MOV R4, #BULLET_WIDTH / 2
    MOV R5, #Red

    BL TFT_DrawCenterRect

    POP {R0-R4, PC}

CLEAR_BULLET
; TAKES R1 = X_Center, R2 = X_Center
    PUSH {R0-R4, LR} 

    MOV R3, #BULLET_WIDTH / 2
    MOV R4, #BULLET_WIDTH / 2
    MOV R5, #Black

    BL TFT_DrawCenterRect

    POP {R0-R4, PC}
    LTORG
;#####################################################################################################################################################################	
; PLAYER HANDLING
;#####################################################################################################################################################################	


UPDATE_PLAYERS_POS
    PUSH{R0-R4, LR}

; R7 contains the state

PLAYER_1_UPDATE
    LDR R0, =P1_POS_Y
    LDRH R1, [R0]

    TST R7, #P1_UP_STATE
    SUBNE R1, R1, #PLAYER_SPEED

    TST R7, #P1_DOWN_STATE
    ADDNE R1, R1, #PLAYER_SPEED

    ; Check player 1 boundries
    CMP R1, #(SHIP_HEIGHT / 2 + UPPER_PLAYER_BOUND)
    MOVLT R1, #(SHIP_HEIGHT / 2 + UPPER_PLAYER_BOUND)

    CMP R1, #(SCREEN_HEIGHT - SHIP_HEIGHT / 2)
    MOVGT R1, #(SCREEN_HEIGHT - SHIP_HEIGHT / 2)

    STRH R1, [R0]
END_PLAYER_1_UPDATE


PLAYER_2_UPDATE
    LDR R0, =P2_POS_Y
    LDRH R1, [R0]

    TST R7, #P2_UP_STATE
    SUBNE R1, R1, #PLAYER_SPEED

    TST R7, #P2_DOWN_STATE
    ADDNE R1, R1, #PLAYER_SPEED

    ; Check player 2 boundries
    CMP R1, #(SHIP_HEIGHT / 2 + UPPER_PLAYER_BOUND)
    MOVLT R1, #(SHIP_HEIGHT / 2 + UPPER_PLAYER_BOUND)

    CMP R1, #(SCREEN_HEIGHT - SHIP_HEIGHT / 2)
    MOVGT R1, #(SCREEN_HEIGHT - SHIP_HEIGHT / 2)

    STRH R1, [R0]
END_PLAYER_2_UPDATE

    POP{R0-R4, PC}

    LTORG

RENDER_PLAYERS
    PUSH {R0-R4, LR}
    
    ; Rendering Player 1
    MOV R1, #P1_X
    LDR R0, =P1_POS_Y
    LDRH R2, [R0]

    LDR R3, =P1_IDLE

    TST R7, #P1_UP_STATE
    LDRNE R3, =P1_UP

    TST R7, #P1_DOWN_STATE
    LDRNE R3, =P1_DOWN

    BL TFT_DrawImage_Center

    ; Rendering Player 2
    MOV R1, #P2_X
    LDR R0, =P2_POS_Y
    LDRH R2, [R0]

    LDR R3, =P2_IDLE

    TST R7, #P2_UP_STATE
    LDRNE R3, =P2_UP

    TST R7, #P2_DOWN_STATE
    LDRNE R3, =P2_DOWN

    BL TFT_DrawImage_Center

    POP {R0-R4, PC}

CLEAR_RENDER 
    PUSH {R0-R4, LR}
    
    ; Check if 0011 the last two bits are off (meaning the player 1 isn't moving)
    TST R7, #3
    BEQ SKIP_P1_CLEAR_RENDER

    MOV R1, #P1_X
    LDR R0, =P1_POS_Y
    LDRH R2, [R0]
    MOV R3, #SHIP_WIDTH / 2
    MOV R4, #SHIP_HEIGHT / 2
    MOV R5, #BACKGROUND
    BL TFT_DrawCenterRect

SKIP_P1_CLEAR_RENDER

    ; Check if 1100 the  are off (meaning the player 2 isn't moving)
    TST R7, #12
    BEQ SKIP_P2_CLEAR_RENDER

    MOV R1, #P2_X
    LDR R0, =P2_POS_Y
    LDRH R2, [R0]
    MOV R3, #SHIP_WIDTH / 2
    MOV R4, #SHIP_HEIGHT / 2
    MOV R5, #BACKGROUND
    BL TFT_DrawCenterRect

SKIP_P2_CLEAR_RENDER

    POP {R0-R4, PC}


MOD
    ; Computs R1 % R2
    ; Returns the output in R3

    PUSH {R0-R1, LR}

    UDIV R0, R1, R2 ; R0 = R1 / R2 

    MUL R2, R2, R0 ; R2 = R2 * (R1 / R2)

    SUB R1, R2 ; R1 = R1 - R2 * (R1 / R2)

    MOV R3, R1

    POP {R0-R1,PC}

RAND_RANGE
    PUSH {R0-R2, R5, LR}
    ;R1 = MIN_RANGE
    ;R2 = MAX_RANGE
    ;R3 = OUT

    ; MIN_RANGE + RAND % (MAX_RANGE - MIN_RANGE + 1)          
    MOV R5, R1

    SUB R2, R2, R5  
    ADD R2, R2, #1

    BL RAND

    ; RAND % (MAX_RANGE - MIN_RANGE + 1)
    MOV R1, R3
    BL MOD

    ADD R3, R3, R5

    POP {R0-R2,R5,PC}


RAND
    PUSH {R0-R2, LR}
     ; Load current seed value
    LDR     R0, =RAND_SEED         
    LDR     R1, [R0]         

    ; Computes SEED_new = (SEED_old * 1664525 + 1013904223) % 2^32 (will happen with overflow)
    LDR     R2, =1664525      
    MUL     R1, R2, R1 

    LDR     R2, =1013904223   
    ADD     R1, R2, R1        

    STR     R1, [R0] 

    ; Return value in R3
    MOV     R3, R1          
    POP {R0-R2, PC}



