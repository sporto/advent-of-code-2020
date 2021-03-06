import utils
import gleam/list
import gleam/result
import gleam/int
import gleam/string
import gleam/set
import gleam/io
import gleam/bool
import gleam/pair
import gleam/function
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

// Entry

pub fn part1_sample() {
	try tiles = read(sample)

	part1(tiles)
}

pub fn part1_main() {
	try tiles = read(input)

	part1(tiles)
}

pub fn part2_sample() {
	try tiles = read(sample)

	part2(tiles)
}

pub fn part2_main() {
	try tiles = read(input)

	part2(tiles)
}


fn part1(tiles: List(Tile)) -> Result(Int, String) {
	// generate_edge_map(tiles)
	// |> map.map_values(fn(k, v) { set.to_list(v) })
	// |> io.debug

	// Ok(0)

	try grid = place(map.new(), tiles, 0)

	try corners = get_grid_corners(grid)

	let corner_ids = [
			corners.top_left,
			corners.top_right,
			corners.bottom_left,
			corners.bottom_right
		]
		|> list.map(fn(tile: Tile) {
			tile.id
		})

	let total = utils.multiply(corner_ids)

	Ok(total)
}

fn part2(tiles) {
	try grid = place(map.new(), tiles, 0)

	let stiched = grid
	|> map.map_values(fn(k,v) { remove_borders(v) })
	|> stitch

	// print_matrix(stiched) |> io.debug

	stiched
	|> find_sea_monsters
	|> utils.replace_error("Nothing found")
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
							// let bin = utils.from_binary(line)

							map.update(
								in: acc,
								update: line,
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
	Tile(
		..tile,
		lines: flip_lines(tile.lines, flip)
	)
}

fn flip_lines(lines, flip) {
	case flip {
		FlipNone -> lines
		Flip -> lines |> list.reverse
	}
}

fn rotate_tile(tile: Tile, rotation: Rotation) {
	Tile(
		..tile,
		lines: rotate_lines(tile.lines, rotation)
	)
}

fn rotate_lines(lines, rotation) {
	case rotation {
		R0 -> lines
		R90 -> lines |> rotate_90
		R180 -> lines |> rotate_90 |> rotate_90
		R270 -> lines |> rotate_90 |> rotate_90 |> rotate_90
	}
}

fn rotate_90(lines) {
	utils.rotate_matrix_90(lines)
}

fn get_line(direction: Direction, tile: Tile) -> List(Bool) {
	case direction {
		Top -> get_top_line(tile.lines)
		Bottom -> get_bottom_line(tile.lines)
		Left -> get_left_line(tile.lines)
		Right -> get_rigth_line(tile.lines)
	}
}

pub fn get_left_line(lines) {
	lines
	|> list.map(list.head)
	|> result.all
	|> result.unwrap([])
}

pub fn get_rigth_line(lines) {
	lines
	|> list.map(list.reverse)
	|> get_left_line
}

pub fn get_top_line(lines) {
	lines
	|> list.head
	|> result.unwrap([])
}

pub fn get_bottom_line(lines) {
	lines
	|> list.reverse
	|> get_top_line
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

fn remove_borders(tile: Tile) -> Tile {
	Tile(..tile, lines: remove_matrix_borders(tile.lines))
}

pub fn remove_matrix_borders(lines: List(List(a))) -> List(List(a)) {
	lines
	|> list.map(list.drop(_, 1))
	|> list.map(list.reverse)
	|> list.map(list.drop(_, 1))
	|> list.map(list.reverse)
	|> list.drop(1)
	|> list.reverse
	|> list.drop(1)
	|> list.reverse
}

fn stitch(grid: Grid) -> Map(Coor, Bool) {
	// let bounds = get_grid_bounds(grid)

	// let x_range = list.range(bounds.min_x, bounds.max_x + 1)
	// let y_range = list.range(bounds.min_y, bounds.max_y + 1)

	map.fold(
		over: grid,
		from: map.new(),
		with: fn(tile_coor: Coor, tile: Tile, acc1) {
			let tile_map = lines_to_map(tile.lines)
			let size = list.length(tile.lines)
			map.fold(
				over: tile_map,
				from: acc1,
				with: fn(cell_coor: Coor, cell, acc) {
					let coor = Coor(
						tile_coor.x * size + cell_coor.x,
						tile_coor.y * size + cell_coor.y
					)
					map.insert(acc, coor, cell)
				}
			)
		}
	)
}

pub fn lines_to_map(lines: List(List(a))) -> Map(Coor, a) {
	lines
	|> utils.index_fold(
		from: map.new(),
		with: fn(row_ix, row, acc_row) {
			row
			|> utils.index_fold(
				from: acc_row,
				with: fn(col_ix, cell, acc) {
					let coor = Coor(col_ix, row_ix * -1)
					map.insert(acc, coor, cell)
				}
			)
		}
	)
}

fn print_matrix(grid: Map(Coor, Bool)) {

	let bounds = get_grid_bounds(grid)
	let x_range = list.range(bounds.min_x, bounds.max_x + 1)
	let y_range = list.range(bounds.min_y, bounds.max_y + 1)

	list.map(y_range, fn(y) {
		list.map(x_range, fn(x) {
			let coor = Coor(x, y)
			map.get(grid, coor)
			|> result.unwrap(False)
			|> cell_to_string
		})
		|> string.join("")
	})
	|> string.join("\n")
}

fn cell_to_string(cell: Bool) {
	case cell {
		True -> "#"
		False -> "."
	}
}

fn find_sea_monsters(grid: Map(Coor, Bool)) -> Result(Int, Nil) {
	let mask = parse_mask()
	let rows = grid_to_rows(grid)

	// need to rotate and flip
	list.find_map(
		rotations,
		fn(rotation) {
			list.find_map(
				flips,
				fn(flip) {
					find_sea_monsters_for_transform(rows, mask, rotation, flip)
				}
			)
		}
	)
}

fn find_sea_monsters_for_transform(rows, mask, rotation, flip) {
	let new_rows = rows
	|> flip_lines(flip)
	|> rotate_lines(rotation)

	find_sea_monsters_in_matrix(new_rows, mask)
}

fn find_sea_monsters_in_matrix(rows: List(List(Bool)), mask) -> Result(Int, Nil) {
	let count = list.index_map(rows, fn(row_ix, row: List(Bool)) {
		list.index_map(row, fn(col_ix, _) {
			find_sea_monsters_from(rows, mask, col_ix, row_ix)
		})
	})
	|> list.flatten
	|> list.filter_map(function.identity)
	|> utils.sum

	case count > 0 {
		True -> {
			let true_cells = count_true_cells(rows)
			let cells_in_seamonsters = count_true_cells(mask) * count
			Ok(true_cells - cells_in_seamonsters)
		}
		False -> Error(Nil)
	}
}

fn grid_to_rows(grid: Map(Coor, Bool)) -> List(List(Bool)) {
	let bounds = get_grid_bounds(grid)
	let x_range = list.range(bounds.min_x, bounds.max_x + 1)
	let y_range = list.range(bounds.min_y, bounds.max_y + 1)

	list.map(y_range, fn(y) {
		list.map(x_range, fn(x) {
			let coor = Coor(x, y)
			map.get(grid, coor)
			|> result.unwrap(False)
		})
	})
}

const sea_monster_mask = [
	"                  # ",
	"#    ##    ##    ###",
	" #  #  #  #  #  #   ",
]

fn parse_mask() {
	sea_monster_mask
	|> list.map(parse_mask_line)
}

fn parse_mask_line(line) {
	line
	|> string.to_graphemes
	|> list.map(parse_mask_char)
}

fn parse_mask_char(c) {
	case c {
		"#" -> True
		_ -> False
	}
}

fn find_sea_monsters_from(rows: List(List(Bool)), mask: List(List(Bool)), col_ix: Int, row_ix: Int) -> Result(Int, Nil) {
	try area = get_area(rows, mask, col_ix, row_ix)

	// let discard = case row_ix == 2 {
	// 	True -> {
	// 		case col_ix == 2 {
	// 			True -> io.debug(area)
	// 			False ->[]
	// 		}
	// 	}
	// 	False -> []
	// }

	let res = apply_mask(area, mask)
	|> list.all(list.all(_, fn(cell) { cell == True }))

	case res {
		True -> Ok(1)
		False -> Error(Nil)
	}
}

fn get_area(rows, mask, col_ix, row_ix) {
	let mask_len = mask |> list.head |> result.unwrap([]) |> list.length

	let area = rows
	|> list.drop(row_ix)
	|> list.take(3)
	|> list.map(fn(row) {
		row
		|> list.drop(col_ix)
		|> list.take(mask_len)
	})

	let has_3_rows = area |> list.length == 3
	let has_x_len = area |> list.head |> result.unwrap([]) |> list.length == mask_len

	case has_3_rows, has_x_len {
		True, True -> Ok(area)
		_, _ -> Error(Nil)
	}
}

fn apply_mask(rows: List(List(Bool)), mask: List(List(Bool))) -> List(List(Bool)) {
	list.zip(rows, mask)
	|> list.map(fn(row_tuple) {
		let tuple(row, row_mask) = row_tuple

		list.zip(row, row_mask)
		|> list.map(fn(cell_tuple) {
			let tuple(cell, cell_mask) = cell_tuple
			case cell_mask {
				False -> True
				True -> {
					case cell {
						True -> True
						False -> False
					}
				}
			}
		})
	})
}

fn count_true_cells(rows: List(List(Bool))) -> Int {
	list.map(rows, fn(row) {
		list.map(row, bool.to_int)
	})
	|> list.flatten
	|> utils.sum
}