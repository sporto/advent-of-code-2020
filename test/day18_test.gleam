import day18.{Num, Open, Close, Sum, Mul}
import gleam/should
import gleam/map
import gleam/pair
import gleam/list
import gleam/io

pub fn parse_test() {
	day18.parse("1 + 2")
	|> should.equal(3)

	day18.parse("(1 + 2)")
	|> should.equal(3)

	day18.parse("(1 + 2) + 3")
	|> should.equal(6)

	day18.parse("3 + (1 + 2)")
	|> should.equal(6)

	day18.parse("2 * (4 + 8)")
	|> should.equal(24)

	day18.parse("(2 * 4) + 8")
	|> should.equal(16)

	day18.parse("1 + 2 * 3 + 4 * 5 + 6")
	|> should.equal(71)

	day18.parse("1 + (2 * 3) + (4 * (5 + 6))")
	|> should.equal(51)

	day18.parse("2 * 3 + (4 * 5)")
	|> should.equal(26)

	day18.parse("5 + (8 * 3 + 9 + 3 * 4 * 3)")
	|> should.equal(437)

	day18.parse("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))")
	|> should.equal(12240)

	day18.parse("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2")
	|> should.equal(13632)
}

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

pub fn part1_test() {
	day18.part1()
	|> should.equal(Ok(0))
}