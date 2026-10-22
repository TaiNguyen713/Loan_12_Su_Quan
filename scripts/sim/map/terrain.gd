class_name Terrain
extends RefCounted
## Các loại ô địa hình và luật đi lại của chúng (S2.T01).
## Sim chỉ đọc bảng này; hình ảnh của từng loại nằm ở lớp render.

enum T {
	GRASS,
	FOREST,
	RIVER,
	BRIDGE,
	FERRY,
	SEA_SHALLOW,
	SEA_DEEP,
	MINE_STONE,
	MINE_IRON,
	MINE_SALTPETER,
}

const COUNT: int = 10

const NAMES: Array[String] = [
	"Đất",
	"Rừng",
	"Sông",
	"Cầu",
	"Bến phà",
	"Biển nông",
	"Biển sâu",
	"Mỏ đá",
	"Mỏ sắt",
	"Mỏ diêm tiêu",
]

## Cầu và bến phà đi được cả trên bộ lẫn dưới nước (thuyền đi dưới cầu).
const WALK_LAND: Array[bool] = [true, false, false, true, true, false, false, false, false, false]
const WALK_WATER: Array[bool] = [false, false, true, true, true, true, true, false, false, false]
const BUILDABLE: Array[bool] = [true, false, false, false, false, false, false, false, false, false]
const MOVE_COST: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]


static func is_mine(terrain: int) -> bool:
	return terrain >= T.MINE_STONE and terrain <= T.MINE_SALTPETER


## Đi được không. Với nước, biển sâu chỉ thuyền lớn (`large`) đi được.
static func walkable(terrain: int, water: bool = false, large: bool = false) -> bool:
	if water:
		if terrain == T.SEA_DEEP:
			return large
		return WALK_WATER[terrain]
	return WALK_LAND[terrain]
