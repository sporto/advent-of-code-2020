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