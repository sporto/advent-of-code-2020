import gleam/pair
import gleam/string
import gleam/int
import gleam/list
import gleam/result
import gleam/io
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
	let buses = parse_buses(pair.second(t))
	let tuple(bus, bus_time) = find_bus(initial_time, buses)
	bus * {bus_time - initial_time}
}

fn parse_buses(input: String) -> List(Int) {
	input
	|> string.split(",")
	|> list.filter_map(int.parse)
}

fn find_bus(time: Int, buses: List(Int)) {
	let maybe_bus = buses |> list.find(utils.is_divisor_of(time, _))

	// io.debug(time)
	// io.debug(maybe_bus)

	case maybe_bus {
		Ok(bus) -> tuple(bus, time)
		Error(_) -> find_bus(time + 1, buses)
	}
}

pub fn part1_sample() {
	part1(sample)
}

pub fn part1_main() {
	part1(input)
}