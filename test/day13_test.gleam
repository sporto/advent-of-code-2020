import day13
import gleam/should
import gleam/io

pub fn part1_sample_test() {
	day13.part1_sample()
	|> should.equal(295)
}

pub fn part1_main_test() {
	day13.part1_main()
	|> should.equal(115)
}

pub fn part2_sample_test() {
	day13.part2_sample()
	|> should.equal(1068781)
}

pub fn part2_test() {
	day13.part2(0, "17,x,13,19")
	|> should.equal(3417)

	day13.part2(0, "67,7,59,61")
	|> should.equal(754018)

	day13.part2(779_200, "67,x,7,59,61")
	|> should.equal(779_210)

	day13.part2(1261470, "67,7,x,59,61")
	|> should.equal(1261476)

	day13.part2(1_202_161_400, "1789,37,47,1889")
	|> should.equal(1_202_161_486)
}

// too slow
// pub fn part2_main_test() {
// 	day13.part2_main()
// 	|> should.equal(1068781)
// }