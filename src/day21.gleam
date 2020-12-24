import utils
import gleam/list
import gleam/result
import gleam/pair
import gleam/string
import gleam/io
import gleam/set.{Set}
import gleam/map.{Map}

const sample = "data/21/sample.txt"
const input = "data/21/input.txt"

fn read(file) {
	utils.get_input_lines(file, parse_line)
}

pub type InputLine{
	InputLine(
		ingredients: List(String),
		allergens: List(String)
	)
}

fn parse_line(line: String) -> Result(InputLine, String) {
	case string.split_once(line, "(contains") {
		Ok(t) -> {
			let line = InputLine(
				ingredients: pair.first(t) |> string.trim |> string.split(" "),
				allergens: pair.second(t) |> string.drop_right(1) |> string.trim |> string.split(", ")
			)
			Ok(line)
		}
		Error(e) -> Error(line)
	}
}

pub fn part1_sample() {
	read(sample)
	|> result.map(part_1)
}

fn part_1(lines) {
	io.debug("---allergens---")

	let mm = lines
	|> make_map_by_allergen
	|> io.debug

	io.debug("---ingredients---")

	let m2 = lines
	|> make_map_by_ingredient
	|> io.debug

	1
}

fn make_map_by_allergen(lines) -> Map(String, Set(String)) {
	list.fold(
		over: lines,
		from: map.new(),
		with: fn(line: InputLine, acc1) {
			list.fold(
				over: line.allergens,
				from: acc1,
				with: fn(allergen, acc) {
					map.update(acc, allergen, fn(res) {
						case res {
							Error(_) -> line.ingredients |> set.from_list
							Ok(previous) -> set.union(previous, line.ingredients |> set.from_list)
						}
					})
				}
			)
		}
	)
}

fn make_map_by_ingredient(lines) -> Map(String, Set(String)) {
	list.fold(
		over: lines,
		from: map.new(),
		with: fn(line: InputLine, acc1) {
			list.fold(
				over: line.ingredients,
				from: acc1,
				with: fn(ingredient, acc) {
					map.update(acc, ingredient, fn(res) {
						case res {
							Error(_) -> line.allergens |> set.from_list
							Ok(previous) -> set.union(previous, line.allergens |> set.from_list)
						}
					})
				}
			)
		}
	)
}