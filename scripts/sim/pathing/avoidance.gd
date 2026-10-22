class_name Avoidance
extends RefCounted
## Né tránh cục bộ (S2.T04): mỗi tick đẩy các quân đang chồng lên nhau ra xa.
## Spatial hash ô 32 px (lớn hơn khoảng cách chạm nên chỉ cần xét 3×3 ô); quân nặng đẩy quân nhẹ.
## Quân đã tới đích khó bị đẩy và chỉ đẩy nhau khi chồng nặng, để đám đông đã dàn xong không rung.

const HASH_CELL: float = 32.0
const HASH_ROW: int = 4096
## Hai quân chạm nhau khi khoảng cách nhỏ hơn 0.9 × tổng bán kính.
const OVERLAP_FACTOR: float = 0.9
const ARRIVED_MASS_FACTOR: float = 4.0
## Hai quân đã tới đích chỉ đẩy nhau khi gần hơn 0.6 × khoảng cách chạm thông thường.
const ARRIVED_PAIR_FACTOR: float = 0.6
static var _no_bucket := PackedInt32Array()


static func step(units: Array[Unit], grid: GridData, dt: float) -> void:
	var count := units.size()
	if count < 2:
		return
	var positions := PackedVector2Array()
	var radii := PackedFloat32Array()
	var masses := PackedFloat32Array()
	var arrived := PackedByteArray()
	var ids := PackedInt32Array()
	positions.resize(count)
	radii.resize(count)
	masses.resize(count)
	arrived.resize(count)
	ids.resize(count)
	var buckets := {}
	for i in count:
		var unit := units[i]
		positions[i] = unit.position
		ids[i] = unit.id
		radii[i] = unit.radius
		arrived[i] = 1 if unit.arrived else 0
		masses[i] = unit.mass * (ARRIVED_MASS_FACTOR if unit.arrived else 1.0)
		var key := _bucket_key(unit.position)
		if buckets.has(key):
			var existing: PackedInt32Array = buckets[key]
			existing.append(i)
		else:
			var created := PackedInt32Array()
			created.append(i)
			buckets[key] = created

	var pushes := PackedVector2Array()
	pushes.resize(count)
	for i in count:
		_accumulate(i, positions, radii, masses, arrived, ids, buckets, pushes)
	for i in count:
		var push := pushes[i]
		if push == Vector2.ZERO:
			continue
		# Trên cầu chỉ đẩy dọc theo cầu (trục y), không đẩy ngang để khỏi rớt xuống sông.
		if _on_bridge(grid, positions[i]):
			push.x = 0.0
		var limit := units[i].speed * dt
		if push.length_squared() > limit * limit:
			push = push.normalized() * limit
		_apply(units[i], push, grid)


## Khoảng cách tối thiểu giữa hai quân trước khi chúng đẩy nhau.
static func min_distance(a: Unit, b: Unit) -> float:
	return (a.radius + b.radius) * OVERLAP_FACTOR


static func _bucket_key(point: Vector2) -> int:
	return (floori(point.y / HASH_CELL) + 1) * HASH_ROW + floori(point.x / HASH_CELL) + 1


static func _on_bridge(grid: GridData, point: Vector2) -> bool:
	return grid.get_terrain(grid.cell_of(point)) == Terrain.T.BRIDGE


## Cộng lực đẩy của mọi cặp (index, j) với j > index vào cả hai quân, nên mỗi cặp chỉ tính một lần.
static func _accumulate(
	index: int,
	positions: PackedVector2Array,
	radii: PackedFloat32Array,
	masses: PackedFloat32Array,
	arrived: PackedByteArray,
	ids: PackedInt32Array,
	buckets: Dictionary,
	pushes: PackedVector2Array
) -> void:
	var here := positions[index]
	var home := _bucket_key(here)
	for row in range(-1, 2):
		for column in range(-1, 2):
			var bucket: PackedInt32Array = buckets.get(home + row * HASH_ROW + column, _no_bucket)
			for other in bucket:
				if other <= index:
					continue
				var offset := here - positions[other]
				var min_dist := (radii[index] + radii[other]) * OVERLAP_FACTOR
				if arrived[index] == 1 and arrived[other] == 1:
					min_dist *= ARRIVED_PAIR_FACTOR
				var dist_sq := offset.length_squared()
				if dist_sq >= min_dist * min_dist:
					continue
				var dist := sqrt(dist_sq)
				var direction := (
					offset / dist if dist >= 0.01 else _tie_break(ids[index], ids[other])
				)
				var overlap := min_dist - dist
				var total_mass := masses[index] + masses[other]
				pushes[index] += direction * overlap * masses[other] / total_mass
				pushes[other] -= direction * overlap * masses[index] / total_mass


## Hai quân trùng hẳn một chỗ: chọn hướng từ id của chúng, không dùng số ngẫu nhiên.
static func _tie_break(unit_id: int, other_id: int) -> Vector2:
	return Vector2.from_angle(deg_to_rad(float((unit_id * 37 + other_id * 91) % 360)))


static func _apply(unit: Unit, push: Vector2, grid: GridData) -> void:
	if push == Vector2.ZERO:
		return
	var candidates: Array[Vector2] = [
		unit.position + push,
		unit.position + Vector2(push.x, 0.0),
		unit.position + Vector2(0.0, push.y),
	]
	for candidate in candidates:
		if grid.point_walkable(candidate, unit.water, unit.large):
			unit.position = candidate
			return
