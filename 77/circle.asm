       processor 6502


VSYNC   =  $00
VBLANK  =  $01
WSYNC   =  $02
NUSIZ0  =  $04
NUSIZ1  =  $05
COLUP0  =  $06
COLUP1  =  $07
COLUPF  =  $08
COLUBK  =  $09
CTRLPF  =  $0A
PF0     =  $0D
PF1     =  $0E
PF2     =  $0F
RESM0   =  $12
RESM1   =  $13
ENAMM0  =  $1D
ENAMM1  =  $1E
HMOVE   =  $2a
HMM0    =  $22
HMM1    =  $23
HMCLR   =  $2B
INTIM   =  $284
TIM64T  =  $296

       org $F000
start
       sei
       cld
       ldx #$2B
       txs

       lda #0
clear
       sta 0,X
       dex
       bne clear

       lda #$02
       sta COLUBK
       lda #$0E
       sta COLUPF
       sta COLUP0
       sta COLUP1
       

main
       lda #%10
       sta VSYNC
       sta WSYNC
       sta WSYNC
       sta WSYNC
       lda #44
       sta TIM64T
       lda #0
       sta VSYNC

timer
       lda INTIM
       bne timer

       sta WSYNC
       sta HMOVE
       sta VBLANK ;a=0

       sta HMCLR
       lda #$80
       sta HMM0
       lda #-$0
       sta HMM1
       lda #%110000
       sta NUSIZ0
       sta NUSIZ1
       nop
       nop
       nop
       nop
       nop
       nop
       nop
       sta RESM0
       sta RESM1
       ldy #14
       sta WSYNC
       sta HMOVE
       sta HMCLR
line
       sta WSYNC
       sta HMOVE
       dey
       bne line
       ldx #0
       ldy #0

       lda #%10
       sta ENAMM0
       sta ENAMM1
doline
       sta WSYNC
       sta HMOVE

       lda #%1
       sta CTRLPF
       txa
       cmp inside,Y
       bmi sameinside
       iny
       lda inside,Y
       sta PF1
       iny
       lda inside,Y
       sta PF2
       iny
sameinside

       lda delta,X
       sta HMM1
       eor #$FF
       clc
       adc #$10
       sta HMM0
endline
       inx
       cpx #158
       bne doline

       lda #%00
       sta ENAMM0
       sta ENAMM1
       sta PF2


       ldy #18
after
       sta WSYNC
       sta HMOVE
       dey
       bne after


       sta WSYNC
       lda #%10
       sta VBLANK

       ldx #30
overscan
       sta WSYNC
       dex
       bne overscan
       jmp main

       org $F200
inside
       .byte 2, $00, $C0
       .byte 5, $00, $F0
       .byte 9, $00, $FC
       .byte 16, $00, $FF
       .byte 26, $03, $FF
       .byte 40, $0F, $FF
       .byte 118, $03, $FF
       .byte 132, $00, $FF
       .byte 142, $00, $FC
       .byte 149, $00, $F0
       .byte 153, $00, $C0
       .byte 156, $00, $00
       .byte 158, $00, $00
delta
       .byte $20, $50, $30, $20, $30, $10, $20, $20
       .byte $10, $20, $10, $10, $10, $10, $10, $10
       .byte $10, $10, $10, $10, $10, $00, $10, $10
       .byte $00, $10, $10, $00, $10, $10, $00, $10
       .byte $00, $10, $00, $10, $00, $10, $00, $10
       .byte $00, $00, $10, $00, $00, $10, $00, $00
       .byte $10, $00, $00, $10, $00, $00, $00, $10
       .byte $00, $00, $00, $00, $10, $00, $00, $00
       .byte $00, $00, $10, $00, $00, $00, $00, $00
       .byte $00, $00, $00, $00, $00, $00, $00, $00
       .byte $00, $00, $00, $00, $00, $00, $00, $00
       .byte $00, $00, -$10, $00, $00, $00, $00, $00
       .byte -$10, $00, $00, $00, $00, -$10, $00, $00
       .byte $00, -$10, $00, $00, -$10, $00, $00, -$10
       .byte $00, $00, -$10, $00, $00, -$10, $00, -$10
       .byte $00, -$10, $00, -$10, $00, -$10, $00, -$10
       .byte -$10, $00, -$10, -$10, $00, -$10, -$10, $00
       .byte -$10, -$10, -$10, -$10, -$10, -$10, -$10, -$10
       .byte -$10, -$10, -$10, -$20, -$10, -$20, -$20, -$10
       .byte -$30, -$20, -$30, -$50, -$20

       org $FFFC
       .word start
       .word start
