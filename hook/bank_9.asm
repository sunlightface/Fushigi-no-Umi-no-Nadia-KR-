.bank $09, $A000
; 둘째 플레이어의 이름 목록에서 첫째 플레이어가 고른 이름을 검정으로 표시
.org $AD2E
DrawSecondPlayerNames:
    lda $AD
    sta BlackNameSlot
    jsr $AD5F
    lda #$00
    sta BlackNameSlot
    rts

; 입력: $15=저장 이름 번호, $0F/$10=이름 문자열 주소
DrawSavedName:
    lda #$FF
    sta GlyphInkMask
    lda BlackNameSlot
    cmp $15
    bne DrawSavedName_Text
    lda #$00
    sta GlyphInkMask
DrawSavedName_Text:
    jsr $C018
    lda #$FF
    sta GlyphInkMask
    rts
    .fill $AD5F - ., $EA

; 저장 이름 한 개의 글자색 지정과 출력
.org $ADA0
    jsr DrawSavedName

; 등록보기 LV의 두 자리 숫자 출력
.org $A2F4
    jsr DrawLevelNumberBridge
    .fill $A2FF - ., $EA

; 디버그 전술의 한 자리 숫자 출력
.org $B694
    jsr DrawDebugDigitBridge
    nop

; 디버그 행동의 두 자리 숫자 출력
.org $B74D
    jsr DrawDebugNumberBridge
    .fill $B756 - ., $EA

; 번호판 한 행의 2바이트 숫자 문자열 출력
.org $AB23
    jsr $C04B
    .db $10
    .dw DrawStageNumberRow
    .fill $AB2E - ., $EA
.org $AB86
    jsr $C04B
    .db $10
    .dw DrawStageNumberRow
    .fill $AB91 - ., $EA

; 완료한 스테이지의 하이픈 표시
.org $AB5C
    jsr $C04B
    .db $10
    .dw DrawStageClearMark
.org $ABBF
    jsr $C04B
    .db $10
    .dw DrawStageClearMark

; 저장 이름의 복사 길이
.org $ADF0
    cpx #$08

; 이름을 저장할 SRAM 시작 주소 6개
; 각 주소의 저장 공간: 등록 확인값 4바이트, 이름 8바이트, 종료 코드 1바이트
.org $AE10
    .dw $7F00, $7F0D, $7F1A, $7F27, $7F34, $7F41

; 입력판 페이지 전환
.org $AE52
    jsr SwitchKeyboardBridge

; 이름 입력 종료
.org $AE60
    jmp $AE6B

; A 입력은 요청만 기록. 조합과 이름 위치 이동은 메인 루프에서 처리
.org $B877
    jsr $C04B
    .db $10
    .dw SelectNameKey
    jmp $B8F2

; 원본 입력 속도 판정 이후 유효한 입력 칸으로 이동
KeyboardMoveBridge:
    jsr $C04B
    .db $10
    .dw MoveKeyboardCursor
    ldx #$01
    jsr $9042
    rts
    .fill $B895 - ., $EA

; B 입력도 메인 루프에서 한 글자씩 분해하도록 요청
.org $B8A5
    jsr $C04B
    .db $10
    .dw QueueNameBackspace
    jmp $B8F2
    .fill $B8B3 - ., $EA

; 위, 아래, 왼쪽, 오른쪽의 원본 반복 대기 다음 호출
.org $B8C3
    ldx #$00
    jsr KeyboardMoveBridge
.org $B8D0
    ldx #$01
    jsr KeyboardMoveBridge
.org $B8DD
    ldx #$02
    jsr KeyboardMoveBridge
.org $B8EA
    ldx #$03
    jsr KeyboardMoveBridge

; 이름 미리보기 초기화
.org $B8F6
    jsr $C04B
    .db $10
    .dw InitializeNamePreview
    rts

; 엔딩의 역할 창과 이름 창을 한 묶음으로 준비
; 원본 $BC6C 표의 왼쪽 창 번호는 $0565와 같은 $00, $02, ... $0E
.org $BC31
    jsr $C04B
    .db $10
    .dw PrepareEndingCredits
    nop
