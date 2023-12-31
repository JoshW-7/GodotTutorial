extends CharacterBody2D
class_name Player


const SPEED = 300.0
const JUMP_VELOCITY = -500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var start_position

enum State {
	NORMAL,
	HIT
}
var state := State.NORMAL

func _ready():
	start_position = global_position

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	match state:
		State.NORMAL:
			# Handle Jump.
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				$Jump.play()

			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var direction = Input.get_axis("ui_left", "ui_right")
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		
			if not is_on_floor():
				$AnimationPlayer.play("jump")
			elif velocity.x != 0:
				$AnimationPlayer.play("walk")
			else:
				$AnimationPlayer.play("idle")
				
			if Input.is_action_pressed("ui_left"):
				$Sprite2D.flip_h = true
			elif Input.is_action_pressed("ui_right"):
				$Sprite2D.flip_h = false
		State.HIT:
			pass
			
	move_and_slide()


func _on_area_2d_body_entered(body):
	state = State.HIT
	velocity = Vector2.ZERO
	$Hit.play()
	$AnimationPlayer.play("hit")
	await $AnimationPlayer.animation_finished
	global_position = start_position
	state = State.NORMAL
	
func play_walk_sound():
	if is_on_floor():
		$Walk.play()
		
func emit_particles():
	$CPUParticles2D.emitting = true
