extends Node2D
const DAYS_IN_YEAR = 365
var script_member_variable = 1000


func _ready():
	# Constant mathexpression.
	evaluate("2 + 2")
	# Math expression with variables.
	evaluate("x + y", ["x", "y"], [60, 100])

	# Call built-in method (built-in math function call).
	evaluate("deg_to_rad(90)")

	# Call user method (defined in the script).
	# We can do this because the expression execution is bound to `self`
	# in the `evaluate()` method.
	# Since this user method returns a value, we can use it in math expressions.
	# evaluate("call_me() + DAYS_IN_YEAR + script_member_variable")
	evaluate("call_me(call_me(222,[]),[12,'sdfdsf'])")

	# evaluate("call_me('some string')")
	evaluate("script_member_variable+2")

	Pindot.log.info("script_member_variable ====", script_member_variable)  #LOG


func evaluate(command, variable_names = [], variable_values = []) -> void:
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		Pindot.log.error(expression.get_error_text())
		return

	var result = expression.execute(variable_values, self)

	if not expression.has_execute_failed():
		print(str(result))
	else:
		Pindot.log.error(expression.get_error_text())


func call_me(argument: int, p2: Array):
	print("\nYou called 'call_me()' in the expression text.")
	Pindot.log.info("args ====", [argument, p2])
	# The method's return value is also the expression's return value.
	return argument
