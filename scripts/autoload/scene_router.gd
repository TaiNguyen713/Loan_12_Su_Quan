extends Node
## Chuyển scene bằng nạp luồng phụ (S1.T02). Màn loading sẽ nghe `progress_changed`.

signal progress_changed(ratio: float)
signal load_failed(path: String)

var _path: String = ""


func _ready() -> void:
	set_process(false)


func goto(path: String) -> void:
	if not _path.is_empty():
		return
	EventBus.scene_leaving.emit()
	if ResourceLoader.load_threaded_request(path) != OK:
		load_failed.emit(path)
		return
	_path = path
	set_process(true)


func _process(_delta: float) -> void:
	var progress: Array = []
	match ResourceLoader.load_threaded_get_status(_path, progress):
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_changed.emit(float(progress[0]))
		ResourceLoader.THREAD_LOAD_LOADED:
			var packed := ResourceLoader.load_threaded_get(_path) as PackedScene
			_path = ""
			set_process(false)
			progress_changed.emit(1.0)
			get_tree().change_scene_to_packed(packed)
		_:
			var failed := _path
			_path = ""
			set_process(false)
			load_failed.emit(failed)
