import day23
import gleam/should

const sample = [3,8,9,1,2,5,4,6,7]
const input = [4,6,3,5,2,8,1,7,9]

pub fn part1_sample_10_test() {
	day23.part1(10, sample)
	|> should.equal(Ok("92658374"))
}

pub fn part1_sample_100_test() {
	day23.part1(100, sample)
	|> should.equal(Ok("67384529"))
}

pub fn part1_main_test() {
	day23.part1(100, input)
	|> should.equal(Ok("52937846"))
}

pub fn part2_sample_test() {
	day23.part2(sample)
	|> should.equal(Ok(149245887792))
}