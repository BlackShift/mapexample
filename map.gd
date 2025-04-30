@tool
class_name Map extends Node

static func element_filter(element) -> bool:
	return element is MapElement

static func link_test(link_element:MapLink,test_element:MapLink) -> bool:
	if (link_element.A == test_element.A and link_element.B == test_element.B) or \
		(link_element.B == test_element.A and link_element.A == test_element.B):
		return true
	return false

signal map_changed

var elements:Dictionary[Vector2i,MapElement]
var dirty_map_extents:bool = true
var map_extents:Rect2i:
	get():
		if not dirty_map_extents:
			return map_extents
		var new_extents := Rect2i(Vector2i.ZERO,-Vector2i.ONE)
		for child:MapElement in get_children().filter(element_filter):
			if new_extents.size == -Vector2i.ONE:
				new_extents = Rect2i(child.position,Vector2i.ZERO)
			else:
				new_extents = new_extents.expand(child.position)
		map_extents = new_extents
		dirty_map_extents = false
		return map_extents

var links:Array[MapLink]

func _init() -> void:
	child_entered_tree.connect(on_child_entered)

func _ready() -> void:
	print(map_extents)
	build_links()

func build_links() -> void:
	links.clear()
	for child:MapElement in get_children().filter(element_filter):
		for child_link in child.links:
			if child_link.get_parent() != self:
				continue
			var link := MapLink.new(child.position,child_link.position)
			if links.any(link_test.bind(link)):
				continue
			links.append(link)
	pass

func on_child_entered(child:Node) -> void:
	if child is MapElement:
		var map_element := child as MapElement
		map_element.position_changed.connect(on_element_position_change.bind(map_element))
		map_element.link_changed.connect(build_links)
		map_element.link_changed.connect(map_changed.emit)
		on_element_position_change(map_element)
	pass

func on_child_exited(child:Node) -> void:
	if child is MapElement:
		child.position_changed.disconnect(on_element_position_change)

func on_element_position_change(element:MapElement) -> void:
	var idx = elements.values().find(element)
	if idx >= 0:
		var old_position := elements.keys()[idx] as Vector2i
		elements.erase(old_position)
	if elements.has(element.position) and elements[element.position] != element:
		print_debug("Duplicate map Element at position: ",element.position)
	elements.set(element.position,element)
	dirty_map_extents = true
	build_links()
	map_changed.emit()

func get_element_at(pos:Vector2i) -> MapElement:
	return elements.get(pos,null)
