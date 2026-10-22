class_name StuckWatch
extends RefCounted
## Phát hiện quân bị kẹt (S2.T04): đang có lệnh đi mà trong 2 giây chỉ nhích dưới 2 px thì
## tìm đường lại; sau 3 lần tìm lại vẫn kẹt thì thôi và đứng yên.

const WINDOW_SECONDS: float = 2.0
const MIN_PROGRESS: float = 2.0
const MAX_REPATHS: int = 3
const CHECK_EVERY: int = 5


## Mỗi quân chỉ được xét một lần trong CHECK_EVERY tick (so le theo id) để rẻ khi có hàng trăm quân.
static func step(units: Array[Unit], pathfinder: Pathfinder, dt: float, tick: int = 0) -> void:
	for unit in units:
		if unit.moving and (tick + unit.id) % CHECK_EVERY == 0:
			_watch(unit, pathfinder, dt * CHECK_EVERY)


static func _watch(unit: Unit, pathfinder: Pathfinder, dt: float) -> void:
	unit.stuck_clock += dt
	if unit.stuck_clock < WINDOW_SECONDS:
		return
	var progress := unit.position.distance_to(unit.stuck_anchor)
	unit.stuck_clock = 0.0
	unit.stuck_anchor = unit.position
	if progress >= MIN_PROGRESS:
		unit.repaths = 0
		return
	unit.repaths += 1
	if unit.repaths > MAX_REPATHS:
		unit.stop()
		return
	_repath(unit, pathfinder)


## Chuyển sang đường A* riêng của quân này, dù trước đó đi theo flow field.
static func _repath(unit: Unit, pathfinder: Pathfinder) -> void:
	unit.flow = null
	unit.path = pathfinder.find_path(unit.position, unit.destination, unit.water, unit.large)
	unit.path_index = 0
	if unit.path.is_empty():
		unit.stop()
