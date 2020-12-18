import utils
import gleam/string
import gleam/list
import gleam/int
import gleam/io
import gleam/pair
import gleam/queue.{Queue}

const input = "data/18/input.txt"

pub type Token{
	Num(Int)
	Open
	Close
	Sum
	Mul
}

pub fn parse(input: String) {
	input
	|> string.to_graphemes
	|> tokenize([], _)
	|> consume(queue.new(), _)
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

type Stack = Queue(Token)

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

pub fn to_stack(l: List(a)) -> Queue(a) {
	l
	// |> list.reverse
	|> queue.from_list
}

pub fn push_stack(stack: Queue(a), v: a) -> Queue(a) {
	queue.push_back(stack, v)
}

pub fn pop_stack(stack: Queue(a)) -> Result(tuple(a, Queue(a)), Nil) {
	queue.pop_back(stack)
}

pub fn take_until_open(acc, stack: Stack) {
	case pop_stack(stack) {
		Ok(tuple(val, next_stack)) -> {
			// io.debug(val)
			// io.debug(next_stack |> queue.to_list)
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
	// io.debug(stack)
	let tuple(values, next_stack) = take_until_open([], stack)
	// io.debug(next_stack |> queue.to_list)

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

	// io.debug(next_stack)
	push_stack(next_stack, res)
}

fn add(a, b) { a + b }

fn mul(a, b) { a * b }