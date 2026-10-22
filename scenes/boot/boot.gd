extends Node
## Màn khởi động: chuyển thẳng vào scene trận. Sẽ chuyển sang menu chính ở S10.T05.


func _ready() -> void:
	SceneRouter.goto("res://scenes/match/match.tscn")
