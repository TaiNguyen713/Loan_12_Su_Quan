class_name MinHeap
extends RefCounted
## Hàng đợi ưu tiên nhị phân (nhỏ nhất ra trước) cho Dijkstra của flow field (S2.T03).

## Độ ưu tiên của phần tử vừa được pop().
var last_priority: float = 0.0

var _priorities := PackedFloat32Array()
var _values := PackedInt32Array()


func is_empty() -> bool:
	return _values.is_empty()


func size() -> int:
	return _values.size()


func push(priority: float, value: int) -> void:
	_priorities.append(priority)
	_values.append(value)
	var index := _values.size() - 1
	while index > 0:
		var parent := (index - 1) >> 1
		if _priorities[parent] <= _priorities[index]:
			break
		_swap(index, parent)
		index = parent


## Lấy giá trị có độ ưu tiên nhỏ nhất; độ ưu tiên đó nằm ở last_priority.
func pop() -> int:
	var top := _values[0]
	last_priority = _priorities[0]
	var last := _values.size() - 1
	_priorities[0] = _priorities[last]
	_values[0] = _values[last]
	_priorities.resize(last)
	_values.resize(last)
	var index := 0
	while true:
		var left := index * 2 + 1
		var right := left + 1
		var smallest := index
		if left < last and _priorities[left] < _priorities[smallest]:
			smallest = left
		if right < last and _priorities[right] < _priorities[smallest]:
			smallest = right
		if smallest == index:
			break
		_swap(index, smallest)
		index = smallest
	return top


func _swap(a: int, b: int) -> void:
	var priority := _priorities[a]
	_priorities[a] = _priorities[b]
	_priorities[b] = priority
	var value := _values[a]
	_values[a] = _values[b]
	_values[b] = value
