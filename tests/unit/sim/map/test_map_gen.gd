extends GdUnitTestSuite
## S2.T02: sinh bản đồ "Hai đàng".

const SMALL := Vector2i(64, 48)


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func test_s2_t02_tc1_same_seed_same_map() -> void:
	var a := MapGen.generate(_rng(7), SMALL)
	var b := MapGen.generate(_rng(7), SMALL)
	assert_array(Array(a.terrain)).is_equal(Array(b.terrain))


func test_different_seeds_give_different_maps() -> void:
	var a := MapGen.generate(_rng(7), SMALL)
	var b := MapGen.generate(_rng(8), SMALL)
	assert_array(Array(a.terrain)).is_not_equal(Array(b.terrain))


func test_s2_t02_tc3_map_is_point_symmetric() -> void:
	for seed_value in [1, 2, 3, 4, 5]:
		var grid := MapGen.generate_valid(_rng(seed_value), SMALL)
		for y in grid.height:
			for x in grid.width:
				var mirrored := Vector2i(grid.width - 1 - x, grid.height - 1 - y)
				assert_int(grid.get_terrain(Vector2i(x, y))).is_equal(grid.get_terrain(mirrored))


func test_s2_t02_tc2_both_bases_are_connected_by_land_for_100_seeds() -> void:
	for seed_value in 100:
		var grid := MapGen.generate_valid(_rng(seed_value), SMALL)
		var north := MapGen.base_cell(grid, true)
		var south := MapGen.base_cell(grid, false)
		assert_bool(MapGen.land_connected(grid, north, south)).is_true()


func test_map_has_a_river_bridges_forests_and_each_kind_of_mine() -> void:
	var grid := MapGen.generate_valid(_rng(42), SMALL)
	assert_bool(grid.count_terrain(Terrain.T.RIVER) > 0).is_true()
	assert_bool(grid.count_terrain(Terrain.T.BRIDGE) >= 8).is_true()
	assert_bool(grid.count_terrain(Terrain.T.FOREST) > 0).is_true()
	for kind in [Terrain.T.MINE_STONE, Terrain.T.MINE_IRON, Terrain.T.MINE_SALTPETER]:
		# 2 bên × 2 mỏ × 4 ô
		assert_int(grid.count_terrain(kind)).is_equal(16)


func test_three_bridges_when_asked() -> void:
	var two := MapGen.generate(_rng(9), SMALL, 2)
	var three := MapGen.generate(_rng(9), SMALL, 3)
	var more_bridge_cells := (
		three.count_terrain(Terrain.T.BRIDGE) > two.count_terrain(Terrain.T.BRIDGE)
	)
	assert_bool(more_bridge_cells).is_true()


func test_bases_stand_on_open_ground_with_no_forest_nearby() -> void:
	var grid := MapGen.generate_valid(_rng(5), SMALL)
	for north in [true, false]:
		var base := MapGen.base_cell(grid, north)
		for dy in range(-5, 6):
			for dx in range(-5, 6):
				if Vector2(dx, dy).length() <= 5.0:
					assert_int(grid.get_terrain(base + Vector2i(dx, dy))).is_equal(Terrain.T.GRASS)
