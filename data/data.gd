extends Node
# Autoload "Data". Loads shared game data from JSON once. Runs on server and client.

var classes: Dictionary[StringName, ClassDef] = {}
var monsters: Dictionary[StringName, MonsterDef] = {}

func _ready() -> void:
	for row in _rows("res://data/classes.json"):
		var c := ClassDef.new()
		_fill(c, row)
		classes[c.id] = c
	for row in _rows("res://data/monsters.json"):
		var m := MonsterDef.new()
		_fill(m, row)
		monsters[m.id] = m

func _rows(path: String) -> Array:
	if not FileAccess.file_exists(path):
		_fail("data file not found: " + path)
		return []
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		_fail("data file is empty: " + path)
		return []
	var json := JSON.new()
	if json.parse(text) != OK:
		_fail("%s line %d: %s" % [path, json.get_error_line(), json.get_error_message()])
		return []
	var parsed = json.data
	if not (parsed is Dictionary and parsed.get("version") == 1 and parsed.get("rows") is Array):
		_fail("bad data file (needs version 1 and rows): " + path)
		return []
	return parsed["rows"]

func _fail(message: String) -> void:
	push_error(message)
	get_tree().quit(1)

# Copies one JSON row into a typed object. Unknown or missing fields stop the game.
func _fill(obj: Object, row: Dictionary) -> void:
	var missing := {}
	for p in obj.get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			missing[p.name] = true
	for key in row:
		assert(missing.has(key), "%s: unknown field '%s'" % [row.get("id"), key])
		var value = row[key]
		match typeof(obj.get(key)):
			TYPE_INT: value = int(value)
			TYPE_STRING_NAME: value = StringName(value)
		obj.set(key, value)
		missing.erase(key)
	assert(missing.is_empty(), "%s: missing fields %s" % [row.get("id"), missing.keys()])
