import utils
import gleam/list
import gleam/result
import gleam/int
import gleam/string
import gleam/io
import gleam/pair
import gleam/map.{Map}

const sample = "data/20/sample.txt"

pub type TileLine = List(Bool)

pub type TileRaw{
	TileRaw(
		id: Int,
		lines: List(TileLine),
	)
}

pub type Tile{
	Tile(
		id: Int,
		left: List(Bool),
		right: List(Bool),
		top: List(Bool),
		bottom: List(Bool),
	)
}

pub type Coor{
	Coor(x: Int, y: Int)
}

fn get_x(coor: Coor) {
	coor.x
}

fn get_y(coor: Coor) {
	coor.y
}

pub type Grid = Map(Coor, Tile)

pub type Direction{
	Top
	Bottom
	Left
	Right
}

pub type Rotation{
	R0
	R90
	R180
	R270
}

pub type Flip{
	FlipH
	FlipV
}

const directions = [ Top, Bottom, Left, Right ]
const rotations = [ R0, R90, R180, R270 ]
const flips = [ FlipH, FlipV ]

pub fn read(file: String) -> Result(List(Tile), String) {
	utils.read_file(file)
	|> utils.replace_error("Could not read file")
	|> result.then(parse_input)
	|> result.map(list.map(_, to_tile_info))
}

fn parse_input(file: String) -> Result(List(TileRaw), String) {
	file
	|> string.split("\n\n")
	|> list.map(parse_tile)
	|> result.all
}

fn parse_tile(input) -> Result(TileRaw, String) {
	let lines = input
	|> string.split("\n")

	case lines {
		[x, ..rest] -> {
			try id = parse_title(x)

			try tile_lines = rest
			|> list.map(parse_tile_line)
			|> result.all
			|> utils.replace_error("Could not parse tile lines")

			Ok(TileRaw(id: id, lines: tile_lines))
		}
		_ -> Error("Invalid input")
	}
}

fn parse_title(input) {
	input
	|> string.drop_left(5)
	|> string.drop_right(1)
	|> int.parse
	|> utils.replace_error(input)
}

fn parse_tile_line(input) {
	input
	|> string.to_graphemes
	|> list.map(parse_char)
	|> result.all
	|> utils.replace_error(input)
}

fn parse_char(input) {
	case input {
		"." -> Ok(False)
		"#" -> Ok(True)
		_ -> Error(input)
	}
}

fn to_tile_info(tile: TileRaw) -> Tile {
	Tile(
		id: tile.id,
		left: left_hash(tile.lines),
		right: right_hash(tile.lines),
		top: top_hash(tile.lines),
		bottom: bottom_hash(tile.lines),
	)
}

fn left_hash(lines) {
	lines
	|> list.map(list.head)
	|> result.all
	|> result.unwrap([])
}

fn right_hash(lines) {
	lines
	|> list.map(list.reverse)
	|> left_hash
}

fn top_hash(lines) {
	lines
	|> list.head
	|> result.unwrap([])
}

fn bottom_hash(lines) {
	lines
	|> list.reverse
	|> top_hash
}

// Entry

pub fn part1_sample() {
	try tiles = read(sample)

	let grid = part1(tiles)
	|> map.map_values(fn(k, tile: Tile) {
		tile.id
	})
	|> io.debug

	let xs = grid |> map.keys |> list.map(get_x)
	let ys = grid |> map.keys |> list.map(get_y)
	let min_x = utils.min(xs)
	let max_x = utils.max(xs)
	let min_y = utils.min(ys)
	let max_y = utils.max(ys)

	// io.debug(max_x)

	try top_left = map.get(grid, Coor(min_x, min_y)) |> utils.replace_error("No top left")
	try top_right = map.get(grid, Coor(max_x, min_y)) |> utils.replace_error("No top right")
	try bottom_left = map.get(grid, Coor(min_x, max_y)) |> utils.replace_error("No bottom left")
	try bottom_right = map.get(grid, Coor(max_x, max_y)) |> utils.replace_error("No bottom right")

	let total = top_left * top_right * bottom_left * bottom_right

	Ok(total)
}

fn part1(tiles: List(Tile)) -> Grid {
	// io.debug(tiles |> list.length)
	place(map.new(), tiles)
}

fn place(grid: Grid, tiles: List(Tile)) -> Grid {
	case tiles {
		[] -> grid
		[tile, ..remaining_tiles] -> {
			// If the grid is empty, just put the first tile in 0,0
			case map.size(grid) == 0 {
				True -> {
					// io.debug("Placing tile in 0,0")
					// io.debug(tile.id)
					let next_grid = map.insert(grid, Coor(0,0), tile)
					place(next_grid, remaining_tiles)
				}
				False -> {
					// Try to place this tile
					// Otherwise place at the end and continue
					case try_place_tile(grid, tile) {
						Ok(next_grid) -> {
							// io.debug("Tile was placed")
							// io.debug(tile.id)
							// io.debug(remaining_tiles |> list.length)
							place(next_grid, remaining_tiles)
						}
						Error(_) -> {
							// io.debug("Could not place tile")
							// io.debug(tile.id)
							place(
								grid,
								list.append(remaining_tiles, [tile])
							)
						}
					}
				}
			}
		}
	}
}

fn try_place_tile(grid: Grid, tile_to_place: Tile) -> Result(Grid, String) {
	// For each existing tile in the grid, try to place this one next
	let tiles = map.to_list(grid)

	list.find_map(
		in: tiles,
		with: fn(tile_tupple) {
			let tuple(reference_coor, reference_tile) = tile_tupple

			list.find_map(
				in: directions,
				with: fn(direction) {

					list.find_map(
						in: rotations,
						with: fn(rotation) {
							list.find_map(
								in: flips,
								with: fn(flip) {
									try_place_tile_relative(
										grid: grid,
										tile_to_place: tile_to_place,
										reference_tile: reference_tile,
										reference_coor: reference_coor,
										direction: direction,
										rotation: rotation,
										flip: flip
									)
								}
							)
						}
					)
					|>utils.replace_error("Could not find rotation")

				}
			)
			|>utils.replace_error("Could not find direction")

		}
	)
	|>utils.replace_error("Could not find reference tile")

}

fn try_place_tile_relative(
	grid grid: Grid,
	tile_to_place tile_to_place: Tile,
	reference_tile reference_tile: Tile,
	reference_coor reference_coor: Coor,
	direction direction: Direction,
	rotation rotation: Rotation,
	flip flip: Flip
	) -> Result(Grid, String) {

	let placement_coor = relative_coor(direction, reference_coor)

	case map.has_key(grid, placement_coor) {
		True -> Error("Coor already taken")
		False -> {
			let tile = tile_to_place
			|> flip_tile(flip)
			|> rotate_tile(rotation)

			let reference_line = get_reference_line(direction, reference_tile)
			let placement_line = get_placement_line(direction, tile)

			case reference_line == placement_line {
				True -> {
					Ok(map.insert(grid, placement_coor, tile))
				}
				False -> Error("No match")
			}
		}
	}
}

fn flip_tile(tile: Tile, flip: Flip) {
	case flip {
		FlipH ->
			Tile(
				id: tile.id,
				left: tile.right,
				right: tile.left,
				top: tile.top |> list.reverse,
				bottom: tile.bottom |> list.reverse,
			)
		FlipV ->
			Tile(
				id: tile.id,
				left: tile.left |> list.reverse,
				right: tile.right |> list.reverse,
				top: tile.bottom,
				bottom: tile.top,
			)
	}
}

fn rotate_tile(tile: Tile, rotation: Rotation) {
	case rotation {
		R0 -> tile
		R90 -> tile |> rotate_90
		R180 -> tile |> rotate_90 |> rotate_90
		R270 -> tile |> rotate_90 |> rotate_90 |> rotate_90
	}
}

fn rotate_90(tile) {
	Tile(
		id: tile.id,
		right: tile.top,
		bottom: tile.right,
		left: tile.bottom,
		top: tile.left,
	)
}

fn get_reference_line(direction: Direction, tile: Tile) -> List(Bool) {
	case direction {
		Top -> tile.top
		Bottom -> tile.bottom
		Left -> tile.left
		Right -> tile.right
	}
}

fn get_placement_line(direction, tile) {
	get_reference_line(direction |> opposite_direction, tile)
}

fn opposite_direction(direction) {
	case direction {
		Top -> Bottom
		Bottom -> Top
		Left -> Right
		Right -> Left
	}
}

fn relative_coor(direction: Direction, coor: Coor) {
	let Coor(x,y) = coor

	case direction {
		Top -> Coor(x, y - 1)
		Bottom -> Coor(x, y + 1)
		Left -> Coor(x - 1, y)
		Right -> Coor(x + 1, y)
	}
}