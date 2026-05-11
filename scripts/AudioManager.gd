extends Node
class_name AudioManager
##
## Plays the level track and emits beats. Stub for roadmap item #4.
##
## Public API the rest of the codebase relies on:
##   - `play(stream, bpm)` — start a track.
##   - `current_beat() -> float` — beat position (fractional).
##   - `beat` signal — fired on every integer beat boundary.
##

signal beat(index: int)

var _bpm: float = 120.0
var _player: AudioStreamPlayer = null
var _last_int_beat: int = -1


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)


func play(stream: AudioStream, bpm: float) -> void:
	_bpm = max(bpm, 1.0)
	_last_int_beat = -1
	_player.stream = stream
	_player.play()


func stop() -> void:
	_player.stop()


func current_beat() -> float:
	if _player == null or not _player.playing:
		return 0.0
	return _player.get_playback_position() * _bpm / 60.0


func _process(_delta: float) -> void:
	if _player == null or not _player.playing:
		return
	var b: int = int(floor(current_beat()))
	if b != _last_int_beat:
		_last_int_beat = b
		emit_signal("beat", b)
