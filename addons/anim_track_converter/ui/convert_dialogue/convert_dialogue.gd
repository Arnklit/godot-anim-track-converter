@tool
extends AcceptDialog

const CustomEditorPlugin := preload("res://addons/anim_track_converter/plugin.gd")
const EditorUtil := preload("res://addons/anim_track_converter/lib/editor_util.gd")
const TrackConvertSelect := preload("res://addons/anim_track_converter/ui/convert_dialogue/track_convert_select.gd")

const AnimTrackConverter = preload("res://addons/anim_track_converter/lib/anim_track_converter.gd")


var _editor_plugin: CustomEditorPlugin
var _editor_interface: EditorInterface
var _anim_track_converter: AnimTrackConverter
var _anim_player: AnimationPlayer

@onready var track_convert_select: TrackConvertSelect = $TrackConvertVbox/TrackConvertSelect

func init(editor_plugin: CustomEditorPlugin) -> void:
	_editor_plugin = editor_plugin
	_editor_interface = editor_plugin.get_editor_interface()
	_anim_track_converter = AnimTrackConverter.new(_editor_plugin)
	track_convert_select.init(_editor_plugin)
