import day11
import gleam/should
import gleam/map

pub fn part1_sample1_test() {
	day11.part1_sample1()
	|> should.equal(Ok([]))
}