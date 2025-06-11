    EXPORT Painter
	import selector
    import Colors

    import DRAW_RECT
    import PRINT_NUM
    import TFT_DrawImage
    import CUSTOM_DELAY
    import DELAY_1_SECOND
    import BACK_TO_MAIN
    AREA PainterDATA, DATA, READWRITE

GRID SPACE 2400     
;Colors
Red     EQU 0xF800
Green   EQU 0x0340
Blue    EQU 0x001F
Yellow  EQU 0xFFE0

Black   EQU 0x0000
Gray    EQU 0xe73d
Orange  EQU 0xfce1
Purple  EQU 0x5153
Dark_Blue EQU 0x1c74

Pink    EQU 0xf81f
White   EQU 0xFFFF



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


; Selector 
Selector_X_Start    EQU     280
Selector_Y_Start    EQU     7 
Selector_Y_Difference      EQU     26

Selector_Hight  EQU     16
Selector_Width  EQU     15




;Delays
DELAY_Button  EQU     0x0F604 
DELAY_INTERVAL  EQU     0x18604 
SOURCE_DELAY_INTERVAL EQU   0x386004   
FRAME_DELAY 	EQU 	0xA8604



    AREA PainterCode, CODE, READONLY
	
Painter FUNCTION
    ;initialization
   
    ;Game Logic
    BL PAINTER_SETUP
    BL DELAY_1_SECOND
	BL PainterGame_MAIN

    B .
    ENDFUNC

PAINTER_SETUP
	PUSH {R0-R1, R3, LR}
    
    MOV R3, #0
    LDR R0, =GRID

PAINTER_INITIAL

    MOV R1, #White
    STRH R1, [R0, R3]
    ADDS R3, R3, #2
    CMP R3, #2400	
    BLT PAINTER_INITIAL

    POP {R0-R1, R3, PC}


DRAW_COLOR_PALETTE
    PUSH{LR}
    ;Fill screen with color 
    MOV R1, #0
    MOV R2, #0
    MOV R3, #319
    MOV R4, #239
    MOV R5, #White
    BL DRAW_RECT

    ;Boarder
    MOV R1, #296
    MOV R2, #0
    MOV R3, #319
    MOV R4, #239
    MOV R5, #Black
    BL DRAW_RECT

    MOV R1, #297
    MOV R2, #2
    MOV R3, #317
    MOV R4, #237
    MOV R5, #White
    BL DRAW_RECT

    MOV R1, #297
    MOV R2, #0
    MOV R3, #317
    MOV R4, #4
    MOV R5, #Black
    BL DRAW_RECT

    MOV R1, #297
    MOV R2, #235
    MOV R3, #317
    MOV R4, #239
    MOV R5, #Black
    BL DRAW_RECT


    ;Draw Colors

    MOV R1, #299
    MOV R2, #6
    MOV R3, #315
    MOV R4, #24
    MOV R6, #9
    LDR R12, =Colors

Colors_Loop
    MOV R5, #0
    LDRH R5, [R12], #2

    MOV R0, #White
    CMP R5, R0
    MOVEQ R5, #Gray
    
    BL DRAW_RECT

    ADD R2, #26
    ADD R4, #26

    SUBS R6, R6, #1
    BNE Colors_Loop    


    ;Draw Separators
    MOV R1, #297
    MOV R2, #27
    MOV R3, #317
    MOV R4, #29
    MOV R5, #Black
    MOV R6, #8

Sepatator_Loop
    BL DRAW_RECT

    ADD R2, #26
    ADD R4, #26

    SUBS R6, R6, #1
    BNE Sepatator_Loop  

    POP{PC}

   LTORG

HANDLE_ERASER
    PUSH {R0-R6, LR}
    MOV R1, #280
    MOV R2, #0
    MOV R3, #295
    MOV R4, #240
    MOV R5, #White
    BL DRAW_RECT

    MOV R12, #5
    BL SET_COLOR
    POP{R0-R6,  PC}


SET_COLOR
    PUSH {R0-R6, LR}

    MOV R0, #DELAY_Button
    BL CUSTOM_DELAY

    ;getting the last time
    CMP R12, #0
    SUBNE R6, R12, #1

    ;The previous part

    MOV R1, #Selector_X_Start
    MOV R2, #Selector_Y_Start
    MOV R0, #Selector_Y_Difference
    MUL R0, R6, R0
    ADD R2, R0
    MOV R3, #Selector_X_Start
    ADD R3, R3, #Selector_Width
    ADD R4, R2, #Selector_Hight
    MOV R5, #White

    BL DRAW_RECT

    CMP R12, #9
    MOVEQ R12, #0

    LDR R0, =Colors
    LDRH R10, [R0, R12, LSL #1]
    MOV R1, #Selector_X_Start
    MOV R2, #Selector_Y_Start
    MOV R0, #Selector_Y_Difference
    MUL R0, R12, R0
    ADD R2, R0
    LDR R3, =selector
    BL TFT_DrawImage 
    

    POP {R0-R6, PC}

;####################################################*"Functions"*##############################################################################################
GET_COLOR
    PUSH{R0-R4,LR}

    LSR R1, R1, #3
    LSR R2, R2, #3

    MOV R0, #40
    MUL R3, R2, R0
    ADD R3, R1

    MOV R0, #2
    MUL R3, R3, R0

    LDR R0, =GRID
    LDRH R5, [R0, R3]


    POP{R0-R4, PC}

LTORG

STORE_COLOR
    PUSH{R1-R5, LR}

    LSR R1, R1, #3
    LSR R2, R2, #3

    MOV R0, #40
    MUL R3, R2, R0
    ADD R3, R1

    MOV R0, #2
    MUL R3, R3, R0

    LDR R0, =GRID
    STRH R6, [R0, R3]

    POP{R1-R5, PC}


PainterGame_MAIN
    PUSH {R0-R12, LR}
    
    MOV R1, #0
    MOV R2, #0
    MOV R3, #320
    MOV R4, #240
    MOV R5, #White
    BL DRAW_RECT

    BL DRAW_COLOR_PALETTE

    MOV R1, #0
    MOV R2, #0
    MOV R3, #7
    MOV R4, #7
    MOV R5, #Red
    BL DRAW_RECT  

    ; R1, R2, R3, R4 for pos
    ; R5, R6, R10 for colors
    ; R7, R8 State
    ; R12 counter

    MOV R12, #0

    BL SET_COLOR
PAINTER_GAME_LOOP

    BL BACK_TO_MAIN

    BL PAINTER_GET_STATE

    LDR R0, =GPIOB_BASE + GPIO_IDR

    LDR R9, [R0]
    TST R9, #BTN_BD

    MOVNE R8, #1
    MOVEQ R8, #0
 
    TST R9, #BTN_BU
    ADDNE R12, #1  
    BLNE SET_COLOR

    TST R9, #BTN_BR
    BLNE HANDLE_ERASER

    MOVEQ R5, R10
    MOVNE R5, #White
	
	MOV R6, R10
	
    BL REDRAW_CURSOR

    B PAINTER_GAME_LOOP

	POP {R0-R12,PC}

SETUP
    PUSH {R0-R12,LR}

    POP{R0-R12,PC}
    LTORG

;#####################################################################################################################################################################	

; *************************************************************
; GET STATE  (0->Nochange,1->Up 2->Down 3->Left 4->right) In R7
; *************************************************************
PAINTER_GET_STATE
	PUSH {R0-R2,LR}
	LDR R0, =GPIOB_BASE + GPIO_IDR
    LDR R1, [R0]

    MOV R7, #0

    TST R1, #BTN_AU
    MOVNE R7, #1

    TST R1, #BTN_AD
    MOVNE R7, #2

    TST R1, #BTN_AL
    MOVNE R7, #3

    TST R1, #BTN_AR
    MOVNE R7, #4

   
	POP {R0-R2,PC}

    LTORG
; *************************************************************
; ReDraw Square Centered at (x=R5, y=R6 ,ColorBackground=R1, ColorSquare=R2,Direction=R7 (0->Nochange,1->Up 2->Down 3->Left 4->right))
; *************************************************************
REDRAW_CURSOR
	PUSH{R0, R12, LR}
	

    CMP R7, #1
    BEQ PAINTER_UP
     
    CMP R7, #2
    BEQ PAINTER_DOWN

    CMP R7, #3
    BEQ PAINTER_LEFT

    CMP R7, #4
    BEQ PAINTER_RIGHT

    B NO_CHANGE

PAINTER_DOWN
    CMP R8, #0
    BLEQ GET_COLOR
    BLNE STORE_COLOR
    BL DRAW_RECT

    CMP R4, #239
    ADDNE R2, R2, #8
    ADDNE R4, R4, #8
	
	CMP R8, #0
    BLNE STORE_COLOR

    BL DRAW_CURSOR

    LDR R0, =FRAME_DELAY
    BL CUSTOM_DELAY
    B MOVE_END

PAINTER_UP
    CMP R8, #0
    BLEQ GET_COLOR
    BLNE STORE_COLOR
    BL DRAW_RECT

    CMP R2, #0 
    SUBNE R2, R2, #8
    SUBNE R4, R4, #8
	
	CMP R8, #0
    BLNE STORE_COLOR

    BL DRAW_CURSOR


    LDR R0,=FRAME_DELAY
    BL CUSTOM_DELAY

    B MOVE_END
PAINTER_RIGHT
    CMP R8, #0
    BLEQ GET_COLOR
    BLNE STORE_COLOR
    BL DRAW_RECT

    MOV R12, #279
    CMP R3, R12
    ADDNE R1, R1, #8
    ADDNE R3, R3, #8
		
	CMP R8, #0
    BLNE STORE_COLOR

    BL DRAW_CURSOR

    LDR R0,=FRAME_DELAY
    BL CUSTOM_DELAY

    B MOVE_END

PAINTER_LEFT
    CMP R8, #0
    BLEQ GET_COLOR
    BLNE STORE_COLOR
    BL DRAW_RECT

    CMP R1, #0
    SUBNE R1, R1, #8
    SUBNE R3, R3, #8
	
	CMP R8, #0
    BLNE STORE_COLOR

    BL DRAW_CURSOR

    LDR R0,=FRAME_DELAY
    BL CUSTOM_DELAY
    B MOVE_END

NO_CHANGE
    CMP R8, #1
    BLEQ STORE_COLOR

    BL DRAW_CURSOR

    LDR R0,=FRAME_DELAY
    BL CUSTOM_DELAY
MOVE_END
	pop{R0, R12, PC}

DRAW_CURSOR
    PUSH {R1-R4, LR}

    MOV R5, #Black
    BL DRAW_RECT

    ADDS R1, R1, #1
    ADDS R2, R2, #1
    SUBS R3, R3, #1
    SUBS R4, R4, #1
    
    MOV R5, R6
    BL DRAW_RECT

    POP{R1-R4, PC}


    END