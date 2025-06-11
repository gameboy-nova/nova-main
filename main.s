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

    EXPORT __main
    EXPORT PRINT_NUM
    IMPORT TwoP_Snake_Icon
    IMPORT Fruit_Basket_Icon
    IMPORT Painter_Logo
    IMPORT Ping_Icon
    IMPORT Shooter_Icon
    IMPORT Snake_Icon
    IMPORT LOGO
    IMPORT MAIN_CHOOSE_GAME_MSG
	IMPORT P
    IMPORT I
    IMPORT N
    IMPORT G
    IMPORT CR
    IMPORT digitArr
    IMPORT CHARS
	IMPORT DIGITS
    IMPORT MSG
	IMPORT MSG2
    IMPORT SNAKE_GAME
    IMPORT PongMain
    IMPORT Painter
    IMPORT STAR_BLAST_MAIN
    IMPORT SNAKE_GAMEP2
    IMPORT Fruit
    EXPORT CUSTOM_DELAY
    EXPORT DRAW_RECT
    EXPORT TFT_DrawCenterRect
    EXPORT DRAW_TITLE
    EXPORT DRAW_DIGIT
    EXPORT PRINT
	EXPORT GAME_MAIN
    EXPORT DRAW_DIGITAL
    EXPORT TFT_DrawImage
    EXPORT TFT_DrawImage_Center
    EXPORT TFT_FillScreen 
    EXPORT DELAY_1_SECOND   
    EXPORT DELAY_HALF_SECOND
    EXPORT DELAY_100_MILLISECOND
    EXPORT DELAY_10_MILLISECOND
    EXPORT DELAY_1_MILLISECOND
    EXPORT GAME_BACK_HANDLE
	EXPORT BACK_TO_MAIN
    AREA MYDATA, DATA, READWRITE

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
DarkGreen EQU 0x142A

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

BTN_OK          EQU     (1 << 7)
BTN_BCK 		EQU 	(1 << 2)
; Selector 
GameIcon_Width      EQU 60
GameIcon_Height     EQU 60
Selector_Padding    EQU 2 ; How much bigger the selector is than the icon on each side
Selector_Width      EQU GameIcon_Width + (Selector_Padding * 2)  
Selector_Height     EQU GameIcon_Height + (Selector_Padding * 2)
Selector_Color      EQU White

CHAR_SIZE       EQU     20
CHAR_MEM_SIZE   EQU     520
TITLE_X         EQU     120
TITLE_Y         EQU     5

; Print contants
; Print contants
ASCII_CHAR_OFFSET EQU 'A'
ASCII_NUM_OFFSET EQU '0'
CHAR_WIDTH EQU 16
	
DELAY_INTERVAL  EQU     0x18604 
SOURCE_DELAY_INTERVAL EQU   0x386004   
FRAME_DELAY 	EQU 	0xA8604

NumberOfGames       EQU 6 ; Total number of game slots
IconsPerRow         EQU 3 ; Number of icons per row for up/down navigation

IconCoordinates_Buffer      SPACE (NumberOfGames * 8)  ; 5 pairs of X,Y coordinates (DCD, DCD = 8 bytes per pair)
IconDataPointers_Buffer     SPACE (NumberOfGames * 4)  ; 5 data pointers (DCD = 4 bytes per pointer)
CurrentSelection_Buffer     SPACE 4        ; For a single DCD
PrevSelection_Buffer     SPACE 4        ; For a single DCD

    AREA MAIN, CODE, READONLY

__main FUNCTION
    BL SETUP
    BL INIT_MENU_DATA       ; Initialize our menu data tables in RAM
    
    LDR R5, =Black
    BL TFT_FillScreen


    MOV R1, #160
    MOV R2, #120
    LDR R3, =LOGO
    BL TFT_DrawImage_Center

    BL Play_Sweep_Sound
    BL DELAY_1_SECOND

	
    BL GAME_MAIN

    B .
    ENDFUNC

;####################################################*"Functions"*##############################################################################################
BACK_TO_MAIN
	PUSH{R0,R1,LR}
	LDR R0, =GPIOB_BASE + GPIO_IDR
	LDR R1, [R0]
	TST R1, #BTN_BCK
	BNE RETURN_TO_MAIN

	POP{R0,R1,PC}
RETURN_TO_MAIN
	POP{R0,R1,R2}
	B GAME_MAIN

GAME_BACK_HANDLE

	BL DELAY_HALF_SECOND
    ; R1 contains game main 

    LDR R0, =GPIOB_BASE + GPIO_IDR
GAME_END_HANDLE_LOOP
	LDR R2, [R0]

	MOV R3, #0x3FA
	TST R2, R3
	BXNE R1

	TST R2, #BTN_BCK
	BNE GAME_MAIN

	B GAME_END_HANDLE_LOOP



GAME_MAIN    
    LDR R5, =Black          
    BL TFT_FillScreen
   
    MOV R1, #0              ; X_start
    MOV R2, #0              ; Y_start
    MOV R3, #319            ; X_end (screen_width - 1)
    MOV R4, #29             ; Y_end (banner_height - 1)
    LDR R5, =Black          ; Color
    BL DRAW_RECT

    MOV R1, #56             ; X position for image
    MOV R2, #4              ; Y position for image
    LDR R3, =MAIN_CHOOSE_GAME_MSG  ; Pointer to image data
    MOV R4, #White
    MOV R5, #Black
    BL PRINT


    BL Render
MenuInputLoop
    LDR R0, =GPIOB_BASE + GPIO_IDR
    LDRH R1, [R0]
    
    ; --- Process Right Button (BTN_AR) ---
    TST R1, #BTN_AR
    BNE HandleBtnAR         
    
    ; Check BTN_AL (Left)
    TST R1, #BTN_AL
    BNE HandleBtnAL

    TST R1, #BTN_AU
    BNE HandleBtnAU

    TST R1, #BTN_AD
    BNE HandleBtnAD

    TST R1, #BTN_OK
    BNE HandleBtnOK

NoButtonHandledThisPass
    B MenuInputLoop         ; Loop back to read inputs again

HandleBtnAR
    BL ProcessBtnRight
    BL Render
    LDR R0, =FRAME_DELAY
    BL CUSTOM_DELAY
    B MenuInputLoop         ; Loop back

HandleBtnAL
    BL ProcessBtnLeft
    BL Render
    LDR R0, =FRAME_DELAY
    BL CUSTOM_DELAY
    B MenuInputLoop

HandleBtnAU
    BL ProcessBtnUp
    BL Render
    LDR R0, =FRAME_DELAY
    BL CUSTOM_DELAY
    B MenuInputLoop

HandleBtnAD
    BL ProcessBtnDown
    BL Render
    LDR R0, =FRAME_DELAY
    BL CUSTOM_DELAY
    B MenuInputLoop

HandleBtnOK
    BL ProcessBtnSelect
    BL Render
    LDR R0, =FRAME_DELAY
    BL CUSTOM_DELAY
    B MenuInputLoop

StoreNewSelectionAndRender
    STR R1, [R0]                ; Store updated selection (R0=addr, R1=new value)
    POP {R0-R4, PC}             ; Restore and return from button processing routine

    LTORG
ProcessBtnRight
    PUSH {R0-R4, LR}            ; Save R0-R4, LR
    LDR R0, =CurrentSelection_Buffer
    LDR R1, [R0]                ; R1 = current selection value
    LDR R3, =PrevSelection_Buffer
    STR R1, [R3]
    ADD R1, R1, #1              ; Increment selection
    LDR R2, =NumberOfGames
    CMP R1, R2                  ; Compare with NumberOfGames
    BGE ResetSelectionToZeroR   ; If selection >= NumberOfGames, wrap to 0
    B StoreNewSelectionAndRender; Otherwise, store and render

    LTORG
ResetSelectionToZeroR
    MOV R1, #0
    B StoreNewSelectionAndRender

ProcessBtnLeft
    PUSH {R0-R4, LR}
    LDR R0, =CurrentSelection_Buffer
    LDR R1, [R0]                ; R1 = current selection
    LDR R3, =PrevSelection_Buffer
    STR R1, [R3]
    SUBS R1, R1, #1             ; Decrement selection
    BGE StoreNewSelectionAndRender ; If result is >= 0, store and render
    LDR R1, =NumberOfGames      ; Else, wrap to NumberOfGames - 1
    SUBS R1, R1, #1
    B StoreNewSelectionAndRender

ProcessBtnUp
    PUSH {R0-R4, LR}            ; Save R0-R4, LR
    LDR R0, =CurrentSelection_Buffer ; R0 for StoreNewSelectionAndRender
    LDR R1, [R0]                ; R1 = CurrentSelection
    LDR R3, =PrevSelection_Buffer
    STR R1, [R3]    
    LDR R2, =IconsPerRow
    SUB R3, R1, R2              ; R3 = PotentialNewSelection = CurrentSelection - IconsPerRow
    
    CMP R3, #0
    BLT WrapAroundU       ; If PotentialNewSelection < 0, clamp by returning
    
    MOV R1, R3                  ; Valid move: NewSelection = PotentialNewSelection
    B StoreNewSelectionAndRender; Store, Render, and POP R0-R4, PC

WrapAroundU
    ADD R3, R3, R2
    ADD R3, R3, R2
    LDR R4, =NumberOfGames
    CMP R3, R4
    BLT  movbeforestore
    SUBS R3, R3, #1
    B movbeforestore

movbeforestore
    MOV R1, R3
    B StoreNewSelectionAndRender


    LTORG
ProcessBtnDown
    PUSH {R0-R4, LR}            ; Save R0-R4, LR
    LDR R0, =CurrentSelection_Buffer ; R0 for StoreNewSelectionAndRender
    LDR R1, [R0]                ; R1 = CurrentSelection
    LDR R3, =PrevSelection_Buffer
    STR R1, [R3]
    LDR R2, =IconsPerRow
    LDR R3, =NumberOfGames
    ADD R4, R1, R2              ; R4 = PotentialNewSelection = CurrentSelection + IconsPerRow
    
    CMP R4, R3                  ; Is PotentialNewSelection >= NumberOfGames?
    BGE WrapAroundD      ; If yes, clamp by returning
    
    MOV R1, R4                  ; Valid move: NewSelection = PotentialNewSelection
    B StoreNewSelectionAndRender; Store, Render, and POP R0-R4, PC

WrapAroundD
    SUBS R4, R4, R2
    SUBS R4, R4, R2
    CMP R4, #0
    BLT StoreNewSelectionAndRender
    MOV R1, R4
    B StoreNewSelectionAndRender

    LTORG
ProcessBtnSelect
    PUSH {R0-R7, LR}        ; Save registers
    LDR R0, =CurrentSelection_Buffer
    LDR R0, [R0]            ; R0 = CurrentSelection index
    
    CMP R0, #0 ; For Painter (if Painter_Game function exists)
    BEQ LaunchPainterGame

    CMP R0, #1
    BEQ LaunchSnakeGame

    CMP R0, #2
    BEQ LaunchPongGame

    CMP R0, #3
    BEQ LaunchStarBlastGame

    CMP R0, #4
    BEQ LaunchDoubleSnakeGame

    CMP R0, #5
    BEQ LaunchFruitCatchGame

    B EndProcessBtnSelect   ; If not Snake or other handled game, just return to menu loop

LaunchSnakeGame
    LDR R5, =White          ; Clear screen to White before starting game
    BL TFT_FillScreen
    BL SNAKE_GAME           ; Call the Snake game function
    LDR R5, =White          ; Menu background color
    BL TFT_FillScreen
    BL Render               ; Re-render the menu
    ; Fall through to EndProcessBtnSelect or directly branch to MenuInputLoop


LaunchStarBlastGame
    LDR R5, =Black          ; Clear screen to White before starting game
    BL TFT_FillScreen
    BL STAR_BLAST_MAIN           ; Call the Snake game function
    LDR R5, =White          ; Menu background color
    BL TFT_FillScreen
    BL Render               ; Re-render the menu

LaunchDoubleSnakeGame
    LDR R5, =Black          ; Clear screen to White before starting game
    BL TFT_FillScreen
    BL SNAKE_GAMEP2           ; Call the Snake game function
    LDR R5, =White          ; Menu background color
    BL TFT_FillScreen
    BL Render               ; Re-render the menu


LaunchPongGame
    LDR R5, =Black          ; Clear screen to Black before starting game
    BL TFT_FillScreen
    BL PongMain        ; Call the Pong game function
    LDR R5, =White          ; Menu background color
    BL TFT_FillScreen
    BL Render               ; Re-render the menu

LaunchPainterGame
    LDR R5, =White          ; Clear screen to White before starting game
    BL TFT_FillScreen
    BL Painter           ; Call the Painter game function
    LDR R5, =White          ; Menu background color
    BL TFT_FillScreen
    BL Render               ; Re-render the menu

LaunchFruitCatchGame
    LDR R5, =Black          ; Clear screen to Black before starting game
    BL TFT_FillScreen
    BL Fruit           ; Call the Fruit game function
    LDR R5, =White          ; Menu background color
    BL TFT_FillScreen
    BL Render               ; Re-render the menu

EndProcessBtnSelect
    POP {R0-R7, PC}         ; Restore registers and return to MenuInputLoop

;;;;;;;;;;
Render
    PUSH {R1-R12, LR}
 
    MOV R6, #0                  ; R6 = Loop counter / current icon index
    LDR R7, =IconCoordinates_Buffer    ; R7 = Base address of IconCoordinates table
    LDR R8, =IconDataPointers_Buffer   ; R8 = Base address of IconDataPointers table
    LDR R9, =NumberOfGames      ; R9 = Total number of game slots
    
    BL Draw_selector            ; Draw the selector around the chosen icon

DrawIconsLoop
    CMP R6, R9                  ; Compare current icon index (R6) with NumberOfGames (R9)
    BGE EndDrawIconsLoop        ; If R6 >= R9, all icons drawn, branch to end

    MOV R10, R6, LSL #2         
    ADD R10, R8, R10            ; R10 = IconDataPointers_Buffer + (R6 * 4) -> Address of current icon's data pointer
    LDR R3, [R10]               ; R0 = Pointer to actual icon pixel data

    MOV R10, R6, LSL #3         
    ADD R10, R7, R10            ; R10 = IconCoordinates_Buffer + (R6 * 8) -> Address of current icon's X coord
    LDR R1, [R10], #4           ; R1 = X-coordinate, R10 post-increments to Y-coordinate
    LDR R2, [R10]               ; R2 = Y-coordinate

    BL TFT_DrawImage            ; Draw the icon (R0=data, R1=X, R2=Y)

    ADD R6, R6, #1              ; Increment icon index
    B DrawIconsLoop             ; Loop back to draw next icon

EndDrawIconsLoop                ; Label for after the loop finishes
    POP {R1-R12, PC}

Draw_selector
    PUSH {R0-R12, LR}

    LDR R6, =PrevSelection_Buffer
    LDR R6, [R6]                
    MOV R10, R6, LSL #3         
    LDR R7, =IconCoordinates_Buffer    
    ADD R10, R7, R10            
    LDR R0, [R10], #4           
    LDR R1, [R10]               

    LDR R4, =Selector_Padding   
    SUB R10, R0, R4             
    SUB R11, R1, R4             
    MOV R1, R10                 
    MOV R2, R11                 

    LDR R0, =Selector_Width     
    ADD R3, R1, R0              ; R3 = X1_sel + Selector_Width
    SUB R3, R3, #1              ; R3 for DRAW_RECT (X2_sel) = X1_sel + Selector_Width - 1

    LDR R0, =Selector_Height    
    ADD R4, R2, R0              ; R4 = Y1_sel + Selector_Height
    SUB R4, R4, #1              
    
    LDR R5, =Black     
    BL DRAW_RECT
 

    LDR R6, =CurrentSelection_Buffer   ; R6 = Address of CurrentSelection variable
    LDR R6, [R6]                ; R6 = Value of CurrentSelection (index of selected icon)
    MOV R10, R6, LSL #3         ; R10 = CurrentSelection_index * 8 (offset in IconCoordinates)
    LDR R7, =IconCoordinates_Buffer    ; R7 (reused) = Base address of IconCoordinates table
    ADD R10, R7, R10            ; R10 = Address of selected icon's X coord
    LDR R0, [R10], #4           ; R0 = SelectedIconX, R10 now points to SelectedIconY memory location
    LDR R1, [R10]               ; R1 = SelectedIconY

    LDR R4, =Selector_Padding   ; R4 = Selector_Padding value
    SUB R10, R0, R4             ; R10 (X1_sel) = SelectedIconX - Selector_Padding
    SUB R11, R1, R4             ; R11 (Y1_sel) = SelectedIconY - Selector_Padding
    MOV R1, R10                 ; R1 for DRAW_RECT = X1_sel
    MOV R2, R11                 ; R2 for DRAW_RECT = Y1_sel

    LDR R0, =Selector_Width     ; R0 = Selector_Width value
    ADD R3, R1, R0              ; R3 = X1_sel + Selector_Width
    SUB R3, R3, #1              ; R3 for DRAW_RECT (X2_sel) = X1_sel + Selector_Width - 1

    LDR R0, =Selector_Height    ; R0 = Selector_Height value
    ADD R4, R2, R0              ; R4 = Y1_sel + Selector_Height
    SUB R4, R4, #1              ; R4 for DRAW_RECT (Y2_sel) = Y1_sel + Selector_Height - 1
    
    LDR R5, =Selector_Color     ; R5 for DRAW_RECT = Color for the selector
    BL DRAW_RECT

    POP {R0-R12, PC}            ; Restore registers and return

SETUP
    PUSH {R0-R12,LR}

    BL GPIO_INIT
    BL LCD_INIT

    POP{R0-R12,PC}
	LTORG
INIT_MENU_DATA
    PUSH {R0-R12, LR} ; Save registers

    LDR R0, =IconCoordinates_Buffer ; R0 = base address of the coordinate buffer
    LDR R1, =35
    STR R1, [R0], #4
    LDR R1, =60
    STR R1, [R0], #4

    LDR R1, =130
    STR R1, [R0], #4
    LDR R1, =60
    STR R1, [R0], #4

    LDR R1, =225
    STR R1, [R0], #4
    LDR R1, =60
    STR R1, [R0], #4

    LDR R1, =35
    STR R1, [R0], #4
    LDR R1, =160
    STR R1, [R0], #4
    
    LDR R1, =130
    STR R1, [R0], #4
    LDR R1, =160
    STR R1, [R0], #4

    LDR R1, =225
    STR R1, [R0], #4
    LDR R1, =160
    STR R1, [R0], #4

    LDR R0, =IconDataPointers_Buffer ; R0 = base address of the data pointers buffer
    LDR R1, =Painter_Logo
    STR R1, [R0], #4
    
    LDR R1, =Snake_Icon
    STR R1, [R0], #4
   
    LDR R1, =Ping_Icon
    STR R1, [R0], #4
   
    LDR R1, =Shooter_Icon
    STR R1, [R0], #4
   
    LDR R1, =TwoP_Snake_Icon
    STR R1, [R0], #4

    LDR R1, =Fruit_Basket_Icon
    STR R1, [R0], #4

    LDR R0, =CurrentSelection_Buffer
    MOV R1, #0
    STR R1, [R0]

    LDR R0, =PrevSelection_Buffer
    MOV R1, #0
    STR R1, [R0]

    POP {R0-R12, PC} ; Restore registers and return




Play_Sweep_Sound
    PUSH {R0-R7, LR}

    LDR R0, =0x40000420      ; TIM3_CCER
    LDR R1, [R0]
    ORR R1, R1, #(1 << 8)    ; CC3E = 1
    STR R1, [R0]

    MOV R4, #1000          ; Start at ARR = 1000 (~1kHz)
    MOV R5, #2000          ; End at ARR = 2000 (~500Hz)

Sound_Loop
    CMP R4, R5
    BGT End_Sound

    ; Set ARR (Auto-reload register)
    LDR R6, =0x4000042C    ; TIM3_ARR
    STR R4, [R6]

    ; Set CCR3 (50% duty)
    LSR R7, R4, #1         ; CCR3 = ARR / 2
    LDR R6, =0x4000043C    ; TIM3_CCR3
    STR R7, [R6]

    ; Small delay (~100ms software loop)
    LDR R6, =800000
Delay_Loop3
    SUBS R6, R6, #1
    BNE Delay_Loop3

    ; Increment ARR by 100
    ADD R4, R4, #100
    B Sound_Loop

End_Sound
    ; Turn off sound (CCR3 = 0)
    LDR R6, =0x4000043C
    MOV R7, #0
    STR R7, [R6]

    POP {R0-R7, pc}


;#####################################################################################################################################################################	

; Initializes the I/O pins
GPIO_INIT
	PUSH {R0-R12,LR}
    ; Enable clocks for GPIOA,B,C
    LDR R0, =RCC_BASE + RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, #0x1F
    STR R1, [R0]

    ; Configure A, B to be output and C, D to be an input
    LDR R0, =GPIOA_BASE + GPIO_MODER
    LDR R1, =0x55555555  
    STR R1, [R0]
	
	
    ; Configure speed for GPIOA,B,C (Medium Speed)
    LDR R0, =GPIOA_BASE + GPIO_OSPEEDR
    LDR R1, =0x55555555
    STR R1, [R0]
	
        ; Configure A, B to be output and C, D to be an input
    LDR R0, =GPIOB_BASE + GPIO_MODER
    LDR R1, =0x00000000  
    STR R1, [R0]
	
	
    ; Configure speed for GPIOA,B,C (Medium Speed)
    LDR R0, =GPIOB_BASE + GPIO_OSPEEDR
    LDR R1, =0xFFFFFFFF
    STR R1, [R0]

    ; Configure speed for GPIOA,B,C (Medium Speed)
    LDR R0, =GPIOB_BASE + GPIO_PUPDR
    LDR R1, =0x00000000
    STR R1, [R0]

    ; Enable GPIOB + TIM3 clocks
    LDR R0, =0x40023830      ; RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 1)     ; GPIOBEN
    STR R1, [R0]

    LDR R0, =0x40023840      ; RCC_APB1ENR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 1)     ; TIM3EN
    STR R1, [R0]

    ; Set PB0 to AF mode (MODER0 = 10)
    LDR R0, =0x40020400      ; GPIOB_MODER
    LDR R1, [R0]
    BIC R1, R1, #0x3
    ORR R1, R1, #0x2
    STR R1, [R0]

    ; Set AF2 for PB0 (TIM3_CH3)
    LDR R0, =0x40020420      ; GPIOB_AFRL
    LDR R1, [R0]
    BIC R1, R1, #(0xF << (4 * 0))
    ORR R1, R1, #(0x2 << (4 * 0))
    STR R1, [R0]

    ; TIM3 disable
    LDR R0, =0x40000400      ; TIM3_CR1
    MOV R1, #0
    STR R1, [R0]

    ; PWM mode 1 on CH3
    LDR R0, =0x4000041C      ; TIM3_CCMR2
    MOV R1, #(6 << 4)        ; OC3M = 110
    ORR R1, R1, #(1 << 3)    ; OC3PE = 1
    STR R1, [R0]

    ; Prescaler = 15 → 16 MHz / (15 + 1) = 1 MHz timer tick
    LDR R0, =0x40000428      ; TIM3_PSC
    MOV R1, #15
    STR R1, [R0]

    ; Auto-reload = 999 → PWM frequency = 1 MHz / 1000 = 1 kHz
    LDR R0, =0x4000042C
    MOV R1, #999
    STR R1, [R0]

    ; CCR3 = 500 → 50% duty cycle
    LDR R0, =0x4000043C
    MOV R1, #500
    STR R1, [R0]

    ; Generate update event
    LDR R0, =0x40000444
    MOV R1, #1
    STR R1, [R0]

    ; Enable timer
    LDR R0, =0x40000400
    MOV R1, #1
    STR R1, [R0]
 
	POP {R0-R12,PC}

;#####################################################################################################################################################################	
;Initializes the LCD pins
LCD_INIT
    PUSH {R0-R2, LR}

    LDR R1, =GPIOA_BASE + GPIO_ODR
    LDR R2, [R1]
    
; ======= HARDWARE RESET ======= ;

    ; Reset low
    BIC R2, R2, #TFT_RST
    STR R2, [R1]
    BL DELAY
    
    ; Reset high
    ORR R2, R2, #TFT_RST
    STR R2, [R1]
    BL DELAY
   
; ======= COLMOD ======= ;

    MOV R0, #0x3A
    BL LCD_COMMAND_WRITE
    MOV R0, #0x55
    BL LCD_DATA_WRITE

; ======= MEMORY ACCESS CONTROL (MADCTL) ======= ;

	MOV R0, #0x36       
	BL LCD_COMMAND_WRITE
	MOV R0, #0x28       
	BL LCD_DATA_WRITE
    
	
; ======= SLEEP OUT ======= ; (Turns off sleep mode)

    MOV R0, #0x11
    BL LCD_COMMAND_WRITE
    BL DELAY
	

; ======= DISPLAY ON ======= ; (Turns off sleep mode)

    ; Display ON
    MOV R0, #0x29
    BL LCD_COMMAND_WRITE

    POP {R0-R2, PC}

;#####################################################################################################################################################################	
LCD_COMMAND_WRITE
    PUSH {R1-R2, LR}

    ; Set CS low
    LDR R1, =GPIOA_BASE + GPIO_ODR
    LDR R2, [R1]
    BIC R2, R2, #TFT_CS
    STR R2, [R1]

    ; Set DC (RS) low for command
    BIC R2, R2, #TFT_DC
    STR R2, [R1]

    ; Set RD high (not used in write operation)
    ORR R2, R2, #TFT_RD
    STR R2, [R1]

    ; Send command (R0 contains command)
    BIC R2, R2, #0xFF   ; Clear data bits PA0-PA7
    AND R0, R0, #0xFF   ; Ensure only 8 bits
    ORR R2, R2, R0      ; Combine with control bits
    STR R2, [R1]

    ; Generate WR pulse (low > high)
    BIC R2, R2, #TFT_WR
    STR R2, [R1]
    ORR R2, R2, #TFT_WR
    STR R2, [R1]

    ; Set CS high
    ORR R2, R2, #TFT_CS
    STR R2, [R1]

    POP {R1-R2, PC}

;#####################################################################################################################################################################	
LCD_DATA_WRITE
    PUSH {R1-R2, LR}

    ; Set CS low
    LDR R1, =GPIOA_BASE + GPIO_ODR
    LDR R2, [R1]
    BIC R2, R2, #TFT_CS
    STR R2, [R1]

    ; Set DC (RS) high for data
    ORR R2, R2, #TFT_DC
    STR R2, [R1]

    ; Set RD high (not used in write operation)
    ORR R2, R2, #TFT_RD
    STR R2, [R1]

    ; Send data (R0 contains data)
    BIC R2, R2, #0xFF   ; Clear data bits PA0-PA7
    AND R0, R0, #0xFF   ; Ensure only 8 bits
    ORR R2, R2, R0      ; Combine with control bits
    STR R2, [R1]

    ; Generate WR pulse
    BIC R2, R2, #TFT_WR
    STR R2, [R1]
    ORR R2, R2, #TFT_WR
    STR R2, [R1]

    ; Set CS high
    ORR R2, R2, #TFT_CS
    STR R2, [R1]

    POP {R1-R2, PC}

;#####################################################################################################################################################################	
TFT_FillScreen  
    PUSH {R1-R5, LR}

    ; Set Column Address (0-319)
    MOV R0, #0x2A
    BL LCD_COMMAND_WRITE
    MOV R0, #0x00
    BL LCD_DATA_WRITE
    MOV R0, #0x00
    BL LCD_DATA_WRITE
    MOV R0, #0x01      ; High byte of 0x013F (319)
    BL LCD_DATA_WRITE
    MOV R0, #0x3F      ; Low byte of 0x013F (319)
    BL LCD_DATA_WRITE

    ; Set Page Address (0-239)
    MOV R0, #0x2B
    BL LCD_COMMAND_WRITE
    MOV R0, #0x00
    BL LCD_DATA_WRITE
    MOV R0, #0x00
    BL LCD_DATA_WRITE
    MOV R0, #0x00
    BL LCD_DATA_WRITE
    MOV R0, #0xEF      ; 239
    BL LCD_DATA_WRITE

    ; Memory Write
    MOV R0, #0x2C
    BL LCD_COMMAND_WRITE

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte

    ; Fill screen with color (320x240 = 76800 pixels)
    LDR R3, =76800
FillLoop
    ; Write high byte
    MOV R0, R1
    BL LCD_DATA_WRITE
    
    ; Write low byte
    MOV R0, R2
    BL LCD_DATA_WRITE
    
    SUBS R3, R3, #1
    BNE FillLoop

    POP {R1-R5, LR}
    BX LR

;R1: X
;R2: Y
;R3: ADRESS
TFT_DrawImage
    PUSH {R0-R12, LR}

    ; Load image width and height
    LDR R4, [R3], #4  ; Load width  (R3 = Width)
    LDR R5, [R3], #4  ; Load height (R4 = Height)

    ; =====================
    ; Set Column Address (X Start, X End)
    ; =====================
    MOV R0, #0x2A
    BL LCD_COMMAND_WRITE

    MOV R0, R1, LSR #8
    BL LCD_DATA_WRITE

    MOV R0, R1  ; X Start
    BL LCD_DATA_WRITE

    ADD R0, R1, R4
    SUB R0, R0, #1  ; X End = X + Width - 1
    MOV R9, R0

    MOV R0, R9, LSR #8
    BL LCD_DATA_WRITE
    MOV R0, R9
    BL LCD_DATA_WRITE

    ; =====================
    ; Set Page Address (Y Start, Y End)
    ; =====================
    MOV R0, #0x2B
    BL LCD_COMMAND_WRITE
    MOV R0, R2, LSR #8
    BL LCD_DATA_WRITE
    MOV R0, R2  ; Y Start
    BL LCD_DATA_WRITE

    ADD R0, R2, R5
    SUB R0, R0, #1  ; Y End = Y + Height - 1
    MOV R9, R0

    MOV R0, R9, LSR #8
    BL LCD_DATA_WRITE
    MOV R0, R9
    BL LCD_DATA_WRITE

    ; =====================
    ; Start Writing Pixels
    ; =====================
    MOV R0, #0x2C
    BL LCD_COMMAND_WRITE

    ; =====================
    ; Send Pixel Data (BGR565)
    ; =====================
    MUL R6, R4, R5  ; Total pixels = Width × Height
TFT_ImageLoop
    LDRH R0, [R3], #2  ; Load one pixel (16-bit BGR565)
    MOV R1, R0, LSR #8 ; Extract high byte
    AND R2, R0, #0xFF  ; Extract low byte


    MOV R0, R1         ; Send High Byte first
    BL LCD_DATA_WRITE
    MOV R0, R2         ; Send Low Byte second
    BL LCD_DATA_WRITE

    SUBS R6, R6, #1
    BNE TFT_ImageLoop

    POP {R0-R12, LR}
    BX LR
    ;;;;;;;;;;;;;;;;;;;
    LTORG
TFT_DrawImage_Center
    PUSH {R0-R7,R11-R12, LR}
    
    ;store the image address
    MOV R12, R3

    ; Load image width and height
    LDR R6, [R12], #4  ; Load width  (R3 = Width)
    LDR R7, [R12], #4  ; Load height (R4 = Height)

    ;calculate the loop size
    MUL R11, R6, R7

    ;calculate the half width and hight
    MOV R6, R6, LSR #1
    MOV R7, R7, LSR #1

    ;calculate the END x and y && start x and y
    ADD R3, R1, R6
    SUB R3, #1
    ADD R4, R2, R7
    SUB R4, #1
    
    SUB R1, R1, R6
    SUB R2, R2, R7

    ; Set Column Address (X Start, X End)
    MOV R0, #0x2A
    BL LCD_COMMAND_WRITE

    ;X1 higher 8 bits
    MOV R0, R1, LSR #8
    BL LCD_DATA_WRITE

    MOV R0, R1
    BL LCD_DATA_WRITE

    ;X2 higher 8 bits
    MOV R0, R3, LSR #8
    BL LCD_DATA_WRITE

    ;X2 lower 8 bits
    MOV R0, R3
    BL LCD_DATA_WRITE

    ;Set Page Address (Y Start, Y End)
    MOV R0, #0x2B
    BL LCD_COMMAND_WRITE
    
    ;Y1 higher 8 bits
    MOV R0, R2, LSR #8
    BL LCD_DATA_WRITE
    
    ;Y1 lower 8 bits
    MOV R0, R2 
    BL LCD_DATA_WRITE

    ;Y2 higher 8 bits
    MOV R0, R4, LSR #8
    BL LCD_DATA_WRITE

    ;Y2 lower 8 bits
    MOV R0, R4
    BL LCD_DATA_WRITE

    ; Start Writing Pixels
    MOV R0, #0x2C
    BL LCD_COMMAND_WRITE

TFT_ImageLoop_Center
    LDRH R0, [R12], #2  ; Load one pixel

    MOV R1, R0, LSR #8 ; Extract high byte
    AND R2, R0, #0xFF  ; Extract low byte

    MOV R0, R1         ; Send High Byte first
    BL LCD_DATA_WRITE

    MOV R0, R2         ; Send Low Byte second
    BL LCD_DATA_WRITE

    SUBS R11, R11, #1
    BNE TFT_ImageLoop_Center

    POP {R0-R7,R11-R12, PC}

DRAW_RECT
    ;THIS FUNCTION TAKES X AND Y AND A COLOR AND DRAWS THIS PIXEL
	;R1 = X1
	;R2 = Y1
	;R3 = X2
	;R4 = Y2
	;R5 = COLOR
    PUSH {R1-R12, LR}

    ; Set Column Address (X1 to X2)
    MOV R0, #0x2A        ; Column address set command
    BL LCD_COMMAND_WRITE
    
    ; Send X1 (16-bit)
    MOV R0, R1, LSR #8   ; X1 high byte
    BL LCD_DATA_WRITE

    MOV R0, R1           ; X1 low byte
    BL LCD_DATA_WRITE
    
    ; Send X2 (16-bit)
    MOV R0, R3, LSR #8   ; X2 high byte
    BL LCD_DATA_WRITE
    MOV R0, R3           ; X2 low byte
    BL LCD_DATA_WRITE

    ; Set Page Address (Y1 to Y2)
    MOV R0, #0x2B        ; Page address set command
    BL LCD_COMMAND_WRITE
    
    ; Send Y1 (16-bit)
    MOV R0, R2, LSR #8   ; Y1 high byte
    BL LCD_DATA_WRITE
    MOV R0, R2           ; Y1 low byte
    BL LCD_DATA_WRITE
    
    ; Send Y2 (16-bit)
    MOV R0, R4, LSR #8   ; Y2 high byte
    BL LCD_DATA_WRITE

    MOV R0, R4           ; Y2 low byte
    BL LCD_DATA_WRITE

    ; Memory Write
    MOV R0, #0x2C        ; Memory write command
    BL LCD_COMMAND_WRITE

    SUB R7, R3, R1     
    ADD R7, R7, #1    
    SUB R8, R4, R2       
    ADD R8, R8, #1        ; total pixels = width * height
	MUL R8, R7, R8

    ; Prepare color bytes
    MOV R1, R5, LSR #8   ; High byte
    AND R2, R5, #0xFF    ; Low byte

DRAW_RECT_LOOP
    ; Write high byte
    MOV R0, R1
    BL LCD_DATA_WRITE
    
    ; Write low byte
    MOV R0, R2
    BL LCD_DATA_WRITE
    
    SUBS R8, R8, #1
    BNE DRAW_RECT_LOOP

    POP {R1-R12, PC}
;R1 X1
;R2 Y1
;R3 Half WIDTH
;R4 Half HEIGHT
;R5 COLOR
TFT_DrawCenterRect
    PUSH {R0-R12, LR}

    ;RECTANGLE VERTICES:
    ; (X - BATWIDTH, Y - BATHEIGHT)
    ; (X + BATWIDTH, Y + BATHEIGHT)

    SUB R1, R1, R3
    
    ; X COORDINATES
    MOV R0, #0x2A
    BL LCD_COMMAND_WRITE
    
    MOV R0, R1, LSR #8 ;HIGH X1 BYTE
    BL LCD_DATA_WRITE
    MOV R0, R1        ;LOW BYTE
    BL LCD_DATA_WRITE

    ADD R1, R1, R3
	ADD R1, R1, R3
	;SUB R1, R1, #1  Abdallah did comment this

    MOV R0, R1, LSR #8 ;HIGH X2 BYTE
    BL LCD_DATA_WRITE
    MOV R0, R1         ;LOW BYTE
    BL LCD_DATA_WRITE

    ; Y COORDINATES
    SUB R2, R2, R4

    MOV R0, #0x2B
    BL LCD_COMMAND_WRITE
    
    MOV R0, R2, LSR #8 ;HIGH Y1 BYTE
    BL LCD_DATA_WRITE
    MOV R0, R2         ;LOW BYTE
    BL LCD_DATA_WRITE

	ADD R2, R2, R4
	ADD R2, R2, R4
	;SUB R2, R2, #1  Abdallah did comment this 

    MOV R0, R2, LSR #8 ;HIGH Y2 BYTE
    BL LCD_DATA_WRITE
    MOV R0, R2         ;LOW BYTE
    BL LCD_DATA_WRITE

        ; Memory Write
    MOV R0, #0x2C
    BL LCD_COMMAND_WRITE

    ; Prepare color bytes
    ; REUSE 1 AS COUNTER
    MOV R9, R5, LSR #8     ; High byte
    AND R10, R5, #0xFF      ; Low byte

    ; Fill screen with color (2*Width)*(2*Height)
    ;STORE
    MOV R6, R3  ;WIDTH->R6
    MOV R7, R4  ;HEIGHT->R7
    MOV R8, #2  ;2 -> R8
    MUL R6, R6, R8 ;R6 *= 2
    MUL R7, R7, R8 ;R7 *= 2
    ADD R6,R6,#1  ; FOR THE CENTRE PIXEL
    ADD R7,R7,#1  ; FOR THE CENTRE PIXEL
    MUL R1, R6, R7 ;R1(COUNTER) = R6 * R7

centerRectLoop

    ; Write high byte
    MOV R0, R9
    BL LCD_DATA_WRITE
    
    ; Write low byte
    MOV R0, R10
    BL LCD_DATA_WRITE
    
    SUBS R1, R1, #1
    BNE centerRectLoop

    POP {R0-R12, LR}
    BX LR
    LTORG

DRAW_TITLE
    PUSH    {R1-R3, LR}
    MOV R1, #TITLE_X
    MOV R2, #TITLE_Y
    LDR R3, =P
    BL TFT_DrawImage

    ADD R1, R1, #CHAR_SIZE
    LDR R3, =I
    BL TFT_DrawImage

    ADD R1, R1, #CHAR_SIZE
    LDR R3, =N
    BL TFT_DrawImage
    
    ADD R1, R1, #CHAR_SIZE
    LDR R3, =G
    BL TFT_DrawImage

    ADD R1, R1, #16 ;Special distance for copywrite character
    LDR R3, =CR
    BL TFT_DrawImage

    POP     {R1-R3,PC}
;#####################################################################################################################################################################	
;R1: X
;R2: Y
;R3: NUMBER
DRAW_DIGIT
    PUSH{R1-R5, LR}

    MOV R4, R3
    LDR R3, =digitArr
    MOV R5, #CHAR_MEM_SIZE
    MUL R4, R4, R5
    ADD R3, R3, R4
    BL 	TFT_DrawImage
    LDR R5, =digitArr
    SUB R3, R5, R4
    STR R3, [R5]

    POP{R1-R5, PC}
;#####################################################################################################################################################################	

DRAW_DIGITAL
    PUSH {R0-R12, LR}

    ; =====================
    ; Set Column Address (X Start, X End)
    ; =====================
	MOV R11, R4
	MOV R12, R5
	
    MOV R0, #0x2A
    BL LCD_COMMAND_WRITE

    MOV R0, R1, LSR #8
    BL LCD_DATA_WRITE

    MOV R0, R1  ; X Start
    BL LCD_DATA_WRITE

    ADD R0, R1, #16
    SUB R0, R0, #1  ; X End = X + Width - 1
    MOV R9, R0

    MOV R0, R9, LSR #8
    BL LCD_DATA_WRITE

    MOV R0, R9
    BL LCD_DATA_WRITE

    ; =====================
    ; Set Page Address (Y Start, Y End)
    ; =====================
    MOV R0, #0x2B
    BL LCD_COMMAND_WRITE
    
    MOV R0, R2, LSR #8
    BL LCD_DATA_WRITE

    MOV R0, R2  ; Y Start
    BL LCD_DATA_WRITE

    ADD R0, R2, #16
    SUB R0, R0, #1  ; Y End = Y + Height - 1
    MOV R9, R0

    MOV R0, R9, LSR #8
    BL LCD_DATA_WRITE

    MOV R0, R9
    BL LCD_DATA_WRITE

    ; =====================
    ; Start Writing Pixels
    ; =====================
    MOV R0, #0x2C
    BL LCD_COMMAND_WRITE

    ; =====================
    ; Send Pixel Data (BGR565)
    ; =====================
    MOV R6, #16

LOOP1
    CMP R6, #0
    BEQ END_DRAWDIGIT

    LDRH R4, [R3], #2
    MOV R5, #16

LOOP2
    MOV R7, R12
    TST R4, #(1 << 15)
    MOVNE R7, R11

    MOV R1, R7, LSR #8 ; Extract high byte
    AND R2, R7, #0xFF  ; Extract low byte

    MOV R0, R1         ; Send High Byte first
    BL LCD_DATA_WRITE
    
    MOV R0, R2         ; Send Low Byte second
    BL LCD_DATA_WRITE

    LSL R4, R4, #1
    SUBS R5, #1
    BNE LOOP2
    SUB R6, #1
    B LOOP1

END_DRAWDIGIT
    POP {R0-R12, PC}

PRINT
    PUSH {R0-R12,LR}
    ; R1 X, R2 Y, R3 Message Address
    MOV R10, R3

PRINT_LOOP
    MOV R9, #0
    LDRB R9, [R10], #1
	CMP R9, #0
	BEQ END_PRINT
    CMP R9, #0x20
    BEQ SKIP_DRAW_CHAR
    
    CMP R9, #ASCII_CHAR_OFFSET
    SUBLT R9, #ASCII_NUM_OFFSET
    LDRLT R3, =DIGITS
    SUBGE R9, R9, #ASCII_CHAR_OFFSET
    LDRGE R3, =CHARS

    LSL R9, R9, #5
    ADD R3, R3, R9
	BL DRAW_DIGITAL

SKIP_DRAW_CHAR
    ADD R1, R1, #CHAR_WIDTH

    SUBS R8, R8, #1
    B PRINT_LOOP

END_PRINT
    POP {R0-R12,PC}
;######################

; *************************************************************
; Prints a decimal number
; r1: x
; r2: y
; r3: number
; *************************************************************
PRINT_NUM
    PUSH {R0, R4-R12, LR}

    ; INITIAL ASSIGNMENTS
    MOV R8, R3 ; MOVES NUMBER TO R8
    MOV R9, SP ; MOVES STACK POINTER TO R9
    LDR R3, =DIGITS ;LOAD DIGITS' ADDRESS TO R3

    CMP R8, #0; NUMBER == 0?
    BNE STORE_LOOP
    LDR R3, =DIGITS ;LOAD DIGITS' ADDRES TO R3
    BL DRAW_DIGITAL; PRINTS 0
    B NUM_PRINT_DONE

STORE_LOOP
    MOV R6, #10
    UDIV R0, R8, R6 ;R0 = QUOTIENT(R8 / R6)
    MUL R7, R0, R6  
    SUB R6, R8, R7  ; R6 = R8 % 10 (R8 - (R0 * 10))
    PUSH {R6}
    MOV R8, R0
    CMP R8, #0
    BNE STORE_LOOP

DIGIT_PRNT_LOOP
    POP {R8}
    LSL R8, R8, #5
    LDR R3, =DIGITS ;LOAD DIGITS' ADDRESS TO R3
    ADD R3, R3, R8
    BL  DRAW_DIGITAL 
    ADD R1, R1, #CHAR_WIDTH
    CMP SP, R9
    BNE DIGIT_PRNT_LOOP

NUM_PRINT_DONE
    POP {R0, R4-R12, LR}
    BX  LR


DELAY
    PUSH {R0, LR}
    LDR R0, =DELAY_INTERVAL
DELAY_LOOP
    SUBS R0, R0, #1
    BNE DELAY_LOOP
    POP {R0, LR}
    BX LR

;=======================================================

DELAY_1_SECOND
	PUSH{R0-R12, LR}
	LDR R0, =SOURCE_DELAY_INTERVAL
DELAY_1_SECOND_LOOP
	SUBS R0, R0, #1
	BGE DELAY_1_SECOND_LOOP
	POP{R0-R12, PC}
 
;=======================================================
 
DELAY_HALF_SECOND
	PUSH{R0-R12, LR}
	LDR R0, =SOURCE_DELAY_INTERVAL
 
DELAY_HALF_SECOND_LOOP
	SUBS R0, R0, #2
	BGE DELAY_HALF_SECOND_LOOP
	POP{R0-R12, PC}
 
;=======================================================
 
DELAY_100_MILLISECOND
	PUSH{R0-R12, LR}
	LDR R0, =SOURCE_DELAY_INTERVAL
 
DELAY_100_MILLISECOND_LOOP
	SUBS R0, R0, #10
	BGE DELAY_10_MILLISECOND_LOOP
	POP{R0-R12, PC}
 
;=======================================================
 
DELAY_10_MILLISECOND
	PUSH{R0-R12, LR}
	LDR R0, =SOURCE_DELAY_INTERVAL
 
DELAY_10_MILLISECOND_LOOP
	SUBS R0, R0, #100
	BGE DELAY_10_MILLISECOND_LOOP
	POP{R0-R12, PC}
 
;=======================================================
 
DELAY_1_MILLISECOND
	PUSH{R0-R12, LR}
	LDR R0, =SOURCE_DELAY_INTERVAL
 
DELAY_1_MILLISECOND_LOOP
	SUBS R0, R0, #1000
	BGE DELAY_10_MILLISECOND_LOOP
	POP{R0-R12, PC}
 
;=======================================================

CUSTOM_DELAY
	;input R0 = DELAY_INTERVAL
	PUSH{R0, LR}

CUSTOM_DELAY_LOOP
	SUBS R0, R0, #1
	BGE CUSTOM_DELAY_LOOP
	POP{R0, PC}
 		
    END