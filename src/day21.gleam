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

pub fn part1_main() {
	read(input)
	|> result.map(part_1)
}

fn part_1(lines) {
	let all_ingredients = get_all_ingredients(lines)

	let table = lines
	|> build_sets
	// |> io.debug
	|> extract_singles(_, map.new(), 0)
	// |> io.debug

	// io.debug(all_ingredients)

	let bad_ingredients = table |> map.values |> set.from_list

	// io.debug(bad_ingredients)

	let good_ingredients = set.fold(
		over: bad_ingredients,
		from: all_ingredients,
		with: fn(bad, acc) {
			set.delete(acc, bad)
		}
	)

	let count = lines
	|> list.map(
		fn(line: InputLine) {
			set.intersection(line.ingredients, good_ingredients) |> set.size
		}
	) |> utils.sum

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

fn build_sets(lines) {
	lines
	|> list.fold(
		from: map.new(),
		with: fn(line: InputLine, acc1) {

			line.allergens
			|> set.fold(
				from: acc1,
				with: fn(allergen, acc) {
					map.update(acc, allergen, fn(res) {
						case res {
							Ok(previous) -> set.intersection(line.ingredients, previous)
							Error(_) -> line.ingredients
 						}
					})
				}
			)

		}
	)
}

fn extract_singles(
		input_table: Map(String, Set(String)),
		output_table: Map(String, String),
		failures
	) {

	case map.size(input_table) {
		0 -> output_table
		_ -> {
			case extract_single(input_table) {
				Error(_) -> {
					output_table
				}
				Ok(t) -> {
					let tuple(all, ing) = t	
					let next_output_table = map.insert(output_table, all, ing)

					// remove from the input table the ingredients already found
					let next_input_table = input_table
						|> map.map_values(fn(k, v) { 
							set.delete(v, ing)
						})
						// remove empty keys
						|> map.filter(fn(k, v) {
							set.size(v) > 0
						})

					extract_singles(next_input_table, next_output_table, 0)
				}
			}


		}
	}
}

fn extract_single(
		input_table: Map(String, Set(String))
	) -> Result(tuple(String, String), String) {

		input_table
		|> map.to_list
		|> list.find_map(fn(t) {
			let tuple(allergen, ingredients) = t
			case ingredients |> set.to_list {
				[ing] -> {
					Ok(tuple(allergen, ing))
				}
				_ -> Error("Not here")
			}
		})
		|> utils.replace_error("Not found")
}
