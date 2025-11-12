extends Control

## --- public variables ---
var speaker_filter: String = ""

## --- private variables ---
var _speaker_icons: Dictionary = {
	"Curator": null,
	"Activist": null,
	"Guard": null,
	"Medium": null,
	"Mole": null,
	"Scientist": null,
	"Culprit": null
}

## --- onready variables ---
@onready var scroll_container: ScrollContainer = $NinePatchRect/MarginContainer/ScrollContainer
@onready var inv_slots: VBoxContainer = $NinePatchRect/MarginContainer/ScrollContainer/VBoxContainer
@onready var statement_item_scene = preload("res://scenes/UI/statment_item.tscn")
@onready var speaker_filter_menu: OptionButton = $SpeakerFilter

func _ready():
	SignalBus.dialogue_added.connect(dialogue_added)
	refresh_list()
	
## --- public methods ---

## Refreshes the inventory statement list
## @param filter_speaker: Optional new filter
func refresh_list(filter_speaker: String = "") -> void:
	# Set filter
	if (not filter_speaker.is_empty()):
		speaker_filter = filter_speaker
	
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
		
## --- listener methods ---

## Updates the filter based on selection
func _on_speaker_filter_item_selected(index: int) -> void:
	refresh_list(speaker_filter_menu.get_item_metadata(index))

## Listens for when a dialogue is added
func dialogue_added(_dialogue_id: String) -> void:
	# Get dialogue
	var data = InventoryManager.get_dialogue(_dialogue_id)
	
	# Set filtering
	speaker_filter = data["speaker"]
	
	# Refresh
	_refresh_speaker_filter_menu()
	refresh_list()
	
	# Scroll to bottom
	await get_tree().process_frame
	var v_scroll_bar = scroll_container.get_v_scroll_bar()
	scroll_container.scroll_vertical = v_scroll_bar.max_value

## --- private methods ---

## Refreshes the speaker filter menu options
func _refresh_speaker_filter_menu():
	speaker_filter_menu.clear()

	var speakers = InventoryManager.get_discovered_speakers()
	var idx = 0
	for speaker_name in speakers:
		speaker_filter_menu.add_item(speaker_name)
		speaker_filter_menu.set_item_metadata(idx, speaker_name)

		# Set icon if available
		if _speaker_icons.has(speaker_name):
			speaker_filter_menu.set_item_icon(idx, _speaker_icons[speaker_name])

		idx += 1
		
	# Set selected
	speaker_filter_menu.select(speakers.find(speaker_filter))
