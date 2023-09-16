extends StaticBody2D

var CLOSED = load("res://res/assets/enviroment/test/cat block/face.png");
var OPEN = load("res://res/assets/enviroment/test/cat block/face_open.png");
var rngChecker = false;
var rng = RandomNumberGenerator.new();
var randomNumber;
const TRIGGER = 5;
var onetime = true;

func _ready():
	$handler.play("idle");
	$paws.play("default");

func _process(delta):
	if not rngChecker:
		rngChecker = true;
		randomNumber = int(rng.randf_range(1.0, 11.0));
		await get_tree().create_timer(3).timeout;
		rngChecker = false;

	if onetime:
		if randomNumber == TRIGGER:
			onetime = false;
			$meow.play();
			$face.set_texture(OPEN);
			await get_tree().create_timer(1).timeout;
			randomNumber = 1;
			$face.set_texture(CLOSED);
			onetime = true;
