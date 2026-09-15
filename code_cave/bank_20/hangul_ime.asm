; 선택한 초성, 중성, 종성의 후보만 수정. 조회 실패 시 원래 상태 유지
ComposeSelectedJamo:
    cmp #ImeJungFirst
    bcs ComposeSelectedJamo_Vowel
    sec
    sbc #(ImeChoFirst - 1)
    sta ImeCandidateCho
    lda ImeCandidateJung
    bne ComposeSelectedJamo_Resolve
    beq ComposeSelectedJamo_ClearFinal
ComposeSelectedJamo_Vowel:
    cmp #ImeJongFirst
    bcs ComposeSelectedJamo_Final
    sec
    sbc #(ImeJungFirst - 1)
    sta ImeCandidateJung
    lda ImeCandidateCho
    bne ComposeSelectedJamo_Resolve
ComposeSelectedJamo_ClearFinal:
    lda #$00
    sta ImeCandidateJong
    beq ComposeSelectedJamo_Resolve
ComposeSelectedJamo_Final:
    sec
    sbc #(ImeJongFirst - 1)
    sta ImeCandidateJong
    lda ImeCandidateCho
    beq ComposeSelectedJamo_Reject
    lda ImeCandidateJung
    beq ComposeSelectedJamo_Reject
ComposeSelectedJamo_Resolve:
    jsr ResolveNameComposition
    bcc ComposeSelectedJamo_Reject
    jsr CommitNameComponents
    jmp PollNameInput_Write
ComposeSelectedJamo_Reject:
    jmp PollNameInput_Finish

; B: 종성, 중성, 초성 순으로 제거. 이미 빈 칸이면 이전 칸으로만 이동
DeleteNameComponent:
    lda ImeCandidateJong
    beq DeleteNameComponent_Vowel
    lda #$00
    sta ImeCandidateJong
    beq ComposeSelectedJamo_Resolve
DeleteNameComponent_Vowel:
    lda ImeCandidateJung
    beq DeleteNameComponent_Initial
    lda #$00
    sta ImeCandidateJung
    beq ComposeSelectedJamo_Resolve
DeleteNameComponent_Initial:
    lda ImeCandidateCho
    beq DeleteNameComponent_Direct
    lda #$00
    sta ImeCandidateCho
    beq ComposeSelectedJamo_Resolve
DeleteNameComponent_Direct:
    lda InputNameSlot
    asl a
    tax
    lda $03D4,x
    cmp #$FF
    bne ComposeSelectedJamo_Resolve
    lda $2C
    beq ComposeSelectedJamo_Reject
    dec $2C
    jsr UpdateNameSlotCursor
    jmp PollNameInput_Finish

; 결과 글리프를 보존하면서 현재 칸의 조합 상태 확정
CommitNameComponents:
    pha
    ldx InputNameSlot
    lda ImeCandidateCho
    sta ImeCho,x
    lda ImeCandidateJung
    sta ImeJung,x
    lda ImeCandidateJong
    sta ImeJong,x
    pla
    rts

; 이름 칸 커서는 layout 값을 사용. 네 칸 완료 시 마지막 칸에 유지
UpdateNameSlotCursor:
    lda $2C
    sta $2A
    cmp #$04
    bcc UpdateNameSlotCursor_Position
    rts
UpdateNameSlotCursor_Position:
    sta $0421
    tax
    lda #InputNameCursorX
UpdateNameSlotCursor_X:
    cpx #$00
    beq UpdateNameSlotCursor_Store
    clc
    adc #InputNameCursorStepX
    dex
    bne UpdateNameSlotCursor_X
UpdateNameSlotCursor_Store:
    sta $0425
    ldx #$01
    jsr $C04B
    .db $04
    .dw $9042 ; 원본 이름 칸 이동 효과음 유지
    rts

; 후보를 완성형 또는 단독 자모로 변환. 성공하면 C 설정, 없으면 해제
; GlyphCodeHigh와 A에 고유번호의 상위 바이트와 하위 바이트 반환
ResolveNameComposition:
    lda #ImeJamoHigh
    sta GlyphCodeHigh
    lda ImeCandidateCho
    beq ResolveNameComposition_Vowel
    ldx ImeCandidateJung
    bne LookupHangulCode
    clc
    adc #(ImeChoFirst - 1)
    sec
    rts
ResolveNameComposition_Vowel:
    lda ImeCandidateJung
    beq ResolveNameComposition_Blank
    clc
    adc #(ImeJungFirst - 1)
    sec
    rts
ResolveNameComposition_Blank:
    lda #$FF
    sta GlyphCodeHigh
    sec
    rts

; 초성 묶음 588칸과 중성 묶음 28칸에 종성 번호를 더해 조합키 계산
; $31에서 조합키를 이진 검색하고 같은 위치의 $32 고유번호 조회
; 검색 중에만 NMI와 IRQ를 막아 임시 PRG 매핑과 영 페이지 계산값 보호
; PRG $20의 실행 코드는 유지하고 $A000 창만 바꾼 뒤 원래 $21로 복원
LookupHangulCode:
    php
    sei
    lda $00
    and #$7F
    sta $2000
    lda ImeCandidateCho
    sec
    sbc #$01
    asl a
    tax
    lda ImeInitialKeys,x
    sta $11
    lda ImeInitialKeys+1,x
    sta $12
    lda ImeCandidateJung
    sec
    sbc #$01
    asl a
    tax
    clc
    lda $11
    adc ImeVowelKeys,x
    sta $11
    lda $12
    adc ImeVowelKeys+1,x
    sta $12
    clc
    lda $11
    adc ImeCandidateJong
    sta $11
    lda $12
    adc #$00
    sta $12
    lda #$07
    ora $2D
    sta $8000
    lda #$31
    sta $8001
    lda #$00
    sta $09
    sta $0A
    lda #(((HangulKeysEnd - HangulKeys) / 2) & $FF)
    sta $0B
    lda #(((HangulKeysEnd - HangulKeys) / 2) / $100)
    sta $0C
LookupHangulCode_Search:
    lda $0A
    cmp $0C
    bcc LookupHangulCode_Middle
    bne LookupHangulCode_Missing
    lda $09
    cmp $0B
    bcs LookupHangulCode_Missing
LookupHangulCode_Middle:
    clc
    lda $09
    adc $0B
    sta $0D
    lda $0A
    adc $0C
    lsr a
    sta $0E
    ror $0D
    lda $0D
    asl a
    sta $15
    lda $0E
    rol a
    clc
    adc #$A0
    sta $16
    ldy #$01
    lda ($15),y
    cmp $12
    bcc LookupHangulCode_Lower
    bne LookupHangulCode_Upper
    dey
    lda ($15),y
    cmp $11
    beq LookupHangulCode_Found
    bcc LookupHangulCode_Lower
LookupHangulCode_Upper:
    lda $0D
    sta $0B
    lda $0E
    sta $0C
    jmp LookupHangulCode_Search
LookupHangulCode_Lower:
    clc
    lda $0D
    adc #$01
    sta $09
    lda $0E
    adc #$00
    sta $0A
    jmp LookupHangulCode_Search
LookupHangulCode_Found:
    lda #$32
    sta $8001
    ldy #$00
    lda ($15),y
    sta $13
    iny
    lda ($15),y
    sta GlyphCodeHigh
    lda #$01
    bne LookupHangulCode_Restore
LookupHangulCode_Missing:
    lda #$00
LookupHangulCode_Restore:
    sta $14
    lda #$21
    sta $8001
    lda $00
    sta $2000
    plp
    lda $14
    beq LookupHangulCode_Failed
    lda $13
    sec
    rts
LookupHangulCode_Failed:
    clc
    rts

; 현재 자모 순서에 대응하는 조합키의 초성 부분과 중성 부분
ImeInitialKeys:
    .dw 0, 588, 1176, 1764, 2352, 2940, 3528, 4116, 4704, 5292
    .dw 5880, 6468, 7056, 7644, 8232, 8820, 9408, 9996, 10584
ImeVowelKeys:
    .dw 0, 28, 56, 84, 112, 140, 168, 196, 224, 252, 280
    .dw 308, 336, 364, 392, 420, 448, 476, 504, 532, 560
