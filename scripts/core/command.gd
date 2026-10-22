class_name Command
extends RefCounted
## Mọi hành động của người chơi hoặc AI đều là một Command, đi qua CommandQueue (S1.T06).

var tick: int = 0
var seq: int = 0
var team: int = 0
var type: StringName = &""
var unit_ids: PackedInt32Array = PackedInt32Array()
var target_pos: Vector2 = Vector2.ZERO
var target_id: int = -1
var waypoints: PackedVector2Array = PackedVector2Array()
var params: Dictionary = {}


func to_dict() -> Dictionary:
	var points: Array = []
	for point in waypoints:
		points.append([point.x, point.y])
	return {
		"tick": tick,
		"seq": seq,
		"team": team,
		"type": String(type),
		"unit_ids": Array(unit_ids),
		"target_pos": [target_pos.x, target_pos.y],
		"target_id": target_id,
		"waypoints": points,
		"params": params,
	}


static func from_dict(data: Dictionary) -> Command:
	var cmd := Command.new()
	cmd.tick = int(data.get("tick", 0))
	cmd.seq = int(data.get("seq", 0))
	cmd.team = int(data.get("team", 0))
	cmd.type = StringName(data.get("type", ""))
	cmd.unit_ids = PackedInt32Array(data.get("unit_ids", []))
	var pos: Array = data.get("target_pos", [0.0, 0.0])
	cmd.target_pos = Vector2(float(pos[0]), float(pos[1]))
	cmd.target_id = int(data.get("target_id", -1))
	for point in data.get("waypoints", []):
		cmd.waypoints.append(Vector2(float(point[0]), float(point[1])))
	cmd.params = data.get("params", {})
	return cmd
