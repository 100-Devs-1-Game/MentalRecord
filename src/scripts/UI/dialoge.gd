extends Control


@onready var icon: TextureRect = %icon
@onready var text_node: RichTextLabel = %text

@export var activist_sprite: Texture2D
@export var curator_sprite: Texture2D
@export var guard_sprite: Texture2D
@export var medium_sprite: Texture2D
@export var mole_sprite: Texture2D
@export var scientist_sprite: Texture2D

var skipping := false

func _ready():
	SignalBus.dialogue_requested.connect(show_dialogue)
	visible = false


func show_dialogue(speaker: String, text: String) -> void:
	skipping = false

	var sprite_map := {
		"activist": activist_sprite,
		"curator": curator_sprite,
		"guard": guard_sprite,
		"medium": medium_sprite,
		"mole": mole_sprite,
		"scientist": scientist_sprite,
		"culprit": null
	}

	icon.texture = sprite_map.get(speaker.to_lower(), null)

	text_node.visible_ratio = 0.0
	text_node.text = text
	visible = true

	while text_node.visible_ratio < 1.0 and not skipping:
		text_node.visible_ratio = min(text_node.visible_ratio + 0.02, 1.0)
		await get_tree().create_timer(0.01).timeout

	text_node.visible_ratio = 1.0


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if text_node.visible_ratio < 1.0:
			skipping = true
			text_node.visible_ratio = 1.0
		else:
			visible = false
		SignalBus.paused_state_changed.emit(false)


func _on_skip_pressed() -> void:
	if text_node.visible_ratio < 1.0:
		skipping = true
		text_node.visible_ratio = 1.0
	else:
		visible = false
		SignalBus.paused_state_changed.emit(false)
