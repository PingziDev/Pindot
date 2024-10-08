## Pindot框架的配置数据
@tool
@icon("res://addons/pindot/config/config.svg")
class_name PindotConfig
extends Resource

@export_category("日志")
## 日志输出级别, 见 PindotLogLevel
@export var log_level: PindotLog.LogLevel = PindotLog.LogLevel.INFO
## 日志输出类别, * 代表全部
@export var log_category: Array[String] = ["*"]
