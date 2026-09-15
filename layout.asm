TitleTextLeft       equ $01 ; 타이틀 계열의 공통 문자열
GameTextLeft        equ $01 ; 인게임 공통 문자열
SavedNameTextLeft   equ $03 ; 저장된 이름 목록
AbilityTextLeft     equ $02 ; 기술, 능력 목록
ItemTextLeft        equ $02 ; 아이템 목록
OtherItemTextLeft   equ $02 ; 다른 아이템 목록
;----------------------------------
; 등록 보기와 이름 목록
ViewPromptX         equ $01
ViewPromptY         equ $02
ViewPromptWidth     equ $06
ViewPromptHeight    equ $03
ViewNameListX       equ $02
ViewNameListY       equ $06
ViewNameListWidth   equ $04
ViewNameListHeight  equ $07
ViewLevelsX         equ $08
ViewLevelsY         equ $02
ViewLevelsWidth     equ $07
ViewLevelsHeight    equ $0B
ViewEmptyX          equ $08
ViewEmptyY          equ $02
ViewEmptyWidth      equ $07
ViewEmptyHeight     equ $0B
ViewStageX          equ $04
ViewStageY          equ $02
ViewStageHeight     equ $0B
;----------------------------------
; 스테이지 선택
StagePromptX        equ $01
StagePromptY        equ $00
StagePromptWidth    equ $07
StagePromptHeight   equ $02
StageCaptionX       equ $08
StageCaptionY       equ $00
StageCaptionWidth   equ $07
StageCaptionHeight  equ $02
StageBoardX         equ $01
StageBoardY         equ $02
StageBoardHeight50  equ $0B
StageBoardHeight55  equ $0C
Stage50CursorX      equ $20
Stage50CursorY      equ $2A
Stage50CursorStepX  equ $20
Stage50CursorStepY  equ $10
;----------------------------------
; 스테이지 번호판의 행 위치표의 폭
NumberBoardWidth    equ $0B
NumberTextLeft      equ $03
NumberTextTop       equ $01
NumberTextRowStep   equ $02
NumberClearLeft     equ $02 ; 완료 표시는 숫자 바로 왼쪽
ViewLevelTextLeft   equ $0B
ViewLevelTextTop    equ $01
ViewLevelRowStep    equ $02
;----------------------------------
; 타이틀 메뉴(미사용)
TitleCursorX                equ $56
TitleCursorY                equ $39
TitleCursorStepY            equ $10
; 디버그 타이틀 메뉴
DebugTitleCursorX           equ $56 ;58
DebugTitleCursorY           equ $39 ;3F
DebugTitleCursorStepY       equ $10
;----------------------------------
; 등록하기, 등록삭제, 등록보기, 플레이어1, 2의 이름 목록
Player1CursorX            equ $26
Player1CursorY            equ $69
Player1CursorStepY        equ $10
Player2CursorX            equ $A6
Player2CursorY            equ $69
Player2CursorStepY        equ $10
;-----------------------------------
; 입력 중 이름의 네임테이블 좌표
NamePreviewTextX    equ $16
NamePreviewTextY    equ $05
; 입력판
KeyboardCursorX             equ $98
KeyboardCursorY             equ $41
KeyboardCursorStepX         equ $08
KeyboardCursorStepY         equ $10
; 입력 중인 이름 커서
InputNameCursorX            equ $B0
InputNameCursorY            equ $21
InputNameCursorStepX        equ $08
InputNameCursorStepY        equ $00
;-----------------------------------
; 예, 아니오
ConfirmCursorX              equ $C6
ConfirmCursorY              equ $99
ConfirmCursorStepY          equ $10
;-----------------------------------
; 혼자하기, 둘이하기
PlayerCountCursorX          equ $66
PlayerCountCursorY          equ $69
PlayerCountCursorStepY      equ $10
;-----------------------------------
; 환경설정 항목
SettingsCursorX             equ $26
SettingsCursorY             equ $49
SettingsCursorStepY         equ $10
; 게임, 전투 속도
SpeedCursorX                equ $87
SpeedCursorY                equ $91
SpeedCursorStepX            equ $08
SpeedCursorStepY            equ $00
;-----------------------------------
; 게임 계속, 종료
ContinueCursorX             equ $98
ContinueCursorY             equ $29
ContinueCursorStepY         equ $10
;-----------------------------------
; 디버그 메뉴
DebugMenuCursorX            equ $56
DebugMenuCursorY            equ $39
DebugMenuCursorStepY        equ $10
; 디버그 전술
DebugTacticsCursorX         equ $86
DebugTacticsCursorY         equ $29
DebugTacticsCursorStepX     equ $10
DebugTacticsCursorStepY     equ $10
; 디버그 공격, 방어, 특수, 기타
DebugActionCursorX          equ $5E
DebugActionCursorY          equ $49
DebugActionCursorStepX      equ $20
DebugActionCursorStepY      equ $10
; 디버그 정신 설정
DebugMindCursorX            equ $5F
DebugMindCursorY            equ $A1
DebugMindCursorStepX        equ $08
DebugMindCursorStepY        equ $00
;-----------------------------------
; 스테이지 55칸
Stage55CursorX              equ $20
Stage55CursorY              equ $2A
Stage55CursorStepX          equ $20
Stage55CursorStepY          equ $10

; 인게임 명령, 전투 하위 메뉴의 세로 이동 간격
; 시작 좌표는 창 위치 $BA/$BB에서 계산
GameMenuCursorStepY      equ $10
BattleSubmenuCursorStepY equ $10

; 인게임 명령 커서: 창의 위쪽을 기준으로 한 시작 Y 보정값
; 커서 Y값 = $BB * 16 + GameMenuCursorOffsetY
GameMenuCursorOffsetY    equ $09

; 전투 메뉴: 양쪽 플레이어의 시작 X, 화면 Y-1, 세로 이동 간격
BattleMenuLeftX     equ $18
BattleMenuRightX    equ $B8
BattleMenuCursorY   equ $99
BattleMenuStepY     equ $10

; 전투 이름과 H, M 수치의 위치: 8픽셀 단위
BattleNameLeftX     equ $00
BattleNameRightX    equ $18
BattleNameY         equ $02
BattleHpLeftX       equ $00
BattleHpRightX      equ $18
BattleHpY           equ $04
BattleMpLeftX       equ $04
BattleMpRightX      equ $1C
BattleMpY           equ $04
BattleStatusStepY   equ $05 ; 같은 편 캐릭터 사이의 세로 간격
; ------------------------------------------------------------

; 창 버퍼 안의 숫자 위치와 행 간격
NumberTextStart     equ NumberBoardWidth * 2 * NumberTextTop + NumberTextLeft
NumberClearStart    equ NumberBoardWidth * 2 * NumberTextTop + NumberClearLeft
NumberLineBytes     equ NumberBoardWidth * 2 * NumberTextRowStep
LevelTextStart      equ ViewLevelsWidth * 2 * (ViewLevelTextTop + 1) + ViewLevelTextLeft
LevelLineBytes      equ ViewLevelsWidth * 2 * ViewLevelRowStep
; ------------------------------------------------------------
.prg
.bank $08, $8000

.org $9F7E
    .db ViewPromptX, ViewPromptY
.org $9FE2
    .db ViewPromptWidth, ViewPromptHeight

.org $9F50
    .db ViewNameListX, ViewNameListY
.org $9FB4
    .db ViewNameListWidth, ViewNameListHeight

.org $9F7A
    .db ViewLevelsX, ViewLevelsY
.org $9FDE
    .db ViewLevelsWidth, ViewLevelsHeight
.org $9F80
    .db ViewEmptyX, ViewEmptyY
.org $9FE4
    .db ViewEmptyWidth, ViewEmptyHeight
.org $9F82
    .db ViewStageX, ViewStageY
.org $9FE6
    .db NumberBoardWidth, ViewStageHeight

.org $9F5C
    .db StagePromptX, StagePromptY
.org $9FC0
    .db StagePromptWidth, StagePromptHeight
.org $9F5E
    .db StageCaptionX, StageCaptionY
.org $9FC2
    .db StageCaptionWidth, StageCaptionHeight
.org $9F60
    .db StageBoardX, StageBoardY
.org $9FC4
    .db NumberBoardWidth, StageBoardHeight50
.org $9F94
    .db StageBoardX, StageBoardY
.org $9FF8
    .db NumberBoardWidth, StageBoardHeight55

.org $9710
    .db SpeedCursorX + SpeedCursorStepX * 0, SpeedCursorX + SpeedCursorStepX * 1, SpeedCursorX + SpeedCursorStepX * 2, SpeedCursorX + SpeedCursorStepX * 3, SpeedCursorX + SpeedCursorStepX * 4

.org $9960
    .db DebugMindCursorX + DebugMindCursorStepX * 0, DebugMindCursorX + DebugMindCursorStepX * 1, DebugMindCursorX + DebugMindCursorStepX * 2, DebugMindCursorX + DebugMindCursorStepX * 3, DebugMindCursorX + DebugMindCursorStepX * 4, DebugMindCursorX + DebugMindCursorStepX * 5, DebugMindCursorX + DebugMindCursorStepX * 6, DebugMindCursorX + DebugMindCursorStepX * 7
; ------------------------------------------------------------
.bank $09, $A000

.org $AA87
    adc #TitleTextLeft 
.org $AD96
    adc #SavedNameTextLeft 

.org $A319
    .dw LevelTextStart + LevelLineBytes * 0
    .dw LevelTextStart + LevelLineBytes * 1
    .dw LevelTextStart + LevelLineBytes * 2
    .dw LevelTextStart + LevelLineBytes * 3
    .dw LevelTextStart + LevelLineBytes * 4
    .dw LevelTextStart + LevelLineBytes * 5
    .dw LevelTextStart + LevelLineBytes * 6
    .dw LevelTextStart + LevelLineBytes * 7
    .dw LevelTextStart + LevelLineBytes * 8
    .dw LevelTextStart + LevelLineBytes * 9

.org $ABCE
    .dw NumberTextStart + NumberLineBytes * 0
    .dw NumberTextStart + NumberLineBytes * 1
    .dw NumberTextStart + NumberLineBytes * 2
    .dw NumberTextStart + NumberLineBytes * 3
    .dw NumberTextStart + NumberLineBytes * 4
    .dw NumberTextStart + NumberLineBytes * 5
    .dw NumberTextStart + NumberLineBytes * 6
    .dw NumberTextStart + NumberLineBytes * 7
    .dw NumberTextStart + NumberLineBytes * 8
    .dw NumberTextStart + NumberLineBytes * 9
    .dw NumberTextStart + NumberLineBytes * 10

.org $ACC0
    .dw NumberClearStart + NumberLineBytes * 0 + 0, NumberClearStart + NumberLineBytes * 0 + 4, NumberClearStart + NumberLineBytes * 0 + 8, NumberClearStart + NumberLineBytes * 0 + 12, NumberClearStart + NumberLineBytes * 0 + 16
    .dw NumberClearStart + NumberLineBytes * 1 + 0, NumberClearStart + NumberLineBytes * 1 + 4, NumberClearStart + NumberLineBytes * 1 + 8, NumberClearStart + NumberLineBytes * 1 + 12, NumberClearStart + NumberLineBytes * 1 + 16
    .dw NumberClearStart + NumberLineBytes * 2 + 0, NumberClearStart + NumberLineBytes * 2 + 4, NumberClearStart + NumberLineBytes * 2 + 8, NumberClearStart + NumberLineBytes * 2 + 12, NumberClearStart + NumberLineBytes * 2 + 16
    .dw NumberClearStart + NumberLineBytes * 3 + 0, NumberClearStart + NumberLineBytes * 3 + 4, NumberClearStart + NumberLineBytes * 3 + 8, NumberClearStart + NumberLineBytes * 3 + 12, NumberClearStart + NumberLineBytes * 3 + 16
    .dw NumberClearStart + NumberLineBytes * 4 + 0, NumberClearStart + NumberLineBytes * 4 + 4, NumberClearStart + NumberLineBytes * 4 + 8, NumberClearStart + NumberLineBytes * 4 + 12, NumberClearStart + NumberLineBytes * 4 + 16
    .dw NumberClearStart + NumberLineBytes * 5 + 0, NumberClearStart + NumberLineBytes * 5 + 4, NumberClearStart + NumberLineBytes * 5 + 8, NumberClearStart + NumberLineBytes * 5 + 12, NumberClearStart + NumberLineBytes * 5 + 16
    .dw NumberClearStart + NumberLineBytes * 6 + 0, NumberClearStart + NumberLineBytes * 6 + 4, NumberClearStart + NumberLineBytes * 6 + 8, NumberClearStart + NumberLineBytes * 6 + 12, NumberClearStart + NumberLineBytes * 6 + 16
    .dw NumberClearStart + NumberLineBytes * 7 + 0, NumberClearStart + NumberLineBytes * 7 + 4, NumberClearStart + NumberLineBytes * 7 + 8, NumberClearStart + NumberLineBytes * 7 + 12, NumberClearStart + NumberLineBytes * 7 + 16
    .dw NumberClearStart + NumberLineBytes * 8 + 0, NumberClearStart + NumberLineBytes * 8 + 4, NumberClearStart + NumberLineBytes * 8 + 8, NumberClearStart + NumberLineBytes * 8 + 12, NumberClearStart + NumberLineBytes * 8 + 16
    .dw NumberClearStart + NumberLineBytes * 9 + 0, NumberClearStart + NumberLineBytes * 9 + 4, NumberClearStart + NumberLineBytes * 9 + 8, NumberClearStart + NumberLineBytes * 9 + 12, NumberClearStart + NumberLineBytes * 9 + 16
    .dw NumberClearStart + NumberLineBytes * 10 + 0, NumberClearStart + NumberLineBytes * 10 + 4, NumberClearStart + NumberLineBytes * 10 + 8, NumberClearStart + NumberLineBytes * 10 + 12, NumberClearStart + NumberLineBytes * 10 + 16

.org $B021
    .db TitleCursorX, TitleCursorY
.org $B026
    .db TitleCursorStepY

.org $B02B
    .db Player1CursorX, Player1CursorY
.org $B030
    .db Player1CursorStepY

.org $B035
    .db KeyboardCursorX, KeyboardCursorY
.org $B039
    .db KeyboardCursorStepX, KeyboardCursorStepY

.org $B03F
    .db InputNameCursorX, InputNameCursorY
.org $B043
    .db InputNameCursorStepX, InputNameCursorStepY

.org $B049
    .db ConfirmCursorX, ConfirmCursorY
.org $B04E
    .db ConfirmCursorStepY

.org $B053
    .db PlayerCountCursorX, PlayerCountCursorY
.org $B058
    .db PlayerCountCursorStepY

.org $B05D
    .db Player2CursorX, Player2CursorY
.org $B062
    .db Player2CursorStepY

.org $B071
    .db SettingsCursorX, SettingsCursorY
.org $B076
    .db SettingsCursorStepY

.org $B07B
    .db SpeedCursorX, SpeedCursorY
.org $B07F
    .db SpeedCursorStepX, SpeedCursorStepY

.org $B099
    .db Stage50CursorX, Stage50CursorY
.org $B09D
    .db Stage50CursorStepX, Stage50CursorStepY

.org $B0A3
    .db ContinueCursorX, ContinueCursorY
.org $B0A8
    .db ContinueCursorStepY

.org $B0AD
    .db DebugMenuCursorX, DebugMenuCursorY
.org $B0B2
    .db DebugMenuCursorStepY

.org $B0B7
    .db DebugTacticsCursorX, DebugTacticsCursorY
.org $B0BB
    .db DebugTacticsCursorStepX, DebugTacticsCursorStepY

.org $B0C1
    .db DebugActionCursorX, DebugActionCursorY
.org $B0C5
    .db DebugActionCursorStepX, DebugActionCursorStepY

.org $B0CB
    .db DebugTitleCursorX, DebugTitleCursorY
.org $B0D0
    .db DebugTitleCursorStepY

.org $B0D5
    .db DebugMindCursorX, DebugMindCursorY
.org $B0D9
    .db DebugMindCursorStepX, DebugMindCursorStepY

.org $B0DF
    .db Stage55CursorX, Stage55CursorY
.org $B0E3
    .db Stage55CursorStepX, Stage55CursorStepY

.org $B06C
    .db GameMenuCursorStepY
.org $B094
    .db BattleSubmenuCursorStepY

.org $B085
    .db BattleMenuLeftX, BattleMenuCursorY
.org $B08A
    .db BattleMenuStepY
; ------------------------------------------------------------
.bank $0C, $8000

.org $9498
    adc #GameTextLeft 
.org $9A0D
    adc #($14 + AbilityTextLeft) 
.org $9BF5
    adc #($14 + ItemTextLeft) 
.org $9C39
    adc #($14 + OtherItemTextLeft) 
; ------------------------------------------------------------
.bank $3E, $C000

; 전투 H 수치의 네임테이블 위치
.org $D966
    .dw $2000 + BattleHpY * $20 + BattleHpLeftX
    .dw $2000 + (BattleHpY + BattleStatusStepY) * $20 + BattleHpLeftX
    .dw $2000 + (BattleHpY + BattleStatusStepY * 2) * $20 + BattleHpLeftX
    .dw $2000 + BattleHpY * $20 + BattleHpLeftX
    .dw $2000 + BattleHpY * $20 + BattleHpRightX
    .dw $2000 + (BattleHpY + BattleStatusStepY) * $20 + BattleHpRightX
    .dw $2000 + (BattleHpY + BattleStatusStepY * 2) * $20 + BattleHpRightX
    .dw $2000 + BattleHpY * $20 + BattleHpRightX

; 전투 M 수치의 네임테이블 위치
.org $D976
    .dw $2000 + BattleMpY * $20 + BattleMpLeftX
    .dw $2000 + (BattleMpY + BattleStatusStepY) * $20 + BattleMpLeftX
    .dw $2000 + (BattleMpY + BattleStatusStepY * 2) * $20 + BattleMpLeftX
    .dw $2000 + BattleMpY * $20 + BattleMpLeftX
    .dw $2000 + BattleMpY * $20 + BattleMpRightX
    .dw $2000 + (BattleMpY + BattleStatusStepY) * $20 + BattleMpRightX
    .dw $2000 + (BattleMpY + BattleStatusStepY * 2) * $20 + BattleMpRightX
    .dw $2000 + BattleMpY * $20 + BattleMpRightX

; 전투 캐릭터 이름의 네임테이블 위치
.org $D986
    .dw $2000 + BattleNameY * $20 + BattleNameLeftX
    .dw $2000 + (BattleNameY + BattleStatusStepY) * $20 + BattleNameLeftX
    .dw $2000 + (BattleNameY + BattleStatusStepY * 2) * $20 + BattleNameLeftX
    .dw $2000 + BattleNameY * $20 + BattleNameLeftX
    .dw $2000 + BattleNameY * $20 + BattleNameRightX
    .dw $2000 + (BattleNameY + BattleStatusStepY) * $20 + BattleNameRightX
    .dw $2000 + (BattleNameY + BattleStatusStepY * 2) * $20 + BattleNameRightX
    .dw $2000 + BattleNameY * $20 + BattleNameRightX

; 인게임 명령 커서의 시작 Y 계산
.org $C727
    lda $BB
    asl a
    asl a
    asl a
    asl a
    clc
    adc #GameMenuCursorOffsetY
    sta $03FF,x
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

.org $DB78
    lda #($20 + (NamePreviewTextY * $20 + NamePreviewTextX) / $100)
.org $DB7D
    lda #((NamePreviewTextY * $20 + NamePreviewTextX) & $FF)
.org $DB8F
    lda #($20 + ((NamePreviewTextY + 1) * $20 + NamePreviewTextX) / $100)
.org $DB94
    lda #(((NamePreviewTextY + 1) * $20 + NamePreviewTextX) & $FF)
; ------------------------------------------------------------
.bank $3F, $E000

.org $F3AA
    .db BattleMenuLeftX, BattleMenuRightX
