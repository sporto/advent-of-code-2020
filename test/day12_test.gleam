import day12
import gleam/should
import gleam/map
import gleam/io

pub fn part1_sample1_test() {
	day12.part1_sample1()
	|> should.equal(Ok(25))
}

pub fn bear_test() {
	day12.bear(90, 90)
	|> should.equal(180)

	day12.bear(270, 90)
	|> should.equal(0)

	day12.bear(270, 180)
	|> should.equal(90)

	day12.bear(90, -90)
	|> should.equal(0)

	day12.bear(90, -180)
	|> should.equal(270)
}

pub fn part1_test() {
	day12.part1_main()
	|> should.equal(Ok(1710))
}
