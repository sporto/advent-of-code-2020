import utils
import gleam/string
import gleam/list
import gleam/int
import gleam/io
import gleam/pair

const input = "data/18/input.txt"

pub type Token{
	Num(Int)
	Open
	Close
	Sum
	Mul
}

pub fn parse(input: String) -> Int {
	input
	|> string.to_graphemes
	|> tokenize([], _)
	|> consume([], _)
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

fn consume(stack: Stack, tokens: List(Token)) -> Stack {
	case tokens {
		[] -> evaluate(stack)
		[x, ..rest] -> {
			case x {
				Open -> consume(push_stack(stack, x), rest)
				Close -> {
					let next_stack = evaluate(stack)
					consume(next_stack, rest)
				}
				Sum -> consume(push_stack(stack, x), rest)
				Mul -> consume(push_stack(stack, x), rest)
				Num(val) -> consume(push_stack(stack, x), rest)
			}
		}
	}
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
pub fn evaluate(stack: Stack) -> Stack {
	let tuple(values, next_stack) = take_until_open([], stack)

	let res = values
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

	push_stack(next_stack, res)
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