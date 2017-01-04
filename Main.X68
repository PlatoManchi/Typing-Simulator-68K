*-----------------------------------------------------------
* Title      : Main
* Written by : Plato Manchi
* Date       :
* Description: Main program
*-----------------------------------------------------------
    ORG    $1000
    

START:                  ; first instruction of program

* Put program code here

    move.b      #SET_SCREEN_SIZE, d0
    move.l      #1600*$10000+900, d1        Set screen to 1600 x 900
    trap        #15

    move.b      #SET_SCREEN_SIZE, d0
    move.l      #2, d1        Set screen to 1600 x 900
    trap        #15

    * enabling double buffer
    move.l      #ENABLE_DOUBLE_BUFFER, d0
    move.l      #17, d1
    trap        #15                     ; calling trap to enable double buffer

    lea         LoadingStr, a0
    move.l      a0, -(sp)     ; number
    move.l      #$00e4f5e8, -(sp)     ; color
    move.l      #430, -(sp)       ; screen y
    move.l      #700, -(sp)       ; screen x
    jsr         DrawString
    add.l       #16, sp          ; deleting data used by subroutine to avoid memory leak
    
    move.l  #SWAP_BUFFER,d0
    trap    #15
    
    * Order in which stack contains information is
    * x - Position on screen (long)
    * y - Position on screen (long)
    * Chunk_X - Position from which image should be drawn
    * Chunk_Y - Position from which image should be drawn
    * Chunk_Width - Width of image part to be drawn
    * Chunk_Height - Height of image part to be drawn
    * EndOfBitmapFile - contains the ending address of bitmap
    * Since stack is first in last out the data has to be pushed in reverse order
    move.l      #EndOfBGSpriteFile, -(sp)
    move.l      #BGSpriteFile, -(sp)
    move.l      #900, -(sp)     ; chunk_height is 128
    move.l      #1600, -(sp)     ; chunk_width is 128
    move.l      #0, -(sp)       ; chunk_y
    move.l      #0, -(sp)       ; chunk_x
    move.l      #0, -(sp)       ; screen y
    move.l      #0, -(sp)       ; screen xprite
    jsr drawSprite              ; calling subroutine to draw s
    add.l      #32, sp          ; deleting data used by subroutine to avoid memory leak
    

    jsr         seedRandomNumber
    
    jsr         InitTimer
    jsr         InitChallengeWords
    jsr         UpdateLevelIndicator
    
    
    *-------- opening sound
    lea         OpeningBG, a1
    move.l      #PLAY_SOUND, d0
    trap        #15
    
GameLoop:

    * process input
    jsr         ProcessInput 
    
    * clear screen
    jsr         ClearComputerScreen
    
    jsr         UpdateUserInput
    * Draw UserInput
    jsr         DrawHealth
    jsr         DrawScore
    jsr         DrawUserInput
    

    
    jsr         UpdateTimer
    
    
    * draw only necessary
    cmp.l       #MAIN_MENU_SCREEN, GameState
    beq         .menuScreen
    
    cmp.l       #GAME_SCREEN, GameState
    beq         .game
    
    cmp.l       #GAME_OVER_SCREEN, GameState
    beq         .gameoverScreen
    
.menuScreen
    jsr         MainMenu
    jmp         .endofscreens
.game
    jsr         DrawChallengeWords
    * updating challenge positions
    jsr         UpdateChallengeLevel
    jsr         UpdateChallengeWords
    
    jmp         .endofscreens
.gameoverScreen
    jsr         GameOverScreen
.endofscreens
    
    * drawing on screen using double buffer
    move.l      #SWAP_BUFFER, d0
    trap        #15
    
    bra         GameLoop
    
    move.b  #EXIT_SIMULATOR,d0
    trap    #15
        
    SIMHALT             ; halt simulator

    * includes
    INCLUDE "Common.X68"
    INCLUDE "7SegmentLED.X68"
    INCLUDE "16SegmentLED.X68"
    INCLUDE "SpriteRendering.X68"
    INCLUDE "WordDictionary.X68"
    INCLUDE "Timer.X68"
    
    * Put variables and constants here
OpeningBG               dc.b    'sounds\bg.wav',0
BlopEffect              dc.b    'sounds\Blop.wav',0
WrongEffect             dc.b    'sounds\ComputerErrorAlert.wav',0
HurtEffect              dc.b    'sounds\hurt.wav',0
    
TitleText               dc.b    'typing|simulator',0
TutorialText            dc.b    'type|start|and|press|enter',0
GameOverText1           dc.b    'type|restart|to|restart',0
GameOverText2           dc.b    'type|exit|to|exit',0
StartText               dc.b    'start',0
ExitText                dc.b    'exit',0
RestartText             dc.b    'restart',0
LoadingStr              dc.b    'loading',0
HAVE_HAD_NO_INPUT       ds.b    1
ClearOffset             ds.b    0
LastKeyPressed          ds.l    1
BGSpriteFile            INCBIN "assets\bg.bmp"
EndOfBGSpriteFile 

LevelIndicator          INCBIN "assets\levelIndicator.bmp"
EndOfLevelIndicator

LevelIndicator_X        dc.l    LEVEL_INDICATOR_X
LevelIndicator_Y        dc.l    LEVEL_INDICATOR_Y

* user input field
UserInputField_X        dc.l    250
UserInputField_Y        dc.l    680
UserInputBG_X1          dc.l    236
UserInputBG_Y1          dc.l    665
UserInputBG_X2          dc.l    800
UserInputBG_Y2          dc.l    725

UserInputTextColor      dc.l    USER_INPUT_COLOR
UserInputEvent          dc.l    0
UserInputWrong          dc.l    0
UserInputElapsed        dc.l    0

* health bar
HealthLabel         dc.b    'health',0
HealthLabel_X       dc.l    814
HealthLabel_Y       dc.l    680
HealthBG_X1         dc.l    800
HealthBG_Y1         dc.l    665
HealthBG_X2         dc.l    1082
HealthBG_Y2         dc.l    725

HealthNumber_X      dc.l    1015
HealthNumber_Y      dc.l    680

HealthCount         dc.l    INITIAL_HEALTH
* score
ScoreLabel          dc.b    'score',0
ScoreLabel_X        dc.l    1096
ScoreLabel_Y        dc.l    680
ScoreBG_X1          dc.l    1082
ScoreBG_Y1          dc.l    665
ScoreBG_X2          dc.l    1362
ScoreBG_Y2          dc.l    725

ScoreNumber_X       dc.l    1270
ScoreNumber_Y       dc.l    680

ScoreCount          dc.l    0


*variables regarding challenge words
ChallengeWord_Acc   dc.l    10
ChallengeWordCount  dc.l    1

ChallengeWord_Draw  ds.l    MAX_WORDS_ON_SCREEN
ChallengeWord_Addr  ds.l    MAX_WORDS_ON_SCREEN
ChallengeWord_Speed ds.l    MAX_WORDS_ON_SCREEN             ; speed has to be pixels per 100th of second
ChallengeWord_X     dS.l    MAX_WORDS_ON_SCREEN             ;400<<FRAC_BITS<<FRAC_BITS
ChallengeWord_Y     ds.l    MAX_WORDS_ON_SCREEN

CanAddNewWord       dc.l        1
CanAddTimeElapsed   dc.l        0

GameState           dc.l        MAIN_MENU_SCREEN

TutorialElapsed     dc.l        0
IsAnimating         dc.l        1
AnimationTimer      dc.l        0



UpdateLevelIndicator
    movem.l     d0-d1, -(sp)
    
    * redrawing the previous region of level indicator to aviod trail
    move.l      #EndOfBGSpriteFile, -(sp)
    move.l      #BGSpriteFile, -(sp)
    move.l      #48, -(sp)     ; chunk_height is 128
    move.l      #48, -(sp)     ; chunk_width is 128
    move.l      LevelIndicator_Y, -(sp)       ; chunk_y
    move.l      LevelIndicator_X, -(sp)       ; chunk_x
    move.l      LevelIndicator_Y, -(sp)       ; screen y
    move.l      LevelIndicator_X, -(sp)       ; screen x
    jsr drawSprite              ; calling subroutine to draw s
    add.l      #32, sp          ; deleting data used by subroutine to avoid memory leak
    
    move.l      #LEVEL_INDICATOR_Y, d0
    move.l      ScoreCount, d1
    lsr.l       #1, d1
    sub.l       d1, d0
    move.l      d0, LevelIndicator_Y
    
    move.l      #EndOfLevelIndicator, -(sp)
    move.l      #LevelIndicator, -(sp)
    move.l      #47, -(sp)     ; chunk_height
    move.l      #48, -(sp)     ; chunk_width
    move.l      #0, -(sp)       ; chunk_y
    move.l      #0, -(sp)       ; chunk_x
    move.l      d0, -(sp)       ; screen y
    move.l      LevelIndicator_X, -(sp)       ; screen x
    jsr drawSprite              ; calling subroutine to draw s
    add.l      #32, sp          ; deleting data used by subroutine to avoid memory leak
    
    movem.l     (sp)+, d0-d1
    rts



ClearComputerScreen
    movem.l      d0-d4, -(sp)               ; saving registers that are being used in the subroutine
    
    move.l      #$00362a00, d1
    move.l      #SET_PEN_COLOR, d0          ; setting pen color
    trap        #15
    move.l      #SET_FILL_COLOR, d0         ; setting fill color
    trap        #15
    
    * draw rectangle
    move.l      #DRAW_RECT, d0
    move.l      #236, d1
    move.l      #55, d2
    move.l      #1362, d3
    move.l      #725, d4
    trap        #15
    
    movem.l     (sp)+, d0-d4
    rts
    


MainMenu
    movem.l     d0-d7, -(sp)
    
    move.l      deltaTime, d7
        
    move.l      #$00c9dad1, d1
    move.l      #SET_PEN_COLOR, d0         ; setting pen color
    trap        #15
    move.l      #SET_FILL_COLOR, d0         ; setting fill color
    trap        #15
    
    cmp.l       #1, IsAnimating
    bne         .notAnimating
    
    add.l       AnimationTimer, d7
    move.l      d7, AnimationTimer
    
    move.l      #DRAW_RECT, d0
    move.l      #TITLE_BG_X1, d1
    move.l      #TITLE_BG_X2, d3
    
    move.l      d7, d6
    lsr.l       #1, d6
    
    move.l      #TITLE_BG_Y1, d5
    add.l       #TITLE_BG_Y2, d5
    
    lsr.l       #1, d5
    
    move.l      d5, d2
    sub.l       d6, d2
    
    cmp.l       #TITLE_BG_Y1, d2
    bgt         .y1notborder
    
    move.l      #TITLE_BG_Y1, d2
    move.l      #0, IsAnimating
.y1notborder
    
    move.l      d5, d4
    add.l       d6, d4
    
    cmp.l       #TITLE_BG_Y2, d4
    blt         .y2notborder
    
    move.l      #TITLE_BG_Y2, d4
    move.l      #0, IsAnimating
.y2notborder
    trap        #15
        
    jmp         .returnBack
.notAnimating
    add.l       d7, TutorialElapsed
    
    * draw rectangle
    move.l      #DRAW_RECT, d0
    move.l      #TITLE_BG_X1, d1
    move.l      #TITLE_BG_Y1, d2
    move.l      #TITLE_BG_X2, d3
    move.l      #TITLE_BG_Y2, d4
    trap        #15
    
    *TitleText
    lea         TitleText, a0
    move.l      a0, -(sp)     ; string
    move.l      #$00362a00, -(sp)
    move.l      #TITLE_LABEL_Y, -(sp)       ; screen y
    move.l      #TITLE_LABEL_X, -(sp)       ; screen x
    jsr         DrawString
    add.l       #16, sp                 ; deleting data used by subroutine to avoid memory leak

    
    cmp.l       #120, TutorialElapsed
    bgt         .skipDrawing
    
    lea         TutorialText, a0
    move.l      a0, -(sp)     ; string
    move.l      #$00e4f5e8, -(sp)
    move.l      #TUTORIAL_TEXT_Y, -(sp)       ; screen y
    move.l      #TUTORIAL_TEXT_X, -(sp)       ; screen x
    jsr         DrawString
    add.l       #16, sp                 ; deleting data used by subroutine to avoid memory leak

.skipDrawing
    cmp.l       #150, TutorialElapsed
    blt         .returnBack
    move.l      #0, TutorialElapsed
    
.returnBack
    movem.l     (sp)+, d0-d7
    rts



GameOverScreen
    movem.l     d0-d7/a0-a6, -(sp)
    
    move.l      deltaTime, d7
    move.l      #$00c9dad1, d1
    move.l      #SET_PEN_COLOR, d0         ; setting pen color
    trap        #15
    move.l      #SET_FILL_COLOR, d0         ; setting fill color
    trap        #15
    
    cmp.l       #1, IsAnimating
    bne         .notAnimating
    
    add.l       AnimationTimer, d7
    move.l      d7, AnimationTimer
    
    move.l      #DRAW_RECT, d0
    move.l      #GO_SCORE_BG_X1, d1
    move.l      #GO_SCORE_BG_X2, d3
    
    move.l      d7, d6
    lsr.l       #1, d6
    
    move.l      #GO_SCORE_BG_Y1, d5
    add.l       #GO_SCORE_BG_Y2, d5
    
    lsr.l       #1, d5
    
    move.l      d5, d2
    sub.l       d6, d2
    
    cmp.l       #GO_SCORE_BG_Y1, d2
    bgt         .y1notborder
    
    move.l      #GO_SCORE_BG_Y1, d2
    move.l      #0, IsAnimating
.y1notborder
    
    move.l      d5, d4
    add.l       d6, d4
    
    cmp.l       #GO_SCORE_BG_Y2, d4
    blt         .y2notborder
    
    move.l      #GO_SCORE_BG_Y2, d4
    move.l      #0, IsAnimating
.y2notborder
    trap        #15
        
    jmp         .returnBack
.notAnimating
    add.l       d7, TutorialElapsed
    
    move.l      #$00c9dad1, d1
    move.l      #SET_PEN_COLOR, d0         ; setting pen color
    trap        #15
    move.l      #SET_FILL_COLOR, d0         ; setting fill color
    trap        #15
    
    * draw rectangle
    move.l      #DRAW_RECT, d0
    move.l      #GO_SCORE_BG_X1, d1
    move.l      #GO_SCORE_BG_Y1, d2
    move.l      #GO_SCORE_BG_X2, d3
    move.l      #GO_SCORE_BG_Y2, d4
    trap        #15

    *---- finished drawing bg for input field
    
    lea         ScoreLabel, a0
    move.l      a0, -(sp)     ; string
;    move.l      #$004ccc1d, -(sp)     ; color
    move.l      #$00362a00, -(sp)
    move.l      #GO_SCORE_LABEL_Y, -(sp)       ; screen y
    move.l      #GO_SCORE_LABEL_X, -(sp)       ; screen x
    jsr         DrawString
    add.l       #16, sp                 ; deleting data used by subroutine to avoid memory leak
    
    
    * Order in which stack contains information is
    * x - Position on screen (long)
    * y - Position on screen (long)
    * color - color of the digit
    * number - number to be drawn
    * Since stack is first in last out the data has to be pushed in reverse order
    move.l      #3, -(sp)
    move.l      ScoreCount, -(sp)     ; number
    move.l      #$00362a00, -(sp)     ; color
    move.l      #GO_SCORE_NUMBER_Y, -(sp)       ; screen y
    move.l      #GO_SCORE_NUMBER_X, -(sp)       ; screen x
    jsr         DrawDigits
    add.l       #20, sp          ; deleting data used by subroutine to avoid memory leak

    cmp.l       #120, TutorialElapsed
    bgt         .skipDrawing
    
    lea         GameOverText1, a0
    move.l      a0, -(sp)     ; string
    move.l      #$00e4f5e8, -(sp)
    move.l      #RESTART_LABEL_Y, -(sp)       ; screen y
    move.l      #RESTART_LABEL_X, -(sp)       ; screen x
    jsr         DrawString
    add.l       #16, sp                 ; deleting data used by subroutine to avoid memory leak
    
    lea         GameOverText2, a0
    move.l      a0, -(sp)     ; string
    move.l      #$00e4f5e8, -(sp)
    move.l      #EXIT_LABEL_Y, -(sp)       ; screen y
    move.l      #EXIT_LABEL_X, -(sp)       ; screen x
    jsr         DrawString
    add.l       #16, sp                 ; deleting data used by subroutine to avoid memory leak
    
.skipDrawing
    cmp.l       #150, TutorialElapsed
    blt         .returnBack
    move.l      #0, TutorialElapsed
    
.returnBack
    movem.l     (sp)+, d0-d7/a0-a6
    rts



RestartGame
    jsr         InitChallengeWords
    move.l      #GAME_SCREEN, GameState
    move.l      #INITIAL_HEALTH, HealthCount
    move.l      #0, ScoreCount
    jsr         UpdateLevelIndicator
    rts



UpdateChallengeLevel
    movem.l     d0-d7/a0-a6, -(sp)

    lea         ChallengeWord_Draw, a0
    
    move.l      deltaTime, d7
    add.l       d7, CanAddTimeElapsed

    cmp.l       #70, CanAddTimeElapsed
    blt         .returnBack

    move.l      #0, CanAddTimeElapsed

    clr.l       d0                          ; counter    
    clr.l       d6                          ; number of words on screen

.parsingLoop
    move.l      d0, d1
    lsl.l       #2, d1
    move.l      (a0, d1), d2
    beq         .skipIncr
    add.l       #1, d6

.skipIncr
    add.l       #1, d0
    cmp.l       ChallengeWordCount, d0
    blt         .parsingLoop

    * d6 contains the count of words displayed on screen
    cmp.l       ChallengeWordCount, d6
    bgt         .returnBack

    clr.l       d0                          ; counter    
.parseLoop2
    move.l      d0, d1
    lsl.l       #2, d1
    move.l      (a0, d1), d2
    bne         .skipIncr2
    move.l      #1, (a0, d1)            ; setting the d1 to be visible
    jmp         .returnBack
.skipIncr2
    add.l       #1, d0
    cmp.l       ChallengeWordCount, d0
    blt         .parseLoop2



.returnBack
    movem.l     (sp)+, d0-d7/a0-a6
    rts



InitChallengeWords
    movem.l     d0-d7/a0-a6, -(sp)
    
    lea         ChallengeWord_Addr, a1
    lea         ChallengeWord_Speed, a2
    lea         ChallengeWord_X, a3
    lea         ChallengeWord_Y, a4
    lea         ChallengeWord_Draw, a5
    
    move.l      #MAX_WORDS_ON_SCREEN, d0                 ; loop counter
   
.parsingLoop
    move.l      d0, d1
    subi.l      #1, d1                  ; if value is 20 get 19th word
    clr.l	    d6
    jsr         getRandomByteIntoD6
    move.l      d6, -(sp)
    move.l      #WORD_DICTIONARY, -(sp)
    jsr         GetNthWord
    add.l       #8, sp
    
    * a0 will have the address of nth word
    move.l      d0, d1
    subi.l      #1, d1                  ; if value is 20 get 19th word
    lsl.l       #2, d1
    move.l      a0, (a1, d1)
    move.l      #INITIAL_SPEED, (a2, d1)

    clr.l	    d6
    jsr         getRandomByteIntoD6
    lsl.l       #1, d6
    addi.l      #STARTING_WORD_X, d6
    
    * converting it to fixed point
    lsl.l       #FRAC_BITS, d6
    lsl.l       #FRAC_BITS, d6
    
    move.l      d6, (a3, d1)
    move.l      #INITIAL_WORD_Y, (a4, d1)
    
    move.l      #0, (a5, d1)
    
    * looping condition
    subi.l      #1, d0
    bne         .parsingLoop
    
    movem.l     (sp)+, d0-d7/a0-a6
    rts







DrawChallengeWords
    movem.l     d0-d2/a0-a2, -(sp)
    
    lea         ChallengeWord_Addr, a0
    lea         ChallengeWord_X, a1
    lea         ChallengeWord_Y, a2
    lea         ChallengeWord_Draw, a3
    
    move.l      ChallengeWordCount, d1          ; loop counter
    
.parsingLoop
    move.l      d1, d2
    subi.l      #1, d2
    lsl.l       #2, d2
    
    move.l      (a3, d2), d0
    beq         .skipIteration
    
    move.l      (a0, d2), -(sp)                    ; string
    move.l      #$00908335, -(sp)
    
    move.l      (a2, d2), d0
    lsr.l       #FRAC_BITS, d0
    lsr.l       #FRAC_BITS, d0
    move.l      d0, -(sp)                   ; screen y
    
    move.l      (a1, d2), d0
    lsr.l       #FRAC_BITS, d0
    lsr.l       #FRAC_BITS, d0
    move.l      d0, -(sp)                   ; screen x
    
    jsr         DrawString
    add.l       #16, sp                     ; deleting data used by subroutine to avoid memory leak

.skipIteration
    * loop conditions
    subi.l      #1, d1
    bne         .parsingLoop
    
    movem.l     (sp)+, d0-d2/a0-a2
    rts






UpdateChallengeWords
    movem.l     d0-d5/a0-a1, -(sp)
    
    lea         ChallengeWord_Speed, a0
    lea         ChallengeWord_Y, a1
    lea         ChallengeWord_Draw, a3
    
    move.l      ChallengeWordCount, d4          ; loop counter
.parsingLoop
    move.l      d4, d5
    subi.l      #1, d5
    lsl.l       #2, d5
    
    move.l      (a3, d5), d0
    beq         .skipReset
    
    move.l      (a1, d5), d0
    move.l      (a0, d5), d1
    move.l      deltaTime, d2
    
    * v = u + a * t
    move.l      ChallengeWord_Acc, d3
    mulu        d2, d3
    add.l       d3, d1
    
    move.l      d1, (a0, d5)     ; saving the final velocity

    * s = u*t + 0.5*a*t*t
    mulu        d2, d1
    move.l      ChallengeWord_Acc, d3
    mulu        d2, d2
    mulu        d3, d2
    lsr.l       #1, d2                  ; 0.5 *( a*t*t )
    
    add.l       d2, d1
    
    * adding delta distance to the y
    add.l       d1, d0
    move.l      d0, (a1, d5)
    
    cmpi.l      #ENDING_WORD_Y, d0
    blt         .skipReset
    
    lea         HurtEffect, a1
    move.l      #PLAY_SOUND, d0
    trap        #15
    
    move.l      d5, -(sp)
    jsr         ResetWord
    add.l       #4, sp
    sub.l       #1, HealthCount
    bne         .returnBack
    * if health is 0 
    move.l      #1, IsAnimating
    move.l      #0, AnimationTimer

    move.l      #GAME_OVER_SCREEN, GameState
    
    lea         OpeningBG, a1
    move.l      #PLAY_SOUND, d0
    trap        #15
.skipReset
    * looping condition
    subi.l      #1, d4
    bne         .parsingLoop
.returnBack
    movem.l     (sp)+, d0-d5/a0-a1
    rts






ResetWord
    movem.l     d0-d7/a0-a6, -(sp)
    
    move.l      64(sp), d0       ; index

    lea         ChallengeWord_X, a0    
    lea         ChallengeWord_Y, a1
    lea         ChallengeWord_Speed, a2
    lea         ChallengeWord_Addr, a3
    lea         ChallengeWord_Draw, a4
    
    * resetting position    
    move.l      #INITIAL_WORD_Y, (a1, d0)
    clr.l	    d6
    jsr         getRandomByteIntoD6
    lsl.l       #1, d6
    add.l       #STARTING_WORD_X, d6
    * converting it to fixed point
    lsl.l       #FRAC_BITS, d6
    lsl.l       #FRAC_BITS, d6
    move.l      d6, (a0, d0)

    * resetting velocity
    move.l      #INITIAL_SPEED, (a2, d0)
    
    * getting random word
    clr.l	    d6
    jsr         getRandomByteIntoD6
    move.l      d6, -(sp)
    move.l      #WORD_DICTIONARY, -(sp)
    jsr         GetNthWord
    add.l       #8, sp
    
    * a0 will have the address of nth word
    move.l      64(sp), d0       ; index
    move.l      a0, (a3, d0)
    
    * setting draw as false
    move.l      #0, (a4, d0)
    
    movem.l     (sp)+, d0-d7/a0-a6
    rts
    
    
    
    
    
    
UpdateUserInput
    movem.l     d0/a0, -(sp)
    
    cmpi.l      #0, UserInputEvent
    beq         .noEvent

    cmpi.l      #1, UserInputWrong
    beq         .noError
    move.l      #USER_INPUT_ERROR, d0
    move.l      d0, UserInputTextColor
    jmp         .skipNoError    
.noError
    move.l      #USER_INPUT_CORRECT, d0
    move.l      d0, UserInputTextColor

.skipNoError
    move.l      deltaTime, d0
    add.l       d0, UserInputElapsed
    cmp.l       #20, UserInputElapsed
    bgt         .clearEvent
    jmp         .returnBack
    
.clearEvent
    move.l      #0, UserInputEvent
    lea         InputUserField, a0
    move.w      #$7B00, (a0)
.noEvent
    move.l      #USER_INPUT_COLOR, d0
    move.l      d0, UserInputTextColor
    move.l      #0, UserInputWrong

.returnBack
    movem.l     (sp)+, d0/a0
    rts
    
   


 
    
DrawUserInput
    movem.l      d0-d4, -(sp)     ; saving registers that are being used in the subroutine

    move.l      #$00525756, d1
    ;move.l      #$0036332e, d1
    move.l      #SET_PEN_COLOR, d0         ; setting pen color
    trap        #15
    move.l      #SET_FILL_COLOR, d0         ; setting fill color
    trap        #15
    
    * draw rectangle
    move.l      #DRAW_RECT, d0
    move.l      UserInputBG_X1, d1
    move.l      UserInputBG_Y1, d2
    move.l      UserInputBG_X2, d3
    move.l      UserInputBG_Y2, d4
    trap        #15

    *---- finished drawing bg for input field
    
    lea         InputUserField, a0
    move.l      a0, -(sp)     ; number
;    move.l      #$004ccc1d, -(sp)     ; color
    move.l      UserInputTextColor, -(sp)
    move.l      UserInputField_Y, -(sp)       ; screen y
    move.l      UserInputField_X, -(sp)       ; screen x
    jsr         DrawString
    add.l       #16, sp          ; deleting data used by subroutine to avoid memory leak
    
    movem.l     (sp)+, d0-d4
    rts





DrawHealth
    movem.l      d0-d4, -(sp)     ; saving registers that are being used in the subroutine

    ;move.l      #$00029a51, d1
    move.l      #$00005eff, d1
    move.l      #SET_PEN_COLOR, d0         ; setting pen color
    trap        #15
    move.l      #SET_FILL_COLOR, d0         ; setting fill color
    trap        #15
    
    * draw rectangle
    move.l      #DRAW_RECT, d0
    move.l      HealthBG_X1, d1
    move.l      HealthBG_Y1, d2
    move.l      HealthBG_X2, d3
    move.l      HealthBG_Y2, d4
    trap        #15

    *---- finished drawing bg for input field
    cmp.l       #GAME_SCREEN, GameState
    bne         .returnBack
    
    lea         HealthLabel, a0
    move.l      a0, -(sp)     ; number
;    move.l      #$00014c19, -(sp)     ; color
    move.l      #$00b2e4ff, -(sp)
    move.l      HealthLabel_Y, -(sp)       ; screen y
    move.l      HealthLabel_X, -(sp)       ; screen x
    jsr         DrawString
    add.l       #16, sp          ; deleting data used by subroutine to avoid memory leak
    
    
    * Order in which stack contains information is
    * x - Position on screen (long)
    * y - Position on screen (long)
    * color - color of the digit
    * number - number to be drawn
    * Since stack is first in last out the data has to be pushed in reverse order
    move.l      #2, -(sp)
    move.l      HealthCount, -(sp)     ; number
    ;move.l      #$00014c19, -(sp)     ; color
    move.l      #$00b2e4ff, -(sp)     ; color
    move.l      HealthNumber_Y, -(sp)       ; screen y
    move.l      HealthNumber_X, -(sp)       ; screen x
    jsr         DrawDigits
    add.l       #20, sp          ; deleting data used by subroutine to avoid memory leak
    
.returnBack
    movem.l     (sp)+, d0-d4
    rts






DrawScore
    movem.l      d0-d4, -(sp)     ; saving registers that are being used in the subroutine

    move.l      #$009d9807, d1
    move.l      #SET_PEN_COLOR, d0         ; setting pen color
    trap        #15
    move.l      #SET_FILL_COLOR, d0         ; setting fill color
    trap        #15
    
    * draw rectangle
    move.l      #DRAW_RECT, d0
    move.l      ScoreBG_X1, d1
    move.l      ScoreBG_Y1, d2
    move.l      ScoreBG_X2, d3
    move.l      ScoreBG_Y2, d4
    trap        #15

    *---- finished drawing bg for input field
    cmp.l       #GAME_SCREEN, GameState
    bne         .returnBack
    
    lea         ScoreLabel, a0
    move.l      a0, -(sp)     ; string
;    move.l      #$004ccc1d, -(sp)     ; color
    move.l      #$004c4100, -(sp)
    move.l      ScoreLabel_Y, -(sp)       ; screen y
    move.l      ScoreLabel_X, -(sp)       ; screen x
    jsr         DrawString
    add.l       #16, sp                 ; deleting data used by subroutine to avoid memory leak
    
    
    * Order in which stack contains information is
    * x - Position on screen (long)
    * y - Position on screen (long)
    * color - color of the digit
    * number - number to be drawn
    * Since stack is first in last out the data has to be pushed in reverse order
    move.l      #3, -(sp)
    move.l      ScoreCount, -(sp)     ; number
    move.l      #$004c4100, -(sp)     ; color
    move.l      ScoreNumber_Y, -(sp)       ; screen y
    move.l      ScoreNumber_X, -(sp)       ; screen x
    jsr         DrawDigits
    add.l       #20, sp          ; deleting data used by subroutine to avoid memory leak

.returnBack
    movem.l     (sp)+, d0-d4
    rts







    * Subroutines
ProcessInput
    movem.l     d0-d1, -(sp)     ; saving registers that are being used in the subroutine
    cmpi.l      #1, UserInputEvent
    beq         .noInput
    
    clr.l       d1
    move.b      #GET_USER_INPUT_COMMAND, d0
    trap        #15
    andi.l      #$FF, d1                        ; gets the last pressed key
    
    * check if last key pressed and current key pressed are different
    * when keys are pressed fast, next key is pressed before the previous key
    * is released. so check if the previous key pressed is not same ans current
    * key pressed then process the input
    cmp.l       LastKeyPressed, d1
    beq         .dontProcess
    move.b      #1, HAVE_HAD_NO_INPUT
.dontProcess
    move.l      d1, LastKeyPressed              ; saving last pressed key
    
    * check if the last pressed key is still being pressed
    move.b      #GET_USER_INPUT_COMMAND, d0
    trap        #15
    andi.l      #$FF, d1
    beq         .noInput
    
    * if last pressed key is still being pressed
    move.l      LastKeyPressed, d1
    
    move.b      HAVE_HAD_NO_INPUT, d0
    beq         .skipNoInput
    move.b      #0, HAVE_HAD_NO_INPUT
        
    cmp.l       #BACKSPACE_KEYCODE, d1
    beq         .backspaceInput

    cmp.l       #ENTER_KEYCODE, d1
    beq         .enterInput

    * checking if input is in range of a-z
    cmp.l       #A_KEYCODE, d1
    blt         .skipNoInput
    
    cmp.l       #Z_KEYCODE, d1
    bgt         .skipNoInput
    
    * if >= a && <= z keycode is alhpabet
    bra         .alphabetInput
    
.backspaceInput
    jsr         BackspacePressed
    bra         .skipNoInput

.enterInput
    jsr         EnterPressed
    bra         .skipNoInput
    
.alphabetInput
    jsr         AlphabetPressed
    bra         .skipNoInput
    
.noInput
    move.b      #1, HAVE_HAD_NO_INPUT
.skipNoInput

    movem.l      (sp)+, d0-d1           ; reloading registers
    rts
    
    
    
    
    
    
    
AlphabetPressed
    * calling string length to know the length of user input string
    * so that the letter entered can be added at the end of the string
    
    * StringLength takes a6 and d4 as inputs so saving the registers
    * before calling the function
    move.l          a6, -(sp)
    move.l          d4, -(sp)

    lea             InputUserField, a6
    jsr             StringLength
    
    cmpi.l          #21, d4
    beq             .returnBack             ; limiting the input to 20 characters
    
    lea             InputUserField, a6      ; StringLength will trash the a6 register so reinitializing a6
    
    move.l          LastKeyPressed, d1
    * ascii value of a is 97 but keycode is 65 so adding 32 to convert keycode to ascii
    addi.l          #32, d1
    
    subi.l          #1, d4                  ; last letter will be '_' so substract length by 1
    move.b          d1, (a6, d4)
    addi.l          #1, d4
    move.b          #$7B, (a6, d4)            ; adding a '_' at end of the string
    addi.l          #1, d4
    move.b          #$0, (a6, d4)
    
.returnBack
    * restoring the registers back
    move.l         (sp)+, d4
    move.l         (sp)+, a6
    rts
   






StartGame
    move.l      #GAME_SCREEN, GameState
    rts





ExitGame
    move.l      #EXIT_SIMULATOR, d0
    trap        #15
    rts





 
EnterPressed
    movem.l     d0-d7/a0-a6, -(sp)
    
    move.l      #1, UserInputEvent
    move.l      #0, UserInputElapsed
    
    cmp.l       #GAME_SCREEN, GameState
    beq         .gameInput
    *------- if not game input 
    *StartText
    
    * removing the trailing '_' from user input field
    lea         InputUserField, a6
    jsr         StringLength
    lea         InputUserField, a6
    subi.l      #1, d4    
    move.b      #$0, (a6, d4)
    
    
    *----------- start
    lea         StartText, a5
    move.l      a6, -(sp)     ; string
    move.l      a5, -(sp)
    jsr         StringCompare
    add.l       #8, sp    
    * if d0 == 1 equal string
    move.l      d0, UserInputWrong
    cmpi.l      #1, d0
    bne         .checkExit
    jsr         StartGame
    jmp         .skipCmd

.checkExit
    *----------- exit
    lea         ExitText, a5
    move.l      a6, -(sp)     ; string
    move.l      a5, -(sp)
    jsr         StringCompare
    add.l       #8, sp
    * if d0 == 1 equal string
    move.l      d0, UserInputWrong
    cmpi.l      #1, d0
    bne         .checkRestart
    jsr         ExitGame
    jmp         .skipCmd

.checkRestart
    *----------- RestartGame
    lea         RestartText, a5
    move.l      a6, -(sp)     ; string
    move.l      a5, -(sp)
    jsr         StringCompare
    add.l       #8, sp
    * if d0 == 1 equal string
    move.l      d0, UserInputWrong
    cmpi.l      #1, d0
    bne         .skipCmd
    jsr         RestartGame
;    jmp         .skipCmd

.skipCmd
    * adding the trailing '_' to user input field    
    move.l      #InputUserField, a6
    jsr         StringLength
    move.l      #InputUserField, a6

    move.b      #$7B, (a6, d4)            ; adding a '_' at end of the string
    addi.l      #1, d4
    move.b      #$0, (a6, d4)
    
    jmp         .exitLoop
.gameInput
    move.l      ChallengeWordCount, d1          ; loop counter
    lea         ChallengeWord_Addr, a0
    lea         ChallengeWord_Draw, a1
    
.parsingLoop
    move.l      d1, d2
    subi.l      #1, d2
    lsl.l       #2, d2
    
    * check only if the word is being shown on the screen
    move.l      (a1, d2), d0
    beq         .skipIteration
    
    lea         InputUserField, a6
    * removing the trailing '_' from user input field
    jsr         StringLength
    lea         InputUserField, a6
    subi.l      #1, d4    
    move.b      #$0, (a6, d4)

    
    move.l      a6, -(sp)     ; string
    move.l      (a0, d2), -(sp)
    jsr         StringCompare
    add.l       #8, sp
    
    * adding the trailing '_' to user input field    
    move.l      #InputUserField, a6
    jsr         StringLength
    move.l      #InputUserField, a6

    move.b      #$7B, (a6, d4)            ; adding a '_' at end of the string
    addi.l      #1, d4
    move.b      #$0, (a6, d4)
    
    * if d0 == 1 equal string
    move.l      d0, UserInputWrong
    cmpi.l      #1, d0
    beq         .correctWord
    
.skipIteration
    * looping condition
    subi.l      #1, d1
    bne         .parsingLoop
    
    lea         WrongEffect, a1
    move.l      #PLAY_SOUND, d0
    trap        #15
    
    jmp         .exitLoop

.correctWord
    move.l      d2, -(sp)
    jsr         ResetWord
    add.l       #4, sp
    
    move.l      ScoreCount, d0
    add.l       #10, d0
    move.l      d0, ScoreCount
    
    divu        #50, d0
    and.l       #$0000FFFF, d0
    add.l       #1, d0
    move.l      d0, ChallengeWordCount
    
    lea         BlopEffect, a1
    move.l      #PLAY_SOUND, d0
    trap        #15
    
    jsr         UpdateLevelIndicator
.exitLoop
    movem.l     (sp)+, d0-d7/a0-a6
    rts







BackspacePressed
    move.l          a6, -(sp)
    move.l          d4, -(sp)
    
    lea             InputUserField, a6
    jsr             StringLength
    
    cmpi.l          #1, d4                  ; if length of string is 1 it means there is no data in the string
    beq             .skipSubroutine
    
    lea             InputUserField, a6      ; StringLength will trash the a6 register so reinitializing a6

    subi.l          #1, d4    
    move.b          #$0, (a6, d4)
    subi.l          #1, d4
    move.b          #$7B, (a6, d4)
    
.skipSubroutine
    move.l         (sp)+, d4
    move.l         (sp)+, a6
    rts
    
    
    
    
    
    
    * since this is a variable with dynamic memory size, its declared at end of program
InputUserField      dc.b        $7B,0
    END    START        ; last line of source




























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
