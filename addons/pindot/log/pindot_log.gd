## 游戏框架日志类
##
## 用于记录游戏框架的日志
class_name PindotLog
extends Node

#region 日志级别配置项

enum LogLevel {
	PROFILER = LOG_LEVEL_PROFILER,  ## 分析
	DEBUG = LOG_LEVEL_DEBUG,  ## 调试
	INFO = LOG_LEVEL_INFO,  ## 信息
	WARNING = LOG_LEVEL_WARNING,  ## 警告
	ERROR = LOG_LEVEL_ERROR,  ## 错误
	FATAL = LOG_LEVEL_FATAL,  ## 致命
}

## 游戏框架日志等级
const LOG_LEVEL_PROFILER = 0
const LOG_LEVEL_DEBUG = 1
const LOG_LEVEL_INFO = 2
const LOG_LEVEL_WARNING = 3
const LOG_LEVEL_ERROR = 4
const LOG_LEVEL_FATAL = 5

#endregion

## 表示所有分类,会显示全部分类的日志
const LOG_CATEGORY_ALL = "*"

# stack忽略的内容, 每行格式{source，function},会寻找并过滤
@export var stack_ignore_filters := [
	{source = "pindot", function = ""},
]
## 调试信息调用栈显示行数
@export var debug_stack_size := 3
@export var info_stack_size := 1

## 分析配置
@export var profiler_max := 200
@export var is_profiling := false

## 配置信息,从全局读取
var show_debug_info: bool = false
var show_level: LogLevel = LogLevel.DEBUG
var show_category: Array[String] = [LOG_CATEGORY_ALL]
var template_handler: LogTemplateHandler
var output_handler: LogOutputHandler

## 在终端输出,而不是在引擎中输出
var is_terminal := false

## 纯粹的日志处理器,不带任何多余信息
var terminal_template_handler: LogTemplateHandler
var terminal_output_handler: LogOutputHandler
## 命令行指定的handler
var command_template_handler: LogTemplateHandler

## 是否是编辑器,编辑器会显示调用栈
var is_editor:
	get:
		return OS.has_feature("editor")

var profiler_data: Array[String]


func _ready():
	# 读取配置数据
	show_debug_info = Pindot.config.log_debug
	show_level = Pindot.config.log_level
	show_category = Pindot.config.log_category
	template_handler = load(Pindot.config.log_template_handler).new()
	output_handler = load(Pindot.config.log_output_handler).new()

	if template_handler == null:
		printerr("[Pindot] log_template_handler 配置不正确,需要为继承 LogTemplateHandler 的类")

	if output_handler == null:
		printerr("[Pindot] log_output_handler 配置不正确,需要为继承 LogOutputHandler 的类")

	# 获取环境信息
	# 当运行参数中包含 pindot_log_terminal 时，只输出纯净的日志
	is_terminal = "pindot_log_terminal" in OS.get_cmdline_args()
	if is_terminal:
		terminal_template_handler = LogTemplateHandlerANSI.new()
		terminal_output_handler = LogOutputHandler.new()

	if show_debug_info:
		prints(
			"-----[Pindot] logger ready:",
			"show_level:" + LogLevel.keys()[show_level],
			"show_category:" + ",".join(show_category),
			"is_terminal:" + str(is_terminal),
			"-----"
		)


#region 日志快捷指令


## 打印调试日志
func debug(name: String, data: Variant = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.DEBUG or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.DEBUG)
	_output_message(msg)

	if is_editor:
		var stack_msg = _get_stack(debug_stack_size)
		_output_message(stack_msg)


## 打印信息日志
func info(name: String, data: Variant = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.INFO or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.INFO)

	if is_editor:
		var stack_msg = _get_stack(info_stack_size, false)
		msg += "\t" + stack_msg

	_output_message(msg)


## 打印警告日志
func warn(name: String, data: Variant = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.WARNING or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.WARNING)
	_output_message(msg)

	if is_editor:
		var stack_msg = _get_stack(debug_stack_size)
		_output_message(stack_msg)

	# TODO 带颜色信息的日志推送到引擎显示问题
	# push_warning(terminal_template_handler.get_message(name, data, category, LogLevel.WARNING))
	if !is_terminal:
		push_warning(msg)


## 打印错误日志
func error(name: String, data: Variant = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.ERROR or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.ERROR)
	_output_message(msg)

	if is_editor:
		var stack_msg = _get_stack(debug_stack_size)
		_output_message(stack_msg)

	if !is_terminal:
		push_error(msg)


## 打印致命日志
func fatal(name: String, data: Variant = "", category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.FATAL or !_is_category_show(category):
		return
	var msg = _get_message(name, data, category, LogLevel.FATAL)
	_output_message(msg)

	if is_editor:
		var stack_msg = _get_stack(debug_stack_size)
		_output_message(stack_msg)

	if !is_terminal:
		push_error(msg)


#endregion

#region 整块日志分析


## 标记分析开始
func profiler_start(category: String) -> void:
	if show_level > LogLevel.PROFILER or !_is_category_show(category):
		return
	profiler_data.clear()
	is_profiling = true
	_add_profiler_message(
		"--------------profilter start-----------------[{category}]".format({category = category}),
		"",
		category
	)


## 记录分析日志
func profiler(name: String, data: Variant, category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.PROFILER or !_is_category_show(category):
		return
	if is_profiling:
		_add_profiler_message(name, data, category)
		if profiler_data.size() >= profiler_max:
			profiler_stop(category)


## 标记分析结束
func profiler_stop(category: String = LOG_CATEGORY_ALL) -> void:
	if show_level > LogLevel.PROFILER or !_is_category_show(category):
		return
	is_profiling = false
	_add_profiler_message(
		"--------------profilter stop-----------------[{category}]".format({category = category}),
		"",
		category
	)


func _add_profiler_message(name, data, category):
	var msg = _get_message(name, data, category, LogLevel.PROFILER)
	profiler_data.append(msg)
	_output_message(msg)


#endregion


## 是否显示对应类别
func _is_category_show(category: String) -> bool:
	if show_category.has(LOG_CATEGORY_ALL):
		return true
	return show_category.has(category)


## 获取日志信息
func _get_message(name: String, data: Variant, category: String, level: LogLevel) -> String:
	if is_terminal:
		return terminal_template_handler.get_message(name, data, category, level)
	return template_handler.get_message(name, data, category, level)


## 输出日志
func _output_message(msg: String) -> void:
	if is_terminal:
		terminal_output_handler.log(msg)
	else:
		output_handler.log(msg)


## 获取调用栈,多行栈要换行
func _get_stack(stack_size: int, stack_newline: bool = true) -> String:
	var stack = get_stack()
	var stack_trace_message = ""
	var got_stack_count = 0

	if !stack.is_empty():  # 检查栈是否为空
		for entry in stack:  # 直接遍历栈，避免使用索引
			var infilter = stack_ignore_filters.any(
				func(filter): return (
					entry.source.contains(filter.source)
					and (!filter.function or entry.function.contains(filter.function))
				)
			)
			if infilter:
				continue

			stack_trace_message += _get_stack_message(entry.source, entry.line, entry.function)

			got_stack_count += 1
			if stack_newline:
				stack_trace_message += "\n"

			if got_stack_count >= stack_size:  # 达到限制后停止
				break
	else:
		stack_trace_message = (
			"No stack trace available, please run from within the editor "
			+ "or connect to a remote debug context."
		)

	return stack_trace_message


## 获取调用栈信息
func _get_stack_message(source: String, line: int, function: String) -> String:
	if is_terminal:
		return terminal_template_handler.get_stack_message(source, line, function)
	return template_handler.get_stack_message(source, line, function)
