extends GdUnitTestSuite
## S1.T05: đồng hồ 20 Hz.


func test_ticks_for_rounds_up() -> void:
	assert_int(SimClock.ticks_for(0.05)).is_equal(1)
	assert_int(SimClock.ticks_for(1.0)).is_equal(20)
	assert_int(SimClock.ticks_for(0.06)).is_equal(2)
	assert_int(SimClock.ticks_for(0.0)).is_equal(0)


func test_ticks_for_is_not_fooled_by_float_error() -> void:
	# 0.15 * 20 = 3.0000000000000004 trong số thực
	assert_int(SimClock.ticks_for(0.15)).is_equal(3)


func test_advance_counts_ticks() -> void:
	var clock := SimClock.new()
	for i in 5:
		clock.advance()
	assert_int(clock.tick).is_equal(5)


func test_project_runs_the_sim_at_20_hz() -> void:
	assert_int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second")).is_equal(SimClock.TICKS_PER_SECOND)
