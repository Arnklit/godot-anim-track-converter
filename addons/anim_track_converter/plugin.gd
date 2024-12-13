@tool
extends EditorPlugin

const ConvertDialogue := preload("ui/convert_dialogue/convert_dialogue.gd")

const EditorUtil := preload("lib/editor_util.gd")

var convert_dialogue: ConvertDialogue

var edit_menu_button: MenuButton

var _last_anim_player: AnimationPlayer
const SCENE_TREE_IDX := 0
var _scene_tree: Tree

func _enter_tree() -> void:
	# Create dialogue
	convert_dialogue = load("res://addons/anim_track_converter/ui/convert_dialogue/convert_dialogue.tscn").instantiate()
	get_editor_interface().get_base_control().add_child(convert_dialogue)
	print("in enter tree of plugin")
	convert_dialogue.init(self)
	# Create menu button
	_add_convert_option(_pop_up_convert)


func _pop_up_convert() -> void:
	convert_dialogue.popup_centered()
	convert_dialogue.reset_size()
	var troot := convert_dialogue.track_convert_select.create_item()
	var it := convert_dialogue.track_convert_select.create_item(troot)
	it.set_editable(0, true)
	it.set_selectable(0, true)
	it.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	it.set_text(0, "Test item")


func _exit_tree() -> void:
	if convert_dialogue and convert_dialogue.is_inside_tree():
		get_editor_interface().get_base_control().remove_child(convert_dialogue)
		convert_dialogue.queue_free()

	_remove_convert_option()


func _handles(object: Object) -> bool:
	if object is AnimationPlayer:
		_last_anim_player = object
	return false


# Editor methods
func get_anim_player() -> AnimationPlayer:
	# Check for pinned animation
	if not _scene_tree:
		var _scene_tree_editor = EditorUtil.find_editor_control_with_class(
			get_editor_interface().get_base_control(),
			"SceneTreeEditor"
		)
		
		if not _scene_tree_editor:
			push_error("[Animation Converter] Could not find scene tree editor. Please report this.")
			return null
			
		_scene_tree = _scene_tree_editor.get_child(SCENE_TREE_IDX)
		
	if not _scene_tree:
		push_error("[Animation Converter] Could not find scene tree editor. Please report this.")
		return null
		
	var found_anim := EditorUtil.find_active_anim_player(
		get_editor_interface().get_base_control(),
		_scene_tree
	)
	
	if found_anim:
		return found_anim
	
	# Get latest edited
	return _last_anim_player


# Plugin buttons

const TOOL_CONVERT := 999
const TOOL_ANIM_LIBRARY := 1

func _add_convert_option(on_pressed: Callable):
	var base_control := get_editor_interface().get_base_control()
	if not edit_menu_button:
		edit_menu_button = EditorUtil.find_edit_menu_button(base_control)
	if not edit_menu_button:
		push_error("[Animation Converter] Could not find Edit menu button. Please report this issue.")
		return
	
	var edit_popup := edit_menu_button.get_popup()

	# Add convert item
	edit_popup.add_icon_item(
		base_control.get_theme_icon(&"Reload", &"EditorIcons"), 
		"Convert",
		TOOL_CONVERT,
	)
	
	edit_popup.notification(NOTIFICATION_TRANSLATION_CHANGED)

	edit_popup.id_pressed.connect(_on_menu_button_pressed)


func _remove_convert_option():
	if not edit_menu_button:
		return
	
	var base_control := get_editor_interface().get_base_control()
	
	var menu_popup := edit_menu_button.get_popup()
	menu_popup.remove_item(menu_popup.get_item_index(TOOL_CONVERT))

	menu_popup.id_pressed.disconnect(_on_menu_button_pressed)


func _on_menu_button_pressed(id: int):
	if id == TOOL_CONVERT:
		convert_dialogue.popup_centered()
