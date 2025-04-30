@tool
extends Control

@export var map:Map
@export var spacing:Vector2
@export var link_thickness:float = 2.0
@export var center_position:Vector2i

@export_tool_button("Redraw") var redraw_btn:Callable = queue_redraw
func _ready() -> void:
	if map:
		map.map_changed.connect(queue_redraw)


func _draw() -> void:
	if not map:
		return
	#Calculate sizes
	var center := size/2
	var cell_size:Vector2

	var elements := map.get_children().filter(Map.element_filter)
	for cell:MapElement in elements:
		cell_size = cell_size.max(cell.preview_size)
	
	center -= spacing * Vector2(center_position) + cell_size * Vector2(center_position)
	
	for link:MapLink in map.links:
		var start = spacing * Vector2(link.A) + cell_size * Vector2(link.A)
		var end = spacing * Vector2(link.B) + cell_size * Vector2(link.B)
		draw_line(start+center,end+center,Color.BLACK,link_thickness)
	
	for cell:MapElement in elements:
		if not cell.preview_texture:
			continue
		var offset = spacing * Vector2(cell.position) + cell_size * Vector2(cell.position)
		offset -= cell.preview_size/2
		draw_texture_rect(cell.preview_texture,Rect2(offset+center,cell.preview_size),false)
	

	#draw_rect(Rect2(Vector2.ZERO,cell_size),Color.RED)
	pass
