extends RefCounted
## Lưới dựng sẵn cho test. Không đọc dữ liệu thật.


## 24×20: sông ở hai hàng 9–10, cầu ở cột 10–11. Nửa trên là Bắc, nửa dưới là Nam.
static func river_with_bridge() -> GridData:
	var grid := GridData.new(24, 20)
	for x in 24:
		grid.set_terrain(Vector2i(x, 9), Terrain.T.RIVER)
		grid.set_terrain(Vector2i(x, 10), Terrain.T.RIVER)
	for x in [10, 11]:
		grid.set_terrain(Vector2i(x, 9), Terrain.T.BRIDGE)
		grid.set_terrain(Vector2i(x, 10), Terrain.T.BRIDGE)
	return grid


## Vòng rừng bao kín ô `center`: ô đó vẫn là đất nhưng không có đường vào.
static func wall_in(grid: GridData, center: Vector2i) -> void:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx != 0 or dy != 0:
				grid.set_terrain(center + Vector2i(dx, dy), Terrain.T.FOREST)
