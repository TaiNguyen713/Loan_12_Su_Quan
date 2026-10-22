extends GdUnitTestSuite
## S2.T01: luật đi lại của từng loại địa hình.


func test_s2_t01_tc1_walk_flags() -> void:
	assert_bool(Terrain.walkable(Terrain.T.RIVER)).is_false()
	assert_bool(Terrain.walkable(Terrain.T.BRIDGE)).is_true()
	assert_bool(Terrain.walkable(Terrain.T.GRASS)).is_true()
	assert_bool(Terrain.walkable(Terrain.T.FOREST)).is_false()
	assert_bool(Terrain.walkable(Terrain.T.RIVER, true)).is_true()
	assert_bool(Terrain.walkable(Terrain.T.GRASS, true)).is_false()


func test_bridge_and_ferry_are_walkable_on_land_and_water() -> void:
	for value in [Terrain.T.BRIDGE, Terrain.T.FERRY]:
		assert_bool(Terrain.walkable(value, false)).is_true()
		assert_bool(Terrain.walkable(value, true)).is_true()


func test_s2_t01_tc2_only_large_ships_use_deep_sea() -> void:
	assert_bool(Terrain.walkable(Terrain.T.SEA_DEEP, true, false)).is_false()
	assert_bool(Terrain.walkable(Terrain.T.SEA_DEEP, true, true)).is_true()
	assert_bool(Terrain.walkable(Terrain.T.SEA_SHALLOW, true, false)).is_true()
	assert_bool(Terrain.walkable(Terrain.T.SEA_DEEP, false, true)).is_false()


func test_mines_are_not_walkable_and_only_grass_is_buildable() -> void:
	for value in [Terrain.T.MINE_STONE, Terrain.T.MINE_IRON, Terrain.T.MINE_SALTPETER]:
		assert_bool(Terrain.is_mine(value)).is_true()
		assert_bool(Terrain.walkable(value)).is_false()
		assert_bool(Terrain.walkable(value, true)).is_false()
	assert_bool(Terrain.BUILDABLE[Terrain.T.GRASS]).is_true()
	assert_bool(Terrain.BUILDABLE[Terrain.T.BRIDGE]).is_false()


func test_every_terrain_has_a_name_and_all_tables_have_the_same_size() -> void:
	assert_int(Terrain.NAMES.size()).is_equal(Terrain.COUNT)
	assert_int(Terrain.WALK_LAND.size()).is_equal(Terrain.COUNT)
	assert_int(Terrain.WALK_WATER.size()).is_equal(Terrain.COUNT)
	assert_int(Terrain.BUILDABLE.size()).is_equal(Terrain.COUNT)
	assert_int(Terrain.MOVE_COST.size()).is_equal(Terrain.COUNT)
