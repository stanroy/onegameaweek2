extends Node

@export_flags_3d_physics var collision_mask: int
var level_ground_mesh: MeshInstance3D
var max_bounds: Vector3
var origin: Vector3
var margin: float = 5.0
var dig_spot_scene = preload("res://ents/dig_spot/dig_spot.tscn")
var dig_spot_instance: Node3D

# Plan for the dig spot randomization:
# get meshes size
# get container node3d position (its going to be an origin of this system), we're going to add 
# meshe's max size to it, this way we have mapped xz plane for the dig spot to exist in
# put the dig spot in the sky, randomize xz position, fire raycast downwards
# get ground plane position, set dig spot position to position the raycast gets
# ???
# profit


func _ready() -> void:
	# load ground mesh, size and pos
	level_ground_mesh = get_parent().find_child("Ground") as MeshInstance3D
	origin = (get_parent().find_child("GroundContainer") as Node3D).position
	# add height to prepare for raycast
	origin.y = 0.0
	max_bounds = level_ground_mesh.mesh.get_aabb().size
	# ignore y size of the mesh
	max_bounds.y = 0.0
	#print(level_ground_mesh.mesh.get_aabb().size)
	#print(level_ground_mesh.mesh.get_aabb().position)
	
	
	print("origin " + str(origin))
	print("max_size " + str(max_bounds))
	print("origin + max_size " + str(origin+max_bounds))

	# instantiate dig spot
	dig_spot_instance = dig_spot_scene.instantiate() as Node3D
	
	# set dig spot in the sky and randomize pos
	dig_spot_instance.position = _randomize_dig_spot_pos(origin, max_bounds, margin)
	
	
	get_parent().add_child.call_deferred(dig_spot_instance)
	var new_pos = _fire_raycast()
	if new_pos != Vector3.ZERO:
		dig_spot_instance.position = new_pos
	


func _fire_raycast() -> Vector3:
	var space_state = get_parent().get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(dig_spot_instance.position, dig_spot_instance.position + (Vector3.DOWN * 150.0))
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
		print("Hit:", result.collider, "at", result.position)
	else:
		print("No hit :(")
		return Vector3.ZERO

func _randomize_dig_spot_pos(origin: Vector3, max_bounds: Vector3, margin: float) -> Vector3:
	var x = randf_range(origin.x + margin, max_bounds.x - margin)
	var z = randf_range(origin.z + margin, max_bounds.z - margin)

	
	return Vector3(x,50.0,z)
