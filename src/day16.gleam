import utils
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/io
import gleam/pair
import gleam/bool
import gleam/map
import gleam/function
import gleam/set

const part1_rules_sample =  "data/16/part1-rules-sample.txt"
const part2_rules_sample =  "data/16/part2-rules-sample.txt"
const part1_sample_tickets = "data/16/part1-tickets-sample.txt"
const part2_sample_tickets = "data/16/part2-tickets-sample.txt"
const rules =  "data/16/rules.txt"
const tickets = "data/16/tickets.txt"

const part2_sample_ticket = [11,12,13]
// const sample_ticket = [7,1,14]
const main_ticket = [181,131,61,67,151,59,113,101,79,53,71,193,179,103,149,157,127,97,73,191]

pub type Rule{
	Rule(
		field: String,
		range1: Range,
		range2: Range,
	)
}

pub type RuleSet = List(Rule)

pub type Ticket = List(Int)

pub type Range{
	Range(min: Int, max: Int)
}

// Parse

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
	let rule = Rule(field, range1, range2)

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

// Validations

fn part1_validate_ticket(rules, ticket) -> Int {
	ticket
	|> list.map(part1_validate_field(rules, _))
	|> utils.sum
}

fn part1_validate_field(rules, field) -> Int {
	case is_valid_field(rules, field) {
		True -> 0
		False -> field
	}
}

fn is_valid_ticket(rules: RuleSet, ticket: Ticket) -> Bool {
	ticket
	|> list.all(is_valid_field(rules, _))
}

fn is_valid_field(rules: RuleSet, field: Int) -> Bool {
	rules
	|> list.any(validate_field_rule(field, _))
}

fn validate_field_rule(field: Int, rule: Rule) -> Bool {
	[rule.range1, rule.range2]
	|> list.any(is_valid_field_range(field, _))
}

fn is_valid_field_range(field: Int, range: Range) -> Bool {
	field >= range.min && field <= range.max
}

// fn test_tickets(rules: RuleSet, tickets) -> Bool {
// 	tickets
// 	|> list.all(test_ticket(_, rules))
// }

// fn test_ticket(ticket, rules: RuleSet) -> Bool {
// 	// each field in the ticket must be valid for the corresponding rule
// 	list.zip(rules, ticket)
// 	|> list.all(fn(t) {
// 		let tuple(rule, field) = t
// 		validate_field_rule(field, rule)
// 	})
// }

fn invalid_values_for_rule(values: List(Int), rule: Rule) -> List(Int) {
	values
	|> list.filter(fn(val){
		validate_field_rule(val, rule)
		|> bool.negate
	})
}


// Entry

pub fn part1_sample() {
	part1(part1_sample_tickets, part1_rules_sample)
}

pub fn part1_main() {
	part1(tickets, rules)
}

pub fn part2_sample() {
	part2(
		part2_sample_tickets,
		part2_rules_sample,
		part2_sample_ticket
	)
}

pub fn part2_main() {
	part2(
		tickets,
		rules,
		main_ticket
	)
}

fn part1(tickets_input, rules_input) {
	try tickets = utils.get_input_lines(tickets_input, parse_ticket)
	try rules = utils.get_input_lines(rules_input, parse_rule)

	let sum = tickets
	|> list.map(part1_validate_ticket(rules, _))
	|> utils.sum

	Ok(sum)
}

fn part2(tickets_input: String, rules_input: String, ticket: Ticket) {
	try tickets = utils.get_input_lines(tickets_input, parse_ticket)
	try rules = utils.get_input_lines(rules_input, parse_rule)

	let valid_tickets = tickets
	|> list.filter(is_valid_ticket(rules, _))

	let values_per_index = list.range(0, list.length(main_ticket))
		|> list.fold(
			from: map.new(),
			with: fn(ix, acc) {
				// Collect all values at this index
				let values = valid_tickets |> list.map(fn(ticket) {
					list.at(ticket, ix) |> result.unwrap(-1)
				})

				map.insert(acc, ix, values)
			}
		)

	// io.debug(map.get(values_per_index, 16))

	let possible_rules_per_index = map.map_values(values_per_index, fn(key, values) {
		rules
			|> list.filter_map(fn(rule) {
				case invalid_values_for_rule(values, rule) {
					[] -> Ok(rule.field)
					_ -> Error(Nil)
				}
			})
	})

	possible_rules_per_index
	|> map.to_list
	|> list.sort(fn(a, b) {
		int.compare(pair.second(a) |> list.length, pair.second(b) |> list.length)
	})
	|> list.fold(
		from: map.new(),
		with: fn(t, acc) {
			let tuple(field_index, matched_rules) = t

			let matched_rules_set = set.from_list(matched_rules)
			let used_rules = map.values(acc) |> set.from_list

			let unused_rules =
				set.fold(
					over: used_rules,
					from: matched_rules_set,
					with: fn(r, ac) { set.delete(ac, r) }
				)

			case set.to_list(unused_rules) |> list.head {
				Ok(head) -> {
					map.insert(acc, field_index, head)
				}
				_ -> acc
			}
		}
	)
	|> io.debug


	Ok([0])
}