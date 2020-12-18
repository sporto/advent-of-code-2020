import utils
import gleam/string
import gleam/list
import gleam/int
import gleam/queue.{Queue}

const input = "data/18/input.txt"

// fn read_input(file: String) -> Result(Matrix3D, String) {
// 	utils.get_input_lines(file, parse_line)
// 	|> result.map(make_matrix_3d)
// }

// pub fn part1_sample() -> Result(Int, String) {
// 	read_input(sample1)
// 	|> result.map(part1)
// }

// pub type Atom{
// 	Expression()
// }

// + 2
// + (2 * 3)


pub type Token{
	Num(Int)
	Open
	Close
	Sum
	Mul
}

fn eval(input: String) {
	// parse(input)

	1
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

// fn consume(total, tokens: List(Token)) -> Int {
// 	case tokens {
// 		[] -> 0
// 		[x, ..rest] -> {
// 			case x {
// 				Open -> total + consume(0, rest)
// 				Close -> total
// 				Sum -> total + consume(0, rest)
// 				Mul -> total * consume(0, rest)
// 				Num(val) -> consume(val, rest)
// 			}
// 		}
// 	}
// }

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


fn push_stack(stack: Stack, v: Token) -> Stack {
	queue.push_back(stack, v)
}

fn pop_stack(stack: Stack) -> Result(tuple(Token, Stack), Nil) {
	queue.pop_back(stack)
}

// Evaluate until an Open is found
// Push the evaluated num into the stack
fn evaluate(stack) -> Stack {
	// TODO
	queue.new()
}