PRODUCTION  set 1                           ; set to 0 for GENS compatibility (for debugging) and 1 when ready
CHEAT       set 0                           ; set to 1 for cheat enabled
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

        org     $206                            ; only for label
Game

        org     $924E
        jsr     msuSega

        org     $6A980                          ; only for label
ret_msuSega

        org     $78EDE                          ; mute music by aborting PlayMusic function
        rts
        
        org     $78FAE                          ; StopAllSound function
        ;jsr     msuHijack_StopAllSound         ; doesn't work because of how this SMPS driver works
        ;nop

        org     $87C0                           ; Mute music on optionscreen
        jsr     msuHijack_StopOptions           ; Thanks to PepilloPEV and neodev for hinting the location!
        
        org     $9484
        jmp     msuHijack_SoundTest

        org     $948A                           ; only for label
retFromHijack

        org     $9494                           ; only for label
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
        org     $F96E
        jsr     play_track_16                   ; My Lover
        org     $F982
        jsr     play_track_15                   ; Silence Night

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
        move.b  (a6)+,($F708).w                 ; original bypassed code
        move.b  ($F708).w,d0                    ; original bypassed code
        jsr     findAndPlayTrack
        move.b  (a6)+,d0                        ; original bypassed code
        rts

msuHijack_StopOptions
        moveq   #0,d1                           ; original bypassed code
        move.w  #$3D,d7                         ; original bypassed code
        jsr     msuStop
        rts

msuHijack_StopAllSound
        move.b  #$2B,d0                         ; original bypassed code
        move.b  #$80,d1                         ; original bypassed code
        cmpi.b  #00,($F708).w                   ; if this RAM location is 00 and does not contain a SoundID, stop the music
        beq     jmp_msuStop
        rts
jmp_msuStop
        jsr msuStop
        rts

msuHijack_Fade
        move.b  #$28,($F702).l                  ; original bypassed code
        jsr     msuFade
        rts

msuHijack_SoundTest
        beq.w   jmp_sub_9494                    ; original bypassed code with custom jmp label
        move.w  ($FF32).w,d0                    ; original bypassed code
        move.b  soundIDs(pc,d0.w),d0            ; original bypassed code with custom array
        jsr     findAndPlayTrack
        move.w  ($FF32).w,d0                    ; original bypassed code
        jmp     retFromHijack
jmp_sub_9494
        jmp     sub_9494
        
soundIDs:       
        dc.b    $81 ; 00 ---------- first music item
        dc.b    $82 ; 01
        dc.b    $83 ; 02
        dc.b    $84 ; 03
        dc.b    $85 ; 04
        dc.b    $86 ; 05
        dc.b    $87 ; 06
        dc.b    $88 ; 07
        dc.b    $89 ; 08
        dc.b    $8A ; 09
        dc.b    $8B ; 0A
        dc.b    $8C ; 0B
        dc.b    $8D ; 0C
        dc.b    $8E ; 0D
        dc.b    $8F ; 0E
        dc.b    $90 ; 0F
        dc.b    $91 ; 10
        dc.b    $92 ; 11
        dc.b    $93 ; 12 ---------- last music item
        dc.b    $A0 ; 13 ----------  first sfx item
        dc.b    $A2 ; 14
        dc.b    $A3 ; 15
        dc.b    $A4 ; 16
        dc.b    $A5 ; 17
        dc.b    $A6 ; 18
        dc.b    $A7 ; 19
        dc.b    $A8 ; 1A
        dc.b    $A9 ; 1B
        dc.b    $AA ; 1C
        dc.b    $AB ; 1D
        dc.b    $AC ; 1E
        dc.b    $AD ; 1F
        dc.b    $AF ; 20
        dc.b    $B0 ; 21
        dc.b    $B1 ; 22
        dc.b    $B2 ; 23
        dc.b    $B3 ; 24
        dc.b    $B4 ; 25
        dc.b    $B5 ; 26
        dc.b    $B6 ; 27
        dc.b    $B7 ; 28
        dc.b    $B8 ; 29
        dc.b    $B9 ; 2A
        dc.b    $C0 ; 2B
        dc.b    $C1 ; 2C
        dc.b    $C2 ; 2D
        dc.b    $C3 ; 2E
        dc.b    $C4 ; 2F
        dc.b    $CA ; 30
        dc.b    $CB ; 31
        dc.b    $CC ; 32
        dc.b    $CD ; 33
        dc.b    $CF ; 34 -----------  last sfx item
        dc.b    0
        align   2
        
findAndPlayTrack
        cmp.b	#$81,d0					; The Shinobi           set@ $CBD8
        beq     play_track_1
        cmp.b	#$82,d0					; Terrible Beat         set@ $CBD8
        beq     play_track_2
        cmp.b	#$83,d0					; Round Clear           set@ $A5D2
        beq     play_track_3
        cmp.b	#$84,d0					; Make Me Dance         set@ $CBD8
        beq     play_track_4
        cmp.b	#$85,d0					; Over the Bay          set@ $CBD8
        beq     play_track_5
        cmp.b	#$86,d0					; China Town            set@ $CBD8
        beq     play_track_6
        cmp.b	#$87,d0					; Run or Die            set@ $CBD8
        beq     play_track_7
        cmp.b	#$88,d0					; Like a Wind           set@ $CBD8
        beq     play_track_8
        cmp.b	#$89,d0					; Labyrinth             set@ $CBD8
        beq     play_track_9
        cmp.b	#$8A,d0					; Sunrise Blvd.         set@ $CBD8
        beq     play_track_10
        cmp.b	#$8B,d0					; The Dark City         set@ $CBD8
        beq     play_track_11
        cmp.b	#$8C,d0					; Ninja Step            set@ $CBD8
        beq     play_track_12
        cmp.b	#$8D,d0					; Long Distance (story) set@ $A40C
        beq     play_track_13
        cmp.b	#$8E,d0					; Failure               set@ $A11C
        beq     play_track_14
        cmp.b	#$8F,d0					; Silence Night         set@ $F97E ?
        beq     play_track_15
        cmp.b	#$90,d0					; My Lover              set@ $F96A ?
        beq     play_track_16
        cmp.b	#$91,d0					; Game Over             set@ $A96E
        beq     play_track_17
        cmp.b	#$92,d0					; The Ninja Master      set@ $CBD8
        beq     play_track_18
        cmp.b	#$93,d0					; Opening               set@ $9682
        beq     play_track_19
        rts


play_track_1						; The Shinobi		
        move.w	#($1200|1),MCD_CMD			; send cmd: play track #1, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_2						; Terrible Beat
        move.w	#($1200|2),MCD_CMD			; send cmd: play track #2, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_3						; Round Clear
        move.w	#($1100|3),MCD_CMD			; send cmd: play track #3, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_4						; Make Me Dance    
        move.w	#($1200|4),MCD_CMD			; send cmd: play track #4, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_5						; Over the Bay   
        move.w	#($1200|5),MCD_CMD			; send cmd: play track #5, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_6						; China Town        
        move.w	#($1200|6),MCD_CMD			; send cmd: play track #6, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_7						; Run or Die           
        move.w	#($1200|7),MCD_CMD			; send cmd: play track #7, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_8						; Like a Wind           
        move.w	#($1200|8),MCD_CMD			; send cmd: play track #8, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_9						; Labyrinth     
        move.w	#($1200|9),MCD_CMD			; send cmd: play track #9, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_10						; Sunrise Blvd.   
        move.w	#($1200|10),MCD_CMD			; send cmd: play track #10, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_11						; The Dark City   
        move.w	#($1200|11),MCD_CMD			; send cmd: play track #11, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_12						; Ninja Step     
        move.w	#($1200|12),MCD_CMD			; send cmd: play track #12, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_13						; Long Distance (story)
        move.w	#($1200|13),MCD_CMD			; send cmd: play track #13, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_14                                           ; Failure
        move.w	#($1100|14),MCD_CMD			; send cmd: play track #14, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_15                                           ; Silence Night
        move.w	#($1100|15),MCD_CMD			; send cmd: play track #15, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        lea     ($FA1E).l,a5                            ; original bypassed code
        rts
play_track_16                                           ; My Lover 
        move.w	#($1200|16),MCD_CMD			; send cmd: play track #16, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        lea     ($F9FE).l,a5                            ; original bypassed code
        rts
play_track_17                                           ; Game Over
        move.w	#($1100|17),MCD_CMD			; send cmd: play track #17, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_18                                           ; The Ninja Master 
        move.w	#($1200|18),MCD_CMD			; send cmd: play track #18, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts
play_track_19                                           ; Opening
        move.w	#($1100|19),MCD_CMD			; send cmd: play track #19, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        rts

msuSega
        move.w	#($1100|20),MCD_CMD			; send cmd: play track #19, no loop
        addq.b	#1,MCD_CMD_CK				; Increment command clock
        jsr     ret_msuSega
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
