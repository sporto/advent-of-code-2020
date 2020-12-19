import utils
import gleam/string
import gleam/int
import gleam/result
import gleam/list

const sample_rules = "data/19/sample-rules.txt"

pub type Rule{
	Either(List(Rule))
	Char(String)
	Sequence(List(Int))
}

pub fn read_rules(input) {
	utils
		.get_input_lines(input, parse_rule)
}

fn parse_rule(line) {
	try tuple(left, right) = case string.split(line, ": ") {
		[l,r] -> Ok(tuple(l, r))
		_ -> Error(line)
	}

	try rule_num = int.parse(left)
		|> utils.replace_error("Invalid rule num")

	try rule = parse_rule_right(right)

	Ok(tuple(rule_num, rule))
}

fn parse_rule_right(input: String) -> Result(Rule, String) {
	let trimmed = string.trim(input)

	case string.split(trimmed, "|") {
		[a, b] -> {
			try aa = parse_rule_sequence(a)
			try bb = parse_rule_sequence(b)
			Ok(Either([aa, bb]))
		}
		_ -> {
			case string.starts_with(trimmed, "\"") {
				True -> {
					trimmed
					|> string.replace("\"", "")
					|> Char
					|> Ok
				}
				False -> {
					parse_rule_sequence(trimmed)
				}
			}
		}
	}
}

pub fn parse_rule_sequence(input: String) -> Result(Rule, String) {
	let parts = input
		|> string.trim
		|> string.split(" ")

	parts
	|> list.map(int.parse)
	|> result.all
	|> utils.replace_error("Could not parse sequence")
	|> result.map(Sequence)
}

pub fn part1_sample() {
	read_rules(sample_rules)
}