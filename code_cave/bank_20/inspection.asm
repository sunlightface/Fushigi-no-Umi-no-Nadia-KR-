; 스탯 숫자와 문구는 고정 타일 재사용. V와 X만 동적 배정
DrawInspectionStatus:
    jsr FlushGlyphBuffer
    lda #$01
    sta GameTextMode
    lda NextBgTile
    pha
    lda $02D9
    cmp InspectionFontBank
    beq DrawInspectionStatus_Ready
    lda #$CA
    sta NextBgTile
    lda #$00
    sta InspectionGlyphCount
    lda #$83
    sta GlyphCodeHigh
DrawInspectionStatus_Load:
    jsr AllocateBgTile
    ldx InspectionGlyphCount
    lda InspectionStatusCodes,x
    jsr CopyGlyphToBuffer
    lda BufferedBytes
    cmp #$60
    bne DrawInspectionStatus_Next
    jsr FlushGlyphBuffer
DrawInspectionStatus_Next:
    inc InspectionGlyphCount
    lda InspectionGlyphCount
    cmp #$15
    bne DrawInspectionStatus_Load
    jsr FlushGlyphBuffer
    lda $02D9
    sta InspectionFontBank
DrawInspectionStatus_Ready:
    pla
    sta NextBgTile
    ; 목록 출력과 공유하는 RAM에는 매번 고정 글자의 대응표만 복원
    ldx #$14
DrawInspectionStatus_Record:
    lda InspectionStatusCodes,x
    sta InspectionGlyphLow,x
    lda #$83
    sta InspectionGlyphHigh,x
    lda InspectionStatusTiles,x
    sta InspectionGlyphTiles,x
    dex
    bpl DrawInspectionStatus_Record
    lda #$15
    sta InspectionGlyphCount
    ldx #$00
    jsr $C04B
    .db $06
    .dw $86DA
    jsr $C04B
    .db $06
    .dw $9519
    lda #$FF
    sta InspectionGlyphCount
    rts

; 고유번호 $83xx의 하위 바이트. 숫자 열 개, A C D E H L M P S T, 슬래시
InspectionStatusCodes:
    .db $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18
    .db $20, $22, $23, $24, $27, $2B, $2C, $2F, $32, $33, $0E
; 위 글자 순서에 대응하는 상단 타일. 바로 다음 타일은 글자 하단
InspectionStatusTiles:
    .db $CA, $CC, $CE, $DA, $DC, $DE, $E0, $E2, $E4, $E6
    .db $E8, $EA, $EC, $EE, $F0, $F2, $F4, $F6, $F8, $FA, $FC

; 조사 페이지 교체: 기존 창을 닫은 뒤 같은 타일 영역에 새 창 준비
; $B8~$BB는 다음 창의 크기와 위치, $AC는 목록 개수
; 상단 이름의 별도 CHR 뱅크와 메시지 창은 변경하지 않음
ReplaceInspectionWindow:
    lda $AC
    pha
    ldx #$03
ReplaceInspectionWindow_Save:
    lda $B8,x
    pha
    dex
    bpl ReplaceInspectionWindow_Save
    jsr FlushGlyphBuffer
    ; 버튼 대기 중에도 다시 그리므로 원본 스프라이트 Y도 화면 밖으로 이동
    ; 능력치 복귀 시 $CDCB에서 창 위치에 맞는 Y로 복구
    lda #$F0
    sta $0307
    jsr $C04B
    .db $06
    .dw $9EC5 ; 능력치 창 안의 캐릭터 스프라이트 숨김
    jsr $C04B
    .db $06
    .dw $A77E ; 이전 창 닫기, 닫기 훅에서 첫 글리프 타일 회수
    ldx #$00
ReplaceInspectionWindow_Restore:
    pla
    sta $B8,x
    inx
    cpx #$04
    bne ReplaceInspectionWindow_Restore
    pla
    sta $AC
    jsr $C04B
    .db $06
    .dw $A6F3 ; 새 창 열기
    jsr $C04B
    .db $06
    .dw $A75E ; 새 창의 버퍼와 테두리 준비
    rts

; 조사 기술 페이지: 원본 기술 필터와 목록 출력 함수를 그대로 사용
DrawInspectionSkills:
    lda #$00
    sta InspectionGlyphCount
    lda $AC
    bne DrawInspectionSkills_List
    ldx #$02
    jsr $C04B
    .db $06
    .dw $86DA ; Text_127: 기술 없음
    jmp FinishInspectionList
DrawInspectionSkills_List:
    lda #$C0
    jsr $C04B
    .db $06
    .dw $99EE
    jmp FinishInspectionList

; 조사 아이템 페이지: 원본 소지품 순서와 목록 출력 함수를 그대로 사용
DrawInspectionItems:
    lda #$00
    sta InspectionGlyphCount
    lda $AC
    bne DrawInspectionItems_List
    ldx #$04
    jsr $C04B
    .db $06
    .dw $86DA ; Text_128: 아이템 없음
    jmp FinishInspectionList
DrawInspectionItems_List:
    jsr $C04B
    .db $06
    .dw $9BEF
FinishInspectionList:
    lda #$FF
    sta InspectionGlyphCount
    jsr $C04B
    .db $06
    .dw $A775 ; 완성한 현재 페이지 표시
    rts

; 조사 수치가 바뀌면 숫자의 고정 타일 번호만 기록
; X는 숫자 버퍼 시작 위치, $12는 자리 수, $0B/$0C는 하단 기록 주소
DrawStatusNumber:
    stx $0D
    ldx #$1A
DrawStatusNumber_Push:
    lda $00,x
    pha
    dex
    cpx $0D
    bcs DrawStatusNumber_Push
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
    ldy #$00
DrawStatusNumber_Read:
    pla
    cmp #$7F
    beq DrawStatusNumber_Blank
    and #$0F
    tax
    lda InspectionStatusTiles,x
    sta ($13),y
    ora #$01
    bne DrawStatusNumber_Bottom
DrawStatusNumber_Blank:
    lda #$FF
    sta ($13),y
DrawStatusNumber_Bottom:
    sta ($0B),y
    iny
    dec $12
    bne DrawStatusNumber_Read
    rts
