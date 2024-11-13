@tool
extends EditorPlugin

const EditorUtil := preload("lib/editor_util.gd")

var _last_anim_player: AnimationPlayer
const SCENE_TREE_IDX := 0
var _scene_tree: Tree

func _enter_tree() -> void:
	
	
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


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
			push_error("[Animation Refactor] Could not find scene tree editor. Please report this.")
			return null
			
		_scene_tree = _scene_tree_editor.get_child(SCENE_TREE_IDX)
		
	if not _scene_tree:
		push_error("[Animation Refactor] Could not find scene tree editor. Please report this.")
		return null
		
	var found_anim := EditorUtil.find_active_anim_player(
		get_editor_interface().get_base_control(),
		_scene_tree
	)
	
	if found_anim:
		return found_anim
	
	# Get latest edited
	return _last_anim_player
