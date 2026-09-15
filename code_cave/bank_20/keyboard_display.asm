; 이름 4글자의 BG 영역 배정과 입력판 표시
ShowNameKeyboard:
    lda #$00
    sta $AF
    ldx #$0A
    jsr $C04B
    .db $04
    .dw $9EB4
    lda NextBgTile
    sta NameTileBase
    clc
    adc #$08
    sta NextBgTile
    sta RedrawBgTile
    ldx #$0C
    jsr $C04B
    .db $04
    .dw $9EB4
    jsr LoadKeyboardLayout
    rts


; 입력판만 숨긴 뒤 폰트와 타일 배치를 끝내고 속성을 한 번에 복원
; 한글과 영어 입력판은 원본처럼 같은 창 위치와 크기를 사용
SwitchKeyboardPage:
    jsr FlushGlyphBuffer
    ldx #$1A
    jsr $C04B
    .db $04
    .dw $AEFC ; 입력판 커서 슬롯 $1A 숨김. 이름 칸 슬롯 $27은 유지
    lda #$01
    jsr WaitKeyboardTransfer
    jsr HideKeyboardAttributes
    lda #$02
    jsr WaitKeyboardTransfer

    lda RedrawBgTile
    sta NextBgTile
    jsr $C04B
    .db $06
    .dw $A6ED ; 현재 입력판의 RAM 창 버퍼만 초기화
    lda $AF
    asl a
    clc
    adc #$0C
    tax
    jsr $C04B
    .db $04
    .dw $A32D ; 문자열만 준비. 원본의 행별 창 공개는 호출하지 않음
    jsr LoadKeyboardLayout

    ; 원본 창 버퍼를 직접 전송할 주소와 크기 준비
    lda $B4
    sta $D0
    lda $B5
    sta $D1
    lda $B8
    asl a
    sta $D4
    lda $B9
    asl a
    sta $D5
    lda $BA
    asl a
    sta $DA
    lda $BB
    asl a
    asl a
    asl a
    asl a
    asl a
    asl a
    ora $DA
    sta $DA
    lda $BB
    lsr a
    lsr a
    clc
    adc #$20
    sta $DB
    lda #$03
    jsr WaitKeyboardTransfer
    lda #$04
    jsr WaitKeyboardTransfer
    ldx #$1A
    jsr $C04B
    .db $04
    .dw $AEF6 ; 완성된 입력판의 커서 다시 활성화
    rts

; NMI가 직접 부르는 함수도 같은 PRG $20에 있으므로 여기서만 전송 대기
; 완료 후 원본 대기 항목 $04로 돌아간 다음에만 다른 뱅크 호출 허용
WaitKeyboardTransfer:
    sta KeyboardTransferState
    lda #$50
    sta $50
WaitKeyboardTransfer_Wait:
    lda KeyboardTransferState
    bne WaitKeyboardTransfer_Wait
    lda #$04
    sta $50
    rts

; 보관한 속성에서 입력판의 16x16 영역만 비활성 팔레트 1로 변경
; GlyphBuffer는 이 전송이 끝난 뒤부터 원래 폰트 버퍼로 다시 사용
HideKeyboardAttributes:
    ldx #$3F
HideKeyboardAttributes_Copy:
    lda KeyboardSavedAttrs,x
    sta GlyphBuffer,x
    dex
    bpl HideKeyboardAttributes_Copy
    lda $BB
    sta $09
    clc
    adc $B9
    sta $0A
    lda $BA
    clc
    adc $B8
    sta $0C
HideKeyboardAttributes_Row:
    lda $09
    and #$01
    asl a
    sta $0E
    lda $09
    lsr a
    asl a
    asl a
    asl a
    sta $0D
    lda $BA
    sta $0B
HideKeyboardAttributes_Column:
    lda $0B
    and #$01
    ora $0E
    tay
    lda $0B
    lsr a
    clc
    adc $0D
    tax
    lda GlyphBuffer,x
    and KeyboardAttributeMask,y
    ora KeyboardHiddenPalette,y
    sta GlyphBuffer,x
    inc $0B
    lda $0B
    cmp $0C
    bne HideKeyboardAttributes_Column
    inc $09
    lda $09
    cmp $0A
    bne HideKeyboardAttributes_Row
    rts
KeyboardAttributeMask:
    .db $FC, $F3, $CF, $3F
KeyboardHiddenPalette:
    .db $01, $04, $10, $40

; 입력판 전용 NMI: 공용 글리프 전송과 원본 창 전송 루틴은 변경하지 않음
UploadKeyboardPage:
    lda KeyboardTransferState
    bne UploadKeyboardPage_Start
    rts
UploadKeyboardPage_Start:
    bit $2002
    lda $00
    and #$FB
    sta $2000
    lda KeyboardTransferState
    cmp #$03
    bne UploadKeyboardPage_Attributes
    jmp UploadKeyboardPage_Rows
UploadKeyboardPage_Attributes:
    lda #$23
    sta $2006
    lda #$C0
    sta $2006
    ldx #$00
    lda KeyboardTransferState
    cmp #$01
    beq UploadKeyboardPage_Read
    cmp #$02
    beq UploadKeyboardPage_Hide
    ; 전체 속성 복원은 한 VBlank에서 끝내므로 자판 전체가 동시에 나타남
UploadKeyboardPage_Reveal:
    lda KeyboardSavedAttrs,x
    sta $2007
    inx
    cpx #$40
    bne UploadKeyboardPage_Reveal
    jmp UploadKeyboardPage_Done
UploadKeyboardPage_Read:
    lda $2007 ; PPU 읽기 버퍼의 이전 값은 버림
UploadKeyboardPage_ReadByte:
    lda $2007
    sta KeyboardSavedAttrs,x
    inx
    cpx #$40
    bne UploadKeyboardPage_ReadByte
    jmp UploadKeyboardPage_Done
UploadKeyboardPage_Hide:
    lda GlyphBuffer,x
    sta $2007
    inx
    cpx #$40
    bne UploadKeyboardPage_Hide
    jmp UploadKeyboardPage_Done

; 속성은 숨긴 채 유지하고 네임테이블만 한 번에 두 타일 행씩 전송
; $D0/$D1은 창 버퍼, $DA/$DB는 PPU 주소, $D4는 행 너비, $D5는 남은 행
UploadKeyboardPage_Rows:
    ldx #$02
UploadKeyboardPage_Row:
    lda $DB
    sta $2006
    lda $DA
    sta $2006
    ldy #$00
UploadKeyboardPage_Tile:
    lda ($D0),y
    sta $2007
    iny
    cpy $D4
    bne UploadKeyboardPage_Tile
    clc
    lda $D0
    adc $D4
    sta $D0
    lda $D1
    adc #$00
    sta $D1
    clc
    lda $DA
    adc #$20
    sta $DA
    bcc UploadKeyboardPage_NextRow
    inc $DB
UploadKeyboardPage_NextRow:
    dec $D5
    beq UploadKeyboardPage_Done
    dex
    bne UploadKeyboardPage_Row
    lda $00
    sta $2000
    rts
UploadKeyboardPage_Done:
    lda $00
    sta $2000
    lda #$00
    sta KeyboardTransferState
    rts
