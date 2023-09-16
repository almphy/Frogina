extends Area2D

func _on_body_entered(body):
	if body.has_method("collectableManager"):
		$sprite.queue_free();
		$hitbox.queue_free();
		$sfx.play();
		$collect.restart();
		body.collectableManager("coin");
		await get_tree().create_timer(1).timeout;
		self.queue_free();
