class_name MoveSystem
extends RefCounted
## Di chuyển đơn vị theo đường A* hoặc theo flow field mỗi tick (S2.T03).
## Né tránh giữa các quân nằm ở Avoidance, phát hiện kẹt ở StuckWatch.

## Cách đích bao nhiêu ô (Chebyshev) thì thôi theo flow field, đi thẳng tới chỗ đứng riêng.
const FLOW_FINAL_APPROACH_CELLS: int = 2
const WAYPOINT_REACHED: float = 6.0


static func step(units: Array[Unit], grid: GridData, dt: float) -> void:
	for unit in units:
		if unit.moving:
			_step_unit(unit, grid, dt)


static func _step_unit(unit: Unit, grid: GridData, dt: float) -> void:
	var travel := unit.speed * dt
	if unit.uses_flow():
		_follow_flow(unit, grid, travel)
	else:
		_follow_path(unit, grid, travel)


static func _follow_path(unit: Unit, grid: GridData, travel: float) -> void:
	if unit.path_index >= unit.path.size():
		unit.stop()
		return
	var target := unit.path[unit.path_index]
	var last := unit.path_index == unit.path.size() - 1
	if unit.position.distance_to(target) <= maxf(travel, 1.0 if last else WAYPOINT_REACHED):
		if last:
			unit.position = target
			unit.stop()
			unit.arrived = true
		else:
			unit.path_index += 1
		return
	_move_toward(unit, grid, target, travel)


static func _follow_flow(unit: Unit, grid: GridData, travel: float) -> void:
	var cell := grid.cell_of(unit.position)
	var field := unit.flow
	var to_destination := unit.position.distance_to(unit.destination)
	var near := (
		maxi(
			absi(cell.x - grid.cell_of(unit.destination).x),
			absi(cell.y - grid.cell_of(unit.destination).y)
		)
		<= FLOW_FINAL_APPROACH_CELLS
	)
	if near or field.direction_index(cell) == FlowField.NONE:
		if to_destination <= maxf(travel, 1.0):
			unit.position = unit.destination
			unit.stop()
			unit.arrived = true
			return
		_move_toward(unit, grid, unit.destination, travel)
		return
	var target := grid.cell_center(field.next_cell(cell))
	_move_toward(unit, grid, target, travel)


## Bước tới target; vướng vật cản thì trượt theo từng trục.
static func _move_toward(unit: Unit, grid: GridData, target: Vector2, travel: float) -> void:
	var offset := target - unit.position
	var distance := offset.length()
	if distance < 0.001:
		return
	var move := offset / distance * minf(travel, distance)
	var candidates: Array[Vector2] = [unit.position + move]
	candidates.append(unit.position + Vector2(move.x, 0.0))
	candidates.append(unit.position + Vector2(0.0, move.y))
	for candidate in candidates:
		if grid.point_walkable(candidate, unit.water, unit.large):
			unit.position = candidate
			return
