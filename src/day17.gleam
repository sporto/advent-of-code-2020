import utils
import gleam/string
import gleam/io
import gleam/list
import gleam/result
import gleam/int
import gleam/map.{Map}

const sample1 = "data/17/sample1.txt"

fn read_input(file: String) -> Result(Matrix, String) {
	utils.get_input_lines(file, parse_line)
	|> result.map(make_matrix)
}

pub type Cell{
		On
		Off
	}

fn is_on(cell) {
	cell == On
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

pub fn part1_sample() -> Result(Int, String) {
	read_input(sample1)
	|> result.map(part1)
}

fn part1(matrix: Matrix) -> Int {

	// io.debug(count_active(matrix))

	matrix
	|> part1_mutate(0, _)
	// |> io.debug
	|> print_matrix
	|> count_active
}

const max_cycles = 1

fn part1_mutate(cycle: Int, matrix: Matrix) -> Matrix {
	case cycle > max_cycles {
		True -> matrix
		False -> {
			let next_matrix = matrix
				|> grow
				|> map.map_values(part1_mutate_cell(matrix))

			part1_mutate(cycle + 1, next_matrix)
		}
	}
}

fn part1_mutate_cell(matrix) {
	fn(point, cell) {
		let neighbors = get_neighbors(matrix, point)

		// io.debug(list.length(neighbors))

		let active_neighbors = neighbors
			|> list.filter(is_on)
			|> list.length

		case cell {
			On -> {
				case active_neighbors == 2 || active_neighbors == 3 {
					True -> On
					False -> Off
				}
			}
			Off -> {
				case active_neighbors == 3 {
					True -> On
					False -> Off
				}
			}
		}
	}
}

pub fn get_neighbors(matrix, point) {
	let x_range = list.range(point.x - 1, point.x + 2)
	let y_range = list.range(point.y - 1, point.y + 2)
	let z_range = list.range(point.z - 1, point.z + 2)

	// io.debug(x_range)
	// io.debug(y_range)

	x_range
	|> list.fold(
		from: [],
		with: fn(x, x_acc) {
			y_range
			|> list.fold(
				from: x_acc,
				with: fn(y, y_acc) {
					z_range
					|> list.fold(
						from: y_acc,
						with: fn(z, acc) {
							let this_point = Point(x, y, z)
							case this_point == point {
								True -> acc
								False -> {
									let value = map.get(matrix, this_point)
										|> result.unwrap(Off)

									[value, ..acc]
								}
							}
						}
					)
				}
			)
		}
	)
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

pub fn grow(matrix: Matrix) -> Matrix {
	let new_bounds = matrix
	|> get_matrix_bounds
	|> grow_bounds

	fill(new_bounds, matrix)
}

fn fill(bounds, matrix) {
	let x_range = list.range(bounds.min_x, bounds.max_x)
	let y_range = list.range(bounds.min_y, bounds.max_y)
	let z_range = list.range(bounds.min_z, bounds.max_z)

	x_range
	|> list.fold(
		from: matrix,
		with: fn(x, x_acc) {
			y_range
			|> list.fold(
				from: x_acc,
				with: fn(y, y_acc) {
					z_range
					|> list.fold(
						from: y_acc,
						with: fn(z, acc) {
							let point = Point(x, y, z)
							map.update(acc, point, fn(res) {
								case res {
									Ok(current) -> current
									Error(_) -> Off
								}
							})
						}
					)
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

fn count_active(matrix: Matrix) -> Int {
	matrix
	|> map.values
	|> list.filter(is_on)
	|> list.length
}

fn print_matrix(matrix) {
	let bounds = get_matrix_bounds(matrix)
	let x_range = list.range(bounds.min_x, bounds.max_x)
	let y_range = list.range(bounds.min_y, bounds.max_y)
	let z_range = list.range(bounds.min_z, bounds.max_z)

	z_range
	|> list.map(fn(z) {

		y_range
		|> list.map(fn(y) {

			x_range
			|> list.map(fn(x) {
				let point = Point(x, y, z)
				let cell = map.get(matrix, point) |> result.unwrap(Off)
				case cell {
					On -> "#"
					Off -> "."
				}
			})
			|> string.join("")
			|> io.debug

		})
		|> string.join("\n")

	})

	matrix
}