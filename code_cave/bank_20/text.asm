; 문자열 처리 함수 선택
TextBankDispatch:
    jsr $C000
    .dw ReadTextLeadByte, RenderKoreanCharacter
    .dw RenderInsertedText, ResetTextTiles
    .dw PollNameInput, SwitchKeyboardPage
    .dw InitializeMenuRedraw, PrepareMenuRedraw
    .dw BeginTitleMenuGroup
    .dw DrawLevelNumber, DrawDebugDigit, DrawDebugNumber
    .dw RebuildGameWindow, OpenGameWindow, CloseGameWindow

; 이전 메뉴의 팔레트 전환과 새 묶음 초기화
BeginTitleMenuGroup:
    lda #$55
    ldx #$00
    jsr $C054
    pha
    lda #$00
    sta NextBgTile
    sta BufferedBytes
    sta NumberTilesReady
    sta BlackNameSlot
    sta GameTextMode
    lda #$FF
    sta InspectionFontBank
    sta GlyphInkMask
    pla
    rts

; 등록 목록 한 창에서만 하이픈 재사용. 출력 후 다른 창과 공유하지 않음
DrawRegistrationList:
    lda #RegistrationDashPending
    sta InspectionGlyphCount
    jsr $C04B
    .db $04
    .dw $9EB4
    php
    pha
    lda #$FF
    sta InspectionGlyphCount
    pla
    plp
    rts

; 엔딩 크레딧 두 창의 글리프 배치를 함께 초기화
; 이전 두 창은 원본 $BC50에서 모두 닫힘. 오른쪽 창을 열 때는 초기화하지 않음
PrepareEndingCredits:
    lda #$00
    sta GameTextMode
    jsr ResetTextTiles
    lda #EndingTextFirstTile
    sta NextBgTile
    ldx $0565
    rts

; 선택 커서 활성화와 반복 출력 영역의 시작점 기록
InitializeMenuRedraw:
    lda #$81
    sta $0406
    lda NextBgTile
    sta RedrawBgTile
    lda #$FF
    sta RedrawSelection
    rts

; 변경된 선택 항목에 같은 BG 타일 영역 배정
; 선택이 바뀌면 A에 선택 번호보다 1 큰 값 반환. 그대로면 0 반환
PrepareMenuRedraw:
    lda $AF
    cmp RedrawSelection
    beq PrepareMenuRedraw_Unchanged
    sta RedrawSelection
    lda RedrawBgTile
    sta NextBgTile
    lda $AF
    clc
    adc #$01
    rts
PrepareMenuRedraw_Unchanged:
    lda #$00
    rts

; 메뉴 묶음의 타일 인덱스 초기화
ResetTextTiles:
    lda #$00
    sta NextBgTile
    sta BufferedBytes
    sta UploadBytes
    sta NumberTilesReady
    sta $B1
    sta BlackNameSlot
    lda GameTextMode
    beq ResetTextTiles_Ink
    lda #$01
    sta GameTextMode
    jsr IsBattleScreen
    bne ResetTextTiles_Map
    lda BattleHudEnd
    bne ResetTextTiles_Start
ResetTextTiles_Map:
    lda #$60
ResetTextTiles_Start:
    sta NextBgTile
    sta GameWindowTiles
    sta GameWindowNext
ResetTextTiles_Ink:
    lda #$FF
    sta GlyphInkMask
    sta InspectionGlyphCount
    lda #$C0
    rts

; 문자열 바이트 읽기와 행 끝 전송
ReadTextLeadByte:
    ldy $18
    jsr ReadTextByte
    sta $1A
    cmp #$70
    beq ReadTextLeadByte_Flush
    cmp #$71
    bne ReadTextLeadByte_Return
ReadTextLeadByte_Flush:
    jsr FlushGlyphBuffer
ReadTextLeadByte_Return:
    lda $1A
    rts

; 1바이트 공백과 2바이트 고유번호 읽기
RenderKoreanCharacter:
    lda $1A
    sta GlyphCodeHigh
    cmp #$FF
    beq RenderKoreanCharacter_Draw
    inc $18
    ldy $18
    jsr ReadTextByte
RenderKoreanCharacter_Draw:
    jsr PrepareGlyph
    rts

; 삽입 문자열 주소를 따라 공백, 숫자, 글리프 출력
RenderInsertedText:
    lda $0F
    pha
    lda $10
    pha
    jsr ResolveInsertedText
    ldy #$00
RenderInsertedText_Read:
    jsr ReadTextByte
    cmp #$70
    beq RenderInsertedText_End
    sta GlyphCodeHigh
    cmp #$FF
    beq RenderInsertedText_Draw
    cmp #$60
    bcc RenderInsertedText_Pair
    cmp #$6A
    bcs RenderInsertedText_Pair
    sec
    sbc #($60 - DigitCodeLow)
    ldx #$83
    stx GlyphCodeHigh
    bne RenderInsertedText_Draw
RenderInsertedText_Pair:
    iny
    jsr ReadTextByte
RenderInsertedText_Draw:
    tax
    tya
    pha
    txa
    jsr PrepareGlyph
    pla
    tay
    inc $19
    iny
    bne RenderInsertedText_Read
RenderInsertedText_End:
    pla
    sta $10
    pla
    sta $0F

; $03D4 또는 $03DD의 삽입 이름 바로 뒤에 있는 '은/을' 확인
RenderInsertedParticle:
    lda $17
    cmp #$03
    bne RenderInsertedParticle_End
    lda $16
    cmp #$D4
    beq RenderInsertedParticle_Read
    cmp #$DD
    bne RenderInsertedParticle_End
RenderInsertedParticle_Read:
    ldy $18
    iny
    jsr ReadTextByte
    cmp #$89
    bne RenderInsertedParticle_End
    iny
    jsr ReadTextByte
    cmp #$5B
    beq RenderInsertedParticle_Search
    cmp #$5C
    bne RenderInsertedParticle_End

; '은/을'의 하위 바이트를 보관하고 삽입 슬롯의 이름 주소 검색
RenderInsertedParticle_Search:
    pha
    ldy #$00
    lda ($16),y
    bne RenderInsertedParticle_Change
    ldx #$00
RenderInsertedParticle_FindName:
    ldy #$01
    lda ($16),y
    cmp NameTable,x
    bne RenderInsertedParticle_NextName
    iny
    lda ($16),y
    cmp NameTable+1,x
    beq RenderInsertedParticle_Keep
RenderInsertedParticle_NextName:
    inx
    inx
    cpx #(NameTableEnd - NameTable)
    bne RenderInsertedParticle_FindName

; 목록에 없는 이름 뒤의 '은/을'을 '는/를' 글리프로 출력
RenderInsertedParticle_Change:
    pla
    cmp #$5B
    beq RenderInsertedParticle_Neun
    lda #$86
    sta GlyphCodeHigh
    lda #$54
    bne RenderInsertedParticle_Draw
RenderInsertedParticle_Neun:
    lda #$84
    sta GlyphCodeHigh
    lda #$F7
RenderInsertedParticle_Draw:
    jsr PrepareGlyph
    inc $18
    inc $18
    inc $19
    rts
RenderInsertedParticle_Keep:
    pla
RenderInsertedParticle_End:
    rts

; '은/을'을 그대로 출력할 고정 이름의 문자열 주소
NameTable:
    .dw Text_416, Text_417, Text_418 	; 그라탱, 쟝, 킹
    .dw Text_421, Text_422, Text_424 	; 측근, 가고일, 바벨탑
    .dw Text_427, Text_429 				; 게로봇, 대장
    .dw Text_430, Text_431 				; 참, 타오참
    .dw Text_438, Text_439, Text_440 	; 힐, 타오힐, 롱
    .dw Text_446, Text_447 				; 참, 타오참
    .dw Text_454, Text_455, Text_456 	; 힐, 타오힐, 롱
    .dw Text_462, Text_464, Text_468 	; 샷건, 폭탄, 나뭇잎
    .dw Text_470, Text_472, Text_476 	; 샷건, 폭탄, 나뭇잎
NameTableEnd:
