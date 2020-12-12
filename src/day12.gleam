import utils
import gleam/bool
import gleam/function
import gleam/io
import gleam/list
import gleam/int
import gleam/result
import gleam/string
import gleam/pair

const sample1 = "data/12/sample1.txt"
const input = "data/12/input.txt"

pub type Ship{
	Ship(
		bearing: Int,
		x: Int,
		y: Int,
	)
}

pub type Waypoint{
	Waypoint(x: Int, y: Int)
}

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

fn part1(ins) {
	let initial = Ship(
		bearing: 90,
		x: 0,
		y: 0
	)

	list.fold(
		over: ins,
		from: initial,
		with: part1_step
	)
	|> io.debug
	|> manhattan_distance
}

fn part1_step(ins: Ins, ship: Ship) {
	// io.debug(ship)
	// io.debug(ins)
	case ins {
		N(val) -> Ship(..ship, y: ship.y + val)
		S(val) -> Ship(..ship, y: ship.y - val)
		E(val) -> Ship(..ship, x: ship.x + val)
		W(val) -> Ship(..ship, x: ship.x - val)
		L(val) -> bear_ship(ship, val * -1)
		R(val) -> bear_ship(ship, val)
		F(val) -> {
			case ship.bearing {
				0 -> part1_step(N(val), ship)
				90 -> part1_step(E(val), ship)
				180 -> part1_step(S(val), ship)
				270 -> part1_step(W(val), ship)
				_ -> ship
			}
		}
	}
}

fn part2(ins) {
	let ship = Ship(
		bearing: 90,
		x: 0,
		y: 0
	)

	let waypoint = Waypoint(
		x: 10,
		y: 1,
	)

	list.fold(
		over: ins,
		from: tuple(ship, waypoint),
		with: part2_step
	)
	|> io.debug
	|> pair.first
	|> manhattan_distance
}

fn part2_step(ins: Ins, t: tuple(Ship, Waypoint)) {
	// io.debug(t)
	// io.debug(ins)

	let tuple(ship, wp) = t

	case ins {
		N(val) ->
			tuple(ship, Waypoint(..wp, y: wp.y + val))
		S(val) ->
			tuple(ship, Waypoint(..wp, y: wp.y - val))
		E(val) ->
			tuple(ship, Waypoint(..wp, x: wp.x + val))
		W(val) ->
			tuple(ship, Waypoint(..wp, x: wp.x - val))
		L(val) ->
			tuple(
				ship,
				rotate_waypoint(wp, val * -1)
			)
		R(val) ->
			tuple(
				ship,
				rotate_waypoint(wp, val)
			)
		F(val) ->
			tuple(
				Ship(..ship,
					x: ship.x + wp.x * val,
					y: ship.y + wp.y * val
				),
				wp
			)
	}
}

fn rotate_waypoint(wp, val) {
	let tuple(x, y) = rotate_vector(wp.x, wp.y, val)
	Waypoint(x: x, y: y)
}

pub fn rotate_vector(x, y, degrees) {
	case bear(0, degrees) {
		90 -> tuple(y, x * -1)
		180 -> tuple(x * -1, y * -1)
		270 -> tuple(y * -1, x)
		_ -> tuple(x, y)
	}
}

fn bear_ship(ship: Ship, d: Int) {
	Ship(..ship, bearing: bear(ship.bearing, d))
}

pub fn bear(bearing: Int, degrees: Int) {
	utils.rem(bearing + degrees + 360, 360)
}

fn manhattan_distance(ship) {
	utils.abs(ship.x) + utils.abs(ship.y)
}

pub fn part1_sample1() {
	read_input(sample1)
	|> result.map(part1)
}

pub fn part1_main() {
	read_input(input)
	|> result.map(part1)
}

pub fn part2_sample() {
	read_input(sample1)
	|> result.map(part2)
}

pub fn part2_main() {
	read_input(input)
	|> result.map(part2)
}