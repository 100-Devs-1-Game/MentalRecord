extends Control

## --- public variables ---
var speaker_filter: String = ""

## --- onready variables ---
@onready var scroll_container: ScrollContainer = $NinePatchRect/MarginContainer/ScrollContainer
@onready var inv_slots: VBoxContainer = $NinePatchRect/MarginContainer/ScrollContainer/VBoxContainer
@onready var statement_item_scene = preload("res://scenes/UI/statment_item.tscn")

func _ready():
	SignalBus.dialogue_added.connect(dialogue_added)
	refresh_list()
	
## --- public methods ---

## Sets the filter and refreshes the list
func set_filters_and_refresh(new_speaker_filter: String) -> void:
	speaker_filter = new_speaker_filter
	refresh_list()

## Refreshes the inventory statement list
func refresh_list() -> void:
	# Remove old statements
	for child in inv_slots.get_children():
		inv_slots.remove_child(child)
		child.queue_free()
		
	# Get list of statements
	var statements = InventoryManager.get_collected_statements(speaker_filter)
	for statement in statements:
		var btn = statement_item_scene.instantiate()
		btn.canvas_parent = self
		btn.set_meta_info(statement)
		inv_slots.add_child(btn)

## Listens for when a dialogue is added
func dialogue_added(_dialogue_id: String) -> void:
	refresh_list()
	
	# Scroll to bottom
	await get_tree().process_frame
	var v_scroll_bar = scroll_container.get_v_scroll_bar()
	scroll_container.scroll_vertical = v_scroll_bar.max_value
