extends Node

const MIN_AUDIO_VOLUME : float = 0.0001
const MAX_AUDIO_VOLUME : float = 1.0000
 
# List of volume levels for audio buses (used as anchor points for fade-in and fade-out effects)
var m_VolumeLevels : Array = []
 
# Initialize the audio manager
func _ready() -> void:
	for busIndex in AudioServer.get_bus_count():
		# Add the initial volume level of each bus to the list
		m_VolumeLevels.append(db_to_linear(AudioServer.get_bus_volume_db(busIndex)))


# Returns the number of available audio buses
func GetBusCount() -> int:
	return AudioServer.get_bus_count()

	
# Returns the volume level (0.0 - 1.0) of the requested bus
func GetVolume(busIndex : int) -> float:
	return m_VolumeLevels[busIndex]


# Set the volume level (0.0 - 1.0) of the requested bus
func SetVolume(busIndex : int, volume : float) -> void:
	# Adjust the volume levels if they are out of bounds
	if (volume < MIN_AUDIO_VOLUME): volume = MIN_AUDIO_VOLUME
	if (volume > MAX_AUDIO_VOLUME): volume = MAX_AUDIO_VOLUME
	 
	# Set the volume of the requested audio bus
	m_VolumeLevels[busIndex] = volume
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(volume))


# Perform a fade-in effect on the requested bus
func EffectFadeIn(busIndex : int, duration : float) -> void:
	create_tween().tween_method(_ChangeAudioBusVolume.bind(busIndex),
		linear_to_db(MIN_AUDIO_VOLUME), linear_to_db(m_VolumeLevels[busIndex]), duration)

  
# Perform a fade-out effect on the requested bus
func EffectFadeOut(busIndex : int, duration : float) -> void:
	create_tween().tween_method(_ChangeAudioBusVolume.bind(busIndex),
		linear_to_db(m_VolumeLevels[busIndex]), linear_to_db(MIN_AUDIO_VOLUME), duration)


# Change the volume of a specific audio bus (tweened method)
func _ChangeAudioBusVolume(value: float, busIndex : int) -> void:
	AudioServer.set_bus_volume_db(busIndex, value)


# Add an audio effect to a specific bus. Returns the index of the new effect
func AddBusEffect(busIndex : int, effect : AudioEffect) -> int:
	AudioServer.add_bus_effect(busIndex, effect)
	return AudioServer.get_bus_effect_count(busIndex) - 1


# Remove an audio effect from a specific bus
func RemoveBusEffect(busIndex : int, effectIndex : int) -> void:
	AudioServer.remove_bus_effect(busIndex, effectIndex)

	 
# Enable / disable an audio effect on a specific bus
func ToggleBusEffect(busIndex : int, effectIndex : int, enable : bool) -> void:
	AudioServer.set_bus_effect_enabled(busIndex, effectIndex, enable)


# Enable / disable an audio effect on a specific bus
func IsBusEffectEnabled(busIndex : int, effectIndex : int) -> bool:
	return AudioServer.is_bus_effect_enabled(busIndex, effectIndex)
