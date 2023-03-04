extends Node2D

var path_finder
var units = []
var unitCounter = 0
var unitCounterToTransfer = 0

func _ready():
	path_finder = Pathfinder.new($TileMap)
	get_units()
	subscribe_to_units_signals(units)
	
func subscribe_to_units_signals(units: Array):
	for unit in units:
		unit.connect("right_clicked", Callable(self, "_move_unit_to_point"))

func _move_unit_to_point(unit: Unit, point: Vector2):
	var path = path_finder.get_move_path(unit.position, unit.target)
	unit.set_path(path)
	unit = null

func get_units():
	units = null
	units = get_tree().get_nodes_in_group("units")

func _on_area_selected(object):
	var start = object.start
	var end = object.end
	var area = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	var ut = get_units_in_area(area)
	for selectedUnits in units:
		selectedUnits.set_selected(false)
	for selectedUnits in ut:
		selectedUnits.set_selected(!selectedUnits.selected)
		unitCounter += 1
	unitCounterToTransfer = unitCounter
	if unitCounter > 0:
		Game.unitPanelCall()
	unitCounter = 0
	
func get_units_in_area(area):
	var selectedUnits = []
	for unit in units:
		if unit.position.x > area[0].x and unit.position.x < area[1].x:
			if unit.position.y > area[0].y and unit.position.y < area[1].y:
				selectedUnits.append(unit)
		elif unit.position.x - 6 < area[0].x and unit.position.x + 6 > area[0].x:
			if unit.position.y - 7 < area[0].y and unit.position.y + 7 > area[0].y:
				selectedUnits.append(unit)
	return selectedUnits
	
