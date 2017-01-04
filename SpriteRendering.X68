*-----------------------------------------------------------
* Title      : Sprite Rendering
* Written by : Plato Manchi
* Date       :
* Description: Render a part of image specified
* Input      : 256 color pallet bitmap
*-----------------------------------------------------------

* Constants 
OFFSET_TO_DIB_HEADER EQU $E
OFFSET_TO_GET_IMAGE_WIDTH EQU $12
OFFSET_TO_GET_IMAGE_HEIGHT EQU $16

COLOR_TABLE_SIZE EQU 1024

* variables are hiding behind 8 data registers, 7 address registers
* and 1 return address on stack that computes upto 64 byte
* 64(sp) - screen x
* 68(sp) - screen y
* 72(sp) - chunk x
* 76(sp) - chunk y
* 80(sp) - chunk width
* 84(sp) - chunk height
STACK_SCREEN_X EQU 64
STACK_SCREEN_Y EQU 68
STACK_CHUNK_X EQU 72
STACK_CHUNK_Y EQU 76
STACK_CHUNK_WIDTH EQU 80
STACK_CHUNK_HEIGHT EQU 84
STACK_FILE_POINTER  EQU 88
STACK_EOF_POINTER EQU 92



*subroutine to draw sprite
drawSprite
    
    
    movem.l     ALL_REGISTERS,-(sp)   ; saving data and address registers for future use
    
    * Legend of data containing in registers
    * a6 - start of file
    * a5 - start of color table
    * a4 - start of pixel data
    * a0 - end of file pointer
    
    * d7 - width of image
    * d6 - height of image
    * d5 - padding value
    
    move.l      STACK_FILE_POINTER(sp), a6               ; getting the location of sprite file
    move.l      OFFSET_TO_DIB_HEADER(a6), d7    ; getting DIB Header size       
    
    * the value is in little endian format. converting it to big endian
    rol.w       #$8, d7
    swap.w      d7
    rol.w       #$8, d7
    
    move.l      STACK_EOF_POINTER(sp), a0       ; end of bitmap file
        
    * fetching the color palette location
    add.l       a6, d7
    add.l       #OFFSET_TO_DIB_HEADER, d7
    move.l      d7, a5                          ; start of color palette
    
    * this code takes 256 color palette bitmap and each color in pallet is stored as 4 bytes (00 BB GG RR) format
    * so the color table occupy 256 * 4 = 1024 bytes.
    * pixel data starts at a5 + 1024
    move.l      #COLOR_TABLE_SIZE, d0
    
    * fetching start of pixel data
    move.l      a5, a4
    add.l       d0, a4                              ; start of pixel data
    
    move.l      OFFSET_TO_GET_IMAGE_WIDTH(a6), d7   ; contains image width
    * the value is in little endian
    rol.w       #$8, d7
    swap.w      d7
    rol.w       #$8, d7

    move.l      STACK_CHUNK_WIDTH(sp), d6           ; contains chunk width
    
;    clr.l       d5
;    move.l      STACK_CHUNK_X(sp), d0               ; getting chunk x
;    add.l       d6, d0
;    cmp.l       d6, d7
;    bgt         SkipSubstractionPadding ; if the chunk is not border condition padding is not needed
    
    * dividing image width by 4 and getting remainder
    move.l      d7, d5
    divu.w      #$0004, d5
    clr.w       d5
    swap.w      d5
    
    * calculate padding if width is not a multiple of 4
    beq         SkipSubstractionPadding
    move.l      d5, d4
    move.l      #$4, d5
    sub.l       d4, d5
    add.l       d5, d7
SkipSubstractionPadding
    
    
    * pixel(i,j) = (chunk_y + j) * (image_width + padding) + chunk_width + i
    * at this moment d7 has image width and d6 has chunk width
    move.l      STACK_CHUNK_X(sp), d3
    move.l      STACK_CHUNK_Y(sp), d4
      
    * d3 - chunk x
    * d4 - chunk y
    * d5 - padding
    * d6 - chunk width
    * d7 - image width

VerticalLoop
HorizontalLoop
    * formula to calculate the address of the pixel at i,j
    * pixel(i ,j) = (EOF - ((Image_Width + Padding)*(Chunk_Y + j))) + Chunk_X + i
    move.l      d7, d0
;    add.l       d5, d0
    move.l      d4, d1
    add.l       STACK_CHUNK_HEIGHT(sp), d1
    mulu.w      d1, d0
    move.l      a0, a1
    sub.l       d0, a1
    move.l      d3, d1
    add.l       d6, d1
    ;sub.l       STACK_CHUNK_WIDTH(sp), d1
    add.l       d1, a1                      ; calculate the address location of pixel data
    
    clr.l       d2

    move.b      (a1), d2                    ; fetching pixel value from pixel data
    mulu.w      #$4, d2                     ; Since each color takes 4 bytes, multiply index with 4
    move.l      (a5, d2), d1                ; looking up for color in color table and setting it as pen color
    ror.l       #8, d1                      ; color is in aa bb gg rr format
    move.l      #80, d0                     ; trap code to set the pen color to pixel color
    trap        #15
    
    move.l      STACK_SCREEN_X(sp), d1
    add.l       d6, d1                      ; calculating horizontal location on screen to draw pixel
    move.l      STACK_SCREEN_Y(sp), d2
    add.l       STACK_CHUNK_HEIGHT(sp), d2  ; calculating vertical location on screen to draw pixel
    move.l      #82, d0      
    trap        #15                         ; draw pixel at location with pen color on screen

    subi.l      #1, d6                      ; decrementing horizontal loop counter
    bne HorizontalLoop

    move.l      STACK_CHUNK_WIDTH(sp), d6

    subi.l      #1, STACK_CHUNK_HEIGHT(sp)  ; decrementing vertical loop counter
    bne VerticalLoop
    
    movem.l     (sp)+,ALL_REGISTERS         ;loading data and address registers back
    

    
    rts
    













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
