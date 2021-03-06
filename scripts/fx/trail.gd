extends Line2D

export(NodePath) var targetPath
export var trailLength = 0

var target

func _ready():
	target = get_node(targetPath)

func _process(delta):
	if not target:
		queue_free()
		return 
		
	global_rotation = 0
	global_position = Vector2.ZERO
	add_point(target.global_position)
	
	while get_point_count() > trailLength:
		remove_point(0)
