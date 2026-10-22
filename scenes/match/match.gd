extends Node2D
## Scene trận. Giai đoạn S1: chỉ chạy vòng tick cố định 20 Hz, chưa có thực thể.

var clock := SimClock.new()
var commands := CommandQueue.new()


func _ready() -> void:
	RngService.start_match(Session.match_seed)


func _physics_process(_delta: float) -> void:
	clock.advance()
	for cmd in commands.pop_due(clock.tick):
		EventBus.command_issued.emit(cmd)
