.nes2
.mapper 4
.open "Fushigi no Umi no Nadia (KR).nes", "_Fushigi no Umi no Nadia (KR).nes"
; -----------------------------------------------------------------------------------------
; 공용 RAM: 글리프 전송과 문자열 렌더링
GlyphBuffer     		equ $0580 ; 글자 세 개의 모양을 담는 96바이트, 끝 주소 $05DF
BufferedBytes   		equ $05E0 ; 준비한 폰트 바이트 수
NextBgTile      		equ $05E1 ; 다음 글리프의 상단 타일 번호
UploadTile      		equ $05E2 ; 전송 버퍼 첫 글리프의 타일 번호
UploadBytes     		equ $05E3 ; VBlank 전송 요청 바이트 수
TextResult      		equ $05E4 ; 문자열 훅의 반환값
CurrentBgTile   		equ $05E5 ; 현재 글리프의 상단 타일 번호
GlyphCodeHigh   		equ $05E6 ; 현재 고유번호 상위 바이트
GlyphInkMask    		equ $7F50 ; 타이틀 글자색 마스크. 흰색은 $FF, 검정은 $00
GameTextMode    		equ $7F51 ; 출력 영역. 0은 타이틀, 1은 인게임 창, 2는 상단 메시지
UploadChrBank   		equ $7F65 ; 인게임 글리프를 기록할 2KB CHR 뱅크
; -----------------------------------------------------------------------------------------
; 이름 입력 RAM
NameTileBase    		equ $05E7 ; 입력 중 이름 4글자의 첫 BG 타일 번호
InputKeyIndex   		equ $05E8 ; 선택한 자판 칸. 행마다 16칸씩 배치한 표의 위치
InputNameSlot   		equ $05E9 ; 입력 중인 이름의 글자 위치 0~3
InputTableLo    		equ $05EA ; 현재 자판 고유번호 표 주소의 하위 바이트
InputPending    		equ $05EB ; 이름 입력 요청. 1은 글자, 2는 다음 버튼, 3은 B 버튼
InputTableHi    		equ $05EC ; 현재 자판 고유번호 표 주소의 상위 바이트
; -----------------------------------------------------------------------------------------
; 메뉴 재출력 RAM
RedrawBgTile    		equ $05EE ; 다시 그릴 창의 첫 BG 타일 번호
RedrawSelection 		equ $05EF ; 현재 표시된 선택 항목 번호
BlackNameSlot   		equ $7F4F ; 검정으로 표시할 저장 이름 번호. 0이면 강조하지 않음
; -----------------------------------------------------------------------------------------
; 화면별 RAM 재사용: 이름 입력과 동시에 사용하지 않는 등록보기, 스테이지 화면
RegistrationPopupTile 	equ InputTableLo ; 등록보기 상세창의 첫 BG 타일 번호
StageClearTile			equ NameTileBase ; 스테이지 완료 표시의 상단 BG 타일
; -----------------------------------------------------------------------------------------
; 숫자 출력 RAM
NumberTilesReady 		equ $7F4E ; 공용 숫자 타일의 준비 여부
StatusDigitTiles 		equ $7F5B ; 전투 숫자 0~9의 상단 타일
InspectionFontBank      equ $7F7F ; 스탯 고정 글자를 준비한 CHR 뱅크, $FF는 재준비 필요
; -----------------------------------------------------------------------------------------
; 인게임 창 RAM
GameWindowTiles  		equ $7F52 ; 인게임 창 깊이별 첫 글리프 타일 8개
GameWindowNext   		equ $7F5A ; 상단 메시지 출력 중 보관하는 인게임 창의 다음 타일
; -----------------------------------------------------------------------------------------
; 조사 목록과 등록 목록 출력 중 사용: 전투 이름과 입력판 정보의 RAM 재사용
; 등록 목록은 첫 칸만 사용. $80은 하이픈 미준비, $81은 준비 완료
InspectionGlyphCount    equ $7F6E ; 조사 재사용 표의 글자 수 또는 등록 하이픈 상태. $FF는 재사용 중지
InspectionGlyphLow      equ $7F80 ; 글리프 고유번호 하위 바이트 32개
InspectionGlyphHigh     equ $7FA0 ; 글리프 고유번호 상위 바이트 32개
InspectionGlyphTiles    equ $7FC0 ; 각 글리프의 상단 타일 번호 32개
; -----------------------------------------------------------------------------------------
; 전투 RAM: BattleNameTiles 중 $7F80~$7FBF는 이름 입력 중 커서 행 정보로 재사용
BattleHudEnd     		equ $7F66 ; 전투 이름과 수치 다음에 배치할 메뉴의 첫 타일
BattleNameTiles  		equ $7F80 ; 전투 참가 슬롯 8개의 이름 타일, 슬롯당 상하단 16바이트
; -----------------------------------------------------------------------------------------
; 입력판 커서 RAM: $7F80~$7FBF는 전투의 BattleNameTiles와 공유
KeyboardRowCount  		equ $7F67 ; 현재 입력판의 행 수
KeyboardNextRow   		equ $7F68 ; 다음 버튼이 있는 행. $FF이면 버튼 없음
KeyboardNextCol	  		equ $7F69 ; '다음' 버튼의 시작 열
KeyboardDirection 		equ $7F6A ; 현재 이동 방향 0~3
KeyboardStartRow  		equ $7F6B ; 이동 전 행
KeyboardStartCol  		equ $7F6C ; 이동 전 열
KeyboardMaskLo    		equ $7F80 ; 최대 16행의 유효한 0~7열 비트
KeyboardMaskHi			equ $7F90 ; 최대 16행의 유효한 8~15열 비트
KeyboardRowWidths		equ $7FB0 ; 각 행 마지막 유효 칸의 오른쪽 경계
; 입력판 전환 중에만 사용. 인게임 상태와 전투 이름의 사용하지 않는 부분 재사용
KeyboardTransferState 	equ GameWindowNext ; 0은 완료. 1부터 속성 보관, 숨김, 타일 배치, 공개 순서
KeyboardSavedAttrs    	equ $7FC0 ; 전환 전 화면 속성 64바이트, 입력판 행 정보와 겹치지 않음
; 이름 네 칸의 조합 상태. 페이지 전환 때 지우지 않음
ImeCho           		equ $7F6F ; 이름 네 칸의 초성 번호 1~19. 0이면 없음
ImeJung          		equ $7F73 ; 이름 네 칸의 중성 번호 1~21. 0이면 없음
ImeJong          		equ $7F77 ; 이름 네 칸의 종성 번호 1~27. 0이면 없음
ImeCandidateCho  		equ $7F7B ; 검색 성공 전에 보관하는 후보 초성
ImeCandidateJung 		equ $7F7C ; 후보 중성
ImeCandidateJong 		equ $7F7D ; 후보 종성
ImeAdvance       		equ $7F7E ; 1이면 미리보기 갱신 후 다음 이름 칸으로 이동
; ------------------------------------------------------------------------------------------
.prg
.include "script.asm"
.include "layout.asm"
.include "hook\bank_8.asm"
.include "hook\bank_9.asm"
.include "hook\bank_A.asm"
.include "hook\bank_C.asm"
.include "hook\bank_D.asm"
.include "code_cave\bank_20.asm"
.include "code_cave\bank_3E.asm"
.include "code_cave\bank_3F.asm"
; ------------------------------------------------------------
.bank $27
.incbin "assets\kr_font.bin"
; 이름 입력 조합 조회: 같은 인덱스의 키와 고유번호가 한 쌍
.bank $31, $A000
HangulKeys:
.incbin "assets\hangul_keys.bin"
HangulKeysEnd:
.bank $32, $A000
HangulCodes:
.incbin "assets\hangul_codes.bin"
HangulCodesEnd:
; ------------------------------------------------------------
orga 0x20010 
.incbin "assets\kr_chr0.bin" ; 배틀 메뉴0~9ACDEHM메뉴 창PSTX/LV 히라가나특수문자"

orga 0x21610
.incbin "assets\kr_chr1.bin" ; 0~9ACDEHM메뉴 창PSTX/LV 히라가나특수문자"
;-------------------------------------------------------------
orga 0x23010
.incbin "assets\kr_chr2.bin" ; 타이틀 로고

orga 0x1B611
.incbin "assets\kr_chr2_metatiles.bin" ; 타이틀 맵 타일

orga 0x1B791
.incbin "assets\kr_chr2_map.bin" ; 타이틀 맵

;-------------------------------------------------------------
; 0~9ACDEHM메뉴 창PSTX/LV 으로 동일함
orga 0x24E10
.incbin "assets\kr_chr_dupe0.bin"

orga 0x25610
.incbin "assets\kr_chr_dupe0.bin"

orga 0x25E10
.incbin "assets\kr_chr_dupe0.bin"

orga 0x26610
.incbin "assets\kr_chr_dupe0.bin"

orga 0x26E10
.incbin "assets\kr_chr_dupe0.bin"

orga 0x27610
.incbin "assets\kr_chr_dupe0.bin"

orga 0x27E10
.incbin "assets\kr_chr_dupe0.bin"

orga 0x28610
.incbin "assets\kr_chr_dupe0.bin"

orga 0x28E10
.incbin "assets\kr_chr_dupe0.bin"

orga 0x29610
.incbin "assets\kr_chr_dupe0.bin"
;-------------------------------------------------------------
orga 0x2A910 	 
.incbin "assets\kr_chr3.bin"	; バンザーイ: 만세	
;-------------------------------------------------------------
orga 0x2C010
.incbin "assets\kr_chr4.bin"	; 캐릭터 스프라이트, 카타카나

orga 0x2D010
.incbin "assets\kr_chr5.bin"	; 캐릭터 스프라이트, 카타카나
;-------------------------------------------------------------
; kr_chr_dupe.bin 동일한데 팔레트 인덱스만 다름
orga 0x3D610
.incbin "assets\kr_chr_dupe1.bin" 			

orga 0x3DE10
.incbin "assets\kr_chr_dupe1.bin"

orga 0x3F010
.incbin "assets\kr_chr6.bin" ; kr_chr1.bin 동일한데 팔레트 인덱스만 다름

.close
