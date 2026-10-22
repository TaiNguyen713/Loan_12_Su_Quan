# SETUP — Cài môi trường trên máy mới

Mục tiêu: sau khi đổi máy, kéo repo về và chạy lại được test, game và trang tiến độ.
Phiên bản khóa nằm ở [`docs/plan/05_VERSIONS.md`](plan/05_VERSIONS.md). Khi hai nơi lệch nhau thì file đó là chuẩn.

## 1. Đã nằm trong repo (không cần cài lại)

| Thành phần | Vị trí |
|---|---|
| Code, dữ liệu cân bằng, test | `scripts/`, `data/`, `tests/` |
| GdUnit4 v6.2.2 | `addons/gdUnit4/` (đã commit) |
| Thư viện Python của tools | `tools/requirements.txt` |
| Kế hoạch và trạng thái | `docs/plan/` |
| Script trang tiến độ | `tools/dashboard/` |

## 2. Cài ngoài repo

| Công cụ | Phiên bản | Ghi chú |
|---|---|---|
| Git | bản mới | |
| GitHub CLI (`gh`) | bản mới | chạy `gh auth login` một lần; trang tiến độ và PR dùng nó |
| Python | 3.12.x | |
| Godot Standard (không phải .NET) | **4.7.2-stable** | tải ở github.com/godotengine/godot/releases/tag/4.7.2-stable, giải nén vào thư mục riêng **ngoài repo**; phải đúng 4.7.2 |
| Export templates | **4.7.2-stable** (khoảng 1,28 GB) | chỉ cần khi build APK hoặc bản desktop trên máy này (Editor → Manage Export Templates); CI vẫn build được khi máy không có |
| JDK 17 (Temurin) và Android SDK | theo `05_VERSIONS.md` | chỉ cần để build APK trên máy này; chưa từng chạy thử ở máy cũ, APK mới chỉ build qua CI |

## 3. Các bước

```bash
git clone https://github.com/TaiNguyen713/Loan_12_Su_Quan.git
cd Loan_12_Su_Quan
git checkout feat/S2-T04-avoidance
pip install -r tools/requirements.txt
```

Nhánh đang làm xem bằng `gh pr list`. Các PR là bản nháp xếp chồng nhau: PR sau lấy nhánh của PR trước làm base.

Mở dự án lần đầu để Godot tạo thư mục `.godot/` (thư mục này không được commit):

```bash
godot --headless --path . --import
```

Ở đây `godot` là đường dẫn tới file thực thi Godot 4.7.2 vừa giải nén.

## 4. Kiểm tra máy đã sẵn sàng

Test GdUnit4 (phải báo 0 lỗi):

```bash
godot --headless --path . -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --add res://tests --ignoreHeadlessMode
```

Test và lint của tools:

```bash
python -m pytest -q tools/tests
```

```bash
python -m ruff check tools
```

```bash
python tools/ci/version_guard.py
```

Chạy thử game trên PC: mở dự án trong Godot rồi nhấn F5 (cảnh `scenes/boot`). Chuột trái ra lệnh đi cho quân phe 0.

## 5. Giữ tiến độ khi đổi máy

- Tiến độ nằm ở git và GitHub: nhánh, commit, PR. Trước khi rời máy cũ, kiểm tra `git status` sạch và mọi nhánh đã push.
- Phiên Claude Code không chuyển theo máy. Trên máy mới, mở thư mục repo và yêu cầu đọc `docs/plan/01_ROADMAP.md` cùng vài commit gần nhất.
- Roadmap chỉ là kế hoạch, không tự ghi trạng thái. Trạng thái từng task nằm trong bảng `S` ở đầu `tools/dashboard/build_data.py`; sửa bảng đó khi một task đổi trạng thái.

## 6. Làm mới trang tiến độ

Trang là artifact riêng tư trên tài khoản Claude, xem được từ điện thoại. Mã nguồn nằm ở `tools/dashboard/`:

- `build_data.py` đọc roadmap, ước lượng, git, `gh` và log test, rồi ghi 7 file JSON.
- `index.html` là trang hiển thị.

Bước 1, chạy test và lưu log:

```bash
godot --headless --path . -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --add res://tests --ignoreHeadlessMode > build/gdunit.log
```

Bước 2, sinh dữ liệu:

```bash
python tools/dashboard/build_data.py build/dash build/gdunit.log
```

Bước 3: tải các file trong `build/dash` lên artifact và cập nhật các tài liệu `datasets/*`. Bước này cần một phiên Claude Code, và artifact thuộc tài khoản của người tạo; trên máy mới hãy nhờ Claude đọc artifact hiện có trước khi cập nhật.

Các số hiệu năng (`perf_*`, `avoid_*`) trong `build_data.py` được ghi tay từ lần đo bằng script Godot; cập nhật chúng khi đo lại.
