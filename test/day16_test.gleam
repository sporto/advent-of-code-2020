import day16
import gleam/should

pub fn part1_samples_test() {
	day16.part1_sample()
	|> should.equal(Ok([]))

}
