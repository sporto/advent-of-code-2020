import day20
import gleam/should

pub fn part1_sample_test() {
	day20.part1_sample()
	|> should.equal(Ok(20899048083289))
}

pub fn part1_main_test() {
	day20.part1_main()
	|> should.equal(Ok(1))
}