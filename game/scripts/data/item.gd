class_name Item

var resource: ItemResource
var quantity: int

# Getters
var item_name: String:
	get: return resource.item_name
var use_effects: Array[TargetedEffect]:
	get: return resource.use_effects
var use_avfx: Array[AVFXResource]:
	get: return resource.use_avfx
var consumable: bool = true:
	get: return resource.consumable
var use_message: String:
	get: return resource.use_message
