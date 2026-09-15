; 등록번호를 삽입 문자열에 전달
PrepareRegistrationNumber:
    lda $AC

; 숫자 한 자리를 2바이트 고유번호와 종료 코드로 기록
; A의 숫자를 $03CB~$03CD에 고유번호 두 바이트와 종료 코드로 기록
WriteInsertedNumber:
    clc
    adc #DigitCodeLow
    sta $03CC
    lda #$83
    sta $03CB
    lda #$70
    sta $03CD
    rts

; 번호판 한 행을 출력하고 첫 행에서 완료 표시 글자 준비
; X는 행 번호의 두 배, $0D/$0E는 문자열 주소, $0B/$0C는 상단 주소
DrawStageNumberRow:
    txa
    pha
    cpx #$00
    bne DrawStageNumberRow_Text
    lda #$83
    sta GlyphCodeHigh
    jsr AllocateBgTile
    lda CurrentBgTile
    sta StageClearTile
    lda #$0C
    jsr CopyGlyphToBuffer
    jsr FlushGlyphBuffer
DrawStageNumberRow_Text:
    lda $0D
    sta $0F
    lda $0E
    sta $10
    lda $B8
    asl a
    sta $18
    clc
    adc $0B
    sta $11
    lda $0C
    adc #$00
    sta $12
    jsr $C018
    pla
    tax
    rts

; 완료 표시의 상하단 타일을 $0B/$0C의 상단 주소부터 기록
DrawStageClearMark:
    ldy #$00
    lda StageClearTile
    sta ($0B),y
    lda $B8
    asl a
    tay
    lda StageClearTile
    clc
    adc #$01
    sta ($0B),y
    rts

; 숫자 0~9를 공용 BG 영역에 준비
PrepareNumberTiles:
    lda NumberTilesReady
    bne PrepareNumberTiles_End
    jsr FlushGlyphBuffer
    lda #NumberTileBase
    sta UploadTile
    lda #$83
    sta GlyphCodeHigh
    lda #DigitCodeLow
PrepareNumberTiles_Next:
    pha
    jsr CopyGlyphToBuffer
    lda BufferedBytes
    cmp #$60
    bne PrepareNumberTiles_Advance
    jsr FlushGlyphBuffer
    lda UploadTile
    clc
    adc #$06 ; 숫자 세 개를 보냈으므로 타일 여섯 칸 이동
    sta UploadTile
PrepareNumberTiles_Advance:
    pla
    clc
    adc #$01
    cmp #(DigitCodeLow + $0A)
    bne PrepareNumberTiles_Next
    ; 세 개씩 보내고 남은 마지막 숫자도 전송
    jsr FlushGlyphBuffer
    lda #$01
    sta NumberTilesReady
PrepareNumberTiles_End:
    rts

; 원본 숫자 $60~$69를 타이틀 숫자 타일로 변환. 0은 $E8, 1은 $EA
; 숫자는 상하 두 타일 간격으로 선택하고 원본 공백 $7F는 $FF 반환
GetNumberTile:
    cmp #$7F
    beq GetNumberTile_Space
    and #$0F
    asl a
    clc
    adc #NumberTileBase
    rts
GetNumberTile_Space:
    lda #$FF
    rts

; 숫자 하단 주소 $0B/$0C에서 상단 주소 $13/$14 계산
SetNumberTopRow:
    lda $B8
    asl a
    sta $0D
    sec
    lda $0B
    sbc $0D
    sta $13
    lda $0C
    sbc #$00
    sta $14
    rts

; LV 두 자리 숫자의 목적지 설정
DrawLevelNumber:
    lda $13
    sta $0B
    lda $14
    sta $0C

; $19/$1A의 두 자리 숫자를 창 버퍼에 기록
DrawDebugNumber:
    jsr PrepareNumberTiles
    jsr SetNumberTopRow
    ldy #$00
    lda $19
    jsr StoreNumberDigit
    iny
    lda $1A

; 숫자 한 칸의 상하단 타일 기록
StoreNumberDigit:
    jsr GetNumberTile
    sta ($13),y
    ora #$01
    sta ($0B),y
    rts

; $1A의 한 자리 숫자를 창 버퍼에 기록
DrawDebugDigit:
    jsr PrepareNumberTiles
    jsr SetNumberTopRow
    ldy #$00
    lda $1A
    jsr StoreNumberDigit
    rts

; VBlank 동안 변경된 디버그 숫자 두 칸의 상하단 전송
; $0200/$0201은 하단 PPU 주소, $0202/$0203은 원본 숫자 코드
UploadDebugNumber:
    lda $A5
    bne UploadDebugNumber_End
    jsr $E467
    lda $00
    and #$FB
    sta $2000
    sec
    lda $0200
    sbc #$20
    tax
    lda $0201
    sbc #$00
    sta $2006
    stx $2006
    lda $0202
    jsr GetNumberTile
    sta $2007
    lda $0203
    jsr GetNumberTile
    sta $2007
    lda $0201
    sta $2006
    lda $0200
    sta $2006
    lda $0202
    jsr GetNumberTile
    ora #$01
    sta $2007
    lda $0203
    jsr GetNumberTile
    ora #$01
    sta $2007
    lda $00
    sta $2000
    lda #$FF
    sta $A5
UploadDebugNumber_End:
    rts
