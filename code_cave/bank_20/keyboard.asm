; 선택한 칸의 고유번호를 자판 표에서 직접 읽음
ReadSelectedKey:
    lda InputTableLo
    sta $0F
    lda InputTableHi
    sta $10
    ldy InputKeyIndex
    lda ($0F),y
    pha
    inc $10
    lda ($0F),y
    sta GlyphCodeHigh
    pla
    rts

; 입력 종료 시 '다음'으로 넘긴 빈 칸을 1바이트 FF 공백으로 저장
PackInputNameSpaces:
    ldx #$00
    ldy #$00
PackInputNameSpaces_Copy:
    lda $03D4,x
    sta $03D4,y
    iny
    cmp #$FF
    beq PackInputNameSpaces_Next
    lda $03D5,x
    sta $03D4,y
    iny
PackInputNameSpaces_Next:
    inx
    inx
    cpx #$08
    bne PackInputNameSpaces_Copy
    lda #$70
    sta $03D4,y
    rts

; 현재 페이지의 행 정보와 고유번호 표 주소를 ROM에서 읽음
LoadKeyboardLayout:
    lda $AF
    asl a
    tax
    lda KeyboardPagePointers,x
    sta $0F
    lda KeyboardPagePointers+1,x
    sta $10
    ldy #$00
    lda ($0F),y
    sta KeyboardRowCount
    iny
    lda ($0F),y
    sta KeyboardNextRow
    iny
    lda ($0F),y
    sta KeyboardNextCol
    iny
    lda ($0F),y
    sta InputTableLo
    iny
    lda ($0F),y
    sta InputTableHi
    iny
    ldx #$00
LoadKeyboardLayout_MaskLo:
    lda ($0F),y
    sta KeyboardMaskLo,x
    iny
    inx
    cpx #$10
    bne LoadKeyboardLayout_MaskLo
    ldx #$00
LoadKeyboardLayout_MaskHi:
    lda ($0F),y
    sta KeyboardMaskHi,x
    iny
    inx
    cpx #$10
    bne LoadKeyboardLayout_MaskHi
    ldx #$00
LoadKeyboardLayout_Widths:
    lda ($0F),y
    sta KeyboardRowWidths,x
    iny
    inx
    cpx #$10
    bne LoadKeyboardLayout_Widths

; 첫 번째 유효한 입력 칸으로 커서 위치 설정
ResetKeyboardCursor:
    lda #$00
    sta $0414
    sta $0415
ResetKeyboardCursor_Row:
    ldx $0415
    lda KeyboardRowWidths,x
    bne ResetKeyboardCursor_Column
    inc $0415
    lda $0415
    cmp KeyboardRowCount
    bcc ResetKeyboardCursor_Row
    lda #$00
    sta $0415
    jmp UpdateKeyboardPosition
ResetKeyboardCursor_Column:
    jsr IsKeyboardCell
    bne UpdateKeyboardPosition
    inc $0414
    bne ResetKeyboardCursor_Column

; 유효한 글자 또는 버튼이면 Z 플래그 해제. 문자열과 폰트는 읽지 않음
IsKeyboardCell:
    ldx $0415
    lda $0414
    and #$07
    tay
    lda $0414
    cmp #$08
    bcs IsKeyboardCell_High
    lda KeyboardMaskLo,x
    and KeyboardColumnBits,y
    rts
IsKeyboardCell_High:
    lda KeyboardMaskHi,x
    and KeyboardColumnBits,y
    rts

; 현재 행과 열을 layout의 시작 좌표와 이동 간격으로 변환
UpdateKeyboardPosition:
    lda #KeyboardCursorX
    ldx $0414
UpdateKeyboardPosition_X:
    cpx #$00
    beq UpdateKeyboardPosition_StoreX
    clc
    adc #KeyboardCursorStepX
    dex
    bne UpdateKeyboardPosition_X
UpdateKeyboardPosition_StoreX:
    sta $0418
    lda #KeyboardCursorY
    ldx $0415
UpdateKeyboardPosition_Y:
    cpx #$00
    beq UpdateKeyboardPosition_StoreY
    clc
    adc #KeyboardCursorStepY
    dex
    bne UpdateKeyboardPosition_Y
UpdateKeyboardPosition_StoreY:
    sta $0419
    rts

; 원본 키 반복 간격 유지. X의 0~3은 위, 아래, 왼쪽, 오른쪽 순서
MoveKeyboardCursor:
    stx KeyboardDirection
    lda $0415
    sta KeyboardStartRow
    lda $0414
    sta KeyboardStartCol
    cpx #$02
    bcc MoveKeyboardCursor_Vertical
    ldx $0415
    lda KeyboardRowWidths,x
    bne MoveKeyboardCursor_Horizontal
    rts
MoveKeyboardCursor_Horizontal:
    lda KeyboardDirection
    cmp #$02
    bne MoveKeyboardCursor_Right
    lda $0414
    bne MoveKeyboardCursor_Left
    ldx $0415
    lda KeyboardRowWidths,x
    sta $0414
MoveKeyboardCursor_Left:
    dec $0414
    jmp MoveKeyboardCursor_Check
MoveKeyboardCursor_Right:
    inc $0414
    ldx $0415
    lda $0414
    cmp KeyboardRowWidths,x
    bcc MoveKeyboardCursor_Check
    lda #$00
    sta $0414
MoveKeyboardCursor_Check:
    jsr IsKeyboardCell
    beq MoveKeyboardCursor_Horizontal
    jmp UpdateKeyboardPosition
MoveKeyboardCursor_Vertical:
    lda KeyboardDirection
    bne MoveKeyboardCursor_Down
    lda $0415
    bne MoveKeyboardCursor_Up
    lda KeyboardRowCount
    sta $0415
MoveKeyboardCursor_Up:
    dec $0415
    jmp MoveKeyboardCursor_Row
MoveKeyboardCursor_Down:
    inc $0415
    lda $0415
    cmp KeyboardRowCount
    bcc MoveKeyboardCursor_Row
    lda #$00
    sta $0415
MoveKeyboardCursor_Row:
    lda $0415
    cmp KeyboardStartRow
    beq MoveKeyboardCursor_End
    tax
    lda KeyboardRowWidths,x
    beq MoveKeyboardCursor_Vertical
    sec
    sbc #$01
    cmp KeyboardStartCol
    bcc MoveKeyboardCursor_Column
    lda KeyboardStartCol
MoveKeyboardCursor_Column:
    sta $0414
MoveKeyboardCursor_Clamp:
    jsr IsKeyboardCell
    bne MoveKeyboardCursor_Update
    lda $0414
    beq MoveKeyboardCursor_Forward
    dec $0414
    bpl MoveKeyboardCursor_Clamp
MoveKeyboardCursor_Forward:
    inc $0414
    jsr IsKeyboardCell
    beq MoveKeyboardCursor_Forward
MoveKeyboardCursor_Update:
    jmp UpdateKeyboardPosition
MoveKeyboardCursor_End:
    rts

; 열 번호의 하위 세 비트에 대응하는 유효 칸 비트
KeyboardColumnBits:
    .db $01, $02, $04, $08, $10, $20, $40, $80
