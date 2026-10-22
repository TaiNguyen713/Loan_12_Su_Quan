class_name Unit
extends RefCounted
## Một đơn vị trong sim: dữ liệu và trạng thái di chuyển. Không có hình ảnh (xem UnitsView).

var id: int = 0
var team: int = 0
var position: Vector2 = Vector2.ZERO
## Vị trí tick trước, để render nội suy giữa hai tick.
var previous_position: Vector2 = Vector2.ZERO
var speed: float = 66.0
var radius: float = 8.0
var water: bool = false
var large: bool = false

var moving: bool = false
var destination: Vector2 = Vector2.ZERO
## Đường A* đang đi (khi flow == null).
var path := PackedVector2Array()
var path_index: int = 0
## Flow field đang theo (khi đi theo nhóm).
var flow: FlowField = null


func stop() -> void:
	moving = false
	path = PackedVector2Array()
	path_index = 0
	flow = null


func uses_flow() -> bool:
	return flow != null
