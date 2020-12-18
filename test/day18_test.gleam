import day18
import gleam/should
import gleam/map
import gleam/list
import gleam/io
import gleam/queue

// pub fn eval_test() {
// 	day18.eval("1 + 2")
// 	|> should.equal(3)
// }


pub fn parse_test() {
	day18.parse("(1 + 1)")
	|> should.equal(queue.new())
}

// 1 * (2 + 3)
// 1
// *
// 

// stack:
// ) eval until (
// 3
// +
// 2
// (
// *
// 1