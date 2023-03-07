extends Camera2D  #Скрипт привязан к камере


#Camera control
@export var SPEED = 15.0
@export var ZOOM_SPEED = 20.0
@export var ZOOM_MARGIN = 0.5
@export var ZOOM_MIN = 1.2
@export var ZOOM_MAX = 2.0

var zoomFactor = 2.0
var zoomPos = Vector2()
var isZooming = false

var screenSize = Vector2()
var inputMouseX = 0
var inputMouseY = 0

var mousePos = Vector2()   #локальная(относительная) позиция мыши(в текущем зуме)
var mousePosGlobal = Vector2()   #глобальная(абсолютная) позиция мыши
var start = Vector2()   #стартовая точка области
var startV = Vector2()   #относительная стартовая точка области
var end = Vector2()   #конечная точка
var endV = Vector2()    #относительная конечная точка области
var isDragging = false   #выделяется ли область в данный момент
signal area_selected    #сигнал о том, что область выделена
signal start_move_selection    #сигнал ...
@onready var box = get_node("../UI/Panel")    #Отмечает следующее свойство как назначенное при изменении состояния готовности узла. Значения этих свойств не назначаются сразу после создания узла, а вычисляются и сохраняются непосредственно перед созданием узла.
@warning_ignore("unused_parameter", "unused_parameter")    #Отмечает следующую инструкцию, чтобы игнорировать указанное предупреждение.

func _ready():    #Вызывается, когда узел «готов», т. е. когда и узел, и его дочерние элементы вошли в дерево сцены. Если у узла есть дочерние узлы, их обратные вызовы _ready() срабатывают первыми, а родительский узел впоследствии получает уведомление о готовности.
	connect("area_selected", Callable(get_parent(), "_on_area_selected")) #Соединяет сигнал с вызываемым. Используйте флаги для установки отложенных или одноразовых соединений.
	#соединяет сигнал "area_selected" с вызываемым Callable(get_parent(), "_on_area_selected"), аргументы которого родительский узел этого скрипта и функция в этом узле

func _process(delta): #Вызывается на этапе обработки основного цикла. Обработка происходит в каждом кадре и с максимально возможной скоростью, поэтому дельта-время с момента предыдущего кадра непостоянна. дельта в секундах.
	
	var inputX = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var inputY = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	position.x = lerp(position.x, position.x + (inputX + inputMouseX) * SPEED * zoom.x, SPEED*delta)
	position.y = lerp(position.y, position.y + (inputY + inputMouseY) * SPEED * zoom.y, SPEED*delta)
	
	zoom.x = lerp(zoom.x, zoom.x * zoomFactor, ZOOM_SPEED*delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomFactor, ZOOM_SPEED*delta)
	
	zoom.x = clamp(zoom.x, ZOOM_MIN, ZOOM_MAX)
	zoom.y = clamp(zoom.y, ZOOM_MIN, ZOOM_MAX)
	
	if not isZooming:
		zoomFactor = 1.0
	
	if Input.is_action_just_pressed("LeftClick"):   #при зажатой левой кнопке мыши
		start = mousePosGlobal  #инициализация
		startV = mousePos
		isDragging = true
	
	if isDragging:  #если область в процессе выделения
		end = mousePosGlobal 
		endV = mousePos
		draw_area()  #отрисовываем область
	
	if Input.is_action_just_released("LeftClick"):   #при отпущенной левой кнопке мыши
		if startV.distance_to(mousePos) >= 0:   #учитывает только ненулевые выделения
			end = mousePosGlobal
			endV = mousePos
			isDragging = false
			draw_area(false)   #останавливаем отрисовку
			emit_signal("area_selected", self)  #испускается сигнал самому себе
		else:
			end = start
			isDragging = false
			draw_area(false)
			emit_signal("area_selected", self)
	
func _input(event):   #входящие события 
	
	#if abs(zoomPos.x - get_global_mouse_position().x) > ZOOM_MARGIN:
		#zoomFactor = 1.0
		
	#if abs(zoomPos.y - get_global_mouse_position().y) > ZOOM_MARGIN:
		#zoomFactor = 1.0
		
	if event is InputEventMouseButton:
		if event.is_pressed():
			isZooming = true
			if event.is_action("MouseWheelDown"):
				zoomFactor -= 0.01 * ZOOM_SPEED
				zoomPos = get_global_mouse_position()
			if event.is_action("MouseWheelUp"):
				zoomFactor += 0.01 * ZOOM_SPEED
				zoomPos = get_global_mouse_position()
		else:
			isZooming = false
			
	if event is InputEventMouse:   #события мыши
		mousePos = event.position    #инициализация
		mousePosGlobal = get_global_mouse_position()
		screenSize = get_viewport_rect().size
		if mousePos.x > screenSize.x - 30:
			inputMouseX = 1
		elif mousePos.y > screenSize.y - 30:
			inputMouseY = 1
		elif mousePos.x < 30:
			inputMouseX = -1
		elif mousePos.y < 30:
			inputMouseY = -1
		else:
			inputMouseX = 0
			inputMouseY = 0

func draw_area(isntReset = true):   #отрисовываем область, аргумент - обнуляет область при отпускании мыши
	box.size = Vector2(abs(startV.x - endV.x), abs(startV.y - endV.y))
	var pos = Vector2()
	pos.x = min(startV.x, endV.x)
	pos.y = min(startV.y, endV.y)
	box.position = pos
	box.size *= int(isntReset)
	

