import day20
import gleam/should

pub fn part1_sample_test() {
	day20.part1_sample()
	|> should.equal(Ok([]))
}