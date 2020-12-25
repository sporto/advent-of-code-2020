import utils
import gleam/int

const player1 = "data/22/player1.txt"
const player2 = "data/22/player2.txt"
const sample1 = "data/22/sample-player1.txt"
const sample2 = "data/22/sample-player2.txt"

fn read(file) {
	utils.get_input_lines(file, parse_line)
}

fn parse_line(line) {
	int.parse(line) |> utils.replace_error(line)
}

pub fn part1_sample() {
	part1(sample1, sample2)
}

fn part1(file1, file2) {
	try deck1 = read(file1)
	try deck2 = read(file2)

	Ok(1)
}