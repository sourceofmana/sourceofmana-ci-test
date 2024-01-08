extends Node
class_name SkillData

@export var _id : int
@export var _name : String
@export var _iconPath : String
@export var _castPresetPath : String
@export var _castTextureOverride : String
@export var _castColor : Color
@export var _castTime : float
@export var _cooldownTime : float
@export var _state : EntityCommons.State
@export var _mode : Skill.TargetMode
@export var _damage : int
@export var _heal : int

# Stats, must have the same name than their relatives in EntityStats
@export var stamina : int
@export var mana : int

func _init():
	_id = 0
	_name = "Unknown"
	_iconPath = "res://data/graphics/items/skill/spell.png"
	_castPresetPath = ""
	_castTextureOverride = ""
	_castColor = Color.PINK
	_castTime = 0.0
	_cooldownTime = 0.0
	_state = EntityCommons.State.IDLE
	_mode = Skill.TargetMode.SINGLE
	_damage = 0
	_heal = 0
	stamina = 0
	mana = 0