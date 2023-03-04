extends Node

@onready var buildingPanel = preload("res://Global/spawn_unit.tscn")
@onready var unitPanel = preload("res://Global/unit_panel.tscn")
@onready var minePanel = preload("res://Global/mine_panel.tscn")

var uiPanels = []


var Wood = 0
var Food = 0
var Stone = 0
var Gold = 0
var Iron = 0
var Coal = 0

func spawnUnit():
	var path = get_tree().get_root().get_node("World/UI")
	var spawnUnit = buildingPanel.instantiate()
	path.add_child(spawnUnit)
	
func unitPanelCall():
	var path = get_tree().get_root().get_node("World/UI")
	var panel = unitPanel.instantiate()
	path.add_child(panel)

func minePanelCall():
	var path = get_tree().get_root().get_node("World/UI")
	var panel = minePanel.instantiate()
	path.add_child(panel)
