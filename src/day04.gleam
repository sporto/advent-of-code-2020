import utils
import gleam/io
import gleam/list
import gleam/result
import gleam/function
import gleam/string
import gleam/int
import gleam/bool
import gleam/map.{Map}
import gleam/regex

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
	-> Result(Map(String, String), String) {

	input
		|> string.replace(each: "\n", with: " ")
		|> string.split(" ")
		|> list.map(parse_field)
		|> result.all
		|> result.map_error(fn(_) { "Failed to parse passport" })
		|> result.map(map.from_list)
}

pub fn validate_byr(value) -> Result(String, String) {
	let valid = case int.parse(value) {
		Ok(num) -> num >= 1920 && num <= 2002
		Error(_) -> False
	}

	case valid {
		True -> Ok(value)
		False ->
			Error(string.concat(["Invalid byr ", value]))
	}
}

pub fn validate_iyr(value) -> Result(String, String) {
	let valid = case int.parse(value) {
		Ok(num) -> num >= 2010 && num <= 2020
		Error(_) -> False
	}

	case valid {
		True -> Ok(value)
		False ->
			Error(string.concat(["Invalid iyr ", value]))
	}
}

pub fn validate_eyr(value) -> Result(String, String) {
	let valid = case int.parse(value) {
		Ok(num) -> num >= 2020 && num <= 2030
		Error(_) -> False
	}

	case valid {
		True -> Ok(value)
		False ->
			Error(string.concat(["Invalid eyr ", value]))
	}
}

type Height{
	Cm(Int)
	In(Int)
}

fn parse_height(value) -> Result(Height, Nil) {
	case string.ends_with(value, "cm") {
		True -> {
			let cms = string.replace(value, "cm", "")
			int.parse(cms)
				|> result.map(Cm)
		}
		False -> {
			let inches = string.replace(value, "in", "")
			int.parse(inches)
				|> result.map(In)
		}
	}
}

pub fn validate_hgt(value) -> Result(String, String) {
	let valid = case parse_height(value) {
		Ok(Cm(cms)) -> cms >= 150 && cms <= 193
		Ok(In(ins)) -> ins >= 59 && ins <= 76
		_ -> False
	}

	case valid {
		True -> Ok(value)
		False ->
			Error(string.concat(["Invalid hgt ", value]))
	}
}

pub fn validate_hcl(value) -> Result(String, String) {
	assert Ok(re) = regex.from_string("^([0-9]|[a-f]){6}$")

	let chars = string.drop_left(value, 1)

	let starts_with_hash = string.starts_with(value, "#")
	let has_correct_length = string.length(chars) == 6
	let has_valid_chars = regex.check(re, chars)

	let valid = starts_with_hash && has_correct_length && has_valid_chars

	case valid {
		True -> Ok(value)
		False ->
			Error(string.concat(["Invalid hcl ", value]))
	}
}

pub fn validate_ecl(value) -> Result(String, String) {
	case value {
		"amb" -> Ok(value)
		"blu" -> Ok(value)
		"brn" -> Ok(value)
		"gry" -> Ok(value)
		"grn" -> Ok(value)
		"hzl" -> Ok(value)
		"oth" -> Ok(value)
		_ ->
			Error(string.concat(["Invalid ecl ", value]))
	}
}

pub fn validate_pid(value) -> Result(String, String) {
	let has_correct_length = string.length(value) == 9

	let is_number = case int.parse(value) {
		Ok(_) -> True
		Error(_) -> False
	}

	let valid = has_correct_length && is_number

	case valid {
		True -> Ok(value)
		False ->
			Error(string.concat(["Invalid pid ", value]))
	}
}

pub fn validate_field(passport, key)
		-> Result(String, String)
	{

	case map.get(passport, key) {
		Ok(value) -> {
			case key {
				"ecl" -> validate_ecl(value)
				"pid" -> validate_pid(value)
				"eyr" -> validate_eyr(value)
				"hcl" -> validate_hcl(value)
				"byr" -> validate_byr(value)
				"iyr" -> validate_iyr(value)
				"hgt" -> validate_hgt(value)
			}
		}
		Error(Nil) ->
			Error(string.concat(["Required key not found", key]))
	}
}

type Passport = Map(String, String)

fn validate_passport(
		passport: Passport
	) -> Result(Passport, String) {

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
	|> list.map(validate_field(passport, _))
	|> result.all
	|> result.map(fn(_) { passport } )
}

fn validate_passports(passports) {
	passports
	|> list.map(validate_passport)
}

pub fn parse_and_validate_passport(input) {
	input
	|> parse_passport
	|> result.then(validate_passport)
}

pub fn main() {
	let res = utils.read_file(input)
	|> result.map(split_passports)
	|> result.unwrap([])
	|> list.map(parse_passport)
	|> result.all
	|> result.map(validate_passports)
	|> result.unwrap([])
	|> list.map(result.is_ok)
	|> list.map(bool.to_int)
	|> utils.sum

	io.debug(res)

	0
}