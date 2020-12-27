import rolling.{Rolling}
import utils
import gleam/list
import gleam/result
import gleam/int
import gleam/io
import gleam/string

pub fn part1(max_moves: Int, input) {
	let cups = rolling.from_list(input)

	try final = p1_move_or_stop(
		max_moves: max_moves,
		previous_move: 0,
		cups: cups
	)

	// print_final(final)

	try rolled = final
		|> rolling.from_list
		|> roll_until_num_is_first(_, 1)

	let res = rolled
		|> rolling.to_list
		|> list.drop(1)
		|> list.map(int.to_string)
		|> string.join("")

	Ok(res)
}

pub fn part2(input) -> Result(Int, Nil) {
	let one_million = 1_000_000
	let max_moves = 10_000_000
	let max = utils.max(input)
	let filler = list.range(max + 1, one_million + 1)

	let cups = list.append(input, filler)
		|> rolling.from_list

	try final = p1_move_or_stop(
		max_moves: max_moves,
		previous_move: 0,
		cups: cups
	)

	// print_final(final)

	try rolled = final
		|> rolling.from_list
		|> roll_until_num_is_first(_, 1)

	let rolled_list = rolling.to_list(rolled)

	try a = rolled_list |> list.head
	try b = rolled_list |> list.drop(1) |> list.head

	Ok(a * b)
}

fn p1_move_or_stop(
		max_moves max_moves: Int,
		previous_move previous_move: Int,
		cups cups: Rolling(Int)
	) -> Result(List(Int), Nil) {

	case previous_move >= max_moves {
		True -> Ok(cups |> rolling.to_list)
		False -> {
			let move = previous_move + 1
			print_move(move)
			p1_move(cups)
				|> result.then(p1_move_or_stop(max_moves, move, _))
		}
	}
}

fn p1_move(input: Rolling(Int)) -> Result(Rolling(Int), Nil) {
	// print_cups(input |> rolling.to_list)

	let all_cups = rolling.to_list(input)
	try current_cup = rolling.current(input)

	// take three after current
	let picked_cups = all_cups |> list.take(4) |> list.drop(1)
	let remaining = [current_cup, ..list.drop(all_cups, 4)]

	// print_picked(picked_cups)

	let destination_cup = find_destination_cup(
		all_cups: all_cups,
		candidate: current_cup - 1,
		picked_cups: picked_cups,
	)

	// print_destination(destination_cup)

	// This returns with the destination as first
	try placed = place_cups(
		destination: destination_cup,
		picked_cups: picked_cups,
		remaining: remaining,
	)

	// io.debug(placed)

	try next_list = placed
	|> rolling.from_list
	|> roll_until_num_is_first(current_cup)

	next_list
	|> rolling.roll
	|> Ok
}

fn find_destination_cup(
	all_cups all_cups,
	candidate candidate,
	picked_cups picked_cups,
) -> Int {
	let min_value = utils.min(all_cups)

	case candidate < min_value {
		True -> {
			let max_value = utils.max(all_cups)
			find_destination_cup(all_cups, max_value, picked_cups)
		}
		False -> {
			let is_in_picked = list.any(picked_cups, fn(cup) { cup == candidate })
			case is_in_picked {
				True -> {
					find_destination_cup(all_cups, candidate - 1, picked_cups)
				}
				False -> {
					candidate
				}
			}
		}
	}
}

fn place_cups(
	destination destination: Int,
	picked_cups picked_cups: List(Int),
	remaining remaining: List(Int)
	) -> Result(List(Int), Nil) {

	case remaining {
		[first, ..rest] -> {
			case first == destination {
				True -> {
					list.append(
						[first, ..picked_cups], rest
					)
					|> Ok
				}
				False -> {
					place_cups(
						destination,
						picked_cups,
						list.append(rest, [first])
					)
				}
			}
		}
		_ -> Error(Nil)
	}
}

fn roll_until_num_is_first(l: Rolling(Int), wanted: Int) -> Result(Rolling(Int), Nil) {
	case rolling.current(l) {
		Ok(current) -> {
			case current == wanted {
				True -> Ok(l)
				False -> roll_until_num_is_first(
					rolling.roll(l), wanted
				)
			}
		}
		Error(Nil) -> Error(Nil)
	}
}

fn print_move(move) {
	io.debug("     ")
	[
		"-- move ",
		int.to_string(move),
		" --"
	] |> print
}

fn print_cups(cups: List(Int)) {
	let message = cups
	|> list.map(int.to_string)
	|> string.join(" ")

	["cups: ", message] |> print
}

fn print_picked(cups) {
	let message = cups
		|> list.map(int.to_string)
		|> string.join(" ")

	["pick up: ", message] |> print
}

fn print_destination(cup) {
	["destination:", int.to_string(cup)] |> print
}

fn print_final(cups) {
	io.debug("-- final --")
	print_cups(cups)
}

fn print(l: List(String)) {
	l |> string.join("") |> io.debug
}