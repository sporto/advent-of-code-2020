import utils
import gleam/string
import gleam/list
import gleam/int

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
	|> consume([], _)
}

fn consume(tokens: List(Token), chars: List(String)) -> List(Token) {
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
			consume(list.append(tokens, next), rest)
		}
	}
}