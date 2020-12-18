import day18.{Num, Open, Close, Sum, Mul}
import gleam/should
import gleam/map
import gleam/pair
import gleam/list
import gleam/io

// pub fn eval_test() {
// 	day18.eval("1 + 2")
// 	|> should.equal(3)
// }

pub fn take_until_open_test() {
	let res = [Num(1), Num(2), Open, Num(3), Num(4)]
	|> day18.to_stack
	|> day18.take_until_open([], _)

	res
	|> pair.first
	|> should.equal([Num(3), Num(4)])

	let expected_stack = [Num(1), Num(2)]
		|> day18.to_stack

	res
	|> pair.second
	|> should.equal(expected_stack)
}

fn evaluate_test_(input_list, expected_list) {
	let expected = expected_list |> day18.to_stack

	let actual = input_list
	|> day18.to_stack
	|> day18.evaluate
	// |> io.debug

	actual
	|> should.equal(expected)
}

pub fn evaluate_test() {
	evaluate_test_(
		[Num(1), Sum, Num(2)],
		[Num(3)]
	)

	evaluate_test_(
		[Num(2), Mul, Num(3)],
		[Num(6)]
	)

	evaluate_test_(
		[Num(1), Sum, Open, Num(2), Sum, Num(3)],
		[Num(1), Sum, Num(5)]
	)

	evaluate_test_(
		[Num(2), Mul, Num(3), Sum, Num(5)],
		[Num(11)]
	)

	evaluate_test_(
		[Num(2), Sum, Num(3), Mul, Num(5)],
		[Num(25)]
	)
}


pub fn queue_test() {
	[11,10]
	|> queue.from_list
	|> queue.push_front(2)
	|> queue.push_front(1)
	|> io.debug
	|> queue.push_back(20)
	|> queue.push_back(21)
	|> io.debug
	|> queue.to_list
	|> should.equal([1,2,10,11,20,21])
}
