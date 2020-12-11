import utils
import gleam/bool
import gleam/function
import gleam/io
import gleam/list
import gleam/result
import gleam/string

const sample1 = "data/11/sample1.txt"

pub type Place{
	Floor
	Empty
	Taken
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

fn parse_grid(lines) -> Result(List(List(Place)), Nil) {
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

fn mutate_cell(grid grid, row_ix row_ix, col_ix col_ix, cell cell) {
	let adjacent = get_adjacent(grid, row_ix, col_ix)
	let occupied_adjacent = adjacent
		|> list.filter(is_taken)
		|> list.length

	case cell {
		Empty -> case occupied_adjacent == 0 {
			True -> Taken
			False -> Empty
		}
		Taken -> case occupied_adjacent >=  4 {
			True -> Empty
			False -> Taken
		}
		Floor -> Floor
	}
}

fn get_adjacent(grid grid, row_ix row_ix, col_ix col_ix) {
	[
		get(grid, row_ix - 1, col_ix - 1),
		get(grid, row_ix - 1, col_ix),
		get(grid, row_ix - 1, col_ix + 1),
		get(grid, row_ix, col_ix - 1),
		get(grid, row_ix, col_ix + 1),
		get(grid, row_ix + 1, col_ix - 1),
		get(grid, row_ix + 1, col_ix),
		get(grid, row_ix + 1, col_ix + 1),
	]
	|> list.filter_map(function.identity)
}

fn get(grid grid, row_ix row_ix, col_ix col_ix) -> Result(Place, Nil) {
	try row = list.at(grid, row_ix)
	list.at(row, col_ix)
}

fn mutate(grid) {
	list.index_map(grid, fn(row_ix, row) {
		list.index_map(row, fn(col_ix, cell) {
			mutate_cell(
				grid: grid,
				row_ix: row_ix,
				col_ix: col_ix,
				cell: cell
			)
		})
	})
}

fn mutate_until_stable(grid, round) {
	let mutated = mutate(grid)

	// io.debug(round + 1)
	// io.debug(mutated |> to_printable)

	case mutated == grid {
		True -> grid
		False -> mutate_until_stable(mutated, round + 1)
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
	|> mutate_until_stable(0)
	|> count_taken_places
}

pub fn part1_sample1() {
	read_input(sample1)
	|> result.map(part1)
}