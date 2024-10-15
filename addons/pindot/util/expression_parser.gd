## 字符串形式的函数解析工具
class_name ExpressionParser

#region	数据映射

## 函数映射表, 格式: {函数名:Callable}, 需要将函数封装成Callable
##		TIP: 函数定义时要将caller作为第一个参数,其他随意
##		如: func	buy(caller:Customer,buyer:Customer):->void
var callable_map: Dictionary
## 存储每个函数的预期参数类型, 用于检验填写的表达式参数
var callable_param_types: Dictionary


## 注册函数,只有注册过的函数才可以通过表达式调用
## 示例:
## func testfunc1(caller: Variant, p):
## 		return int(p) + 2
## parser.register_callable("testfunc1", testfunc1, [TYPE_NIL])  # TYPE_NIL 匹配未指定类型的参数
##
## func testfunc5(caller: Variant, p1: String, p2: int, p3: Array):
## 		return caller
## parser.register_callable("testfunc5", testfunc5, [TYPE_STRING, TYPE_INT, TYPE_ARRAY])
func register_callable(key: String, callable: Callable, param_types: Array):
	assert(!callable_map.has(key), "Callable already registered: " + key)
	callable_map[key] = callable
	callable_param_types[key] = param_types


func unregister_callable(key: String):
	assert(callable_map.has(key), "Callable	not	found: " + key)
	callable_map.erase(key)
	callable_param_types.erase(key)


#endregion

#region	函数解析


class ExpressionObj:
	var name: String
	var params: Array

	func _init(name, params) -> void:
		self.name = name
		self.params = params


## 执行表达式
## @param caller 调用函数者,可以在函数中声音具体的类型, 如: function(caller:Customer)
## @param expression 字符串的表达式,如:	buy(nearest(["8001","8002"]))
## 执行失败返回null
func execute_expression(caller: Variant, expression: String) -> Variant:
	var obj = parse_expression(expression)
	return call_method_recursive(caller, obj)


## 解析表达式的函数名和参数,返回ExpressionObj
## 示例:
## 输入: 'myFunction("param1", ["8001", "8002"], "testparam2")'
## 输出: ["param1", ["8001", "8002"],	"testparam2"]
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


#endregion

#region	函数执行


## 递归解析并调用函数
func call_method_recursive(caller: Variant, method_obj: ExpressionObj) -> Variant:
	# 获取函数名并在映射表中查找对应的可调用函数
	var func_name = method_obj.name
	var callable: Callable = callable_map.get(func_name, null)

	# 如果函数不存在，抛出错误
	if not callable:
		Pindot.log.error(" Function	not	found:", func_name)
		return null

	# 解析并准备参数
	var resolved_params = []
	for param in method_obj.params:
		# 如果参数是嵌套的 ExpressionObj，则递归解析并调用
		if param is ExpressionObj:
			resolved_params.append(call_method_recursive(caller, param))
		else:
			# 否则直接添加原始参数
			resolved_params.append(param)

	# 检查参数数量是否匹配
	var expected_param_count = callable.get_argument_count()
	var received_param_count = resolved_params.size()

	# 检查参数类型
	if !_check_parameter_types(func_name, resolved_params):
		return null

	# 函数定义时要将caller作为第一个参数,其他参数由函数自定义
	resolved_params.insert(0, caller)

	# 调用函数并返回结果
	return callable.callv(resolved_params)


# 在调用前检查参数类型
func _check_parameter_types(func_name: String, received_params: Array) -> bool:
	assert(callable_param_types.has(func_name), "Function type not found: " + func_name)
	var expected_types = callable_param_types[func_name]

	var expected_params_count = expected_types.size()
	var received_params_count = received_params.size()

	# 不做参数个数校验,因为有的参数默认有值可以不填写
	# if expected_params_count != received_params_count:
	# 	# 输出: Parameter count mismatch in function: buy Expected: 1, Received: 0
	# 	Pindot.log.error(
	# 		"Parameter count mismatch in function: " + func_name,
	# 		"Expected: " + str(expected_params_count) + ", Received: " + str(received_params_count)
	# 	)
	# 	return false
	for i in range(expected_params_count):
		# TYPE_NIL 这里代表任意类型
		if expected_types[i] != TYPE_NIL and expected_types[i] != typeof(received_params[i]):
			# 输出: Parameter mismatch in function: buy param1: expected Object, but got String "me"
			Pindot.log.error(
				"Parameter mismatch in function: " + func_name,
				(
					"param"
					+ str(i + 1)
					+ ": expected "
					+ _get_variant_type_name(expected_types[i])
					+ ", but got "
					+ _get_variant_type_name(typeof(received_params[i]))
					+ ' "'
					+ str(received_params[i])
					+ '"'
				)
			)
			return false
	return true


func _get_variant_type_name(value: Variant.Type) -> String:
	match value:
		TYPE_NIL:
			return "Nil"
		TYPE_BOOL:
			return "Bool"
		TYPE_INT:
			return "Int"
		TYPE_STRING:
			return "String"
		TYPE_DICTIONARY:
			return "Dictionary"
		TYPE_ARRAY:
			return "Array"
		TYPE_OBJECT:
			return "Object"
		TYPE_DICTIONARY:
			return "Dictionary"
		TYPE_DICTIONARY:
			return "Dictionary"
		# 其他类型可以根据需要添加
		_:
			return "Unknown	Type"

#endregion
