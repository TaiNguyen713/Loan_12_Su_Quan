extends GdUnitTestSuite
## S2.T04: đám đông qua một cầu hẹp trong trận mô phỏng đầy đủ.

const Grids = preload("res://tests/fixtures/grids.gd")

const MAX_SECONDS: float = 120.0
const MAX_TICKS: int = 120 * SimClock.TICKS_PER_SECOND


func _crowd(count: int) -> MatchSim:
	var sim := MatchSim.new()
	sim.setup_with_grid(Grids.wide_river_with_bridge())
	sim.spawn_group(0, count, Vector2(24 * 32.0, 9 * 32.0))
	var ids := PackedInt32Array()
	for unit in sim.units:
		ids.append(unit.id)
	sim.issue_move(0, ids, Vector2(24 * 32.0, 31 * 32.0))
	return sim


func _all_arrived(sim: MatchSim) -> bool:
	for unit in sim.units:
		if not unit.arrived:
			return false
	return true


func test_s2_t04_tc1_two_hundred_units_cross_a_two_wide_bridge_in_two_minutes() -> void:
	var sim := _crowd(200)
	assert_int(sim.units.size()).is_equal(200)
	var river_visits := 0
	var finished_at := -1
	for tick in MAX_TICKS:
		sim.step()
		for unit in sim.units:
			if sim.grid.get_terrain(sim.grid.cell_of(unit.position)) == Terrain.T.RIVER:
				river_visits += 1
		if _all_arrived(sim):
			finished_at = tick
			break
	assert_int(river_visits).is_equal(0)
	assert_bool(finished_at >= 0).is_true()
	assert_bool(finished_at / float(SimClock.TICKS_PER_SECOND) <= MAX_SECONDS).is_true()
	for unit in sim.units:
		assert_bool(unit.position.y > 21 * 32.0).is_true()


func test_nobody_gives_up_while_waiting_in_the_crowd() -> void:
	var sim := _crowd(120)
	for tick in MAX_TICKS:
		sim.step()
		if _all_arrived(sim):
			break
	var gave_up := 0
	for unit in sim.units:
		if not unit.arrived:
			gave_up += 1
	assert_int(gave_up).is_equal(0)


func test_units_that_finished_do_not_overlap_much() -> void:
	var sim := _crowd(60)
	for tick in MAX_TICKS:
		sim.step()
		if _all_arrived(sim):
			break
	var worst := INF
	for i in sim.units.size():
		for j in range(i + 1, sim.units.size()):
			var gap := sim.units[i].position.distance_to(sim.units[j].position)
			worst = minf(worst, gap / Avoidance.min_distance(sim.units[i], sim.units[j]))
	# Quân đã tới đích chỉ đẩy nhau khi gần hơn 0.6 lần khoảng cách chạm.
	assert_bool(worst >= 0.55).is_true()
