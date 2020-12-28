import day24.{Coor}
import gleam/should

pub fn move_test() {
	let init = Coor(1,1)

	day24.move(init, day24.N)
		|> should.equal(Coor(1,0))

	day24.move(init, day24.NW)
		|> should.equal(Coor(0,1))

	day24.move(init, day24.NE)
		|> should.equal(Coor(2,0))

	day24.move(init, day24.S)
		|> should.equal(Coor(1,2))

	day24.move(init, day24.SW)
		|> should.equal(Coor(0,2))

	day24.move(init, day24.SE)
		|> should.equal(Coor(2,1))
}