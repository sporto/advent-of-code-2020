import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/int
import utils

pub type Side{
		Start
		End
	}

pub fn split(col: List(a), side: Side) -> List(a) {
	let count = list.length(col) / 2

	case side {
		Start ->
			list.take(col, count)
		End ->
			list.drop(col, count)
	}
}

pub fn reduce(col: List(a), sides: List(Side)) -> List(a) {
	case sides {
		[] -> col
		[ side, ..rest ] ->
			reduce(split(col, side), rest)
	}
}

fn row_char_to_side(c: String) -> Side {
	case c {
		"F" -> Start
		_ -> End
	}
}

fn col_char_to_side(c: String) -> Side {
	case c {
		"L" -> Start
		_ -> End
	}
}

pub fn find_row(sequence: String) -> Int {
	let sides = sequence
		|> string.to_graphemes
		|> list.map(row_char_to_side)

	let rows = 	list.range(0, 128)

	reduce(rows, sides)
		|> list.head
		|> result.unwrap(0)
}

pub fn find_col(sequence: String) -> Int {
	let sides = sequence
		|> string.to_graphemes
		|> list.map(col_char_to_side)

	let cols = list.range(0, 8)

	reduce(cols, sides)
		|> list.head
		|> result.unwrap(0)
}

pub fn find_seat(sequence: String) {
	tuple(
		find_row(string.slice(sequence, 0, 7)),
		find_col(string.drop_left(sequence, 7)),
	)
}

pub fn seat_id(sequence: String) {
	let tuple(row, col) = find_seat(sequence)
	row * 8 + col
}

const input = "data/05/input.txt"

pub fn part1(file: String) {
	file
	|> utils.split_lines
	|> list.map(seat_id)
	|> utils.max
	|> io.debug
}

fn find_missing(col: List(Int)) {
	let folder = fn(n, prev) {
		case prev {
			0 -> Ok(n)
			_ -> case n == prev + 1 {
				True -> Ok(n)
				False -> Error(prev + 1)
			}
		}
	}

	utils.try_fold(over: col, from: 0, with: folder)
}

pub fn part2(file: String) {
	file
	|> utils.split_lines
	|> list.map(seat_id)
	|> list.sort(int.compare)
	|> find_missing
	|> io.debug
}

pub fn main() {
	utils.read_file(input)
	|> result.map(part2)
}