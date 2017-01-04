*-----------------------------------------------------------
* Title      : 16SegmentLED
* Written by : Plato Manchi
* Date       :
* Description:
*-----------------------------------------------------------

    * Put variables and constants here
LED_16_GAP             EQU 2
LED_16_WIDTH           EQU 10
LED_16_HEIGHT          EQU 15
LED_16_LINE_SPACING    EQU 6

STACK_SCREEN_X      EQU 64
STACK_SCREEN_Y      EQU 68
STACK_COLOR         EQU 72
STACK_NUMBER        EQU 76

DigitalAlphabetMaskValue	    dc.l	$F3C0, $FFC0, $CF00, $0F0A, $CFC0, $C3C0, $DF40, $33C0, $CC30, $C430, $0386, $0F00, $330C, $330A, $FF00, $E3C0, $FF02, $E3C2, $DDC0, $C030, $3F00, $0305, $3F10, $000F, $001C, $CC05, $0C00, $0000

*if the constants decleration goes longer it throwing compile time error
* since this is sequential memory, declaring variables in different line will be same as declaring them stright on
* the loop happens from 16 till 1 so adding a 0 at start of all arrays
*-----------------------------------------1---------------------------2------------------------------3---------------------------4-----------------------------5--------------------------------6-------------------
LED_16_POSITION_X1      dc.l    0, LED_16_GAP,                 (LED_16_WIDTH+LED_16_GAP),      (2*LED_16_WIDTH),           (2*LED_16_WIDTH),               (LED_16_WIDTH+LED_16_GAP),      LED_16_GAP                                            
*-------------------------------------------7---------------------------8---------------------------9--------------------------------10---------------------------11----------------------------12----------------------
                        dc.l   0,                          0,                                   LED_16_GAP,                 (LED_16_WIDTH+LED_16_GAP),      LED_16_WIDTH,               LED_16_WIDTH
*----------------------------------------13------------------------14---------------------------------15--------------------------16
                        dc.l   LED_16_GAP,                 (LED_16_WIDTH+LED_16_GAP),      (LED_16_WIDTH+LED_16_GAP),      LED_16_GAP


LED_16_POSITION_Y1      dc.l    0, 0,                          0,                              LED_16_GAP,                 (LED_16_HEIGHT+LED_16_GAP),     (2*LED_16_HEIGHT),              (2*LED_16_HEIGHT)
                        dc.l    (LED_16_HEIGHT+LED_16_GAP),     LED_16_GAP,                 LED_16_HEIGHT,              LED_16_HEIGHT,                  LED_16_GAP,                 (LED_16_HEIGHT+LED_16_GAP)
                        dc.l    LED_16_GAP,                 (LED_16_HEIGHT-LED_16_GAP),     (LED_16_HEIGHT+LED_16_GAP),     ((2*LED_16_HEIGHT)-LED_16_GAP)

LED_16_POSITION_X2      dc.l    0, (LED_16_WIDTH-LED_16_GAP),  ((2*LED_16_WIDTH)-LED_16_GAP),  (2*LED_16_WIDTH),           (2*LED_16_WIDTH),               ((2*LED_16_WIDTH)-LED_16_GAP),  (LED_16_WIDTH-LED_16_GAP)
                        dc.l    0,                              0,                          (LED_16_WIDTH-LED_16_GAP),  ((2*LED_16_WIDTH)-LED_16_GAP),  LED_16_WIDTH,               LED_16_WIDTH
                        dc.l    (LED_16_WIDTH-LED_16_GAP),  ((2*LED_16_WIDTH)-LED_16_GAP),  ((2*LED_16_WIDTH)-LED_16_GAP),  (LED_16_WIDTH-LED_16_GAP)

LED_16_POSITION_Y2      dc.l    0, 0,                          0,                              (LED_16_HEIGHT-LED_16_GAP), ((2*LED_16_HEIGHT)-LED_16_GAP), (2*LED_16_HEIGHT),              (2*LED_16_HEIGHT)
                        dc.l    ((2*LED_16_HEIGHT)-LED_16_GAP), (LED_16_HEIGHT-LED_16_GAP), LED_16_HEIGHT,              LED_16_HEIGHT,                  (LED_16_HEIGHT-LED_16_GAP), ((2*LED_16_HEIGHT)-LED_16_GAP)
                        dc.l    (LED_16_HEIGHT-LED_16_GAP), LED_16_GAP,                     ((2*LED_16_HEIGHT)-LED_16_GAP), (LED_16_HEIGHT+LED_16_GAP)




DrawString

    movem.l     ALL_REGISTERS,-(sp)   ; making sure registers are not trashed
    lea         DigitalAlphabetMaskValue, a0
    lea         LED_16_POSITION_X1, a1
    lea         LED_16_POSITION_Y1, a2
    lea         LED_16_POSITION_X2, a3
    lea         LED_16_POSITION_Y2, a4
    
    move.l      STACK_NUMBER(sp),a6
    jsr         StringLength
    
    subi.l      #1, d4
    ;move.l      STACK_NUMBER(sp),d7
    ;move.l      #1, d4                  ; allows three digit numbers
    
    move.l      STACK_COLOR(sp), d1     ; setting pen color
    move.l      #80, d0
    trap        #15
    
    move.l      #$3, d1         ; setting pen width
    move.l      #93, d0
    trap        #15
    clr.l       d7                      ; clearing d7
    move.l      STACK_NUMBER(sp),a6     ; string length trashes the a6 register, reloading a6
ParseWord
    move.b      (a6, d4), d7
    subi.l      #97, d7
    move.l      d7, d3
    ;divu.w      #26, d3             ; dividing my 26 because there are 26 letters
    ;clr.l       d7
    ;move.w      d3, d7
    ;swap        d3
    ;andi.l      #$0000FFFF, d3       ; removing higher bits to get remainder
    lsl.l       #2, d3
    move.l      (a0, d3), d3

	
    move.l      #16, d6					; loop counter to loop through 16 segments
    

    
.ParseMaskLoop
    lsr.l       #1, d3           ; check if the right most bit is set or not
    bcc.s       .SkipDrawing      ; if carry flag is not set skip drawing
    
    * draw the segment
    move.l      d6, d5
    lsl.l       #2, d5
    
    ;subi.l      #1, d4                      ; counter goes from 1 - nth number so substract 1 to offset
    
    move.l      #LED_16_WIDTH, d1
    lsl.l       #1, d1
    add.l       #LED_16_LINE_SPACING, d1
    mulu.w      d4, d1
    add.l       STACK_SCREEN_X(sp), d1      ; setting x1
    add.l      (a1, d5), d1
    
    move.l      STACK_SCREEN_Y(sp), d2
    add.l      (a2, d5), d2                 ; setting y1
    
    move.l      #86, d0
    trap        #15
    
    move.l      #LED_16_WIDTH, d1
    lsl.l       #1, d1
    add.l       #LED_16_LINE_SPACING, d1
    mulu.w      d4, d1
    add.l       STACK_SCREEN_X(sp), d1      ; setting x2
    add.l      (a3, d5), d1
    
    move.l      STACK_SCREEN_Y(sp), d2
    add.l      (a4, d5), d2                ; setting y2
    
    ;addi.l      #1, d4                      ; returning counter to its original position
    
    move.l      #85, d0
    trap        #15
	
	bra			.SkipDrawing
	
.SkipDrawing
    subi.l      #1, d6
    ;cmp.l       #16, d6
    
    bne         .ParseMaskLoop
.ParseNextLetter
    subi.l      #1, d4
    cmp.l       #0, d4
    bge         ParseWord
    
.returnBack
    movem.l     (sp)+,ALL_REGISTERS         ;loading data and address registers back
    rts












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
