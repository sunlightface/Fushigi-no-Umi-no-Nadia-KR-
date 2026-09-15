.create "Fushigi no Umi no Nadia (KR).nes", 0

.nes2
.mapper 4
.submapper 0

.prgrom   0x80000
.chrrom   0
.prgram   0
.prgnvram 0x2000
.chrram   0x40000
.chrnvram 0

.mirroring vertical
.timing ntsc

SourcePointer   equ 0x00
SourcePrgBank   equ 0x02
ChrBankBase     equ 0x03
PagesRemaining equ 0x04

.prg

; PRG 0x00~0x0F: 원본 PRG
; PRG 0x10~0x1F: 원본 CHR-ROM
.bank 0x00, 0x8000
.incbin "Fushigi no Umi no Nadia (J).nes", 0x000010, 0x040000

; PRG 0x20~0x3D: 빈 확장 영역

; PRG 0x3E / CPU 0xC000~0xDFFF
.bank 0x3E, 0xC000
.incbin "Fushigi no Umi no Nadia (J).nes", 0x01C010, 0x0586
jmp LoadChrRam
.incbin "Fushigi no Umi no Nadia (J).nes", 0x01C599, 0x1A77

; PRG 0x3F / CPU 0xE000~0xFFFF
.bank last, 0xE000
.incbin "Fushigi no Umi no Nadia (J).nes", 0x01E010, 0x1EA9

LoadChrRam:
    lda #0x10
    sta SourcePrgBank

Next8KiB:
    lda SourcePrgBank
    sec
    sbc #0x10
    asl a
    asl a
    asl a
    sta ChrBankBase

    jsr MapChr8KiB

    lda #0x06
    sta 0x8000
    lda SourcePrgBank
    sta 0x8001

    lda #0x00
    sta 0x2006
    sta 0x2006
    sta SourcePointer

    lda #0x80
    sta SourcePointer+1

    lda #0x20
    sta PagesRemaining

CopyPage:
    ldy #0x00

CopyByte:
    lda (SourcePointer),y
    sta 0x2007
    iny
    bne CopyByte

    inc SourcePointer+1
    dec PagesRemaining
    bne CopyPage

    inc SourcePrgBank
    lda SourcePrgBank
    cmp #0x20
    bne Next8KiB

    lda #0x00
    sta ChrBankBase
    jsr MapChr8KiB

    lda #0x00
    sta 0x8000

    jsr 0xE4FD
    jmp 0xC589

MapChr8KiB:
    ldx #0x00

NextChrRegister:
    txa
    sta 0x8000

    lda ChrBankOffsets,x
    clc
    adc ChrBankBase
    sta 0x8001

    inx
    cpx #0x06
    bne NextChrRegister
    rts

ChrBankOffsets:	; 0xFF15에서 0xFF1A
    .db 0x00, 0x02, 0x04, 0x05, 0x06, 0x07

; -------------------------------------------
; 네임테이블 초기화 중 NMI의 PPU 주소 변경을 막아 CHR-RAM 보호
; 입력: $06=채울 타일, $07=네임테이블 주소 상위 바이트
; 화면이 꺼진 상태에서 호출. 원래 함수의 $E747~$E77F 영역만 사용
.org 0xE747
ClearNametable:
    lda $50
    pha
    ldx #$00
    stx $50
    bit $2002
    jsr $E467
    lda $07
    sta $2006
    stx $2006

    ; 타일 960칸: 처음 192바이트, 이어서 256바이트씩 세 번
    lda $06
    ldy #$04
    ldx #$C0
ClearNametable_Tiles:
    sta $2007
    dex
    bne ClearNametable_Tiles
    dey
    bne ClearNametable_Tiles

    ; 속성 64바이트 초기화
    lda #$00
    ldx #$40
ClearNametable_Attributes:
    sta $2007
    dex
    bne ClearNametable_Attributes
    sta $05
    sta $06

    ; 기존 NMI 작업과 원본 함수의 반환값 복원
    pla
    sta $50
    txa
    sec
    clv
    rts
    .fill 0xE780 - ., $EA

; -------------------------------------------
; 원본 코드
;910E: lda 0xFFD4
;9111: bne 0x9122      ; 0이 아니면 일반 메뉴

; 0이면 디버그 메뉴
;9116: ldx #0x5E
;9118: jsr 0x9EB4      ; T0107: 디버그 항목이 포함된 6개 메뉴

; 0이 아니면 일반 메뉴
;9125: ldx #0x00
;9127: jsr 0x9EB4      ; T0060: 일반 5개 메뉴	
; -------------------------------------------
.org 0xFFD4
.db  0xFF             ; 0x00: 디버그 메뉴, 0xFF: 일반 메뉴, 게임할때 중간에 뭐가 뜸

.org 0xFFD8
.incbin "Fushigi no Umi no Nadia (J).nes", 0x01FFE8, 0x0028 ; 원본 CPU 0xFFD8~0xFFFF: RESET 진입 코드와 인터럽트 벡터

.close
