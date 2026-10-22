extends GdUnitTestSuite
## S2.T01: lưới địa hình.


func test_cell_conversions_round_trip() -> void:
	var grid := GridData.new(40, 30)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 200:
		var cell := Vector2i(rng.randi_range(0, 39), rng.randi_range(0, 29))
		assert_vector(Vector2(grid.cell_of(grid.cell_center(cell)))).is_equal(Vector2(cell))


func test_set_terrain_bumps_version_and_emits_only_on_change() -> void:
	var grid := GridData.new(8, 8)
	var changed: Array = []
	grid.cell_changed.connect(func(cell: Vector2i) -> void: changed.append(cell))
	grid.set_terrain(Vector2i(2, 3), Terrain.T.RIVER)
	grid.set_terrain(Vector2i(2, 3), Terrain.T.RIVER)
	assert_int(grid.version).is_equal(1)
	assert_array(changed).is_equal([Vector2i(2, 3)])


func test_blocked_cells_are_not_walkable_until_released() -> void:
	var grid := GridData.new(8, 8)
	grid.block_rect(Rect2i(2, 2, 2, 2), true)
	assert_bool(grid.walkable(Vector2i(3, 3))).is_false()
	assert_bool(grid.walkable(Vector2i(4, 4))).is_true()
	grid.block_rect(Rect2i(2, 2, 2, 2), false)
	assert_bool(grid.walkable(Vector2i(3, 3))).is_true()


func test_out_of_bounds_is_not_walkable() -> void:
	var grid := GridData.new(8, 8)
	assert_bool(grid.walkable(Vector2i(-1, 0))).is_false()
	assert_bool(grid.walkable(Vector2i(8, 0))).is_false()


func test_nearest_walkable_finds_the_closest_free_cell() -> void:
	var grid := GridData.new(10, 10)
	grid.set_terrain(Vector2i(5, 5), Terrain.T.FOREST)
	var found := grid.nearest_walkable(Vector2i(5, 5))
	assert_int(maxi(absi(found.x - 5), absi(found.y - 5))).is_equal(1)
	assert_bool(grid.walkable(found)).is_true()


func test_nearest_walkable_gives_up_with_minus_one() -> void:
	var grid := GridData.new(6, 6)
	for y in 6:
		for x in 6:
			grid.set_terrain(Vector2i(x, y), Terrain.T.FOREST)
	assert_vector(Vector2(grid.nearest_walkable(Vector2i(3, 3), 5))).is_equal(Vector2(-1, -1))
