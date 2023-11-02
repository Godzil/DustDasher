extends RigidBody3D

## Vertical force applyed per second
@export_range(750, 3000) var thurst : float = 1000.0

## Rotation force applyed per second
@export_range(50, 200) var torque_thrust : float = 100.0


@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var is_transitionning : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_pressed('boost'):
		apply_central_force(basis.y * delta * thurst)
		booster_particles.emitting = true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		booster_particles.emitting = false
		if rocket_audio.playing == true:
			rocket_audio.stop()
			
	if Input.is_action_pressed("rotate_left"):
		right_booster_particles.emitting = true
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
	else:
		right_booster_particles.emitting = false

	if Input.is_action_pressed("rotate_right"):
		left_booster_particles.emitting = true
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))
	else:
		left_booster_particles.emitting = false

func _on_body_entered(body : Node) -> void:
	if is_transitionning == false:
		if body.is_in_group("Goal"):
			complete_level(body.file_path)

		if body.is_in_group("Hazard"):
			crash_sequence()

func complete_level(next_level_file : String) -> void:
	set_process(false)
	is_transitionning = true
	success_audio.play()
	success_particles.emitting = true
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))

func crash_sequence() -> void:
	set_process(false)
	is_transitionning = true
	explosion_audio.play()
	explosion_particles.emitting = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
