extends GdUnitTestSuite
## S2.T03: quân đi qua cầu trong một trận mô phỏng đầy đủ (lệnh -> hàng đợi -> di chuyển).

const Grids = preload("res://tests/fixtures/grids.gd")

const SOUTH := Vector2(12 * 32.0, 17.5 * 32.0)
const MAX_TICKS: int = 60 * SimClock.TICKS_PER_SECOND


func _sim_with_units(count: int) -> MatchSim:
	var sim := MatchSim.new()
	sim.setup_with_grid(Grids.river_with_bridge())
	sim.spawn_group(0, count, Vector2(6 * 32.0, 3.5 * 32.0))
	return sim


func _order_all_south(sim: MatchSim) -> void:
	var ids := PackedInt32Array()
	for unit in sim.units:
		ids.append(unit.id)
	sim.issue_move(0, ids, SOUTH)


func _run_until_all_stop(sim: MatchSim) -> int:
	var river_visits := 0
	for tick in MAX_TICKS:
		sim.step()
		var any_moving := false
		for unit in sim.units:
			any_moving = any_moving or unit.moving
			if sim.grid.get_terrain(sim.grid.cell_of(unit.position)) == Terrain.T.RIVER:
				river_visits += 1
		if not any_moving:
			break
	return river_visits


func test_a_small_group_uses_astar_and_crosses_the_bridge() -> void:
	var sim := _sim_with_units(3)
	_order_all_south(sim)
	var river_visits := _run_until_all_stop(sim)
	assert_str(sim.last_move_mode).is_equal("A*")
	assert_int(river_visits).is_equal(0)
	for unit in sim.units:
		assert_bool(unit.moving).is_false()
		assert_bool(unit.position.y > 11 * 32.0).is_true()


func test_a_big_group_uses_a_flow_field_and_all_arrive_south_without_touching_the_river() -> void:
	var sim := _sim_with_units(12)
	_order_all_south(sim)
	var river_visits := _run_until_all_stop(sim)
	assert_str(sim.last_move_mode).is_equal("flow field")
	assert_int(river_visits).is_equal(0)
	for unit in sim.units:
		assert_bool(unit.moving).is_false()
		assert_bool(unit.position.y > 11 * 32.0).is_true()
		assert_bool(unit.position.distance_to(SOUTH) < 12 * 14.0).is_true()


func test_a_command_takes_effect_on_the_next_tick() -> void:
	var sim := _sim_with_units(3)
	_order_all_south(sim)
	assert_bool(sim.units[0].moving).is_false()
	var applied := sim.step()
	assert_int(applied.size()).is_equal(1)
	assert_bool(sim.units[0].moving).is_true()


func test_the_same_orders_give_the_same_state_hash() -> void:
	var hashes: Array = []
	for run in 2:
		var sim := _sim_with_units(12)
		_order_all_south(sim)
		for tick in 400:
			sim.step()
		hashes.append(StateHash.compute(sim.snapshot()))
	assert_int(hashes[0]).is_equal(hashes[1])


func test_units_cannot_walk_through_a_wall_of_forest() -> void:
	var sim := _sim_with_units(3)
	for x in sim.grid.width:
		sim.grid.set_terrain(Vector2i(x, 13), Terrain.T.FOREST)
	_order_all_south(sim)
	_run_until_all_stop(sim)
	for unit in sim.units:
		assert_bool(unit.position.y < 13 * 32.0).is_true()
