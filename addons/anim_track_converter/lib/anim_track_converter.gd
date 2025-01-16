# Utility class to handle conversion logic

const EditorUtil := preload("res://addons/anim_track_converter/lib/editor_util.gd")

var _editor_plugin: EditorPlugin
var _undo_redo: EditorUndoRedoManager


func _init(editor_plugin: EditorPlugin) -> void:
	_editor_plugin = editor_plugin
	_undo_redo = editor_plugin.get_undo_redo()


static func convert_track_to_bezier(p_anim: Animation, p_index: int, p_insert_at: int) -> int:
	if (p_insert_at < 0):
		p_insert_at = p_anim.get_track_count()

	var track_path: String = p_anim.track_get_path(p_index)
	
	var key_type = typeof(p_anim.track_get_key_value(p_index, 0))
	var subindices = get_bezier_subindices_for_type(key_type)

	for i in subindices.size():
		var subindex: String = subindices[i]
		var new_track_index: int = p_insert_at + i

		p_anim.add_track(Animation.TYPE_BEZIER, new_track_index)
		
		p_anim.track_set_path(new_track_index, track_path + subindex)
		
		var key_count: int = p_anim.track_get_key_count(p_index)

		for j in key_count:
			var key_time: float = p_anim.track_get_key_time(p_index, j)
			var key_value = p_anim.track_get_key_value(p_index, j)
			var key_sub_value = key_value if subindex.is_empty() else key_value[i]
			p_anim.bezier_track_insert_key(new_track_index, key_time, key_sub_value, Vector2(0.0, 0.0), Vector2(0.0, 0.0))
		
	return subindices.size();


static func get_bezier_subindices_for_type(p_type) -> Array[String]:
	var subindices: Array[String];
	match p_type:
		TYPE_INT:
			subindices.push_back("")
		TYPE_FLOAT:
			subindices.push_back("")
		TYPE_VECTOR2:
			subindices.push_back(":x")
			subindices.push_back(":y")
		TYPE_VECTOR3:
			subindices.push_back(":x")
			subindices.push_back(":y")
			subindices.push_back(":z")
		TYPE_QUATERNION:
			subindices.push_back(":x")
			subindices.push_back(":y")
			subindices.push_back(":z")
			subindices.push_back(":w")
		TYPE_COLOR:
			subindices.push_back(":r")
			subindices.push_back(":g")
			subindices.push_back(":b")
			subindices.push_back(":a")
		TYPE_PLANE:
			subindices.push_back(":x")
			subindices.push_back(":y")
			subindices.push_back(":z")
			subindices.push_back(":d")
	return subindices
