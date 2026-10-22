# 05 — Chốt phiên bản công cụ & thư viện

> Kiểm tra ngày **22/10/2026** từ trang Releases chính thức (GitHub, Docker Hub, PyPI).
> Đây là **bộ phiên bản khóa cho Phase 0 – Phase 2 (S0 – S10)**. Chỉ được nâng cấp theo quy trình ở mục 4.

## 1. Bộ phiên bản khóa

| Thành phần | Phiên bản khóa | Phát hành | Tương thích | Nguồn tải |
|---|---|---|---|---|
| **Godot Engine** (Standard, không phải .NET) | **4.7.2-stable** | 18/08/2026 | — | github.com/godotengine/godot/releases/tag/4.7.2-stable |
| Android export templates | **4.7.2-stable** (bắt buộc trùng engine) | 18/08/2026 | Godot 4.7.2 | Editor → Manage Export Templates |
| **GdUnit4** (addon test) | **v6.2.2** | 07/10/2026 | Bảng tương thích chính thức ghi v6.2.x hỗ trợ tới Godot 4.7.1. Với 4.7.2 (bản patch) cần xác nhận ở S0.T05 (xem mục 3) | github.com/MikeSchulze/gdUnit4/releases/tag/v6.2.2 |
| GdUnit4 GitHub Action | **MikeSchulze/gdUnit4-action@v1.3.2** | 28/06/2026 | GdUnit4 v6.x | Marketplace "gdunit4-test-runner-action" |
| **LimboAI** (GDExtension) | **v1.8.1** | 20/08/2026 | Được build cho Godot **4.7.2-stable** | github.com/limbonaut/limboai/releases/tag/v1.8.1 — dùng bản **GDExtension**, không dùng bản module |
| **Sentry Godot SDK** | **2.4.0** | 21/10/2026 | Godot ≥ 4.5; Android arm64/arm32/x86_64/x86 | github.com/getsentry/sentry-godot/releases/tag/2.4.0 |
| Docker image cho CI | **barichello/godot-ci:4.7.2** | — | Godot 4.7.2 | hub.docker.com/r/barichello/godot-ci |
| gdtoolkit (gdlint/gdformat) | **4.5.0** (`pip install "gdtoolkit==4.5.0"`) | 09/10/2025 | Ngữ pháp GDScript 4 (xem rủi ro ở mục 3) | pypi.org/project/gdtoolkit |
| Python (cho `tools/`) | **3.12.x** | — | — | python.org |
| pytest / pandas / matplotlib / ruff / Pillow | Khóa trong `tools/requirements.txt` bằng `pip-compile` ở S1.T04 | — | Python 3.12 | PyPI |
| godot-cpp (chỉ dùng từ S18) | Nhánh **4.5** (nhánh 4.x mới nhất hiện có) | — | GDExtension tương thích tiến: build bằng API 4.5 vẫn chạy trên Godot 4.7 | github.com/godotengine/godot-cpp |
| JDK (build Android) | **17** (Temurin) | — | Godot 4.x Android | adoptium.net |
| Android SDK | Platform-tools, Build-tools và SDK Platform theo **trang "Exporting for Android" của Godot 4.7** | — | — | Android Studio SDK Manager |
| Blender (pipeline đồ họa) | **4.x LTS mới nhất** tại thời điểm S0.T07, ghi lại số cụ thể vào mục 5 | — | Script `bpy` | blender.org |

> Các dòng ghi "theo trang của Godot" hoặc "LTS mới nhất" phải được người làm S0.T03/S0.T07 điền **số phiên bản cụ thể** vào mục 5, sau đó coi như đã khóa.

## 2. Ghi phiên bản ở đâu (một nguồn duy nhất)

| Nơi | Nội dung |
|---|---|
| `project.godot` | `config/features=PackedStringArray("4.7", "GL Compatibility")` |
| `.github/workflows/*.yml` | `env: GODOT_VERSION: "4.7.2"`, image `barichello/godot-ci:4.7.2`, action `gdUnit4-action@v1.3.2` |
| `addons/README.md` | Bảng: addon · phiên bản · ngày cài · link release |
| `tools/requirements.txt` | Phiên bản Python đã khóa (sinh bằng `pip-compile`) |
| `.tool-versions` (tùy chọn) | `python 3.12.x`, `java temurin-17` |

CI có bước **version-guard**: đọc `GODOT_VERSION` trong workflow, đối chiếu với `config/features` và phiên bản ghi trong `addons/*/plugin.cfg`. Lệch nhau thì fail.

## 3. Rủi ro tương thích & việc cần xác nhận ở S0

| # | Rủi ro | Cách xác nhận (task S0.T05) | Phương án dự phòng |
|---|---|---|---|
| R1 | Bảng tương thích của GdUnit4 v6.2.x mới ghi tới **4.7.1**, chưa ghi 4.7.2 | Chạy test mẫu và scene runner trên 4.7.2 headless, trên cả Windows và Linux CI | Hạ engine xuống **4.7.1-stable** (đổi engine, templates và image `godot-ci:4.7.1`); LimboAI v1.8.0 hỗ trợ 4.7 |
| R2 | gdtoolkit 4.5.0 (10/2025) có thể chưa hiểu cú pháp GDScript mới thêm ở Godot 4.6–4.7 | Chạy `gdlint` trên code mẫu có typed loop, lambda nhiều dòng, `@abstract`… | Thêm rule bỏ qua cho file đó, hoặc tạm chỉ chạy `gdformat --check`. Theo dõi bản gdtoolkit mới |
| R3 | LimboAI là GDExtension, cần đúng binary Android trong gói addon | Export APK debug, mở scene có `BTPlayer` trên máy thật | Dùng FSM tự viết (đã có thiết kế ở ALGO S3.T04), BT tạm thời viết bằng GDScript |
| R4 | Sentry SDK cần plugin Android và `use_gradle_build` (kiểm tra theo tài liệu Sentry khi tích hợp ở S20) | Crash thử ở S20.T02-TC1 | Tạm tắt Sentry và chỉ dùng Android vitals |
| R5 | godot-cpp chưa có nhánh 4.7 | Build thử 1 lớp trống ở đầu S18 | Dùng nhánh 4.5 (tương thích tiến) hoặc `master` gắn theo commit cụ thể |

Kết quả xác nhận R1–R3 ghi vào `docs/plan/spike_report.md` ở cuối S0. **Nếu R1 fail, toàn bộ bảng mục 1 đổi sang Godot 4.7.1** trước khi bắt đầu S1.

## 4. Quy trình nâng cấp phiên bản

1. **Chỉ nâng cấp ở sprint đầu mỗi phase** (S1, S5, S11, S18), không nâng cấp giữa sprint. Ngoại lệ là bản vá bảo mật hoặc crash.
2. Bản vá cùng nhánh (ví dụ 4.7.2 → 4.7.3): được phép nếu CI xanh và benchmark perf không chậm hơn quá 5%.
3. Bản nâng cấp minor của engine (ví dụ 4.7 → 4.8): bắt buộc phải có:
   - GdUnit4, LimboAI và Sentry đều có bản hỗ trợ chính thức cho engine mới;
   - một nhánh `chore/upgrade-godot-4.8` chạy toàn bộ test U/I/SC cùng AI soak 50 trận;
   - ghi lại thay đổi API đáng chú ý vào ADR.
4. **Khóa engine từ M4 (S20):** từ thời điểm này tới khi ra mắt 1.0 chỉ nhận bản vá cùng nhánh.

## 5. Nhật ký phiên bản thực tế (người làm task tự điền)

| Ngày | Thành phần | Phiên bản | Người cập nhật | Lý do |
|---|---|---|---|---|
| 22/10/2026 | Bộ phiên bản khóa ban đầu | như mục 1 | — | Tạo tài liệu |
| | Android SDK Platform / Build-tools | | | S0.T03 |
| | Blender | | | S0.T07 |
