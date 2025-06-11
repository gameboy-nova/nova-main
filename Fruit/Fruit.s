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
    EXPORT Fruit
    IMPORT APPLE
    IMPORT ORANGE
    IMPORT BASKET
    IMPORT MELON
    IMPORT PEAR
    IMPORT CHARS
	IMPORT DIGITS
    IMPORT digitArr
    IMPORT WIN_MSG_IMG
    IMPORT LOSE_MSG_IMG
    IMPORT MSG_IMG
    IMPORT DELAY_1_SECOND
    IMPORT CUSTOM_DELAY
    IMPORT TFT_DrawImage 
	IMPORT TFT_FillScreen
	IMPORT DRAW_DIGIT
	IMPORT DRAW_RECT
	IMPORT TFT_DrawCenterRect
    IMPORT PRINT
    IMPORT PRINT_NUM
    IMPORT BACK_TO_MAIN
    IMPORT GAME_BACK_HANDLE
	AREA FruitData, DATA, READWRITE

;Colors
Red     EQU 0xF800  ; 11111 000000 00000
Green   EQU 0x07E0  ; 00000 111111 00000
Blue    EQU 0x001F  ; 00000 000000 11111
Yellow  EQU 0xFFE0  ; 11111 111111 00000
White   EQU 0xFFFF  ; 11111 111111 11111
Black   EQU 0x0000  ; 00000 000000 00000
BASKET_CLR EQU 0x07E0 ; Green
FRUIT_CLR  EQU 0xF800 ; Red

; Constants
SCREEN_WIDTH    EQU     320
SCREEN_HEIGHT   EQU     240

BASKET_WIDTH    EQU     30
BASKET_HEIGHT   EQU     20
BASKET_Y_POS    EQU     SCREEN_HEIGHT - BASKET_HEIGHT - 5 ; Fixed Y position at the bottom
BASKET_MOVE_SPEED EQU   9  ; Reduced from 8 to 3 for smoother movement

FRUIT_SIZE      EQU     30 ; Fruit will be a square
FRUIT_FALL_SPEED EQU    10

UPPER_BOUND     EQU     30       ; Top boundary for score display, etc.
LOWER_BOUND     EQU     SCREEN_HEIGHT - 5 ; Bottom edge of playable area
RIGHT_BOUND     EQU     SCREEN_WIDTH - 5
LEFT_BOUND      EQU     5

TITLE_X         EQU     70 
TITLE_Y         EQU     0
CHAR_SIZE       EQU     20      
CHAR_MEM_SIZE   EQU     520     
MAX_SCORE       EQU     15       ; Max score to win the game
SCORE_X         EQU     10        ; X position for score display (top-right)
SCORE_Y         EQU     10         ; Y position for score display
SCORE_CLR       EQU     White      ; Color for score display
MAX_MISSED_FRUITS EQU     3          ; Number of fruits allowed to be missed
MISSED_X          EQU     SCREEN_WIDTH - 30 ; X for missed fruits count (adjusted for space)
MISSED_Y          EQU     SCORE_Y           ; Y for missed fruits count (same line as score)
MISSED_CLR        EQU     Red               ; Color for missed fruit count
FRUIT_TYPE_APPLE  EQU     0
FRUIT_TYPE_ORANGE EQU     1
FRUIT_TYPE_MELON  EQU     2
FRUIT_TYPE_PEAR   EQU     3

; Positioning for Game Over Messages (adjust X based on actual image widths)
WIN_MSG_X         EQU     ((SCREEN_WIDTH - 7 * 16) / 2) ; Example: Center a 100px wide image
WIN_MSG_Y         EQU     ((SCREEN_HEIGHT - 3 * 16) / 2); Example: Center a 40px high image
LOSE_MSG_X        EQU     ((SCREEN_WIDTH - 8 * 16) / 2) ; Example: Center a 100px wide image
LOSE_MSG_Y        EQU     ((SCREEN_HEIGHT - 3 * 16) / 2); Example: Center a 40px high image
RetryImage_X        EQU     ((SCREEN_WIDTH - 16 * 16) / 2)
RetryImage_Y        EQU     (WIN_MSG_Y) + 32


ASCII_CHAR_OFFSET EQU 'A'
ASCII_NUM_OFFSET EQU '0'
CHAR_WIDTH EQU 16

ASCII_OFFSET EQU 'A'


; Timing Constants
FRAME_DELAY_DEFAULT       EQU     500000  ; Default frame delay
FRAME_DELAY_LEVEL2        EQU     425000  ; Slightly faster
FRAME_DELAY_LEVEL3        EQU     350000  ; Even faster
;SOURCE_DELAY_INTERVAL EQU 2000000  ; Longer delay for screens - Unused in current logic for game speed

; Score Thresholds for Difficulty Increase
SCORE_THRESHOLD_LEVEL2    EQU     5       ; Score to reach for level 2 difficulty
SCORE_THRESHOLD_LEVEL3    EQU     10      ; Score to reach for level 3 difficulty

GPIOA_BASE      EQU     0x40020000
GPIOB_BASE		EQU		0x40020400

; Define register offsets
RCC_AHB1ENR     EQU     0x30
GPIO_MODER      EQU     0x00
GPIO_OTYPER     EQU     0x04
GPIO_OSPEEDR    EQU     0x08
GPIO_PUPDR      EQU     0x0C
GPIO_IDR        EQU     0x10
GPIO_ODR        EQU     0x14

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

; Game state variables
score           DCB     0
basket_X        DCW     0
prev_basket_X   DCW     0 ; Previous basket X
fruit_X         DCW     0
fruit_Y         DCW     0
prev_fruit_X    DCW     0 ; Previous fruit X
prev_fruit_Y    DCW     0 ; Previous fruit Y
fruit_active    DCB     0
prev_fruit_active DCB   0 ; Was fruit active in previous frame?
lcg_seed        DCW     1234 ; Seed for pseudo-random number generator
missed_fruits   DCB     0           ; Counter for uncaught fruits
current_fruit_type DCB  FRUIT_TYPE_APPLE ; Current type of fruit to spawn
current_frame_delay DCD   FRAME_DELAY_DEFAULT ; Current frame delay, for difficulty

DELAY_INTERVAL  EQU     0x18604 
SOURCE_DELAY_INTERVAL EQU   0x386004   
FRAME_DELAY     EQU     0x10500

LCG_A               EQU     205        ; LCG Multiplier
LCG_C               EQU     1011       ; LCG Increment
; LCG_M is implicitly 2^16 due to 16-bit HWORD operations for seed
HORIZONTAL_SPAWN_MARGIN EQU 10     ; Margin from screen edges for fruit spawning

    AREA FruitCode, CODE, READONLY
	
Fruit FUNCTION
	
MAIN_GAME_RESTART          ; Label for restarting the game
    BL VARS_INIT           ; Initialize/reset all game variables

    LDR R5, =Black         ; Set color to Black
    BL TFT_FillScreen      ; Clear the screen before starting/restarting

    LDR R0, =DELAY_1_SECOND ; Or a shorter delay for restarts
    
    BL GAME_LOOP           ; Enter the main game loop

    B .                    ; Should ideally not be reached if GAME_LOOP handles retry
    ENDFUNC
	LTORG
;####################################################*"Functions"*##############################################################################################
GAME_LOOP
    PUSH {R0-R12, LR}

GAME_LOOP_LOGIC_START
    BL BACK_TO_MAIN
    BL ERASE_CURRENT_BASKET
    BL ERASE_CURRENT_FRUIT

    BL GET_STATE_SIMPLE     ; R3 will have button state

    CMP R3, #0
    BLNE UPDATE_BASKET_POS    ; Updates basket_X based on R3
    BL UPDATE_FRUIT_POS     ; Handles fruit falling, spawning new fruit if needed
  
    BL CHECK_COLLISION
  
    LDR R4, =score      ; Use R4 to avoid conflict if CHECK_COLLISION uses R0-R3
    LDRB R4, [R4]       ; R4 = current score
    MOV R5, #MAX_SCORE  ; R5 = max score to win (MAX_SCORE is 15 now)
    CMP R4, R5
    BGE GAME_OVER_WIN   ; If score >= MAX_SCORE, player wins

    BL CHECK_FRUIT_MISSED   ; This might branch to GAME_OVER_LOSE

    BL RENDER_GAME_OBJECTS  ; Renders basket and fruit at new positions

    LDR R0, =score
    LDRB R0, [R0]       ; R0 = score value
    MOV R1, #SCORE_X    ; R1 = X position for score
    MOV R2, #SCORE_Y    ; R2 = Y position for score
    MOV R3, R0          ; R3 = score value for PRINT_NUM
    BL PRINT_NUM        ; Draw the current score using PRINT_NUM

    LDR R0, =missed_fruits
    LDRB R0, [R0]           ; R0 = missed_fruits value
    MOV R1, #MISSED_X       ; R1 = X position for missed count
    MOV R2, #MISSED_Y       ; R2 = Y position for missed count
    MOV R3, R0              ; R3 = missed_fruits value (digit to draw)
    BL DRAW_DIGIT          ; Draw the missed fruits count

    LDR R1, =score
    LDRB R1, [R1]                   ; R1 = current score value
    LDR R2, =current_frame_delay    ; R2 = address of current_frame_delay variable

    LDR R4, =FRAME_DELAY_DEFAULT    ; R4 holds the delay to be set

    LDR R5, =SCORE_THRESHOLD_LEVEL3
    CMP R1, R5
    BLT CHECK_DIFFICULTY_LEVEL2_NEXT ; If score < SCORE_THRESHOLD_LEVEL3, try level 2
    LDR R4, =FRAME_DELAY_LEVEL3     ; Else, score is high enough for level 3 delay
    B STORE_NEW_FRAME_DELAY_VALUE
	LTORG
CHECK_DIFFICULTY_LEVEL2_NEXT
    LDR R5, =SCORE_THRESHOLD_LEVEL2
    CMP R1, R5
    BLT STORE_NEW_FRAME_DELAY_VALUE   ; If score < SCORE_THRESHOLD_LEVEL2, R4 (default) is fine
    LDR R4, =FRAME_DELAY_LEVEL2     ; Else, score is high enough for level 2 delay

STORE_NEW_FRAME_DELAY_VALUE
    STR R4, [R2]                    ; Store the chosen frame delay value into the variable
    LDR R0, [R2]                    ; Load the current_frame_delay value from variable into R0
    BL CUSTOM_DELAY
    B GAME_LOOP_LOGIC_START ; Loop back to process next frame (GAME_LOOP_LOGIC_START is after PUSH {R0-R12,LR} at GAME_LOOP label)

GAME_LOOP_EXIT_POINT       ; Common exit for GAME_LOOP (called by GAME_MAIN with BL GAME_LOOP)
    POP {R0-R12, PC}        ; Return to GAME_MAIN (specifically, to GAME_MAIN_LOOP_ENTRY)

    POP {R0-R12, PC}

GAME_OVER_WIN               ; Label for game over when player wins
    PUSH {R0-R5, LR}    ; Save context

    MOV R1, #0                  ; X1 = 0
    MOV R2, #0                  ; Y1 = 0
    MOV R3, #SCREEN_WIDTH       ; X2 = SCREEN_WIDTH
    MOV R4, #SCREEN_HEIGHT      ; Y2 = SCREEN_HEIGHT
    LDR R5, =Green              ; Color Green for Win Screen
    BL DRAW_RECT                ; Clear screen to Green

    MOV R1, #WIN_MSG_X          ; R1 = X for WIN_MSG_IMG
    MOV R2, #WIN_MSG_Y          ; R2 = Y for WIN_MSG_IMG
    LDR R3, =WIN_MSG_IMG        ; R3 = address of WIN_MSG_IMG data
    BL PRINT

    MOV R1, #RetryImage_X
    MOV R2, #RetryImage_Y
    LDR R3, =MSG_IMG
    BL PRINT

    LDR R1, =MAIN_GAME_RESTART
    BL GAME_BACK_HANDLE

    POP {R0-R5, LR}       ; Restore registers before waiting loop

WAIT_FOR_RETRY_WIN_LOOP
    BL GET_STATE_SIMPLE     ; Get button state in R3 (assuming it returns button state)
    CMP R3, #0              ; Check if any button pressed (R3 non-zero)
    BEQ WAIT_FOR_RETRY_WIN_LOOP ; If no button, keep waiting

    B MAIN_GAME_RESTART     ; Button pressed, branch to restart the game

;-----------------------------------------------------------------------------
GAME_OVER_LOSE              ; Label for game over when player loses
    PUSH {R0-R5, LR}    ; Save context

    MOV R1, #0                  ; X1 = 0
    MOV R2, #0                  ; Y1 = 0
    MOV R3, #SCREEN_WIDTH       ; X2 = SCREEN_WIDTH
    MOV R4, #SCREEN_HEIGHT      ; Y2 = SCREEN_HEIGHT
    LDR R5, =Red                ; Color Red for Lose Screen
    BL DRAW_RECT                ; Clear screen to Red

    MOV R1, #LOSE_MSG_X         ; R1 = X for LOSE_MSG_IMG
    MOV R2, #LOSE_MSG_Y         ; R2 = Y for LOSE_MSG_IMG
    LDR R3, =LOSE_MSG_IMG       ; R3 = address of LOSE_MSG_IMG data
    BL PRINT

    MOV R1, #RetryImage_X
    MOV R2, #RetryImage_Y
    LDR R3, =MSG_IMG
    BL PRINT

    LDR R1, =MAIN_GAME_RESTART
    BL GAME_BACK_HANDLE

    POP {R0-R5, LR}       ; Restore registers before waiting loop

WAIT_FOR_RETRY_LOSE_LOOP
    BL GET_STATE_SIMPLE     ; Get button state in R3
    CMP R3, #0              ; Check if any button pressed
    BEQ WAIT_FOR_RETRY_LOSE_LOOP ; If no button, keep waiting

    B MAIN_GAME_RESTART     ; Button pressed, branch to restart the game

;#####################################################################################################################################################################	
; Initializes the variables with the appropriate values
VARS_INIT
    PUSH {R0-R4, LR}    ; Save registers that will be used

    LDR R0, =score
    MOV R1, #0
    STRB R1, [R0]
    MOV R1, #SCREEN_WIDTH       ; R1 = SCREEN_WIDTH
    MOV R2, #BASKET_WIDTH       ; R2 = BASKET_WIDTH
    SUB R1, R1, R2              ; R1 = SCREEN_WIDTH - BASKET_WIDTH
    LSR R1, R1, #1              ; R1 = (SCREEN_WIDTH - BASKET_WIDTH) / 2 (division by 2)

    LDR R0, =basket_X
    STRH R1, [R0]               ; basket_X = calculated center
    LDR R0, =prev_basket_X
    STRH R1, [R0]               ; prev_basket_X = calculated center

    MOV R1, #0
    LDR R0, =fruit_X
    STRH R1, [R0]
    LDR R0, =prev_fruit_X
    STRH R1, [R0]

    MOV R1, #UPPER_BOUND      ; FRUIT_START_Y is typically 0
    LDR R0, =fruit_Y
    STRH R1, [R0]
    LDR R0, =prev_fruit_Y
    STRH R1, [R0]

    LDR R0, =fruit_active
    MOV R1, #0
    STRB R1, [R0]
    LDR R0, =prev_fruit_active ; also init prev_fruit_active
    STRB R1, [R0]

    LDR R0, =lcg_seed
    MOV R1, #1234               ; Initial LCG seed value
    STRH R1, [R0]

    LDR R0, =missed_fruits
    LDR R0, =missed_fruits
    MOV R1, #0
    STRB R1, [R0]

    ; Initialize current_fruit_type to Apple
    LDR R0, =current_fruit_type
    MOV R1, #FRUIT_TYPE_APPLE
    STRB R1, [R0]

    ; Initialize current_frame_delay to default
    LDR R0, =current_frame_delay
    LDR R1, =FRAME_DELAY_DEFAULT
    STR R1, [R0]

    POP {R0-R4, LR}
    BX LR

ERASE_CURRENT_BASKET
    PUSH {R0-R7, LR}

    LDR R0, =basket_X
    LDRH R1, [R0]           ; R1 = current basket_X
    MOV R2, #BASKET_Y_POS   ; R2 = BASKET_Y_POS
    ADD R3, R1, #BASKET_WIDTH ; R3 = X2 (basket_X + BASKET_WIDTH)
    MOV R4, #BASKET_Y_POS
    ADD R4, R4, #BASKET_HEIGHT; R4 = Y2 (BASKET_Y_POS + BASKET_HEIGHT)
    LDR R5, =Black          ; Color Black
    BL DRAW_RECT

    POP {R0-R7, PC}

;#####################################################################################################################################################################	
ERASE_CURRENT_FRUIT
    PUSH {R0-R7, LR}

    LDR R0, =fruit_active
    LDRB R0, [R0]           ; R0 = current fruit_active
    CMP R0, #1
    BNE ERASE_CURRENT_FRUIT_DONE ; If fruit not active, nothing to erase

    LDR R0, =fruit_X
    LDRH R1, [R0]           ; R1 = current fruit_X
    LDR R0, =fruit_Y
    LDRH R2, [R0]           ; R2 = current fruit_Y
    ADD R3, R1, #FRUIT_SIZE ; R3 = X2 (fruit_X + FRUIT_SIZE)
    ADD R4, R2, #FRUIT_SIZE ; R4 = Y2 (fruit_Y + FRUIT_SIZE)
    LDR R5, =Black          ; Color Black
    BL DRAW_RECT

ERASE_CURRENT_FRUIT_DONE
    POP {R0-R7, PC}

;#####################################################################################################################################################################	
ERASE_OLD_POSITIONS
    PUSH {R0-R7, LR}

    LDR R0, =basket_X
    LDRH R0, [R0]           ; R0 = current basket_X
    LDR R1, =prev_basket_X
    LDRH R1, [R1]           ; R1 = prev_basket_X
    CMP R0, R1
    BEQ SKIP_BASKET_ERASE   ; If basket hasn't moved, skip erasing

    MOV R1, R1              ; R1 = prev_basket_X
    MOV R2, #BASKET_Y_POS   ; R2 = BASKET_Y_POS (fixed Y)
    ADD R3, R1, #BASKET_WIDTH ; R3 = X2
    MOV R4, #BASKET_Y_POS
    ADD R4, R4, #BASKET_HEIGHT ; R4 = Y2
    LDR R5, =Black          ; Color Black
    BL DRAW_RECT

SKIP_BASKET_ERASE
    LDR R0, =fruit_active
    LDRB R0, [R0]           ; R0 = current fruit_active
    LDR R1, =prev_fruit_active
    LDRB R1, [R1]           ; R1 = prev_fruit_active
    CMP R1, #1
    BNE ERASE_DONE          ; If prev_fruit_active was 0, skip erasing

    CMP R0, #1              ; Is fruit still active?
    BNE ERASE_PREV_FRUIT_CENTER    ; If fruit became inactive, must erase old position

    LDR R2, =fruit_X
    LDRH R2, [R2]           ; R2 = current fruit_X
    LDR R3, =prev_fruit_X
    LDRH R3, [R3]           ; R3 = prev_fruit_X
    CMP R2, R3
    BNE ERASE_PREV_FRUIT_CENTER    ; If X position changed, must erase

    LDR R2, =fruit_Y
    LDRH R2, [R2]           ; R2 = current fruit_Y
    LDR R3, =prev_fruit_Y
    LDRH R3, [R3]           ; R3 = prev_fruit_Y
    CMP R2, R3
    BEQ ERASE_DONE          ; If both X and Y same, skip erasing

ERASE_PREV_FRUIT_CENTER
    LDR R0, =prev_fruit_X
    LDRH R1, [R0]           ; R1 = prev_fruit_X
    LDR R0, =prev_fruit_Y
    LDRH R2, [R0]           ; R2 = prev_fruit_Y
    MOV R7, #FRUIT_SIZE     ; R7 = FRUIT_SIZE (10)
    LSR R7, R7, #1          ; R7 = FRUIT_SIZE / 2 (5)
    
    ADD R1, R1, R7          ; R1 = prev_fruit_X_center (prev_fruit_X + 5)
    ADD R2, R2, R7          ; R2 = prev_fruit_Y_center (prev_fruit_Y + 5)
    MOV R3, R7              ; R3 = Half_Width (5)
    MOV R4, R7              ; R4 = Half_Height (5)
    LDR R5, =Black          ; Color Black
    BL TFT_DrawCenterRect

ERASE_DONE
    POP {R0-R7, PC}
;#####################################################################################################################################################################	
GET_STATE_SIMPLE
    PUSH {R0, R4, LR}       ; R4 for GPIOB_IDR base
    LDR R0, =GPIOB_BASE + GPIO_IDR  ; Read from GPIOB where the buttons are connected
    LDRH R1, [R0]          ; Load the input state into R1
    
    MOV R3, #0              ; Default: no button pressed / no relevant bits set in R3

    TST R1, #BTN_BL         ; Test if BTN_BL is pressed
    ORRNE R3, R3, #1        ; If pressed, set bit 0 in R3 for "left"

    TST R1, #BTN_BR         ; Test if BTN_BR is pressed
    ORRNE R3, R3, #2        ; If pressed, set bit 1 in R3 for "right"

    POP {R0, R4, PC}

;#####################################################################################################################################################################	
UPDATE_BASKET_POS
    PUSH {R0-R7, LR}

    LDR R0, =basket_X
    LDRH R1, [R0]           ; R1 = current basket_X
    LDR R2, =prev_basket_X
    STRH R1, [R2]           ; prev_basket_X = current basket_X

    LDR R4, =basket_X
    LDRH R5, [R4]           ; R5 = current basket_X
    
    MOV R6, #BASKET_MOVE_SPEED  ; R6 = BASKET_MOVE_SPEED (direct constant access)
    
    ; Check for left button press
    TST R3, #1                  ; Test if left button (bit 0) is pressed
    BEQ CHECK_RIGHT_BTN         ; If not, skip left movement

    SUB R5, R5, R6              ; basket_X = basket_X - BASKET_MOVE_SPEED

    MOV R7, #LEFT_BOUND         ; R7 = LEFT_BOUND (direct constant access)
    CMP R5, R7
    MOVLT R5, R7                ; If basket_X < LEFT_BOUND, basket_X = LEFT_BOUND

CHECK_RIGHT_BTN
    TST R3, #2                  ; Test if right button (bit 1) is pressed
    BEQ STORE_UPDATED_POS       ; If not, skip right movement

    ADD R5, R5, R6              ; basket_X = basket_X + BASKET_MOVE_SPEED

    MOV R7, #RIGHT_BOUND        ; R7 = RIGHT_BOUND (direct constant access)
    SUB R7, R7, #BASKET_WIDTH   ; R7 = RIGHT_BOUND - BASKET_WIDTH
    
    CMP R5, R7
    MOVGT R5, R7                ; If basket_X > (RIGHT_BOUND - BASKET_WIDTH), clamp it

STORE_UPDATED_POS
    ; Store the final basket_X value
    STRH R5, [R4]               ; Store updated basket_X

END_UPDATE_BASKET
    POP {R0-R7, PC}

;#####################################################################################################################################################################	
RENDER_GAME_OBJECTS
    PUSH {LR}

    BL RENDER_BASKET

    BL RENDER_FRUIT

    POP {PC}

RENDER_BASKET
    PUSH {R0-R7, LR} ; Save registers

    ; Always draw basket at its current position
    LDR R0, =basket_X
    LDRH R1, [R0]       ; R1 = current basket_X (target X for TFT_DrawImage)

    MOV R2, #BASKET_Y_POS ; R2 = basket_Y (target Y for TFT_DrawImage)
    LDR R3, =BASKET     ; R3 = address of BASKET image data
    BL TFT_DrawImage    ; Call function to draw the image

RENDER_BASKET_DONE

    POP {R0-R7, PC}

;#####################################################################################################################################################################	
RENDER_FRUIT
    PUSH {R0-R7, LR}

    LDR R0, =fruit_active
    LDRB R6, [R0]       ; Load current fruit_active flag into R6
    
    CMP R6, #1
    BNE RENDER_FRUIT_DONE ; If fruit not active, skip drawing
    
    LDR R0, =fruit_X
    LDRH R1, [R0]       ; R1 = current fruit_X
    LDR R0, =fruit_Y
    LDRH R2, [R0]       ; R2 = current fruit_Y
    
    MOV R7, #FRUIT_SIZE     ; R7 = FRUIT_SIZE (15)
    LSR R7, R7, #1          ; R7 = FRUIT_SIZE / 2 (7)

    ADD R1, R1, R7          ; R1 = fruit_X_center (fruit_X + 7)
    ADD R2, R2, R7          ; R2 = fruit_Y_center (fruit_Y + 7)
    MOV R3, R7              ; R3 = Half_Width (7)
    MOV R4, R7              ; R4 = Half_Height (7)

    LDR R0, =current_fruit_type
    LDRB R6, [R0]           ; R6 = current_fruit_type
    CMP R6, #FRUIT_TYPE_APPLE
    LDREQ R3, =APPLE    ; If Apple, R5 = address of APPLE image data
    CMP R6, #FRUIT_TYPE_ORANGE
    LDREQ R3, =ORANGE   
    CMP R6, #FRUIT_TYPE_MELON
    LDREQ R3, =MELON
    CMP R6, #FRUIT_TYPE_PEAR
    LDREQ R3, =PEAR

    BL TFT_DrawImage    ; Call function to draw the image

RENDER_FRUIT_DONE
    POP {R0-R7, PC}
;#####################################################################################################################################################################	
;-----------------------------------------------------------------------------
; SPAWN_FRUIT: Activates a new fruit at a random X position at the top.
; Modifies: fruit_X, fruit_Y, fruit_active, lcg_seed
;           prev_fruit_X, prev_fruit_Y, prev_fruit_active
;-----------------------------------------------------------------------------
SPAWN_FRUIT
    PUSH {R0-R7, LR}

    LDR R0, =current_fruit_type
    LDRB R1, [R0]           ; R1 = current type
    EOR R1, R1, #1          ; Toggle 0 to 1, 1 to 0 (FRUIT_TYPE_APPLE <-> FRUIT_TYPE_ORANGE)
    STRB R1, [R0]           ; Store new type

    LDR R0, =lcg_seed
    LDRH R1, [R0]           ; R1 = current lcg_seed

    MOV R2, #LCG_A          ; R2 = LCG_A (multiplier)
    MUL R1, R1, R2          ; R1 = R1 * R2 (lower 32 bits of product)
    MOV R2, #LCG_C          ; R2 = LCG_C (increment)
    ADD R1, R1, R2          ; R1 = R1 + R2 (new seed value, auto-modulo by 16/32-bit register size)
                                ; For HWORD, we only care about lower 16-bits.
    STRH R1, [R0]           ; Store new 16-bit seed back to lcg_seed

    MOV R2, #SCREEN_WIDTH
    SUB R2, R2, #FRUIT_SIZE
    MOV R3, #HORIZONTAL_SPAWN_MARGIN
    LSL R3, R3, #1          ; R3 = HORIZONTAL_SPAWN_MARGIN * 2
    SUB R2, R2, R3          ; R2 = fruit_X_spawn_range

    MOV R4, R1              ; R4 = random_value (from R1, ensure it's positive or handle if it can be negative)
    UDIV R5, R4, R2         ; R5 = R4 / R2 (random_value / range)
    MUL R5, R5, R2          ; R5 = (random_value / range) * range
    SUB R1, R4, R5          ; R1 = random_value % range (this is the remainder)

    ADD R1, R1, #HORIZONTAL_SPAWN_MARGIN ; R1 = (random_value % range) + HORIZONTAL_SPAWN_MARGIN

    LDR R0, =fruit_X
    STRH R1, [R0]           ; fruit_X = calculated X position

    LDR R0, =fruit_Y
    MOV R1, #0
    STRH R1, [R0]           ; fruit_Y = 0
    LDR R0, =fruit_active
    MOV R1, #1
    STRB R1, [R0]           ; fruit_active = 1

    LDR R0, =fruit_X
    LDRH R1, [R0]           ; R1 = new fruit_X
    LDR R2, =prev_fruit_X
    STRH R1, [R2]           ; prev_fruit_X = new fruit_X

    LDR R0, =fruit_Y
    LDRH R1, [R0]           ; R1 = new fruit_Y
    LDR R2, =prev_fruit_Y
    STRH R1, [R2]           ; prev_fruit_Y = new fruit_Y

    LDR R0, =fruit_active
    LDRB R1, [R0]           ; R1 = new fruit_active (should be 1)
    LDR R2, =prev_fruit_active
    STRB R1, [R2]           ; prev_fruit_active = new fruit_active

    POP {R0-R7, PC}

;-----------------------------------------------------------------------------
; UPDATE_FRUIT_POS: Manages fruit falling and respawning.
; Modifies: fruit_X, fruit_Y, fruit_active, and their prev_ counterparts
; Calls: SPAWN_FRUIT
;-----------------------------------------------------------------------------
UPDATE_FRUIT_POS
    PUSH {R0-R7, LR}

    LDR R0, =fruit_X
    LDRH R1, [R0]           ; R1 = current fruit_X
    LDR R2, =prev_fruit_X
    STRH R1, [R2]           ; prev_fruit_X = current fruit_X

    LDR R0, =fruit_Y
    LDRH R1, [R0]           ; R1 = current fruit_Y
    LDR R2, =prev_fruit_Y
    STRH R1, [R2]           ; prev_fruit_Y = current fruit_Y

    LDR R0, =fruit_active
    LDRB R1, [R0]           ; R1 = current fruit_active
    LDR R2, =prev_fruit_active
    STRB R1, [R2]           ; prev_fruit_active = current fruit_active

    CMP R1, #0              ; Compare current fruit_active (from R1) with 0
    BEQ FRUIT_NEEDS_SPAWN   ; If inactive, branch to spawn a new fruit

    LDR R0, =fruit_Y
    LDRH R3, [R0]           ; R3 = current fruit_Y
    ADD R3, R3, #FRUIT_FALL_SPEED ; R3 = fruit_Y + FRUIT_FALL_SPEED
    STRH R3, [R0]           ; Store updated fruit_Y

    CMP R3, #240            ; Compare fruit_Y with 240 (SCREEN_HEIGHT)
    BLT FRUIT_UPDATE_DONE   ; If fruit_Y < 240, it's still on screen

    LDR R4, =missed_fruits
    LDRB R5, [R4]
    ADD R5, R5, #1
    STRB R5, [R4]           ; missed_fruits++

    LDR R0, =fruit_active
    MOV R1, #0
    STRB R1, [R0]           ; fruit_active = 0
    B FRUIT_UPDATE_DONE     ; Skip to end for this frame

FRUIT_NEEDS_SPAWN
    BL SPAWN_FRUIT          ; Call SPAWN_FRUIT to activate and position a new fruit

FRUIT_UPDATE_DONE
    POP {R0-R7, PC}

;-----------------------------------------------------------------------------
; CHECK_COLLISION: Checks for collision between fruit and basket.
; Modifies: score, fruit_active if collision occurs.
;-----------------------------------------------------------------------------
CHECK_COLLISION
    PUSH {R0-R10, LR}

    ; 1. Check if fruit is active
    LDR R0, =fruit_active
    LDRB R0, [R0]           ; R0 = fruit_active
    CMP R0, #0
    BEQ NO_COLLISION        ; If fruit not active, no collision

    ; 2. Get fruit coordinates
    LDR R1, =fruit_X
    LDRH R1, [R1]           ; R1 = fruit_left (fruit_X)
    LDR R2, =fruit_Y
    LDRH R2, [R2]           ; R2 = fruit_top (fruit_Y)
    MOV R3, #FRUIT_SIZE
    ADD R4, R1, R3          ; R4 = fruit_right (fruit_X + FRUIT_SIZE)
    ADD R5, R2, R3          ; R5 = fruit_bottom (fruit_Y + FRUIT_SIZE)

    ; 3. Get basket coordinates
    LDR R6, =basket_X
    LDRH R6, [R6]           ; R6 = basket_left (basket_X)
    MOV R7, #BASKET_Y_POS   ; R7 = basket_top (BASKET_Y_POS)
    MOV R8, #BASKET_WIDTH
    ADD R9, R6, R8          ; R9 = basket_right (basket_X + BASKET_WIDTH)
    MOV R8, #BASKET_HEIGHT
    ADD R10, R7, R8         ; R10 = basket_bottom (BASKET_Y_POS + BASKET_HEIGHT)

    ; 4. Perform AABB collision check
    ; Collision if NOT (fruit_right < basket_left OR fruit_left > basket_right OR fruit_bottom < basket_top OR fruit_top > basket_bottom)

    ; Check: fruit_right < basket_left (fruit is to the left of basket)
    CMP R4, R6
    BLT NO_COLLISION_LOGIC  ; If R4 (fruit_right) < R6 (basket_left), no collision

    ; Check: fruit_left > basket_right (fruit is to the right of basket)
    CMP R1, R9
    BGT NO_COLLISION_LOGIC  ; If R1 (fruit_left) > R9 (basket_right), no collision

    ; Check: fruit_bottom < basket_top (fruit is above basket)
    CMP R5, R7
    BLT NO_COLLISION_LOGIC  ; If R5 (fruit_bottom) < R7 (basket_top), no collision

    ; Check: fruit_top > basket_bottom (fruit is below basket)
    CMP R2, R10
    BGT NO_COLLISION_LOGIC  ; If R2 (fruit_top) > R10 (basket_bottom), no collision

    ; If none of the above conditions for NO_COLLISION_LOGIC were met, then there IS a collision.
COLLISION_OCCURRED
    ; Increment score
    LDR R4, =score
    LDRB R1, [R4]           ; R1 = current score (LDRB for DCB)
    ADD R1, R1, #1          ; Increment score
    STRB R1, [R4]           ; Store new score (STRB for DCB)

    ; Deactivate fruit
    LDR R0, =fruit_active
    MOV R1, #0
    STRB R1, [R0]           ; fruit_active = 0 (will spawn new one on next update)

    B COLLISION_HANDLED     ; Skip NO_COLLISION_LOGIC label

NO_COLLISION_LOGIC     ; Label for branching if no collision is detected by any check
    ; No action needed if no collision

COLLISION_HANDLED      ; Common exit point for this function section
NO_COLLISION           ; Overall exit if fruit was not active initially or no collision
    POP {R0-R10, PC}

;#####################################################################################################################################################################	
CHECK_FRUIT_MISSED
    PUSH {R0, R1, LR}       ; Save R0, R1 and Link Register

    LDR R0, =missed_fruits
    LDRB R0, [R0]           ; R0 = current missed_fruits count
    MOV R1, #MAX_MISSED_FRUITS ; R1 = maximum allowed misses
    CMP R0, R1
    BLT CHECK_FRUIT_MISSED_DONE ; If missed_fruits < MAX_MISSED_FRUITS, continue

    ; If missed_fruits >= MAX_MISSED_FRUITS, game over
    B GAME_OVER_LOSE        ; Branch to game over lose state

CHECK_FRUIT_MISSED_DONE
    POP {R0, R1, PC}        ; Restore registers and return (continue game)

 		
    END