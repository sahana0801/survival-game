class_name FemaleNPC extends CharacterBody2D
## Female Adventurer NPC located near the starter town campfire.
## Built following Godot agentic design principles:
## - godot-gdscript-mastery: strong typing, signal-up/call-down, safe tweens
## - godot-composition: decoupled interaction area, clean responsibilities
## - godot-2d-animation: AnimatedSprite2D, advance(0) pose sync
## - godot-dialogue-system: skip-safe visible_ratio typewriter, HUD broadcast

enum State {
	IDLE_CAMPFIRE,
	LOOK_AT_PLAYER,
	CHATTING
}

@export var campfire_path: NodePath = ^"../camp_fire"
@export var npc_name: String = "Elena"
@export var interaction_distance: float = 80.0

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var interaction_area: Area2D = %InteractionArea
@onready var prompt_badge: Control = %PromptBadge
@onready var prompt_label: Label = %PromptLabel
@onready var speech_bubble: Control = %SpeechBubble
@onready var dialogue_text: RichTextLabel = %DialogueText
@onready var speaker_name_label: Label = %SpeakerNameLabel
@onready var bubble_timer: Timer = %BubbleTimer

var current_state: State = State.IDLE_CAMPFIRE
var player: CharacterBody2D = null
var is_player_in_range: bool = false
var dialogue_index: int = 0
var type_tween: Tween = null
var prompt_tween: Tween = null
var campfire_node: Node2D = null

const DIALOGUES: Array[String] = [
	"Chào mừng lữ khách! Hơi ấm từ đống lửa trại này là chốn bình yên hiếm hoi nơi hoang dã. Nhấn 'F' để nhóm lại lửa nếu nó lụi tàn.",
	"Trước khi lên đường khám phá, hãy rèn luyện kỹ năng và chuẩn bị vũ khí thật cẩn thận. Bắn cung chuẩn xác sẽ cứu mạng bạn trong gang tấc.",
	"Đừng quên để ý thanh đói và khát! Bạn có thể uống nước ngọt tại hồ với phím 'Y', và ăn táo thu hoạch được với phím 'X'.",
	"Hãy cẩn thận khi màn đêm buông xuống! Những bóng ma hắc ám thức giấc và quái vật lởn vởn khắp nơi. Hãy luôn giữ lửa trại sáng rực!",
	"Tôi đã nhìn thấy một cánh cổng cổ đại kỳ bí nằm sâu trong rừng về phía đông... Đừng liều lĩnh bước vào nếu trang bị chưa sẵn sàng!",
	"Hãy dừng chân nghỉ ngơi bất cứ khi nào bạn mệt mỏi. Chúc những mũi tên của bạn luôn bách phát bách trúng!"
]


func _ready() -> void:
	if has_node(campfire_path):
		campfire_node = get_node(campfire_path) as Node2D
	
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
	
	if speaker_name_label != null:
		speaker_name_label.text = npc_name
	
	_face_direction(Vector2.DOWN)
	_play_idle()


func _process(_delta: float) -> void:
	if is_player_in_range and player != null:
		if current_state != State.CHATTING:
			_face_towards(player.global_position)
		
		# Check for interaction (harvest key 'E', chat key 'C', or ui_accept)
		if Input.is_action_just_pressed("harvest") or Input.is_action_just_pressed("chat") or Input.is_action_just_pressed("ui_accept"):
			_advance_dialogue()
	elif current_state != State.IDLE_CAMPFIRE:
		_return_to_campfire()


func _face_towards(target_pos: Vector2) -> void:
	var dir_vec: Vector2 = (target_pos - global_position).normalized()
	_face_direction(dir_vec)


func _face_direction(dir: Vector2) -> void:
	if sprite == null:
		return
	var anim_name: StringName = &"idle_down"
	
	# Determine 6-way facing direction
	if dir.y < -0.4:
		if dir.x < -0.3:
			anim_name = &"idle_left_up"
		elif dir.x > 0.3:
			anim_name = &"idle_right_up"
		else:
			anim_name = &"idle_up"
	elif dir.y > 0.4:
		if dir.x < -0.3:
			anim_name = &"idle_left_down"
		elif dir.x > 0.3:
			anim_name = &"idle_right_down"
		else:
			anim_name = &"idle_down"
	else:
		if dir.x < 0:
			anim_name = &"idle_left_down"
		else:
			anim_name = &"idle_right_down"
	
	if sprite.animation != anim_name:
		sprite.play(anim_name)


func _play_idle() -> void:
	_face_direction(Vector2.DOWN)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and (body.name == "Player" or body.has_method("player")):
		player = body as CharacterBody2D
		is_player_in_range = true
		current_state = State.LOOK_AT_PLAYER
		_show_prompt(true)


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		is_player_in_range = false
		_show_prompt(false)
		_hide_speech_bubble()
		_return_to_campfire()


func _return_to_campfire() -> void:
	current_state = State.IDLE_CAMPFIRE
	_play_idle()


func _show_prompt(show: bool) -> void:
	if prompt_badge == null:
		return
	if prompt_tween != null and prompt_tween.is_valid():
		prompt_tween.kill()
	prompt_tween = create_tween()
	
	if show:
		prompt_badge.visible = true
		prompt_tween.tween_property(prompt_badge, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		prompt_tween.tween_property(prompt_badge, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		prompt_tween.tween_callback(func() -> void: prompt_badge.visible = false)


func _advance_dialogue() -> void:
	current_state = State.CHATTING
	if player != null:
		_face_towards(player.global_position)
	
	var text: String = DIALOGUES[dialogue_index]
	dialogue_index = (dialogue_index + 1) % DIALOGUES.size()
	
	_display_speech(text)
	
	# Send to global HUD messages for accessibility if available
	_send_hud_message(npc_name + ": \"" + text + "\"")


func _send_hud_message(text: String) -> void:
	if not is_inside_tree():
		return
	var root: Window = get_tree().root
	if root != null and root.has_node("PlayerStats"):
		var stats: Node = root.get_node("PlayerStats")
		if stats != null and stats.has_method("send_message"):
			stats.send_message(text)


func _display_speech(text: String) -> void:
	if speech_bubble == null or dialogue_text == null:
		return
	speech_bubble.visible = true
	speech_bubble.modulate.a = 1.0
	dialogue_text.text = text
	
	# Skip-safe typewriter effect as per godot-dialogue-system skill
	dialogue_text.visible_ratio = 0.0
	if type_tween != null and type_tween.is_valid():
		type_tween.kill()
	type_tween = create_tween()
	var duration: float = clampf(float(text.length()) * 0.02, 0.5, 2.0)
	type_tween.tween_property(dialogue_text, "visible_ratio", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
	
	# Auto dismiss after reading time
	if bubble_timer != null:
		bubble_timer.stop()
		bubble_timer.wait_time = duration + 6.0
		bubble_timer.start()


func _on_bubble_timeout() -> void:
	_hide_speech_bubble()
	if is_player_in_range and player != null:
		current_state = State.LOOK_AT_PLAYER
	else:
		_return_to_campfire()


func _hide_speech_bubble() -> void:
	if speech_bubble == null:
		return
	if type_tween != null and type_tween.is_valid():
		type_tween.kill()
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(speech_bubble, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	fade_tween.tween_callback(func() -> void: speech_bubble.visible = false)
