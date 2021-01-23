PRODUCTION  set 1                           ; set to 0 for GENS compatibility (for debugging) and 1 when ready
CHEAT       set 1                           ; set to 1 for cheat enabled
DEBUG_MENU  set 0                           ; set to 1 for debug menu enabled

; I/O
HW_version      EQU $A10001                 ; hardware version in low nibble
                                            ; bit 6 is PAL (50Hz) if set, NTSC (60Hz) if clear
                                            ; region flags in bits 7 and 6:
                                            ;         USA NTSC = $80
                                            ;         Asia PAL = $C0
                                            ;         Japan NTSC = $00
                                            ;         Europe PAL = $C0
                                            
; MSU-MD vars
MCD_STAT        EQU $A12020                 ; 0-ready, 1-init, 2-cmd busy
MCD_CMD         EQU $A12010 
MCD_ARG         EQU $A12011
MCD_CMD_CK      EQU $A1201F

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        org $4
        dc.l    ENTRY_POINT                     ; custom entry point for redirecting
        
        org     $100
        dc.b    'SEGA MEGASD     '              ; needed for MegaSD and Emulators
        org     $120
        dc.b    'THE SUPER SHINOBI MSU-MD                        '
        org     $150
        dc.b    'THE REVENGE SHINOBI MSU-MD                      '
        org     $190
        dc.b    'JUE'

        org     $1A4                            ; ROM_END
        dc.l    $000FFFFF                       ; Overwrite with 8 MBIT size

        org     $206
Game

        org     $27E
        jsr     msuSega

        org     $78ED6                          ; mute music by aborting PlayMusic function
        rts
        
        org     $78FAE                          ; StopAllSound function
        ;jsr     msuHijack_StopAllSound
        ;nop

        
        org     $9484
        jmp     msuHijack_SoundTest

        org     $948A
retFromHijack

        org     $9494
sub_9494
        
        org     $9682
        jsr     play_track_19                   ; Opening
        org     $A11C
        jsr     play_track_14                   ; Failure
        org     $A40C
        jsr     play_track_13                   ; Long Distance (story)
        org     $A5D2
        jsr     play_track_3                    ; Round Clear
        org     $A96E
        jsr     play_track_17                   ; Game Over


        org     $CBD8
        jsr     msuHijack_Levels

        org     $79088
        jsr     msuHijack_Fade
        nop

; CHEAT ----------------------------------------------------------------------
        if CHEAT
        org     $3E2E4
        dc.w    $600C                           ; unl. energy
        org     $3E38A
        dc.w    $600A                           ; unl. shuriken
        endif
; CHEAT ----------------------------------------------------------------------


        org     $80000
MSUDRV
        incbin  "msu-drv.bin"        
        align   2

msuHijack_Levels
        move.b  (a6)+,($F708).w
        move.b  ($F708).w,d0
        jsr     findAndPlayTrack
        move.b  (a6)+,d0
        rts

msuHijack_StopAllSound
        move.b  #$2B,d0
        move.b  #$80,d1
        jsr msuStop
        rts

msuHijack_Fade
        move.b  #$28,($F702).l
        jsr     msuFade
        rts

msuHijack_SoundTest
        beq.w   jmp_sub_9494
        move.w  ($FF32).w,d0
        move.b  soundIDs(pc,d0.w),d0
        jsr     findAndPlayTrack
        jmp     retFromHijack
jmp_sub_9494
        jmp     sub_9494
        
soundIDs:       
        dc.b    $81
        dc.b    $82
        dc.b    $83
        dc.b    $84
        dc.b    $85
        dc.b    $86
        dc.b    $87
        dc.b    $88
        dc.b    $89
        dc.b    $8A
        dc.b    $8B
        dc.b    $8C
        dc.b    $8D
        dc.b    $8E
        dc.b    $8F
        dc.b    $90
        dc.b    $91
        dc.b    $92
        dc.b    $93
        dc.b    $A0
        dc.b    $A2
        dc.b    $A3
        dc.b    $A4
        dc.b    $A5
        dc.b    $A6
        dc.b    $A7
        dc.b    $A8
        dc.b    $A9
        dc.b    $AA
        dc.b    $AB
        dc.b    $AC
        dc.b    $AD
        dc.b    $AF
        dc.b    $B0
        dc.b    $B1
        dc.b    $B2
        dc.b    $B3
        dc.b    $B4
        dc.b    $B5
        dc.b    $B6
        dc.b    $B7
        dc.b    $B8
        dc.b    $B9
        dc.b    $C0
        dc.b    $C1
        dc.b    $C2
        dc.b    $C3
        dc.b    $C4
        dc.b    $CA
        dc.b    $CB
        dc.b    $CC
        dc.b    $CD
        dc.b    $CF
        dc.b    0
        align   2
        
findAndPlayTrack
        cmp.b	#$81,d0					; The Shinobi           CBD8
        beq     play_track_1
        cmp.b	#$82,d0					; Terrible Beat         CBD8
        beq     play_track_2
        cmp.b	#$83,d0					; Round Clear           A5D2
        beq     play_track_3
        cmp.b	#$84,d0					; Make Me Dance         
        beq     play_track_4
        cmp.b	#$85,d0					; Over the Bay          
        beq     play_track_5
        cmp.b	#$86,d0					; China Town            
        beq     play_track_6
        cmp.b	#$87,d0					; Run or Die            
        beq     play_track_7
        cmp.b	#$88,d0					; Like a Wind           
        beq     play_track_8
        cmp.b	#$89,d0					; Labyrinth             
        beq     play_track_9
        cmp.b	#$8A,d0					; Sunrise Blvd.         
        beq     play_track_10
        cmp.b	#$8B,d0					; The Dark City         
        beq     play_track_11
        cmp.b	#$8C,d0					; Ninja Step            
        beq     play_track_12
        cmp.b	#$8D,d0					; Long Distance (story) A40C
        beq     play_track_13
        cmp.b	#$8E,d0					; Failure               A11C
        beq     play_track_14
        cmp.b	#$8F,d0					; Silence Night         
        beq     play_track_15
        cmp.b	#$90,d0					; My Lover              
        beq     play_track_16
        cmp.b	#$91,d0					; Game Over             A96E
        beq     play_track_17
        cmp.b	#$92,d0					; The Ninja Master      
        beq     play_track_18
        cmp.b	#$93,d0					; Opening               9682
        beq     play_track_19
        rts


play_track_1								
        move.w	#($1100|1),MCD_CMD			; send cmd: play track #1, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_2							
        move.w	#($1100|2),MCD_CMD			; send cmd: play track #2, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_3							
        move.w	#($1100|3),MCD_CMD			; send cmd: play track #3, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_4							
        move.w	#($1100|4),MCD_CMD			; send cmd: play track #4, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_5							
        move.w	#($1100|5),MCD_CMD			; send cmd: play track #5, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_6							
        move.w	#($1100|6),MCD_CMD			; send cmd: play track #6, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_7							
        move.w	#($1100|7),MCD_CMD			; send cmd: play track #7, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_8						
        move.w	#($1100|8),MCD_CMD			; send cmd: play track #8, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_9								
        move.w	#($1100|9),MCD_CMD			; send cmd: play track #9, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_10						
        move.w	#($1100|10),MCD_CMD			; send cmd: play track #10, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_11							
        move.w	#($1100|11),MCD_CMD			; send cmd: play track #11, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_12						
        move.w	#($1100|12),MCD_CMD			; send cmd: play track #12, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_13							
        move.w	#($1100|13),MCD_CMD			; send cmd: play track #13, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_14
        move.w	#($1100|14),MCD_CMD			; send cmd: play track #14, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_15
        move.w	#($1100|15),MCD_CMD			; send cmd: play track #15, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_16
        move.w	#($1100|16),MCD_CMD			; send cmd: play track #16, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_17
        move.w	#($1100|17),MCD_CMD			; send cmd: play track #17, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_18
        move.w	#($1100|18),MCD_CMD			; send cmd: play track #18, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_19
        move.w	#($1100|19),MCD_CMD			; send cmd: play track #19, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts

msuSega
        move.w  #8,($FF26).w
        move.w	#($1100|20),MCD_CMD			; send cmd: play track #19, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts

msuStop
        move.w	#($1300|00),MCD_CMD			; send cmd: pause track
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts

msuFade
        move.w	#($1300|35),MCD_CMD			; send cmd: pause track
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts

audio_init
        jsr     MSUDRV
        nop

        if PRODUCTION
        
        tst.b   d0                          ; if 1: no CD Hardware found
        bne     audio_init_fail             ; Return without setting CD enabled
        
        endif

ready_init
        tst.b   MCD_STAT
        bne.s   ready_init
        move.w  #($1500|255),MCD_CMD        ; Set CD Volume to MAX
        addq.b  #1,MCD_CMD_CK               ; Increment command clock
        rts
audio_init_fail
        jmp     lockout
        
        align   2
ENTRY_POINT
        tst.w   $00A10008                   ; Test mystery reset (expansion port reset?)
        bne Main                            ; Branch if Not Equal (to zero) - to Main
        tst.w   $00A1000C                   ; Test reset button
        bne Main                            ; Branch if Not Equal (to zero) - to Main
Main
        move.b  $00A10001,d0                ; Move Megadrive hardware version to d0
        andi.b  #$0F,d0                     ; The version is stored in last four bits, so mask it with 0F
        beq     Skip                        ; If version is equal to 0, skip TMSS signature
        move.l  #'SEGA',$00A14000           ; Move the string "SEGA" to 0xA14000
Skip
        btst    #$6,(HW_version).l          ; Check for PAL or NTSC, 0=60Hz, 1=50Hz
        bne     jump_lockout                ; branch if != 0
        jsr     audio_init
        jmp     Game
jump_lockout
        jmp     lockout
        

        align   2
lockout
        incbin  "msuLockout.bin"
