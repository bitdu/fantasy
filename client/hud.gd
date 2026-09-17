extends CanvasLayer

@onready var hp_bar: ProgressBar = $Root/Bars/HpBar
@onready var hp_text: Label = $Root/Bars/HpBar/HpText
@onready var mp_bar: ProgressBar = $Root/Bars/MpBar
@onready var mp_text: Label = $Root/Bars/MpBar/MpText
@onready var stats_window: StatsWindow = $Root/StatsWindow

var _players: Node3D

func _ready() -> void:
	_players = get_parent().get_node("Players")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_stats"):
		stats_window.visible = not stats_window.visible

func _process(_delta: float) -> void:
	var me := _players.get_node_or_null(str(multiplayer.get_unique_id()))
	if me == null:
		return
	stats_window.player = me
	var s: Stats = me.stats
	_set_bar(hp_bar, hp_text, s.hp, s.max_hp())
	_set_bar(mp_bar, mp_text, s.mp, s.max_mp())

func _set_bar(bar: ProgressBar, text: Label, current: int, maximum: int) -> void:
	bar.max_value = maximum
	bar.value = current
	text.text = "%d / %d" % [current, maximum]
