class_name UnitsView
extends Node2D
## Vẽ đơn vị bằng hình tròn tạm (chưa có sprite, S11), nội suy giữa hai tick.

const TEAM_COLORS: Array[Color] = [Color("f4c62a"), Color("d42e28")]
const OUTLINE := Color(0.08, 0.06, 0.05, 0.9)
const MARKER_LIFETIME: float = 1.2

var sim: MatchSim
var marker: Vector2 = Vector2.ZERO
var marker_age: float = MARKER_LIFETIME


func _ready() -> void:
	# UnitsView tự nội suy vị trí quân khi vẽ.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


func _process(delta: float) -> void:
	marker_age += delta
	queue_redraw()


## Đánh dấu điểm vừa ra lệnh (vòng tròn thu nhỏ dần).
func show_marker(sim_position: Vector2) -> void:
	marker = sim_position
	marker_age = 0.0


func _draw() -> void:
	if sim == null:
		return
	if marker_age < MARKER_LIFETIME:
		var t := marker_age / MARKER_LIFETIME
		var center := Iso.to_screen(marker)
		_draw_ring(center, 26.0 * (1.0 - t) + 6.0, Color(1, 1, 1, 1.0 - t))
	var blend := Engine.get_physics_interpolation_fraction()
	var screen_points: Array[Dictionary] = []
	for unit in sim.units:
		var point := Iso.to_screen(unit.previous_position.lerp(unit.position, blend))
		screen_points.append({"point": point, "unit": unit})
	screen_points.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool: return a["point"].y < b["point"].y
	)
	for entry in screen_points:
		var unit: Unit = entry["unit"]
		var point: Vector2 = entry["point"]
		draw_set_transform(point, 0.0, Vector2(1.0, 0.5))
		draw_circle(Vector2(2, 3), unit.radius + 1.0, Color(0, 0, 0, 0.3))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var color: Color = TEAM_COLORS[unit.team % TEAM_COLORS.size()]
		draw_circle(point + Vector2(0, -unit.radius * 0.8), unit.radius, OUTLINE)
		draw_circle(point + Vector2(0, -unit.radius * 0.8), unit.radius - 1.5, color)


func _draw_ring(center: Vector2, radius: float, color: Color) -> void:
	draw_set_transform(center, 0.0, Vector2(1.0, 0.5))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, color, 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
