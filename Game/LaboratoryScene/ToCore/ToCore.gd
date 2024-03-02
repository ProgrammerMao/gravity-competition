extends Area3D

func _on_body_entered(body):
	if body.name != "Correct":
		if body.attribute == "gravity":
			if not body.hijack_node:
				body.hijack_node = self
