extends GdUnitTestSuite
## S1.T01 / S1.T02: màn khởi động chuyển được sang scene trận rỗng bằng SceneRouter.


func test_S1_T01_TC1_boot_goes_to_the_empty_match_scene() -> void:
	var runner := scene_runner("res://scenes/boot/boot.tscn")
	await await_millis(1500)
	assert_str(get_tree().current_scene.name).is_equal("Match")
	runner.simulate_frames(5)
	var match_scene := get_tree().current_scene
	assert_int(match_scene.clock.tick).is_greater(0)
