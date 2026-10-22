extends GdUnitTestSuite
## S2.T04: né tránh cục bộ.

const Grids = preload("res://tests/fixtures/grids.gd")

const DT := SimClock.DT


func _unit(id: int, position: Vector2, mass: float = 1.0) -> Unit:
	var unit := Unit.new()
	unit.id = id
	unit.position = position
	unit.previous_position = position
	unit.mass = mass
	return unit


func _open_grid() -> GridData:
	return GridData.new(40, 30)


func _smallest_gap(units: Array[Unit]) -> float:
	var smallest := INF
	for i in units.size():
		for j in range(i + 1, units.size()):
			var gap := units[i].position.distance_to(units[j].position)
			smallest = minf(smallest, gap / Avoidance.min_distance(units[i], units[j]))
	return smallest


func test_s2_t04_tc2_fifty_units_spawned_on_one_point_spread_out() -> void:
	var grid := _open_grid()
	var units: Array[Unit] = []
	for i in 50:
		units.append(_unit(i + 1, Vector2(640, 480)))
	for tick in 60:
		Avoidance.step(units, grid, DT)
	# Không cặp nào chồng nhau quá 10% khoảng cách tối thiểu.
	assert_bool(_smallest_gap(units) >= 0.9).is_true()


func test_two_overlapping_units_are_pushed_apart_equally() -> void:
	var grid := _open_grid()
	var a := _unit(1, Vector2(600, 480))
	var b := _unit(2, Vector2(606, 480))
	var units: Array[Unit] = [a, b]
	Avoidance.step(units, grid, DT)
	assert_float(a.position.x).is_less(600.0)
	assert_float(b.position.x).is_greater(606.0)
	assert_float(600.0 - a.position.x).is_equal_approx(b.position.x - 606.0, 0.0001)


func test_a_heavy_unit_pushes_a_light_unit_more() -> void:
	var grid := _open_grid()
	var light := _unit(1, Vector2(600, 480), 1.0)
	var heavy := _unit(2, Vector2(612, 480), 4.0)
	var units: Array[Unit] = [light, heavy]
	Avoidance.step(units, grid, DT)
	var light_moved := 600.0 - light.position.x
	var heavy_moved := heavy.position.x - 612.0
	assert_float(light_moved).is_equal_approx(heavy_moved * 4.0, 0.0001)


func test_arrived_units_that_only_touch_do_not_push_each_other() -> void:
	var grid := _open_grid()
	var a := _unit(1, Vector2(600, 480))
	var b := _unit(2, Vector2(612, 480))
	a.arrived = true
	b.arrived = true
	var units: Array[Unit] = [a, b]
	Avoidance.step(units, grid, DT)
	assert_vector(a.position).is_equal(Vector2(600, 480))
	assert_vector(b.position).is_equal(Vector2(612, 480))


func test_arrived_units_that_overlap_badly_still_separate() -> void:
	var grid := _open_grid()
	var a := _unit(1, Vector2(600, 480))
	var b := _unit(2, Vector2(603, 480))
	a.arrived = true
	b.arrived = true
	var units: Array[Unit] = [a, b]
	for tick in 20:
		Avoidance.step(units, grid, DT)
	var needed := Avoidance.min_distance(a, b) * Avoidance.ARRIVED_PAIR_FACTOR
	assert_bool(a.position.distance_to(b.position) >= needed - 0.01).is_true()


func test_an_arrived_unit_is_pushed_less_than_a_moving_one() -> void:
	var grid := _open_grid()
	var settled := _unit(1, Vector2(600, 480))
	var walker := _unit(2, Vector2(606, 480))
	settled.arrived = true
	var units: Array[Unit] = [settled, walker]
	Avoidance.step(units, grid, DT)
	assert_float(600.0 - settled.position.x).is_less(walker.position.x - 606.0)


func test_s2_t04_tc4_units_on_a_bridge_are_never_pushed_sideways() -> void:
	var grid := Grids.river_with_bridge()
	var bridge_x := 10.5 * 32.0
	var a := _unit(1, Vector2(bridge_x - 2, 9.5 * 32.0))
	var b := _unit(2, Vector2(bridge_x + 2, 9.5 * 32.0))
	var units: Array[Unit] = [a, b]
	Avoidance.step(units, grid, DT)
	assert_float(a.position.x).is_equal(bridge_x - 2)
	assert_float(b.position.x).is_equal(bridge_x + 2)
	# Nhưng vẫn bị đẩy dọc theo cầu khi chồng nhau theo trục y.
	var c := _unit(3, Vector2(bridge_x, 9.4 * 32.0))
	var d := _unit(4, Vector2(bridge_x, 9.4 * 32.0 + 4))
	Avoidance.step([c, d] as Array[Unit], grid, DT)
	assert_float(c.position.y).is_less(9.4 * 32.0)
	assert_float(d.position.y).is_greater(9.4 * 32.0 + 4)


func test_a_push_never_moves_a_unit_into_a_blocked_cell() -> void:
	var grid := _open_grid()
	for y in grid.height:
		grid.set_terrain(Vector2i(6, y), Terrain.T.FOREST)
	var edge := Vector2(6 * 32.0 - 1.0, 480)
	var near_wall := _unit(1, edge)
	var pusher := _unit(2, edge - Vector2(4, 0), 4.0)
	var units: Array[Unit] = [near_wall, pusher]
	for tick in 20:
		Avoidance.step(units, grid, DT)
	assert_bool(grid.point_walkable(near_wall.position)).is_true()
	assert_bool(grid.point_walkable(pusher.position)).is_true()


func test_two_units_on_exactly_the_same_point_split_in_opposite_directions() -> void:
	var grid := _open_grid()
	var a := _unit(1, Vector2(640, 480))
	var b := _unit(2, Vector2(640, 480))
	var units: Array[Unit] = [a, b]
	Avoidance.step(units, grid, DT)
	var middle := (a.position + b.position) * 0.5
	assert_vector(middle).is_equal_approx(Vector2(640, 480), Vector2(0.001, 0.001))
	assert_bool(a.position.distance_to(b.position) > 0.1).is_true()


func test_the_result_does_not_depend_on_random_numbers() -> void:
	var results: Array = []
	for run in 2:
		var grid := _open_grid()
		var units: Array[Unit] = []
		for i in 30:
			units.append(_unit(i + 1, Vector2(640, 480)))
		for tick in 30:
			Avoidance.step(units, grid, DT)
		results.append(units.map(func(u: Unit) -> Vector2: return u.position))
	assert_array(results[0]).is_equal(results[1])


func test_fewer_than_two_units_does_nothing() -> void:
	var lone := _unit(1, Vector2(100, 100))
	Avoidance.step([lone] as Array[Unit], _open_grid(), DT)
	assert_vector(lone.position).is_equal(Vector2(100, 100))
