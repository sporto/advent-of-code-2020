import day17.{Point, On, Off}
import gleam/should
import gleam/map
import gleam/list

pub fn grow_test() {
	let matrix = [
		tuple(Point(1, 1, 1), On)
	] |> map.from_list

	matrix
	|> day17.grow
	|> map.keys
	|> list.length
	|> should.equal(27)
}

pub fn get_neighbors_test() {
	let point = Point(1, 1, 1)

	let matrix = [
		tuple(point, On)
	] |> map.from_list

	day17.get_neighbors(matrix, point)
	|> list.length
	|> should.equal(26)
}

pub fn part1_samples_test() {
	day17.part1_sample()
	|> should.equal(Ok(1))
}
