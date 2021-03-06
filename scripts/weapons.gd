extends Node

const KNIFE_SCENE = preload("res://scenes/objects/weapons/knife.tscn")
const AXE_SCENE = preload("res://scenes/objects/weapons/axe.tscn")
const SHURIKEN_SCENE = preload("res://scenes/objects/weapons/shuriken.tscn")

const WEAPONS = {
	"knife":    {"scene": KNIFE_SCENE,    "frame": 0, "impulse": 640, "shot_rate": 0.6},
	"axe":      {"scene": AXE_SCENE,      "frame": 1, "impulse": 750, "shot_rate": 1.0},
	"shuriken": {"scene": SHURIKEN_SCENE, "frame": 2, "impulse": 820, "shot_rate": 0.2}
}

func get_info(name):
	var info = WEAPONS[name.to_lower()]
	
	if not info:
		printerr("Weapon not found: %s" % name)
	
	return info
