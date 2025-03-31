@tool
extends EditorPlugin

const ConvertDialogue := preload("ui/convert_dialogue/convert_dialogue.gd")
const AnimTrackConvert := preload("res://addons/anim_track_converter/lib/anim_track_converter.gd")

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
	convert_dialogue.init(self)
	# Create menu button
	_add_convert_option()


func _pop_up_convert() -> void:
	convert_dialogue.popup_centered()
	convert_dialogue.track_convert_select.clear()
	convert_dialogue.track_convert_select.generate_track_list(get_anim_player())
	if not convert_dialogue.confirmed.is_connected(_convert):
		convert_dialogue.confirmed.connect(_convert)


func _get_animation_track_reference_count(path: NodePath, lib: AnimationLibrary) -> int:
	var counter := 0
	for anim_name in lib.get_animation_list():
		var anim := lib.get_animation(anim_name)
		for i in anim.get_track_count():
			if path == anim.track_get_path(i) and anim.track_get_type(i) == Animation.TrackType.TYPE_VALUE:
				counter += 1
	return counter


func _convert() -> void:
	var player : AnimationPlayer = _last_anim_player
	var anim_name = player.assigned_animation
	
	var lib := player.get_animation_library(player.find_animation_library(player.get_animation(anim_name)))
	var reset_lib := player.get_animation_library(player.find_animation_library(player.get_animation(StringName("RESET"))))
	
	var animation: Animation = player.get_animation(anim_name).duplicate()
	var reset_animation: Animation = player.get_animation(StringName("RESET")).duplicate()
	
	var tree_root : TreeItem = convert_dialogue.track_convert_select.get_root()
	if tree_root:
		
		var new_track_count := animation.get_track_count()
		var new_reset_track_count := reset_animation.get_track_count()
		
		# Loop through the selected tracks create new converted copies of the tracks and thier
		# reset tracks.
		var it = tree_root.get_first_child()
		while it:
			var md: Dictionary = it.get_metadata(0)
			var idx: int = md["track_idx"]
			if it.is_checked(0) and idx >= 0 and idx < animation.get_track_count():
				var reset_idx = reset_animation.find_track(animation.track_get_path(idx), animation.track_get_type(idx))
				new_track_count += AnimTrackConvert.convert_track_to_bezier(animation, idx, new_track_count)
				if reset_idx >= 0:
					new_reset_track_count += AnimTrackConvert.convert_track_to_bezier(reset_animation, reset_idx, new_reset_track_count)
			it = it.get_next()
		
		var unused_reset_tracks: Array[NodePath]
		
		# Go through the selected tracks in reverse and delete the orinal trakcs (but not the reset
		# tracks yet)
		# We add any deleted tracks to a list
		it = tree_root.get_child(-1)
		while(it):
			var md: Dictionary = it.get_metadata(0)
			var idx: int = md["track_idx"]
			if it.is_checked(0) and idx >= 0 and idx < animation.get_track_count():
				unused_reset_tracks.append(animation.track_get_path(idx))
				animation.remove_track(idx)
			it = it.get_prev()
		
		# We iterate through the list of deleted tracks and remove any that still have users
		# in other animations, meaning they should not be deleted from the reset animation
		for i in range(unused_reset_tracks.size() -1, -1, -1) :
			if _get_animation_track_reference_count(unused_reset_tracks[i], lib) > 2:
				unused_reset_tracks.remove_at(i)
		
		# We iterate through the remaining list and delete the reset tracks it contains.
		for i in range(reset_animation.get_track_count() -1, -1, -1):
			if reset_animation.track_get_type(i) == Animation.TYPE_VALUE:
				if unused_reset_tracks.has(reset_animation.track_get_path(i)):
					reset_animation.remove_track(i)
	
	
	var ur = get_undo_redo()
	
	ur.create_action("Convert animation to Bezier")
	
	ur.add_undo_method(lib, "add_animation", anim_name.split("/")[-1], player.get_animation(anim_name))
	ur.add_do_method(lib, "add_animation", anim_name.split("/")[-1], animation)
#
	ur.add_undo_method(reset_lib, "add_animation", StringName("RESET"), player.get_animation(StringName("RESET")))
	ur.add_do_method(reset_lib, "add_animation", StringName("RESET"), reset_animation)
	
	ur.commit_action()


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

func _add_convert_option():
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
		"Convert Value Track to Bezier Track...",
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
	
	if convert_dialogue.confirmed.is_connected(_convert):
		convert_dialogue.confirmed.disconnect(_convert)


func _on_menu_button_pressed(id: int):
	if id == TOOL_CONVERT:
		_pop_up_convert()
