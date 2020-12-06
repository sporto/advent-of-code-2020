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
	let inputs = group
	|> utils.split_lines
	|> list.map(person_input)

	case inputs {
		[] -> 0
		[ a ] -> set.size(a)
		[ a, ..rest ] -> {
			rest
			|> list.fold(from: a, with: set.intersection)
			|> set.size
		}
	}
}

fn part2(file: String) {
	file
	|> utils.split_groups
	|> list.map(count_group)
	|> utils.sum
}

pub fn main() {
	utils.read_file(input)
	|> result.map(part2)
}