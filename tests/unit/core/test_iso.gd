extends GdUnitTestSuite
## S2.T01: phép chiếu giữa không gian sim và màn hình isometric.


func test_known_points() -> void:
	assert_vector(Iso.to_screen(Vector2(64, 0))).is_equal(Vector2(64, 32))
	assert_vector(Iso.to_screen(Vector2(0, 64))).is_equal(Vector2(-64, 32))
	assert_vector(Iso.to_screen(Vector2(32, 32))).is_equal(Vector2(0, 32))


func test_s2_t01_tc3_round_trip_for_1000_random_points() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in 1000:
		var point := Vector2(rng.randf_range(0, 4096), rng.randf_range(0, 3072))
		var back := Iso.to_sim(Iso.to_screen(point))
		assert_float(back.distance_to(point)).is_less(0.001)
