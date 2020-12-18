import day18
import gleam/should
import gleam/map
import gleam/list
import gleam/io

// pub fn eval_test() {
// 	day18.eval("1 + 2")
// 	|> should.equal(3)
// }


pub fn parse_test() {
	day18.parse("(1 + 1)")
	|> should.equal([])
}