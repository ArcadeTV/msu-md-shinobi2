### SoundDriver
SMPS-Mucom 68k (early)

```
PlaySoundID:
		moveq	#0,d0
		btst	#7,($FFF708).l
		beq.w	loc_78F92
		move.b	($FFF708).l,d0
		cmpi.b	#$A0,d0
		bcs.w	PlayMusic	; 80-9F	- Music
		cmpi.b	#$D0,d0
		bcs.w	PlaySFX		; A0-CF	- SFX
		cmpi.b	#$D8,d0
		bcs.w	loc_78F92	; D0-D7	- Stop All
		cmpi.b	#$E0,d0
		bcs.w	PlayMusic	; D8-DF	- Music	(invalid, should be Special SFX)
		cmpi.b	#$E4,d0
		bcs.w	PlaySnd_Command	; E0-E3	- Special Commands
		bra.w	loc_78F92
```

### MAME debugging

```
<software name="supshin" cloneof="revshin">
    <description>The Super Shinobi (Jpn)</description>
    <year>1989</year>
    <publisher>Sega</publisher>
    <info name="serial" value="G-4019"/>
    <info name="release" value="19891202"/>
    <info name="alt_title" value="ザ・スーパー忍"/>
    <part name="cart" interface="megadriv_cart">
        <dataarea name="rom" width="16" endianness="big" size="524288">
            <rom name="mpr-12675.bin" size="524288" crc="5c7e5ea6" sha1="d5807a44d2059aa4ff27ecb7bdc749fbb0382550"/>
        </dataarea>
    </part>
</software>
```

Find sound cmd:
`wp ffF708,1,w,wpdata >= 0xD0 && wpdata < 0xD7`

Find sound calls:
`wp ffF708,1,w,wpdata > 0x80 && wpdata < 0x94`