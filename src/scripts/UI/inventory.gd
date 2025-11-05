extends Control

@onready var inv_slots: VBoxContainer = $VBoxContainer

func add_statement(node: Control):

	node.reparent(inv_slots,false)