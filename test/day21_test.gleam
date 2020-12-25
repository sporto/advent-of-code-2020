import day21
import gleam/should

pub fn part1_sample_test() {
	day21.part1_sample()
	|> should.equal(Ok(5))
}

pub fn part1_main_test() {
	day21.part1_main()
	|> should.equal(Ok(2170))
}