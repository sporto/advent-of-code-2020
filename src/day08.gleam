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
	NoOp(Int)
	Acc(Int)
	Jump(Int)
}

pub type Outcome{
	Halted(Int)
	Terminated(Int)
}

fn parse_op(op: String, value: Int) -> Result(Op, String) {
	case op {
		"nop" -> Ok(NoOp(value))
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
	) -> Outcome {

	// io.println("")
	// io.println(string.append("counter ", int.to_string(counter + 1)))
	// io.println(string.append("pos ", int.to_string(pos)))
	// io.println(string.append("acc ", int.to_string(acc)))

	case set.contains(visited, pos) {
		True -> Halted(acc)
		False -> {
			case list.at(in: ins, get: pos) {
				Ok(op) -> {
					// io.debug(op)
					let next_counter = counter + 1
					let next_visited = set.insert(visited, pos)

					case op {
						NoOp(_) -> run(ins, pos + 1, acc, next_counter, next_visited)
						Acc(val) -> run(ins, pos + 1, acc + val, next_counter, next_visited)
						Jump(val) -> run(ins, pos + val, acc, next_counter, next_visited)
					}
				}
				Error(_) -> Terminated(acc)
			}
		}
	}
}

fn run_program(instructions) {
	run(instructions, pos: 0, acc: 0, counter: 0, visited: set.new())
}

fn part1(file) {
	try instructions = file
	|> utils.split_lines
	|> parse_instructions
	// |> io.debug

	instructions
	|> run_program
	|> io.debug
	|> Ok
}

fn mutate_instructions(instructions: List(Op)) -> List(List(Op)) {
	let ins_count = list.length(instructions)

	list.repeat(instructions, times: ins_count)
	|> list.index_map(fn(ix, ins) {
		ins
		|> list.index_map(fn(ix_in_ins, op) {
			case ix == ix_in_ins {
				True -> {
					case op {
						NoOp(value) -> Jump(value)
						Jump(value) -> NoOp(value)
						_ -> op
					}
				}
				False -> op
			}
		})
	})
}

fn part2(file) -> Result(Outcome, String) {
	try instructions = file
	|> utils.split_lines
	|> parse_instructions

	mutate_instructions(instructions)
	|> list.map(run_program)
	|> list.find(fn(outcome) {
		case outcome {
			Terminated(_) -> True
			Halted(_) -> False
		}
	})
	|> result.map_error(fn(_) { "No program terminated" })
	|> io.debug
}

pub fn main() {
	utils.read_file(input)
	|> result.map_error(fn(_) { "Could not read file" })
	|> result.then(part2)
}