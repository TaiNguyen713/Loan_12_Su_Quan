extends GdUnitTestSuite
## S2.T03: tìm đường A*.

const Grids = preload("res://tests/fixtures/grids.gd")

const NORTH := Vector2(4.5 * 32, 2.5 * 32)
const SOUTH := Vector2(4.5 * 32, 17.5 * 32)


func test_s2_t03_tc1_path_crosses_the_river_only_over_the_bridge() -> void:
	var grid := Grids.river_with_bridge()
	var path := Pathfinder.new(grid).find_path(NORTH, SOUTH)
	assert_bool(path.size() > 0).is_true()
	var used_bridge := false
	for point in path:
		var value := grid.get_terrain(grid.cell_of(point))
		assert_bool(value != Terrain.T.RIVER).is_true()
		used_bridge = used_bridge or value == Terrain.T.BRIDGE
	assert_bool(used_bridge).is_true()
	assert_vector(path[path.size() - 1]).is_equal(SOUTH)


func test_s2_t03_tc2_target_on_a_blocked_cell_goes_to_the_nearest_free_cell() -> void:
	var grid := Grids.river_with_bridge()
	grid.set_terrain(Vector2i(4, 17), Terrain.T.FOREST)
	var path := Pathfinder.new(grid).find_path(NORTH, SOUTH)
	assert_bool(path.size() > 0).is_true()
	var end := grid.cell_of(path[path.size() - 1])
	assert_bool(grid.walkable(end)).is_true()
	assert_bool(maxi(absi(end.x - 4), absi(end.y - 17)) <= 1).is_true()


func test_s2_t03_tc3_enclosed_target_gives_a_partial_path_and_does_not_hang() -> void:
	var grid := Grids.river_with_bridge()
	Grids.wall_in(grid, Vector2i(4, 17))
	var path := Pathfinder.new(grid).find_path(NORTH, SOUTH)
	assert_bool(path.size() > 0).is_true()
	var end := grid.cell_of(path[path.size() - 1])
	assert_bool(end != Vector2i(4, 17)).is_true()
	assert_bool(maxi(absi(end.x - 4), absi(end.y - 17)) <= 3).is_true()


func test_no_path_returns_empty_when_start_has_no_walkable_cell_nearby() -> void:
	var grid := GridData.new(6, 6)
	for y in 6:
		for x in 6:
			grid.set_terrain(Vector2i(x, y), Terrain.T.FOREST)
	assert_int(Pathfinder.new(grid).find_path(Vector2(40, 40), Vector2(100, 100)).size()).is_equal(
		0
	)


func test_s2_t03_tc5_destroyed_bridge_changes_the_route() -> void:
	var grid := Grids.river_with_bridge()
	var pathfinder := Pathfinder.new(grid)
	assert_bool(pathfinder.find_path(NORTH, SOUTH).size() > 0).is_true()
	for x in [10, 11]:
		grid.set_terrain(Vector2i(x, 9), Terrain.T.RIVER)
		grid.set_terrain(Vector2i(x, 10), Terrain.T.RIVER)
	var path := pathfinder.find_path(NORTH, SOUTH)
	for point in path:
		assert_bool(grid.cell_of(point).y < 9).is_true()


func test_s2_t03_tc7_water_domain_uses_rivers_and_bridges_not_grass() -> void:
	var grid := Grids.river_with_bridge()
	var from := Vector2(2.5 * 32, 9.5 * 32)
	var to := Vector2(20.5 * 32, 10.5 * 32)
	var path := Pathfinder.new(grid).find_path(from, to, true)
	assert_bool(path.size() > 0).is_true()
	for point in path:
		assert_bool(Terrain.walkable(grid.get_terrain(grid.cell_of(point)), true)).is_true()


func test_should_use_flow_needs_a_big_group_and_a_far_target() -> void:
	var pathfinder := Pathfinder.new(Grids.river_with_bridge())
	assert_bool(pathfinder.should_use_flow(8, 400.0)).is_true()
	assert_bool(pathfinder.should_use_flow(7, 400.0)).is_false()
	assert_bool(pathfinder.should_use_flow(20, 300.0)).is_false()


func test_flow_field_is_cached_and_cleared_when_terrain_changes() -> void:
	var grid := Grids.river_with_bridge()
	var pathfinder := Pathfinder.new(grid)
	var first := pathfinder.flow_field(SOUTH)
	assert_object(pathfinder.flow_field(SOUTH)).is_same(first)
	assert_int(pathfinder.cached_field_count()).is_equal(1)
	grid.set_terrain(Vector2i(0, 0), Terrain.T.FOREST)
	assert_int(pathfinder.cached_field_count()).is_equal(0)


func test_flow_cache_keeps_at_most_32_fields() -> void:
	var pathfinder := Pathfinder.new(Grids.river_with_bridge())
	for i in 40:
		pathfinder.flow_field(Vector2((i % 20) * 32 + 16, floori(i / 20.0) * 32 + 16))
	assert_bool(pathfinder.cached_field_count() <= Pathfinder.CACHE_LIMIT).is_true()
