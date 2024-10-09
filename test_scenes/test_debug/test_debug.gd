extends Node2D


func _ready() -> void:
	# 可以打印调试信息
	Pindot.log.debug("name", "value", "categary")
	Pindot.log.info("name", "value", "categary")
	Pindot.log.warn("name", "value", "categary")
	Pindot.log.error("name", "value", "categary")
	Pindot.log.fatal("name", "value", "categary")

	# 可以记录分析日志
	Pindot.log.profiler_start("category")
	Pindot.log.profiler("name", "value", "categary")
	Pindot.log.profiler_stop("category")
