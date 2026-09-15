#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
나디아 타이틀 로고 편집용 BIN 내보내기와 원본 ROM 형식 저장.

수정한 18x9 타일 BIN을 임포트하면 최종 파일 세 개를 저장한다.
  이름.bin           : CHR 4096바이트, ROM 파일 위치 $23010
  이름_metatiles.bin : 4타일 조합표 384바이트, ROM 파일 위치 $1B611
  이름_map.bin       : 16x15 배치 맵 240바이트, ROM 파일 위치 $1B791

원본 ROM에서 타이틀 전체 배치를 읽고 로고 부분만 교체한다.
로고 밖에서 사용하는 CHR 타일과 배치는 보호한다. 속성과 팔레트는 변경하지 않는다.
타일이나 조합표 공간이 부족하면 파일을 저장하기 전에 중단한다.
Python 표준 라이브러리만 사용하며 ROM이나 ASM을 직접 수정하지 않는다.
"""

from __future__ import annotations

import os
import tempfile
import tkinter as tk
from tkinter import filedialog, messagebox
from pathlib import Path

TILE_BYTES = 16
LOGO_W = 18
LOGO_H = 9
LOGO_CELLS = LOGO_W * LOGO_H
LOGO_BYTES = LOGO_CELLS * TILE_BYTES
NAME_TABLE_BYTES = LOGO_CELLS
LOGO_X = 7
LOGO_Y = 4
SCREEN_W = 32
SCREEN_H = 30
CHR_ROM_OFFSET = 0x23010
METATILE_ROM_OFFSET = 0x1B611
MAP_ROM_OFFSET = 0x1B791
METATILE_CAPACITY = 96
METATILE_BYTES = METATILE_CAPACITY * 4
MAP_BYTES = 16 * 15
DEFAULT_ROM = Path(__file__).resolve().parent.parent / "Fushigi no Umi no Nadia (J).nes"

def decode_tile(tile: bytes) -> list[list[int]]:
    """Decode a 16-byte NES 2bpp CHR tile into an 8x8 array of values 0..3."""
    if len(tile) != TILE_BYTES:
        raise ValueError("CHR tile must be 16 bytes")
    pix = [[0] * 8 for _ in range(8)]
    for y in range(8):
        p0 = tile[y]
        p1 = tile[y + 8]
        for x in range(8):
            bit = 7 - x
            pix[y][x] = ((p0 >> bit) & 1) | (((p1 >> bit) & 1) << 1)
    return pix


def validate_chr(chr_data: bytes) -> None:
    if len(chr_data) != 4096:
        raise ValueError("타이틀 CHR은 4096바이트 / 256타일이어야 합니다.")


def is_logo_cell(index: int) -> bool:
    x, y = index % SCREEN_W, index // SCREEN_W
    return LOGO_X <= x < LOGO_X + LOGO_W and LOGO_Y <= y < LOGO_Y + LOGO_H


def crop_logo(title_nt: bytes) -> bytes:
    if len(title_nt) != SCREEN_W * SCREEN_H:
        raise ValueError("전체 타이틀 배치는 32x30칸이어야 합니다.")
    return bytes(tile for index, tile in enumerate(title_nt) if is_logo_cell(index))


def replace_logo(title_nt: bytes, logo_nt: bytes) -> bytes:
    crop_logo(title_nt)
    if len(logo_nt) != NAME_TABLE_BYTES:
        raise ValueError("로고 네임테이블은 18x9 / 162바이트이어야 합니다.")
    out = bytearray(title_nt)
    for y in range(LOGO_H):
        start = (LOGO_Y + y) * SCREEN_W + LOGO_X
        out[start:start + LOGO_W] = logo_nt[y * LOGO_W:(y + 1) * LOGO_W]
    return bytes(out)


def decode_title_layout(metatiles: bytes, tile_map: bytes) -> bytes:
    """원본의 4타일 조합표와 16x15 맵을 32x30 타일 번호로 펼친다."""
    if len(metatiles) != METATILE_BYTES or len(tile_map) != MAP_BYTES:
        raise ValueError("조합표는 384바이트, 배치 맵은 240바이트이어야 합니다.")
    title_nt = bytearray(SCREEN_W * SCREEN_H)
    for cell, group in enumerate(tile_map):
        if group >= METATILE_CAPACITY:
            raise ValueError("배치 맵에 조합표 범위를 벗어난 번호가 있습니다.")
        x, y = (cell % 16) * 2, (cell // 16) * 2
        block = metatiles[group * 4:group * 4 + 4]
        start = y * SCREEN_W + x
        title_nt[start:start + 2] = block[:2]
        title_nt[start + SCREEN_W:start + SCREEN_W + 2] = block[2:]
    return bytes(title_nt)


def encode_title_layout(title_nt: bytes) -> tuple[bytes, bytes, int]:
    """타이틀 전체를 중복 조합 제거 후 원본 크기의 BIN 두 개로 변환한다."""
    crop_logo(title_nt)
    groups: dict[bytes, int] = {}
    metatiles = bytearray()
    tile_map = bytearray()
    for y in range(0, SCREEN_H, 2):
        for x in range(0, SCREEN_W, 2):
            start = y * SCREEN_W + x
            block = title_nt[start:start + 2] + title_nt[start + SCREEN_W:start + SCREEN_W + 2]
            if block not in groups:
                if len(groups) == METATILE_CAPACITY:
                    raise ValueError(
                        "4타일 조합이 원본 공간의 96개를 초과합니다.\n"
                        "파일은 저장하지 않습니다. 로고의 서로 다른 16x16 조합을 줄여 주세요."
                    )
                groups[block] = len(groups)
                metatiles.extend(block)
            tile_map.append(groups[block])
    metatiles.extend(bytes(METATILE_BYTES - len(metatiles)))
    return bytes(metatiles), bytes(tile_map), len(groups)


def read_original_title(rom_path: Path) -> tuple[bytes, bytes]:
    """원본 ROM의 타이틀 전용 포인터와 데이터 크기를 확인하고 읽는다."""
    rom = rom_path.read_bytes()
    pointers = bytes.fromhex("01 B6 81 B7 71 B8 B1 B8")
    if (len(rom) != 0x40010 or rom[:4] != b"NES\x1a"
            or rom[4:6] != bytes((8, 16)) or rom[6] & 0x04
            or rom[0x18649:0x18651] != pointers):
        raise ValueError("나디아 일본어 원본 ROM을 선택해 주세요. 확장 ROM은 사용하지 않습니다.")
    title_nt = decode_title_layout(
        rom[METATILE_ROM_OFFSET:MAP_ROM_OFFSET],
        rom[MAP_ROM_OFFSET:MAP_ROM_OFFSET + MAP_BYTES],
    )
    return title_nt, rom[CHR_ROM_OFFSET:CHR_ROM_OFFSET + 4096]


def preserve_outside_layout(title_nt: bytes, original_chr: bytes, new_chr: bytes) -> bytes:
    """이전 GUI 출력도 열 수 있도록 로고 밖 그림을 같은 새 타일로 연결한다.

    예: 이전 출력에서 $00이 그림으로 바뀌었다면, 원래 공백과 동일한 타일을 찾는다.
    빈 타일 번호를 $01로 고정하지 않고 실제 16바이트가 같은지 비교한다.
    """
    out = bytearray(title_nt)
    remap = {}
    for tile in {t for i, t in enumerate(title_nt) if not is_logo_cell(i)}:
        block = original_chr[tile * TILE_BYTES:(tile + 1) * TILE_BYTES]
        if new_chr[tile * TILE_BYTES:(tile + 1) * TILE_BYTES] == block:
            remap[tile] = tile
            continue
        match = next((n for n in range(256)
                      if new_chr[n * TILE_BYTES:(n + 1) * TILE_BYTES] == block), None)
        if match is None:
            raise ValueError(
                f"로고 밖에서 쓰는 원본 타일 ${tile:02X}의 그림이 CHR에 없습니다.\n"
                "원본 CHR을 열어 수정 로고를 다시 임포트해 주세요."
            )
        remap[tile] = match
    for index, tile in enumerate(title_nt):
        if not is_logo_cell(index):
            out[index] = remap[tile]
    return bytes(out)


def extract_packed_logo(chr_data: bytes, name_table: bytes | list[int] | tuple[int, ...]) -> bytes:
    """Build a screen-ordered 18x9 tile binary using the supplied name table."""
    validate_chr(chr_data)
    if len(name_table) != NAME_TABLE_BYTES or any(not 0 <= n < 256 for n in name_table):
        raise ValueError("로고 네임테이블은 타일 번호 162개이어야 합니다.")
    out = bytearray()
    for tile_id in name_table:
        off = tile_id * TILE_BYTES
        out += chr_data[off:off + TILE_BYTES]
    return bytes(out)


def rebuild_chr_and_nametable(
    chr_data: bytes,
    packed: bytes,
    title_nt: bytes,
) -> tuple[bytes, bytes, list[int], list[int]]:
    """로고 밖 타일을 보호하며 편집 결과에 맞는 CHR과 로고 배치를 만든다.

    반환: 새 CHR, 새 로고 배치, 추가 배정 번호, 확인이 필요한 비공백 덮어쓰기 번호.
    """
    validate_chr(chr_data)
    if len(packed) != LOGO_BYTES:
        raise ValueError(
            f"로고 바이너리 크기가 맞지 않습니다.\n"
            f"필요: {LOGO_BYTES} bytes ({LOGO_W}x{LOGO_H} tiles)\n"
            f"현재: {len(packed)} bytes"
        )

    name_table = crop_logo(title_nt)
    original_logo_ids = set(name_table)
    # 로고 밖에서 참조하는 타일은 공백까지 모두 보호한다.
    protected_ids = {tile for index, tile in enumerate(title_nt) if not is_logo_cell(index)}
    unused_ids = [i for i in range(256) if i not in original_logo_ids and i not in protected_ids]
    blank = bytes(TILE_BYTES)
    blank_unused = [
        i for i in unused_ids
        if chr_data[i * TILE_BYTES:(i + 1) * TILE_BYTES] == blank
    ]
    nonblank_unused = [i for i in unused_ids if i not in set(blank_unused)]
    # 마지막에는 더 이상 필요하지 않은 로고 슬롯도 재사용할 수 있다.
    allocation_pool = blank_unused + nonblank_unused + sorted(original_logo_ids - protected_ids)

    out = bytearray(chr_data)
    new_name_table = [0] * LOGO_CELLS

    # 보호 타일과 같은 그림은 그대로 공유한다. 원래 빈칸은 추가 배정이 필요 없다.
    graphic_to_tile: dict[bytes, int] = {}
    for tile in sorted(protected_ids):
        block = chr_data[tile * TILE_BYTES:(tile + 1) * TILE_BYTES]
        graphic_to_tile.setdefault(block, tile)
    assigned = set(protected_ids)
    allocated: list[int] = []
    overwritten_nonblank: list[int] = []
    pool_pos = 0

    for cell, old_tile_id in enumerate(name_table):
        block = packed[cell * TILE_BYTES:(cell + 1) * TILE_BYTES]

        # If this exact edited graphic already has a tile, share it.
        existing = graphic_to_tile.get(block)
        if existing is not None:
            new_name_table[cell] = existing
            continue

        # 공유되지 않은 원래 번호가 비어 있으면 그 번호를 우선 유지한다.
        if old_tile_id not in assigned:
            tile_id = old_tile_id
        else:
            while pool_pos < len(allocation_pool) and allocation_pool[pool_pos] in assigned:
                pool_pos += 1
            if pool_pos >= len(allocation_pool):
                raise ValueError(
                    "추가로 필요한 CHR 슬롯이 부족합니다.\n"
                    "수정된 로고의 서로 다른 타일 수를 줄이거나 더 큰/다른 CHR 영역을 사용해야 합니다."
                )
            tile_id = allocation_pool[pool_pos]
            pool_pos += 1
            allocated.append(tile_id)
            if tile_id in nonblank_unused:
                overwritten_nonblank.append(tile_id)

        assigned.add(tile_id)
        graphic_to_tile[block] = tile_id
        new_name_table[cell] = tile_id
        off = tile_id * TILE_BYTES
        out[off:off + TILE_BYTES] = block

    if max(new_name_table) > 0xFF:
        raise ValueError("생성된 네임테이블에 0xFF를 넘는 타일 번호가 있습니다.")

    return bytes(out), bytes(new_name_table), allocated, overwritten_nonblank


def save_bin_set(outputs: dict[Path, bytes]) -> None:
    """세 파일을 먼저 임시 저장하고 교체한다. 교체 실패 시 기존 파일을 복구한다."""
    previous = {path: path.read_bytes() if path.exists() else None for path in outputs}
    staged: dict[Path, Path] = {}
    replaced: list[Path] = []
    try:
        for path, data in outputs.items():
            with tempfile.NamedTemporaryFile(dir=path.parent, prefix=path.name + ".", delete=False) as f:
                staged[path] = Path(f.name)
                f.write(data)
        for path, temp in staged.items():
            os.replace(temp, path)
            replaced.append(path)
    except OSError:
        for path in reversed(replaced):
            old = previous[path]
            if old is None:
                path.unlink(missing_ok=True)
            else:
                path.write_bytes(old)
        raise
    finally:
        for temp in staged.values():
            temp.unlink(missing_ok=True)


class NadiaLogoGUI(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Nadia Logo - CHR / 조합표 / 배치 맵")
        self.resizable(False, False)

        self.chr_path: Path | None = None
        self.chr_data: bytes | None = None
        self.rom_path: Path | None = None
        self.title_nt: bytes | None = None
        self.preview_name_table: list[int] = []

        self.path_var = tk.StringVar(value="CHR BIN을 열어 주세요")
        self.status_var = tk.StringVar(
            value="로고 익스포트 2592B / 최종 저장: CHR 4096B + 조합표 384B + 배치 맵 240B"
        )

        outer = tk.Frame(self, padx=12, pady=12)
        outer.pack()

        top = tk.Frame(outer)
        top.pack(fill="x")

        tk.Button(top, text="CHR BIN 열기", width=20, command=self.open_chr).pack(side="left")
        tk.Label(top, textvariable=self.path_var, anchor="w", width=58).pack(side="left", padx=(10, 0))

        preview_box = tk.LabelFrame(outer, text="현재 네임테이블 조합 미리보기", padx=8, pady=8)
        preview_box.pack(fill="x", pady=(10, 8))

        self.scale = 3
        self.canvas = tk.Canvas(
            preview_box,
            width=LOGO_W * 8 * self.scale,
            height=LOGO_H * 8 * self.scale,
            bg="#202020",
            highlightthickness=0,
        )
        self.canvas.pack()

        btns = tk.Frame(outer)
        btns.pack(fill="x", pady=(4, 4))

        self.export_btn = tk.Button(
            btns,
            text="1. 로고 BIN 익스포트",
            width=28,
            state="disabled",
            command=self.export_logo,
        )
        self.export_btn.pack(side="left", padx=(0, 8))

        self.import_btn = tk.Button(
            btns,
            text="2. 수정 BIN 임포트 → 최종 BIN 3개 저장",
            width=36,
            state="disabled",
            command=self.import_logo,
        )
        self.import_btn.pack(side="left")

        tk.Label(
            outer,
            text=(
                "익스포트 BIN은 화면 순서 그대로 18타일 × 9줄입니다. "
                "CHR 에디터의 가로 폭을 18 tiles로 맞춰 편집하세요."
            ),
            justify="left",
            anchor="w",
        ).pack(fill="x", pady=(7, 2))

        tk.Label(
            outer,
            text=(
                "원본 ROM의 로고 밖 배치는 보존합니다. 저장한 CHR / 조합표 / 배치 맵을 "
                "각각 ROM $23010 / $1B611 / $1B791에 넣으세요."
            ),
            justify="left",
            anchor="w",
        ).pack(fill="x", pady=(0, 7))

        tk.Label(outer, textvariable=self.status_var, anchor="w", relief="sunken", padx=6).pack(fill="x")

    def open_chr(self) -> None:
        path = filedialog.askopenfilename(
            title="CHR BIN 선택",
            filetypes=[("CHR / BIN files", "*.bin"), ("All files", "*.*")],
        )
        if not path:
            return

        try:
            data = Path(path).read_bytes()
            validate_chr(data)
            rom_path = self.rom_path or DEFAULT_ROM
            if not rom_path.is_file():
                chosen = filedialog.askopenfilename(
                    title="타이틀 배치를 읽을 나디아 일본어 원본 ROM 선택",
                    filetypes=[("NES ROM", "*.nes"), ("All files", "*.*")],
                )
                if not chosen:
                    return
                rom_path = Path(chosen)
            original_nt, original_chr = read_original_title(rom_path)
            chr_path = Path(path)
            meta_path = chr_path.with_name(chr_path.stem + "_metatiles.bin")
            map_path = chr_path.with_name(chr_path.stem + "_map.bin")
            legacy_path = chr_path.with_name(chr_path.stem + "_nametable.bin")
            legacy_long_path = chr_path.with_name(chr_path.stem + "_nametable_18x9.bin")
            if meta_path.exists() or map_path.exists():
                # 새 세트가 있으면 원본 배열 대신 저장된 현재 배치를 사용한다.
                logo_nt = crop_logo(decode_title_layout(meta_path.read_bytes(), map_path.read_bytes()))
            elif legacy_path.exists() or legacy_long_path.exists():
                # 이전 GUI에서 만든 CHR + 162바이트 NT도 그대로 불러올 수 있다.
                logo_nt = (legacy_path if legacy_path.exists() else legacy_long_path).read_bytes()
            else:
                logo_nt = crop_logo(original_nt)
            outside_nt = preserve_outside_layout(original_nt, original_chr, data)
            title_nt = replace_logo(outside_nt, logo_nt)
        except Exception as e:
            messagebox.showerror("열기 실패", str(e))
            return

        self.chr_path = Path(path)
        self.chr_data = data
        self.rom_path = rom_path
        self.title_nt = title_nt
        self.preview_name_table = list(logo_nt)
        self.path_var.set(f"{self.chr_path.name}  ({len(data)} bytes / {len(data)//16} tiles)")
        self.export_btn.config(state="normal")
        self.import_btn.config(state="normal")
        self.status_var.set("CHR 로드 완료. 함께 있는 배치 BIN이 있으면 현재 배치로 조합합니다.")
        self.draw_preview(data, self.preview_name_table)

    def draw_preview(self, chr_data: bytes, name_table: list[int] | tuple[int, ...]) -> None:
        self.canvas.delete("all")
        colors = ("#101010", "#686868", "#b0b0b0", "#f0f0f0")
        s = self.scale

        for cell, tile_id in enumerate(name_table):
            tx = cell % LOGO_W
            ty = cell // LOGO_W
            off = tile_id * TILE_BYTES
            pix = decode_tile(chr_data[off:off + TILE_BYTES])
            x0 = tx * 8 * s
            y0 = ty * 8 * s
            for py in range(8):
                for px in range(8):
                    x = x0 + px * s
                    y = y0 + py * s
                    self.canvas.create_rectangle(
                        x, y, x + s, y + s,
                        fill=colors[pix[py][px]],
                        outline=colors[pix[py][px]],
                    )

    def export_logo(self) -> None:
        if self.chr_data is None or self.chr_path is None:
            return

        default_name = self.chr_path.stem + "_logo_18x9.bin"
        path = filedialog.asksaveasfilename(
            title="조합된 로고 BIN 저장",
            initialdir=str(self.chr_path.parent),
            initialfile=default_name,
            defaultextension=".bin",
            filetypes=[("BIN files", "*.bin"), ("All files", "*.*")],
        )
        if not path:
            return

        try:
            packed = extract_packed_logo(self.chr_data, self.preview_name_table)
            Path(path).write_bytes(packed)
        except Exception as e:
            messagebox.showerror("익스포트 실패", str(e))
            return

        self.status_var.set(f"익스포트 완료: {os.path.basename(path)} ({len(packed)} bytes)")
        messagebox.showinfo(
            "완료",
            f"로고를 화면 순서로 익스포트했습니다.\n\n"
            f"{LOGO_W} x {LOGO_H} tiles\n"
            f"{len(packed)} bytes\n\n"
            f"CHR 에디터의 가로 폭을 {LOGO_W} tiles로 맞춰 편집하세요.",
        )

    def import_logo(self) -> None:
        if self.chr_data is None or self.chr_path is None or self.title_nt is None:
            return

        logo_path = filedialog.askopenfilename(
            title="수정한 로고 BIN 선택",
            initialdir=str(self.chr_path.parent),
            filetypes=[("BIN files", "*.bin"), ("All files", "*.*")],
        )
        if not logo_path:
            return

        try:
            packed = Path(logo_path).read_bytes()
            new_chr, new_nt_bytes, allocated, overwritten_nonblank = rebuild_chr_and_nametable(
                self.chr_data, packed, self.title_nt
            )
            new_title_nt = replace_logo(self.title_nt, new_nt_bytes)
            metatiles, tile_map, group_count = encode_title_layout(new_title_nt)
        except Exception as e:
            messagebox.showerror("임포트 실패", str(e))
            return

        if overwritten_nonblank:
            ids = ", ".join(f"${x:02X}" for x in overwritten_nonblank[:24])
            if len(overwritten_nonblank) > 24:
                ids += f" ... 외 {len(overwritten_nonblank)-24}개"
            ok = messagebox.askyesno(
                "빈 CHR 슬롯 부족",
                "수정본에 필요한 추가 타일 수가 현재 비어 있는 미사용 CHR 슬롯보다 많습니다.\n\n"
                "계속하면 타이틀 배치에서 참조하지 않는 비공백 CHR 슬롯도 덮어씁니다.\n"
                "로고 밖에서 사용하는 타일은 제외했지만, 다른 용도로 사용하는 슬롯인지 확인해 주세요.\n\n"
                f"덮어쓸 슬롯: {ids}\n\n계속할까요?",
            )
            if not ok:
                self.status_var.set("임포트 취소: 빈 CHR 슬롯 부족")
                return

        stem = self.chr_path.stem.strip()
        if stem.endswith("_og"):
            stem = stem[:-3]
        default_chr_name = stem + ".bin"
        chr_out_path = filedialog.asksaveasfilename(
            title="수정된 CHR 저장",
            initialdir=str(self.chr_path.parent),
            initialfile=default_chr_name,
            defaultextension=".bin",
            filetypes=[("BIN files", "*.bin"), ("All files", "*.*")],
        )
        if not chr_out_path:
            return

        chr_out = Path(chr_out_path).resolve()
        meta_out = chr_out.with_name(chr_out.stem + "_metatiles.bin")
        map_out = chr_out.with_name(chr_out.stem + "_map.bin")
        outputs = {chr_out: new_chr, meta_out: metatiles, map_out: tile_map}
        protected_paths = {Path(logo_path).resolve(), self.rom_path.resolve()}
        if any(path in protected_paths for path in outputs):
            messagebox.showerror("저장 위치 오류", "원본 ROM이나 편집용 로고 BIN을 출력 파일로 덮어쓸 수 없습니다.")
            return
        existing = [path.name for path in outputs if path.exists()]
        if existing and not messagebox.askyesno(
            "기존 BIN 덮어쓰기", "아래 파일을 새 세트로 교체할까요?\n\n" + "\n".join(existing)
        ):
            return

        try:
            save_bin_set(outputs)
        except Exception as e:
            messagebox.showerror("저장 실패", str(e))
            return

        new_nt = list(new_nt_bytes)
        self.chr_path = chr_out
        self.chr_data = new_chr
        self.title_nt = new_title_nt
        self.preview_name_table = new_nt
        self.path_var.set(f"{chr_out.name}  ({len(new_chr)} bytes / 256 tiles)")
        self.status_var.set(
            f"BIN 3개 저장 완료 / 조합 {group_count}/{METATILE_CAPACITY}개 / 추가 타일 {len(allocated)}개"
        )
        self.draw_preview(new_chr, new_nt)

        allocated_text = (
            ", ".join(f"${x:02X}" for x in allocated)
            if allocated else "없음"
        )
        messagebox.showinfo(
            "완료",
            "원본 출력 코드가 읽는 형식으로 BIN 세 개를 저장했습니다.\n\n"
            f"CHR: {chr_out.name} (4096 bytes) → ROM $23010\n"
            f"조합표: {meta_out.name} (384 bytes) → ROM $1B611\n"
            f"배치 맵: {map_out.name} (240 bytes) → ROM $1B791\n\n"
            f"조합표 사용량: {group_count}/{METATILE_CAPACITY}\n"
            f"추가 배정 CHR 슬롯: {allocated_text}\n\n"
            "속성과 팔레트, 게임 출력 코드는 그대로 사용합니다.\n"
            "기존 162-byte 네임테이블 BIN은 ROM에 넣지 않습니다.",
        )


if __name__ == "__main__":
    app = NadiaLogoGUI()
    app.mainloop()
