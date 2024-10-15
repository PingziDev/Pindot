extends GutTest

var util := ExpressionParser.new()

#region 函数解析


## 解析单个函数名
func test_func():
	var method_obj = util.parse_expression("testfunc")
	assert_true(method_obj.name == "testfunc", "name should be :" + str(method_obj.name))
	assert_true(method_obj.params == [], "params should be :" + str(method_obj.params))
	Pindot.log.info("testfunc ====", [method_obj.name, method_obj.params])


## 解析单个函数名 带 1个参数
func test_func_with_param():
	var method_obj = util.parse_expression('testfunc("testparam1")')
	assert_true(method_obj.name == "testfunc", "name should be :" + str(method_obj.name))
	assert_true(method_obj.params == ["testparam1"], "params should be :" + str(method_obj.params))
	Pindot.log.info('testfunc("testparam1") ====', [method_obj.name, method_obj.params])


## 解析单个函数名 带 多个参数
func test_func_with_params():
	var method_obj = util.parse_expression('testfunc("testparam1","testparam2")')
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
	var method_obj = util.parse_expression("testfunc1(testfunc2())")
	assert_true(method_obj.name == "testfunc1", "name should be :" + str(method_obj.name))
	assert_true(
		method_obj.params[0] is ExpressionParser.ExpressionObj,
		"params[0] should be util.MethodObj, but: " + str(method_obj.params[0])
	)
	Pindot.log.info("testfunc1(testfunc2()) ====", [method_obj.name, method_obj.params])


## 解析嵌套函数,带多个参数
func test_nested_func_with_params():
	var method_obj = util.parse_expression(
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
		"params[0] should be util.MethodObj, but: " + str(method_obj.params[0])
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


func testfunc1(p):
	return int(p) + 2


func testfunc2(p):
	return int(p) + 1


func testfunc3(p1, p2):
	return int(p1) + int(p2)


var function_dict = {
	"testfunc1": testfunc1,
	"testfunc2": testfunc2,
	"testfunc3": testfunc3,
}


## 检查函数调用结果
func test_expression_result():
	var result = util.execute_expression("testfunc1(testfunc2(1))", function_dict)
	Pindot.log.info("testfunc1(testfunc2(1)) result ====", result)
	assert_true(result == 4, "result should be 4, but: " + str(result))


## 检查函数调用结果-多参数
func test_expression_result_with_params():
	var result = util.execute_expression("testfunc3(testfunc1(1),testfunc2(1))", function_dict)
	Pindot.log.info("testfunc3(testfunc1(1),testfunc2(1)) result ====", result)
	assert_true(result == 5, "result should be 5, but: " + str(result))

#endregion
