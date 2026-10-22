class_name CameraMath
extends RefCounted
## Phép tính thuần cho camera (S2.T05): kẹp biên và zoom quanh một điểm.


## Kẹp tâm camera sao cho khung nhìn không ra khỏi `bounds`; khung lớn hơn bản đồ thì căn giữa.
static func clamp_center(center: Vector2, view_size: Vector2, bounds: Rect2) -> Vector2:
	var result := center
	var half := view_size * 0.5
	if view_size.x >= bounds.size.x:
		result.x = bounds.get_center().x
	else:
		result.x = clampf(center.x, bounds.position.x + half.x, bounds.end.x - half.x)
	if view_size.y >= bounds.size.y:
		result.y = bounds.get_center().y
	else:
		result.y = clampf(center.y, bounds.position.y + half.y, bounds.end.y - half.y)
	return result


## Tâm camera mới sau khi đổi zoom sao cho điểm thế giới dưới con trỏ đứng yên.
## `cursor_offset` là vị trí con trỏ so với giữa màn hình, tính bằng px màn hình.
static func zoom_about(
	center: Vector2, old_zoom: float, new_zoom: float, cursor_offset: Vector2
) -> Vector2:
	return center + cursor_offset / old_zoom - cursor_offset / new_zoom


## Hình chữ nhật bao quanh bản đồ sau khi chiếu isometric, để kẹp camera.
static func iso_bounds(map_pixel_size: Vector2) -> Rect2:
	var corners: Array[Vector2] = [
		Iso.to_screen(Vector2.ZERO),
		Iso.to_screen(Vector2(map_pixel_size.x, 0.0)),
		Iso.to_screen(Vector2(0.0, map_pixel_size.y)),
		Iso.to_screen(map_pixel_size),
	]
	var bounds := Rect2(corners[0], Vector2.ZERO)
	for corner in corners:
		bounds = bounds.expand(corner)
	return bounds
