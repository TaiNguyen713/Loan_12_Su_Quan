extends GdUnitTestSuite
## S2.T06: minimap và HUD của trận.

const Grids = preload("res://tests/fixtures/grids.gd")


func _hud() -> MatchHud:
	var sim := MatchSim.new()
	sim.setup_with_grid(Grids.river_with_bridge())
	sim.spawn_group(0, 5, Vector2(6 * 32.0, 3.5 * 32.0))
	var camera := CameraController.new()
	add_child(auto_free(camera))
	camera.set_bounds(sim.grid.pixel_size())
	var hud := MatchHud.new()
	add_child(auto_free(hud))
	hud.setup(sim, camera)
	return hud


func _click(position: Vector2, pressed: bool = true) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = pressed
	return event


func test_s2_t06_tc1_minimap_is_120_pt_square_at_the_bottom_left() -> void:
	var hud := _hud()
	var unit := hud.pt()
	var view := hud.get_viewport().get_visible_rect().size
	assert_vector(hud.minimap.size).is_equal_approx(Vector2(120, 120) * unit, Vector2(0.01, 0.01))
	assert_float(hud.minimap.position.x).is_equal_approx(104.0 * unit, 0.01)
	assert_float(hud.minimap.position.y + hud.minimap.size.y).is_equal_approx(
		view.y - 12.0 * unit, 0.01
	)


func test_map_is_letterboxed_with_the_grid_aspect_ratio() -> void:
	var hud := _hud()
	var rect := hud.minimap.map_rect()
	assert_float(rect.size.x / rect.size.y).is_equal_approx(24.0 / 20.0, 0.001)
	assert_bool(Rect2(Vector2.ZERO, hud.minimap.size).encloses(rect)).is_true()


func test_s2_t06_tc2_click_in_the_middle_jumps_to_the_middle_of_the_map() -> void:
	var hud := _hud()
	var minimap := hud.minimap
	var requests: Array = []
	minimap.jump_requested.connect(func(point: Vector2) -> void: requests.append(point))
	minimap._gui_input(_click(minimap.size * 0.5))
	assert_int(requests.size()).is_equal(1)
	assert_vector(requests[0]).is_equal_approx(
		minimap.sim.grid.pixel_size() * 0.5, Vector2(0.5, 0.5)
	)


func test_s2_t06_tc3_dragging_keeps_sending_positions_until_release() -> void:
	var hud := _hud()
	var minimap := hud.minimap
	var requests: Array = []
	minimap.jump_requested.connect(func(point: Vector2) -> void: requests.append(point))
	minimap._gui_input(_click(Vector2(20, 20)))
	var motion := InputEventMouseMotion.new()
	motion.position = Vector2(60, 60)
	minimap._gui_input(motion)
	minimap._gui_input(_click(Vector2(60, 60), false))
	motion.position = Vector2(80, 80)
	minimap._gui_input(motion)
	assert_int(requests.size()).is_equal(2)


func test_click_outside_the_map_is_clamped_to_its_edge() -> void:
	var hud := _hud()
	var minimap := hud.minimap
	var point := minimap.local_to_sim(Vector2(-500, -500))
	assert_vector(point).is_equal(Vector2.ZERO)


func test_local_and_sim_conversions_round_trip() -> void:
	var hud := _hud()
	var minimap := hud.minimap
	var sim_point := Vector2(300, 400)
	assert_vector(minimap.local_to_sim(minimap.sim_to_local(sim_point))).is_equal_approx(
		sim_point, Vector2(0.01, 0.01)
	)
