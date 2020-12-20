import utils
import gleam/list
import gleam/result
import gleam/int
import gleam/string
import gleam/io

const sample = "data/20/sample.txt"

pub type TileLine = List(Bool)

pub type Tile{
	Tile(
		id: Int,
		lines: List(TileLine),
	)
}

pub type TileInfo{
	TileInfo(
		id: Int,
		left: Int,
		right: Int,
		top: Int,
		bottom: Int,
	)
}

pub fn read(file: String) {
	utils.read_file(file)
	|> utils.replace_error("Could not read file")
	|> result.then(parse_input)
	|> result.map(list.map(_, to_tile_info))
}

fn parse_input(file: String) -> Result(List(Tile), String) {
	file
	|> string.split("\n\n")
	|> list.map(parse_tile)
	|> result.all
}

fn parse_tile(input) {
	let lines = input
	|> string.split("\n")

	case lines {
		[x, ..rest] -> {
			try id = parse_title(x)

			try tile_lines = rest
			|> list.map(parse_tile_line)
			|> result.all
			|> utils.replace_error("Could not parse tile lines")

			Ok(Tile(id: id, lines: tile_lines))
		}
		_ -> Error("Invalid input")
	}
}

fn parse_title(input) {
	input
	|> string.drop_left(5)
	|> string.drop_right(1)
	|> int.parse
	|> utils.replace_error(input)
}

fn parse_tile_line(input) {
	input
	|> string.to_graphemes
	|> list.map(parse_char)
	|> result.all
	|> utils.replace_error(input)
}

fn parse_char(input) {
	case input {
		"." -> Ok(False)
		"#" -> Ok(True)
		_ -> Error(input)
	}
}

fn to_tile_info(tile: Tile) -> TileInfo {
	TileInfo(
		id: tile.id,
		left: left_hash(tile.lines),
		right: right_hash(tile.lines),
		top: top_hash(tile.lines),
		bottom: bottom_hash(tile.lines),
	)
}

fn left_hash(lines) {
	lines
	|> list.map(list.head)
	|> result.all
	|> result.unwrap([])
	|> hash
}

fn right_hash(lines) {
	lines
	|> list.map(list.reverse)
	|> left_hash
}

fn top_hash(lines) {
	lines
	|> list.head
	|> result.unwrap([])
	|> hash
}

fn bottom_hash(lines) {
	lines
	|> list.reverse
	|> top_hash
}

fn hash(line: List(Bool)) {
	utils.from_binary(line)
}

// Entry

pub fn part1_sample() {
	read(sample)
	|> io.debug

	Ok([1])
}