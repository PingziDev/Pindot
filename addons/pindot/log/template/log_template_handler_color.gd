## 扩展日志模板,增加颜色
extends LogTemplateHandler


## 返回日志模板,需要包含基础的信息,可以自行添加额外的模板数据
func get_message(
	name: String,
	data: Variant,
	category: String = PindotLog.LOG_CATEGORY_ALL,
	level: PindotLog.LogLevel = PindotLog.LogLevel.INFO
) -> String:
	var levelcolor = "white"
	var datacolor = "white"
	# 可选颜色 ['black', 'red', 'green', 'yellow', 'blue', 'magenta',
	# 'pink', 'purple', 'cyan', 'white', 'orange', 'gray']
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
	return (
		(
			"[[color=gray]{category}][{level}[/color]] "
			+ "[color={levelcolor}]{name}[/color] "
			+ "[color={datacolor}]{data}[/color]"
		)
		. format(
			{
				category = category,
				level = PindotLog.LogLevel.keys()[level],
				name = name,
				data = data,
				levelcolor = levelcolor,
				datacolor = datacolor
			}
		)
	)


## 获取调用栈信息
func get_stack_message(source: String, line: int, function: String) -> String:
	return (
		(
			"\t\t[code][color={sourcecolor}]{source}:{line}[/color] "
			+ "[color={functioncolor}]{function}[/color][/code]"
		)
		. format({source = source, line = str(line), function = function})
	)
