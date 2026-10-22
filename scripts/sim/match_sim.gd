class_name MatchSim
extends RefCounted
## Mô phỏng một trận: bản đồ, tìm đường, đơn vị, hàng đợi lệnh và đồng hồ 20 Hz.
## Hiện mới có di chuyển (S2); chiến đấu, kinh tế… thêm vào các sprint sau.

const MOVE_COMMAND: StringName = &"move"
## Khoảng cách giữa các chỗ đứng của nhóm quân quanh đích.
const SLOT_SPACING: float = 14.0
const GOLDEN_ANGLE: float = 2.39996323

var grid: GridData
var pathfinder: Pathfinder
var clock := SimClock.new()
var commands := CommandQueue.new()
var units: Array[Unit] = []
## "A*" hoặc "flow field": cách tìm đường của lệnh di chuyển gần nhất (hiển thị cho dev).
var last_move_mode: String = ""

var _next_id: int = 1


func setup(rng: RandomNumberGenerator, size: Vector2i = Vector2i(128, 96)) -> void:
	setup_with_grid(MapGen.generate_valid(rng, size))


func setup_with_grid(p_grid: GridData) -> void:
	grid = p_grid
	pathfinder = Pathfinder.new(grid)


func spawn_unit(team: int, position: Vector2, speed: float = 66.0) -> Unit:
	var unit := Unit.new()
	unit.id = _next_id
	_next_id += 1
	unit.team = team
	unit.position = position
	unit.previous_position = position
	unit.speed = speed
	units.append(unit)
	return unit


## Rải `count` quân quanh `center` theo hình xoắn ốc, chỉ đặt lên ô đi được.
func spawn_group(team: int, count: int, center: Vector2) -> Array[Unit]:
	var spawned: Array[Unit] = []
	for slot in _slots(center, count * 3):
		if spawned.size() >= count:
			break
		if grid.point_walkable(slot):
			spawned.append(spawn_unit(team, slot))
	return spawned


## Đẩy lệnh di chuyển vào hàng đợi; có hiệu lực từ tick kế tiếp.
func issue_move(team: int, unit_ids: PackedInt32Array, target: Vector2) -> Command:
	var cmd := Command.new()
	cmd.type = MOVE_COMMAND
	cmd.team = team
	cmd.unit_ids = unit_ids
	cmd.target_pos = target
	commands.push(cmd, clock.tick)
	return cmd


## Một tick: tăng đồng hồ, áp dụng lệnh đến hạn, rồi di chuyển. Trả về các lệnh vừa áp dụng.
func step() -> Array[Command]:
	for unit in units:
		unit.previous_position = unit.position
	clock.advance()
	var applied := commands.pop_due(clock.tick)
	for cmd in applied:
		_apply(cmd)
	MoveSystem.step(units, grid, SimClock.DT)
	return applied


func find_unit(id: int) -> Unit:
	for unit in units:
		if unit.id == id:
			return unit
	return null


func snapshot() -> Dictionary:
	var entities: Array = []
	for unit in units:
		(
			entities
			. append(
				{
					"id": unit.id,
					"x": unit.position.x,
					"y": unit.position.y,
					"hp": 1.0,
					"state": 1 if unit.moving else 0,
					"team": unit.team,
				}
			)
		)
	return {"tick": clock.tick, "entities": entities}


func _apply(cmd: Command) -> void:
	if cmd.type == MOVE_COMMAND:
		_apply_move(cmd)


func _apply_move(cmd: Command) -> void:
	var movers: Array[Unit] = []
	var centroid := Vector2.ZERO
	for id in cmd.unit_ids:
		var unit := find_unit(id)
		if unit != null:
			movers.append(unit)
			centroid += unit.position
	if movers.is_empty():
		return
	centroid /= movers.size()

	var slots := _slots(cmd.target_pos, movers.size())
	var use_flow := pathfinder.should_use_flow(movers.size(), centroid.distance_to(cmd.target_pos))
	last_move_mode = "flow field" if use_flow else "A*"
	var field: FlowField = null
	if use_flow:
		field = pathfinder.flow_field(cmd.target_pos, movers[0].water, movers[0].large)
	for i in movers.size():
		var unit := movers[i]
		var slot := _walkable_slot(slots[i], unit)
		unit.stop()
		unit.destination = slot
		if use_flow:
			unit.flow = field
		else:
			unit.path = pathfinder.find_path(unit.position, slot, unit.water, unit.large)
			unit.path_index = 0
		unit.moving = use_flow or not unit.path.is_empty()


func _walkable_slot(slot: Vector2, unit: Unit) -> Vector2:
	if grid.point_walkable(slot, unit.water, unit.large):
		return slot
	var cell := grid.nearest_walkable(grid.cell_of(slot), 12, unit.water, unit.large)
	return grid.cell_center(cell) if cell.x >= 0 else slot


func _slots(center: Vector2, count: int) -> Array[Vector2]:
	var slots: Array[Vector2] = []
	for i in count:
		var radius := SLOT_SPACING * sqrt(float(i))
		slots.append(center + Vector2.from_angle(i * GOLDEN_ANGLE) * radius)
	return slots
