extends GdUnitTestSuite
## S2.T05: phép tính thuần của camera.

const BOUNDS := Rect2(-1000, 0, 3000, 2000)


func test_clamp_keeps_the_view_inside_bounds() -> void:
	var view := Vector2(800, 400)
	var clamped := CameraMath.clamp_center(Vector2(-5000, 5000), view, BOUNDS)
	assert_vector(clamped).is_equal(Vector2(-1000 + 400, 2000 - 200))


func test_clamp_leaves_a_center_that_is_already_inside() -> void:
	var inside := Vector2(300, 900)
	assert_vector(CameraMath.clamp_center(inside, Vector2(800, 400), BOUNDS)).is_equal(inside)


func test_view_larger_than_the_map_is_centered() -> void:
	var clamped := CameraMath.clamp_center(Vector2(0, 0), Vector2(5000, 4000), BOUNDS)
	assert_vector(clamped).is_equal(BOUNDS.get_center())


func test_s2_t05_tc6_zoom_keeps_the_point_under_the_cursor() -> void:
	var center := Vector2(400, 300)
	var cursor := Vector2(150, -80)
	var old_zoom := 1.0
	var new_zoom := 2.0
	var start_point := center + cursor / old_zoom
	var new_center := CameraMath.zoom_about(center, old_zoom, new_zoom, cursor)
	var end_point := new_center + cursor / new_zoom
	assert_vector(end_point).is_equal_approx(start_point, Vector2(0.001, 0.001))


func test_iso_bounds_of_a_map() -> void:
	var bounds := CameraMath.iso_bounds(Vector2(128 * 32, 96 * 32))
	assert_vector(bounds.position).is_equal(Vector2(-96 * 32, 0))
	assert_vector(bounds.size).is_equal(Vector2((128 + 96) * 32, (128 + 96) * 16))
