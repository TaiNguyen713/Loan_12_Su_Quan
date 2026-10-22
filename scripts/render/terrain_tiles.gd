class_name TerrainTiles
extends RefCounted
## Tạo TileSet isometric 64×32 từ hình vẽ tạm bằng code (chưa có art thật, S11 sẽ thay).
## Mỗi loại địa hình một ô; đất có thêm ô thứ hai để tạo bàn cờ dễ nhìn.

const TILE_SIZE := Vector2i(64, 32)
const GRASS_ALT_INDEX: int = Terrain.COUNT
const SOURCE_ID: int = 0

const COLORS: Array[Color] = [
	Color("5c8f43"),  # đất
	Color("2f5d2c"),  # rừng
	Color("3b78ad"),  # sông
	Color("9a7443"),  # cầu
	Color("b08a52"),  # bến phà
	Color("4f95bd"),  # biển nông
	Color("1f4d7a"),  # biển sâu
	Color("8c8c86"),  # mỏ đá
	Color("6b5a52"),  # mỏ sắt
	Color("b7a56a"),  # mỏ diêm tiêu
]
const GRASS_ALT_COLOR := Color("65984c")


static func atlas_index(terrain_value: int, cell: Vector2i) -> int:
	if terrain_value == Terrain.T.GRASS and (cell.x + cell.y) % 2 == 1:
		return GRASS_ALT_INDEX
	return terrain_value


static func build() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tile_set.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	tile_set.tile_size = TILE_SIZE
	var atlas := TileSetAtlasSource.new()
	atlas.texture = ImageTexture.create_from_image(_atlas_image())
	atlas.texture_region_size = TILE_SIZE
	for index in Terrain.COUNT + 1:
		atlas.create_tile(Vector2i(index, 0))
	tile_set.add_source(atlas, SOURCE_ID)
	return tile_set


static func _atlas_image() -> Image:
	var image := Image.create_empty(
		(Terrain.COUNT + 1) * TILE_SIZE.x, TILE_SIZE.y, false, Image.FORMAT_RGBA8
	)
	for index in Terrain.COUNT + 1:
		var color := GRASS_ALT_COLOR if index == GRASS_ALT_INDEX else COLORS[index]
		_paint_diamond(image, index * TILE_SIZE.x, color, index)
	return image


static func _paint_diamond(image: Image, x0: int, color: Color, index: int) -> void:
	var half_w := TILE_SIZE.x * 0.5
	var half_h := TILE_SIZE.y * 0.5
	for py in TILE_SIZE.y:
		for px in TILE_SIZE.x:
			var edge := absf(px + 0.5 - half_w) / half_w + absf(py + 0.5 - half_h) / half_h
			if edge > 1.0:
				continue
			var shade := color
			if edge > 0.92:
				shade = color.darkened(0.18)
			elif _has_detail(index, px, py):
				shade = color.darkened(0.25)
			image.set_pixel(x0 + px, py, shade)


## Chi tiết nhỏ cho từng loại để phân biệt được khi không có art.
static func _has_detail(index: int, px: int, py: int) -> bool:
	match index:
		Terrain.T.FOREST:
			return (floori(px / 6.0) + floori(py / 4.0)) % 2 == 0 and py > 6 and py < 26
		Terrain.T.RIVER, Terrain.T.SEA_SHALLOW, Terrain.T.SEA_DEEP:
			return py % 8 == 3 and (px + py) % 16 < 6
		Terrain.T.BRIDGE:
			return px % 8 == 0
		Terrain.T.FERRY:
			return py == 15 or px == 31
		Terrain.T.MINE_STONE, Terrain.T.MINE_IRON, Terrain.T.MINE_SALTPETER:
			return (px * 7 + py * 3) % 11 < 3
		_:
			return false
