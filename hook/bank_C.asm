.bank $0C, $8000

; 인게임 문자열의 타일 영역과 행 간격 설정
.org $9491
    jsr $C04B
    .db $10
    .dw BeginGameText

; 인게임 메시지의 표시 글자 수 계산
.org $94CC
    jsr $C04B
    .db $10
    .dw MeasureGameText
    rts

; 조사 숫자를 상단과 하단 타일로 기록
.org $955E
    jsr $C04B
    .db $10
    .dw DrawStatusNumber
    rts

; 첫째 캐릭터 이름의 문자열 주소 기록
.org $98EE
    jsr $990E
    ldx #$09
    jsr $C04B
    .db $10
    .dw StoreCharacterName
    rts
    .fill $98FE - ., $EA

; 둘째 캐릭터 이름의 문자열 주소 기록
.org $98FE
    jsr $990E
    ldx #$12
    jsr $C04B
    .db $10
    .dw StoreCharacterName
    rts
    .fill $990E - ., $EA

; 기술 목록의 한글 문자열 주소
.org $9B0D
    .dw Text_430, Text_431, Text_432, Text_433
    .dw Text_434, Text_435, Text_436, Text_437
    .dw Text_438, Text_439, Text_440, Text_441
    .dw Text_442, Text_443, Text_444, Text_445

; 아이템 목록의 한글 문자열 주소
.org $9D24
    .dw Text_462, Text_463, Text_464, Text_465
    .dw Text_466, Text_467, Text_468, Text_469