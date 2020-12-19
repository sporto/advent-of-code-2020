import gleam/list
import gleam/dynamic.{Dynamic}
import gleam/string
import gleam/int
import gleam/result
import gleam/map
import gleam/bool

pub external fn read_file(name: String) -> Result(String, Dynamic) =
  "file" "read_file"

pub external fn rem(Int, Int) -> Int =
  "erlang" "rem"

pub fn split_lines(file: String) -> List(String) {
  string.split(file, "\n")
}

pub fn split_groups(file: String) -> List(String) {
	string.split(file, "\n\n")
}

pub fn get_input_lines(
		file_name: String,
		parse_line: fn(String) -> Result(a, String)
	) -> Result(List(a), String) {

	try file = read_file(file_name)
		|> replace_error("Could not read file")

	file
	|> split_lines
	|> list.map(parse_line)
	|> result.all
}

///

pub fn abs(num) {
	case num >= 0 {
		True -> num
		False -> num * -1
	}
}

pub fn sum(col: List(Int)) -> Int {
  list.fold(over: col, from: 0, with: fn(n, t) { n + t } )
}

pub fn multiply(col: List(Int)) -> Int {
  list.fold(over: col, from: 1, with: fn(n, t) { n * t } )
}

// pub fn min(col: List(Int)) -> Int {
// 	list.fold(over: col, from: 1_000_000_000_000, with: int.min)
// }
pub external fn min(List(Int)) -> Int =
	"lists" "min"

pub fn max(col: List(Int)) -> Int {
	list.fold(over: col, from: 0, with: int.max)
}

pub fn try_fold(
		over collection: List(a),
		from accumulator: b,
		with fun: fn(a, b) -> Result(b, b),
	) -> b {

		case collection {
			[] -> accumulator
			[ first, ..rest ] ->
				case fun(first, accumulator) {
					Ok(next_accumulator) ->
						try_fold(rest, next_accumulator, fun)
					Error(b) -> b
				}
		}
}

pub fn replace_error(
		res: Result(a, b), error: c
	) -> Result(a, c)  {

	res
	|> result.map_error(fn(_) { error })
}

pub fn windows(collection) {
	list.zip(
		collection,
		list.drop(collection, 1),
	)
}

pub fn count(collection) {
	let update = fn(res) {
		case res {
			Ok(val) -> val + 1
			Error(Nil) -> 1
		}
	}

	let folder = fn(ele, acc) {
		map.update(
			in: acc,
			update: ele,
			with: update
		)
	}

	list.fold(
		over: collection,
		from: map.new(),
		with: folder
	)
}

pub fn is_divisor_of(number num, divisor divisor) {
	rem(num, divisor) == 0
}

fn to_binary_(num: Int, acc: List(Bool)) -> List(Bool) {
	case num == 0 {
		True -> acc
		False -> {
			let quotient = num / 2
			let remainder = rem(num, 2)
			let bit = case remainder {
				0 -> False
				_ -> True
			}

			to_binary_(
				quotient,
				list.append([ bit ], acc)
			)
		}
	}
}

pub fn to_binary(num: Int) -> List(Bool) {
	to_binary_(num, [])
}

pub fn to_binary_string(num: Int) -> String {
	to_binary(num)
	|> list.map(fn(v) {
		case v {
			True -> "1"
			False -> "0"
		}
	})
	|> string.join("")
}

fn from_binary_(total: Int, bin: List(Bool)) -> Int {
	case bin {
		[] -> total
		[first, ..rest] -> from_binary_(total * 2 + bool.to_int(first), rest)
	}
}

pub fn from_binary(bin: List(Bool)) -> Int {
	from_binary_(0, bin)
}

pub fn from_binary_string(bin: String) -> Int {
	bin
	|> string.to_graphemes
	|> list.filter_map(int.parse)
	|> list.filter_map(fn(n) {
		case n {
			0 -> Ok(False)
			1 -> Ok(True)
			_ -> Error(Nil)
		}
	})
	|> from_binary
}

pub fn permutations(l: List(a)) -> List(List(a)) {
	case l {
		[] -> [[]]
		_ -> {
			// For each value in the list
			list.map(l, fn(x) {
				// Make a sub list without the current value x
				list.filter(l, fn(y) { y != x })
				// Get the permutations for this sub list
				|> permutations
				// Add the x value at the begging of each sub list
				|> list.map(list.append([x], _))

			})
			// Return a List(List(a))
			|> list.flatten
		}
	}
}