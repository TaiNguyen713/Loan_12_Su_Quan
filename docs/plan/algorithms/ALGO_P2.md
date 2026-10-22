# Thuật toán & quy trình xử lý — Phase 2 (S5 – S10)

> Quy ước chung (tick, 6 tài nguyên `[L,G,Đ,T,S,D]`, pt 844×390, trần quân): xem mục 0 của [ALGO_P0_P1.md](ALGO_P0_P1.md).

---

## Sprint 5 — Chiến đấu

### S5.T01 — Mô hình sát thương
```
stat(x)  = (base_x + Σ add_x) × Π(1 + mult_x)                     # modifier stack (S8.T02)
bonus    = max(1, max{ def.bonus[tag] | tag ∈ target.tags })       # lấy hệ số lớn nhất, không nhân dồn
raw      = stat(attack) × bonus × formation_mult
damage   = max(1, raw − stat(target.armor))
LUẬT CÔNG TRÌNH QUÂN SỰ (Nam Bắc mục 7):
  if target.is_building and target.def.military and not attacker.def.can_damage_military: damage = 0
  (công trình dân sự thì mọi đơn vị đều gây được sát thương; can_damage_military = siege | elephant | ship)
```
Ví dụ kiểm tra:
- công 10, giáp 3 → 7;
- công 2, giáp 10 → 1;
- lính giáo đánh voi: `max(1, 8 × 2.5 − 5) = 15`;
- lính súng bắn Doanh trại → 0 (công trình quân sự);
- đại bác bắn Lũy: `90 × 3 − 6 = 264`.

**Tầm bắn và nạp đạn:**
- `gap = target.edge_distance(pos) − radius`. Bắn được khi `min_range ≤ gap ≤ range`.
- `cooldown_ticks = ceil(reload_s / DT)`. Phát đầu tiên bắn ngay khi mục tiêu vào tầm, nên trong 20 giây với nạp 4 giây sẽ có 5 phát.
- **Độ chính xác:** `rng("combat").randf() < accuracy` → trúng. Trượt thì đạn rơi lệch ±28 px. Cận chiến và pháo luôn trúng.

### S5.T02 — Đạn, sát thương lan, pool, đạn dược
- **ObjectPool:** tạo trước 128 đối tượng; hết thì mở rộng thêm một nửa và ghi cảnh báo.
- **Loại đạn:**

| Loại | Tốc độ (px/s) | Quỹ đạo |
|---|---|---|
| `ball` (súng) | 1200 | Bám theo mục tiêu |
| `arrow` | 650 | Bám theo mục tiêu |
| `shell` (pháo) | 480 | Cong, rơi vào điểm cố định ±14 px |
| `ship_shot` | 700 | Bay thẳng, rơi vào điểm cố định ±20 px |

- **Đạn dược:** **trước** mỗi phát, gọi `try_spend(ammo)` (S4.T05). Không đủ thì không bắn, `cooldown` giữ nguyên, quân hiện biểu tượng "hết đạn".
- **Sát thương lan:**
  - Duyệt `entities_in_radius` theo ID tăng dần, bỏ qua quân mình.
  - `falloff = 1 − clamp(d / (1.5 × splash), 0, 0.6)`.
  - Sát thương lên công trình vẫn áp dụng luật công trình quân sự ở S5.T01.

### S5.T03 — Chọn mục tiêu
Quét mỗi 0.4 giây; thời điểm quét lệch theo `id % 8` để mọi quân không quét cùng một tick.
```
score(t) = W[category] × 100 − dist/sight × 50 + (t đang đánh ta ? 30 : 0) + (1 − hp%) × 20
```
**Trọng số W:** đại bác 5 · cai đội 4.5 · lính súng/cơ súng 4 · kỵ 4 · voi 4 · thuyền chiến 4 · bộ binh 3 · lính trống 2 · dân 1 · công trình dân sự 0.5 · công trình quân sự/Lũy 0.3.

- Đơn vị không có `can_damage_military` **không chọn** công trình quân sự làm mục tiêu.
- **Giới hạn đuổi theo:** quân tự phát hiện địch thì bỏ khi đã đuổi quá `1.5 × sight` tính từ `acquire_pos`. Lệnh tấn công trực tiếp không bị giới hạn.
- Lệnh **Cấm bắn** (S6.T04) chặn mọi lần tự chọn mục tiêu.

### S5.T04 — Chết, xác quân, hiệu ứng
- `unit_died` được phát đúng 1 lần. Quân chết bị xóa khỏi selection, nhóm, Đội và spatial hash.
- Xác quân lấy từ pool: giữ nguyên 15 giây, mờ dần trong 5 giây.
- Tối đa **400** xác cùng lúc (giảm cho 800 quân); vượt thì giải phóng xác cũ nhất.
- Render và âm thanh tự lắng nghe EventBus; sim không gọi tới chúng.

### S5.T05 — Tool cân bằng DPS/TTK
```
value(u) = Σ cost[i] × RES_VALUE[i]        RES_VALUE = [1.0 L, 1.0 G, 1.2 Đ, 1.0 T, 2.0 S, 2.5 D]
dmg = luật S5.T01 (gồm công trình quân sự); TTK = (ceil(hp/dmg)/acc − 1) × reload
DPS = dmg × acc / reload;  cost_eff[a][b] = (DPS[a][b]/value(a)) / (DPS[b][a]/value(b))
đạn dược mỗi phút = ammo × 60 / reload → cột "chi phí đạn/phút" cho mỗi đơn vị
cảnh báo: cost_eff > 5 hoặc < 0.2 mà cặp đó không có trong balance/counters.csv
xuất: ttk.csv, dps.csv, ammo.csv, heatmap.png
```

---

## Sprint 6 — Đội, đội hình, sĩ khí, 8 lệnh

### S6.T01 — Ba hình & giữ hàng
**Sinh vị trí slot:** khoảng cách `sp = 20 px` (chặt hơn bản cũ vì Đội đông).

| Hình | Số cột |
|---|---|
| Ngang | `cols = ceil(n / 3)` (3 hàng) |
| Dọc | `cols = min(5, n)` |
| Vuông | `cols = ceil(sqrt(n))`, chỉ dùng chu vi; lõi dành cho cai đội và lính trống |

**Gán quân vào slot:** sắp theo `rank`. Dùng Hungarian khi n ≤ 50 (O(n³) ≈ 125k phép tính, chỉ chạy lúc lập hình); n lớn hơn thì dùng tham lam.

**Di chuyển:**
- Leader ảo đi theo flow field với tốc độ của quân chậm nhất.
- `slot_world = leader + rotate(offset, facing)`. Quân được tăng tốc tối đa ×1.3 để đuổi kịp slot.

**Giữ hàng khi gặp địch** (sửa lỗi của bản gốc):
- Đội ở trạng thái Move hoặc AttackMove gặp địch thì **toàn Đội dừng và quay mặt** về hướng địch; từng lính không tự chạy khỏi slot.
- Lính cận chiến chỉ được rời slot tối đa 1.5 × sp để đánh, sau đó quay về.
- Lính súng bắn từ chỗ đứng.

**Qua cầu hoặc chỗ hẹp:** đo bề rộng đi được `w` → `cols_tạm = max(1, floor(w/sp))` → co thành hàng dọc; qua khỏi thì khôi phục hình.

### S6.T02 — Lập Đội một nút
```
nút "Lập Đội 30" / "Lập Đội 50" bật khi: trong selection có ≥ N lính CÙNG loại (infantry hoặc ranged), cùng phe
on press(N):
    cost = cost(cai_doi) + cost(linh_trong); if !try_spend(cost): toast "Thiếu tài nguyên"; return
    members = N lính cùng loại gần tâm nhất; spawn cai đội + lính trống ngay sau hàng đầu
    Formation{id, type (đang chọn, mặc định Vuông với giáo, Ngang với súng), size N, officer, drummer, members}
bonus khi Đội còn cai đội:
    melee:  attack +2, armor +3        ranged: attack +2 ("hỏa lực"), armor +3
mất cai đội: mất bonus, toàn Đội −25 sĩ khí; Đội vẫn giữ hình nhưng không được bonus cho tới khi Bổ sung có cai đội mới
```
**Bổ sung không phá hình:** lính mới **đi tới slot trống phía sau** (theo thứ tự hàng sau rồi mới lên hàng trước). Các lính đang đứng trong slot không đổi vị trí.

**Cai đội và lính trống** luôn nằm ở slot "sau hàng đầu" (hàng 1, giữa). Khi đổi hình thì gán lại slot cho họ trước tiên.

### S6.T03 — Sĩ khí
Sĩ khí `m` ∈ [0, 100].

| Sự kiện | Δ |
|---|---|
| Đội mất quân | `−60 × (số chết / quân số ban đầu)` |
| Đồng đội ngoài Đội chết trong 300 px | −2 |
| Bị đánh từ phía sau (góc > 120°) | −1 mỗi đòn |
| Mất cai đội | −25 |
| Đói (mỗi 5 giây) | −5 |
| Trúng pháo | −3 |
| Trúng loạt đạn | −1 mỗi phát trúng |
| Không có địch trong tầm nhìn | +2/s |
| Trong 200 px quanh cai đội hoặc nhân vật chỉ huy | +4/s |
| Lệnh **Nghỉ** | Tốc độ hồi ×2 |
| Danh nghĩa của Trịnh (S9.T05) | Tốc độ hồi ×1.1 |

`m` về 0 thì quân chuyển sang trạng thái **Rout** trong 8 giây: chạy về Phủ hoặc Làng gần nhất. Sau đó tập hợp lại khi `m ≥ 40` và (có cai đội trong 200 px hoặc không có địch trong tầm nhìn).

### S6.T04 — 8 lệnh Cossacks (thanh lệnh 6 nút + 3 nút hình)
| Nút | Command | Hành vi |
|---|---|---|
| Giữ vị trí | `Hold` | Không di chuyển; bắn hoặc đánh mục tiêu đã trong tầm; Đội giữ hình |
| Nghỉ | `Rest` | Dừng mọi lệnh; không tự đánh (chỉ phản đòn khi bị đánh cận chiến); sĩ khí hồi ×2 |
| Đi và đánh | bật/tắt `AttackMoveMode` | Bật thì lệnh di chuyển kế tiếp thành AttackMove |
| Cấm bắn / Cho phép bắn | `FireToggle` | Cấm thì không tự chọn mục tiêu; lệnh tấn công trực tiếp vẫn thực hiện |
| Bổ sung | `Reinforce` | Lấy lính cùng loại đang rảnh trong 400 px lấp vào slot trống; thiếu thì xếp hàng luyện ở Doanh trại gần nhất, rally tới Đội |
| Canh | `Guard(center)` | Đứng tại chỗ; địch vào bán kính 300 px thì đánh, xong quay về center |
| Ngang / Dọc / Vuông | `SetShape` | Đổi hình tại chỗ, gán lại slot theo thứ tự rank |
| Thêm điểm | `Move(waypoints)` | Giữ nút rồi chạm lần lượt; tối đa 8 điểm |

**Bắn loạt:** Đội lính súng ở trạng thái Hold hoặc Guard tự bắn loạt. Thuật toán:
- chờ tới khi ≥ 80% thành viên đã nạp xong (tối đa 1.5 giây);
- tất cả bắn trong cùng một tick, mục tiêu phân bổ lần lượt (round-robin);
- **mỗi phát vẫn trừ đạn dược**; ai không đủ đạn thì không bắn.

---

## Sprint 7 — Sương mù chiến tranh

- **S7.T01:** mỗi phe có `vis_count[]` và `explored[]` kích thước W×H. Ảnh R8 với giá trị 255 / 110 / 0, shader làm mờ 3×3.
- **S7.T02:** disc tầm nhìn được tính trước cho bán kính 1..15 ô; chỉ cập nhật khi thực thể đổi ô. Có bóng ma cho công trình địch đã từng thấy. Mọi truy vấn chọn quân, chọn mục tiêu và AI đều phải qua `is_visible`. Thuyền thấy được trên nước như trên đất.
- **S7.T03:** minimap dùng chính texture fog. Chấm của địch chỉ vẽ khi đang nhìn thấy.
- **S7.T04:** cập nhật theo dirty-rect, `update()` texture tối đa 10 lần/giây. Mục tiêu < **1.5 ms/tick** với 800 quân. Có hàm `full_recompute()` chỉ dùng trong test để so khớp.

---

## Sprint 8 — Lũy, nghiên cứu, giai đoạn, chiếm đoạt

### S8.T01 — Lũy, tường, cổng, đồn
**Kéo để xây:** đường 4-liên-thông (supercover, không có lỗ chéo):
```
while (x, y) ≠ b: thêm ô; e2 = 2·err; if e2 > −dy: err −= dy; x += sx  elif e2 < dx: err += dx; y += sy
```
Lọc các ô hợp lệ: `buildable` **và** `owner[cell] == team` (lãnh thổ, S4.T06). Sau đó lấy phần đầu dãy vừa đủ tài nguyên.

**Lũy của Nguyễn:**
- Ô Lũy có `blocked_mask` theo phe:
  - phe chủ: bộ binh (tag `infantry`) **đi lên được**; kỵ, voi, pháo không đi lên được;
  - phe khác: bị chặn hoàn toàn.
- Cần lưới pathing riêng cho từng phe và từng loại quân: `LAND_INF_<team>` và `LAND_HEAVY`. Thêm 2 instance; flow field cache có khóa theo lưới.
- Quân đứng trên ô Lũy: `armor +3`, `range ×1.15`, nhận ít hơn 25% sát thương cận chiến.
- Nghiên cứu "Binh thư Đào Duy Từ" (R33): Lũy máu +25%.

**Tường thường của Trịnh:** chặn mọi đơn vị, không đứng lên được.

**Cổng:** ô cổng đi được cho mọi đơn vị của phe chủ, bị chặn với phe khác.

**Phá Lũy, tường, cổng:** chỉ đơn vị có `can_damage_military` (S5.T01). Khi một ô bị phá: mở ô, xóa cache flow field liên quan, quân đang đi thì repath.

**Đồn:** bắn như Phủ (S5.T03). Dân của phe chủ đứng trong `anti_capture_radius` (10 ô, R36 lên 14) **không thể bị chiếm**.

### S8.T02 — Thư phòng & 40 nghiên cứu
**Cơ chế:**
- `ResearchDef{id, building, era, cost[6], time_s, requires[], effects[{target, stat, op, value}]}`.
- Hoàn thành → đẩy effect vào `ModifierStack[team]`, tăng `version`.
- **Trịnh:** `time_s × 1.15`.
- Công trình nghiên cứu bị phá giữa chừng → hủy, hoàn 50%.

**Danh sách 40 mục** (khởi điểm, chỉnh sau playtest; giá ghi theo L/G/Đ/T/S/D):

| ID | Tên | Nơi | GĐ | Giá | Thời gian (s) | Hiệu lực | Cần |
|---|---|---|---|---|---|---|---|
| R01 | Nông cụ | Kho lúa | I | 300 L, 200 G | 60 | Lúa +15% | – |
| R02 | Thủy lợi | Kho lúa | II | 600 L, 300 G, 200 Đ | 90 | Lúa +15% | R01 |
| R03 | Rìu thép | Thư phòng | I | 200 G, 50 S | 50 | Gỗ +15% | – |
| R04 | Cưa xẻ | Thư phòng | II | 400 G, 100 S | 80 | Gỗ +15% | R03 |
| R05 | Khai đá | Mỏ | I | 300 G, 200 Đ | 60 | Đá +20% | – |
| R06 | Luyện sắt | Mỏ | I | 300 G, 200 Đ, 100 T | 70 | Sắt +20% | – |
| R07 | Nấu diêm | Mỏ | II | 300 G, 100 Đ, 150 T | 70 | Diêm +20% | – |
| R08 | Hầm sâu | Mỏ | II | 400 G, 300 Đ, 200 T | 90 | Mọi mỏ +15% | R05 |
| R09 | Đúc tiền niên hiệu | Thư phòng | I | 300 Đ, 300 T, 100 S | 80 | Thuế đinh +20% | – |
| R10 | Sổ đinh | Thư phòng | II | 500 Đ, 500 T | 100 | Thuế đinh +20% | R09 |
| R11 | Chợ phiên | Chợ | I | 300 G, 300 T | 60 | Phí chợ 10% → 6% | – |
| R12 | Kho đụn | Kho lúa | II | 500 L, 300 G | 80 | Upkeep Lúa −10% | R01 |
| R13 | Đường trạm | Thư phòng | I | 200 L, 200 G | 50 | Dân tốc độ +10% | – |
| R14 | **Sang giai đoạn II** | Thư phòng | I | 1200 L, 800 G, 800 Đ, 1000 T | 120 | S8.T03 | xem S8.T03 |
| R15 | Giáp mây | Doanh trại | I | 300 L, 200 T | 60 | Bộ binh giáp +1 | – |
| R16 | Giáp mây II | Doanh trại | II | 600 L, 400 T | 90 | Bộ binh giáp +1 | R15 |
| R17 | Giáo dài | Doanh trại | I | 300 L, 150 G, 100 T | 60 | Lính giáo công +2 | – |
| R18 | Đao rèn | Doanh trại | I | 300 L, 200 T, 50 S | 60 | Lính đao công +2 | – |
| R19 | Tập trận | Doanh trại | II | 400 L, 300 T | 80 | Luyện bộ binh −15% thời gian | – |
| R20 | Yên cương | Chuồng ngựa | I | 300 L, 200 T | 60 | Kỵ tốc độ +10% | – |
| R21 | Giáp ngựa | Chuồng ngựa | II | 500 L, 400 T, 100 S | 80 | Kỵ giáp +2 | R20 |
| R22 | Luyện voi | Chuồng voi | II | 600 L, 400 T | 90 | Voi máu +15% | – |
| R23 | Bành voi | Chuồng voi | II | 500 L, 300 G, 300 T | 90 | Voi giáp +2 | R22 |
| R24 | Tập bắn bia | Trường tập bắn | II | 300 L, 300 T, 50 S | 70 | Súng chính xác +0.05 | – |
| R25 | Nạp nhanh | Trường tập bắn | II | 400 T, 150 S, 150 D | 90 | Súng nạp ×0.85 | R24 |
| R26 | Thuốc súng tốt | Thư phòng | II | 500 T, 100 S, 300 D | 90 | Súng và pháo công +10% | – |
| R27 | Nòng đồng | Xưởng đúc | II | 600 T, 300 S | 100 | Pháo tầm +10% | – |
| R28 | Đúc pháo nhanh | Xưởng đúc | II | 500 G, 500 T, 200 S | 90 | Luyện pháo −20% thời gian | – |
| R29 | Đạn chùm | Xưởng đúc | II | 800 T, 300 S, 300 D | 120 | Pháo lan 48 → 64 px | R27 |
| R30 | Đóng thuyền nhanh | Cảng | I | 600 G, 300 T | 80 | Đóng thuyền −20% thời gian | – |
| R31 | Mũi pháo | Cảng | II | 400 G, 400 T, 200 S | 90 | Thuyền chiến công +15% | – |
| R32 | Buồm lớn | Cảng | I | 500 G, 200 T | 70 | Thuyền tốc độ +10% | – |
| R33 | Binh thư Đào Duy Từ (Nguyễn) | Thư phòng | II | 600 Đ, 500 T | 120 | Lũy máu +25% | – |
| R34 | Đắp thành | Thư phòng | II | 500 G, 500 Đ | 90 | Tường và cổng máu +20% | – |
| R35 | Đồn lũy | Thư phòng | I | 300 Đ, 300 T, 100 S | 80 | Đồn tầm +15%, công +2 | – |
| R36 | Canh phòng | Thư phòng | I | 300 G, 200 T | 60 | Bán kính chống bắt dân của Đồn 10 → 14 ô | – |
| R37 | Ngoại giao | Thư phòng | II | 400 T | 80 | Quan hệ tăng ×1.25 | – |
| R38 | Tào Ty mở rộng (Nguyễn) | Tào Ty | II | 300 G, 500 T | 90 | Thuế thuyền +15% | – |
| R39 | Tuần ty Phố Hiến (Trịnh) | Cảng | II | 300 Đ, 500 T | 90 | Thuế mỗi thuyền +15% | – |
| R40 | Quân lương | Thư phòng | II | 600 L, 300 T | 90 | Phạt đói mỗi 8 s (thay vì 5 s); lính đánh thuê bỏ đi chậm ×1.5 | – |

**Luật cộng phần trăm:** cộng các giá trị ADD trước, nhân các MULT sau. Nâng cấp từng loại lính ở công trình luyện ra nó, hỏa lực chung (R26) ở Thư phòng, đúng như Nam Bắc mục 5.

### S8.T03 — Chuyển giai đoạn I → II
- **Điều kiện nghiên cứu R14:** có Thư phòng, ≥ 1 Làng ngoài Phủ chúa, ≥ 1 Doanh trại, ≥ 1 Kho lúa. Giá và thời gian theo bảng (Trịnh +15% thời gian).
- **Khi hoàn thành:**
  ```
  team.era = 2 → phát era_changed
  mở khóa mọi BuildingDef, UnitDef, ResearchDef có era == 2 (theo faction)
  lưới Xây: ô mờ của GĐ II hiện bình thường; toast "Đã sang Giai đoạn II – Đại chiến"
  ```
- **Giai đoạn khởi đầu** (thiết lập đấu tự do): chọn II thì bắt đầu với `era = 2` và tài nguyên ×1.5.
- **UI ô bị khóa:** dòng điều kiện = danh sách các điều kiện còn thiếu (ví dụ "Giai đoạn II", "Cần Làng").

### S8.T04 — Chiếm đoạt & sửa chữa
**Kiểm tra mỗi 0.5 giây** cho thực thể `capturable` (dân, đại bác, công trình dân sự):
```
enemy_near = có quân chiến đấu của phe khác trong 80 px (công trình: trong 3 ô quanh footprint)
guard_near = có quân chiến đấu của phe chủ trong 120 px, hoặc thực thể nằm trong vùng chống bắt của Đồn phe chủ
if enemy_near and not guard_near:
    capture_t += 0.5
    if capture_t == 0.5: phát capture_warning → thẻ cảnh báo "… sắp bị bắt – chạm để tới" (S3.T05)
    ngưỡng: dân, đại bác = 2.0 s; công trình dân sự = 5.0 s
    capture_t ≥ ngưỡng → đổi team; phát entity_captured; dân giữ faction gốc (origin_faction)
else: capture_t = 0
```
- **Xây công trình của phe khác:** dân có `origin_faction ≠ team.faction` thì lưới Xây hiện thêm tab "Phe <origin>" với các công trình **không đặc trưng** của phe đó. Ví dụ dân Nguyễn bị Trịnh chiếm thì Trịnh xây được Làng giá Nguyễn (được khẩn hoang), nhưng không xây được Lũy hay Tào Ty.
- **Sửa chữa:** tốc độ `rate(n) × max_hp / build_s`; mỗi 1% máu hồi tốn 0.5% giá gốc. Tự phá công trình hoàn 30%.

---

## Sprint 9 — Chợ, cảng, thương điếm, chính trị

### S9.T01 — Chợ (giá dùng chung)
`Market` là singleton của trận, chung cho mọi người chơi.

| Tài nguyên | Giá gốc `base` (Tiền/đơn vị) |
|---|---|
| Lúa | 1.0 |
| Gỗ | 1.0 |
| Đá | 1.2 |
| Sắt | 2.0 |
| Diêm | 2.5 |
```
giao dịch theo lô 100 đơn vị:
  mua X:  trả 100 × p[X] × (1 + fee) Tiền; sau đó p[X] *= 1.03
  bán X:  nhận 100 × p[X] × (1 − fee) Tiền; sau đó p[X] *= 0.97
  fee = 0.10 (R11: 0.06)
mỗi 10 giây: p[X] += (base[X] − p[X]) × 0.02     # trôi dần về giá gốc
clamp p ∈ [0.25 × base, 4 × base]
đổi tài nguyên → tài nguyên: bán X rồi mua Y trong cùng một lệnh
```
Mỗi giao dịch phát `market_price_changed`. UI Chợ hiện giá mua và bán hiện tại, kèm mũi tên xu hướng 60 giây gần nhất.

### S9.T02 — Cảng, thuyền buôn, thuế
**Thuyền buôn ngoại quốc (NPC):**

| Tham số | Nguyễn | Trịnh |
|---|---|---|
| Chu kỳ ghé (mỗi Cảng) | 60 s | 90 s |
| Chờ cấp phép khi cập cảng | 0 s | **20 s** |
| Thuế mỗi thuyền | 40 T | 70 T |
| Tối đa cùng lúc mỗi Cảng | 2 | 2 |
| Bonus | Tào Ty ×1.25, R38 ×1.15 | R39 ×1.15 |

- **Đường đi:** sinh ở điểm biển ngoài khơi trên bản đồ → đi theo pathing WATER tới Cảng → cập cảng 15 giây (Trịnh thêm 20 giây chờ cấp phép) → **thu thuế khi rời đi** → quay ra biển.
- Thuyền buôn là NPC trung lập. Thuyền chiến của phe đối địch có thể đánh chìm (không ai được thuế). Phe chủ Cảng nhận cảnh báo.

**Thuyền buôn của người chơi:**
- Chạy giữa Cảng của mình và điểm thương thuyền ngoài khơi.
- Mỗi chuyến khứ hồi thu `min(150, 0.6 × khoảng cách tính bằng ô)` Tiền.

**Tào Ty:** mỗi phe Nguyễn chỉ 1 cái; nhân thuế ×1.25 cho mọi Cảng của phe.

### S9.T03 — Thương điếm & quan hệ phương Tây
**Trạng thái:** `rel[power][team]` ∈ [0, 100], với `power ∈ {VOC, BDN}`.

| | Trịnh | Nguyễn |
|---|---|---|
| VOC khởi đầu | 45 | 20 |
| BĐN khởi đầu | 15 | 45 |

Bản đồ có "điểm thương nhân" của từng power thì mới xây được Thương điếm của power đó (S4.T02).

**Tăng quan hệ:** `+1` cho mỗi 50 Tiền tiêu ở Thương điếm của power đó, nhân với `×1.2` nếu có Danh nghĩa (Trịnh) và `×1.25` nếu có R37.
**Suy giảm:** −1 mỗi 2 phút không giao dịch.
**Ai được phục vụ:** `ally(power)` = phe có `rel` cao nhất và ≥ 40.
- **Đổi phe:** khi một phe khác vượt đồng minh hiện tại ≥ 10 điểm.
- Phát `relation_changed` và toast "VOC đổi sang ủng hộ …". Tàu VOC mà phe cũ đang thuê rời đi sau 30 giây.

**Trận lớn** (cửa sổ trượt 120 giây):
```
loss(team) = Σ value(u) của quân team chết
nếu loss(A) ≥ 1500 và loss(A) ≥ 2 × loss(B): mọi power: rel[A] −= 20, rel[B] += 10 (mỗi trận lớn chỉ tính 1 lần)
```

**Dịch vụ của Thương điếm** (chỉ cho phe `ally`):

| Dịch vụ | Điều kiện | Giá | Giới hạn |
|---|---|---|---|
| Mua Sắt hoặc Diêm (lô 100) | rel ≥ 40 | `100 × base × 1.5` Tiền (Danh nghĩa −15%) | – |
| Mua đại bác | rel ≥ 40, đã ở GĐ II | 300 T + 50 S | Xuất hiện tại Thương điếm |
| Thuê tàu chiến VOC | rel ≥ 70 | 400 T + upkeep 2 T/phút | Tối đa 2 chiếc |
| Thuê thợ đúc BĐN | rel ≥ 70 | 300 T + upkeep 1 T/phút | 1 người mỗi Xưởng đúc |

### S9.T04 — Lính đánh thuê & upkeep Tiền
- Các khoản thuê có tag `mercenary`; upkeep Tiền trừ theo phút (S4.T05).
- **Khi `Tiền < 0`:**
  - Tàu thuê **đứng yên**: không di chuyển, không bắn.
  - Mỗi 10 giây (×1.5 với R40), khoản thuê lâu nhất **bỏ đi**: tàu rời bản đồ, thợ đúc biến mất. Phát cảnh báo `tien_am`.
- **Tiền ≥ 0 trở lại:** tàu hoạt động bình thường.
- **Thợ đúc BĐN:** gắn vào Xưởng đúc → pháo luyện nhanh hơn 25%, pháo luyện ra có `attack ×1.1`.

### S9.T05 — Lưỡng đầu chế
- **Triều vua Lê** là thực thể dân sự, chiếm được (ngưỡng 5 giây, S8.T04).
- Phe Trịnh có **Danh nghĩa** khi `trieu_vua.alive and trieu_vua.team == trịnh`:
  - sĩ khí hồi ×1.1;
  - giá ở Thương điếm −15%;
  - quan hệ tăng ×1.2.
- Triều vua bị chiếm hoặc bị phá → mất Danh nghĩa, phát toast và cảnh báo cho Trịnh. Chiếm lại thì có lại.
- Phe khác chiếm được Triều vua **không** nhận bonus (chỉ làm Trịnh mất).
- **Bộ máy cồng kềnh:** nghiên cứu của Trịnh lâu hơn 15% (S8.T02).

---

## Sprint 10 — AI & thiết lập đấu tự do

### S10.T01 — AI chiến lược (Utility AI)
Chạy mỗi `think_interval` giây.

| Hành động | Hàm điểm |
|---|---|
| Luyện dân | `1 − dân / mục tiêu` (mục tiêu = 30 + 10 × độ khó ở GĐ I, 50 + 10 × độ khó ở GĐ II) |
| Xây Nhà | `free_pop ≤ 5 ? 1 : 0` |
| Lập Làng | Có đất trống hoặc lãnh thổ gần mỏ chưa khai thác; `0.7 + 0.3 × khẩn hoang` |
| Ruộng, Mỏ | Thiếu loại tài nguyên đó so với tỉ lệ mục tiêu L/G/Đ/T/S/D = 0.30/0.22/0.15/0.13/0.10/0.10 |
| Chợ: bán/mua | Một tài nguyên vượt 1500 thì bán; cần tài nguyên cho hành động có điểm cao nhất mà thiếu dưới 300 thì mua, nếu giá < 1.5 × base |
| Sang GĐ II | 0.9 khi đủ điều kiện và tài nguyên |
| Công trình quân sự | Theo build order của phe; 0.8 |
| Luyện quân | `0.6 + 0.4 × counter_need`; ưu tiên số lượng chẵn 30/50 để lập Đội |
| Thương điếm | rel < 40 và dư Tiền > 800 thì giao dịch; rel ≥ 70 và quân yếu thế thì thuê |
| Nghiên cứu | Dư tài nguyên > 600; ưu tiên năng suất ở GĐ I, quân sự ở GĐ II |
| Đồn chống bắt dân | Có mỏ ở xa lãnh thổ > 10 ô; 0.6 |

AI **phải tính cả upkeep và đạn dược**: không luyện thêm súng hay pháo khi `net_income(Sắt hoặc Diêm)` âm quá −50/phút.

### S10.T02 — AI chiến thuật (Behavior Tree)
```
Selector
├─ [avg morale của Đội < 30]                 → Retreat về lãnh thổ
├─ [địch trong lãnh thổ]                      → Defend: lập Đội (S6.T02) nếu có ≥ 30 lính cùng loại → Guard/AttackMove
├─ [bị chặn bởi Lũy hoặc tường địch]          → đưa đại bác/voi lên trước, Hold ngoài tầm Đồn, bắn phá 1 đoạn → AttackMove qua chỗ vỡ
├─ [elapsed ≥ next_attack và power ≥ 1.2 × est_enemy] → FormUp: Đội giáo Vuông ở trước, Đội súng Ngang ở sau → AttackMove
└─ Idle: Rest tại điểm tập kết
power = Σ hp × dps; est_enemy = quân địch đã thấy trong 120 s gần nhất
```

### S10.T03 — Độ khó
| Tham số | Dễ | Thường | Khó |
|---|---|---|---|
| `think_interval` | 2.0 s | 1.5 s | 1.0 s |
| `apm_budget` | 3 | 5 | 8 |
| `gather_mult` | 0.8 | 1.0 | 1.2 |
| Đợt tấn công đầu | 12 phút | 9 phút | 6 phút (cộng thêm thời gian hòa bình) |
| Lập Đội | Không | Có | Có |
| Dùng chợ và Thương điếm | Chỉ bán | Có | Có |
| Nhìn xuyên fog | Không | Không | Không |

### S10.T04 — AI soak headless
```
godot --headless res://tests/ai/soak.tscn -- --seed=S --players=2..4 --profiles=… --max-min=60 --out=out.csv
```
- Ghi các cột: `winner, reason, duration, peak_units, era2_at, idle_worker_s, market_trades, crashed`.
- Nightly: 50 seed với 1v1 và 10 seed với 1v3.

### S10.T05 — Điều kiện thắng & thiết lập Đấu tự do
**Kiểm tra mỗi 1 giây:**
```
Tiêu diệt: team bị loại khi không còn công trình trung tâm (Phủ chúa, Làng, Triều vua) và không còn quân chiến đấu
Chiếm thủ phủ: zone = 8 ô quanh Phủ chúa của địch;
   nếu trong zone có quân chiến đấu của A và không có quân chiến đấu của chủ Phủ → hold[A] += 1, ngược lại hold[A] = 0
   hold ≥ 120 → A thắng (vòng tiến độ hiện trên HUD của cả hai bên)
Đình chiến: khi elapsed ≥ truce_min × 60:
   score = 0.4 × territory_share + 0.3 × econ_share + 0.3 × army_share
   territory_share = số ô lãnh thổ / tổng; econ_share = tổng tài nguyên thu được (theo value) / tổng;
   army_share = Σ value của quân đang sống / tổng → bên điểm cao nhất thắng; hòa thì hiện kết quả "Đình chiến bất phân thắng bại"
```
**Màn thiết lập Đấu tự do:**

| Tùy chọn | Giá trị |
|---|---|
| Phe | Trịnh / Nguyễn |
| Đối thủ | 1–3 AI, mỗi AI có phe và độ khó riêng |
| Địa hình | Hai đàng (sông Gianh) / Ven biển / Đồng bằng |
| Kích thước | Nhỏ 96×72 / Vừa 128×96 |
| Tài nguyên đầu | Thấp / Thường / Cao |
| Giai đoạn khởi đầu | I / II |
| Hòa bình | 0 / 5 / 10 phút: không thể tấn công công trình hoặc chiếm đoạt, quân không vượt được sông |
| Vị trí xuất phát | Ngẫu nhiên / chọn |
| Điều kiện thắng | Tiêu diệt / Chiếm thủ phủ / Đình chiến 20, 30, 45 phút |
| Dịch bệnh | Bật / Tắt |

`cap_match` tự chọn theo hạng máy (S18.T01); người chơi có thể giảm xuống, không tăng được.
