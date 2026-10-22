class_name CommandQueue
extends RefCounted
## Hàng đợi lệnh theo tick (S1.T06). Lệnh xếp theo (tick, thứ tự đẩy vào);
## lệnh đã áp dụng được ghi vào history để phát lại.

## Các lệnh đã áp dụng theo thứ tự, ở dạng Dictionary (Command.to_dict).
var history: Array[Dictionary] = []

var _pending: Array[Command] = []
var _next_seq: int = 0


## Lệnh luôn có hiệu lực từ tick kế tiếp trở đi, không bao giờ trong quá khứ.
func push(cmd: Command, current_tick: int) -> void:
	cmd.tick = maxi(cmd.tick, current_tick + 1)
	cmd.seq = _next_seq
	_next_seq += 1
	var index := _pending.size()
	while index > 0 and _pending[index - 1].tick > cmd.tick:
		index -= 1
	_pending.insert(index, cmd)


## Lấy các lệnh đến hạn (tick <= current_tick) theo đúng thứ tự áp dụng.
func pop_due(current_tick: int) -> Array[Command]:
	var due: Array[Command] = []
	while not _pending.is_empty() and _pending[0].tick <= current_tick:
		var cmd: Command = _pending.pop_front()
		due.append(cmd)
		history.append(cmd.to_dict())
	return due


func pending_count() -> int:
	return _pending.size()
