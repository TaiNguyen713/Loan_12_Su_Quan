extends GdUnitTestSuite
## S1.T06: RNG có seed theo trận.


func _draw_numbers(seed_value: int, stream_name: StringName, count: int) -> Array:
	RngService.start_match(seed_value)
	var rng := RngService.stream(stream_name)
	var numbers: Array = []
	for i in count:
		numbers.append(rng.randi())
	return numbers


func test_same_seed_gives_same_sequence() -> void:
	assert_array(_draw_numbers(42, &"combat", 20)).is_equal(_draw_numbers(42, &"combat", 20))


func test_S1_T06_TC2_different_seed_gives_different_sequence() -> void:
	assert_array(_draw_numbers(42, &"combat", 20)).is_not_equal(_draw_numbers(43, &"combat", 20))


func test_streams_are_independent() -> void:
	RngService.start_match(42)
	var solo: Array = []
	var combat := RngService.stream(&"combat")
	for i in 10:
		solo.append(combat.randi())

	RngService.start_match(42)
	RngService.stream(&"ai_1").randi()  # một hệ thống khác dùng RNG xen vào
	var mixed: Array = []
	var combat_again := RngService.stream(&"combat")
	for i in 10:
		mixed.append(combat_again.randi())
	assert_array(mixed).is_equal(solo)


func test_restore_continues_the_same_sequence() -> void:
	RngService.start_match(7)
	var rng := RngService.stream(&"mapgen")
	for i in 5:
		rng.randi()
	var saved := RngService.snapshot()
	var expected: Array = []
	for i in 5:
		expected.append(rng.randi())

	RngService.restore(saved)
	var after: Array = []
	var restored := RngService.stream(&"mapgen")
	for i in 5:
		after.append(restored.randi())
	assert_array(after).is_equal(expected)
