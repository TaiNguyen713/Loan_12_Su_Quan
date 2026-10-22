extends Node
## Mọi số ngẫu nhiên trong sim, AI và sinh bản đồ phải lấy qua đây (S1.T06).
## Mỗi hệ thống dùng một stream riêng để thêm hoặc bớt hệ thống này không làm lệch hệ thống khác.

var match_seed: int = 0

var _streams: Dictionary = {}


func start_match(seed_value: int) -> void:
	match_seed = seed_value
	_streams.clear()


func stream(stream_name: StringName) -> RandomNumberGenerator:
	var key := String(stream_name)
	if not _streams.has(key):
		var rng := RandomNumberGenerator.new()
		rng.seed = StateHash.fnv_string("%d:%s" % [match_seed, key])
		_streams[key] = rng
	return _streams[key]


## state của từng stream, dùng cho StateHash và lưu game.
func snapshot() -> Dictionary:
	var states := {}
	for key in _streams:
		var rng: RandomNumberGenerator = _streams[key]
		states[key] = rng.state
	return states


func restore(states: Dictionary) -> void:
	_streams.clear()
	for key in states:
		var rng := RandomNumberGenerator.new()
		rng.state = int(states[key])
		_streams[String(key)] = rng
