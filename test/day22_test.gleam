import day22
import gleam/should

pub fn part1_sample_test() {
	day22.part1_sample()
	|> should.equal(Ok(306))
}

pub fn part1_main_test() {
	day22.part1_main()
	|> should.equal(Ok(32489))
}