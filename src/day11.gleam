import utils
import gleam/bool
import gleam/function
import gleam/io
import gleam/list
import gleam/result
import gleam/string

const sample1 = "data/11/sample1.txt"
const input = "data/11/input.txt"

pub type Cell{
	Floor
	Empty
	Taken
}

type Grid = List(List(Cell))

type Coor{
	Coor(row: Int, col: Int)
}

fn is_taken(place) {
	place == Taken
}

fn parse_place(c) {
	case c {
		"." -> Ok(Floor)
		"#" -> Ok(Taken)
		"L" -> Ok(Empty)
		_ -> Error(Nil)
	}
}

fn serialize_cell(place) {
	case place {
		Floor -> "."
		Taken -> "#"
		Empty -> "L"
	}
}

fn parse_row(row) {
	row
	|> string.to_graphemes
	|> list.map(parse_place)
	|> result.all
}

fn parse_grid(lines) -> Result(Grid, Nil) {
	lines
	|> list.map(parse_row)
	|> result.all
}

fn read_input(file) {
	utils.read_file(file)
	|> result.nil_error
	|> result.map(utils.split_lines)
	|> result.then(parse_grid)
}

fn part1_mutate_cell(
		grid grid: Grid,
		coor coor: Coor,
		cell cell: Cell
	) {

	let adjacent = get_adjacent(grid, coor)
	let occupied_count = adjacent
		|> list.filter(is_taken)
		|> list.length

	case cell {
		Empty -> case occupied_count == 0 {
			True -> Taken
			False -> Empty
		}
		Taken -> case occupied_count >=  4 {
			True -> Empty
			False -> Taken
		}
		Floor -> Floor
	}
}

fn part2_mutate_cell(
		grid grid: Grid,
		coor: Coor,
		cell cell: Cell
	) {

	let visible_seats = get_visible_seats(grid, coor)
	let occupied_count = visible_seats
		|> list.filter(is_taken)
		|> list.length

	case cell {
		Empty -> case occupied_count == 0 {
			True -> Taken
			False -> Empty
		}
		Taken -> case occupied_count >=  5 {
			True -> Empty
			False -> Taken
		}
		Floor -> Floor
	}
}

fn get_adjacent(grid grid, coor) {
	[
		get(grid, move_coor(coor, -1, -1) ),
		get(grid, move_coor(coor, -1, 0) ),
		get(grid, move_coor(coor, -1, 1) ),
		get(grid, move_coor(coor, 0, -1) ),
		get(grid, move_coor(coor, 0, 1) ),
		get(grid, move_coor(coor, 1, -1) ),
		get(grid, move_coor(coor, 1, 0) ),
		get(grid, move_coor(coor, 1, 1) ),
	]
	|> list.filter_map(function.identity)
}

fn get_visible_seats(grid grid: Grid, coor: Coor) {
	[
		search_visible(grid, coor, -1, -1),
		search_visible(grid, coor, -1, 0),
		search_visible(grid, coor, -1, 1),
		search_visible(grid, coor, 0, -1),
		search_visible(grid, coor, 0, 1),
		search_visible(grid, coor, 1, -1),
		search_visible(grid, coor, 1, 0),
		search_visible(grid, coor, 1, 1),
	]
	|> list.filter_map(function.identity)
}

fn search_visible(grid, from_coor, move_row, move_col) {
	let next_coor = move_coor(from_coor, move_row, move_col)

	case get(grid, next_coor) {
		Ok(cell) -> {
			case cell {
				Taken -> Ok(Taken)
				Empty -> Ok(Empty)
				Floor -> search_visible(grid, next_coor, move_row, move_col)
			}
		}
		Error(Nil) -> Error(Nil)
	}
}

fn move_coor(coor, move_row, move_col) {
	Coor(
		row: coor.row + move_row,
		col: coor.col + move_col,
	)
}

fn get(grid grid, coor) -> Result(Cell, Nil) {
	try row = list.at(grid, coor.row)
	list.at(row, coor.col)
}

fn mutate_grid(
		grid: Grid,
		mutate_cell: fn(Grid, Coor, Cell) -> Cell
	) -> Grid {

	list.index_map(grid, fn(row_ix, row) {
		list.index_map(row, fn(col_ix, cell) {
			let coor = Coor(row_ix, col_ix)
			mutate_cell(
				grid,
				coor,
				cell
			)
		})
	})
}

fn mutate_until_stable(
		grid: Grid,
		round: Int,
		mutate_cell: fn(Grid, Coor, Cell) -> Cell
	) {

	let mutated = mutate_grid(grid, mutate_cell)

	// io.debug(round + 1)
	// io.debug(mutated |> to_printable)

	case mutated == grid {
		True -> grid
		False -> mutate_until_stable(mutated, round + 1, mutate_cell)
	}
}

fn to_printable(grid) {
	grid
	|> list.map(list.map(_, serialize_cell))
	|> list.map(string.join(_, ""))
}

fn count_taken_places(grid) {
	grid
	|> list.map(
		list.map(_, is_taken)
	)
	|> list.flatten
	|> list.map(bool.to_int)
	|> utils.sum
}

fn part1(grid) {
	grid
	|> mutate_until_stable(0, part1_mutate_cell)
	|> count_taken_places
}

pub fn part1_sample1() {
	read_input(sample1)
	|> result.map(part1)
}

pub fn part1_main() {
	read_input(input)
	|> result.map(part1)
}

fn part2(grid) {
	grid
	|> mutate_until_stable(0, part2_mutate_cell)
	|> count_taken_places
}

pub fn part2_sample1() {
	read_input(sample1)
	|> result.map(part2)
}

pub fn part2_main() {
	read_input(input)
	|> result.map(part2)
}