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

var show_level: LogLevel = LogLevel.DEBUG
var show_category: Array[String] = ["*"]


func _ready():
	# show_level = Pindot.config.log_level
	# show_category = Pindot.config.log_category
	# Logger.info("show_level ====", show_level)  #LOG
	prints(
		"---logger ready:",
		"show_level:" + LogLevel.keys()[show_level],
		"show_category:" + ",".join(show_category),
		"---"
	)
