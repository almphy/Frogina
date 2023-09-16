extends Node2D

var MASTER = AudioServer.get_bus_index("Master");
var MUSIC = AudioServer.get_bus_index("Music");
var SFX = AudioServer.get_bus_index("SFX");

func _ready():
	$almphy/handle.play("idle");
	$intro.play("intro");

func end():
	get_tree().change_scene_to_file("res://meta/test.tscn");

func _on_musicvol_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC, value);
	if value == -30: AudioServer.set_bus_mute(MUSIC, true);
	else: AudioServer.set_bus_mute(MUSIC, false);
	
func _on_mastervol_value_changed(value):
	AudioServer.set_bus_volume_db(MASTER, value);
	if value == -30: AudioServer.set_bus_mute(MASTER, true);
	else: AudioServer.set_bus_mute(MASTER, false);

func _on_sfxvol_value_changed(value):
	AudioServer.set_bus_volume_db(SFX, value);
	if value == -30: AudioServer.set_bus_mute(SFX, true);
	else: AudioServer.set_bus_mute(SFX, false);

func _on_testroom_pressed():
	get_tree().change_scene_to_file("res://meta/test.tscn");

func _on_quit_pressed():
	get_tree().quit();
