class_name FlowField
extends RefCounted
## Trường dòng chảy cho cả nhóm quân cùng đích (S2.T03): một lần Dijkstra từ đích,
## sau đó mỗi quân chỉ tra ô kế tiếp, không phải tìm đường riêng.

## Tám hướng; chỉ số chẵn là ngang/dọc, chỉ số lẻ là chéo.
const DIRS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(1, 1),
	Vector2i(0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, -1),
]
const NONE: int = 255
const DIAGONAL_COST: float = 1.41421356
const EPSILON: float = 0.0001

var width: int = 0
var height: int = 0
var goal_cells: Array[Vector2i] = []
## Chi phí từ ô tới đích; INF nghĩa là không tới được.
var integration := PackedFloat32Array()
## Chỉ số trong DIRS của bước tốt nhất, hoặc NONE.
var best := PackedByteArray()


## Dựng trường dòng chảy tới `goal` (tọa độ sim). Đích gồm các ô đi được trong bán kính
## `goal_radius` quanh đích để cả nhóm có chỗ đứng.
static func build(
	grid: GridData, goal: Vector2, water: bool = false, large: bool = false, goal_radius: int = 2
) -> FlowField:
	var field := FlowField.new()
	field.width = grid.width
	field.height = grid.height
	var count := grid.width * grid.height
	field.integration.resize(count)
	field.integration.fill(INF)
	field.best.resize(count)
	field.best.fill(NONE)

	var walk := PackedByteArray()
	walk.resize(count)
	for y in grid.height:
		for x in grid.width:
			if grid.walkable(Vector2i(x, y), water, large):
				walk[y * grid.width + x] = 1

	var goal_cell := grid.cell_of(goal)
	field.goal_cells = _goal_cells(grid, goal_cell, goal_radius, water, large)
	var heap := MinHeap.new()
	for cell in field.goal_cells:
		var index := grid.index_of(cell)
		field.integration[index] = 0.0
		heap.push(0.0, index)

	while not heap.is_empty():
		var index := heap.pop()
		var cost := heap.last_priority
		if cost > field.integration[index] + EPSILON:
			continue
		var cx := index % grid.width
		var cy := floori(float(index) / grid.width)
		for k in DIRS.size():
			var nx := cx + DIRS[k].x
			var ny := cy + DIRS[k].y
			if nx < 0 or ny < 0 or nx >= grid.width or ny >= grid.height:
				continue
			var next := ny * grid.width + nx
			if walk[next] == 0:
				continue
			var step := 1.0
			if k % 2 == 1:
				# Không cắt góc: cả hai ô ngang/dọc kề phải đi được.
				if walk[cy * grid.width + nx] == 0 or walk[ny * grid.width + cx] == 0:
					continue
				step = DIAGONAL_COST
			var new_cost := cost + step * Terrain.MOVE_COST[grid.terrain[next]]
			if new_cost < field.integration[next] - EPSILON:
				field.integration[next] = new_cost
				heap.push(new_cost, next)

	field._compute_best(walk)
	return field


static func _goal_cells(
	grid: GridData, center: Vector2i, radius: int, water: bool, large: bool
) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var cell := center + Vector2i(dx, dy)
			if Vector2(dx, dy).length() <= radius + 0.5 and grid.walkable(cell, water, large):
				cells.append(cell)
	if cells.is_empty():
		var nearest := grid.nearest_walkable(center, 12, water, large)
		if nearest.x >= 0:
			cells.append(nearest)
	return cells


func reachable(cell: Vector2i) -> bool:
	return is_finite(integration[cell.y * width + cell.x])


## Chỉ số hướng trong DIRS của ô, hoặc NONE nếu là ô đích hoặc không tới được.
func direction_index(cell: Vector2i) -> int:
	return best[cell.y * width + cell.x]


## Ô kế tiếp phải bước tới; trả về chính ô đó nếu đã ở đích hoặc không có đường.
func next_cell(cell: Vector2i) -> Vector2i:
	var k := direction_index(cell)
	if k == NONE:
		return cell
	return cell + DIRS[k]


func _compute_best(walk: PackedByteArray) -> void:
	for y in height:
		for x in width:
			var index := y * width + x
			if walk[index] == 0 or integration[index] == 0.0 or not is_finite(integration[index]):
				continue
			var best_cost: float = integration[index]
			var best_k := NONE
			for k in DIRS.size():
				var nx := x + DIRS[k].x
				var ny := y + DIRS[k].y
				if nx < 0 or ny < 0 or nx >= width or ny >= height:
					continue
				var next := ny * width + nx
				if walk[next] == 0:
					continue
				if k % 2 == 1 and (walk[y * width + nx] == 0 or walk[ny * width + x] == 0):
					continue
				if integration[next] < best_cost - EPSILON:
					best_cost = integration[next]
					best_k = k
			best[index] = best_k
