; 전투 이름 타일 보관 영역과 H, M, 숫자 글리프 준비
InitializeBattleText:
    lda #$FF
    sta InspectionGlyphCount
    sta InspectionFontBank
    lda #$01
    sta GameTextMode
    lda #$00
    sta BufferedBytes
    sta UploadBytes
    sta NumberTilesReady
    ldx #$00
InitializeBattleText_Clear:
    sta BattleNameTiles,x
    inx
    bpl InitializeBattleText_Clear
    lda #$60
    sta NextBgTile
    lda #$83
    sta GlyphCodeHigh
    lda #$00
    sta $0D
InitializeBattleText_Digit:
    jsr AllocateBgTile
    ldx $0D
    lda CurrentBgTile
    sta StatusDigitTiles,x
    txa
    clc
    adc #DigitCodeLow
    jsr CopyGlyphToBuffer
    lda BufferedBytes
    cmp #$60
    bne InitializeBattleText_NextDigit
    jsr FlushGlyphBuffer
InitializeBattleText_NextDigit:
    inc $0D
    lda $0D
    cmp #$0A
    bne InitializeBattleText_Digit
    jsr AllocateBgTile
    lda #$27
    jsr CopyGlyphToBuffer
    jsr AllocateBgTile
    lda #$2C
    jsr CopyGlyphToBuffer
    jsr FlushGlyphBuffer
    lda NextBgTile
    sta BattleHudEnd
    rts

; A로 받은 전투 참가 슬롯의 이름과 H, M 수치를 출력
DrawBattleStatus:
    asl a
    sta $02E2
    lsr a
    tax
    lda $0357,x
    cmp #$FE
    bcc DrawBattleStatus_Character
    rts
DrawBattleStatus_Character:
    sta $02FC
    txa
    lsr a
    lsr a
    and #$01
    sta $02FB
    lda $02E2
    asl a
    asl a
    asl a
    tax
    lda BattleNameTiles,x
    bne DrawBattleStatus_CachedName
    lda BattleHudEnd
    sta NextBgTile
    jsr $C04B
    .db $06
    .dw $98EE
    ldx #$0F
    lda #$FF
DrawBattleStatus_ClearName:
    sta $02E3,x
    dex
    bpl DrawBattleStatus_ClearName
    lda $03D5
    sta $0F
    lda $03D6
    sta $10
    lda #$EB
    sta $11
    lda #$02
    sta $12
    lda #$08
    sta $18
    jsr $C018
    lda NextBgTile
    sta BattleHudEnd
    lda $02E2
    asl a
    asl a
    asl a
    tax
    ldy #$00
DrawBattleStatus_SaveName:
    lda $02E3,y
    sta BattleNameTiles,x
    inx
    iny
    cpy #$10
    bne DrawBattleStatus_SaveName
    beq DrawBattleStatus_NameReady
DrawBattleStatus_CachedName:
    ldy #$00
DrawBattleStatus_CopyName:
    lda BattleNameTiles,x
    sta $02E3,y
    inx
    iny
    cpy #$10
    bne DrawBattleStatus_CopyName
DrawBattleStatus_NameReady:
    lda #$02
    jsr $C045
    jsr $C04B
    .db $06
    .dw $8024
    jsr $C01B
    lda #BattleHpTile
    jsr PrepareBattleNumber
    lda #$00
    jsr $C045
    jsr $C04B
    .db $06
    .dw $8027
    jsr $C01B
    lda #BattleMpTile
    jsr PrepareBattleNumber
    lda #$01
    jsr $C045
    rts

; A는 H 또는 M의 상단 타일, $18~$1A는 원본 숫자 코드 세 자리
PrepareBattleNumber:
    sta $02E3
    ora #$01
    sta $02EB
    ldx #$02
PrepareBattleNumber_Digit:
    lda $18,x
    sec
    sbc #$60
    tay
    lda StatusDigitTiles,y
    sta $02E4,x
    ora #$01
    sta $02EC,x
    dex
    bpl PrepareBattleNumber_Digit
    rts
