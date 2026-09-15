.bank $20, $8000
; 숫자 출력 상수
NumberTileBase   		equ $E8   	; 숫자 0~9의 BG 타일 $E8~$FB
DigitCodeLow     		equ $0F   	; 숫자 고유번호 $830F~$8318의 시작 하위 바이트

; 등록 목록 한 창의 하이픈 재사용 상태. 조사 목록의 글리프 수와 구분
RegistrationDashCode    equ $830C 	; 하이픈 고유번호
RegistrationDashPending equ $80  	; 이번 목록에서 아직 하이픈을 올리지 않음
RegistrationDashReady   equ $81  	; 이번 목록에서 올린 하이픈 타일 재사용

; 현재 자판의 자모 고유번호. 같은 모양의 초성과 종성도 별도로 판별
ImeJamoHigh     		equ $8C
ImeChoFirst     		equ $91
ImeJungFirst    		equ $A4
ImeJongFirst    		equ $B9
ImeJongEnd      		equ $D4

; 전투 H, M 표시 타일 상수
BattleHpTile     		equ $7C   	; 전투 H 표시의 상단 타일
BattleMpTile     		equ $80   	; 전투 M 표시의 상단 타일

; 엔딩은 위 그림과 아래 크레딧의 CHR 뱅크가 서로 다름
EndingScreenId   		equ $09
EndingTextFirstTile 	equ $80		; 아래 화면의 빈 배경 $00과 창 테두리를 보존
; ------------------------------------------------------------

; 기능 파일은 이 파일이 있는 폴더를 기준으로 포함
.relativeinclude on
.include "bank_20/text.asm"
.include "bank_20/glyph.asm"
.include "bank_20/chr_transfer.asm"
.include "bank_20/game_text.asm"
.include "bank_20/inspection.asm"
.include "bank_20/battle.asm"
.include "bank_20/keyboard_display.asm"
.include "bank_20/name_input.asm"
.include "bank_20/hangul_ime.asm"
.include "bank_20/keyboard.asm"
.include "bank_20/numbers.asm"
.include "bank_20/keyboard_data.asm"
.relativeinclude off
