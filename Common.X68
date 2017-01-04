*-----------------------------------------------------------
* Title      : Common
* Written by : Plato Manchi
* Date       :
* Description: contains global variables and subroutines
*-----------------------------------------------------------

* Registers
ALL_REGISTERS REG D0-D7/A0-A6

* Trap codes
EXIT_SIMULATOR          EQU     9
GET_USER_INPUT_COMMAND  EQU     19
SET_SCREEN_SIZE         EQU     33
PLAY_SOUND              EQU     73
SET_PEN_COLOR           EQU     80
SET_FILL_COLOR          EQU     81
DRAW_RECT               EQU     87
ENABLE_DOUBLE_BUFFER    EQU     92
SWAP_BUFFER             EQU     94

SYSTEM_TIME             EQU     8

* keycode
BACKSPACE_KEYCODE       EQU     $8
ENTER_KEYCODE           EQU     $D
A_KEYCODE               EQU     $41
Z_KEYCODE               EQU     $5A


* fixedpoint math
FRAC_BITS               EQU     6

* gameplay
MAX_WORDS_ON_SCREEN     EQU     20
INITIAL_SPEED           EQU     1
INITIAL_WORD_Y          EQU     60<<FRAC_BITS<<FRAC_BITS
ENDING_WORD_Y           EQU     620<<FRAC_BITS<<FRAC_BITS
STARTING_WORD_X         EQU     300
INITIAL_HEALTH          EQU     10

LEVEL_INDICATOR_X       EQU     67
LEVEL_INDICATOR_Y       EQU     620

* scenes
MAIN_MENU_SCREEN        EQU     0
GAME_SCREEN             EQU     1
GAME_OVER_SCREEN        EQU     2

* main menu
TITLE_BG_X1             EQU     600
TITLE_BG_Y1             EQU     250
TITLE_BG_X2             EQU     1040
TITLE_BG_Y2             EQU     350

TITLE_LABEL_X           EQU     615
TITLE_LABEL_Y           EQU     284

TUTORIAL_TEXT_X         EQU     470
TUTORIAl_TEXT_Y         EQU     500

* GameOver screen
GO_SCORE_BG_X1          EQU     620
GO_SCORE_BG_Y1          EQU     250
GO_SCORE_BG_X2          EQU     1000
GO_SCORE_BG_Y2          EQU     350

GO_SCORE_LABEL_X        EQU     635
GO_SCORE_LABEL_Y        EQU     284

GO_SCORE_NUMBER_X       EQU     900
GO_SCORE_NUMBER_Y       EQU     284

RESTART_LABEL_X         EQU     500
RESTART_LABEL_Y         EQU     500

EXIT_LABEL_X            EQU     580
EXIT_LABEL_Y            EQU     570
* colors
USER_INPUT_COLOR        EQU     $00faf81a
USER_INPUT_ERROR        EQU     $00005eff
USER_INPUT_CORRECT      EQU     $004ccc1d



* Input:    address of string in a6
* Output:   the length of string in d4
StringLength
    clr.l       d4      ; clearing the counter
.LengthLoop
    cmpi.b       #0, (a6)+
    beq         .ReturnBack
    addi.l      #1, d4

    jmp         .LengthLoop

.ReturnBack
    rts


StringCompare
    movem.l     d1-d7/a0-a6, -(sp)
    
    move.l      60(sp), a5
    
    move.l      64(sp), a6
    
    move.l      #1, d0
    move.l      #0, d1
    clr.l       d2
.compareLoop
    move.b      (a6, d1), d2
    cmp.b       (a5, d1), d2
    bne         .notEqual
    
    cmpi.b      #0, d2
    beq         .returnBack    
    
    addi.l      #1, d1
    jmp         .compareLoop
.notEqual
    move.l      #0, d0
    jmp         .returnBack    
    
.returnBack
    
    movem.l     (sp)+, d1-d7/a0-a6
    rts


GetNthWord
    movem.l     d0, -(sp)
    move.l      8(sp), a0       ; getting starting address of word array
    move.l      12(sp), d0       ; getting the n value
    beq         .returnBack     ; if n=0 return the starting address of array
    clr.l       d1
.parsingLoop
    cmpi.b      #0, (a0)+
    bne         .skipIncrementCounter
    addi.l      #1, d1
.skipIncrementCounter
    cmp.l      d0, d1
    bne         .parsingLoop
.returnBack    
    ;sub.l       #2, a0
    movem.l     (sp)+, d0
    rts


RANDOMVAL       ds.l    1
TEMPRANDOMLONG  ds.l    1

seedRandomNumber
        movem.l ALL_REGISTERS,-(sp)
        clr.l   d6
        move.b  #SYSTEM_TIME,d0
        TRAP    #15

        move.l  d1,RANDOMVAL
        movem.l (sp)+,ALL_REGISTERS
        rts

getRandomByteIntoD6
        movem.l d0,-(sp)
        movem.l d1,-(sp)
        movem.l d2,-(sp)
        move.l  RANDOMVAL,d0
       	moveq	#$AF-$100,d1
       	moveq	#18,d2
Ninc0	
	add.l	d0,d0
	bcc	Ninc1
	eor.b	d1,d0
Ninc1
	dbf	d2,Ninc0
	
	move.l	d0,RANDOMVAL
	clr.l	d6
	move.b	d0,d6
	
        movem.l (sp)+,d2
        movem.l (sp)+,d1
        movem.l (sp)+,d0
        rts
        

getRandomLongIntoD6
        movem.l ALL_REGISTERS,-(sp)
        jsr     getRandomByteIntoD6
        move.b  d6,d5
        jsr     getRandomByteIntoD6
        lsl.l   #8,d5
        move.b  d6,d5
        jsr     getRandomByteIntoD6
        lsl.l   #8,d5
        move.b  d6,d5
        jsr     getRandomByteIntoD6
        lsl.l   #8,d5
        move.b  d6,d5
        move.l  d5,TEMPRANDOMLONG
        movem.l (sp)+,ALL_REGISTERS
        move.l  TEMPRANDOMLONG,d6
        rts




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
