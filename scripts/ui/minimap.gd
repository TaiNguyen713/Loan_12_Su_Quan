class_name Minimap
extends Control
## Minimap vuông (S2.T06): bản đồ nhìn từ trên xuống, khung camera, quân hai phe.
## Chạm hoặc kéo trên minimap để đưa camera tới đó; sự kiện không lọt xuống bản đồ chính.

signal jump_requested(sim_position: Vector2)

const TEAM_COLORS: Array[Color] = [Color("f4c62a"), Color("d42e28")]
const FRAME_COLOR := Color(0.55, 0.5, 0.35)
const VIEW_COLOR := Color(1, 1, 1, 0.9)

var sim: MatchSim
var camera: Camera2D

var _texture: ImageTexture
var _dragging: bool = false


func setup(p_sim: MatchSim, p_camera: Camera2D) -> void:
	sim = p_sim
	camera = p_camera
	mouse_filter = Control.MOUSE_FILTER_STOP
	_texture = ImageTexture.create_from_image(_terrain_image())


## Vùng chứa bản đồ bên trong ô vuông, giữ đúng tỉ lệ rộng : cao của lưới.
func map_rect() -> Rect2:
	var scale_factor := minf(size.x / sim.grid.width, size.y / sim.grid.height)
	var map_size := Vector2(sim.grid.width, sim.grid.height) * scale_factor
	return Rect2((size - map_size) * 0.5, map_size)


## Điểm trong control (px cục bộ) -> toạ độ sim; kẹp vào trong bản đồ.
func local_to_sim(local: Vector2) -> Vector2:
	var rect := map_rect()
	var ratio := ((local - rect.position) / rect.size).clamp(Vector2.ZERO, Vector2.ONE)
	return ratio * sim.grid.pixel_size()


func sim_to_local(sim_position: Vector2) -> Vector2:
	var rect := map_rect()
	return rect.position + sim_position / sim.grid.pixel_size() * rect.size


func _process(_delta: float) -> void:
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_LEFT:
			_dragging = button.pressed
			if button.pressed:
				jump_requested.emit(local_to_sim(button.position))
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		jump_requested.emit(local_to_sim((event as InputEventMouseMotion).position))
		accept_event()


func _draw() -> void:
	if sim == null:
		return
	var rect := map_rect()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.05, 0.05, 0.85))
	draw_texture_rect(_texture, rect, false)
	for unit in sim.units:
		var point := sim_to_local(unit.position)
		draw_rect(Rect2(point - Vector2(1.5, 1.5), Vector2(3, 3)), TEAM_COLORS[unit.team % 2])
	_draw_camera_view()
	draw_rect(Rect2(Vector2.ZERO, size), FRAME_COLOR, false, 2.0)


## Khung nhìn của camera là một hình thoi nghiêng khi quy về không gian sim.
func _draw_camera_view() -> void:
	if camera == null:
		return
	var half := get_viewport_rect().size / camera.zoom.x * 0.5
	var screen_corners: Array[Vector2] = [
		camera.position + Vector2(-half.x, -half.y),
		camera.position + Vector2(half.x, -half.y),
		camera.position + Vector2(half.x, half.y),
		camera.position + Vector2(-half.x, half.y),
	]
	var points := PackedVector2Array()
	for corner in screen_corners:
		points.append(sim_to_local(Iso.to_sim(corner)))
	points.append(points[0])
	draw_polyline(points, VIEW_COLOR, 1.5)


func _terrain_image() -> Image:
	var image := Image.create_empty(sim.grid.width, sim.grid.height, false, Image.FORMAT_RGBA8)
	for y in sim.grid.height:
		for x in sim.grid.width:
			var value := sim.grid.get_terrain(Vector2i(x, y))
			image.set_pixel(x, y, TerrainTiles.COLORS[value])
	return image
