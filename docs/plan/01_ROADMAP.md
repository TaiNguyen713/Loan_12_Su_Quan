# 01 — Lộ trình phát triển: Phase · Sprint · Task

> Game: **Nam Bắc Phân Tranh** (tên tạm) — RTS Android, lối chơi Cossacks 3, bối cảnh Trịnh – Nguyễn.
> Thiết kế: [../GAME_DESIGN.md](../GAME_DESIGN.md) (v2, theo doc Nam Bắc + wireframe 844×390) · Ước lượng: [04_ESTIMATES.md](04_ESTIMATES.md) · Phiên bản công cụ: [05_VERSIONS.md](05_VERSIONS.md) · Công nghệ: [02_TECH_STACK.md](02_TECH_STACK.md) · Cấu trúc thư mục: [03_SKELETON.md](03_SKELETON.md)
> Test case: [../test/](../test/TEST_STRATEGY.md)
> **Thuật toán & tham số:** [P0–P1](algorithms/ALGO_P0_P1.md) · [P2](algorithms/ALGO_P2.md) · [P3](algorithms/ALGO_P3.md) · [P4–P5](algorithms/ALGO_P4_P5.md). Khi có mâu thuẫn về số liệu, file thuật toán là chuẩn.

## 0. Giả định lập kế hoạch

- **Phạm vi bản 1.0:** Trịnh + Nguyễn, giai đoạn I–II (1558–1672), nhiệm vụ chiến dịch 1–7, Đấu tự do 1–3 AI, Trận lịch sử, trên Android và **bản desktop Windows/Linux cùng nội dung** (CI xuất cả hai, xem S0.T04). Ba phe phụ, giai đoạn III, nhiều người chơi và bản PC nằm ở **Phase 6 (sau phát hành)**.
- **Nhịp làm việc:**
  - Sprint dài **2 tuần**. Nhóm gồm 2 lập trình viên, 1 họa sĩ bán thời gian, 1 người lo âm thanh và QA bán thời gian, 1 người thiết kế game kiêm PO. Chi tiết năng lực ở [04_ESTIMATES](04_ESTIMATES.md).
  - Bắt đầu **Thứ Hai 26/10/2026**, nghỉ Tết 01–12/02/2027.
- **Mã task** `Sxx.Tyy` dùng chung cho Issue, tên nhánh (`feat/S03.T02-selection`) và mã test case (`S03.T02-TC1`).
- **Definition of Done chung:**
  - code đã được review;
  - CI xanh (lint, GdUnit4);
  - mọi test case của task đều pass;
  - tài liệu được cập nhật;
  - với task ảnh hưởng tới hiệu năng hoặc input: đã chạy trên ít nhất 1 máy Android thật.

## 1. Phase & Milestone

| Phase | Sprint | Thời gian | Mục tiêu | Milestone (tiêu chí thoát) |
|---|---|---|---|---|
| **P0 – Tiền sản xuất** | S0 | 26/10 – 06/11/2026 | Duyệt GDD v2, CI, spike 800 quân | **M0**: CI xanh, APK debug tự build, spike đạt go |
| **P1 – Nền tảng RTS** | S1–S4 | 09/11/2026 – 01/01/2027 | Kiến trúc, bản đồ có sông/cầu/bến phà, input 844×390, kinh tế lõi 6 tài nguyên | **M1 – Core loop** chạy trên máy thật |
| **P2 – Chiều sâu Cossacks** | S5–S10 | 04/01 – 09/04/2027 (nghỉ Tết) | Chiến đấu, Đội, sĩ khí, fog, Lũy, nghiên cứu, giai đoạn, chợ, cảng, chính trị, AI | **M2 – Đấu tự do alpha**: 1–3 AI, đủ 3 điều kiện thắng |
| **P3 – Nội dung & đồ họa** | S11–S17 | 12/04 – 16/07/2027 | Đồ họa, đủ quân 2 phe, thủy chiến, chế độ chơi, chiến dịch nhiệm vụ 1–7, thẩm định sử | **M3 – Đủ nội dung 1.0** |
| **P4 – Hoàn thiện mobile** | S18–S20 | 19/07 – 27/08/2027 | 800 quân trên máy tầm trung, lưu game, đa ngôn ngữ, bản release | **M4 – Bản beta** |
| **P5 – Beta & phát hành** | S21–S22 | 30/08 – 24/09/2027 | Closed beta, phát hành | **M5 – Ra mắt 1.0** |
| P6 – Sau phát hành | — | từ 10/2027 | Giai đoạn III, 3 phe phụ, nhiều người chơi, tối ưu riêng cho PC | — |

## 2. Lịch Sprint

| Sprint | Thời gian | Chủ đề |
|---|---|---|
| S0 | 26/10 – 06/11/2026 | Tiền sản xuất & CI |
| S1 | 09/11 – 20/11/2026 | Kiến trúc lõi & dữ liệu |
| S2 | 23/11 – 04/12/2026 | Bản đồ, sông/cầu/bến phà, tìm đường, camera |
| S3 | 07/12 – 18/12/2026 | Cử chỉ, chọn quân, lệnh, cảnh báo |
| S4 | 21/12/2026 – 01/01/2027 | Kinh tế lõi: 6 tài nguyên, giá tăng dần, upkeep |
| S5 | 04/01 – 15/01/2027 | Chiến đấu cốt lõi |
| S6 | 18/01 – 29/01/2027 | Đội, đội hình, sĩ khí, 8 lệnh |
| — | 01/02 – 12/02/2027 | **Nghỉ Tết** |
| S7 | 15/02 – 26/02/2027 | Sương mù chiến tranh |
| S8 | 01/03 – 12/03/2027 | Lũy, nghiên cứu, giai đoạn, chiếm đoạt |
| S9 | 15/03 – 26/03/2027 | Chợ, cảng, thương điếm, chính trị |
| S10 | 29/03 – 09/04/2027 | AI & thiết lập đấu tự do |
| S11 | 12/04 – 23/04/2027 | Pipeline đồ họa |
| S12 | 26/04 – 07/05/2027 | Đủ quân, công trình & âm thanh 2 phe |
| S13 | 10/05 – 21/05/2027 | Thủy quân, bến phà, dịch bệnh |
| S14 | 24/05 – 04/06/2027 | Trigger, chế độ chơi, tiến trình chiến dịch |
| S15 | 07/06 – 18/06/2027 | Chiến dịch I (nhiệm vụ 1–3) |
| S16 | 21/06 – 02/07/2027 | Chiến dịch II (nhiệm vụ 4–7) |
| S17 | 05/07 – 16/07/2027 | Nội dung lịch sử & thẩm định |
| S18 | 19/07 – 30/07/2027 | Hiệu năng 800 quân |
| S19 | 02/08 – 13/08/2027 | UX, lưu game, đa ngôn ngữ |
| S20 | 16/08 – 27/08/2027 | Tích hợp Android & release |
| S21 | 30/08 – 10/09/2027 | Closed beta |
| S22 | 13/09 – 24/09/2027 | Phát hành |

---

## PHASE 0 — Tiền sản xuất

### Sprint 0 — Tiền sản xuất & CI
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S0.T01 | Duyệt GDD v2 với doc Nam Bắc và wireframe; chốt phạm vi 1.0 | Markdown, canvas Design | GDD v2 được duyệt, phạm vi đóng băng | — |
| S0.T02 | ADR-001, ADR-002 (engine, renderer, hướng đồ họa) | MADR | 2 ADR | S0.T01 |
| S0.T03 | Chuẩn hóa repo: LFS, `.gitignore`, hook commit, template PR | Git, Git LFS, pre-commit | Repo trên GitHub | — |
| S0.T04 | CI: lint → test → export APK debug | GitHub Actions, gdtoolkit, gdUnit4-action, `godot-ci:4.7.2` | `ci.yml` xanh | S0.T03, S0.T05 |
| S0.T05 | Cài framework test, xác nhận tương thích phiên bản (05_VERSIONS R1–R3) | GdUnit4 6.2.2, LimboAI 1.8.1, pytest | Test mẫu chạy headless | — |
| S0.T06 | Spike **800 quân**: lưới, A*, flow field thô, chạm ra lệnh; đo trên máy thật | Godot 4.7.2, `AStarGrid2D`, Profiler, `adb`, AGI | `spike_report.md`, go/no-go cho trần 800/400 | S0.T05 |
| S0.T07 | Thử phong cách đồ họa: 1 quân + 1 công trình, render isometric | Blender `bpy`, Aseprite | Sprite mẫu hiển thị trên điện thoại ở khung 844×390 | S0.T02 |

---

## PHASE 1 — Nền tảng RTS

### Sprint 1 — Kiến trúc lõi & dữ liệu
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S1.T01 | Khởi tạo project Godot theo skeleton, lint kiểm tra phụ thuộc giữa các lớp | Godot 4.7.2, GDScript typed, script Python | Scene trận rỗng chạy trên PC và Android | S0 |
| S1.T02 | EventBus + SceneRouter | Signals, threaded loading | Chuyển màn không rò rỉ node | S1.T01 |
| S1.T03 | Custom Resource: `UnitDef`, `BuildingDef` (có `growth`, `era`), `FactionDef`, `ResearchDef`, `ScenarioDef` | `Resource`, `@export` | Bảng GDD v2 có dạng `.tres` | S1.T01 |
| S1.T04 | Tool CSV → tres + validator (6 tài nguyên, giai đoạn, tham chiếu) | Python 3.12, pandas, pytest | Chạy trong CI | S1.T03 |
| S1.T05 | Tick cố định 20 Hz, render nội suy | `physics_interpolation` | Sim không phụ thuộc FPS | S1.T01 |
| S1.T06 | RNG có seed, CommandQueue, state hash | RandomNumberGenerator, Command pattern | Cùng seed + cùng lệnh → cùng hash | S1.T05 |

### Sprint 2 — Bản đồ, sông/cầu/bến phà, tìm đường, camera
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S2.T01 | Địa hình isometric: cỏ, rừng, sông, **cầu**, **bến phà**, biển nông/sâu, mỏ | `TileMapLayer`, custom data layer | Map vẽ tay hiển thị và cản đường đúng | S1 |
| S2.T02 | Định dạng map + sinh thủ tục (sông Gianh, 2–3 cầu, 1–2 bến phà, bờ biển, đối xứng) | `FastNoiseLite`, RNG có seed | Cùng seed → cùng map, luôn có đường qua sông | S2.T01 |
| S2.T03 | A* + flow field, lớp đường bộ/đường thủy, cache | `AStarGrid2D`, flow field tự viết | 800 quân cùng đích < 6 ms/tick trên máy tầm trung | S2.T01 |
| S2.T04 | Né tránh cục bộ cho 800 quân, chống kẹt ở cầu | Spatial hash, separation | Không kẹt ở cầu rộng 2 ô | S2.T03 |
| S2.T05 | Camera: kéo 2 ngón, chụm zoom, quán tính, giới hạn biên, vùng an toàn 44 pt | `InputEventScreenDrag`, `DisplayServer` safe area | Mượt, không trôi | S1 |
| S2.T06 | Minimap 120×120 pt, chạm để nhảy camera | `ImageTexture`, `_gui_input` | Cập nhật 4 Hz | S2.T01 |

### Sprint 3 — Cử chỉ, chọn quân, lệnh, cảnh báo
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S3.T01 | Nhận diện cử chỉ: chạm, chạm đúp, **giữ 0.3 s rồi kéo = khung chọn**, kéo/chụm 2 ngón | FSM trên `InputEventScreenTouch/Drag` | `GestureRecognizer` | S2.T05 |
| S3.T02 | Chọn quân: chạm, khung chọn, nút "Chọn vùng", chạm đúp, **5 ô nhóm**, ô "Rảnh" | Spatial hash, HUD | Chọn đúng 100% trong scene test | S3.T01 |
| S3.T03 | Hệ thống lệnh: đi/đánh/khai thác/xây, **Thêm điểm** (nhiều điểm), **Điểm tập kết** | Command pattern, CommandQueue | Mọi lệnh đi qua queue | S1.T06 |
| S3.T04 | FSM của đơn vị | LimboAI HSM | ADR-006 | S3.T03 |
| S3.T05 | Phản hồi lệnh + **thẻ cảnh báo** (chạm để nhảy camera) | `Input.vibrate_handheld`, Control, EventBus | Mọi lệnh có phản hồi < 100 ms | S3.T03 |

### Sprint 4 — Kinh tế lõi → **M1**
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S4.T01 | Khai thác: ruộng 4 chỗ + Kho lúa; rừng cạn; **Mỏ** 5→10 chỗ làm bên trong (Đá/Sắt/Diêm); thuế đinh | `sim/economy` | Thu nhập khớp công thức ±2% | S3.T04 |
| S4.T02 | Đặt & xây công trình, **lưới Xây 4 tab**, **giá tăng dần `gốc × gⁿ`** | TileMap query, Control | Giá hiển thị đúng n | S2.T01 |
| S4.T03 | Phủ/Làng tuyển dân: chạm +1, giữ mở bảng (−1/+5/vô hạn); dân số và trần quân | `sim/economy/production` | Hàng đợi vô hạn dừng khi hết tài nguyên | S4.T02 |
| S4.T04 | Thanh trên 36 pt (6 tài nguyên, dân số, Rảnh) + bảng chi tiết thu/chi + bảng lệnh tự ẩn | Control, Theme | Khớp wireframe artboard 1 | S4.T03 |
| S4.T05 | Upkeep Lúa, **tiêu hao Sắt/Diêm mỗi phát**, Tiền âm | `sim/economy/upkeep` | Hết Sắt hoặc Diêm thì không bắn được | S4.T01 |
| S4.T06 | Lãnh thổ (bán kính quanh Phủ/Làng/Đồn) + **khẩn hoang** của Nguyễn | Lưới lãnh thổ theo phe | Làng trên đất trống −30% giá | S4.T02 |

---

## PHASE 2 — Chiều sâu Cossacks

### Sprint 5 — Chiến đấu
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S5.T01 | Mô hình sát thương + luật "công trình quân sự/Lũy chỉ bị pháo, voi, thuyền phá" | `sim/combat/damage` | Unit test cho mọi nhánh | S1.T03 |
| S5.T02 | Đạn, sát thương lan, object pool, **trừ đạn dược** | ObjectPool | Không cấp phát node mới trong trận | S5.T01, S4.T05 |
| S5.T03 | Chọn mục tiêu, giới hạn đuổi theo | Spatial hash | Không đuổi mãi | S5.T01 |
| S5.T04 | Chết, xác quân, hook hiệu ứng | Particles, EventBus | Xác dùng pool | S5.T02 |
| S5.T05 | Tool cân bằng DPS/TTK theo chi phí 6 tài nguyên | pandas, matplotlib | Báo cáo trong CI | S1.T04 |

### Sprint 6 — Đội, đội hình, sĩ khí, 8 lệnh
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S6.T01 | Ba hình Ngang/Dọc/Vuông, **giữ hàng khi gặp địch**, qua cầu thì co lại | Gán slot (Hungarian/tham lam), flow field | Qua cầu xong lập lại hình | S2.T03 |
| S6.T02 | **Lập Đội 30/50 bằng một nút** (tự thêm cai đội + lính trống), bonus Cossacks, bổ sung không phá hình | `sim/formations` | Đội lập trong 1 thao tác | S6.T01 |
| S6.T03 | Sĩ khí & tháo chạy | `sim/morale`, LimboAI | Tập hợp lại được | S6.T02 |
| S6.T04 | **8 lệnh Cossacks**: Giữ, Nghỉ, Đi và đánh, Cấm/Cho bắn, Bổ sung, Canh, Đổi hình, Nhiều điểm + bắn loạt | Commands | Thanh lệnh khớp wireframe | S6.T02, S3.T03 |

### Sprint 7 — Sương mù chiến tranh
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S7.T01 | Lưới fog + shader | `Image`, `.gdshader` | Biên mềm | S2.T01 |
| S7.T02 | Tầm nhìn, ẩn địch, bóng ma công trình | `sim/fog` | AI không nhìn xuyên fog | S7.T01 |
| S7.T03 | Fog trên minimap | — | Khớp fog chính | S7.T01 |
| S7.T04 | Tối ưu fog cho 800 quân | Dirty-rect | < 1.5 ms/tick | S7.T02 |

### Sprint 8 — Lũy, nghiên cứu, giai đoạn, chiếm đoạt
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S8.T01 | **Lũy Nguyễn** (quân bộ đứng lên được, +3 giáp +15% tầm, chỉ xây trong lãnh thổ), tường thường, cổng, Đồn (chống bắt dân) | Lưới theo phe, đường 4-liên-thông | Kéo 20 ô lũy trong 1 thao tác | S4.T06, S5.T01 |
| S8.T02 | Thư phòng + **40 nghiên cứu** + modifier stack (Trịnh nghiên cứu lâu hơn 15%) | `ResearchDef` | Đủ 40 mục | S1.T03 |
| S8.T03 | **Chuyển giai đoạn I → II**, mở khóa, chọn giai đoạn khởi đầu | Cờ `era` trên Def | Mục bị khóa hiện điều kiện mở | S8.T02 |
| S8.T04 | Chiếm đoạt (trễ 2 s + cảnh báo; xây được công trình phe khác) + sửa chữa | `sim/capture` | Cảnh báo hiện trước khi mất dân | S5.T03, S3.T05 |

### Sprint 9 — Chợ, cảng, thương điếm, chính trị
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S9.T01 | **Chợ**: giá dao động, dùng chung cho mọi người chơi | `sim/market` | Mua đẩy giá lên, bán kéo giá xuống | S4.T01 |
| S9.T02 | **Cảng** + thuyền buôn ngoại quốc (NPC) + thuế; Nguyễn tới dày, Trịnh thưa nhưng thuế cao; **Tào Ty** | `sim/trade`, pathing đường thủy | Thu nhập khớp công thức | S9.T01, S2.T03 |
| S9.T03 | **Thương điếm** + thanh quan hệ VOC/BĐN: mua vũ khí ≥ 40, thuê ≥ 70, trận lớn làm giảm, đổi phe | `sim/diplomacy` | Đổi phe đúng luật | S9.T01 |
| S9.T04 | Lính đánh thuê, thợ đúc BĐN, upkeep Tiền, bỏ đi khi Tiền âm | `sim/economy/upkeep` | Đào ngũ 1 người mỗi 10 s khi Tiền âm | S9.T03, S4.T05 |
| S9.T05 | **Lưỡng đầu chế**: Triều vua Lê, Danh nghĩa | `sim/politics` | Mất Danh nghĩa khi Triều vua bị chiếm hoặc phá | S8.T04 |

### Sprint 10 — AI & thiết lập đấu tự do → **M2**
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S10.T01 | AI chiến lược: 6 tài nguyên, giá tăng dần, chợ, giai đoạn, quan hệ phương Tây | Utility AI + LimboAI Blackboard | Tự phát triển tới trần quân | S4, S8, S9 |
| S10.T02 | AI chiến thuật: lập Đội, dùng 8 lệnh, rút lui, công Lũy bằng pháo | LimboAI BT | Dùng ≥ 2 hình đội | S6, S10.T01 |
| S10.T03 | Độ khó Dễ/Thường/Khó | `AIProfile.tres` | Tỉ lệ thắng tăng theo độ khó | S10.T02 |
| S10.T04 | AI soak headless, 1–3 AI | CLI `--headless`, CSV | 50 trận chạy nightly | S10.T03 |
| S10.T05 | **3 điều kiện thắng** + màn thiết lập Đấu tự do (đối thủ, địa hình, tài nguyên, giai đoạn, hòa bình, kích thước, vị trí, dịch bệnh) | `sim/victory`, Control | Mọi tùy chọn có hiệu lực | S10.T01 |

---

## PHASE 3 — Nội dung & đồ họa

### Sprint 11 — Pipeline đồ họa
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S11.T01 | Style guide thế kỷ 17 (trang phục, công trình, tàu thuyền) + bảng màu và hoa văn 2 phe | Moodboard Figma, tư liệu có nguồn | `docs/art/STYLE_GUIDE.md` | S0.T07 |
| S11.T02 | Script render Blender: 8 hướng × 4 hoạt ảnh (đất), 8 hướng × 2 hoạt ảnh (thuyền) | `bpy`, Pillow | 1 lệnh render cả danh sách | S11.T01 |
| S11.T03 | Import, atlas, nén ETC2/ASTC | Godot import, SpriteFrames | RAM texture < 150 MB | S11.T02 |
| S11.T04 | Unit renderer + mask tô màu phe | AnimatedSprite2D, shader | Màu phe tô bằng mask | S11.T03 |

### Sprint 12 — Đủ quân, công trình & âm thanh 2 phe
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S12.T01 | Đơn vị chung (9 loại + cai đội, lính trống) | Pipeline S11, `UnitDef` | Đủ sprite, icon, chỉ số | S11 |
| S12.T02 | Đơn vị đặc trưng: Cơ súng, Thổ binh, Ngư binh, Lính súng Đàng Ngoài, Thuyền chiến Đàng Ngoài, tàu VOC (NPC) | Như trên | Winrate Trịnh và Nguyễn trong 45–55% | S12.T01 |
| S12.T03 | Công trình 2 phe (21 loại × 4 trạng thái) | Blender/Krita | Đủ sprite | S11 |
| S12.T04 | Âm thanh: súng, pháo, trống, chiêng, voi, sóng biển, nhạc; audio bus | Godot Audio | Có giới hạn số voice | S5.T04 |

### Sprint 13 — Thủy quân, bến phà, dịch bệnh
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S13.T01 | Thủy chiến: thuyền chiến, ngư binh, tàu VOC, bắn vào bờ, chở quân/đổ bộ | Pathing đường thủy, `domain = WATER` | Thuyền chỉ đi trên nước | S2.T03, S12 |
| S13.T02 | **Bến phà** (qua sông theo lượt) và cầu (phá được bằng pháo) | `sim/pathing` + `sim/ferry` | Qua sông đúng sức chở | S13.T01 |
| S13.T03 | AI thủy quân và dùng bến phà | LimboAI BT | AI vượt sông được | S13.T02, S10 |
| S13.T04 | **Dịch bệnh** (tùy chọn khi tạo trận) | `sim/supply` | Bật/tắt có hiệu lực | S4.T06 |

### Sprint 14 — Trigger, chế độ chơi, tiến trình chiến dịch
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S14.T01 | Trigger dạng dữ liệu + mục tiêu nhiệm vụ | `TriggerDef`, interpreter | Viết nhiệm vụ không cần code | S1.T03 |
| S14.T02 | Hội thoại, briefing, cutscene nhẹ | Tween, RichTextLabel | Bỏ qua được, có đa ngôn ngữ | S14.T01 |
| S14.T03 | Editor plugin thiết kế màn | `EditorPlugin`, `@tool` | Designer tự làm được màn | S14.T01 |
| S14.T04 | Chế độ **Trận lịch sử** (quân có sẵn, không có kinh tế) | `ScenarioDef.mode = battle` | Vào trận < 10 s | S14.T01 |
| S14.T05 | Menu chiến dịch Trịnh/Nguyễn, mở khóa nhiệm vụ, lưu tiến trình | `user://` JSON, ghi file an toàn | Không mất tiến trình | S14.T01 |

### Sprint 15 — Chiến dịch I
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S15.T01 | NV1 Vào Thuận Hóa 1558 (Nguyễn, kiêm hướng dẫn chơi) | Trigger, map vẽ tay | Người mới hoàn thành < 15 phút | S14 |
| S15.T02 | NV2 Trận 1627 (chơi được bằng cả 2 phe) | Như trên | Lời giải mẫu thắng ở chế độ headless | S14 |
| S15.T03 | NV3 Lũy Thầy 1630 (xây tuyến lũy trước khi Trịnh tới) | Trigger + Lũy | Có đồng hồ đếm ngược | S8.T01 |
| S15.T04 | Nhân vật chỉ huy trong chiến dịch (đơn vị có tên + aura nhỏ) | `CommanderDef`, modifier | Chỉ xuất hiện trong chiến dịch | S8.T02 |

### Sprint 16 — Chiến dịch II
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S16.T01 | NV4 Sông Gianh 1643 (hải chiến, thuyền nhỏ đánh tàu VOC) | Trigger + thủy chiến | Thắng/thua đúng điều kiện | S13.T01 |
| S16.T02 | NV5 Trường Dục 1648 (giữ lũy, voi phản công đêm) | Trigger + ánh sáng đêm | Có pha phòng thủ → phản công | S15 |
| S16.T03 | NV6 Nghệ An 1655–1656 (Trịnh, với Trịnh Tạc và Trịnh Căn) | Trigger | Đẩy quân Nguyễn về bờ nam | S15.T04 |
| S16.T04 | NV7 Trận cuối 1672 (Trịnh, kết thúc bằng đình chiến) | Trigger + luật đình chiến | Kết thúc đúng sử | S10.T05 |

### Sprint 17 — Nội dung lịch sử & thẩm định → **M3**
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S17.T01 | Bách khoa lịch sử (mỗi mục có nguồn và độ chắc nguồn) | `.tres`, RichTextLabel | Không mục nào thiếu nguồn | S14.T05 |
| S17.T02 | **Người hiểu sử duyệt** tên, lời thoại, hình ảnh công trình, trang phục | Bảng rà soát CSV | Đóng hết các mục cần sửa | S15, S16 |
| S17.T03 | Nội dung Trận lịch sử (5 trận từ giai đoạn I–II) | `ScenarioDef` | Mỗi trận 10–15 phút | S14.T04 |

---

## PHASE 4 — Hoàn thiện mobile

### Sprint 18 — Hiệu năng 800 quân
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S18.T01 | Profiling trên ma trận thiết bị, **chốt trần quân theo cấu hình máy** | Godot Profiler, AGI, Perfetto | Bảng trần 800/400 đã kiểm chứng | M3 |
| S18.T02 | Port hot path sang C++ | GDExtension `godot-cpp` | Nhanh hơn ≥ 3 lần | S18.T01 |
| S18.T03 | MultiMesh + LOD | MultiMeshInstance2D, shader | ≤ 150 draw call với 800 quân | S18.T01 |
| S18.T04 | Bộ nhớ, thời gian tải, nhiệt, pin | Threaded load | Tải trận < 8 s | S18.T01 |

### Sprint 19 — UX, lưu game, đa ngôn ngữ
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S19.T01 | Lưu/tải giữa trận, schema có phiên bản | FileAccess, JSON zstd | Tải lại cho ra cùng hash | S1.T06 |
| S19.T02 | Cài đặt: cỡ UI, "kéo 1 ngón để cuộn", tay trái, mù màu, âm thanh, đồ họa | ConfigFile | Áp dụng ngay | — |
| S19.T03 | Hướng dẫn tương tác (bổ sung cho NV1) | Trigger + overlay | Hoàn thành < 10 phút | S15.T01 |
| S19.T04 | Đa ngôn ngữ vi/en, font Việt | TranslationServer, Be Vietnam Pro | Không còn chuỗi hard-code | — |

### Sprint 20 — Tích hợp Android & release → **M4**
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S20.T01 | Nút Back, ra nền, safe area 44 pt, xoay màn hình | `_notification`, DisplayServer | Đạt checklist | S19 |
| S20.T02 | Sentry + Data safety | Sentry Godot SDK 2.4.0 | Crash thử có stack trace | — |
| S20.T03 | (Tùy chọn) Play Games, Billing | Plugin chính thức | ADR-009 | — |
| S20.T04 | AAB release, ký số | Gradle build, CI secrets | `release.yml` | S0.T04 |

---

## PHASE 5 — Beta & phát hành

### Sprint 21 — Closed beta
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S21.T01 | Kênh Closed testing | Play Console | Tester cài được | S20.T04 |
| S21.T02 | Feedback, sửa lỗi, cân bằng 2 phe | Issues, tool S5.T05 | 0 blocker | S21.T01 |
| S21.T03 | Pre-launch report | Play pre-launch / Test Lab | 0 crash | S21.T01 |

### Sprint 22 — Phát hành → **M5**
| ID | Task | Framework / Kỹ thuật | Đầu ra (DoD) | Phụ thuộc |
|---|---|---|---|---|
| S22.T01 | Trang store, trailer, IARC | Play Console, DaVinci | Được duyệt | S21 |
| S22.T02 | Checklist, staged rollout | Play Console | Có tiêu chí rollback | S22.T01 |
| S22.T03 | Theo dõi sau ra mắt | Android vitals, Sentry | Crash-free ≥ 99.5% | S22.T02 |

---

## PHASE 6 — Sau phát hành (ước lượng lại sau M5)

| Hạng mục | Ghi chú |
|---|---|
| Giai đoạn III (1672–1777): Nam tiến, Phú Xuân, nhiệm vụ 8 (1774–75) | Bản đồ mở rộng phía nam; cần thêm nghiên cứu cấp III |
| Phe Mạc | **Tra cứu sử trước** khi đặt bản đồ và chỉ số |
| Hà Lan, Bồ Đào Nha chơi được | Phát triển từ NPC của bản 1.0 |
| Nhiều người chơi 2–4 (điện thoại), 8 (PC) | Lockstep tất định, cần chuyển sim sang fixed-point |
| Tối ưu riêng cho PC (bản desktop cơ bản đã có từ 1.0) | HUD 1920×1080, phím tắt Cossacks 3, trần 3000 quân |

## 3. Rủi ro chính

| Rủi ro | Mức | Giảm thiểu |
|---|---|---|
| Không đạt 800 quân trên máy tầm trung | Cao | Spike ở S0.T06; flow field ở S2.T03; trần quân theo cấu hình máy; C++ và MultiMesh ở S18 |
| Kinh tế 6 tài nguyên, chợ và chính trị quá nặng với người chơi điện thoại | Cao | Thanh trên chỉ hiện số trong kho, chạm mới xem chi tiết; NV1 dạy dần từng phần; playtest từ M1 |
| Cân bằng Trịnh đông quân và Nguyễn giỏi phòng thủ | Cao | Tool S5.T05, AI soak S10.T04, playtest sớm |
| Khối lượng đồ họa (21 công trình, 18 bộ sprite) | Cao | Pipeline render tự động, luồng đồ họa song song (04_ESTIMATES) |
| Sai sót và nhạy cảm lịch sử | Trung bình | S17.T02 có người hiểu sử duyệt; trình bày cân bằng |
| Plugin không theo kịp phiên bản Godot | Trung bình | [05_VERSIONS](05_VERSIONS.md) |
