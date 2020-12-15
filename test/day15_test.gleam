import day15
import gleam/should

const sample1 = [0,3,6]

pub fn part1_samples_test() {
	day15.part1(sample1)
	|> should.equal(436)
}