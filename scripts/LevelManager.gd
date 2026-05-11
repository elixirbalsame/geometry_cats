extends Node
class_name LevelManager
##
## Loads and validates level JSON files.
##
## The runtime spawner (obstacle placement per beat, music sync) will be
## added in later roadmap items. This stub already ships a complete
## `validate()` because level generation is the first task delegated
## to AI agents and they need an authoritative checker.
##

# --- Registries --------------------------------------------------------------

const _OBSTACLE_TYPES := [
	"spike", "frame", "sarcophagus", "ra_beam",
	"shoji", "barrel", "gate_and", "gate_or", "gate_not",
]

const _COLLECTIBLE_TYPES := [
	"fish_coin", "yarn_ball", "daily_cursed",
]

const _CAT_FORMS := ["normal", "long", "loaf", "blob"]

const _REQUIRED_TOP_LEVEL := [
	"id", "epoch", "title", "bpm", "duration_sec",
	"music", "background", "palette", "obstacles",
]

# --- Public API --------------------------------------------------------------

## Loads a JSON level from disk. Returns the parsed Dictionary, or null on error.
## Pass the same path to `validate()` afterwards.
static func load_level(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open level: %s" % path)
		return null
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("Level JSON is malformed: %s" % path)
		return null
	return parsed


## Returns an array of human-readable error strings.
## An empty array means the level is valid.
static func validate(level: Variant) -> Array:
	var errors: Array = []

	if typeof(level) != TYPE_DICTIONARY:
		errors.append("Top-level value must be a JSON object.")
		return errors

	# Required fields & basic types.
	for key in _REQUIRED_TOP_LEVEL:
		if not level.has(key):
			errors.append("Missing required field: '%s'." % key)

	if errors.size() > 0:
		return errors  # bail early; further checks would cascade.

	# BPM and duration ranges.
	var bpm: int = int(level.get("bpm", 0))
	var duration_sec: int = int(level.get("duration_sec", 0))
	if bpm < 60 or bpm > 240:
		errors.append("bpm must be in [60, 240], got %d." % bpm)
	if duration_sec < 15 or duration_sec > 300:
		errors.append("duration_sec must be in [15, 300], got %d." % duration_sec)

	var max_beat: float = 0.0
	if bpm > 0 and duration_sec > 0:
		max_beat = float(duration_sec) * float(bpm) / 60.0

	# Palette.
	var palette: Variant = level.get("palette")
	if typeof(palette) != TYPE_ARRAY or (palette as Array).size() != 3:
		errors.append("palette must be an array of exactly 3 hex strings.")
	else:
		for c in (palette as Array):
			if typeof(c) != TYPE_STRING or not _is_hex_color(c):
				errors.append("palette entry '%s' is not a #RRGGBB string." % str(c))

	# Obstacles.
	var obstacles: Variant = level.get("obstacles", [])
	if typeof(obstacles) != TYPE_ARRAY:
		errors.append("obstacles must be an array.")
	else:
		for i in (obstacles as Array).size():
			var o: Variant = (obstacles as Array)[i]
			_check_event(o, "obstacles[%d]" % i, _OBSTACLE_TYPES, max_beat, errors)

	# Collectibles (optional).
	if level.has("collectibles"):
		var collectibles: Variant = level.get("collectibles")
		if typeof(collectibles) != TYPE_ARRAY:
			errors.append("collectibles must be an array.")
		else:
			for i in (collectibles as Array).size():
				var c: Variant = (collectibles as Array)[i]
				_check_event(c, "collectibles[%d]" % i, _COLLECTIBLE_TYPES, max_beat, errors)

	# Physics zones (optional).
	if level.has("physics_zones"):
		_check_physics_zones(level["physics_zones"], max_beat, errors)

	# Boss (optional).
	if level.has("boss"):
		var boss: Variant = level["boss"]
		if typeof(boss) != TYPE_DICTIONARY:
			errors.append("boss must be an object.")
		else:
			if not boss.has("name") or typeof(boss["name"]) != TYPE_STRING:
				errors.append("boss.name must be a string.")
			if not boss.has("question_id") or typeof(boss["question_id"]) != TYPE_STRING:
				errors.append("boss.question_id must be a string.")

	return errors


# --- Helpers -----------------------------------------------------------------

static func _check_event(
	event: Variant, label: String, allowed_types: Array,
	max_beat: float, errors: Array
) -> void:
	if typeof(event) != TYPE_DICTIONARY:
		errors.append("%s must be an object." % label)
		return
	if not event.has("beat") or typeof(event["beat"]) not in [TYPE_FLOAT, TYPE_INT]:
		errors.append("%s.beat must be a number." % label)
	else:
		var beat: float = float(event["beat"])
		if beat < 0.0 or beat > max_beat:
			errors.append("%s.beat=%.2f is outside [0, %.2f]." % [label, beat, max_beat])
	if not event.has("type") or typeof(event["type"]) != TYPE_STRING:
		errors.append("%s.type must be a string." % label)
	elif not allowed_types.has(event["type"]):
		errors.append("%s.type '%s' is not registered." % [label, event["type"]])
	# `lane` is required for obstacles only; we check it leniently.
	if event.has("lane") and not ["ground", "air"].has(event["lane"]):
		errors.append("%s.lane must be 'ground' or 'air'." % label)


static func _check_physics_zones(
	zones: Variant, max_beat: float, errors: Array
) -> void:
	if typeof(zones) != TYPE_ARRAY:
		errors.append("physics_zones must be an array.")
		return
	var parsed: Array = []  # of [start, end]
	for i in (zones as Array).size():
		var z: Variant = (zones as Array)[i]
		var label := "physics_zones[%d]" % i
		if typeof(z) != TYPE_DICTIONARY:
			errors.append("%s must be an object." % label)
			continue
		var ok := true
		for key in ["start_beat", "end_beat", "form"]:
			if not z.has(key):
				errors.append("%s.%s missing." % [label, key])
				ok = false
		if not ok:
			continue
		var s: float = float(z["start_beat"])
		var e: float = float(z["end_beat"])
		if s < 0.0 or e > max_beat or e <= s:
			errors.append("%s has invalid beat range [%.2f, %.2f]." % [label, s, e])
		if not _CAT_FORMS.has(z["form"]):
			errors.append("%s.form '%s' is unknown." % [label, z["form"]])
		parsed.append([s, e])
	# Overlap check.
	parsed.sort_custom(func(a, b): return a[0] < b[0])
	for i in range(1, parsed.size()):
		if parsed[i][0] < parsed[i - 1][1]:
			errors.append(
				"physics_zones overlap at beat %.2f." % parsed[i][0]
			)


static func _is_hex_color(s: String) -> bool:
	if s.length() != 7 or not s.begins_with("#"):
		return false
	for i in range(1, 7):
		var c := s[i]
		if not ((c >= "0" and c <= "9") or (c >= "a" and c <= "f") or (c >= "A" and c <= "F")):
			return false
	return true
