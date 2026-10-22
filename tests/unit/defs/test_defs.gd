extends GdUnitTestSuite
## S1.T03: dữ liệu .tres sinh từ CSV phải nạp được và đúng kiểu.


func _load_dir(dir: String) -> Array[Resource]:
	var result: Array[Resource] = []
	for file in DirAccess.get_files_at(dir):
		if file.ends_with(".tres"):
			result.append(load("%s/%s" % [dir, file]))
	return result


func test_s1_t03_tc1_every_unit_loads_with_six_resource_slots() -> void:
	var units := _load_dir("res://data/units")
	assert_int(units.size()).is_equal(18)
	for res in units:
		var unit := res as UnitDef
		assert_object(unit).is_not_null()
		assert_int(unit.cost.size()).is_equal(6)
		assert_int(unit.upkeep.size()).is_equal(6)
		assert_int(unit.ammo.size()).is_equal(6)
		assert_str(String(unit.id)).is_not_empty()


func test_every_building_loads() -> void:
	var buildings := _load_dir("res://data/buildings")
	assert_int(buildings.size()).is_equal(21)
	for res in buildings:
		var building := res as BuildingDef
		assert_object(building).is_not_null()
		assert_int(building.cost.size()).is_equal(6)
		assert_bool(building.size.x >= 1 and building.size.y >= 1).is_true()


func test_s1_t03_tc4_house_growth_is_1_05() -> void:
	var house := load("res://data/buildings/building_nha.tres") as BuildingDef
	assert_float(house.growth).is_equal_approx(1.05, 0.0001)


func test_spearman_values_match_the_balance_table() -> void:
	var spear := load("res://data/units/unit_linh_giao.tres") as UnitDef
	assert_float(spear.hp).is_equal(90.0)
	assert_float(spear.bonus[&"cavalry"]).is_equal(2.0)
	assert_float(spear.bonus[&"elephant"]).is_equal(2.5)
	assert_bool(spear.has_tag(&"melee")).is_true()
	assert_float(spear.cost[0]).is_equal(30.0)
	assert_float(spear.cost[1]).is_equal(10.0)


func test_s4_t02_tc1_third_barracks_price() -> void:
	var barracks := load("res://data/buildings/building_doanh_trai.tres") as BuildingDef
	var price := barracks.cost_for_count(2)
	assert_float(price[1]).is_equal(365.0)  # gỗ: 200 × 1.35²
	assert_float(price[2]).is_equal(182.0)  # đá: 100 × 1.35²
	assert_float(barracks.cost_for_count(0)[1]).is_equal(200.0)


func test_military_flags() -> void:
	var wall := load("res://data/buildings/building_luy.tres") as BuildingDef
	assert_bool(wall.military).is_true()
	assert_bool(wall.walk_inf_owner).is_true()
	var cannon := load("res://data/units/unit_dai_bac.tres") as UnitDef
	assert_bool(cannon.can_damage_military).is_true()
	var musket := load("res://data/units/unit_linh_sung_hoa_mai.tres") as UnitDef
	assert_bool(musket.can_damage_military).is_false()
