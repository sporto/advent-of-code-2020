import day24.{Coor, E, SE, SW, W, NW, NE}
import gleam/should

pub fn move_test() {
	let init = Coor(1,1)

	day24.move(init, E)
		|> should.equal(Coor(2,1))

	day24.move(init, W)
		|> should.equal(Coor(0,1))

	day24.move(init, NW)
		|> should.equal(Coor(1,0))

	day24.move(init, NE)
		|> should.equal(Coor(2,0))

	day24.move(init, SW)
		|> should.equal(Coor(0,2))

	day24.move(init, SE)
		|> should.equal(Coor(1,2))
}

pub fn parse_line_test() {
	day24.parse_line("esenee")
	|> should.equal(Ok([E,SE,NE,E]))

	day24.parse_line("nwwswee")
	|> should.equal(Ok([NW,W,SW,E,E]))
}