import day14
import gleam/should
import gleam/io

pub fn part1_sample_test() {
	day14.part1_sample()
	|> should.equal(Ok([]))
}