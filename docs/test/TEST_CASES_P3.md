# Test case — Phase 3 (S11 – S17)

Loại: **U** unit · **I** integration · **SC** scene/UI · **T** tool · **P** hiệu năng · **D** thiết bị thật · **M** thủ công · **AI** tự chơi headless · **CI** pipeline.

---

## Sprint 11 — Pipeline đồ họa

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S11.T01-TC1 | M | Style guide | Rà 5 nhóm tư liệu | Mỗi ảnh có nguồn |
| S11.T01-TC2 | M | Bảng màu | Mô phỏng deuteranopia và protanopia | Vẫn phân biệt được 2 phe |
| S11.T02-TC1 | T | Model quân bộ | Render | 8 hướng × 4 hoạt ảnh |
| S11.T02-TC2 | T | Model thuyền (`--kind ship`) | Render | 8 hướng × (đi, chìm) |
| S11.T02-TC3 | T | Render 2 lần | So hash | Giống nhau |
| S11.T02-TC4 | T | Thiếu action | Chạy | Exit 1, báo tên action |
| S11.T03-TC1 | CI | Các file `.import` | Kiểm tra | Nén VRAM, không có mipmaps |
| S11.T03-TC2 | D | Trận đủ asset | Đo RAM texture | < 150 MB |
| S11.T04-TC1 | U | Góc 0–359° | Ánh xạ sang 8 hướng | Đúng sector |
| S11.T04-TC2 | SC | Zoom 0.55 | Nhìn một Đội | Chỉ vẽ cờ Đội kèm số thứ tự |

---

## Sprint 12 — Đủ quân, công trình & âm thanh

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S12.T01-TC1 | U | Đơn vị chung | Kiểm tra | Có sprite, icon, chỉ số, bản dịch; validator pass |
| S12.T01-TC2 | T | Roster | Chạy tool DPS/TTK | Không cặp nào bị cảnh báo |
| S12.T02-TC1 | AI | 50 trận Trịnh vs Nguyễn, "Hai đàng", GĐ I | Thống kê | Winrate của Trịnh trong 45–55% |
| S12.T02-TC2 | AI | 20 trận "Ven biển" | Thống kê | Trong 40–60% |
| S12.T02-TC3 | U | Thổ binh trong 15 ô quanh Làng / ở ngoài | Đọc giáp | 4 / 1 |
| S12.T02-TC4 | M | `CHANGELOG` cân bằng | Rà | Mỗi vòng chỉnh có ghi lý do và số liệu |
| S12.T03-TC1 | SC | Mỗi công trình | Chuyển qua 4 trạng thái | Sprite đổi đúng |
| S12.T03-TC2 | SC | Công trình bị chiếm | Xem | Màu phe đổi theo mask |
| S12.T04-TC1 | I | Loạt bắn 30 lính súng | Đếm voice | Chỉ 1 âm thanh loạt |
| S12.T04-TC2 | I | 100 tiếng nổ cùng lúc | Đếm voice | ≤ 14 |
| S12.T04-TC3 | CI | `LICENSES.md` | Kiểm tra | Không file âm thanh nào thiếu giấy phép |

---

## Sprint 13 — Thủy quân, bến phà, dịch bệnh

### S13.T01 — Thủy chiến
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S13.T01-TC1 | U | Thuyền chiến, mục tiêu ở góc 90° so với mũi | Bắn | Không bắn ngay mà quay mũi trước |
| S13.T01-TC2 | U | Tàu VOC, mục tiêu ở trước mũi (0°) | Bắn | Không bắn (chỉ bắn hai mạn) |
| S13.T01-TC3 | I | 3 ngư binh vây 1 tàu VOC | Chạy | Tàu −20% tốc độ |
| S13.T01-TC4 | U | Ngư binh bắn tàu VOC | Tính sát thương | `max(1, 10 × 2 − 6) = 14` |
| S13.T01-TC5 | I | Thuyền chở 10 quân bị chìm | Chạy | 10 quân chết |
| S13.T01-TC6 | I | Đổ bộ | Thả quân | Quân xuống các ô đất trong bán kính 2 ô |

### S13.T02 — Bến phà & cầu
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S13.T02-TC1 | I | 25 lính ở bến A | Lệnh sang B | Chuyến 1 chở 20, chuyến 2 chở 5; mỗi chuyến 12 s |
| S13.T02-TC2 | U | 7 voi | Một chuyến | Chở tối đa 6 voi (3 × 6 = 18 ≤ 20) |
| S13.T02-TC3 | U | Cầu ở xa, bến phà ở gần | A* | Chọn bến phà khi chi phí thấp hơn |
| S13.T02-TC4 | I | Phà bị đánh chìm khi đang chở | Chạy | Quân trên phà chết; phà hồi sinh sau 60 s |
| S13.T02-TC5 | I | Đại bác phá cầu | Chạy | Ô cầu thành sông, quân đang đứng trên cầu chết, cache bị xóa |
| S13.T02-TC6 | U | Lính súng bắn cầu | Tính sát thương | 0 |
| S13.T02-TC7 | I | Dân sửa cầu | 30 s, đủ tài nguyên | Cầu đi lại được |

### S13.T03 — AI thủy & qua sông
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S13.T03-TC1 | AI | Cầu duy nhất bị phá | Chạy | AI qua sông bằng bến phà hoặc thuyền trong ≤ 3 phút |
| S13.T03-TC2 | AI | Bản đồ ven biển | 10 trận | AI xây Cảng và có thuyền chiến |

### S13.T04 — Dịch bệnh
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S13.T04-TC1 | I | Bật dịch bệnh, quân ở ngoài lãnh thổ 200 s, xa nguồn lúa 50 ô | Chạy 60 s sau mốc 180 s | Mất 6% máu, có biểu tượng bệnh |
| S13.T04-TC2 | I | Quân về lãnh thổ | Chạy | Hết bệnh, bộ đếm về 0 |
| S13.T04-TC3 | I | Tắt dịch bệnh | Chạy như TC1 | Không mất máu |
| S13.T04-TC4 | U | Máu 21% | Tick bệnh | Không xuống dưới 20% |

---

## Sprint 14 — Trigger, chế độ chơi, tiến trình

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S14.T01-TC1 | U | Trigger `once` | Điều kiện đúng 2 lần | Hành động chạy 1 lần |
| S14.T01-TC2 | U | AND/OR lồng nhau | Đánh giá | Đúng bảng chân trị |
| S14.T01-TC3 | U | `wall_segments_built(area, 40)` | Xây 39 rồi 40 đoạn | Đúng ở đoạn thứ 40 |
| S14.T01-TC4 | U | Tham chiếu sai | Nạp màn | Báo lỗi khi nạp |
| S14.T02-TC1 | SC | Hội thoại 5 câu | Chạm, rồi Bỏ qua | Sang câu đúng; bỏ qua thì tới cuối |
| S14.T02-TC2 | SC | Khung 844×390 | Đo hộp thoại | Cao ≤ 120 pt |
| S14.T03-TC1 | U | Đặt bến phà và điểm thương nhân bằng plugin, lưu rồi nạp | Round-trip | Không mất dữ liệu |
| S14.T04-TC1 | SC | Trận lịch sử | Mở HUD | Không có nút Xây, không có nút luyện quân |
| S14.T04-TC2 | D | Máy tầm trung | Đo thời gian vào trận | < 10 s |
| S14.T04-TC3 | I | Trận lịch sử | Chạy 5 phút | Lúa không giảm (tắt upkeep), đạn dược vẫn trừ |
| S14.T05-TC1 | SC | Save mới | Mở chiến dịch Trịnh | Chỉ mở NV2 |
| S14.T05-TC2 | I | Thắng NV2 ở chiến dịch Nguyễn | Mở chiến dịch Trịnh | NV2 bên Trịnh vẫn ở trạng thái "unlocked" (lưu riêng) |
| S14.T05-TC3 | I | Tắt app giữa lúc ghi save | Mở lại | Save không hỏng |

---

## Sprint 15 — Chiến dịch I

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S15.T01-TC1 | M | NV1 | Người mới chơi | Hoàn thành trong 12–15 phút |
| S15.T01-TC2 | I | Lời giải mẫu NV1 | Chạy headless | Thắng |
| S15.T01-TC3 | SC | Bước "lập Làng" | Đặt Làng trên đất trống | Giá hiện đã giảm 30%; có câu thoại giải thích khẩn hoang |
| S15.T02-TC1 | I | NV2 phe Nguyễn | Giữ Phủ 12 phút | Thắng |
| S15.T02-TC2 | I | NV2 phe Trịnh | Không chiếm được Phủ trong 12 phút | Thua, hiện lời kết lịch sử |
| S15.T02-TC3 | I | Lời giải mẫu cho cả 2 phe | Chạy headless | Thắng |
| S15.T03-TC1 | I | NV3 | Xây 40 đoạn trước phút 10 | Mục tiêu 1 xong; quân Trịnh tới đúng phút 10 |
| S15.T03-TC2 | I | NV3 | Tới phút 10 mới có 30 đoạn | Thua |
| S15.T03-TC3 | SC | NV3 | Nhìn HUD | Đồng hồ đếm ngược ở dưới thanh trên, không che thẻ cảnh báo |
| S15.T04-TC1 | U | Đào Duy Từ cách quân 200 px | Đọc tốc độ xây Lũy | ×1.5 |
| S15.T04-TC2 | U | 2 chỉ huy có aura sĩ khí chồng nhau | Tính | Lấy giá trị lớn nhất |
| S15.T04-TC3 | I | Chỉ huy bắt buộc chết | Chạy | Thua nhiệm vụ |
| S15.T04-TC4 | SC | Đấu tự do | Mở danh sách luyện quân | Không có chỉ huy |

---

## Sprint 16 — Chiến dịch II

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S16.T01-TC1 | I | NV4 | Đánh chìm cả 3 tàu VOC | Thắng; `rel(VOC, Nguyễn)` +30 |
| S16.T01-TC2 | I | NV4 | Mất hết thuyền | Thua |
| S16.T01-TC3 | P | NV4 có 50 ngư binh + 3 tàu + thuyền Trịnh | Đo FPS trên máy tầm trung | ≥ 30 FPS |
| S16.T02-TC1 | I | NV5 | Giữ được pha 1 trong 10 phút | Sang pha 2: trời tối, tầm nhìn ×0.5, nhận 20 voi |
| S16.T02-TC2 | I | NV5 pha 2 | Phá 3 doanh trại trong 8 phút | Thắng |
| S16.T03-TC1 | I | NV6 | Giữ mỗi vùng trong 60 giây | Mục tiêu xong từng vùng |
| S16.T03-TC2 | I | NV6 | Mất Trịnh Căn | Mất 1 sao (chỉ huy không bắt buộc), nhiệm vụ không thua |
| S16.T04-TC1 | I | NV7 | Tới phút 15 | Đình chiến, có màn kết "sông Gianh thành giới tuyến" |
| S16.T04-TC2 | U | Điểm đình chiến 0.55 | Tính sao | 2 sao |
| S16.T04-TC3 | I | Phủ người chơi bị chiếm ở phút 12 | Chạy | Thua |

---

## Sprint 17 — Nội dung lịch sử & thẩm định

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S17.T01-TC1 | U | Mọi mục bách khoa | Kiểm tra trường `sources` | Không mục nào rỗng |
| S17.T01-TC2 | SC | Mục có `certainty = conflict` | Mở | Hiện huy hiệu "Nguồn lệch" |
| S17.T02-TC1 | M | `history_review.csv` | Rà | Không còn dòng "Sửa" nào mở |
| S17.T02-TC2 | M | Lời kết các nhiệm vụ | Rà riêng tính cân bằng | Có ghi nhận của người duyệt |
| S17.T02-TC3 | M | Chi tiết hư cấu | Kiểm tra | Có `fiction_note` |
| S17.T03-TC1 | I | 5 trận lịch sử | Lời giải mẫu | Đều thắng |
| S17.T03-TC2 | M | Mỗi trận | Chơi | 10–15 phút |

### Milestone M3
| ID | Loại | Bước | Kết quả mong đợi |
|---|---|---|---|
| M3-TC1 | M | Chơi hết chiến dịch Nguyễn (NV1–5) và Trịnh (NV2, 6, 7) | Không có blocker |
| M3-TC2 | CI | Quét asset placeholder | Không còn cái nào |
