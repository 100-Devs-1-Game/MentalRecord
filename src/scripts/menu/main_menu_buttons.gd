extends VBoxContainer
# Handles main menu button operations

## --- exported variables ---
@export var game_scene: String
@export var credits_scene: String

## --- onready variables ---
@onready var new_game_button: Button = $NewGameButton
@onready var continue_button: Button = $ContinueButton
@onready var credits_button: Button = $CreditsButton
@onready var quit_button: Button = $QuitButton

## --- private methods ---

## Starts a new game and loads into the game scene
func _new_game() -> void:
	get_tree().change_scene_to_file(game_scene)
	SceneManager.load_start_room()
	
## Loads data from save file and enters game scene
func _load_game() -> void:
	get_tree().change_scene_to_file(game_scene)
	
## Loads credits scene
func _goto_credits() -> void:
	get_tree().change_scene_to_file(credits_scene)
	
## Quits the game
func _quit_game() -> void:
	get_tree().quit()
