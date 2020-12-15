import day15
import gleam/should

const part1_limit = 2020
const part2_limit = 30_000_000

pub fn part1_samples_test() {
	day15.main(part1_limit, [0,3,6])
	|> should.equal(436)

	day15.main(part1_limit, [1,3,2])
	|> should.equal(1)

	day15.main(part1_limit, [2,1,3])
	|> should.equal(10)

	day15.main(part1_limit, [1,2,3])
	|> should.equal(27)

	day15.main(part1_limit, [2,3,1])
	|> should.equal(78)

	day15.main(part1_limit, [3,2,1])
	|> should.equal(438)

	day15.main(part1_limit, [3,1,2])
	|> should.equal(1836)
}

pub fn part1_main_test() {
	day15.main(part1_limit, [10,16,6,0,1,17])
	|> should.equal(412)
}

// timeout
// pub fn part2_samples_test() {
// 	day15.main(part2_limit, [0,3,6])
// 	|> should.equal(175594)
// }