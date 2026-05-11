extends Node2D
class_name GlitchFX
##
## ASCII-disintegration death effect. Stub for roadmap item #6.
##
## The visual implementation will be added later. For now we expose the
## entry point other modules already call.
##

signal finished

## Plays the death glitch over `duration` seconds, then emits `finished`.
func play(duration: float = 0.6) -> void:
	# Placeholder: a real implementation will render an ASCII shader pass
	# and a meme card. For now we just wait the requested time.
	await get_tree().create_timer(duration).timeout
	emit_signal("finished")
