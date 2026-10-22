extends GdUnitTestSuite
## S2.T04: phát hiện quân kẹt và tìm đường lại.

const Grids = preload("res://tests/fixtures/grids.gd")

const WINDOW_TICKS := 40  # 2 giây ở 20 Hz

var _tick: int = 0


func _setup() -> Array:
	var grid := Grids.river_with_bridge()
	var pathfinder := Pathfinder.new(grid)
	var unit := Unit.new()
	unit.id = 1
	unit.position = Vector2(4.5 * 32, 2.5 * 32)
	unit.destination = Vector2(4.5 * 32, 17.5 * 32)
	unit.path = pathfinder.find_path(unit.position, unit.destination)
	unit.moving = true
	unit.reset_progress()
	return [pathfinder, unit]


func before_test() -> void:
	_tick = 0


func _run_ticks(units: Array[Unit], pathfinder: Pathfinder, ticks: int) -> void:
	for step in ticks:
		StuckWatch.step(units, pathfinder, SimClock.DT, _tick)
		_tick += 1


func test_a_unit_that_does_not_move_is_repathed_after_two_seconds() -> void:
	var parts := _setup()
	var pathfinder: Pathfinder = parts[0]
	var unit: Unit = parts[1]
	var units: Array[Unit] = [unit]
	_run_ticks(units, pathfinder, WINDOW_TICKS - 1)
	assert_int(unit.repaths).is_equal(0)
	_run_ticks(units, pathfinder, 1)
	assert_int(unit.repaths).is_equal(1)
	assert_bool(unit.moving).is_true()


func test_after_three_repaths_a_still_stuck_unit_gives_up() -> void:
	var parts := _setup()
	var pathfinder: Pathfinder = parts[0]
	var unit: Unit = parts[1]
	var units: Array[Unit] = [unit]
	_run_ticks(units, pathfinder, WINDOW_TICKS * 3)
	assert_int(unit.repaths).is_equal(3)
	assert_bool(unit.moving).is_true()
	_run_ticks(units, pathfinder, WINDOW_TICKS)
	assert_bool(unit.moving).is_false()
	assert_bool(unit.arrived).is_false()


func test_making_progress_resets_the_repath_counter() -> void:
	var parts := _setup()
	var pathfinder: Pathfinder = parts[0]
	var unit: Unit = parts[1]
	var units: Array[Unit] = [unit]
	_run_ticks(units, pathfinder, WINDOW_TICKS * 2)
	assert_int(unit.repaths).is_equal(2)
	unit.position += Vector2(30, 0)
	_run_ticks(units, pathfinder, WINDOW_TICKS)
	assert_int(unit.repaths).is_equal(0)


func test_a_repath_moves_a_flow_follower_onto_its_own_astar_path() -> void:
	var parts := _setup()
	var pathfinder: Pathfinder = parts[0]
	var unit: Unit = parts[1]
	unit.flow = pathfinder.flow_field(unit.destination)
	unit.path = PackedVector2Array()
	var units: Array[Unit] = [unit]
	_run_ticks(units, pathfinder, WINDOW_TICKS)
	assert_object(unit.flow).is_null()
	assert_bool(unit.path.size() > 0).is_true()


func test_an_unreachable_destination_stops_the_unit_at_the_first_check() -> void:
	var parts := _setup()
	var pathfinder: Pathfinder = parts[0]
	var unit: Unit = parts[1]
	for y in pathfinder.grid.height:
		for x in pathfinder.grid.width:
			pathfinder.grid.set_terrain(Vector2i(x, y), Terrain.T.FOREST)
	var units: Array[Unit] = [unit]
	_run_ticks(units, pathfinder, WINDOW_TICKS)
	assert_bool(unit.moving).is_false()


func test_idle_units_are_ignored() -> void:
	var parts := _setup()
	var pathfinder: Pathfinder = parts[0]
	var unit: Unit = parts[1]
	unit.stop()
	var units: Array[Unit] = [unit]
	_run_ticks(units, pathfinder, WINDOW_TICKS * 5)
	assert_int(unit.repaths).is_equal(0)
