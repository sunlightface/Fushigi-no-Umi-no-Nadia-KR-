.bank $0A, $8000

; 전투 이름과 수치의 글리프 준비
.org $8265
    jsr BeginBattleTextBridge
    nop

; 전투 참가 캐릭터의 이름과 H, M 수치 출력
.org $816B
    jsr $C04B
    .db $10
    .dw DrawBattleStatus
    rts