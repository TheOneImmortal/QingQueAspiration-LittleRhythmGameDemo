extends Node2D
## 牌格
class_name Lattice


var card: MahjongCard

const card_template := preload("res://Game/Mahjong/Card/card.tscn")


func set_empty() -> void:
	if card:
		remove_child(card)
		card.queue_free()
		card = null


func set_type(kind: Mahjong.MahjongKind) -> void:
	if !card:
		card = card_template.instantiate()
		add_child(card)
	
	card.set_kind(kind)
