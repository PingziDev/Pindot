## 字符串形式的函数解析工具
class_name ExpressionParser


class ExpressionObj:
	var name: String
	var params: Array

	func _init(name, params) -> void:
		self.name = name
		self.params = params


## 执行表达式
func execute_expression(expression: String, function_dict: Dictionary) -> Variant:
	var obj = parse_expression(expression)
	return call_method_recursive(obj, function_dict)


## 解析表达式的函数名和参数,返回ExpressionObj
## 示例:
## 输入: 'myFunction("param1", ["8001", "8002"], "testparam2")'
## 输出: ["param1", ["8001", "8002"], "testparam2"]
## 输入: 'buy(nearest(["8001", "8002"], "testparam2"))'
## 输出: [ExpressionObj("buy", [ExpressionObj("nearest", [["8001", "8002"], "testparam2"])])]
func parse_expression(input: String) -> ExpressionObj:
	# 定义正则表达式，匹配函数名和所有参数部分
	var regex = RegEx.new()
	regex.compile(r"(\w+)\s*\((.*)\)")  # 匹配函数名和参数部分，允许空格

	# 匹配输入字符串
	var result = regex.search(input)

	if result:
		var method_name = result.get_string(1)  # 获取函数名
		var all_params = result.get_string(2)  # 获取所有参数部分

		# 将参数部分按逗号分割，处理嵌套函数和数组参数
		var params = _split_params(all_params)

		return ExpressionObj.new(method_name, params)

	# 无需解析,直接原样传出
	return ExpressionObj.new(input, [])


## 分割参数，保留数组参数和嵌套函数调用
func _split_params(param_string: String) -> Array:
	var params = []
	var current_param = ""
	var in_quotes = false
	var bracket_depth = 0
	var parenthesis_depth = 0  # 用于检测嵌套函数

	for char in param_string:
		match char:
			"[":
				bracket_depth += 1  # 进入数组
			"]":
				bracket_depth -= 1  # 退出数组
			"(":
				parenthesis_depth += 1  # 进入函数嵌套
			")":
				parenthesis_depth -= 1  # 退出函数嵌套
			'"':
				in_quotes = !in_quotes  # 切换引号状态
			",":
				if bracket_depth == 0 and parenthesis_depth == 0 and not in_quotes:
					# 如果不在引号、数组或函数内，处理参数
					params.append(_parse_param(current_param.strip_edges()))
					current_param = ""  # 重置当前参数
					continue
		current_param += char  # 添加当前字符

	# 添加最后一个参数
	if current_param.strip_edges() != "":
		params.append(_parse_param(current_param))

	return params


## 解析单个参数，包括嵌套函数
func _parse_param(param: String) -> Variant:
	# 检查是否是函数调用
	if param.contains("(") and param.ends_with(")"):
		# 递归解析嵌套的函数
		return parse_expression(param)

	# 处理数组
	if param.begins_with("[") and param.ends_with("]"):
		return _parse_array_param(param)

	# 否则返回原始参数（去掉引号）
	return param.replace('"', "")


## 解析数组参数
func _parse_array_param(param: String) -> Array:
	param = param.strip_edges().trim_prefix("[").trim_suffix("]")
	var result_array = []
	for value in param.split(","):
		result_array.append(value.strip_edges().replace('"', ""))
	return result_array


## 递归解析并调用函数
func call_method_recursive(
	method_obj: ExpressionObj,
	function_dict: Dictionary,
) -> Variant:
	# 获取函数名并在映射表中查找对应的可调用函数
	var func_name = method_obj.name
	var callable_func = function_dict.get(func_name, null)

	# 如果函数不存在，抛出错误
	if not callable_func:
		Pindot.log.error(" Function not found:", func_name)
		return null

	# 解析并准备参数
	var resolved_params = []
	for param in method_obj.params:
		# 如果参数是嵌套的 ExpressionObj，则递归解析并调用
		if param is ExpressionObj:
			resolved_params.append(call_method_recursive(param, function_dict))
		else:
			# 否则直接添加原始参数
			resolved_params.append(param)

	# 调用函数并返回结果
	return callable_func.callv(resolved_params)
