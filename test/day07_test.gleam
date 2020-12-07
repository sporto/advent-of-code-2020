
import day07
import gleam/should

pub fn parse_content_test() {
	"1 bright white bag"
	|> day07.parse_content
	|> should.equal(
		Ok(tuple(1, "bright white"))
	)

	"2 muted yellow bags."
	|> day07.parse_content
	|> should.equal(
		Ok(tuple(2, "muted yellow"))
	)

	"3 bright white bags"
	|> day07.parse_content
	|> should.equal(
		Ok(tuple(3, "bright white"))
	)

	// "no other bags."
	// |> day07.parse_content
	// |> should.equal(
	// 	Ok(tuple(3, "bright white"))
	// )
}

pub fn parse_line_test() {
	let expected = tuple(
		"light red",
		[
			tuple(1, "bright white"),
			tuple(2, "muted yellow"),
		]
	)

	"light red bags contain 1 bright white bag, 2 muted yellow bags."
	|> day07.parse_line
	|> should.equal(
		Ok(expected)
	)

	"dotted black bags contain no other bags."
	|> day07.parse_line
	|> should.equal(
		Ok(tuple("dotted black", []))
	)
}

pub fn main_test() {
	day07.main()
	|> should.equal(Ok(14177))
}