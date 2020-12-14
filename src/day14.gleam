import utils
import gleam/list
import gleam/result
import gleam/string
import gleam/int
import gleam/pair
import gleam/io
import gleam/map.{Map}

const sample = "data/14/sample.txt"
const sample2 = "data/14/sample2.txt"
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
	try tuple(left, right) = parse_line_split(line)
	try mem = left
		|> string.drop_left(4)
		|> string.drop_right(1)
		|> int.parse
		|> utils.replace_error("Could not parse line")

	try val = int.parse(right)
		|> utils.replace_error("Could not parse line")

	Ok(Mem(mem, val))
}

fn parse_line_split(line: String) -> Result(tuple(String, String), String) {
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

	final.mem
	|> map.values
	|> utils.sum
}

fn part1_step(ins, state) {
	// io.debug(ins)
	// io.debug(state.mem)
	case ins {
		Mask(mask) ->
			State(..state, mask: mask)
		Mem(slot, value) ->
			State(..state, mem: set_memory(state.mem, state.mask, slot, value))
	}
}

fn set_memory(memory, mask, slot, value) {
	map.insert(
		into: memory,
		for: slot,
		insert: masked_value(mask, value)
	)
}

fn masked_value(mask, value) {
	let expanded = utils.to_binary(value)
	let expanded_filled = fill(expanded)

	list.zip(mask, expanded_filled)
	|> list.map(fn(t) {
		case pair.first(t) {
			Same -> pair.second(t)
			Zero -> False
			One -> True
		}
	})
	|> utils.from_binary
}

fn fill(bits) {
	let diff = 36 - list.length(bits)
	list.append(list.repeat(False, diff), bits)
}

pub fn part1_sample() {
	read_input(sample)
	|> result.map(part1)
}

pub fn part1_main() {
	read_input(input)
	|> result.map(part1)
}

fn part2(input) {
	let state = State(mask: [], mem: map.new())

	let final = input
	|> list.fold(
		from: state,
		with: part2_step
	)

	final.mem
	|> map.values
	|> utils.sum
}

fn part2_step(ins, state) {
	// io.debug(ins)
	// io.debug(state.mem)
	case ins {
		Mask(mask) ->
			State(..state, mask: mask)
		Mem(slot, value) ->
			State(..state, mem: part2_set_memory(state.mem, state.mask, slot, value))
	}
}

fn part2_set_memory(memory: Map(Int, Int), mask, slot, value) {
	let slot_in_binary = utils.to_binary(slot)
	let filled_address = fill(slot_in_binary)
	// io.debug("set")

	let addresses_to_write = list.zip(mask, filled_address)
	|> list.fold(
		from: [[]],
		with: fn(t, acc) {
			let tuple(mask_bit, bit) = t
			fold_mask(mask_bit, bit, acc)
		}
	)
	|> list.map(utils.from_binary)
	// |> io.debug

	addresses_to_write
	|> list.fold(
		from: memory,
		with: fn(address, acc) { map.insert(acc, address, value) }
	)
}

pub fn fold_mask(mask_bit, bit, acc) {
	case mask_bit {
		Zero -> list.map(acc, add(_, bit))
		One -> list.map(acc, add(_, True))
		Same -> list.map(acc, split_binary) |> list.flatten
	}
}

fn add(l, bit) {
	list.append(l, [bit])
}

fn split_binary(l: List(Bool)) -> List(List(Bool)) {
	[add(l, True), add(l, False)]
}

pub fn part2_sample() {
	read_input(sample2)
	|> result.map(part2)
}

pub fn part2_main() {
	read_input(input)
	|> result.map(part2)
}