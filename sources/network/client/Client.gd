extends Object

#
func WarpPlayer(map : String, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		Launcher.Map.EmplaceMapNode(map)
		PushNotification(map, _rpcID)

	if Launcher.Player:
		Launcher.Player.entityVelocity = Vector2.ZERO

func EmotePlayer(playerID : int, emoteID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	var entity : Entity = Entities.Get(playerID)
	if entity && entity.get_parent() && entity.interactive:
		entity.interactive.DisplayEmote.call_deferred(emoteID)

func AddEntity(agentID : int, entityType : ActorCommons.Type, entityID : String, nick : String, velocity : Vector2, position : Vector2i, orientation : Vector2, state : ActorCommons.State, skillCastID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		Launcher.Map.AddEntity(agentID, entityType, entityID, nick, velocity, position, orientation, state, skillCastID)

func RemoveEntity(agentID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		Launcher.Map.RemoveEntity(agentID)

func ForceUpdateEntity(ridAgent : int, velocity : Vector2, position : Vector2, orientation : Vector2, state : ActorCommons.State, skillCastID : int):
	if Launcher.Map:
		Launcher.Map.UpdateEntity(ridAgent, velocity, position, orientation, state, skillCastID)

func UpdateEntity(ridAgent : int, velocity : Vector2, position : Vector2, orientation : Vector2, state : ActorCommons.State, skillCastID : int):
	if Launcher.Map:
		Launcher.Map.UpdateEntity(ridAgent, velocity, position, orientation, state, skillCastID)

func ChatAgent(ridAgent : int, text : String, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(ridAgent)
		if entity && entity.get_parent():
			if entity.type == ActorCommons.Type.PLAYER && Launcher.GUI:
				Launcher.GUI.chatContainer.AddPlayerText(entity.nick, text)
			if entity.interactive:
				entity.interactive.DisplaySpeech.call_deferred(text)

func ToggleContext(enable : bool, _rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.dialogueWindow.Toggle(enable)

func ContextText(author : String, text : String, _rpcID : int = NetworkCommons.RidSingleMode):
	if not author.is_empty():
		Launcher.GUI.dialogueWindow.AddName(author)
	Launcher.GUI.dialogueWindow.AddDialogue(text)
	Launcher.GUI.dialogueWindow.ToggleButton(false, "")

func ContextContinue(_rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.dialogueWindow.ToggleButton(true, "Next")

func ContextClose(_rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.dialogueWindow.ToggleButton(true, "Close")

func ContextChoice(texts : PackedStringArray, _rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.dialogueWindow.AddChoices(texts)

func TargetAlteration(ridAgent : int, targetID : int, value : int, alteration : ActorCommons.Alteration, skillID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(targetID)
		var caller : Entity = Entities.Get(ridAgent)
		if caller && entity && entity.get_parent() and entity.interactive:
			entity.interactive.DisplayAlteration.call_deferred(entity, caller, value, alteration, skillID)

func Casted(agentID : int, skillID : int, cooldown : float, _rpcID : int = NetworkCommons.RidSingleMode):
	var entity : Entity = Entities.Get(agentID)
	if entity and entity.get_parent() and entity.interactive:
		entity.interactive.DisplaySkill.call_deferred(entity, skillID, cooldown)

func TargetLevelUp(targetID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(targetID)
		if entity and entity.get_parent() and entity.interactive:
			entity.interactive.DisplayLevelUp.call_deferred()
			entity.stat.attributes_updated.emit()

func Morphed(ridAgent : int, morphID : String, morphed : bool, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(ridAgent)
		if entity:
			var morphData : EntityData = Instantiate.FindEntityReference(morphID)
			entity.stat.Morph(morphData)
			entity.SetVisual(morphData, morphed)

func UpdateActiveStats(ridAgent : int, level : int, experience : int, gp : int, health : int, mana : int, stamina : int, weight : float, shape : String, spirit : String, currentShape : String, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(ridAgent)
		if entity and entity.get_parent() and entity.stat:
			var levelUp : bool = entity.stat.level != level
			entity.stat.level			= level
			entity.stat.experience		= experience
			entity.stat.gp				= gp
			entity.stat.health			= health
			entity.stat.mana			= mana
			entity.stat.stamina			= stamina
			entity.stat.weight			= weight
			entity.stat.shape		= shape
			entity.stat.spirit		= spirit
			entity.stat.currentShape	= currentShape
			if levelUp:
				if entity == Launcher.Player:
					PushNotification("Level %d reached.\nFeel the mana power growing inside you!" % (level))
				entity.stat.RefreshAttributes()
			else:
				entity.stat.RefreshActiveStats()

func UpdateAttributes(ridAgent : int, strength : int, vitality : int, agility : int, endurance : int, concentration : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		var entity : Entity = Entities.Get(ridAgent)
		if entity and entity.get_parent() and entity.stat:
			entity.stat.strength		= strength
			entity.stat.vitality		= vitality
			entity.stat.agility			= agility
			entity.stat.endurance		= endurance
			entity.stat.concentration	= concentration
			entity.stat.RefreshAttributes()

func ItemAdded(itemID : int, count : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player and DB.ItemsDB.has(itemID):
		var cell : BaseCell = DB.ItemsDB[itemID]
		if cell and Launcher.Player.inventory.PushItem(cell, count):
			if Launcher.GUI:
				Launcher.GUI.pickupPanel.AddLast(cell, count)
				Launcher.GUI.inventoryWindow.RefreshInventory()
			cell.used.emit()

func ItemRemoved(itemID : int, count : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player and DB.ItemsDB.has(itemID):
		var cell : BaseCell = DB.ItemsDB[itemID]
		if cell:
			Launcher.Player.inventory.PopItem(cell, count)
			CellTile.RefreshShortcuts(cell)
			if Launcher.GUI and Launcher.GUI.inventoryWindow:
				Launcher.GUI.inventoryWindow.RefreshInventory()
			cell.used.emit()

func RefreshInventory(cells : Dictionary, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Player and Launcher.Player.inventory:
		Launcher.Player.inventory.ImportInventory(cells)
	if Launcher.GUI and Launcher.GUI.inventoryWindow:
		Launcher.GUI.inventoryWindow.RefreshInventory()

func DropAdded(dropID : int, itemID : int, pos : Vector2, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map and itemID in DB.ItemsDB:
		Launcher.Map.AddDrop(dropID, DB.ItemsDB[itemID], pos)

func DropRemoved(dropID : int, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.Map:
		Launcher.Map.RemoveDrop(dropID)

#
func PushNotification(notif : String, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.GUI:
		Launcher.GUI.notificationLabel.AddNotification(notif)

#
func AuthError(err : NetworkCommons.AuthError, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.GUI:
		Launcher.GUI.loginPanel.FillWarningLabel(err)

func CharacterError(err : NetworkCommons.AuthError, _rpcID : int = NetworkCommons.RidSingleMode):
	if Launcher.GUI:
		Launcher.GUI.characterPanel.FillWarningLabel(err)

func CharacterInfo(info : Dictionary, _rpcID : int = NetworkCommons.RidSingleMode):
	Launcher.GUI.characterPanel.AddCharacter(info)

#
func ConnectServer():
	if Launcher.GUI and Launcher.GUI.loginPanel:
		Launcher.GUI.loginPanel.EnableButtons.call_deferred(true)

func DisconnectServer():
	Launcher.Mode(true, true)
	FSM.EnterState(FSM.States.LOGIN_SCREEN)
	AuthError(NetworkCommons.AuthError.ERR_SERVER_UNREACHABLE)

#
func Init():
	if not Launcher.Root.multiplayer.connected_to_server.is_connected(ConnectServer):
		Launcher.Root.multiplayer.connected_to_server.connect(ConnectServer)
	if not Launcher.Root.multiplayer.connection_failed.is_connected(DisconnectServer):
		Launcher.Root.multiplayer.connection_failed.connect(DisconnectServer)
	if not Launcher.Root.multiplayer.server_disconnected.is_connected(DisconnectServer):
		Launcher.Root.multiplayer.server_disconnected.connect(DisconnectServer)

func Destroy():
	if Launcher.Root.multiplayer.connected_to_server.is_connected(ConnectServer):
		Launcher.Root.multiplayer.connected_to_server.disconnect(ConnectServer)
	if Launcher.Root.multiplayer.connection_failed.is_connected(DisconnectServer):
		Launcher.Root.multiplayer.connection_failed.disconnect(DisconnectServer)
	if Launcher.Root.multiplayer.server_disconnected.is_connected(DisconnectServer):
		Launcher.Root.multiplayer.server_disconnected.disconnect(DisconnectServer)