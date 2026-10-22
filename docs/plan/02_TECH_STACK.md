# 02 — Công nghệ, framework & kiến trúc

> Liên quan: [01_ROADMAP.md](01_ROADMAP.md) · [03_SKELETON.md](03_SKELETON.md) · [../test/TEST_STRATEGY.md](../test/TEST_STRATEGY.md)

## 1. Bảng công nghệ chính

| Mảng | Lựa chọn | Lý do | Phương án thay thế đã cân nhắc |
|---|---|---|---|
| Engine | **Godot 4.7.2-stable** (phiên bản đã khóa, toàn bộ bảng ở [05_VERSIONS.md](05_VERSIONS.md)) | Miễn phí, nhẹ, xuất Android tốt, scene/script dạng text dễ review & diff | Unity (phí/điều khoản runtime, nặng), Unreal (quá nặng cho mobile 2D), Defold (hệ sinh thái nhỏ) |
| Ngôn ngữ | **GDScript có kiểu tĩnh** (typed) | Lặp nhanh, tích hợp editor, hot-reload | C# (.NET trên Android còn hạn chế, APK to hơn) |
| Hot path hiệu năng | **GDExtension C++ (godot-cpp)** — chỉ khi profiling chứng minh cần (S18) | Flow field, tách nhóm (separation), fog cho 800 quân | Giữ GDScript + tối ưu thuật toán |
| Renderer | **GL Compatibility** (OpenGL ES 3.0) | Chạy được trên máy Android tầm thấp, 2D không cần Vulkan | Mobile (Vulkan) — bật thử ở S18 cho máy cao cấp |
| Bản đồ | **TileMapLayer** (isometric) + terrain sets | Có sẵn trong Godot 4.3+, có editor để vẽ map tay | Vẽ bằng `_draw()` (chỉ dùng cho spike S0.T06) |
| Tìm đường | **AStarGrid2D** (đường đơn lẻ) + **Flow field tự viết** (nhóm lớn) + **spatial hash** | A* đủ cho vài quân; flow field O(1)/quân khi cả đạo quân đi chung đích | NavigationServer2D + NavigationAgent2D (RVO tốt nhưng đắt khi >200 agent) |
| Né tránh cục bộ | Boids separation trên spatial hash; đánh giá thêm RVO của NavigationServer2D | Rẻ, kiểm soát được | ORCA tự viết |
| Máy trạng thái quân & AI | **LimboAI** (Behavior Tree + HSM, GDExtension, hỗ trợ Android) | Có editor trực quan, debugger, nhanh hơn BT viết bằng GDScript | Beehave (thuần GDScript, chậm hơn), FSM tự viết |
| AI chiến lược | **Utility AI** (chấm điểm hành động) chạy trên Blackboard của LimboAI | Ra quyết định linh hoạt theo tình huống, dễ chỉnh độ khó | Kịch bản build order cố định |
| Dữ liệu game | **Custom Resource (.tres)**: `UnitDef`, `BuildingDef`, … · nguồn gốc là **CSV** cân bằng | Có kiểu, sửa được trong Inspector, CSV dễ chỉnh hàng loạt | JSON thuần (mất kiểu), Google Sheets API |
| Công cụ dữ liệu | **Python 3.12**: `pandas`, `pytest`, `matplotlib` | Chuyển CSV → .tres, kiểm tra dữ liệu, tính bảng DPS/TTK | Viết EditorPlugin trong Godot |
| Đồ họa | **Blender** (dựng 3D → render sẵn 8 hướng) + script `bpy`, **Aseprite/Krita** chỉnh tay | Giống phong cách isometric của Cossacks, 1 model → mọi hướng và mọi animation | Vẽ tay từng frame (quá tốn công) |
| Hoạt ảnh/hiển thị quân | `AnimatedSprite2D` (giai đoạn đầu) → **MultiMeshInstance2D + shader chọn frame** (S18) | MultiMesh vẽ hàng trăm quân trong 1 draw call | Sprite riêng cho từng quân |
| Hiệu ứng | `GPUParticles2D` / `CPUParticles2D` (CPU trên máy yếu), shader `.gdshader` | Khói súng, nổ, bụi | Sprite sheet có sẵn |
| Âm thanh | Godot Audio (AudioStreamPlayer2D, Audio Bus), file `.ogg` | Đủ dùng, không thêm phí license | FMOD (cấu hình phức tạp) |
| Giao diện | Godot Control + **Theme** dùng chung, font **Be Vietnam Pro / Noto Sans** (OFL, đủ dấu tiếng Việt) | Hiển thị đúng dấu, co giãn theo màn hình | — |
| Đa ngôn ngữ | `TranslationServer` + file CSV/PO (vi, en) | Có sẵn, dùng POEdit được | — |
| Lưu game | `FileAccess` + JSON có `version` + migrator; thư mục `user://` | Đọc được, dễ debug, nâng cấp schema được | `ResourceSaver` (dễ vỡ khi đổi class) |
| Kiểm thử | **GdUnit4** (unit, mock, scene runner, xuất JUnit) · **pytest** cho tool Python | GdUnit4 có GitHub Action chính thức và scene runner để test UI/input | GUT (không có scene runner tốt bằng) |
| Lint/format | **gdtoolkit** (`gdlint`, `gdformat`) · `ruff` cho Python | Code thống nhất, chặn lỗi đơn giản trong CI | — |
| CI/CD | **GitHub Actions**: `gdUnit4-action`, image Docker `barichello/godot-ci` để export headless | Miễn phí cho repo cá nhân, export APK/AAB tự động | GitLab CI, Codemagic |
| Quản lý mã nguồn | Git + **Git LFS** (png, wav, ogg, blend, kra) · trunk-based + nhánh tính năng ngắn · Conventional Commits | Asset lớn không làm phình repo | Perforce (thừa với nhóm nhỏ) |
| Theo dõi lỗi/crash | **Sentry Godot SDK** (hỗ trợ Android) + **Play Console Android vitals** | Crash GDScript & native, breadcrumbs | Firebase Crashlytics (plugin Godot do cộng đồng tự duy trì) |
| Profiling | Godot Profiler/Monitors, **Android GPU Inspector**, **Perfetto**, `adb shell dumpsys gfxinfo` | Đo CPU/GPU/nhiệt trên máy thật | — |
| Test trên thiết bị | Máy thật (ma trận bên dưới) + **Firebase Test Lab / Play pre-launch report** | Bắt crash trên nhiều dòng máy | Chỉ dùng emulator (không đáng tin cho GPU) |
| Phát hành | Android App Bundle (**AAB**), Play App Signing, kênh Internal → Closed → Production | Bắt buộc với Google Play | APK side-load (chỉ dùng nội bộ) |
| Dịch vụ Play (tùy chọn) | Plugin **GodotGooglePlayBilling** (nếu bán DLC chiến dịch), Play Games Services (thành tích) | Plugin chính thức | — |
| Quản lý dự án | GitHub Projects (board theo sprint), Issues gắn ID task (`S03.T02`) | Gắn liền với repo và PR | Jira/Linear |

## 2. Thiết bị mục tiêu

| Hạng | Ví dụ | Mục tiêu |
|---|---|---|
| Thấp (min-spec) | Snapdragon 680 / Helio G85, 4 GB RAM, Android 10 | Trần 400 quân, ≥ 30 FPS (p50) |
| Trung bình | Snapdragon 7 Gen 1 / Dimensity 1080, 6–8 GB RAM | Trần 800 quân, ≥ 30 FPS (p50) |
| Cao | Snapdragon 8 Gen 2+ | Trần 800 quân, ≥ 45 FPS (p50) |
| Tablet | Samsung Tab A8 / A9+ | Bố cục UI cho màn hình lớn |

`minSdk` = 24 (Android 7). `targetSdk` theo yêu cầu hiện hành của Google Play lúc phát hành (kiểm tra lại ở S20). Hạng máy được tự phân khi khởi động (ALGO S18.T01).

## 3. Kiến trúc tổng thể

```
┌──────────────────────────── Presentation (render mỗi frame) ───────────────────────────┐
│ scenes/ · scripts/render (camera, unit renderer, fog shader, overlay) · scripts/ui      │
└──────────────▲──────────────────────────────────────────────────────▲──────────────────┘
               │ đọc state (nội suy giữa 2 tick)                       │ signal qua EventBus
┌──────────────┴──────────── Input & Command ──────────────────────────┴──────────────────┐
│ scripts/input: Gesture → Selection → Command (Move/Attack/Gather/Build/Formation…)     │
│ Lệnh là object dữ liệu → đưa vào CommandQueue (để replay/test, sau này dùng cho mạng)  │
└──────────────┬─────────────────────────────────────────────────────────────────────────┘
               │ apply ở đầu mỗi tick
┌──────────────▼──────────── Simulation (tick cố định 20 Hz) ─────────────────────────────┐
│ scripts/sim: economy · territory · combat · pathing · ferry · formations · morale · fog │
│              research · capture · market · trade · diplomacy · politics · victory       │
│ scripts/entities: Unit/Building/Resource (dữ liệu + component)                          │
│ scripts/ai: chiến lược (utility) · chiến thuật (BT LimboAI) — chỉ ra lệnh như người chơi│
└──────────────┬─────────────────────────────────────────────────────────────────────────┘
               │ chỉ đọc
┌──────────────▼──────────── Data ────────────────────────────────────────────────────────┐
│ data/*.tres (UnitDef, BuildingDef, ResearchDef, FactionDef, ScenarioDef) ← tools/ từ CSV    │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

**Nguyên tắc:**
1. **Tách sim khỏi render.** Sim chạy tick cố định (20 Hz), render nội suy vị trí. Nhờ vậy test headless được và hành vi không phụ thuộc FPS.
2. **Mọi hành động đều là `Command`.** Người chơi, AI và (sau này) mạng đều đi chung một đường → replay được, test được.
3. **Data-driven.** Chỉ số và kịch bản nằm trong `data/`, code không chứa số cân bằng.
4. **RNG có seed theo trận.** Cùng seed + cùng chuỗi lệnh → cùng kết quả (tiền đề cho replay; multiplayer lockstep để Phase 6).
5. **Giao tiếp lỏng qua `EventBus`** (autoload với các signal) giữa sim ↔ UI ↔ audio.
6. **Object pooling** cho đạn, hiệu ứng, xác quân.

## 4. Danh sách ADR cần viết (thư mục `docs/adr/`)

| ADR | Chủ đề | Sprint |
|---|---|---|
| ADR-001 | Chọn engine Godot + GDScript typed | S0 |
| ADR-002 | Renderer GL Compatibility, chiến lược hiển thị isometric pre-render | S0 |
| ADR-003 | Tách sim tick cố định / render nội suy | S1 |
| ADR-004 | Định dạng dữ liệu: CSV → Custom Resource | S1 |
| ADR-005 | Tìm đường: A* + flow field + spatial hash (so với NavigationServer2D) | S2 |
| ADR-006 | LimboAI cho FSM quân và AI | S3 |
| ADR-007 | Định dạng save & cách nâng cấp phiên bản | S19 |
| ADR-008 | GDExtension C++ cho hot path (dựa trên kết quả profiling) | S18 |
| ADR-009 | Mô hình kinh doanh (miễn phí / trả phí / DLC chiến dịch) | S20 |
