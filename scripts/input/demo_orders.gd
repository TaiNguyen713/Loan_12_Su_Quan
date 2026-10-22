class_name DemoOrders
extends Node
## Điều khiển tạm cho bản chơi thử S2: chuột trái ra lệnh đi cho toàn bộ quân của phe người chơi.
## Sẽ được thay bằng chọn quân và bộ lệnh thật ở S3.

signal order_issued(sim_position: Vector2)

const PLAYER_TEAM: int = 0

var sim: MatchSim


## Điểm màn hình (toạ độ khung nhìn) -> toạ độ sim, theo camera hiện tại.
func screen_to_sim(screen_position: Vector2) -> Vector2:
	var world := get_viewport().get_canvas_transform().affine_inverse() * screen_position
	return Iso.to_sim(world)


func order_all_to(sim_position: Vector2) -> void:
	var ids := PackedInt32Array()
	for unit in sim.units:
		if unit.team == PLAYER_TEAM:
			ids.append(unit.id)
	if ids.is_empty():
		return
	sim.issue_move(PLAYER_TEAM, ids, sim_position)
	order_issued.emit(sim_position)


func _unhandled_input(event: InputEvent) -> void:
	if sim == null or not (event is InputEventMouseButton):
		return
	var click := event as InputEventMouseButton
	if click.button_index == MOUSE_BUTTON_LEFT and click.pressed:
		var target := screen_to_sim(click.position)
		if sim.grid.in_bounds(sim.grid.cell_of(target)):
			order_all_to(target)
