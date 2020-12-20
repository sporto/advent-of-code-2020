import utils
import gleam/list
import gleam/result
import gleam/int
import gleam/string
import gleam/set
import gleam/io
import gleam/pair
import gleam/map.{Map}

const sample = "data/20/sample.txt"
const input = "data/20/input.txt"

pub type TileLine = List(Bool)

pub type Tile{
	Tile(
		id: Int,
		lines: List(TileLine),
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

type Bounds{
	Bounds(
		min_x: Int,
		max_x: Int,
		min_y: Int,
		max_y: Int,
	)
}

type Corners{
	Corners(
		top_left: Tile,
		top_right: Tile,
		bottom_left: Tile,
		bottom_right: Tile,
	)
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
	FlipNone
	Flip
}

const directions = [ Top, Bottom, Left, Right ]
const rotations = [ R0, R90, R180, R270 ]
const flips = [ FlipNone, Flip ]

pub fn read(file: String) -> Result(List(Tile), String) {
	utils.read_file(file)
	|> utils.replace_error("Could not read file")
	|> result.then(parse_input)
	|> result.map(list.map(_, to_tile_info))
}

fn parse_input(file: String) -> Result(List(Tile), String) {
	file
	|> string.split("\n\n")
	|> list.map(parse_tile)
	|> result.all
}

fn parse_tile(input) -> Result(Tile, String) {
	let lines = input
	|> string.split("\n")

	case lines {
		[x, ..rest] -> {
			try id = parse_title(x)

			try tile_lines = rest
			|> list.map(parse_tile_line)
			|> result.all
			|> utils.replace_error("Could not parse tile lines")

			Ok(Tile(id: id, lines: tile_lines))
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

fn to_tile_info(tile: Tile) -> Tile {
	Tile(
		id: tile.id,
		left: left_hash(tile.lines),
		right: right_hash(tile.lines),
		top: top_hash(tile.lines),
		bottom: bottom_hash(tile.lines),
	)
}

pub fn left_hash(lines) {
	lines
	|> list.map(list.head)
	|> result.all
	|> result.unwrap([])
}

pub fn right_hash(lines) {
	lines
	|> list.map(list.reverse)
	|> left_hash
}

pub fn top_hash(lines) {
	lines
	|> list.head
	|> result.unwrap([])
}

pub fn bottom_hash(lines) {
	lines
	|> list.reverse
	|> top_hash
}

// Entry

pub fn part1_sample() {
	try tiles = read(sample)

	part1(tiles)
}

pub fn part1_main() {
	try tiles = read(input)

	part1(tiles)
}

fn part1(tiles: List(Tile)) -> Result(Int, String) {
	tiles
	|> list.map(fn(tile: Tile) {
		io.debug(tile.id)
		io.debug(tile.left)
		// io.debug(tile.bottom)
	})

	generate_edge_map(tiles)
	|> map.map_values(fn(k, v) { set.to_list(v) })
	|> io.debug

	Ok(0)

	// try grid = place_and_rotate(map.new(), tiles)

	// try corners = get_grid_corners(grid)

	// let corner_ids = [
	// 		corners.top_left,
	// 		corners.top_right,
	// 		corners.bottom_left,
	// 		corners.bottom_right
	// 	]
	// 	|> list.map(fn(tile: Tile) {
	// 		tile.id
	// 	})

	// let total = utils.multiply(corner_ids)

	// Ok(total)
}

fn generate_edge_map(tiles) {
	list.fold(
		over: tiles,
		from: map.new(),
		with: fn(tile, acc_tiles) {
			list.fold(
				over: rotations,
				from: acc_tiles,
				with: fn(rotation, acc_rotation) {
					list.fold(
						over: flips,
						from: acc_rotation,
						with: fn(flip, acc) {
							let transformed = tile
								|> flip_tile(flip)
								|> rotate_tile(rotation)

							let line = get_line(Top, transformed)
							let bin = utils.from_binary(line)

							map.update(
								in: acc,
								update: bin,
								with: fn(res) {
									case res {
										Error(_) -> [ tile.id ] |> set.from_list
										Ok(previous) -> set.insert(previous, tile.id)
									}
								}
							)
						}
					)
				}
			)
		}
	)
}

/////////

fn get_grid_bounds(grid) {
	let xs = grid |> map.keys |> list.map(get_x)
	let ys = grid |> map.keys |> list.map(get_y)

	// io.debug(grid)
	// io.debug(xs)
	// io.debug(ys)

	Bounds(
		min_x: utils.min(xs),
		max_x: utils.max(xs),
		min_y: utils.min(ys),
		max_y: utils.max(ys),
	)
}

fn get_grid_corners(grid: Grid) -> Result(Corners, String) {
	let bounds = get_grid_bounds(grid)

	try top_left = map
		.get(
			grid,
			Coor(bounds.min_x, bounds.min_y)
		)
		|> utils.replace_error("No top left")

	try top_right = map.get(
			grid,
			Coor(bounds.max_x, bounds.min_y)
		)
		|> utils.replace_error("No top right")

	try bottom_left = map.get(
			grid,
			Coor(bounds.min_x, bounds.max_y)
		)
		|> utils.replace_error("No bottom left")

	try bottom_right = map.get(
			grid,
			Coor(bounds.max_x, bounds.max_y)
		)
		|> utils.replace_error("No bottom right")

	let corners = Corners(
		top_left: top_left,
		top_right: top_right,
		bottom_left: bottom_left,
		bottom_right: bottom_right,
	)

	Ok(corners)
}

fn place_and_rotate(grid: Grid, tiles: List(Tile)) -> Result(Grid, String) {
	tiles
	|> list.index_map(fn(ix, tile) {
		utils.rotate(tiles, ix)
	})
	|> list.find_map(fn(ts) {
		io.debug("Trying new sequence")
		case place(grid, ts, 0) {
			Error(e) -> Error(e)
			Ok(candidate) -> {
				io.debug("Got candidate")
				// Must be a rectangle
				check_is_rectange(candidate)
			}
 		}
	})
	|> utils.replace_error("Could not find combination")
}

fn check_is_rectange(grid: Grid) -> Result(Grid, String) {
	case get_grid_corners(grid) {
		Error(e) -> {
			io.debug("Not a rectangle")
			Error(e)
		}
		Ok(_) -> Ok(grid)
	}
}

fn place(
		grid grid: Grid,
		tiles tiles: List(Tile),
		failures failures: Int
	) -> Result(Grid, String) {

	let maybe_keep_going = case failures > list.length(tiles) {
		True -> Error("Too many failures")
		False -> Ok("Keep going")
	}

	try keep_going = maybe_keep_going

	case tiles {
		[] -> Ok(grid)
		[tile, ..remaining_tiles] -> {
			// If the grid is empty, just put the first tile in 0,0
			case map.size(grid) == 0 {
				True -> {
					// io.debug("Placing tile in 0,0")
					// io.debug(tile.id)
					let next_grid = map.insert(grid, Coor(0,0), tile)
					place(next_grid, remaining_tiles, failures: 0)
				}
				False -> {
					// Try to place this tile
					// Otherwise place at the end and continue
					case try_place_tile(grid, tile) {
						Ok(next_grid) -> {
							// io.debug(remaining_tiles |> list.length)
							place(next_grid, remaining_tiles, failures: 0)
						}
						Error(_) -> {
							// io.debug("Could not place tile")
							// io.debug(tile.id)
							place(
								grid,
								list.append(remaining_tiles, [tile]),
								failures: failures + 1
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
			|> rotate_tile(rotation)
			|> flip_tile(flip)

			let reference_line = get_line(direction, reference_tile)
			let placement_line = get_placement_line(direction, tile)

			case reference_line == placement_line {
				True -> {
					// io.debug("    ")
					// io.debug("Tile was placed")
					// io.debug(tile_to_place.id)
					// io.debug(placement_coor)
					// io.debug(direction)
					// io.debug(rotation)
					// io.debug(flip)
					Ok(map.insert(grid, placement_coor, tile))
				}
				False -> Error("No match")
			}
		}
	}
}

fn flip_tile(tile: Tile, flip: Flip) {
	case flip {
		FlipNone -> tile
		Flip ->
			Tile(
				id: tile.id,
				lines: tile.lines |> list.reverse,
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
		lines: rotate_lines_90(tile.lines)
	)
}

fn rotate_lines_90(lines) {
	case lines {
		[] -> []
		[[], ..rest] -> []
		_ -> {
			// last needs to be the last element in the list
			// init needs to be all elements except the last
			[
			list.map(lines, last) , ..(rotate_lines_90(list.map(lines, init)))
			]
		}
	}
}

fn get_line(direction: Direction, tile: Tile) -> List(Bool) {
	case direction {
		Top -> tile.top
		Bottom -> tile.bottom
		Left -> tile.left
		Right -> tile.right
	}
}

fn get_placement_line(direction, tile) {
	get_line(direction |> opposite_direction, tile)
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
		Top -> Coor(x, y + 1)
		Bottom -> Coor(x, y - 1)
		Left -> Coor(x - 1, y)
		Right -> Coor(x + 1, y)
	}
}