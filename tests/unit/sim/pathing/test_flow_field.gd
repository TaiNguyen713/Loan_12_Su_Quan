extends GdUnitTestSuite
## S2.T03: trường dòng chảy.

const Grids = preload("res://tests/fixtures/grids.gd")

const SOUTH := Vector2(4.5 * 32, 17.5 * 32)


func test_goal_cells_cost_zero_and_unwalkable_cells_are_unreachable() -> void:
	var grid := Grids.river_with_bridge()
	var field := FlowField.build(grid, SOUTH)
	assert_bool(field.goal_cells.size() > 0).is_true()
	for cell in field.goal_cells:
		assert_float(field.integration[grid.index_of(cell)]).is_equal(0.0)
		assert_int(field.direction_index(cell)).is_equal(FlowField.NONE)
	assert_bool(field.reachable(Vector2i(3, 9))).is_false()


func test_s2_t03_tc4_every_step_goes_to_a_cell_with_lower_cost() -> void:
	var grid := Grids.river_with_bridge()
	var field := FlowField.build(grid, SOUTH)
	for y in grid.height:
		for x in grid.width:
			var cell := Vector2i(x, y)
			if not grid.walkable(cell) or field.direction_index(cell) == FlowField.NONE:
				continue
			var next := field.next_cell(cell)
			assert_bool(grid.walkable(next)).is_true()
			var next_cost := field.integration[grid.index_of(next)]
			assert_bool(next_cost < field.integration[grid.index_of(cell)]).is_true()


func test_following_the_field_from_the_north_reaches_the_goal_over_the_bridge() -> void:
	var grid := Grids.river_with_bridge()
	var field := FlowField.build(grid, SOUTH)
	var cell := Vector2i(18, 1)
	var crossed_bridge := false
	for step in 200:
		if field.direction_index(cell) == FlowField.NONE:
			break
		cell = field.next_cell(cell)
		crossed_bridge = crossed_bridge or grid.get_terrain(cell) == Terrain.T.BRIDGE
		assert_bool(grid.get_terrain(cell) != Terrain.T.RIVER).is_true()
	assert_bool(crossed_bridge).is_true()
	assert_bool(field.goal_cells.has(cell)).is_true()


func test_diagonal_steps_never_cut_a_blocked_corner() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var grid := MapGen.generate_valid(rng, Vector2i(48, 36))
	var field := FlowField.build(grid, grid.cell_center(MapGen.base_cell(grid, false)))
	for y in grid.height:
		for x in grid.width:
			var k := field.direction_index(Vector2i(x, y))
			if k == FlowField.NONE or k % 2 == 0:
				continue
			var step := FlowField.DIRS[k]
			assert_bool(grid.walkable(Vector2i(x + step.x, y))).is_true()
			assert_bool(grid.walkable(Vector2i(x, y + step.y))).is_true()


func test_unreachable_goal_side_after_the_bridge_is_removed() -> void:
	var grid := Grids.river_with_bridge()
	for x in [10, 11]:
		grid.set_terrain(Vector2i(x, 9), Terrain.T.RIVER)
		grid.set_terrain(Vector2i(x, 10), Terrain.T.RIVER)
	var field := FlowField.build(grid, SOUTH)
	assert_bool(field.reachable(Vector2i(18, 1))).is_false()
	assert_bool(field.reachable(Vector2i(18, 18))).is_true()
