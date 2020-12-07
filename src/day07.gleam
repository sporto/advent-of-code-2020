import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam/set
import gleam/map.{Map}
import gleam/function
import utils

const input = "data/07/input.txt"
const bag = "shiny gold"

type Content = tuple(Int, String)

pub fn parse_content(item: String) -> Result(Content, Nil) {
	try parts = item
	|> string.split_once(" ")

	try qty = pair.first(parts)
	|> int.parse

	let name = pair.second(parts)
	|> string.replace(".", "")
	|> string.replace("bags", "")
	|> string.replace("bag", "")
	|> string.trim

	Ok(tuple(qty, name))
}

pub fn parse_line(line: String)
	-> Result(tuple(String, List(Content)), Nil)
	{

	try parts = line
	|> string.split_once("bags contain")

	let tuple(name, content) = parts
	let is_empty = string.contains(content, "no other bags")

	let content_list = case is_empty {
		True -> []
		False -> {
			content
			|> string.split(on: ", ")
			|> list.map(string.trim)
			|> list.map(parse_content)
			|> list.filter_map(function.identity)
		}
	}

	Ok(tuple(string.trim(name), content_list))
}

pub fn make_content_list(file: String) {
	file
	|> utils.split_lines
	|> list.map(parse_line)
	|> list.filter_map(function.identity)
}

fn drop_qty(t: tuple(String, List(Content))) -> tuple(String, List(String)) {
	let content = pair.second(t)
		|> list.map(pair.second)

	tuple(pair.first(t), content)
}

fn reverse_map_merge(
		key: String,
		values: List(String),
		map_: Map(String, List(String)),
	) -> Map(String, List(String)) {

	values
	|> list.fold(
		from: map_,
		with: fn(value, next_map) {
			next_map
			|> map.update(
				update: value,
				with: fn(res) {
					case res {
						Ok(current) -> [ key, ..current ]
						Error(_) -> [ key ]
					}
				}
			)
		}
	)
}

fn reverse_map(map_: Map(String, List(String))) -> Map(String, List(String)) {
	map.fold(
		over: map_,
		from: map.new(),
		with: reverse_map_merge
	)
}

pub fn make_reverse_lookup_map(file: String) {
	make_content_list(file)
	|> list.map(drop_qty)
	|> map.from_list
	|> reverse_map
}

fn follow_ancestors(lookup_map, name) -> List(String) {
	case map.get(lookup_map, name) {
		Error(_) -> []
		Ok(containers) ->
			{
				let ancestors = containers
					|> list.map(follow_ancestors(lookup_map, _))
					|> list.flatten

				list.append(containers, ancestors)
			}
	}
}

fn count_bags(lookup_map, name) -> Int {
	case map.get(lookup_map, name) {
		Error(_) -> 0
		Ok(children) -> {
			let count = children
				|> list.map(fn(tu) {
					pair.first(tu) * count_bags(lookup_map, pair.second(tu))
				})
				|> utils.sum

			1 + count
		}
	}
}

pub fn part1(file: String) {
	make_reverse_lookup_map(file)
	|> follow_ancestors("shiny gold")
	|> set.from_list
	|> set.size
	|> io.debug
}

pub fn part2(file: String) {
	make_content_list(file)
	|> map.from_list
	|> count_bags("shiny gold")
	|> fn(n) { n - 1 }
	|> io.debug
}

pub fn main() {
	utils.read_file(input)
	|> result.map(part2)
}