extends GutTest

var parser := ExpressionParser.new()

#region 函数映射


func testfunc1(caller: Variant, p):
	return int(p) + 2


func testfunc2(caller: Variant, p: String):
	return int(p) + 1


func testfunc3(caller: Variant, p1: int, p2: int):
	return int(p1) + int(p2)


class TestClass:
	var a = 1


func testfunc4(caller: TestClass, p1):
	Pindot.log.info("caller in testfunc4 ====", caller)  #LOG
	return caller


func testfunc5(caller: Variant, p1: String, p2: int, p3: Array):
	return caller


func before_all():
	parser.register_callable("testfunc1", testfunc1, [TYPE_NIL])  # TYPE_NIL 匹配未指定类型的参数
	parser.register_callable("testfunc2", testfunc2, [TYPE_STRING])
	parser.register_callable("testfunc3", testfunc3, [TYPE_INT, TYPE_INT])
	parser.register_callable("testfunc4", testfunc4, [TYPE_NIL])
	parser.register_callable("testfunc5", testfunc5, [TYPE_STRING, TYPE_INT, TYPE_ARRAY])


#endregion

#region 函数解析


## 解析单个函数名
func test_func():
	var method_obj = parser.parse_expression("testfunc")
	assert_true(method_obj.name == "testfunc", "name should be :" + str(method_obj.name))
	assert_true(method_obj.params == [], "params should be :" + str(method_obj.params))
	Pindot.log.info("testfunc ====", [method_obj.name, method_obj.params])


## 解析单个函数名 带 1个参数
func test_func_with_param():
	var method_obj = parser.parse_expression('testfunc("testparam1")')
	assert_true(method_obj.name == "testfunc", "name should be :" + str(method_obj.name))
	assert_true(method_obj.params == ["testparam1"], "params should be :" + str(method_obj.params))
	Pindot.log.info('testfunc("testparam1") ====', [method_obj.name, method_obj.params])


## 解析单个函数名 带 多个参数
func test_func_with_params():
	var method_obj = parser.parse_expression('testfunc("testparam1","testparam2")')
	assert_true(method_obj.name == "testfunc", "name should be :" + str(method_obj.name))
	assert_true(
		method_obj.params == ["testparam1", "testparam2"],
		"params should be :" + str(method_obj.params)
	)
	Pindot.log.info(
		'testfunc("testparam1","testparam2") ====', [method_obj.name, method_obj.params]
	)


## 解析嵌套函数
func test_nested_func():
	var method_obj = parser.parse_expression("testfunc1(testfunc2())")
	assert_true(method_obj.name == "testfunc1", "name should be :" + str(method_obj.name))
	assert_true(
		method_obj.params[0] is ExpressionParser.ExpressionObj,
		"params[0] should be parser.MethodObj, but: " + str(method_obj.params[0])
	)
	Pindot.log.info("testfunc1(testfunc2()) ====", [method_obj.name, method_obj.params])


## 解析嵌套函数,带多个参数
func test_nested_func_with_params():
	var method_obj = parser.parse_expression(
		'testfunc1(testfunc2("func2param1","func2param2"),"func1param2","func1param3")'
	)
	assert_true(method_obj.name == "testfunc1", "name should be :" + str(method_obj.name))

	assert_true(
		method_obj.params[1] == "func1param2", "params[1] should be :" + str(method_obj.params[1])
	)
	assert_true(
		method_obj.params[2] == "func1param3", "params[2] should be :" + str(method_obj.params[2])
	)

	assert_true(
		method_obj.params[0] is ExpressionParser.ExpressionObj,
		"params[0] should be parser.MethodObj, but: " + str(method_obj.params[0])
	)
	assert_true(
		method_obj.params[0].params == ["func2param1", "func2param2"],
		"params[0].params should be :" + str(method_obj.params[0].params)
	)
	Pindot.log.info(
		'testfunc1(testfunc2("func2param1","func2param2"),"func1param2","func1param3") ====',
		[method_obj.name, method_obj.params]
	)
	Pindot.log.info(
		"method_obj.params[0] ====", [method_obj.params[0].name, method_obj.params[0].params]
	)


#endregion

#region 函数调用

## 函数定义时要将caller作为第一个参数,其他随意


func test_检查函数调用结果():
	var result = parser.execute_expression(self, "testfunc1(testfunc2(1))")
	Pindot.log.info("testfunc1(testfunc2(1)) result ====", result)
	assert_true(result == 4, "result should be 4, but: " + str(result))


func test_检查函数调用结果_多参数():
	var result = parser.execute_expression(self, "testfunc3(testfunc1(1),testfunc2(1))")
	Pindot.log.info("testfunc3(testfunc1(1),testfunc2(1)) result ====", result)
	assert_true(result == 5, "result should be 5, but: " + str(result))


func test_可以传入额外的参数():
	var result = parser.execute_expression(TestClass.new(), "testfunc4(testfunc1(1))")
	Pindot.log.info("testfunc4(testfunc1(1)) result ====", result)
	assert_true(result is TestClass, "result wrong: " + str(result))


func test_参数数量不对报错():
	var result = parser.execute_expression(TestClass.new(), "testfunc4(testfunc1(1),1,2,3)")
	assert_true(result == null)
	Pindot.log.info("这里会有报错↑↑↑")

	parser.execute_expression(TestClass.new(), "testfunc4(1)")
	Pindot.log.info("这里没有报错↑↑↑")


func test_参数类型不对报错():
	var result = parser.execute_expression(self, "testfunc5(1,2,3)")
	assert_true(result == null)
	Pindot.log.info("这里会有报错↑↑↑")

	parser.execute_expression(self, 'testfunc5("string",testfunc1(1),[3,4])')
	Pindot.log.info("这里没有报错↑↑↑")

#endregion
