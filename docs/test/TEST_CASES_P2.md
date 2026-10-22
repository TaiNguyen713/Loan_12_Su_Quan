# Test case — Phase 2 (S5 – S10)

Loại: **U** unit · **I** integration · **SC** scene/UI · **T** tool · **P** hiệu năng · **D** thiết bị thật · **M** thủ công · **AI** tự chơi headless.

---

## Sprint 5 — Chiến đấu

### S5.T01 — Sát thương
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S5.T01-TC1 | U | Công 10, giáp 3 | Tính | 7 |
| S5.T01-TC2 | U | Công 2, giáp 10 | Tính | 1 |
| S5.T01-TC3 | U | Lính giáo đánh voi | Tính | `max(1, 8 × 2.5 − 5) = 15` |
| S5.T01-TC4 | U | Lính súng bắn Doanh trại | Tính | 0 (công trình quân sự) |
| S5.T01-TC5 | U | Lính súng bắn Nhà | Tính | `26 − 1 = 25` (công trình dân sự) |
| S5.T01-TC6 | U | Đại bác bắn Lũy | Tính | `90 × 3 − 6 = 264` |
| S5.T01-TC7 | U | Seed cố định, lính súng accuracy 0.75, 1000 phát | Đếm số phát trúng | 750 ± 30 |
| S5.T01-TC8 | I | Lính súng nạp 4 s | Bắn liên tục 20 giây | 5 phát |

### S5.T02 — Đạn, lan, pool, đạn dược
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S5.T02-TC1 | I | Trận 400 vs 400 | So số node trước và sau 60 giây | Không tăng quá kích thước pool |
| S5.T02-TC2 | U | Lan 48 px, 3 địch + 1 quân ta trong vùng | Nổ | Quân ta không mất máu |
| S5.T02-TC3 | I | Đại bác, Diêm = 1 | Lệnh bắn | Không bắn (cần 2 Diêm), hiện "hết đạn" |
| S5.T02-TC4 | I | Mỗi phát pháo | Đếm tài nguyên trước và sau | Sắt −1, Diêm −2 |

### S5.T03 — Chọn mục tiêu
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S5.T03-TC1 | U | Trong tầm có dân và đại bác địch | Chọn mục tiêu | Đại bác (W = 5) |
| S5.T03-TC2 | U | Lính giáo đứng cạnh Doanh trại địch | Idle | Không chọn Doanh trại |
| S5.T03-TC3 | I | Đang bật Cấm bắn | Địch vào tầm | Không tự đánh |
| S5.T03-TC4 | I | Quân tự phát hiện địch, địch chạy xa 1.5 × sight | Chạy | Quân bỏ đuổi |

### S5.T04 — Chết & xác
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S5.T04-TC1 | I | Quân chết | Theo dõi EventBus | `unit_died` đúng 1 lần |
| S5.T04-TC2 | I | 500 xác | Đếm số xác đang tồn tại | ≤ 400 |
| S5.T04-TC3 | I | Lính trong một Đội chết | Kiểm tra Đội | Slot trống, quân số Đội giảm 1 |

### S5.T05 — Tool cân bằng
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S5.T05-TC1 | T | 2 quân có số liệu tay | Chạy tool | TTK khớp kết quả tính tay |
| S5.T05-TC2 | T | Toàn bộ roster | Chạy tool | Có `ammo.csv` với cột "chi phí đạn/phút" |
| S5.T05-TC3 | T | Lính súng đánh Doanh trại | Chạy tool | DPS = 0, không bị gắn cảnh báo |

---

## Sprint 6 — Đội, đội hình, sĩ khí, 8 lệnh

### S6.T01 — Ba hình & giữ hàng
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S6.T01-TC1 | U | 30 lính, hình Ngang | Tính slot | 3 hàng × 10 cột |
| S6.T01-TC2 | I | Đội đang Move gặp địch | Chạy | Cả Đội dừng và quay mặt về địch; không lính nào rời slot quá 1.5 × sp |
| S6.T01-TC3 | I | Đội 50 lính qua cầu rộng 2 ô | Chạy | Co thành hàng dọc; qua xong lập lại hình trong ≤ 5 giây |
| S6.T01-TC4 | U | Gán slot | Tổng quãng đường | ≤ 1.2 × lời giải tối ưu |

### S6.T02 — Lập Đội một nút
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S6.T02-TC1 | SC | Chọn 29 lính giáo | Nhìn nút "Lập Đội 30" | Nút tắt |
| S6.T02-TC2 | I | Chọn 30 lính giáo, đủ tài nguyên | Nhấn | Có Đội 30 kèm cai đội và lính trống; trừ 160 L, 50 T, 20 G |
| S6.T02-TC3 | I | Thiếu Tiền | Nhấn | Từ chối, toast "Thiếu tài nguyên", không tạo Đội |
| S6.T02-TC4 | U | Đội cận chiến / Đội lính bắn | Đọc chỉ số | +2 công +3 giáp / +2 công +3 giáp |
| S6.T02-TC5 | I | Đội thiếu 5 lính, ra lệnh Bổ sung | Chạy | Lính mới đứng vào slot phía sau; lính cũ không đổi slot |
| S6.T02-TC6 | U | Mọi hình | Kiểm tra vị trí cai đội và lính trống | Luôn ở hàng thứ 2, giữa |

### S6.T03 — Sĩ khí
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S6.T03-TC1 | U | 100, Đội mất 30% quân | Cập nhật | 82 |
| S6.T03-TC2 | U | Lệnh Nghỉ, không có địch | 10 giây | +40 (2/s × 2) |
| S6.T03-TC3 | I | Sĩ khí về 0 | Chạy | Rout 8 giây, sau đó tập hợp lại khi ≥ 40 |
| S6.T03-TC4 | U | Trịnh có Danh nghĩa, không có địch | 10 giây | +22 |

### S6.T04 — 8 lệnh & bắn loạt
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S6.T04-TC1 | SC | Chọn 1 Đội | Nhìn thanh lệnh | 6 nút (Giữ, Nghỉ, Đi và đánh, Cấm bắn, Bổ sung, Canh) + 3 nút hình, khớp artboard 1 |
| S6.T04-TC2 | I | Canh ở C | Địch vào 250 px rồi chết | Đội đánh rồi quay về C |
| S6.T04-TC3 | I | Giữ vị trí | Địch ngoài tầm | Không di chuyển |
| S6.T04-TC4 | I | Đội 30 lính súng ở trạng thái Hold, đủ đạn | Địch vào tầm | ≥ 80% số lính bắn trong cùng 1 tick |
| S6.T04-TC5 | I | Bắn loạt nhưng chỉ đủ đạn cho 10 người | Bắn | Đúng 10 phát, tài nguyên trừ đúng 10 lần |
| S6.T04-TC6 | I | Thêm điểm × 9 | Chạm 9 điểm | Chỉ nhận 8 điểm |

---

## Sprint 7 — Sương mù

| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S7.T01-TC1 | U | Ô mới | Đọc trạng thái | Chưa khám phá |
| S7.T01-TC2 | U | Quân đi qua rồi rời đi | Đọc trạng thái | Đã khám phá |
| S7.T02-TC1 | SC | Địch trong fog | Chạm vào vị trí đó | Không chọn được |
| S7.T02-TC2 | I | AI Khó | Kiểm tra các truy vấn của AI | Chỉ thấy quân trong tầm nhìn |
| S7.T02-TC3 | U | Thuyền địch trong fog trên biển | Kiểm tra | Bị ẩn |
| S7.T03-TC1 | SC | Minimap | So với lưới fog | Khớp |
| S7.T04-TC1 | P | 800 quân di chuyển | Đo thời gian fog | < 1.5 ms/tick |
| S7.T04-TC2 | U | Dirty-rect | So với `full_recompute()` | Giống nhau |

---

## Sprint 8 — Lũy, nghiên cứu, giai đoạn, chiếm đoạt

### S8.T01 — Lũy, tường, cổng, đồn
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S8.T01-TC1 | SC | Nguyễn, GĐ II | Kéo một đường chéo 20 ô trong lãnh thổ | 20 đoạn liền nhau, không có lỗ chéo |
| S8.T01-TC2 | U | Đường lũy kéo ra ngoài lãnh thổ | Đặt | Chỉ đặt phần nằm trong lãnh thổ |
| S8.T01-TC3 | I | Lính giáo Nguyễn | Lệnh đi lên ô Lũy | Đứng được; giáp +3, tầm ×1.15 |
| S8.T01-TC4 | I | Kỵ binh Nguyễn | Lệnh đi lên Lũy | Không đi lên được, tìm đường vòng |
| S8.T01-TC5 | I | Quân Trịnh | Đi tới Lũy | Bị chặn |
| S8.T01-TC6 | U | Lính súng Trịnh bắn Lũy | Tính sát thương | 0 |
| S8.T01-TC7 | I | Đại bác phá 1 đoạn Lũy | Chạy | Ô mở ra, quân Trịnh đi qua chỗ vỡ |
| S8.T01-TC8 | I | Dân Nguyễn trong 10 ô quanh Đồn, có địch đứng cạnh | Chạy 5 giây | Không bị chiếm |

### S8.T02 — 40 nghiên cứu
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S8.T02-TC1 | U | Bảng `ResearchDef` | Đếm | Đúng 40 mục, validator pass |
| S8.T02-TC2 | U | R15 xong | Đọc chỉ số | Quân đang có và quân luyện sau đều có giáp +1 |
| S8.T02-TC3 | U | Chưa xong R24 | Mở R25 | Bị khóa |
| S8.T02-TC4 | U | Trịnh nghiên cứu R01 | Đọc thời gian | 69 s (60 × 1.15) |
| S8.T02-TC5 | U | Nguyễn | Kiểm tra R39 | Không thấy (R39 là của Trịnh) |
| S8.T02-TC6 | I | Công trình bị phá giữa lúc nghiên cứu | Chạy | Hủy, hoàn 50% |

### S8.T03 — Chuyển giai đoạn
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S8.T03-TC1 | U | Chưa có Làng ngoài Phủ | Mở R14 | Bị khóa, ghi "Cần Làng" |
| S8.T03-TC2 | I | R14 xong | Mở lưới Xây | Chuồng voi, Xưởng đúc, Lũy… không còn mờ; phát `era_changed` |
| S8.T03-TC3 | I | Đấu tự do, chọn GĐ khởi đầu II | Bắt đầu trận | `era = 2`, tài nguyên ×1.5 |

### S8.T04 — Chiếm đoạt & sửa chữa
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S8.T04-TC1 | I | Dân không có quân bảo vệ, có kỵ địch đứng cạnh | Chạy | Thẻ cảnh báo hiện ở 0.5 s; dân bị chiếm ở 2.0 s |
| S8.T04-TC2 | I | Như TC1, quân ta tới trong 1.5 s | Chạy | Không bị chiếm, bộ đếm về 0 |
| S8.T04-TC3 | I | Chợ không có quân bảo vệ | Chạy 5 s | Đổi phe |
| S8.T04-TC4 | U | Doanh trại không có quân bảo vệ | Chạy 10 s | Không đổi phe (công trình quân sự) |
| S8.T04-TC5 | SC | Trịnh có dân gốc Nguyễn | Mở lưới Xây | Có tab "Phe Nguyễn" với Làng (khẩn hoang), không có Lũy hay Tào Ty |
| S8.T04-TC6 | I | Nhà còn 50% máu | Sửa | Tốn 25% giá gốc |

---

## Sprint 9 — Chợ, cảng, thương điếm, chính trị

### S9.T01 — Chợ
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S9.T01-TC1 | U | Giá Sắt = 2.0 | Mua 100 | Trả 220 Tiền; giá mới 2.06 |
| S9.T01-TC2 | U | Giá Lúa = 1.0 | Bán 100 | Nhận 90 Tiền; giá mới 0.97 |
| S9.T01-TC3 | I | 2 người chơi | A mua 500 Sắt | Giá B thấy cũng tăng (dùng chung) |
| S9.T01-TC4 | U | Giá 3.0, gốc 2.0 | Chạy 10 s | 2.98 |
| S9.T01-TC5 | U | Mua liên tục | Giá vượt 4 × gốc | Bị kẹp ở 8.0 |

### S9.T02 — Cảng & thuế
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S9.T02-TC1 | I | Nguyễn, 1 Cảng, không có Tào Ty | Chạy 10 phút | Khoảng 10 thuyền, thuế khoảng 400 T (±1 thuyền) |
| S9.T02-TC2 | I | Trịnh, 1 Cảng | Chạy 10 phút | Khoảng 6 thuyền, mỗi thuyền chờ thêm 20 s, thuế khoảng 420 T |
| S9.T02-TC3 | U | Nguyễn có Tào Ty | Thuế mỗi thuyền | 50 T |
| S9.T02-TC4 | I | Thuyền chiến Trịnh đánh chìm thuyền buôn đang tới Cảng Nguyễn | Chạy | Không ai nhận thuế; Nguyễn có cảnh báo |
| S9.T02-TC5 | I | Thuyền buôn của người chơi, khoảng cách 300 ô | 1 chuyến khứ hồi | +150 T (bị kẹp) |

### S9.T03 — Thương điếm & quan hệ
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S9.T03-TC1 | U | Khởi đầu | Đọc quan hệ | VOC: Trịnh 45, Nguyễn 20; BĐN: Nguyễn 45, Trịnh 15 |
| S9.T03-TC2 | I | Nguyễn tiêu 1500 T ở Thương điếm VOC | Chạy | rel(VOC, Nguyễn) = 50 |
| S9.T03-TC3 | I | rel(VOC): Nguyễn 56, Trịnh 45 | Kiểm tra | VOC đổi sang Nguyễn (vượt ≥ 10); tàu VOC của Trịnh rời đi sau 30 s |
| S9.T03-TC4 | I | Trịnh mất 1600 value, Nguyễn mất 500 trong 120 s | Chạy | Mọi power: rel[Trịnh] −20, rel[Nguyễn] +10 |
| S9.T03-TC5 | SC | rel = 39 | Mở Thương điếm | Nút mua vũ khí bị khóa, ghi "Cần quan hệ 40" |
| S9.T03-TC6 | I | rel = 70 | Thuê tàu VOC lần thứ 3 | Bị từ chối (tối đa 2) |

### S9.T04 — Lính đánh thuê
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S9.T04-TC1 | I | 2 tàu thuê, Tiền = −10 | Chạy | Tàu đứng yên, không bắn |
| S9.T04-TC2 | I | Như TC1 | Chạy 20 s | 2 tàu lần lượt rời đi ở giây 10 và 20 |
| S9.T04-TC3 | I | Thợ đúc BĐN | Luyện đại bác | Thời gian 35 / 1.25 = 28 s; công 99 |

### S9.T05 — Lưỡng đầu chế
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S9.T05-TC1 | U | Trịnh còn Triều vua | Mua Sắt ở Thương điếm | Giá −15% |
| S9.T05-TC2 | I | Nguyễn chiếm Triều vua | Chạy | Trịnh mất Danh nghĩa, có cảnh báo; Nguyễn không được bonus |
| S9.T05-TC3 | I | Trịnh chiếm lại | Chạy | Có lại Danh nghĩa |

---

## Sprint 10 — AI & Đấu tự do

### S10.T01 — AI chiến lược
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S10.T01-TC1 | AI | AI chơi một mình 25 phút | Chạy | Đạt trần quân, sang GĐ II trước phút 15, không có dân rảnh quá 30 s |
| S10.T01-TC2 | U | Sắt ròng −80/phút | Chấm điểm "luyện lính súng" | Bị chặn |
| S10.T01-TC3 | AI | 20 trận | Đếm giao dịch chợ | ≥ 1 giao dịch mỗi trận |

### S10.T02 — AI chiến thuật
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S10.T02-TC1 | AI | 30 trận | Đếm | AI lập ≥ 2 Đội và dùng ≥ 2 hình |
| S10.T02-TC2 | I | AI Trịnh gặp Lũy | Chạy | Đưa đại bác lên, phá ≥ 1 đoạn, rồi tiến qua chỗ vỡ |
| S10.T02-TC3 | I | Sĩ khí Đội AI < 30 | Chạy | Rút về |

### S10.T03 — Độ khó
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S10.T03-TC1 | AI | 50 trận Khó vs Dễ | Thống kê | Khó thắng ≥ 80% |
| S10.T03-TC2 | AI | 50 trận Thường vs Dễ | Thống kê | Thường thắng 60–80% |
| S10.T03-TC3 | M | 5 người mới gặp AI Dễ | Chơi | ≥ 4 người thắng |

### S10.T04 — Soak
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S10.T04-TC1 | CI | Nightly | 50 trận 1v1 + 10 trận 1v3 | CSV đủ cột, 0 crash |
| S10.T04-TC2 | AI | Seed gây crash | Chạy lại | Tái hiện được |

### S10.T05 — Điều kiện thắng & thiết lập
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S10.T05-TC1 | I | Tiêu diệt: địch còn 1 Làng | Phá Làng, quân địch còn 3 lính | Chưa thắng; giết nốt 3 lính thì thắng |
| S10.T05-TC2 | I | Chiếm thủ phủ | Giữ vùng 119 giây rồi có 1 lính địch vào vùng | Bộ đếm về 0, chưa thắng |
| S10.T05-TC3 | I | Chiếm thủ phủ | Giữ đủ 120 giây | Thắng |
| S10.T05-TC4 | U | Đình chiến: lãnh thổ 60/40, kinh tế 50/50, quân 30/70 | Tính điểm | A = 0.24 + 0.15 + 0.09 = 0.48, B = 0.52 → B thắng |
| S10.T05-TC5 | I | Hòa bình 5 phút | Ra lệnh tấn công công trình ở phút 3 | Bị chặn; quân không qua sông được |
| S10.T05-TC6 | SC | Màn thiết lập | Đổi từng tùy chọn | Mọi tùy chọn được lưu vào `ScenarioDef` và có hiệu lực trong trận |

### Milestone M2
| ID | Loại | Bước | Kết quả mong đợi |
|---|---|---|---|
| M2-TC1 | M | 5 người, mỗi người 2 trận Đấu tự do với AI Thường | Điểm "vui" trung bình ≥ 3.5/5; thu feedback về 6 tài nguyên và Đội |
| M2-TC2 | P | 800 quân trên máy tầm trung (chưa tối ưu) | p50 ≥ 25 FPS |
