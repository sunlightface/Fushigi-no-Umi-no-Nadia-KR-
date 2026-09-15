; 공백 타일 기록과 글리프 출력 준비
; A는 고유번호 하위 바이트, GlyphCodeHigh는 상위 바이트
PrepareGlyph:
    ldx GlyphCodeHigh
    cpx #$FF
    bne PrepareGlyph_Font
    ldy $19
    lda #$FF
    sta ($13),y
    sta ($11),y
    rts
PrepareGlyph_Font:
    ldy GameTextMode
    bne PrepareGlyph_Allocate
    ldy GlyphInkMask
    beq PrepareGlyph_Allocate
    cpx #$83
    bne PrepareGlyph_Allocate
    cmp #DigitCodeLow
    bcc PrepareGlyph_Allocate
    cmp #(DigitCodeLow + $0A)
    bcs PrepareGlyph_Allocate
    pha
    jsr PrepareNumberTiles
    pla
    sec
    sbc #DigitCodeLow
    asl a
    clc
    adc #NumberTileBase
    sta CurrentBgTile
    bne PrepareGlyph_WriteTiles
PrepareGlyph_Allocate:
    jsr PrepareGlyphTile
PrepareGlyph_WriteTiles:
    ldy $19
    lda CurrentBgTile
    sta ($13),y
    clc
    adc #$01
    sta ($11),y
    lda BufferedBytes
    cmp #$60
    bne PrepareGlyph_End
    jsr FlushGlyphBuffer
PrepareGlyph_End:
    rts

; 화면과 재사용 상태에 따라 글자의 타일 준비 방법 선택
PrepareGlyphTile:
    ldy GameTextMode
    beq PrepareRegistrationGlyph
    cpy #$01
    bne PrepareNewGlyph
    ldy InspectionGlyphCount
    bpl PrepareInspectionGlyph

; 재사용하지 않는 글자는 새 타일을 배정하고 모양을 버퍼에 복사
PrepareNewGlyph:
    pha
    jsr AllocateBgTile
    pla
    jmp CopyGlyphToBuffer

; 조사 문구와 목록에서 고유번호가 같으면 기존 타일 사용
PrepareInspectionGlyph:
    tax
PrepareInspectionGlyph_Find:
    dey
    bmi PrepareInspectionGlyph_New
    cmp InspectionGlyphLow,y
    bne PrepareInspectionGlyph_Find
    lda GlyphCodeHigh
    cmp InspectionGlyphHigh,y
    beq PrepareInspectionGlyph_Found
    txa
    jmp PrepareInspectionGlyph_Find
PrepareInspectionGlyph_Found:
    lda InspectionGlyphTiles,y
    sta CurrentBgTile
    rts
PrepareInspectionGlyph_New:
    txa
    pha
    jsr AllocateBgTile
    pla
    ldx InspectionGlyphCount
    sta InspectionGlyphLow,x
    pha
    lda GlyphCodeHigh
    sta InspectionGlyphHigh,x
    lda CurrentBgTile
    sta InspectionGlyphTiles,x
    inc InspectionGlyphCount
    pla
    jmp CopyGlyphToBuffer

; 등록 목록에서는 흰색 하이픈만 재사용. 조사 표의 첫 칸을 빌려 사용
PrepareRegistrationGlyph:
    cmp #(RegistrationDashCode & $FF)
    bne PrepareNewGlyph
    ldy GlyphCodeHigh
    cpy #(RegistrationDashCode / $100)
    bne PrepareNewGlyph
    ldy GlyphInkMask
    cpy #$FF
    bne PrepareNewGlyph
    ldy InspectionGlyphCount
    cpy #RegistrationDashReady
    beq PrepareRegistrationGlyph_Reuse
    cpy #RegistrationDashPending
    bne PrepareNewGlyph
    jsr AllocateBgTile
    lda CurrentBgTile
    sta InspectionGlyphTiles
    lda #RegistrationDashReady
    sta InspectionGlyphCount
    lda #(RegistrationDashCode & $FF)
    jmp CopyGlyphToBuffer
PrepareRegistrationGlyph_Reuse:
    lda InspectionGlyphTiles
    sta CurrentBgTile
    rts

; 고유번호의 글자 모양을 화면 색상에 맞춰 32바이트 복사
; A는 고유번호 하위 바이트, GlyphCodeHigh는 상위 바이트
CopyGlyphToBuffer:
    tax
    lda $15
    pha
    lda $16
    pha
    txa
    asl a
    asl a
    asl a
    asl a
    asl a
    sta $15
    txa
    lsr a
    lsr a
    lsr a
    ora #$A0
    sta $16

    php
    sei
    lda $00
    and #$7F
    sta $2000
    lda #$07
    ora $2D
    sta $8000
    lda GlyphCodeHigh
    sec
    sbc #$83
    clc
    adc #$27
    sta $8001

    ldx BufferedBytes
    ldy #$00
    lda $02CD
    cmp #EndingScreenId
    bne CopyGlyphToBuffer_SelectMode
; 엔딩은 원본 비트 그대로 복사. 인물 그림과 공유하는 팔레트 유지
CopyGlyphToBuffer_EndingByte:
    lda ($15),y
    sta GlyphBuffer,x
    inx
    iny
    cpy #$20
    bne CopyGlyphToBuffer_EndingByte
    jmp CopyGlyphToBuffer_Done
CopyGlyphToBuffer_SelectMode:
    lda GameTextMode
    beq CopyGlyphToBuffer_TitleByte
    jsr IsBattleScreen
    bne CopyGlyphToBuffer_GameByte
; 전투는 배경색 번호 1, 글자색 번호 2로 변환
CopyGlyphToBuffer_BattleByte:
    lda ($15),y
    sta GlyphBuffer,x
    tya
    and #$08
    beq CopyGlyphToBuffer_BattleNext
    lda GlyphBuffer,x
    eor #$FF
    sta GlyphBuffer,x
CopyGlyphToBuffer_BattleNext:
    inx
    iny
    cpy #$20
    bne CopyGlyphToBuffer_BattleByte
    beq CopyGlyphToBuffer_Done
; 타이틀은 배경색 번호 1. 이름 강조 여부에 따라 글자색 선택
CopyGlyphToBuffer_TitleByte:
    lda ($15),y
    sta GlyphBuffer,x
    tya
    and #$08
    beq CopyGlyphToBuffer_TitleNext
    lda GlyphBuffer,x
    eor #$FF
    and GlyphInkMask
    sta GlyphBuffer,x
CopyGlyphToBuffer_TitleNext:
    inx
    iny
    cpy #$20
    bne CopyGlyphToBuffer_TitleByte
    jmp CopyGlyphToBuffer_Done

; 인게임은 검정 배경에 흰 글자. 복사 중에는 출력 모드를 다시 읽지 않음
CopyGlyphToBuffer_GameByte:
    tya
    and #$08
    bne CopyGlyphToBuffer_GamePlane1
    lda ($15),y
    eor #$FF
    sta GlyphBuffer,x
    jmp CopyGlyphToBuffer_GameNext
CopyGlyphToBuffer_GamePlane1:
    lda #$00
    sta GlyphBuffer,x

CopyGlyphToBuffer_GameNext:
    inx
    iny
    cpy #$20
    bne CopyGlyphToBuffer_GameByte
CopyGlyphToBuffer_Done:
    stx BufferedBytes
    lda #$21
    sta $8001
    lda $00
    sta $2000
    plp
    pla
    sta $16
    pla
    sta $15
    rts
