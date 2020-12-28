import day24.{Acc, Coor, E, SE, SW, W, NW, NE, White, Black}
import gleam/should
import gleam/map

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

pub fn follow_instructions_test() {
	[
		[E, SE, W]
	] |> day24.follow_instructions(
		Acc(Coor(0,0), map.new())
	)
	|> should.equal(
		Acc(
			Coor(0,0),
			[tuple(Coor(0,1), Black)] |> map.from_list
		)
	)

	[
		[E, SE, W],
		[NW,W,SW,E,E]
	] |> day24.follow_instructions(
		Acc(Coor(0,0), map.new())
	)
	|> should.equal(
		Acc(
			Coor(0,0),
			[
				tuple(Coor(0,1), Black),
				tuple(Coor(0,0), Black)
			] |> map.from_list
		)
	)
}

pub fn get_adjacents_test() {
	day24.get_adjacents(map.new(), Coor(0,0))
	|> should.equal([Black, Black, Black, Black, Black, Black])
}

pub fn transform_tile_test() {
	day24.transform_tile(Black, 0)
	|> should.equal(White)

	day24.transform_tile(Black, 1)
	|> should.equal(Black)

	day24.transform_tile(Black, 2)
	|> should.equal(Black)

	day24.transform_tile(Black, 3)
	|> should.equal(White)

	day24.transform_tile(White, 0)
	|> should.equal(White)

	day24.transform_tile(White, 1)
	|> should.equal(White)

	day24.transform_tile(White, 2)
	|> should.equal(Black)

	day24.transform_tile(White, 3)
	|> should.equal(White)
}

pub fn grow_test() {
	let grid = [
		tuple(Coor(1,1), White)
	] |> map.from_list

	let expected = [
		tuple(Coor(1,1), White),

		tuple(Coor(1,0), Black),
		tuple(Coor(2,0), Black),
		tuple(Coor(2,1), Black),
		tuple(Coor(1,2), Black),
		tuple(Coor(0,2), Black),
		tuple(Coor(0,1), Black),
	] |> map.from_list

	day24.grow(grid)
	|> should.equal(expected)
}

pub fn part1_sample_test() {
	day24.part1(day24.sample)
	|> should.equal(Ok(10))
}

pub fn part1_test() {
	day24.part1(day24.input)
	|> should.equal(Ok(495))
}

pub fn part2_sample_test() {
	day24.part2(day24.sample)
	|> should.equal(Ok(100))
}