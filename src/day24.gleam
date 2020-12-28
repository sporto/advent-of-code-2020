import gleam/string
import gleam/io
import gleam/result
import gleam/list
import gleam/int
import gleam/map.{Map}
import utils

pub const sample = "data/24/sample.txt"
pub const input = "data/24/input.txt"

pub type Dir{
	E
	SE
	SW
	W
	NW
	NE
}

pub type Coor{
	Coor(x: Int, y: Int)
}

pub type Color{
	White
	Black
}

pub type Grid = Map(Coor, Color)

fn is_black(col: Color) {
	col == Black
}

fn read(file: String) {
	utils.get_input_lines(file, parse_line)
}

pub fn parse_line(line: String) -> Result(List(Dir), String) {
	line
	|> string.to_graphemes
	|> string.join(",")
	|> string.replace("s,e","se")
	|> string.replace("s,w","sw")
	|> string.replace("n,e","ne")
	|> string.replace("n,w","nw")
	|> string.split(",")
	|> list.map(parse_char)
	|> result.all
	|> utils.replace_error("Could not parse")
}

fn parse_char(c: String) {
	case c {
		"e" -> Ok(E)
		"w" -> Ok(W)
		"nw" -> Ok(NW)
		"ne" -> Ok(NE)
		"sw" -> Ok(SW)
		"se" -> Ok(SE)
		_ -> Error(Nil)
	}
}

pub type Acc{
	Acc(
		coor: Coor,
		grid: Map(Coor, Color)
	)
}

pub fn part1(file) {
	try instructions = read(file)

	let initial = Acc(
		Coor(0,0),
		map.new()
	)

	let acc = follow_instructions(instructions, initial)

	let blacks = count_blacks(acc.grid)

	Ok(blacks)
}

//  day24:part2_sample().
pub fn part2_sample() {
	part2(sample)
}

pub fn part2(file) {
	try instructions = read(file)

	let initial = Acc(
		Coor(0,0),
		map.new()
	)

	let acc = follow_instructions(instructions, initial)

	let final = acc.grid
	|> transform(0)

	let blacks = count_blacks(final)

	Ok(blacks)
}

fn count_blacks(grid) {
	grid
	|> map.values
	|> list.filter(is_black)
	|> list.length
}

pub fn follow_instructions(
		instructions: List(List(Dir)),
		acc: Acc
	) -> Acc {

	// reference tile doesn't change

	instructions
	|> list.fold(
		from: acc,
		with: fn(line, acc: Acc) {
			let coor  = walk(acc.coor, line)
			let next_grid = flip_tile(coor, acc.grid)

			Acc(..acc, grid: next_grid)
		}
	)
}

pub fn walk(coor: Coor, steps: List(Dir)) -> Coor {
	steps
	|> list.fold(
		from: coor,
		with: move,
	)
}

pub fn move(dir: Dir, coor: Coor) -> Coor {
	case dir {
		E -> Coor(coor.x + 1, coor.y)
		W -> Coor(coor.x - 1, coor.y)
		NW -> Coor(coor.x, coor.y - 1)
		NE -> Coor(coor.x + 1, coor.y - 1)
		SW -> Coor(coor.x - 1, coor.y + 1)
		SE -> Coor(coor.x, coor.y + 1)
	}
}

fn flip_tile(coor: Coor, grid) {
	map.update(grid, coor, fn(res) {
		case res {
			Error(_) -> Black
			Ok(current)  -> {
				flip(current)
			}
		}
	})
}

const max_days = 1

fn transform(grid: Grid, day: Int) {
	print_day(day)
	print_blacks(grid)
	// io.debug(grid)

	case day >= max_days {
		True -> grid
		False -> {
			let next_grid = grid
				|> grow
				|> transform_grid

			transform(next_grid, day + 1)
		}
	}
}

fn transform_grid(grid: Grid) -> Grid {
	grid
	|> map.map_values(fn(coor: Coor, tile: Color) {
		let adjacents = get_adjacents(grid, coor)

		let blacks = adjacents
			|> list.filter(is_black)
			|> list.length

		transform_tile(tile, blacks)
	})
}

pub fn transform_tile(tile, black_count: Int) {
	case tile {
		Black -> {
			case black_count {
				1 | 2 -> tile
				_ -> flip(tile)
			}
		}
		White -> {
			case black_count {
				2 -> flip(tile)
				_ -> tile
			}
		}
	}
}

fn flip(tile) {
	case tile {
		Black -> White
		White -> Black
	}
}

pub fn grow(grid: Grid) -> Grid {
	// For each tile, make sure there is an adjacent
	map.fold(
		over: grid,
		from: grid,
		with: fn(coor, tile, acc1) {
			let adjacents = get_adjacent_coors(coor)
			list.fold(
				over: adjacents,
				from: acc1,
				with: fn(adj_coor, acc) {
					map.update(acc, adj_coor, fn(res) {
						case res {
							Error(_) -> Black
							Ok(current) -> current
						}
					})
				}
			)
		}
	)
}

pub fn get_adjacents(grid: Grid, coor: Coor) -> List(Color) {
	get_adjacent_coors(coor)
	|> list.map(get_tile(grid, _))
}

fn get_adjacent_coors(coor: Coor) -> List(Coor) {
	[
		move(E, coor),
		move(W, coor),
		move(NW, coor),
		move(NE, coor),
		move(SW, coor),
		move(SE, coor),
	]
}

fn get_tile(grid: Grid, coor: Coor) -> Color {
	map.get(grid, coor)
	|> result.unwrap(Black)
}

fn print_day(day) {
	[
		"Day ",
		int.to_string(day)
	] |> print_message
}

fn print_blacks(grid) {
	let count = count_blacks(grid)

	[
		"Blacks ",
		int.to_string(count)
	] |> print_message
}

fn print_message(message) {
	message |> string.join("") |> io.debug
}