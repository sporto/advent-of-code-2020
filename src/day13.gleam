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

fn part2_parse_buses(input: String) -> List(tuple(Int,Int)) {
	input
	|> string.split(",")
	|> list.index_map(fn(ix, e) { tuple(ix, e) })
	|> list.filter_map(fn(t) {
		case int.parse(pair.second(t)) {
			Ok(num) -> Ok(tuple(pair.first(t), num))
			Error(_) -> Error(Nil)
		}
	})
	|> list.sort(fn(a, b) {
		int.compare(pair.second(a), pair.second(b))
	})
	|> list.reverse
	|> io.debug
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
		[ bus, ..rest ] -> {
			case bus_can_depart(time + pair.first(bus), pair.second(bus)) {
				True -> check_departures(time, rest)
				False -> False
			}
		}
	}
}

fn bus_can_depart(time, bus) {
	utils.is_divisor_of(time, bus)
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
	// let min = 100_000_000_000_000
	let min = 756_261_495_958_000
	part2(min, pair.second(input))
}