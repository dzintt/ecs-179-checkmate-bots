extends Node
## Currency Manager - Gold economy management
## Singleton accessible via CurrencyManager
## Tracks player gold, handles transactions

var current_gold: int = 10  # Starting gold


func _ready():
	print("CurrencyManager initialized with ", current_gold, " gold")

	# Connect to EventBus signals
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.wave_completed.connect(_on_wave_completed)


## Add gold to player's balance
func add_gold(amount: int):
	if amount <= 0:
		return

	current_gold += amount
	if SoundManager:
		SoundManager.play_gold_gain()
	EventBus.gold_changed.emit(current_gold)
	print("Gold added: +", amount, " | Total: ", current_gold)


## Check if player can afford a cost
func can_afford(cost: int) -> bool:
	return current_gold >= cost


## Spend gold (returns true if successful)
func spend_gold(cost: int) -> bool:
	if not can_afford(cost):
		print("Cannot afford: ", cost, " (have ", current_gold, ")")
		return false

	current_gold -= cost
	EventBus.gold_changed.emit(current_gold)
	print("Gold spent: -", cost, " | Remaining: ", current_gold)
	return true


## Get current gold amount
func get_current_gold() -> int:
	return current_gold


## Reset gold to starting amount
func reset_gold():
	current_gold = 20
	EventBus.gold_changed.emit(current_gold)
	print("Gold reset to ", current_gold)


# Event handlers
func _on_enemy_died(enemy: Node, gold_reward: int):
	add_gold(gold_reward)


func _on_wave_completed(wave_number: int):
	# TODO: Award wave completion bonus (define in wave definition)
	var bonus = 5 + wave_number  # Placeholder
	add_gold(bonus)
	print("Wave ", wave_number, " completed! Bonus: ", bonus)
