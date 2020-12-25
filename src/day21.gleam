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

	let table = lines
	|> compare_lines(map.new(), compare_common)
	|> check_if_lines_have_one(lines)
	// |> io.debug

	let all_ingredients = get_all_ingredients(lines)

	let bad_ingredients = table |> map.keys |> set.from_list

	// io.debug(bad_ingredients)

	let good_ingredients = set.fold(
		over: bad_ingredients,
		from: all_ingredients,
		with: fn(bad, acc) {
			set.delete(acc, bad)
		}
	)

	// io.debug(good_ingredients |> set.to_list)

	let count = lines
	|> list.map(
		fn(line: InputLine) {
			set.intersection(line.ingredients, good_ingredients) |> set.size
		}
	) |> utils.sum

	// io.debug("---ingredients---")

	// let m2 = lines
	// |> make_map_by_ingredient
	// |> io.debug

	count
}

fn get_all_ingredients(lines) -> Set(String) {
	lines
	|> list.map(fn(l: InputLine) { l.ingredients })
	|> list.fold(
		from: set.new(),
		with: set.union
	)
}

fn compare_lines(lines: List(InputLine), table, compare_fn) -> Map(String, String) {
	lines
	|> list.fold(
		from: table,
		with: fn(line1, acc1: Map(String, String)) {
			lines
			|> list.fold(
				from: acc1,
				with: fn(line2, acc: Map(String, String)) {
					case line1 == line2 {
						True -> acc
						False -> {
							compare_fn(acc, line1, line2)
						}
					}
				}
			)
		}
	)
}

fn compare_common(
		table: Map(String, String),
		line1: InputLine,
		line2: InputLine
	) ->  Map(String, String) {

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
					map.insert(table, ingredient, allergen)
				}
				_ -> table
			}
		}
		_ -> table
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

fn check_if_lines_have_one(table: Map(String, String), lines: List(InputLine)) -> Map(String, String) {
	lines
	|> list.fold(
		from: table,
		with: fn(line, acc) {
			check_if_lines_has_one(acc, line)
		}
	)
}

fn check_if_lines_has_one(table, line) {
	let lineb = remove(table, line)
	// if the line has one ingredient and one allergen then join
	case lineb.ingredients |> set.to_list {
		[ingredient] -> {
			case lineb.allergens |> set.to_list {
				[allergen] -> {
					map.insert(table, ingredient, allergen)
				}
				_ -> table
			}
		}
		_ -> table
	}
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