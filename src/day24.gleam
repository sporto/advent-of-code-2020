import gleam/string
import gleam/io
import gleam/result
import gleam/list
import gleam/map.{Map}
import utils

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

type Acc{
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

	let grid = follow_instructions(instructions, initial)
	|> io.debug

	Ok(0)
}

fn follow_instructions(instructions: List(List(Dir)), acc: Acc) -> Acc {
	instructions
	|> list.fold(
		from: acc,
		with: fn(line, acc: Acc) {
			let next_coor  = walk(acc.coor, line)
			let next_grid = flip_tile(next_coor, acc.grid)
			Acc(
				next_coor,
				next_grid
			)
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
				case current {
					White -> Black
					Black -> White
				}
			}
		}
	})
}