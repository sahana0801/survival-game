class_name ExecutionerMinion extends CharacterBody2D

signal minion_died

@export var max_health: int = 25
var current_health: int = 25
var is_dead: bool = false
var speed: float = 130.0

var player: Node2D = null

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HitBox


func _ready() -> void:
	current_health = max_health
	if anim_sprite != null:
		anim_sprite.play("appear")
		var tree := get_tree()
		if tree != null:
			await anim_sprite.animation_finished
		if not is_inside_tree():
			return
		anim_sprite.play("idle")
		
	# Find player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]


func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if player != null and is_instance_valid(player) and player.is_alive:
		var dir = (player.global_position - global_position).normalized()
		velocity = velocity.move_toward(dir * speed, delta * 400.0)
		if anim_sprite != null:
			anim_sprite.flip_h = dir.x < 0
		move_and_slide()


func take_damage(damage: int, is_crit: bool = false) -> void:
	if is_dead:
		return
		
	current_health -= damage
	var num_color = Color(1.0, 0.6, 0.1) if is_crit else Color(0.8, 0.3, 1.0)
	Helpers.spawn_damage_number(global_position, damage, num_color, is_crit, "-")
	
	if current_health <= 0:
		death()


func death() -> void:
	if is_dead:
		return
	is_dead = true
	minion_died.emit()
	velocity = Vector2.ZERO
	
	if hitbox != null:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
		
	if anim_sprite != null:
		anim_sprite.play("death")
		var tree := get_tree()
		if tree != null:
			await anim_sprite.animation_finished
	if not is_inside_tree():
		return
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body is Player or body.has_method("hurtByEnemy"):
		body.hurtByEnemy(self, 10)
		death()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if is_dead:
		return
	if area.has_method("arrow_deal_damage") or area.has_method("sword_deal_damage"):
		var damage = area.damage if "damage" in area else PlayerStats.get_weapon_damage()
		var is_crit = area.is_crit if "is_crit" in area else false
		take_damage(damage, is_crit)


func enemy() -> void:
	pass
