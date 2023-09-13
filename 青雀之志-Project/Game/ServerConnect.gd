extends Node2D


signal sound_value(value)


var udp = PacketPeerUDP.new()

func _ready() -> void:
	udp.bind(10077)

func _process(delta: float) -> void:
	var message := udp.get_packet()
	if message:
		$"../TextEdit".text = ""
		out("接收到udp信息：" + str(message) + "\n")
		print("接收到udp信息：")
		print(message)
		var var_message := message.get_string_from_utf16()
		if var_message:
			var j: Dictionary = JSON.parse_string(var_message)
			if j:
				out("解析成功：" + str(var_message) + "\n")
				print("解析成功：")
				print(var_message)
				if j.has("E"):
					out("解析到E：" + str(j.E) + "\n")
					print("解析到E：")
					print(j.E)
				if j.has("Q"):
					out("解析到Q：" + str(j.Q) + "\n")
					print("解析到Q：")
					print(j.Q)
				if j.has("value"):
					out("解析到value：" + str(j.value) + "\n")
					print("解析到value：")
					print(j.value)
					emit_signal("sound_value", j.value)
			else:
				out("解析失败!" + "\n")
				print("解析失败!")
		out("----------" + "\n")
		print("----------")


func out(s):
	$"../TextEdit".text = s + $"../TextEdit".text
