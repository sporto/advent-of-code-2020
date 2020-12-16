import day16
import gleam/should

pub fn part1_samples_test() {
	day16.part1_sample()
	|> should.equal(Ok(71))
}

pub fn part1_main_test() {
	day16.part1_main()
	|> should.equal(Ok(27898))
}

// pub fn part2_sample_test() {
// 	day16.part2_sample()
// 	|> should.equal(Ok([]))
// }

pub fn part2_main_test() {
	day16.part2_main()
	|> should.equal(Ok([]))
}

// day16:part2_main().