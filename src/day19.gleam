import utils
import gleam/string
import gleam/int
import gleam/bool
import gleam/result
import gleam/list
import gleam/pair
import gleam/map.{Map}
import gleam/io

const sample_rules = "data/19/sample-rules.txt"
const sample_messages = "data/19/sample-messages.txt"
const main_rules = "data/19/rules.txt"
const main_messages = "data/19/messages.txt"

pub type Rule{
	Text(String)
	Or(Rule, Rule)
	Seq(List(Int))
}

pub fn read_rules(input) {
	utils.get_input_lines(input, parse_rule)
	|> result.map(map.from_list)
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

	part1(rules, messages)
}

pub fn part1_main() {
	try rules = read_rules(main_rules)
	try messages = read_messages(main_messages)

	part1(rules, messages)
}

fn part1(rules, messages) -> Result(Int, String) {
	let keys = rules
	|> map.keys
	|> list.sort(int.compare)
	|> list.reverse

	let resolved = keys
	|> list.fold(
		from: map.new(),
		with: fn(key, cache) {
			let res = resolve_with_cache(rules, cache, key)
			case res {
				Ok(tt) -> {
					pair.first(tt)
				}
				Error(e) -> cache
			}
		}
	)

	try valid = map.get(resolved, 0) |> utils.replace_error("Coudn't get")

	messages
	|> list.map(check_message(valid, _))
	|> list.map(bool.to_int)
	|> utils.sum
	|> Ok
}

fn resolve_with_cache(rules, cache, index) {
	case resolve_using_cache(rules, cache, index) {
		Ok(resolved) -> {
			let next_cache = map.insert(cache, index, resolved)
			Ok(tuple(next_cache, resolved))
		}
		Error(e) -> Error(e)
	}
}

fn resolve_using_cache(rules, cache, index) {
	case map.get(cache, index) {
		Ok(value) -> Ok(value)
		// Not found in cache, resolve
		Error(_) -> {
			resolve(rules, index)
		}
	}
}

pub fn resolve(rules, index) -> Result(List(String), String) {
	case map.get(rules, index) {
		Ok(rule) -> {
			resolve_rule(rules, rule)
		}
		Error(_) -> Error("Invalid")
	}
}

pub fn resolve_rule(rules, rule) -> Result(List(String), String) {
	case rule {
		Text(value) -> Ok([value])
		Or(a, b) -> {
			try aa = resolve_rule(rules, a)
			try bb = resolve_rule(rules, b)
			[aa, bb] |> list.flatten |> Ok
		}
		Seq(rule_ids) -> {
			resolve_sequence(rules, rule_ids)
		}
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
		|> list.map(string.append(l, _))
	})
	|> list.flatten
}

fn check_message(valid: List(String), message: String) -> Bool {
	list.contains(valid, message)
}