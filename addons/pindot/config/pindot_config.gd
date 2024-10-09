## Pindot框架的配置数据
@tool
@icon("res://addons/pindot/config/config.svg")
class_name PindotConfig
extends Resource

@export_category("日志")
## 显示调试信息
@export var log_debug: bool = false
## 日志输出级别, 见 PindotLogLevel
@export var log_level: PindotLog.LogLevel = PindotLog.LogLevel.INFO

## 日志输出类别, * 代表全部
@export var log_category: Array[String] = ["*"]

## 日志模板处理器
@export_file("*.gd")
var log_template_handler: String = "res://addons/pindot/log/template/log_template_handler_color.gd"

## 日志输出处理器
@export_file("*.gd")
var log_output_handler: String = "res://addons/pindot/log/output/log_output_handler_color.gd"
