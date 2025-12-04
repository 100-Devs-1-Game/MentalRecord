extends VBoxContainer
# Handles main menu button operations

## --- exported variables ---
@export var intro_scene: String
@export var game_scene: String
@export var credits_scene: String
@export var settings: Control

## --- onready vars ---
@onready var continue_button: Button = $ContinueButton

func _ready() -> void:
	if (!InventoryManager.load_from_file("save")):
		continue_button.hide()

## --- private methods ---

## Starts a new game and loads into the game scene
func _new_game() -> void:
	get_tree().change_scene_to_file(intro_scene)
	InventoryManager.clear_data()
	
## Loads data from save file and enters game scene
func _load_game() -> void:
	get_tree().change_scene_to_file(game_scene)
	SceneManager.load_start_room()
	
## Opens the settings menu
func _open_settings() -> void:
	settings.show()
	
## Loads credits scene
func _goto_credits() -> void:
	get_tree().change_scene_to_file(credits_scene)
	
## Quits the game
func _quit_game() -> void:
	get_tree().quit()
