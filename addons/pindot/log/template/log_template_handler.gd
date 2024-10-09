## 日志模板基类
class_name LogTemplateHandler


## 返回日志模板,需要包含基础的信息,可以自行添加额外的模板数据
func get_message(
	name: String,
	data: Variant,
	category: String = PindotLog.LOG_CATEGORY_ALL,
	level: PindotLog.LogLevel = PindotLog.LogLevel.INFO
) -> String:
	return "[{category}][{level}] {name} === {data}".format(
		{category = category, level = PindotLog.LogLevel.keys()[level], name = name, data = data}
	)
