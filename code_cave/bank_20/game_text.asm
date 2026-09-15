; PRG $22/$23 또는 RAM에서 문자열 바이트 읽기
ReadTextByte:
    lda $10
    cmp #$80
    bcc ReadTextByte_Direct
    cmp #$C0
    bcs ReadTextByte_Direct
    php
    sei
    lda $00
    and #$7F
    sta $2000
    lda $10
    pha
    cmp #$A0
    bcs ReadTextByte_Bank22
    ora #$20
    sta $10
    lda #$23
    bne ReadTextByte_MapBank
ReadTextByte_Bank22:
    lda #$22
ReadTextByte_MapBank:
    tax
    lda #$07
    ora $2D
    sta $8000
    txa
    sta $8001
    lda ($0F),y
    tax
    lda #$21
    sta $8001
    pla
    sta $10
    lda $00
    sta $2000
    plp
    txa
    rts
ReadTextByte_Direct:
    lda ($0F),y
    rts

; 삽입 슬롯의 직접 문자열 또는 참조 주소를 $0F/$10에 설정
; 참조 형식: $00, 주소 하위, 주소 상위, $70
ResolveInsertedText:
    lda $16
    sta $0F
    lda $17
    sta $10
    ldy #$00
    lda ($16),y
    bne ResolveInsertedText_End
    iny
    lda ($16),y
    tax
    iny
    lda ($16),y
    sta $10
    stx $0F
ResolveInsertedText_End:
    rts

; $0F/$10의 이름 주소를 X가 가리키는 삽입 슬롯에 기록
StoreCharacterName:
    lda $0F
    sta $0D
    lda $10
    sta $0E

; $0D/$0E는 문자열 주소. X는 삽입 슬롯의 시작 위치 0, 9, 18, 27, 36
StoreInsertedText:
    lda #$00
    sta $03CB,x
    lda $0D
    sta $03CC,x
    lda $0E
    sta $03CD,x
    lda #$70
    sta $03CE,x
    rts

; 현재 플레이어의 이름 문자열 주소를 $0D/$0E에 설정
GetGamePlayerName:
    lda $02FB
    and #$01       ; 상태 비트를 제외하고 플레이어 번호만 사용
    tax
    beq GetGamePlayerName_Saved
    lda $042D
    bne GetGamePlayerName_Saved
    lda #(CpuPlayerName & $FF)
    sta $0D
    lda #(CpuPlayerName / $100)
    sta $0E
    rts
GetGamePlayerName_Saved:
    lda $042E,x
    sec
    sbc #$01
    sta $0D
    asl a
    asl a
    sta $0E
    asl a
    clc
    adc $0E
    adc $0D
    adc #$04
    sta $0D
    lda #$7F
    sta $0E
    rts

; 인게임 글리프 시작점과 원본 문자열의 행 간격 설정
BeginGameText:
    lda GameTextMode
    bne BeginGameText_Line
    lda #$01
    sta GameTextMode
    lda #$60
    sta NextBgTile
    lda $B1
    lsr a
    lsr a
    lsr a
    tax
    lda #$60
    sta GameWindowTiles,x
BeginGameText_Line:
    lda $B8
    asl a
    sta $18
    asl a
    rts

; 상단 메시지의 타일 영역 선택과 표시 글자 수 계산
; $0F/$10의 문자열을 읽어 한 행의 표시 글자 수를 $0E에 기록
MeasureGameText:
    jsr FlushGlyphBuffer
    lda GameTextMode
    cmp #$02
    beq MeasureGameText_Area
    lda NextBgTile
    ldx GameTextMode
    bne MeasureGameText_SaveWindow
    lda #$60
    sta GameWindowTiles
MeasureGameText_SaveWindow:
    sta GameWindowNext
MeasureGameText_Area:
    lda #$02
    sta GameTextMode
    jsr IsBattleScreen
    bne MeasureGameText_Map
    lda GameWindowNext
    bne MeasureGameText_Start
MeasureGameText_Map:
    lda #$CA
MeasureGameText_Start:
    sta NextBgTile
    lda #$00
    sta $0E
    ldy #$00
MeasureGameText_Read:
    jsr ReadTextByte
    cmp #$70
    beq MeasureGameText_End
    cmp #$71
    beq MeasureGameText_End
    cmp #$72
    bcc MeasureGameText_Character
    cmp #$77
    bcs MeasureGameText_Character
    sec
    sbc #$72
    asl a
    tax
    lda $EABF,x
    sta $16
    lda $EAC0,x
    sta $17
    tya
    pha
    lda $0F
    pha
    lda $10
    pha
    jsr ResolveInsertedText
    ldy #$00
MeasureGameText_Inserted:
    jsr ReadTextByte
    cmp #$70
    beq MeasureGameText_Restore
    cmp #$83
    bcc MeasureGameText_InsertedAdvance
    cmp #$FF
    beq MeasureGameText_InsertedAdvance
    iny
MeasureGameText_InsertedAdvance:
    inc $0E
    iny
    bne MeasureGameText_Inserted
MeasureGameText_Restore:
    pla
    sta $10
    pla
    sta $0F
    pla
    tay
    iny
    bne MeasureGameText_Read
MeasureGameText_Character:
    cmp #$FF
    beq MeasureGameText_Advance
    iny
MeasureGameText_Advance:
    inc $0E
    iny
    bne MeasureGameText_Read
MeasureGameText_End:
    rts

; 인게임 창을 다시 만들 때 해당 창의 첫 타일부터 배정
RebuildGameWindow:
    lda GameTextMode
    beq RebuildGameWindow_Record
    lda #$01
    sta GameTextMode
    lda $B1
    lsr a
    lsr a
    lsr a
    tax
    lda GameWindowTiles,x
    sta NextBgTile
RebuildGameWindow_Record:
    jsr $C04B
    .db $06
    .dw $A700
    rts

; 인게임 새 창의 첫 타일 기록과 원본 창 정보 작성
OpenGameWindow:
    lda GameTextMode
    beq RebuildGameWindow_Record
    cmp #$02
    bne OpenGameWindow_Record
    lda #$01
    sta GameTextMode
    lda GameWindowNext
    sta NextBgTile
OpenGameWindow_Record:
    lda $B1
    lsr a
    lsr a
    lsr a
    tax
    lda NextBgTile
    sta GameWindowTiles,x
    jmp RebuildGameWindow_Record

; 닫은 창의 첫 타일 회수와 원본 창 표시 상태 갱신
CloseGameWindow:
    lda GameTextMode
    beq CloseGameWindow_State
    lda #$01
    sta GameTextMode
    lda $B1
    lsr a
    lsr a
    lsr a
    tax
    inx
    lda GameWindowTiles,x
    sta NextBgTile
CloseGameWindow_State:
    jsr $C04B
    .db $06
    .dw $A7B8
    rts

; ------------------------------------------------------------
