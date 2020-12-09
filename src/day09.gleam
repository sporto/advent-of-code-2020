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

fn process_part1(nums) {
	let previous_range = 25

	nums
	|> list.index_map(check_num(previous_range, nums))
	|> list.find(fn(t) { pair.second(t) |> bool.negate })
	|> result.map_error(fn(_) { "Could find result" })
	|> result.map(pair.first)
}

fn get_input() {
	try file = utils.read_file(input)
		|> result.map_error(fn(_) { "Could not read file" })

	file
	|> utils.split_lines
	|> list.map(int.parse)
	|> result.all
	|> result.map_error(fn(_) { "Could not parse" })
}

pub fn part1() {
	get_input()
	|> result.then(process_part1)
}

type Contiguous{
	Collecting(List(Int))
	Exact(List(Int))
	Over
}

fn find_contiguous(sum: Int, nums: List(Int)) {
	fn(ix: Int, num: Int) {
		let lookup = list.drop(nums, ix)
		lookup
		|> list.fold(
			from: Collecting([]),
			with: fn(num, acc) {
				case acc {
					Over -> Over
					Collecting(collected) -> {
						let next = [num, ..collected]
						let collected_sum = utils.sum(next)
						case collected_sum {
							_ if collected_sum < sum ->
								Collecting(next)
							_ if collected_sum == sum ->
								Exact(next)
							_ if collected_sum > sum ->
								Over
						}
					}
					Exact(_) -> acc
				}
			}
		)
	}
}

fn get_contiguous(contiguous) {
	case contiguous {
		Collecting(_) -> Error(Nil)
		Exact(nums) -> Ok(nums)
		Over -> Error(Nil)
	}
}

fn add_smallest_and_largest(nums: List(Int)) -> Int {
	utils.min(nums) + utils.max(nums)
}

fn process_part2(nums) {
	// hardcoded to make part2 faster
	let sum = 32321523
	// let sum = 127

	nums
	|> list.index_map(find_contiguous(sum, nums))
	|> list.find_map(get_contiguous)
	|> result.map_error(fn(_) { "Could not find contiguous"})
	|> result.map(add_smallest_and_largest)
}

pub fn part2() {
	get_input()
	|> result.then(process_part2)
}