class_name CharacterSwapNPC extends CharacterBody2D
## Companion NPC located at the starting village campfire.
## Allows the player to seamlessly swap between the Knight and Archer characters.
## Whichever character is inactive rests here by the campfire.

@export var npc_name: String = "Cung Thủ"
@export var interaction_distance: float = 75.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_badge: Control = $PromptBadge
@onready var prompt_label: Label = $PromptBadge/PromptLabel
@onready var speech_bubble: Control = $SpeechBubble
@onready var dialogue_text: RichTextLabel = $SpeechBubble/DialogueText
@onready var speaker_name_label: Label = $SpeechBubble/SpeakerNameLabel
@onready var bubble_timer: Timer = $BubbleTimer

var player: Player = null
var is_player_in_range: bool = false
var type_tween: Tween = null
var prompt_tween: Tween = null

var archer_frames: SpriteFrames = null
var knight_frames: SpriteFrames = null


func _ready() -> void:
	_setup_sprite_frames()
	
	if prompt_badge != null:
		prompt_badge.visible = false
		prompt_badge.modulate.a = 0.0
	if speech_bubble != null:
		speech_bubble.visible = false
		speech_bubble.modulate.a = 0.0
	
	if interaction_area != null:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	if bubble_timer != null:
		bubble_timer.timeout.connect(_on_bubble_timeout)
	
	if PlayerStats != null:
		PlayerStats.characterChanged.connect(_on_character_changed)
	
	_update_npc_appearance()


func _setup_sprite_frames() -> void:
	# 1. Build Archer Frames from Girl-Sheet.png
	var girl_path = "res://art/SimpleCharacter/Girl-Sheet.png"
	var girl_tex: Texture2D = null
	if ResourceLoader.exists(girl_path):
		girl_tex = load(girl_path)
	if girl_tex == null:
		var abs_path = ProjectSettings.globalize_path(girl_path)
		if FileAccess.file_exists(girl_path):
			var img = Image.load_from_file(abs_path)
			if img != null:
				girl_tex = ImageTexture.create_from_image(img)

	if girl_tex != null:
		archer_frames = SpriteFrames.new()
		var make_f = func(idx: int) -> AtlasTexture:
			var at = AtlasTexture.new()
			at.atlas = girl_tex
			at.region = Rect2(idx * 24, 0, 24, 24)
			return at

		archer_frames.add_animation(&"idle")
		archer_frames.set_animation_speed(&"idle", 5.0)
		archer_frames.set_animation_loop(&"idle", true)
		for i in 4:
			archer_frames.add_frame(&"idle", make_f.call(i))

	# 2. Build Knight Frames from Character_Idle_Sword.png
	var knight_path = "res://art/fantasy/Art/Characters/Main Character/Character_Idle_Sword.png"
	var knight_tex: Texture2D = null
	if ResourceLoader.exists(knight_path):
		knight_tex = load(knight_path)
	if knight_tex == null:
		var abs_k = ProjectSettings.globalize_path(knight_path)
		if FileAccess.file_exists(knight_path):
			var img_k = Image.load_from_file(abs_k)
			if img_k != null:
				knight_tex = ImageTexture.create_from_image(img_k)

	if knight_tex != null:
		knight_frames = SpriteFrames.new()
		var make_kf = func(col: int) -> AtlasTexture:
			var at = AtlasTexture.new()
			at.atlas = knight_tex
			# South idle is row 3 (offset y = 3 * 48 = 144)
			at.region = Rect2(col * 40, 144, 40, 48)
			return at

		knight_frames.add_animation(&"idle")
		knight_frames.set_animation_speed(&"idle", 5.0)
		knight_frames.set_animation_loop(&"idle", true)
		for i in 4:
			knight_frames.add_frame(&"idle", make_kf.call(i))


func _process(_delta: float) -> void:
	if is_player_in_range and player != null:
		if Input.is_action_just_pressed("harvest") or Input.is_action_just_pressed("ui_accept"):
			_trigger_character_swap()


func _update_npc_appearance() -> void:
	var active_char = PlayerStats.active_character if PlayerStats else PlayerStats.CharacterType.KNIGHT
	
	if active_char == PlayerStats.CharacterType.KNIGHT:
		# Player is Knight -> NPC is Archer
		npc_name = "Cung Thủ"
		if sprite != null and archer_frames != null:
			sprite.sprite_frames = archer_frames
			sprite.scale = Vector2(2.4, 2.4)
			sprite.offset = Vector2(0, -10)
			sprite.play("idle")
		if prompt_label != null:
			prompt_label.text = "💬 [E] Đổi sang Cung Thủ"
	else:
		# Player is Archer -> NPC is Knight
		npc_name = "Hiệp Sĩ"
		if sprite != null and knight_frames != null:
			sprite.sprite_frames = knight_frames
			sprite.scale = Vector2(2.0, 2.0)
			sprite.offset = Vector2(0, -16)
			sprite.play("idle")
		if prompt_label != null:
			prompt_label.text = "💬 [E] Đổi sang Hiệp Sĩ"

	if speaker_name_label != null:
		speaker_name_label.text = npc_name


func _on_character_changed(_new_char: int) -> void:
	_update_npc_appearance()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		is_player_in_range = true
		_show_prompt(true)


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		is_player_in_range = false
		_show_prompt(false)
		_hide_speech_bubble()


func _show_prompt(show: bool) -> void:
	if prompt_badge == null:
		return
	if prompt_tween != null and prompt_tween.is_valid():
		prompt_tween.kill()
	prompt_tween = create_tween()
	
	if show:
		_update_npc_appearance()
		prompt_badge.visible = true
		prompt_tween.tween_property(prompt_badge, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		prompt_tween.tween_property(prompt_badge, "modulate:a", 0.0, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		prompt_tween.tween_callback(func() -> void: prompt_badge.visible = false)


func _trigger_character_swap() -> void:
	if player == null:
		return

	var current_player_char = PlayerStats.active_character
	var target_char: int
	var dialogue_msg: String

	if current_player_char == PlayerStats.CharacterType.KNIGHT:
		target_char = PlayerStats.CharacterType.ARCHER
		dialogue_msg = "Chào Hiệp Sĩ! Hãy để tôi giương cung bảo vệ vùng đất này!"
		PlayerStats.send_message("✦ ĐÃ ĐỔI NHÂN VẬT THÀNH CUNG THỦ (XẠ THỦ) ✦")
	else:
		target_char = PlayerStats.CharacterType.KNIGHT
		dialogue_msg = "Cung Thủ hãy nghỉ ngơi! Để tôi rút kiếm tiên phong dẹp loạn!"
		PlayerStats.send_message("✦ ĐÃ ĐỔI NHÂN VẬT THÀNH HIỆP SĨ (CẬN CHIẾN) ✦")

	# Swap active character on player
	if player.has_method("apply_character_type"):
		player.apply_character_type(target_char)
	else:
		PlayerStats.set_active_character(target_char)

	# Visual spawn notification number
	Helpers.spawn_damage_number(player.global_position, "✦ ĐỔI NHÂN VẬT ✦", Color(1.0, 0.85, 0.25), true, "", "")

	# Display NPC speech
	_display_speech(dialogue_msg)
	_update_npc_appearance()


func _display_speech(text: String) -> void:
	if speech_bubble == null or dialogue_text == null:
		return
	speech_bubble.visible = true
	speech_bubble.modulate.a = 1.0
	dialogue_text.text = text
	
	dialogue_text.visible_ratio = 0.0
	if type_tween != null and type_tween.is_valid():
		type_tween.kill()
	type_tween = create_tween()
	var duration: float = clampf(float(text.length()) * 0.02, 0.4, 1.8)
	type_tween.tween_property(dialogue_text, "visible_ratio", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
	
	if bubble_timer != null:
		bubble_timer.stop()
		bubble_timer.wait_time = duration + 5.0
		bubble_timer.start()


func _on_bubble_timeout() -> void:
	_hide_speech_bubble()


func _hide_speech_bubble() -> void:
	if speech_bubble == null:
		return
	if type_tween != null and type_tween.is_valid():
		type_tween.kill()
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(speech_bubble, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	fade_tween.tween_callback(func() -> void: speech_bubble.visible = false)
