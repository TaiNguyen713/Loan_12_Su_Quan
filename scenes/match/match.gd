extends Node2D
## Scene trận. S2: bản đồ "Hai đàng", quân demo, camera và minimap; chưa có kinh tế hay chiến đấu.

const DEMO_PLAYER_UNITS: int = 40
const DEMO_ENEMY_UNITS: int = 20

var sim: MatchSim
var clock: SimClock
var terrain_view: TerrainView
var units_view: UnitsView
var camera: CameraController
var hud: MatchHud
var orders: DemoOrders


func _ready() -> void:
	RngService.start_match(Session.match_seed)
	sim = MatchSim.new()
	sim.setup(RngService.stream(&"mapgen"))
	clock = sim.clock
	var north := sim.grid.cell_center(MapGen.base_cell(sim.grid, true))
	var south := sim.grid.cell_center(MapGen.base_cell(sim.grid, false))
	sim.spawn_group(0, DEMO_PLAYER_UNITS, north)
	sim.spawn_group(1, DEMO_ENEMY_UNITS, south)

	terrain_view = TerrainView.new()
	add_child(terrain_view)
	terrain_view.setup(sim.grid)

	units_view = UnitsView.new()
	units_view.sim = sim
	add_child(units_view)

	camera = CameraController.new()
	add_child(camera)
	camera.set_bounds(sim.grid.pixel_size())
	camera.position = Iso.to_screen(north)
	camera.make_current()

	orders = DemoOrders.new()
	orders.sim = sim
	orders.order_issued.connect(units_view.show_marker)
	add_child(orders)

	hud = MatchHud.new()
	add_child(hud)
	hud.setup(sim, camera)
	hud.minimap.jump_requested.connect(camera.jump_to_sim)


func _physics_process(_delta: float) -> void:
	for cmd in sim.step():
		EventBus.command_issued.emit(cmd)


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and key.keycode == KEY_ESCAPE:
		get_tree().quit()
