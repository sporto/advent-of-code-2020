import day19.{Sequence}
import gleam/should
import gleam/map
import gleam/pair
import gleam/list
import gleam/io
import gleam/result

pub fn parse_rule_sequence_test() {
	day19.parse_rule_sequence("4 1 5")
	|> should.equal(Ok(Sequence([4,1,5])))
}

pub fn part1_sample_test() {
	day19.part1_sample()
	|> should.equal(Ok([]))
}
