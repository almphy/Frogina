extends ParallaxLayer

var BACKGROUND_SPEED: float = -20;

func _process(delta):
	self.motion_offset.x += BACKGROUND_SPEED * delta;
	self.motion_offset.y += BACKGROUND_SPEED * delta;
