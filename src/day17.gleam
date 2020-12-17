import utils
import gleam/string
import gleam/list
import gleam/result
import gleam/map.{Map}

const sample1 = "data/17/sample1.txt"

fn read_input(file) {
	utils.get_input_lines(file, parse_line)
	|> result.map(make_matrix)
	|> result.map(part1)
}

pub type Cell{
		On
		Off
	}

// Parse input

fn parse_line(line) -> Result(List(Cell), String) {
	line
	|> string.to_graphemes
	|> list.map(parse_char)
	|> Ok
}

fn parse_char(c) {
	case c {
		"#" -> On
		_ -> Off
	}
}

pub type Point{
	Point(x: Int, y: Int, z: Int)
}

pub type Matrix = Map(Point, Cell)

pub fn make_matrix(input: List(List(Cell))) -> Matrix {
	input
	|> add_index
	|> list.fold(
		from: map.new(),
		with: fn(row_tuple, acc) {
			let tuple(row_ix, row) = row_tuple
			row
			|> add_index
			|> list.fold(
				from: acc,
				with: fn(col_tuple, acc_) {
					let tuple(col_ix, cell) = col_tuple
					let point = Point(col_ix, row_ix, 0)
					map.insert(acc_, point, cell)
				}
			)
		}
	)
}

fn add_index(l: List(a)) -> List(tuple(Int, a)) {
	list.index_map(l, fn(ix, a) { tuple(ix, a) })
}

// Entry

pub fn part1_sample() {
	read_input(sample1)
}

fn part1(matrix) {
	matrix
}