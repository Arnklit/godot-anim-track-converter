# Utility class to handle conversion logic

const EditorUtil := preload("res://addons/anim_track_converter/lib/editor_util.gd")

var _editor_plugin: EditorPlugin
var _undo_redo: EditorUndoRedoManager


func _init(editor_plugin: EditorPlugin) -> void:
	_editor_plugin = editor_plugin
	_undo_redo = editor_plugin.get_undo_redo()


func _convert_track_to_bezier(p_anim: Animation, p_index: int, p_mode: int, p_insert_at: int) -> int:
	if (p_insert_at < 0):
		p_insert_at = p_anim.get_track_count()

	var track_path: String = p_anim.track_get_path(p_index);
	var key_type = p_anim.track_get_key_value(p_index, 0).get_type();
	var subindices = _get_bezier_subindices_for_type(key_type);

	### Let's fix undo-redo after, we are gonna do it differently anyway
	### We will make a full copy of the animation, do the convert to the copy
	### and only perform undo redo with applying the converted animation instead
	### of the original
	
	#EditorUndoRedoManager *undo_redo = EditorUndoRedoManager::get_singleton();
	#undo_redo->create_action(TTR("Animation Convert Track to Bezier"), UndoRedo::MERGE_DISABLE, p_anim, true);

	for i in subindices.size():
		var subindex: String = subindices[i];
		var new_track_index: int = p_insert_at + i;

		p_anim.add_track(Animation.TYPE_BEZIER, new_track_index)
		p_anim.remove_track(new_track_index)

		p_anim.track_set_path(new_track_index, track_path + subindex)
		
		var key_count: int = p_anim.track_get_key_count(p_index);

		for j in key_count:
			var key_time: float = p_anim.track_get_key_time(p_index, j);
			var key_value = p_anim.track_get_key_value(p_index, j);
			var key_sub_value = key_value if subindex.is_empty() else key_value.get(subindex.substr(1));
			p_anim.bezier_track_insert_key(new_track_index, key_time, key_sub_value, Vector2(0.0, 0.0), Vector2(0.0, 0.0))
		

		for j in key_count:
		
			undo_redo->add_do_method(this, "_bezier_track_set_key_handle_mode", p_anim, new_track_index, j, p_mode, Animation::HANDLE_SET_MODE_AUTO);
			
	}

	undo_redo->commit_action();

	return subindices.size();
}
