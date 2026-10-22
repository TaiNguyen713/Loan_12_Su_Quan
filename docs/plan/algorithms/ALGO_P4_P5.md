# Thuật toán & quy trình xử lý — Phase 4 & Phase 5 (S18 – S22)

> Quy ước chung: xem mục 0 của [ALGO_P0_P1.md](ALGO_P0_P1.md).

---

## Sprint 18 — Hiệu năng 800 quân

### S18.T01 — Profiling & chốt trần quân theo hạng máy
**Scene benchmark** `tests/perf/bench_200|400|800.tscn`:
- 2 phe chia thành các Đội 50 người.
- Giao chiến ở giữa bản đồ "Hai đàng". Có 6 Đội lính súng bắn loạt, 4 khẩu đại bác và 2 Đội đi qua cầu.
- Seed cố định, chạy 120 giây, bỏ 10 giây đầu.

**Đo:** FPS p50/p1, ms của sim theo từng hệ thống (pathing, avoidance, combat, fog, economy), GPU ms, RAM.

**Phân hạng máy khi khởi động** (đọc model GPU, số RAM, rồi chạy 3 giây micro-benchmark sim với 400 quân giả lập):

| Hạng | Điều kiện | `cap_match` | Mặc định đồ họa |
|---|---|---|---|
| Thấp | RAM < 6 GB **hoặc** micro-bench > 9 ms/tick | 400 | Thấp |
| Trung | còn lại | 800 | Trung |
| Cao | RAM ≥ 8 GB **và** micro-bench < 4 ms/tick | 800 | Cao |

**Mục tiêu nghiệm thu:**

| Hạng | Mục tiêu |
|---|---|
| Trung | p50 ≥ 30 FPS với 800 quân |
| Thấp | p50 ≥ 30 FPS với 400 quân |
| Cao | p50 ≥ 45 FPS với 800 quân |

Kết quả ghi vào `docs/perf/baseline.csv`. Nếu không đạt thì phải có quyết định hạ trần quân và ghi lại trong GDD.

### S18.T02 — Port C++ (GDExtension)
- **Ứng viên:** flow field, avoidance, fog, tìm mục tiêu. Chỉ port hệ thống chiếm > 15% thời gian sim.
- Cùng API với bản GDScript, chọn qua cờ `Settings.native_hot_paths`.
- **Parity test:** so sánh 100 map ngẫu nhiên, kết quả phải bằng nhau tuyệt đối (dùng kiểu số nguyên).
- Build bằng SCons cho android arm64/arm32 và windows/linux, dùng godot-cpp nhánh 4.5.

### S18.T03 — MultiMesh & LOD
- Mỗi (loại quân × phe) dùng 1 MultiMeshInstance2D. `custom_data = (frame, team, flags)`, shader tự chọn frame trên atlas.
- **Sắp theo chiều sâu:** sắp lại thứ tự instance mỗi 4 frame bằng insertion sort.
- **LOD theo zoom:**

| Zoom | Hiển thị |
|---|---|
| < 0.6 | Atlas nửa độ phân giải, hoạt ảnh 6 fps, tắt bóng |
| < 0.45 | Chỉ vẽ **cờ Đội** cùng chấm màu của lính lẻ |

  Có độ trễ ±0.03 khi đổi mức để tránh nhấp nháy.
- **Mục tiêu:** ≤ 150 draw call với 800 quân.

### S18.T04 — Bộ nhớ, tải, nhiệt, pin
- **Tải trận:** threaded load chỉ asset của các phe có trong trận, kèm scene khởi động shader. Mục tiêu tải < 8 giây.
- **Rò bộ nhớ:** soak 30 phút, hồi quy tuyến tính `MEMORY_STATIC`. Độ dốc > 2 MB/phút là có rò rỉ.
- **Tiết kiệm pin:** 30 FPS, tắt particle, LOD từ zoom 0.8.
- **Nhiệt:** khi thermal status ≥ 2 thì tự hạ xuống 30 FPS và hiện toast.

---

## Sprint 19 — UX, lưu game, đa ngôn ngữ

### S19.T01 — Lưu/tải giữa trận
**Snapshot** (JSON nén zstd) gồm:
- `version: 2, scenario_id, mode, tick, match_seed, rng_states`;
- `teams[{faction, era, res[6], researches_done[], modifier_stack, ai_blackboard, unit_cap}]`;
- `market{p[6]}, relations{VOC:{…}, BDN:{…}}, ally{…}`, `merchant_ships[]`, `ferries[]`, `bridges[{id, hp}]`;
- `territory` (base64), `entities[theo ID: …, capture_t, origin_faction, formation_id]`;
- `formations[{id, type, shape, officer, drummer, members, slots}]`, `fog_explored`, `triggers_state`, `flags`, `pending_commands`.

**Luật:**
- Tải xong, hash trạng thái phải bằng hash lúc lưu; chạy tiếp N tick phải khớp với chạy liền không lưu.
- Có migrator `v1 → v2`. File hỏng thì báo lỗi và giữ nguyên file cũ.
- **Tự lưu:** mỗi 120 giây và khi app ra nền; giữ 3 slot xoay vòng. Ghi theo kiểu `tmp` → rename.

### S19.T02 — Cài đặt
- `ConfigFile` lưu tại `user://settings.cfg`.

| Cài đặt | Giá trị |
|---|---|
| **Cỡ UI** | 0.85–1.3, nhân trên khung pt |
| **Kéo 1 ngón để cuộn** | Mặc định tắt (S2.T05) |
| **Tay trái** | Đổi bên minimap ↔ nút Xây/Thêm điểm, cột nhóm sang phải |
| **Mù màu** | Chồng hoa văn phe lên mask |
| Âm thanh | Volume theo bus |
| Đồ họa | Thấp/Trung/Cao |
| Rung | Bật/tắt |
| Trần quân | Chỉ giảm được, không tăng quá hạng máy |

- **Kiểm tra tràn màn hình:** mọi Control của HUD phải nằm trong safe area ở cỡ UI 1.3 với khung 844×390.

### S19.T03 — Hướng dẫn tương tác
- Overlay khoét lỗ tại control cần chạm, chặn input ở các vùng khác. Bước tiếp theo mở khi nhận đúng event.
- **Bổ sung cho NV1** (giữ nguyên trigger S15.T01). Các bước:
  1. chạm chọn dân;
  2. **giữ 0.3 giây rồi kéo** để khung chọn;
  3. **kéo 2 ngón** để cuộn;
  4. chụm để zoom;
  5. mở lưới **Xây**, đặt Làng;
  6. vào **Ruộng** / **Mỏ**;
  7. chạm nhóm tài nguyên để xem thu/chi;
  8. **Lập Đội 30**;
  9. đổi hình **Vuông**;
  10. lệnh **Đi và đánh**.
- Có nút "Bỏ qua". Đặt `Settings.tutorial_done = true` khi xong hoặc bỏ qua.

### S19.T04 — Đa ngôn ngữ
- File `localization/strings.csv` có cột `keys, vi, en`.
- Lint chuỗi hard-code bằng regex tìm ký tự có dấu `[À-ỹ]` hoặc ≥ 2 từ chữ nằm ngoài `tr()`.
- Kiểm tra không thiếu khóa giữa vi và en.
- **Font:** Be Vietnam Pro, dự phòng Noto Sans. Câu kiểm tra glyph: "Phủ chúa, Lũy Thầy, Tào Ty, Diêm tiêu, ỷ ỹ ự ữ ẵ ẫ".
- **Tràn chữ** ở khung 844×390: nút 48×48 pt chỉ được tối đa 2 dòng × 8 ký tự; dài hơn thì dùng nhãn viết tắt kèm tooltip khi giữ nút.

---

## Sprint 20 — Tích hợp Android & release

### S20.T01 — Hành vi Android
- **Back:** đang trong trận thì mở menu tạm dừng; ở menu chính thì hỏi "Thoát?". `quit_on_go_back = false`.
- **Ra nền:** tạm dừng, tắt tiếng, tự lưu. Quay lại thì vẫn tạm dừng.
- **Safe area:** `max(44 pt, inset thật)` cho trái/phải; đáy là `max(8 pt, inset thanh home)`.
- **Xoay:** `sensor_landscape`. Khi `size_changed` thì tính lại bố cục.

### S20.T02 — Sentry & Data safety
- Chỉ khởi tạo SDK khi người chơi đồng ý. Gửi kèm `release`, `environment`, breadcrumb từ EventBus (lấy mẫu). Không gửi dữ liệu cá nhân.
- Nút "Crash thử" chỉ có ở bản debug.
- Bảng Data safety điền theo dữ liệu SDK thực sự gửi.

### S20.T03 — Billing / Play Games (tùy chọn)
`query_purchases` lúc khởi động → acknowledge các giao dịch → cache quyền sở hữu (kèm hash). Chế độ offline dùng cache. Mở thành tích khi kết thúc NV1.

### S20.T04 — AAB release
- `version_code = MAJOR×10000 + MINOR×100 + PATCH`, phải lớn hơn bản trước.
- Keystore lưu base64 trong secret → file tạm → `GODOT_ANDROID_KEYSTORE_RELEASE_*` → xóa ở bước `always()`; mask mật khẩu.
- Kiểm tra bằng `bundletool validate`, sau đó so `targetSdk`.

---

## Sprint 21 — Closed beta *(quy trình)*

- **S21.T01:** tạo kênh Closed testing, Google Group tester, link opt-in. Đảm bảo đủ số tester và số ngày test theo chính sách Play **tại thời điểm thực hiện**. Cập nhật bản mới thì save cũ vẫn mở được.
- **S21.T02:** phân loại lỗi trong ≤ 48 giờ. Sửa lỗi theo thứ tự viết test tái hiện → sửa → PR. **Cân bằng 2 phe:** gom winrate (nếu tester đồng ý chia sẻ), chạy lại tool S5.T05 và vòng cân bằng S12.T02.
- **S21.T03:** đọc pre-launch report, xử lý theo thứ tự crash > ANR > bảo mật > khả năng truy cập.

## Sprint 22 — Phát hành *(quy trình)*

- **S22.T01:** chụp 8 ảnh 16:9 từ bản build (có HUD 844×390 thật), trailer 30–60 giây, mô tả vi/en. Hoàn tất IARC và Data safety.
- **S22.T02:**
  - **Checklist:** CI xanh, 0 blocker, 0 critical, benchmark đạt S18.T01, save beta mở được, đủ bản dịch.
  - **Rollout:** 10% → 48 giờ → 50% → 48 giờ → 100%.
  - **Dừng** khi crash-free < 99.5%, hoặc ANR ≥ 0.47%, hoặc có lỗi mất save.
- **S22.T03:** cảnh báo Sentry khi có lỗi mới hoặc lỗi chiếm > 1% số phiên mỗi giờ. Theo dõi Android vitals mỗi ngày trong 14 ngày đầu.
