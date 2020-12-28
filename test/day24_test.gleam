import day24.{Coor, E, SE, SW, W, NW, NE}
import gleam/should

const sample = "data/24/sample.txt"

pub fn move_test() {
	let init = Coor(1,1)

	day24.move(E, init)
		|> should.equal(Coor(2,1))

	day24.move(W, init)
		|> should.equal(Coor(0,1))

	day24.move(NW, init)
		|> should.equal(Coor(1,0))

	day24.move(NE, init)
		|> should.equal(Coor(2,0))

	day24.move(SW, init)
		|> should.equal(Coor(0,2))

	day24.move(SE, init)
		|> should.equal(Coor(1,2))
}

pub fn parse_line_test() {
	day24.parse_line("esenee")
	|> should.equal(Ok([E,SE,NE,E]))

	day24.parse_line("nwwswee")
	|> should.equal(Ok([NW,W,SW,E,E]))
}

pub fn walk_test() {
	day24.walk(Coor(0,0), [E, SE, W, NW])
	|> should.equal(Coor(0,0))

	day24.walk(Coor(3,0), [SW, NW, SW, NW])
	|> should.equal(Coor(1,0))
}

pub fn part1_sample_10_test() {
	day24.part1(sample)
	|> should.equal(Ok(1))
}