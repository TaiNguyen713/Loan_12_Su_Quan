extends GdUnitTestSuite
## S2.T01: TileMapLayer isometric phải khớp phép chiếu Iso.


func _view() -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	var grid := MapGen.generate_valid(rng, Vector2i(48, 36))
	var view := TerrainView.new()
	add_child(auto_free(view))
	view.setup(grid)
	return [view, grid]


func test_s2_t01_tc4_every_cell_has_a_tile() -> void:
	var parts := _view()
	var view: TerrainView = parts[0]
	var grid: GridData = parts[1]
	assert_int(view.layer.get_used_cells().size()).is_equal(grid.width * grid.height)


func test_s2_t01_tc4_tile_centers_match_the_iso_projection() -> void:
	var parts := _view()
	var view: TerrainView = parts[0]
	var grid: GridData = parts[1]
	for cell in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(20, 5), Vector2i(47, 35)]:
		var expected := Iso.to_screen(grid.cell_center(cell))
		assert_vector(view.cell_screen_center(cell)).is_equal_approx(expected, Vector2(0.01, 0.01))


func test_changing_a_cell_updates_its_tile() -> void:
	var parts := _view()
	var view: TerrainView = parts[0]
	var grid: GridData = parts[1]
	var cell := Vector2i(10, 10)
	grid.set_terrain(cell, Terrain.T.SEA_DEEP)
	var atlas := view.layer.get_cell_atlas_coords(cell)
	assert_int(atlas.x).is_equal(Terrain.T.SEA_DEEP)


func test_tileset_has_one_tile_per_terrain_plus_the_grass_variant() -> void:
	var tile_set := TerrainTiles.build()
	var source := tile_set.get_source(TerrainTiles.SOURCE_ID) as TileSetAtlasSource
	assert_int(source.get_tiles_count()).is_equal(Terrain.COUNT + 1)
	assert_int(tile_set.tile_shape).is_equal(TileSet.TILE_SHAPE_ISOMETRIC)
