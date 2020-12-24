import utils
import gleam/list
import gleam/result
import gleam/pair
import gleam/string

const sample = "data/21/sample.txt"
const input = "data/21/input.txt"

fn read(file) {
	utils.get_input_lines(file, parse_line)
}

pub type InputLine{
	InputLine(
		ingredients: List(String),
		allergens: List(String)
	)
}

fn parse_line(line: String) -> Result(InputLine, String) {
	case string.split_once(line, "(contains") {
		Ok(t) -> {
			let line = InputLine(
				ingredients: pair.first(t) |> string.trim |> string.split(" "),
				allergens: pair.second(t) |> string.drop_right(1) |> string.trim |> string.split(", ")
			)
			Ok(line)
		}
		Error(e) -> Error(line)
	}
}

pub fn part1_sample() {
	read(sample)
	|> result.map(part_1)
}

fn part_1(lines) {
	lines
}