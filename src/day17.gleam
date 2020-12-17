import utils
import gleam/string
import gleam/io
import gleam/list
import gleam/result
import gleam/int
import gleam/map.{Map}

const sample1 = "data/17/sample1.txt"
const input = "data/17/input.txt"

fn read_input_3d(file: String) -> Result(Matrix3D, String) {
	utils.get_input_lines(file, parse_line)
	|> result.map(make_matrix_3d)
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

pub type Point3D{
	Point3D(x: Int, y: Int, z: Int)
}

pub type Point4D{
	Point4D(x: Int, y: Int, z: Int, w: Int)
}

pub type Matrix3D = Map(Point3D, Cell)

pub type Matrix4D = Map(Point4D, Cell)

fn make_matrix_3d(input: List(List(Cell))) -> Matrix3D {
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
					let point = Point3D(col_ix, row_ix, 0)
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
	read_input_3d(sample1)
	|> result.map(part1)
}

pub fn part1_main() -> Result(Int, String) {
	read_input_3d(input)
	|> result.map(part1)
}

fn part1(matrix: Matrix3D) -> Int {

	// io.debug(count_active(matrix))

	matrix
	// |> print_matrix
	|> part1_mutate(0, _)
	// |> print_matrix
	// |> io.debug
	|> count_active
}

const max_cycles = 6

fn part1_mutate(cycle: Int, matrix: Matrix3D) -> Matrix3D {
	case cycle >= max_cycles {
		True -> matrix
		False -> {
			let next_matrix = matrix
				|> grow_3d
				|> map.map_values(part1_mutate_cell(matrix))

			part1_mutate(cycle + 1, next_matrix)
		}
	}
}

fn part1_mutate_cell(matrix: Matrix3D) {
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

pub fn get_neighbors(matrix: Matrix3D, point) {
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
							let this_point = Point3D(x, y, z)
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

pub type Bounds3D{
	Bounds3D(
		min_x: Int,
		max_x: Int,
		min_y: Int,
		max_y: Int,
		min_z: Int,
		max_z: Int,
	)
}

pub fn grow_3d(matrix: Matrix3D) -> Matrix3D {
	let new_bounds = matrix
	|> get_matrix_3d_bounds
	|> grow_bounds_3d
	// |> io.debug

	fill_3d(new_bounds, matrix)
}

fn fill_3d(bounds: Bounds3D, matrix: Matrix3D) -> Matrix3D {
	let x_range = list.range(bounds.min_x, bounds.max_x + 1)
	let y_range = list.range(bounds.min_y, bounds.max_y + 1)
	let z_range = list.range(bounds.min_z, bounds.max_z + 1)
	// io.debug(x_range)

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
							let point = Point3D(x, y, z)
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

pub fn get_matrix_3d_bounds(matrix: Matrix3D) -> Bounds3D {
	let keys = matrix |> map.keys
	let initial_bounds = Bounds3D(
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
		with: fn(key: Point3D, bounds_acc: Bounds3D) {
			Bounds3D(
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

fn grow_bounds_3d(bounds: Bounds3D) -> Bounds3D {
	Bounds3D(
		min_x: bounds.min_x - 1,
		max_x: bounds.max_x + 1,
		min_y: bounds.min_y - 1,
		max_y: bounds.max_y + 1,
		min_z: bounds.min_z - 1,
		max_z: bounds.max_z + 1,
	)
}

fn count_active(matrix: Matrix3D) -> Int {
	matrix
	|> map.values
	|> list.filter(is_on)
	|> list.length
}

fn print_matrix(matrix) {
	let bounds = get_matrix_3d_bounds(matrix)
	io.debug(bounds)
	let x_range = list.range(bounds.min_x, bounds.max_x)
	let y_range = list.range(bounds.min_y, bounds.max_y)
	let z_range = list.range(bounds.min_z, bounds.max_z)

	z_range
	|> list.map(fn(z) {
		io.debug(z)

		y_range
		|> list.map(fn(y) {

			x_range
			|> list.map(fn(x) {
				let point = Point3D(x, y, z)
				let cell = map.get(matrix, point) |> result.unwrap(Off)
				case cell {
					On -> "#"
					Off -> "."
				}
			})
			|> string.join("")
			|> io.debug

		})

	})

	matrix
}