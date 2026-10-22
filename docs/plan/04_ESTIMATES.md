# 04 — Ước lượng công (giờ & story point)

> Sinh tự động từ bảng ước lượng. Sửa số thì sửa bảng nguồn rồi sinh lại (hoặc sửa tay cả bảng và phần tổng).
> Liên quan: [01_ROADMAP.md](01_ROADMAP.md) · thuật toán: [algorithms/](algorithms/ALGO_P0_P1.md)

## 1. Giả định

| Vai trò | Ký hiệu | Năng lực mỗi sprint (giờ hiệu dụng) | Ghi chú |
|---|---|---|---|
| Lập trình viên | DEV | 120 | 2 người × 10 ngày × 6 giờ hiệu dụng |
| Họa sĩ | ART | 40 | 1 người bán thời gian (≈ 50%) |
| Âm thanh | AUD | 10 | Bán thời gian hoặc thuê ngoài |
| Kiểm thử | QA | 20 | Bán thời gian; dev tự viết test tự động (đã tính trong giờ DEV) |
| Thiết kế game / PO | DES | 30 | Thiết kế màn, cân bằng, nội dung lịch sử, duyệt |

- **Giờ** là giờ làm việc lý tưởng của người có kinh nghiệm với Godot, **đã gồm** viết test tự động theo TEST_CASES và review code.
- **Story point (SP)** theo dãy Fibonacci, quy đổi theo tổng giờ của task: ≤4h=1 · ≤8h=2 · ≤14h=3 · ≤24h=5 · ≤40h=8 · ≤64h=13 · ≤100h=21 · >100h=34.
- **Khoảng dao động:** thấp = 0.8 × ước lượng, cao = 1.5 × ước lượng. Task có ghi "Rủi ro cao" nên dùng mức cao khi lập sprint.
- Nếu chỉ có **1 lập trình viên**: năng lực DEV = 60 giờ/sprint, tức tiến độ phần lập trình kéo dài khoảng ×1.6–2.

## 2. Ước lượng từng task


### Sprint 0 — Tiền sản xuất & CI

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S0.T01 | Duyệt GDD v2 với Nam Bắc + wireframe |  | 2 |  |  | 10 | 12 | 3 | 10–18 |  |
| S0.T02 | ADR-001, ADR-002 | 4 |  |  |  |  | 4 | 1 | 3–6 |  |
| S0.T03 | Chuẩn hóa repo | 6 |  |  |  |  | 6 | 2 | 5–9 |  |
| S0.T04 | CI lint/test/export + version-guard | 16 |  |  |  |  | 16 | 5 | 13–24 |  |
| S0.T05 | Framework test + xác nhận R1–R3 | 8 |  |  |  |  | 8 | 2 | 6–12 |  |
| S0.T06 | Spike 800 quân + đo trên máy thật | 32 |  |  | 6 |  | 38 | 8 | 30–57 | Rủi ro cao: quyết định trần quân |
| S0.T07 | Thử phong cách đồ họa ở khung 844×390 | 2 | 16 |  |  |  | 18 | 5 | 14–27 |  |

### Sprint 1 — Kiến trúc lõi & dữ liệu

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S1.T01 | Khởi tạo project + lint lớp | 16 |  |  |  |  | 16 | 5 | 13–24 |  |
| S1.T02 | EventBus + SceneRouter | 10 | 2 |  |  |  | 12 | 3 | 10–18 |  |
| S1.T03 | Custom Resource (6 tài nguyên, era, growth, ammo) | 18 |  |  |  | 4 | 22 | 5 | 18–33 |  |
| S1.T04 | Tool CSV→tres + validator 6 luật | 20 |  |  |  |  | 20 | 5 | 16–30 |  |
| S1.T05 | Tick cố định + nội suy | 10 |  |  |  |  | 10 | 3 | 8–15 |  |
| S1.T06 | RNG + CommandQueue + state hash | 16 |  |  | 2 |  | 18 | 5 | 14–27 |  |

### Sprint 2 — Bản đồ, sông/cầu/bến phà, tìm đường, camera

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S2.T01 | Địa hình: sông, cầu, bến phà, biển | 18 | 18 |  |  |  | 36 | 8 | 29–54 |  |
| S2.T02 | Sinh bản đồ hai đàng / ven biển / 1–4 người | 24 |  |  |  | 6 | 30 | 8 | 24–45 |  |
| S2.T03 | A* + flow field 2 lớp đất/nước | 36 |  |  |  |  | 36 | 8 | 29–54 | Rủi ro cao: 800 quân |
| S2.T04 | Né tránh 800 quân + cầu | 24 |  |  |  |  | 24 | 5 | 19–36 | Rủi ro cao |
| S2.T05 | Camera 2 ngón + safe area | 10 |  |  | 2 |  | 12 | 3 | 10–18 |  |
| S2.T06 | Minimap 120 pt | 8 |  |  |  |  | 8 | 2 | 6–12 |  |

### Sprint 3 — Cử chỉ, chọn quân, lệnh, cảnh báo

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S3.T01 | Cử chỉ (giữ 0.3 s → khung chọn, 2 ngón) | 18 |  |  | 4 |  | 22 | 5 | 18–33 |  |
| S3.T02 | Chọn quân + 5 ô nhóm + Rảnh | 16 | 4 |  |  |  | 20 | 5 | 16–30 |  |
| S3.T03 | Lệnh + Thêm điểm + Điểm tập kết | 22 |  |  |  |  | 22 | 5 | 18–33 |  |
| S3.T04 | FSM LimboAI (WorkInside, Hold, Rest, Guard) | 22 |  |  |  |  | 22 | 5 | 18–33 | Phụ thuộc R3 |
| S3.T05 | Phản hồi + thẻ cảnh báo | 12 | 2 | 4 |  |  | 18 | 5 | 14–27 |  |

### Sprint 4 — Kinh tế lõi

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S4.T01 | Khai thác ruộng/rừng/mỏ + thuế đinh | 24 |  |  |  |  | 24 | 5 | 19–36 |  |
| S4.T02 | Đặt & xây + lưới Xây 4 tab + giá tăng dần | 24 | 6 |  |  | 2 | 32 | 8 | 26–48 |  |
| S4.T03 | Tuyển dân +1/−1/+5/vô hạn, dân số, trần quân | 16 |  |  |  |  | 16 | 5 | 13–24 |  |
| S4.T04 | Thanh trên 6 tài nguyên + thu/chi + bảng lệnh | 20 | 8 |  |  | 4 | 32 | 8 | 26–48 |  |
| S4.T05 | Upkeep Lúa + đạn dược + Tiền âm | 12 |  |  |  | 2 | 14 | 3 | 11–21 |  |
| S4.T06 | Lãnh thổ + khẩn hoang | 12 |  |  |  | 2 | 14 | 3 | 11–21 |  |
| M1 | Kiểm thử milestone M1 |  |  |  | 12 | 4 | 16 | 5 | 13–24 |  |

### Sprint 5 — Chiến đấu

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S5.T01 | Sát thương + luật công trình quân sự | 14 |  |  |  |  | 14 | 3 | 11–21 |  |
| S5.T02 | Đạn, lan, pool, đạn dược | 16 | 6 |  |  |  | 22 | 5 | 18–33 |  |
| S5.T03 | Chọn mục tiêu | 14 |  |  |  |  | 14 | 3 | 11–21 |  |
| S5.T04 | Chết, xác, hiệu ứng | 10 | 10 | 4 |  |  | 24 | 5 | 19–36 |  |
| S5.T05 | Tool cân bằng 6 tài nguyên | 14 |  |  |  | 6 | 20 | 5 | 16–30 |  |

### Sprint 6 — Đội, đội hình, sĩ khí, 8 lệnh

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S6.T01 | Ba hình, giữ hàng, qua cầu | 34 |  |  |  |  | 34 | 8 | 27–51 | Rủi ro cao |
| S6.T02 | Lập Đội một nút + bonus + bổ sung | 22 | 4 |  |  | 4 | 30 | 8 | 24–45 |  |
| S6.T03 | Sĩ khí & tháo chạy | 16 |  |  |  | 4 | 20 | 5 | 16–30 |  |
| S6.T04 | 8 lệnh Cossacks + bắn loạt | 22 |  |  |  |  | 22 | 5 | 18–33 |  |

### Sprint 7 — Sương mù chiến tranh

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S7.T01 | Lưới fog + shader | 18 |  |  |  |  | 18 | 5 | 14–27 |  |
| S7.T02 | Tầm nhìn, ẩn địch, bóng ma | 16 |  |  |  |  | 16 | 5 | 13–24 |  |
| S7.T03 | Fog trên minimap | 4 |  |  |  |  | 4 | 1 | 3–6 |  |
| S7.T04 | Tối ưu fog 800 quân | 12 |  |  |  |  | 12 | 3 | 10–18 |  |

### Sprint 8 — Lũy, nghiên cứu, giai đoạn, chiếm đoạt

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S8.T01 | Lũy đứng lên được + tường + cổng + đồn | 34 | 6 |  |  |  | 40 | 8 | 32–60 | Rủi ro cao: lưới theo phe/loại quân |
| S8.T02 | Thư phòng + 40 nghiên cứu | 22 | 10 |  |  | 10 | 42 | 13 | 34–63 |  |
| S8.T03 | Chuyển giai đoạn I→II | 10 |  |  |  | 2 | 12 | 3 | 10–18 |  |
| S8.T04 | Chiếm đoạt trễ 2 s + công trình phe khác + sửa | 18 |  |  |  | 2 | 20 | 5 | 16–30 |  |

### Sprint 9 — Chợ, cảng, thương điếm, chính trị

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S9.T01 | Chợ giá dùng chung | 14 | 4 |  |  | 4 | 22 | 5 | 18–33 |  |
| S9.T02 | Cảng + thuyền buôn NPC + thuế + Tào Ty | 24 | 6 |  |  | 4 | 34 | 8 | 27–51 |  |
| S9.T03 | Thương điếm + quan hệ + đổi phe | 24 | 4 |  |  | 6 | 34 | 8 | 27–51 |  |
| S9.T04 | Lính đánh thuê + thợ đúc + Tiền âm | 10 |  |  |  |  | 10 | 3 | 8–15 |  |
| S9.T05 | Lưỡng đầu chế | 8 |  |  |  | 2 | 10 | 3 | 8–15 |  |

### Sprint 10 — AI & thiết lập đấu tự do

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S10.T01 | AI chiến lược (6 tài nguyên, chợ, giai đoạn, ngoại giao) | 40 |  |  |  | 6 | 46 | 13 | 37–69 | Rủi ro cao: tinh chỉnh lâu |
| S10.T02 | AI chiến thuật (Đội, công Lũy) | 32 |  |  |  |  | 32 | 8 | 26–48 | Rủi ro cao |
| S10.T03 | Độ khó | 8 |  |  |  | 4 | 12 | 3 | 10–18 |  |
| S10.T04 | Soak 1–3 AI + nightly | 16 |  |  |  |  | 16 | 5 | 13–24 |  |
| S10.T05 | 3 điều kiện thắng + màn thiết lập | 18 | 6 |  |  | 4 | 28 | 8 | 22–42 |  |
| M2 | Kiểm thử milestone M2 |  |  |  | 16 | 6 | 22 | 5 | 18–33 |  |

### Sprint 11 — Pipeline đồ họa

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S11.T01 | Style guide thế kỷ 17 |  | 20 |  |  | 6 | 26 | 8 | 21–39 |  |
| S11.T02 | Script render Blender (đất + thuyền) | 22 | 16 |  |  |  | 38 | 8 | 30–57 |  |
| S11.T03 | Import & atlas | 12 | 4 |  |  |  | 16 | 5 | 13–24 |  |
| S11.T04 | Unit renderer + cờ Đội | 22 |  |  |  |  | 22 | 5 | 18–33 |  |

### Sprint 12 — Đủ quân, công trình & âm thanh

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S12.T01 | Đơn vị chung (model + sprite + dữ liệu) | 8 | 110 |  |  | 4 | 122 | 34 | 98–183 | Khối lượng đồ họa — xem mục 4 |
| S12.T02 | Đơn vị đặc trưng + NPC + vòng cân bằng | 12 | 80 |  |  | 10 | 102 | 34 | 82–153 | Như trên |
| S12.T03 | Công trình 2 phe (21 loại) |  | 150 |  |  |  | 150 | 34 | 120–225 | Như trên |
| S12.T04 | Âm thanh | 8 |  | 70 |  |  | 78 | 21 | 62–117 | Mua hoặc thuê |

### Sprint 13 — Thủy quân, bến phà, dịch bệnh

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S13.T01 | Thủy chiến | 32 | 10 |  |  |  | 42 | 13 | 34–63 | Rủi ro cao |
| S13.T02 | Bến phà & cầu phá được | 24 | 6 |  |  |  | 30 | 8 | 24–45 |  |
| S13.T03 | AI thủy & qua sông | 18 |  |  |  |  | 18 | 5 | 14–27 |  |
| S13.T04 | Dịch bệnh (tùy chọn) | 6 |  |  |  | 2 | 8 | 2 | 6–12 |  |

### Sprint 14 — Trigger, chế độ chơi, tiến trình

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S14.T01 | Trigger dạng dữ liệu | 28 |  |  |  | 4 | 32 | 8 | 26–48 |  |
| S14.T02 | Hội thoại & cutscene | 14 | 6 |  |  |  | 20 | 5 | 16–30 |  |
| S14.T03 | Editor plugin | 24 |  |  |  | 4 | 28 | 8 | 22–42 |  |
| S14.T04 | Chế độ Trận lịch sử | 10 |  |  |  | 2 | 12 | 3 | 10–18 |  |
| S14.T05 | Menu chiến dịch + tiến trình | 16 | 10 |  |  |  | 26 | 8 | 21–39 |  |

### Sprint 15 — Chiến dịch I

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S15.T01 | NV1 Vào Thuận Hóa (hướng dẫn) | 8 |  |  | 6 | 30 | 44 | 13 | 35–66 | Thiết kế màn |
| S15.T02 | NV2 Trận 1627 (2 phe) | 6 |  |  | 8 | 30 | 44 | 13 | 35–66 |  |
| S15.T03 | NV3 Lũy Thầy 1630 | 6 |  |  | 6 | 24 | 36 | 8 | 29–54 |  |
| S15.T04 | Nhân vật chỉ huy chiến dịch | 12 | 24 |  |  | 4 | 40 | 8 | 32–60 |  |

### Sprint 16 — Chiến dịch II

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S16.T01 | NV4 Sông Gianh 1643 | 8 |  |  | 6 | 26 | 40 | 8 | 32–60 |  |
| S16.T02 | NV5 Trường Dục 1648 (đêm) | 10 |  |  | 6 | 24 | 40 | 8 | 32–60 |  |
| S16.T03 | NV6 Nghệ An 1655–56 | 4 |  |  | 6 | 22 | 32 | 8 | 26–48 |  |
| S16.T04 | NV7 Trận cuối 1672 | 4 |  |  | 6 | 22 | 32 | 8 | 26–48 |  |

### Sprint 17 — Nội dung lịch sử & thẩm định

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S17.T01 | Bách khoa lịch sử | 8 |  |  |  | 24 | 32 | 8 | 26–48 |  |
| S17.T02 | Người hiểu sử duyệt |  |  |  |  | 20 | 20 | 5 | 16–30 | Cần chuyên gia ngoài (không tính giờ) |
| S17.T03 | 5 Trận lịch sử | 4 |  |  | 6 | 30 | 40 | 8 | 32–60 |  |
| M3 | Kiểm thử milestone M3 |  |  |  | 16 | 6 | 22 | 5 | 18–33 |  |

### Sprint 18 — Hiệu năng 800 quân

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S18.T01 | Profiling + phân hạng máy + chốt trần | 16 |  |  | 10 |  | 26 | 8 | 21–39 |  |
| S18.T02 | Port C++ GDExtension | 48 |  |  |  |  | 48 | 13 | 38–72 | Rủi ro cao |
| S18.T03 | MultiMesh + LOD cờ Đội | 30 |  |  |  |  | 30 | 8 | 24–45 |  |
| S18.T04 | Bộ nhớ, tải, nhiệt, pin | 16 |  |  | 6 |  | 22 | 5 | 18–33 |  |

### Sprint 19 — UX, lưu game, đa ngôn ngữ

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S19.T01 | Lưu/tải (chợ, quan hệ, phà, Đội) | 32 |  |  |  |  | 32 | 8 | 26–48 | Rủi ro: tất định |
| S19.T02 | Cài đặt (1 ngón, tay trái, cỡ UI) | 14 | 4 |  |  |  | 18 | 5 | 14–27 |  |
| S19.T03 | Hướng dẫn tương tác 10 bước | 14 |  |  |  | 8 | 22 | 5 | 18–33 |  |
| S19.T04 | Đa ngôn ngữ vi/en | 12 |  |  |  | 20 | 32 | 8 | 26–48 |  |

### Sprint 20 — Android & release

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S20.T01 | Hành vi Android + safe area | 10 |  |  | 6 |  | 16 | 5 | 13–24 |  |
| S20.T02 | Sentry + Data safety | 10 |  |  |  | 4 | 14 | 3 | 11–21 |  |
| S20.T03 | Billing / Play Games (tùy chọn) | 20 |  |  |  |  | 20 | 5 | 16–30 | Bỏ nếu ADR-009 chọn trả phí |
| S20.T04 | AAB release | 12 |  |  |  |  | 12 | 3 | 10–18 |  |
| M4 | Kiểm thử milestone M4 |  |  |  | 16 |  | 16 | 5 | 13–24 |  |

### Sprint 21 — Closed beta

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S21.T01 | Kênh Closed testing | 2 |  |  |  | 6 | 8 | 2 | 6–12 |  |
| S21.T02 | Feedback, sửa lỗi, cân bằng | 90 |  |  | 20 | 10 | 120 | 34 | 96–180 | Ngân sách sửa lỗi |
| S21.T03 | Pre-launch report | 6 |  |  | 6 |  | 12 | 3 | 10–18 |  |

### Sprint 22 — Phát hành

| ID | Task | DEV | ART | AUD | QA | DES | Tổng giờ | SP | Khoảng (giờ) | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| S22.T01 | Trang store + trailer |  | 16 |  |  | 12 | 28 | 8 | 22–42 |  |
| S22.T02 | Checklist & rollout | 6 |  |  | 6 | 4 | 16 | 5 | 13–24 |  |
| S22.T03 | Theo dõi sau ra mắt | 16 |  |  |  | 4 | 20 | 5 | 16–30 |  |

## 3. Tổng theo sprint & mức tải

Tỉ lệ % = giờ ước lượng / năng lực của vai trò. **⚠ = vượt 100%** (cần điều chỉnh, xem mục 4).

| Sprint | DEV | ART | AUD | QA | DES | SP | Cảnh báo |
|---|---|---|---|---|---|---|---|
| S0 | 68 (57%) | 18 (45%) | – | 6 (30%) | 10 (33%) | 26 |  |
| S1 | 90 (75%) | 2 (5%) | – | 2 (10%) | 4 (13%) | 26 |  |
| S2 | 120 (100%) | 18 (45%) | – | 2 (10%) | 6 (20%) | 34 |  |
| S3 | 90 (75%) | 6 (15%) | 4 (40%) | 4 (20%) | – | 25 |  |
| S4 | 108 (90%) | 14 (35%) | – | 12 (60%) | 14 (47%) | 37 |  |
| S5 | 68 (57%) | 16 (40%) | 4 (40%) | – | 6 (20%) | 21 |  |
| S6 | 94 (78%) | 4 (10%) | – | – | 8 (27%) | 26 |  |
| S7 | 50 (42%) | – | – | – | – | 14 |  |
| S8 | 84 (70%) | 16 (40%) | – | – | 14 (47%) | 29 |  |
| S9 | 80 (67%) | 14 (35%) | – | – | 16 (53%) | 27 |  |
| S10 | 114 (95%) | 6 (15%) | – | 16 (80%) | 20 (67%) | 42 |  |
| S11 | 56 (47%) | 40 (100%) | – | – | 6 (20%) | 26 |  |
| S12 | 28 (23%) | 340 (850%) ⚠ | 70 (700%) ⚠ | – | 14 (47%) | 123 | ART 850%, AUD 700% |
| S13 | 80 (67%) | 16 (40%) | – | – | 2 (7%) | 28 |  |
| S14 | 92 (77%) | 16 (40%) | – | – | 10 (33%) | 32 |  |
| S15 | 32 (27%) | 24 (60%) | – | 20 (100%) | 88 (293%) ⚠ | 42 | DES 293% |
| S16 | 26 (22%) | – | – | 24 (120%) ⚠ | 94 (313%) ⚠ | 32 | QA 120%, DES 313% |
| S17 | 12 (10%) | – | – | 22 (110%) ⚠ | 80 (267%) ⚠ | 26 | QA 110%, DES 267% |
| S18 | 110 (92%) | – | – | 16 (80%) | – | 34 |  |
| S19 | 72 (60%) | 4 (10%) | – | – | 28 (93%) | 26 |  |
| S20 | 52 (43%) | – | – | 22 (110%) ⚠ | 4 (13%) | 21 | QA 110% |
| S21 | 98 (82%) | – | – | 26 (130%) ⚠ | 16 (53%) | 39 | QA 130% |
| S22 | 22 (18%) | 16 (40%) | – | 6 (30%) | 20 (67%) | 18 |  |
| **Tổng** | **1646** | **570** | **78** | **178** | **460** | **754** | |

**Tổng toàn dự án:** 2932 giờ (khoảng 2346–4398 giờ).
Riêng DEV: 1646 giờ ≈ 13.7 sprint ở năng lực 120 giờ/sprint; nếu chỉ có 1 dev thì ≈ 27.4 sprint.

## 4. Chỗ quá tải & đề xuất điều chỉnh

| Vai trò | Sprint vượt | Giờ vượt | Năng lực còn trống có thể dồn sang | Còn thiếu | Đề xuất |
|---|---|---|---|---|---|
| **ART** | S12 (850%) | 300 giờ | S5–S10 còn trống ≈ 184 giờ | ≈ 116 giờ | (1) Mở **luồng đồ họa song song từ S5**: dựng model quân và công trình trước, ngay khi có style guide nháp. (2) Phần thiếu: tăng ART lên toàn thời gian ở S11–S12 (+80 giờ) **và** thuê ngoài khoảng 3 model công trình (≈ 36 giờ) |
| **AUD** | S12 (700%) | 60 giờ | S0–S11 còn trống ≈ 112 giờ | 0 | Bắt đầu âm thanh từ S6 theo luồng song song; vẫn nên mua gói SFX thương mại để đảm bảo chất lượng |
| **DES** | S15 (293%), S16 (313%), S17 (267%) | 172 giờ | S11–S14 còn trống ≈ 88 giờ | ≈ 84 giờ | (1) Viết **brief 7 nhiệm vụ + 5 trận lịch sử** trong S11–S14. (2) Phần thiếu ≈ 84 giờ giao cho **DEV dựng trigger**: DEV ở S15–S17 chỉ dùng 10–27% năng lực, còn dư ≈ 290 giờ |
| **QA** | S16, S17, S20, S21 | 14 giờ | — | 14 giờ | Thuê tester theo giờ cho các tuần playtest |
| **DEV** | — nhưng **S2 = 100%**, S10 = 95%, S18 = 92% | 0 | Trung bình chỉ dùng ≈ 60% năng lực | — | Ba sprint này không còn đệm cho task "Rủi ro cao". Phương án dự phòng: chuyển S2.T06 (minimap, 8 giờ) sang S3; chuyển S10.T04 (soak, 16 giờ) sang S11; chuyển S18.T04 sang S19 |

**So với kế hoạch trước** (2 phe, 4 tài nguyên):
- Tổng tăng **+19%** (2456 → 2932 giờ). DEV tăng +22% (1346 → 1646 giờ).
- Phần tăng đến từ:
  - kinh tế 6 tài nguyên và giá tăng dần;
  - chợ, cảng, thương điếm, chính trị (S9 mới, ≈ 126 giờ);
  - Lũy đứng lên được;
  - bến phà và cầu;
  - trần quân 800;
  - chế độ Trận lịch sử.

**Tổng kết:**
- Với 2 DEV, phần lập trình vẫn vừa sức, nhưng **S2, S10, S18 không còn đệm**.
- Điểm nghẽn là **đồ họa (S12)** và **thiết kế màn (S15–S17)**.
- Giữ được mốc phát hành **24/09/2027** nếu chốt trước S5 ba việc:
  - (a) luồng đồ họa song song, kèm tăng ART toàn thời gian ở S11–S12 hoặc thuê ngoài;
  - (b) mua hoặc đặt làm âm thanh từ S6;
  - (c) DEV nhận phần dựng trigger nhiệm vụ ở S15–S17.

## 5. Cách dùng khi lập sprint

1. Planning: lấy các task của sprint, cộng giờ theo vai trò và so với năng lực thực tế của đội (trừ ngày nghỉ).
2. Task "Rủi ro cao": lập kế hoạch theo mức cao của khoảng dao động.
3. Cuối sprint ghi **giờ thực tế** vào cột bổ sung trên Issue. Sau 3 sprint, tính hệ số `thực tế / ước lượng` cho từng vai trò rồi nhân hệ số đó cho các sprint còn lại.
