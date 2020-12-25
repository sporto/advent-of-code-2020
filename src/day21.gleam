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
		ingredients: Set(String),
		allergens: Set(String)
	)
}

fn parse_line(line: String) -> Result(InputLine, String) {
	case string.split_once(line, "(contains") {
		Ok(t) -> {
			let ingredients = pair.first(t) |> string.trim |> string.split(" ") |> set.from_list
			let allergens = pair.second(t) |> string.drop_right(1) |> string.trim |> string.split(", ") |> set.from_list

			let line = InputLine(
				ingredients: ingredients,
				allergens: allergens,
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

	compare_lines(lines)
	|> io.debug

	// let mm = lines
	// |> make_map_by_allergen
	// |> io.debug

	// io.debug("---ingredients---")

	// let m2 = lines
	// |> make_map_by_ingredient
	// |> io.debug

	1
}

fn compare_lines(lines: List(InputLine)) -> Map(String, String) {
	lines
	|> list.fold(
		from: map.new(),
		with: fn(line1, acc1: Map(String, String)) {
			lines
			|> list.fold(
				from: acc1,
				with: fn(line2, acc: Map(String, String)) {
					case line1 == line2 {
						True -> acc
						False -> {
							case compare(acc, line1, line2) {
								Error(_) -> acc
								Ok(next_acc) -> next_acc
							}
						}
					}
				}
			)
		}
	)
}

fn compare(
		table: Map(String, String),
		line1: InputLine,
		line2: InputLine
	) ->  Result(Map(String, String), String) {

	// Remove the know ingredients and allergens
	let line1b = remove(table, line1)
	let line2b = remove(table, line2)

	// We want only one common allergen
	// And only one common ingredient
	let common_ingredients = set.intersection(
		line1b.ingredients,
		line2b.ingredients
		)
		|> set.to_list

	let common_allergens = set.intersection(
		line1b.allergens,
		line2b.allergens
		)
		|> set.to_list

	case common_ingredients {
		[ingredient] -> {
			case common_allergens {
				[allergen] -> {
					let next_table = map.insert(table, ingredient, allergen)

					Ok(next_table)
				}
				_ -> Error("No match")
			}
		}
		_ -> Error("No match")
	}
}

fn remove(table: Map(String, String), line: InputLine) -> InputLine {
	map.fold(
		over: table,
		from: line,
		with: fn(ing: String, all: String, acc: InputLine) {
			InputLine(
				ingredients: set.delete(acc.ingredients, ing),
				allergens: set.delete(acc.allergens, all),
			)
		}
	)
}

fn make_map_by_allergen(lines) -> Map(String, Set(String)) {
	list.fold(
		over: lines,
		from: map.new(),
		with: fn(line: InputLine, acc1) {
			list.fold(
				over: line.allergens |> set.to_list(),
				from: acc1,
				with: fn(allergen, acc) {
					map.update(acc, allergen, fn(res) {
						case res {
							Error(_) -> line.ingredients
							Ok(previous) -> set.union(previous, line.ingredients)
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
				over: line.ingredients |> set.to_list(),
				from: acc1,
				with: fn(ingredient, acc) {
					map.update(acc, ingredient, fn(res) {
						case res {
							Error(_) -> line.allergens
							Ok(previous) -> set.union(previous, line.allergens)
						}
					})
				}
			)
		}
	)
}