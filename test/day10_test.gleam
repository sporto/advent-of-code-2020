import day10
import gleam/should
import gleam/map

pub fn part1_sample1_test() {
	day10.part1_sample1()
	|> should.equal(Ok(7 * 5))
}

pub fn part1_sample2_test() {
	day10.part1_sample2()
	|> should.equal(Ok(22 * 10))
}

pub fn part1_main_test() {
	day10.part1_main()
	|> should.equal(Ok(2100))
}

pub fn part2_sample1_test() {
	day10.part2_sample1()
	|> should.equal(Ok([[0]]))
}