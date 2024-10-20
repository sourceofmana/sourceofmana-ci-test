extends ServiceBase

@onready var background : TextureRect			= $Background

# Overlay
@onready var menu : Control						= $Overlay/Sections/Indicators/Menu
@onready var stats : Control					= $Overlay/Sections/Indicators/Stat

@onready var shortcuts : Container				= $Overlay/Sections/Shortcuts
@onready var sticks : Container					= $Overlay/Sections/Shortcuts/Sticks
@onready var boxes : Control					= $Overlay/Sections/Shortcuts/Boxes

@onready var notificationLabel : RichTextLabel	= $Overlay/Sections/Indicators/Info/Notification
@onready var pickupPanel : PanelContainer		= $Overlay/Sections/Indicators/Info/PickUp
@onready var loadingControl : Control			= $Overlay/Sections/Contexts/Loading
@onready var dialogueWindow : VBoxContainer		= $Overlay/Sections/Contexts/Dialogue
@onready var choiceContext : ContextMenu		= $Overlay/Sections/Contexts/Dialogue/BottomVbox/ChoiceVbox/Choice
@onready var infoContext : ContextMenu			= $Overlay/Sections/Contexts/Info

# Windows
@onready var windows : Control					= $Windows/Floating

@onready var newsWindow : WindowPanel			= $Windows/Floating/News
@onready var loginWindow : WindowPanel			= $Windows/Floating/Login
@onready var inventoryWindow : WindowPanel		= $Windows/Floating/Inventory
@onready var minimapWindow : WindowPanel		= $Windows/Floating/Minimap
@onready var chatWindow : WindowPanel			= $Windows/Floating/Chat
@onready var settingsWindow : WindowPanel		= $Windows/Floating/Settings
@onready var emoteWindow : WindowPanel			= $Windows/Floating/Emote
@onready var skillWindow : WindowPanel			= $Windows/Floating/Skill
@onready var quitWindow : WindowPanel			= $Windows/Floating/Quit
@onready var respawnWindow : WindowPanel		= $Windows/Floating/Respawn
@onready var statWindow : WindowPanel			= $Windows/Floating/Stat

@onready var chatContainer : ChatContainer		= $Windows/Floating/Chat/Margin/VBoxContainer
@onready var emoteContainer : Container			= $Windows/Floating/Emote/ItemContainer/Grid

# Shaders
@onready var CRTShader : TextureRect			= $Shaders/CRT
@onready var HQ4xShader : TextureRect			= $Shaders/HQ4x

# State transition
var progressTimer : Timer						= null

#
func CloseWindow():
	ToggleControl(quitWindow)

func GetCurrentWindow() -> Control:
	if windows && windows.get_child_count() > 0:
		return windows.get_child(windows.get_child_count() - 1)
	return null

func CloseCurrentWindow():
	var control : WindowPanel = GetCurrentWindow()
	if control:
		ToggleControl(control)

func ToggleControl(control : WindowPanel):
	if control:
		control.ToggleControl()

func ToggleChatNewLine():
	if chatWindow:
		if chatWindow.is_visible() == false:
			ToggleControl(chatWindow)
		chatContainer.SetNewLineEnabled(true)

#
func EnterLoginMenu():
	infoContext.set_visible(false)

	menu.SetItemsVisible(false)
	stats.set_visible(false)
	statWindow.set_visible(false)

	dialogueWindow.set_visible(false)
	notificationLabel.set_visible(false)
	pickupPanel.set_visible(false)
	loadingControl.set_visible(false)
	menu.set_visible(false)
	shortcuts.set_visible(false)
	quitWindow.set_visible(false)
	respawnWindow.EnableControl(false)

	background.set_visible(true)
	newsWindow.EnableControl(true)
	loginWindow.EnableControl(true)

func EnterLoginProgress():
	newsWindow.EnableControl(false)
	loginWindow.EnableControl(false)

	progressTimer = Callback.SelfDestructTimer(self, NetworkCommons.LoginAttemptTimeout, Launcher.Network.Client.NetworkIssue, [], "ProgressTimer")
	loadingControl.set_visible(true)

func EnterCharMenu():
	progressTimer.stop()
	progressTimer = null
	loadingControl.set_visible(false)
	Launcher.FSM.EnterState(Launcher.FSM.States.CHAR_PROGRESS)

func EnterCharProgress():
	Launcher.Network.ConnectPlayer(Launcher.FSM.playerName)
	progressTimer = Callback.SelfDestructTimer(self, NetworkCommons.CharSelectionTimeout, Launcher.Network.Client.NetworkIssue, [], "ProgressTimer")
	loadingControl.set_visible(true)

func EnterGame():
	progressTimer.stop()
	progressTimer = null
	loadingControl.set_visible(false)

	infoContext.Clear()
	infoContext.Push(ContextData.new("gp_interact"))
	infoContext.Push(ContextData.new("gp_untarget"))
	infoContext.Push(ContextData.new("gp_morph"))
	infoContext.Push(ContextData.new("gp_sit"))
	infoContext.Push(ContextData.new("gp_target"))
	infoContext.Push(ContextData.new("gp_pickup"))
	infoContext.FadeIn()

	background.set_visible(false)
	loginWindow.EnableControl(false)
	newsWindow.EnableControl(false)

	stats.set_visible(true)
	menu.set_visible(true)
	shortcuts.set_visible(true)
	notificationLabel.set_visible(true)

	menu.SetItemsVisible(true)
	stats.Init()
	statWindow.Init(Launcher.Player)

#
func _post_launch():
	get_tree().set_auto_accept_quit(false)
	get_tree().set_quit_on_go_back(false)

	if Launcher.FSM:
		Launcher.FSM.enter_login.connect(EnterLoginMenu)
		Launcher.FSM.enter_login_progress.connect(EnterLoginProgress)
		Launcher.FSM.enter_char.connect(EnterCharMenu)
		Launcher.FSM.enter_char_progress.connect(EnterCharProgress)
		Launcher.FSM.enter_game.connect(EnterGame)

	Launcher.FSM.EnterState(Launcher.FSM.States.LOGIN_SCREEN)
	isInitialized = true

func _notification(notif):
	match notif:
		Node.NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST:
			ToggleControl(quitWindow)
		Node.NOTIFICATION_WM_MOUSE_EXIT:
			if windows:
				windows.ClearWindowsModifier()
		Node.NOTIFICATION_DRAG_BEGIN:
			Launcher.Action.Enable(false)
		Node.NOTIFICATION_DRAG_END:
			Launcher.Action.Enable(true)

func _ready():
	assert(CRTShader.material != null, "CRT Shader can't load as its texture material is missing")
	CRTShader.material.set_shader_parameter("resolution", get_viewport().size / 2)

func _on_ui_margin_resized():
	if CRTShader and CRTShader.material:
		CRTShader.material.set_shader_parameter("resolution", get_viewport().size / 2)

	if settingsWindow:
		settingsWindow.set_fullscreen(DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_FULLSCREEN)
		settingsWindow.set_windowPos(DisplayServer.window_get_position(0))
		settingsWindow.set_resolution(DisplayServer.window_get_size(0))
