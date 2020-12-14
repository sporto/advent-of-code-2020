import utils
import gleam/list
import gleam/result
import gleam/string
import gleam/int
import gleam/pair
import gleam/map.{Map}

const sample = "data/14/sample.txt"
const input = "data/14/input.txt"
const mask = "mask = "

pub type Ins {
	Mask(List(Bit))
	Mem(Int, Int)
}

pub type Bit{
	Same
	Zero
	One
}

pub fn read_input(file) {
	utils.read_file(file)
	|> utils.replace_error("Could not read file")
	|> result.map(utils.split_lines)
	|> result.then(parse_lines)
}

fn parse_lines(lines: List(String)) -> Result(List(Ins), String) {
	lines
	|> list.map(parse_line)
	|> result.all
}

fn parse_line(line: String) -> Result(Ins, String) {
	case string.starts_with(line, mask) {
		True -> parse_bitmask(line)
		False -> parse_mem_ins(line)
	}
}

fn parse_bitmask(line) {
	string.replace(line, mask, "")
		|> string.to_graphemes
		|> list.map(parse_bit)
		|> result.all
		|> result.map(Mask)
}

fn parse_bit(c) -> Result(Bit, String) {
	case c {
		"X" -> Ok(Same)
		"0" -> Ok(Zero)
		"1" -> Ok(One)
		_ -> Error(c)
	}
}

fn parse_mem_ins(line) {
	try tuple(left, right) = split(line)
	try mem = left
		|> string.drop_left(4)
		|> string.drop_right(1)
		|> int.parse
		|> utils.replace_error("Could not parse line")

	try val = int.parse(right)
		|> utils.replace_error("Could not parse line")

	Ok(Mem(mem, val))
}

fn split(line: String) -> Result(tuple(String, String), String) {
	case string.split(line, " = ") {
		[left, right] -> Ok(tuple(left, right))
		_ -> Error(line)
	}
}

type State{
	State(
		mask: List(Bit),
		mem: Map(Int, Int)
	)
}

fn part1(input) {
	let state = State(mask: [], mem: map.new())

	let final = input
	|> list.fold(
		from: state,
		with: part1_step
	)

	final.mask
}

fn part1_step(ins, state) {
	case ins {
		Mask(mask) ->
			State(..state, mask: mask)
		Mem(slot, value) ->
			State(..state, mem: set_mem(state.mem, state.mask, slot, value))
	}
}

fn set_mem(memory, mask, slot, value) {
	map.insert(
		into: memory,
		for: slot,
		insert: masked_value(mask, value)
	)
}

fn masked_value(mask, value) {
	let expanded = utils.to_binary(value)

	list.zip(mask, expanded)
	|> list.map(fn(t) {
		case pair.first(t) {
			Same -> pair.second(t)
			Zero -> False
			One -> True
		}
	})
	|> from_binary
}

fn from_binary(bin: List(Bool)) -> Int {
	0
}

pub fn part1_sample() {
	read_input(sample)
	|> result.map(part1)
}