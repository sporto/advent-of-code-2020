import day17
import gleam/should
import gleam/map

pub fn part1_samples_test() {
	day17.part1_sample()
	|> should.equal(Ok(map.new()))
}