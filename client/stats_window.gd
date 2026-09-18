class_name StatsWindow
extends PanelContainer

const STATS: Array[StringName] = [&"strength", &"wisdom", &"speed", &"vitality"]

var player: Node   # set by HUD once our body exists

@onready var _grid: GridContainer = $Margin/VBox/Grid
@onready var _free_points: Label = $Margin/VBox/FreePoints
@onready var _derived: Label = $Margin/VBox/Derived

var _value_labels := {}
var _plus_buttons := {}

func _ready() -> void:
	for stat in STATS:
		var prefix := str(stat).capitalize()        # &"speed" -> "Speed"
		_value_labels[stat] = _grid.get_node(prefix + "Value")
		_plus_buttons[stat] = _grid.get_node(prefix + "Plus")
		_plus_buttons[stat].pressed.connect(_on_plus.bind(stat))

func _process(_delta: float) -> void:
	if not visible or player == null:
		return
	var s: Stats = player.stats
	for stat in STATS:
		_value_labels[stat].text = str(s.get(stat))
		_plus_buttons[stat].disabled = s.free_points <= 0
	_free_points.text = "Free points: %d" % s.free_points
	var phys := s.shown_phys_damage()
	var magic := s.shown_magic_damage()
	_derived.text = "HP %d   MP %d\nPhysical %d-%d   Magic %d-%d\nMove %d%%   Attack speed %d%%" % [
		s.max_hp(), s.max_mp(), phys.x, phys.y, magic.x, magic.y,
		s.shown_move_speed(), s.shown_attack_speed()]

func _on_plus(stat: StringName) -> void:
	player.request_add_point.rpc_id(1, stat)
	
