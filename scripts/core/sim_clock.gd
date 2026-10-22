class_name SimClock
extends RefCounted
## Đồng hồ mô phỏng 20 Hz (S1.T05). Sim chỉ tính thời gian bằng số tick, không đọc delta của frame.

const TICKS_PER_SECOND: int = 20
const DT: float = 1.0 / TICKS_PER_SECOND

var tick: int = 0


func advance() -> void:
	tick += 1


## Số tick tối thiểu để phủ hết `seconds`; sai số nhỏ tránh 0.15 × 20 = 3.0000000000000004 thành 4.
static func ticks_for(seconds: float) -> int:
	return ceili(seconds * TICKS_PER_SECOND - 0.000001)
