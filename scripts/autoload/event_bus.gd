extends Node
## Cổng sự kiện giữa sim, UI và âm thanh. Chỉ khai báo signal, không có logic (S1.T02).
## Thêm signal mới phải cập nhật bảng trong docs/plan/algorithms/ALGO_P0_P1.md (S1.T02).

signal scene_leaving

signal unit_spawned(id: int, team: int, type: StringName)
signal unit_died(id: int, team: int, type: StringName, killer_id: int)
signal building_placed(id: int, team: int, type: StringName)
signal building_completed(id: int, team: int, type: StringName)
signal building_destroyed(id: int, team: int, type: StringName)

## res theo thứ tự Lúa, Gỗ, Đá, Tiền, Sắt, Diêm tiêu.
signal resources_changed(team: int, res: PackedFloat32Array)
signal selection_changed(ids: PackedInt32Array)
signal command_issued(cmd: Command)

signal alert_raised(kind: StringName, pos: Vector2, entity_id: int)
signal capture_warning(id: int, from_team: int, to_team: int)
signal entity_captured(id: int, from_team: int, to_team: int)

signal era_changed(team: int, era: int)
signal relation_changed(power: StringName, team: int, value: float)
signal market_price_changed(res: int, price: float)
signal morale_broken(id: int)
signal research_done(team: int, id: StringName)
signal objective_updated(id: StringName, state: int)
signal match_ended(winner_team: int, reason: StringName)
