extends Control
## 启动界面
class_name StartScene


## 开始游戏，进入选关界面
## 发出后根节点会删除此节点
signal start
## 游戏设置
## 大概root节点不会处理此信号，发出后应有start节点控制显示【设置】信息，比如谁做的什么的
signal game_set
## 关于
## 大概root节点不会处理此信号，发出后应有start节点控制显示【关于】信息，比如谁做的什么的
signal about
## 退出游戏
signal exit


## 设置应用目标节点
@onready var sets: Sets = $"../Sets"
