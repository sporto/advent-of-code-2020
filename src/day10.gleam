import utils
import gleam/list
import gleam/result
import gleam/int
import gleam/pair
import gleam/map
import gleam/io

const sample1 = "data/10/sample1.txt"
const sample2 = "data/10/sample2.txt"
const input = "data/10/input.txt"

fn parse_lines(lines) {
	lines
	|> list.map(int.parse)
	|> result.all
	|> utils.replace_error("Could not parse")
}

fn read_input(file) {
	utils.read_file(file)
	|> utils.replace_error("Could not read file")
	|> result.map(utils.split_lines)
	|> result.then(parse_lines)
}

fn diff(t) {
	pair.second(t) - pair.first(t)
}

fn part1(lines) {
	[0, ..lines]
	|> list.sort(int.compare)
	|> utils.windows
	|> list.map(diff)
	|> list.append([3])
	|> utils.count
	|> map.to_list
	|> list.map(pair.second)
	|> utils.multiply
}

pub fn part1_sample1() {
	read_input(sample1)
	|> result.map(part1)
}

pub fn part1_sample2() {
	read_input(sample2)
	|> result.map(part1)
}

pub fn part1_main() {
	read_input(input)
	|> result.map(part1)
}

fn arrangements(
		nums: List(Int),
		previous: List(Int),
		wanted: Int
	)
	-> List(List(Int))
	{

	case nums {
		[] -> []
		[ first, ..rest ] -> {
			let diff = first - anchor

			case diff > 3 {
				True -> []
				False -> {
					[
						// This num is included
						[ list.append(previous, nums) ],
						arrangements(
							rest,
							previous,
							anchor
						),
						arrangements(
							rest,
							list.append(previous, [ first ]),
							first
						),
					] |> list.flatten
				}
			}
		}
	}
}

fn from(nums, wanted) {
	case nums {
		[] -> []
		[ first, ..rest ] -> {
			case first == wanted {
				True -> {
					nums
					from(rest, wanted + 1)
					from(rest, wanted + 2)
					from(rest, wanted + 3)
				}
				False -> []
			}
		}
	}
}

fn arrangements(nums) {
	from(nums, 1)
	from(nums, 2)
	from(nums, 3)
}

fn part2(lines) {
	let nums = lines
	|> list.sort(int.compare)

	let max = utils.max(nums)

	nums
	|> list.append([max + 3])
	|> arrangements()
}

pub fn part2_sample1() {
	read_input(sample1)
	|> result.map(part2)
}