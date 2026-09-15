; 예약 타일을 건너뛰고 연속된 타일 두 개 배정
AllocateBgTile:
    lda GameTextMode
    bne AllocateGameTile
    lda NextBgTile
    cmp #$70
    bne AllocateBgTile_Check7F
    jsr FlushGlyphBuffer
    lda #$78
AllocateBgTile_Check7F:
    cmp #$7E
    bne AllocateBgTile_Store
    jsr FlushGlyphBuffer
    lda #$80
AllocateBgTile_Store:
    ldx NumberTilesReady
    beq AllocateBgTile_CheckEnd
    cmp #NumberTileBase
    bcs AllocateBgTile_Full
AllocateBgTile_CheckEnd:
    cmp #$FC
    bcc AllocateBgTile_Available
AllocateBgTile_Full:
    brk
AllocateBgTile_Available:
    sta CurrentBgTile
    ldx BufferedBytes
    bne AllocateBgTile_Advance
    sta UploadTile
AllocateBgTile_Advance:
    clc
    adc #$02
    sta NextBgTile
    rts

; 인게임 허용 범위에서 상단과 하단 타일 두 개 배정
AllocateGameTile:
    jsr IsBattleScreen
    beq AllocateBattleTile
    lda NextBgTile
    cmp #$70
    bne AllocateGameTile_Check7E
    jsr FlushGlyphBuffer
    lda #$78
AllocateGameTile_Check7E:
    cmp #$7E
    bne AllocateGameTile_CheckD0
    jsr FlushGlyphBuffer
    lda #$CA
AllocateGameTile_CheckD0:
    cmp #$D0
    bne AllocateGameTile_CheckEnd
    jsr FlushGlyphBuffer
    lda #$DA
AllocateGameTile_CheckEnd:
    cmp #$FE
    bcs AllocateGameTile_Full
    cmp #$CA
    bcc AllocateBgTile_Available
    ldx GameTextMode
    cpx #$01
    bne AllocateBgTile_Available
    ; 다른 목록이 고정 글자를 덮으면 다음 스탯 진입 때 다시 준비
    ldx #$FF
    stx InspectionFontBank
    jmp AllocateBgTile_Available
AllocateGameTile_Full:
    brk

; 전투용 글리프: 기존 $60~$FB 다음 $0A~$0F, $1A~$5F를 배정
; $70~$77, $7E~$7F, $FC~$FF는 보존. NextBgTile의 $FE는 빈자리 없음
AllocateBattleTile:
    lda NextBgTile
    cmp #$FC
    bne AllocateBattleTile_Check10
    jsr FlushGlyphBuffer
    lda #$0A
AllocateBattleTile_Check10:
    cmp #$10
    bne AllocateBattleTile_CheckLast
    jsr FlushGlyphBuffer
    lda #$1A
AllocateBattleTile_CheckLast:
    cmp #$5E
    bne AllocateBattleTile_Check70
    jsr AllocateBgTile_Available
    lda #$FE
    sta NextBgTile
    rts
AllocateBattleTile_Check70:
    cmp #$70
    bne AllocateBattleTile_Check7E
    jsr FlushGlyphBuffer
    lda #$78
AllocateBattleTile_Check7E:
    cmp #$7E
    bne AllocateBattleTile_CheckEnd
    jsr FlushGlyphBuffer
    lda #$80
AllocateBattleTile_CheckEnd:
    cmp #$FE
    bcs AllocateBattleTile_Full
    jmp AllocateBgTile_Available
AllocateBattleTile_Full:
    brk

; 전투 화면이면 Z 플래그를 설정
IsBattleScreen:
    lda $02CD
    cmp #$03
    beq IsBattleScreen_End
    cmp #$07
IsBattleScreen_End:
    rts

; 준비한 폰트 바이트의 전송 요청과 완료 대기
FlushGlyphBuffer:
    lda BufferedBytes
    beq FlushGlyphBuffer_End
    txa
    pha
    tya
    pha
    lda $50
    pha
    lda GameTextMode
    cmp #$01
    bne FlushGlyphBuffer_Single
    lda UploadTile
    bpl FlushGlyphBuffer_Single
    lda $045E
    bne FlushGlyphBuffer_Single
    lda $02D9
    cmp $80
    bne FlushGlyphBuffer_Single
    ldx #$00
FlushGlyphBuffer_Frame:
    lda $82,x
    sta UploadChrBank
    txa
    tay
FlushGlyphBuffer_FindBank:
    dey
    bmi FlushGlyphBuffer_SendBank
    lda $82,y
    cmp UploadChrBank
    beq FlushGlyphBuffer_NextFrame
    bne FlushGlyphBuffer_FindBank
FlushGlyphBuffer_SendBank:
    jsr SendGlyphBuffer
FlushGlyphBuffer_NextFrame:
    inx
    cpx $81
    beq FlushGlyphBuffer_Done
    cpx #$08
    bne FlushGlyphBuffer_Frame
    beq FlushGlyphBuffer_Done
FlushGlyphBuffer_Single:
    lda $02D9
    sta UploadChrBank
    jsr SendGlyphBuffer
FlushGlyphBuffer_Done:
    pla
    sta $50
    pla
    tay
    pla
    tax
    lda #$00
    sta BufferedBytes
FlushGlyphBuffer_End:
    rts

; 글리프 버퍼의 VBlank 전송 요청과 완료 대기
SendGlyphBuffer:
    lda BufferedBytes
    sta UploadBytes
    lda #$7C
    sta $50
SendGlyphBuffer_Wait:
    lda UploadBytes
    bne SendGlyphBuffer_Wait
    rts

; VBlank 동안 준비된 글자 한 개에서 세 개를 CHR-RAM에 전송
UploadGlyphBuffer:
    lda UploadBytes
    bne UploadGlyphBuffer_Map
    rts
UploadGlyphBuffer_Map:
    lda GameTextMode
    beq UploadGlyphBuffer_Title
    ldx #$00
    cmp #$02
    beq UploadGlyphBuffer_Game
    ldx #$08
UploadGlyphBuffer_Game:
    lda $02D0,x
    jsr $E4C1
    lda $02D1,x
    cpx #$00
    beq UploadGlyphBuffer_MapSecond
    lda UploadChrBank
UploadGlyphBuffer_MapSecond:
    jsr $E4C8
    jmp UploadGlyphBuffer_Address
UploadGlyphBuffer_Title:
    lda $02CD
    cmp #EndingScreenId
    bne UploadGlyphBuffer_TitleBanks
    ; 엔딩 아래쪽 CHR $04/$06에 기록. 위 그림의 $08/$0A는 보존
    ldx #$08
    jmp UploadGlyphBuffer_Game
UploadGlyphBuffer_TitleBanks:
    lda #$7C
    jsr $E4C1
    lda #$7E
    jsr $E4C8
UploadGlyphBuffer_Address:
    bit $2002
    lda $00
    and #$FB
    sta $2000
    lda UploadTile
    lsr a
    lsr a
    lsr a
    lsr a
    sta $2006
    lda UploadTile
    asl a
    asl a
    asl a
    asl a
    sta $2006
    ldx #$00
UploadGlyphBuffer_Byte:
    ; 한 글자의 32바이트를 모두 보낸 뒤 다음 글자가 있는지 확인
    lda GlyphBuffer,x
    sta $2007
    lda GlyphBuffer+1,x
    sta $2007
    lda GlyphBuffer+2,x
    sta $2007
    lda GlyphBuffer+3,x
    sta $2007
    lda GlyphBuffer+4,x
    sta $2007
    lda GlyphBuffer+5,x
    sta $2007
    lda GlyphBuffer+6,x
    sta $2007
    lda GlyphBuffer+7,x
    sta $2007
    lda GlyphBuffer+8,x
    sta $2007
    lda GlyphBuffer+9,x
    sta $2007
    lda GlyphBuffer+10,x
    sta $2007
    lda GlyphBuffer+11,x
    sta $2007
    lda GlyphBuffer+12,x
    sta $2007
    lda GlyphBuffer+13,x
    sta $2007
    lda GlyphBuffer+14,x
    sta $2007
    lda GlyphBuffer+15,x
    sta $2007
    lda GlyphBuffer+16,x
    sta $2007
    lda GlyphBuffer+17,x
    sta $2007
    lda GlyphBuffer+18,x
    sta $2007
    lda GlyphBuffer+19,x
    sta $2007
    lda GlyphBuffer+20,x
    sta $2007
    lda GlyphBuffer+21,x
    sta $2007
    lda GlyphBuffer+22,x
    sta $2007
    lda GlyphBuffer+23,x
    sta $2007
    lda GlyphBuffer+24,x
    sta $2007
    lda GlyphBuffer+25,x
    sta $2007
    lda GlyphBuffer+26,x
    sta $2007
    lda GlyphBuffer+27,x
    sta $2007
    lda GlyphBuffer+28,x
    sta $2007
    lda GlyphBuffer+29,x
    sta $2007
    lda GlyphBuffer+30,x
    sta $2007
    lda GlyphBuffer+31,x
    sta $2007
    txa
    clc
    adc #$20
    tax
    cpx UploadBytes
    beq UploadGlyphBuffer_Restore
    jmp UploadGlyphBuffer_Byte
UploadGlyphBuffer_Restore:
    lda $00
    sta $2000
    lda $02D0
    jsr $E4C1
    lda $02D1
    jsr $E4C8
    lda #$00
    sta UploadBytes
UploadGlyphBuffer_End:
    rts
