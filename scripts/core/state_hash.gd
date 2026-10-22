class_name StateHash
extends RefCounted
## FNV-1a 64 bit để so sánh trạng thái sim giữa hai lần chạy (S1.T06).
## Số nguyên GDScript là int64 và tràn số theo kiểu quay vòng, đúng với FNV.

const OFFSET: int = -3750763034362895579  # 0xcbf29ce484222325
const PRIME: int = 1099511628211  # 0x100000001b3
const FLOAT_SCALE: float = 16.0


static func add_byte(h: int, value: int) -> int:
	return (h ^ (value & 0xFF)) * PRIME


## Tám byte, byte thấp trước.
static func add_int(h: int, value: int) -> int:
	for shift in range(0, 64, 8):
		h = add_byte(h, value >> shift)
	return h


static func add_float(h: int, value: float) -> int:
	return add_int(h, roundi(value * FLOAT_SCALE))


static func add_string(h: int, text: String) -> int:
	for byte in text.to_utf8_buffer():
		h = add_byte(h, byte)
	return h


static func fnv_string(text: String) -> int:
	return add_string(OFFSET, text)


## snapshot: { tick, rng: {tên: state}, teams: [{res: [6 số]}], market: [6 giá],
## entities: [{id, x, y, hp, state, team}] }. Thứ tự đưa vào hash cố định nên kết quả
## không phụ thuộc thứ tự khóa hay thứ tự entity trong mảng.
static func compute(snapshot: Dictionary) -> int:
	var h := OFFSET
	h = add_int(h, int(snapshot.get("tick", 0)))

	var rng_states: Dictionary = snapshot.get("rng", {})
	var keys: Array = rng_states.keys()
	keys.sort()
	for key in keys:
		h = add_string(h, str(key))
		h = add_int(h, int(rng_states[key]))

	for team in snapshot.get("teams", []):
		var resources: Array = team.get("res", [])
		for amount in resources:
			h = add_float(h, float(amount))

	for price in snapshot.get("market", []):
		h = add_float(h, float(price))

	var entities: Array = snapshot.get("entities", []).duplicate()
	entities.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["id"]) < int(b["id"]))
	for entity in entities:
		h = add_int(h, int(entity["id"]))
		h = add_float(h, float(entity.get("x", 0.0)))
		h = add_float(h, float(entity.get("y", 0.0)))
		h = add_float(h, float(entity.get("hp", 0.0)))
		h = add_int(h, int(entity.get("state", 0)))
		h = add_int(h, int(entity.get("team", 0)))
	return h
