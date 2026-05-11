extends CharacterBody2D
class_name PlayerController
##
## The cat. Stub for roadmap item #2.
##
## Implements only the public surface that other modules need:
##   - `set_form(form: String)` — switches the cat between
##     "normal" / "long" / "loaf" / "blob".
##   - `die()` — hands control to `GlitchFX` and emits `died`.
##
## Movement and tap-handling will be filled in by the next PR.
##

signal died
signal form_changed(new_form: String)

const VALID_FORMS := ["normal", "long", "loaf", "blob"]

@export var config: GameConfig

var current_form: String = "normal"


func _ready() -> void:
	if config == null:
		push_warning("PlayerController has no GameConfig assigned; using defaults.")


func set_form(form: String) -> void:
	if not VALID_FORMS.has(form):
		push_error("Unknown cat form: %s" % form)
		return
	if form == current_form:
		return
	current_form = form
	emit_signal("form_changed", form)
	# Collider resizing is performed in the next roadmap PR.


func die() -> void:
	emit_signal("died")
	# Visual disintegration is handled by GlitchFX in roadmap item #6.
