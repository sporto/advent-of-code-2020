import day18.{Num, Open, Close, Sum, Mul}
import gleam/should
import gleam/map
import gleam/pair
import gleam/list
import gleam/io
import gleam/queue

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

	let expected_stack = [Num(1), Num(2)] |> day18.to_stack

	res
	|> pair.second
	|> queue.is_equal(_, expected_stack)
	|> should.be_true
}

fn evaluate_test_(input_list, expected_list) {
	let expected = expected_list |> day18.to_stack |> queue.to_list

	let actual = input_list
	|> day18.to_stack
	|> day18.evaluate
	|> queue.to_list

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

	// evaluate_test_(
	// 	[Num(2), Mul, Num(3), Sum, Num(5)],
	// 	[Num(11)]
	// )

	// evaluate_test_(
	// 	[Num(2), Sum, Num(3), Mul, Num(5)],
	// 	[Num(25)]
	// )
}

