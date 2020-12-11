import utils
import gleam/result
import gleam/string
import gleam/list

const sample1 = "data/11/sample1.txt"

pub type Place{
	Floor
	Empty
	Taken
}

fn parse_place(c) {
	case c {
		"." -> Ok(Floor)
		"#" -> Ok(Taken)
		"L" -> Ok(Empty)
		_ -> Error(Nil)
	}
}

fn parse_row(row) {
	row
	|> string.to_graphemes
	|> list.map(parse_place)
	|> result.all
}

fn parse_grid(lines) -> Result(List(List(Place)), Nil) {
	lines
	|> list.map(parse_row)
	|> result.all
}

fn read_input(file) {
	utils.read_file(file)
	|> result.nil_error
	|> result.map(utils.split_lines)
	|> result.then(parse_grid)
}

fn part1(grid) {
	grid
}

pub fn part1_sample1() {
	read_input(sample1)
	|> result.map(part1)
}