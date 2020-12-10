import utils
import gleam/list
import gleam/result
import gleam/int
import gleam/pair
import gleam/map

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