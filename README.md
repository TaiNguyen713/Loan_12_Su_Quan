# Nam Bắc Phân Tranh

RTS Android lối chơi Cossacks 3, bối cảnh Trịnh – Nguyễn phân tranh (1558–1672 cho bản 1.0).

- Thiết kế: [docs/GAME_DESIGN.md](docs/GAME_DESIGN.md)
- Lộ trình, thuật toán, ước lượng, phiên bản công cụ: [docs/plan/](docs/plan/01_ROADMAP.md)
- Test case: [docs/test/](docs/test/TEST_STRATEGY.md)

## Yêu cầu

| Công cụ | Phiên bản | Ghi chú |
|---|---|---|
| Godot (bản Standard) | 4.7.2-stable | Xem [05_VERSIONS.md](docs/plan/05_VERSIONS.md) |
| Python | 3.12 | Cho `tools/` |
| Git LFS | bất kỳ | Asset nhị phân dùng LFS |

## Bắt đầu

```bash
git lfs install
git config core.hooksPath .githooks        # kiểm tra định dạng commit
pip install -r tools/requirements.txt
```

Mở `project.godot` bằng Godot 4.7.2 rồi nhấn F5.

## Dữ liệu cân bằng

Số liệu quân và công trình nằm ở `data/balance/*.csv`. **Không sửa tay** các file `.tres`; sinh lại bằng:

```bash
python tools/data_validator/validate.py data/balance   # kiểm tra
python tools/balance/csv_to_tres.py                    # sinh data/units, data/buildings
```

## Kiểm thử

```bash
python -m pytest tools/tests          # công cụ Python
python tools/ci/check_layers.py       # quy tắc phụ thuộc giữa các lớp
python tools/ci/version_guard.py      # phiên bản Godot khớp nhau
```

Test GDScript (GdUnit4) nằm ở `tests/`; chạy trong editor hoặc qua CI. GdUnit4 6.2.2 cần được cài vào
`addons/gdUnit4/` (xem [addons/README.md](addons/README.md)).

## Quy ước commit

`<type>(<scope>): <mô tả> (Sx.Tyy)`, ví dụ `feat(sim): add market prices (S9.T01)`. Mã task theo
[roadmap](docs/plan/01_ROADMAP.md); `docs` và `chore` có thể bỏ mã task.
