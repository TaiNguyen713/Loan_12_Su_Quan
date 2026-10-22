class_name TerrainView
extends Node2D
## Vẽ địa hình bằng TileMapLayer isometric, căn khớp với phép chiếu Iso (S2.T01).

var layer := TileMapLayer.new()


func setup(grid: GridData) -> void:
	layer.tile_set = TerrainTiles.build()
	add_child(layer)
	# Căn lớp sao cho tâm ô (0,0) của TileMap trùng tâm ô đó khi chiếu bằng Iso.
	var wanted := Iso.to_screen(grid.cell_center(Vector2i.ZERO))
	layer.position = wanted - layer.map_to_local(Vector2i.ZERO)
	for y in grid.height:
		for x in grid.width:
			var cell := Vector2i(x, y)
			var atlas := TerrainTiles.atlas_index(grid.get_terrain(cell), cell)
			layer.set_cell(cell, TerrainTiles.SOURCE_ID, Vector2i(atlas, 0))
	grid.cell_changed.connect(func(cell: Vector2i) -> void: _refresh_cell(grid, cell))


## Vị trí tâm ô trên màn hình (không gian của node này), theo TileMap.
func cell_screen_center(cell: Vector2i) -> Vector2:
	return layer.position + layer.map_to_local(cell)


func _refresh_cell(grid: GridData, cell: Vector2i) -> void:
	var atlas := TerrainTiles.atlas_index(grid.get_terrain(cell), cell)
	layer.set_cell(cell, TerrainTiles.SOURCE_ID, Vector2i(atlas, 0))
