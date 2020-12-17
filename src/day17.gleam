import utils
import gleam/string
import gleam/io
import gleam/list
import gleam/result
import gleam/int
import gleam/map.{Map}

const sample1 = "data/17/sample1.txt"

fn read_input(file) {
	utils.get_input_lines(file, parse_line)
	|> result.map(make_matrix)
	|> result.map(part1)
}

pub type Cell{
		On
		Off
	}

// Parse input

fn parse_line(line) -> Result(List(Cell), String) {
	line
	|> string.to_graphemes
	|> list.map(parse_char)
	|> Ok
}

fn parse_char(c) {
	case c {
		"#" -> On
		_ -> Off
	}
}

pub type Point{
	Point(x: Int, y: Int, z: Int)
}

pub type Matrix = Map(Point, Cell)

// fn get_x(point) {
// 	point.x
// }

// fn get_y(point) {
// 	point.y
// }

// fn get_z(point) {
// 	point.z
// }

fn make_matrix(input: List(List(Cell))) -> Matrix {
	input
	|> add_index
	|> list.fold(
		from: map.new(),
		with: fn(row_tuple, acc) {
			let tuple(row_ix, row) = row_tuple
			row
			|> add_index
			|> list.fold(
				from: acc,
				with: fn(col_tuple, acc_) {
					let tuple(col_ix, cell) = col_tuple
					let point = Point(col_ix, row_ix, 0)
					map.insert(acc_, point, cell)
				}
			)
		}
	)
}

fn add_index(l: List(a)) -> List(tuple(Int, a)) {
	list.index_map(l, fn(ix, a) { tuple(ix, a) })
}

// Entry

pub fn part1_sample() {
	read_input(sample1)
	|> result.map(part1)
}

fn part1(matrix) {
	matrix
	|> part1_mutate(0, _)
	|> io.debug
}

fn part1_mutate(cycle, matrix) {
	matrix
	|> grow
}

type Bounds{
	Bounds(
		min_x: Int,
		max_x: Int,
		min_y: Int,
		max_y: Int,
		min_z: Int,
		max_z: Int,
	)
}

fn grow(matrix: Matrix) -> Matrix {
	let new_bounds = matrix
	|> get_matrix_bounds
	|> grow_bounds

	// io.debug(new_bounds)
	[
		fill_x_min(new_bounds, _),
		// fill_y(new_bounds),
		// fill_z(new_bounds)
	]
	|> list.fold(
		from: matrix,
		with: fn(fun, matrix_acc) {
			fun(matrix_acc)
		}
	)
}

fn fill_x_min(bounds, matrix) {
	let y_range = list.range(bounds.min_y, bounds.max_y)
	let z_range = list.range(bounds.min_z, bounds.max_z)
	y_range
	|> list.fold(
		from: matrix,
		with: fn(y, matrix_acc) {
			z_range
			|> list.fold(
				from: matrix_acc,
				with: fn(z, matrix_acc_2) {
					let point = Point(x: bounds.min_x, y: y, z: z)
					map.insert(matrix_acc_2, point, Off)
				}
			)
		}
	)
}

fn get_matrix_bounds(matrix: Matrix) -> Bounds {
	let keys = matrix |> map.keys
	let initial_bounds = Bounds(
		min_x: 0,
		max_x: 0,
		min_y: 0,
		max_y: 0,
		min_z: 0,
		max_z: 0,
	)

	keys
	|> list.fold(
		from: initial_bounds,
		with: fn(key: Point, bounds_acc: Bounds) {
			Bounds(
				min_x: int.min(bounds_acc.min_x, key.x),
				max_x: int.max(bounds_acc.max_x, key.x),
				min_y: int.min(bounds_acc.min_y, key.y),
				max_y: int.max(bounds_acc.max_y, key.y),
				min_z: int.min(bounds_acc.min_z, key.z),
				max_z: int.max(bounds_acc.max_z, key.z),
			)
		}
	)
}

fn grow_bounds(bounds: Bounds) -> Bounds {
	Bounds(
		min_x: bounds.min_x - 1,
		max_x: bounds.max_x + 1,
		min_y: bounds.min_y - 1,
		max_y: bounds.max_y + 1,
		min_z: bounds.min_z - 1,
		max_z: bounds.max_z + 1,
	)
}