extends Node2D


@export var start_pos: Vector2
@export var end_pos: Vector2 = Vector2(100, 0)

var color_changer: Tween
var position_changer: Tween

@onready var target_color: Color = $Sprite2D.self_modulate
@onready var no_color: Color = $Sprite2D.self_modulate

@onready var sprite_2d: Sprite2D = $Sprite2D

const cardA := preload("res://Game/Mahjong/Card/牌A.png")
const cardB := preload("res://Game/Mahjong/Card/牌B.png")
const cardC := preload("res://Game/Mahjong/Card/牌C.png")


func _ready() -> void:
	target_color.a = 1
	no_color.a = 0


func hit(mahjong_kind: Mahjong.MahjongKind):
	match mahjong_kind:
		Mahjong.MahjongKind.A:
			sprite_2d.texture = cardA
		Mahjong.MahjongKind.B:
			sprite_2d.texture = cardB
		Mahjong.MahjongKind.C:
			sprite_2d.texture = cardC
	
	if color_changer:
		color_changer.kill()
	color_changer = create_tween()
	
	if position_changer:
		position_changer.kill()
	position_changer = create_tween()
	
	sprite_2d.self_modulate.a = 0
	color_changer.tween_property(sprite_2d, "self_modulate", target_color, 0.3)
	color_changer.tween_interval(0.1)
	color_changer.tween_property(sprite_2d, "self_modulate", no_color, 0.4).set_ease(Tween.EASE_IN)
	
	sprite_2d.position = start_pos
	position_changer.tween_property(sprite_2d, "position", end_pos, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
