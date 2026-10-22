extends GdUnitTestSuite
## S1.T06: hàng đợi lệnh theo tick.


func _command(type: StringName, tick: int = 0) -> Command:
	var cmd := Command.new()
	cmd.type = type
	cmd.tick = tick
	return cmd


func test_s1_t06_tc4_command_pushed_at_tick_10_is_applied_at_tick_11() -> void:
	var queue := CommandQueue.new()
	queue.push(_command(&"move"), 10)
	assert_int(queue.pop_due(10).size()).is_equal(0)
	assert_int(queue.pop_due(11).size()).is_equal(1)
	assert_int(queue.pending_count()).is_equal(0)


func test_commands_on_the_same_tick_keep_push_order() -> void:
	var queue := CommandQueue.new()
	queue.push(_command(&"a"), 0)
	queue.push(_command(&"b"), 0)
	queue.push(_command(&"c"), 0)
	var due := queue.pop_due(1)
	assert_array(due.map(func(c: Command) -> StringName: return c.type)).is_equal([&"a", &"b", &"c"])


func test_earlier_scheduled_tick_goes_first_even_if_pushed_later() -> void:
	var queue := CommandQueue.new()
	queue.push(_command(&"late", 50), 0)
	queue.push(_command(&"early", 5), 0)
	var types := queue.pop_due(50).map(func(c: Command) -> StringName: return c.type)
	assert_array(types).is_equal([&"early", &"late"])


func test_history_records_applied_commands_for_replay() -> void:
	var queue := CommandQueue.new()
	var cmd := _command(&"move")
	cmd.unit_ids = PackedInt32Array([4, 5])
	cmd.target_pos = Vector2(12.5, 3.0)
	queue.push(cmd, 0)
	queue.pop_due(1)
	assert_int(queue.history.size()).is_equal(1)
	var replayed := Command.from_dict(queue.history[0])
	assert_str(String(replayed.type)).is_equal("move")
	assert_array(Array(replayed.unit_ids)).is_equal([4, 5])
	assert_vector(replayed.target_pos).is_equal(Vector2(12.5, 3.0))
	assert_int(replayed.tick).is_equal(1)
