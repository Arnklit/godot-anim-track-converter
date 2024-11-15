@tool
extends AcceptDialog

const CustomEditorPlugin := preload("res://addons/anim_track_converter/plugin.gd")
const EditorUtil := preload("res://addons/anim_track_converter/lib/editor_util.gd")

const AnimTrackConverter = preload("res://addons/anim_track_converter/lib/anim_track_converter.gd")


var _editor_plugin: CustomEditorPlugin
var _editor_interface: EditorInterface
var _anim_track_converter: AnimTrackConverter
var _anim_player: AnimationPlayer



func init(editor_plugin: CustomEditorPlugin) -> void:
	_editor_plugin = editor_plugin
	_editor_interface = editor_plugin.get_editor_interface()
	_anim_track_converter = AnimTrackConverter.new(_editor_plugin)
	#node_select.init(_editor_plugin)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
