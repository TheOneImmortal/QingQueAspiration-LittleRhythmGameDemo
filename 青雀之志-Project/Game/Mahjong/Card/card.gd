extends Node2D
class_name MahjongCard


var card_kind: Mahjong.MahjongKind

const card_A = preload("res://Game/Mahjong/Card/牌A.png")
const card_B = preload("res://Game/Mahjong/Card/牌B.png")
const card_C = preload("res://Game/Mahjong/Card/牌C.png")

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	set_kind(card_kind)


func set_kind(kind: Mahjong.MahjongKind) -> void:
	card_kind = kind
	
	if sprite_2d:
		match kind:
			Mahjong.MahjongKind.A:
				sprite_2d.texture = card_A
			Mahjong.MahjongKind.B:
				sprite_2d.texture = card_B
			Mahjong.MahjongKind.C:
				sprite_2d.texture = card_C
