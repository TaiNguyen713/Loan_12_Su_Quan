class_name MatchHud
extends CanvasLayer
## HUD tạm cho bản chơi thử S2: minimap, gợi ý điều khiển, FPS và thông tin tick.
## Kích thước tính theo "pt" của khung tham chiếu 844×390 (xem docs/GAME_DESIGN.md §12).

const REFERENCE_HEIGHT: float = 390.0
const SAFE_MARGIN_PT: float = 44.0
const MINIMAP_PT: float = 120.0
const MINIMAP_LEFT_PT: float = 104.0
const MINIMAP_BOTTOM_PT: float = 12.0

var minimap: Minimap
var sim: MatchSim

var _info := Label.new()
var _help := Label.new()


func setup(p_sim: MatchSim, camera: Camera2D) -> void:
	sim = p_sim
	minimap = Minimap.new()
	minimap.setup(sim, camera)
	add_child(minimap)
	_help.text = (
		"Chuột trái: đi tới đó (cả quân vàng)   Chuột phải kéo / WASD: cuộn\n"
		+ "Lăn chuột: zoom   Minimap: chạm để nhảy   Esc: thoát"
	)
	_style(_help, 14)
	_style(_info, 13)
	add_child(_help)
	add_child(_info)
	get_viewport().size_changed.connect(_layout)
	_layout()


## Số px của 1 pt ở độ phân giải hiện tại.
func pt() -> float:
	return get_viewport().get_visible_rect().size.y / REFERENCE_HEIGHT


func _process(_delta: float) -> void:
	_info.text = (
		"FPS %d · tick %d · %d quân · tìm đường: %s"
		% [
			Engine.get_frames_per_second(),
			sim.clock.tick,
			sim.units.size(),
			sim.last_move_mode if sim.last_move_mode != "" else "—",
		]
	)


func _layout() -> void:
	var unit := pt()
	var view := get_viewport().get_visible_rect().size
	var side := MINIMAP_PT * unit
	minimap.size = Vector2(side, side)
	minimap.position = Vector2(MINIMAP_LEFT_PT * unit, view.y - (MINIMAP_BOTTOM_PT * unit) - side)
	_help.position = Vector2(SAFE_MARGIN_PT * unit, 8.0 * unit)
	_info.position = Vector2(SAFE_MARGIN_PT * unit, view.y - 20.0 * unit)
	_info.reset_size()


func _style(label: Label, font_size: int) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
