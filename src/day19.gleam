import utils
import gleam/string
import gleam/int
import gleam/result
import gleam/list
import gleam/map.{Map}
import gleam/io

const sample_rules = "data/19/sample-rules.txt"
const sample_messages = "data/19/sample-messages.txt"

pub type Rule{
	Text(String)
	Or(Rule, Rule)
	Seq(List(Int))
}

pub fn read_rules(input) {
	utils.get_input_lines(input, parse_rule)
	|> result.map(map.from_list)
	// |> result.map(resolve_rules)
}

pub fn read_messages(input) {
	utils.read_file(input)
	|> utils.replace_error("Could not read file")
	|> result.map(utils.split_lines)
}

fn parse_rule(line: String) -> Result(tuple(Int, Rule), String) {
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
			Ok(Or(aa, bb))
		}
		_ -> {
			case string.starts_with(trimmed, "\"") {
				True -> {
					trimmed
					|> string.replace("\"", "")
					|> Text
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
	|> result.map(Seq)
}

pub fn part1_sample() {
	try rules = read_rules(sample_rules)
	try messages = read_messages(sample_messages)

	io.debug(rules)
	let valid = part1(rules, messages)
	io.debug(valid)

	Ok(1)
}

fn part1(rules, messages) {
	messages
	// |> list.map(check_message(rules, 0, _))
}

// fn check_message(rules_map, rule_index, message) {
// 	// io.debug(message)
// 	case map.get(rules_map, rule_index) {
// 		Ok(rule) -> {
// 			check_message_rule(rules_map, rule, message)
// 		}
// 		Error(_) -> Error("Invalid rule")
// 	}
// }

// fn check_message_rule(rules_map, rule, message) {
// 	case rule {
// 		Char(c) -> case c == message {
// 			True -> Ok("")
// 			False -> Error(message)
// 		}
// 		Either(rules) -> {
// 			let results = rules
// 				|> list.map(check_message_rule(rules_map, _, message))

// 			results
// 			|> list.fold(
// 				from: Error(message),
// 				with: fn(result, acc) {
// 					case acc {
// 						Ok(_) -> acc
// 						Error(_) -> result
// 					}
// 				}
// 			)
// 		}
// 		Sequence(rule_ids) -> {
// 			rule_ids
// 			|> list.fold(
// 				from: Ok(message),
// 				with: fn(rule_id, res) {
// 					case res {
// 						Error(_) -> res
// 						Ok(mes) -> {
// 							check_message(rules_map, rule_id, mes)
// 						}
// 					}
// 				}
// 			)
// 		}
// 	}
// }

pub fn resolve(rules, index) -> Result(List(String), String) {
	case map.get(rules, index) {
		Ok(rule) -> {
			case rule {
				Text(value) -> Ok([value])
				Or(_, _) -> todo
				Seq(rule_ids) -> {
					resolve_sequence(rules, rule_ids)
				}
			}
		}
		Error(_) -> Error("Invalid")
	}
}

pub fn resolve_sequence(rules, rule_ids: List(Int)) -> Result(List(String), String) {
	try results = rule_ids
	|> list.map(resolve(rules, _))
	|> result.all

	results
	|> list.fold(
		from: [""],
		with: fn(resolved: List(String), acc) {
			combine(acc, resolved)
		}
	)
	|> Ok
}

pub fn combine(left: List(String), right: List(String)) -> List(String) {
	left
	|> list.map(fn(l) {
		right
		|> list.map(fn(r) {
			string.append(l, r)
		})
	})
	|> list.flatten
}