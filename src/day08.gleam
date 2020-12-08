import utils
import gleam/io
import gleam/result
import gleam/string
import gleam/list
import gleam/int
import gleam/set.{Set}

// const input = "data/08/sample1.txt"
const input = "data/08/input.txt"

type Op{
	NoOp
	Acc(Int)
	Jump(Int)
}

fn parse_op(op: String, value: Int) -> Result(Op, String) {
	case op {
		"nop" -> Ok(NoOp)
		"acc" -> Ok(Acc(value))
		"jmp" -> Ok(Jump(value))
		_ -> Error(string.append("Invalid ", op))
	}
}

fn parse_line(line: String) -> Result(Op, String) {
	try split = string.split_once(line, " ")
		|> result.map_error(fn(_) { "Could not split" })

	let tuple(a, b) = split
	try num = int.parse(b) |> result.map_error(fn(_) { "Invalid num" })
	try op = parse_op(a, num)

	Ok(op)
}

fn parse_instructions(lines: List(String)) {
	lines
	|> list.map(parse_line)
	|> result.all
}

fn run(
		ins: List(Op),
		pos pos: Int,
		acc acc: Int,
		counter counter: Int,
		visited visited: Set(Int),
	) -> Int {

	// io.println("")
	// io.println(string.append("counter ", int.to_string(counter + 1)))
	// io.println(string.append("pos ", int.to_string(pos)))
	// io.println(string.append("acc ", int.to_string(acc)))

	case set.contains(visited, pos) {
		True -> acc
		False -> {
			case list.at(in: ins, get: pos) {
				Ok(op) -> {
					// io.debug(op)
					let next_counter = counter + 1
					let next_visited = set.insert(visited, pos)

					case op {
						NoOp -> run(ins, pos + 1, acc, next_counter, next_visited)
						Acc(val) -> run(ins, pos + 1, acc + val, next_counter, next_visited)
						Jump(val) -> run(ins, pos + val, acc, next_counter, next_visited)
					}
				}
				Error(_) -> acc
			}
		}
	}
}

fn part1(file) {
	try instructions = file
	|> utils.split_lines
	|> parse_instructions
	// |> io.debug

	instructions
	|> run(pos: 0, acc: 0, counter: 0, visited: set.new())
	|> io.debug
	|> Ok
}

pub fn main() {
	utils.read_file(input)
	|> result.map_error(fn(_) { "Could not read file" })
	|> result.then(part1)
}