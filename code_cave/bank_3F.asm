.bank $3F, $E000

; 삽입 문자열의 원본 주소 기록
.org $EB25
    jsr $C04B
    .db $10
    .dw StoreInsertedText
    rts
; 디버그에서 변경한 숫자의 VBlank 출력
.org $E243
    jsr $C04B
    .db $10
    .dw UploadDebugNumber
    rts

; 문자열 첫 바이트 읽기
.org $EA4B
    jsr ReadTextBridge
    sta $1A
    nop

; $72~$76의 삽입 문자열 읽기
.org $EAA3
    jsr InsertTextBridge
    jmp $EABA

; 2바이트 고유번호 출력
.org $EAC9
    jmp RenderTextBridge	

; 첫째와 둘째 이름 버퍼에 저장 이름 복사
; $0D/$0E의 이름 8바이트를 $03D4 또는 $03DD에 복사하고 $70으로 끝냄
.org $EACC
CopyFirstSavedName:
    ldx #$09
    bne CopySavedName
CopySecondSavedName:
    ldx #$12
CopySavedName:
    ldy #$00
CopySavedName_Byte:
    lda ($0D),y
    sta $03CB,x
    iny
    inx
    cpy #$08
    bne CopySavedName_Byte
    lda #$70
    sta $03CB,x
    rts

; LV 출력 함수 호출
DrawLevelNumberBridge:
    lda #$09
    jmp CallTextBank

; 디버그 숫자 출력과 원본 반복문의 X 보존
DrawDebugDigitBridge:
    txa
    pha
    lda #$0A
    jsr CallTextBank
    pla
    tax
    rts
DrawDebugNumberBridge:
    txa
    pha
    lda #$0B
    jsr CallTextBank
    pla
    tax
    rts

; 인게임 창을 다시 만들 때의 글리프 배치 처리
RebuildGameWindowBridge:
    lda #$0C
    jmp CallTextBank

; 인게임 새 창의 글리프 배치 처리
OpenGameWindowBridge:
    lda #$0D
    jmp CallTextBank

; 인게임 창을 닫은 뒤의 글리프 배치 처리
CloseGameWindowBridge:
    lda #$0E
    jmp CallTextBank

; 등록 목록의 하이픈 재사용 처리 호출. X의 원본 창 번호는 유지
DrawRegistrationListBridge:
    jsr $C04B
    .db $10
    .dw DrawRegistrationList
    rts

; 문자열 코드 뱅크 호출과 복귀
.org $FF1B
ReadTextBridge:
    lda #$00
    beq CallTextBank
RenderTextBridge:
    lda #$01
    bne CallTextBank
InsertTextBridge:
    lda #$02
    bne CallTextBank
ResetTextBridge:
    lda #$03
    bne CallTextBank
PollNameInputBridge:
    lda #$04
    bne CallTextBank
SwitchKeyboardBridge:
    lda #$05
    bne CallTextBank
InitializeMenuRedrawBridge:
    lda #$06
    bne CallTextBank
PrepareMenuRedrawBridge:
    lda #$07
    bne CallTextBank
BeginTitleMenuBridge:
    lda #$08

CallTextBank:
    php
    pha
    lda $4A
    pha
    lda $4B
    pha
    sei
    lda $00
    and #$7F
    sta $2000
    lda #$10
    sta $4A
    sta $4B
    lda #$06
    ora $2D
    sta $8000
    lda #$20
    sta $8001
    lda #$07
    ora $2D
    sta $8000
    lda #$21
    sta $8001
    lda $00
    sta $2000
    tsx
    lda $0104,x
    pha
    plp
    lda $0103,x
    jsr TextBankDispatch
    sta TextResult

    sei
    lda $00
    and #$7F
    sta $2000
    pla
    sta $4B
    pla
    sta $4A
    asl a
    tax
    lda #$06
    ora $2D
    sta $8000
    stx $8001
    lda #$07
    ora $2D
    sta $8000
    inx
    stx $8001
    dex
    pla
    lda $00
    sta $2000
    plp
    lda TextResult
    rts

; 변경된 스테이지 설명창 출력
RedrawStageCaptionBridge:
    jsr PrepareMenuRedrawBridge
    beq RedrawStageCaption_End
    ldx #$2C
    jmp $9EB4
RedrawStageCaption_End:
    rts

; 등록보기 상세창의 첫 타일 기록
OpenRegistrationPopupBridge:
    lda NextBgTile
    sta RegistrationPopupTile
    jmp $9EB4

; 상세창 타일 인덱스 회수와 창 닫기
CloseRegistrationPopupBridge:
    lda RegistrationPopupTile
    sta NextBgTile
    jmp $9065
