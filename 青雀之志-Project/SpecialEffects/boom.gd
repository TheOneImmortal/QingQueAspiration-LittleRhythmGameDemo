extends Node2D


@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var timer: Timer = $Timer


func _ready() -> void:
	gpu_particles_2d.emitting = true
	timer.start(gpu_particles_2d.lifetime)
	timer.timeout.connect(Callable(self, "queue_free"))
