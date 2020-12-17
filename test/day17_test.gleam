import day17.{Point3D, On, Off}
import gleam/should
import gleam/map
import gleam/list
import gleam/io

pub fn grow_test() {
	let matrix = [
		tuple(Point3D(0, 0, 0), On)
	] |> map.from_list

	let next_matrix = matrix
	|> day17.grow_3d

	next_matrix
	|> map.keys
	|> list.length
	|> should.equal(27)

	let bounds = day17.get_matrix_3d_bounds(next_matrix)
	// io.debug(bounds)

	bounds.min_x |> should.equal(-1)
	bounds.max_x |> should.equal(1)
	bounds.min_y |> should.equal(-1)
	bounds.max_y |> should.equal(1)
	bounds.min_z |> should.equal(-1)
	bounds.max_z |> should.equal(1)
}

pub fn get_neighbors_test() {
	let point = Point3D(1, 1, 1)

	let matrix = [
		tuple(point, On)
	] |> map.from_list

	day17.get_neighbors(matrix, point)
	|> list.length
	|> should.equal(26)
}

pub fn part1_samples_test() {
	day17.part1_sample()
	|> should.equal(Ok(112))
}

pub fn part1_main_test() {
	day17.part1_main()
	|> should.equal(Ok(391))
}
