extends CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

var IDLE_RES = load("res://res/assets/player/idle.png");
var WALK_RES = load("res://res/assets/player/walk.png");
var JUMP_RES = load("res://res/assets/player/jump.png");
var FALL_RES = load("res://res/assets/player/fall.png");

var MACH0_RES = load("res://res/assets/player/speed-o-meter/0.png");
var MACH1_RES = load("res://res/assets/player/speed-o-meter/1.png");
var MACH2_RES = load("res://res/assets/player/speed-o-meter/2.png");
var MACH3_RES = load("res://res/assets/player/speed-o-meter/3.png");
var MACH4_RES = load("res://res/assets/player/speed-o-meter/4.png");

@onready var UI = $UI;
@onready var COINS = $UI/coins;
@onready var SCORE = $UI/score;
@onready var STATUS = $UI/status;
@onready var VEGGIES = $UI/veggies;
@onready var COYOTE_TIME = $coyotetime;
@onready var SPRITE = $sprite;
@onready var JUMP_BUFFER = $jumpbuffer;
@onready var ANIMATIONS = $basic;
@onready var MACH4_PARTICLES = $mach3;
@onready var SKID_PARTICLES = $skid;

@export var state = 0;
#0 - idle
#1 - mach1
#2 - mach2
#3 - mach3
#4 - mach4
#5- crouching
#6 - jumping
#7 - falling
#8 - attacking 
#9 - taking damage
var moving: bool = false;
var was_on_floor: bool;
var last_direction;
var direction;
var stunned = false;
var skidding = false;
var friction;
var tempspeed;

var mach4: int = 800;
var mach3: int = 650;
var mach2: int = 400;
var mach1: int = 150;
var mach0: int = 0;
var acceleration: int = 3;
var jump_height: float = -800.0;

func _physics_process(delta):
	print(tempspeed);
	friction = false;
	_state_machine();
	
	if is_on_floor() and state == 4: MACH4_PARTICLES.set_emitting(true);
	else: MACH4_PARTICLES.set_emitting(false);
			
	if not is_on_floor() and COYOTE_TIME.is_stopped():
		velocity.y += gravity * delta;

	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not COYOTE_TIME.is_stopped():
			COYOTE_TIME.stop();
			velocity.y = jump_height;
		else:
			JUMP_BUFFER.start();
		
	if Input.is_action_just_released("jump") && velocity.y < 0:
		velocity.y *= 0.5;
		
	skidHandler("left", "right");
	if int(velocity.x) <= -200 and skidding and direction == "left":
		stunned = false;
		direction = null;
		skidding = false;
		
	skidHandler("right", "left");
	if int(velocity.x) >= 200 and skidding and direction == "right":
		stunned = false;
		direction = null;
		skidding = false;
			
	if not stunned:
		if Input.is_action_pressed("right"):
			direction = "right";
		elif Input.is_action_pressed("left"):
			direction = "left";
		else:
			direction = null;
			if is_on_floor():
				last_direction = null;
			
	if stunned and direction == "right":
		if int(velocity.x) == mach0:
			last_direction = "right";
		SPRITE.flip_h = false;
		velocity.x = min(velocity.x + acceleration, mach4);
	if stunned and direction == "left":
		if int(velocity.x) == mach0:
			last_direction = "left";
		SPRITE.flip_h = true;
		velocity.x = max(velocity.x - acceleration, -mach4);
		
	if direction == "right":
		if int(velocity.x) == mach0 or int(velocity.x) >= mach3:
			last_direction = "right";
		SPRITE.flip_h = false;
		velocity.x = min(velocity.x + acceleration, mach4);
	if direction == "left":
		if int(velocity.x) == mach0 or int(velocity.x) <= -mach3:
			last_direction = "left";
		SPRITE.flip_h = true;
		velocity.x = max(velocity.x - acceleration, -mach4);
	if direction == null:
		friction = true;
		
	if not is_on_floor():
		if not skidding: acceleration = 10;
		else: acceleration = 20;
		if friction: velocity.x = lerp(int(velocity.x), 0, .01);
	else:
		if not skidding: acceleration = 3;
		else: acceleration = 200;
		if friction: velocity.x = lerp(int(velocity.x), 0, .15);
		
	was_on_floor = is_on_floor();
	move_and_slide();
	
	if is_on_floor() and not JUMP_BUFFER.is_stopped():
		JUMP_BUFFER.stop();
		velocity.y = jump_height;
		
func _state_machine():
	if not is_on_floor() and Input.is_action_pressed("jump"): state = 6;
	if not is_on_floor() and not Input.is_action_pressed("jump"): state = 7;
	if not is_on_floor() and was_on_floor and state == 7:
		COYOTE_TIME.start();
		
	if velocity.x <= mach4 and velocity.x > mach3 or velocity.x >= -mach4 and velocity.x < -mach3:
		$UI/speedometer.set_texture(MACH4_RES);
		if is_on_floor() or not COYOTE_TIME.is_stopped():
			state = 4;
	elif velocity.x <= mach3 and velocity.x > mach2 or velocity.x >= -mach3 and velocity.x < -mach2:
		$UI/speedometer.set_texture(MACH3_RES);
		if is_on_floor() or not COYOTE_TIME.is_stopped():
			state = 3;
	elif velocity.x <= mach2 and velocity.x > mach1 or velocity.x >= -mach2 and velocity.x < -mach1:
		$UI/speedometer.set_texture(MACH2_RES);
		if is_on_floor() or not COYOTE_TIME.is_stopped():
			state = 2;
	elif velocity.x <= mach1 and velocity.x > mach0 or velocity.x >= -mach1 and velocity.x < -mach0:
		$UI/speedometer.set_texture(MACH1_RES);
		if is_on_floor() or not COYOTE_TIME.is_stopped():
			state = 1;
	elif velocity.x == mach0:
		$UI/speedometer.set_texture(MACH0_RES);
		if is_on_floor() or not COYOTE_TIME.is_stopped():
			state = 0;
		
	match state:
		0: #idle
			if not UI.scoreface:
				STATUS.play("default");
			moving = false;
			SPRITE.set_texture(IDLE_RES);
			SPRITE.set_vframes(1);
			ANIMATIONS.speed_scale = 1;
			ANIMATIONS.play("idle");
		1: #mach1
			if not UI.scoreface:
				STATUS.play("default");
			moving = true;
			SPRITE.set_texture(WALK_RES);
			SPRITE.set_vframes(2);
			ANIMATIONS.speed_scale = 1;
			ANIMATIONS.play("walk");
		2: #mach2
			if not UI.scoreface:
				STATUS.play("default");
			moving = true;
			SPRITE.set_texture(WALK_RES);
			SPRITE.set_vframes(2);SKID_PARTICLES
			ANIMATIONS.speed_scale = 1.2;
			ANIMATIONS.play("walk");
		3: #mach3
			if not UI.scoreface:
				STATUS.play("score");
			moving = true;
			SPRITE.set_texture(WALK_RES);
			SPRITE.set_vframes(2);
			ANIMATIONS.speed_scale = 1.4;
			ANIMATIONS.play("walk");
		4: #mach4
			if not UI.scoreface:
				STATUS.play("scream");
			moving = true;
			SPRITE.set_texture(WALK_RES);
			SPRITE.set_vframes(2);
			ANIMATIONS.speed_scale = 1.6;
			ANIMATIONS.play("walk");
		6: #jump
			pass;
		7: #fall
			pass;
		_:
			get_tree().quit();

func skidHandler(x: String, y: String):
	if not friction:
		tempspeed = velocity.x;
	if not skidding and Input.is_action_pressed(x) and last_direction == y:
		friction = true;
		if velocity.x < 3 and velocity.x > -3:
			SKID_PARTICLES.restart();
			velocity.x = 0;
			stunned = true;
			skidding = true;
			direction = x;

func collectableManager(x: String):
	match x:
		"coin":
			UI.COINS+=1;
			UI.SCORE+=1000;
		"veggies":
			UI.VEGGIES+=1;
			UI.SCORE+=10000;
	COINS.set_text(" [tornado radius=30.0 freq=1.0]" + str(UI.COINS));
	SCORE.set_text("[wave amp=350 freq=2][center]" + str(UI.SCORE));
	VEGGIES.set_text(" [tornado radius=30.0 freq=1.0]" + str(UI.VEGGIES));
