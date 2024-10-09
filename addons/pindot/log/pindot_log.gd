## 游戏框架日志类
##
## 用于记录游戏框架的日志
class_name PindotLog
extends Node

#region 日志级别配置项

enum LogLevel {
	DEBUG = LOG_LEVEL_DEBUG,  ## 调试
	INFO = LOG_LEVEL_INFO,  ## 信息
	WARNING = LOG_LEVEL_WARNING,  ## 警告
	ERROR = LOG_LEVEL_ERROR,  ## 错误
	FATAL = LOG_LEVEL_FATAL,  ## 致命
}

## 游戏框架日志等级
const LOG_LEVEL_DEBUG = 0
const LOG_LEVEL_INFO = 1
const LOG_LEVEL_WARNING = 2
const LOG_LEVEL_ERROR = 3
const LOG_LEVEL_FATAL = 4

#endregion

## 表示所有分类,会显示全部分类的日志
const LOG_CATEGORY_ALL = "*"

## 配置信息,从全局读取
var show_level: LogLevel = LogLevel.DEBUG
var show_category: Array[String] = [LOG_CATEGORY_ALL]
var template_handler: LogTemplateHandler
var output_handler: LogOutputHandler

## 是否只输出纯净日志
var is_log_pure := false

## 纯粹的日志处理器,不带任何多余信息
var template_handler_pure: LogTemplateHandler
var output_handler_pure: LogOutputHandler


func _ready():
	# 读取配置数据
	show_level = Pindot.config.log_level
	show_category = Pindot.config.log_category
	template_handler = load(Pindot.config.log_template_handler).new()
	output_handler = load(Pindot.config.log_output_handler).new()

	if template_handler == null:
		printerr("[Pindot] log_template_handler 配置不正确,需要为继承 LogTemplateHandler 的类")

	if output_handler == null:
		printerr("[Pindot] log_output_handler 配置不正确,需要为继承 LogOutputHandler 的类")

	if Pindot.config.log_debug:
		prints(
			"-----[Pindot] logger ready:",
			"show_level:" + LogLevel.keys()[show_level],
			"show_category:" + ",".join(show_category),
			"-----"
		)

	# 获取环境信息
	# 当运行参数中包含 pindot_log_pure 时，只输出纯净的日志
	is_log_pure = "pindot_log_pure" in OS.get_cmdline_args()
	if is_log_pure:
		template_handler_pure = LogTemplateHandler.new()
		output_handler_pure = LogOutputHandler.new()


#region 日志快捷指令


## 打印调试日志
func debug(name: String, data: String = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.DEBUG or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.DEBUG)
	_output_message(msg)


## 打印信息日志
func info(name: String, data: String = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.INFO or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.INFO)
	_output_message(msg)


## 打印警告日志
func warn(name: String, data: String = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.WARNING or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.WARNING)
	_output_message(msg)
	# TODO 带颜色信息的日志推送到引擎显示问题
	# push_warning(template_handler_pure.get_message(name, data, category, LogLevel.WARNING))
	push_warning(msg)


## 打印错误日志
func error(name: String, data: String = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.ERROR or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.ERROR)
	_output_message(msg)

	push_error(msg)


## 打印致命日志
func fatal(name: String, data: String = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.FATAL or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.FATAL)
	_output_message(msg)

	push_error(msg)


#endregion


## 是否显示对应类别
func _is_category_show(category: String):
	if show_category.has(LOG_CATEGORY_ALL):
		return true
	return show_category.has(category)


## 获取日志信息
func _get_message(name: String, data: String, category: String, level: LogLevel) -> String:
	if is_log_pure:
		return template_handler_pure.get_message(name, data, category, level)
	return template_handler.get_message(name, data, category, level)


## 输出日志
func _output_message(msg: String) -> void:
	if is_log_pure:
		output_handler_pure.log(msg)
	else:
		output_handler.log(msg)
