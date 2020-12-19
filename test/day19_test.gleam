import day19.{Seq, Text, Or}
import gleam/should
import gleam/map
import gleam/pair
import gleam/list
import gleam/io
import gleam/result

// pub fn part1_sample_test() {
// 	day19.part1_sample()
// 	|> should.equal(Ok(0))
// }

pub fn sequence_test() {
	let rules = [
		tuple(0, Seq([1,2])),
		tuple(1, Text("a")),
		tuple(2, Text("b")),
	]
	|> map.from_list

	day19.resolve(rules, 0)
	|> should.equal(Ok(["ab"]))
}

pub fn combine_test() {
	day19.combine(["a"], ["x"])
	|> should.equal(["ax"])

	day19.combine(["a", "b"], ["x"])
	|> should.equal(["ax", "bx"])

	day19.combine(["a"], ["x", "y"])
	|> should.equal(["ax", "ay"])

	day19.combine(["a", "b"], ["x", "y"])
	|> should.equal(["ax", "ay", "bx", "by"])
}