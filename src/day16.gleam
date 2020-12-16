import utils
import gleam/int
import gleam/list
import gleam/result
import gleam/string

const tickets = "data/16/tickets.txt"
const sample_tickets = "data/16/tickets-sample.txt"
const sample_ticket = [7,1,14]
const ticket = [181,131,61,67,151,59,113,101,79,53,71,193,179,103,149,157,127,97,73,191]

pub fn part1_sample() {
	utils.get_input_lines(sample_tickets, parse_line)
}

fn parse_line(line) {
	line
	|> string.split(",")
	|> list.map(int.parse)
	|> result.all
	|> utils.replace_error("Could not parse")
}