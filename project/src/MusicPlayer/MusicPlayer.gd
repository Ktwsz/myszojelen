extends AudioStreamPlayer

export var fade_in := true
export var fade_out := true

export var fade_in_time := 0.5
export var fade_out_time := 0.5

export var looped := true

# How many seconds wait until rep lay on loop
export var replay_delay := 0.0

onready var replay_timer : Timer = $ReplayTimer
onready var tween : Tween = $FadeTween

const MIN_VOLUME : float = -100.0
const NORMAL_VOLUME : float = 0.0

var _force_stopped := false


func _ready() -> void:
	connect("finished", self, "_on_music_finished")
	replay_timer.connect("timeout", self, "_on_replay_timer_timeout")
	
	_prepare_tween()


func _prepare_tween() -> void:
	if fade_in:
		fade_in()
	
	if fade_out:
		delayed_fade_out()


func fade_in() -> void:
	_fade_volume(MIN_VOLUME, NORMAL_VOLUME, fade_in_time, Tween.TRANS_EXPO)


func delayed_fade_out() -> void:
	var delay := stream.get_length() - fade_out_time
	fade_out(delay)


func fade_out(delay:float = 0.0) -> void:
	_fade_volume(NORMAL_VOLUME, MIN_VOLUME, fade_out_time, Tween.TRANS_LINEAR, delay)


func _fade_volume(from:float, to:float, duration:float, trans_type:int, delay:float=0.0) -> void:
	tween.interpolate_property(self, "volume_db", from, to, duration, trans_type, Tween.EASE_OUT, delay)
	tween.start()


# Use this method to stop music and be sure, it will not be replayed
func force_stop() -> void:
	stop()
	tween.stop_all()
	_force_stopped = true
	replay_timer.stop()


func _on_music_finished() -> void:
	if looped and not _force_stopped:
		replay_timer.start(replay_delay)


func _on_replay_timer_timeout() -> void:
	if looped:
		play()


func play(from_position:float=0.0) -> void:
	_force_stopped = false
	
	_prepare_tween()
	
	if not fade_in:
		volume_db = NORMAL_VOLUME
	
	.play()
