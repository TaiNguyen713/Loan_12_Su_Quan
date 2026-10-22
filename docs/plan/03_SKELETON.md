# 03 — Skeleton dự án

> Các thư mục bên dưới đã được tạo sẵn và chỉ chứa `.gitkeep`, chưa có code.
> Cột chú thích bên phải ghi **task** trong [01_ROADMAP.md](01_ROADMAP.md) sẽ đưa nội dung vào thư mục đó.

## 1. Cây thư mục

```
Loan_12_Su_Quan/
├── project.godot                 # cấu hình Godot                              S1.T01
├── export_presets.cfg            # preset Android                              S0.T04, S20.T04
├── icon.svg                                                                    S11.T01
├── README.md                     # hướng dẫn build/chạy                         S0.T03
├── .gitignore · .gitattributes                                                 S0.T03
├── .github/
│   ├── workflows/                # ci.yml, nightly.yml, release.yml            S0.T04, S10.T04, S20.T04
│   └── ISSUE_TEMPLATE/                                                         S0.T03
│
├── addons/                       # gdUnit4 6.2.2, limboai 1.8.1, sentry 2.4.0  S0.T05, S3.T04, S20.T02
│
├── assets/                       # file nhị phân → Git LFS
│   ├── art/
│   │   ├── units/{trinh,nguyen,common}/                                        S12.T01–T02
│   │   ├── buildings/{trinh,nguyen,common}/                                    S12.T03
│   │   ├── terrain/              # cỏ, rừng, sông, cầu, bến phà, biển           S2.T01
│   │   ├── props/                # cây, mỏ, ruộng                              S2.T01
│   │   ├── fx/                                                                 S5.T04
│   │   ├── ui/{icons,portraits,frames}/                                        S4.T04, S14.T02
│   │   └── source/               # .blend/.kra gốc                             S11.T02
│   ├── audio/{music,sfx,voice,ambience}/                                       S12.T04
│   ├── fonts/                    # Be Vietnam Pro, Noto Sans                   S19.T04
│   └── shaders/                  # fog, màu phe, ghost, đêm                    S7.T01, S11.T04, S16.T02
│
├── data/                         # .tres sinh từ data/balance/ — không sửa tay
│   ├── balance/                  # CSV gốc + CHANGELOG cân bằng                S1.T04, S12.T02
│   ├── factions/                 # FactionDef (Trịnh, Nguyễn)                  S1.T03
│   ├── units/                                                                  S1.T03
│   ├── buildings/                                                              S1.T03
│   ├── research/                 # 40 ResearchDef + R14 sang giai đoạn II      S8.T02–T03
│   ├── formations/                                                             S6.T01
│   ├── commanders/               # nhân vật chỉ huy (chỉ trong chiến dịch)     S15.T04
│   ├── ai_profiles/                                                            S10.T03
│   ├── maps/                                                                   S2.T02
│   ├── scenarios/                # nhiệm vụ, trận lịch sử                      S14.T01, S15–S17
│   ├── campaigns/                # chiến dịch Trịnh, Nguyễn                    S14.T05
│   └── encyclopedia/                                                           S17.T01
│
├── localization/                 # strings.csv (vi, en)                        S19.T04
│
├── scenes/
│   ├── boot/ · menus/ · campaign/ · match/                                     S1.T02, S10.T05, S14.T05
│   ├── entities/{units,buildings,resources,projectiles}/                       S1.T01, S5.T02
│   ├── ui/{hud,panels,widgets}/  # HUD 844×390                                 S4.T04
│   └── fx/                                                                     S5.T04
│
├── scripts/
│   ├── autoload/                 # event_bus, scene_router, session, settings, save_manager, audio_manager, telemetry
│   ├── core/                     # object_pool, spatial_hash, fixed_tick, rng_service, command_queue
│   ├── defs/                     # UnitDef, BuildingDef, ResearchDef, FactionDef, ScenarioDef, …   S1.T03
│   ├── sim/
│   │   ├── economy/              # khai thác, mỏ, sản xuất, dân số, upkeep, đạn dược, thuế đinh   S4
│   │   ├── territory/            # lãnh thổ, khẩn hoang                        S4.T06
│   │   ├── combat/                                                             S5
│   │   ├── pathing/              # A*, flow field, lớp đất/nước/theo phe       S2.T03–T04, S8.T01
│   │   ├── ferry/                # bến phà, cầu                                S13.T02
│   │   ├── formations/           # Đội, 3 hình, bổ sung                        S6.T01–T02
│   │   ├── morale/                                                             S6.T03
│   │   ├── fog/                                                                S7
│   │   ├── research/             # modifier stack, giai đoạn                   S8.T02–T03
│   │   ├── capture/                                                            S8.T04
│   │   ├── market/               # chợ giá dùng chung                          S9.T01
│   │   ├── trade/                # cảng, thuyền buôn, Tào Ty                   S9.T02
│   │   ├── diplomacy/            # thương điếm, quan hệ VOC/BĐN, đánh thuê     S9.T03–T04
│   │   ├── politics/             # lưỡng đầu chế                               S9.T05
│   │   ├── supply/               # dịch bệnh                                   S13.T04
│   │   ├── triggers/                                                           S14.T01
│   │   └── victory/              # tiêu diệt, chiếm thủ phủ, đình chiến        S10.T05
│   ├── entities/                 # Unit, Building, ResourceNode, Ship, Ferry, Bridge, Commander
│   ├── commands/                 # Move, AttackMove, Hold, Rest, FireToggle, Reinforce, Guard, SetShape, Waypoints   S3.T03, S6.T04
│   ├── ai/{strategic,tactical,behaviors}/                                      S10, S13.T03
│   ├── input/                    # gesture_recognizer, selection, groups, dispatch   S3.T01–T03
│   ├── render/                   # camera, unit_renderer, fog_view, overlay, minimap   S2.T05–T06, S11.T04, S18.T03
│   ├── ui/                       # HUD, thanh trên, bảng lệnh, lưới Xây, thẻ cảnh báo, chợ, thương điếm
│   ├── campaign/                                                               S14.T05
│   ├── platform/                 # Android: back, pause, safe area             S20
│   └── net/                      # (Phase 6) nhiều người chơi
│
├── native/                       # GDExtension C++                             S18.T02
├── tests/{unit,integration,scene,perf,ai,fixtures,manual}/
├── tools/{balance,data_validator,asset_pipeline,ci,tests}/
├── docs/{plan,plan/algorithms,test,adr,art,design/missions,perf}/
└── build/                        # (gitignore)
```

## 2. Quy tắc phụ thuộc giữa các lớp

| Lớp | Được phép gọi | Không được gọi |
|---|---|---|
| `scripts/defs` | — | mọi lớp khác |
| `scripts/core` | `defs` | `sim`, `render`, `ui` |
| `scripts/sim/*`, `entities`, `commands` | `core`, `defs`, `EventBus` | `render`, `ui`, `input`, API vẽ |
| `scripts/ai` | `sim` (chỉ đọc), `commands` | Sửa trạng thái sim |
| `scripts/input` | `commands`, `sim` (chỉ đọc) | Sửa trạng thái sim |
| `scripts/render`, `ui` | `sim` (chỉ đọc), `EventBus`, `input` | Sửa trạng thái sim |

Các module `sim/market`, `sim/trade`, `sim/diplomacy`, `sim/politics` chỉ giao tiếp với nhau qua EventBus và các truy vấn chỉ đọc. Lint ở S1.T01 kiểm tra quy tắc này (test `S1.T01-TC3`).

## 3. Hiện trạng

Repo hiện chỉ có tài liệu và thư mục rỗng. Các file ở thư mục gốc được tạo trong task ghi bên cạnh.

## 4. Quy ước đặt tên

- File và thư mục: `snake_case`. Class: `PascalCase`. Hằng số: `UPPER_SNAKE`.
- Signal ở thì quá khứ (`unit_died`, `era_changed`).
- Resource: `<loai>_<id>.tres`, ví dụ `unit_co_sung.tres`, `research_r14_giai_doan_2.tres`.
- Nhánh: `feat/S09.T01-market`. Commit: `feat(sim): … (S09.T01)`.
