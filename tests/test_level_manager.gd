extends "res://addons/gut/test.gd"
##
## Smoke tests for LevelManager.validate().
##
## Requires the GUT addon (not yet vendored). Until CI is wired up these
## tests document expected behavior and can be run manually in-editor.
##

const LevelManager = preload("res://scripts/LevelManager.gd")


func _good_level() -> Dictionary:
	return {
		"id": "test_01",
		"epoch": "meowgypt",
		"title": "Smoke",
		"bpm": 120,
		"duration_sec": 30,
		"music": "res://assets/music/test.ogg",
		"background": "pyramid_dawn",
		"palette": ["#ffffff", "#000000", "#ff00aa"],
		"obstacles": [
			{ "beat": 4, "type": "spike", "lane": "ground" }
		]
	}


func test_valid_level_passes():
	assert_eq(LevelManager.validate(_good_level()).size(), 0)


func test_bad_bpm_rejected():
	var lvl := _good_level()
	lvl["bpm"] = 10
	assert_gt(LevelManager.validate(lvl).size(), 0)


func test_unknown_obstacle_type_rejected():
	var lvl := _good_level()
	lvl["obstacles"] = [{ "beat": 4, "type": "laser_cat", "lane": "air" }]
	assert_gt(LevelManager.validate(lvl).size(), 0)


func test_beat_out_of_range_rejected():
	var lvl := _good_level()
	# duration 30s @ 120bpm -> max beat 60. Use 9999.
	lvl["obstacles"] = [{ "beat": 9999, "type": "spike", "lane": "ground" }]
	assert_gt(LevelManager.validate(lvl).size(), 0)


func test_overlapping_zones_rejected():
	var lvl := _good_level()
	lvl["physics_zones"] = [
		{ "start_beat": 4,  "end_beat": 12, "form": "long" },
		{ "start_beat": 10, "end_beat": 16, "form": "loaf" }
	]
	assert_gt(LevelManager.validate(lvl).size(), 0)


func test_palette_must_be_three_hex():
	var lvl := _good_level()
	lvl["palette"] = ["#fff", "#000000", "#aaaaaa"]
	assert_gt(LevelManager.validate(lvl).size(), 0)
