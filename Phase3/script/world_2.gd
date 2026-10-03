extends Node2D

@onready var anim_player = $world2openingcutscene/AnimationPlayer
@onready var camera = $world2openingcutscene/Path2D/PathFollow2D/Camera2D
@onready var npc = $npc

var is_opening_cutscene = false

var has_player_entered_area = false
var player = null

var is_path_following = false

var smoke_has_happened = false
var smoke_is_happening = false


func _ready():
	# init chest
	PlayerStats.inventory = $Chest/InventoryStacked
	PlayerStats.inventory.create_and_add_item("health_potion")
	PlayerStats.c_inventory = $Chest/CtrlInventoryStacked


func _physics_process(_delta):
	if is_opening_cutscene:
		var path_follower = $world2openingcutscene/Path2D/PathFollow2D
		
		if is_path_following:
			path_follower.progress_ratio += 0.002
			
			if path_follower.progress_ratio >= 1:
				cutscene_ending()
				
			if !smoke_has_happened and path_follower.progress_ratio >= 0.85 and !smoke_is_happening:
				smoke_is_happening = true
				toggle_smoke()
				await get_tree().create_timer(10).timeout
				$world2openingcutscene/TileMap_finished.visible = true
				$world2openingcutscene/TileMap_unfinished.visible = false
				npc.set_start_position(npc.start_position)
				toggle_smoke()
				await get_tree().create_timer(0.5).timeout
				smoke_has_happened = true
				smoke_is_happening = false

func toggle_smoke():
	var smoke1 = $world2openingcutscene/SmokeParticles1
	var smoke2 = $world2openingcutscene/SmokeParticles2
	var smoke3 = $world2openingcutscene/SmokeParticles3
	smoke1.emitting = !smoke1.emitting
	smoke2.emitting = !smoke2.emitting
	smoke3.emitting = !smoke3.emitting

func _on_player_detection_body_entered(body):
	if body.has_method("player"):
		player = body
		if !has_player_entered_area:
			has_player_entered_area = true
			cutscene_opening()


func cutscene_opening():
	is_opening_cutscene = true
	anim_player.play("cover_fade")
	player.camera.enabled = false
	camera.enabled = true
	is_path_following = true


func cutscene_ending():
	is_path_following = false
	is_opening_cutscene = false
	camera.enabled = false
	player.camera.enabled = true
	$world2openingcutscene.visible = false
	$world2main.visible = true
