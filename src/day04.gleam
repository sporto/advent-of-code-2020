import utils
import gleam/io
import gleam/list
import gleam/result
import gleam/function
import gleam/string
import gleam/bool
import gleam/map.{Map}

const input = "data/04/input.txt"

fn split_passports(file: String) -> List(String) {
	string.split(file, "\n\n")
}

fn parse_field(input: String)
	-> Result(tuple(String, String), Nil) {
	case string.split(input, ":") {
		[ key, value ] -> Ok(tuple(key, value))
		_ -> Error(Nil)
	}
}

fn parse_passport(input: String)
	-> Result(Map(String, String), Nil) {

	input
		|> string.replace(each: "\n", with: " ")
		|> string.split(" ")
		|> list.map(parse_field)
		|> result.all
		|> result.map(map.from_list)
}

fn validate_passport(passport) -> Bool {
	let required = [
		"ecl",
		"pid",
		"eyr",
		"hcl",
		"byr",
		"iyr",
		"hgt",
	]

	required
	|> list.map(fn(key) {
		map.has_key(passport, key)
	})
	|> list.all(function.identity)
}

fn validate_passports(passports) {
	passports
	|> list.map(validate_passport)
}

pub fn main() {
	let res = utils.read_file(input)
	|> result.map(split_passports)
	|> result.unwrap([])
	|> list.map(parse_passport)
	|> result.all
	|> result.map(validate_passports)
	|> result.unwrap([])
	|> list.map(bool.to_int)
	|> utils.sum

	io.debug(res)

	0
}