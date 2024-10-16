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


func async_testfunc(caller: Variant, p1: String):
	var res = int(p1)
	for i in 2:
		await wait_seconds(0.1)
		res += 1
		Pindot.log.info(
			"async_testfunc awaiting", "res=" + str(res) + " time=" + str(Time.get_ticks_msec())
		)
	return res


var async_testfunc1_data := 0


func async_testfunc1(caller: Variant, p1: String):
	for i in 2:
		await wait_seconds(0.1)
		async_testfunc1_data += int(p1)
		Pindot.log.info(
			"async_testfunc1 awaiting",
			"res=" + str(async_testfunc1_data) + " time=" + str(Time.get_ticks_msec())
		)
	return async_testfunc1_data


func before_all():
	parser.register_callable("testfunc1", testfunc1, [TYPE_NIL])  # TYPE_NIL 匹配未指定类型的参数
	parser.register_callable("testfunc2", testfunc2, [TYPE_STRING])
	parser.register_callable("testfunc3", testfunc3, [TYPE_INT, TYPE_INT])  # 直接通过excel调用的函数是无法传入int格式的参数的,只有将其他函数的结果作为参数的情况,才能传入int格式
	parser.register_callable("testfunc4", testfunc4, [TYPE_NIL])
	parser.register_callable("testfunc5", testfunc5, [TYPE_STRING, TYPE_INT, TYPE_ARRAY])
	parser.register_callable("async_testfunc", async_testfunc, [TYPE_STRING])
	parser.register_callable("async_testfunc1", async_testfunc1, [TYPE_STRING])


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
	var result = await parser.execute_expression(self, "testfunc1(testfunc2(1))")
	Pindot.log.info("testfunc1(testfunc2(1)) result ====", result)
	assert_true(result == 4, "result should be 4, but: " + str(result))


func test_检查函数调用结果_多参数():
	var result = await parser.execute_expression(self, "testfunc3(testfunc1(1),testfunc2(1))")
	Pindot.log.info("testfunc3(testfunc1(1),testfunc2(1)) result ====", result)
	assert_true(result == 5, "result should be 5, but: " + str(result))


func test_可以传入额外的参数():
	var result = await parser.execute_expression(TestClass.new(), "testfunc4(testfunc1(1))")
	Pindot.log.info("testfunc4(testfunc1(1)) result ====", result)
	assert_true(result is TestClass, "result wrong: " + str(result))


func test_参数数量不对报错():
	var result = await parser.execute_expression(TestClass.new(), "testfunc4(testfunc1(1),1,2,3)")
	assert_true(result == null)
	Pindot.log.info("这里会有报错↑↑↑")

	parser.execute_expression(TestClass.new(), "testfunc4(1)")
	Pindot.log.info("这里没有报错↑↑↑")


func test_参数类型不对报错():
	var result = await parser.execute_expression(self, "testfunc5(1,2,3)")
	assert_true(result == null)
	Pindot.log.info("这里会有报错↑↑↑")

	parser.execute_expression(self, 'testfunc5("string",testfunc1(1),[3,4])')
	Pindot.log.info("这里没有报错↑↑↑")


func test_异步函数调用():
	var result = await parser.execute_expression(self, "async_testfunc(1)")
	Pindot.log.info("async_testfunc(1) result ====", result)

	assert_true(result == 3, "result should be 3, but: " + str(result))


func test_可以直接调用异步函数():
	parser.execute_expression(self, "async_testfunc1(100)")
	Pindot.log.info("直接执行,函数会异步调用")
	assert_true(
		async_testfunc1_data == 0,
		"async_testfunc1_data should be 0, but: " + str(async_testfunc1_data)
	)
	await wait_seconds(0.1)
	await wait_seconds(0.1)
	Pindot.log.info("这里有结果了↑↑↑")
	
	Pindot.log.info("async_testfunc(1) result ====", async_testfunc1_data)
	assert_true(
		async_testfunc1_data == 200,
		"async_testfunc1_data should be 200, but: " + str(async_testfunc1_data)
	)

#endregion
