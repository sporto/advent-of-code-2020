import utils
import gleam/int
import gleam/list
import gleam/result
import gleam/string

const tickets = "data/16/tickets.txt"
const sample_tickets = "data/16/tickets-sample.txt"
const rules =  "data/16/rules.txt"
const rules_sample =  "data/16/rules-sample.txt"
const sample_ticket = [7,1,14]
const ticket = [181,131,61,67,151,59,113,101,79,53,71,193,179,103,149,157,127,97,73,191]

pub type Rule{
	Rule(
		field: String,
		range1: Range,
		range2: Range,
	)
}

pub type Range{
	Range(min: Int, max: Int)
}

pub fn part1_sample() {
	try tickets = utils.get_input_lines(sample_tickets, parse_ticket)
	try rules = utils.get_input_lines(rules_sample, parse_rule)

	Ok(rules)
}

fn parse_ticket(line) {
	line
	|> string.split(",")
	|> list.map(int.parse)
	|> result.all
	|> utils.replace_error("Could not parse")
}

fn parse_rule(line) {
	try tuple(field, right) = case string.split(line, ": ") {
		[field, right] -> Ok(tuple(field, right))
		_ -> Error("Invalid line")
	}

	try tuple(left_range, right_range) = case string.split(right, " or ") {
		[left_range, right_range] -> Ok(tuple(left_range, right_range))
		_ -> Error("Invalid range")
	}

	try range1 = parse_range(left_range)
	try range2 = parse_range(right_range)
	let rule = Rule(field, range1, range1)

	Ok(rule)
}

fn parse_range(input) {
	case string.split(input, "-") {
		[a,b] -> {
			try min = int.parse(a) |> utils.replace_error(a)
			try max = int.parse(b) |> utils.replace_error(b)
			Ok(Range(min, max))
		}
		_ -> Error("Invalid range")
	}
}