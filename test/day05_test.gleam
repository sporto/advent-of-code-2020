import day05.{Start,End}
import gleam/should

pub fn split_test() {
	day05.split([1,2], Start)
	|> should.equal([1])

	day05.split([1,2], End)
	|> should.equal([2])

	day05.split([1,2,3,4], Start)
	|> should.equal([1,2])

	day05.split([1,2,3,4], End)
	|> should.equal([3,4])
}

pub fn reduce_test() {
	day05.reduce([1,2,3,4], [Start, Start])
	|> should.equal([1])

	day05.reduce([1,2,3,4], [Start, End])
	|> should.equal([2])

	day05.reduce([1,2,3,4], [End, Start])
	|> should.equal([3])

	day05.reduce([1,2,3,4,5,6,7,8], [End, Start, End])
	|> should.equal([6])

	// to many reductions
	day05.reduce([1,2,3,4], [End, Start, End])
	|> should.equal([3])
}

pub fn find_row_test() {
	day05.find_row("FBFBBFFRLR")
	|> should.equal(44)
}

pub fn find_col_test() {
	day05.find_col("RLR")
	|> should.equal(5)
}

pub fn find_seat_test() {
	day05.find_seat("FBFBBFFRLR")
	|> should.equal(tuple(44, 5))
}

pub fn seat_id_test() {
	day05.seat_id("FBFBBFFRLR")
	|> should.equal(357)

	day05.seat_id("BFFFBBFRRR")
	|> should.equal(567)

	day05.seat_id("FFFBBBFRRR")
	|> should.equal(119)

	day05.seat_id("BBFFBBFRLL")
	|> should.equal(820)
}

pub fn main_test() {
	day05.main() |> should.equal(1)
}