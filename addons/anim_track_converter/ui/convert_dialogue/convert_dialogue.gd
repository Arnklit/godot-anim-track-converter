@tool
extends AcceptDialog

const CustomEditorPlugin := preload("res://addons/anim_track_converter/plugin.gd")
const EditorUtil := preload("res://addons/anim_track_converter/lib/editor_util.gd")

const AnimTrackConverter = preload("res://addons/anim_track_converter/lib/anim_track_converter.gd")


var _editor_plugin: CustomEditorPlugin
var _editor_interface: EditorInterface
var _anim_track_converter: AnimTrackConverter
var _anim_player: AnimationPlayer

@onready var track_convert_select: Tree = $TrackConvertVbox/TrackConvertSelect

func init(editor_plugin: CustomEditorPlugin) -> void:
	_editor_plugin = editor_plugin
	_editor_interface = editor_plugin.get_editor_interface()
	_anim_track_converter = AnimTrackConverter.new(_editor_plugin)

	#var troot := track_convert_select.create_item()
	#var it := track_convert_select.create_item(troot)
	#it.set_editable(0, true)
	#it.set_selectable(0, true)
	#it.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	#it.set_text(0, "Test item")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
