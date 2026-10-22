# Thuật toán & quy trình xử lý — Phase 0 & Phase 1 (S0 – S4)

> Mỗi mục gồm: **Thuật toán/Quy trình** → **Tham số mặc định** → **Độ phức tạp** → **Edge case** (kèm mã test case).
> Pseudocode độc lập ngôn ngữ. Khi chuyển sang GDScript, giữ nguyên tên tham số để dễ đối chiếu với test.
> Thiết kế chuẩn: [GAME_DESIGN v2](../../GAME_DESIGN.md) (theo doc Nam Bắc + wireframe 844×390).

## 0. Quy ước chung (cho mọi phase)

| Quy ước | Giá trị |
|---|---|
| Tick mô phỏng | **20 Hz** (`DT = 0.05 s`); `ticks = ceil(giây / DT)` |
| Không gian sim | Tọa độ Descartes, đơn vị px thế giới, 1 ô = 32 px. Chỉ `render/` mới chiếu sang isometric |
| Tài nguyên | Mảng 6 phần tử, theo thứ tự `[LUA, GO, DA, TIEN, SAT, DIEM]`; viết tắt trên UI: L, G, Đ, T, S, D. Lưu dạng `float`; mọi phép so sánh đủ/thiếu dùng sai số `1e-6` (ví dụ 0.5 Sắt đủ cho đúng 5 phát 0.1) |
| Đơn vị UI | **pt theo khung 844×390** (wireframe). Đổi sang px: `px = pt × (chiều cao viewport / 390)` |
| Giai đoạn | `era ∈ {1, 2}` trong bản 1.0 (3 để dành cho sau phát hành) |
| Ngẫu nhiên | Chỉ lấy qua `RngService.stream(name)` |
| ID thực thể | `int` tăng dần, không tái sử dụng trong một trận |
| Thứ tự cập nhật mỗi tick | 1. Command · 2. AI · 3. di chuyển · 4. chiến đấu · 5. đạn · 6. kinh tế (khai thác, upkeep, thuế, chợ, thương mại) · 7. sĩ khí · 8. chiếm đoạt · 9. fog · 10. trigger · 11. dọn thực thể chết · 12. phát sự kiện |
| Duyệt thực thể | Theo ID tăng dần (tất định) |
| Trần quân | `cap_match` = 800 (máy hạng Trung trở lên) hoặc 400 (máy hạng Thấp); mỗi người chơi được `floor(cap_match / số người chơi)` |

---

## Sprint 0

### S0.T01 — Duyệt GDD v2 *(quy trình)*
1. Đối chiếu từng mục của GDD v2 với doc Nam Bắc và wireframe. Ghi mọi chênh lệch vào bảng `Mục | Nam Bắc | GDD v2 | Quyết định`.
2. Rà các chỗ có nhãn **[GDD v2 đặt]**: đồng ý hoặc sửa số.
3. Ký duyệt bảng MoSCoW (GDD §16) → đóng băng phạm vi. Mọi thay đổi sau đó đi qua Issue nhãn `change-request`.

### S0.T02 — ADR *(quy trình)*
Mẫu MADR: `Bối cảnh · Yếu tố quyết định · ≥ 2 phương án · Quyết định · Hệ quả`. Lưu tại `docs/adr/ADR-00x-<slug>.md`.

### S0.T03 — Chuẩn hóa repo *(quy trình)*
- Git LFS cho `*.png *.jpg *.psd *.kra *.blend *.wav *.ogg *.ttf *.otf *.glb`.
- `.gitignore`: `.godot/ build/ *.apk *.aab *.keystore *.jks __pycache__/`.
- Hook `commit-msg` (thư mục `.githooks/`, bật bằng `git config core.hooksPath .githooks`, không cần cài thêm gì) kiểm tra regex `^(feat|fix|docs|test|refactor|perf|chore|ci)(\(.+\))?: .+ \(S\d{1,2}\.T\d{2}\)$`. Mã task theo đúng ID trong roadmap (`S0.T04`, `S12.T01`). Riêng `docs` và `chore` thì mã task là tùy chọn.
- Template PR có các mục: Task ID · Mô tả · Test case đã chạy · Ảnh UI.
- Branch protection cho `main`: bắt buộc CI xanh và 1 người review.

### S0.T04 — CI
```
lint : gdtoolkit==4.5.0 → gdlint scripts tests; ruff tools
data : python tools/data_validator/validate.py data/
test : container barichello/godot-ci:4.7.2 → godot --headless --import
       → MikeSchulze/gdUnit4-action@v1.3.2 (tests/unit, integration, scene) → JUnit; pytest tools/tests
build: needs[test] → godot --headless --export-debug "Android" build/game.apk → upload-artifact
version-guard: GODOT_VERSION == config/features == plugin.cfg của các addon (xem 05_VERSIONS)
```

### S0.T05 — Framework test
Cài GdUnit4 6.2.2 và LimboAI 1.8.1 (bản GDExtension), khóa phiên bản trong `addons/README.md`. Chạy `runtest -a tests/` ở chế độ headless. Xác nhận các rủi ro R1–R3 của 05_VERSIONS và ghi kết quả vào `spike_report.md`.

### S0.T06 — Spike 800 quân
**Dựng:**
- Lưới 128×96, có sông và 2 cầu.
- `AStarGrid2D` cho quân đi lẻ; **flow field thô** (BFS 8 hướng) cho nhóm ≥ 8 quân.
- 800 quân là `Node2D` tự vẽ, chia 2 phe. Spatial hash ô 64 px. Mỗi quân tự đánh quân địch gần nhất.

**Đo:**
- FPS p50 và p1 (mỗi giây ghi 1 dòng CSV), thời gian 1 tick sim.
- Độ trễ input: quay video 240 fps.
- Nhiệt: `dumpsys thermalservice`.
- Chạy 2 kịch bản: 800 quân và 400 quân.

**Quyết định:**

| Kết quả | Hành động |
|---|---|
| Máy tầm trung p50 ≥ 25 FPS với 800 quân **và** máy yếu ≥ 25 FPS với 400 quân | **go** với `cap_match` 800/400 |
| Chỉ đạt khi giảm xuống 600/300 | Ghi trần tạm 600/300, báo PO, đưa phần port C++ (S18.T02) lên sớm |
| Không đạt cả mức trên | **no-go**: đổi sang MultiMesh và C++ ngay ở P1 |

### S0.T07 — Thử phong cách đồ họa
Camera Blender orthographic, quay xuống 30°, xoay 8 hướng × 45°. Kích thước khung: bộ binh 64, kỵ binh 96, voi/pháo/thuyền 128 px. Hiển thị thử ở khung 844×390 pt với zoom 0.5 / 1.0 / 1.8: yêu cầu chiều cao một lính ≥ 8 pt ở zoom 1.0.

---

## Sprint 1

### S1.T01 — Khởi tạo project
`project.godot`:
- `gl_compatibility`, `sensor_landscape`, stretch `canvas_items` + `expand`.
- Kích thước cửa sổ tham chiếu **1688×780** (gấp 2 lần 844×390). `physics_ticks_per_second = 20`, bật `physics_interpolation`.
- Autoload: `EventBus, RngService, Settings, SceneRouter, Session, SaveManager, AudioManager`.

Lint kiểm tra phụ thuộc giữa các lớp (`tools/ci/check_layers.py`): quét `preload/load("res://scripts/<x>/")`, `class_name` và API vẽ. Lớp nào gọi sang lớp không có trong bảng ALLOWED của [03_SKELETON §2](../03_SKELETON.md) thì báo lỗi.

### S1.T02 — EventBus & SceneRouter
**Danh mục signal bắt buộc:**

| Signal | Tham số |
|---|---|
| `unit_spawned` / `unit_died` | `id, team, type` / `id, team, type, killer_id` |
| `building_placed/completed/destroyed` | `id, team, type` |
| `resources_changed` | `team, res: PackedFloat32Array[6]` |
| `selection_changed` | `ids: PackedInt32Array` |
| `command_issued` | `cmd` |
| `alert_raised` | `kind: StringName, pos: Vector2, entity_id` |
| `capture_warning` / `entity_captured` | `id, from_team, to_team` |
| `era_changed` | `team, era` |
| `relation_changed` | `power: StringName, team, value` |
| `market_price_changed` | `res, price` |
| `morale_broken` | `id` |
| `research_done` | `team, id` |
| `objective_updated` | `id, state` |
| `match_ended` | `winner_team, reason` |

**SceneRouter.goto(path):** `load_threaded_request` → mỗi frame đọc `load_threaded_get_status` → `change_scene_to_packed`. Lỗi thì quay về menu. Trước khi đổi scene phát `scene_leaving` để các autoload xóa trạng thái trận.

### S1.T03 — Custom Resource
**`UnitDef`:**
- Định danh: `id, name_key, faction (rỗng = cả hai), era (1|2), replaces (id của đơn vị bị thay thế, ví dụ lính súng Đàng Ngoài thay lính súng)`.
- Giá: `cost: PackedFloat32Array[6]`.
- Chỉ số: `hp, armor, attack, range (≤20 = cận chiến), min_range, reload_s, accuracy, projectile, splash_px, speed, sight, radius, pop, train_s`.
- Tiêu hao: `upkeep: PackedFloat32Array[6] (mỗi phút)`, `ammo: PackedFloat32Array[6] (mỗi phát)`.
- Phân loại: `tags (infantry, melee, ranged, cavalry, elephant, siege, ship, small_ship, large_ship, worker, officer, drummer, mercenary, local)`, `bonus: Dictionary[tag → hệ số]`, `rank`, `domain (LAND|WATER)`, `capturable`, `can_damage_military: bool` (true cho siege, elephant, ship).

**`BuildingDef`:**
- `id, name_key, faction, era, cost[6], growth (g)`.
- `hp, armor, size, build_s, pop_bonus, dropoff: PackedInt32Array` (các loại tài nguyên nhận).
- `trains, researches, slots (cho ruộng/mỏ), territory_radius`.
- `military: bool` (chỉ bị phá bởi đơn vị có `can_damage_military`), `capturable`, `wall, walkable_by_owner_infantry, gate, max_count, coast_only, deposit_type`.
- Phòng thủ: `attack, range, reload_s, anti_capture_radius`.

**`ResearchDef`** (S8.T02), **`FactionDef`** (`units, buildings, mods: Dictionary` cho các luật riêng của phe), **`ScenarioDef`** (`mode: campaign|skirmish|battle, players, map, start_era, victory, rules{upkeep, plague, peace_min, pop_cap, truce_min}`).

### S1.T04 — Tool CSV → tres & validator
CSV dùng header trùng tên trường. Mảng 6 tài nguyên ghi theo dạng `L:40|G:10|T:20|S:5`. Mảng tag ngăn bằng `|`.

**Luật validator:**
1. Trường bắt buộc khác rỗng.
2. Số ≥ 0; `accuracy` ∈ [0,1]; `range` ≥ `min_range`; `growth` ≥ 1.
3. Mọi tham chiếu (`trains`, `researches`, `replaces`, `requires`) phải tồn tại.
4. Quân tầm xa phải có `projectile` và `ammo` > 0 nếu là súng hoặc pháo.
5. `era` của đơn vị ≥ `era` của công trình luyện ra nó.
6. Đơn vị và công trình có `faction` phải nằm trong `FactionDef` của đúng phe đó.

Lỗi in theo dạng `file:dòng:cột: thông điệp`, exit code 1. Chạy 2 lần phải cho ra cùng file (idempotent).

### S1.T05 — Tick cố định
`_physics_process` (20 Hz): lưu `prev_pos` rồi gọi `Sim.step()`. Render dùng physics interpolation của Godot. Sim không đọc `delta` của render.

### S1.T06 — RNG, CommandQueue, hash
- `RngService.stream(name)`: seed = `hash(match_seed + name)`.
- `Command{tick, team, type, unit_ids, target_pos, target_id, waypoints[], params}`. Lệnh do người chơi tạo được xếp vào tick `current + 1`.
- **State hash:** FNV-1a 64 trên dãy:
  - tick, state của các RNG stream, tài nguyên của các phe (×16, làm tròn);
  - **bảng giá chợ**, thanh quan hệ phương Tây, giai đoạn của từng phe;
  - từng thực thể theo ID: `id, x×16, y×16, hp×16, state, team`.

---

## Sprint 2

### S2.T01 — Địa hình
TileSet isometric 64×32. **Custom data:**

| Loại ô | `walk_land` | `walk_water` | `buildable` | `move_cost` |
|---|---|---|---|---|
| Cỏ | ✔ | | ✔ | 1.0 |
| Rừng (có cây) | | | | – |
| Sông | | ✔ | | – |
| **Cầu** | ✔ | ✔ (thuyền đi dưới được) | | 1.0 |
| **Bến phà** | ✔ (điểm lên/xuống phà) | ✔ | | 1.0 |
| Biển nông | | ✔ | | – |
| Biển sâu | | ✔ (chỉ thuyền `large_ship`) | | – |
| Mỏ (đá/sắt/diêm) | | | chỉ cho Mỏ | – |

Khi nạp map, chép sang `GridData` (các PackedByteArray). Cầu là thực thể `Bridge` có máu (S13.T02); khi cầu bị phá, các ô cầu chuyển thành sông.

### S2.T02 — Sinh bản đồ
```
1. Sông Gianh: y_c(x) = H/2 + 5·sin(0.07x + φ) + 2·noise(x); ô nước khi |y − y_c| ≤ 2
2. Cầu: 2 cầu (bản đồ vừa: 3) tại x ∈ {W/4, 3W/4} (+ W/2) + jitter ±4; mỗi cầu rộng 2 ô
3. Bến phà: 1 bến (vừa: 2) ở các khoảng giữa cầu, mỗi bến có 1 ô lên bờ Bắc + 1 ô lên bờ Nam
4. Bờ biển (nếu chọn "ven biển"): dải biển nông 4 ô + biển sâu ở mép Đông
5. Sinh NỬA BẮC (rừng Poisson-disc; mỏ đá/sắt/diêm mỗi loại 2 cái; đất trống cho khẩn hoang),
   rồi LẬT ĐỐI XỨNG TÂM sang nửa Nam
6. Đặt Phủ chúa cho mỗi bên (Trịnh thêm Triều vua Lê cách Phủ 8 ô)
7. Kiểm tra: BFS đường bộ từ Phủ A tới Phủ B (đi qua cầu); BFS đường thủy từ Cảng tiềm năng tới biển.
   Lỗi → seed += 1, tối đa 5 lần
```
Với 3–4 người chơi: thêm sông nhánh theo chiều dọc và đặt xuất phát ở 4 góc, đối xứng quay 90°.

### S2.T03 — A* + flow field
- Hai instance lưới: **LAND** và **WATER**. Quân `domain = WATER` có `large_ship` dùng lớp nước sâu.
- **Chọn thuật toán:** `n < 8` hoặc khoảng cách `< 12` ô thì dùng A* (heuristic OCTILE, `allow_partial = true`). Ngược lại dùng flow field (Dijkstra 8 hướng, chi phí ngang/dọc 1, chéo 1.414, nhân thêm `move_cost`).
- **Cache:** LRU **32** field, khóa = (team, domain, đích lượng tử hóa 2×2). Ô đổi trạng thái chặn (xây nhà, cầu bị phá, lũy) → xóa các field có chứa ô đó.
- **Ngân sách:** tối đa 2 field mỗi tick.
- **Mục tiêu hiệu năng:** 800 quân với 6 đích khác nhau < 6 ms/tick trên máy tầm trung.
- **Edge case:** đích bị chặn → ô đi được gần nhất (tìm xoáy ốc, tối đa 12 ô). Đích ở bờ bên kia mà không có đường bộ → trả về đường một phần và phát `alert_raised("no_path")`. Có nhà chặn đường đang đi → repath ở tick kế tiếp.

### S2.T04 — Né tránh cục bộ
- Spatial hash ô **32 px** (lớn hơn khoảng cách chạm của mọi quân bộ, nên chỉ cần xét 3×3 ô), xây lại mỗi tick. Mỗi cặp chỉ tính một lần rồi đẩy cả hai quân.
- Lực đẩy: `push += d/|d| × (min_d − |d|) × mass_o / (mass_u + mass_o)`, với `min_d = 0.9 × (r_u + r_o)`.
- Mass: bộ binh 1, kỵ binh 2, voi/pháo 4.
- Quân đã tới đích (`arrived`) có mass ×4. Hai quân đều đã tới đích chỉ đẩy nhau khi gần hơn **0.6 ×** khoảng cách chạm (không đẩy hoàn toàn bỏ qua, vì như vậy chúng có thể chồng khít nhau mãi).
- **Ở cầu (ô `bridge`):** tắt lực đẩy ngang, chỉ giữ đẩy theo phương dọc cầu (mô phỏng đi thành hàng).
- **Kẹt (`StuckWatch`):** đang đi mà trong 2 giây dịch chuyển < 2 px → repath (chuyển sang A* riêng của quân đó); 3 lần liên tiếp → về Idle. Mỗi quân chỉ được xét 1 lần trong 5 tick (so le theo id), thời gian cộng dồn 0.25 s mỗi lần.
- **Ngân sách:** < 3 ms/tick cho 800 quân trên máy tầm trung. Bản GDScript đo được 4.5 ms (800 quân đi rải) và 21 ms (800 quân dồn trong vùng 240×120 px) trên laptop Intel Iris Xe, nên **chưa đạt**; port C++ ở S18.T02.

### S2.T05 — Camera
```
kéo 2 ngón:  pos −= delta_tâm / zoom; vel = EMA(delta/dt, α = 0.3)
nhả tay:     vel *= exp(−5·dt), dừng khi < 10 px/s
chụm:        z = clamp(z0 × d/d0, 0.4, 1.8), giữ đứng yên điểm thế giới dưới tâm 2 ngón
kéo 1 ngón:  không làm gì; nếu Settings.one_finger_pan = true thì cuộn như kéo 2 ngón (S19.T02)
giới hạn:    pos trong map_rect thu nhỏ đi nửa khung nhìn; HUD neo theo safe area (tối thiểu 44 pt trái/phải)
```

### S2.T06 — Minimap
120×120 pt ở góc dưới trái (cách mép an toàn 60 pt, cách đáy 12 pt). Nền địa hình tạo một lần thành `ImageTexture`. Lớp động vẽ lại mỗi 0.25 giây. Chạm hoặc kéo trên minimap thì đặt `cam.pos = local / size × map_px`, rồi `accept_event()`.

---

## Sprint 3

### S3.T01 — Nhận diện cử chỉ
**Tham số** (pt):

| Tham số | Giá trị |
|---|---|
| `TAP_SLOP` | 8 pt |
| `TAP_MAX` | 250 ms |
| `DOUBLE_TAP` | 300 ms, khoảng cách ≤ 30 pt |
| `HOLD_BOX` | **300 ms** |
| `BUTTON_HOLD` | 500 ms |

```
IDLE --chạm (không trên HUD)--> PRESSED(start, t0)
PRESSED:
   ngón thứ 2 chạm                → TWO_FINGER (hủy tap)
   di chuyển > SLOP và t < 300 ms → NONE (không làm gì; one_finger_pan bật thì → PAN)
   giữ ≥ 300 ms, chưa di chuyển   → BOX_ARMED (rung nhẹ 10 ms)
   nhả tay ≤ 250 ms               → tap; nếu có tap trước trong 300 ms, cách ≤ 30 pt → double_tap
BOX_ARMED: di chuyển → BOX(kéo khung); nhả tay mà không di chuyển → hủy
BOX:       di chuyển → box_update; nhả tay → box_end
TWO_FINGER: pan (tâm 2 ngón) + pinch; hết ngón → IDLE (không phát tap)
Chế độ "Chọn vùng" bật: PRESSED + di chuyển > SLOP → BOX ngay, không cần giữ
```

### S3.T02 — Chọn quân
- **Chạm:** quân gần nhất có `dist − r < 10/zoom`. Không có thì xét công trình, rồi tài nguyên.
- **Khung chọn:** chỉ quân ta. Trong khung có quân chiến đấu thì loại dân ra.
- **Chạm đúp:** mọi quân ta cùng loại trong khung nhìn.
- **5 ô nhóm** (cột trái 52 pt): giữ 500 ms để gán `group[k] = ids`; chạm để chọn lại, sau khi lọc bỏ ID không còn sống. Nhãn ô ghi số và loại chiếm đa số (ví dụ "2 Voi"). Ô trống có viền đứt.
- **Ô "Rảnh N"** trên thanh trên: chọn lần lượt từng dân đang Idle và đưa camera tới đó. N = số dân rảnh; N > 0 thì nền ô màu cam.

### S3.T03 — Hệ thống lệnh
**Phân giải khi chạm lên bản đồ trong lúc có quân được chọn:**
```
mode == WAYPOINT (đang giữ nút "Thêm điểm"): nối điểm vào waypoints[], chưa ra lệnh
hit là địch → Attack | hit là mỏ/ruộng/cây và có dân → dân Gather (vào Mỏ/Ruộng), lính → Move
hit là công trình ta đang xây dở → dân Build | còn lại → Move (theo đội hình nếu đang chọn một Đội)
nhả nút "Thêm điểm" → ra lệnh Move(waypoints) (hoặc AttackMove nếu chế độ "Đi và đánh" đang bật)
```
**Điểm tập kết:** chọn công trình → nút "Điểm tập kết" → chạm lên bản đồ để đặt `rally`. Chạm lên ruộng hoặc mỏ thì dân mới luyện ra tự vào làm.

### S3.T04 — FSM của đơn vị (LimboAI HSM)
Các trạng thái: `Idle, Move, AttackMove, Attack, Gather (ruộng/rừng), WorkInside (mỏ), Return, Build, Repair, Hold, Rest, Guard, Rout, Boarding`.
- Chuyển trạng thái giống bản trước, thêm:
  - `WorkInside`: dân ẩn khỏi bản đồ và chiếm 1 chỗ trong mỏ;
  - `Hold, Rest, Guard`: theo lệnh ở S6.T04.
- `reach` = 14 px khi còn đang đi theo path, 26 px khi đã hết path.

### S3.T05 — Phản hồi & thẻ cảnh báo
- **Phản hồi lệnh:** dấu đích (0.7 giây), rung 20 ms, âm thanh xác nhận giới hạn bằng token bucket (4 lượt/giây).
- **Thẻ cảnh báo:** thẻ 220×36 pt ngay dưới thanh trên, tối đa 2 thẻ cùng lúc, mỗi thẻ hiện 5 giây.
  ```
  on alert_raised(kind, pos):
      nếu cùng kind và cách < 10 ô so với một thẻ đang hiện → gộp (cập nhật vị trí)
      không thì đẩy vào hàng đợi; hàng đợi đầy thì bỏ thẻ ưu tiên thấp nhất
  ưu tiên: capture_warning 5 > under_attack 4 > tien_am 3 > het_lua 3 > het_dan 2 > no_path 1
  chạm thẻ → camera nhảy tới pos; với capture_warning thì chọn luôn khu vực đó
  giới hạn tần suất: mỗi kind tối đa 1 lần/15 s (capture_warning: 1 lần/5 s cho mỗi thực thể)
  ```

---

## Sprint 4

### S4.T01 — Khai thác
| Nguồn | Cơ chế | Tốc độ mặc định |
|---|---|---|
| Ruộng (3×3, 4 chỗ, không cạn) | Dân cày gặt rồi chở về Kho lúa/Làng/Phủ gần nhất; mang tối đa 10 | `t_g = 0.5 s`/đơn vị |
| Rừng (cây 1×1, 300 đơn vị) | Chặt rồi chở về Làng/Phủ/Kho lúa gần nhất | `t_g = 0.6 s` |
| Mỏ (2×2 trên mỏ đá/sắt/diêm, không cạn) | Dân **vào trong mỏ**; tài nguyên cộng thẳng vào kho | Đá 15, Sắt 10, Diêm 8 đơn vị/phút cho mỗi dân |
| Thuế đinh | Mỗi 60 giây | `Tiền += 0.5 × số dân của phe` |

- Thu nhập từ ruộng hoặc rừng: `60 × 10 / (10·t_g + 2d/speed + 0.5)` đơn vị/phút.
- Nâng cấp mỏ (200G 100Đ 100T): thêm 5 chỗ.
- Mỏ đầy chỗ: dân được giao việc đi tới mỏ cùng loại gần nhất; không còn mỏ nào thì về Idle kèm cảnh báo.
- Ruộng có ô hiển thị số người cày (0–4/4).

### S4.T02 — Đặt & xây, giá tăng dần
```
cost(type, team) = round(base_cost × growth ^ n)    # n = số công trình cùng loại của phe (kể cả đang xây)
                                                    # round = làm tròn nửa lên (Godot roundf): 364.5 → 365
max_count: Phủ chúa 1, Triều vua 1, Tào Ty 1
```
- **Lưới Xây:** tấm bên phải rộng 420 pt, 4 tab (Kinh tế/Quân sự/Phòng thủ/Biển), lưới 4 cột, ô cao 72 pt ghi tên và giá theo `cost()` hiện tại.
  - Giá màu đỏ: thiếu tài nguyên.
  - Ô mờ: chưa mở khóa, kèm dòng điều kiện (ví dụ "Giai đoạn II", "Cần Doanh trại", "Bản đồ không có thương nhân").
  - Nút × 44 pt để đóng.
- **Đặt:** chạm chọn ô → chạm lên bản đồ.
  - Bóng mờ xanh khi hợp lệ, đỏ khi không.
  - Điều kiện hợp lệ: ô `buildable`; viền trống 1 ô (trừ lũy); `coast_only` thì phải giáp nước; công trình mỏ phải trùng ô mỏ đúng loại; Lũy/Tường phải nằm trong lãnh thổ (S4.T06).
- **Tốc độ xây:** `rate(n) = 1 + 0.75(n − 1)`, tối đa 8 dân. Tự hủy khi đang xây hoàn 75%; bị địch phá thì không hoàn.

### S4.T03 — Tuyển dân, hàng đợi, dân số
- **Bảng luyện quân:**
  - Chạm nút đơn vị: `queue += 1`.
  - Giữ 500 ms: mở bảng số lượng `[−1] [+5] [Vô hạn]`.
  - Biểu tượng ∞ hiện khi đang ở chế độ vô hạn.
- **Mỗi tick ở công trình:**
  ```
  if queue rỗng: return
  if chưa trừ tiền cho lượt đầu: if try_spend(cost): paid = true else: (vô hạn → chờ; thường → chờ, hiện giá đỏ)
  t += DT × train_speed; t ≥ train_s →
      if pop_used + pop > pop_cap hoặc units_of_team ≥ team_unit_cap: chờ + alert "Thiếu nhà"/"Đạt trần quân"
      else: spawn tại cửa → rally; queue −= 1 (vô hạn thì giữ nguyên)
  ```
  Tiền được trừ **khi bắt đầu luyện mỗi lượt**, không trừ khi xếp hàng (giống Cossacks: xếp hàng không giữ tiền).
- **Dân số:** `pop_cap = min(Σ pop_bonus, team_unit_cap)`.
  - Phủ +30, Làng +20, Nhà +15 (Nguyễn +12).
  - `team_unit_cap = floor(cap_match / số người chơi)`.

### S4.T04 — HUD thanh trên & bảng lệnh
- **Thanh trên** cao 36 pt, nằm trong vùng an toàn, từ trái sang phải:
  - `[Dân x/y]` 70 pt;
  - `[Rảnh N]` 60 pt;
  - nhóm 6 tài nguyên (chỉ số trong kho; con số màu đỏ khi Tiền < 0 hoặc tài nguyên = 0);
  - nút `II` 44 pt.
- **Chạm nhóm tài nguyên** mở bảng chi tiết (Control, rộng 360 pt). Mỗi tài nguyên có 1 dòng: `số người làm · thu/phút · chi/phút (upkeep + đạn) · ròng`. Số liệu tính bằng trung bình trượt 60 giây.
- **Bảng lệnh** ở đáy giữa, rộng 456 pt, cao ≤ 96 pt (≤ 25% chiều cao):
  - Chỉ hiện khi có đối tượng được chọn; ẩn hoặc hiện bằng tween 120 ms.
  - Dòng 1: tên × số lượng · hình đội · bonus.
  - Dòng 2: nút 48×48 pt. Nội dung theo đối tượng: Đội/quân thì 6 lệnh + 3 hình; công trình thì các nút luyện và nghiên cứu; dân thì các nút làm việc.
- Nút **Xây** 64 pt góc dưới phải mở lưới Xây (S4.T02); nút **Thêm điểm** 64 pt nằm bên trái nút Xây.

### S4.T05 — Upkeep, đạn dược, Tiền âm
```
mỗi 1 giây:
    với mỗi đơn vị u: res −= u.def.upkeep / 60        # Lúa cho mọi lính; Tiền cho lính đánh thuê (S9.T04)
    Lúa < 0 → Lúa = 0; đói: mỗi 5 s, mọi lính mất 2% max_hp (không dưới 10%), sĩ khí −5; alert het_lua
    Tiền được phép < 0 (đến −2000) → alert tien_am; xử lý đào ngũ ở S9.T04
mỗi phát bắn (S5.T02): nếu Sắt ≥ ammo.S và Diêm ≥ ammo.D → trừ; không đủ → không bắn,
    hiện biểu tượng "hết đạn", alert het_dan (1 lần/15 s)
```
**Upkeep Lúa mặc định (mỗi phút):** bộ binh 0.2 · kỵ binh 0.4 · voi 1.0 · đại bác 0.3 · thuyền 0.3 · dân 0.

### S4.T06 — Lãnh thổ & khẩn hoang
- Lưới `owner[cell]` tính lại khi có công trình mới hoặc bị phá. Mỗi ô thuộc phe có nguồn **gần nhất** trong bán kính (Phủ 20, Làng 15, Đồn 10). Hòa thì ô thuộc phe có ID công trình nhỏ hơn.
- **Đất trống:** ô không thuộc phe nào.
- **Khẩn hoang (Nguyễn):** Làng đặt trên footprint **toàn bộ là đất trống** được giảm giá 30% (áp dụng sau `cost()`).
- **Hiển thị:** khi đang đặt công trình, vẽ lớp lãnh thổ với viền màu phe và alpha 0.2.

---

## 5. Bảng số liệu khởi điểm [GDD v2 đặt]

Giá ghi theo thứ tự **L / G / Đ / T / S / D**, số 0 để trống.

**Đơn vị bộ:**

| Đơn vị | Phe | GĐ | Giá | Máu | Công | Giáp | Tầm | Nạp (s) | Chính xác | Tốc độ | Dân số | Luyện (s) | Bonus | Đạn/phát (S, D) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Dân | Trịnh / Nguyễn | I | 40 L / 50 L | 40 | 3 | 0 | 10 | 1.2 | – | 72 | 1 | 8 | – | – |
| Lính giáo | cả hai | I | 30 L, 10 G | 90 | 8 | 2 | 14 | 1.0 | – | 66 | 1 | 10 | kỵ ×2, voi ×2.5 | – |
| Lính đao | cả hai | I | 30 L, 15 T | 70 | 10 | 1 | 12 | 0.8 | – | 80 | 1 | 9 | ranged ×1.5 | – |
| Lính súng hỏa mai | Nguyễn | I | 40 L, 10 G, 20 T, 5 S | 60 | 26 | 1 | 210 | 4.0 | 0.75 | 60 | 1 | 14 | – | 0.1, 0.2 |
| Lính súng Đàng Ngoài | Trịnh | I | 35 L, 10 G, 15 T, 5 S | 60 | 26 | 1 | 210 | 4.0 | 0.80 | 60 | 1 | 12 | – | 0.1, 0.2 |
| Cơ súng | Nguyễn | II | 50 L, 10 G, 30 T, 10 S | 65 | 28 | 1 | 220 | 3.6 | 0.85 | 60 | 1 | 16 | – | 0.1, 0.2 |
| Thổ binh | Nguyễn | I | 25 L, 10 G | 70 | 7 | 1 (+3 gần Làng/Phủ) | 14 | 1.0 | – | 66 | 1 | 6 | – | – |
| Kỵ binh | cả hai | I | 70 L, 50 T, 10 S | 140 | 14 | 3 | 14 | 1.2 | – | 115 | 1 | 18 | ranged ×1.5, siege ×1.5 | – |
| Voi chiến | cả hai | II | 200 L, 120 T | 520 | 32 | 5 | 16 | 2.0 | – | 55 | 3 | 30 | infantry ×1.5, building ×2 | – |
| Đại bác | cả hai | II | 60 G, 150 T, 100 S | 180 | 90 | 2 | 380 (min 70) | 7.5 | 1.0 (lan 48 px) | 30 | 2 | 35 | building ×2.5, wall ×3 | 1, 2 |
| Cai đội | cả hai (tự thêm) | I | 100 L, 50 T | 120 | 10 | 2 | 14 | 1.0 | – | 70 | 1 | – | – | – |
| Lính trống | cả hai (tự thêm) | I | 60 L, 20 G | 50 | 0 | 0 | – | – | – | 66 | 1 | – | – | – |

**Đơn vị thủy:**

| Đơn vị | Phe | Giá | Máu | Công | Giáp | Tầm | Nạp (s) | Tốc độ | Dân số | Luyện (s) | Ghi chú | Đạn/phát (S, D) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Thuyền chiến | Nguyễn | 150 G, 80 T, 20 S | 400 | 20 | 3 | 220 | 3.0 | 80 | 3 | 25 | Pháo mũi, bắn vào bờ; chở 10 quân | 0.5, 1 |
| Thuyền chiến Đàng Ngoài | Trịnh | 160 G, 90 T, 25 S | 520 | 20 | 4 | 220 | 3.0 | 75 | 3 | 28 | Bền hơn; chở 10 quân | 0.5, 1 |
| Ngư binh | Nguyễn | 60 G, 30 T | 150 | 10 | 1 | 160 | 2.0 | 120 | 1 | 12 | `small_ship`, large_ship ×2 | 0.05, 0.1 |
| Thuyền buôn | cả hai | 120 G, 30 T | 250 | 0 | 1 | – | – | 90 | 2 | 20 | Chở hàng tới Chợ/Cảng khác | – |
| Tàu chiến VOC | NPC (thuê) | 400 T + 2 T/phút | 1200 | 45 | 6 | 300 | 5.0 | 60 | – | – | `large_ship`, hai mạn ±60° | 0 (NPC tự lo) |
| Thợ đúc BĐN | NPC (thuê) | 300 T + 1 T/phút | – | – | – | – | – | – | – | – | Gắn vào Xưởng đúc | – |

**Công trình** (giá gốc, hệ số tăng g):

| Công trình | Phe | GĐ | Giá gốc | g | Máu | Kích thước | Xây (s) | Dân số | Quân sự? | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| Phủ chúa | cả hai | I | có sẵn | – | 4000 | 4×4 | – | +30 | Không (bị chiếm được) | Luyện dân, kho nhận mọi tài nguyên, bắn tên (10/220/2 s), lãnh thổ 20, tối đa 1 |
| Triều vua Lê | Trịnh | I | có sẵn | – | 2500 | 4×3 | – | – | Không | Danh nghĩa, tối đa 1 |
| Làng | cả hai | I | 150 G, 100 Đ | 1.4 | 1500 | 3×3 | 40 | +20 | Không | Luyện dân, kho, lãnh thổ 15 |
| Nhà | cả hai | I | 60 G, 20 Đ | 1.05 | 400 | 2×2 | 15 | +15 (Nguyễn +12) | Không | – |
| Ruộng | cả hai | I | 40 G | 1.0 | 200 | 3×3 | 10 | – | Không | 4 chỗ |
| Kho lúa | cả hai | I | 100 G | 1.2 | 600 | 2×2 | 18 | – | Không | Nhận Lúa, Gỗ |
| Mỏ | cả hai | I | 100 G, 50 Đ | 1.2 | 800 | 2×2 | 20 | – | Không | 5 chỗ (nâng +5) |
| Chợ | cả hai | I | 200 G, 100 Đ | 1.5 | 1000 | 3×3 | 30 | – | Không | S9.T01 |
| Doanh trại | cả hai | I | 200 G, 100 Đ | 1.35 | 1200 | 3×3 | 25 | – | **Có** | Giáo, đao, súng, thổ binh |
| Chuồng ngựa | cả hai | I | 200 G, 80 T | 1.35 | 1100 | 3×3 | 28 | – | Có | Kỵ binh |
| Thư phòng | cả hai | I | 250 G, 150 Đ, 100 T | 2.0 | 1000 | 3×3 | 30 | – | Không | Nghiên cứu, sang giai đoạn II |
| Cảng | cả hai | I | 200 G, 50 Đ | 1.35 | 1000 | 3×3 | 30 | – | Không | Phải giáp nước; thuyền |
| Đồn / tháp canh | cả hai | I | 100 G, 80 Đ, 20 S | 1.3 | 900 | 2×2 | 20 | – | Có | Bắn 8/240/1.5 s; chống bắt dân 10 ô; lãnh thổ 10 |
| Chuồng voi | cả hai | II | 250 G, 150 Đ, 150 T | 1.5 | 1300 | 3×3 | 32 | – | Có | Voi |
| Xưởng đúc súng | cả hai | II | 200 G, 200 Đ, 150 T, 100 S | 1.5 | 1300 | 3×3 | 35 | – | Có | Đại bác |
| Trường tập bắn | cả hai | II | 200 G, 100 Đ, 100 T | 1.5 | 1100 | 3×3 | 30 | – | Có | Cơ súng (Nguyễn), nghiên cứu hỏa lực |
| Thương điếm | cả hai | II | 300 G, 200 Đ, 200 T | 2.0 | 1000 | 3×3 | 30 | – | Không | Chỉ đặt trong 12 ô quanh điểm thương nhân trên bản đồ |
| Tào Ty | Nguyễn | II | 200 G, 100 Đ, 200 T | – | 800 | 2×2 | 25 | – | Không | Tối đa 1 |
| Lũy (mỗi ô) | Nguyễn | II | 10 G, 20 Đ | 1.0 | 1000 | 1×1 | 10 | – | Có | Quân bộ của mình đứng lên được |
| Tường thường (mỗi ô) | Trịnh | II | 10 G, 15 Đ | 1.0 | 600 | 1×1 | 8 | – | Có | – |
| Cổng | cả hai | II | 30 G, 40 Đ | 1.0 | 900 | 1×2 | 12 | – | Có | – |

**Khởi đầu đấu tự do (tài nguyên "Thường"):**
- Tài nguyên: 1000 L, 800 G, 500 Đ, 500 T, 200 S, 200 D.
- Công trình: 1 Phủ chúa (Trịnh thêm Triều vua Lê).
- Quân: 10 dân, 5 lính giáo.

Mức "Thấp" nhân ×0.5, mức "Cao" nhân ×2.
