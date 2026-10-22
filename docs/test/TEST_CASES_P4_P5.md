# Test case — Phase 4 & Phase 5 (S18 – S22)

Loại: **U** unit · **I** integration · **SC** scene/UI · **P** hiệu năng · **D** thiết bị thật · **M** thủ công · **CI** pipeline.

---

## Sprint 18 — Hiệu năng 800 quân

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S18.T01-TC1 | P | Máy hạng Trung | `bench_800` | p50 ≥ 30 FPS |
| S18.T01-TC2 | P | Máy hạng Thấp | `bench_400` | p50 ≥ 30 FPS |
| S18.T01-TC3 | U | RAM 4 GB | Phân hạng | Thấp, `cap_match = 400` |
| S18.T01-TC4 | P | Chạy benchmark 2 lần | So sánh | Chênh < 5% |
| S18.T02-TC1 | U | Flow field C++ và GDScript | 100 map | Output giống hệt |
| S18.T02-TC2 | P | Benchmark | So thời gian | C++ nhanh hơn ≥ 3 lần |
| S18.T02-TC3 | D | Máy arm32 | Chạy | Không crash |
| S18.T03-TC1 | P | 800 quân | Đếm draw call | ≤ 150 |
| S18.T03-TC2 | SC | Zoom 0.44 | Xem | Chỉ có cờ Đội và chấm màu |
| S18.T03-TC3 | M | Zoom quanh ngưỡng 0.45 | Quan sát | Không nhấp nháy |
| S18.T04-TC1 | D | Máy hạng Thấp | Đo thời gian tải | < 8 s |
| S18.T04-TC2 | D | Soak 30 phút | Đo độ dốc RAM | < 2 MB/phút |
| S18.T04-TC3 | D | Thermal status 2 | Chạy | Tự hạ xuống 30 FPS, có toast |

---

## Sprint 19 — UX, lưu game, đa ngôn ngữ

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S19.T01-TC1 | I | Trận có chợ, quan hệ, phà đang chạy, Đội | Lưu → tải → chạy 1000 tick | Hash khớp với chạy liền |
| S19.T01-TC2 | U | Save v1 | Nạp | Migrator đưa lên v2 |
| S19.T01-TC3 | U | File save bị cắt nửa | Nạp | Báo lỗi, giữ file cũ |
| S19.T01-TC4 | D | App bị hệ điều hành kill | Mở lại | Có bản tự lưu ≤ 2 phút trước |
| S19.T02-TC1 | SC | Cỡ UI 1.3, khung 844×390 | Đo | Mọi control nằm trong safe area |
| S19.T02-TC2 | SC | Bật "Kéo 1 ngón để cuộn" | Kéo 1 ngón | Camera cuộn |
| S19.T02-TC3 | SC | Tay trái | Bật | Minimap ↔ nút Xây đổi bên, cột nhóm sang phải |
| S19.T02-TC4 | SC | Máy hạng Thấp | Đặt trần quân 800 | Không cho phép (tối đa 400) |
| S19.T03-TC1 | M | 5 người mới | Hướng dẫn | Trung vị < 10 phút, ≥ 4/5 người hoàn thành |
| S19.T03-TC2 | SC | Bước "giữ 0.3 s rồi kéo" | Kéo mà không giữ | Không sang bước tiếp |
| S19.T04-TC1 | CI | Lint chuỗi | Quét | Không còn chuỗi hard-code |
| S19.T04-TC2 | U | vi và en | So khóa | Không thiếu khóa |
| S19.T04-TC3 | M | Câu kiểm tra glyph | Hiển thị | Dấu đúng, không ra ô vuông |
| S19.T04-TC4 | SC | Tiếng Anh, nút 48 pt | Xem | ≤ 2 dòng; dài hơn thì có tooltip khi giữ nút |

---

## Sprint 20 — Tích hợp Android & release

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S20.T01-TC1 | D | Trong trận | Nhấn Back | Mở menu tạm dừng |
| S20.T01-TC2 | D | Trong trận | Home rồi quay lại | Vẫn tạm dừng, đã tự lưu |
| S20.T01-TC3 | D | Máy có thanh home | Đo | Bảng lệnh cách đáy ≥ inset của thanh home |
| S20.T01-TC4 | D | Xoay ngang 180° | — | Bố cục và input đúng |
| S20.T02-TC1 | D | Nút crash thử | Nhấn | Sentry có sự kiện kèm stack trace |
| S20.T02-TC2 | D | Người chơi từ chối chia sẻ | Chơi | Không có sự kiện nào được gửi |
| S20.T03-TC1 | D | Tài khoản test | Mua rồi cài lại | Khôi phục được |
| S20.T04-TC1 | CI | Tag `v*` | Chạy release | AAB đã ký, version code tăng |
| S20.T04-TC2 | CI | `bundletool validate` | Chạy | Hợp lệ, targetSdk đúng |
| S20.T04-TC3 | CI | Log | Kiểm tra | Không lộ secret |

### Milestone M4
| ID | Loại | Bước | Kết quả mong đợi |
|---|---|---|---|
| M4-TC1 | P | Benchmark theo hạng máy | Đạt mục tiêu S18.T01 |
| M4-TC2 | M | Rà danh sách lỗi | 0 blocker, 0 critical |

---

## Sprint 21 — Closed beta

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S21.T01-TC1 | D | Link opt-in | Cài từ Play | Thành công |
| S21.T01-TC2 | D | Phát hành bản cập nhật | Mở save cũ | Mở được |
| S21.T02-TC1 | M | Lỗi được báo | Phân loại | Có mức độ và người phụ trách trong ≤ 48 giờ |
| S21.T02-TC2 | CI | Mỗi lỗi đã sửa | Kiểm tra | Có test hồi quy |
| S21.T02-TC3 | AI | Sau vòng cân bằng beta | 50 trận | Winrate Trịnh 45–55% |
| S21.T03-TC1 | D | Pre-launch report | Đọc | 0 crash, 0 ANR |

## Sprint 22 — Phát hành

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S22.T01-TC1 | M | Ảnh chụp | Đối chiếu với bản build | Ảnh thật, có HUD 844×390 |
| S22.T01-TC2 | M | Mô tả vi/en | Soát | Không có lỗi |
| S22.T02-TC1 | M | Checklist | Rà | 100% mục đạt |
| S22.T02-TC2 | M | Rollout 10% | Theo dõi 48 giờ | Crash-free ≥ 99.5% thì lên 50%, không đạt thì dừng |
| S22.T03-TC1 | M | Crash mới | Theo dõi | Có cảnh báo trong ≤ 15 phút |
| S22.T03-TC2 | M | Android vitals tuần đầu | Đọc | ANR < 0.47%, crash < 1.09% |
