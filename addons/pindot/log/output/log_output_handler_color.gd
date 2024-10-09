## 扩展日志输出,可以打印颜色
extends LogOutputHandler


## 输出日志信息
func log(msg: String) -> void:
	print_rich(msg)
