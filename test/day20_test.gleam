import day20.{Coor}
import gleam/should
import gleam/map

pub fn part1_sample_test() {
	day20.part1_sample()
	|> should.equal(Ok(20899048083289))
}

// pub fn part1_main_test() {
// 	day20.part1_main()
// 	|> should.equal(Ok(18482479935793))
// }

pub fn part2_sample_test() {
	day20.part2_sample()
	|> should.equal(Ok(273))
}

pub fn part2_main_test() {
	day20.part2_main()
	|> should.equal(Ok(2118))
}

pub fn remove_matrix_borders_test() {
	let matrix = [
		[1,2,3,4],
		[5,6,7,8],
		[5,6,7,8],
		[1,2,3,4],
	]

	let expected = [
		[6,7],
		[6,7],
	]

	day20.remove_matrix_borders(matrix)
	|> should.equal(expected)
}

pub fn lines_to_map_test() {
	let matrix = [
		[1,2],
		[3,4]
	]

	let expected = [
		tuple(Coor(0,0), 1),
		tuple(Coor(1,0), 2),
		tuple(Coor(0,-1), 3),
		tuple(Coor(1,-1), 4),
	] |> map.from_list

	day20.lines_to_map(matrix)
	|> should.equal(expected)
}