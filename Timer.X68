*-----------------------------------------------------------
* Title      : Timer
* Written by : Plato Manchi
* Date       :
* Description: 
*-----------------------------------------------------------

prevFrameTime       dc.l    0
currentFrameTime    dc.l    0
deltaTime           dc.l    0

InitTimer
    movem.l     d0-d1, -(sp)
    
    move.l      #SYSTEM_TIME, d0
    trap        #15
    
    move.l      d1, prevFrameTime
    
    movem.l     (sp)+, d0-d1
    rts
    

UpdateTimer
    movem.l     d0-d1, -(sp)
    
    move.l      #SYSTEM_TIME, d0
    trap        #15
    
    move.l      d1, currentFrameTime
    sub.l       prevFrameTime, d1
    move.l      d1, deltaTime
    move.l      currentFrameTime, prevFrameTime
    
    movem.l     (sp)+, d0-d1
    rts
*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
