@tool
extends Tree

const TrackConverter := preload("res://addons/anim_track_converter/lib/anim_track_converter.gd")

var _editor_plugin: EditorPlugin
var _gui: Control
var _root: Node

func init(editor_plugin: EditorPlugin):
	_editor_plugin = editor_plugin
	_gui = editor_plugin.get_editor_interface().get_base_control()
	_editor_plugin.scene_changed.connect(_scene_changed)


func _exit_tree() -> void:
	if _editor_plugin and _editor_plugin.scene_changed.is_connected(_scene_changed):
		_editor_plugin.scene_changed.disconnect(_scene_changed)


func _scene_changed(scne_root: Node) -> void:
	_root = scne_root


func generate_track_list(animation: Animation, animation_player: AnimationPlayer) -> void:
	
	#var root: Node = get_node(animation_player.root_node) ### EHHH I DON'T KNOW IF THAT'S RIGHT
		
	var troot: TreeItem = create_item()
	
	for i in animation.get_track_count():
		if animation.track_get_key_count(i) == 0:
			continue
		var path: NodePath = animation.track_get_path(i)
		var node: Node = null
		
		if _root:
			node = _root.get_node_or_null(path)
		
		var text: String
		
		var icon: Texture2D
		
		if node:
			icon = _gui.get_theme_icon(node.get_class(), "EditorIcons")
			
			text = node.get_name()
			
			var sub_path: String
			
			for t in path.get_subname_count():
				text += "."
				text += path.get_subname(t)
			
			# Store full path instead for copying.
			path = NodePath(node.get_path().get_concatenated_names() + ":" + path.get_concatenated_subnames())
		
		else:
			text = path
			var sep = text.find(":")
			if sep != -1:
				text = text.substr(sep, text.length())
		
		var track_type: String
		match animation.track_get_type(i):
			Animation.TYPE_POSITION_3D:
				track_type = "Position"
			Animation.TYPE_ROTATION_3D:
				track_type = "Rotation"
			Animation.TYPE_SCALE_3D:
				track_type = "Scale"
			Animation.TYPE_BLEND_SHAPE:
				track_type = "BlendShape"
			Animation.TYPE_METHOD:
				continue
			Animation.TYPE_BEZIER:
				continue
			Animation.TYPE_AUDIO:
				continue
			Animation.TYPE_ANIMATION:
				continue
		
		if !track_type.is_empty():
			text += track_type
		
		var it: TreeItem = create_item(troot)
		it.set_editable(0, true)
		it.set_selectable(0, true)
		it.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		it.set_icon(0, icon)
		it.set_text(0, text) # text string is empty
		var md := {}
		md["track_idx"] = i
		md["path"] = path
		it.set_metadata(0, md)
