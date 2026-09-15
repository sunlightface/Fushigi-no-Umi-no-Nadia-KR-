.bank $3E, $C000

; 조사 스탯의 고정 글자를 준비하고 문구와 수치를 출력
.org $CDA0
    jsr $C04B
    .db $10
    .dw DrawInspectionStatus
    nop
    nop

; ------------------------------------------------------------
; 조사 창은 능력치, 기술, 아이템 페이지를 겹치지 않고 교체
.org $CE31
    jsr $C04B
    .db $10
    .dw ReplaceInspectionWindow
.org $CE37
    jsr $C04B
    .db $10
    .dw DrawInspectionSkills
    .fill $CE4B - ., $EA

; 기술 페이지에서 B: 목록을 닫은 뒤 능력치 창을 다시 그림
.org $CE59
    jmp $CD7D

.org $CE89
    jsr $C04B
    .db $10
    .dw ReplaceInspectionWindow
.org $CE8F
    jsr $C04B
    .db $10
    .dw DrawInspectionItems
    .fill $CEA1 - ., $EA

; 아이템 페이지에서 B: 기술 페이지 진입 경로에서 교체와 재출력
.org $CEAC
    jmp $CE0A
    .fill $CEB2 - ., $EA

; 현재 플레이어의 등록 이름을 삽입 문자열로 지정
.org $C768
    jsr $C04B
    .db $10
    .dw GetGamePlayerName
    jmp $EB14

; 전투 글리프 초기화와 캐릭터 배치 반복문의 시작값 설정
.org $C771
BeginBattleTextBridge:
    jsr $C04B
    .db $10
    .dw InitializeBattleText
    ldx #$00
    ldy #$00
    rts

; 전투 이름 8칸 또는 H, M 수치 4칸의 상하단 전송
.org $D8D0
    lda $2A
    beq UploadBattleStatus_Start
    rts
UploadBattleStatus_Start:
    jsr $E467
    lda $2C
    asl a
    asl a
    asl a
    asl a
    clc
    adc $02E2
    tax
    lda $D966,x
    sta $96
    lda $D967,x
    sta $97
    ldy #$04
    lda $2C
    cmp #$02
    bne UploadBattleStatus_Width
    ldy #$08
UploadBattleStatus_Width:
    sty $95
    bit $2002
    lda $97
    sta $2006
    lda $96
    sta $2006
    ldx #$00
UploadBattleStatus_Top:
    lda $02E3,x
    sta $2007
    inx
    cpx $95
    bne UploadBattleStatus_Top
    clc
    lda $96
    adc #$20
    sta $96
    lda $97
    adc #$00
    sta $2006
    lda $96
    sta $2006
    ldx #$00
UploadBattleStatus_Bottom:
    lda $02EB,x
    sta $2007
    inx
    cpx $95
    bne UploadBattleStatus_Bottom
    lda #$FF
    sta $2A
    rts

; 글자 전송을 기다리는 동안에는 PRG $20이 이미 선택되어 있음
.org $D0CE
    .dw UploadGlyphBuffer, $0000

; 기존 미사용 항목 $50: 입력판 전환 전용. 대기는 항상 PRG $20에서 실행
.org $D0A2
    .dw UploadKeyboardPage, $0000

; 메인 루프에서 이름 미리보기 갱신
.org $DB6B
    jsr PollNameInputBridge
    beq $DB6B
