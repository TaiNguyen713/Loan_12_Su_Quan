class_name GridData
extends RefCounted
## Lưới địa hình của một trận: nguồn sự thật dùng chung cho tìm đường, tầm nhìn và đặt công trình.
## Ô vuông 32 px trong không gian sim; chuyển sang isometric chỉ làm ở lớp render (Iso).

signal cell_changed(cell: Vector2i)

const CELL_SIZE: int = 32

var width: int = 0
var height: int = 0
## Loại địa hình của từng ô (giá trị Terrain.T).
var terrain := PackedByteArray()
## Số vật cản (công trình, tài nguyên) đang đứng trên ô; > 0 là bị chặn.
var blocked := PackedByteArray()
## Tăng mỗi khi có ô đổi, để cache biết mà làm mới.
var version: int = 0


func _init(p_width: int, p_height: int) -> void:
	width = p_width
	height = p_height
	terrain.resize(width * height)
	terrain.fill(Terrain.T.GRASS)
	blocked.resize(width * height)
	blocked.fill(0)


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


func index_of(cell: Vector2i) -> int:
	return cell.y * width + cell.x


func get_terrain(cell: Vector2i) -> int:
	return terrain[index_of(cell)]


func set_terrain(cell: Vector2i, value: int) -> void:
	var index := index_of(cell)
	if terrain[index] == value:
		return
	terrain[index] = value
	version += 1
	cell_changed.emit(cell)


func is_blocked(cell: Vector2i) -> bool:
	return blocked[index_of(cell)] > 0


## Đặt hoặc gỡ vật cản lên cả hình chữ nhật ô (công trình, cây).
func block_rect(rect: Rect2i, on: bool) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var cell := Vector2i(x, y)
			if not in_bounds(cell):
				continue
			var index := index_of(cell)
			blocked[index] = maxi(0, blocked[index] + (1 if on else -1))
			version += 1
			cell_changed.emit(cell)


func walkable(cell: Vector2i, water: bool = false, large: bool = false) -> bool:
	if not in_bounds(cell):
		return false
	var index := index_of(cell)
	return blocked[index] == 0 and Terrain.walkable(terrain[index], water, large)


func cell_of(point: Vector2) -> Vector2i:
	return Vector2i(floori(point.x / CELL_SIZE), floori(point.y / CELL_SIZE))


func cell_center(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * CELL_SIZE


func pixel_size() -> Vector2:
	return Vector2(width, height) * CELL_SIZE


func point_walkable(point: Vector2, water: bool = false, large: bool = false) -> bool:
	return walkable(cell_of(point), water, large)


## Ô đi được gần nhất, tìm theo vòng xoáy tối đa max_radius ô.
## Trả về Vector2i(-1, -1) nếu không có ô nào.
func nearest_walkable(
	cell: Vector2i, max_radius: int = 12, water: bool = false, large: bool = false
) -> Vector2i:
	if walkable(cell, water, large):
		return cell
	for radius in range(1, max_radius + 1):
		var best := Vector2i(-1, -1)
		var best_distance := INF
		for dy in range(-radius, radius + 1):
			for dx in range(-radius, radius + 1):
				if absi(dx) != radius and absi(dy) != radius:
					continue
				var candidate := cell + Vector2i(dx, dy)
				if not walkable(candidate, water, large):
					continue
				var distance := Vector2(dx, dy).length_squared()
				if distance < best_distance:
					best_distance = distance
					best = candidate
		if best.x >= 0:
			return best
	return Vector2i(-1, -1)


func count_terrain(value: int) -> int:
	var total := 0
	for cell_value in terrain:
		if cell_value == value:
			total += 1
	return total
