; 2바이트 이름 버퍼와 이름 칸 초기화
InitializeNamePreview:
    lda #$00
    sta InputPending
    ldx #$0F
InitializeNamePreview_Ime:
    sta ImeCho,x
    dex
    bpl InitializeNamePreview_Ime
    ldx #$00
InitializeNamePreview_Name:
    lda #$FF
    sta $03D4,x
    sta $03D5,x
    inx
    inx
    cpx #$08
    bne InitializeNamePreview_Name
    lda #$70
    sta $03DC
    ldx #$07
    lda #$FF
InitializeNamePreview_Blank:
    sta $02E8,x
    dex
    bpl InitializeNamePreview_Blank
    jsr ResetKeyboardCursor
    rts

; NMI: 유효 칸만 선택하고 '다음'은 글자 없는 한 칸 이동으로 기록
SelectNameKey:
    lda InputPending
    bne SelectNameKey_Ignore
    jsr IsKeyboardCell
    beq SelectNameKey_Ignore
    ldx $0415
    txa
    asl a
    asl a
    asl a
    asl a
    clc
    adc $0414
    sta InputKeyIndex
    lda #$01
    sta InputPending
    cpx KeyboardNextRow
    bne SelectNameKey_Record
    lda $0414
    cmp KeyboardNextCol
    bne SelectNameKey_Record
    inc InputPending
SelectNameKey_Record:
    lda $2C
    sta InputNameSlot
    lda #$01
    rts
SelectNameKey_Ignore:
    lda #$00
    rts

; NMI에서는 이름을 지우지 않고 현재 칸의 B 입력만 기록
QueueNameBackspace:
    lda InputPending
    bne QueueNameBackspace_End
    lda $2C
    sta InputNameSlot
    lda #$03
    sta InputPending
QueueNameBackspace_End:
    rts

; 메인 루프: 조합, 분해, 미리보기 갱신이 끝난 뒤에만 이름 위치 이동
PollNameInput:
    lda InputPending
    bne PollNameInput_Update
    lda $02E2
    rts
PollNameInput_Update:
    ; 계산 중에는 원본 키 입력 NMI를 쉬게 해서 요청과 미리보기 보호
    lda #$04
    sta $50
    lda #$00
    sta ImeAdvance
    ldx InputNameSlot
    lda ImeCho,x
    sta ImeCandidateCho
    lda ImeJung,x
    sta ImeCandidateJung
    lda ImeJong,x
    sta ImeCandidateJong
    lda InputPending
    cmp #$02
    bne PollNameInput_CheckBack
    jmp PollNameInput_Advance
PollNameInput_CheckBack:
    cmp #$03
    bne PollNameInput_Read
    jmp DeleteNameComponent
PollNameInput_Read:
    jsr ReadSelectedKey
    ldx $AF
    bne PollNameInput_Direct
    ldx GlyphCodeHigh
    cpx #ImeJamoHigh
    bne PollNameInput_Direct
    cmp #ImeChoFirst
    bcc PollNameInput_Direct
    cmp #ImeJongEnd
    bcs PollNameInput_Direct
    jmp ComposeSelectedJamo
PollNameInput_Direct:
    ; 영문과 숫자 등 일반 문자는 그대로 기록하고 해당 칸의 조합만 해제
    pha
    lda #$00
    sta ImeCandidateCho
    sta ImeCandidateJung
    sta ImeCandidateJong
    lda #$01
    sta ImeAdvance
    pla
    jsr CommitNameComponents
PollNameInput_Write:
    pha
    lda InputNameSlot
    asl a
    tay
    lda GlyphCodeHigh
    sta $03D4,y
    pla
    sta $03D5,y
    ldx GlyphCodeHigh
    cpx #$FF
    beq PollNameInput_Blank
    pha
    lda InputNameSlot
    asl a
    clc
    adc NameTileBase
    sta UploadTile
    pla
    jsr CopyGlyphToBuffer
    jsr FlushGlyphBuffer
    ldx InputNameSlot
    lda UploadTile
    sta $02E8,x
    clc
    adc #$01
    sta $02EC,x
    jmp PollNameInput_Done
PollNameInput_Blank:
    ldx InputNameSlot
    lda #$FF
    sta $02E8,x
    sta $02EC,x
PollNameInput_Done:
    lda ImeAdvance
    beq PollNameInput_Finish
PollNameInput_Advance:
    inc $2C
    jsr UpdateNameSlotCursor
    lda $2C
    cmp #$04
    bne PollNameInput_Finish
    jsr PackInputNameSpaces
    lda #$FF
    sta $02E2
PollNameInput_Finish:
    lda #$00
    sta InputPending
    lda #$60
    sta $50
PollNameInput_Return:
    lda $02E2
    rts
