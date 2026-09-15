; 입력판의 행 정보와 선택 글리프 고유번호
; tools/generate_keyboard.py로 생성
KeyboardPagePointers:
    .dw KeyboardKo, KeyboardEn

; Text_066의 행 수, 다음 버튼 행과 열, 글리프 표 주소
KeyboardKo:
    .db $09, $08, $00
    .dw KeyboardKoCodes
    ; 각 행에서 선택 가능한 0부터 7열
    .db $FF, $FF, $FF, $FF, $01, $FF, $FF, $7F, $01, $00, $00, $00, $00, $00, $00, $00
    ; 각 행에서 선택 가능한 8부터 15열
    .db $03, $01, $03, $03, $00, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00
    ; 각 행의 마지막 선택 칸 오른쪽 경계
    .db $0A, $09, $0A, $0A, $01, $0A, $0A, $07, $01, $00, $00, $00, $00, $00, $00, $00

KeyboardKoCodes:
    ; 행마다 16칸의 고유번호 하위 바이트
    .db $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $FF, $FF, $FF, $FF, $FF, $FF
    .db $9B, $9C, $9D, $9E, $9F, $A0, $A1, $A2, $A3, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $FF, $FF, $FF, $FF, $FF, $FF
    .db $AE, $AF, $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $FF, $FF, $FF, $FF, $FF, $FF
    .db $B8, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $B9, $BA, $BB, $BC, $BD, $BE, $BF, $C0, $C1, $C2, $FF, $FF, $FF, $FF, $FF, $FF
    .db $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $FF, $FF, $FF, $FF, $FF, $FF
    .db $CD, $CE, $CF, $D0, $D1, $D2, $D3, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    ; 같은 칸의 고유번호 상위 바이트
    .db $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $FF, $FF, $FF, $FF, $FF, $FF
    .db $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $FF, $FF, $FF, $FF, $FF, $FF
    .db $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $FF, $FF, $FF, $FF, $FF, $FF
    .db $8C, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $FF, $FF, $FF, $FF, $FF, $FF
    .db $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $FF, $FF, $FF, $FF, $FF, $FF
    .db $8C, $8C, $8C, $8C, $8C, $8C, $8C, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; Text_067의 행 수, 다음 버튼 행과 열, 글리프 표 주소
KeyboardEn:
    .db $07, $FF, $FF
    .dw KeyboardEnCodes
    ; 각 행에서 선택 가능한 0부터 7열
    .db $FF, $FF, $FF, $3F, $FF, $FF, $3F, $00, $00, $00, $00, $00, $00, $00, $00, $00
    ; 각 행에서 선택 가능한 8부터 15열
    .db $03, $03, $03, $00, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    ; 각 행의 마지막 선택 칸 오른쪽 경계
    .db $0A, $0A, $0A, $06, $0A, $0A, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00

KeyboardEnCodes:
    ; 행마다 16칸의 고유번호 하위 바이트
    .db $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18, $FF, $FF, $FF, $FF, $FF, $FF
    .db $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $FF, $FF, $FF, $FF, $FF, $FF
    .db $2A, $2B, $2C, $2D, $2E, $2F, $30, $31, $32, $33, $FF, $FF, $FF, $FF, $FF, $FF
    .db $34, $35, $36, $37, $38, $39, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $FF, $FF, $FF, $FF, $FF, $FF
    .db $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53, $FF, $FF, $FF, $FF, $FF, $FF
    .db $54, $55, $56, $57, $58, $59, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    ; 같은 칸의 고유번호 상위 바이트
    .db $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $FF, $FF, $FF, $FF, $FF, $FF
    .db $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $FF, $FF, $FF, $FF, $FF, $FF
    .db $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $FF, $FF, $FF, $FF, $FF, $FF
    .db $83, $83, $83, $83, $83, $83, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $FF, $FF, $FF, $FF, $FF, $FF
    .db $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $FF, $FF, $FF, $FF, $FF, $FF
    .db $83, $83, $83, $83, $83, $83, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
