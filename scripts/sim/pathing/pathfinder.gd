class_name Pathfinder
extends RefCounted
## Tìm đường (S2.T03): A* cho quân đi lẻ hoặc đích gần, flow field cho cả nhóm đi xa.
## Có hai lưới độc lập: đường bộ và đường thủy (thuyền lớn có lưới riêng vì đi được biển sâu).

## Từ ngần này quân cùng đích trở lên và đích đủ xa thì dùng flow field.
const FLOW_GROUP_MIN: int = 8
const FLOW_MIN_DISTANCE: float = 12.0 * GridData.CELL_SIZE
const CACHE_LIMIT: int = 32

var grid: GridData

var _astars: Dictionary = {}
var _fields: Dictionary = {}


func _init(p_grid: GridData) -> void:
	grid = p_grid
	grid.cell_changed.connect(_on_cell_changed)


## Nhóm đủ đông và đích đủ xa thì đi theo flow field, ngược lại mỗi quân tự tìm đường A*.
func should_use_flow(unit_count: int, distance: float) -> bool:
	return unit_count >= FLOW_GROUP_MIN and distance >= FLOW_MIN_DISTANCE


## Các điểm đường đi (tọa độ sim), không gồm vị trí hiện tại.
## Đích bị chặn thì tới ô đi được gần nhất;
## đích không tới được thì đi tới ô gần đích nhất mà A* tìm được. Rỗng nếu không có đường.
func find_path(
	from: Vector2, to: Vector2, water: bool = false, large: bool = false
) -> PackedVector2Array:
	var start := grid.nearest_walkable(grid.cell_of(from), 12, water, large)
	var goal_wanted := grid.cell_of(to)
	var goal := grid.nearest_walkable(goal_wanted, 12, water, large)
	if start.x < 0 or goal.x < 0:
		return PackedVector2Array()
	var path := _astar_for(water, large).get_point_path(start, goal, true)
	if path.size() > 0:
		path.remove_at(0)
	if goal == goal_wanted and grid.point_walkable(to, water, large):
		if path.is_empty() and start == goal:
			path.append(to)
		elif not path.is_empty() and grid.cell_of(path[path.size() - 1]) == goal:
			# Chỉ đổi điểm cuối thành đích chính xác khi đường thật sự tới được ô đích.
			path[path.size() - 1] = to
	return path


## Trường dòng chảy tới `goal`, lấy từ cache nếu đã có (LRU 32 trường).
func flow_field(goal: Vector2, water: bool = false, large: bool = false) -> FlowField:
	var key := "%d:%d:%d" % [grid.cell_of(goal).x, grid.cell_of(goal).y, _domain_key(water, large)]
	if _fields.has(key):
		var cached: FlowField = _fields[key]
		_fields.erase(key)
		_fields[key] = cached
		return cached
	var field := FlowField.build(grid, goal, water, large)
	_fields[key] = field
	if _fields.size() > CACHE_LIMIT:
		_fields.erase(_fields.keys()[0])
	return field


func cached_field_count() -> int:
	return _fields.size()


func _domain_key(water: bool, large: bool) -> int:
	return (1 if water else 0) | (2 if large else 0)


func _astar_for(water: bool, large: bool) -> AStarGrid2D:
	var key := _domain_key(water, large)
	if _astars.has(key):
		return _astars[key]
	var astar := AStarGrid2D.new()
	astar.region = Rect2i(0, 0, grid.width, grid.height)
	astar.cell_size = Vector2(GridData.CELL_SIZE, GridData.CELL_SIZE)
	astar.offset = astar.cell_size * 0.5
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar.update()
	for y in grid.height:
		for x in grid.width:
			if not grid.walkable(Vector2i(x, y), water, large):
				astar.set_point_solid(Vector2i(x, y), true)
	_astars[key] = astar
	return astar


## Ô đổi trạng thái (xây nhà, cầu bị phá…): cập nhật A* và bỏ cache flow field.
func _on_cell_changed(cell: Vector2i) -> void:
	for key in _astars:
		var flags: int = key
		var astar: AStarGrid2D = _astars[key]
		var water := (flags & 1) != 0
		var large := (flags & 2) != 0
		astar.set_point_solid(cell, not grid.walkable(cell, water, large))
	_fields.clear()
