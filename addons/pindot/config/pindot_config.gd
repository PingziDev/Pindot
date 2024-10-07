## Pindot框架的配置数据
@tool
@icon("res://addons/pindot/config/config.svg")
class_name PindotConfig
extends Resource

#region 日志级别配置项

enum PindotLogLevel {
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

## 日志输出级别, 见 PindotLogLevel
@export var log_level: PindotLogLevel
