extends Node2D
## 麻将组
class_name Mahjong


## 当被增加时发出
signal mahjong_increased(MahjongKind)
## 当被增加到满时发出
signal full

## 当被消耗时发出
signal mahjong_reduced(MahjongKind)
## 当完美消耗（四张同牌）时发出，同时也会发出empty，但不会发出mahjong_reduced
signal mahjong_prefect_reduced(MahjongKind)
## 当被消耗到空时发出
signal empty
## 当已为空，仍然被企图消耗时发出
signal excessived_reduced

## 麻将类型
enum MahjongKind {
	A,
	B,
	C,
}

var count_a: int = 0
var count_b: int = 0
var count_c: int = 0

@onready var lattices: Array[Lattice] = [$"1" as Lattice,
		$"2" as Lattice,
		$"3" as Lattice,
		$"4" as Lattice]

var now_types: Array[MahjongKind]


func restart() -> void:
	for lattice in lattices:
		lattice.set_empty()
	
	count_a = 0
	count_b = 0
	count_c = 0
	
	now_types.clear()


func attack() -> void:
	if now_types.is_empty():
		emit_signal("excessived_reduced")
	else:
		var attack_type: MahjongKind = now_types.pop_back()
		lattices[now_types.size()].set_empty()
		emit_signal("mahjong_reduced", attack_type)
		if now_types.is_empty():
			emit_signal("empty")


func add_card(mahjong_kind: MahjongKind) -> void:
	match mahjong_kind:
		MahjongKind.A:
			count_a += 1
		MahjongKind.B:
			count_b += 1
		MahjongKind.C:
			count_c += 1
	
	if count_a + count_b + count_c > 4:
		match mahjong_kind:
			MahjongKind.A:
				if ((count_a <= count_b or count_b == 0)
						and (count_a <= count_c or count_c == 0)):
					count_a -= 1
					recalculate_cards_pos()
					emit_signal("mahjong_reduced", MahjongKind.A)
					check_four()
					return
			MahjongKind.B:
				if ((count_b <= count_a or count_a == 0)
						and (count_b <= count_c or count_c == 0)):
					count_b -= 1
					recalculate_cards_pos()
					emit_signal("mahjong_reduced", MahjongKind.B)
					check_four()
					return
			MahjongKind.C:
				if ((count_c <= count_a or count_a == 0)
						and (count_c <= count_b or count_b == 0)):
					count_c -= 1
					recalculate_cards_pos()
					emit_signal("mahjong_reduced", MahjongKind.C)
					check_four()
					return
		
		if (count_a > 0
				and (count_a <= count_b or count_b == 0)
				and (count_a <= count_c or count_c == 0)):
			count_a -= 1
			emit_signal("mahjong_reduced", MahjongKind.A)
		elif (count_b > 0
				and (count_b <= count_a or count_a == 0)
				and (count_b <= count_c or count_c == 0)):
			count_b -= 1
			emit_signal("mahjong_reduced", MahjongKind.B)
		elif (count_c > 0
				and (count_c <= count_a or count_a == 0)
				and (count_c <= count_b or count_b == 0)):
			count_c -= 1
			emit_signal("mahjong_reduced", MahjongKind.C)
		
		recalculate_cards_pos()
		check_four()
		return
	
	recalculate_cards_pos()
	emit_signal("mahjong_increased", mahjong_kind)
	if now_types.size() == 4:
		emit_signal("full")
		check_four()


func check_four() -> void:
	if count_a == 4:
		emit_signal("mahjong_prefect_reduced", MahjongKind.A)
	elif count_b == 4:
		emit_signal("mahjong_prefect_reduced", MahjongKind.B)
	elif count_c == 4:
		emit_signal("mahjong_prefect_reduced", MahjongKind.C)
	else:
		return
	
	count_a = 0
	count_b = 0
	count_c = 0
	
	recalculate_cards_pos()


func recalculate_cards_pos() -> void:
	var max_card := maxi(count_a, maxi(count_b, count_c))
	
	var now_lattice := 0
	var new_types: Array[MahjongKind]
	
	if max_card != 0:
		match max_card:
			count_a:
				for i in range(0, count_a):
					new_types.append(MahjongKind.A)
				
				if count_b > count_c:
					for i in range(0, count_b):
						new_types.append(MahjongKind.B)
					for i in range(0, count_c):
						new_types.append(MahjongKind.C)
				else:
					for i in range(0, count_c):
						new_types.append(MahjongKind.C)
					for i in range(0, count_b):
						new_types.append(MahjongKind.B)
			count_b:
				for i in range(0, count_b):
					new_types.append(MahjongKind.B)
				
				if count_a > count_c:
					for i in range(0, count_a):
						new_types.append(MahjongKind.A)
					for i in range(0, count_c):
						new_types.append(MahjongKind.C)
				else:
					for i in range(0, count_c):
						new_types.append(MahjongKind.C)
					for i in range(0, count_a):
						new_types.append(MahjongKind.A)
			count_c:
				for i in range(0, count_c):
					new_types.append(MahjongKind.C)
				
				if count_a > count_b:
					for i in range(0, count_a):
						new_types.append(MahjongKind.A)
					for i in range(0, count_b):
						new_types.append(MahjongKind.B)
				else:
					for i in range(0, count_b):
						new_types.append(MahjongKind.B)
					for i in range(0, count_a):
						new_types.append(MahjongKind.A)
	
	var min_size: int = min(new_types.size(), now_types.size())
	for i in range(0, min_size):
		if new_types[i] != now_types[i]:
			now_types[i] = new_types[i]
			lattices[i].set_type(now_types[i])
	
	for i in range(min_size, now_types.size()):
		now_types.remove_at(min_size)
		lattices[i].set_empty()
	
	for i in range(min_size, new_types.size()):
		now_types.append(new_types[i])
		lattices[i].set_type(now_types[i])
