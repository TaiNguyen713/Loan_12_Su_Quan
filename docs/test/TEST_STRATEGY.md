# Chiến lược kiểm thử

> Test case chi tiết cho từng task:
> [P0–P1](TEST_CASES_P0_P1.md) · [P2](TEST_CASES_P2.md) · [P3](TEST_CASES_P3.md) · [P4–P5](TEST_CASES_P4_P5.md)

## 1. Các cấp kiểm thử

| Mã | Loại | Công cụ | Chạy ở đâu | Khi nào |
|---|---|---|---|---|
| **U** | Unit: hàm/lớp thuần (công thức sát thương, tìm đường, kinh tế…) | GdUnit4 (`GdUnitTestSuite`, mock/spy) | CI headless | Mỗi PR |
| **I** | Integration: nhiều hệ thống trong một sim headless (không render) | GdUnit4 + `SimHarness` (dựng trận từ fixture) | CI headless | Mỗi PR |
| **SC** | Scene/UI: nạp scene, giả lập chạm/kéo, kiểm tra node | GdUnit4 `GdUnitSceneRunner` (`simulate_mouse_*`, `simulate_screen_touch_*`) | CI headless | Mỗi PR |
| **T** | Test cho tool Python (CSV → tres, validator, balance) | `pytest` | CI | Mỗi PR |
| **P** | Hiệu năng/benchmark: scene chuẩn có N quân, đo ms/tick, FPS | Scene trong `tests/perf/`, `Performance.get_monitor` | Máy thật + CI nightly (chỉ đo CPU) | Nightly + cuối sprint |
| **D** | Thiết bị thật: input, nhiệt độ, vòng đời app | Checklist thủ công + `adb` | Ma trận thiết bị | Cuối sprint |
| **M** | Thủ công/khám phá: cảm giác chơi, nội dung, lịch sử | Checklist trong `tests/manual/` | Bản build sprint | Cuối sprint |
| **AI** | Tự chơi AI vs AI headless, thống kê | `tools/ci/ai_soak` (S10.T04) | CI nightly | Nightly từ S10 |

**Tỉ trọng mong muốn:** U ~60%, I ~20%, SC ~10%, còn lại là P, D, M.

## 2. Quy ước

- **Mã test case:** `<TaskID>-TC<n>`, ví dụ `S03.T02-TC4`. Tên hàm test GdUnit4 bắt đầu bằng mã này để truy vết, ví dụ `func test_s3_t02_tc4_double_tap_selects_same_type()`.
- **Vị trí file test:** `tests/<loại>/` đặt song song với `scripts/`, ví dụ `scripts/sim/combat/damage.gd` → `tests/unit/sim/combat/test_damage.gd`.
- **Fixture:** bản đồ nhỏ 32×32 và dữ liệu rút gọn đặt trong `tests/fixtures/`. Test **không** đọc dữ liệu cân bằng thật, trừ test có ghi rõ "dữ liệu thật".
- **Tất định:** mọi test I/SC/AI đều cố định seed RNG. Test không được phụ thuộc thời gian thực: dùng `SimHarness.step(n_ticks)` thay cho `await get_tree().create_timer()`.
- **Test thủ công** (M, D) lưu thành checklist Markdown trong `tests/manual/`. Kết quả ghi vào issue của sprint.

## 3. Cổng chất lượng trong CI

| Cổng | Điều kiện để merge |
|---|---|
| Lint | `gdlint` và `ruff` không còn lỗi |
| Unit/Integration/Scene | 100% pass, không có test bị skip mà chưa ghi lý do |
| Dữ liệu | `data_validator` pass |
| Build | Export APK debug thành công |
| Perf (nightly) | Không chậm hơn baseline quá 10%. Vượt ngưỡng thì tạo issue tự động |

## 4. Ma trận thiết bị

| Hạng | Máy tối thiểu cần có | Dùng cho |
|---|---|---|
| Thấp | 1 máy Snapdragon 6xx/Helio G8x, 4 GB RAM, Android 10 | P, D (min-spec) |
| Trung bình | 1 máy Snapdragon 7 Gen x | P, D |
| Cao | 1 máy flagship (hoặc Firebase Test Lab) | P |
| Tablet | 1 máy tablet 10–11" | D (bố cục UI) |

## 5. Tiêu chí lỗi

| Mức | Định nghĩa | Chặn phát hành? |
|---|---|---|
| Blocker | Crash, mất save, không chơi tiếp được | Có |
| Critical | Sai luật chơi lõi, AI kẹt, rò bộ nhớ | Có (từ M4) |
| Major | UI sai, hiệu năng dưới mục tiêu | Xét theo từng lỗi |
| Minor | Lỗi hiển thị, chính tả | Không |
