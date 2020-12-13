import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam/option.{Option, Some, None}
import utils

const sample = tuple(
	939,
	"7,13,x,x,59,x,31,19"
)

const input = tuple(
	1000104,
	"41,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,37,x,x,x,x,x,659,x,x,x,x,x,x,x,23,x,x,x,x,13,x,x,x,x,x,19,x,x,x,x,x,x,x,x,x,29,x,937,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,17"
)

fn part1(t) {
	let initial_time = pair.first(t)
	let buses = part1_parse_buses(pair.second(t))
	let tuple(bus, bus_time) = part1_find_bus(initial_time, buses)
	bus * { bus_time - initial_time }
}

fn part1_parse_buses(input: String) -> List(Int) {
	input
	|> string.split(",")
	|> list.filter_map(int.parse)
}

fn part1_find_bus(time: Int, buses: List(Int)) {
	let maybe_bus = buses |> list.find(utils.is_divisor_of(time, _))

	case maybe_bus {
		Ok(bus) -> tuple(bus, time)
		Error(_) -> part1_find_bus(time + 1, buses)
	}
}

pub fn part2(earliest, input) {
	let buses = part2_parse_buses(input)

	part2_find_time(earliest, buses)
}

fn part2_parse_buses(input: String) -> List(Option(Int)) {
	input
	|> string.split(",")
	|> list.map(function.compose(int.parse, option.from_result))
}

fn part2_find_time(time: Int, buses) {
	case check_departures(time, buses) {
		True -> time
		False -> part2_find_time(time +1, buses)
	}
}

fn check_departures(time, buses) {
	case buses {
		[] -> True
		[ first, ..rest ] -> {
			case bus_can_depart(time, first) {
				True -> check_departures(time + 1, rest)
				False -> False
			}
		}
	}
}

fn bus_can_depart(time, maybe_bus) {
	case maybe_bus {
		None -> True
		Some(bus) -> utils.is_divisor_of(time, bus)
	}
}

pub fn part1_sample() {
	part1(sample)
}

pub fn part1_main() {
	part1(input)
}

pub fn part2_sample() {
	part2(0, "7,13,x,x,59,x,31,19")
}

pub fn part2_main() {
	part2(100_000_000_000_000, pair.second(input))
}