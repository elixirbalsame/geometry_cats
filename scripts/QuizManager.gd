extends Node
class_name QuizManager
##
## Boss-question logic. Stub for roadmap item #8.
##
## The full Boss scene will arrive later, but the *scoring* function is
## pure and is implemented now so tests can pin its behavior.
##

## Returns true if `chosen_index` matches the `correct_index` of the question.
##
## `question` is a Dictionary loaded from `data/questions.json`:
##     { "id": "...", "prompt": "...", "options": [...], "correct_index": 1 }
static func is_correct(question: Dictionary, chosen_index: int) -> bool:
	if not question.has("correct_index"):
		push_error("Question is missing 'correct_index'.")
		return false
	return int(question["correct_index"]) == chosen_index


## Loads the question bank from disk and returns it as a Dictionary keyed by id.
static func load_bank(path: String = "res://data/questions.json") -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open question bank: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_error("Question bank must be a JSON array.")
		return {}
	var out: Dictionary = {}
	for q in parsed:
		if typeof(q) == TYPE_DICTIONARY and q.has("id"):
			out[q["id"]] = q
	return out
