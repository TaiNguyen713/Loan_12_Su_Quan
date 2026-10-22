extends GdUnitTestSuite
## S1.T06: hash trạng thái sim.


func _snapshot() -> Dictionary:
	return {
		"tick": 120,
		"rng": {"combat": 99, "ai_1": 7},
		"teams": [{"res": [1000.0, 800.0, 500.0, 500.0, 200.0, 200.0]}],
		"market": [1.0, 1.0, 1.2, 1.0, 2.0, 2.5],
		"entities": [
			{"id": 1, "x": 10.0, "y": 20.0, "hp": 90.0, "state": 2, "team": 0},
			{"id": 2, "x": 30.0, "y": 40.0, "hp": 60.0, "state": 0, "team": 1},
		],
	}


func test_fnv_matches_reference_vectors() -> void:
	assert_int(StateHash.fnv_string("")).is_equal(-3750763034362895579)
	assert_int(StateHash.fnv_string("a")).is_equal(-5808556873153909620)
	assert_int(StateHash.fnv_string("foobar")).is_equal(-8821353812377114648)


func test_add_int_uses_eight_little_endian_bytes() -> void:
	assert_int(StateHash.add_int(StateHash.OFFSET, 1)).is_equal(-8517097267634966620)
	assert_int(StateHash.add_int(StateHash.OFFSET, -1)).is_equal(-8289690350564177859)


func test_same_snapshot_gives_same_hash() -> void:
	assert_int(StateHash.compute(_snapshot())).is_equal(StateHash.compute(_snapshot()))


func test_entity_order_and_rng_key_order_do_not_matter() -> void:
	var shuffled := _snapshot()
	shuffled["entities"].reverse()
	shuffled["rng"] = {"ai_1": 7, "combat": 99}
	assert_int(StateHash.compute(shuffled)).is_equal(StateHash.compute(_snapshot()))


func test_s1_t06_tc3_market_price_is_part_of_the_hash() -> void:
	var changed := _snapshot()
	changed["market"][4] = 2.06
	assert_int(StateHash.compute(changed)).is_not_equal(StateHash.compute(_snapshot()))


func test_entity_hp_change_changes_the_hash() -> void:
	var changed := _snapshot()
	changed["entities"][0]["hp"] = 89.0
	assert_int(StateHash.compute(changed)).is_not_equal(StateHash.compute(_snapshot()))
