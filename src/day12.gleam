import utils
import gleam/bool
import gleam/function
import gleam/io
import gleam/list
import gleam/int
import gleam/result
import gleam/string

const sample1 = "data/12/sample1.txt"

pub type Ins{
	N(Int)
	S(Int)
	W(Int)
	E(Int)
	F(Int)
	L(Int)
	R(Int)
}

fn read_input(file) {
	utils.get_input_lines(file, parse_line)
}

fn parse_line(line) -> Result(Ins, String) {
	let letter = string.slice(line, 0, 1)
	let digits = string.drop_left(line, 1)

	try val = int.parse(digits) |> utils.replace_error("Could not parse int")

	case letter {
		"N" -> Ok(N(val))
		"S" -> Ok(S(val))
		"W" -> Ok(W(val))
		"E" -> Ok(E(val))
		"F" -> Ok(F(val))
		"L" -> Ok(L(val))
		"R" -> Ok(R(val))
		_ -> Error("line")
	}
}

pub fn part1_sample1() {
	read_input(sample1)
	// |> result.map(part1)
}