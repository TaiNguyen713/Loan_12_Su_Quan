class_name MapGen
extends RefCounted
## Sinh bản đồ "Hai đàng" có seed (S2.T02): sông Gianh ở giữa, 2–3 cầu, rừng và mỏ.
## Bản đồ đối xứng tâm nên hai bên công bằng: ô (x, y) giống hệt ô (W-1-x, H-1-y).

const RIVER_HALF_WIDTH: float = 2.0
const BASE_CLEAR_RADIUS: int = 7
const MAX_ATTEMPTS: int = 5
const FOREST_CLUSTERS: int = 18
const MINES_PER_KIND: int = 2
## Dọn rừng quanh hai đầu cầu trong phạm vi này (tính từ tâm sông).
const BRIDGE_CLEAR_BAND: float = 6.0
const ORTHOGONAL: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]


## Sinh bản đồ rồi kiểm tra hai căn cứ nối được bằng đường bộ.
## Không nối được thì sinh lại, tối đa 5 lần.
static func generate_valid(
	rng: RandomNumberGenerator, size: Vector2i = Vector2i(128, 96), bridge_count: int = 2
) -> GridData:
	var grid: GridData = null
	for attempt in MAX_ATTEMPTS:
		grid = generate(rng, size, bridge_count)
		if land_connected(grid, base_cell(grid, true), base_cell(grid, false)):
			return grid
	push_warning("MapGen: không có bản đồ nối được sau %d lần, dùng bản cuối" % MAX_ATTEMPTS)
	return grid


static func generate(
	rng: RandomNumberGenerator, size: Vector2i = Vector2i(128, 96), bridge_count: int = 2
) -> GridData:
	var grid := GridData.new(size.x, size.y)
	_carve_river_north(grid, rng)
	_scatter_forests_north(grid, rng)
	_place_mines_north(grid, rng)
	_mirror_to_south(grid)
	_place_bridges(grid, rng, bridge_count)
	return grid


## Phủ chúa của bên Bắc (north = true) hoặc bên Nam.
static func base_cell(grid: GridData, north: bool) -> Vector2i:
	var margin := maxi(8, floori(grid.height / 7.0))
	return Vector2i(grid.width >> 1, margin if north else grid.height - 1 - margin)


static func land_connected(grid: GridData, from: Vector2i, to: Vector2i) -> bool:
	if not grid.walkable(from) or not grid.walkable(to):
		return false
	var seen := PackedByteArray()
	seen.resize(grid.width * grid.height)
	var queue: Array[Vector2i] = [from]
	seen[grid.index_of(from)] = 1
	var head := 0
	while head < queue.size():
		var cell := queue[head]
		head += 1
		if cell == to:
			return true
		for step in ORTHOGONAL:
			var next := cell + step
			if grid.walkable(next) and seen[grid.index_of(next)] == 0:
				seen[grid.index_of(next)] = 1
				queue.append(next)
	return false


## Tâm sông theo cột x. Hàm lẻ quanh giữa bản đồ nên đối xứng tâm.
static func _river_center(grid: GridData, x: int, curve: Vector4) -> float:
	var t := float(x) - (grid.width - 1) * 0.5
	return (grid.height - 1) * 0.5 + curve.x * sin(curve.y * t) + curve.z * sin(curve.w * t)


static func _river_curve(rng: RandomNumberGenerator) -> Vector4:
	return Vector4(
		rng.randf_range(3.5, 5.5),
		rng.randf_range(0.05, 0.09),
		rng.randf_range(1.0, 2.0),
		rng.randf_range(0.17, 0.25)
	)


static func _carve_river_north(grid: GridData, rng: RandomNumberGenerator) -> void:
	var curve := _river_curve(rng)
	grid.set_meta(&"river_curve", curve)
	for x in grid.width:
		var center := _river_center(grid, x, curve)
		for y in grid.height >> 1:
			if absf(y - center) <= RIVER_HALF_WIDTH:
				grid.set_terrain(Vector2i(x, y), Terrain.T.RIVER)


static func _distance_to_river(grid: GridData, cell: Vector2i) -> float:
	var curve: Vector4 = grid.get_meta(&"river_curve")
	return absf(cell.y - _river_center(grid, cell.x, curve))


static func _in_base_zone(grid: GridData, cell: Vector2i) -> bool:
	return Vector2(cell - base_cell(grid, true)).length() <= BASE_CLEAR_RADIUS


static func _scatter_forests_north(grid: GridData, rng: RandomNumberGenerator) -> void:
	var half := grid.height >> 1
	for i in FOREST_CLUSTERS:
		var center := Vector2i(rng.randi_range(3, grid.width - 4), rng.randi_range(3, half - 4))
		if _distance_to_river(grid, center) < 6.0:
			continue
		var radius := rng.randi_range(2, 5)
		for dy in range(-radius, radius + 1):
			for dx in range(-radius, radius + 1):
				var cell := center + Vector2i(dx, dy)
				if cell.y >= half or not grid.in_bounds(cell):
					continue
				if Vector2(dx, dy).length() > radius or rng.randf() > 0.75:
					continue
				if grid.get_terrain(cell) == Terrain.T.GRASS and not _in_base_zone(grid, cell):
					grid.set_terrain(cell, Terrain.T.FOREST)


static func _place_mines_north(grid: GridData, rng: RandomNumberGenerator) -> void:
	var half := grid.height >> 1
	var kinds: Array[int] = [Terrain.T.MINE_STONE, Terrain.T.MINE_IRON, Terrain.T.MINE_SALTPETER]
	for kind in kinds:
		var placed := 0
		var tries := 0
		while placed < MINES_PER_KIND and tries < 200:
			tries += 1
			var origin := Vector2i(rng.randi_range(4, grid.width - 6), rng.randi_range(4, half - 6))
			if _distance_to_river(grid, origin) < 7.0 or _in_base_zone(grid, origin):
				continue
			if not _is_free_block(grid, origin):
				continue
			for dy in 2:
				for dx in 2:
					grid.set_terrain(origin + Vector2i(dx, dy), kind)
			placed += 1


static func _is_free_block(grid: GridData, origin: Vector2i) -> bool:
	for dy in range(-1, 3):
		for dx in range(-1, 3):
			var cell := origin + Vector2i(dx, dy)
			if not grid.in_bounds(cell) or grid.get_terrain(cell) != Terrain.T.GRASS:
				return false
	return true


## Nửa Nam là bản sao lật tâm của nửa Bắc (sông, rừng, mỏ).
static func _mirror_to_south(grid: GridData) -> void:
	for y in grid.height >> 1:
		for x in grid.width:
			var mirrored := Vector2i(grid.width - 1 - x, grid.height - 1 - y)
			grid.set_terrain(mirrored, grid.get_terrain(Vector2i(x, y)))


## Cầu rộng 2 cột, đặt theo cặp đối xứng; dọn rừng ở hai đầu cầu để chắc chắn đi được.
static func _place_bridges(grid: GridData, rng: RandomNumberGenerator, count: int) -> void:
	var columns: Array[int] = []
	var quarter := grid.width >> 2
	var first := clampi(quarter + rng.randi_range(-4, 4), 4, (grid.width >> 1) - 6)
	columns.append(first)
	columns.append(grid.width - 2 - first)
	if count >= 3:
		columns.append((grid.width >> 1) - 1)
	for column in columns:
		for x in range(column, column + 2):
			_clear_and_bridge_column(grid, x)


static func _clear_and_bridge_column(grid: GridData, x: int) -> void:
	for y in grid.height:
		var cell := Vector2i(x, y)
		var value := grid.get_terrain(cell)
		if value == Terrain.T.RIVER:
			grid.set_terrain(cell, Terrain.T.BRIDGE)
		elif value == Terrain.T.FOREST and _distance_to_river(grid, cell) <= BRIDGE_CLEAR_BAND:
			grid.set_terrain(cell, Terrain.T.GRASS)
