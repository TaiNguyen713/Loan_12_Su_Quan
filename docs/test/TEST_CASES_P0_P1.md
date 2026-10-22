# Test case — Phase 0 & Phase 1 (S0 – S4)

Loại: **U** unit · **I** integration · **SC** scene/UI · **T** tool Python · **P** hiệu năng · **D** thiết bị thật · **M** thủ công · **CI** pipeline.
Quy ước: [TEST_STRATEGY.md](TEST_STRATEGY.md). Kích thước UI tính bằng pt theo khung **844×390**.

---

## Sprint 0

### S0.T01 — Duyệt GDD v2
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S0.T01-TC1 | M | GDD v2, doc Nam Bắc | Đối chiếu từng mục, ghi vào bảng chênh lệch | Mọi chênh lệch có quyết định; không chênh lệch nào về thiết kế mà chưa được xử lý |
| S0.T01-TC2 | M | Canvas wireframe | So bố cục HUD trong GDD §12 với 2 artboard | Kích thước khớp: thanh trên 36, cột nhóm 52, minimap 120, nút 48/64 |
| S0.T01-TC3 | M | MoSCoW | PO ký duyệt | Phạm vi 1.0 đóng băng |

### S0.T02 — ADR
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S0.T02-TC1 | M | 2 ADR | Kiểm tra theo mẫu MADR | Đủ mục, so sánh ≥ 2 phương án |
| S0.T02-TC2 | M | ADR-002 | Đối chiếu kết quả spike S0.T06 | Quyết định khớp số liệu |

### S0.T03 — Repo
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S0.T03-TC1 | CI | `.gitattributes` | Commit 1 file `.png`, chạy `git lfs ls-files` | File nằm trong LFS |
| S0.T03-TC2 | CI | Hook commit-msg | Commit với message "abc" | Bị từ chối |
| S0.T03-TC3 | CI | `.gitignore` | Mở editor, chạy `git status` | Không thấy `.godot/` |

### S0.T04 — CI
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S0.T04-TC1 | CI | PR có lỗi `gdlint` | Push | Job lint thất bại |
| S0.T04-TC2 | CI | Có 1 test fail | Push | Job test thất bại, có JUnit |
| S0.T04-TC3 | CI | Code sạch | Push lên `main` | Có APK debug, cài được lên máy |
| S0.T04-TC4 | CI | `GODOT_VERSION` khác `config/features` | Chạy CI | Job version-guard thất bại |

### S0.T05 — Framework test & tương thích
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S0.T05-TC1 | U | GdUnit4 6.2.2 trên Godot 4.7.2 | Chạy test mẫu headless | Pass, exit 0 (đóng rủi ro R1) |
| S0.T05-TC2 | D | LimboAI 1.8.1 | Export APK có `BTPlayer`, chạy trên máy | Không crash (đóng rủi ro R3) |
| S0.T05-TC3 | CI | gdtoolkit 4.5.0 | Lint file mẫu có typed loop và lambda nhiều dòng | Không báo lỗi cú pháp sai (rủi ro R2) |

### S0.T06 — Spike 800 quân
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S0.T06-TC1 | P | Máy tầm trung | 800 quân giao chiến 5 phút | Có số liệu; ngưỡng go: p50 ≥ 25 FPS |
| S0.T06-TC2 | P | Máy yếu | 400 quân giao chiến 5 phút | Ngưỡng go: p50 ≥ 25 FPS |
| S0.T06-TC3 | D | Như TC1 | Đo nhiệt sau 15 phút | Thermal status < 3 |
| S0.T06-TC4 | D | — | Đo độ trễ từ lúc chạm tới lúc có phản hồi | ≤ 100 ms |

### S0.T07 — Phong cách đồ họa
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S0.T07-TC1 | M | Sprite mẫu, khung 844×390 | Zoom 1.0 | Lính cao ≥ 8 pt, nhận ra được phe |
| S0.T07-TC2 | M | 8 hướng | Cho quân đi vòng tròn | Không giật, không lệch tâm |

---

## Sprint 1

### S1.T01 — Khởi tạo project
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S1.T01-TC1 | SC | Project mới | `godot --headless --quit-after 120` với scene trận rỗng | Exit 0, log sạch |
| S1.T01-TC2 | D | APK debug | Mở trên máy | Màn hình ngang, renderer GL Compatibility |
| S1.T01-TC3 | CI | Lint lớp | Thêm `queue_redraw()` vào một file trong `scripts/sim` | Lint báo lỗi đúng file và dòng |

### S1.T02 — EventBus & SceneRouter
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S1.T02-TC1 | U | EventBus | Phát `alert_raised` | Listener nhận đúng 1 lần, đúng tham số |
| S1.T02-TC2 | SC | SceneRouter | Menu → trận → menu, lặp 10 lần | Số node trở về giá trị ban đầu (±5) |
| S1.T02-TC3 | SC | Scene nặng | Chuyển scene | Có loading, không đứng hình > 200 ms |

### S1.T03 — Custom Resource
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S1.T03-TC1 | U | Mọi `.tres` | Nạp | Thành công, mảng `cost` có đủ 6 phần tử |
| S1.T03-TC2 | U | ALGO §5 | So các chỉ số trong `.tres` với bảng | Khớp 100% |
| S1.T03-TC3 | U | `FactionDef` Trịnh | Hỏi danh sách quân | Có Lính súng Đàng Ngoài, không có Lính súng hỏa mai và Cơ súng |
| S1.T03-TC4 | U | `BuildingDef` Nhà | Đọc `growth` | 1.05 |

### S1.T04 — Tool CSV & validator
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S1.T04-TC1 | T | CSV hợp lệ | Chạy tool | Sinh `.tres`, Godot nạp được |
| S1.T04-TC2 | T | Voi chiến `era = 1` nhưng Chuồng voi (luyện ra nó) `era = 2` | Chạy validator | Báo lỗi luật 5: đơn vị mở khóa trước công trình luyện ra nó |
| S1.T04-TC3 | T | Đại bác thiếu `ammo` | Chạy validator | Báo lỗi luật 4 |
| S1.T04-TC4 | T | Chạy tool 2 lần | So output | Giống hệt nhau |

### S1.T05 — Tick cố định
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S1.T05-TC1 | I | Quân đi 10 ô | Chạy ở 30 và 120 FPS | Tới đích cùng số tick |
| S1.T05-TC2 | SC | Render | Ghi vị trí hiển thị mỗi frame | Không có bước nhảy lớn bất thường |

### S1.T06 — RNG, CommandQueue, hash
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S1.T06-TC1 | I | Seed 42, 200 lệnh, có giao dịch chợ | Chạy 2 lần × 6000 tick | Hash bằng nhau |
| S1.T06-TC2 | I | Seed 42 rồi seed 43 | Chạy | Hash khác nhau |
| S1.T06-TC3 | U | Hash | Đổi giá chợ 1 tài nguyên rồi tính hash | Hash đổi (giá chợ có trong hash) |
| S1.T06-TC4 | U | CommandQueue | Đẩy lệnh ở tick 10; lấy lệnh đến hạn ở tick 10 rồi tick 11 | Tick 10 không có lệnh nào; tick 11 có đúng 1 lệnh |
| S1.T06-TC5 | U | CommandQueue | Áp dụng 1 lệnh rồi dựng lại từ `history` | Lệnh dựng lại giống lệnh gốc (loại, đơn vị, đích, tick) |

---

## Sprint 2

### S2.T01 — Địa hình
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S2.T01-TC1 | U | Map fixture | Hỏi `walk_land` / `walk_water` cho ô cầu | true / true |
| S2.T01-TC2 | U | Ô biển sâu | Hỏi `walk_water` với thuyền nhỏ và với `large_ship` | Chỉ thuyền lớn đi được ở biển sâu (theo đánh dấu map) |
| S2.T01-TC3 | U | Đổi tọa độ | world → cell → world cho 1000 điểm | Sai số < nửa ô |

### S2.T02 — Sinh bản đồ
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S2.T02-TC1 | U | Seed 7 | Sinh 2 lần | Giống hệt nhau |
| S2.T02-TC2 | I | 100 seed | BFS đường bộ từ Phủ A tới Phủ B | Luôn có đường, đi qua cầu |
| S2.T02-TC3 | I | 100 seed | Đếm mỏ đá/sắt/diêm và đất trống quanh mỗi bên | Chênh lệch ≤ 10% |
| S2.T02-TC4 | I | Bản đồ "Ven biển" | BFS đường thủy từ bờ biển mỗi bên ra biển sâu | Có đường |

### S2.T03 — A* + flow field
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S2.T03-TC1 | U | Sông có 1 cầu | Tìm đường từ bờ Bắc sang bờ Nam | Đi qua cầu |
| S2.T03-TC2 | U | Thuyền | Tìm đường tới một ô đất | Trả về ô nước gần nhất |
| S2.T03-TC3 | U | Đích bị bao kín | Tìm đường | Đường một phần, phát `no_path` |
| S2.T03-TC4 | P | 800 quân, 6 đích | Đo thời gian | < 6 ms/tick trên máy tầm trung |
| S2.T03-TC5 | I | Cầu bị phá khi quân đang đi | Chạy | Quân repath trong ≤ 1 giây |

### S2.T04 — Né tránh
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S2.T04-TC1 | I | 200 quân qua cầu rộng 2 ô | Lệnh sang bờ kia | 100% qua được trong ≤ 120 giây, không quân nào kẹt |
| S2.T04-TC2 | I | 50 quân sinh cùng 1 điểm | Chạy 60 tick | Không chồng nhau quá 10% |
| S2.T04-TC3 | P | 800 quân | Đo thời gian avoidance | < 3 ms/tick |

### S2.T05 — Camera
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S2.T05-TC1 | SC | — | Kéo **2 ngón** 100 pt | Camera dịch 100 / zoom |
| S2.T05-TC2 | SC | `one_finger_pan` tắt | Kéo **1 ngón** không giữ | Camera đứng yên |
| S2.T05-TC3 | SC | — | Chụm 2 ngón từ 100 lên 200 pt | Zoom ×2 (bị kẹp trong giới hạn), tâm đứng yên |
| S2.T05-TC4 | D | Máy có tai thỏ | Mở trận | Không control nào nằm trong vùng 44 pt trái/phải |

### S2.T06 — Minimap
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S2.T06-TC1 | SC | — | Đo kích thước và vị trí minimap | 120×120 pt, góc dưới trái |
| S2.T06-TC2 | SC | — | Chạm giữa minimap | Camera tới giữa bản đồ |
| S2.T06-TC3 | SC | — | Kéo trên minimap | Bản đồ chính không cuộn theo |

---

## Sprint 3

### S3.T01 — Cử chỉ
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S3.T01-TC1 | U | — | Chạm 80 ms, dịch 3 pt | Phát `tap` |
| S3.T01-TC2 | U | — | 2 tap cách 250 ms | Phát `double_tap` |
| S3.T01-TC3 | U | — | Giữ 320 ms rồi kéo 40 pt | Phát `box_start` rồi `box_update` |
| S3.T01-TC4 | U | — | Giữ 200 ms rồi kéo 40 pt | Không có khung chọn, không có tap |
| S3.T01-TC5 | U | Bật "Chọn vùng" | Kéo ngay | Có khung chọn, không cần giữ |
| S3.T01-TC6 | U | — | 2 ngón chạm rồi tách | Phát `pinch`, không phát tap |
| S3.T01-TC7 | U | — | Chạm bắt đầu trên HUD | Bản đồ không nhận cử chỉ |

### S3.T02 — Chọn quân
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S3.T02-TC1 | SC | 10 lính + 5 dân | Khung chọn bao hết | Chỉ chọn 10 lính |
| S3.T02-TC2 | SC | 5 ô nhóm | Giữ ô 2 trong 500 ms để gán 4 voi | Ô ghi "2 Voi" |
| S3.T02-TC3 | SC | Có 3 dân rảnh | Chạm "Rảnh 3" 3 lần | Lần lượt chọn 3 dân khác nhau, camera nhảy theo |
| S3.T02-TC4 | SC | 0 dân rảnh | Nhìn ô Rảnh | Không có nền cam, hiện "Rảnh 0" |

### S3.T03 — Lệnh
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S3.T03-TC1 | I | Có quân được chọn | Giữ "Thêm điểm", chạm 3 điểm, nhả | Quân đi qua 3 điểm theo thứ tự |
| S3.T03-TC2 | I | Doanh trại | Đặt điểm tập kết lên bản đồ | Quân mới ra đi tới điểm đó |
| S3.T03-TC3 | I | Phủ, tập kết lên mỏ đá | Luyện dân | Dân vào mỏ (`WorkInside`) |
| S3.T03-TC4 | I | Dân được chọn | Chạm ruộng | Dân thành dân cày |

### S3.T04 — FSM
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S3.T04-TC1 | U | Dân, mỏ còn chỗ | Ra lệnh khai thác | Trạng thái `WorkInside`, dân bị ẩn |
| S3.T04-TC2 | U | Mọi trạng thái | Nhận lệnh Stop | Về Idle |
| S3.T04-TC3 | U | Gather, đầy 10 | Tick | Chuyển sang Return |

### S3.T05 — Phản hồi & thẻ cảnh báo
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S3.T05-TC1 | SC | — | Phát 3 cảnh báo khác loại cùng lúc | Hiện tối đa 2 thẻ, thẻ ưu tiên cao nhất đứng đầu |
| S3.T05-TC2 | SC | Có thẻ `capture_warning` | Chạm thẻ | Camera nhảy tới vị trí, vùng đó được chọn |
| S3.T05-TC3 | SC | — | Phát `het_lua` 2 lần cách nhau 5 giây | Chỉ hiện 1 lần (giới hạn 15 giây) |
| S3.T05-TC4 | SC | Thẻ | Đo kích thước và vị trí | 220×36 pt, ngay dưới thanh trên |

---

## Sprint 4

### S4.T01 — Khai thác
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S4.T01-TC1 | I | 1 dân cày, ruộng cách Kho lúa 5 ô | Chạy 120 giây | Lúa khớp công thức ±2% |
| S4.T01-TC2 | I | Mỏ sắt có 5 dân | Chạy 60 giây | Sắt +50 (10 × 5) |
| S4.T01-TC3 | I | Mỏ đầy 5/5 | Giao thêm dân thứ 6 | Dân đi tới mỏ cùng loại gần nhất; không có thì Idle kèm cảnh báo |
| S4.T01-TC4 | I | 40 dân | Chờ 60 giây | Tiền +20 (thuế đinh) |
| S4.T01-TC5 | I | Ruộng | Khai thác 30 phút | Ruộng không cạn |

### S4.T02 — Đặt & xây, giá tăng dần
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S4.T02-TC1 | U | Đã có 2 Doanh trại (g = 1.35) | Hỏi giá Doanh trại thứ 3 | `round(200 × 1.35²) = 365` Gỗ, `round(100 × 1.82) = 182` Đá |
| S4.T02-TC2 | SC | Lưới Xây | Mở lưới | Có 4 tab, lưới 4 cột, ô cao 72 pt, có nút × 44 pt |
| S4.T02-TC3 | SC | Đang ở GĐ I | Xem ô Chuồng voi | Ô mờ, ghi "Giai đoạn II" |
| S4.T02-TC4 | U | — | Đặt Mỏ lên ô cỏ | Bị từ chối (phải đặt trên mỏ) |
| S4.T02-TC5 | U | — | Đặt Cảng xa nước | Bị từ chối |
| S4.T02-TC6 | U | Đã có Phủ chúa | Đặt Phủ chúa thứ 2 | Bị từ chối (`max_count`) |

### S4.T03 — Tuyển dân, hàng đợi, dân số
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S4.T03-TC1 | SC | Phủ chúa | Chạm nút Dân 3 lần | Hàng đợi = 3 |
| S4.T03-TC2 | SC | — | Giữ nút 500 ms | Mở bảng −1 / +5 / Vô hạn |
| S4.T03-TC3 | I | Bật vô hạn, Lúa chỉ đủ cho 4 dân | Chạy | Ra 4 dân rồi dừng chờ; không trừ tiền trước |
| S4.T03-TC4 | I | 1v1 với `cap_match = 800` | Luyện tới trần | Mỗi bên dừng ở 400, có cảnh báo "Đạt trần quân" |
| S4.T03-TC5 | U | Nguyễn có 3 Nhà | Tính `pop_cap` | 30 + 3 × 12 = 66 |

### S4.T04 — HUD
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S4.T04-TC1 | SC | Khung 844×390 | Đo thanh trên | Cao 36 pt, nằm trong vùng an toàn 44 pt, đủ 6 tài nguyên |
| S4.T04-TC2 | SC | — | Chạm nhóm tài nguyên | Mở bảng chi tiết: số người làm, thu, chi, ròng mỗi phút |
| S4.T04-TC3 | SC | Không chọn gì | Nhìn bảng lệnh | Bảng ẩn |
| S4.T04-TC4 | SC | Chọn 1 Đội | Đo bảng lệnh | Hiện, cao ≤ 96 pt, nút 48×48 |
| S4.T04-TC5 | SC | Tiền = −10 | Nhìn thanh trên | Số Tiền hiện màu đỏ |

### S4.T05 — Upkeep, đạn dược, Tiền âm
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S4.T05-TC1 | U | 50 bộ binh | Chạy 60 giây | Lúa −10 |
| S4.T05-TC2 | I | 10 lính súng, Sắt = 0.5, Diêm dư | Cho bắn | Bắn được 5 phát (mỗi phát 0.1 Sắt), sau đó dừng, hiện "hết đạn" |
| S4.T05-TC3 | I | Lúa = 0 trong 30 giây | Chạy | Mỗi lính −12% máu (không dưới 10%), sĩ khí −30, cảnh báo `het_lua` |
| S4.T05-TC4 | U | Upkeep Tiền làm Tiền âm | Chạy | Tiền được âm (không thấp hơn −2000), cảnh báo `tien_am` |

### S4.T06 — Lãnh thổ & khẩn hoang
| ID | Loại | Tiền điều kiện | Bước | Kết quả mong đợi |
|---|---|---|---|---|
| S4.T06-TC1 | U | Phủ tại (64, 13) | Hỏi chủ của ô cách 19 ô / 21 ô | Thuộc phe / đất trống |
| S4.T06-TC2 | U | Nguyễn | Giá Làng trên đất trống, đây là Làng đầu tiên | `150 × 0.7 = 105` Gỗ, 70 Đá |
| S4.T06-TC3 | U | Nguyễn | Làng có 1 ô nằm trong lãnh thổ | Không được giảm giá |
| S4.T06-TC4 | U | Trịnh | Làng trên đất trống | Không được giảm giá |

### Milestone M1
| ID | Loại | Bước | Kết quả mong đợi |
|---|---|---|---|
| M1-TC1 | D | Chơi 20 phút trên máy tầm trung, 400 quân | Không crash, p50 ≥ 30 FPS |
| M1-TC2 | M | 3 người mới chơi thử | Tự lập Làng, giao ruộng và mỏ, xây Nhà, luyện quân trong ≤ 7 phút |
