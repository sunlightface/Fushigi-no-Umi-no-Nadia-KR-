.bank $08, $8000
.org $90F2
.db $0F, $0F, $0F, $0F ; 비활성 메뉴 팔레트

; 게임 종료 메뉴의 비활성 팔레트: 글리프 교체 중 이전 창 숨김
.org $9CAD
    .db $0F, $0F, $0F, $0F

; 승리, 패배 후 창 초기화 전에 타이틀 출력 방식으로 전환
.org $9C5D
    lda #$00
    sta $045D
    sta $53
    sta $54
    sta GameTextMode
    nop

; 타이틀 메뉴 묶음의 타일 배치 시작
.org $9EF3
    jmp BeginTitleMenuBridge

; 등록 메뉴와 혼자하기·둘이하기의 플레이어 목록에서 하이픈 타일 재사용
.org $91DA ; 혼자하기 / 둘이하기 플레이어1 이름 목록
    jsr DrawRegistrationListBridge
.org $925F ; 둘이하기 플레이어2 이름 목록
    jsr DrawRegistrationListBridge
.org $94B4
    jsr DrawRegistrationListBridge
.org $95B9
    jsr DrawRegistrationListBridge
.org $9723
    jsr DrawRegistrationListBridge

; 스테이지 선택 설명창의 반복 출력
.org $941B
    jsr InitializeMenuRedrawBridge
.org $944F
    jsr RedrawStageCaptionBridge

; 게임 계속하기의 스테이지 설명창도 같은 타일 영역에 반복 출력
.org $9E51
    jsr InitializeMenuRedrawBridge
.org $9E85
    jsr RedrawStageCaptionBridge

; 등록보기 오른쪽 창의 반복 출력
.org $972F
    jsr InitializeMenuRedrawBridge
.org $975B
    jsr PrepareMenuRedrawBridge
    beq $9735

; 등록보기 상세창의 타일 영역 배정과 회수
.org $9794
    jsr OpenRegistrationPopupBridge
.org $97A3
    jsr CloseRegistrationPopupBridge

; 플레이어1, 2 안내문의 번호 생성
.org $91BD
    lda #$01
    jsr $C04B
    .db $10
    .dw WriteInsertedNumber
    .fill $91CA - ., $EA
.org $924B
    lda #$02
    jsr $C04B
    .db $10
    .dw WriteInsertedNumber
    .fill $9258 - ., $EA

; 확인창에서 저장된 이름 8바이트 불러오기
.org $92F1
    jsr CopyFirstSavedName
.org $9306
    jsr CopySecondSavedName
.org $9622
    jsr CopyFirstSavedName
.org $9CF5
    jsr CopyFirstSavedName
.org $9D48
    jsr CopyFirstSavedName
.org $9D95
    jsr CopyFirstSavedName

; 게임 종료 후 혼자하기 저장 확인창의 등록번호 생성
.org $9CF8
    lda $042E
    jsr $C04B
    .db $10
    .dw WriteInsertedNumber
    .fill $9D06 - ., $EA

; 게임 종료 후 플레이어1 저장 확인창의 등록번호 생성
.org $9D4B
    lda $042E
    jsr $C04B
    .db $10
    .dw WriteInsertedNumber
    .fill $9D59 - ., $EA

; 게임 종료 후 플레이어2 저장 확인창의 등록번호 생성
.org $9D98
    lda $042F
    jsr $C04B
    .db $10
    .dw WriteInsertedNumber
    .fill $9DA6 - ., $EA

; 이름 칸과 입력판 표시
.org $951F
    jsr $C04B
    .db $10
    .dw ShowNameKeyboard
    nop
    nop
    nop
    nop

; 등록 확인창의 등록번호 생성
.org $953D
    jsr $C04B
    .db $10
    .dw PrepareRegistrationNumber
    nop
    nop
    nop
    nop
    nop
    nop
    nop

; 삭제 확인창의 등록번호 생성
.org $962F
    jsr $C04B
    .db $10
    .dw PrepareRegistrationNumber
    nop
    nop
    nop
    nop
    nop
    nop
    nop
