import day12
import gleam/should
import gleam/map
import gleam/io

pub fn part1_sample1_test() {
	day12.part1_sample1()
	|> should.equal(Ok(25))
}
