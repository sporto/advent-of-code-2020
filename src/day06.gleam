import utils
import gleam/result
import gleam/list
import gleam/string
import gleam/map
import gleam/set.{Set}

const input = "data/06/input.txt"

fn person_input(answers: String) -> Set(String)  {
	answers
	|> string.to_graphemes
	|> set.from_list
}

fn count_group(group: String) -> Int {
	group
	|> utils.split_lines
	|> list.map(person_input)
	|> list.fold(from: set.new(), with: set.union)
	|> set.size
}

fn part1(file: String) {
	file
	|> utils.split_groups
	|> list.map(count_group)
	|> utils.sum
}

pub fn main() {
	utils.read_file(input)
	|> result.map(part1)
}