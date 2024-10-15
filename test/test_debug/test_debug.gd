# extends GutTest

# ## 检查打印参数合并为字符串
# func test_log_result_is_string():
# 	var result = Pindot.log._parse_string("Hello", "World")
# 	assert_typeof(result, TYPE_STRING)

# ## 检查打印结果包含颜色
# func test_log_result_contains_color():
# 	var result = Pindot.log._parse_string("Hello", "World")
# 	assert_true(result.find("color") > 0)
