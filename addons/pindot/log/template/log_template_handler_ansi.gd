## ANSI 格式的输出
class_name LogTemplateHandlerANSI
extends LogTemplateHandler

# ANSI 颜色转义序列
var ansi_colors = {
	"black": "\u001b[30m",
	"red": "\u001b[31m",
	"green": "\u001b[32m",
	"yellow": "\u001b[33m",
	"blue": "\u001b[34m",
	"magenta": "\u001b[35m",
	"cyan": "\u001b[36m",
	"white": "\u001b[37m",
	"gray": "\u001b[90m",
	"pink": "\u001b[95m",
	"purple": "\u001b[35m",
	"orange": "\u001b[33m",  # ANSI 没有橙色，使用黄色代替
	"reset": "\u001b[0m"
}


# 返回日志模板，包含基础信息和颜色
func get_message(
	name: String,
	data: Variant,
	category: String = PindotLog.LOG_CATEGORY_ALL,
	level: PindotLog.LogLevel = PindotLog.LogLevel.INFO
) -> String:
	var levelcolor = "white"
	var datacolor = "white"

	# 为不同日志级别选择对应的颜色
	match level:
		PindotLog.LogLevel.PROFILER:
			levelcolor = "gray"
		PindotLog.LogLevel.DEBUG:
			levelcolor = "cyan"
		PindotLog.LogLevel.INFO:
			levelcolor = "green"
		PindotLog.LogLevel.WARNING:
			levelcolor = "yellow"
		PindotLog.LogLevel.ERROR:
			levelcolor = "pink"
		PindotLog.LogLevel.FATAL:
			levelcolor = "magenta"

	# 构建输出消息，插入 ANSI 颜色
	return (
		(
			"{gray}[{category}][{level}]{reset} "
			+ "{levelcolor}{name}{reset} "
			+ "{datacolor}{data}{reset}"
		)
		. format(
			{
				"category": category,
				"level": PindotLog.LogLevel.keys()[level],
				"name": name,
				"data": data,
				"gray": ansi_colors["gray"],
				"levelcolor": ansi_colors.get(levelcolor, ansi_colors["white"]),
				"datacolor": ansi_colors.get(datacolor, ansi_colors["white"]),
				"reset": ansi_colors["reset"]
			}
		)
	)


# 获取调用栈信息，添加 ANSI 颜色
func get_stack_message(source: String, line: int, function: String) -> String:
	return "\t\t{gray}{source}:{line}{reset} {cyan}{function}{reset}".format(
		{
			"source": source,
			"line": str(line),
			"function": function,
			"gray": ansi_colors["gray"],
			"cyan": ansi_colors["cyan"],
			"reset": ansi_colors["reset"]
		}
	)
