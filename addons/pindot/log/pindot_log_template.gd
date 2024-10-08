## 日志输出模板
var no_color_template := "[{category}] {name} {data}"
var color_template := "[[color=gray]{category}[/color]] [color={levelcolor}]{name}[/color] [color={datacolor}]{data}[/color]"

var stack_no_color_template = "\t{source}:{line}"
var stack_color_template = "\t\t[code][color={sourcecolor}]{source}:{line}[/color] [color={functioncolor}]{function}[/color][/code]"

var time_temmplate := "{hour}:{minute}:{second}"
