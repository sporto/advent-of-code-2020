import day09
import gleam/should

pub fn part1_test() {
	day09.part1()
	|> should.equal(Ok(32321523))
}

pub fn part2_test() {
	day09.part2()
	|> should.equal(Ok(4794981))
}