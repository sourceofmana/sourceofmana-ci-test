extends WindowPanel
class_name InventoryWindow

@onready var weightStat : Control		= $VBoxContainer/Weight/BgTex/Weight
@onready var itemGrid : GridContainer	= $VBoxContainer/ItemContainer/Grid

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/ItemContainer.resized.connect(_on_panel_resized)

func _on_panel_resized():
	print("resized")
	if itemGrid.get_child_count() > 0:
		var tileSize = get_child(0).size.x + get("theme_override_constants/h_separation")
		itemGrid.columns = max(1, int(get_parent().get_size().x / tileSize))
	else:
		itemGrid.columns = 100

var timeout = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timeout += delta

func update_inventory():
	# crude debounce
	if timeout <= 1.0:
		return
	timeout = 0.0
	print("update_inventory") # this is print too often, TODO make sure this function is only called when needed
	
	var player = Launcher.Entities.playerEntity
	# display inventory
	update_inventory_ui()
	# update weight
	weightStat.SetStat(
		player.inventory.calculate_weight(), player.stat.maxWeight)


const Tile = preload("res://scenes/gui/inventory/ItemGridTile.tscn")

# render inventory items to ui
func update_inventory_ui():
	print("update_inventory_ui")
	for oldItem in itemGrid.get_children():
		itemGrid.remove_child(oldItem)
		oldItem.disconnect("ItemClicked", _on_item_click)
		oldItem.queue_free()
	
	for item in Launcher.Entities.playerEntity.inventory.items:
		var tileInstance : InventoryItemGridTile = Tile.instantiate()
		tileInstance.set_data(item)
		tileInstance.connect("ItemClicked", _on_item_click)
		itemGrid.add_child(tileInstance)


func _on_item_click(item: InventoryItem):
	Launcher.Entities.playerEntity.inventory.use_item(item)
