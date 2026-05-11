extends Resource
class_name GameConfig
##
## Central tunables for Meow-try Dash.
##
## Every "magic number" lives here so designers and AI agents can tweak
## feel without grepping through gameplay code. A `GameConfig.tres` resource
## should be authored later; this script is the schema.
##

# --- Physics -----------------------------------------------------------------

## World gravity in pixels / sec^2. Geometry Dash style — high and snappy.
@export var gravity: float = 2400.0

## Forward auto-scroll speed in pixels / sec.
@export var scroll_speed: float = 520.0

## Initial vertical velocity applied by a tap-to-jump (pixels / sec).
@export var jump_velocity: float = -900.0

# --- Rhythm ------------------------------------------------------------------

## Half-width (in seconds) of the "perfect" tap window for echo-meow.
@export var perfect_window_sec: float = 0.06

## Half-width (in seconds) of the "good" tap window. Outside this = miss.
@export var good_window_sec: float = 0.15

# --- Cat forms ---------------------------------------------------------------

## Default collider half-extents per form (width, height) in pixels.
@export var form_sizes: Dictionary = {
	"normal": Vector2(32, 32),
	"long":   Vector2(64, 16),
	"loaf":   Vector2(40, 28),
	"blob":   Vector2(28, 28),
}
