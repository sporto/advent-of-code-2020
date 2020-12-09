import day09
import gleam/should

pub fn part1_test() {
	day09.part1()
	|> should.equal(Ok(127))
}