# Thuật toán & quy trình xử lý — Phase 3 (S11 – S17)

> Quy ước chung: xem mục 0 của [ALGO_P0_P1.md](ALGO_P0_P1.md).

---

## Sprint 11 — Pipeline đồ họa

### S11.T01 — Style guide *(quy trình)*
1. Thu thập tư liệu thế kỷ 17 cho 5 nhóm: quân phục, vũ khí, cờ hiệu, kiến trúc (phủ, làng, chợ, cảng), tàu thuyền (thuyền chiến Đàng Trong có pháo mũi, tàu VOC). Mỗi ảnh ghi nguồn.
2. Bảng màu: Trịnh vàng `#F4C62A`, Nguyễn đỏ `#D42E28`. Mỗi phe có hoa văn riêng cho chế độ mù màu.
3. Kiểm tra với các dạng mù màu deuteranopia và protanopia. Yêu cầu: độ sáng của 2 màu phe chênh ≥ 25%.
4. Quy định kích thước khung, pivot và số frame:

| Hoạt ảnh | Đơn vị trên đất | Thuyền |
|---|---|---|
| Đứng (idle) | 4 | 4 |
| Đi (walk) | 8 | 6 (đi/bơi) |
| Đánh (attack) | 8 | – |
| Chết (death) | 8 | – |
| Chìm (sink) | – | 6 |

Thuyền vẽ 8 hướng, các hoạt ảnh di chuyển và chìm loop.

### S11.T02 — Script render Blender
```
blender -b model.blend -P render_unit.py -- --out out/<id> --size 64|96|128 --kind land|ship
```
- Cố định engine EEVEE và `seed = 0`, tắt motion blur, để kết quả tất định.
- Camera orthographic, quay xuống 30°. Quay model 8 hướng; với mỗi hướng render từng action.
- Pass thứ hai: mask màu phe (emission trắng trên phần có thuộc tính `team_mask`).
- Thiếu action thì exit 1, báo tên action bị thiếu.
- Ghép sprite sheet bằng Pillow kèm `meta.json`.

### S11.T03 — Import & atlas
- Preset nén VRAM (ETC2/ASTC), tắt mipmaps, bật fix alpha border. CI kiểm tra mọi file `.import`.
- Sinh `SpriteFrames` từ `meta.json`.
- Nạp asset theo phe có trong trận. Mục tiêu RAM texture < 150 MB.

### S11.T04 — Unit renderer
- **Hướng sprite:** `dir = posmod(round(atan2(v_screen) / (π/4)), 8)`, tính theo hướng sau khi chiếu isometric.
- **Màu phe:** `COLOR.rgb = mix(base, team × (0.4 + 0.8·lum), mask.r)`.
- **Đồng bộ đòn đánh:** `hit_frame` trùng với tick gây sát thương.
- **Đội:** vẽ cờ đội (màu phe, kèm số thứ tự Đội) phía trên cai đội. Khi zoom < 0.6 chỉ vẽ cờ đội.

---

## Sprint 12 — Đủ quân, công trình & âm thanh

### S12.T01 / S12.T02 — Đơn vị chung & đặc trưng *(quy trình + cân bằng)*
1. Nhập các dòng ở ALGO_P0_P1 §5 vào `units.csv` → render → atlas → csv_to_tres → validator → tool DPS/TTK (S5.T05). Xử lý mọi cặp bị cảnh báo.
2. **Vòng cân bằng hai phe:**
   ```
   chạy 50 trận AI vs AI (Thường vs Thường, đổi bên, bản đồ "Hai đàng", GĐ khởi đầu I)
   winrate(Trịnh) ∉ [45%, 55%] → chỉnh ±5% MỘT trong các đòn bẩy, theo thứ tự ưu tiên:
       (1) giá Dân của Trịnh  (2) Nhà của Nguyễn +12/+13  (3) máu Lũy  (4) chu kỳ thuyền buôn  (5) chỉ số Cơ súng / Lính súng ĐN
   chạy lại; tối đa 6 vòng; ghi mỗi vòng vào data/balance/CHANGELOG.md
   ```
   Chạy thêm 20 trận trên bản đồ "Ven biển" để kiểm tra thủy quân. Mục tiêu winrate trong 40–60%.

### S12.T03 — Công trình 2 phe
- Mỗi công trình có 4 sprite: xây 0–33%, xây 33–99%, hoàn thành, hư hại (< 30% máu). Thêm đống đổ nát giữ 20 giây.
- Công trình bị chiếm thì tô lại màu phe qua mask, không đổi sprite.
- Kiến trúc riêng theo phe cho Phủ chúa, Làng, Nhà, Doanh trại. Triều vua Lê và Tào Ty là công trình độc nhất.

### S12.T04 — Âm thanh
- **Bus:** `Master → Music / SFX / UI / Voice / Ambience` (sóng biển, chợ).
- **Giới hạn voice:** mỗi `sound_id` tối đa 4, toàn cục tối đa 14. Vượt thì thay voice ở xa camera nhất.
- **Âm thanh trận đông:** hơn 30 quân giao chiến trong khung nhìn → bật lớp âm thanh nền "trận chiến", giảm âm lượng tiếng lẻ đi 40%.
- **Loạt đạn:** một loạt bắn (S6.T04) chỉ phát **1 âm thanh loạt** kèm biến thể, không phát N tiếng súng riêng.
- Mọi file có dòng tương ứng trong `assets/audio/LICENSES.md`; CI kiểm tra.

---

## Sprint 13 — Thủy quân, bến phà, dịch bệnh

### S13.T01 — Thủy chiến
- **Pathing:** thuyền dùng lưới WATER; `large_ship` chỉ đi được ở biển sâu và sông lớn (đánh dấu trên map).
- **Bắn:**
  - Thuyền chiến có pháo mũi: chỉ bắn khi mục tiêu nằm trong ±45° quanh hướng mũi, nên thuyền tự quay mũi về mục tiêu.
  - Tàu VOC bắn hai mạn: mục tiêu trong ±60° quanh hai bên sườn.
  - Bắn được mục tiêu trên bờ trong tầm.
- **Ngư binh:** `small_ship`, ×2 sát thương lên `large_ship`. Khi ≥ 3 ngư binh vây một tàu lớn (cùng ở trong 120 px quanh nó), tàu đó bị −20% tốc độ.
- **Chở quân:** thuyền chiến chở 10 quân.
  - Lệnh "Lên thuyền": quân đi tới ô đất kề thuyền, bị ẩn và đưa vào `cargo`.
  - Đổ bộ: BFS các ô đất đi được trong bán kính 2 ô quanh thuyền rồi thả quân.
  - Thuyền chìm thì quân trong `cargo` chết.
- **Hoạt ảnh chìm:** 3 giây, sau đó để lại xác thuyền ở dạng sprite nổi 10 giây.

### S13.T02 — Bến phà & cầu
**Bến phà** gồm 1 cặp điểm A (bờ Bắc) – B (bờ Nam) và 1 phà trung lập (NPC):

| Tham số | Giá trị |
|---|---|
| Sức chở | 20 dân số mỗi chuyến (voi tính 3, pháo tính 2) |
| Thời gian một chiều | 12 s |
| Thời gian chờ tối đa ở bến | 5 s (hoặc tới khi đầy) |

```
Pathing coi A↔B là một "cạnh ảo" với chi phí 12 s × speed (để A* và flow field chọn bến phà khi rẻ hơn đi vòng qua cầu)
quân tới A → xếp hàng; phà ở A → lên phà tới khi đầy hoặc hết thời gian chờ → sang B (12 s) → thả quân → quay lại
quân trên phà: ẩn, không bị tấn công; phà chìm (thuyền chiến địch bắn được, máu 300) → quân trên phà chết; phà hồi sinh sau 60 s
```
**Cầu:**
- Cầu là thực thể quân sự (máu 1500, chỉ bị phá bởi đơn vị có `can_damage_military`).
- Cầu bị phá: các ô cầu chuyển thành sông, xóa cache flow field, quân đang đứng trên cầu chết.
- Dân sửa lại được cầu với giá 200 G, 100 Đ và 30 giây (cần ít nhất 1 đầu cầu nằm trong lãnh thổ).

### S13.T03 — AI thủy quân & qua sông
- AI xây Cảng khi bản đồ có biển. Đóng thuyền chiến khi địch có thuyền chiến hoặc khi có thuyền buôn của địch để săn.
- Hộ tống thuyền buôn của mình bằng lệnh Guard quanh Cảng.
- **Qua sông:** để pathing tự chọn cầu hoặc bến phà. AI thấy cầu bị phá thì đổi sang bến phà hoặc dùng thuyền chở quân. Cầu bị phá trong lãnh thổ của AI thì AI sửa lại khi có tài nguyên.
- **Phá cầu phòng thủ:** khi đạo quân địch mạnh hơn ≥ 1.5 lần đang tiến về phía cầu, AI Khó cho đại bác bắn phá cầu.

### S13.T04 — Dịch bệnh & tiếp tế (tùy chọn khi tạo trận)
Kiểm tra mỗi 10 giây với từng quân của phe có bật dịch bệnh:
```
ngoài lãnh thổ phe mình liên tục > 180 s và cách Kho lúa/Làng/Phủ gần nhất > 40 ô
    → mất 1% max_hp mỗi 10 s (không chết vì bệnh dưới 20% máu); sĩ khí −1
hiển thị biểu tượng "bệnh" trên đầu quân bị ảnh hưởng; cảnh báo 1 lần/60 s
về lại lãnh thổ → bộ đếm về 0, hồi phục bình thường
```

---

## Sprint 14 — Trigger, chế độ chơi, tiến trình chiến dịch

### S14.T01 — Trigger dạng dữ liệu
**Mô hình:** `TriggerDef{id, once, enabled, condition: And|Or|Not|Leaf, actions[]}`.

**Leaf (điều kiện):**
- `unit_in_area`, `entity_dead`, `time_elapsed`, `resource_at_least`, `building_count`;
- `era_reached`, `relation_at_least(power, team, n)`, `captured(entity_tag)`, `wall_segments_built(area, n)`;
- `ships_sunk(owner, n)`, `night`, `flag`.

**Action (hành động):**
- `show_message`, `spawn_units`, `set_objective`, `win`, `lose`, `set_flag`, `camera_pan`, `play_dialog`;
- `give_resources`, `enable_trigger`, `set_relation`, `force_truce`, `set_night(on)`, `ai_attack(target_area)`.

**Đánh giá:** mỗi 10 tick và ngay khi có event liên quan, theo thứ tự khai báo, AND/OR đánh giá ngắn mạch. Mọi tham chiếu được kiểm tra khi nạp màn.

### S14.T02 — Hội thoại & cutscene
- `DialogDef{lines[{speaker_id, portrait, text_key, pause_sim}]}`.
- Chữ chạy tốc độ 40 ký tự/s. Chạm để hiện hết câu, chạm tiếp để sang câu sau. Có nút "Bỏ qua".
- `camera_pan` khóa input camera trong lúc lia, xong thì mở lại.
- Hộp thoại cao ≤ 120 pt ở đáy màn hình, chân dung 72 pt.

### S14.T03 — Editor plugin
- Dock để đặt Area, SpawnPoint, Entity tag, Trigger và **điểm thương nhân**, **bến phà**, **điểm thuyền buôn ngoài khơi**.
- Lưu và nạp `ScenarioDef`. Kiểm tra round-trip.

### S14.T04 — Trận lịch sử
- `ScenarioDef.mode = battle`:
  - tắt khai thác, xây dựng và luyện quân (ẩn nút Xây);
  - quân, Đội và tài nguyên đạn dược có sẵn; upkeep Lúa tắt.
- Điều kiện thắng theo kịch bản (ví dụ "phá đội tàu", "giữ cầu 8 phút").
- Có nút "Chơi lại nhanh".
- Thời gian vào trận < 10 giây vì bản đồ nhỏ và không có kinh tế.

### S14.T05 — Menu chiến dịch & tiến trình
**Save** `user://campaign.json`:
```
{version:2, campaigns: {nguyen: {missions:{"1":{"state":"completed","stars":2}, "2":{"state":"unlocked"}}},
                        trinh:  {missions:{...}}}}
```
- **Thứ tự mở khóa** (theo GDD §11):

| Chiến dịch | Nhiệm vụ |
|---|---|
| Nguyễn | 1 → 2 → 3 → 4 → 5 |
| Trịnh | 2 → 6 → 7 |

  Nhiệm vụ 2 thuộc cả hai chiến dịch nhưng mỗi chiến dịch lưu kết quả riêng.
- **Ghi file an toàn:** ghi `tmp` → copy bản hiện tại thành `.bak` → rename `tmp`. Khi nạp mà lỗi parse thì dùng `.bak`.

---

## Sprint 15 — Chiến dịch I

**Quy trình chung cho mỗi nhiệm vụ:**
1. Viết brief tại `docs/design/missions/<id>.md`: bối cảnh có nguồn và **độ chắc nguồn**, phe chơi, mục tiêu chính và phụ (cho 1–3 sao), điều kiện thua, quân và tài nguyên khởi đầu, đợt địch theo thời gian, thời lượng mục tiêu, gợi ý.
2. Vẽ map. Đặt trigger bằng plugin.
3. Viết lời giải mẫu `tests/fixtures/solutions/<id>.cmdlog` để phát lại ở chế độ headless.
4. Playtest 3 lần ở độ khó Thường, chỉnh cho tới khi thời lượng đúng mục tiêu.

### S15.T01 — NV1 Vào Thuận Hóa (1558)
- **Phe:** Nguyễn. Kiêm hướng dẫn chơi (S19.T03 bổ sung overlay).
- **Chuỗi mục tiêu:**
  1. Lập Làng trên đất trống (dạy khẩn hoang −30%).
  2. Giao 8 dân làm ruộng, 4 dân làm mỏ đá.
  3. Xây Nhà.
  4. Dựng Phủ ở Ái Tử: đặt Phủ chúa tại vùng chỉ định.
  5. Lập Đội 30 lính giáo để đẩy lui một nhóm thổ phỉ nhỏ.
- **Thời lượng mục tiêu:** 12–15 phút. Không thua được, trừ khi Phủ bị phá.

### S15.T02 — NV2 Trận 1627 (cả hai phe)
- **Nguyễn:** cầm cự **12 phút** (rút gọn từ "4 tháng") trước quân Trịnh đông hơn khoảng 2 lần. Thua khi Phủ chúa bị chiếm hoặc phá.
- **Trịnh:** chiếm Phủ của Nguyễn trong 12 phút. Hết giờ thì thua ("không thắng, phải rút quân").
- **Sao:** giữ được ≥ 70% công trình (Nguyễn) / chiếm trước phút 10 (Trịnh).

### S15.T03 — NV3 Lũy Thầy (1630)
- **Phe:** Nguyễn, đã ở GĐ II, có Đào Duy Từ là nhân vật chỉ huy.
- **Mục tiêu:** xây đủ **40 ô Lũy** trong vùng đánh dấu trước **phút 10**. Từ phút 10 quân Trịnh tới; giữ 8 phút.
- **Đồng hồ đếm ngược** hiển thị dưới thanh trên.
- Trigger `wall_segments_built(area, 40)`. Ghi chú trong game rằng năm xây lũy lệch giữa các nguồn.

### S15.T04 — Nhân vật chỉ huy (chỉ có trong chiến dịch)
- **`CommanderDef`:** đơn vị có tên, máu cao, **1 aura** (bán kính 250 px, cập nhật mỗi 0.5 giây). Aura cùng loại từ nhiều chỉ huy lấy giá trị lớn nhất, không cộng dồn. Không có kỹ năng chủ động.

| Chỉ huy | Phe | Aura |
|---|---|---|
| Đào Duy Từ | Nguyễn | Xây Lũy nhanh ×1.5 và Lũy giáp +3 trong vùng |
| Nguyễn Phúc Tần | Nguyễn | Voi và bộ binh công +10% |
| Trịnh Tạc | Trịnh | Sĩ khí +4/s |
| Trịnh Căn | Trịnh | Đại bác nạp nhanh ×0.9 |

- **Chỉ huy chết:** đồng minh trong 600 px −30 sĩ khí. Nhiệm vụ đánh dấu chỉ huy là "bắt buộc" thì thua.
- Tên và lời thoại chờ duyệt ở S17.T02.

---

## Sprint 16 — Chiến dịch II

### S16.T01 — NV4 Sông Gianh (1643)
- **Phe:** Nguyễn. Có Nguyễn Phúc Tần. Bản đồ cửa sông.
- **Lực lượng:** người chơi có **50 ngư binh** (Nam Bắc: "50–60 thuyền nhỏ") và 3 thuyền chiến. Địch có 3 tàu VOC (NPC, `large_ship`) cùng thuyền chiến Trịnh.
- **Mục tiêu:** đánh chìm cả 3 tàu VOC. Thua khi mất hết thuyền.
- **Sao:** mất ≤ 20 ngư binh.
- Kết thúc nhiệm vụ: `set_relation(VOC, nguyen, +30)` để báo trước sự kiện VOC hòa với Nguyễn năm 1651.
- Ghi chú trong game: ngày trận đánh và quân số lệch giữa các nguồn.

### S16.T02 — NV5 Trường Dục (1648)
**Pha 1 – Phòng thủ (10 phút):** giữ tuyến lũy có sẵn trước các đợt tấn công của Trịnh.

**Pha 2 – Phản công đêm:**
- `set_night(true)`: tầm nhìn mọi đơn vị ×0.5, lớp phủ tối alpha 0.5.
- Người chơi nhận thêm 20 voi chiến (Nam Bắc: "trăm voi", rút gọn cho trần quân điện thoại), cùng Nguyễn Phúc Tần.
- Mục tiêu: phá 3 doanh trại của Trịnh trong 8 phút.

### S16.T03 — NV6 Nghệ An (1655–1656)
- **Phe:** Trịnh. Có Trịnh Tạc và Trịnh Căn.
- **Mục tiêu:** đẩy quân Nguyễn ở các vùng phía Bắc sông Gianh về bờ Nam bằng cách giành lại 3 vùng (trigger giữ vùng 60 giây cho mỗi vùng).
- **Sao:** không mất chỉ huy nào.

### S16.T04 — NV7 Trận cuối (1672)
- **Phe:** Trịnh.
- **Mục tiêu:** tiến đánh Phú Xuân. Ở **phút 15**, bất kể kết quả chiến sự, trigger `force_truce` → màn kết thúc "Đình chiến – sông Gianh thành giới tuyến".
- **Sao:** tính theo điểm đình chiến (S10.T05): ≥ 50% được 2 sao, ≥ 60% được 3 sao.
- Thua chỉ khi Phủ chúa của người chơi bị chiếm trước phút 15.
- Ghi chú trong game: tên chỉ huy phía Nguyễn lệch giữa các nguồn.

---

## Sprint 17 — Nội dung lịch sử & thẩm định

### S17.T01 — Bách khoa
- `EncyclopediaEntry{id, category, title_key, body_key, image, sources[], certainty: many|one|conflict, fiction_note_key?, unlock}`.
- Hiển thị huy hiệu độ chắc nguồn:

| `certainty` | Huy hiệu |
|---|---|
| `many` | Nhiều nguồn |
| `one` | Một nguồn |
| `conflict` | Nguồn lệch |

- Validator báo lỗi khi `sources` rỗng.

### S17.T02 — Người hiểu sử duyệt *(quy trình)*
1. Xuất toàn bộ tên, lời thoại, brief, mô tả công trình và trang phục, cùng ảnh concept, ra `docs/history_review.csv` với các cột: `key, nội dung, nguồn, độ chắc, người duyệt, kết quả (OK/Sửa/Hư cấu), ghi chú`.
2. Nguồn đối chiếu: các nguồn ở doc Nam Bắc mục 10, *Đại Nam thực lục tiền biên*, *Phủ biên tạp lục*.
3. Mọi chi tiết thêm vào cho gameplay đều có `fiction_note`.
4. Rà riêng về **tính cân bằng của cách trình bày** (nội chiến, không tôn một bên): đọc lại mọi lời kết của các nhiệm vụ.
5. Đóng hết các dòng "Sửa" trước M3.

### S17.T03 — Nội dung Trận lịch sử
Năm trận khởi điểm, mỗi trận 10–15 phút:

| Trận | Nội dung |
|---|---|
| Giữ cầu sông Gianh | Phòng thủ cầu |
| Đêm Trường Dục | Tấn công bằng voi |
| Hải chiến 1643 rút gọn | Thủy chiến |
| Công lũy Trấn Ninh | Pháo phá lũy |
| Vượt sông Lam | Qua sông bằng bến phà |

Mỗi trận được viết như một `ScenarioDef(mode = battle)`, có 3 sao và lời giải mẫu.
