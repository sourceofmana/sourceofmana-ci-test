extends BaseAgent
class_name PlayerAgent

#
var rpcRID : int						= NetworkCommons.RidUnknown
var lastStat : ActorStats				= ActorStats.new()
var respawnDestination : Destination	= Destination.new()
var exploreOrigin : Destination			= Destination.new()
var ownScript : NpcScript			= null

#
static func GetEntityType() -> ActorCommons.Type: return ActorCommons.Type.PLAYER

#
func UpdateLastStats():
	if rpcRID == NetworkCommons.RidUnknown:
		return

	if lastStat.level != stat.level or \
	lastStat.experience != stat.experience or \
	lastStat.gp != stat.gp or \
	lastStat.health != stat.health or \
	lastStat.mana != stat.mana or \
	lastStat.stamina != stat.stamina or \
	lastStat.weight != stat.weight or \
	lastStat.shape != stat.shape or \
	lastStat.spirit != stat.spirit or \
	lastStat.currentShape != stat.currentShape:
		Network.UpdateActiveStats(get_rid().get_id(), stat.level, stat.experience, stat.gp, stat.health, stat.mana, stat.stamina, stat.weight, stat.shape, stat.spirit, stat.currentShape, rpcRID)
		lastStat.level				= stat.level
		lastStat.experience			= stat.experience
		lastStat.gp					= stat.gp
		lastStat.health				= stat.health
		lastStat.mana				= stat.mana
		lastStat.stamina			= stat.stamina
		lastStat.weight				= stat.weight
		lastStat.shape		= stat.shape
		lastStat.spirit		= stat.spirit
		lastStat.currentShape		= stat.currentShape

	if lastStat.strength != stat.strength or \
	lastStat.vitality != stat.vitality or \
	lastStat.agility != stat.agility or \
	lastStat.endurance != stat.endurance or \
	lastStat.concentration != stat.concentration:
		Network.UpdateAttributes(get_rid().get_id(), stat.strength, stat.vitality, stat.agility, stat.endurance, stat.concentration, rpcRID)
		lastStat.strength			= stat.strength
		lastStat.vitality			= stat.vitality
		lastStat.agility			= stat.agility
		lastStat.endurance			= stat.endurance
		lastStat.concentration		= stat.concentration

func Morph(notifyMorphing : bool, morphID : String = ""):
	if morphID.length() == 0:
		morphID = GetNextShapeID()
		if morphID.length() == 0:
			return

	var morphData : EntityData = Instantiate.FindEntityReference(morphID)
	stat.Morph(morphData)
	Network.Server.NotifyNeighbours(self, "Morphed", [morphID, notifyMorphing])

#
func _physics_process(delta):
	super._physics_process(delta)
	UpdateLastStats()

func _ready():
	regenTimer = Timer.new()
	regenTimer.set_name("RegenTimer")
	Callback.OneShotCallback(regenTimer.tree_entered, Callback.ResetTimer, [regenTimer, ActorCommons.RegenDelay, stat.Regen])
	add_child.call_deferred(regenTimer)

	respawnDestination.map = Launcher.World.defaultSpawn.map.name
	respawnDestination.pos = Launcher.World.defaultSpawn.spawn_position

	super._ready()

func _exit_tree():
	ClearScript()

#
func Respawn():
	if not ActorCommons.IsAlive(self):
		stat.health  = int(stat.current.maxHealth / 2.0)
		WarpTo(respawnDestination)

func Explore():
	if ActorCommons.IsAlive(self):
		var map : WorldMap = WorldAgent.GetMapFromAgent(self)
		if map and map.HasFlags(WorldMap.Flags.ONLY_SPIRIT):
			if stat.IsSailing():
				exploreOrigin.map = map.name
				exploreOrigin.pos = position
				WarpTo(ActorCommons.SailingDestination)

func WarpTo(dest : Destination):
	var nextMap : WorldMap = Launcher.World.GetMap(dest.map)
	if nextMap:
		Launcher.World.Warp(self, nextMap, dest.pos)

func Killed():
	super.Killed()
	if ownScript:
		ClearScript()

#
func AddScript(npc : NpcAgent):
	if npc and npc.playerScriptPreset:
		ownScript = npc.playerScriptPreset.new(npc, self)

func ClearScript():
	if ownScript:
		ownScript.OnQuit()
		ownScript = null