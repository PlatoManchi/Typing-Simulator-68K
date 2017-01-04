*-----------------------------------------------------------
* Title      : 7 Segment LED
* Written by : Plato Manchi
* Date       :
* Description: Draw 7 segment LED at a position on screen
* Input      : D7 contains the numbet to be printed
*-----------------------------------------------------------

* Put variables and constants here
LED_OFFSET          EQU     3
LED_SIZE            EQU     15
LED_LINE_SPACING    EQU     6

STACK_SCREEN_X      EQU     64
STACK_SCREEN_Y      EQU     68
STACK_COLOR         EQU     72
STACK_NUMBER        EQU     76
STACK_LENGTH        EQU     80

DigitalMaskValues	    dc.l	$3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $67

*-----------------------------------a----------------------b-------------------------c---------------------------d----------------------------e----------------------------f----------------------g---------
LED_POSITION_X1         dc.l    LED_OFFSET,             LED_SIZE,               LED_SIZE,                   (LED_SIZE-LED_OFFSET),    0,                            0,                          LED_OFFSET
LED_POSITION_Y1         dc.l    0,                      LED_OFFSET,            (LED_SIZE+LED_OFFSET),       (2*LED_SIZE),             (LED_SIZE+LED_OFFSET),        LED_OFFSET,                 LED_SIZE
LED_POSITION_X2         dc.l    (LED_SIZE-LED_OFFSET),  LED_SIZE,               LED_SIZE,                   LED_OFFSET,               0,                            0,                          (LED_SIZE-LED_OFFSET)
LED_POSITION_Y2         dc.l    0,                     (LED_SIZE-LED_OFFSET),   ((2*LED_SIZE)-LED_OFFSET),  (2*LED_SIZE),             ((2*LED_SIZE)-LED_OFFSET),    (LED_SIZE-LED_OFFSET),      LED_SIZE

    
*    a
*   ---
* f|   | b
*  | g |
*   ---
* e|   | c
*  |   |
*   ---
*    d
DrawDigits

    movem.l     ALL_REGISTERS,-(sp)   ; making sure registers are not trashed
    lea         DigitalMaskValues, a0
    lea         LED_POSITION_X1, a1
    lea         LED_POSITION_Y1, a2
    lea         LED_POSITION_X2, a3
    lea         LED_POSITION_Y2, a4

    move.l      STACK_NUMBER(sp),d7
    move.l      STACK_LENGTH(sp), d4                  ; number of digits to print
    
    move.l      STACK_COLOR(sp), d1     ; setting pen color
    move.l      #80, d0
    trap        #15
    
    move.l      #LED_OFFSET, d1         ; setting pen width
    move.l      #93, d0
    trap        #15
    
ParseNumber    
    move.l      d7, d3
    divu.w      #10, d3
    clr.l       d7
    move.w      d3, d7
    swap        d3
    andi.l      #$0000FFFF, d3       ; removing higher bits to get remainder
    lsl.l       #2, d3
    move.l      (a0, d3), d3
    clr.l       d6
    

    
ParseMaskLoop
    lsr.l       #1, d3           ; check if the right most bit is set or not
    bcc.s       SkipDrawing      ; if carry flag is not set skip drawing
    
    * draw the segment
    move.l      d6, d5
    lsl.l       #2, d5
    
    move.l      #LED_SIZE, d1
    add.l       #LED_LINE_SPACING, d1
    mulu.w      d4, d1
    add.l       STACK_SCREEN_X(sp), d1      ; setting x1
    add.l      (a1, d5), d1
    
    move.l      STACK_SCREEN_Y(sp), d2
    add.l      (a2, d5), d2                 ; setting y1
    
    move.l      #86, d0
    trap        #15
    
    move.l      #LED_SIZE, d1
    add.l       #LED_LINE_SPACING, d1
    mulu.w      d4, d1
    add.l       STACK_SCREEN_X(sp), d1      ; setting x1
    add.l      (a3, d5), d1
    
    move.l      STACK_SCREEN_Y(sp), d2
    add.l      (a4, d5), d2                ; setting y1
    
    move.l      #85, d0
    trap        #15
SkipDrawing
    addi.l      #1, d6
    cmp.l       #8, d6
    
    bne         ParseMaskLoop
    
    subi.l      #1, d4
    bne         ParseNumber
    
    movem.l     (sp)+,ALL_REGISTERS         ;loading data and address registers back
    rts




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
