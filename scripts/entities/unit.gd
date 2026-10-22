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
## Khối lượng khi né tránh: bộ binh 1, kỵ binh 2, voi và pháo 4. Quân nặng đẩy quân nhẹ.
var mass: float = 1.0
var water: bool = false
var large: bool = false

var moving: bool = false
## Đã tới đích của lệnh vừa rồi (đứng yên và khó bị đẩy).
var arrived: bool = false
var destination: Vector2 = Vector2.ZERO
## Đường A* đang đi (khi flow == null).
var path := PackedVector2Array()
var path_index: int = 0
## Flow field đang theo (khi đi theo nhóm).
var flow: FlowField = null

## Theo dõi kẹt (StuckWatch): thời gian trong cửa sổ hiện tại, vị trí đầu cửa sổ
## và số lần đã tìm lại đường.
var stuck_clock: float = 0.0
var stuck_anchor := Vector2.ZERO
var repaths: int = 0


func stop() -> void:
	moving = false
	arrived = false
	path = PackedVector2Array()
	path_index = 0
	flow = null
	reset_progress()


## Bắt đầu đếm tiến độ cho StuckWatch từ vị trí hiện tại.
func reset_progress() -> void:
	stuck_clock = 0.0
	stuck_anchor = position
	repaths = 0


func uses_flow() -> bool:
	return flow != null
