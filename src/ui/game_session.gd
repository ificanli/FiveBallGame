extends Node

## Session-level UI flags (autoload singleton "GameSession").
## Presentation only; never enters rule data or replays.

const SETTINGS_PATH := "user://settings.cfg"
const CONTROLS_SECTION := "controls"
const INPUT_MODE_KEY := "input_mode"

var tutorial_mode := false
## 出杆方式: "drag" = 拉杆出手(按住拖拽, 松开击球), "fine" = 精细瞄准(调向+选档+点击球)
var input_mode := "drag"


func _ready() -> void:
	_load_settings()


func set_input_mode(mode: String) -> void:
	if mode not in ["drag", "fine"]:
		return
	input_mode = mode
	_save_settings()


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	var stored := str(cfg.get_value(CONTROLS_SECTION, INPUT_MODE_KEY, "drag"))
	input_mode = stored if stored in ["drag", "fine"] else "drag"


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(CONTROLS_SECTION, INPUT_MODE_KEY, input_mode)
	cfg.save(SETTINGS_PATH)
