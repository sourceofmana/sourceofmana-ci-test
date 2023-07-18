extends Node
class_name Formulas

#
static func GetMaxHealth(stat : EntityStats) -> int:
	var value : float = stat.vitality
	value += stat.base.health
	return int(value)

static func GetMaxMana(stat : EntityStats) -> int:
	var value : float = stat.concentration
	value += stat.base.mana
	return int(value)

static func GetMaxStamina(stat : EntityStats) -> int:
	var value : float = stat.endurance * 0.5
	value += stat.concentration * 0.5
	value += stat.base.stamina
	return int(value)

static func GetAttackStrength(stat : EntityStats) -> int:
	var value : float = stat.strength * 2
	value += stat.base.attackStrength
	return int(value)

static func GetAttackSpeed(stat : EntityStats) -> float:
	var value : float = stat.agility * 2
	value += stat.base.attackSpeed
	return value

static func GetAttackSpeedSec(stat : EntityStats) -> float:
	var value : float = stat.current.attackSpeed
	value /= 250
	return value

static func GetAttackRange(stat : EntityStats) -> int:
	return stat.base.attackRange

static func GetWalkSpeed(stat : EntityStats) -> float:
	var value : float = stat.level * 0.1
	value += stat.base.walkSpeed
	return value

static func GetWeightCapacity(stat : EntityStats) -> float:
	var value : float = stat.level
	value += stat.strength * 2
	value += stat.base.weightCapacity * 0.3
	return snappedf(value, 0.001)

#
static func ClampHealth(stat : EntityStats) -> int:
	return clampi(stat.health, 0, stat.base.health)

static func ClampMana(stat : EntityStats) -> int:
	return clampi(stat.mana, 0, stat.base.mana)

static func ClampStamina(stat : EntityStats) -> int:
	return clampi(stat.stamina, 0, stat.base.stamina)

static func GetWeight(inventory : EntityInventory) -> int:
	return inventory.calculate_weight() / 1000