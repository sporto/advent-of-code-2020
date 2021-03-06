import utils
import gleam/string
import gleam/list
import gleam/int
import gleam/io
import gleam/pair
import gleam/result

const input = "data/18/input.txt"

pub type Token{
	Num(Int)
	Open
	Close
	Sum
	Mul
}

pub fn part1() {
	utils.get_input_lines(input, fn(line) { Ok(parse_linear(line)) })
	|> result.map(utils.sum)
}

pub fn part2() {
	utils.get_input_lines(input, fn(line) { Ok(parse_precedence(line)) })
	|> result.map(utils.sum)
}

pub fn parse_linear(input: String) -> Int {
	parse(evaluate_linear, input)
}

pub fn parse_precedence(input: String) -> Int {
	parse(evaluate_addition_precedence, input)
}

pub fn parse(evaluate_fn, input: String) -> Int {
	input
	|> string.to_graphemes
	|> tokenize([], _)
	|> consume(evaluate_fn, [], _)
	|> extract
}

fn tokenize(tokens: List(Token), chars: List(String)) -> List(Token) {
	case chars {
		[] -> tokens
		[x, ..rest] -> {
			let next = case x {
				"(" -> [Open]
				")" -> [Close]
				" " -> []
				"+" -> [Sum]
				"*" -> [Mul]
				_ -> {
					case int.parse(x) {
						Ok(num) -> [Num(num)]
						Error(_) -> []
					}
				}
			}
			tokenize(list.append(tokens, next), rest)
		}
	}
}

type Stack = List(Token)

fn consume(evaluate_fn, stack: Stack, tokens: List(Token)) -> Stack {
	case tokens {
		[] -> evaluate(evaluate_fn, stack)
		[x, ..rest] -> {
			case x {
				Open -> consume(evaluate_fn, push_stack(stack, x), rest)
				Close -> {
					let next_stack = evaluate(evaluate_fn, stack)
					consume(evaluate_fn, next_stack, rest)
				}
				Sum -> consume(evaluate_fn, push_stack(stack, x), rest)
				Mul -> consume(evaluate_fn, push_stack(stack, x), rest)
				Num(val) -> consume(evaluate_fn, push_stack(stack, x), rest)
			}
		}
	}
}

pub fn new_stack() {
	[]
}

pub fn to_stack(l: List(Token)) -> Stack {
	list.reverse(l)
}

pub fn push_stack(stack: Stack, v: Token) -> Stack {
	[v, ..stack]
}

pub fn pop_stack(stack: Stack) -> Result(tuple(Token, Stack), Nil) {
	case stack {
		[x, ..rest] -> Ok(tuple(x, rest))
		_ -> Error(Nil)
	}
}

pub fn take_until_open(acc, stack: Stack) {
	case pop_stack(stack) {
		Ok(tuple(val, next_stack)) -> {
			case val {
				Open -> tuple(acc, next_stack)
				_ -> take_until_open(
					[val, ..acc],
					next_stack
				)
			}
		}
		Error(_) -> tuple(acc, stack)
	}
}

// Evaluate until an Open is found
// Push the evaluated num into the stack
pub fn evaluate(evaluate_fn, stack: Stack) -> Stack {
	let tuple(values, next_stack) = take_until_open([], stack)

	let res = evaluate_fn(values)

	push_stack(next_stack, res)
}

pub fn evaluate_linear(values: List(Token)) -> Token {
	values
		|> list.fold(
			from: tuple(0, add),
			with: fn(val, acc_tuple) {
				let tuple(total, operation) = acc_tuple
				case val {
					Num(num) -> tuple(operation(total, num), add)
					Sum -> tuple(total, add)
					Mul -> tuple(total, mul)
					Open -> tuple(total, add)
					Close -> tuple(total, add)
				}
			}
		)
		|> pair.first
		|> Num
}

pub fn evaluate_addition_precedence(values) {
	// evaluate_linear(values)
	// * push stack
	// + push stack
	// Num if top of stack is + evaluate
	values
	|> list.fold(
		from: new_stack(),
		with: fn(token, stack) {
			let next_stack = push_stack(stack, token)
			case token {
				Sum -> next_stack
				Mul -> next_stack
				Num(num) -> {
					case pop_stack(stack) {
						Ok(tuple(previous_token, stack_without_1)) -> {
							case previous_token {
								Sum -> {
									case pop_stack(stack_without_1) {
										Ok(tuple(previous_previous_token, stack_without_2)) -> {
											case previous_previous_token {
												Num(other_num) -> {
													push_stack(
														stack_without_2,
														Num(num + other_num)
													)
												}
												_ -> next_stack
											}
										}
										Error(_) -> next_stack
									}
								}
								_ -> next_stack
							}
						}
						Error(_) -> next_stack
					}
				}
				_ -> next_stack
			}
		}
	) |> evaluate_linear
}

fn add(a, b) { a + b }

fn mul(a, b) { a * b }

fn extract(tokens: List(Token)) -> Int {
	tokens
	|> list.fold(
		from: 0,
		with: fn(token, acc) {
			case token {
				Num(num) -> acc + num
				_ -> acc
			}
		}
	)
}