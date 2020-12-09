import utils
import gleam/int
import gleam/result
import gleam/list
import gleam/function
import gleam/bool
import gleam/pair
import gleam/io

const input = "data/09/input.txt"

fn check_num(previous_range: Int, nums: List(Int)) {
	fn(ix: Int, num: Int) -> tuple(Int, Bool) {

		let res = case ix < previous_range {
			True -> True
			False -> {
				let previous = nums
					|> list.drop(ix - previous_range)
					|> list.take(previous_range)

				check_sum_from_previous(previous, num)
			}
		}

		tuple(num, res)
	}
}

fn check_sum_from_previous(
		previous: List(Int),
		num: Int
	) -> Bool {

	previous
	|> list.map(fn(comp) {
		let diff = num - comp
		case diff * 2 == num {
			True -> False
			False -> list.contains(previous, diff)
		}
	})
	|> list.any(function.identity)
}

fn process_part1(file) {
	try nums = file
	|> utils.split_lines
	|> list.map(int.parse)
	|> result.all
	|> result.map_error(fn(_) { "Could not parse" })

	let previous_range = 25

	nums
	|> list.index_map(check_num(previous_range, nums))
	|> list.find(fn(t) { pair.second(t) |> bool.negate })
	|> result.map_error(fn(_) { "Could find result" })
	|> result.map(pair.first)
}

pub fn part1() {
	utils.read_file(input)
	|> result.map_error(fn(_) { "Could not read file" })
	|> result.then(process_part1)
}