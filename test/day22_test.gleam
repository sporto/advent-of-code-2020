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

pub fn part2_sample_test() {
	day22.part2_sample()
	|> should.equal(Ok(291))
}

pub fn part2_main_test() {
	day22.part2_main()
	|> should.equal(Ok(1))
}