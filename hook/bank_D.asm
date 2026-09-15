.bank $0D, $A000
; 메뉴 묶음의 타일 인덱스 초기화
.org $A6E0
    jsr ResetTextBridge
    nop
    nop
    nop

; 현재 창의 글리프 배치 시작점으로 복귀
.org $A6ED
    jsr RebuildGameWindowBridge

; 새 창의 글리프 배치 시작점 기록
.org $A6FA
    jsr OpenGameWindowBridge

; 닫은 창의 글리프 타일 회수
.org $A79A
    jsr CloseGameWindowBridge